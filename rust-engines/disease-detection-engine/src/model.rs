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

/// ONNX Runtime model wrapper for disease detection.
///
/// Loads and runs inference on an ONNX-exported EfficientNet-B4 + U-Net model.
/// Only available when compiled with the `onnx` feature.
#[cfg(feature = "onnx")]
struct OnnxModel {
    session: std::sync::Mutex<ort::session::Session>,
    num_classes: usize,
    input_size: u32,
    segmentation_enabled: bool,
}

#[cfg(feature = "onnx")]
impl OnnxModel {
    /// Load an ONNX model from the given file path.
    fn load(
        path: &str,
        num_classes: usize,
        input_size: u32,
        segmentation_enabled: bool,
    ) -> Result<Self, ModelError> {
        let session = ort::session::Session::builder()
            .map_err(|e| ModelError::LoadError(format!("Failed to create session builder: {e}")))?
            .with_optimization_level(ort::session::builder::GraphOptimizationLevel::Level3)
            .map_err(|e| ModelError::LoadError(format!("Failed to set optimization level: {e}")))?
            .commit_from_file(path)
            .map_err(|e| ModelError::LoadError(format!("Failed to load ONNX model from '{path}': {e}")))?;

        Ok(Self {
            session: std::sync::Mutex::new(session),
            num_classes,
            input_size,
            segmentation_enabled,
        })
    }

    /// Run inference on a preprocessed CHW tensor, returning classification logits
    /// and optional segmentation logits.
    fn forward(&self, input: &[f32]) -> Result<ModelOutput, ModelError> {
        let size = self.input_size as usize;
        let input_tensor = ort::value::Tensor::from_array(
            ([1usize, 3, size, size], input.to_vec()),
        ).map_err(|e| ModelError::InferenceError(format!("Failed to create input tensor: {e}")))?;

        let mut session = self.session.lock()
            .map_err(|e| ModelError::InferenceError(format!("Session lock poisoned: {e}")))?;
        let outputs = session.run(ort::inputs![input_tensor])
            .map_err(|e| ModelError::InferenceError(format!("ONNX inference failed: {e}")))?;

        // First output: classification logits [1, num_classes]
        let (_, cls_data) = outputs[0]
            .try_extract_tensor::<f32>()
            .map_err(|e| ModelError::InferenceError(format!("Failed to extract classification output: {e}")))?;
        let classification_logits: Vec<f32> = cls_data.iter().copied().take(self.num_classes).collect();

        // Second output (optional): segmentation logits [1, 1, H, W]
        let (segmentation_logits, segmentation_size) = if self.segmentation_enabled && outputs.len() > 1 {
            let (seg_shape, seg_data) = outputs[1]
                .try_extract_tensor::<f32>()
                .map_err(|e| ModelError::InferenceError(format!("Failed to extract segmentation output: {e}")))?;
            let dims: &[i64] = &*seg_shape;
            let seg_h = if dims.len() >= 3 { dims[dims.len() - 2] as usize } else { size };
            let seg_w = if dims.len() >= 2 { dims[dims.len() - 1] as usize } else { size };
            (Some(seg_data.to_vec()), Some((seg_h, seg_w)))
        } else {
            (None, None)
        };

        Ok(ModelOutput {
            classification_logits,
            segmentation_logits,
            segmentation_size,
        })
    }
}

/// Selects the active inference backend.
enum ModelBackend {
    /// Deterministic demo weights for testing.
    Demo(DemoWeights),
    /// ONNX Runtime session for production inference.
    #[cfg(feature = "onnx")]
    Onnx(OnnxModel),
}

/// Disease detection model session.
///
/// Manages model loading and raw inference. In production (with the `onnx`
/// feature), wraps an ONNX Runtime session; for testing, uses deterministic
/// demo weights.
pub struct DiseaseModel {
    config: DiseaseModelConfig,
    backend: Option<ModelBackend>,
    is_loaded: bool,
}

impl DiseaseModel {
    /// Create a new model session.
    pub fn new(config: DiseaseModelConfig) -> Self {
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
    ///
    /// Without the `onnx` feature, always uses `DemoWeights`.
    pub fn load(&mut self, #[allow(unused)] path: &str, _format: ModelFormat) -> Result<(), ModelError> {
        #[cfg(feature = "onnx")]
        {
            match OnnxModel::load(
                path,
                self.config.num_classes,
                self.config.input_size,
                self.config.segmentation_enabled,
            ) {
                Ok(onnx) => {
                    eprintln!("[disease-detection] Loaded ONNX model from '{path}'");
                    self.backend = Some(ModelBackend::Onnx(onnx));
                    self.is_loaded = true;
                    return Ok(());
                }
                Err(e) => {
                    eprintln!(
                        "[disease-detection] WARNING: Failed to load ONNX model from '{path}': {e}. \
                         Falling back to demo weights."
                    );
                }
            }
        }

        #[cfg(not(feature = "onnx"))]
        {
            eprintln!(
                "[disease-detection] ONNX feature not enabled; using demo weights \
                 (compile with --features onnx to load real models)."
            );
        }

        let weights = DemoWeights::init(self.config.num_classes);
        self.backend = Some(ModelBackend::Demo(weights));
        self.is_loaded = true;
        Ok(())
    }

    /// Load a demo model for testing.
    pub fn load_demo(&mut self) -> Result<(), ModelError> {
        let weights = DemoWeights::init(self.config.num_classes);
        self.backend = Some(ModelBackend::Demo(weights));
        self.is_loaded = true;
        Ok(())
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
        let backend = self.backend.as_ref().ok_or(ModelError::NotLoaded)?;

        match backend {
            ModelBackend::Demo(weights) => {
                let flat: Vec<f32> = tensor.iter().cloned().collect();
                let classification_logits = weights.forward(&flat);

                // Simulate segmentation output if enabled
                let (segmentation_logits, segmentation_size) = if self.config.segmentation_enabled {
                    let seg_h = self.config.input_size as usize;
                    let seg_w = self.config.input_size as usize;
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
            #[cfg(feature = "onnx")]
            ModelBackend::Onnx(onnx) => {
                let flat: Vec<f32> = tensor.iter().cloned().collect();
                onnx.forward(&flat)
            }
        }
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

    #[test]
    fn test_load_fallback_to_demo() {
        let mut model = DiseaseModel::new(DiseaseModelConfig::default());
        // Loading a non-existent path should fall back to demo weights
        model.load("/nonexistent/model.onnx", ModelFormat::Onnx).unwrap();
        assert!(model.is_loaded());

        let img = make_test_image(300, 300);
        let output = model.infer_image(&img).unwrap();
        assert_eq!(output.classification_logits.len(), NUM_DISEASE_CLASSES);
    }
}
