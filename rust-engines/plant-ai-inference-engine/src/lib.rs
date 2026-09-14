//! Plant AI Inference Engine
//!
//! High-performance image preprocessing and AI model inference pipeline.
//! Handles image normalization, tiling, batch preparation, and result postprocessing.

pub mod explain;
pub mod multitask;
pub mod onnx;
pub mod pipeline;
pub mod postprocessing;
pub mod preprocessing;

pub use explain::{FocusRegion, Heatmap, DEFAULT_FOCUS_THRESHOLD};
pub use multitask::{
    MultiTaskClassifier, MultiTaskManifest, Normalization, TaskEntry, MANIFEST_FILE_NAME,
};
pub use onnx::{
    OnnxClassifier, OnnxError, LABELS_FILE_NAME, MODEL_FILE_NAME, TRAINING_META_FILE_NAME,
};
pub use pipeline::{prepare_batch, InferenceBatch, InferenceResult, ModelConfig};
pub use postprocessing::{
    postprocess_classification, ClassificationOutput, DetectionBox, TopKResult,
};
pub use preprocessing::{preprocess_image, ImageBuffer, NormalizationParams, PreprocessConfig};
