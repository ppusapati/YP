//! AIGatewayService gRPC implementation.
//!
//! Dispatches incoming gRPC requests to the appropriate Rust AI engine module.
//! Each RPC is executed on `spawn_blocking` so that CPU-bound engine work does
//! not starve the tokio runtime.

use std::sync::Arc;

use tonic::{Request, Response, Status};
use uuid::Uuid;

use crate::config::Config;
use crate::diagnosis::DiagnosisEngine;
use crate::recommend::RecommendEngine;
use crate::satellite::SatelliteEngine;
use crate::yield_predict::YieldEngine;
use crate::proto;
use crate::proto::ai_gateway_service_server::AiGatewayService;

/// The AI Gateway gRPC service implementation.
///
/// Holds `Arc` references to each engine sub-module so that cloning into
/// `spawn_blocking` tasks is cheap.
pub struct AiGatewayServiceImpl {
    diagnosis: Arc<DiagnosisEngine>,
    yield_engine: Arc<YieldEngine>,
    satellite: Arc<SatelliteEngine>,
    recommend: Arc<RecommendEngine>,
}

impl AiGatewayServiceImpl {
    /// Create a new service from configuration. Initialises all engine modules.
    pub fn new(config: &Config) -> Self {
        let model_paths = config.models.clone();

        Self {
            diagnosis: Arc::new(DiagnosisEngine::new(model_paths.clone())),
            yield_engine: Arc::new(YieldEngine::new(model_paths.clone())),
            satellite: Arc::new(SatelliteEngine::new(model_paths.clone())),
            recommend: Arc::new(RecommendEngine::new(model_paths)),
        }
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
        tracing::info!(request_id = %req.request_id, images = req.images.len(), "DiagnoseImage");

        let engine = self.diagnosis.clone();
        let result = tokio::task::spawn_blocking(move || engine.diagnose_image(&req))
            .await
            .map_err(|e| Status::internal(format!("diagnosis task panicked: {e}")))?;

        Ok(Response::new(result))
    }

    async fn detect_pests(
        &self,
        request: Request<proto::DetectPestsRequest>,
    ) -> Result<Response<proto::DetectPestsResponse>, Status> {
        let mut req = request.into_inner();
        req.request_id = ensure_request_id(&req.request_id);
        tracing::info!(request_id = %req.request_id, images = req.images.len(), "DetectPests");

        let engine = self.diagnosis.clone();
        let result = tokio::task::spawn_blocking(move || engine.detect_pests(&req))
            .await
            .map_err(|e| Status::internal(format!("pest detection task panicked: {e}")))?;

        Ok(Response::new(result))
    }

    async fn detect_nutrient_deficiency(
        &self,
        request: Request<proto::DetectNutrientDeficiencyRequest>,
    ) -> Result<Response<proto::DetectNutrientDeficiencyResponse>, Status> {
        let mut req = request.into_inner();
        req.request_id = ensure_request_id(&req.request_id);
        tracing::info!(request_id = %req.request_id, images = req.images.len(), "DetectNutrientDeficiency");

        let engine = self.diagnosis.clone();
        let result = tokio::task::spawn_blocking(move || engine.detect_nutrient_deficiency(&req))
            .await
            .map_err(|e| Status::internal(format!("nutrient deficiency detection panicked: {e}")))?;

        Ok(Response::new(result))
    }

    async fn classify_plant(
        &self,
        request: Request<proto::ClassifyPlantRequest>,
    ) -> Result<Response<proto::ClassifyPlantResponse>, Status> {
        let mut req = request.into_inner();
        req.request_id = ensure_request_id(&req.request_id);
        tracing::info!(request_id = %req.request_id, images = req.images.len(), "ClassifyPlant");

        let engine = self.diagnosis.clone();
        let result = tokio::task::spawn_blocking(move || engine.classify_plant(&req))
            .await
            .map_err(|e| Status::internal(format!("plant classification panicked: {e}")))?;

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
}
