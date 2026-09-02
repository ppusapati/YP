//! Model session management for pest detection.

use serde::{Deserialize, Serialize};
use thiserror::Error;

use crate::preprocess::{ImageBuffer, PreprocessConfig, PreprocessError, preprocess_image};
use crate::types::NUM_PEST_CLASSES;

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

/// ONNX Runtime model wrapper for pest detection.
///
/// Loads and runs inference on an ONNX-exported MobileNetV3-Large model.
/// Only available when compiled with the `onnx` feature.
#[cfg(feature = "onnx")]
struct OnnxModel {
    session: ort::session::Session,
    num_classes: usize,
    input_size: u32,
    with_bbox: bool,
}

#[cfg(feature = "onnx")]
impl OnnxModel {
    fn load(
        path: &str,
        num_classes: usize,
        input_size: u32,
        with_bbox: bool,
    ) -> Result<Self, ModelError> {
        let session = ort::session::Session::builder()
            .map_err(|e| ModelError::LoadError(format!("Failed to create session builder: {e}")))?
            .with_optimization_level(ort::session::builder::GraphOptimizationLevel::Level3)
            .map_err(|e| ModelError::LoadError(format!("Failed to set optimization level: {e}")))?
            .commit_from_file(path)
            .map_err(|e| ModelError::LoadError(format!("Failed to load ONNX model from '{path}': {e}")))?;

        Ok(Self { session, num_classes, input_size, with_bbox })
    }

    fn forward(&self, input: &[f32]) -> Result<ModelOutput, ModelError> {
        let size = self.input_size as usize;
        let input_array = ndarray::Array4::from_shape_vec(
            (1, 3, size, size),
            input.to_vec(),
        ).map_err(|e| ModelError::InferenceError(format!("Input shape error: {e}")))?;

        let outputs = self.session.run(
            ort::inputs![input_array]
                .map_err(|e| ModelError::InferenceError(format!("Failed to create inputs: {e}")))?,
        ).map_err(|e| ModelError::InferenceError(format!("ONNX inference failed: {e}")))?;

        // First output: classification logits [1, num_classes]
        let cls_tensor = outputs[0]
            .try_extract_tensor::<f32>()
            .map_err(|e| ModelError::InferenceError(format!("Failed to extract classification output: {e}")))?;
        let classification_logits: Vec<f32> = cls_tensor.iter().copied().take(self.num_classes).collect();

        // Second output (optional): bounding box [1, 4]
        let bbox = if self.with_bbox && outputs.len() > 1 {
            let bbox_tensor = outputs[1]
                .try_extract_tensor::<f32>()
                .map_err(|e| ModelError::InferenceError(format!("Failed to extract bbox output: {e}")))?;
            let vals: Vec<f32> = bbox_tensor.iter().copied().take(4).collect();
            if vals.len() == 4 {
                Some([vals[0], vals[1], vals[2], vals[3]])
            } else {
                None
            }
        } else {
            None
        };

        Ok(ModelOutput { classification_logits, bbox })
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

/// Pest detection model session.
pub struct PestModel {
    config: PestModelConfig,
    backend: Option<ModelBackend>,
    is_loaded: bool,
}

impl PestModel {
    pub fn new(config: PestModelConfig) -> Self {
        Self { config, backend: None, is_loaded: false }
    }

    /// Load model from a file path.
    ///
    /// When compiled with the `onnx` feature, attempts to load an ONNX model
    /// first. If the file does not exist or loading fails, falls back to
    /// `DemoWeights` with a warning printed to stderr.
    pub fn load(&mut self, #[allow(unused)] path: &str) -> Result<(), ModelError> {
        #[cfg(feature = "onnx")]
        {
            match OnnxModel::load(
                path,
                self.config.num_classes,
                self.config.input_size,
                self.config.with_bbox,
            ) {
                Ok(onnx) => {
                    eprintln!("[pest-detection] Loaded ONNX model from '{path}'");
                    self.backend = Some(ModelBackend::Onnx(onnx));
                    self.is_loaded = true;
                    return Ok(());
                }
                Err(e) => {
                    eprintln!(
                        "[pest-detection] WARNING: Failed to load ONNX model from '{path}': {e}. \
                         Falling back to demo weights."
                    );
                }
            }
        }

        #[cfg(not(feature = "onnx"))]
        {
            eprintln!(
                "[pest-detection] ONNX feature not enabled; using demo weights \
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

    pub fn is_loaded(&self) -> bool {
        self.is_loaded
    }

    pub fn config(&self) -> &PestModelConfig {
        &self.config
    }

    pub fn infer_image(&self, image: &ImageBuffer) -> Result<ModelOutput, ModelError> {
        let backend = self.backend.as_ref().ok_or(ModelError::NotLoaded)?;
        let tensor = preprocess_image(image, &self.config.preprocess)?;
        let flat: Vec<f32> = tensor.iter().cloned().collect();

        match backend {
            ModelBackend::Demo(weights) => {
                let logits = weights.forward(&flat);
                let bbox = if self.config.with_bbox {
                    Some([0.3, 0.3, 0.7, 0.7]) // Demo bbox
                } else {
                    None
                };
                Ok(ModelOutput { classification_logits: logits, bbox })
            }
            #[cfg(feature = "onnx")]
            ModelBackend::Onnx(onnx) => onnx.forward(&flat),
        }
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

    #[test]
    fn test_load_fallback_to_demo() {
        let mut model = PestModel::new(PestModelConfig::default());
        model.load("/nonexistent/model.onnx").unwrap();
        assert!(model.is_loaded());

        let img = ImageBuffer::from_rgb(vec![128; 300 * 300 * 3], 300, 300).unwrap();
        let out = model.infer_image(&img).unwrap();
        assert_eq!(out.classification_logits.len(), NUM_PEST_CLASSES);
    }
}
