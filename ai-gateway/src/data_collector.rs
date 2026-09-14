//! Training-data collection and human review.
//!
//! Every vision inference that produces a label (from an external API or the
//! local model) can be stored as a training sample: the image, its labels,
//! where the label came from (provenance), and the field/crop/geo context.
//! Sample ids are the SHA-256 of the image bytes, so the same photo is never
//! stored twice. Reviewers confirm, correct, or reject labels through the
//! review API; decisions are written back onto the sample and appended to an
//! audit log, and the training pipeline applies them when loading data.

use std::collections::{HashMap, HashSet};
use std::path::{Path, PathBuf};

use chrono::Utc;
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use tokio::sync::mpsc;

use crate::config::DataCollectionConfig;
use crate::proto;
use crate::vision_client::VisionResult;

pub const MANIFEST_FILE: &str = "manifest.jsonl";
pub const REVIEWS_FILE: &str = "reviews.jsonl";

/// Where a label came from.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum Provenance {
    ExternalApi,
    LocalModel,
    Human,
}

impl Provenance {
    pub fn as_str(self) -> &'static str {
        match self {
            Provenance::ExternalApi => "external_api",
            Provenance::LocalModel => "local_model",
            Provenance::Human => "human",
        }
    }

    pub fn parse(s: &str) -> Option<Self> {
        match s {
            "external_api" => Some(Provenance::ExternalApi),
            "local_model" => Some(Provenance::LocalModel),
            "human" => Some(Provenance::Human),
            _ => None,
        }
    }
}

/// Field / crop / geo context captured with a sample.
#[derive(Debug, Clone, Default, PartialEq, Serialize, Deserialize)]
pub struct SampleContext {
    #[serde(default)]
    pub tenant_id: String,
    #[serde(default)]
    pub farm_id: String,
    #[serde(default)]
    pub field_id: String,
    #[serde(default)]
    pub crop: String,
    #[serde(default)]
    pub latitude: f64,
    #[serde(default)]
    pub longitude: f64,
    #[serde(default)]
    pub submitted_by: String,
    #[serde(default)]
    pub request_id: String,
}

impl SampleContext {
    pub fn from_proto(ctx: &Option<proto::SampleContext>, request_id: &str) -> Self {
        let mut out = match ctx {
            Some(c) => Self {
                tenant_id: c.tenant_id.clone(),
                farm_id: c.farm_id.clone(),
                field_id: c.field_id.clone(),
                crop: c.crop.clone(),
                latitude: c.latitude,
                longitude: c.longitude,
                submitted_by: c.submitted_by.clone(),
                request_id: String::new(),
            },
            None => Self::default(),
        };
        out.request_id = request_id.to_string();
        out
    }

    pub fn to_proto(&self) -> proto::SampleContext {
        proto::SampleContext {
            tenant_id: self.tenant_id.clone(),
            farm_id: self.farm_id.clone(),
            field_id: self.field_id.clone(),
            crop: self.crop.clone(),
            latitude: self.latitude,
            longitude: self.longitude,
            submitted_by: self.submitted_by.clone(),
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Label {
    pub name: String,
    #[serde(default)]
    pub scientific_name: String,
    pub confidence: f64,
    #[serde(default)]
    pub category: String,
    #[serde(default)]
    pub severity: String,
}

/// A trained model's confident disagreement with a stored label.
///
/// Written back by the training pipeline after a run: when a model puts almost
/// all its probability on a class the label does not name, the label is the
/// more likely thing to be wrong. Those samples are worth a reviewer's time
/// long before the merely low-confidence ones, because a wrong label does not
/// just waste a training example — it teaches the next model the same mistake.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct LabelSuspicion {
    /// What the model predicted instead.
    pub predicted: String,
    /// Probability it gave that prediction.
    pub predicted_prob: f64,
    /// Probability it gave the stored label.
    pub label_prob: f64,
    /// Which model disagreed, so a stale flag can be recognised.
    #[serde(default)]
    pub model_version: String,
    #[serde(default)]
    pub flagged_at: String,
}

/// A reviewer's decision about a sample's labels.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct LabelReview {
    pub decision: ReviewDecision,
    #[serde(default)]
    pub corrected_label: String,
    #[serde(default)]
    pub reviewer_id: String,
    #[serde(default)]
    pub tenant_id: String,
    #[serde(default)]
    pub notes: String,
    pub reviewed_at: String,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum ReviewDecision {
    Confirmed,
    Corrected,
    Rejected,
}

impl ReviewDecision {
    pub fn as_str(self) -> &'static str {
        match self {
            ReviewDecision::Confirmed => "confirmed",
            ReviewDecision::Corrected => "corrected",
            ReviewDecision::Rejected => "rejected",
        }
    }

    pub fn parse(s: &str) -> Option<Self> {
        match s.trim().to_ascii_lowercase().as_str() {
            "confirmed" | "confirm" | "accept" | "accepted" => Some(ReviewDecision::Confirmed),
            "corrected" | "correct" => Some(ReviewDecision::Corrected),
            "rejected" | "reject" => Some(ReviewDecision::Rejected),
            _ => None,
        }
    }
}

/// The per-sample record stored at `{task}/labels/{id}.json`.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TrainingSample {
    pub id: String,
    pub timestamp: String,
    pub task: String,
    pub provider: String,
    pub image_path: String,
    pub labels: Vec<Label>,
    pub raw_api_response: Option<String>,
    #[serde(default = "default_provenance")]
    pub provenance: Provenance,
    #[serde(default)]
    pub content_hash: String,
    #[serde(default)]
    pub model_version: String,
    #[serde(default)]
    pub context: SampleContext,
    #[serde(default)]
    pub review: Option<LabelReview>,
    /// Set when a trained model confidently contradicted this sample's label.
    #[serde(default)]
    pub suspect: Option<LabelSuspicion>,
}

fn default_provenance() -> Provenance {
    Provenance::ExternalApi
}

impl TrainingSample {
    /// Highest-confidence label name, before review.
    pub fn top_label(&self) -> Option<&Label> {
        self.labels.iter().max_by(|a, b| {
            a.confidence
                .partial_cmp(&b.confidence)
                .unwrap_or(std::cmp::Ordering::Equal)
        })
    }

    pub fn top_confidence(&self) -> f64 {
        self.top_label().map(|l| l.confidence).unwrap_or(0.0)
    }

    /// Label after applying any review: corrected label wins, rejected
    /// samples have none, otherwise the top auto-label.
    pub fn effective_label(&self) -> Option<String> {
        match &self.review {
            Some(r) if r.decision == ReviewDecision::Rejected => None,
            Some(r) if r.decision == ReviewDecision::Corrected && !r.corrected_label.is_empty() => {
                Some(r.corrected_label.clone())
            }
            _ => self.top_label().map(|l| l.name.clone()),
        }
    }

    pub fn to_proto(&self) -> proto::TrainingSampleInfo {
        proto::TrainingSampleInfo {
            id: self.id.clone(),
            task: self.task.clone(),
            timestamp: self.timestamp.clone(),
            provenance: self.provenance.as_str().to_string(),
            provider: if self.model_version.is_empty() {
                self.provider.clone()
            } else {
                self.model_version.clone()
            },
            labels: self
                .labels
                .iter()
                .map(|l| proto::TrainingLabel {
                    name: l.name.clone(),
                    confidence: l.confidence,
                    category: l.category.clone(),
                    severity: l.severity.clone(),
                })
                .collect(),
            top_confidence: self.top_confidence(),
            context: Some(self.context.to_proto()),
            review: self.review.as_ref().map(|r| proto::LabelReview {
                decision: r.decision.as_str().to_string(),
                corrected_label: r.corrected_label.clone(),
                reviewer_id: r.reviewer_id.clone(),
                tenant_id: r.tenant_id.clone(),
                notes: r.notes.clone(),
                reviewed_at: r.reviewed_at.clone(),
            }),
            effective_label: self.effective_label().unwrap_or_default(),
            suspect: self.suspect.as_ref().map(|x| proto::LabelSuspicion {
                predicted: x.predicted.clone(),
                predicted_prob: x.predicted_prob,
                label_prob: x.label_prob,
                model_version: x.model_version.clone(),
                flagged_at: x.flagged_at.clone(),
            }),
        }
    }
}

/// One line of `{task}/manifest.jsonl`: enough to filter without opening
/// every label file.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ManifestEntry {
    pub id: String,
    pub image: String,
    pub labels: Vec<String>,
    pub timestamp: String,
    #[serde(default = "default_provenance")]
    pub provenance: Provenance,
    #[serde(default)]
    pub confidence: f64,
    #[serde(default)]
    pub tenant_id: String,
    #[serde(default)]
    pub field_id: String,
    #[serde(default)]
    pub crop: String,
    #[serde(default)]
    pub content_hash: String,
}

/// Filters for the review queue.
#[derive(Debug, Clone, Default)]
pub struct SampleQuery {
    pub task: String,
    pub review_status: ReviewStatus,
    pub tenant_id: Option<String>,
    pub min_confidence: Option<f64>,
    pub max_confidence: Option<f64>,
    pub provenance: Option<Provenance>,
    /// Only samples a trained model contradicted.
    pub suspect_only: bool,
    pub order: SampleOrder,
    pub offset: usize,
    pub limit: usize,
}

#[derive(Debug, Clone, Copy, Default, PartialEq, Eq)]
pub enum ReviewStatus {
    #[default]
    Unreviewed,
    Reviewed,
    All,
}

#[derive(Debug, Clone, Copy, Default, PartialEq, Eq)]
pub enum SampleOrder {
    /// Lowest-confidence first: the active-learning order.
    #[default]
    ConfidenceAsc,
    Newest,
    /// Samples a trained model contradicted, worst disagreement first, then
    /// everything else in the usual order.
    SuspectFirst,
}

pub struct SamplePage {
    pub samples: Vec<TrainingSample>,
    pub total: usize,
    pub unreviewed: usize,
}

#[derive(Debug, thiserror::Error)]
pub enum ReviewError {
    #[error("unknown task {0:?}")]
    UnknownTask(String),
    #[error("sample {0} not found")]
    NotFound(String),
    #[error("invalid review: {0}")]
    Invalid(String),
    #[error("sample {0} belongs to another tenant")]
    Forbidden(String),
    #[error("io: {0}")]
    Io(#[from] std::io::Error),
    #[error("json: {0}")]
    Json(#[from] serde_json::Error),
}

const TASKS: [&str; 4] = [
    "disease",
    "pest",
    "nutrient_deficiency",
    "plant_classification",
];

fn validate_task(task: &str) -> Result<(), ReviewError> {
    if TASKS.contains(&task) {
        Ok(())
    } else {
        Err(ReviewError::UnknownTask(task.to_string()))
    }
}

fn validate_id(id: &str) -> Result<(), ReviewError> {
    if id.is_empty() || !id.chars().all(|c| c.is_ascii_hexdigit() || c == '_') {
        return Err(ReviewError::Invalid(format!("malformed sample id {id:?}")));
    }
    Ok(())
}

/// Compute the sample id for an image.
pub fn content_hash(image_bytes: &[u8]) -> String {
    let mut h = Sha256::new();
    h.update(image_bytes);
    format!("{:x}", h.finalize())
}

pub struct CollectionInput {
    pub task: String,
    pub image_bytes: Vec<u8>,
    pub labels: Vec<Label>,
    pub provenance: Provenance,
    /// API provider name or local model version.
    pub source: String,
    pub raw_response: Option<String>,
    pub context: SampleContext,
}

impl CollectionInput {
    pub fn from_vision_result(
        image_bytes: Vec<u8>,
        vr: VisionResult,
        context: SampleContext,
    ) -> Self {
        Self {
            task: vr.task.clone(),
            image_bytes,
            labels: vr
                .detections
                .iter()
                .map(|d| Label {
                    name: d.label.clone(),
                    scientific_name: d.scientific_name.clone(),
                    confidence: d.confidence,
                    category: d.category.clone(),
                    severity: d.severity.clone(),
                })
                .collect(),
            provenance: Provenance::ExternalApi,
            source: vr.provider.clone(),
            raw_response: vr.raw_response,
            context,
        }
    }
}

pub struct DataCollector {
    config: DataCollectionConfig,
    sender: mpsc::Sender<CollectionInput>,
}

impl DataCollector {
    pub fn new(config: &DataCollectionConfig) -> Self {
        let (sender, receiver) = mpsc::channel::<CollectionInput>(1024);
        let cfg = config.clone();
        tokio::spawn(async move {
            Self::collection_worker(cfg, receiver).await;
        });
        Self {
            config: config.clone(),
            sender,
        }
    }

    pub fn is_enabled(&self) -> bool {
        self.config.enabled
    }

    pub fn storage_dir(&self) -> &str {
        &self.config.storage_dir
    }

    /// Queue a sample for storage. Fire-and-forget; drops on backpressure.
    pub async fn collect(&self, input: CollectionInput) {
        if !self.config.enabled || input.image_bytes.is_empty() || input.labels.is_empty() {
            return;
        }
        if self.sender.try_send(input).is_err() {
            tracing::warn!("data collection queue full; sample dropped");
        }
    }

    async fn collection_worker(
        config: DataCollectionConfig,
        mut receiver: mpsc::Receiver<CollectionInput>,
    ) {
        let mut store = SampleStore::new(&config);
        while let Some(job) = receiver.recv().await {
            let outcome = tokio::task::block_in_place(|| store.save(job));
            match outcome {
                Ok(SaveOutcome::Stored(id)) => tracing::debug!(id, "training sample collected"),
                Ok(SaveOutcome::Duplicate(id)) => {
                    tracing::debug!(id, "training sample already stored")
                }
                Ok(SaveOutcome::CategoryFull(label)) => {
                    tracing::debug!(label, "category at max_images_per_category; sample skipped")
                }
                Err(e) => tracing::warn!("data collection failed: {e}"),
            }
        }
    }

    // ── Review API (synchronous filesystem access; call from spawn_blocking) ──

    pub fn list_samples(&self, query: &SampleQuery) -> Result<SamplePage, ReviewError> {
        SampleStore::new(&self.config).list(query)
    }

    pub fn submit_review(
        &self,
        task: &str,
        sample_id: &str,
        review: LabelReview,
    ) -> Result<TrainingSample, ReviewError> {
        SampleStore::new(&self.config).review(task, sample_id, review)
    }

    /// Read a sample's image; `tenant_id` (when non-empty) must match the
    /// tenant the sample was collected under.
    pub fn sample_image(
        &self,
        task: &str,
        sample_id: &str,
        tenant_id: &str,
    ) -> Result<Vec<u8>, ReviewError> {
        SampleStore::new(&self.config).image(task, sample_id, tenant_id)
    }
}

pub enum SaveOutcome {
    Stored(String),
    Duplicate(String),
    CategoryFull(String),
}

/// Filesystem layout under `storage_dir`:
/// `{task}/images/{id}.jpg`, `{task}/labels/{id}.json`, `{task}/manifest.jsonl`,
/// `{task}/reviews.jsonl`.
pub struct SampleStore {
    root: PathBuf,
    max_per_category: usize,
    save_raw: bool,
    /// (task, label) → stored count, filled lazily from the manifest.
    counts: HashMap<(String, String), usize>,
    counted_tasks: HashSet<String>,
}

impl SampleStore {
    pub fn new(config: &DataCollectionConfig) -> Self {
        Self {
            root: PathBuf::from(&config.storage_dir),
            max_per_category: config.max_images_per_category,
            save_raw: config.save_raw_response,
            counts: HashMap::new(),
            counted_tasks: HashSet::new(),
        }
    }

    fn task_dir(&self, task: &str) -> PathBuf {
        self.root.join(task)
    }

    fn label_path(&self, task: &str, id: &str) -> PathBuf {
        self.task_dir(task)
            .join("labels")
            .join(format!("{id}.json"))
    }

    fn ensure_counts(&mut self, task: &str) -> Result<(), ReviewError> {
        if self.counted_tasks.contains(task) {
            return Ok(());
        }
        for entry in self.read_manifest(task)? {
            for label in entry.labels {
                *self.counts.entry((task.to_string(), label)).or_default() += 1;
            }
        }
        self.counted_tasks.insert(task.to_string());
        Ok(())
    }

    pub fn save(&mut self, job: CollectionInput) -> Result<SaveOutcome, ReviewError> {
        validate_task(&job.task)?;
        let id = content_hash(&job.image_bytes);
        let label_path = self.label_path(&job.task, &id);
        if label_path.exists() {
            return Ok(SaveOutcome::Duplicate(id));
        }

        self.ensure_counts(&job.task)?;
        let top = job
            .labels
            .iter()
            .max_by(|a, b| {
                a.confidence
                    .partial_cmp(&b.confidence)
                    .unwrap_or(std::cmp::Ordering::Equal)
            })
            .map(|l| l.name.clone())
            .unwrap_or_default();
        if self.max_per_category > 0 {
            let n = self
                .counts
                .get(&(job.task.clone(), top.clone()))
                .copied()
                .unwrap_or(0);
            if n >= self.max_per_category {
                return Ok(SaveOutcome::CategoryFull(top));
            }
        }

        let task_dir = self.task_dir(&job.task);
        let images_dir = task_dir.join("images");
        std::fs::create_dir_all(&images_dir)?;
        std::fs::create_dir_all(task_dir.join("labels"))?;
        let image_path = images_dir.join(format!("{id}.jpg"));
        std::fs::write(&image_path, &job.image_bytes)?;

        let sample = TrainingSample {
            id: id.clone(),
            timestamp: Utc::now().to_rfc3339(),
            task: job.task.clone(),
            provider: job.source.clone(),
            image_path: image_path.to_string_lossy().to_string(),
            labels: job.labels,
            raw_api_response: if self.save_raw {
                job.raw_response
            } else {
                None
            },
            provenance: job.provenance,
            content_hash: id.clone(),
            model_version: if job.provenance == Provenance::LocalModel {
                job.source
            } else {
                String::new()
            },
            context: job.context,
            review: None,
            suspect: None,
        };
        write_json_atomic(&label_path, &sample)?;
        append_line(&task_dir.join(MANIFEST_FILE), &manifest_entry(&sample))?;
        *self.counts.entry((job.task, top)).or_default() += 1;
        Ok(SaveOutcome::Stored(id))
    }

    pub fn read_manifest(&self, task: &str) -> Result<Vec<ManifestEntry>, ReviewError> {
        let path = self.task_dir(task).join(MANIFEST_FILE);
        if !path.exists() {
            return Ok(Vec::new());
        }
        let content = std::fs::read_to_string(path)?;
        let mut out = Vec::new();
        for line in content.lines().filter(|l| !l.trim().is_empty()) {
            match serde_json::from_str::<ManifestEntry>(line) {
                Ok(e) => out.push(e),
                Err(e) => tracing::warn!(task, error = %e, "skipping malformed manifest line"),
            }
        }
        Ok(out)
    }

    pub fn load(&self, task: &str, id: &str) -> Result<TrainingSample, ReviewError> {
        validate_task(task)?;
        validate_id(id)?;
        let path = self.label_path(task, id);
        if !path.exists() {
            return Err(ReviewError::NotFound(id.to_string()));
        }
        Ok(serde_json::from_str(&std::fs::read_to_string(path)?)?)
    }

    pub fn list(&self, q: &SampleQuery) -> Result<SamplePage, ReviewError> {
        validate_task(&q.task)?;
        let mut samples: Vec<TrainingSample> = Vec::new();
        let mut unreviewed = 0usize;
        for entry in self.read_manifest(&q.task)? {
            let Ok(sample) = self.load(&q.task, &entry.id) else {
                continue;
            };
            if sample.review.is_none() {
                unreviewed += 1;
            }
            let reviewed = sample.review.is_some();
            let keep = match q.review_status {
                ReviewStatus::Unreviewed => !reviewed,
                ReviewStatus::Reviewed => reviewed,
                ReviewStatus::All => true,
            } && q
                .tenant_id
                .as_ref()
                .map_or(true, |t| t.is_empty() || sample.context.tenant_id == *t)
                && q.min_confidence
                    .map_or(true, |m| sample.top_confidence() >= m)
                && q.max_confidence
                    .map_or(true, |m| m <= 0.0 || sample.top_confidence() <= m)
                && q.provenance.map_or(true, |p| sample.provenance == p)
                && (!q.suspect_only || sample.suspect.is_some());
            if keep {
                samples.push(sample);
            }
        }
        match q.order {
            SampleOrder::ConfidenceAsc => samples.sort_by(|a, b| {
                a.top_confidence()
                    .partial_cmp(&b.top_confidence())
                    .unwrap_or(std::cmp::Ordering::Equal)
                    .then_with(|| a.timestamp.cmp(&b.timestamp))
            }),
            SampleOrder::Newest => samples.sort_by(|a, b| b.timestamp.cmp(&a.timestamp)),
            SampleOrder::SuspectFirst => samples.sort_by(|a, b| {
                // Rank by how sure the model was that the label is wrong, so
                // the clearest mistakes reach a reviewer first.
                let strength = |s: &TrainingSample| {
                    s.suspect
                        .as_ref()
                        .map(|x| x.predicted_prob - x.label_prob)
                        .unwrap_or(f64::MIN)
                };
                strength(b)
                    .partial_cmp(&strength(a))
                    .unwrap_or(std::cmp::Ordering::Equal)
                    .then_with(|| {
                        a.top_confidence()
                            .partial_cmp(&b.top_confidence())
                            .unwrap_or(std::cmp::Ordering::Equal)
                    })
            }),
        }
        let total = samples.len();
        let limit = if q.limit == 0 { 50 } else { q.limit.min(500) };
        let page = samples.into_iter().skip(q.offset).take(limit).collect();
        Ok(SamplePage {
            samples: page,
            total,
            unreviewed,
        })
    }

    pub fn review(
        &self,
        task: &str,
        id: &str,
        mut review: LabelReview,
    ) -> Result<TrainingSample, ReviewError> {
        let mut sample = self.load(task, id)?;
        Self::check_tenant(&sample, &review.tenant_id)?;
        if review.decision == ReviewDecision::Corrected {
            review.corrected_label = review.corrected_label.trim().to_string();
            if review.corrected_label.is_empty() {
                return Err(ReviewError::Invalid(
                    "corrected decision requires corrected_label".into(),
                ));
            }
        }
        if review.reviewer_id.trim().is_empty() {
            return Err(ReviewError::Invalid("reviewer_id is required".into()));
        }
        if review.reviewed_at.is_empty() {
            review.reviewed_at = Utc::now().to_rfc3339();
        }
        sample.review = Some(review.clone());
        write_json_atomic(&self.label_path(task, id), &sample)?;
        append_line(
            &self.task_dir(task).join(REVIEWS_FILE),
            &serde_json::json!({
                "sample_id": id,
                "task": task,
                "decision": review.decision.as_str(),
                "corrected_label": review.corrected_label,
                "reviewer_id": review.reviewer_id,
                "tenant_id": review.tenant_id,
                "notes": review.notes,
                "reviewed_at": review.reviewed_at,
                "auto_label": sample.top_label().map(|l| l.name.clone()).unwrap_or_default(),
            }),
        )?;
        Ok(sample)
    }

    /// A tenant-scoped caller (non-empty `tenant_id`) may only touch samples
    /// collected under that tenant; an empty tenant is a platform operator.
    fn check_tenant(sample: &TrainingSample, tenant_id: &str) -> Result<(), ReviewError> {
        if !tenant_id.is_empty() && sample.context.tenant_id != tenant_id {
            return Err(ReviewError::Forbidden(sample.id.clone()));
        }
        Ok(())
    }

    pub fn image(&self, task: &str, id: &str, tenant_id: &str) -> Result<Vec<u8>, ReviewError> {
        let sample = self.load(task, id)?;
        Self::check_tenant(&sample, tenant_id)?;
        let path = Path::new(&sample.image_path);
        if !path.exists() {
            return Err(ReviewError::NotFound(id.to_string()));
        }
        Ok(std::fs::read(path)?)
    }
}

fn manifest_entry(sample: &TrainingSample) -> serde_json::Value {
    serde_json::json!(ManifestEntry {
        id: sample.id.clone(),
        image: sample.image_path.clone(),
        labels: sample.labels.iter().map(|l| l.name.clone()).collect(),
        timestamp: sample.timestamp.clone(),
        provenance: sample.provenance,
        confidence: sample.top_confidence(),
        tenant_id: sample.context.tenant_id.clone(),
        field_id: sample.context.field_id.clone(),
        crop: sample.context.crop.clone(),
        content_hash: sample.content_hash.clone(),
    })
}

fn write_json_atomic<T: Serialize>(path: &Path, value: &T) -> Result<(), ReviewError> {
    let tmp = path.with_extension("json.tmp");
    std::fs::write(&tmp, serde_json::to_string_pretty(value)?)?;
    std::fs::rename(&tmp, path)?;
    Ok(())
}

fn append_line(path: &Path, value: &serde_json::Value) -> Result<(), ReviewError> {
    use std::io::Write;
    let mut line = serde_json::to_string(value)?;
    line.push('\n');
    std::fs::OpenOptions::new()
        .create(true)
        .append(true)
        .open(path)?
        .write_all(line.as_bytes())?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::vision_client::{Detection, VisionResult};

    fn config(dir: &Path) -> DataCollectionConfig {
        DataCollectionConfig {
            enabled: true,
            storage_dir: dir.to_string_lossy().to_string(),
            max_images_per_category: 100,
            save_raw_response: true,
        }
    }

    fn vision(task: &str, label: &str, conf: f64) -> VisionResult {
        VisionResult {
            provider: "plantnet".into(),
            task: task.into(),
            detections: vec![Detection {
                label: label.into(),
                scientific_name: String::new(),
                confidence: conf,
                category: "fungal".into(),
                description: String::new(),
                severity: "moderate".into(),
                recommendations: vec![],
            }],
            raw_response: Some("{}".into()),
        }
    }

    fn ctx(tenant: &str) -> SampleContext {
        SampleContext {
            tenant_id: tenant.into(),
            field_id: "f1".into(),
            crop: "wheat".into(),
            latitude: 18.5,
            longitude: 73.8,
            ..Default::default()
        }
    }

    #[test]
    fn save_dedupes_by_content_and_records_context() {
        let dir = tempfile::tempdir().unwrap();
        let mut store = SampleStore::new(&config(dir.path()));
        let img = vec![1u8, 2, 3, 4];

        let first = store
            .save(CollectionInput::from_vision_result(
                img.clone(),
                vision("disease", "rust", 0.9),
                ctx("t1"),
            ))
            .unwrap();
        let id = match first {
            SaveOutcome::Stored(id) => id,
            _ => panic!("expected stored"),
        };
        assert_eq!(id, content_hash(&img));
        assert!(matches!(
            store
                .save(CollectionInput::from_vision_result(
                    img.clone(),
                    vision("disease", "rust", 0.9),
                    ctx("t1")
                ))
                .unwrap(),
            SaveOutcome::Duplicate(_)
        ));

        let sample = store.load("disease", &id).unwrap();
        assert_eq!(sample.provenance, Provenance::ExternalApi);
        assert_eq!(sample.context.tenant_id, "t1");
        assert_eq!(sample.context.crop, "wheat");
        assert_eq!(sample.effective_label().as_deref(), Some("rust"));
        assert_eq!(store.read_manifest("disease").unwrap().len(), 1);
        assert_eq!(store.read_manifest("disease").unwrap()[0].confidence, 0.9);
    }

    #[test]
    fn category_cap_is_enforced() {
        let dir = tempfile::tempdir().unwrap();
        let mut cfg = config(dir.path());
        cfg.max_images_per_category = 2;
        let mut store = SampleStore::new(&cfg);
        for i in 0..3u8 {
            let out = store
                .save(CollectionInput::from_vision_result(
                    vec![i, i, i],
                    vision("pest", "aphid", 0.8),
                    ctx("t"),
                ))
                .unwrap();
            if i < 2 {
                assert!(matches!(out, SaveOutcome::Stored(_)));
            } else {
                assert!(matches!(out, SaveOutcome::CategoryFull(ref l) if l == "aphid"));
            }
        }
        assert_eq!(store.read_manifest("pest").unwrap().len(), 2);
    }

    #[test]
    fn review_queue_orders_by_confidence_and_applies_decisions() {
        let dir = tempfile::tempdir().unwrap();
        let cfg = config(dir.path());
        let mut store = SampleStore::new(&cfg);
        let ids: Vec<String> = [(0.95, "rust"), (0.40, "blight"), (0.70, "rust")]
            .iter()
            .enumerate()
            .map(|(i, (c, l))| {
                match store
                    .save(CollectionInput::from_vision_result(
                        vec![i as u8; 8],
                        vision("disease", l, *c),
                        ctx("t1"),
                    ))
                    .unwrap()
                {
                    SaveOutcome::Stored(id) => id,
                    _ => panic!(),
                }
            })
            .collect();

        let page = store
            .list(&SampleQuery {
                task: "disease".into(),
                ..Default::default()
            })
            .unwrap();
        assert_eq!(page.total, 3);
        assert_eq!(page.unreviewed, 3);
        assert_eq!(
            page.samples[0].top_confidence(),
            0.40,
            "lowest confidence first"
        );

        let corrected = store
            .review(
                "disease",
                &ids[1],
                LabelReview {
                    decision: ReviewDecision::Corrected,
                    corrected_label: "leaf_spot".into(),
                    reviewer_id: "agro-1".into(),
                    tenant_id: "t1".into(),
                    notes: String::new(),
                    reviewed_at: String::new(),
                },
            )
            .unwrap();
        assert_eq!(corrected.effective_label().as_deref(), Some("leaf_spot"));
        assert!(!corrected.review.unwrap().reviewed_at.is_empty());

        store
            .review(
                "disease",
                &ids[0],
                LabelReview {
                    decision: ReviewDecision::Rejected,
                    corrected_label: String::new(),
                    reviewer_id: "agro-1".into(),
                    tenant_id: "t1".into(),
                    notes: "blurry".into(),
                    reviewed_at: String::new(),
                },
            )
            .unwrap();
        assert_eq!(
            store.load("disease", &ids[0]).unwrap().effective_label(),
            None
        );

        let pending = store
            .list(&SampleQuery {
                task: "disease".into(),
                ..Default::default()
            })
            .unwrap();
        assert_eq!(pending.total, 1);
        assert_eq!(pending.samples[0].id, ids[2]);
        let reviewed = store
            .list(&SampleQuery {
                task: "disease".into(),
                review_status: ReviewStatus::Reviewed,
                ..Default::default()
            })
            .unwrap();
        assert_eq!(reviewed.total, 2);

        let audit = std::fs::read_to_string(dir.path().join("disease").join(REVIEWS_FILE)).unwrap();
        assert_eq!(audit.lines().count(), 2);
        assert!(audit.contains("leaf_spot"));
    }

    #[test]
    fn review_validation() {
        let dir = tempfile::tempdir().unwrap();
        let mut store = SampleStore::new(&config(dir.path()));
        let id = match store
            .save(CollectionInput::from_vision_result(
                vec![9; 4],
                vision("disease", "rust", 0.5),
                ctx("t"),
            ))
            .unwrap()
        {
            SaveOutcome::Stored(id) => id,
            _ => panic!(),
        };
        let bad = LabelReview {
            decision: ReviewDecision::Corrected,
            corrected_label: "  ".into(),
            reviewer_id: "r".into(),
            tenant_id: String::new(),
            notes: String::new(),
            reviewed_at: String::new(),
        };
        assert!(matches!(
            store.review("disease", &id, bad),
            Err(ReviewError::Invalid(_))
        ));
        assert!(matches!(
            store.review(
                "disease",
                "deadbeef",
                LabelReview {
                    decision: ReviewDecision::Confirmed,
                    corrected_label: String::new(),
                    reviewer_id: "r".into(),
                    tenant_id: String::new(),
                    notes: String::new(),
                    reviewed_at: String::new(),
                }
            ),
            Err(ReviewError::NotFound(_))
        ));
        assert!(matches!(
            store.load("disease", "../etc/passwd"),
            Err(ReviewError::Invalid(_))
        ));
        assert!(matches!(
            store.load("nope", &id),
            Err(ReviewError::UnknownTask(_))
        ));
        assert_eq!(store.image("disease", &id, "").unwrap(), vec![9; 4]);
        assert_eq!(store.image("disease", &id, "t").unwrap(), vec![9; 4]);
        assert!(matches!(
            store.image("disease", &id, "other-tenant"),
            Err(ReviewError::Forbidden(_))
        ));
        assert!(matches!(
            store.review(
                "disease",
                &id,
                LabelReview {
                    decision: ReviewDecision::Confirmed,
                    corrected_label: String::new(),
                    reviewer_id: "r".into(),
                    tenant_id: "other-tenant".into(),
                    notes: String::new(),
                    reviewed_at: String::new(),
                }
            ),
            Err(ReviewError::Forbidden(_))
        ));
        assert!(store.load("disease", &id).unwrap().review.is_none());
    }

    #[test]
    fn tenant_and_provenance_filters() {
        let dir = tempfile::tempdir().unwrap();
        let mut store = SampleStore::new(&config(dir.path()));
        store
            .save(CollectionInput::from_vision_result(
                vec![1; 4],
                vision("disease", "rust", 0.9),
                ctx("t1"),
            ))
            .unwrap();
        store
            .save(CollectionInput {
                task: "disease".into(),
                image_bytes: vec![2; 4],
                labels: vec![Label {
                    name: "blight".into(),
                    scientific_name: String::new(),
                    confidence: 0.6,
                    category: String::new(),
                    severity: String::new(),
                }],
                provenance: Provenance::LocalModel,
                source: "disease-v3".into(),
                raw_response: None,
                context: ctx("t2"),
            })
            .unwrap();
        let t2 = store
            .list(&SampleQuery {
                task: "disease".into(),
                tenant_id: Some("t2".into()),
                ..Default::default()
            })
            .unwrap();
        assert_eq!(t2.total, 1);
        assert_eq!(t2.samples[0].model_version, "disease-v3");
        let local = store
            .list(&SampleQuery {
                task: "disease".into(),
                provenance: Some(Provenance::LocalModel),
                ..Default::default()
            })
            .unwrap();
        assert_eq!(local.total, 1);
        let conf = store
            .list(&SampleQuery {
                task: "disease".into(),
                max_confidence: Some(0.7),
                ..Default::default()
            })
            .unwrap();
        assert_eq!(conf.total, 1);
    }

    #[tokio::test]
    async fn collect_is_noop_when_disabled() {
        let dir = tempfile::tempdir().unwrap();
        let mut cfg = config(dir.path());
        cfg.enabled = false;
        let collector = DataCollector::new(&cfg);
        assert!(!collector.is_enabled());
        collector
            .collect(CollectionInput::from_vision_result(
                vec![1, 2, 3],
                vision("disease", "rust", 0.9),
                ctx("t"),
            ))
            .await;
        assert!(!dir.path().join("disease").exists());
    }

    #[test]
    fn legacy_label_files_still_load() {
        // Files written before provenance/context existed must deserialize.
        let json = r#"{"id":"20260101_000000_000001","timestamp":"2026-01-01T00:00:00Z","task":"disease",
            "provider":"plantnet","image_path":"/x.jpg","labels":[{"name":"Rust","scientific_name":"","confidence":0.8,"category":"","severity":""}],
            "raw_api_response":null}"#;
        let s: TrainingSample = serde_json::from_str(json).unwrap();
        assert_eq!(s.provenance, Provenance::ExternalApi);
        assert!(s.review.is_none());
        assert_eq!(s.effective_label().as_deref(), Some("Rust"));
    }
}
