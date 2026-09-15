//! A frozen held-out benchmark that every candidate model must pass.
//!
//! A test split recomputed from the current dataset is not a benchmark: it
//! moves every time data arrives, so two models are never compared on the same
//! images and a "+2% accuracy" can be entirely an easier split. A benchmark
//! suite pins the exact sample ids **and the labels they had when it was
//! frozen**, so a later relabel shows up as drift instead of quietly changing
//! the target.
//!
//! The suite also carries the thresholds a model must clear and, once one has
//! been promoted, that model's numbers as a baseline. Gating on both absolutes
//! and regressions catches the two ways a release goes wrong: shipping a model
//! that was never good enough, and shipping one that is worse than what is
//! already live.
//!
//! Because classes are numbered by whatever the training run happened to see,
//! a model's class order need not match the suite's. Predictions are folded
//! into the suite's label space by name before anything is measured — comparing
//! two different index spaces would produce metrics that look plausible and
//! mean nothing.

use std::collections::HashMap;
use std::path::Path;

use serde::{Deserialize, Serialize};

use crate::eval::{EvaluationReport, Prediction};

/// Below this share of pinned samples the benchmark is not measuring what it
/// was frozen to measure.
pub const DEFAULT_MIN_COVERAGE: f64 = 0.95;

/// One pinned sample: an id plus the label it carried when frozen.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct BenchmarkSample {
    pub id: String,
    pub label: String,
}

/// Bars a candidate must clear.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Thresholds {
    pub min_accuracy: f64,
    pub min_macro_f1: f64,
    /// Expected calibration error ceiling: confidence must roughly match
    /// correctness, or downstream spray/no-spray decisions are miscalibrated
    /// even when accuracy looks fine.
    pub max_ece: f64,
    /// Floor for the worst sufficiently-large slice, so a model cannot pass on
    /// its average while failing one crop or region.
    pub min_worst_slice_accuracy: f64,
    /// How much accuracy may regress against the promoted baseline.
    pub max_accuracy_drop: f64,
    /// How much calibration error may grow against the promoted baseline.
    pub max_ece_increase: f64,
    /// Share of pinned samples that must still be present.
    pub min_coverage: f64,
    /// Fewest samples a benchmark may decide on. A handful of images cannot
    /// separate a good model from a lucky one, and promoting on that basis is
    /// exactly what this gate exists to prevent.
    #[serde(default = "default_min_samples")]
    pub min_samples: usize,
}

fn default_min_samples() -> usize {
    50
}

impl Default for Thresholds {
    fn default() -> Self {
        Self {
            min_accuracy: 0.80,
            min_macro_f1: 0.75,
            max_ece: 0.10,
            min_worst_slice_accuracy: 0.65,
            max_accuracy_drop: 0.02,
            max_ece_increase: 0.03,
            min_coverage: DEFAULT_MIN_COVERAGE,
            min_samples: default_min_samples(),
        }
    }
}

/// The numbers a promoted model scored, kept for regression comparison.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Baseline {
    pub model_version: String,
    pub recorded_at: String,
    pub accuracy: f64,
    pub macro_f1: f64,
    pub ece: f64,
    pub worst_slice_accuracy: f64,
}

impl Baseline {
    pub fn from_report(report: &EvaluationReport) -> Self {
        Self {
            model_version: report.model_version.clone(),
            recorded_at: chrono::Utc::now().to_rfc3339(),
            accuracy: report.accuracy,
            macro_f1: report.macro_f1,
            ece: report.calibration.ece,
            worst_slice_accuracy: worst_slice_accuracy(report).unwrap_or(report.accuracy),
        }
    }
}

/// A frozen benchmark for one task.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BenchmarkSuite {
    pub task: String,
    pub created_at: String,
    /// Class order this benchmark measures in. Predictions are folded into it.
    pub labels: Vec<String>,
    pub samples: Vec<BenchmarkSample>,
    #[serde(default)]
    pub thresholds: Thresholds,
    #[serde(default)]
    pub baseline: Option<Baseline>,
    /// Dataset snapshot the suite was cut from, for provenance.
    #[serde(default)]
    pub source_snapshot: String,
}

impl BenchmarkSuite {
    /// Freeze a suite from held-out samples.
    pub fn create(
        task: &str,
        samples: &[(String, String)],
        labels: Vec<String>,
        source_snapshot: &str,
    ) -> anyhow::Result<Self> {
        if samples.is_empty() {
            anyhow::bail!("cannot freeze an empty benchmark for {task}");
        }
        let unknown: Vec<&str> = samples
            .iter()
            .map(|(_, label)| label.as_str())
            .filter(|l| !labels.iter().any(|k| k == l))
            .collect();
        if let Some(first) = unknown.first() {
            anyhow::bail!("sample label {first:?} is not in the benchmark's label list");
        }
        Ok(Self {
            task: task.to_string(),
            created_at: chrono::Utc::now().to_rfc3339(),
            labels,
            samples: samples
                .iter()
                .map(|(id, label)| BenchmarkSample {
                    id: id.clone(),
                    label: label.clone(),
                })
                .collect(),
            thresholds: Thresholds::default(),
            baseline: None,
            source_snapshot: source_snapshot.to_string(),
        })
    }

    pub fn load(path: &Path) -> anyhow::Result<Self> {
        let raw = std::fs::read_to_string(path)
            .map_err(|e| anyhow::anyhow!("cannot read benchmark {}: {e}", path.display()))?;
        let suite: Self = serde_json::from_str(&raw)
            .map_err(|e| anyhow::anyhow!("malformed benchmark {}: {e}", path.display()))?;
        if suite.samples.is_empty() {
            anyhow::bail!("benchmark {} pins no samples", path.display());
        }
        if suite.labels.is_empty() {
            anyhow::bail!("benchmark {} has no label list", path.display());
        }
        Ok(suite)
    }

    pub fn save(&self, path: &Path) -> anyhow::Result<()> {
        if let Some(parent) = path.parent() {
            std::fs::create_dir_all(parent)?;
        }
        std::fs::write(path, serde_json::to_string_pretty(self)?)?;
        Ok(())
    }

    /// Index of a label in the benchmark's class order.
    pub fn label_index(&self, label: &str) -> Option<usize> {
        self.labels.iter().position(|l| l == label)
    }

    /// Match pinned samples against what the dataset currently holds.
    ///
    /// The pinned label wins: if a sample has been relabelled since freezing,
    /// the benchmark still scores against what it was frozen with and reports
    /// the drift, so a changing ground truth cannot quietly move the bar.
    pub fn resolve<'a, S>(
        &self,
        available: &'a [S],
        id_of: impl Fn(&S) -> &str,
    ) -> Coverage<'a, S> {
        let by_id: HashMap<&str, &'a S> = available.iter().map(|s| (id_of(s), s)).collect();
        let mut found = Vec::new();
        let mut missing = Vec::new();
        for pinned in &self.samples {
            match by_id.get(pinned.id.as_str()) {
                Some(&sample) => found.push((pinned.clone(), sample)),
                None => missing.push(pinned.id.clone()),
            }
        }
        Coverage {
            pinned: self.samples.len(),
            found,
            missing,
        }
    }
}

/// Which pinned samples are still available.
#[derive(Debug)]
pub struct Coverage<'a, S> {
    pub pinned: usize,
    pub found: Vec<(BenchmarkSample, &'a S)>,
    pub missing: Vec<String>,
}

impl<S> Coverage<'_, S> {
    pub fn ratio(&self) -> f64 {
        if self.pinned == 0 {
            return 0.0;
        }
        self.found.len() as f64 / self.pinned as f64
    }
}

/// Fold predictions from a model's class order into the benchmark's.
///
/// `model_labels` is the model's own class order. Probability mass on classes
/// the benchmark does not know is dropped and the rest renormalised; that is
/// reported rather than hidden, because it means the model can answer things
/// the benchmark cannot score.
pub fn fold_into_label_space(
    predictions: &[Prediction],
    model_labels: &[String],
    suite_labels: &[String],
) -> anyhow::Result<(Vec<Prediction>, Vec<String>)> {
    let missing: Vec<String> = suite_labels
        .iter()
        .filter(|l| !model_labels.contains(l))
        .cloned()
        .collect();
    if !missing.is_empty() {
        anyhow::bail!(
            "model cannot predict benchmark classes {:?}; it knows {:?}",
            missing,
            model_labels
        );
    }
    let extra: Vec<String> = model_labels
        .iter()
        .filter(|l| !suite_labels.contains(l))
        .cloned()
        .collect();

    // suite index -> model index
    let mapping: Vec<usize> = suite_labels
        .iter()
        .map(|l| model_labels.iter().position(|m| m == l).unwrap())
        .collect();

    let folded = predictions
        .iter()
        .map(|p| {
            let mut probs: Vec<f64> = mapping
                .iter()
                .map(|&m| p.probs.get(m).copied().unwrap_or(0.0))
                .collect();
            let sum: f64 = probs.iter().sum();
            if sum > 0.0 {
                for v in probs.iter_mut() {
                    *v /= sum;
                }
            } else {
                let n = probs.len().max(1);
                probs = vec![1.0 / n as f64; probs.len()];
            }
            Prediction {
                id: p.id.clone(),
                actual: p.actual,
                predicted: crate::eval::argmax(&probs),
                probs,
                slices: p.slices.clone(),
            }
        })
        .collect();
    Ok((folded, extra))
}

/// Why a candidate failed, or that it passed.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GateResult {
    pub passed: bool,
    pub task: String,
    pub model_version: String,
    pub failures: Vec<String>,
    pub warnings: Vec<String>,
    pub accuracy: f64,
    pub macro_f1: f64,
    pub ece: f64,
    pub worst_slice: Option<String>,
    pub worst_slice_accuracy: Option<f64>,
    pub coverage: f64,
    pub compared_to: Option<String>,
}

/// Accuracy of the worst slice large enough to trust.
fn worst_slice_accuracy(report: &EvaluationReport) -> Option<f64> {
    crate::eval::worst_slice(&report.slices).map(|s| s.accuracy)
}

/// Check a report against the suite's thresholds and baseline.
pub fn gate(suite: &BenchmarkSuite, report: &EvaluationReport, coverage: f64) -> GateResult {
    let t = &suite.thresholds;
    let mut failures = Vec::new();
    let mut warnings = Vec::new();

    if report.n_samples < t.min_samples {
        failures.push(format!(
            "the benchmark scored only {} samples, below the {} needed for the result to mean anything; freeze a larger suite",
            report.n_samples, t.min_samples
        ));
    }
    if coverage < t.min_coverage {
        failures.push(format!(
            "benchmark coverage {:.1}% is below the required {:.1}%; the frozen samples are no longer in the dataset",
            coverage * 100.0,
            t.min_coverage * 100.0
        ));
    }
    if report.accuracy < t.min_accuracy {
        failures.push(format!(
            "accuracy {:.4} is below the required {:.4}",
            report.accuracy, t.min_accuracy
        ));
    }
    if report.macro_f1 < t.min_macro_f1 {
        failures.push(format!(
            "macro F1 {:.4} is below the required {:.4}",
            report.macro_f1, t.min_macro_f1
        ));
    }
    if report.calibration.ece > t.max_ece {
        failures.push(format!(
            "calibration error {:.4} exceeds the allowed {:.4}; confidence does not match correctness",
            report.calibration.ece, t.max_ece
        ));
    }

    let worst = crate::eval::worst_slice(&report.slices);
    if let Some(slice) = worst {
        if slice.accuracy < t.min_worst_slice_accuracy {
            failures.push(format!(
                "slice {}={} scores {:.4}, below the required {:.4} ({} samples)",
                slice.dimension, slice.value, slice.accuracy, t.min_worst_slice_accuracy, slice.n
            ));
        }
    } else if !report.slices.is_empty() {
        warnings.push(
            "no slice has enough samples to gate on; slice metrics are indicative only".to_string(),
        );
    }

    if let Some(base) = &suite.baseline {
        let drop = base.accuracy - report.accuracy;
        if drop > t.max_accuracy_drop {
            failures.push(format!(
                "accuracy regressed {:.4} against baseline {} ({:.4} -> {:.4}), more than the allowed {:.4}",
                drop, base.model_version, base.accuracy, report.accuracy, t.max_accuracy_drop
            ));
        }
        let ece_increase = report.calibration.ece - base.ece;
        if ece_increase > t.max_ece_increase {
            failures.push(format!(
                "calibration worsened by {:.4} against baseline {} ({:.4} -> {:.4}), more than the allowed {:.4}",
                ece_increase,
                base.model_version,
                base.ece,
                report.calibration.ece,
                t.max_ece_increase
            ));
        }
        if drop > 0.0 && drop <= t.max_accuracy_drop {
            warnings.push(format!(
                "accuracy is {drop:.4} below the baseline, within tolerance"
            ));
        }
    } else {
        warnings
            .push("no baseline recorded yet; only absolute thresholds were checked".to_string());
    }

    if report.calibration.overconfidence() > 0.05 {
        warnings.push(format!(
            "model is overconfident by {:.4}; temperature {:.3} would cut ECE to {:.4}",
            report.calibration.overconfidence(),
            report.suggested_temperature,
            report.calibration_after_temperature.ece
        ));
    }

    GateResult {
        passed: failures.is_empty(),
        task: suite.task.clone(),
        model_version: report.model_version.clone(),
        failures,
        warnings,
        accuracy: report.accuracy,
        macro_f1: report.macro_f1,
        ece: report.calibration.ece,
        worst_slice: worst.map(|s| format!("{}={}", s.dimension, s.value)),
        worst_slice_accuracy: worst.map(|s| s.accuracy),
        coverage,
        compared_to: suite.baseline.as_ref().map(|b| b.model_version.clone()),
    }
}

impl GateResult {
    pub fn render(&self) -> String {
        let mut out = String::new();
        out.push_str(&format!(
            "\nBenchmark gate: {} ({})\n",
            self.task, self.model_version
        ));
        out.push_str(&"=".repeat(72));
        out.push('\n');
        out.push_str(&format!(
            "accuracy {:.4} | macro F1 {:.4} | ECE {:.4} | coverage {:.1}%\n",
            self.accuracy,
            self.macro_f1,
            self.ece,
            self.coverage * 100.0
        ));
        if let (Some(name), Some(acc)) = (&self.worst_slice, self.worst_slice_accuracy) {
            out.push_str(&format!("worst slice: {name} at {acc:.4}\n"));
        }
        if let Some(base) = &self.compared_to {
            out.push_str(&format!("compared against baseline {base}\n"));
        }
        for w in &self.warnings {
            out.push_str(&format!("  warning: {w}\n"));
        }
        for f in &self.failures {
            out.push_str(&format!("  FAIL: {f}\n"));
        }
        out.push_str(if self.passed {
            "\nPASSED — safe to promote\n"
        } else {
            "\nFAILED — promotion blocked\n"
        });
        out
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::collections::BTreeMap;

    fn labels() -> Vec<String> {
        vec!["healthy".into(), "rust".into()]
    }

    fn suite() -> BenchmarkSuite {
        BenchmarkSuite::create(
            "disease",
            &[
                ("a".to_string(), "healthy".to_string()),
                ("b".to_string(), "rust".to_string()),
            ],
            labels(),
            "snapshot-1",
        )
        .unwrap()
    }

    /// `n` predictions in one crop slice, balanced across both classes, with
    /// the given share correct and the given confidence claimed on each.
    ///
    /// Balanced on purpose: a fixture that only ever predicts one class would
    /// have a poor macro F1 no matter how accurate it looked, and would test
    /// the gate's arithmetic rather than the behaviour under test.
    fn predictions(n: usize, accuracy: f64, confidence: f64) -> Vec<Prediction> {
        let per_class = n / 2;
        let correct_per_class = (accuracy * per_class as f64).round() as usize;
        (0..n)
            .map(|i| {
                let actual = i % 2;
                let is_correct = i / 2 < correct_per_class;
                let predicted = if is_correct { actual } else { 1 - actual };
                let mut probs = vec![1.0 - confidence; 2];
                probs[predicted] = confidence;
                let mut slices = BTreeMap::new();
                slices.insert("crop".to_string(), "wheat".to_string());
                Prediction {
                    id: format!("s{i}"),
                    actual,
                    predicted,
                    probs,
                    slices,
                }
            })
            .collect()
    }

    fn report_at(accuracy: f64, confidence: f64) -> EvaluationReport {
        EvaluationReport::build(
            "disease",
            "candidate-v2",
            &predictions(100, accuracy, confidence),
            &labels(),
        )
    }

    #[test]
    fn creating_a_suite_pins_ids_and_labels() {
        let s = suite();
        assert_eq!(s.task, "disease");
        assert_eq!(s.samples.len(), 2);
        assert_eq!(
            s.samples[0],
            BenchmarkSample {
                id: "a".into(),
                label: "healthy".into()
            }
        );
        assert_eq!(s.label_index("rust"), Some(1));
        assert_eq!(s.label_index("blight"), None);
        assert!(s.baseline.is_none());
        assert_eq!(s.source_snapshot, "snapshot-1");
    }

    #[test]
    fn a_suite_refuses_empty_or_inconsistent_input() {
        assert!(BenchmarkSuite::create("disease", &[], labels(), "s").is_err());

        let err =
            BenchmarkSuite::create("disease", &[("a".into(), "blight".into())], labels(), "s")
                .unwrap_err()
                .to_string();
        assert!(err.contains("blight"), "{err}");
    }

    #[test]
    fn suites_round_trip_through_disk() {
        let dir = tempfile::tempdir().unwrap();
        let path = dir.path().join("nested/disease.json");
        let mut s = suite();
        s.thresholds.min_accuracy = 0.9;
        s.baseline = Some(Baseline {
            model_version: "v1".into(),
            recorded_at: "2026-01-01T00:00:00Z".into(),
            accuracy: 0.9,
            macro_f1: 0.88,
            ece: 0.04,
            worst_slice_accuracy: 0.85,
        });
        s.save(&path).unwrap();

        let back = BenchmarkSuite::load(&path).unwrap();
        assert_eq!(back.samples, s.samples);
        assert_eq!(back.labels, s.labels);
        assert!((back.thresholds.min_accuracy - 0.9).abs() < 1e-12);
        assert_eq!(back.baseline.unwrap().model_version, "v1");
    }

    #[test]
    fn loading_rejects_unusable_files() {
        let dir = tempfile::tempdir().unwrap();
        let path = dir.path().join("b.json");

        assert!(BenchmarkSuite::load(&path)
            .unwrap_err()
            .to_string()
            .contains("cannot read"));

        std::fs::write(&path, "{ not json").unwrap();
        assert!(BenchmarkSuite::load(&path)
            .unwrap_err()
            .to_string()
            .contains("malformed"));

        std::fs::write(
            &path,
            r#"{"task":"d","created_at":"","labels":["a"],"samples":[]}"#,
        )
        .unwrap();
        assert!(BenchmarkSuite::load(&path)
            .unwrap_err()
            .to_string()
            .contains("pins no samples"));
    }

    #[test]
    fn resolve_reports_missing_pinned_samples() {
        let s = suite();
        let available = vec!["a".to_string(), "c".to_string()];
        let coverage = s.resolve(&available, |x| x.as_str());

        assert_eq!(coverage.pinned, 2);
        assert_eq!(coverage.found.len(), 1);
        assert_eq!(coverage.found[0].0.id, "a");
        assert_eq!(coverage.missing, vec!["b".to_string()]);
        assert!((coverage.ratio() - 0.5).abs() < 1e-12);

        // Everything present is full coverage.
        let all = vec!["a".to_string(), "b".to_string()];
        assert!((s.resolve(&all, |x| x.as_str()).ratio() - 1.0).abs() < 1e-12);
    }

    #[test]
    fn folding_reorders_probabilities_by_label_name() {
        // The model learned the classes in the opposite order.
        let model_labels = vec!["rust".to_string(), "healthy".to_string()];
        let preds = vec![Prediction {
            id: "a".into(),
            actual: 0,
            predicted: 0,
            probs: vec![0.8, 0.2], // 80% rust
            slices: BTreeMap::new(),
        }];

        let (folded, extra) = fold_into_label_space(&preds, &model_labels, &labels()).unwrap();
        assert!(extra.is_empty());
        // In suite order (healthy, rust) that is 20% healthy, 80% rust.
        assert!((folded[0].probs[0] - 0.2).abs() < 1e-12);
        assert!((folded[0].probs[1] - 0.8).abs() < 1e-12);
        assert_eq!(folded[0].predicted, 1, "rust is index 1 in suite order");
    }

    #[test]
    fn folding_drops_and_reports_classes_the_benchmark_cannot_score() {
        let model_labels = vec![
            "healthy".to_string(),
            "rust".to_string(),
            "blight".to_string(),
        ];
        let preds = vec![Prediction {
            id: "a".into(),
            actual: 0,
            predicted: 2,
            probs: vec![0.2, 0.3, 0.5],
            slices: BTreeMap::new(),
        }];

        let (folded, extra) = fold_into_label_space(&preds, &model_labels, &labels()).unwrap();
        assert_eq!(extra, vec!["blight".to_string()]);
        // The remaining mass is renormalised, so 0.2:0.3 becomes 0.4:0.6.
        assert!((folded[0].probs[0] - 0.4).abs() < 1e-12);
        assert!((folded[0].probs[1] - 0.6).abs() < 1e-12);
        assert!((folded[0].probs.iter().sum::<f64>() - 1.0).abs() < 1e-12);
        assert_eq!(folded[0].predicted, 1);
    }

    #[test]
    fn folding_fails_when_the_model_cannot_predict_a_benchmark_class() {
        let model_labels = vec!["healthy".to_string()];
        let err = fold_into_label_space(&[], &model_labels, &labels())
            .unwrap_err()
            .to_string();
        assert!(err.contains("rust"), "{err}");
    }

    #[test]
    fn a_good_model_passes_every_gate() {
        let mut s = suite();
        s.thresholds.min_worst_slice_accuracy = 0.8;
        // 90% accurate and claiming 90%: well calibrated.
        let report = report_at(0.9, 0.9);

        let result = gate(&s, &report, 1.0);
        assert!(result.passed, "{:?}", result.failures);
        assert!((result.accuracy - 0.9).abs() < 1e-9);
        assert_eq!(result.worst_slice.as_deref(), Some("crop=wheat"));
        // Without a baseline the gate says so rather than passing silently.
        assert!(result.warnings.iter().any(|w| w.contains("no baseline")));
        assert!(result.render().contains("PASSED"));
    }

    #[test]
    fn low_accuracy_and_bad_calibration_both_block_promotion() {
        let s = suite();
        // 55% accurate while claiming 95% confidence.
        let report = report_at(0.55, 0.95);

        let result = gate(&s, &report, 1.0);
        assert!(!result.passed);
        assert!(
            result.failures.iter().any(|f| f.contains("accuracy")),
            "{:?}",
            result.failures
        );
        assert!(result
            .failures
            .iter()
            .any(|f| f.contains("calibration error")));
        assert!(result.render().contains("FAILED"));
        // The overconfidence warning names the fix.
        assert!(result.warnings.iter().any(|w| w.contains("temperature")));
    }

    #[test]
    fn a_regression_against_the_baseline_blocks_promotion() {
        let mut s = suite();
        s.thresholds.min_accuracy = 0.5;
        s.thresholds.min_macro_f1 = 0.3;
        s.thresholds.max_ece = 1.0;
        s.thresholds.min_worst_slice_accuracy = 0.0;
        s.thresholds.max_accuracy_drop = 0.03;
        s.baseline = Some(Baseline {
            model_version: "live-v1".into(),
            recorded_at: "2026-01-01T00:00:00Z".into(),
            accuracy: 0.90,
            macro_f1: 0.88,
            ece: 0.05,
            worst_slice_accuracy: 0.85,
        });

        // Clears every absolute bar but is 8 points worse than what is live.
        let report = report_at(0.82, 0.82);
        let result = gate(&s, &report, 1.0);
        assert!(!result.passed);
        let msg = result.failures.join(" ");
        assert!(msg.contains("regressed"), "{msg}");
        assert!(msg.contains("live-v1"), "{msg}");
        assert_eq!(result.compared_to.as_deref(), Some("live-v1"));

        // A drop inside the tolerance passes, with a warning.
        let ok = gate(&s, &report_at(0.88, 0.88), 1.0);
        assert!(ok.passed, "{:?}", ok.failures);
        assert!(ok.warnings.iter().any(|w| w.contains("within tolerance")));
    }

    #[test]
    fn a_worse_calibrated_model_is_blocked_even_at_equal_accuracy() {
        let mut s = suite();
        s.thresholds.min_accuracy = 0.5;
        s.thresholds.min_macro_f1 = 0.3;
        s.thresholds.max_ece = 1.0;
        s.thresholds.min_worst_slice_accuracy = 0.0;
        s.baseline = Some(Baseline {
            model_version: "live-v1".into(),
            recorded_at: "2026-01-01T00:00:00Z".into(),
            accuracy: 0.80,
            macro_f1: 0.78,
            ece: 0.02,
            worst_slice_accuracy: 0.75,
        });

        // Same accuracy, but now claiming 99% on every call.
        let result = gate(&s, &report_at(0.80, 0.99), 1.0);
        assert!(!result.passed);
        assert!(
            result
                .failures
                .iter()
                .any(|f| f.contains("calibration worsened")),
            "{:?}",
            result.failures
        );
    }

    #[test]
    fn missing_benchmark_samples_block_promotion() {
        let s = suite();
        let result = gate(&s, &report_at(0.95, 0.95), 0.5);
        assert!(!result.passed);
        assert!(
            result.failures.iter().any(|f| f.contains("coverage")),
            "{:?}",
            result.failures
        );
    }

    #[test]
    fn a_failing_slice_blocks_an_otherwise_good_model() {
        let mut s = suite();
        s.thresholds.min_worst_slice_accuracy = 0.7;
        s.thresholds.min_samples = 90;

        // Wheat is perfect, rice is hopeless; the average clears every bar.
        let mut preds = Vec::new();
        for i in 0..60 {
            let mut slices = BTreeMap::new();
            slices.insert("crop".to_string(), "wheat".to_string());
            preds.push(Prediction {
                id: format!("w{i}"),
                actual: 0,
                predicted: 0,
                probs: vec![0.9, 0.1],
                slices,
            });
        }
        for i in 0..30 {
            let mut slices = BTreeMap::new();
            slices.insert("crop".to_string(), "rice".to_string());
            preds.push(Prediction {
                id: format!("r{i}"),
                actual: 1,
                predicted: 0,
                probs: vec![0.9, 0.1],
                slices,
            });
        }
        let report = EvaluationReport::build("disease", "v2", &preds, &labels());
        assert!(report.accuracy > 0.6);

        let result = gate(&s, &report, 1.0);
        assert!(!result.passed);
        assert!(
            result.failures.iter().any(|f| f.contains("crop=rice")),
            "{:?}",
            result.failures
        );
        assert_eq!(result.worst_slice.as_deref(), Some("crop=rice"));
    }

    #[test]
    fn a_benchmark_too_small_to_decide_anything_blocks_promotion() {
        let mut s = suite();
        // A perfect model, but measured on far too few samples.
        let report = EvaluationReport::build(
            "disease",
            "candidate-v2",
            &predictions(10, 1.0, 0.9),
            &labels(),
        );
        let result = gate(&s, &report, 1.0);
        assert!(!result.passed);
        assert!(
            result
                .failures
                .iter()
                .any(|f| f.contains("only 10 samples")),
            "{:?}",
            result.failures
        );

        // A suite that deliberately lowers the bar is allowed to.
        s.thresholds.min_samples = 10;
        assert!(gate(&s, &report, 1.0).passed);
    }

    #[test]
    fn baselines_are_taken_from_a_report() {
        let report = report_at(0.9, 0.9);
        let base = Baseline::from_report(&report);
        assert_eq!(base.model_version, "candidate-v2");
        assert!((base.accuracy - 0.9).abs() < 1e-9);
        assert!((base.ece - report.calibration.ece).abs() < 1e-12);
        assert!(!base.recorded_at.is_empty());
    }
}
