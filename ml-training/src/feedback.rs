//! Feed a training run's label suspects back into the review queue.
//!
//! Training already notices when it confidently disagrees with a label and
//! writes the list to `label_noise_report.json`, but a report nobody reads
//! changes nothing. This marks those samples in the collected data itself, so
//! the gateway's review queue can put them in front of a human.
//!
//! That ordering matters more than it first appears. A low-confidence sample is
//! one the model found hard; a contradicted label is one where the *data* is
//! probably wrong, and a wrong label does not merely waste an example — it
//! teaches the next model the same mistake and is counted as an error against
//! any model that gets it right.
//!
//! Label files belong to the gateway and carry fields this crate does not model,
//! so they are edited as JSON values rather than deserialised into a struct:
//! round-tripping through a narrower type would quietly drop whatever it did
//! not know about.

use std::collections::HashSet;
use std::path::{Path, PathBuf};

use serde::{Deserialize, Serialize};

use crate::training::NoisySample;

/// The field written into a label file.
pub const SUSPECT_FIELD: &str = "suspect";

/// What a flagging run changed.
#[derive(Debug, Clone, Default, PartialEq, Serialize, Deserialize)]
pub struct FlagReport {
    /// Samples newly marked or re-marked as suspect.
    pub flagged: usize,
    /// Previously flagged samples this run no longer disputes.
    pub cleared: usize,
    /// Suspect ids with no label file, which means the dataset moved under us.
    pub missing: Vec<String>,
}

/// A model's disagreement with a stored label.
///
/// Mirrors the gateway's `LabelSuspicion`; the two are connected by this JSON
/// shape rather than a shared type, because the training pipeline and the
/// gateway are separate binaries that only meet on disk.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Suspicion {
    pub predicted: String,
    pub predicted_prob: f64,
    pub label_prob: f64,
    pub model_version: String,
    pub flagged_at: String,
}

impl Suspicion {
    fn from_noisy(s: &NoisySample, model_version: &str, at: &str) -> Self {
        Self {
            predicted: s.predicted.clone(),
            predicted_prob: s.predicted_prob as f64,
            label_prob: s.label_prob as f64,
            model_version: model_version.to_string(),
            flagged_at: at.to_string(),
        }
    }
}

fn label_path(labels_dir: &Path, id: &str) -> PathBuf {
    labels_dir.join(format!("{id}.json"))
}

/// Read a label file as a JSON object.
fn read_object(path: &Path) -> anyhow::Result<serde_json::Map<String, serde_json::Value>> {
    let raw = std::fs::read_to_string(path)?;
    match serde_json::from_str(&raw)? {
        serde_json::Value::Object(map) => Ok(map),
        other => anyhow::bail!(
            "{} holds a JSON {}, not an object",
            path.display(),
            match other {
                serde_json::Value::Array(_) => "array",
                serde_json::Value::Null => "null",
                _ => "scalar",
            }
        ),
    }
}

/// Write a label file, via a temporary file so a crash cannot truncate it.
fn write_object(
    path: &Path,
    map: &serde_json::Map<String, serde_json::Value>,
) -> anyhow::Result<()> {
    let tmp = path.with_extension("json.tmp");
    std::fs::write(&tmp, serde_json::to_string_pretty(map)?)?;
    std::fs::rename(&tmp, path)?;
    Ok(())
}

/// Mark this run's suspects in `labels_dir` and clear flags it no longer holds.
///
/// Clearing matters: a label disputed by last month's model and vindicated by
/// this one should leave the queue, or reviewers spend their time on questions
/// that have already been answered.
pub fn flag_suspects(
    labels_dir: &Path,
    suspects: &[NoisySample],
    model_version: &str,
) -> anyhow::Result<FlagReport> {
    if !labels_dir.is_dir() {
        anyhow::bail!("no label directory at {}", labels_dir.display());
    }
    let now = chrono::Utc::now().to_rfc3339();
    let mut report = FlagReport::default();
    let suspect_ids: HashSet<&str> = suspects.iter().map(|s| s.id.as_str()).collect();

    for suspect in suspects {
        let path = label_path(labels_dir, &suspect.id);
        if !path.exists() {
            report.missing.push(suspect.id.clone());
            continue;
        }
        let mut map = read_object(&path)?;
        map.insert(
            SUSPECT_FIELD.to_string(),
            serde_json::to_value(Suspicion::from_noisy(suspect, model_version, &now))?,
        );
        write_object(&path, &map)?;
        report.flagged += 1;
    }

    // Sweep the rest of the directory for flags this run does not repeat.
    for entry in std::fs::read_dir(labels_dir)? {
        let path = entry?.path();
        if path.extension().and_then(|e| e.to_str()) != Some("json") {
            continue;
        }
        let Some(id) = path.file_stem().and_then(|s| s.to_str()) else {
            continue;
        };
        if suspect_ids.contains(id) {
            continue;
        }
        let mut map = match read_object(&path) {
            Ok(map) => map,
            Err(e) => {
                // One unreadable file should not stop the sweep; it is already
                // broken for every other reader too.
                tracing::warn!(path = %path.display(), error = %e, "skipping unreadable label file");
                continue;
            }
        };
        if map.remove(SUSPECT_FIELD).is_some() {
            write_object(&path, &map)?;
            report.cleared += 1;
        }
    }

    tracing::info!(
        flagged = report.flagged,
        cleared = report.cleared,
        missing = report.missing.len(),
        "label suspects written back to the review queue"
    );
    Ok(report)
}

/// Read a run's `label_noise_report.json`.
pub fn load_noise_report(path: &Path) -> anyhow::Result<Vec<NoisySample>> {
    let raw = std::fs::read_to_string(path)
        .map_err(|e| anyhow::anyhow!("cannot read {}: {e}", path.display()))?;
    serde_json::from_str(&raw)
        .map_err(|e| anyhow::anyhow!("malformed noise report {}: {e}", path.display()))
}

#[cfg(test)]
mod tests {
    use super::*;

    fn noisy(id: &str, label: &str, predicted: &str) -> NoisySample {
        NoisySample {
            id: id.to_string(),
            label: label.to_string(),
            predicted: predicted.to_string(),
            predicted_prob: 0.97,
            label_prob: 0.01,
            provenance: "external_api".to_string(),
        }
    }

    /// A label file as the gateway writes it, including a field this crate
    /// does not model.
    fn write_label(dir: &Path, id: &str, extra: &str) {
        let body = format!(
            r#"{{"id":"{id}","task":"disease","labels":[{{"name":"rust","confidence":0.8}}],
                "provenance":"external_api","content_hash":"{id}"{extra}}}"#
        );
        std::fs::write(dir.join(format!("{id}.json")), body).unwrap();
    }

    #[test]
    fn flagging_marks_suspects_and_keeps_unknown_fields() {
        let dir = tempfile::tempdir().unwrap();
        write_label(dir.path(), "a", r#","raw_api_response":"{\"x\":1}""#);
        write_label(dir.path(), "b", "");

        let report =
            flag_suspects(dir.path(), &[noisy("a", "rust", "blight")], "disease-v2").unwrap();
        assert_eq!(report.flagged, 1);
        assert_eq!(report.cleared, 0);
        assert!(report.missing.is_empty());

        let map = read_object(&dir.path().join("a.json")).unwrap();
        let suspect: Suspicion = serde_json::from_value(map[SUSPECT_FIELD].clone()).unwrap();
        assert_eq!(suspect.predicted, "blight");
        // Probabilities are f32 in the report, so the widened value carries
        // f32 precision, not f64.
        assert!((suspect.predicted_prob - 0.97).abs() < 1e-6);
        assert_eq!(suspect.model_version, "disease-v2");
        assert!(!suspect.flagged_at.is_empty());

        // Fields this crate knows nothing about must survive the edit.
        assert_eq!(map["raw_api_response"], "{\"x\":1}");
        assert_eq!(map["content_hash"], "a");
        assert!(map["labels"].is_array());

        // A sample the run did not dispute is left alone.
        assert!(!read_object(&dir.path().join("b.json"))
            .unwrap()
            .contains_key(SUSPECT_FIELD));
    }

    #[test]
    fn a_vindicated_label_loses_its_flag() {
        let dir = tempfile::tempdir().unwrap();
        write_label(dir.path(), "a", "");
        write_label(dir.path(), "b", "");

        // First run disputes both.
        let first = flag_suspects(
            dir.path(),
            &[noisy("a", "rust", "blight"), noisy("b", "rust", "blight")],
            "disease-v1",
        )
        .unwrap();
        assert_eq!(first.flagged, 2);

        // Second run disputes only one; the other must leave the queue rather
        // than stay flagged by a model that has been replaced.
        let second =
            flag_suspects(dir.path(), &[noisy("a", "rust", "blight")], "disease-v2").unwrap();
        assert_eq!(second.flagged, 1);
        assert_eq!(second.cleared, 1);

        assert!(read_object(&dir.path().join("a.json"))
            .unwrap()
            .contains_key(SUSPECT_FIELD));
        assert!(!read_object(&dir.path().join("b.json"))
            .unwrap()
            .contains_key(SUSPECT_FIELD));
    }

    #[test]
    fn re_flagging_replaces_the_previous_verdict() {
        let dir = tempfile::tempdir().unwrap();
        write_label(dir.path(), "a", "");

        flag_suspects(dir.path(), &[noisy("a", "rust", "blight")], "v1").unwrap();
        let mut later = noisy("a", "rust", "leaf_spot");
        later.predicted_prob = 0.99;
        flag_suspects(dir.path(), &[later], "v2").unwrap();

        let map = read_object(&dir.path().join("a.json")).unwrap();
        let suspect: Suspicion = serde_json::from_value(map[SUSPECT_FIELD].clone()).unwrap();
        assert_eq!(
            suspect.predicted, "leaf_spot",
            "the stale verdict should be gone"
        );
        assert_eq!(suspect.model_version, "v2");
    }

    #[test]
    fn a_suspect_with_no_label_file_is_reported_not_fatal() {
        let dir = tempfile::tempdir().unwrap();
        write_label(dir.path(), "a", "");

        let report = flag_suspects(
            dir.path(),
            &[
                noisy("a", "rust", "blight"),
                noisy("gone", "rust", "blight"),
            ],
            "v1",
        )
        .unwrap();
        assert_eq!(report.flagged, 1);
        assert_eq!(report.missing, vec!["gone".to_string()]);
    }

    #[test]
    fn an_unreadable_label_file_does_not_stop_the_sweep() {
        let dir = tempfile::tempdir().unwrap();
        write_label(dir.path(), "a", "");
        std::fs::write(dir.path().join("broken.json"), "{ not json").unwrap();
        // A non-JSON file in the directory is ignored entirely.
        std::fs::write(dir.path().join("notes.txt"), "ignore me").unwrap();

        let report = flag_suspects(dir.path(), &[noisy("a", "rust", "blight")], "v1").unwrap();
        assert_eq!(report.flagged, 1);
    }

    #[test]
    fn flagging_nothing_clears_every_flag() {
        let dir = tempfile::tempdir().unwrap();
        write_label(dir.path(), "a", "");
        flag_suspects(dir.path(), &[noisy("a", "rust", "blight")], "v1").unwrap();

        let report = flag_suspects(dir.path(), &[], "v2").unwrap();
        assert_eq!(report.flagged, 0);
        assert_eq!(report.cleared, 1);
    }

    #[test]
    fn a_missing_directory_is_refused() {
        let dir = tempfile::tempdir().unwrap();
        let err = flag_suspects(&dir.path().join("nope"), &[], "v1")
            .unwrap_err()
            .to_string();
        assert!(err.contains("no label directory"), "{err}");
    }

    #[test]
    fn noise_reports_round_trip() {
        let dir = tempfile::tempdir().unwrap();
        let path = dir.path().join("label_noise_report.json");
        let suspects = vec![noisy("a", "rust", "blight")];
        std::fs::write(&path, serde_json::to_string(&suspects).unwrap()).unwrap();

        let loaded = load_noise_report(&path).unwrap();
        assert_eq!(loaded.len(), 1);
        assert_eq!(loaded[0].predicted, "blight");

        std::fs::write(&path, "not json").unwrap();
        assert!(load_noise_report(&path)
            .unwrap_err()
            .to_string()
            .contains("malformed"));
        assert!(load_noise_report(&dir.path().join("absent.json"))
            .unwrap_err()
            .to_string()
            .contains("cannot read"));
    }
}
