use std::collections::HashMap;
use std::path::Path;

use serde::Deserialize;

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
}

#[derive(Debug, Deserialize, Clone)]
pub struct DataConfig {
    pub base_dir: String,
    pub train_split: f64,
    pub val_split: f64,
    pub test_split: f64,
    pub min_samples_per_class: usize,
    pub min_confidence: f64,
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

#[derive(Debug, Deserialize, Clone)]
pub struct AugmentationConfig {
    pub horizontal_flip: bool,
    pub vertical_flip: bool,
    pub rotation_limit: u32,
    pub brightness_range: [f64; 2],
    pub random_crop_scale: [f64; 2],
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
        assert!(result.is_err(), "should fail when [export] section is missing");
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
        assert!(result.is_err(), "should fail when min_confidence is missing");
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
        assert!(result.is_err(), "should fail when task fields like learning_rate are missing");
    }
}
