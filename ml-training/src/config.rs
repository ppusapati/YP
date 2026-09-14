use std::collections::HashMap;
use std::path::Path;

use serde::{Deserialize, Serialize};

use crate::triggers::TriggerConfig;

#[derive(Debug, Deserialize, Clone)]
pub struct TrainingConfig {
    pub data: DataConfig,
    pub tasks: HashMap<String, TaskConfig>,
    pub augmentation: AugmentationConfig,
    pub export: ExportConfig,
    /// Optional retraining trigger configuration.
    #[serde(default)]
    pub retraining: Option<TriggerConfig>,
    /// Tabular regression tasks (e.g. yield), keyed by task name.
    #[serde(default)]
    pub tabular: HashMap<String, TabularTaskConfig>,
    /// Pretrained backbone used by `train-heads` for transfer learning.
    #[serde(default)]
    pub backbone: Option<BackboneConfig>,
    /// Head hyper-parameters for `train-heads`.
    #[serde(default)]
    pub heads: HeadConfig,
}

/// A frozen pretrained ONNX backbone used as a feature extractor.
#[derive(Debug, Deserialize, Clone, Default)]
pub struct BackboneConfig {
    /// Path to the pretrained ONNX file (ImageNet or agriculture-specific).
    pub path: String,
    /// ONNX tensor name to read embeddings from — normally the pooled feature
    /// map just before the pretrained classifier. Empty uses the graph output.
    #[serde(default)]
    pub embedding_output: String,
    /// Required only when the backbone graph has a symbolic input size.
    #[serde(default)]
    pub input_size: usize,
    /// Pixel normalization the backbone expects: imagenet, unit, or symmetric.
    #[serde(default)]
    pub normalization: String,
}

/// Hyper-parameters for the per-task heads trained on frozen embeddings.
#[derive(Debug, Deserialize, Serialize, Clone)]
pub struct HeadConfig {
    /// Width of the hidden layer (must be >= 1).
    #[serde(default = "default_head_hidden")]
    pub hidden_size: usize,
    #[serde(default = "default_head_epochs")]
    pub num_epochs: usize,
    #[serde(default = "default_head_batch_size")]
    pub batch_size: usize,
    #[serde(default = "default_head_lr")]
    pub learning_rate: f64,
    #[serde(default = "default_head_weight_decay")]
    pub weight_decay: f64,
    #[serde(default = "default_head_dropout")]
    pub dropout: f64,
    #[serde(default = "default_head_label_smoothing")]
    pub label_smoothing: f64,
    #[serde(default = "default_head_patience")]
    pub early_stopping_patience: usize,
    /// Extra augmented copies of each training image to embed. 0 embeds each
    /// image once, unaugmented.
    #[serde(default = "default_augment_passes")]
    pub augment_passes: u32,
}

impl Default for HeadConfig {
    fn default() -> Self {
        Self {
            hidden_size: default_head_hidden(),
            num_epochs: default_head_epochs(),
            batch_size: default_head_batch_size(),
            learning_rate: default_head_lr(),
            weight_decay: default_head_weight_decay(),
            dropout: default_head_dropout(),
            label_smoothing: default_head_label_smoothing(),
            early_stopping_patience: default_head_patience(),
            augment_passes: default_augment_passes(),
        }
    }
}

fn default_head_hidden() -> usize {
    256
}
fn default_head_epochs() -> usize {
    60
}
fn default_head_batch_size() -> usize {
    64
}
fn default_head_lr() -> f64 {
    0.001
}
fn default_head_weight_decay() -> f64 {
    0.0001
}
fn default_head_dropout() -> f64 {
    0.2
}
fn default_head_label_smoothing() -> f64 {
    0.05
}
fn default_head_patience() -> usize {
    8
}
fn default_augment_passes() -> u32 {
    2
}

/// Configuration for a tabular regression task trained with gradient boosting.
#[derive(Debug, Deserialize, Clone)]
pub struct TabularTaskConfig {
    /// CSV with a header row; must contain `target_column` plus the feature columns.
    pub data_csv: String,
    /// Name of the target column.
    #[serde(default = "default_target_column")]
    pub target_column: String,
    #[serde(default = "default_n_trees")]
    pub n_trees: usize,
    #[serde(default = "default_max_depth")]
    pub max_depth: usize,
    #[serde(default = "default_learning_rate")]
    pub learning_rate: f64,
    #[serde(default = "default_min_samples_leaf")]
    pub min_samples_leaf: usize,
    #[serde(default = "default_subsample")]
    pub subsample: f64,
    /// Target coverage for conformal prediction intervals.
    #[serde(default = "default_interval_coverage")]
    pub interval_coverage: f64,
    /// Minimum held-out R² required to register the model.
    #[serde(default = "default_min_r_squared")]
    pub min_r_squared: f64,
    /// Path of the JSON model artifact to write.
    pub output_model: String,
}

fn default_target_column() -> String {
    "yield_kg_ha".to_string()
}
fn default_n_trees() -> usize {
    300
}
fn default_max_depth() -> usize {
    4
}
fn default_learning_rate() -> f64 {
    0.05
}
fn default_min_samples_leaf() -> usize {
    5
}
fn default_subsample() -> f64 {
    0.8
}
fn default_interval_coverage() -> f64 {
    0.9
}
fn default_min_r_squared() -> f64 {
    0.5
}

#[derive(Debug, Deserialize, Clone)]
pub struct DataConfig {
    pub base_dir: String,
    pub train_split: f64,
    pub val_split: f64,
    pub test_split: f64,
    pub min_samples_per_class: usize,
    pub min_confidence: f64,
    /// Relative trust in labels by origin; scales each sample's contribution
    /// to class weights. Human-reviewed labels bypass `min_confidence`.
    #[serde(default)]
    pub provenance_weights: ProvenanceWeights,
}

#[derive(Debug, Deserialize, Clone)]
pub struct ProvenanceWeights {
    #[serde(default = "default_human_weight")]
    pub human: f64,
    #[serde(default = "default_external_weight")]
    pub external_api: f64,
    #[serde(default = "default_local_weight")]
    pub local_model: f64,
}

impl Default for ProvenanceWeights {
    fn default() -> Self {
        Self {
            human: default_human_weight(),
            external_api: default_external_weight(),
            local_model: default_local_weight(),
        }
    }
}

impl ProvenanceWeights {
    pub fn for_provenance(&self, provenance: &str) -> f64 {
        match provenance {
            "human" => self.human,
            "local_model" => self.local_model,
            _ => self.external_api,
        }
    }
}

fn default_human_weight() -> f64 {
    1.0
}
fn default_external_weight() -> f64 {
    0.6
}
fn default_local_weight() -> f64 {
    0.3
}

#[derive(Debug, Deserialize, Clone)]
pub struct TaskConfig {
    pub input_size: usize,
    pub num_epochs: usize,
    pub batch_size: usize,
    pub learning_rate: f64,
    pub weight_decay: f64,
    pub label_smoothing: f64,
    pub early_stopping_patience: usize,
    pub output_model: String,
}

/// Training-time augmentation. The first five fields are the original
/// geometry/brightness knobs; the rest target field-photo conditions and
/// default to sensible values so older configs keep working.
#[derive(Debug, Deserialize, Clone)]
pub struct AugmentationConfig {
    pub horizontal_flip: bool,
    pub vertical_flip: bool,
    /// Max rotation in degrees (0 disables).
    pub rotation_limit: u32,
    pub brightness_range: [f64; 2],
    /// Random-resized-crop scale range as a fraction of the shorter side.
    pub random_crop_scale: [f64; 2],
    /// Contrast multiplier about mid-grey.
    #[serde(default = "default_contrast_range")]
    pub contrast_range: [f64; 2],
    /// Gamma range (harsh sun / deep shade).
    #[serde(default = "default_gamma_range")]
    pub gamma_range: [f64; 2],
    /// Max per-channel gain deviation for white-balance / colour casts.
    #[serde(default = "default_color_cast")]
    pub color_cast: f64,
    /// Probability of re-lighting the periphery outside a random ellipse
    /// (uneven subject vs background illumination).
    #[serde(default = "default_background_prob")]
    pub background_prob: f64,
    /// Probability of camera-shake motion blur.
    #[serde(default = "default_motion_blur_prob")]
    pub motion_blur_prob: f64,
    /// Longest blur streak in pixels (at the decoded resolution).
    #[serde(default = "default_motion_blur_max_len")]
    pub motion_blur_max_len: u32,
    /// Probability of painting occluding patches (hands, leaves, tools).
    #[serde(default = "default_occlusion_prob")]
    pub occlusion_prob: f64,
    #[serde(default = "default_occlusion_max_patches")]
    pub occlusion_max_patches: u32,
    /// Max area fraction covered by one patch.
    #[serde(default = "default_occlusion_max_frac")]
    pub occlusion_max_frac: f64,
    /// Max Gaussian sensor-noise sigma as a fraction of full scale.
    #[serde(default = "default_noise_std")]
    pub noise_std: f64,
    /// Base seed; draws are keyed by sample id and epoch on top of it.
    #[serde(default = "default_aug_seed")]
    pub seed: u64,
}

fn default_contrast_range() -> [f64; 2] {
    [0.8, 1.2]
}
fn default_gamma_range() -> [f64; 2] {
    [0.8, 1.25]
}
fn default_color_cast() -> f64 {
    0.1
}
fn default_background_prob() -> f64 {
    0.2
}
fn default_motion_blur_prob() -> f64 {
    0.2
}
fn default_motion_blur_max_len() -> u32 {
    9
}
fn default_occlusion_prob() -> f64 {
    0.3
}
fn default_occlusion_max_patches() -> u32 {
    2
}
fn default_occlusion_max_frac() -> f64 {
    0.2
}
fn default_noise_std() -> f64 {
    0.02
}
fn default_aug_seed() -> u64 {
    42
}

#[derive(Debug, Deserialize, Clone)]
pub struct ExportConfig {
    pub onnx_opset: i64,
    pub dynamic_batch: bool,
}

impl TrainingConfig {
    pub fn from_file(path: &Path) -> anyhow::Result<Self> {
        let content = std::fs::read_to_string(path)?;
        let config: TrainingConfig = toml::from_str(&content)?;
        Ok(config)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn full_toml() -> &'static str {
        r#"
[data]
base_dir = "/data/collected"
train_split = 0.7
val_split = 0.15
test_split = 0.15
min_samples_per_class = 20
min_confidence = 0.8

[tasks.plant_disease]
input_size = 64
num_epochs = 50
batch_size = 32
learning_rate = 0.001
weight_decay = 0.0001
label_smoothing = 0.1
early_stopping_patience = 5
output_model = "models/plant_disease.onnx"

[augmentation]
horizontal_flip = true
vertical_flip = false
rotation_limit = 15
brightness_range = [0.8, 1.2]
random_crop_scale = [0.8, 1.0]

[export]
onnx_opset = 17
dynamic_batch = true
"#
    }

    #[test]
    fn deserialize_full_config() {
        let config: TrainingConfig = toml::from_str(full_toml()).unwrap();

        assert_eq!(config.data.base_dir, "/data/collected");
        assert_eq!(config.data.train_split, 0.7);
        assert_eq!(config.data.val_split, 0.15);
        assert_eq!(config.data.test_split, 0.15);
        assert_eq!(config.data.min_samples_per_class, 20);
        assert_eq!(config.data.min_confidence, 0.8);

        assert!(config.tasks.contains_key("plant_disease"));
        let task = &config.tasks["plant_disease"];
        assert_eq!(task.input_size, 64);
        assert_eq!(task.num_epochs, 50);
        assert_eq!(task.batch_size, 32);
        assert_eq!(task.learning_rate, 0.001);
        assert_eq!(task.weight_decay, 0.0001);
        assert_eq!(task.label_smoothing, 0.1);
        assert_eq!(task.early_stopping_patience, 5);
        assert_eq!(task.output_model, "models/plant_disease.onnx");

        assert!(config.augmentation.horizontal_flip);
        assert!(!config.augmentation.vertical_flip);
        assert_eq!(config.augmentation.rotation_limit, 15);
        assert_eq!(config.augmentation.brightness_range, [0.8, 1.2]);
        assert_eq!(config.augmentation.random_crop_scale, [0.8, 1.0]);

        assert_eq!(config.export.onnx_opset, 17);
        assert!(config.export.dynamic_batch);
    }

    #[test]
    fn deserialize_multiple_tasks() {
        let toml_str = r#"
[data]
base_dir = "/data"
train_split = 0.7
val_split = 0.15
test_split = 0.15
min_samples_per_class = 10
min_confidence = 0.5

[tasks.disease]
input_size = 64
num_epochs = 30
batch_size = 16
learning_rate = 0.001
weight_decay = 0.0
label_smoothing = 0.0
early_stopping_patience = 3
output_model = "disease.onnx"

[tasks.maturity]
input_size = 128
num_epochs = 40
batch_size = 8
learning_rate = 0.0005
weight_decay = 0.001
label_smoothing = 0.05
early_stopping_patience = 5
output_model = "maturity.onnx"

[augmentation]
horizontal_flip = true
vertical_flip = false
rotation_limit = 10
brightness_range = [0.9, 1.1]
random_crop_scale = [0.85, 1.0]

[export]
onnx_opset = 17
dynamic_batch = false
"#;
        let config: TrainingConfig = toml::from_str(toml_str).unwrap();
        assert_eq!(config.tasks.len(), 2);
        assert!(config.tasks.contains_key("disease"));
        assert!(config.tasks.contains_key("maturity"));
        assert_eq!(config.tasks["disease"].input_size, 64);
        assert_eq!(config.tasks["maturity"].input_size, 128);
    }

    #[test]
    fn missing_export_section_errors() {
        let toml_str = r#"
[data]
base_dir = "/data"
train_split = 0.7
val_split = 0.15
test_split = 0.15
min_samples_per_class = 10
min_confidence = 0.5

[augmentation]
horizontal_flip = true
vertical_flip = false
rotation_limit = 10
brightness_range = [0.9, 1.1]
random_crop_scale = [0.8, 1.0]
"#;
        let result = toml::from_str::<TrainingConfig>(toml_str);
        assert!(
            result.is_err(),
            "should fail when [export] section is missing"
        );
    }

    #[test]
    fn missing_data_field_errors() {
        let toml_str = r#"
[data]
base_dir = "/data"
train_split = 0.7
val_split = 0.15
test_split = 0.15
min_samples_per_class = 10

[augmentation]
horizontal_flip = true
vertical_flip = false
rotation_limit = 10
brightness_range = [0.9, 1.1]
random_crop_scale = [0.8, 1.0]

[export]
onnx_opset = 17
dynamic_batch = true
"#;
        let result = toml::from_str::<TrainingConfig>(toml_str);
        assert!(
            result.is_err(),
            "should fail when min_confidence is missing"
        );
    }

    #[test]
    fn missing_task_field_errors() {
        let toml_str = r#"
[data]
base_dir = "/data"
train_split = 0.7
val_split = 0.15
test_split = 0.15
min_samples_per_class = 10
min_confidence = 0.5

[tasks.disease]
input_size = 64
num_epochs = 30
batch_size = 16

[augmentation]
horizontal_flip = true
vertical_flip = false
rotation_limit = 10
brightness_range = [0.9, 1.1]
random_crop_scale = [0.8, 1.0]

[export]
onnx_opset = 17
dynamic_batch = true
"#;
        let result = toml::from_str::<TrainingConfig>(toml_str);
        assert!(
            result.is_err(),
            "should fail when task fields like learning_rate are missing"
        );
    }
}
