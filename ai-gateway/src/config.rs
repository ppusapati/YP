//! Configuration for the AI Gateway service.

use serde::Deserialize;
use std::path::Path;

/// Top-level configuration.
#[derive(Debug, Deserialize, Clone)]
pub struct Config {
    pub server: ServerConfig,
    pub models: ModelPaths,
    #[serde(default)]
    pub external_api: ExternalApiConfig,
    #[serde(default)]
    pub data_collection: DataCollectionConfig,
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

/// External vision API configuration for production inference fallback.
/// When local ONNX models are unavailable, the gateway calls an external
/// vision API (e.g. Google Cloud Vision, PlantNet, or a custom endpoint).
#[derive(Debug, Deserialize, Clone)]
pub struct ExternalApiConfig {
    pub enabled: bool,
    pub provider: VisionProvider,
    pub api_key: String,
    pub base_url: String,
    pub timeout_secs: u64,
    pub max_retries: u32,
}

#[derive(Debug, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "snake_case")]
pub enum VisionProvider {
    GoogleVision,
    PlantNet,
    Custom,
}

impl Default for ExternalApiConfig {
    fn default() -> Self {
        Self {
            enabled: false,
            provider: VisionProvider::PlantNet,
            api_key: String::new(),
            base_url: "https://my-api.plantnet.org/v2".to_string(),
            timeout_secs: 15,
            max_retries: 2,
        }
    }
}

/// Configuration for the data collection pipeline that stores images and
/// labels from external API responses for later model training.
#[derive(Debug, Deserialize, Clone)]
pub struct DataCollectionConfig {
    pub enabled: bool,
    pub storage_dir: String,
    pub max_images_per_category: usize,
    pub save_raw_response: bool,
}

impl Default for DataCollectionConfig {
    fn default() -> Self {
        Self {
            enabled: false,
            storage_dir: "/data/training-collection".to_string(),
            max_images_per_category: 50_000,
            save_raw_response: true,
        }
    }
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
            external_api: ExternalApiConfig::default(),
            data_collection: DataCollectionConfig::default(),
        }
    }
}
