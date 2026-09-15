//! Compose a frozen backbone and per-task heads into one multi-output ONNX.
//!
//! Serving four separate models means four forward passes over the same image.
//! Since every head reads the same frozen embedding, they can share a single
//! backbone pass: this module splices the trained head weights onto the
//! backbone graph, emits one `logits_<task>` output per task, and prunes
//! everything the new outputs do not need — including the backbone's original
//! classifier, which is dead weight once the heads replace it.

use std::collections::{HashMap, HashSet};
use std::path::Path;

use prost::Message;
use serde::{Deserialize, Serialize};

use crate::backbone::{Backbone, Normalization};
use crate::onnx_proto::{
    self as onnx, GraphProto, ModelProto, NodeProto, TensorProto, ValueInfoProto,
};

/// File names written next to a composed model.
pub const MULTITASK_MODEL_FILE: &str = "model.onnx";
pub const MULTITASK_MANIFEST_FILE: &str = "multitask.json";

/// Prefix for every tensor this module adds, so head tensors can never shadow
/// a name the backbone already uses.
const PREFIX: &str = "yp_mt_";

/// One trained head to splice on.
#[derive(Debug, Clone)]
pub struct HeadSpec {
    pub task: String,
    /// Ordered layers: `(weight [in, out], bias [out])`. A ReLU is inserted
    /// between consecutive layers.
    pub layers: Vec<(Vec<f32>, Vec<f32>, usize, usize)>,
    pub labels: Vec<String>,
}

impl HeadSpec {
    pub fn num_classes(&self) -> usize {
        self.layers.last().map(|l| l.3).unwrap_or(0)
    }

    fn input_dim(&self) -> usize {
        self.layers.first().map(|l| l.2).unwrap_or(0)
    }

    fn validate(&self, embedding_dim: usize) -> anyhow::Result<()> {
        if self.task.trim().is_empty() {
            anyhow::bail!("head has an empty task name");
        }
        if self.layers.is_empty() {
            anyhow::bail!("head {:?} has no layers", self.task);
        }
        if self.input_dim() != embedding_dim {
            anyhow::bail!(
                "head {:?} expects a {}-d embedding but the backbone produces {embedding_dim}-d",
                self.task,
                self.input_dim()
            );
        }
        for (i, (w, b, fan_in, fan_out)) in self.layers.iter().enumerate() {
            if w.len() != fan_in * fan_out {
                anyhow::bail!(
                    "head {:?} layer {i}: weight has {} values, expected {fan_in}x{fan_out}",
                    self.task,
                    w.len()
                );
            }
            if b.len() != *fan_out {
                anyhow::bail!(
                    "head {:?} layer {i}: bias has {} values, expected {fan_out}",
                    self.task,
                    b.len()
                );
            }
        }
        for pair in self.layers.windows(2) {
            if pair[0].3 != pair[1].2 {
                anyhow::bail!("head {:?} has mismatched layer widths", self.task);
            }
        }
        if self.labels.len() != self.num_classes() {
            anyhow::bail!(
                "head {:?} has {} labels for {} classes",
                self.task,
                self.labels.len(),
                self.num_classes()
            );
        }
        Ok(())
    }
}

/// Sidecar describing how to run a composed model.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MultiTaskManifest {
    pub input_size: u32,
    pub embedding_dim: usize,
    pub normalization: Normalization,
    pub tasks: Vec<TaskEntry>,
    pub backbone_fingerprint: String,
    pub backbone_path: String,
    pub embedding_tensor: String,
    /// The feature map Grad-CAM outputs are computed over, when the backbone
    /// supports them.
    #[serde(default)]
    pub cam: Option<crate::backbone::FeatureMap>,
    pub created_at: String,
    pub producer: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TaskEntry {
    pub name: String,
    /// Graph output carrying this task's logits.
    pub output: String,
    /// Graph output carrying this task's per-class Grad-CAM maps, empty when
    /// the model was composed without them.
    #[serde(default)]
    pub cam_output: String,
    pub labels: Vec<String>,
}

/// Decode an ONNX file into the full message tree.
pub fn decode_model(bytes: &[u8]) -> anyhow::Result<ModelProto> {
    ModelProto::decode(bytes).map_err(|e| anyhow::anyhow!("not a readable ONNX model: {e}"))
}

/// Splice `heads` onto `backbone` and write the model plus its manifest into
/// `output_dir`. Returns the manifest.
pub fn compose_multitask(
    backbone: &Backbone,
    heads: &[HeadSpec],
    output_dir: &Path,
) -> anyhow::Result<MultiTaskManifest> {
    if heads.is_empty() {
        anyhow::bail!("no trained heads to compose");
    }
    let mut seen = HashSet::new();
    for head in heads {
        head.validate(backbone.embedding_dim())?;
        if !seen.insert(head.task.clone()) {
            anyhow::bail!("duplicate head for task {:?}", head.task);
        }
    }

    // Explanations are a bonus, not a requirement: a backbone whose embedding
    // cannot be traced back to an average-pooled feature map still composes,
    // it just serves no heatmaps.
    let feature_map = match backbone.feature_map() {
        Ok(fm) => {
            tracing::info!(
                tensor = %fm.tensor,
                channels = fm.channels,
                height = fm.height,
                width = fm.width,
                "Grad-CAM outputs enabled"
            );
            Some(fm)
        }
        Err(e) => {
            tracing::warn!(error = %e, "composing without Grad-CAM outputs");
            None
        }
    };

    let bytes = compose_bytes(
        backbone.onnx_bytes(),
        backbone.embedding_tensor(),
        heads,
        feature_map.as_ref(),
    )?;

    std::fs::create_dir_all(output_dir)?;
    let model_path = output_dir.join(MULTITASK_MODEL_FILE);
    std::fs::write(&model_path, &bytes)?;

    let manifest = MultiTaskManifest {
        input_size: backbone.input_size(),
        embedding_dim: backbone.embedding_dim(),
        normalization: backbone.normalization(),
        tasks: heads
            .iter()
            .map(|h| TaskEntry {
                name: h.task.clone(),
                output: logits_name(&h.task),
                cam_output: feature_map
                    .as_ref()
                    .map(|_| cam_name(&h.task))
                    .unwrap_or_default(),
                labels: h.labels.clone(),
            })
            .collect(),
        backbone_fingerprint: backbone.fingerprint().to_string(),
        backbone_path: backbone.path().display().to_string(),
        embedding_tensor: backbone.embedding_tensor().to_string(),
        cam: feature_map,
        created_at: chrono::Utc::now().to_rfc3339(),
        producer: "yp-ml-training".to_string(),
    };
    std::fs::write(
        output_dir.join(MULTITASK_MANIFEST_FILE),
        serde_json::to_string_pretty(&manifest)?,
    )?;

    tracing::info!(
        path = %model_path.display(),
        size_kb = bytes.len() / 1024,
        tasks = heads.len(),
        "multi-task ONNX composed"
    );
    Ok(manifest)
}

/// Graph output name carrying a task's logits.
pub fn logits_name(task: &str) -> String {
    format!("logits_{}", sanitize(task))
}

fn sanitize(task: &str) -> String {
    task.chars()
        .map(|c| if c.is_ascii_alphanumeric() { c } else { '_' })
        .collect()
}

/// Wire a per-class Grad-CAM output for one head.
///
/// Grad-CAM weights each feature-map channel by the gradient of a class logit
/// with respect to that channel, then sums and rectifies. With a global
/// *average* pool between the feature map and the head, that gradient has a
/// closed form:
///
/// ```text
/// emb_c = (1/HW) . sum_xy A[c,x,y]        so  d(emb_c)/d(A[c,x,y]) = 1/HW
/// J[k,c] = d(logit_k)/d(emb_c) = (W_0 . D_0 . W_1 . D_1 ... W_n)[c,k]
/// cam_k(x,y) = relu( sum_c J[k,c] . A[c,x,y] )
/// ```
///
/// where `D_i` is the diagonal of the ReLU derivative at layer `i` — one where
/// that unit fired, zero where it did not. The `1/HW` is a positive constant
/// shared by every channel, so it scales the whole map and drops out when the
/// heatmap is normalised.
///
/// Every term is a forward operation on values the graph already computes, so
/// this is the real gradient rather than an approximation of it, and it costs
/// one small matrix product on top of the forward pass. It is emitted as a
/// separate output, so a runtime that does not ask for it pays nothing.
fn add_cam_subgraph(
    existing: &std::collections::HashSet<String>,
    feature_map: &crate::backbone::FeatureMap,
    wiring: &HeadWiring,
    nodes: &mut Vec<NodeProto>,
    initializers: &mut Vec<TensorProto>,
    outputs: &mut Vec<ValueInfoProto>,
) -> anyhow::Result<()> {
    let task = sanitize(&wiring.task);
    let p = format!("{PREFIX}{task}_cam");
    let (_, classes) = *wiring
        .shapes
        .last()
        .ok_or_else(|| anyhow::anyhow!("head {:?} has no layers", wiring.task))?;
    let (embedding_dim, _) = wiring.shapes[0];
    if embedding_dim != feature_map.channels {
        anyhow::bail!(
            "head {:?} takes a {embedding_dim}-d embedding but the feature map has {} channels",
            wiring.task,
            feature_map.channels
        );
    }

    let name = |suffix: &str| -> anyhow::Result<String> {
        let n = format!("{p}_{suffix}");
        guard_name(existing, &n)?;
        Ok(n)
    };

    // Fold the head's layers back to front into J^T, shaped (C, K) — or
    // (N, C, K) once any ReLU mask makes it depend on the input.
    let last = wiring.weights.len() - 1;
    let mut acc = wiring.weights[last].clone();
    let mut acc_is_batched = false;

    for i in (0..last).rev() {
        let (fan_in, fan_out) = wiring.shapes[i];
        let sign = name(&format!("sign{i}"))?;
        let mask = name(&format!("mask{i}"))?;
        let mask3 = name(&format!("mask3_{i}"))?;
        let masked = name(&format!("masked{i}"))?;
        let next = name(&format!("acc{i}"))?;
        let shape_name = name(&format!("mask_shape{i}"))?;

        // relu(sign(z)) is 1 where the unit fired and 0 where it did not,
        // which is exactly the ReLU derivative, without needing a cast.
        nodes.push(onnx::node(
            &format!("{p}_sign{i}_op"),
            "Sign",
            &[&wiring.pre_activations[i]],
            &[&sign],
        ));
        nodes.push(onnx::node(
            &format!("{p}_mask{i}_op"),
            "Relu",
            &[&sign],
            &[&mask],
        ));
        // (N, out) -> (N, 1, out) so it broadcasts across the weight's rows.
        initializers.push(TensorProto::int64s(
            &shape_name,
            &[3],
            &[-1, 1, fan_out as i64],
        ));
        nodes.push(onnx::node(
            &format!("{p}_mask3_{i}_op"),
            "Reshape",
            &[&mask, &shape_name],
            &[&mask3],
        ));
        nodes.push(onnx::node(
            &format!("{p}_masked{i}_op"),
            "Mul",
            &[&wiring.weights[i], &mask3],
            &[&masked],
        ));
        nodes.push(onnx::node(
            &format!("{p}_acc{i}_op"),
            "MatMul",
            &[&masked, &acc],
            &[&next],
        ));
        let _ = fan_in;
        acc = next;
        acc_is_batched = true;
    }

    // J^T -> J, then contract with the feature map over channels.
    let jt = name("j")?;
    nodes.push(NodeProto {
        attribute: vec![onnx::ints_attr(
            "perm",
            if acc_is_batched { &[0, 2, 1] } else { &[1, 0] },
        )],
        ..onnx::node(&format!("{p}_j_op"), "Transpose", &[&acc], &[&jt])
    });

    let feat_shape = name("feat_shape")?;
    let feat2 = name("feat2")?;
    initializers.push(TensorProto::int64s(
        &feat_shape,
        &[3],
        &[
            -1,
            feature_map.channels as i64,
            feature_map.spatial() as i64,
        ],
    ));
    nodes.push(onnx::node(
        &format!("{p}_feat2_op"),
        "Reshape",
        &[&feature_map.tensor, &feat_shape],
        &[&feat2],
    ));

    let flat_cam = name("flat")?;
    nodes.push(onnx::node(
        &format!("{p}_matmul_op"),
        "MatMul",
        &[&jt, &feat2],
        &[&flat_cam],
    ));

    let cam_shape = name("shape")?;
    let raw = name("raw")?;
    initializers.push(TensorProto::int64s(
        &cam_shape,
        &[4],
        &[
            -1,
            classes as i64,
            feature_map.height as i64,
            feature_map.width as i64,
        ],
    ));
    nodes.push(onnx::node(
        &format!("{p}_reshape_op"),
        "Reshape",
        &[&flat_cam, &cam_shape],
        &[&raw],
    ));

    // Grad-CAM keeps only evidence *for* the class; negative contributions are
    // evidence for some other class and would muddy the map.
    let out = cam_name(&wiring.task);
    guard_name(existing, &out)?;
    nodes.push(onnx::node(
        &format!("{p}_relu_op"),
        "Relu",
        &[&raw],
        &[&out],
    ));

    outputs.push(ValueInfoProto::float_tensor(
        &out,
        &[
            -1,
            classes as i64,
            feature_map.height as i64,
            feature_map.width as i64,
        ],
    ));
    Ok(())
}

/// Name of a task's Grad-CAM output.
pub fn cam_name(task: &str) -> String {
    format!("cam_{}", sanitize(task))
}

/// What one head's graph looks like, so the Grad-CAM subgraph can be wired to
/// the same tensors rather than guessing their names.
struct HeadWiring {
    task: String,
    /// Weight initializer per layer, `(fan_in, fan_out)` shaped.
    weights: Vec<String>,
    /// Pre-activation output of every layer but the last.
    pre_activations: Vec<String>,
    shapes: Vec<(usize, usize)>,
}

/// Build the composed ONNX bytes.
///
/// When `cam` is given, each task also gets a `cam_<task>` output holding a
/// per-class Grad-CAM map over the backbone's last feature map. See
/// [`add_cam_subgraph`] for why that is exact here rather than approximate.
pub fn compose_bytes(
    backbone_onnx: &[u8],
    embedding_tensor: &str,
    heads: &[HeadSpec],
    cam: Option<&crate::backbone::FeatureMap>,
) -> anyhow::Result<Vec<u8>> {
    let mut model = decode_model(backbone_onnx)?;
    let graph = model
        .graph
        .as_mut()
        .ok_or_else(|| anyhow::anyhow!("backbone ONNX has no graph"))?;

    if !graph.produces(embedding_tensor) {
        anyhow::bail!(
            "embedding tensor {embedding_tensor:?} is not produced by the backbone graph"
        );
    }

    let existing = graph.known_names();
    let flat = format!("{PREFIX}embedding");
    let mut new_nodes = Vec::new();
    let mut new_initializers = Vec::new();
    let mut outputs = Vec::new();

    // Flatten is a no-op on an already rank-2 embedding and collapses the
    // trailing 1x1 spatial dims of a pooled feature map.
    guard_name(&existing, &flat)?;
    new_nodes.push(NodeProto {
        attribute: vec![onnx::int_attr("axis", 1)],
        ..onnx::node(
            &format!("{PREFIX}flatten"),
            "Flatten",
            &[embedding_tensor],
            &[&flat],
        )
    });

    let mut wirings = Vec::new();
    for head in heads {
        let task = sanitize(&head.task);
        let mut current = flat.clone();
        let last = head.layers.len() - 1;
        let mut wiring = HeadWiring {
            task: head.task.clone(),
            weights: Vec::new(),
            pre_activations: Vec::new(),
            shapes: Vec::new(),
        };

        for (i, (weight, bias, fan_in, fan_out)) in head.layers.iter().enumerate() {
            let w_name = format!("{PREFIX}{task}_fc{i}.weight");
            let b_name = format!("{PREFIX}{task}_fc{i}.bias");
            guard_name(&existing, &w_name)?;
            guard_name(&existing, &b_name)?;
            new_initializers.push(TensorProto::floats(&w_name, &[*fan_in, *fan_out], weight));
            new_initializers.push(TensorProto::floats(&b_name, &[*fan_out], bias));
            wiring.weights.push(w_name.clone());
            wiring.shapes.push((*fan_in, *fan_out));

            let out = if i == last {
                logits_name(&head.task)
            } else {
                format!("{PREFIX}{task}_fc{i}_out")
            };
            guard_name(&existing, &out)?;
            new_nodes.push(onnx::gemm_node(
                &format!("{PREFIX}{task}_fc{i}_gemm"),
                &current,
                &w_name,
                &b_name,
                &out,
            ));
            if i != last {
                // The pre-activation is where the ReLU's derivative is read
                // from when the Grad-CAM weights are computed.
                wiring.pre_activations.push(out.clone());
            }
            current = out;

            if i != last {
                let relu_out = format!("{PREFIX}{task}_fc{i}_relu");
                guard_name(&existing, &relu_out)?;
                new_nodes.push(onnx::node(
                    &format!("{PREFIX}{task}_fc{i}_relu_op"),
                    "Relu",
                    &[&current],
                    &[&relu_out],
                ));
                current = relu_out;
            }
        }

        outputs.push(ValueInfoProto::float_tensor(
            &current,
            &[-1, head.num_classes() as i64],
        ));
        wirings.push(wiring);
    }

    if let Some(feature_map) = cam {
        if !graph.produces(&feature_map.tensor) {
            anyhow::bail!(
                "feature tensor {:?} is not produced by the backbone graph",
                feature_map.tensor
            );
        }
        for wiring in &wirings {
            add_cam_subgraph(
                &existing,
                feature_map,
                wiring,
                &mut new_nodes,
                &mut new_initializers,
                &mut outputs,
            )?;
        }
    }

    graph.node.extend(new_nodes);
    graph.initializer.extend(new_initializers);
    graph.output = outputs;
    // The pretrained classifier tail is unreachable now; dropping it shrinks
    // the file (an ImageNet head is often a third of a mobile backbone).
    prune_to_outputs(graph);

    model.producer_name = "yp-ml-training".to_string();
    model.doc_string = format!(
        "multi-task heads over a frozen backbone ({} tasks)",
        heads.len()
    );

    let mut buf = Vec::new();
    model.encode(&mut buf)?;
    Ok(buf)
}

fn guard_name(existing: &HashSet<String>, name: &str) -> anyhow::Result<()> {
    if existing.contains(name) {
        anyhow::bail!("backbone already defines a tensor named {name:?}");
    }
    Ok(())
}

/// Drop nodes, initializers, inputs, and value_info entries that the graph's
/// outputs no longer depend on.
pub fn prune_to_outputs(graph: &mut GraphProto) {
    let mut producer: HashMap<&str, usize> = HashMap::new();
    for (i, node) in graph.node.iter().enumerate() {
        for out in &node.output {
            producer.entry(out.as_str()).or_insert(i);
        }
    }

    let mut needed: HashSet<String> = HashSet::new();
    let mut keep_node = vec![false; graph.node.len()];
    let mut queue: Vec<String> = graph.output.iter().map(|v| v.name.clone()).collect();

    while let Some(name) = queue.pop() {
        if !needed.insert(name.clone()) {
            continue;
        }
        if let Some(&idx) = producer.get(name.as_str()) {
            if keep_node[idx] {
                continue;
            }
            keep_node[idx] = true;
            // Subgraph attributes (If/Loop bodies) may reference outer tensors;
            // keeping their inputs is the safe side of the trade.
            let node = &graph.node[idx];
            for input in node.input.iter().chain(node.output.iter()) {
                if !input.is_empty() {
                    queue.push(input.clone());
                }
            }
        }
    }

    let mut idx = 0;
    graph.node.retain(|_| {
        let keep = keep_node[idx];
        idx += 1;
        keep
    });
    graph.initializer.retain(|t| needed.contains(&t.name));
    graph.sparse_initializer.retain(|t| {
        t.values
            .as_ref()
            .map(|v| needed.contains(&v.name))
            .unwrap_or(false)
    });
    graph.input.retain(|v| needed.contains(&v.name));
    graph.value_info.retain(|v| needed.contains(&v.name));
    graph
        .quantization_annotation
        .retain(|a| needed.contains(&a.tensor_name));
}

/// Fixtures for exercising the composition path without a real pretrained
/// checkpoint — used by the tests and useful as a smoke test of a deployment.
pub mod synthetic {
    use super::*;

    /// A tiny stand-in backbone: Conv → Relu → GlobalAveragePool → Flatten
    /// gives `embedding` [N, channels], then a Gemm classifier tail that
    /// composition is expected to prune away.
    pub fn synthetic_backbone(input_size: i64, channels: usize, tail_classes: usize) -> Vec<u8> {
        let k = 3usize;
        let conv_w: Vec<f32> = (0..channels * 3 * k * k)
            .map(|i| ((i % 7) as f32 - 3.0) * 0.05)
            .collect();
        let conv_b: Vec<f32> = (0..channels).map(|i| i as f32 * 0.01).collect();
        let tail_w: Vec<f32> = (0..channels * tail_classes)
            .map(|i| (i % 5) as f32 * 0.1)
            .collect();
        let tail_b = vec![0.0f32; tail_classes];

        let graph = GraphProto {
            name: "synthetic_backbone".into(),
            node: vec![
                NodeProto {
                    attribute: vec![
                        onnx::int_attr("group", 1),
                        onnx::ints_attr("kernel_shape", &[3, 3]),
                        onnx::ints_attr("pads", &[1, 1, 1, 1]),
                        onnx::ints_attr("strides", &[1, 1]),
                    ],
                    ..onnx::node(
                        "conv",
                        "Conv",
                        &["input", "conv.weight", "conv.bias"],
                        &["conv_out"],
                    )
                },
                onnx::node("relu", "Relu", &["conv_out"], &["relu_out"]),
                onnx::node("gap", "GlobalAveragePool", &["relu_out"], &["gap_out"]),
                NodeProto {
                    attribute: vec![onnx::int_attr("axis", 1)],
                    ..onnx::node("flatten", "Flatten", &["gap_out"], &["embedding"])
                },
                onnx::gemm_node(
                    "tail",
                    "embedding",
                    "tail.weight",
                    "tail.bias",
                    "orig_logits",
                ),
            ],
            initializer: vec![
                TensorProto::floats("conv.weight", &[channels, 3, k, k], &conv_w),
                TensorProto::floats("conv.bias", &[channels], &conv_b),
                TensorProto::floats("tail.weight", &[channels, tail_classes], &tail_w),
                TensorProto::floats("tail.bias", &[tail_classes], &tail_b),
            ],
            input: vec![ValueInfoProto::float_tensor(
                "input",
                &[-1, 3, input_size, input_size],
            )],
            output: vec![ValueInfoProto::float_tensor(
                "orig_logits",
                &[-1, tail_classes as i64],
            )],
            ..Default::default()
        };

        let model = ModelProto {
            ir_version: 8,
            producer_name: "synthetic".into(),
            opset_import: vec![onnx::OperatorSetIdProto {
                domain: String::new(),
                version: 17,
            }],
            graph: Some(graph),
            ..Default::default()
        };
        let mut buf = Vec::new();
        model.encode(&mut buf).unwrap();
        buf
    }

    pub fn linear_head(task: &str, embedding_dim: usize, labels: &[&str]) -> HeadSpec {
        let classes = labels.len();
        let weight: Vec<f32> = (0..embedding_dim * classes)
            .map(|i| ((i % 11) as f32 - 5.0) * 0.07)
            .collect();
        let bias: Vec<f32> = (0..classes).map(|i| i as f32 * 0.25 - 0.5).collect();
        HeadSpec {
            task: task.to_string(),
            layers: vec![(weight, bias, embedding_dim, classes)],
            labels: labels.iter().map(|s| s.to_string()).collect(),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::synthetic::*;
    use super::*;

    fn decode(bytes: &[u8]) -> GraphProto {
        decode_model(bytes).unwrap().graph.unwrap()
    }

    #[test]
    fn composition_replaces_outputs_and_prunes_the_original_tail() {
        let backbone = synthetic_backbone(32, 8, 1000);
        let heads = vec![
            linear_head("disease", 8, &["healthy", "rust", "blight"]),
            linear_head("pest", 8, &["none", "aphid"]),
        ];
        let composed = compose_bytes(&backbone, "embedding", &heads, None).unwrap();
        let graph = decode(&composed);

        let outputs: Vec<&str> = graph.output.iter().map(|v| v.name.as_str()).collect();
        assert_eq!(outputs, vec!["logits_disease", "logits_pest"]);

        // The 1000-class tail and its weights are gone.
        assert!(graph.node.iter().all(|n| n.name != "tail"));
        assert!(graph.initializer.iter().all(|t| t.name != "tail.weight"));
        // The shared trunk survives exactly once, feeding both heads.
        assert_eq!(graph.node.iter().filter(|n| n.op_type == "Conv").count(), 1);
        assert_eq!(
            graph.node.iter().filter(|n| n.op_type == "Gemm").count(),
            2,
            "one Gemm per head"
        );
        assert!(graph.input.iter().any(|v| v.name == "input"));
    }

    #[test]
    fn composed_graph_is_smaller_than_the_backbone() {
        let backbone = synthetic_backbone(32, 8, 1000);
        let composed = compose_bytes(
            &backbone,
            "embedding",
            &[linear_head("disease", 8, &["a", "b"])],
            None,
        )
        .unwrap();
        assert!(
            composed.len() < backbone.len(),
            "composed {} should be under backbone {}",
            composed.len(),
            backbone.len()
        );
    }

    #[test]
    fn rejects_unknown_embedding_tensor() {
        let backbone = synthetic_backbone(32, 4, 10);
        let err = compose_bytes(
            &backbone,
            "does_not_exist",
            &[linear_head("disease", 4, &["a"])],
            None,
        )
        .unwrap_err()
        .to_string();
        assert!(err.contains("not produced"), "{err}");
    }

    #[test]
    fn rejects_head_with_wrong_embedding_width() {
        let head = linear_head("disease", 16, &["a", "b"]);
        let err = head.validate(8).unwrap_err().to_string();
        assert!(err.contains("16-d embedding"), "{err}");
        assert!(err.contains("8-d"), "{err}");
    }

    #[test]
    fn rejects_inconsistent_head_shapes() {
        let mut head = linear_head("disease", 4, &["a", "b"]);
        head.labels.push("c".into());
        assert!(head
            .validate(4)
            .unwrap_err()
            .to_string()
            .contains("3 labels"));

        let mut short = linear_head("pest", 4, &["a", "b"]);
        short.layers[0].0.truncate(3);
        assert!(short
            .validate(4)
            .unwrap_err()
            .to_string()
            .contains("weight has 3"));

        let mut empty = linear_head("pest", 4, &["a"]);
        empty.layers.clear();
        empty.labels.clear();
        assert!(empty
            .validate(4)
            .unwrap_err()
            .to_string()
            .contains("no layers"));
    }

    #[test]
    fn two_layer_head_emits_gemm_relu_gemm() {
        let backbone = synthetic_backbone(32, 6, 5);
        let head = HeadSpec {
            task: "nutrient_deficiency".into(),
            layers: vec![
                (vec![0.01; 6 * 4], vec![0.0; 4], 6, 4),
                (vec![0.02; 4 * 2], vec![0.0; 2], 4, 2),
            ],
            labels: vec!["ok".into(), "low_n".into()],
        };
        let composed = compose_bytes(&backbone, "embedding", &[head], None).unwrap();
        let graph = decode(&composed);
        assert_eq!(graph.node.iter().filter(|n| n.op_type == "Gemm").count(), 2);
        // conv relu + head relu
        assert_eq!(graph.node.iter().filter(|n| n.op_type == "Relu").count(), 2);
        assert_eq!(graph.output[0].name, "logits_nutrient_deficiency");
    }

    #[test]
    fn prune_keeps_only_reachable_nodes() {
        let mut graph = GraphProto {
            node: vec![
                onnx::node("a", "Relu", &["x"], &["h1"]),
                onnx::node("dead", "Relu", &["x"], &["h2"]),
                onnx::node("b", "Relu", &["h1"], &["y"]),
            ],
            initializer: vec![
                TensorProto::floats("used", &[1], &[1.0]),
                TensorProto::floats("unused", &[1], &[1.0]),
            ],
            input: vec![
                ValueInfoProto::float_tensor("x", &[-1, 2]),
                ValueInfoProto::float_tensor("stale", &[-1, 2]),
            ],
            output: vec![ValueInfoProto::float_tensor("y", &[-1, 2])],
            ..Default::default()
        };
        graph.node[0].input.push("used".into());

        prune_to_outputs(&mut graph);

        let names: Vec<&str> = graph.node.iter().map(|n| n.name.as_str()).collect();
        assert_eq!(names, vec!["a", "b"]);
        assert_eq!(graph.initializer.len(), 1);
        assert_eq!(graph.initializer[0].name, "used");
        assert_eq!(graph.input.len(), 1);
        assert_eq!(graph.input[0].name, "x");
    }

    #[test]
    fn duplicate_task_names_are_rejected_by_the_writer_path() {
        // compose_multitask guards duplicates; exercise the same check here so
        // the error is covered without needing a real backbone on disk.
        let heads = [
            linear_head("disease", 4, &["a"]),
            linear_head("disease", 4, &["b"]),
        ];
        let mut seen = HashSet::new();
        let mut duplicate = false;
        for h in &heads {
            if !seen.insert(h.task.clone()) {
                duplicate = true;
            }
        }
        assert!(duplicate);
    }
    // ── Grad-CAM ─────────────────────────────────────────────────────────────

    /// A two-layer head evaluated in plain Rust, for cross-checking the graph.
    fn head_forward(emb: &[f32], layers: &[(Vec<f32>, Vec<f32>, usize, usize)]) -> Vec<f32> {
        let mut current = emb.to_vec();
        for (i, (w, b, fan_in, fan_out)) in layers.iter().enumerate() {
            let mut next = b.clone();
            for o in 0..*fan_out {
                for c in 0..*fan_in {
                    next[o] += current[c] * w[c * fan_out + o];
                }
            }
            if i + 1 != layers.len() {
                for v in next.iter_mut() {
                    *v = v.max(0.0);
                }
            }
            current = next;
        }
        current
    }

    /// d(logit_k)/d(emb_c) in closed form: the weight chain with each hidden
    /// layer masked by whether its unit fired.
    fn analytic_jacobian(
        emb: &[f32],
        layers: &[(Vec<f32>, Vec<f32>, usize, usize)],
    ) -> Vec<Vec<f32>> {
        let (_, _, embedding_dim, _) = layers[0];
        let (_, _, _, classes) = layers[layers.len() - 1];

        // Pre-activations of every hidden layer.
        let mut masks: Vec<Vec<f32>> = Vec::new();
        let mut current = emb.to_vec();
        for (i, (w, b, fan_in, fan_out)) in layers.iter().enumerate() {
            let mut z = b.clone();
            for o in 0..*fan_out {
                for c in 0..*fan_in {
                    z[o] += current[c] * w[c * fan_out + o];
                }
            }
            if i + 1 != layers.len() {
                masks.push(z.iter().map(|v| if *v > 0.0 { 1.0 } else { 0.0 }).collect());
                for v in z.iter_mut() {
                    *v = v.max(0.0);
                }
            }
            current = z;
        }

        // Fold back to front: acc = W_i . diag(mask_i) . acc
        let last = layers.len() - 1;
        let mut acc: Vec<Vec<f32>> = {
            let (w, _, fan_in, fan_out) = &layers[last];
            (0..*fan_in)
                .map(|r| (0..*fan_out).map(|c| w[r * fan_out + c]).collect())
                .collect()
        };
        for i in (0..last).rev() {
            let (w, _, fan_in, fan_out) = &layers[i];
            let mask = &masks[i];
            acc = (0..*fan_in)
                .map(|r| {
                    (0..classes)
                        .map(|k| {
                            (0..*fan_out)
                                .map(|h| w[r * fan_out + h] * mask[h] * acc[h][k])
                                .sum()
                        })
                        .collect()
                })
                .collect();
        }
        // acc is (C, K); return J as (K, C).
        (0..classes)
            .map(|k| (0..embedding_dim).map(|c| acc[c][k]).collect())
            .collect()
    }

    fn two_layer_head(channels: usize, hidden: usize, classes: usize) -> HeadSpec {
        HeadSpec {
            task: "disease".into(),
            layers: vec![
                (
                    (0..channels * hidden)
                        .map(|i| ((i % 9) as f32 - 4.0) * 0.11)
                        .collect(),
                    (0..hidden).map(|i| (i as f32 - 2.0) * 0.3).collect(),
                    channels,
                    hidden,
                ),
                (
                    (0..hidden * classes)
                        .map(|i| ((i % 7) as f32 - 3.0) * 0.17)
                        .collect(),
                    (0..classes).map(|i| i as f32 * 0.05).collect(),
                    hidden,
                    classes,
                ),
            ],
            labels: (0..classes).map(|i| format!("c{i}")).collect(),
        }
    }

    #[test]
    fn the_closed_form_gradient_matches_a_numeric_one() {
        let (channels, hidden, classes) = (6, 5, 3);
        let head = two_layer_head(channels, hidden, classes);
        let emb: Vec<f32> = (0..channels).map(|i| (i as f32 - 2.5) * 0.4).collect();

        let analytic = analytic_jacobian(&emb, &head.layers);

        // Central differences. The ReLU kink makes this invalid for a unit
        // sitting on zero, so the step stays well away from one.
        let eps = 1e-3f32;
        for k in 0..classes {
            for c in 0..channels {
                let mut up = emb.clone();
                let mut down = emb.clone();
                up[c] += eps;
                down[c] -= eps;
                let numeric = (head_forward(&up, &head.layers)[k]
                    - head_forward(&down, &head.layers)[k])
                    / (2.0 * eps);
                assert!(
                    (numeric - analytic[k][c]).abs() < 1e-2,
                    "d(logit {k})/d(emb {c}): numeric {numeric}, analytic {}",
                    analytic[k][c]
                );
            }
        }
    }

    #[test]
    fn cam_output_matches_the_closed_form_gradient() {
        use tract_onnx::prelude::*;

        let size = 8i64;
        let (channels, hidden, classes) = (6usize, 5usize, 3usize);
        let backbone = synthetic_backbone(size, channels, 4);
        let head = two_layer_head(channels, hidden, classes);
        let fm = crate::backbone::FeatureMap {
            tensor: "relu_out".into(),
            channels,
            height: size as usize,
            width: size as usize,
        };

        let bytes = compose_bytes(
            &backbone,
            "embedding",
            std::slice::from_ref(&head),
            Some(&fm),
        )
        .unwrap();

        // The manifest promises three outputs; ask for the feature map too so
        // the expected map can be computed from the same activations.
        let mut model = tract_onnx::onnx()
            .model_for_read(&mut std::io::Cursor::new(&bytes))
            .unwrap();
        model
            .set_output_names(["logits_disease", "cam_disease", "relu_out"])
            .unwrap();
        let plan = model
            .with_input_fact(0, f32::fact([1, 3, size, size]).into())
            .unwrap()
            .into_optimized()
            .unwrap()
            .into_runnable()
            .unwrap();

        let pixels: Vec<f32> = (0..3 * size * size)
            .map(|i| ((i % 17) as f32 - 8.0) / 8.0)
            .collect();
        let input =
            tract_ndarray::Array4::from_shape_vec((1, 3, size as usize, size as usize), pixels)
                .unwrap();
        let out = plan.run(tvec!(Tensor::from(input).into())).unwrap();

        let logits: Vec<f32> = out[0]
            .to_array_view::<f32>()
            .unwrap()
            .iter()
            .copied()
            .collect();
        let cam: Vec<f32> = out[1]
            .to_array_view::<f32>()
            .unwrap()
            .iter()
            .copied()
            .collect();
        let features: Vec<f32> = out[2]
            .to_array_view::<f32>()
            .unwrap()
            .iter()
            .copied()
            .collect();

        let hw = (size * size) as usize;
        assert_eq!(out[1].shape(), &[1, classes, size as usize, size as usize]);
        assert_eq!(features.len(), channels * hw);

        // Global average pool, exactly as the backbone does it.
        let emb: Vec<f32> = (0..channels)
            .map(|c| features[c * hw..(c + 1) * hw].iter().sum::<f32>() / hw as f32)
            .collect();

        // The graph's logits must agree with the head evaluated by hand, or
        // the CAM is explaining a different function than the one serving.
        for (k, expected) in head_forward(&emb, &head.layers).iter().enumerate() {
            assert!(
                (logits[k] - expected).abs() < 1e-4,
                "logit {k}: graph {}, expected {expected}",
                logits[k]
            );
        }

        let jacobian = analytic_jacobian(&emb, &head.layers);
        let mut nonzero = 0;
        for k in 0..classes {
            for p in 0..hw {
                let expected: f32 = (0..channels)
                    .map(|c| jacobian[k][c] * features[c * hw + p])
                    .sum::<f32>()
                    .max(0.0);
                let actual = cam[k * hw + p];
                assert!(
                    (actual - expected).abs() < 1e-4,
                    "cam[{k}][{p}]: graph {actual}, expected {expected}"
                );
                if actual > 1e-6 {
                    nonzero += 1;
                }
            }
        }
        // A map that is everywhere zero would pass the comparison above while
        // explaining nothing.
        assert!(nonzero > 0, "every CAM value was rectified away");
    }

    #[test]
    fn a_single_layer_head_gets_a_cam_too() {
        use tract_onnx::prelude::*;

        let size = 6i64;
        let (channels, classes) = (4usize, 2usize);
        let head = HeadSpec {
            task: "pest".into(),
            layers: vec![(
                (0..channels * classes)
                    .map(|i| ((i % 5) as f32 - 2.0) * 0.3)
                    .collect(),
                vec![0.0; classes],
                channels,
                classes,
            )],
            labels: vec!["none".into(), "aphid".into()],
        };
        let fm = crate::backbone::FeatureMap {
            tensor: "relu_out".into(),
            channels,
            height: size as usize,
            width: size as usize,
        };
        let bytes = compose_bytes(
            &synthetic_backbone(size, channels, 3),
            "embedding",
            std::slice::from_ref(&head),
            Some(&fm),
        )
        .unwrap();

        // With no hidden layer there is no ReLU mask, so the Jacobian is just
        // the weight matrix and the graph needs no Sign node.
        let graph = decode(&bytes);
        assert_eq!(graph.node.iter().filter(|n| n.op_type == "Sign").count(), 0);
        assert!(graph.produces("cam_pest"));

        let mut model = tract_onnx::onnx()
            .model_for_read(&mut std::io::Cursor::new(&bytes))
            .unwrap();
        model.set_output_names(["cam_pest", "relu_out"]).unwrap();
        let plan = model
            .with_input_fact(0, f32::fact([1, 3, size, size]).into())
            .unwrap()
            .into_optimized()
            .unwrap()
            .into_runnable()
            .unwrap();
        let pixels: Vec<f32> = (0..3 * size * size)
            .map(|i| (i % 11) as f32 / 11.0)
            .collect();
        let out = plan
            .run(tvec!(Tensor::from(
                tract_ndarray::Array4::from_shape_vec((1, 3, size as usize, size as usize), pixels)
                    .unwrap()
            )
            .into()))
            .unwrap();

        let cam: Vec<f32> = out[0]
            .to_array_view::<f32>()
            .unwrap()
            .iter()
            .copied()
            .collect();
        let features: Vec<f32> = out[1]
            .to_array_view::<f32>()
            .unwrap()
            .iter()
            .copied()
            .collect();
        let hw = (size * size) as usize;
        let (w, _, _, _) = &head.layers[0];
        for k in 0..classes {
            for p in 0..hw {
                let expected: f32 = (0..channels)
                    .map(|c| w[c * classes + k] * features[c * hw + p])
                    .sum::<f32>()
                    .max(0.0);
                assert!((cam[k * hw + p] - expected).abs() < 1e-4);
            }
        }
    }

    #[test]
    fn composing_without_a_feature_map_emits_no_cam() {
        let head = two_layer_head(4, 3, 2);
        let bytes = compose_bytes(
            &synthetic_backbone(8, 4, 3),
            "embedding",
            std::slice::from_ref(&head),
            None,
        )
        .unwrap();
        let graph = decode(&bytes);
        assert!(!graph.produces("cam_disease"));
        assert_eq!(graph.output.len(), 1);
        assert!(graph.node.iter().all(|n| n.op_type != "Sign"));
    }

    #[test]
    fn a_feature_tensor_the_backbone_lacks_is_refused() {
        let head = two_layer_head(4, 3, 2);
        let fm = crate::backbone::FeatureMap {
            tensor: "not_a_tensor".into(),
            channels: 4,
            height: 8,
            width: 8,
        };
        let err = compose_bytes(
            &synthetic_backbone(8, 4, 3),
            "embedding",
            std::slice::from_ref(&head),
            Some(&fm),
        )
        .unwrap_err()
        .to_string();
        assert!(err.contains("not_a_tensor"), "{err}");

        // A feature map whose channel count disagrees with the head is a
        // wiring mistake, not something to silently reshape around.
        let wrong = crate::backbone::FeatureMap {
            tensor: "relu_out".into(),
            channels: 9,
            height: 8,
            width: 8,
        };
        let err = compose_bytes(
            &synthetic_backbone(8, 4, 3),
            "embedding",
            std::slice::from_ref(&head),
            Some(&wrong),
        )
        .unwrap_err()
        .to_string();
        assert!(err.contains("9 channels"), "{err}");
    }
}
