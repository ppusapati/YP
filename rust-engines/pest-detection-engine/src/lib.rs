//! Pest Detection Engine
//!
//! Lightweight inference pipeline for pest detection using MobileNetV3-Large backbone.
//! Supports 23 pest classes with risk assessment and treatment recommendations.
//!
//! Migrated from `python-ai/pest_detection/`.

pub mod inference;
pub mod model;
pub mod nms;
pub mod preprocess;
pub mod types;

pub use inference::{PestDetector, DetectorConfig};
pub use model::{PestModel, PestModelConfig};
pub use nms::{Detection, non_maximum_suppression, class_aware_nms};
pub use preprocess::{ImageBuffer, PreprocessConfig, preprocess_image, preprocess_batch};
pub use types::{
    BoundingBox, DetectedPest, PestDetectionResult, PestSpecies, RiskLevel, NUM_PEST_CLASSES,
};
