use std::collections::HashMap;
use std::path::Path;

use serde::Deserialize;

#[derive(Debug, Deserialize, Clone)]
pub struct TrainingConfig {
    pub data: DataConfig,
    pub tasks: HashMap<String, TaskConfig>,
    pub augmentation: AugmentationConfig,
    pub export: ExportConfig,
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
