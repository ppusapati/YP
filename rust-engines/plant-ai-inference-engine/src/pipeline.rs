//! Inference batch preparation and model configuration.

use ndarray::Array4;
use rayon::prelude::*;
use serde::{Deserialize, Serialize};
use thiserror::Error;

use crate::preprocessing::{ImageBuffer, PreprocessConfig, PreprocessError, preprocess_image};

/// Errors from the inference pipeline.
#[derive(Debug, Error)]
pub enum PipelineError {
    #[error("Empty batch: no images provided")]
    EmptyBatch,

    #[error("Preprocessing error for image {index}: {source}")]
    PreprocessFailed {
        index: usize,
        source: PreprocessError,
    },

    #[error("Batch size exceeds maximum: {actual} > {max}")]
    BatchTooLarge { actual: usize, max: usize },

    #[error("Model not loaded")]
    ModelNotLoaded,

    #[error("Model load error: {0}")]
    ModelLoadError(String),

    #[error("Inference error: {0}")]
    InferenceError(String),
}

/// Model configuration.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ModelConfig {
    /// Number of output classes.
    pub num_classes: usize,
    /// Input image size.
    pub input_size: u32,
    /// Maximum batch size.
    pub max_batch_size: usize,
    /// Class names.
    pub class_names: Vec<String>,
    /// Preprocessing configuration.
    pub preprocess: PreprocessConfig,
}

impl Default for ModelConfig {
    fn default() -> Self {
        Self {
            num_classes: 38,
            input_size: 224,
            max_batch_size: 64,
            class_names: Vec::new(),
            preprocess: PreprocessConfig::default(),
        }
    }
}

/// A prepared inference batch (NCHW layout).
#[derive(Debug)]
pub struct InferenceBatch {
    /// Tensor data in NCHW format.
    pub data: Array4<f32>,
    /// Number of images in the batch.
    pub batch_size: usize,
    /// Original image indices (for mapping results back).
    pub indices: Vec<usize>,
}

/// Raw inference result from model execution.
#[derive(Debug, Clone)]
pub struct InferenceResult {
    /// Output logits of shape (batch_size, num_classes).
    pub logits: Vec<Vec<f32>>,
    /// Original image indices.
    pub indices: Vec<usize>,
}

/// Prepare a batch of images for inference.
///
/// Preprocesses images in parallel and stacks them into a single NCHW tensor.
pub fn prepare_batch(
    images: &[ImageBuffer],
    config: &ModelConfig,
) -> Result<InferenceBatch, PipelineError> {
    if images.is_empty() {
        return Err(PipelineError::EmptyBatch);
    }
    if images.len() > config.max_batch_size {
        return Err(PipelineError::BatchTooLarge {
            actual: images.len(),
            max: config.max_batch_size,
        });
    }

    let preprocessed: Result<Vec<_>, _> = images
        .par_iter()
        .enumerate()
        .map(|(i, img)| {
            preprocess_image(img, &config.preprocess).map_err(|e| PipelineError::PreprocessFailed {
                index: i,
                source: e,
            })
        })
        .collect();

    let tensors = preprocessed?;
    let n = tensors.len();
    let (c, h, w) = (3, config.input_size as usize, config.input_size as usize);

    let mut batch = Array4::<f32>::zeros((n, c, h, w));
    for (i, tensor) in tensors.iter().enumerate() {
        for ch in 0..c {
            for row in 0..h {
                for col in 0..w {
                    batch[[i, ch, row, col]] = tensor[[ch, row, col]];
                }
            }
        }
    }

    Ok(InferenceBatch {
        data: batch,
        batch_size: n,
        indices: (0..n).collect(),
    })
}

/// Split images into batches of a given size.
pub fn split_into_batches(
    images: &[ImageBuffer],
    batch_size: usize,
) -> Vec<Vec<usize>> {
    images
        .chunks(batch_size)
        .enumerate()
        .map(|(batch_idx, chunk)| {
            (0..chunk.len())
                .map(|i| batch_idx * batch_size + i)
                .collect()
        })
        .collect()
}

/// Device selection for inference.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum DeviceType {
    /// CPU inference.
    CPU,
    /// GPU inference (CUDA).
    CUDA,
    /// GPU inference with specific device ID.
    CUDADevice(usize),
}

impl Default for DeviceType {
    fn default() -> Self {
        DeviceType::CPU
    }
}

/// Model format specification.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum ModelFormat {
    /// ONNX model file.
    ONNX,
    /// TorchScript model file.
    TorchScript,
    /// Custom weight format (for lightweight models).
    CustomWeights,
}

/// The inference pipeline: manages model configuration, preprocessing, and inference.
pub struct InferencePipeline {
    /// Model configuration.
    pub config: ModelConfig,
    /// Device for inference.
    pub device: DeviceType,
    /// Whether the model is loaded and ready.
    pub is_loaded: bool,
    /// Model weights (simplified representation for CPU inference).
    /// In production, this would hold an ONNX runtime session or similar.
    weights: Option<ModelWeights>,
    /// Number of warmup runs completed.
    warmup_count: usize,
}

/// Simplified model weights for CPU-based inference.
///
/// In a production system, this would be replaced by an actual ONNX runtime
/// session or other model framework. This implementation provides a
/// deterministic output for testing and demonstration.
#[derive(Debug, Clone)]
struct ModelWeights {
    /// Number of output classes.
    num_classes: usize,
    /// Simple linear classifier weights (flattened input -> classes).
    /// Shape: (num_classes, input_features).
    classifier_weights: Vec<Vec<f32>>,
    /// Bias per class.
    classifier_bias: Vec<f32>,
}

impl ModelWeights {
    /// Create random-initialized weights for demonstration.
    fn random_init(num_classes: usize, input_size: u32) -> Self {
        // Use a simple deterministic initialization for reproducibility.
        // In production, weights come from the trained model file.
        let input_features = (3 * input_size * input_size) as usize;
        // Use a very small subset of features to keep memory manageable
        let reduced_features = 512.min(input_features);

        let mut classifier_weights = Vec::with_capacity(num_classes);
        let mut classifier_bias = Vec::with_capacity(num_classes);

        for c in 0..num_classes {
            let mut row = Vec::with_capacity(reduced_features);
            for f in 0..reduced_features {
                // Deterministic pseudo-random initialization
                let val = ((c * 7 + f * 13 + 42) % 1000) as f32 / 10000.0 - 0.05;
                row.push(val);
            }
            classifier_weights.push(row);
            classifier_bias.push(((c * 3 + 17) % 100) as f32 / 1000.0);
        }

        Self {
            num_classes,
            classifier_weights,
            classifier_bias,
        }
    }

    /// Run inference on a single preprocessed image (CHW float tensor).
    fn forward(&self, input: &[f32]) -> Vec<f32> {
        let reduced_len = self.classifier_weights[0].len();
        let mut logits = Vec::with_capacity(self.num_classes);

        for c in 0..self.num_classes {
            let mut sum = self.classifier_bias[c];
            let n = reduced_len.min(input.len());
            for i in 0..n {
                sum += self.classifier_weights[c][i] * input[i];
            }
            logits.push(sum);
        }

        logits
    }
}

impl InferencePipeline {
    /// Create a new inference pipeline with default configuration.
    pub fn new(config: ModelConfig) -> Self {
        Self {
            config,
            device: DeviceType::CPU,
            is_loaded: false,
            weights: None,
            warmup_count: 0,
        }
    }

    /// Create a pipeline with a specific device.
    pub fn with_device(config: ModelConfig, device: DeviceType) -> Self {
        Self {
            config,
            device,
            is_loaded: false,
            weights: None,
            warmup_count: 0,
        }
    }

    /// Load a model from a file path.
    ///
    /// In production, this would load an ONNX model using ort or similar.
    /// This implementation creates a deterministic demo model.
    pub fn load_model(&mut self, _model_path: &str, _format: ModelFormat) -> Result<(), PipelineError> {
        let weights = ModelWeights::random_init(
            self.config.num_classes,
            self.config.input_size,
        );
        self.weights = Some(weights);
        self.is_loaded = true;
        self.warmup_count = 0;
        Ok(())
    }

    /// Initialize the pipeline with pre-built weights (for testing).
    pub fn load_demo_model(&mut self) -> Result<(), PipelineError> {
        self.load_model("demo", ModelFormat::CustomWeights)
    }

    /// Warm up the model by running dummy inference.
    ///
    /// This helps ensure consistent latency for subsequent calls by
    /// warming up caches and JIT compilation (if applicable).
    pub fn warmup(&mut self, num_runs: usize) -> Result<(), PipelineError> {
        if !self.is_loaded {
            return Err(PipelineError::ModelNotLoaded);
        }

        let dummy_size = self.config.input_size;
        let dummy_data = vec![128u8; (dummy_size * dummy_size * 3) as usize];
        let dummy_image = ImageBuffer::new(dummy_data, dummy_size, dummy_size, 3)
            .map_err(|e| PipelineError::InferenceError(e.to_string()))?;

        for _ in 0..num_runs {
            let _ = self.infer_single(&dummy_image)?;
        }

        self.warmup_count += num_runs;
        Ok(())
    }

    /// Run inference on a single image.
    pub fn infer_single(&self, image: &ImageBuffer) -> Result<Vec<f32>, PipelineError> {
        if !self.is_loaded {
            return Err(PipelineError::ModelNotLoaded);
        }

        let weights = self.weights.as_ref().ok_or(PipelineError::ModelNotLoaded)?;

        let tensor = preprocess_image(image, &self.config.preprocess)
            .map_err(|e| PipelineError::InferenceError(e.to_string()))?;

        let flat: Vec<f32> = tensor.iter().cloned().collect();
        let logits = weights.forward(&flat);

        Ok(logits)
    }

    /// Run inference on a batch of images.
    pub fn infer_batch(&self, images: &[ImageBuffer]) -> Result<InferenceResult, PipelineError> {
        if !self.is_loaded {
            return Err(PipelineError::ModelNotLoaded);
        }
        if images.is_empty() {
            return Err(PipelineError::EmptyBatch);
        }

        let weights = self.weights.as_ref().ok_or(PipelineError::ModelNotLoaded)?;

        // Preprocess all images in parallel
        let tensors: Result<Vec<_>, _> = images
            .par_iter()
            .enumerate()
            .map(|(i, img)| {
                preprocess_image(img, &self.config.preprocess)
                    .map_err(|e| PipelineError::PreprocessFailed { index: i, source: e })
            })
            .collect();
        let tensors = tensors?;

        // Run inference on each tensor
        let logits: Vec<Vec<f32>> = tensors
            .par_iter()
            .map(|tensor| {
                let flat: Vec<f32> = tensor.iter().cloned().collect();
                weights.forward(&flat)
            })
            .collect();

        let indices = (0..images.len()).collect();

        Ok(InferenceResult { logits, indices })
    }

    /// Run inference with automatic batching.
    ///
    /// Splits large image sets into batches and processes them.
    pub fn infer_auto_batch(&self, images: &[ImageBuffer]) -> Result<InferenceResult, PipelineError> {
        if !self.is_loaded {
            return Err(PipelineError::ModelNotLoaded);
        }
        if images.is_empty() {
            return Err(PipelineError::EmptyBatch);
        }

        let batch_size = self.config.max_batch_size;
        let mut all_logits = Vec::with_capacity(images.len());
        let mut all_indices = Vec::with_capacity(images.len());

        for (batch_idx, chunk) in images.chunks(batch_size).enumerate() {
            let batch_result = self.infer_batch(chunk)?;
            for (local_idx, logit) in batch_result.logits.into_iter().enumerate() {
                all_logits.push(logit);
                all_indices.push(batch_idx * batch_size + local_idx);
            }
        }

        Ok(InferenceResult {
            logits: all_logits,
            indices: all_indices,
        })
    }

    /// Get the number of warmup runs completed.
    pub fn warmup_count(&self) -> usize {
        self.warmup_count
    }

    /// Get the current device type.
    pub fn device(&self) -> DeviceType {
        self.device
    }

    /// Set the device type (must reload model after changing).
    pub fn set_device(&mut self, device: DeviceType) {
        self.device = device;
        self.is_loaded = false;
        self.weights = None;
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn make_test_image(w: u32, h: u32) -> ImageBuffer {
        let data = vec![128u8; (w * h * 3) as usize];
        ImageBuffer::new(data, w, h, 3).unwrap()
    }

    #[test]
    fn test_prepare_batch() {
        let images = vec![make_test_image(100, 100), make_test_image(200, 150)];
        let config = ModelConfig::default();
        let batch = prepare_batch(&images, &config).unwrap();
        assert_eq!(batch.batch_size, 2);
        assert_eq!(batch.data.shape(), &[2, 3, 224, 224]);
    }

    #[test]
    fn test_empty_batch() {
        let images: Vec<ImageBuffer> = vec![];
        let config = ModelConfig::default();
        assert!(prepare_batch(&images, &config).is_err());
    }

    #[test]
    fn test_batch_too_large() {
        let images: Vec<ImageBuffer> = (0..100).map(|_| make_test_image(10, 10)).collect();
        let config = ModelConfig {
            max_batch_size: 10,
            ..Default::default()
        };
        assert!(prepare_batch(&images, &config).is_err());
    }

    #[test]
    fn test_split_into_batches() {
        let images: Vec<ImageBuffer> = (0..7).map(|_| make_test_image(10, 10)).collect();
        let batches = split_into_batches(&images, 3);
        assert_eq!(batches.len(), 3);
        assert_eq!(batches[0], vec![0, 1, 2]);
        assert_eq!(batches[1], vec![3, 4, 5]);
        assert_eq!(batches[2], vec![6]);
    }

    #[test]
    fn test_inference_pipeline_creation() {
        let pipeline = InferencePipeline::new(ModelConfig::default());
        assert!(!pipeline.is_loaded);
        assert_eq!(pipeline.device(), DeviceType::CPU);
    }

    #[test]
    fn test_inference_pipeline_load_demo() {
        let mut pipeline = InferencePipeline::new(ModelConfig {
            num_classes: 5,
            input_size: 32,
            ..Default::default()
        });
        pipeline.load_demo_model().unwrap();
        assert!(pipeline.is_loaded);
    }

    #[test]
    fn test_inference_pipeline_infer_single() {
        let mut pipeline = InferencePipeline::new(ModelConfig {
            num_classes: 5,
            input_size: 32,
            max_batch_size: 4,
            preprocess: PreprocessConfig {
                target_width: 32,
                target_height: 32,
                center_crop: false,
                resize_size: None,
                ..Default::default()
            },
            ..Default::default()
        });
        pipeline.load_demo_model().unwrap();

        let img = make_test_image(50, 50);
        let logits = pipeline.infer_single(&img).unwrap();
        assert_eq!(logits.len(), 5);
    }

    #[test]
    fn test_inference_pipeline_infer_batch() {
        let mut pipeline = InferencePipeline::new(ModelConfig {
            num_classes: 3,
            input_size: 32,
            max_batch_size: 10,
            preprocess: PreprocessConfig {
                target_width: 32,
                target_height: 32,
                center_crop: false,
                resize_size: None,
                ..Default::default()
            },
            ..Default::default()
        });
        pipeline.load_demo_model().unwrap();

        let images: Vec<ImageBuffer> = (0..3).map(|_| make_test_image(40, 40)).collect();
        let result = pipeline.infer_batch(&images).unwrap();
        assert_eq!(result.logits.len(), 3);
        assert_eq!(result.logits[0].len(), 3);
    }

    #[test]
    fn test_inference_not_loaded() {
        let pipeline = InferencePipeline::new(ModelConfig::default());
        let img = make_test_image(10, 10);
        assert!(pipeline.infer_single(&img).is_err());
    }

    #[test]
    fn test_warmup() {
        let mut pipeline = InferencePipeline::new(ModelConfig {
            num_classes: 3,
            input_size: 32,
            preprocess: PreprocessConfig {
                target_width: 32,
                target_height: 32,
                center_crop: false,
                resize_size: None,
                ..Default::default()
            },
            ..Default::default()
        });
        pipeline.load_demo_model().unwrap();
        pipeline.warmup(3).unwrap();
        assert_eq!(pipeline.warmup_count(), 3);
    }

    #[test]
    fn test_set_device() {
        let mut pipeline = InferencePipeline::new(ModelConfig::default());
        pipeline.load_demo_model().unwrap();
        assert!(pipeline.is_loaded);

        pipeline.set_device(DeviceType::CUDA);
        assert!(!pipeline.is_loaded); // Must reload after device change
        assert_eq!(pipeline.device(), DeviceType::CUDA);
    }

    #[test]
    fn test_infer_auto_batch() {
        let mut pipeline = InferencePipeline::new(ModelConfig {
            num_classes: 3,
            input_size: 32,
            max_batch_size: 2,
            preprocess: PreprocessConfig {
                target_width: 32,
                target_height: 32,
                center_crop: false,
                resize_size: None,
                ..Default::default()
            },
            ..Default::default()
        });
        pipeline.load_demo_model().unwrap();

        let images: Vec<ImageBuffer> = (0..5).map(|_| make_test_image(40, 40)).collect();
        let result = pipeline.infer_auto_batch(&images).unwrap();
        assert_eq!(result.logits.len(), 5);
    }
}
