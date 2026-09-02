//! High-level plant species classification pipeline.
//!
//! Migrated from Python `plant_classification/inference.py`.
//! Provides the `PlantClassifier` that orchestrates preprocessing,
//! model inference, and softmax postprocessing.

use serde::{Deserialize, Serialize};

use crate::model::{ClassificationModel, ClassificationModelConfig, ModelError};
use crate::preprocess::ImageBuffer;
use crate::types::{ClassificationResult, PlantClass, TopKPrediction};

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

        let mut predictions: Vec<TopKPrediction> = Vec::new();

        for (idx, &prob) in probs.iter().enumerate() {
            if let Some(class) = PlantClass::from_index(idx) {
                if prob >= self.config.min_confidence {
                    predictions.push(TopKPrediction {
                        class,
                        probability: prob,
                    });
                }
            }
        }

        // Sort by probability descending
        predictions.sort_by(|a, b| {
            b.probability
                .partial_cmp(&a.probability)
                .unwrap_or(std::cmp::Ordering::Equal)
        });

        // Apply top-k
        if self.config.top_k > 0 && predictions.len() > self.config.top_k {
            predictions.truncate(self.config.top_k);
        }

        let (predicted_class, confidence) = if let Some(top) = predictions.first() {
            (top.class, top.probability)
        } else {
            (PlantClass::AppleAppleScab, 0.0)
        };

        Ok(ClassificationResult {
            predicted_class,
            confidence,
            top_k: predictions,
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
        assert!(!result.top_k.is_empty());
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
        assert!(result.top_k.len() <= 5);
    }
}
