//! Nutrient Deficiency Detection Engine
//!
//! High-performance inference pipeline for plant nutrient deficiency
//! detection using DenseNet-121 backbone with softmax severity
//! classification. Monitors 10 essential nutrients (N, P, K, Ca, Mg,
//! S, Fe, Zn, Mn, B) with four severity levels.
//!
//! Migrated from `python-ai/nutrient_deficiency/`.

pub mod inference;
pub mod model;
pub mod preprocess;
pub mod types;

pub use inference::{DeficiencyDetector, DetectorConfig};
pub use model::{DeficiencyModel, DeficiencyModelConfig, ModelError, ModelOutput};
pub use preprocess::{ImageBuffer, PreprocessConfig, preprocess_image, preprocess_batch};
pub use types::{
    Nutrient, DeficiencySeverity, NutrientDeficiency, DeficiencyResult,
    NUM_NUTRIENT_CLASSES, NUM_SEVERITY_CLASSES,
};
