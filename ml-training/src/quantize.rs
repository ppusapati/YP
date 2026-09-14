//! Int8 weight quantization for on-device inference.
//!
//! Phones care about download size and memory far more than about the last
//! fraction of a percent of accuracy. Storing weights as int8 with a per-tensor
//! scale cuts the file to roughly a quarter and leaves the graph otherwise
//! untouched: a `DequantizeLinear` in front of each quantized initializer
//! restores float values, so any ONNX runtime that implements opset 10 can run
//! the result without special support.
//!
//! Only large tensors are quantized. Biases and BatchNorm parameters are a
//! rounding error in file size but are exactly where low precision does the
//! most damage, so they stay float.
//!
//! This is weight-only (post-training) quantization: activations stay float32.
//! Producing a fully int8 TFLite model needs the TensorFlow converter, which is
//! outside this pure-Rust pipeline; the int8 ONNX here is the portable
//! artifact, and converters accept it as input.

use std::path::Path;

use prost::Message;
use serde::{Deserialize, Serialize};

use crate::compose::decode_model;
use crate::onnx_proto::{self as onnx, TensorProto};

/// Tensors smaller than this keep full precision.
pub const DEFAULT_MIN_ELEMENTS: usize = 1024;

/// `DequantizeLinear` requires opset 10.
const MIN_OPSET: i64 = 10;

const PREFIX: &str = "yp_q_";

/// What quantization did, for logs and run metadata.
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct QuantizationReport {
    pub tensors_quantized: usize,
    pub tensors_kept_float: usize,
    pub values_quantized: usize,
    pub original_bytes: usize,
    pub quantized_bytes: usize,
    /// Largest absolute error introduced in any quantized weight.
    pub max_weight_error: f32,
}

impl QuantizationReport {
    pub fn size_reduction_pct(&self) -> f64 {
        if self.original_bytes == 0 {
            return 0.0;
        }
        (1.0 - self.quantized_bytes as f64 / self.original_bytes as f64) * 100.0
    }
}

/// Quantize the large float initializers of an ONNX model to int8.
pub fn quantize_bytes(
    model_bytes: &[u8],
    min_elements: usize,
) -> anyhow::Result<(Vec<u8>, QuantizationReport)> {
    let mut model = decode_model(model_bytes)?;

    let opset = model
        .opset_import
        .iter()
        .find(|o| o.domain.is_empty() || o.domain == "ai.onnx")
        .map(|o| o.version)
        .unwrap_or(0);
    if opset < MIN_OPSET {
        anyhow::bail!(
            "model uses opset {opset}; int8 quantization needs opset {MIN_OPSET} or newer"
        );
    }

    let graph = model
        .graph
        .as_mut()
        .ok_or_else(|| anyhow::anyhow!("model has no graph"))?;

    let mut report = QuantizationReport {
        original_bytes: model_bytes.len(),
        ..Default::default()
    };
    let mut dequant_nodes = Vec::new();
    let mut extra_initializers = Vec::new();

    for tensor in graph.initializer.iter_mut() {
        let values = match tensor.as_f32() {
            Some(v) if v.len() >= min_elements.max(1) => v,
            _ => {
                report.tensors_kept_float += 1;
                continue;
            }
        };
        // A graph input of the same name would make the initializer a default
        // rather than a constant; renaming it would change semantics.
        if graph.input.iter().any(|i| i.name == tensor.name) {
            report.tensors_kept_float += 1;
            continue;
        }

        let scale = symmetric_scale(&values);
        if scale == 0.0 {
            // An all-zero tensor quantizes to nothing useful; leave it alone.
            report.tensors_kept_float += 1;
            continue;
        }

        let quantized: Vec<i8> = values
            .iter()
            .map(|&v| (v / scale).round().clamp(-127.0, 127.0) as i8)
            .collect();
        let error = values
            .iter()
            .zip(&quantized)
            .map(|(&v, &q)| (v - q as f32 * scale).abs())
            .fold(0.0f32, f32::max);
        report.max_weight_error = report.max_weight_error.max(error);
        report.values_quantized += values.len();
        report.tensors_quantized += 1;

        let float_name = tensor.name.clone();
        let q_name = format!("{PREFIX}{float_name}_i8");
        let scale_name = format!("{PREFIX}{float_name}_scale");
        let zero_name = format!("{PREFIX}{float_name}_zero");

        let dims = tensor.dims.clone();
        *tensor = TensorProto {
            name: q_name.clone(),
            dims,
            data_type: onnx::INT8,
            raw_data: quantized.iter().map(|&q| q as u8).collect(),
            ..Default::default()
        };

        extra_initializers.push(TensorProto::floats(&scale_name, &[], &[scale]));
        extra_initializers.push(TensorProto {
            name: zero_name.clone(),
            dims: vec![],
            data_type: onnx::INT8,
            raw_data: vec![0u8],
            ..Default::default()
        });

        dequant_nodes.push(onnx::node(
            &format!("{PREFIX}{float_name}_dequant"),
            "DequantizeLinear",
            &[&q_name, &scale_name, &zero_name],
            &[&float_name],
        ));
    }

    if dequant_nodes.is_empty() {
        // Nothing was large enough to be worth quantizing. That is a valid
        // outcome, not a failure: the report says so and the bytes are
        // returned unchanged so callers can skip writing a pointless copy.
        return Ok((
            model_bytes.to_vec(),
            QuantizationReport {
                quantized_bytes: model_bytes.len(),
                ..report
            },
        ));
    }

    graph.initializer.extend(extra_initializers);
    // Dequantize nodes read only initializers, so placing them first keeps the
    // graph topologically ordered.
    dequant_nodes.extend(std::mem::take(&mut graph.node));
    graph.node = dequant_nodes;

    let mut buf = Vec::new();
    model.encode(&mut buf)?;
    report.quantized_bytes = buf.len();
    Ok((buf, report))
}

/// Quantize `input` and write the result to `output`.
///
/// When no tensor is large enough to be worth quantizing, nothing is written
/// and the returned report has `tensors_quantized == 0`.
pub fn quantize_file(
    input: &Path,
    output: &Path,
    min_elements: usize,
) -> anyhow::Result<QuantizationReport> {
    let bytes = std::fs::read(input)?;
    let (quantized, report) = quantize_bytes(&bytes, min_elements)?;
    if report.tensors_quantized == 0 {
        tracing::info!(
            path = %input.display(),
            min_elements,
            "no tensor large enough to quantize; keeping the float model only"
        );
        return Ok(report);
    }
    if let Some(parent) = output.parent() {
        std::fs::create_dir_all(parent)?;
    }
    std::fs::write(output, &quantized)?;
    tracing::info!(
        path = %output.display(),
        tensors = report.tensors_quantized,
        original_kb = report.original_bytes / 1024,
        quantized_kb = report.quantized_bytes / 1024,
        reduction_pct = format!("{:.1}", report.size_reduction_pct()),
        "int8 model written"
    );
    Ok(report)
}

/// Per-tensor symmetric scale mapping the largest magnitude onto 127.
fn symmetric_scale(values: &[f32]) -> f32 {
    let max_abs = values
        .iter()
        .filter(|v| v.is_finite())
        .fold(0.0f32, |acc, &v| acc.max(v.abs()));
    if max_abs == 0.0 {
        0.0
    } else {
        max_abs / 127.0
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::compose::synthetic::synthetic_backbone;

    fn graph_of(bytes: &[u8]) -> crate::onnx_proto::GraphProto {
        decode_model(bytes).unwrap().graph.unwrap()
    }

    #[test]
    fn scale_maps_extreme_to_127() {
        assert_eq!(symmetric_scale(&[0.0, 0.0]), 0.0);
        let s = symmetric_scale(&[-2.54, 1.0]);
        assert!((s - 0.02).abs() < 1e-6, "{s}");
        assert_eq!(((-2.54f32) / s).round(), -127.0);
        // NaNs must not poison the range.
        assert!(symmetric_scale(&[f32::NAN, 1.27]) > 0.0);
    }

    #[test]
    fn quantization_shrinks_the_model_and_rewires_weights() {
        // 64 channels keeps the conv weight well over the element threshold.
        let backbone = synthetic_backbone(32, 64, 200);
        let (quantized, report) = quantize_bytes(&backbone, DEFAULT_MIN_ELEMENTS).unwrap();

        assert!(report.tensors_quantized >= 2, "{report:?}");
        assert!(report.tensors_kept_float >= 1, "biases stay float");
        assert!(
            quantized.len() < backbone.len(),
            "quantized {} vs original {}",
            quantized.len(),
            backbone.len()
        );
        assert!(report.size_reduction_pct() > 40.0, "{report:?}");

        let graph = graph_of(&quantized);
        let dequants = graph
            .node
            .iter()
            .filter(|n| n.op_type == "DequantizeLinear")
            .count();
        assert_eq!(dequants, report.tensors_quantized);
        // Dequantize nodes come first so the graph stays topologically sorted.
        for n in graph.node.iter().take(dequants) {
            assert_eq!(n.op_type, "DequantizeLinear");
        }
        // The original float names are still produced, so consumers are intact.
        assert!(graph.produces("conv.weight"));
        assert!(graph
            .initializer
            .iter()
            .any(|t| t.name.ends_with("_i8") && t.data_type == onnx::INT8));
        // Biases are untouched.
        assert!(graph
            .initializer
            .iter()
            .any(|t| t.name == "conv.bias" && t.data_type == onnx::FLOAT));
    }

    #[test]
    fn quantization_error_stays_within_one_step() {
        let backbone = synthetic_backbone(32, 64, 200);
        let (_, report) = quantize_bytes(&backbone, DEFAULT_MIN_ELEMENTS).unwrap();
        // Rounding to the nearest of 255 levels cannot exceed half a step.
        assert!(report.max_weight_error > 0.0);
        assert!(
            report.max_weight_error < 0.01,
            "unexpectedly large weight error {}",
            report.max_weight_error
        );
        assert!(report.values_quantized > 1000);
    }

    #[test]
    fn nothing_large_enough_is_a_reported_no_op() {
        let backbone = synthetic_backbone(32, 64, 200);
        let (bytes, report) = quantize_bytes(&backbone, 100_000).unwrap();
        assert_eq!(report.tensors_quantized, 0);
        assert_eq!(bytes, backbone, "model must come back untouched");
        assert_eq!(report.size_reduction_pct(), 0.0);

        // And no file is written for a no-op.
        let dir = tempfile::tempdir().unwrap();
        let input = dir.path().join("model.onnx");
        let output = dir.path().join("model.int8.onnx");
        std::fs::write(&input, &backbone).unwrap();
        let report = quantize_file(&input, &output, 100_000).unwrap();
        assert_eq!(report.tensors_quantized, 0);
        assert!(!output.exists());
    }

    #[test]
    fn old_opsets_are_refused() {
        let mut model = decode_model(&synthetic_backbone(32, 64, 200)).unwrap();
        model.opset_import[0].version = 9;
        let mut bytes = Vec::new();
        model.encode(&mut bytes).unwrap();
        let err = quantize_bytes(&bytes, DEFAULT_MIN_ELEMENTS)
            .unwrap_err()
            .to_string();
        assert!(err.contains("opset 9"), "{err}");
    }

    #[test]
    fn quantize_file_writes_and_reports() {
        let dir = tempfile::tempdir().unwrap();
        let input = dir.path().join("model.onnx");
        let output = dir.path().join("nested/model.int8.onnx");
        std::fs::write(&input, synthetic_backbone(32, 64, 200)).unwrap();

        let report = quantize_file(&input, &output, DEFAULT_MIN_ELEMENTS).unwrap();
        assert!(output.exists());
        assert_eq!(
            std::fs::metadata(&output).unwrap().len() as usize,
            report.quantized_bytes
        );
        assert!(report.quantized_bytes < report.original_bytes);
    }
}
