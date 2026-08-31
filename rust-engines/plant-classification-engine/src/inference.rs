//! High-level plant species classification pipeline.
//!
//! Migrated from Python `plant_classification/inference.py`.
//! Provides the `PlantClassifier` that orchestrates preprocessing,
//! model inference, and softmax postprocessing.

use serde::{Deserialize, Serialize};

use crate::model::{ClassificationModel, ClassificationModelConfig, ModelError};
use crate::preprocess::ImageBuffer;
use crate::types::{ClassificationResult, ConfidenceLevel, PlantSpecies, SpeciesCandidate};

/// Configuration for the classification pipeline.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ClassifierConfig {
    /// Number of top candidates to return.
    pub top_k: usize,
    /// Minimum confidence for inclusion in candidates.
    pub min_confidence: f32,
}

impl Default for ClassifierConfig {
    fn default() -> Self {
        Self {
            top_k: 5,
            min_confidence: 0.01,
        }
    }
}

/// Softmax activation over logits.
fn softmax(logits: &[f32]) -> Vec<f32> {
    let max_val = logits.iter().cloned().fold(f32::NEG_INFINITY, f32::max);
    let exps: Vec<f32> = logits.iter().map(|&l| (l - max_val).exp()).collect();
    let sum: f32 = exps.iter().sum();
    if sum > 0.0 {
        exps.iter().map(|&e| e / sum).collect()
    } else {
        vec![1.0 / logits.len() as f32; logits.len()]
    }
}

/// Plant species classification engine.
///
/// Wraps the model and provides high-level classification methods
/// matching the Python `PlantClassifier` API.
pub struct PlantClassifier {
    model: ClassificationModel,
    config: ClassifierConfig,
}

impl PlantClassifier {
    /// Create a new classifier with the given model and config.
    pub fn new(model: ClassificationModel, config: ClassifierConfig) -> Self {
        Self { model, config }
    }

    /// Create with default settings.
    pub fn with_defaults() -> Result<Self, ModelError> {
        let mut model = ClassificationModel::new(ClassificationModelConfig::default());
        model.load_demo()?;
        Ok(Self::new(model, ClassifierConfig::default()))
    }

    /// Classify a single image.
    pub fn classify(&self, image: &ImageBuffer) -> Result<ClassificationResult, ModelError> {
        let output = self.model.infer_image(image)?;
        let probs = softmax(&output.logits);

        let mut candidates: Vec<SpeciesCandidate> = Vec::new();

        for (idx, &prob) in probs.iter().enumerate() {
            if let Some(species) = PlantSpecies::from_index(idx) {
                if prob >= self.config.min_confidence {
                    candidates.push(SpeciesCandidate {
                        species,
                        confidence: prob,
                        confidence_level: ConfidenceLevel::from_score(prob),
                        scientific_name: species.scientific_name().to_string(),
                    });
                }
            }
        }

        // Sort by confidence descending
        candidates.sort_by(|a, b| {
            b.confidence
                .partial_cmp(&a.confidence)
                .unwrap_or(std::cmp::Ordering::Equal)
        });

        // Apply top-k
        if self.config.top_k > 0 && candidates.len() > self.config.top_k {
            candidates.truncate(self.config.top_k);
        }

        let (predicted_species, confidence, confidence_level) = if let Some(top) = candidates.first()
        {
            (top.species, top.confidence, top.confidence_level)
        } else {
            (PlantSpecies::Apple, 0.0, ConfidenceLevel::Low)
        };

        Ok(ClassificationResult {
            candidates,
            predicted_species,
            confidence,
            confidence_level,
        })
    }

    /// Classify a batch of images.
    pub fn classify_batch(
        &self,
        images: &[ImageBuffer],
    ) -> Result<Vec<ClassificationResult>, ModelError> {
        images.iter().map(|img| self.classify(img)).collect()
    }

    /// Get the current classifier configuration.
    pub fn config(&self) -> &ClassifierConfig {
        &self.config
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn make_test_image(w: u32, h: u32) -> ImageBuffer {
        ImageBuffer::from_rgb(vec![128u8; (w * h * 3) as usize], w, h).unwrap()
    }

    #[test]
    fn test_classify_single() {
        let classifier = PlantClassifier::with_defaults().unwrap();
        let img = make_test_image(300, 300);
        let result = classifier.classify(&img).unwrap();
        assert!(result.confidence >= 0.0);
        assert!(result.confidence <= 1.0);
        assert!(!result.candidates.is_empty());
    }

    #[test]
    fn test_classify_batch() {
        let classifier = PlantClassifier::with_defaults().unwrap();
        let images = vec![make_test_image(200, 200), make_test_image(300, 250)];
        let results = classifier.classify_batch(&images).unwrap();
        assert_eq!(results.len(), 2);
    }

    #[test]
    fn test_softmax() {
        let logits = vec![1.0, 2.0, 3.0];
        let probs = softmax(&logits);
        let sum: f32 = probs.iter().sum();
        assert!((sum - 1.0).abs() < 1e-5);
        assert!(probs[2] > probs[1]);
        assert!(probs[1] > probs[0]);
    }

    #[test]
    fn test_top_k() {
        let classifier = PlantClassifier::with_defaults().unwrap();
        let img = make_test_image(300, 300);
        let result = classifier.classify(&img).unwrap();
        assert!(result.candidates.len() <= 5);
    }
}
