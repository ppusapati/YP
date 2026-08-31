//! ONNX model session management for disease detection.
//!
//! In production, this loads an ONNX-exported EfficientNet-B4 + U-Net model
//! via the `ort` crate. This implementation provides a deterministic demo
//! model for testing, mirroring the `InferencePipeline` pattern from
//! `plant-ai-inference-engine`.

use ndarray::Array3;
use serde::{Deserialize, Serialize};
use thiserror::Error;

use crate::preprocess::{ImageBuffer, PreprocessConfig, PreprocessError, preprocess_image};
use crate::types::NUM_DISEASE_CLASSES;

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

/// Model format for loading.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum ModelFormat {
    /// ONNX model file.
    Onnx,
    /// Demo model with deterministic weights.
    Demo,
}

/// Configuration for the disease detection model.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DiseaseModelConfig {
    /// Number of disease classes.
    pub num_classes: usize,
    /// Input image size.
    pub input_size: u32,
    /// Maximum batch size.
    pub max_batch_size: usize,
    /// Preprocessing configuration.
    #[serde(skip)]
    pub preprocess: PreprocessConfig,
    /// Whether segmentation output is enabled.
    pub segmentation_enabled: bool,
}

impl Default for DiseaseModelConfig {
    fn default() -> Self {
        Self {
            num_classes: NUM_DISEASE_CLASSES,
            input_size: 256,
            max_batch_size: 16,
            preprocess: PreprocessConfig::default(),
            segmentation_enabled: true,
        }
    }
}

/// Raw output from model inference.
#[derive(Debug, Clone)]
pub struct ModelOutput {
    /// Classification logits, shape (num_classes,).
    pub classification_logits: Vec<f32>,
    /// Segmentation logits (flattened), shape (1, H, W) where H=W=input_size.
    /// None if segmentation is disabled.
    pub segmentation_logits: Option<Vec<f32>>,
    /// Segmentation output spatial size (height, width).
    pub segmentation_size: Option<(usize, usize)>,
}

/// Simplified model weights for demo/test inference.
#[derive(Debug, Clone)]
struct DemoWeights {
    num_classes: usize,
    classifier: Vec<Vec<f32>>,
    bias: Vec<f32>,
}

impl DemoWeights {
    fn init(num_classes: usize) -> Self {
        let reduced_features = 512;
        let mut classifier = Vec::with_capacity(num_classes);
        let mut bias = Vec::with_capacity(num_classes);

        for c in 0..num_classes {
            let mut row = Vec::with_capacity(reduced_features);
            for f in 0..reduced_features {
                let val = ((c * 7 + f * 13 + 42) % 1000) as f32 / 10000.0 - 0.05;
                row.push(val);
            }
            classifier.push(row);
            bias.push(((c * 3 + 17) % 100) as f32 / 1000.0);
        }

        Self { num_classes, classifier, bias }
    }

    fn forward(&self, input: &[f32]) -> Vec<f32> {
        let reduced_len = self.classifier[0].len();
        let mut logits = Vec::with_capacity(self.num_classes);

        for c in 0..self.num_classes {
            let mut sum = self.bias[c];
            let n = reduced_len.min(input.len());
            for i in 0..n {
                sum += self.classifier[c][i] * input[i];
            }
            logits.push(sum);
        }

        logits
    }
}

/// Disease detection model session.
///
/// Manages model loading and raw inference. In production, wraps an ONNX
/// Runtime session; for testing, uses deterministic demo weights.
pub struct DiseaseModel {
    config: DiseaseModelConfig,
    weights: Option<DemoWeights>,
    is_loaded: bool,
}

impl DiseaseModel {
    /// Create a new model session.
    pub fn new(config: DiseaseModelConfig) -> Self {
        Self {
            config,
            weights: None,
            is_loaded: false,
        }
    }

    /// Load model from a file path.
    ///
    /// In production, this would load an ONNX model via `ort`.
    pub fn load(&mut self, _path: &str, _format: ModelFormat) -> Result<(), ModelError> {
        let weights = DemoWeights::init(self.config.num_classes);
        self.weights = Some(weights);
        self.is_loaded = true;
        Ok(())
    }

    /// Load a demo model for testing.
    pub fn load_demo(&mut self) -> Result<(), ModelError> {
        self.load("demo", ModelFormat::Demo)
    }

    /// Whether the model is loaded and ready for inference.
    pub fn is_loaded(&self) -> bool {
        self.is_loaded
    }

    /// Get the model configuration.
    pub fn config(&self) -> &DiseaseModelConfig {
        &self.config
    }

    /// Run inference on a single preprocessed CHW tensor.
    pub fn infer_tensor(&self, tensor: &Array3<f32>) -> Result<ModelOutput, ModelError> {
        let weights = self.weights.as_ref().ok_or(ModelError::NotLoaded)?;

        let flat: Vec<f32> = tensor.iter().cloned().collect();
        let classification_logits = weights.forward(&flat);

        // Simulate segmentation output if enabled
        let (segmentation_logits, segmentation_size) = if self.config.segmentation_enabled {
            let seg_h = self.config.input_size as usize;
            let seg_w = self.config.input_size as usize;
            // Generate a simple heatmap based on classification confidence
            let max_logit = classification_logits
                .iter()
                .cloned()
                .fold(f32::NEG_INFINITY, f32::max);
            let seg = vec![max_logit * 0.1; seg_h * seg_w];
            (Some(seg), Some((seg_h, seg_w)))
        } else {
            (None, None)
        };

        Ok(ModelOutput {
            classification_logits,
            segmentation_logits,
            segmentation_size,
        })
    }

    /// Run inference on a raw image.
    pub fn infer_image(&self, image: &ImageBuffer) -> Result<ModelOutput, ModelError> {
        let tensor = preprocess_image(image, &self.config.preprocess)?;
        self.infer_tensor(&tensor)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn make_test_image(w: u32, h: u32) -> ImageBuffer {
        let data = vec![128u8; (w * h * 3) as usize];
        ImageBuffer::from_rgb(data, w, h).unwrap()
    }

    #[test]
    fn test_model_load_and_infer() {
        let mut model = DiseaseModel::new(DiseaseModelConfig::default());
        model.load_demo().unwrap();
        assert!(model.is_loaded());

        let img = make_test_image(300, 300);
        let output = model.infer_image(&img).unwrap();
        assert_eq!(output.classification_logits.len(), NUM_DISEASE_CLASSES);
        assert!(output.segmentation_logits.is_some());
    }

    #[test]
    fn test_model_not_loaded_error() {
        let model = DiseaseModel::new(DiseaseModelConfig::default());
        let img = make_test_image(100, 100);
        assert!(model.infer_image(&img).is_err());
    }
}
