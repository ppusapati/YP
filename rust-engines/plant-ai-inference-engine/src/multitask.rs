//! Multi-task ONNX inference: one backbone pass, many heads.
//!
//! Models produced by `yp-ml-training train-heads` carry one `logits_<task>`
//! output per task on top of a shared frozen backbone. Running them through a
//! single plan means the expensive convolutional trunk is evaluated once for
//! all four vision tasks instead of once each — the difference between four
//! model loads and one, which is what makes on-device inference practical.

use std::collections::HashMap;
use std::path::{Path, PathBuf};

use image::imageops::FilterType;
use serde::{Deserialize, Serialize};
use tract_onnx::prelude::*;

use crate::explain::Heatmap;
use crate::onnx::{OnnxError, MODEL_FILE_NAME, VERSION_FILE_NAME};
use crate::postprocessing::{postprocess_classification, ClassificationOutput};

/// Sidecar written next to a composed model.
pub const MANIFEST_FILE_NAME: &str = "multitask.json";

/// Pixel normalization the backbone expects.
#[derive(Debug, Clone, Copy, PartialEq, Serialize, Deserialize)]
pub struct Normalization {
    pub mean: [f32; 3],
    pub std: [f32; 3],
}

impl Default for Normalization {
    fn default() -> Self {
        Self {
            mean: [0.485, 0.456, 0.406],
            std: [0.229, 0.224, 0.225],
        }
    }
}

/// One task carried by a composed model.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TaskEntry {
    pub name: String,
    /// Graph output carrying this task's logits.
    pub output: String,
    /// Graph output carrying per-class Grad-CAM maps, empty when the model was
    /// composed without them.
    #[serde(default)]
    pub cam_output: String,
    pub labels: Vec<String>,
}

/// Index of the largest logit, ties going to the lower index.
fn argmax(values: &[f32]) -> usize {
    values
        .iter()
        .enumerate()
        .fold((0usize, f32::NEG_INFINITY), |best, (i, &v)| {
            if v > best.1 {
                (i, v)
            } else {
                best
            }
        })
        .0
}

/// Shape of the feature map Grad-CAM outputs are computed over.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct CamInfo {
    #[serde(default)]
    pub tensor: String,
    #[serde(default)]
    pub channels: usize,
    pub height: usize,
    pub width: usize,
}

/// Contents of `multitask.json`.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MultiTaskManifest {
    pub input_size: u32,
    #[serde(default)]
    pub embedding_dim: usize,
    #[serde(default)]
    pub normalization: Normalization,
    pub tasks: Vec<TaskEntry>,
    /// Present when the model carries Grad-CAM outputs.
    #[serde(default)]
    pub cam: Option<CamInfo>,
    #[serde(default)]
    pub backbone_fingerprint: String,
    #[serde(default)]
    pub created_at: String,
}

/// A composed backbone + heads model.
pub struct MultiTaskClassifier {
    plan: SimplePlan<TypedFact, Box<dyn TypedOp>, Graph<TypedFact, Box<dyn TypedOp>>>,
    manifest: MultiTaskManifest,
    version: String,
    /// Task name → index into the plan's outputs.
    task_index: HashMap<String, usize>,
    /// Task name → index of its Grad-CAM output, when explanations are on.
    cam_index: HashMap<String, usize>,
}

impl std::fmt::Debug for MultiTaskClassifier {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("MultiTaskClassifier")
            .field("version", &self.version)
            .field("input_size", &self.manifest.input_size)
            .field("tasks", &self.tasks())
            .finish()
    }
}

impl MultiTaskClassifier {
    /// Load `model.onnx` plus `multitask.json` from a directory.
    pub fn load_dir(dir: &Path) -> Result<Self, OnnxError> {
        let model_path = dir.join(MODEL_FILE_NAME);
        if !model_path.exists() {
            return Err(OnnxError::MissingModel(dir.to_path_buf()));
        }
        let manifest_path = dir.join(MANIFEST_FILE_NAME);
        if !manifest_path.exists() {
            return Err(OnnxError::MissingLabels(dir.to_path_buf()));
        }
        let raw = std::fs::read_to_string(&manifest_path)?;
        let manifest: MultiTaskManifest = serde_json::from_str(&raw)
            .map_err(|e| OnnxError::MalformedLabels(format!("{MANIFEST_FILE_NAME}: {e}")))?;

        let version = std::fs::read_to_string(dir.join(VERSION_FILE_NAME))
            .map(|s| s.trim().to_string())
            .ok()
            .filter(|s| !s.is_empty())
            .unwrap_or_else(|| default_version(dir, &manifest));

        Self::from_bytes(&std::fs::read(&model_path)?, manifest, version)
    }

    /// Build from ONNX bytes and a manifest.
    pub fn from_bytes(
        onnx: &[u8],
        manifest: MultiTaskManifest,
        version: impl Into<String>,
    ) -> Result<Self, OnnxError> {
        if manifest.tasks.is_empty() {
            return Err(OnnxError::MalformedLabels(
                "manifest lists no tasks".to_string(),
            ));
        }
        if manifest.input_size == 0 {
            return Err(OnnxError::MalformedLabels(
                "manifest has no input_size".to_string(),
            ));
        }
        for task in &manifest.tasks {
            if task.labels.is_empty() {
                return Err(OnnxError::MalformedLabels(format!(
                    "task {:?} has no labels",
                    task.name
                )));
            }
        }

        let size = manifest.input_size as usize;
        let mut model = tract_onnx::onnx().model_for_read(&mut std::io::Cursor::new(onnx))?;

        // Pin the output order so a task's logits are always read from the slot
        // the manifest claims: logits for every task first, then whichever
        // Grad-CAM maps the model actually carries.
        let mut output_names: Vec<String> =
            manifest.tasks.iter().map(|t| t.output.clone()).collect();
        let mut cam_index = HashMap::new();
        if manifest.cam.is_some() {
            for task in &manifest.tasks {
                if !task.cam_output.is_empty() {
                    cam_index.insert(task.name.clone(), output_names.len());
                    output_names.push(task.cam_output.clone());
                }
            }
        }
        let refs: Vec<&str> = output_names.iter().map(String::as_str).collect();
        model.set_output_names(&refs).map_err(|e| {
            OnnxError::Tract(format!("manifest names an output the model lacks: {e:?}"))
        })?;

        let model = model
            .with_input_fact(0, f32::fact([1, 3, size, size]).into())?
            .into_optimized()?;
        let plan = model.into_runnable()?;

        let task_index = manifest
            .tasks
            .iter()
            .enumerate()
            .map(|(i, t)| (t.name.clone(), i))
            .collect();

        let classifier = Self {
            plan,
            manifest,
            version: version.into(),
            task_index,
            cam_index,
        };

        // A dry run proves every head's width matches its label list, and that
        // each Grad-CAM output has the shape the manifest promises.
        let probe = vec![0.0f32; 3 * size * size];
        let outputs = classifier.run_raw(&probe)?;
        for (i, task) in classifier.manifest.tasks.iter().enumerate() {
            if outputs[i].len() != task.labels.len() {
                return Err(OnnxError::LabelCountMismatch {
                    got: outputs[i].len(),
                    expected: task.labels.len(),
                });
            }
            if let Some(&slot) = classifier.cam_index.get(&task.name) {
                let cam = classifier
                    .manifest
                    .cam
                    .as_ref()
                    .expect("cam slots imply cam info");
                let expected = task.labels.len() * cam.height * cam.width;
                if outputs[slot].len() != expected {
                    return Err(OnnxError::MalformedLabels(format!(
                        "task {:?} Grad-CAM output has {} values, expected {} ({} classes x {}x{})",
                        task.name,
                        outputs[slot].len(),
                        expected,
                        task.labels.len(),
                        cam.height,
                        cam.width
                    )));
                }
            }
        }
        Ok(classifier)
    }

    /// True when this model can explain where a prediction came from.
    pub fn explains(&self) -> bool {
        !self.cam_index.is_empty()
    }

    /// True when this specific task carries a Grad-CAM output.
    pub fn explains_task(&self, task: &str) -> bool {
        self.cam_index.contains_key(task)
    }

    /// Resolution of the Grad-CAM maps, when available.
    pub fn cam_size(&self) -> Option<(usize, usize)> {
        self.manifest.cam.as_ref().map(|c| (c.width, c.height))
    }

    pub fn version(&self) -> &str {
        &self.version
    }

    pub fn input_size(&self) -> u32 {
        self.manifest.input_size
    }

    pub fn manifest(&self) -> &MultiTaskManifest {
        &self.manifest
    }

    /// Task names this model serves, in graph output order.
    pub fn tasks(&self) -> Vec<&str> {
        self.manifest
            .tasks
            .iter()
            .map(|t| t.name.as_str())
            .collect()
    }

    pub fn has_task(&self, task: &str) -> bool {
        self.task_index.contains_key(task)
    }

    /// Class labels for one task.
    pub fn labels(&self, task: &str) -> Option<&[String]> {
        self.task_index
            .get(task)
            .map(|&i| self.manifest.tasks[i].labels.as_slice())
    }

    pub fn num_classes(&self, task: &str) -> usize {
        self.labels(task).map(<[String]>::len).unwrap_or(0)
    }

    /// Decode an image into the CHW tensor this model expects.
    pub fn preprocess(&self, encoded: &[u8]) -> Result<Vec<f32>, OnnxError> {
        let img =
            image::load_from_memory(encoded).map_err(|e| OnnxError::ImageDecode(e.to_string()))?;
        Ok(self.preprocess_decoded(&img))
    }

    /// Preprocess an already-decoded image with the backbone's normalization.
    pub fn preprocess_decoded(&self, img: &image::DynamicImage) -> Vec<f32> {
        let size = self.manifest.input_size;
        let rgb = img.resize_exact(size, size, FilterType::Lanczos3).to_rgb8();
        let (w, h) = (rgb.width() as usize, rgb.height() as usize);
        let mut chw = vec![0.0f32; 3 * w * h];
        let mean = self.manifest.normalization.mean;
        let std = self.manifest.normalization.std;
        for y in 0..h {
            for x in 0..w {
                let p = rgb.get_pixel(x as u32, y as u32);
                for c in 0..3 {
                    let v = p[c] as f32 / 255.0;
                    chw[c * h * w + y * w + x] = (v - mean[c]) / std[c].max(f32::EPSILON);
                }
            }
        }
        chw
    }

    /// One forward pass; returns raw logits per task in manifest order.
    ///
    /// Grad-CAM outputs, if the model has them, are dropped here — use
    /// [`Self::explain`] or [`Self::classify_task_explained`] for those.
    pub fn run(&self, chw: &[f32]) -> Result<Vec<Vec<f32>>, OnnxError> {
        let mut outputs = self.run_raw(chw)?;
        outputs.truncate(self.manifest.tasks.len());
        Ok(outputs)
    }

    /// Every pinned output: task logits, then any Grad-CAM maps.
    fn run_raw(&self, chw: &[f32]) -> Result<Vec<Vec<f32>>, OnnxError> {
        let size = self.manifest.input_size as usize;
        let expected = 3 * size * size;
        if chw.len() != expected {
            return Err(OnnxError::TensorSize {
                got: chw.len(),
                size: self.manifest.input_size,
            });
        }
        let input = tract_ndarray::Array4::from_shape_vec((1, 3, size, size), chw.to_vec())
            .map_err(|e| OnnxError::Tract(e.to_string()))?;
        let outputs = self.plan.run(tvec!(Tensor::from(input).into()))?;
        outputs
            .iter()
            .map(|o| {
                o.to_array_view::<f32>()
                    .map(|v| v.iter().copied().collect())
                    .map_err(OnnxError::from)
            })
            .collect()
    }

    /// Classify an image for every task in one pass.
    pub fn classify_image(
        &self,
        encoded: &[u8],
        top_k: usize,
    ) -> Result<HashMap<String, ClassificationOutput>, OnnxError> {
        let chw = self.preprocess(encoded)?;
        let logits = self.run(&chw)?;
        Ok(self
            .manifest
            .tasks
            .iter()
            .zip(logits)
            .map(|(task, values)| {
                (
                    task.name.clone(),
                    postprocess_classification(&values, &task.labels, top_k.max(1)),
                )
            })
            .collect())
    }

    /// Classify one task and, when the model supports it, say where in the
    /// image the answer came from — both from a single forward pass.
    pub fn classify_task_explained(
        &self,
        task: &str,
        encoded: &[u8],
        top_k: usize,
    ) -> Result<(ClassificationOutput, Option<Heatmap>), OnnxError> {
        let index = self.slot_of(task)?;
        let chw = self.preprocess(encoded)?;
        let outputs = self.run_raw(&chw)?;
        let entry = &self.manifest.tasks[index];
        let output = postprocess_classification(&outputs[index], &entry.labels, top_k.max(1));

        // Explain the class the model actually chose, not a fixed one.
        let predicted = argmax(&outputs[index]);
        let heatmap = self.heatmap_from(task, &outputs, predicted);
        Ok((output, heatmap))
    }

    /// Grad-CAM for one task, defaulting to the predicted class.
    pub fn explain(
        &self,
        task: &str,
        encoded: &[u8],
        class_index: Option<usize>,
    ) -> Result<Heatmap, OnnxError> {
        let index = self.slot_of(task)?;
        if !self.explains_task(task) {
            return Err(OnnxError::MalformedLabels(format!(
                "model carries no Grad-CAM output for task {task:?}"
            )));
        }
        let chw = self.preprocess(encoded)?;
        let outputs = self.run_raw(&chw)?;
        let class = class_index.unwrap_or_else(|| argmax(&outputs[index]));

        let classes = self.manifest.tasks[index].labels.len();
        if class >= classes {
            return Err(OnnxError::MalformedLabels(format!(
                "class {class} is out of range for task {task:?} ({classes} classes)"
            )));
        }
        self.heatmap_from(task, &outputs, class).ok_or_else(|| {
            OnnxError::Tract(format!("Grad-CAM output for task {task:?} was unusable"))
        })
    }

    /// Slice one class's map out of a task's Grad-CAM output.
    fn heatmap_from(&self, task: &str, outputs: &[Vec<f32>], class: usize) -> Option<Heatmap> {
        let slot = *self.cam_index.get(task)?;
        let cam = self.manifest.cam.as_ref()?;
        let entry = self
            .task_index
            .get(task)
            .map(|&i| &self.manifest.tasks[i])?;
        let plane = cam.height * cam.width;
        let start = class * plane;
        let values = outputs.get(slot)?.get(start..start + plane)?;

        Some(Heatmap::new(
            task,
            class,
            entry.labels.get(class).cloned().unwrap_or_default(),
            cam.width,
            cam.height,
            values,
        ))
    }

    fn slot_of(&self, task: &str) -> Result<usize, OnnxError> {
        self.task_index
            .get(task)
            .copied()
            .ok_or_else(|| OnnxError::MalformedLabels(format!("model has no task {task:?}")))
    }

    /// Classify for a single task. The backbone still runs once; the other
    /// heads are a few matrix rows, so this stays far cheaper than a
    /// task-specific model load.
    pub fn classify_task(
        &self,
        task: &str,
        encoded: &[u8],
        top_k: usize,
    ) -> Result<ClassificationOutput, OnnxError> {
        let index = *self
            .task_index
            .get(task)
            .ok_or_else(|| OnnxError::MalformedLabels(format!("model has no task {task:?}")))?;
        let chw = self.preprocess(encoded)?;
        let logits = self.run(&chw)?;
        let entry = &self.manifest.tasks[index];
        Ok(postprocess_classification(
            &logits[index],
            &entry.labels,
            top_k.max(1),
        ))
    }
}

fn default_version(dir: &Path, manifest: &MultiTaskManifest) -> String {
    if manifest.backbone_fingerprint.len() >= 8 {
        return format!("multitask-{}", &manifest.backbone_fingerprint[..8]);
    }
    dir.file_name()
        .map(|n| n.to_string_lossy().to_string())
        .unwrap_or_else(|| "multitask".to_string())
}

/// Directory paths a caller may want to report.
pub fn manifest_path(dir: &Path) -> PathBuf {
    dir.join(MANIFEST_FILE_NAME)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn manifest(tasks: &[(&str, &[&str])]) -> MultiTaskManifest {
        MultiTaskManifest {
            input_size: 32,
            embedding_dim: 8,
            normalization: Normalization::default(),
            tasks: tasks
                .iter()
                .map(|(name, labels)| TaskEntry {
                    name: name.to_string(),
                    output: format!("logits_{name}"),
                    cam_output: String::new(),
                    labels: labels.iter().map(|s| s.to_string()).collect(),
                })
                .collect(),
            cam: None,
            backbone_fingerprint: "abcdef0123456789".into(),
            created_at: "2026-01-01T00:00:00Z".into(),
        }
    }

    #[test]
    fn manifest_round_trips_through_json() {
        let m = manifest(&[("disease", &["healthy", "rust"])]);
        let json = serde_json::to_string(&m).unwrap();
        let back: MultiTaskManifest = serde_json::from_str(&json).unwrap();
        assert_eq!(back.tasks.len(), 1);
        assert_eq!(back.tasks[0].output, "logits_disease");
        assert_eq!(back.input_size, 32);
        assert_eq!(back.normalization.mean, Normalization::default().mean);
    }

    #[test]
    fn manifest_defaults_fill_optional_fields() {
        let json = r#"{"input_size":64,"tasks":[{"name":"pest","output":"logits_pest","labels":["a","b"]}]}"#;
        let m: MultiTaskManifest = serde_json::from_str(json).unwrap();
        assert_eq!(m.input_size, 64);
        assert_eq!(m.normalization, Normalization::default());
        assert!(m.backbone_fingerprint.is_empty());
    }

    #[test]
    fn empty_or_unlabelled_manifests_are_rejected() {
        let mut empty = manifest(&[]);
        empty.tasks.clear();
        let err = MultiTaskClassifier::from_bytes(b"", empty, "v").unwrap_err();
        assert!(matches!(err, OnnxError::MalformedLabels(_)));

        let mut unlabelled = manifest(&[("disease", &["a"])]);
        unlabelled.tasks[0].labels.clear();
        let err = MultiTaskClassifier::from_bytes(b"", unlabelled, "v").unwrap_err();
        assert!(err.to_string().contains("no labels"), "{err}");

        let mut sizeless = manifest(&[("disease", &["a"])]);
        sizeless.input_size = 0;
        let err = MultiTaskClassifier::from_bytes(b"", sizeless, "v").unwrap_err();
        assert!(err.to_string().contains("input_size"), "{err}");
    }

    #[test]
    fn load_dir_requires_model_and_manifest() {
        let dir = tempfile::tempdir().unwrap();
        assert!(matches!(
            MultiTaskClassifier::load_dir(dir.path()),
            Err(OnnxError::MissingModel(_))
        ));
        std::fs::write(dir.path().join(MODEL_FILE_NAME), b"x").unwrap();
        assert!(matches!(
            MultiTaskClassifier::load_dir(dir.path()),
            Err(OnnxError::MissingLabels(_))
        ));
        std::fs::write(manifest_path(dir.path()), "not json").unwrap();
        assert!(matches!(
            MultiTaskClassifier::load_dir(dir.path()),
            Err(OnnxError::MalformedLabels(_))
        ));
    }

    #[test]
    fn version_falls_back_to_the_backbone_fingerprint() {
        let dir = tempfile::tempdir().unwrap();
        let m = manifest(&[("disease", &["a"])]);
        assert_eq!(default_version(dir.path(), &m), "multitask-abcdef01");

        let mut short = m.clone();
        short.backbone_fingerprint = "xy".into();
        assert_eq!(default_version(Path::new("/models/run-7"), &short), "run-7");
    }
}
