//! Plant Classification Engine
//!
//! High-performance inference pipeline for plant species classification
//! using ResNet50 backbone. Supports 38 PlantVillage species classes
//! with softmax confidence scoring and scientific name lookup.
//!
//! Migrated from `python-ai/plant_classification/`.

pub mod inference;
pub mod model;
pub mod preprocess;
pub mod types;

pub use inference::{PlantClassifier, ClassifierConfig};
pub use model::{ClassificationModel, ClassificationModelConfig, ModelError, ModelOutput};
pub use preprocess::{ImageBuffer, PreprocessConfig, preprocess_image, preprocess_batch};
pub use types::{PlantClass, TopKPrediction, ClassificationResult, NUM_CLASSES};
