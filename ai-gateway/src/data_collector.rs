//! Data collection pipeline that stores images and their API-derived labels
//! for later model training. Each inference request that goes through the
//! external API gets its image + labels saved to disk in a format the Python
//! training pipeline can consume.

use std::path::{Path, PathBuf};
use std::sync::atomic::{AtomicU64, Ordering};

use chrono::Utc;
use serde::{Deserialize, Serialize};
use tokio::fs;
use tokio::io::AsyncWriteExt;
use tokio::sync::mpsc;

use crate::config::DataCollectionConfig;
use crate::vision_client::VisionResult;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TrainingSample {
    pub id: String,
    pub timestamp: String,
    pub task: String,
    pub provider: String,
    pub image_path: String,
    pub labels: Vec<Label>,
    pub raw_api_response: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Label {
    pub name: String,
    pub scientific_name: String,
    pub confidence: f64,
    pub category: String,
    pub severity: String,
}

pub struct DataCollector {
    config: DataCollectionConfig,
    sender: mpsc::Sender<CollectionJob>,
    counter: AtomicU64,
}

struct CollectionJob {
    image_bytes: Vec<u8>,
    vision_result: VisionResult,
    sample_id: String,
}

impl DataCollector {
    pub fn new(config: &DataCollectionConfig) -> Self {
        let (sender, receiver) = mpsc::channel::<CollectionJob>(1024);
        let cfg = config.clone();
        tokio::spawn(async move {
            Self::collection_worker(cfg, receiver).await;
        });
        Self {
            config: config.clone(),
            sender,
            counter: AtomicU64::new(0),
        }
    }

    pub fn is_enabled(&self) -> bool {
        self.config.enabled
    }

    pub async fn collect(
        &self,
        image_bytes: Vec<u8>,
        vision_result: VisionResult,
    ) {
        if !self.config.enabled {
            return;
        }
        let seq = self.counter.fetch_add(1, Ordering::Relaxed);
        let sample_id = format!(
            "{}_{:06}",
            Utc::now().format("%Y%m%d_%H%M%S"),
            seq,
        );
        let _ = self
            .sender
            .try_send(CollectionJob {
                image_bytes,
                vision_result,
                sample_id,
            });
    }

    async fn collection_worker(
        config: DataCollectionConfig,
        mut receiver: mpsc::Receiver<CollectionJob>,
    ) {
        while let Some(job) = receiver.recv().await {
            if let Err(e) = Self::save_sample(&config, job).await {
                tracing::warn!("data collection failed: {e}");
            }
        }
    }

    async fn save_sample(
        config: &DataCollectionConfig,
        job: CollectionJob,
    ) -> anyhow::Result<()> {
        let task_dir = PathBuf::from(&config.storage_dir).join(&job.vision_result.task);
        let images_dir = task_dir.join("images");
        let labels_dir = task_dir.join("labels");

        fs::create_dir_all(&images_dir).await?;
        fs::create_dir_all(&labels_dir).await?;

        let image_filename = format!("{}.jpg", job.sample_id);
        let image_path = images_dir.join(&image_filename);
        fs::write(&image_path, &job.image_bytes).await?;

        let labels: Vec<Label> = job
            .vision_result
            .detections
            .iter()
            .map(|d| Label {
                name: d.label.clone(),
                scientific_name: d.scientific_name.clone(),
                confidence: d.confidence,
                category: d.category.clone(),
                severity: d.severity.clone(),
            })
            .collect();

        let sample = TrainingSample {
            id: job.sample_id.clone(),
            timestamp: Utc::now().to_rfc3339(),
            task: job.vision_result.task.clone(),
            provider: job.vision_result.provider.clone(),
            image_path: image_path.to_string_lossy().to_string(),
            labels,
            raw_api_response: if config.save_raw_response {
                job.vision_result.raw_response
            } else {
                None
            },
        };

        let label_path = labels_dir.join(format!("{}.json", job.sample_id));
        let json = serde_json::to_string_pretty(&sample)?;
        fs::write(&label_path, json).await?;

        Self::write_manifest_entry(&task_dir, &sample).await?;

        tracing::debug!(
            task = %sample.task,
            id = %sample.id,
            labels = sample.labels.len(),
            "training sample collected"
        );

        Ok(())
    }

    async fn write_manifest_entry(
        task_dir: &Path,
        sample: &TrainingSample,
    ) -> anyhow::Result<()> {
        let manifest_path = task_dir.join("manifest.jsonl");
        let entry = serde_json::json!({
            "id": sample.id,
            "image": sample.image_path,
            "labels": sample.labels.iter().map(|l| &l.name).collect::<Vec<_>>(),
            "timestamp": sample.timestamp,
        });
        let mut line = serde_json::to_string(&entry)?;
        line.push('\n');
        fs::OpenOptions::new()
            .create(true)
            .append(true)
            .open(&manifest_path)
            .await?
            .write_all(line.as_bytes())
            .await?;
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::config::DataCollectionConfig;
    use crate::vision_client::{Detection, VisionResult};

    fn disabled_config() -> DataCollectionConfig {
        DataCollectionConfig {
            enabled: false,
            storage_dir: "/tmp/test-collection".to_string(),
            max_images_per_category: 100,
            save_raw_response: false,
        }
    }

    fn enabled_config() -> DataCollectionConfig {
        DataCollectionConfig {
            enabled: true,
            storage_dir: "/tmp/test-collection".to_string(),
            max_images_per_category: 100,
            save_raw_response: true,
        }
    }

    fn sample_vision_result() -> VisionResult {
        VisionResult {
            provider: "test".to_string(),
            task: "disease".to_string(),
            detections: vec![Detection {
                label: "Leaf Blight".to_string(),
                scientific_name: "Alternaria alternata".to_string(),
                confidence: 0.92,
                category: "fungal".to_string(),
                description: "Fungal leaf disease".to_string(),
                severity: "moderate".to_string(),
                recommendations: vec!["Apply fungicide".to_string()],
            }],
            raw_response: Some(r#"{"test": true}"#.to_string()),
        }
    }

    #[tokio::test]
    async fn data_collector_creates_with_disabled_config() {
        let cfg = disabled_config();
        let collector = DataCollector::new(&cfg);
        assert!(!collector.is_enabled());
    }

    #[tokio::test]
    async fn data_collector_creates_with_enabled_config() {
        let cfg = enabled_config();
        let collector = DataCollector::new(&cfg);
        assert!(collector.is_enabled());
    }

    #[tokio::test]
    async fn collect_is_noop_when_disabled() {
        let cfg = disabled_config();
        let collector = DataCollector::new(&cfg);
        // Should return immediately without error when disabled.
        collector
            .collect(vec![0xFF, 0xD8, 0xFF], sample_vision_result())
            .await;
    }

    #[test]
    fn training_sample_serializes_to_json() {
        let sample = TrainingSample {
            id: "20260101_000000_000000".to_string(),
            timestamp: "2026-01-01T00:00:00Z".to_string(),
            task: "disease".to_string(),
            provider: "plantnet".to_string(),
            image_path: "/data/images/test.jpg".to_string(),
            labels: vec![Label {
                name: "Rust".to_string(),
                scientific_name: "Puccinia graminis".to_string(),
                confidence: 0.85,
                category: "fungal".to_string(),
                severity: "high".to_string(),
            }],
            raw_api_response: None,
        };
        let json = serde_json::to_string(&sample).expect("should serialize");
        assert!(json.contains("Puccinia graminis"));
        assert!(json.contains("\"confidence\":0.85"));
    }

    #[test]
    fn training_sample_roundtrips_through_json() {
        let sample = TrainingSample {
            id: "test_001".to_string(),
            timestamp: "2026-06-15T12:00:00Z".to_string(),
            task: "pest".to_string(),
            provider: "custom".to_string(),
            image_path: "/images/pest.jpg".to_string(),
            labels: vec![
                Label {
                    name: "Aphid".to_string(),
                    scientific_name: "Aphis gossypii".to_string(),
                    confidence: 0.78,
                    category: "insect".to_string(),
                    severity: "low".to_string(),
                },
                Label {
                    name: "Whitefly".to_string(),
                    scientific_name: "Bemisia tabaci".to_string(),
                    confidence: 0.45,
                    category: "insect".to_string(),
                    severity: "low".to_string(),
                },
            ],
            raw_api_response: Some("raw data".to_string()),
        };
        let json = serde_json::to_string(&sample).unwrap();
        let deserialized: TrainingSample = serde_json::from_str(&json).unwrap();
        assert_eq!(deserialized.id, "test_001");
        assert_eq!(deserialized.labels.len(), 2);
        assert_eq!(deserialized.labels[0].name, "Aphid");
        assert_eq!(deserialized.raw_api_response, Some("raw data".to_string()));
    }

    #[test]
    fn label_fields_are_accessible() {
        let label = Label {
            name: "Test Disease".to_string(),
            scientific_name: "Testus diseaseus".to_string(),
            confidence: 0.99,
            category: "bacterial".to_string(),
            severity: "critical".to_string(),
        };
        assert_eq!(label.name, "Test Disease");
        assert_eq!(label.confidence, 0.99);
        assert_eq!(label.severity, "critical");
    }
}
