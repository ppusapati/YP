//! High-level plant species classification pipeline.
//!
//! Migrated from Python `plant_classification/inference.py`.
//! Provides the `PlantClassifier` that orchestrates preprocessing,
//! model inference, and softmax postprocessing.

use serde::{Deserialize, Serialize};

use crate::model::{ClassificationModel, ClassificationModelConfig, ModelError};
use crate::preprocess::{ImageBuffer, tta_augment};
use crate::types::{ClassificationResult, PlantClass, TopKPrediction};

/// Configuration for the classification pipeline.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ClassifierConfig {
    /// Number of top candidates to return.
    pub top_k: usize,
    /// Minimum confidence for inclusion in candidates.
    pub min_confidence: f32,
    /// Enable test-time augmentation (averages predictions over multiple views).
    pub enable_tta: bool,
}

impl Default for ClassifierConfig {
    fn default() -> Self {
        Self {
            top_k: 5,
            min_confidence: 0.01,
            enable_tta: false,
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
        self.logits_to_result(&output.logits)
    }

    /// Classify with test-time augmentation.
    ///
    /// Runs inference on 6 augmented views (original, horizontal flip,
    /// 4 corner/center crops at 90%) and averages the logits before softmax.
    pub fn classify_with_tta(&self, image: &ImageBuffer) -> Result<ClassificationResult, ModelError> {
        let views = tta_augment(image);
        let num_views = views.len();
        let mut avg_logits: Option<Vec<f32>> = None;

        for view in &views {
            let output = self.model.infer_image(view)?;
            match &mut avg_logits {
                None => avg_logits = Some(output.logits),
                Some(acc) => {
                    for (a, l) in acc.iter_mut().zip(output.logits.iter()) {
                        *a += l;
                    }
                }
            }
        }

        let logits: Vec<f32> = avg_logits
            .unwrap_or_default()
            .into_iter()
            .map(|l| l / num_views as f32)
            .collect();

        self.logits_to_result(&logits)
    }

    /// Classify a single image, using TTA if enabled in config.
    pub fn classify_auto(&self, image: &ImageBuffer) -> Result<ClassificationResult, ModelError> {
        if self.config.enable_tta {
            self.classify_with_tta(image)
        } else {
            self.classify(image)
        }
    }

    /// Classify a batch of images.
    pub fn classify_batch(
        &self,
        images: &[ImageBuffer],
    ) -> Result<Vec<ClassificationResult>, ModelError> {
        images.iter().map(|img| self.classify_auto(img)).collect()
    }

    /// Extract the 512-dim feature vector from the backbone for an image.
    ///
    /// Useful for similarity search, clustering, or transfer learning.
    pub fn extract_features(&self, image: &ImageBuffer) -> Result<Vec<f32>, ModelError> {
        self.model.extract_features(image)
    }

    /// Classify and return both the classification result and feature vector.
    pub fn classify_with_features(
        &self,
        image: &ImageBuffer,
    ) -> Result<(ClassificationResult, Vec<f32>), ModelError> {
        let output = self.model.infer_with_features(image)?;
        let result = self.logits_to_result(&output.logits)?;
        let features = output.features.unwrap_or_default();
        Ok((result, features))
    }

    /// Get the current classifier configuration.
    pub fn config(&self) -> &ClassifierConfig {
        &self.config
    }

    fn logits_to_result(&self, logits: &[f32]) -> Result<ClassificationResult, ModelError> {
        let probs = softmax(logits);

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

        predictions.sort_by(|a, b| {
            b.probability
                .partial_cmp(&a.probability)
                .unwrap_or(std::cmp::Ordering::Equal)
        });

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

    #[test]
    fn test_classify_with_tta() {
        let classifier = PlantClassifier::with_defaults().unwrap();
        let img = make_test_image(300, 300);
        let result = classifier.classify_with_tta(&img).unwrap();
        assert!(result.confidence >= 0.0);
        assert!(result.confidence <= 1.0);
        assert!(!result.top_k.is_empty());
    }

    #[test]
    fn test_classify_auto_without_tta() {
        let classifier = PlantClassifier::with_defaults().unwrap();
        let img = make_test_image(300, 300);
        let no_tta = classifier.classify(&img).unwrap();
        let auto = classifier.classify_auto(&img).unwrap();
        assert_eq!(no_tta.predicted_class, auto.predicted_class);
        assert!((no_tta.confidence - auto.confidence).abs() < 1e-6);
    }

    #[test]
    fn test_classify_auto_with_tta() {
        let mut model = ClassificationModel::new(ClassificationModelConfig::default());
        model.load_demo().unwrap();
        let config = ClassifierConfig {
            enable_tta: true,
            ..ClassifierConfig::default()
        };
        let classifier = PlantClassifier::new(model, config);
        let img = make_test_image(300, 300);
        let result = classifier.classify_auto(&img).unwrap();
        assert!(result.confidence >= 0.0);
        assert!(result.confidence <= 1.0);
    }

    #[test]
    fn test_extract_features() {
        let classifier = PlantClassifier::with_defaults().unwrap();
        let img = make_test_image(300, 300);
        let features = classifier.extract_features(&img).unwrap();
        assert_eq!(features.len(), 512);
    }

    #[test]
    fn test_classify_with_features() {
        let classifier = PlantClassifier::with_defaults().unwrap();
        let img = make_test_image(300, 300);
        let (result, features) = classifier.classify_with_features(&img).unwrap();
        assert!(result.confidence >= 0.0);
        assert_eq!(features.len(), 512);
    }
}
