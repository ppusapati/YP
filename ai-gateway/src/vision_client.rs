//! External vision API client for production fallback when local ONNX models
//! are unavailable.
//!
//! Supports PlantNet (free plant identification API) and Google Cloud Vision.
//! Each call returns structured results that map directly to the gateway's proto
//! response types, so the service layer can seamlessly substitute external API
//! results for local inference results.

use std::time::Duration;

use base64::Engine as _;
use reqwest::Client;
use serde::{Deserialize, Serialize};

use crate::config::{ExternalApiConfig, VisionProvider};

#[derive(Debug, thiserror::Error)]
pub enum VisionError {
    #[error("external API disabled")]
    Disabled,
    #[error("HTTP request failed: {0}")]
    Http(#[from] reqwest::Error),
    #[error("API returned error: {status} {body}")]
    ApiError { status: u16, body: String },
    #[error("failed to parse response: {0}")]
    Parse(String),
}

/// Unified result from any vision API call.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct VisionResult {
    pub provider: String,
    pub task: String,
    pub detections: Vec<Detection>,
    pub raw_response: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Detection {
    pub label: String,
    pub scientific_name: String,
    pub confidence: f64,
    pub category: String,
    pub description: String,
    pub severity: String,
    pub recommendations: Vec<String>,
}

#[derive(Debug)]
pub struct VisionClient {
    config: ExternalApiConfig,
    http: Client,
}

impl VisionClient {
    pub fn new(config: &ExternalApiConfig) -> Result<Self, VisionError> {
        if !config.enabled {
            return Err(VisionError::Disabled);
        }
        let http = Client::builder()
            .timeout(Duration::from_secs(config.timeout_secs))
            .build()?;
        Ok(Self {
            config: config.clone(),
            http,
        })
    }

    pub fn is_enabled(&self) -> bool {
        self.config.enabled
    }

    pub async fn diagnose_disease(
        &self,
        image_bytes: &[u8],
        _plant_species_hint: &str,
    ) -> Result<VisionResult, VisionError> {
        match self.config.provider {
            VisionProvider::PlantNet => self.plantnet_identify(image_bytes, "disease").await,
            VisionProvider::GoogleVision => self.google_vision_detect(image_bytes, "disease").await,
            VisionProvider::Custom => self.custom_api_call(image_bytes, "disease").await,
        }
    }

    pub async fn detect_pests(
        &self,
        image_bytes: &[u8],
        _plant_species_hint: &str,
    ) -> Result<VisionResult, VisionError> {
        match self.config.provider {
            VisionProvider::PlantNet => self.plantnet_identify(image_bytes, "pest").await,
            VisionProvider::GoogleVision => self.google_vision_detect(image_bytes, "pest").await,
            VisionProvider::Custom => self.custom_api_call(image_bytes, "pest").await,
        }
    }

    pub async fn detect_nutrient_deficiency(
        &self,
        image_bytes: &[u8],
        _plant_species_hint: &str,
    ) -> Result<VisionResult, VisionError> {
        match self.config.provider {
            VisionProvider::GoogleVision => {
                self.google_vision_detect(image_bytes, "nutrient_deficiency").await
            }
            _ => self.custom_api_call(image_bytes, "nutrient_deficiency").await,
        }
    }

    pub async fn classify_plant(
        &self,
        image_bytes: &[u8],
    ) -> Result<VisionResult, VisionError> {
        match self.config.provider {
            VisionProvider::PlantNet => {
                self.plantnet_identify(image_bytes, "classification").await
            }
            VisionProvider::GoogleVision => {
                self.google_vision_detect(image_bytes, "classification").await
            }
            VisionProvider::Custom => self.custom_api_call(image_bytes, "classification").await,
        }
    }

    async fn plantnet_identify(
        &self,
        image_bytes: &[u8],
        task: &str,
    ) -> Result<VisionResult, VisionError> {
        let url = format!(
            "{}/identify/all?include-related-images=false&no-reject=false&lang=en&api-key={}",
            self.config.base_url, self.config.api_key,
        );

        let image_vec = image_bytes.to_vec();
        let mut last_err = None;
        for attempt in 0..=self.config.max_retries {
            if attempt > 0 {
                tokio::time::sleep(Duration::from_millis(500 * 2u64.pow(attempt - 1))).await;
            }

            let part = reqwest::multipart::Part::bytes(image_vec.clone())
                .file_name("image.jpg")
                .mime_str("image/jpeg")
                .map_err(|e| VisionError::Parse(e.to_string()))?;
            let form = reqwest::multipart::Form::new()
                .part("images", part)
                .text("organs", "leaf");

            match self.http.post(&url).multipart(form).send().await {
                Ok(resp) => {
                    let status = resp.status().as_u16();
                    let body = resp.text().await.unwrap_or_default();
                    if status != 200 {
                        last_err = Some(VisionError::ApiError { status, body });
                        continue;
                    }
                    return self.parse_plantnet_response(&body, task);
                }
                Err(e) => {
                    last_err = Some(VisionError::Http(e));
                }
            }
        }
        Err(last_err.unwrap_or(VisionError::Parse("no attempts made".into())))
    }

    fn parse_plantnet_response(
        &self,
        body: &str,
        task: &str,
    ) -> Result<VisionResult, VisionError> {
        let v: serde_json::Value =
            serde_json::from_str(body).map_err(|e| VisionError::Parse(e.to_string()))?;

        let results = v["results"]
            .as_array()
            .ok_or_else(|| VisionError::Parse("missing results array".into()))?;

        let detections = results
            .iter()
            .take(10)
            .filter_map(|r| {
                let score = r["score"].as_f64()?;
                let species = &r["species"];
                let common = species["commonNames"]
                    .as_array()
                    .and_then(|a| a.first())
                    .and_then(|v| v.as_str())
                    .unwrap_or("Unknown");
                let scientific = species["scientificNameWithoutAuthor"]
                    .as_str()
                    .unwrap_or("");
                let family = species["family"]["scientificNameWithoutAuthor"]
                    .as_str()
                    .unwrap_or("");

                Some(Detection {
                    label: common.to_string(),
                    scientific_name: scientific.to_string(),
                    confidence: score,
                    category: family.to_string(),
                    description: format!("Identified by PlantNet with {:.1}% confidence", score * 100.0),
                    severity: String::new(),
                    recommendations: vec![],
                })
            })
            .collect();

        Ok(VisionResult {
            provider: "plantnet".to_string(),
            task: task.to_string(),
            detections,
            raw_response: Some(body.to_string()),
        })
    }

    async fn google_vision_detect(
        &self,
        image_bytes: &[u8],
        task: &str,
    ) -> Result<VisionResult, VisionError> {
        let b64 = base64::engine::general_purpose::STANDARD.encode(image_bytes);

        let feature_type = match task {
            "classification" => "LABEL_DETECTION",
            _ => "LABEL_DETECTION",
        };

        let request_body = serde_json::json!({
            "requests": [{
                "image": { "content": b64 },
                "features": [{ "type": feature_type, "maxResults": 15 }]
            }]
        });

        let url = format!(
            "{}/v1/images:annotate?key={}",
            self.config.base_url, self.config.api_key,
        );

        let resp = self.http.post(&url).json(&request_body).send().await?;
        let status = resp.status().as_u16();
        let body = resp.text().await.unwrap_or_default();

        if status != 200 {
            return Err(VisionError::ApiError { status, body });
        }

        self.parse_google_vision_response(&body, task)
    }

    fn parse_google_vision_response(
        &self,
        body: &str,
        task: &str,
    ) -> Result<VisionResult, VisionError> {
        let v: serde_json::Value =
            serde_json::from_str(body).map_err(|e| VisionError::Parse(e.to_string()))?;

        let annotations = v["responses"][0]["labelAnnotations"]
            .as_array()
            .ok_or_else(|| VisionError::Parse("missing labelAnnotations".into()))?;

        let detections = annotations
            .iter()
            .filter_map(|a| {
                let score = a["score"].as_f64()?;
                let desc = a["description"].as_str().unwrap_or("");
                Some(Detection {
                    label: desc.to_string(),
                    scientific_name: String::new(),
                    confidence: score,
                    category: String::new(),
                    description: format!("Google Vision: {} ({:.1}%)", desc, score * 100.0),
                    severity: String::new(),
                    recommendations: vec![],
                })
            })
            .collect();

        Ok(VisionResult {
            provider: "google_vision".to_string(),
            task: task.to_string(),
            detections,
            raw_response: Some(body.to_string()),
        })
    }

    async fn custom_api_call(
        &self,
        image_bytes: &[u8],
        task: &str,
    ) -> Result<VisionResult, VisionError> {
        let b64 = base64::engine::general_purpose::STANDARD.encode(image_bytes);

        let request_body = serde_json::json!({
            "image": b64,
            "task": task,
            "format": "base64",
        });

        let url = format!("{}/analyze", self.config.base_url);
        let resp = self
            .http
            .post(&url)
            .header("Authorization", format!("Bearer {}", self.config.api_key))
            .json(&request_body)
            .send()
            .await?;

        let status = resp.status().as_u16();
        let body = resp.text().await.unwrap_or_default();

        if status != 200 {
            return Err(VisionError::ApiError { status, body });
        }

        let v: serde_json::Value =
            serde_json::from_str(&body).map_err(|e| VisionError::Parse(e.to_string()))?;

        let results = v["results"]
            .as_array()
            .ok_or_else(|| VisionError::Parse("missing results".into()))?;

        let detections = results
            .iter()
            .filter_map(|r| {
                Some(Detection {
                    label: r["label"].as_str()?.to_string(),
                    scientific_name: r["scientific_name"].as_str().unwrap_or("").to_string(),
                    confidence: r["confidence"].as_f64()?,
                    category: r["category"].as_str().unwrap_or("").to_string(),
                    description: r["description"].as_str().unwrap_or("").to_string(),
                    severity: r["severity"].as_str().unwrap_or("").to_string(),
                    recommendations: r["recommendations"]
                        .as_array()
                        .map(|a| {
                            a.iter()
                                .filter_map(|v| v.as_str().map(String::from))
                                .collect()
                        })
                        .unwrap_or_default(),
                })
            })
            .collect();

        Ok(VisionResult {
            provider: "custom".to_string(),
            task: task.to_string(),
            detections,
            raw_response: Some(body),
        })
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::config::{ExternalApiConfig, VisionProvider};

    fn enabled_config() -> ExternalApiConfig {
        ExternalApiConfig {
            enabled: true,
            provider: VisionProvider::PlantNet,
            api_key: "test-key".to_string(),
            base_url: "https://example.com".to_string(),
            timeout_secs: 10,
            max_retries: 1,
        }
    }

    fn disabled_config() -> ExternalApiConfig {
        ExternalApiConfig {
            enabled: false,
            ..enabled_config()
        }
    }

    #[test]
    fn vision_client_construction_succeeds_with_enabled_config() {
        let cfg = enabled_config();
        let client = VisionClient::new(&cfg);
        assert!(client.is_ok());
        assert!(client.unwrap().is_enabled());
    }

    #[test]
    fn vision_client_returns_disabled_error_when_not_enabled() {
        let cfg = disabled_config();
        let result = VisionClient::new(&cfg);
        assert!(result.is_err());
        let err = result.unwrap_err();
        assert!(matches!(err, VisionError::Disabled));
        assert_eq!(err.to_string(), "external API disabled");
    }

    #[test]
    fn vision_result_can_be_constructed_and_cloned() {
        let result = VisionResult {
            provider: "plantnet".to_string(),
            task: "disease".to_string(),
            detections: vec![Detection {
                label: "Tomato Blight".to_string(),
                scientific_name: "Phytophthora infestans".to_string(),
                confidence: 0.95,
                category: "oomycete".to_string(),
                description: "Late blight detected".to_string(),
                severity: "high".to_string(),
                recommendations: vec![
                    "Remove infected leaves".to_string(),
                    "Apply copper fungicide".to_string(),
                ],
            }],
            raw_response: Some("{}".to_string()),
        };
        let cloned = result.clone();
        assert_eq!(cloned.provider, "plantnet");
        assert_eq!(cloned.task, "disease");
        assert_eq!(cloned.detections.len(), 1);
        assert_eq!(cloned.detections[0].label, "Tomato Blight");
        assert_eq!(cloned.detections[0].confidence, 0.95);
        assert_eq!(cloned.detections[0].recommendations.len(), 2);
    }

    #[test]
    fn detection_struct_fields() {
        let det = Detection {
            label: "Aphid".to_string(),
            scientific_name: "Myzus persicae".to_string(),
            confidence: 0.88,
            category: "insect".to_string(),
            description: "Green peach aphid".to_string(),
            severity: "moderate".to_string(),
            recommendations: vec![],
        };
        assert_eq!(det.label, "Aphid");
        assert_eq!(det.scientific_name, "Myzus persicae");
        assert_eq!(det.confidence, 0.88);
        assert!(det.recommendations.is_empty());
    }

    #[test]
    fn vision_result_serializes_to_json() {
        let result = VisionResult {
            provider: "google_vision".to_string(),
            task: "classification".to_string(),
            detections: vec![],
            raw_response: None,
        };
        let json = serde_json::to_string(&result).expect("should serialize");
        assert!(json.contains("google_vision"));
        assert!(json.contains("classification"));

        let deserialized: VisionResult = serde_json::from_str(&json).unwrap();
        assert_eq!(deserialized.provider, "google_vision");
        assert!(deserialized.detections.is_empty());
        assert!(deserialized.raw_response.is_none());
    }

    #[test]
    fn vision_error_display() {
        let disabled = VisionError::Disabled;
        assert_eq!(disabled.to_string(), "external API disabled");

        let api_err = VisionError::ApiError {
            status: 429,
            body: "rate limited".to_string(),
        };
        assert!(api_err.to_string().contains("429"));
        assert!(api_err.to_string().contains("rate limited"));

        let parse_err = VisionError::Parse("bad json".to_string());
        assert!(parse_err.to_string().contains("bad json"));
    }

    #[test]
    fn parse_plantnet_response_extracts_detections() {
        let cfg = enabled_config();
        let client = VisionClient::new(&cfg).unwrap();

        let body = serde_json::json!({
            "results": [
                {
                    "score": 0.85,
                    "species": {
                        "commonNames": ["Tomato"],
                        "scientificNameWithoutAuthor": "Solanum lycopersicum",
                        "family": {
                            "scientificNameWithoutAuthor": "Solanaceae"
                        }
                    }
                },
                {
                    "score": 0.12,
                    "species": {
                        "commonNames": ["Potato"],
                        "scientificNameWithoutAuthor": "Solanum tuberosum",
                        "family": {
                            "scientificNameWithoutAuthor": "Solanaceae"
                        }
                    }
                }
            ]
        });

        let result = client
            .parse_plantnet_response(&body.to_string(), "classification")
            .expect("should parse");
        assert_eq!(result.provider, "plantnet");
        assert_eq!(result.task, "classification");
        assert_eq!(result.detections.len(), 2);
        assert_eq!(result.detections[0].label, "Tomato");
        assert_eq!(result.detections[0].scientific_name, "Solanum lycopersicum");
        assert_eq!(result.detections[0].confidence, 0.85);
        assert_eq!(result.detections[0].category, "Solanaceae");
        assert!(result.raw_response.is_some());
    }

    #[test]
    fn parse_plantnet_response_handles_missing_results() {
        let cfg = enabled_config();
        let client = VisionClient::new(&cfg).unwrap();
        let body = r#"{"status": "ok"}"#;
        let result = client.parse_plantnet_response(body, "disease");
        assert!(result.is_err());
    }

    #[test]
    fn parse_google_vision_response_extracts_labels() {
        let cfg = ExternalApiConfig {
            provider: VisionProvider::GoogleVision,
            ..enabled_config()
        };
        let client = VisionClient::new(&cfg).unwrap();

        let body = serde_json::json!({
            "responses": [{
                "labelAnnotations": [
                    {"description": "Plant", "score": 0.97},
                    {"description": "Leaf", "score": 0.91}
                ]
            }]
        });

        let result = client
            .parse_google_vision_response(&body.to_string(), "classification")
            .expect("should parse");
        assert_eq!(result.provider, "google_vision");
        assert_eq!(result.detections.len(), 2);
        assert_eq!(result.detections[0].label, "Plant");
        assert_eq!(result.detections[0].confidence, 0.97);
        assert_eq!(result.detections[1].label, "Leaf");
    }

    #[test]
    fn parse_google_vision_response_errors_on_missing_annotations() {
        let cfg = ExternalApiConfig {
            provider: VisionProvider::GoogleVision,
            ..enabled_config()
        };
        let client = VisionClient::new(&cfg).unwrap();
        let body = r#"{"responses": [{}]}"#;
        let result = client.parse_google_vision_response(body, "classification");
        assert!(result.is_err());
    }
}
