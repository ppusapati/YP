//! Disease Detection Engine
//!
//! High-performance inference pipeline for plant disease detection using
//! EfficientNet-B4 backbone with U-Net segmentation decoder.
//! Supports 38 PlantVillage disease classes with severity scoring
//! and disease localization heatmaps.
//!
//! Migrated from `python-ai/disease_detection/`.

pub mod heatmap;
pub mod inference;
pub mod model;
pub mod preprocess;
pub mod types;

pub use heatmap::DiseaseHeatmap;
pub use inference::{DiseaseDetector, DetectorConfig};
pub use model::{DiseaseModel, DiseaseModelConfig, ModelFormat, ModelOutput};
pub use preprocess::{ImageBuffer, PreprocessConfig, preprocess_image, preprocess_batch};
pub use types::{DiseaseClass, DiseaseResult, DiagnosisResult, SeverityLevel, NUM_DISEASE_CLASSES};
