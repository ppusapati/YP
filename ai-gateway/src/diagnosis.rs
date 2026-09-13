//! Diagnosis operations: disease detection, pest detection, nutrient deficiency, plant classification.
//!
//! Each task first tries the trained ONNX classifier configured in
//! `ModelPaths` (a directory holding `model.onnx` and a label map). When no
//! model is present or inference fails, the demo detectors answer with a
//! `*-demo-*` version so the service layer can fall back to external APIs.

use std::path::Path;
use std::time::Instant;

use disease_detection_engine::{DiseaseDetector, ImageBuffer as DiseaseImageBuffer};
use nutrient_deficiency_engine::{DeficiencyDetector, ImageBuffer as DeficiencyImageBuffer};
use pest_detection_engine::{ImageBuffer as PestImageBuffer, PestDetector};
use plant_ai_inference_engine::{ClassificationOutput, OnnxClassifier};
use plant_classification_engine::{ImageBuffer as ClassificationImageBuffer, PlantClassifier};

use crate::config::ModelPaths;
use crate::proto;

/// Vision tasks served by the gateway.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum VisionTask {
    Disease,
    Pest,
    NutrientDeficiency,
    PlantClassification,
}

impl VisionTask {
    pub const ALL: [VisionTask; 4] = [
        VisionTask::Disease,
        VisionTask::Pest,
        VisionTask::NutrientDeficiency,
        VisionTask::PlantClassification,
    ];

    pub fn name(self) -> &'static str {
        match self {
            VisionTask::Disease => "disease",
            VisionTask::Pest => "pest",
            VisionTask::NutrientDeficiency => "nutrient_deficiency",
            VisionTask::PlantClassification => "plant_classification",
        }
    }
}

/// Load state of one vision model, for health reporting.
#[derive(Debug, Clone)]
pub struct ModelStatus {
    pub task: VisionTask,
    pub loaded: bool,
    pub version: String,
    pub classes: usize,
}

pub struct DiagnosisEngine {
    disease_detector: DiseaseDetector,
    pest_detector: PestDetector,
    deficiency_detector: DeficiencyDetector,
    plant_classifier: PlantClassifier,
    disease_onnx: Option<OnnxClassifier>,
    pest_onnx: Option<OnnxClassifier>,
    deficiency_onnx: Option<OnnxClassifier>,
    classification_onnx: Option<OnnxClassifier>,
}

/// Labels that mean "nothing detected" for the detection-style tasks.
const NEGATIVE_LABELS: [&str; 6] = [
    "healthy",
    "no_disease",
    "no_pest",
    "none",
    "normal",
    "no_deficiency",
];

fn is_negative_label(label: &str) -> bool {
    let l = label.trim().to_ascii_lowercase().replace([' ', '-'], "_");
    NEGATIVE_LABELS
        .iter()
        .any(|n| l == *n || l.starts_with("healthy"))
}

fn severity_from_confidence(p: f64) -> &'static str {
    if p >= 0.8 {
        "HIGH"
    } else if p >= 0.5 {
        "MEDIUM"
    } else {
        "LOW"
    }
}

fn load_model(task: VisionTask, dir: &str) -> Option<OnnxClassifier> {
    if dir.trim().is_empty() {
        return None;
    }
    match OnnxClassifier::load_dir(Path::new(dir)) {
        Ok(m) => {
            tracing::info!(
                task = task.name(),
                dir,
                version = m.version(),
                classes = m.num_classes(),
                input = m.input_size(),
                "loaded ONNX vision model"
            );
            Some(m)
        }
        Err(e) => {
            tracing::warn!(task = task.name(), dir, error = %e, "no usable ONNX model; demo/external fallback active");
            None
        }
    }
}

impl DiagnosisEngine {
    pub fn new(model_paths: &ModelPaths) -> Result<Self, String> {
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
            disease_onnx: load_model(VisionTask::Disease, &model_paths.disease_detection_model),
            pest_onnx: load_model(VisionTask::Pest, &model_paths.pest_detection_model),
            deficiency_onnx: load_model(
                VisionTask::NutrientDeficiency,
                &model_paths.nutrient_deficiency_model,
            ),
            classification_onnx: load_model(
                VisionTask::PlantClassification,
                &model_paths.plant_classification_model,
            ),
        })
    }

    /// Per-task model load state.
    pub fn model_status(&self) -> Vec<ModelStatus> {
        VisionTask::ALL
            .iter()
            .map(|&task| {
                let m = self.onnx_for(task);
                ModelStatus {
                    task,
                    loaded: m.is_some(),
                    version: m
                        .map(|m| m.version().to_string())
                        .unwrap_or_else(|| format!("{}-demo-v1", task.name().replace('_', "-"))),
                    classes: m.map(|m| m.num_classes()).unwrap_or(0),
                }
            })
            .collect()
    }

    fn onnx_for(&self, task: VisionTask) -> Option<&OnnxClassifier> {
        match task {
            VisionTask::Disease => self.disease_onnx.as_ref(),
            VisionTask::Pest => self.pest_onnx.as_ref(),
            VisionTask::NutrientDeficiency => self.deficiency_onnx.as_ref(),
            VisionTask::PlantClassification => self.classification_onnx.as_ref(),
        }
    }

    /// Run the ONNX classifier over every image with bytes; returns None when
    /// the model is absent or no image could be classified.
    fn classify_all(
        &self,
        task: VisionTask,
        images: &[proto::ImageData],
    ) -> Option<(Vec<ClassificationOutput>, String)> {
        let model = self.onnx_for(task)?;
        let mut outputs = Vec::new();
        for img in images {
            if img.image_bytes.is_empty() {
                continue;
            }
            match model.classify_image(&img.image_bytes, 3) {
                Ok(out) => outputs.push(out),
                Err(e) => {
                    tracing::warn!(task = task.name(), error = %e, "ONNX inference failed for image")
                }
            }
        }
        if outputs.is_empty() {
            return None;
        }
        Some((outputs, model.version().to_string()))
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

        if let Some((outputs, version)) = self.classify_all(VisionTask::Disease, &request.images) {
            let mut diseases = Vec::new();
            let mut health_scores = Vec::new();
            for out in &outputs {
                let healthy_prob = out
                    .top_k
                    .iter()
                    .find(|t| is_negative_label(&t.class_name))
                    .map(|t| t.probability as f64);
                if is_negative_label(&out.class_name) {
                    health_scores.push(out.confidence as f64);
                    continue;
                }
                health_scores.push(healthy_prob.unwrap_or(1.0 - out.confidence as f64));
                for t in out
                    .top_k
                    .iter()
                    .filter(|t| !is_negative_label(&t.class_name) && t.probability >= 0.2)
                {
                    let p = t.probability as f64;
                    diseases.push(proto::DiseaseDetection {
                        disease_id: format!("disease_{}", t.class_index),
                        disease_name: t.class_name.clone(),
                        scientific_name: String::new(),
                        confidence_score: p,
                        severity: severity_from_confidence(p).to_string(),
                        description: format!(
                            "{} detected with {:.1}% confidence",
                            t.class_name,
                            p * 100.0
                        ),
                        symptoms: String::new(),
                        treatment_options: vec![],
                        prevention: String::new(),
                    });
                }
            }
            let overall_health = health_scores.iter().sum::<f64>() / health_scores.len() as f64;
            return proto::DiagnoseImageResponse {
                request_id: request.request_id.clone(),
                diseases,
                overall_health_score: overall_health,
                summary: format!(
                    "Analyzed {} images with local model {}",
                    outputs.len(),
                    version
                ),
                model_version: version,
                processing_time_ms: start.elapsed().as_millis() as i64,
            };
        }

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
                    health_scores.push(if result.is_healthy {
                        1.0
                    } else {
                        1.0 - result.overall_confidence as f64
                    });
                    for d in &result.diseases {
                        all_diseases.push(proto::DiseaseDetection {
                            disease_id: format!("disease_{}", d.disease_class.index()),
                            disease_name: d.disease_class.label().to_string(),
                            scientific_name: String::new(),
                            confidence_score: d.confidence as f64,
                            severity: d.severity.label().to_uppercase(),
                            description: format!(
                                "{} detected with {:.1}% confidence",
                                d.disease_class.label(),
                                d.confidence * 100.0
                            ),
                            symptoms: format!(
                                "Affected area: {:.1}%",
                                d.affected_area_percentage * 100.0
                            ),
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
            processing_time_ms: start.elapsed().as_millis() as i64,
        }
    }

    pub fn detect_pests(&self, request: &proto::DetectPestsRequest) -> proto::DetectPestsResponse {
        let start = Instant::now();

        if let Some((outputs, version)) = self.classify_all(VisionTask::Pest, &request.images) {
            let mut pests = Vec::new();
            for out in &outputs {
                for t in out
                    .top_k
                    .iter()
                    .filter(|t| !is_negative_label(&t.class_name) && t.probability >= 0.2)
                {
                    let p = t.probability as f64;
                    pests.push(proto::PestDetection {
                        pest_id: format!("pest_{}", t.class_index),
                        pest_name: t.class_name.clone(),
                        scientific_name: String::new(),
                        confidence_score: p,
                        damage_level: severity_from_confidence(p).to_string(),
                        description: format!(
                            "{} detected with {:.1}% confidence",
                            t.class_name,
                            p * 100.0
                        ),
                        damage_pattern: String::new(),
                        control_methods: vec![],
                    });
                }
            }
            return proto::DetectPestsResponse {
                request_id: request.request_id.clone(),
                pests,
                model_version: version,
                processing_time_ms: start.elapsed().as_millis() as i64,
            };
        }

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

        proto::DetectPestsResponse {
            request_id: request.request_id.clone(),
            pests: all_pests,
            model_version: "pest-detection-demo-v1".to_string(),
            processing_time_ms: start.elapsed().as_millis() as i64,
        }
    }

    pub fn detect_nutrient_deficiency(
        &self,
        request: &proto::DetectNutrientDeficiencyRequest,
    ) -> proto::DetectNutrientDeficiencyResponse {
        let start = Instant::now();

        if let Some((outputs, version)) =
            self.classify_all(VisionTask::NutrientDeficiency, &request.images)
        {
            let mut deficiencies = Vec::new();
            for out in &outputs {
                for t in out
                    .top_k
                    .iter()
                    .filter(|t| !is_negative_label(&t.class_name) && t.probability >= 0.2)
                {
                    let p = t.probability as f64;
                    deficiencies.push(proto::NutrientDeficiency {
                        nutrient: t.class_name.clone(),
                        confidence_score: p,
                        severity: severity_from_confidence(p).to_string(),
                        description: format!(
                            "{} deficiency detected with {:.1}% confidence",
                            t.class_name,
                            p * 100.0
                        ),
                        visual_symptoms: String::new(),
                        recommended_fertilizers: vec![],
                        application_method: String::new(),
                    });
                }
            }
            return proto::DetectNutrientDeficiencyResponse {
                request_id: request.request_id.clone(),
                deficiencies,
                model_version: version,
                processing_time_ms: start.elapsed().as_millis() as i64,
            };
        }

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

        proto::DetectNutrientDeficiencyResponse {
            request_id: request.request_id.clone(),
            deficiencies: all_deficiencies,
            model_version: "nutrient-deficiency-demo-v1".to_string(),
            processing_time_ms: start.elapsed().as_millis() as i64,
        }
    }

    pub fn classify_plant(
        &self,
        request: &proto::ClassifyPlantRequest,
    ) -> proto::ClassifyPlantResponse {
        let start = Instant::now();

        if let Some((outputs, version)) =
            self.classify_all(VisionTask::PlantClassification, &request.images)
        {
            let best = outputs
                .iter()
                .max_by(|a, b| {
                    a.confidence
                        .partial_cmp(&b.confidence)
                        .unwrap_or(std::cmp::Ordering::Equal)
                })
                .map(|out| proto::PlantClassification {
                    species_id: format!("class_{}", out.class_index),
                    common_name: out.class_name.clone(),
                    scientific_name: String::new(),
                    family: String::new(),
                    confidence: out.confidence as f64,
                });
            return proto::ClassifyPlantResponse {
                request_id: request.request_id.clone(),
                species: best,
                model_version: version,
                processing_time_ms: start.elapsed().as_millis() as i64,
            };
        }

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
                    if best_result
                        .as_ref()
                        .map_or(true, |b| candidate.confidence > b.confidence)
                    {
                        best_result = Some(candidate);
                    }
                }
                Err(e) => {
                    tracing::warn!("plant classification failed: {e}");
                }
            }
        }

        proto::ClassifyPlantResponse {
            request_id: request.request_id.clone(),
            species: best_result,
            model_version: "plant-classification-demo-v1".to_string(),
            processing_time_ms: start.elapsed().as_millis() as i64,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn negative_labels_and_severity() {
        assert!(is_negative_label("healthy"));
        assert!(is_negative_label("Healthy Leaf"));
        assert!(is_negative_label("no-pest"));
        assert!(!is_negative_label("leaf_rust"));
        assert_eq!(severity_from_confidence(0.95), "HIGH");
        assert_eq!(severity_from_confidence(0.6), "MEDIUM");
        assert_eq!(severity_from_confidence(0.3), "LOW");
    }

    #[test]
    fn without_models_all_tasks_report_demo() {
        let engine = DiagnosisEngine::new(&ModelPaths::default()).unwrap();
        let status = engine.model_status();
        assert_eq!(status.len(), 4);
        assert!(status
            .iter()
            .all(|s| !s.loaded && s.version.contains("demo")));

        let resp = engine.diagnose_image(&proto::DiagnoseImageRequest {
            request_id: "r".into(),
            images: vec![proto::ImageData {
                image_bytes: vec![0u8; 256 * 256 * 3],
                ..Default::default()
            }],
            ..Default::default()
        });
        assert!(resp.model_version.contains("demo"));
    }

    #[test]
    fn missing_model_directory_is_tolerated() {
        let paths = ModelPaths {
            disease_detection_model: "/definitely/not/here".into(),
            ..ModelPaths::default()
        };
        let engine = DiagnosisEngine::new(&paths).unwrap();
        assert!(!engine.model_status()[0].loaded);
    }
}
