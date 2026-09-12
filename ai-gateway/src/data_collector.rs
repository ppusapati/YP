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
