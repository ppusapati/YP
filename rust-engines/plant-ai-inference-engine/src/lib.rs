//! Plant AI Inference Engine
//!
//! High-performance image preprocessing and AI model inference pipeline.
//! Handles image normalization, tiling, batch preparation, and result postprocessing.

pub mod preprocessing;
pub mod pipeline;
pub mod postprocessing;

pub use preprocessing::{ImageBuffer, NormalizationParams, PreprocessConfig, preprocess_image};
pub use pipeline::{InferenceBatch, InferenceResult, ModelConfig, prepare_batch};
pub use postprocessing::{ClassificationOutput, DetectionBox, TopKResult, postprocess_classification};
