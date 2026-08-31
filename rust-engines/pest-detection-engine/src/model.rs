//! Model session management for pest detection.

use ndarray::Array3;
use serde::{Deserialize, Serialize};
use thiserror::Error;

use crate::preprocess::{ImageBuffer, PreprocessConfig, PreprocessError, preprocess_image};
use crate::types::NUM_PEST_CLASSES;

#[derive(Debug, Error)]
pub enum ModelError {
    #[error("Model not loaded")]
    NotLoaded,
    #[error("Preprocessing error: {0}")]
    PreprocessError(#[from] PreprocessError),
    #[error("Inference error: {0}")]
    InferenceError(String),
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PestModelConfig {
    pub num_classes: usize,
    pub input_size: u32,
    pub max_batch_size: usize,
    pub with_bbox: bool,
    #[serde(skip)]
    pub preprocess: PreprocessConfig,
}

impl Default for PestModelConfig {
    fn default() -> Self {
        Self {
            num_classes: NUM_PEST_CLASSES,
            input_size: 320,
            max_batch_size: 16,
            with_bbox: false,
            preprocess: PreprocessConfig::default(),
        }
    }
}

pub struct ModelOutput {
    pub classification_logits: Vec<f32>,
    pub bbox: Option<[f32; 4]>,
}

#[derive(Debug, Clone)]
struct DemoWeights {
    num_classes: usize,
    classifier: Vec<Vec<f32>>,
    bias: Vec<f32>,
}

impl DemoWeights {
    fn init(num_classes: usize) -> Self {
        let features = 512;
        let mut classifier = Vec::with_capacity(num_classes);
        let mut bias = Vec::with_capacity(num_classes);
        for c in 0..num_classes {
            let mut row = Vec::with_capacity(features);
            for f in 0..features {
                row.push(((c * 11 + f * 7 + 31) % 1000) as f32 / 10000.0 - 0.05);
            }
            classifier.push(row);
            bias.push(((c * 5 + 13) % 100) as f32 / 1000.0);
        }
        Self { num_classes, classifier, bias }
    }

    fn forward(&self, input: &[f32]) -> Vec<f32> {
        let mut logits = Vec::with_capacity(self.num_classes);
        for c in 0..self.num_classes {
            let n = self.classifier[c].len().min(input.len());
            let mut sum = self.bias[c];
            for i in 0..n {
                sum += self.classifier[c][i] * input[i];
            }
            logits.push(sum);
        }
        logits
    }
}

/// Pest detection model session.
pub struct PestModel {
    config: PestModelConfig,
    weights: Option<DemoWeights>,
    is_loaded: bool,
}

impl PestModel {
    pub fn new(config: PestModelConfig) -> Self {
        Self { config, weights: None, is_loaded: false }
    }

    pub fn load_demo(&mut self) -> Result<(), ModelError> {
        self.weights = Some(DemoWeights::init(self.config.num_classes));
        self.is_loaded = true;
        Ok(())
    }

    pub fn is_loaded(&self) -> bool {
        self.is_loaded
    }

    pub fn config(&self) -> &PestModelConfig {
        &self.config
    }

    pub fn infer_image(&self, image: &ImageBuffer) -> Result<ModelOutput, ModelError> {
        let weights = self.weights.as_ref().ok_or(ModelError::NotLoaded)?;
        let tensor = preprocess_image(image, &self.config.preprocess)?;
        let flat: Vec<f32> = tensor.iter().cloned().collect();
        let logits = weights.forward(&flat);

        let bbox = if self.config.with_bbox {
            Some([0.3, 0.3, 0.7, 0.7]) // Demo bbox
        } else {
            None
        };

        Ok(ModelOutput { classification_logits: logits, bbox })
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_model_load_and_infer() {
        let mut model = PestModel::new(PestModelConfig::default());
        model.load_demo().unwrap();
        let img = ImageBuffer::from_rgb(vec![128; 300 * 300 * 3], 300, 300).unwrap();
        let out = model.infer_image(&img).unwrap();
        assert_eq!(out.classification_logits.len(), NUM_PEST_CLASSES);
    }
}
