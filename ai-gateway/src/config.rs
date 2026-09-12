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

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn config_deserializes_from_full_toml() {
        let toml_str = r#"
[server]
address = "127.0.0.1:9090"
max_concurrent_requests = 64
request_timeout_secs = 10

[models]
disease_detection_model = "/tmp/disease"
pest_detection_model = "/tmp/pest"
nutrient_deficiency_model = "/tmp/nutrient"
plant_classification_model = "/tmp/plant"
yield_prediction_version = "v2.0.0"
crop_growth_version = "v2.0.0"
satellite_ndvi_version = "v2.0.0"
crop_recommendation_version = "v2.0.0"

[external_api]
enabled = true
provider = "google_vision"
api_key = "test-key"
base_url = "https://vision.googleapis.com"
timeout_secs = 30
max_retries = 3

[data_collection]
enabled = true
storage_dir = "/tmp/collect"
max_images_per_category = 100
save_raw_response = false
"#;
        let config: Config = toml::from_str(toml_str).expect("should parse full TOML");
        assert_eq!(config.server.address, "127.0.0.1:9090");
        assert_eq!(config.server.max_concurrent_requests, 64);
        assert_eq!(config.server.request_timeout_secs, 10);
        assert_eq!(config.models.disease_detection_model, "/tmp/disease");
        assert_eq!(config.models.yield_prediction_version, "v2.0.0");
        assert!(config.external_api.enabled);
        assert_eq!(config.external_api.provider, VisionProvider::GoogleVision);
        assert_eq!(config.external_api.api_key, "test-key");
        assert_eq!(config.external_api.timeout_secs, 30);
        assert_eq!(config.external_api.max_retries, 3);
        assert!(config.data_collection.enabled);
        assert_eq!(config.data_collection.storage_dir, "/tmp/collect");
        assert_eq!(config.data_collection.max_images_per_category, 100);
        assert!(!config.data_collection.save_raw_response);
    }

    #[test]
    fn config_uses_defaults_when_external_api_absent() {
        let toml_str = r#"
[server]
address = "0.0.0.0:50051"
max_concurrent_requests = 256
request_timeout_secs = 30

[models]
disease_detection_model = "/models/disease"
pest_detection_model = "/models/pest"
nutrient_deficiency_model = "/models/nutrient"
plant_classification_model = "/models/plant"
yield_prediction_version = "v1.0.0"
crop_growth_version = "v1.0.0"
satellite_ndvi_version = "v1.0.0"
crop_recommendation_version = "v1.0.0"
"#;
        let config: Config = toml::from_str(toml_str).expect("should parse without optional sections");
        // external_api should use Default
        assert!(!config.external_api.enabled);
        assert_eq!(config.external_api.provider, VisionProvider::PlantNet);
        assert_eq!(config.external_api.api_key, "");
        assert_eq!(config.external_api.base_url, "https://my-api.plantnet.org/v2");
        assert_eq!(config.external_api.timeout_secs, 15);
        assert_eq!(config.external_api.max_retries, 2);
        // data_collection should use Default
        assert!(!config.data_collection.enabled);
        assert_eq!(config.data_collection.storage_dir, "/data/training-collection");
        assert_eq!(config.data_collection.max_images_per_category, 50_000);
        assert!(config.data_collection.save_raw_response);
    }

    #[test]
    fn config_default_trait_produces_expected_values() {
        let config = Config::default();
        assert_eq!(config.server.address, "0.0.0.0:50051");
        assert_eq!(config.server.max_concurrent_requests, 256);
        assert_eq!(config.server.request_timeout_secs, 30);
        assert_eq!(config.models.disease_detection_model, "/models/disease-detection-v1");
        assert!(!config.external_api.enabled);
        assert!(!config.data_collection.enabled);
    }

    #[test]
    fn external_api_default_values() {
        let api = ExternalApiConfig::default();
        assert!(!api.enabled);
        assert_eq!(api.provider, VisionProvider::PlantNet);
        assert!(api.api_key.is_empty());
        assert_eq!(api.timeout_secs, 15);
        assert_eq!(api.max_retries, 2);
    }

    #[test]
    fn data_collection_default_values() {
        let dc = DataCollectionConfig::default();
        assert!(!dc.enabled);
        assert_eq!(dc.storage_dir, "/data/training-collection");
        assert_eq!(dc.max_images_per_category, 50_000);
        assert!(dc.save_raw_response);
    }

    #[test]
    fn config_from_file_returns_error_for_missing_file() {
        let result = Config::from_file(Path::new("/nonexistent/config.toml"));
        assert!(result.is_err());
    }

    #[test]
    fn vision_provider_deserializes_all_variants() {
        #[derive(Deserialize)]
        struct Wrapper {
            provider: VisionProvider,
        }
        let cases = [
            (r#"provider = "google_vision""#, VisionProvider::GoogleVision),
            (r#"provider = "plant_net""#, VisionProvider::PlantNet),
            (r#"provider = "custom""#, VisionProvider::Custom),
        ];
        for (toml_str, expected) in &cases {
            let w: Wrapper = toml::from_str(toml_str).unwrap();
            assert_eq!(w.provider, *expected);
        }
    }
}
