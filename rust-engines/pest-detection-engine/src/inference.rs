//! High-level pest detection inference pipeline.
//!
//! Migrated from Python `pest_detection/inference.py`.

use serde::{Deserialize, Serialize};

use crate::model::{PestModel, PestModelConfig, ModelError};
use crate::preprocess::ImageBuffer;
use crate::types::{BoundingBox, DetectedPest, PestDetectionResult, PestSpecies, RiskLevel};

/// Detection pipeline configuration.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DetectorConfig {
    pub confidence_threshold: f32,
}

impl Default for DetectorConfig {
    fn default() -> Self {
        Self { confidence_threshold: 0.3 }
    }
}

fn sigmoid(x: f32) -> f32 {
    1.0 / (1.0 + (-x).exp())
}

/// Pest detection inference engine.
pub struct PestDetector {
    model: PestModel,
    config: DetectorConfig,
}

impl PestDetector {
    pub fn new(model: PestModel, config: DetectorConfig) -> Self {
        Self { model, config }
    }

    pub fn with_defaults() -> Result<Self, ModelError> {
        let mut model = PestModel::new(PestModelConfig::default());
        model.load_demo()?;
        Ok(Self::new(model, DetectorConfig::default()))
    }

    /// Detect pests in a single image.
    pub fn detect(&self, image: &ImageBuffer) -> Result<PestDetectionResult, ModelError> {
        let output = self.model.infer_image(image)?;
        let probs: Vec<f32> = output.classification_logits.iter().map(|&l| sigmoid(l)).collect();

        let mut pests = Vec::new();
        let mut no_pest_prob: f32 = 0.0;

        for (idx, &prob) in probs.iter().enumerate() {
            if let Some(species) = PestSpecies::from_index(idx) {
                if species.is_no_pest() {
                    no_pest_prob = prob;
                    continue;
                }
                if prob >= self.config.confidence_threshold {
                    let risk = RiskLevel::from_confidence_and_count(prob, 1);
                    pests.push(DetectedPest {
                        pest_species: species,
                        confidence: prob,
                        risk_level: risk,
                        treatment: species.treatment().to_string(),
                    });
                }
            }
        }

        pests.sort_by(|a, b| b.confidence.partial_cmp(&a.confidence).unwrap_or(std::cmp::Ordering::Equal));

        let has_pest = !pests.is_empty();

        let (overall_risk, overall_confidence) = if !pests.is_empty() {
            let max_conf = pests.iter().map(|p| p.confidence).fold(0.0f32, f32::max);
            let combined_risk = RiskLevel::from_confidence_and_count(max_conf, pests.len());
            let worst_individual = pests.iter().map(|p| p.risk_level).max().unwrap_or(RiskLevel::None);
            let overall = if combined_risk > worst_individual { combined_risk } else { worst_individual };
            (overall, max_conf)
        } else {
            (RiskLevel::None, no_pest_prob)
        };

        let bbox = if has_pest {
            output.bbox.map(|b| BoundingBox { x1: b[0], y1: b[1], x2: b[2], y2: b[3] })
        } else {
            None
        };

        Ok(PestDetectionResult {
            pests,
            has_pest,
            overall_risk,
            overall_confidence,
            bbox,
        })
    }

    /// Detect pests in a batch of images.
    pub fn detect_batch(&self, images: &[ImageBuffer]) -> Result<Vec<PestDetectionResult>, ModelError> {
        images.iter().map(|img| self.detect(img)).collect()
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
        let detector = PestDetector::with_defaults().unwrap();
        let result = detector.detect(&make_test_image(300, 300)).unwrap();
        assert!(result.overall_confidence >= 0.0);
    }

    #[test]
    fn test_detect_batch() {
        let detector = PestDetector::with_defaults().unwrap();
        let images = vec![make_test_image(200, 200), make_test_image(300, 250)];
        let results = detector.detect_batch(&images).unwrap();
        assert_eq!(results.len(), 2);
    }
}
