//! High-level disease detection inference pipeline.
//!
//! Migrated from Python `disease_detection/inference.py`.
//! Provides the `DiseaseDetector` that orchestrates preprocessing,
//! model inference, and result postprocessing.

use rayon::prelude::*;
use serde::{Deserialize, Serialize};

use crate::model::{DiseaseModel, DiseaseModelConfig, ModelError, ModelOutput};
use crate::preprocess::ImageBuffer;
use crate::types::{DiseaseClass, DiseaseResult, DiagnosisResult, SeverityLevel};

/// Configuration for the detection pipeline.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DetectorConfig {
    /// Minimum confidence for disease detection (default 0.3).
    pub confidence_threshold: f32,
    /// Whether to generate disease localization heatmaps.
    pub generate_heatmap: bool,
    /// Number of top-k diseases to report (0 = all above threshold).
    pub top_k: usize,
}

impl Default for DetectorConfig {
    fn default() -> Self {
        Self {
            confidence_threshold: 0.3,
            generate_heatmap: true,
            top_k: 0,
        }
    }
}

/// Apply sigmoid activation to logits.
fn sigmoid(x: f32) -> f32 {
    1.0 / (1.0 + (-x).exp())
}

/// Postprocess model output into a diagnosis result.
///
/// Mirrors the Python `DiseaseDetector.detect()` logic:
/// 1. Apply sigmoid to classification logits (multi-label)
/// 2. Optionally process segmentation mask for affected area
/// 3. Determine severity from area or confidence
/// 4. Identify healthy vs. diseased
fn postprocess(
    output: &ModelOutput,
    config: &DetectorConfig,
) -> DiagnosisResult {
    let cls_probs: Vec<f32> = output.classification_logits.iter().map(|&l| sigmoid(l)).collect();

    // Process segmentation heatmap
    let (heatmap, heatmap_size, affected_area_pct) = if let (Some(seg_logits), Some(size)) =
        (&output.segmentation_logits, output.segmentation_size)
    {
        let heatmap: Vec<f32> = seg_logits.iter().map(|&l| sigmoid(l)).collect();
        let above_threshold = heatmap.iter().filter(|&&v| v > 0.5).count();
        let area_pct = if heatmap.is_empty() {
            0.0
        } else {
            above_threshold as f32 / heatmap.len() as f32 * 100.0
        };
        (
            if config.generate_heatmap { Some(heatmap) } else { None },
            Some(size),
            area_pct,
        )
    } else {
        (None, None, 0.0)
    };

    // Build disease results (skip healthy classes)
    let mut diseases: Vec<DiseaseResult> = Vec::new();
    let mut max_healthy_prob: f32 = 0.0;

    for (idx, &prob) in cls_probs.iter().enumerate() {
        if let Some(class) = DiseaseClass::from_index(idx) {
            if class.is_healthy() {
                max_healthy_prob = max_healthy_prob.max(prob);
                continue;
            }
            if prob >= config.confidence_threshold {
                let severity = if affected_area_pct > 0.0 {
                    SeverityLevel::from_area_percent(affected_area_pct)
                } else {
                    SeverityLevel::from_confidence(prob)
                };

                diseases.push(DiseaseResult {
                    disease_class: class,
                    confidence: prob,
                    severity,
                    affected_area_percentage: affected_area_pct,
                });
            }
        }
    }

    // Sort by confidence descending
    diseases.sort_by(|a, b| b.confidence.partial_cmp(&a.confidence).unwrap_or(std::cmp::Ordering::Equal));

    // Apply top-k limit
    if config.top_k > 0 && diseases.len() > config.top_k {
        diseases.truncate(config.top_k);
    }

    // Determine overall health status
    let is_healthy = diseases.is_empty() && max_healthy_prob > 0.7;

    // Overall severity and confidence
    let (overall_severity, overall_confidence) = if !diseases.is_empty() {
        let worst_severity = diseases.iter().map(|d| d.severity).max().unwrap_or(SeverityLevel::Mild);
        let best_confidence = diseases.iter().map(|d| d.confidence).fold(0.0f32, f32::max);
        (worst_severity, best_confidence)
    } else {
        (SeverityLevel::Mild, max_healthy_prob)
    };

    DiagnosisResult {
        diseases,
        is_healthy,
        overall_severity,
        overall_confidence,
        heatmap,
        heatmap_size,
    }
}

/// Disease detection inference engine.
///
/// Wraps the model and provides high-level detection methods matching
/// the Python `DiseaseDetector` API.
pub struct DiseaseDetector {
    model: DiseaseModel,
    detector_config: DetectorConfig,
}

impl DiseaseDetector {
    /// Create a new detector with the given model and detection config.
    pub fn new(model: DiseaseModel, config: DetectorConfig) -> Self {
        Self {
            model,
            detector_config: config,
        }
    }

    /// Create with default settings.
    pub fn with_defaults() -> Result<Self, ModelError> {
        let mut model = DiseaseModel::new(DiseaseModelConfig::default());
        model.load_demo()?;
        Ok(Self::new(model, DetectorConfig::default()))
    }

    /// Detect diseases in a single image.
    pub fn detect(&self, image: &ImageBuffer) -> Result<DiagnosisResult, ModelError> {
        let output = self.model.infer_image(image)?;
        Ok(postprocess(&output, &self.detector_config))
    }

    /// Detect diseases in a batch of images.
    pub fn detect_batch(&self, images: &[ImageBuffer]) -> Result<Vec<DiagnosisResult>, ModelError> {
        // Process images sequentially through the model (parallelism is in preprocessing)
        let mut results = Vec::with_capacity(images.len());
        for image in images {
            results.push(self.detect(image)?);
        }
        Ok(results)
    }

    /// Get the current detection configuration.
    pub fn config(&self) -> &DetectorConfig {
        &self.detector_config
    }

    /// Update the confidence threshold.
    pub fn set_confidence_threshold(&mut self, threshold: f32) {
        self.detector_config.confidence_threshold = threshold;
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn make_test_image(w: u32, h: u32) -> ImageBuffer {
        let data = vec![128u8; (w * h * 3) as usize];
        ImageBuffer::from_rgb(data, w, h).unwrap()
    }

    #[test]
    fn test_detect_single() {
        let detector = DiseaseDetector::with_defaults().unwrap();
        let img = make_test_image(300, 300);
        let result = detector.detect(&img).unwrap();
        // Result should have valid structure
        assert!(result.overall_confidence >= 0.0);
        assert!(result.overall_confidence <= 1.0);
    }

    #[test]
    fn test_detect_batch() {
        let detector = DiseaseDetector::with_defaults().unwrap();
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
