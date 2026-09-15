//! AIGatewayService gRPC implementation.
//!
//! Dispatches incoming gRPC requests to the appropriate Rust AI engine module.
//! Each RPC is executed on `spawn_blocking` so that CPU-bound engine work does
//! not starve the tokio runtime.
//!
//! For image-based RPCs (disease, pest, nutrient, plant classification), the
//! fallback chain is: local ONNX model → external vision API → demo weights.
//! When the external API is used, images and labels are collected for training.

use std::sync::Arc;

use tonic::{Request, Response, Status};
use uuid::Uuid;

use crate::alerting::AlertingEngine;
use crate::analytics::AnalyticsEngine;
use crate::config::Config;
use crate::data_collector::{
    CollectionInput, DataCollector, Label, LabelReview, Provenance, ReviewDecision, ReviewError,
    ReviewStatus, SampleContext, SampleOrder, SampleQuery,
};
use crate::diagnosis::DiagnosisEngine;
use crate::prescription::PrescriptionEngine;
use crate::proto;
use crate::proto::ai_gateway_service_server::AiGatewayService;
use crate::recommend::RecommendEngine;
use crate::satellite::SatelliteEngine;
use crate::terrain::TerrainEngine;
use crate::vision_client::{VisionClient, VisionResult};
use crate::water_flow::WaterFlowEngine;
use crate::yield_predict::YieldEngine;

/// The AI Gateway gRPC service implementation.
///
/// Holds `Arc` references to each engine sub-module so that cloning into
/// `spawn_blocking` tasks is cheap. Also holds the optional external vision
/// API client and data collector for the training pipeline.
pub struct AiGatewayServiceImpl {
    diagnosis: Arc<DiagnosisEngine>,
    yield_engine: Arc<YieldEngine>,
    satellite: Arc<SatelliteEngine>,
    recommend: Arc<RecommendEngine>,
    alerting: Arc<AlertingEngine>,
    analytics: Arc<AnalyticsEngine>,
    prescription: Arc<PrescriptionEngine>,
    terrain: Arc<TerrainEngine>,
    water_flow: Arc<WaterFlowEngine>,
    vision_client: Option<Arc<VisionClient>>,
    data_collector: Arc<DataCollector>,
}

impl AiGatewayServiceImpl {
    /// Create a new service from configuration. Initialises all engine modules.
    pub fn new(config: &Config) -> Result<Self, String> {
        let model_paths = config.models.clone();
        let diagnosis = DiagnosisEngine::new(&model_paths)
            .map_err(|e| format!("diagnosis engine init failed: {e}"))?;
        for status in diagnosis.model_status() {
            tracing::info!(
                task = status.task.name(),
                loaded = status.loaded,
                version = %status.version,
                classes = status.classes,
                "vision model status"
            );
        }

        let vision_client = if config.external_api.enabled {
            match VisionClient::new(&config.external_api) {
                Ok(vc) => {
                    tracing::info!(
                        provider = ?config.external_api.provider,
                        "external vision API enabled"
                    );
                    Some(Arc::new(vc))
                }
                Err(e) => {
                    tracing::warn!("external vision API init failed: {e}, continuing without");
                    None
                }
            }
        } else {
            None
        };

        let data_collector = Arc::new(DataCollector::new(&config.data_collection));
        if config.data_collection.enabled {
            tracing::info!(
                dir = %config.data_collection.storage_dir,
                "data collection for model training enabled"
            );
        }

        Ok(Self {
            diagnosis: Arc::new(diagnosis),
            yield_engine: Arc::new(YieldEngine::new(model_paths.clone())),
            satellite: Arc::new(SatelliteEngine::new(model_paths.clone())),
            recommend: Arc::new(RecommendEngine::new(model_paths)),
            alerting: Arc::new(AlertingEngine::new()),
            analytics: Arc::new(AnalyticsEngine::new()),
            prescription: Arc::new(PrescriptionEngine::new()),
            terrain: Arc::new(TerrainEngine::new()),
            water_flow: Arc::new(WaterFlowEngine::new()),
            vision_client,
            data_collector,
        })
    }

    fn is_demo_model(version: &str) -> bool {
        version.contains("demo")
    }

    /// Load state of the local vision models, for health reporting.
    pub fn vision_model_status(&self) -> Vec<crate::diagnosis::ModelStatus> {
        self.diagnosis.model_status()
    }

    fn collect_image_bytes(images: &[proto::ImageData]) -> Vec<u8> {
        images
            .first()
            .map(|img| img.image_bytes.clone())
            .unwrap_or_default()
    }

    /// Store a locally-served prediction as a training sample so low-confidence
    /// cases surface in the review queue (active learning).
    async fn collect_local(
        &self,
        task: &str,
        images: &[proto::ImageData],
        labels: Vec<Label>,
        model_version: &str,
        context: &SampleContext,
    ) {
        if !self.data_collector.is_enabled() || labels.is_empty() {
            return;
        }
        let image_bytes = Self::collect_image_bytes(images);
        if image_bytes.is_empty() {
            return;
        }
        self.data_collector
            .collect(CollectionInput {
                task: task.to_string(),
                image_bytes,
                labels,
                provenance: Provenance::LocalModel,
                source: model_version.to_string(),
                raw_response: None,
                context: context.clone(),
            })
            .await;
    }

    fn review_error(e: ReviewError) -> Status {
        match e {
            ReviewError::UnknownTask(_) | ReviewError::Invalid(_) => {
                Status::invalid_argument(e.to_string())
            }
            ReviewError::NotFound(_) => Status::not_found(e.to_string()),
            ReviewError::Forbidden(_) => Status::permission_denied(e.to_string()),
            ReviewError::Io(_) | ReviewError::Json(_) => Status::internal(e.to_string()),
        }
    }

    fn vision_to_diseases(vr: &VisionResult) -> Vec<proto::DiseaseDetection> {
        vr.detections
            .iter()
            .map(|d| proto::DiseaseDetection {
                disease_id: format!("ext_{}", d.label.to_lowercase().replace(' ', "_")),
                disease_name: d.label.clone(),
                scientific_name: d.scientific_name.clone(),
                confidence_score: d.confidence,
                severity: if d.severity.is_empty() {
                    severity_from_confidence(d.confidence)
                } else {
                    d.severity.clone()
                },
                description: d.description.clone(),
                symptoms: String::new(),
                treatment_options: d.recommendations.clone(),
                prevention: String::new(),
            })
            .collect()
    }

    fn vision_to_pests(vr: &VisionResult) -> Vec<proto::PestDetection> {
        vr.detections
            .iter()
            .map(|d| proto::PestDetection {
                pest_id: format!("ext_{}", d.label.to_lowercase().replace(' ', "_")),
                pest_name: d.label.clone(),
                scientific_name: d.scientific_name.clone(),
                confidence_score: d.confidence,
                damage_level: if d.severity.is_empty() {
                    severity_from_confidence(d.confidence)
                } else {
                    d.severity.clone()
                },
                description: d.description.clone(),
                damage_pattern: String::new(),
                control_methods: d.recommendations.clone(),
            })
            .collect()
    }

    fn vision_to_deficiencies(vr: &VisionResult) -> Vec<proto::NutrientDeficiency> {
        vr.detections
            .iter()
            .map(|d| proto::NutrientDeficiency {
                nutrient: d.label.clone(),
                confidence_score: d.confidence,
                severity: if d.severity.is_empty() {
                    severity_from_confidence(d.confidence)
                } else {
                    d.severity.clone()
                },
                description: d.description.clone(),
                visual_symptoms: String::new(),
                recommended_fertilizers: d.recommendations.clone(),
                application_method: String::new(),
            })
            .collect()
    }

    fn vision_to_classification(vr: &VisionResult) -> Option<proto::PlantClassification> {
        vr.detections.first().map(|d| proto::PlantClassification {
            species_id: format!("ext_{}", d.label.to_lowercase().replace(' ', "_")),
            common_name: d.label.clone(),
            scientific_name: d.scientific_name.clone(),
            family: d.category.clone(),
            confidence: d.confidence,
        })
    }
}

fn severity_from_confidence(confidence: f64) -> String {
    if confidence > 0.8 {
        "SEVERE".to_string()
    } else if confidence > 0.5 {
        "MODERATE".to_string()
    } else {
        "MILD".to_string()
    }
}

/// Ensure the request carries a request_id; generate one if empty.
fn ensure_request_id(id: &str) -> String {
    if id.is_empty() {
        Uuid::new_v4().to_string()
    } else {
        id.to_string()
    }
}

#[tonic::async_trait]
impl AiGatewayService for AiGatewayServiceImpl {
    // ─── Plant Diagnosis ─────────────────────────────────────────────

    async fn diagnose_image(
        &self,
        request: Request<proto::DiagnoseImageRequest>,
    ) -> Result<Response<proto::DiagnoseImageResponse>, Status> {
        let mut req = request.into_inner();
        req.request_id = ensure_request_id(&req.request_id);
        let request_id = req.request_id.clone();
        let images_clone = req.images.clone();
        let sample_context = SampleContext::from_proto(&req.context, &request_id);
        tracing::info!(request_id = %request_id, images = req.images.len(), "DiagnoseImage");

        let engine = self.diagnosis.clone();
        let result = tokio::task::spawn_blocking(move || engine.diagnose_image(&req))
            .await
            .map_err(|e| Status::internal(format!("diagnosis task panicked: {e}")))?;

        if !Self::is_demo_model(&result.model_version) {
            let labels = result
                .diseases
                .iter()
                .map(|d| Label {
                    name: d.disease_name.clone(),
                    scientific_name: d.scientific_name.clone(),
                    confidence: d.confidence_score,
                    category: "disease".into(),
                    severity: d.severity.clone(),
                })
                .collect();
            self.collect_local(
                "disease",
                &images_clone,
                labels,
                &result.model_version,
                &sample_context,
            )
            .await;
        }

        if Self::is_demo_model(&result.model_version) {
            if let Some(ref vc) = self.vision_client {
                let image_bytes = Self::collect_image_bytes(&images_clone);
                if !image_bytes.is_empty() {
                    match vc.diagnose_disease(&image_bytes, "").await {
                        Ok(vr) => {
                            self.data_collector
                                .collect(CollectionInput::from_vision_result(
                                    image_bytes,
                                    vr.clone(),
                                    sample_context.clone(),
                                ))
                                .await;
                            let diseases = Self::vision_to_diseases(&vr);
                            let health = if diseases.is_empty() {
                                1.0
                            } else {
                                1.0 - diseases.iter().map(|d| d.confidence_score).sum::<f64>()
                                    / diseases.len() as f64
                            };
                            return Ok(Response::new(proto::DiagnoseImageResponse {
                                request_id,
                                diseases,
                                overall_health_score: health,
                                summary: format!("Diagnosed via {} API", vr.provider),
                                model_version: format!("external-{}", vr.provider),
                                processing_time_ms: result.processing_time_ms,
                                // External providers return labels only.
                                explanations: Vec::new(),
                            }));
                        }
                        Err(e) => {
                            tracing::warn!(
                                "external API fallback failed for disease diagnosis: {e}"
                            );
                        }
                    }
                }
            }
        }

        Ok(Response::new(result))
    }

    async fn detect_pests(
        &self,
        request: Request<proto::DetectPestsRequest>,
    ) -> Result<Response<proto::DetectPestsResponse>, Status> {
        let mut req = request.into_inner();
        req.request_id = ensure_request_id(&req.request_id);
        let request_id = req.request_id.clone();
        let images_clone = req.images.clone();
        let sample_context = SampleContext::from_proto(&req.context, &request_id);
        tracing::info!(request_id = %request_id, images = req.images.len(), "DetectPests");

        let engine = self.diagnosis.clone();
        let result = tokio::task::spawn_blocking(move || engine.detect_pests(&req))
            .await
            .map_err(|e| Status::internal(format!("pest detection task panicked: {e}")))?;

        if !Self::is_demo_model(&result.model_version) {
            let labels = result
                .pests
                .iter()
                .map(|p| Label {
                    name: p.pest_name.clone(),
                    scientific_name: p.scientific_name.clone(),
                    confidence: p.confidence_score,
                    category: "pest".into(),
                    severity: p.damage_level.clone(),
                })
                .collect();
            self.collect_local(
                "pest",
                &images_clone,
                labels,
                &result.model_version,
                &sample_context,
            )
            .await;
        }

        if Self::is_demo_model(&result.model_version) {
            if let Some(ref vc) = self.vision_client {
                let image_bytes = Self::collect_image_bytes(&images_clone);
                if !image_bytes.is_empty() {
                    match vc.detect_pests(&image_bytes, "").await {
                        Ok(vr) => {
                            self.data_collector
                                .collect(CollectionInput::from_vision_result(
                                    image_bytes,
                                    vr.clone(),
                                    sample_context.clone(),
                                ))
                                .await;
                            return Ok(Response::new(proto::DetectPestsResponse {
                                request_id,
                                pests: Self::vision_to_pests(&vr),
                                model_version: format!("external-{}", vr.provider),
                                processing_time_ms: result.processing_time_ms,
                                // External providers return labels only.
                                explanations: Vec::new(),
                            }));
                        }
                        Err(e) => {
                            tracing::warn!("external API fallback failed for pest detection: {e}");
                        }
                    }
                }
            }
        }

        Ok(Response::new(result))
    }

    async fn detect_nutrient_deficiency(
        &self,
        request: Request<proto::DetectNutrientDeficiencyRequest>,
    ) -> Result<Response<proto::DetectNutrientDeficiencyResponse>, Status> {
        let mut req = request.into_inner();
        req.request_id = ensure_request_id(&req.request_id);
        let request_id = req.request_id.clone();
        let images_clone = req.images.clone();
        let sample_context = SampleContext::from_proto(&req.context, &request_id);
        tracing::info!(request_id = %request_id, images = req.images.len(), "DetectNutrientDeficiency");

        let engine = self.diagnosis.clone();
        let result = tokio::task::spawn_blocking(move || engine.detect_nutrient_deficiency(&req))
            .await
            .map_err(|e| {
                Status::internal(format!("nutrient deficiency detection panicked: {e}"))
            })?;

        if !Self::is_demo_model(&result.model_version) {
            let labels = result
                .deficiencies
                .iter()
                .map(|d| Label {
                    name: d.nutrient.clone(),
                    scientific_name: String::new(),
                    confidence: d.confidence_score,
                    category: "nutrient".into(),
                    severity: d.severity.clone(),
                })
                .collect();
            self.collect_local(
                "nutrient_deficiency",
                &images_clone,
                labels,
                &result.model_version,
                &sample_context,
            )
            .await;
        }

        if Self::is_demo_model(&result.model_version) {
            if let Some(ref vc) = self.vision_client {
                let image_bytes = Self::collect_image_bytes(&images_clone);
                if !image_bytes.is_empty() {
                    match vc.detect_nutrient_deficiency(&image_bytes, "").await {
                        Ok(vr) => {
                            self.data_collector
                                .collect(CollectionInput::from_vision_result(
                                    image_bytes,
                                    vr.clone(),
                                    sample_context.clone(),
                                ))
                                .await;
                            return Ok(Response::new(proto::DetectNutrientDeficiencyResponse {
                                request_id,
                                deficiencies: Self::vision_to_deficiencies(&vr),
                                model_version: format!("external-{}", vr.provider),
                                processing_time_ms: result.processing_time_ms,
                                // External providers return labels only.
                                explanations: Vec::new(),
                            }));
                        }
                        Err(e) => {
                            tracing::warn!(
                                "external API fallback failed for nutrient deficiency: {e}"
                            );
                        }
                    }
                }
            }
        }

        Ok(Response::new(result))
    }

    async fn classify_plant(
        &self,
        request: Request<proto::ClassifyPlantRequest>,
    ) -> Result<Response<proto::ClassifyPlantResponse>, Status> {
        let mut req = request.into_inner();
        req.request_id = ensure_request_id(&req.request_id);
        let request_id = req.request_id.clone();
        let images_clone = req.images.clone();
        let sample_context = SampleContext::from_proto(&req.context, &request_id);
        tracing::info!(request_id = %request_id, images = req.images.len(), "ClassifyPlant");

        let engine = self.diagnosis.clone();
        let result = tokio::task::spawn_blocking(move || engine.classify_plant(&req))
            .await
            .map_err(|e| Status::internal(format!("plant classification panicked: {e}")))?;

        if !Self::is_demo_model(&result.model_version) {
            let labels = result
                .species
                .iter()
                .map(|s| Label {
                    name: s.common_name.clone(),
                    scientific_name: s.scientific_name.clone(),
                    confidence: s.confidence,
                    category: s.family.clone(),
                    severity: String::new(),
                })
                .collect();
            self.collect_local(
                "plant_classification",
                &images_clone,
                labels,
                &result.model_version,
                &sample_context,
            )
            .await;
        }

        if Self::is_demo_model(&result.model_version) {
            if let Some(ref vc) = self.vision_client {
                let image_bytes = Self::collect_image_bytes(&images_clone);
                if !image_bytes.is_empty() {
                    match vc.classify_plant(&image_bytes).await {
                        Ok(vr) => {
                            self.data_collector
                                .collect(CollectionInput::from_vision_result(
                                    image_bytes,
                                    vr.clone(),
                                    sample_context.clone(),
                                ))
                                .await;
                            return Ok(Response::new(proto::ClassifyPlantResponse {
                                request_id,
                                species: Self::vision_to_classification(&vr),
                                model_version: format!("external-{}", vr.provider),
                                processing_time_ms: result.processing_time_ms,
                                // External providers return labels only.
                                explanations: Vec::new(),
                            }));
                        }
                        Err(e) => {
                            tracing::warn!(
                                "external API fallback failed for plant classification: {e}"
                            );
                        }
                    }
                }
            }
        }

        Ok(Response::new(result))
    }

    // ─── Yield Prediction ────────────────────────────────────────────

    async fn predict_yield(
        &self,
        request: Request<proto::PredictYieldRequest>,
    ) -> Result<Response<proto::PredictYieldResponse>, Status> {
        let mut req = request.into_inner();
        req.request_id = ensure_request_id(&req.request_id);
        tracing::info!(request_id = %req.request_id, crop = %req.crop_type, "PredictYield");

        let engine = self.yield_engine.clone();
        let result = tokio::task::spawn_blocking(move || engine.predict_yield(&req))
            .await
            .map_err(|e| Status::internal(format!("yield prediction panicked: {e}")))?;

        Ok(Response::new(result))
    }

    async fn simulate_crop_growth(
        &self,
        request: Request<proto::SimulateCropGrowthRequest>,
    ) -> Result<Response<proto::SimulateCropGrowthResponse>, Status> {
        let mut req = request.into_inner();
        req.request_id = ensure_request_id(&req.request_id);
        tracing::info!(
            request_id = %req.request_id,
            crop = %req.crop_type,
            days = req.simulation_days,
            "SimulateCropGrowth"
        );

        let engine = self.yield_engine.clone();
        let result = tokio::task::spawn_blocking(move || engine.simulate_crop_growth(&req))
            .await
            .map_err(|e| Status::internal(format!("crop growth simulation panicked: {e}")))?;

        Ok(Response::new(result))
    }

    // ─── Satellite / Vegetation ──────────────────────────────────────

    async fn compute_ndvi(
        &self,
        request: Request<proto::ComputeNdviRequest>,
    ) -> Result<Response<proto::ComputeNdviResponse>, Status> {
        let mut req = request.into_inner();
        req.request_id = ensure_request_id(&req.request_id);
        tracing::info!(request_id = %req.request_id, "ComputeNDVI");

        let engine = self.satellite.clone();
        let result = tokio::task::spawn_blocking(move || engine.compute_ndvi(&req))
            .await
            .map_err(|e| Status::internal(format!("NDVI computation panicked: {e}")))?;

        Ok(Response::new(result))
    }

    async fn detect_vegetation_stress(
        &self,
        request: Request<proto::DetectVegetationStressRequest>,
    ) -> Result<Response<proto::DetectVegetationStressResponse>, Status> {
        let mut req = request.into_inner();
        req.request_id = ensure_request_id(&req.request_id);
        tracing::info!(request_id = %req.request_id, "DetectVegetationStress");

        let engine = self.satellite.clone();
        let result = tokio::task::spawn_blocking(move || engine.detect_vegetation_stress(&req))
            .await
            .map_err(|e| Status::internal(format!("vegetation stress detection panicked: {e}")))?;

        Ok(Response::new(result))
    }

    // ─── Recommendations ─────────────────────────────────────────────

    async fn recommend_crops(
        &self,
        request: Request<proto::RecommendCropsRequest>,
    ) -> Result<Response<proto::RecommendCropsResponse>, Status> {
        let mut req = request.into_inner();
        req.request_id = ensure_request_id(&req.request_id);
        tracing::info!(request_id = %req.request_id, max = req.max_recommendations, "RecommendCrops");

        let engine = self.recommend.clone();
        let result = tokio::task::spawn_blocking(move || engine.recommend_crops(&req))
            .await
            .map_err(|e| Status::internal(format!("crop recommendation panicked: {e}")))?;

        Ok(Response::new(result))
    }

    // ─── Alerting ────────────────────────────────────────────────────

    async fn evaluate_field_risk(
        &self,
        request: Request<proto::EvaluateFieldRiskRequest>,
    ) -> Result<Response<proto::EvaluateFieldRiskResponse>, Status> {
        let mut req = request.into_inner();
        req.request_id = ensure_request_id(&req.request_id);
        tracing::info!(request_id = %req.request_id, field = %req.field_id, "EvaluateFieldRisk");

        let engine = self.alerting.clone();
        let result = tokio::task::spawn_blocking(move || engine.evaluate_field_risk(&req))
            .await
            .map_err(|e| Status::internal(format!("field risk evaluation panicked: {e}")))?;

        Ok(Response::new(result))
    }

    // ─── Analytics ───────────────────────────────────────────────────

    async fn compute_field_analytics(
        &self,
        request: Request<proto::ComputeFieldAnalyticsRequest>,
    ) -> Result<Response<proto::ComputeFieldAnalyticsResponse>, Status> {
        let mut req = request.into_inner();
        req.request_id = ensure_request_id(&req.request_id);
        tracing::info!(
            request_id = %req.request_id,
            field = %req.field_id,
            seasons = req.seasons.len(),
            "ComputeFieldAnalytics"
        );

        let engine = self.analytics.clone();
        let result = tokio::task::spawn_blocking(move || engine.compute_field_analytics(&req))
            .await
            .map_err(|e| Status::internal(format!("field analytics computation panicked: {e}")))?;

        Ok(Response::new(result))
    }

    // ─── Prescriptions ──────────────────────────────────────────────

    async fn generate_prescription(
        &self,
        request: Request<proto::GeneratePrescriptionRequest>,
    ) -> Result<Response<proto::GeneratePrescriptionResponse>, Status> {
        let mut req = request.into_inner();
        req.request_id = ensure_request_id(&req.request_id);
        tracing::info!(
            request_id = %req.request_id,
            field = %req.field_id,
            types = ?req.prescription_types,
            "GeneratePrescription"
        );

        let engine = self.prescription.clone();
        let result = tokio::task::spawn_blocking(move || engine.generate_prescription(&req))
            .await
            .map_err(|e| Status::internal(format!("prescription generation panicked: {e}")))?;

        Ok(Response::new(result))
    }

    // ─── Terrain Analysis ───────────────────────────────────────────

    async fn analyze_terrain(
        &self,
        request: Request<proto::AnalyzeTerrainRequest>,
    ) -> Result<Response<proto::AnalyzeTerrainResponse>, Status> {
        let mut req = request.into_inner();
        req.request_id = ensure_request_id(&req.request_id);
        tracing::info!(
            request_id = %req.request_id,
            width = req.width,
            height = req.height,
            analyses = ?req.analyses,
            "AnalyzeTerrain"
        );

        let engine = self.terrain.clone();
        let result = tokio::task::spawn_blocking(move || engine.analyze(&req))
            .await
            .map_err(|e| Status::internal(format!("terrain analysis panicked: {e}")))?;

        Ok(Response::new(result))
    }

    // ─── Water Flow Simulation ──────────────────────────────────────

    async fn simulate_water_flow(
        &self,
        request: Request<proto::SimulateWaterFlowRequest>,
    ) -> Result<Response<proto::SimulateWaterFlowResponse>, Status> {
        let mut req = request.into_inner();
        req.request_id = ensure_request_id(&req.request_id);
        tracing::info!(
            request_id = %req.request_id,
            days = req.simulation_days,
            "SimulateWaterFlow"
        );

        let engine = self.water_flow.clone();
        let result = tokio::task::spawn_blocking(move || engine.simulate(&req))
            .await
            .map_err(|e| Status::internal(format!("water flow simulation panicked: {e}")))?;

        Ok(Response::new(result))
    }

    // ─── Training Data Review ───────────────────────────────────────

    async fn list_training_samples(
        &self,
        request: Request<proto::ListTrainingSamplesRequest>,
    ) -> Result<Response<proto::ListTrainingSamplesResponse>, Status> {
        let req = request.into_inner();
        let query = SampleQuery {
            task: req.task.clone(),
            review_status: match req.review_status.as_str() {
                "" | "unreviewed" => ReviewStatus::Unreviewed,
                "reviewed" => ReviewStatus::Reviewed,
                "all" => ReviewStatus::All,
                other => {
                    return Err(Status::invalid_argument(format!(
                        "review_status must be unreviewed, reviewed, or all (got {other:?})"
                    )))
                }
            },
            tenant_id: (!req.tenant_id.is_empty()).then(|| req.tenant_id.clone()),
            min_confidence: (req.min_confidence > 0.0).then_some(req.min_confidence),
            max_confidence: (req.max_confidence > 0.0).then_some(req.max_confidence),
            provenance: if req.provenance.is_empty() {
                None
            } else {
                Some(Provenance::parse(&req.provenance).ok_or_else(|| {
                    Status::invalid_argument(format!("unknown provenance {:?}", req.provenance))
                })?)
            },
            order: match req.order.as_str() {
                "" | "confidence_asc" => SampleOrder::ConfidenceAsc,
                "newest" => SampleOrder::Newest,
                "suspect_first" => SampleOrder::SuspectFirst,
                other => return Err(Status::invalid_argument(format!("unknown order {other:?}"))),
            },
            suspect_only: req.suspect_only,
            second_opinion_only: req.second_opinion_only,
            offset: req.page_offset.max(0) as usize,
            limit: req.page_size.max(0) as usize,
        };
        let collector = self.data_collector.clone();
        let page = tokio::task::spawn_blocking(move || collector.list_samples(&query))
            .await
            .map_err(|e| Status::internal(format!("sample listing panicked: {e}")))?
            .map_err(Self::review_error)?;
        Ok(Response::new(proto::ListTrainingSamplesResponse {
            samples: page.samples.iter().map(|s| s.to_proto()).collect(),
            total_count: page.total as i32,
            unreviewed_count: page.unreviewed as i32,
        }))
    }

    async fn submit_label_review(
        &self,
        request: Request<proto::SubmitLabelReviewRequest>,
    ) -> Result<Response<proto::SubmitLabelReviewResponse>, Status> {
        let req = request.into_inner();
        let r = req
            .review
            .ok_or_else(|| Status::invalid_argument("review is required"))?;
        let decision = ReviewDecision::parse(&r.decision).ok_or_else(|| {
            Status::invalid_argument("decision must be confirmed, corrected, or rejected")
        })?;
        let review = LabelReview {
            decision,
            corrected_label: r.corrected_label,
            reviewer_id: r.reviewer_id,
            tenant_id: r.tenant_id,
            notes: r.notes,
            reviewed_at: r.reviewed_at,
        };
        tracing::info!(task = %req.task, sample = %req.sample_id, decision = decision.as_str(), "SubmitLabelReview");
        let collector = self.data_collector.clone();
        let (task, id) = (req.task, req.sample_id);
        let sample =
            tokio::task::spawn_blocking(move || collector.submit_review(&task, &id, review))
                .await
                .map_err(|e| Status::internal(format!("review panicked: {e}")))?
                .map_err(Self::review_error)?;
        Ok(Response::new(proto::SubmitLabelReviewResponse {
            sample: Some(sample.to_proto()),
        }))
    }

    async fn get_training_sample_image(
        &self,
        request: Request<proto::GetTrainingSampleImageRequest>,
    ) -> Result<Response<proto::GetTrainingSampleImageResponse>, Status> {
        let req = request.into_inner();
        let collector = self.data_collector.clone();
        let bytes = tokio::task::spawn_blocking(move || {
            collector.sample_image(&req.task, &req.sample_id, &req.tenant_id)
        })
        .await
        .map_err(|e| Status::internal(format!("image read panicked: {e}")))?
        .map_err(Self::review_error)?;
        let mime = if bytes.starts_with(&[0x89, b'P', b'N', b'G']) {
            "image/png"
        } else {
            "image/jpeg"
        };
        Ok(Response::new(proto::GetTrainingSampleImageResponse {
            image_bytes: bytes,
            mime_type: mime.to_string(),
        }))
    }

    async fn request_second_opinion(
        &self,
        request: Request<proto::RequestSecondOpinionRequest>,
    ) -> Result<Response<proto::RequestSecondOpinionResponse>, Status> {
        let req = request.into_inner();
        let collector = self.data_collector.clone();
        let sample = tokio::task::spawn_blocking(move || {
            if req.wanted {
                collector.request_second_opinion(&req.task, &req.sample_id, &req.tenant_id)
            } else {
                collector.clear_second_opinion(&req.task, &req.sample_id, &req.tenant_id)
            }
        })
        .await
        .map_err(|e| Status::internal(format!("join error: {e}")))?
        .map_err(Self::review_error)?;

        Ok(Response::new(proto::RequestSecondOpinionResponse {
            sample: Some(sample.to_proto()),
        }))
    }

    async fn get_review_agreement(
        &self,
        request: Request<proto::GetReviewAgreementRequest>,
    ) -> Result<Response<proto::GetReviewAgreementResponse>, Status> {
        let req = request.into_inner();
        let collector = self.data_collector.clone();
        let tenant = (!req.tenant_id.is_empty()).then_some(req.tenant_id.clone());
        let report = tokio::task::spawn_blocking(move || {
            collector.review_agreement(&req.task, tenant.as_deref())
        })
        .await
        .map_err(|e| Status::internal(format!("join error: {e}")))?
        .map_err(Self::review_error)?;

        Ok(Response::new(proto::GetReviewAgreementResponse {
            agreement: Some(proto::ReviewAgreement {
                compared: report.compared as i32,
                raw_agreement: report.raw_agreement,
                kappa: report.kappa,
                strength: report.strength,
                disagreements: report
                    .disagreements
                    .into_iter()
                    .map(|d| proto::LabelDisagreement {
                        first: d.first,
                        second: d.second,
                        count: d.count as i32,
                    })
                    .collect(),
            }),
        }))
    }
}
