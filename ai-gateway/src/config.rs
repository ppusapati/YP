//! Configuration for the AI Gateway service.

use serde::Deserialize;
use std::path::Path;

/// Top-level configuration.
#[derive(Debug, Deserialize, Clone)]
pub struct Config {
    pub server: ServerConfig,
    pub models: ModelPaths,
}

/// gRPC server configuration.
#[derive(Debug, Deserialize, Clone)]
pub struct ServerConfig {
    /// Address to bind the gRPC server (e.g. "0.0.0.0:50051").
    pub address: String,
    /// Maximum concurrent requests.
    pub max_concurrent_requests: usize,
    /// Request timeout in seconds.
    pub request_timeout_secs: u64,
}

/// Paths and versions for AI/ML model artifacts.
#[derive(Debug, Deserialize, Clone)]
pub struct ModelPaths {
    /// Plant disease detection model directory.
    pub disease_detection_model: String,
    /// Pest detection model directory.
    pub pest_detection_model: String,
    /// Nutrient deficiency detection model directory.
    pub nutrient_deficiency_model: String,
    /// Plant classification / species identification model directory.
    pub plant_classification_model: String,
    /// Yield prediction model version tag.
    pub yield_prediction_version: String,
    /// Crop growth simulation model version tag.
    pub crop_growth_version: String,
    /// Satellite NDVI engine version tag.
    pub satellite_ndvi_version: String,
    /// Crop recommendation engine version tag.
    pub crop_recommendation_version: String,
}

impl Config {
    /// Load configuration from a TOML file.
    pub fn from_file(path: &Path) -> anyhow::Result<Self> {
        let content = std::fs::read_to_string(path)?;
        let config: Config = toml::from_str(&content)?;
        Ok(config)
    }
}

impl Default for Config {
    fn default() -> Self {
        Self {
            server: ServerConfig {
                address: "0.0.0.0:50051".to_string(),
                max_concurrent_requests: 256,
                request_timeout_secs: 30,
            },
            models: ModelPaths {
                disease_detection_model: "/models/disease-detection-v1".to_string(),
                pest_detection_model: "/models/pest-detection-v1".to_string(),
                nutrient_deficiency_model: "/models/nutrient-deficiency-v1".to_string(),
                plant_classification_model: "/models/plant-classification-v1".to_string(),
                yield_prediction_version: "v1.0.0".to_string(),
                crop_growth_version: "v1.0.0".to_string(),
                satellite_ndvi_version: "v1.0.0".to_string(),
                crop_recommendation_version: "v1.0.0".to_string(),
            },
        }
    }
}
