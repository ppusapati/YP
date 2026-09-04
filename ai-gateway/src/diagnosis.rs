//! Diagnosis operations: disease detection, pest detection, nutrient deficiency, plant classification.
//!
//! Wraps the domain-specific detection/classification engines for inference.

use std::time::Instant;

use disease_detection_engine::{
    DiseaseDetector,
    ImageBuffer as DiseaseImageBuffer,
};
use nutrient_deficiency_engine::{
    DeficiencyDetector,
    ImageBuffer as DeficiencyImageBuffer,
};
use pest_detection_engine::{
    PestDetector,
    ImageBuffer as PestImageBuffer,
};
use plant_classification_engine::{
    PlantClassifier,
    ImageBuffer as ClassificationImageBuffer,
};

use crate::proto;

pub struct DiagnosisEngine {
    disease_detector: DiseaseDetector,
    pest_detector: PestDetector,
    deficiency_detector: DeficiencyDetector,
    plant_classifier: PlantClassifier,
}

impl DiagnosisEngine {
    pub fn new() -> Result<Self, String> {
        let disease_detector = DiseaseDetector::with_defaults()
            .map_err(|e| format!("failed to init disease detector: {e}"))?;
        let pest_detector = PestDetector::with_defaults()
            .map_err(|e| format!("failed to init pest detector: {e}"))?;
        let deficiency_detector = DeficiencyDetector::with_defaults()
            .map_err(|e| format!("failed to init deficiency detector: {e}"))?;
        let plant_classifier = PlantClassifier::with_defaults()
            .map_err(|e| format!("failed to init plant classifier: {e}"))?;

        Ok(Self {
            disease_detector,
            pest_detector,
            deficiency_detector,
            plant_classifier,
        })
    }

    fn extract_image_bytes(img: &proto::ImageData, width: u32, height: u32) -> Vec<u8> {
        if !img.image_bytes.is_empty() {
            img.image_bytes.clone()
        } else {
            vec![0u8; (width * height * 3) as usize]
        }
    }

    pub fn diagnose_image(
        &self,
        request: &proto::DiagnoseImageRequest,
    ) -> proto::DiagnoseImageResponse {
        let start = Instant::now();
        let mut all_diseases = Vec::new();
        let mut health_scores = Vec::new();

        for img in &request.images {
            let raw = Self::extract_image_bytes(img, 256, 256);
            let buffer = match DiseaseImageBuffer::from_rgb(raw, 256, 256) {
                Ok(b) => b,
                Err(_) => continue,
            };
            match self.disease_detector.detect(&buffer) {
                Ok(result) => {
                    health_scores.push(if result.is_healthy { 1.0 } else { 1.0 - result.overall_confidence as f64 });
                    for d in &result.diseases {
                        all_diseases.push(proto::DiseaseDetection {
                            disease_id: format!("disease_{}", d.disease_class.index()),
                            disease_name: d.disease_class.label().to_string(),
                            scientific_name: String::new(),
                            confidence_score: d.confidence as f64,
                            severity: d.severity.label().to_uppercase(),
                            description: format!("{} detected with {:.1}% confidence", d.disease_class.label(), d.confidence * 100.0),
                            symptoms: format!("Affected area: {:.1}%", d.affected_area_percentage * 100.0),
                            treatment_options: vec![],
                            prevention: String::new(),
                        });
                    }
                }
                Err(e) => {
                    tracing::warn!("disease detection failed: {e}");
                }
            }
        }

        let overall_health = if health_scores.is_empty() {
            0.0
        } else {
            health_scores.iter().sum::<f64>() / health_scores.len() as f64
        };

        let elapsed = start.elapsed();

        proto::DiagnoseImageResponse {
            request_id: request.request_id.clone(),
            diseases: all_diseases,
            overall_health_score: overall_health,
            summary: if health_scores.is_empty() {
                "No images processed".to_string()
            } else {
                format!("Analyzed {} images", health_scores.len())
            },
            model_version: "disease-detection-demo-v1".to_string(),
            processing_time_ms: elapsed.as_millis() as i64,
        }
    }

    pub fn detect_pests(
        &self,
        request: &proto::DetectPestsRequest,
    ) -> proto::DetectPestsResponse {
        let start = Instant::now();
        let mut all_pests = Vec::new();

        for img in &request.images {
            let raw = Self::extract_image_bytes(img, 640, 640);
            let buffer = match PestImageBuffer::from_rgb(raw, 640, 640) {
                Ok(b) => b,
                Err(_) => continue,
            };
            match self.pest_detector.detect(&buffer) {
                Ok(result) => {
                    for p in &result.pests {
                        if p.pest_species.is_no_pest() {
                            continue;
                        }
                        all_pests.push(proto::PestDetection {
                            pest_id: format!("pest_{}", p.pest_species.index()),
                            pest_name: p.pest_species.label().to_string(),
                            scientific_name: String::new(),
                            confidence_score: p.confidence as f64,
                            damage_level: p.risk_level.label().to_uppercase(),
                            description: format!("{} detected", p.pest_species.label()),
                            damage_pattern: String::new(),
                            control_methods: if p.treatment.is_empty() {
                                vec![]
                            } else {
                                vec![p.treatment.clone()]
                            },
                        });
                    }
                }
                Err(e) => {
                    tracing::warn!("pest detection failed: {e}");
                }
            }
        }

        let elapsed = start.elapsed();

        proto::DetectPestsResponse {
            request_id: request.request_id.clone(),
            pests: all_pests,
            model_version: "pest-detection-demo-v1".to_string(),
            processing_time_ms: elapsed.as_millis() as i64,
        }
    }

    pub fn detect_nutrient_deficiency(
        &self,
        request: &proto::DetectNutrientDeficiencyRequest,
    ) -> proto::DetectNutrientDeficiencyResponse {
        let start = Instant::now();
        let mut all_deficiencies = Vec::new();

        for img in &request.images {
            let raw = Self::extract_image_bytes(img, 256, 256);
            let buffer = match DeficiencyImageBuffer::from_rgb(raw, 256, 256) {
                Ok(b) => b,
                Err(_) => continue,
            };
            match self.deficiency_detector.detect(&buffer) {
                Ok(result) => {
                    for d in &result.deficiencies {
                        all_deficiencies.push(proto::NutrientDeficiency {
                            nutrient: format!("{} ({})", d.nutrient.label(), d.nutrient.symbol()),
                            confidence_score: d.confidence as f64,
                            severity: d.severity.label().to_uppercase(),
                            description: format!("{} deficiency detected", d.nutrient.label()),
                            visual_symptoms: String::new(),
                            recommended_fertilizers: if d.recommendation.is_empty() {
                                vec![d.nutrient.recommendation().to_string()]
                            } else {
                                vec![d.recommendation.clone()]
                            },
                            application_method: String::new(),
                        });
                    }
                }
                Err(e) => {
                    tracing::warn!("nutrient deficiency detection failed: {e}");
                }
            }
        }

        let elapsed = start.elapsed();

        proto::DetectNutrientDeficiencyResponse {
            request_id: request.request_id.clone(),
            deficiencies: all_deficiencies,
            model_version: "nutrient-deficiency-demo-v1".to_string(),
            processing_time_ms: elapsed.as_millis() as i64,
        }
    }

    pub fn classify_plant(
        &self,
        request: &proto::ClassifyPlantRequest,
    ) -> proto::ClassifyPlantResponse {
        let start = Instant::now();
        let mut best_result: Option<proto::PlantClassification> = None;

        for img in &request.images {
            let raw = Self::extract_image_bytes(img, 224, 224);
            let buffer = match ClassificationImageBuffer::from_rgb(raw, 224, 224) {
                Ok(b) => b,
                Err(_) => continue,
            };
            match self.plant_classifier.classify(&buffer) {
                Ok(result) => {
                    let candidate = proto::PlantClassification {
                        species_id: format!("class_{}", result.predicted_class.index()),
                        common_name: result.predicted_class.label().to_string(),
                        scientific_name: String::new(),
                        family: String::new(),
                        confidence: result.confidence as f64,
                    };
                    if best_result.as_ref().map_or(true, |b| candidate.confidence > b.confidence) {
                        best_result = Some(candidate);
                    }
                }
                Err(e) => {
                    tracing::warn!("plant classification failed: {e}");
                }
            }
        }

        let elapsed = start.elapsed();

        proto::ClassifyPlantResponse {
            request_id: request.request_id.clone(),
            species: best_result,
            model_version: "plant-classification-demo-v1".to_string(),
            processing_time_ms: elapsed.as_millis() as i64,
        }
    }
}
