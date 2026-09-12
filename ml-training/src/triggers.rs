//! Retraining Triggers — determine when automated retraining should start.
//!
//! Three trigger types:
//! - `DataThresholdTrigger`: fires when collected samples exceed a per-category threshold.
//! - `ScheduleTrigger`: fires based on a simple cron-like schedule.
//! - `DriftTrigger`: fires when production accuracy drops below a threshold.
//!
//! Configuration lives in the `[retraining]` section of the training TOML config.

use std::collections::HashMap;
use std::path::{Path, PathBuf};

use chrono::{DateTime, Datelike, NaiveTime, Utc, Weekday};
use serde::Deserialize;

// ── Configuration ──────────────────────────────────────────────────

/// Top-level retraining trigger configuration, loaded from TOML.
#[derive(Debug, Deserialize, Clone)]
pub struct TriggerConfig {
    #[serde(default)]
    pub data_threshold: Option<DataThresholdConfig>,
    #[serde(default)]
    pub schedule: Option<ScheduleConfig>,
    #[serde(default)]
    pub drift: Option<DriftConfig>,
}

/// Configuration for data-threshold based retraining.
#[derive(Debug, Deserialize, Clone)]
pub struct DataThresholdConfig {
    /// Minimum new samples per category before triggering retraining.
    pub samples_per_category: usize,
    /// Base directory where collected data lives (one subdir per task).
    pub data_dir: String,
}

/// Configuration for schedule-based retraining.
#[derive(Debug, Deserialize, Clone)]
pub struct ScheduleConfig {
    /// Day of week: "monday", "tuesday", etc.
    pub day_of_week: String,
    /// Time of day in HH:MM format.
    pub time: String,
}

/// Configuration for drift-based retraining.
#[derive(Debug, Deserialize, Clone)]
pub struct DriftConfig {
    /// Minimum accuracy; trigger when accuracy drops below this.
    pub accuracy_threshold: f64,
    /// Path to a JSONL file of recent prediction logs.
    pub predictions_log: String,
}

// ── Trigger Evaluation ─────────────────────────────────────────────

/// Result of evaluating a single trigger.
#[derive(Debug, Clone)]
pub struct TriggerResult {
    pub trigger_name: String,
    pub should_retrain: bool,
    pub reason: String,
}

/// Check the data-threshold trigger for a given task.
///
/// Counts lines in `{data_dir}/{task}/manifest.jsonl` and fires if the
/// count exceeds `samples_per_category * min_categories`.
pub fn check_data_threshold(
    config: &DataThresholdConfig,
    task: &str,
    min_categories: usize,
) -> TriggerResult {
    let manifest_path = PathBuf::from(&config.data_dir)
        .join(task)
        .join("manifest.jsonl");

    let count = match std::fs::read_to_string(&manifest_path) {
        Ok(content) => content.lines().filter(|l| !l.trim().is_empty()).count(),
        Err(_) => 0,
    };

    let threshold = config.samples_per_category * min_categories.max(1);
    let should_retrain = count >= threshold;
    let reason = if should_retrain {
        format!(
            "data threshold reached: {count} samples >= {threshold} ({}x{})",
            config.samples_per_category, min_categories
        )
    } else {
        format!(
            "below threshold: {count} samples < {threshold} ({}x{})",
            config.samples_per_category, min_categories
        )
    };

    TriggerResult {
        trigger_name: "data_threshold".to_string(),
        should_retrain,
        reason,
    }
}

/// Check the schedule trigger against a given timestamp.
///
/// Returns true if `now` falls on the configured day of week and is at or
/// past the configured time.
pub fn check_schedule(config: &ScheduleConfig, now: DateTime<Utc>) -> TriggerResult {
    let target_day = parse_weekday(&config.day_of_week);
    let target_time = NaiveTime::parse_from_str(&config.time, "%H:%M").ok();

    let should_retrain = match (target_day, target_time) {
        (Some(day), Some(time)) => {
            now.weekday() == day && now.time() >= time
        }
        _ => false,
    };

    let reason = if should_retrain {
        format!("schedule matched: {} {}", config.day_of_week, config.time)
    } else {
        format!(
            "schedule not matched: current={} {}, target={} {}",
            now.weekday(),
            now.format("%H:%M"),
            config.day_of_week,
            config.time
        )
    };

    TriggerResult {
        trigger_name: "schedule".to_string(),
        should_retrain,
        reason,
    }
}

/// Check the drift trigger by reading recent predictions and computing accuracy.
///
/// The predictions log is a JSONL file where each line has:
/// `{"predicted": "class_a", "actual": "class_a", "confidence": 0.95, ...}`
pub fn check_drift(config: &DriftConfig) -> TriggerResult {
    let accuracy = compute_recent_accuracy(&config.predictions_log);

    let should_retrain = match accuracy {
        Some(acc) => acc < config.accuracy_threshold,
        None => false, // No data means no drift detected.
    };

    let reason = match accuracy {
        Some(acc) if should_retrain => {
            format!(
                "drift detected: accuracy {acc:.4} < threshold {:.4}",
                config.accuracy_threshold
            )
        }
        Some(acc) => {
            format!(
                "no drift: accuracy {acc:.4} >= threshold {:.4}",
                config.accuracy_threshold
            )
        }
        None => "no prediction log data available".to_string(),
    };

    TriggerResult {
        trigger_name: "drift".to_string(),
        should_retrain,
        reason,
    }
}

/// Evaluate all configured triggers and return the results.
///
/// Returns `true` as the first element if any trigger fired.
pub fn check_triggers(
    config: &TriggerConfig,
    task: &str,
    min_categories: usize,
    now: DateTime<Utc>,
) -> (bool, Vec<TriggerResult>) {
    let mut results = Vec::new();

    if let Some(ref dt_config) = config.data_threshold {
        results.push(check_data_threshold(dt_config, task, min_categories));
    }

    if let Some(ref sched_config) = config.schedule {
        results.push(check_schedule(sched_config, now));
    }

    if let Some(ref drift_config) = config.drift {
        results.push(check_drift(drift_config));
    }

    let any_fired = results.iter().any(|r| r.should_retrain);
    (any_fired, results)
}

// ── Internal helpers ───────────────────────────────────────────────

fn parse_weekday(s: &str) -> Option<Weekday> {
    match s.to_lowercase().as_str() {
        "monday" | "mon" => Some(Weekday::Mon),
        "tuesday" | "tue" => Some(Weekday::Tue),
        "wednesday" | "wed" => Some(Weekday::Wed),
        "thursday" | "thu" => Some(Weekday::Thu),
        "friday" | "fri" => Some(Weekday::Fri),
        "saturday" | "sat" => Some(Weekday::Sat),
        "sunday" | "sun" => Some(Weekday::Sun),
        _ => None,
    }
}

/// Prediction log entry for drift detection.
#[derive(Debug, Deserialize)]
struct PredictionEntry {
    predicted: String,
    actual: String,
    #[allow(dead_code)]
    confidence: Option<f64>,
}

fn compute_recent_accuracy(log_path: &str) -> Option<f64> {
    let content = std::fs::read_to_string(log_path).ok()?;
    let mut correct = 0usize;
    let mut total = 0usize;

    for line in content.lines() {
        let line = line.trim();
        if line.is_empty() {
            continue;
        }
        if let Ok(entry) = serde_json::from_str::<PredictionEntry>(line) {
            if entry.predicted == entry.actual {
                correct += 1;
            }
            total += 1;
        }
    }

    if total == 0 {
        None
    } else {
        Some(correct as f64 / total as f64)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use chrono::TimeZone;
    use std::io::Write;

    // ── DataThresholdTrigger ─────────────────────────────────────

    #[test]
    fn data_threshold_fires_when_enough_samples() {
        let dir = tempfile::tempdir().unwrap();
        let task_dir = dir.path().join("disease_detection");
        std::fs::create_dir_all(&task_dir).unwrap();

        // Write 100 manifest lines.
        let manifest = task_dir.join("manifest.jsonl");
        let mut f = std::fs::File::create(&manifest).unwrap();
        for i in 0..100 {
            writeln!(f, r#"{{"id":"s{i}","image":"img.jpg","labels":["a"],"timestamp":"2024-01-01"}}"#).unwrap();
        }

        let config = DataThresholdConfig {
            samples_per_category: 10,
            data_dir: dir.path().to_string_lossy().to_string(),
        };

        let result = check_data_threshold(&config, "disease_detection", 5);
        assert!(result.should_retrain, "should fire: 100 >= 10*5=50");
        assert!(result.reason.contains("threshold reached"));
    }

    #[test]
    fn data_threshold_does_not_fire_below_threshold() {
        let dir = tempfile::tempdir().unwrap();
        let task_dir = dir.path().join("pest_detection");
        std::fs::create_dir_all(&task_dir).unwrap();

        let manifest = task_dir.join("manifest.jsonl");
        let mut f = std::fs::File::create(&manifest).unwrap();
        for i in 0..5 {
            writeln!(f, r#"{{"id":"s{i}"}}"#).unwrap();
        }

        let config = DataThresholdConfig {
            samples_per_category: 10,
            data_dir: dir.path().to_string_lossy().to_string(),
        };

        let result = check_data_threshold(&config, "pest_detection", 3);
        assert!(!result.should_retrain, "5 < 10*3=30");
    }

    #[test]
    fn data_threshold_handles_missing_manifest() {
        let config = DataThresholdConfig {
            samples_per_category: 10,
            data_dir: "/nonexistent/path".to_string(),
        };

        let result = check_data_threshold(&config, "disease_detection", 3);
        assert!(!result.should_retrain);
    }

    // ── ScheduleTrigger ─────────────────────────────────────────

    #[test]
    fn schedule_fires_on_matching_day_and_time() {
        let config = ScheduleConfig {
            day_of_week: "wednesday".to_string(),
            time: "02:00".to_string(),
        };

        // 2024-01-03 is a Wednesday.
        let now = Utc.with_ymd_and_hms(2024, 1, 3, 3, 0, 0).unwrap();
        let result = check_schedule(&config, now);
        assert!(result.should_retrain, "Wednesday 03:00 >= 02:00");
    }

    #[test]
    fn schedule_does_not_fire_on_wrong_day() {
        let config = ScheduleConfig {
            day_of_week: "monday".to_string(),
            time: "08:00".to_string(),
        };

        // 2024-01-03 is a Wednesday.
        let now = Utc.with_ymd_and_hms(2024, 1, 3, 10, 0, 0).unwrap();
        let result = check_schedule(&config, now);
        assert!(!result.should_retrain);
    }

    #[test]
    fn schedule_does_not_fire_before_time() {
        let config = ScheduleConfig {
            day_of_week: "wednesday".to_string(),
            time: "14:00".to_string(),
        };

        let now = Utc.with_ymd_and_hms(2024, 1, 3, 10, 0, 0).unwrap();
        let result = check_schedule(&config, now);
        assert!(!result.should_retrain, "10:00 < 14:00");
    }

    #[test]
    fn schedule_handles_invalid_day() {
        let config = ScheduleConfig {
            day_of_week: "not_a_day".to_string(),
            time: "08:00".to_string(),
        };

        let now = Utc::now();
        let result = check_schedule(&config, now);
        assert!(!result.should_retrain);
    }

    // ── DriftTrigger ────────────────────────────────────────────

    #[test]
    fn drift_fires_when_accuracy_below_threshold() {
        let dir = tempfile::tempdir().unwrap();
        let log_path = dir.path().join("predictions.jsonl");
        let mut f = std::fs::File::create(&log_path).unwrap();

        // 3 correct out of 10 = 30% accuracy.
        for i in 0..10 {
            let actual = "class_a";
            let predicted = if i < 3 { "class_a" } else { "class_b" };
            writeln!(
                f,
                r#"{{"predicted":"{predicted}","actual":"{actual}","confidence":0.9}}"#
            )
            .unwrap();
        }

        let config = DriftConfig {
            accuracy_threshold: 0.80,
            predictions_log: log_path.to_string_lossy().to_string(),
        };

        let result = check_drift(&config);
        assert!(result.should_retrain, "30% < 80%");
        assert!(result.reason.contains("drift detected"));
    }

    #[test]
    fn drift_does_not_fire_when_accuracy_above_threshold() {
        let dir = tempfile::tempdir().unwrap();
        let log_path = dir.path().join("predictions.jsonl");
        let mut f = std::fs::File::create(&log_path).unwrap();

        // 9 correct out of 10 = 90% accuracy.
        for i in 0..10 {
            let actual = "class_a";
            let predicted = if i < 9 { "class_a" } else { "class_b" };
            writeln!(
                f,
                r#"{{"predicted":"{predicted}","actual":"{actual}","confidence":0.9}}"#
            )
            .unwrap();
        }

        let config = DriftConfig {
            accuracy_threshold: 0.80,
            predictions_log: log_path.to_string_lossy().to_string(),
        };

        let result = check_drift(&config);
        assert!(!result.should_retrain, "90% >= 80%");
        assert!(result.reason.contains("no drift"));
    }

    #[test]
    fn drift_handles_missing_log() {
        let config = DriftConfig {
            accuracy_threshold: 0.80,
            predictions_log: "/nonexistent/log.jsonl".to_string(),
        };

        let result = check_drift(&config);
        assert!(!result.should_retrain);
        assert!(result.reason.contains("no prediction log data"));
    }

    #[test]
    fn drift_handles_empty_log() {
        let dir = tempfile::tempdir().unwrap();
        let log_path = dir.path().join("empty.jsonl");
        std::fs::write(&log_path, "").unwrap();

        let config = DriftConfig {
            accuracy_threshold: 0.80,
            predictions_log: log_path.to_string_lossy().to_string(),
        };

        let result = check_drift(&config);
        assert!(!result.should_retrain);
    }

    // ── check_triggers (combined) ───────────────────────────────

    #[test]
    fn check_triggers_any_fired() {
        let config = TriggerConfig {
            data_threshold: Some(DataThresholdConfig {
                samples_per_category: 1_000_000,
                data_dir: "/nonexistent".to_string(),
            }),
            schedule: Some(ScheduleConfig {
                // Use a specific known day.
                day_of_week: "wednesday".to_string(),
                time: "00:00".to_string(),
            }),
            drift: None,
        };

        // 2024-01-03 is a Wednesday.
        let now = Utc.with_ymd_and_hms(2024, 1, 3, 12, 0, 0).unwrap();
        let (any_fired, results) = check_triggers(&config, "disease_detection", 3, now);

        assert!(any_fired, "schedule trigger should fire");
        assert_eq!(results.len(), 2);
        assert!(!results[0].should_retrain, "data threshold should not fire");
        assert!(results[1].should_retrain, "schedule should fire");
    }

    #[test]
    fn check_triggers_none_fired() {
        let config = TriggerConfig {
            data_threshold: Some(DataThresholdConfig {
                samples_per_category: 1_000_000,
                data_dir: "/nonexistent".to_string(),
            }),
            schedule: Some(ScheduleConfig {
                day_of_week: "monday".to_string(),
                time: "00:00".to_string(),
            }),
            drift: None,
        };

        // 2024-01-03 is a Wednesday.
        let now = Utc.with_ymd_and_hms(2024, 1, 3, 12, 0, 0).unwrap();
        let (any_fired, results) = check_triggers(&config, "disease_detection", 3, now);

        assert!(!any_fired);
        assert_eq!(results.len(), 2);
    }

    #[test]
    fn check_triggers_empty_config() {
        let config = TriggerConfig {
            data_threshold: None,
            schedule: None,
            drift: None,
        };

        let (any_fired, results) = check_triggers(&config, "disease_detection", 3, Utc::now());
        assert!(!any_fired);
        assert!(results.is_empty());
    }

    #[test]
    fn trigger_config_deserializes_from_toml() {
        let toml_str = r#"
[data_threshold]
samples_per_category = 500
data_dir = "/data/collected"

[schedule]
day_of_week = "sunday"
time = "03:00"

[drift]
accuracy_threshold = 0.85
predictions_log = "/logs/predictions.jsonl"
"#;
        let config: TriggerConfig = toml::from_str(toml_str).unwrap();
        assert_eq!(config.data_threshold.as_ref().unwrap().samples_per_category, 500);
        assert_eq!(config.schedule.as_ref().unwrap().day_of_week, "sunday");
        assert!((config.drift.as_ref().unwrap().accuracy_threshold - 0.85).abs() < f64::EPSILON);
    }
}
