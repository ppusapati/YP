//! Model Performance Monitoring — prediction logging and drift detection.
//!
//! - `PredictionLogger`: appends predictions with timestamps to a JSONL file.
//! - `DriftDetector`: compares recent class distributions against a baseline
//!   using KL divergence and chi-squared tests.
//! - `AlertThreshold`: configurable thresholds for flagging drift.

use std::collections::HashMap;
use std::io::Write;
use std::path::{Path, PathBuf};

use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};

// ── Prediction Logger ──────────────────────────────────────────────

/// A single prediction log entry.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PredictionRecord {
    pub timestamp: DateTime<Utc>,
    pub request_id: String,
    pub task: String,
    pub predicted_class: String,
    pub confidence: f64,
    /// Ground truth, if available (e.g. from human review).
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub actual_class: Option<String>,
}

/// Appends prediction records to a JSONL file for later drift analysis.
pub struct PredictionLogger {
    log_path: PathBuf,
}

impl PredictionLogger {
    /// Create a new logger. The parent directory is created if needed.
    pub fn new(log_path: &Path) -> anyhow::Result<Self> {
        if let Some(parent) = log_path.parent() {
            std::fs::create_dir_all(parent)?;
        }
        Ok(Self {
            log_path: log_path.to_path_buf(),
        })
    }

    /// Log a prediction record.
    pub fn log(&self, record: &PredictionRecord) -> anyhow::Result<()> {
        let mut file = std::fs::OpenOptions::new()
            .create(true)
            .append(true)
            .open(&self.log_path)?;
        let line = serde_json::to_string(record)?;
        writeln!(file, "{line}")?;
        Ok(())
    }

    /// Read all prediction records from the log.
    pub fn read_all(&self) -> anyhow::Result<Vec<PredictionRecord>> {
        let content = std::fs::read_to_string(&self.log_path)?;
        let mut records = Vec::new();
        for line in content.lines() {
            let line = line.trim();
            if line.is_empty() {
                continue;
            }
            records.push(serde_json::from_str(line)?);
        }
        Ok(records)
    }

    /// Read only the most recent `n` records.
    pub fn read_recent(&self, n: usize) -> anyhow::Result<Vec<PredictionRecord>> {
        let all = self.read_all()?;
        let start = all.len().saturating_sub(n);
        Ok(all[start..].to_vec())
    }

    /// Path to the log file.
    pub fn path(&self) -> &Path {
        &self.log_path
    }
}

// ── Drift Detection ────────────────────────────────────────────────

/// Configuration for drift alert thresholds.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AlertThreshold {
    /// KL divergence threshold: flag if KL(recent || baseline) exceeds this.
    pub kl_divergence_threshold: f64,
    /// Chi-squared threshold: flag if the chi-squared statistic exceeds this.
    pub chi_squared_threshold: f64,
}

impl Default for AlertThreshold {
    fn default() -> Self {
        Self {
            kl_divergence_threshold: 0.1,
            chi_squared_threshold: 15.0,
        }
    }
}

/// Outcome of a drift check.
#[derive(Debug, Clone)]
pub struct DriftResult {
    pub drift_detected: bool,
    pub kl_divergence: f64,
    pub chi_squared: f64,
    pub baseline_distribution: HashMap<String, f64>,
    pub recent_distribution: HashMap<String, f64>,
    pub details: String,
}

/// Detects prediction distribution drift.
pub struct DriftDetector {
    threshold: AlertThreshold,
}

impl DriftDetector {
    pub fn new(threshold: AlertThreshold) -> Self {
        Self { threshold }
    }

    /// Compare a baseline distribution (from training or an earlier window)
    /// against a recent distribution (from recent predictions).
    ///
    /// Both inputs are class → count maps.
    pub fn check_drift(
        &self,
        baseline_counts: &HashMap<String, usize>,
        recent_counts: &HashMap<String, usize>,
    ) -> DriftResult {
        let baseline_dist = normalize(baseline_counts);
        let recent_dist = normalize(recent_counts);

        // Collect the union of all classes.
        let mut all_classes: Vec<String> = baseline_dist
            .keys()
            .chain(recent_dist.keys())
            .cloned()
            .collect();
        all_classes.sort();
        all_classes.dedup();

        let kl = kl_divergence(&recent_dist, &baseline_dist, &all_classes);
        let chi2 = chi_squared(baseline_counts, recent_counts, &all_classes);

        let kl_flag = kl > self.threshold.kl_divergence_threshold;
        let chi2_flag = chi2 > self.threshold.chi_squared_threshold;
        let drift_detected = kl_flag || chi2_flag;

        let details = format!(
            "KL divergence: {kl:.6} (threshold: {:.6}, {}), \
             Chi-squared: {chi2:.4} (threshold: {:.4}, {})",
            self.threshold.kl_divergence_threshold,
            if kl_flag { "EXCEEDED" } else { "ok" },
            self.threshold.chi_squared_threshold,
            if chi2_flag { "EXCEEDED" } else { "ok" },
        );

        DriftResult {
            drift_detected,
            kl_divergence: kl,
            chi_squared: chi2,
            baseline_distribution: baseline_dist,
            recent_distribution: recent_dist,
            details,
        }
    }

    /// Convenience: build class count maps from prediction records.
    pub fn counts_from_records(records: &[PredictionRecord]) -> HashMap<String, usize> {
        let mut counts = HashMap::new();
        for r in records {
            *counts.entry(r.predicted_class.clone()).or_default() += 1;
        }
        counts
    }
}

// ── Statistical helpers ────────────────────────────────────────────

/// Normalize a count map to a probability distribution.
fn normalize(counts: &HashMap<String, usize>) -> HashMap<String, f64> {
    let total: usize = counts.values().sum();
    if total == 0 {
        return HashMap::new();
    }
    counts
        .iter()
        .map(|(k, &v)| (k.clone(), v as f64 / total as f64))
        .collect()
}

/// KL divergence: D_KL(P || Q) = sum_x P(x) * ln(P(x) / Q(x))
///
/// Uses additive smoothing (epsilon) to handle zero probabilities.
fn kl_divergence(
    p: &HashMap<String, f64>,
    q: &HashMap<String, f64>,
    classes: &[String],
) -> f64 {
    let epsilon = 1e-10;
    let mut kl = 0.0;
    for class in classes {
        let p_val = p.get(class).copied().unwrap_or(0.0).max(epsilon);
        let q_val = q.get(class).copied().unwrap_or(0.0).max(epsilon);
        kl += p_val * (p_val / q_val).ln();
    }
    kl
}

/// Chi-squared statistic comparing observed (recent) against expected
/// (baseline) counts.
fn chi_squared(
    baseline_counts: &HashMap<String, usize>,
    recent_counts: &HashMap<String, usize>,
    classes: &[String],
) -> f64 {
    let baseline_total: f64 = baseline_counts.values().sum::<usize>() as f64;
    let recent_total: f64 = recent_counts.values().sum::<usize>() as f64;

    if baseline_total == 0.0 || recent_total == 0.0 {
        return 0.0;
    }

    let mut chi2 = 0.0;
    for class in classes {
        let baseline_prop = *baseline_counts.get(class).unwrap_or(&0) as f64 / baseline_total;
        let expected = baseline_prop * recent_total;
        let observed = *recent_counts.get(class).unwrap_or(&0) as f64;

        if expected > 0.0 {
            chi2 += (observed - expected).powi(2) / expected;
        }
    }
    chi2
}

#[cfg(test)]
mod tests {
    use super::*;

    // ── PredictionLogger ────────────────────────────────────────

    #[test]
    fn logger_writes_and_reads_records() {
        let dir = tempfile::tempdir().unwrap();
        let log_path = dir.path().join("predictions.jsonl");
        let logger = PredictionLogger::new(&log_path).unwrap();

        let record = PredictionRecord {
            timestamp: Utc::now(),
            request_id: "req-001".to_string(),
            task: "disease_detection".to_string(),
            predicted_class: "blight".to_string(),
            confidence: 0.92,
            actual_class: Some("blight".to_string()),
        };
        logger.log(&record).unwrap();
        logger.log(&record).unwrap();

        let records = logger.read_all().unwrap();
        assert_eq!(records.len(), 2);
        assert_eq!(records[0].predicted_class, "blight");
        assert_eq!(records[0].request_id, "req-001");
    }

    #[test]
    fn logger_read_recent_returns_last_n() {
        let dir = tempfile::tempdir().unwrap();
        let log_path = dir.path().join("predictions.jsonl");
        let logger = PredictionLogger::new(&log_path).unwrap();

        for i in 0..10 {
            let record = PredictionRecord {
                timestamp: Utc::now(),
                request_id: format!("req-{i:03}"),
                task: "pest_detection".to_string(),
                predicted_class: format!("class_{}", i % 3),
                confidence: 0.8 + (i as f64 * 0.01),
                actual_class: None,
            };
            logger.log(&record).unwrap();
        }

        let recent = logger.read_recent(3).unwrap();
        assert_eq!(recent.len(), 3);
        assert_eq!(recent[0].request_id, "req-007");
        assert_eq!(recent[2].request_id, "req-009");
    }

    #[test]
    fn logger_creates_parent_directory() {
        let dir = tempfile::tempdir().unwrap();
        let deep_path = dir.path().join("a").join("b").join("log.jsonl");
        let logger = PredictionLogger::new(&deep_path).unwrap();
        assert!(deep_path.parent().unwrap().exists());

        let record = PredictionRecord {
            timestamp: Utc::now(),
            request_id: "r1".to_string(),
            task: "test".to_string(),
            predicted_class: "c".to_string(),
            confidence: 0.5,
            actual_class: None,
        };
        logger.log(&record).unwrap();
        assert!(deep_path.exists());
    }

    // ── DriftDetector ───────────────────────────────────────────

    fn make_counts(pairs: &[(&str, usize)]) -> HashMap<String, usize> {
        pairs.iter().map(|(k, v)| (k.to_string(), *v)).collect()
    }

    #[test]
    fn no_drift_with_identical_distributions() {
        let detector = DriftDetector::new(AlertThreshold::default());
        let baseline = make_counts(&[("healthy", 50), ("blight", 30), ("rust", 20)]);
        let recent = make_counts(&[("healthy", 50), ("blight", 30), ("rust", 20)]);

        let result = detector.check_drift(&baseline, &recent);
        assert!(!result.drift_detected);
        assert!(result.kl_divergence < 1e-6, "KL should be ~0 for identical dists");
        assert!(result.chi_squared < 1e-6, "chi2 should be ~0 for identical dists");
    }

    #[test]
    fn drift_detected_with_very_different_distributions() {
        let detector = DriftDetector::new(AlertThreshold {
            kl_divergence_threshold: 0.1,
            chi_squared_threshold: 10.0,
        });

        let baseline = make_counts(&[("healthy", 80), ("blight", 10), ("rust", 10)]);
        let recent = make_counts(&[("healthy", 10), ("blight", 10), ("rust", 80)]);

        let result = detector.check_drift(&baseline, &recent);
        assert!(result.drift_detected, "should detect drift with shifted distribution");
        assert!(result.kl_divergence > 0.1);
        assert!(result.details.contains("EXCEEDED"));
    }

    #[test]
    fn drift_with_new_class_in_recent() {
        let detector = DriftDetector::new(AlertThreshold {
            kl_divergence_threshold: 0.05,
            chi_squared_threshold: 5.0,
        });

        let baseline = make_counts(&[("healthy", 70), ("blight", 30)]);
        let recent = make_counts(&[("healthy", 40), ("blight", 20), ("new_disease", 40)]);

        let result = detector.check_drift(&baseline, &recent);
        assert!(result.drift_detected, "new class should trigger drift");
    }

    #[test]
    fn counts_from_records_builds_correct_map() {
        let records = vec![
            PredictionRecord {
                timestamp: Utc::now(),
                request_id: "r1".to_string(),
                task: "t".to_string(),
                predicted_class: "healthy".to_string(),
                confidence: 0.9,
                actual_class: None,
            },
            PredictionRecord {
                timestamp: Utc::now(),
                request_id: "r2".to_string(),
                task: "t".to_string(),
                predicted_class: "blight".to_string(),
                confidence: 0.8,
                actual_class: None,
            },
            PredictionRecord {
                timestamp: Utc::now(),
                request_id: "r3".to_string(),
                task: "t".to_string(),
                predicted_class: "healthy".to_string(),
                confidence: 0.85,
                actual_class: None,
            },
        ];

        let counts = DriftDetector::counts_from_records(&records);
        assert_eq!(counts["healthy"], 2);
        assert_eq!(counts["blight"], 1);
        assert_eq!(counts.len(), 2);
    }

    #[test]
    fn chi_squared_zero_for_same_proportions() {
        let baseline = make_counts(&[("a", 100), ("b", 200)]);
        let recent = make_counts(&[("a", 50), ("b", 100)]);

        let classes = vec!["a".to_string(), "b".to_string()];
        let chi2 = super::chi_squared(&baseline, &recent, &classes);
        assert!(chi2.abs() < 1e-9, "same proportions should give chi2 ~0, got {chi2}");
    }

    #[test]
    fn empty_distributions_handled_gracefully() {
        let detector = DriftDetector::new(AlertThreshold::default());
        let baseline = HashMap::new();
        let recent = make_counts(&[("a", 10)]);

        let result = detector.check_drift(&baseline, &recent);
        // Should not panic; drift may or may not be detected with empty baseline.
        assert!(result.kl_divergence.is_finite());
        assert!(result.chi_squared.is_finite());
    }

    #[test]
    fn alert_threshold_default_values() {
        let threshold = AlertThreshold::default();
        assert!((threshold.kl_divergence_threshold - 0.1).abs() < f64::EPSILON);
        assert!((threshold.chi_squared_threshold - 15.0).abs() < f64::EPSILON);
    }

    #[test]
    fn prediction_record_serialization_roundtrip() {
        let record = PredictionRecord {
            timestamp: Utc::now(),
            request_id: "req-42".to_string(),
            task: "disease_detection".to_string(),
            predicted_class: "blight".to_string(),
            confidence: 0.95,
            actual_class: Some("blight".to_string()),
        };

        let json = serde_json::to_string(&record).unwrap();
        let deserialized: PredictionRecord = serde_json::from_str(&json).unwrap();
        assert_eq!(deserialized.request_id, "req-42");
        assert_eq!(deserialized.predicted_class, "blight");
        assert_eq!(deserialized.actual_class, Some("blight".to_string()));
    }

    #[test]
    fn prediction_record_without_actual_class() {
        let record = PredictionRecord {
            timestamp: Utc::now(),
            request_id: "req-1".to_string(),
            task: "pest_detection".to_string(),
            predicted_class: "aphid".to_string(),
            confidence: 0.78,
            actual_class: None,
        };

        let json = serde_json::to_string(&record).unwrap();
        assert!(!json.contains("actual_class"), "None should be skipped");
        let deserialized: PredictionRecord = serde_json::from_str(&json).unwrap();
        assert!(deserialized.actual_class.is_none());
    }
}
