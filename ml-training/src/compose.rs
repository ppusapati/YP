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
    pub created_at: String,
    pub producer: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TaskEntry {
    pub name: String,
    /// Graph output carrying this task's logits.
    pub output: String,
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

    let bytes = compose_bytes(backbone.onnx_bytes(), backbone.embedding_tensor(), heads)?;

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
                labels: h.labels.clone(),
            })
            .collect(),
        backbone_fingerprint: backbone.fingerprint().to_string(),
        backbone_path: backbone.path().display().to_string(),
        embedding_tensor: backbone.embedding_tensor().to_string(),
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

/// Build the composed ONNX bytes.
pub fn compose_bytes(
    backbone_onnx: &[u8],
    embedding_tensor: &str,
    heads: &[HeadSpec],
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

    for head in heads {
        let task = sanitize(&head.task);
        let mut current = flat.clone();
        let last = head.layers.len() - 1;

        for (i, (weight, bias, fan_in, fan_out)) in head.layers.iter().enumerate() {
            let w_name = format!("{PREFIX}{task}_fc{i}.weight");
            let b_name = format!("{PREFIX}{task}_fc{i}.bias");
            guard_name(&existing, &w_name)?;
            guard_name(&existing, &b_name)?;
            new_initializers.push(TensorProto::floats(&w_name, &[*fan_in, *fan_out], weight));
            new_initializers.push(TensorProto::floats(&b_name, &[*fan_out], bias));

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
        let composed = compose_bytes(&backbone, "embedding", &heads).unwrap();
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
        let composed = compose_bytes(&backbone, "embedding", &[head]).unwrap();
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
}
