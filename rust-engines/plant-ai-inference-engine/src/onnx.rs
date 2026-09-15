//! ONNX image classification backed by `tract` (pure Rust, CPU).
//!
//! Loads the models exported by `yp-ml-training` (`model.onnx` plus a label
//! map) and reproduces the training-time preprocessing exactly: resize to the
//! model's input size without cropping, scale to `[0, 1]`, then ImageNet
//! mean/std normalization in NCHW layout.

use std::collections::HashMap;
use std::path::{Path, PathBuf};

use image::imageops::FilterType;
use thiserror::Error;
use tract_onnx::prelude::*;
use tract_onnx::tract_hir::infer::Factoid;

use crate::postprocessing::{postprocess_classification, ClassificationOutput};
use crate::preprocessing::NormalizationParams;

/// File names expected inside a model directory.
pub const MODEL_FILE_NAME: &str = "model.onnx";
pub const LABELS_FILE_NAME: &str = "labels.json";
pub const TRAINING_META_FILE_NAME: &str = "training_meta.json";
pub const VERSION_FILE_NAME: &str = "version.txt";

/// Errors from loading or running an ONNX classifier.
#[derive(Debug, Error)]
pub enum OnnxError {
    #[error("model directory {0} has no {MODEL_FILE_NAME}")]
    MissingModel(PathBuf),
    #[error("no labels found in {0} (expected {LABELS_FILE_NAME} or {TRAINING_META_FILE_NAME})")]
    MissingLabels(PathBuf),
    #[error("labels file is malformed: {0}")]
    MalformedLabels(String),
    #[error("model input must be a rank-4 NCHW float tensor with 3 channels, got {0:?}")]
    UnsupportedInput(Vec<String>),
    #[error("model output has {got} classes but {expected} labels were supplied")]
    LabelCountMismatch { got: usize, expected: usize },
    #[error("image could not be decoded: {0}")]
    ImageDecode(String),
    #[error("tensor has {got} values, expected 3*{size}*{size}")]
    TensorSize { got: usize, size: u32 },
    #[error("io: {0}")]
    Io(#[from] std::io::Error),
    #[error("tract: {0}")]
    Tract(String),
}

impl From<tract_onnx::prelude::TractError> for OnnxError {
    fn from(e: tract_onnx::prelude::TractError) -> Self {
        OnnxError::Tract(format!("{e:?}"))
    }
}

type Plan = SimplePlan<TypedFact, Box<dyn TypedOp>, Graph<TypedFact, Box<dyn TypedOp>>>;

/// A loaded ONNX image classifier.
pub struct OnnxClassifier {
    plan: Plan,
    input_size: u32,
    labels: Vec<String>,
    version: String,
    normalization: NormalizationParams,
}

impl std::fmt::Debug for OnnxClassifier {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("OnnxClassifier")
            .field("input_size", &self.input_size)
            .field("labels", &self.labels.len())
            .field("version", &self.version)
            .finish()
    }
}

impl OnnxClassifier {
    /// Load `model.onnx` and labels from a directory. Labels come from
    /// `labels.json` (an array of names, or a name→index map) or from the
    /// training pipeline's `training_meta.json` (`label_map`). The version is
    /// `version.txt` when present, otherwise the directory name.
    pub fn load_dir(dir: &Path) -> Result<Self, OnnxError> {
        let model_path = dir.join(MODEL_FILE_NAME);
        if !model_path.exists() {
            return Err(OnnxError::MissingModel(dir.to_path_buf()));
        }
        let labels = load_labels(dir)?;
        let version = std::fs::read_to_string(dir.join(VERSION_FILE_NAME))
            .map(|s| s.trim().to_string())
            .ok()
            .filter(|s| !s.is_empty())
            .unwrap_or_else(|| {
                dir.file_name()
                    .map(|n| n.to_string_lossy().to_string())
                    .unwrap_or_else(|| "onnx".to_string())
            });
        let bytes = std::fs::read(&model_path)?;
        Self::from_bytes(&bytes, labels, version)
    }

    /// Build a classifier from ONNX bytes and an ordered label list.
    pub fn from_bytes(
        onnx: &[u8],
        labels: Vec<String>,
        version: impl Into<String>,
    ) -> Result<Self, OnnxError> {
        let mut cursor = std::io::Cursor::new(onnx);
        let model = tract_onnx::onnx().model_for_read(&mut cursor)?;

        // Resolve the static input size from the graph; the batch dim may be symbolic.
        let input_fact = model.input_fact(0)?;
        let dims: Vec<Option<i64>> = input_fact
            .shape
            .dims()
            .map(|d| d.concretize().and_then(|t| t.to_i64().ok()))
            .collect();
        let describe = || {
            dims.iter()
                .map(|d| d.map(|v| v.to_string()).unwrap_or_else(|| "?".to_string()))
                .collect::<Vec<_>>()
        };
        let input_size: u32 = match dims.as_slice() {
            [_, Some(3), Some(h), Some(w)] if h == w && *h > 0 => *h as u32,
            _ => return Err(OnnxError::UnsupportedInput(describe())),
        };

        let model = model
            .with_input_fact(
                0,
                f32::fact([1, 3, input_size as usize, input_size as usize]).into(),
            )?
            .into_optimized()?;
        let plan = model.into_runnable()?;

        let classifier = Self {
            plan,
            input_size,
            labels,
            version: version.into(),
            normalization: NormalizationParams::imagenet(),
        };

        // Validate the output width against the labels with a dry run.
        let probe = vec![0.0f32; classifier.tensor_len()];
        let logits = classifier.classify_tensor(&probe)?;
        if logits.len() != classifier.labels.len() {
            return Err(OnnxError::LabelCountMismatch {
                got: logits.len(),
                expected: classifier.labels.len(),
            });
        }
        Ok(classifier)
    }

    pub fn input_size(&self) -> u32 {
        self.input_size
    }

    pub fn labels(&self) -> &[String] {
        &self.labels
    }

    pub fn version(&self) -> &str {
        &self.version
    }

    pub fn num_classes(&self) -> usize {
        self.labels.len()
    }

    fn tensor_len(&self) -> usize {
        3 * (self.input_size as usize) * (self.input_size as usize)
    }

    /// Decode an encoded image (JPEG/PNG/WebP...) and produce the CHW input
    /// tensor using the training-time preprocessing.
    pub fn preprocess(&self, encoded: &[u8]) -> Result<Vec<f32>, OnnxError> {
        let img =
            image::load_from_memory(encoded).map_err(|e| OnnxError::ImageDecode(e.to_string()))?;
        Ok(self.preprocess_decoded(&img))
    }

    /// Preprocess an already-decoded image.
    pub fn preprocess_decoded(&self, img: &image::DynamicImage) -> Vec<f32> {
        let size = self.input_size;
        let rgb = img.resize_exact(size, size, FilterType::Lanczos3).to_rgb8();
        let (w, h) = rgb.dimensions();
        let (w, h) = (w as usize, h as usize);
        let mut chw = vec![0.0f32; 3 * w * h];
        let mean = self.normalization.mean;
        let std = self.normalization.std;
        for y in 0..h {
            for x in 0..w {
                let p = rgb.get_pixel(x as u32, y as u32);
                for c in 0..3 {
                    let v = p[c] as f32 / 255.0;
                    chw[c * h * w + y * w + x] = (v - mean[c] as f32) / std[c] as f32;
                }
            }
        }
        chw
    }

    /// Run the network on a CHW tensor and return raw logits.
    pub fn classify_tensor(&self, chw: &[f32]) -> Result<Vec<f32>, OnnxError> {
        if chw.len() != self.tensor_len() {
            return Err(OnnxError::TensorSize {
                got: chw.len(),
                size: self.input_size,
            });
        }
        let size = self.input_size as usize;
        let input = tract_ndarray::Array4::from_shape_vec((1, 3, size, size), chw.to_vec())
            .map_err(|e| OnnxError::Tract(e.to_string()))?;
        let outputs = self.plan.run(tvec!(Tensor::from(input).into()))?;
        let view = outputs[0].to_array_view::<f32>()?;
        Ok(view.iter().copied().collect())
    }

    /// Decode, preprocess, run, and rank classes.
    pub fn classify_image(
        &self,
        encoded: &[u8],
        top_k: usize,
    ) -> Result<ClassificationOutput, OnnxError> {
        let chw = self.preprocess(encoded)?;
        let logits = self.classify_tensor(&chw)?;
        Ok(postprocess_classification(
            &logits,
            &self.labels,
            top_k.max(1),
        ))
    }
}

/// Read labels from `labels.json` or `training_meta.json`.
pub fn load_labels(dir: &Path) -> Result<Vec<String>, OnnxError> {
    let labels_path = dir.join(LABELS_FILE_NAME);
    if labels_path.exists() {
        let raw = std::fs::read_to_string(&labels_path)?;
        return parse_labels_json(&raw);
    }
    let meta_path = dir.join(TRAINING_META_FILE_NAME);
    if meta_path.exists() {
        let raw = std::fs::read_to_string(&meta_path)?;
        let meta: serde_json::Value =
            serde_json::from_str(&raw).map_err(|e| OnnxError::MalformedLabels(e.to_string()))?;
        let map = meta.get("label_map").ok_or_else(|| {
            OnnxError::MalformedLabels("training_meta.json has no label_map".into())
        })?;
        return parse_labels_json(&map.to_string());
    }
    Err(OnnxError::MissingLabels(dir.to_path_buf()))
}

/// Accepts `["a","b"]` or `{"a":0,"b":1}` and returns labels ordered by index.
pub fn parse_labels_json(raw: &str) -> Result<Vec<String>, OnnxError> {
    let value: serde_json::Value =
        serde_json::from_str(raw).map_err(|e| OnnxError::MalformedLabels(e.to_string()))?;
    match value {
        serde_json::Value::Array(items) => {
            let labels: Option<Vec<String>> = items
                .into_iter()
                .map(|v| v.as_str().map(str::to_string))
                .collect();
            labels.filter(|l| !l.is_empty()).ok_or_else(|| {
                OnnxError::MalformedLabels("label array must contain strings".into())
            })
        }
        serde_json::Value::Object(map) => {
            let mut by_index: HashMap<usize, String> = HashMap::new();
            for (name, idx) in map {
                let i = idx.as_u64().ok_or_else(|| {
                    OnnxError::MalformedLabels(format!("label {name:?} has non-integer index"))
                })? as usize;
                by_index.insert(i, name);
            }
            let n = by_index.len();
            let mut labels = Vec::with_capacity(n);
            for i in 0..n {
                labels.push(by_index.remove(&i).ok_or_else(|| {
                    OnnxError::MalformedLabels(format!(
                        "label indices are not contiguous (missing {i})"
                    ))
                })?);
            }
            if labels.is_empty() {
                return Err(OnnxError::MalformedLabels("label map is empty".into()));
            }
            Ok(labels)
        }
        _ => Err(OnnxError::MalformedLabels(
            "labels must be an array or object".into(),
        )),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn labels_from_array_and_map() {
        assert_eq!(
            parse_labels_json(r#"["healthy","rust"]"#).unwrap(),
            vec!["healthy", "rust"]
        );
        assert_eq!(
            parse_labels_json(r#"{"rust":1,"healthy":0,"blight":2}"#).unwrap(),
            vec!["healthy", "rust", "blight"]
        );
        assert!(
            parse_labels_json(r#"{"a":0,"b":2}"#).is_err(),
            "gap in indices"
        );
        assert!(parse_labels_json(r#"[]"#).is_err());
        assert!(parse_labels_json(r#"[1,2]"#).is_err());
        assert!(parse_labels_json(r#"42"#).is_err());
    }

    #[test]
    fn labels_from_directory_sources() {
        let dir = tempfile::tempdir().unwrap();
        assert!(matches!(
            load_labels(dir.path()),
            Err(OnnxError::MissingLabels(_))
        ));

        std::fs::write(
            dir.path().join(TRAINING_META_FILE_NAME),
            r#"{"task":"disease","label_map":{"healthy":0,"leaf_spot":1}}"#,
        )
        .unwrap();
        assert_eq!(
            load_labels(dir.path()).unwrap(),
            vec!["healthy", "leaf_spot"]
        );

        // labels.json wins when both exist.
        std::fs::write(dir.path().join(LABELS_FILE_NAME), r#"["x","y","z"]"#).unwrap();
        assert_eq!(load_labels(dir.path()).unwrap(), vec!["x", "y", "z"]);
    }

    #[test]
    fn load_dir_requires_model_file() {
        let dir = tempfile::tempdir().unwrap();
        std::fs::write(dir.path().join(LABELS_FILE_NAME), r#"["a"]"#).unwrap();
        assert!(matches!(
            OnnxClassifier::load_dir(dir.path()),
            Err(OnnxError::MissingModel(_))
        ));
    }

    #[test]
    fn rejects_garbage_model_bytes() {
        assert!(OnnxClassifier::from_bytes(b"not an onnx file", vec!["a".into()], "v").is_err());
    }
}
