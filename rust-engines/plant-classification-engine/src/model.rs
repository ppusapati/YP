//! Model session for plant classification.

use ndarray::Array3;
use thiserror::Error;

use crate::preprocess::{ImageBuffer, PreprocessConfig, PreprocessError, preprocess_image};
use crate::types::NUM_CLASSES;

#[derive(Debug, Error)]
pub enum ModelError {
    #[error("Model not loaded")]
    NotLoaded,
    #[error("Preprocessing error: {0}")]
    PreprocessError(#[from] PreprocessError),
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
                row.push(((c * 13 + f * 11 + 37) % 1000) as f32 / 10000.0 - 0.05);
            }
            classifier.push(row);
            bias.push(((c * 7 + 19) % 100) as f32 / 1000.0);
        }
        Self { num_classes, classifier, bias }
    }

    fn forward(&self, input: &[f32]) -> Vec<f32> {
        let mut logits = Vec::with_capacity(self.num_classes);
        for c in 0..self.num_classes {
            let n = self.classifier[c].len().min(input.len());
            let mut sum = self.bias[c];
            for i in 0..n { sum += self.classifier[c][i] * input[i]; }
            logits.push(sum);
        }
        logits
    }
}

/// Plant classification model session.
pub struct PlantClassificationModel {
    num_classes: usize,
    preprocess: PreprocessConfig,
    weights: Option<DemoWeights>,
    is_loaded: bool,
}

impl PlantClassificationModel {
    pub fn new(num_classes: usize) -> Self {
        Self {
            num_classes,
            preprocess: PreprocessConfig::default(),
            weights: None,
            is_loaded: false,
        }
    }

    pub fn load_demo(&mut self) -> Result<(), ModelError> {
        self.weights = Some(DemoWeights::init(self.num_classes));
        self.is_loaded = true;
        Ok(())
    }

    pub fn is_loaded(&self) -> bool { self.is_loaded }

    /// Run inference, returning raw logits.
    pub fn infer_image(&self, image: &ImageBuffer) -> Result<Vec<f32>, ModelError> {
        let weights = self.weights.as_ref().ok_or(ModelError::NotLoaded)?;
        let tensor = preprocess_image(image, &self.preprocess)?;
        let flat: Vec<f32> = tensor.iter().cloned().collect();
        Ok(weights.forward(&flat))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_model() {
        let mut model = PlantClassificationModel::new(NUM_CLASSES);
        model.load_demo().unwrap();
        let img = ImageBuffer::from_rgb(vec![128; 300 * 300 * 3], 300, 300).unwrap();
        let logits = model.infer_image(&img).unwrap();
        assert_eq!(logits.len(), NUM_CLASSES);
    }
}
