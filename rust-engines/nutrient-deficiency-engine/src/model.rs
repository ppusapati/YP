//! Model session management for nutrient deficiency detection.
//!
//! In production, loads an ONNX-exported DenseNet-121 with a dual-head
//! architecture: classification head (10 nutrients) + ordinal regression
//! head (3 severity thresholds). This implementation provides deterministic
//! demo weights for testing.

use serde::{Deserialize, Serialize};
use thiserror::Error;

use crate::preprocess::{ImageBuffer, PreprocessConfig, PreprocessError, preprocess_image};
use crate::types::{NUM_NUTRIENT_CLASSES, NUM_SEVERITY_CLASSES};

/// Errors from model operations.
#[derive(Debug, Error)]
pub enum ModelError {
    #[error("Model not loaded")]
    NotLoaded,

    #[error("Model load error: {0}")]
    LoadError(String),

    #[error("Inference error: {0}")]
    InferenceError(String),

    #[error("Preprocessing error: {0}")]
    PreprocessError(#[from] PreprocessError),
}

/// Configuration for the nutrient deficiency model.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DeficiencyModelConfig {
    /// Number of nutrient classes.
    pub num_classes: usize,
    /// Number of severity classes (None, Mild, Moderate, Severe).
    pub num_severity_classes: usize,
    /// Input image size.
    pub input_size: u32,
    /// Maximum batch size.
    pub max_batch_size: usize,
    /// Preprocessing configuration.
    #[serde(skip)]
    pub preprocess: PreprocessConfig,
}

impl Default for DeficiencyModelConfig {
    fn default() -> Self {
        Self {
            num_classes: NUM_NUTRIENT_CLASSES,
            num_severity_classes: NUM_SEVERITY_CLASSES,
            input_size: 224,
            max_batch_size: 16,
            preprocess: PreprocessConfig::default(),
        }
    }
}

/// Raw output from model inference.
#[derive(Debug, Clone)]
pub struct ModelOutput {
    /// Classification logits for each nutrient, shape (num_classes,).
    pub classification_logits: Vec<f32>,
    /// Severity classification logits per nutrient, shape (num_classes, num_severity_classes).
    /// Each row contains logits for [None, Mild, Moderate, Severe].
    pub severity_logits: Vec<Vec<f32>>,
}

/// Demo weights for classification and ordinal regression heads.
#[derive(Debug, Clone)]
struct DemoWeights {
    num_classes: usize,
    num_thresholds: usize,
    cls_weights: Vec<Vec<f32>>,
    cls_bias: Vec<f32>,
    sev_weights: Vec<Vec<Vec<f32>>>,
    sev_bias: Vec<Vec<f32>>,
}

impl DemoWeights {
    fn init(num_classes: usize, num_thresholds: usize) -> Self {
        let features = 1024; // DenseNet-121 final feature dim

        // Classification head
        let mut cls_weights = Vec::with_capacity(num_classes);
        let mut cls_bias = Vec::with_capacity(num_classes);
        for c in 0..num_classes {
            let mut row = Vec::with_capacity(features);
            for f in 0..features {
                let val = ((c * 11 + f * 17 + 53) % 1000) as f32 / 10000.0 - 0.05;
                row.push(val);
            }
            cls_weights.push(row);
            cls_bias.push(((c * 7 + 23) % 100) as f32 / 1000.0);
        }

        // Ordinal severity head (per nutrient, per threshold)
        let mut sev_weights = Vec::with_capacity(num_classes);
        let mut sev_bias = Vec::with_capacity(num_classes);
        for c in 0..num_classes {
            let mut nutrient_weights = Vec::with_capacity(num_thresholds);
            let mut nutrient_bias = Vec::with_capacity(num_thresholds);
            for t in 0..num_thresholds {
                let mut row = Vec::with_capacity(features);
                for f in 0..features {
                    let val = ((c * 19 + t * 31 + f * 13 + 67) % 1000) as f32 / 10000.0 - 0.05;
                    row.push(val);
                }
                nutrient_weights.push(row);
                // Bias decreases with severity threshold to create natural ordering
                nutrient_bias.push(0.5 - (t as f32) * 0.3);
            }
            sev_weights.push(nutrient_weights);
            sev_bias.push(nutrient_bias);
        }

        Self {
            num_classes,
            num_thresholds,
            cls_weights,
            cls_bias,
            sev_weights,
            sev_bias,
        }
    }

    fn forward(&self, input: &[f32]) -> (Vec<f32>, Vec<Vec<f32>>) {
        // Classification head
        let mut cls_logits = Vec::with_capacity(self.num_classes);
        for c in 0..self.num_classes {
            let n = self.cls_weights[c].len().min(input.len());
            let mut sum = self.cls_bias[c];
            for i in 0..n {
                sum += self.cls_weights[c][i] * input[i];
            }
            cls_logits.push(sum);
        }

        // Severity head
        let mut sev_logits = Vec::with_capacity(self.num_classes);
        for c in 0..self.num_classes {
            let mut thresholds = Vec::with_capacity(self.num_thresholds);
            for t in 0..self.num_thresholds {
                let n = self.sev_weights[c][t].len().min(input.len());
                let mut sum = self.sev_bias[c][t];
                for i in 0..n {
                    sum += self.sev_weights[c][t][i] * input[i];
                }
                thresholds.push(sum);
            }
            sev_logits.push(thresholds);
        }

        (cls_logits, sev_logits)
    }
}

/// Nutrient deficiency detection model session.
pub struct DeficiencyModel {
    config: DeficiencyModelConfig,
    weights: Option<DemoWeights>,
    is_loaded: bool,
}

impl DeficiencyModel {
    /// Create a new model session.
    pub fn new(config: DeficiencyModelConfig) -> Self {
        Self {
            config,
            weights: None,
            is_loaded: false,
        }
    }

    /// Load a demo model for testing.
    pub fn load_demo(&mut self) -> Result<(), ModelError> {
        let weights = DemoWeights::init(
            self.config.num_classes,
            self.config.num_severity_classes,
        );
        self.weights = Some(weights);
        self.is_loaded = true;
        Ok(())
    }

    /// Whether the model is loaded and ready for inference.
    pub fn is_loaded(&self) -> bool {
        self.is_loaded
    }

    /// Get the model configuration.
    pub fn config(&self) -> &DeficiencyModelConfig {
        &self.config
    }

    /// Run inference on a raw image.
    pub fn infer_image(&self, image: &ImageBuffer) -> Result<ModelOutput, ModelError> {
        let weights = self.weights.as_ref().ok_or(ModelError::NotLoaded)?;
        let tensor = preprocess_image(image, &self.config.preprocess)?;
        let flat: Vec<f32> = tensor.iter().cloned().collect();
        let (cls_logits, sev_logits) = weights.forward(&flat);

        Ok(ModelOutput {
            classification_logits: cls_logits,
            severity_logits: sev_logits,
        })
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn make_test_image(w: u32, h: u32) -> ImageBuffer {
        ImageBuffer::from_rgb(vec![128u8; (w * h * 3) as usize], w, h).unwrap()
    }

    #[test]
    fn test_model_load_and_infer() {
        let mut model = DeficiencyModel::new(DeficiencyModelConfig::default());
        model.load_demo().unwrap();
        assert!(model.is_loaded());

        let img = make_test_image(300, 300);
        let output = model.infer_image(&img).unwrap();
        assert_eq!(output.classification_logits.len(), NUM_NUTRIENT_CLASSES);
        assert_eq!(output.severity_logits.len(), NUM_NUTRIENT_CLASSES);
        for sev in &output.severity_logits {
            assert_eq!(sev.len(), NUM_SEVERITY_CLASSES);
        }
    }

    #[test]
    fn test_model_not_loaded_error() {
        let model = DeficiencyModel::new(DeficiencyModelConfig::default());
        let img = make_test_image(100, 100);
        assert!(model.infer_image(&img).is_err());
    }
}
