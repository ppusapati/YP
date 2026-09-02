//! High-level nutrient deficiency detection pipeline.
//!
//! Migrated from Python `nutrient_deficiency/inference.py`.
//! Provides the `DeficiencyDetector` that orchestrates preprocessing,
//! model inference, classification postprocessing, and ordinal severity
//! regression.

use serde::{Deserialize, Serialize};

use crate::model::{DeficiencyModel, DeficiencyModelConfig, ModelError};
use crate::preprocess::ImageBuffer;
use crate::types::{DeficiencyResult, DeficiencySeverity, Nutrient, NutrientDeficiency};

/// Configuration for the deficiency detection pipeline.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DetectorConfig {
    /// Minimum confidence for a nutrient deficiency to be reported.
    pub confidence_threshold: f32,
    /// Number of top deficiencies to report (0 = all above threshold).
    pub top_k: usize,
}

impl Default for DetectorConfig {
    fn default() -> Self {
        Self {
            confidence_threshold: 0.3,
            top_k: 0,
        }
    }
}

/// Sigmoid activation for multi-label classification.
fn sigmoid(x: f32) -> f32 {
    1.0 / (1.0 + (-x).exp())
}

/// Nutrient deficiency detection engine.
///
/// Wraps the DenseNet-121 model and provides high-level detection
/// methods with ordinal severity regression.
pub struct DeficiencyDetector {
    model: DeficiencyModel,
    config: DetectorConfig,
}

impl DeficiencyDetector {
    /// Create a new detector with the given model and config.
    pub fn new(model: DeficiencyModel, config: DetectorConfig) -> Self {
        Self { model, config }
    }

    /// Create with default settings.
    pub fn with_defaults() -> Result<Self, ModelError> {
        let mut model = DeficiencyModel::new(DeficiencyModelConfig::default());
        model.load_demo()?;
        Ok(Self::new(model, DetectorConfig::default()))
    }

    /// Detect nutrient deficiencies in a single image.
    pub fn detect(&self, image: &ImageBuffer) -> Result<DeficiencyResult, ModelError> {
        let output = self.model.infer_image(image)?;

        // Apply sigmoid to classification logits (multi-label)
        let cls_probs: Vec<f32> = output
            .classification_logits
            .iter()
            .map(|&l| sigmoid(l))
            .collect();

        let mut deficiencies = Vec::new();

        for (idx, &prob) in cls_probs.iter().enumerate() {
            if prob >= self.config.confidence_threshold {
                if let Some(nutrient) = Nutrient::from_index(idx) {
                    let sev_logits = if idx < output.severity_logits.len() {
                        &output.severity_logits[idx]
                    } else {
                        &vec![0.0; 4]
                    };

                    // Apply softmax to severity logits, then argmax to get severity class
                    let (severity, severity_probs) =
                        DeficiencySeverity::from_softmax_logits(sev_logits);

                    deficiencies.push(NutrientDeficiency {
                        nutrient,
                        confidence: prob,
                        severity,
                        severity_probs,
                        recommendation: nutrient.recommendation().to_string(),
                    });
                }
            }
        }

        // Sort by severity descending, then confidence descending
        deficiencies.sort_by(|a, b| {
            b.severity
                .cmp(&a.severity)
                .then_with(|| {
                    b.confidence
                        .partial_cmp(&a.confidence)
                        .unwrap_or(std::cmp::Ordering::Equal)
                })
        });

        // Apply top-k limit
        if self.config.top_k > 0 && deficiencies.len() > self.config.top_k {
            deficiencies.truncate(self.config.top_k);
        }

        let is_healthy = deficiencies.is_empty();
        let worst_severity = deficiencies
            .iter()
            .map(|d| d.severity)
            .max()
            .unwrap_or(DeficiencySeverity::None);
        let overall_confidence = deficiencies
            .iter()
            .map(|d| d.confidence)
            .fold(0.0f32, f32::max);

        Ok(DeficiencyResult {
            deficiencies,
            is_healthy,
            worst_severity,
            overall_confidence,
        })
    }

    /// Detect deficiencies in a batch of images.
    pub fn detect_batch(
        &self,
        images: &[ImageBuffer],
    ) -> Result<Vec<DeficiencyResult>, ModelError> {
        images.iter().map(|img| self.detect(img)).collect()
    }

    /// Get the current detection configuration.
    pub fn config(&self) -> &DetectorConfig {
        &self.config
    }

    /// Update the confidence threshold.
    pub fn set_confidence_threshold(&mut self, threshold: f32) {
        self.config.confidence_threshold = threshold;
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn make_test_image(w: u32, h: u32) -> ImageBuffer {
        ImageBuffer::from_rgb(vec![128u8; (w * h * 3) as usize], w, h).unwrap()
    }

    #[test]
    fn test_detect_single() {
        let detector = DeficiencyDetector::with_defaults().unwrap();
        let img = make_test_image(300, 300);
        let result = detector.detect(&img).unwrap();
        assert!(result.overall_confidence >= 0.0);
    }

    #[test]
    fn test_detect_batch() {
        let detector = DeficiencyDetector::with_defaults().unwrap();
        let images = vec![make_test_image(200, 200), make_test_image(300, 250)];
        let results = detector.detect_batch(&images).unwrap();
        assert_eq!(results.len(), 2);
    }

    #[test]
    fn test_sigmoid() {
        assert!((sigmoid(0.0) - 0.5).abs() < 1e-6);
        assert!(sigmoid(10.0) > 0.99);
        assert!(sigmoid(-10.0) < 0.01);
    }
}
