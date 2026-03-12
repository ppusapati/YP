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
}
