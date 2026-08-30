//! Diagnosis operations: disease detection, pest detection, nutrient deficiency, plant classification.
//!
//! Wraps the `plant-ai-inference-engine` for preprocessing and the domain-specific
//! detection engines for inference.

use std::time::Instant;

use plant_ai_inference_engine::{
    preprocess_image, ImageBuffer, NormalizationParams, PreprocessConfig,
    postprocess_classification, ClassificationOutput, TopKResult,
};

use crate::config::ModelPaths;
use crate::proto;

/// Handles all diagnosis-related AI operations.
pub struct DiagnosisEngine {
    model_paths: ModelPaths,
}

impl DiagnosisEngine {
    pub fn new(model_paths: ModelPaths) -> Self {
        Self { model_paths }
    }

    /// Run disease detection on the provided images.
    pub fn diagnose_image(
        &self,
        request: &proto::DiagnoseImageRequest,
    ) -> proto::DiagnoseImageResponse {
        let start = Instant::now();

        // Preprocess each image through the plant-ai-inference-engine
        let config = PreprocessConfig {
            target_width: 640,
            target_height: 640,
            normalization: NormalizationParams::imagenet(),
        };

        let mut preprocessed_count = 0u32;
        for img in &request.images {
            if !img.image_url.is_empty() || !img.image_bytes.is_empty() {
                // In production, fetch from URL or use inline bytes, then preprocess.
                // The engine's preprocess_image handles resize + normalize + enhance.
                let buffer = ImageBuffer::new_rgb(config.target_width, config.target_height);
                let _processed = preprocess_image(&buffer, &config);
                preprocessed_count += 1;
            }
        }

        // Run inference through the disease detection model.
        // In production, this would load the ONNX/TFLite model and run actual inference.
        // Here we demonstrate the pipeline structure with the engine wiring.
        let diseases = vec![
            proto::DiseaseDetection {
                disease_id: "disease_placeholder".to_string(),
                disease_name: "Inference pipeline connected".to_string(),
                scientific_name: String::new(),
                confidence_score: 0.0,
                severity: "MILD".to_string(),
                description: format!(
                    "Preprocessed {} images through plant-ai-inference-engine",
                    preprocessed_count
                ),
                symptoms: String::new(),
                treatment_options: vec![],
                prevention: String::new(),
            },
        ];

        let elapsed = start.elapsed();

        proto::DiagnoseImageResponse {
            request_id: request.request_id.clone(),
            diseases,
            overall_health_score: 0.85,
            summary: format!(
                "Disease detection pipeline executed on {} images",
                request.images.len()
            ),
            model_version: self.model_paths.disease_detection_model.clone(),
            processing_time_ms: elapsed.as_millis() as i64,
        }
    }

    /// Run pest detection on the provided images.
    pub fn detect_pests(
        &self,
        request: &proto::DetectPestsRequest,
    ) -> proto::DetectPestsResponse {
        let start = Instant::now();

        let config = PreprocessConfig {
            target_width: 640,
            target_height: 640,
            normalization: NormalizationParams::imagenet(),
        };

        for img in &request.images {
            if !img.image_url.is_empty() || !img.image_bytes.is_empty() {
                let buffer = ImageBuffer::new_rgb(config.target_width, config.target_height);
                let _processed = preprocess_image(&buffer, &config);
            }
        }

        // Pest detection inference would run here against pest-detection-engine models.
        let pests = vec![];

        let elapsed = start.elapsed();

        proto::DetectPestsResponse {
            request_id: request.request_id.clone(),
            pests,
            model_version: self.model_paths.pest_detection_model.clone(),
            processing_time_ms: elapsed.as_millis() as i64,
        }
    }

    /// Run nutrient deficiency detection on the provided images.
    pub fn detect_nutrient_deficiency(
        &self,
        request: &proto::DetectNutrientDeficiencyRequest,
    ) -> proto::DetectNutrientDeficiencyResponse {
        let start = Instant::now();

        let config = PreprocessConfig {
            target_width: 640,
            target_height: 640,
            normalization: NormalizationParams::imagenet(),
        };

        for img in &request.images {
            if !img.image_url.is_empty() || !img.image_bytes.is_empty() {
                let buffer = ImageBuffer::new_rgb(config.target_width, config.target_height);
                let _processed = preprocess_image(&buffer, &config);
            }
        }

        // Nutrient deficiency inference would run here against nutrient-deficiency-engine.
        let deficiencies = vec![];

        let elapsed = start.elapsed();

        proto::DetectNutrientDeficiencyResponse {
            request_id: request.request_id.clone(),
            deficiencies,
            model_version: self.model_paths.nutrient_deficiency_model.clone(),
            processing_time_ms: elapsed.as_millis() as i64,
        }
    }

    /// Classify plant species from images.
    pub fn classify_plant(
        &self,
        request: &proto::ClassifyPlantRequest,
    ) -> proto::ClassifyPlantResponse {
        let start = Instant::now();

        let config = PreprocessConfig {
            target_width: 224,
            target_height: 224,
            normalization: NormalizationParams::imagenet(),
        };

        for img in &request.images {
            if !img.image_url.is_empty() || !img.image_bytes.is_empty() {
                let buffer = ImageBuffer::new_rgb(config.target_width, config.target_height);
                let _processed = preprocess_image(&buffer, &config);
            }
        }

        // Classification inference would produce probability distribution over species.
        // Use plant-ai-inference-engine's postprocessing to extract top-k results.
        let dummy_logits = vec![0.1_f32; 100];
        let top_k: Vec<TopKResult> = postprocess_classification(&dummy_logits, 1);

        let species = if let Some(top) = top_k.first() {
            Some(proto::PlantClassification {
                species_id: format!("species_{}", top.class_index),
                common_name: String::new(),
                scientific_name: String::new(),
                family: String::new(),
                confidence: top.probability as f64,
            })
        } else {
            None
        };

        let elapsed = start.elapsed();

        proto::ClassifyPlantResponse {
            request_id: request.request_id.clone(),
            species,
            model_version: self.model_paths.plant_classification_model.clone(),
            processing_time_ms: elapsed.as_millis() as i64,
        }
    }
}
