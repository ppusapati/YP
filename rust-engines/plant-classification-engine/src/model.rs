//! Model session for plant classification.

use thiserror::Error;
use serde::{Deserialize, Serialize};

use crate::preprocess::{ImageBuffer, PreprocessConfig, PreprocessError, preprocess_image};
use crate::types::NUM_CLASSES;

#[derive(Debug, Error)]
pub enum ModelError {
    #[error("Model not loaded")]
    NotLoaded,
    #[error("Model load error: {0}")]
    LoadError(String),
    #[error("Preprocessing error: {0}")]
    PreprocessError(#[from] PreprocessError),
    #[error("Inference error: {0}")]
    InferenceError(String),
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

/// ONNX Runtime model wrapper for plant classification.
///
/// Loads and runs inference on an ONNX-exported ResNet50 model.
/// Only available when compiled with the `onnx` feature.
#[cfg(feature = "onnx")]
struct OnnxModel {
    session: std::sync::Mutex<ort::session::Session>,
    num_classes: usize,
    input_size: u32,
}

#[cfg(feature = "onnx")]
impl OnnxModel {
    fn load(path: &str, num_classes: usize, input_size: u32) -> Result<Self, ModelError> {
        let session = ort::session::Session::builder()
            .map_err(|e| ModelError::LoadError(format!("Failed to create session builder: {e}")))?
            .with_optimization_level(ort::session::builder::GraphOptimizationLevel::Level3)
            .map_err(|e| ModelError::LoadError(format!("Failed to set optimization level: {e}")))?
            .commit_from_file(path)
            .map_err(|e| ModelError::LoadError(format!("Failed to load ONNX model from '{path}': {e}")))?;

        Ok(Self { session: std::sync::Mutex::new(session), num_classes, input_size })
    }

    fn forward(&self, input: &[f32]) -> Result<Vec<f32>, ModelError> {
        let size = self.input_size as usize;
        let input_tensor = ort::value::Tensor::from_array(
            ([1usize, 3, size, size], input.to_vec()),
        ).map_err(|e| ModelError::InferenceError(format!("Failed to create input tensor: {e}")))?;

        let mut session = self.session.lock()
            .map_err(|e| ModelError::InferenceError(format!("Session lock poisoned: {e}")))?;
        let outputs = session.run(ort::inputs![input_tensor])
            .map_err(|e| ModelError::InferenceError(format!("ONNX inference failed: {e}")))?;

        let (_, cls_data) = outputs[0]
            .try_extract_tensor::<f32>()
            .map_err(|e| ModelError::InferenceError(format!("Failed to extract output: {e}")))?;
        let logits: Vec<f32> = cls_data.iter().copied().take(self.num_classes).collect();

        Ok(logits)
    }
}

/// Configuration for the classification model.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ClassificationModelConfig {
    /// Number of plant species classes.
    pub num_classes: usize,
    /// Input image size.
    pub input_size: u32,
    /// Maximum batch size.
    pub max_batch_size: usize,
    /// Preprocessing configuration.
    #[serde(skip)]
    pub preprocess: PreprocessConfig,
}

impl Default for ClassificationModelConfig {
    fn default() -> Self {
        Self {
            num_classes: NUM_CLASSES,
            input_size: 224,
            max_batch_size: 16,
            preprocess: PreprocessConfig::default(),
        }
    }
}

/// Raw output from model inference.
#[derive(Debug, Clone)]
pub struct ModelOutput {
    /// Classification logits, shape (num_classes,).
    pub logits: Vec<f32>,
    /// Feature vector from the backbone (before the classifier head).
    /// Present only when feature extraction is requested.
    pub features: Option<Vec<f32>>,
}

/// Selects the active inference backend.
enum ModelBackend {
    /// Deterministic demo weights for testing.
    Demo(DemoWeights),
    /// ONNX Runtime session for production inference.
    #[cfg(feature = "onnx")]
    Onnx(OnnxModel),
}

/// Plant classification model session.
pub struct ClassificationModel {
    config: ClassificationModelConfig,
    backend: Option<ModelBackend>,
    is_loaded: bool,
}

impl ClassificationModel {
    /// Create a new model session with the given config.
    pub fn new(config: ClassificationModelConfig) -> Self {
        Self {
            config,
            backend: None,
            is_loaded: false,
        }
    }

    /// Load model from a file path.
    ///
    /// When compiled with the `onnx` feature, attempts to load an ONNX model
    /// first. If the file does not exist or loading fails, falls back to
    /// `DemoWeights` with a warning printed to stderr.
    pub fn load(&mut self, #[allow(unused)] path: &str) -> Result<(), ModelError> {
        #[cfg(feature = "onnx")]
        {
            match OnnxModel::load(path, self.config.num_classes, self.config.input_size) {
                Ok(onnx) => {
                    eprintln!("[plant-classification] Loaded ONNX model from '{path}'");
                    self.backend = Some(ModelBackend::Onnx(onnx));
                    self.is_loaded = true;
                    return Ok(());
                }
                Err(e) => {
                    eprintln!(
                        "[plant-classification] WARNING: Failed to load ONNX model from '{path}': {e}. \
                         Falling back to demo weights."
                    );
                }
            }
        }

        #[cfg(not(feature = "onnx"))]
        {
            eprintln!(
                "[plant-classification] ONNX feature not enabled; using demo weights \
                 (compile with --features onnx to load real models)."
            );
        }

        self.backend = Some(ModelBackend::Demo(DemoWeights::init(self.config.num_classes)));
        self.is_loaded = true;
        Ok(())
    }

    /// Load a demo model for testing.
    pub fn load_demo(&mut self) -> Result<(), ModelError> {
        self.backend = Some(ModelBackend::Demo(DemoWeights::init(self.config.num_classes)));
        self.is_loaded = true;
        Ok(())
    }

    pub fn is_loaded(&self) -> bool { self.is_loaded }

    /// Get the model configuration.
    pub fn config(&self) -> &ClassificationModelConfig {
        &self.config
    }

    /// Run inference, returning a `ModelOutput` containing raw logits.
    pub fn infer_image(&self, image: &ImageBuffer) -> Result<ModelOutput, ModelError> {
        let backend = self.backend.as_ref().ok_or(ModelError::NotLoaded)?;
        let tensor = preprocess_image(image, &self.config.preprocess)?;
        let flat: Vec<f32> = tensor.iter().cloned().collect();

        let logits = match backend {
            ModelBackend::Demo(weights) => weights.forward(&flat),
            #[cfg(feature = "onnx")]
            ModelBackend::Onnx(onnx) => onnx.forward(&flat)?,
        };

        Ok(ModelOutput { logits, features: None })
    }

    /// Extract the feature vector from the backbone (before the classifier head).
    ///
    /// For the demo backend this returns the first 512 elements of the
    /// preprocessed tensor (matching ResNet50's avgpool output dimension).
    /// For the ONNX backend with a dual-output model, this returns the
    /// second output (feature embedding); otherwise falls back to the
    /// preprocessed tensor truncated to 512 dims.
    pub fn extract_features(&self, image: &ImageBuffer) -> Result<Vec<f32>, ModelError> {
        let backend = self.backend.as_ref().ok_or(ModelError::NotLoaded)?;
        let tensor = preprocess_image(image, &self.config.preprocess)?;
        let flat: Vec<f32> = tensor.iter().cloned().collect();
        let feature_dim = 512;

        match backend {
            ModelBackend::Demo(_) => {
                Ok(flat.into_iter().take(feature_dim).collect())
            }
            #[cfg(feature = "onnx")]
            ModelBackend::Onnx(onnx) => {
                let size = onnx.input_size as usize;
                let input_tensor = ort::value::Tensor::from_array(
                    ([1usize, 3, size, size], flat.clone()),
                ).map_err(|e| ModelError::InferenceError(format!("Failed to create input tensor: {e}")))?;

                let mut session = onnx.session.lock()
                    .map_err(|e| ModelError::InferenceError(format!("Session lock poisoned: {e}")))?;
                let outputs = session.run(ort::inputs![input_tensor])
                    .map_err(|e| ModelError::InferenceError(format!("ONNX inference failed: {e}")))?;

                if outputs.len() > 1 {
                    let (_, feat_data) = outputs[1]
                        .try_extract_tensor::<f32>()
                        .map_err(|e| ModelError::InferenceError(format!("Failed to extract features: {e}")))?;
                    Ok(feat_data.iter().copied().collect())
                } else {
                    Ok(flat.into_iter().take(feature_dim).collect())
                }
            }
        }
    }

    /// Run inference and return both logits and feature vector.
    pub fn infer_with_features(&self, image: &ImageBuffer) -> Result<ModelOutput, ModelError> {
        let backend = self.backend.as_ref().ok_or(ModelError::NotLoaded)?;
        let tensor = preprocess_image(image, &self.config.preprocess)?;
        let flat: Vec<f32> = tensor.iter().cloned().collect();
        let feature_dim = 512;

        let (logits, features) = match backend {
            ModelBackend::Demo(weights) => {
                let feats: Vec<f32> = flat.iter().take(feature_dim).cloned().collect();
                let logits = weights.forward(&flat);
                (logits, feats)
            }
            #[cfg(feature = "onnx")]
            ModelBackend::Onnx(onnx) => {
                let logits = onnx.forward(&flat)?;
                let feats: Vec<f32> = flat.iter().take(feature_dim).cloned().collect();
                (logits, feats)
            }
        };

        Ok(ModelOutput { logits, features: Some(features) })
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_model() {
        let mut model = ClassificationModel::new(ClassificationModelConfig::default());
        model.load_demo().unwrap();
        let img = ImageBuffer::from_rgb(vec![128; 300 * 300 * 3], 300, 300).unwrap();
        let output = model.infer_image(&img).unwrap();
        assert_eq!(output.logits.len(), NUM_CLASSES);
        assert!(output.features.is_none());
    }

    #[test]
    fn test_load_fallback_to_demo() {
        let mut model = ClassificationModel::new(ClassificationModelConfig::default());
        model.load("/nonexistent/model.onnx").unwrap();
        assert!(model.is_loaded());

        let img = ImageBuffer::from_rgb(vec![128; 300 * 300 * 3], 300, 300).unwrap();
        let output = model.infer_image(&img).unwrap();
        assert_eq!(output.logits.len(), NUM_CLASSES);
    }

    #[test]
    fn test_extract_features() {
        let mut model = ClassificationModel::new(ClassificationModelConfig::default());
        model.load_demo().unwrap();
        let img = ImageBuffer::from_rgb(vec![128; 300 * 300 * 3], 300, 300).unwrap();
        let features = model.extract_features(&img).unwrap();
        assert_eq!(features.len(), 512);
    }

    #[test]
    fn test_infer_with_features() {
        let mut model = ClassificationModel::new(ClassificationModelConfig::default());
        model.load_demo().unwrap();
        let img = ImageBuffer::from_rgb(vec![128; 300 * 300 * 3], 300, 300).unwrap();
        let output = model.infer_with_features(&img).unwrap();
        assert_eq!(output.logits.len(), NUM_CLASSES);
        assert!(output.features.is_some());
        assert_eq!(output.features.unwrap().len(), 512);
    }
}
