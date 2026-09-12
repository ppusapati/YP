//! Model Registry — track model versions with metadata as JSON files.
//!
//! Each registered model is stored as a JSON file inside a registry directory.
//! The registry supports versioned models organized by task, promotion from
//! staging to production, archival, and best-model selection by metric.

use std::collections::HashMap;
use std::path::{Path, PathBuf};

use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};

/// Status of a model in its lifecycle.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum ModelStatus {
    Staging,
    Production,
    Archived,
}

/// Metrics collected during model evaluation.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ModelMetrics {
    pub accuracy: f64,
    pub f1: f64,
    pub precision: f64,
    pub recall: f64,
}

/// Full metadata for a registered model.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ModelMetadata {
    pub model_name: String,
    pub version: String,
    pub task: String,
    pub created_at: DateTime<Utc>,
    pub metrics: ModelMetrics,
    pub training_config_hash: String,
    pub onnx_path: String,
    pub status: ModelStatus,
}

/// A file-backed model registry.
pub struct ModelRegistry {
    registry_dir: PathBuf,
}

impl ModelRegistry {
    /// Create a new registry backed by the given directory.
    /// The directory is created if it does not exist.
    pub fn new(registry_dir: &Path) -> anyhow::Result<Self> {
        std::fs::create_dir_all(registry_dir)?;
        Ok(Self {
            registry_dir: registry_dir.to_path_buf(),
        })
    }

    /// Filename for a model entry: `{task}__{version}.json`
    fn entry_filename(task: &str, version: &str) -> String {
        format!("{}__{}.json", task, version)
    }

    /// Register a new model. Fails if an entry with the same task+version
    /// already exists.
    pub fn register_model(&self, metadata: ModelMetadata) -> anyhow::Result<()> {
        let filename = Self::entry_filename(&metadata.task, &metadata.version);
        let path = self.registry_dir.join(&filename);
        if path.exists() {
            anyhow::bail!(
                "model already registered: task={}, version={}",
                metadata.task,
                metadata.version
            );
        }
        let json = serde_json::to_string_pretty(&metadata)?;
        std::fs::write(&path, json)?;
        Ok(())
    }

    /// List all registered models, optionally filtered by task.
    pub fn list_models(&self, task_filter: Option<&str>) -> anyhow::Result<Vec<ModelMetadata>> {
        let mut models = Vec::new();
        for entry in std::fs::read_dir(&self.registry_dir)? {
            let entry = entry?;
            let path = entry.path();
            if path.extension().and_then(|e| e.to_str()) != Some("json") {
                continue;
            }
            let content = std::fs::read_to_string(&path)?;
            let meta: ModelMetadata = serde_json::from_str(&content)?;
            if let Some(task) = task_filter {
                if meta.task != task {
                    continue;
                }
            }
            models.push(meta);
        }
        // Sort by created_at descending (newest first).
        models.sort_by(|a, b| b.created_at.cmp(&a.created_at));
        Ok(models)
    }

    /// Get a specific model by task and version.
    pub fn get_model(&self, task: &str, version: &str) -> anyhow::Result<ModelMetadata> {
        let filename = Self::entry_filename(task, version);
        let path = self.registry_dir.join(&filename);
        if !path.exists() {
            anyhow::bail!("model not found: task={task}, version={version}");
        }
        let content = std::fs::read_to_string(&path)?;
        let meta: ModelMetadata = serde_json::from_str(&content)?;
        Ok(meta)
    }

    /// Promote a model from staging to production.
    ///
    /// Any existing production model for the same task is demoted to archived.
    pub fn promote_model(&self, task: &str, version: &str) -> anyhow::Result<()> {
        // First, archive any current production model for this task.
        let all = self.list_models(Some(task))?;
        for m in &all {
            if m.status == ModelStatus::Production {
                self.set_status(&m.task, &m.version, ModelStatus::Archived)?;
            }
        }
        // Then promote the target.
        self.set_status(task, version, ModelStatus::Production)?;
        Ok(())
    }

    /// Archive a model.
    pub fn archive_model(&self, task: &str, version: &str) -> anyhow::Result<()> {
        self.set_status(task, version, ModelStatus::Archived)
    }

    /// Select the best model for a task according to a given metric.
    ///
    /// Only staging and production models are considered.
    pub fn best_model(&self, task: &str, metric: &str) -> anyhow::Result<ModelMetadata> {
        let models = self.list_models(Some(task))?;
        let active: Vec<&ModelMetadata> = models
            .iter()
            .filter(|m| m.status != ModelStatus::Archived)
            .collect();

        if active.is_empty() {
            anyhow::bail!("no active models for task '{task}'");
        }

        let best = active
            .into_iter()
            .max_by(|a, b| {
                let va = metric_value(&a.metrics, metric);
                let vb = metric_value(&b.metrics, metric);
                va.partial_cmp(&vb).unwrap_or(std::cmp::Ordering::Equal)
            })
            .unwrap();

        Ok(best.clone())
    }

    /// Compare two model versions for the same task, returning a map of
    /// metric deltas (new - old).
    pub fn compare_versions(
        &self,
        task: &str,
        version_a: &str,
        version_b: &str,
    ) -> anyhow::Result<HashMap<String, f64>> {
        let a = self.get_model(task, version_a)?;
        let b = self.get_model(task, version_b)?;
        let mut deltas = HashMap::new();
        deltas.insert("accuracy".to_string(), b.metrics.accuracy - a.metrics.accuracy);
        deltas.insert("f1".to_string(), b.metrics.f1 - a.metrics.f1);
        deltas.insert("precision".to_string(), b.metrics.precision - a.metrics.precision);
        deltas.insert("recall".to_string(), b.metrics.recall - a.metrics.recall);
        Ok(deltas)
    }

    // ── internal helpers ────────────────────────────────────────────

    fn set_status(&self, task: &str, version: &str, status: ModelStatus) -> anyhow::Result<()> {
        let filename = Self::entry_filename(task, version);
        let path = self.registry_dir.join(&filename);
        if !path.exists() {
            anyhow::bail!("model not found: task={task}, version={version}");
        }
        let content = std::fs::read_to_string(&path)?;
        let mut meta: ModelMetadata = serde_json::from_str(&content)?;
        meta.status = status;
        let json = serde_json::to_string_pretty(&meta)?;
        std::fs::write(&path, json)?;
        Ok(())
    }
}

/// Extract a named metric value.
fn metric_value(metrics: &ModelMetrics, name: &str) -> f64 {
    match name {
        "accuracy" => metrics.accuracy,
        "f1" => metrics.f1,
        "precision" => metrics.precision,
        "recall" => metrics.recall,
        _ => 0.0,
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;

    fn temp_registry() -> (tempfile::TempDir, ModelRegistry) {
        let dir = tempfile::tempdir().unwrap();
        let registry = ModelRegistry::new(dir.path()).unwrap();
        (dir, registry)
    }

    fn sample_metadata(task: &str, version: &str, accuracy: f64) -> ModelMetadata {
        ModelMetadata {
            model_name: format!("{task}-model"),
            version: version.to_string(),
            task: task.to_string(),
            created_at: Utc::now(),
            metrics: ModelMetrics {
                accuracy,
                f1: accuracy * 0.95,
                precision: accuracy * 0.97,
                recall: accuracy * 0.93,
            },
            training_config_hash: "abc123".to_string(),
            onnx_path: format!("/models/{task}/{version}/model.onnx"),
            status: ModelStatus::Staging,
        }
    }

    #[test]
    fn register_and_get_model() {
        let (_dir, registry) = temp_registry();
        let meta = sample_metadata("disease_detection", "v1.0.0", 0.92);
        registry.register_model(meta.clone()).unwrap();

        let retrieved = registry.get_model("disease_detection", "v1.0.0").unwrap();
        assert_eq!(retrieved.model_name, "disease_detection-model");
        assert_eq!(retrieved.version, "v1.0.0");
        assert_eq!(retrieved.task, "disease_detection");
        assert_eq!(retrieved.status, ModelStatus::Staging);
        assert!((retrieved.metrics.accuracy - 0.92).abs() < f64::EPSILON);
    }

    #[test]
    fn register_duplicate_fails() {
        let (_dir, registry) = temp_registry();
        let meta = sample_metadata("pest_detection", "v1.0.0", 0.88);
        registry.register_model(meta.clone()).unwrap();

        let result = registry.register_model(meta);
        assert!(result.is_err());
        assert!(
            result.unwrap_err().to_string().contains("already registered"),
            "error should mention 'already registered'"
        );
    }

    #[test]
    fn list_models_returns_all() {
        let (_dir, registry) = temp_registry();
        registry
            .register_model(sample_metadata("disease_detection", "v1.0.0", 0.90))
            .unwrap();
        registry
            .register_model(sample_metadata("disease_detection", "v2.0.0", 0.93))
            .unwrap();
        registry
            .register_model(sample_metadata("pest_detection", "v1.0.0", 0.85))
            .unwrap();

        let all = registry.list_models(None).unwrap();
        assert_eq!(all.len(), 3);
    }

    #[test]
    fn list_models_filters_by_task() {
        let (_dir, registry) = temp_registry();
        registry
            .register_model(sample_metadata("disease_detection", "v1.0.0", 0.90))
            .unwrap();
        registry
            .register_model(sample_metadata("pest_detection", "v1.0.0", 0.85))
            .unwrap();

        let disease_only = registry.list_models(Some("disease_detection")).unwrap();
        assert_eq!(disease_only.len(), 1);
        assert_eq!(disease_only[0].task, "disease_detection");
    }

    #[test]
    fn get_nonexistent_model_errors() {
        let (_dir, registry) = temp_registry();
        let result = registry.get_model("nothing", "v0.0.0");
        assert!(result.is_err());
    }

    #[test]
    fn promote_model_sets_production_and_archives_previous() {
        let (_dir, registry) = temp_registry();
        registry
            .register_model(sample_metadata("disease_detection", "v1.0.0", 0.90))
            .unwrap();
        registry
            .register_model(sample_metadata("disease_detection", "v2.0.0", 0.93))
            .unwrap();

        // Promote v1 to production.
        registry.promote_model("disease_detection", "v1.0.0").unwrap();
        let v1 = registry.get_model("disease_detection", "v1.0.0").unwrap();
        assert_eq!(v1.status, ModelStatus::Production);

        // Now promote v2 — v1 should be archived.
        registry.promote_model("disease_detection", "v2.0.0").unwrap();
        let v1 = registry.get_model("disease_detection", "v1.0.0").unwrap();
        let v2 = registry.get_model("disease_detection", "v2.0.0").unwrap();
        assert_eq!(v1.status, ModelStatus::Archived);
        assert_eq!(v2.status, ModelStatus::Production);
    }

    #[test]
    fn archive_model_sets_archived() {
        let (_dir, registry) = temp_registry();
        registry
            .register_model(sample_metadata("pest_detection", "v1.0.0", 0.88))
            .unwrap();
        registry.archive_model("pest_detection", "v1.0.0").unwrap();

        let m = registry.get_model("pest_detection", "v1.0.0").unwrap();
        assert_eq!(m.status, ModelStatus::Archived);
    }

    #[test]
    fn best_model_selects_highest_accuracy() {
        let (_dir, registry) = temp_registry();
        registry
            .register_model(sample_metadata("disease_detection", "v1.0.0", 0.85))
            .unwrap();
        registry
            .register_model(sample_metadata("disease_detection", "v2.0.0", 0.92))
            .unwrap();
        registry
            .register_model(sample_metadata("disease_detection", "v3.0.0", 0.88))
            .unwrap();

        let best = registry.best_model("disease_detection", "accuracy").unwrap();
        assert_eq!(best.version, "v2.0.0");
    }

    #[test]
    fn best_model_ignores_archived() {
        let (_dir, registry) = temp_registry();
        registry
            .register_model(sample_metadata("disease_detection", "v1.0.0", 0.95))
            .unwrap();
        registry
            .register_model(sample_metadata("disease_detection", "v2.0.0", 0.88))
            .unwrap();

        registry.archive_model("disease_detection", "v1.0.0").unwrap();

        let best = registry.best_model("disease_detection", "accuracy").unwrap();
        assert_eq!(best.version, "v2.0.0");
    }

    #[test]
    fn compare_versions_returns_deltas() {
        let (_dir, registry) = temp_registry();
        registry
            .register_model(sample_metadata("disease_detection", "v1.0.0", 0.85))
            .unwrap();
        registry
            .register_model(sample_metadata("disease_detection", "v2.0.0", 0.92))
            .unwrap();

        let deltas = registry
            .compare_versions("disease_detection", "v1.0.0", "v2.0.0")
            .unwrap();
        let acc_delta = deltas["accuracy"];
        assert!((acc_delta - 0.07).abs() < 1e-9, "accuracy delta should be ~0.07, got {acc_delta}");
    }

    #[test]
    fn registry_persists_to_disk() {
        let dir = tempfile::tempdir().unwrap();
        {
            let registry = ModelRegistry::new(dir.path()).unwrap();
            registry
                .register_model(sample_metadata("disease_detection", "v1.0.0", 0.90))
                .unwrap();
        }
        // Reopen from the same directory.
        let registry = ModelRegistry::new(dir.path()).unwrap();
        let m = registry.get_model("disease_detection", "v1.0.0").unwrap();
        assert_eq!(m.version, "v1.0.0");

        // Verify the JSON file exists.
        let files: Vec<_> = fs::read_dir(dir.path())
            .unwrap()
            .filter_map(|e| e.ok())
            .collect();
        assert_eq!(files.len(), 1);
    }
}
