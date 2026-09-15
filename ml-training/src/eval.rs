//! Model evaluation: confusion matrix, calibration, and sliced metrics.
//!
//! Accuracy alone hides the failures that matter in the field. A disease model
//! at 92% overall can still be useless on rice, or on photos from one label
//! source, or at the confidence thresholds the app uses to decide whether to
//! show a result at all. This module answers three questions that accuracy
//! cannot:
//!
//! * **What does it confuse?** A confusion matrix, with the worst pairs called
//!   out — confusing two rusts is a different problem from calling blight
//!   healthy.
//! * **Can the confidence be trusted?** Reliability bins, expected and maximum
//!   calibration error, Brier score, and negative log-likelihood. A model that
//!   says 90% and is right 60% of the time will drive bad spray decisions even
//!   at a respectable accuracy. [`fit_temperature`] then fits the single
//!   parameter that usually fixes it.
//! * **Who does it fail for?** The same metrics sliced by crop, label source,
//!   region, and season, so a subgroup that the average hides shows up.
//!
//! Everything here operates on [`Prediction`] values, so the maths is testable
//! without a model, a backend, or an image on disk.

use std::collections::{BTreeMap, BTreeSet};

use serde::{Deserialize, Serialize};

/// Default number of equal-width confidence bins for reliability.
pub const DEFAULT_BINS: usize = 10;

/// A slice with fewer samples than this is reported but not gated on: metrics
/// over a handful of images are noise.
pub const MIN_SLICE_SAMPLES: usize = 20;

/// Probabilities below this are clamped before taking logs.
const EPS: f64 = 1e-12;

/// One model prediction, with the metadata needed to slice it.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Prediction {
    pub id: String,
    pub actual: usize,
    pub predicted: usize,
    /// Class probabilities, summing to 1.
    pub probs: Vec<f64>,
    /// Slice dimension → value, e.g. `crop` → `wheat`.
    #[serde(default)]
    pub slices: BTreeMap<String, String>,
}

impl Prediction {
    /// Probability assigned to the predicted class.
    pub fn confidence(&self) -> f64 {
        self.probs.get(self.predicted).copied().unwrap_or(0.0)
    }

    /// Probability assigned to the true class.
    pub fn true_probability(&self) -> f64 {
        self.probs.get(self.actual).copied().unwrap_or(0.0)
    }

    pub fn correct(&self) -> bool {
        self.predicted == self.actual
    }
}

/// Turn logits into probabilities, shifting by the maximum for stability.
pub fn softmax(logits: &[f32]) -> Vec<f64> {
    let widened: Vec<f64> = logits.iter().map(|&l| l as f64).collect();
    softmax_f64(&widened)
}

/// Softmax over f64 logits. Temperature fitting stays in double precision
/// because the NLL differences between nearby temperatures are small enough
/// that an f32 round trip would swamp them.
pub fn softmax_f64(logits: &[f64]) -> Vec<f64> {
    let max = logits.iter().fold(f64::NEG_INFINITY, |a, &b| a.max(b));
    let uniform = || {
        let n = logits.len().max(1);
        vec![1.0 / n as f64; logits.len()]
    };
    if !max.is_finite() {
        // An all-NaN or all-infinite row carries no information; spread the
        // mass evenly rather than emitting NaNs that poison every metric.
        return uniform();
    }
    let exps: Vec<f64> = logits
        .iter()
        .map(|&l| (l - max).exp())
        .map(|v| if v.is_finite() { v } else { 0.0 })
        .collect();
    let sum: f64 = exps.iter().sum();
    if sum <= 0.0 {
        return uniform();
    }
    exps.into_iter().map(|e| e / sum).collect()
}

/// Rescale probabilities by a temperature, exactly as dividing the original
/// logits by it: softmax is shift-invariant, so `ln(p)` differs from the
/// logits only by a constant softmax discards.
fn rescale(probs: &[f64], t: f64) -> Vec<f64> {
    let scaled: Vec<f64> = probs.iter().map(|&v| v.max(EPS).ln() / t).collect();
    softmax_f64(&scaled)
}

/// Index of the largest value, ties going to the lower index.
pub fn argmax(values: &[f64]) -> usize {
    values
        .iter()
        .enumerate()
        .fold((0usize, f64::NEG_INFINITY), |best, (i, &v)| {
            if v > best.1 {
                (i, v)
            } else {
                best
            }
        })
        .0
}

// ── Confusion matrix ─────────────────────────────────────────────────────────

/// Precision, recall and F1 for one class.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ClassMetrics {
    pub label: String,
    pub precision: f64,
    pub recall: f64,
    pub f1: f64,
    /// True instances of this class.
    pub support: usize,
}

/// Counts of actual vs predicted classes.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ConfusionMatrix {
    pub labels: Vec<String>,
    /// `counts[actual][predicted]`.
    pub counts: Vec<Vec<usize>>,
}

impl ConfusionMatrix {
    pub fn build(predictions: &[Prediction], labels: &[String]) -> Self {
        let n = labels.len();
        let mut counts = vec![vec![0usize; n]; n];
        for p in predictions {
            if p.actual < n && p.predicted < n {
                counts[p.actual][p.predicted] += 1;
            }
        }
        Self {
            labels: labels.to_vec(),
            counts,
        }
    }

    pub fn total(&self) -> usize {
        self.counts.iter().flatten().sum()
    }

    pub fn correct(&self) -> usize {
        (0..self.labels.len()).map(|i| self.counts[i][i]).sum()
    }

    pub fn accuracy(&self) -> f64 {
        let total = self.total();
        if total == 0 {
            return 0.0;
        }
        self.correct() as f64 / total as f64
    }

    /// Mean per-class recall. Unlike accuracy this does not flatter a model
    /// that only gets the majority class right.
    pub fn balanced_accuracy(&self) -> f64 {
        let recalls: Vec<f64> = (0..self.labels.len())
            .filter(|&i| self.support(i) > 0)
            .map(|i| self.counts[i][i] as f64 / self.support(i) as f64)
            .collect();
        mean(&recalls)
    }

    fn support(&self, class: usize) -> usize {
        self.counts[class].iter().sum()
    }

    fn predicted_count(&self, class: usize) -> usize {
        self.counts.iter().map(|row| row[class]).sum()
    }

    pub fn per_class(&self) -> Vec<ClassMetrics> {
        (0..self.labels.len())
            .map(|i| {
                let tp = self.counts[i][i] as f64;
                let support = self.support(i);
                let predicted = self.predicted_count(i);
                let precision = if predicted > 0 {
                    tp / predicted as f64
                } else {
                    0.0
                };
                let recall = if support > 0 {
                    tp / support as f64
                } else {
                    0.0
                };
                let f1 = if precision + recall > 0.0 {
                    2.0 * precision * recall / (precision + recall)
                } else {
                    0.0
                };
                ClassMetrics {
                    label: self.labels[i].clone(),
                    precision,
                    recall,
                    f1,
                    support,
                }
            })
            .collect()
    }

    /// Unweighted mean F1 over classes that actually appear.
    pub fn macro_f1(&self) -> f64 {
        let f1s: Vec<f64> = self
            .per_class()
            .into_iter()
            .filter(|m| m.support > 0)
            .map(|m| m.f1)
            .collect();
        mean(&f1s)
    }

    /// Support-weighted mean F1.
    pub fn weighted_f1(&self) -> f64 {
        let total = self.total();
        if total == 0 {
            return 0.0;
        }
        self.per_class()
            .into_iter()
            .map(|m| m.f1 * m.support as f64)
            .sum::<f64>()
            / total as f64
    }

    /// The `n` most frequent (actual, predicted) mistakes, worst first.
    pub fn top_confusions(&self, n: usize) -> Vec<Confusion> {
        let mut out: Vec<Confusion> = Vec::new();
        for (a, row) in self.counts.iter().enumerate() {
            for (p, &count) in row.iter().enumerate() {
                if a != p && count > 0 {
                    let support = self.support(a);
                    out.push(Confusion {
                        actual: self.labels[a].clone(),
                        predicted: self.labels[p].clone(),
                        count,
                        rate: if support > 0 {
                            count as f64 / support as f64
                        } else {
                            0.0
                        },
                    });
                }
            }
        }
        out.sort_by(|x, y| y.count.cmp(&x.count).then(x.actual.cmp(&y.actual)));
        out.truncate(n);
        out
    }

    /// Text rendering, truncating long labels to keep columns aligned.
    pub fn render(&self) -> String {
        let n = self.labels.len();
        let short: Vec<String> = self
            .labels
            .iter()
            .map(|l| l.chars().take(12).collect())
            .collect();
        let width = short.iter().map(String::len).max().unwrap_or(6).max(6);

        let mut out = String::new();
        out.push_str(&format!("{:<width$} ", "actual\\pred", width = width));
        for s in &short {
            out.push_str(&format!("{s:>8}"));
        }
        out.push_str(&format!("{:>8}\n", "total"));

        for i in 0..n {
            out.push_str(&format!("{:<width$} ", short[i], width = width));
            for j in 0..n {
                out.push_str(&format!("{:>8}", self.counts[i][j]));
            }
            out.push_str(&format!("{:>8}\n", self.support(i)));
        }
        out
    }
}

/// One frequent mistake.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Confusion {
    pub actual: String,
    pub predicted: String,
    pub count: usize,
    /// Share of this class's true instances that landed here.
    pub rate: f64,
}

// ── Calibration ──────────────────────────────────────────────────────────────

/// One confidence bucket of the reliability curve.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CalibrationBin {
    pub lower: f64,
    pub upper: f64,
    pub count: usize,
    /// Mean predicted confidence in this bucket.
    pub mean_confidence: f64,
    /// Share actually correct in this bucket.
    pub accuracy: f64,
}

impl CalibrationBin {
    /// Positive when the model is overconfident in this bucket.
    pub fn gap(&self) -> f64 {
        self.mean_confidence - self.accuracy
    }
}

/// How well confidence tracks correctness.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Calibration {
    pub bins: Vec<CalibrationBin>,
    /// Expected calibration error: sample-weighted mean |confidence − accuracy|.
    pub ece: f64,
    /// Worst bucket gap, over buckets holding at least one sample.
    pub mce: f64,
    /// Multiclass Brier score; lower is better.
    pub brier: f64,
    /// Mean negative log-likelihood of the true class.
    pub nll: f64,
    pub avg_confidence: f64,
    pub accuracy: f64,
    pub n: usize,
}

impl Calibration {
    /// Positive when the model claims more confidence than it earns.
    pub fn overconfidence(&self) -> f64 {
        self.avg_confidence - self.accuracy
    }
}

/// Compute reliability bins and calibration error.
pub fn calibrate(predictions: &[Prediction], n_bins: usize) -> Calibration {
    let n_bins = n_bins.max(1);
    let n = predictions.len();
    let mut bins: Vec<CalibrationBin> = (0..n_bins)
        .map(|i| CalibrationBin {
            lower: i as f64 / n_bins as f64,
            upper: (i + 1) as f64 / n_bins as f64,
            count: 0,
            mean_confidence: 0.0,
            accuracy: 0.0,
        })
        .collect();

    let mut conf_sum = vec![0.0f64; n_bins];
    let mut correct_sum = vec![0usize; n_bins];
    let mut brier = 0.0f64;
    let mut nll = 0.0f64;
    let mut total_conf = 0.0f64;
    let mut total_correct = 0usize;

    for p in predictions {
        let conf = p.confidence();
        // The top bucket is closed at 1.0 so a perfectly confident prediction
        // does not fall off the end.
        let idx = ((conf * n_bins as f64).floor() as usize).min(n_bins - 1);
        bins[idx].count += 1;
        conf_sum[idx] += conf;
        if p.correct() {
            correct_sum[idx] += 1;
            total_correct += 1;
        }
        total_conf += conf;

        for (k, &prob) in p.probs.iter().enumerate() {
            let target = if k == p.actual { 1.0 } else { 0.0 };
            brier += (prob - target).powi(2);
        }
        nll -= p.true_probability().max(EPS).ln();
    }

    for i in 0..n_bins {
        if bins[i].count > 0 {
            bins[i].mean_confidence = conf_sum[i] / bins[i].count as f64;
            bins[i].accuracy = correct_sum[i] as f64 / bins[i].count as f64;
        }
    }

    let (ece, mce) = if n == 0 {
        (0.0, 0.0)
    } else {
        let ece = bins
            .iter()
            .filter(|b| b.count > 0)
            .map(|b| (b.count as f64 / n as f64) * b.gap().abs())
            .sum();
        let mce = bins
            .iter()
            .filter(|b| b.count > 0)
            .map(|b| b.gap().abs())
            .fold(0.0f64, f64::max);
        (ece, mce)
    };

    Calibration {
        bins,
        ece,
        mce,
        brier: if n > 0 { brier / n as f64 } else { 0.0 },
        nll: if n > 0 { nll / n as f64 } else { 0.0 },
        avg_confidence: if n > 0 { total_conf / n as f64 } else { 0.0 },
        accuracy: if n > 0 {
            total_correct as f64 / n as f64
        } else {
            0.0
        },
        n,
    }
}

/// Mean negative log-likelihood after dividing the logits by `t`.
fn nll_at_temperature(predictions: &[Prediction], t: f64) -> f64 {
    if predictions.is_empty() {
        return 0.0;
    }
    let mut total = 0.0;
    for p in predictions {
        let probs = rescale(&p.probs, t);
        total -= probs.get(p.actual).copied().unwrap_or(0.0).max(EPS).ln();
    }
    total / predictions.len() as f64
}

/// Fit the single temperature that minimises negative log-likelihood.
///
/// Temperature scaling is the standard fix for the overconfidence that
/// cross-entropy training produces: dividing the logits by one learned scalar
/// leaves every prediction's ranking — and therefore accuracy — untouched
/// while bringing confidence back in line with correctness. Fit it on
/// validation data, never on test.
pub fn fit_temperature(predictions: &[Prediction]) -> f64 {
    if predictions.len() < 2 {
        return 1.0;
    }
    // NLL in temperature is unimodal, so a coarse scan followed by golden
    // section on the bracketing interval is both robust and quick.
    let (mut lo, mut hi) = (0.05f64, 10.0f64);
    let mut best = (1.0f64, nll_at_temperature(predictions, 1.0));
    let steps = 40;
    for i in 0..=steps {
        let t = lo + (hi - lo) * i as f64 / steps as f64;
        let nll = nll_at_temperature(predictions, t);
        if nll < best.1 {
            best = (t, nll);
        }
    }
    let span = (hi - lo) / steps as f64;
    lo = (best.0 - span).max(0.05);
    hi = (best.0 + span).min(10.0);

    let phi = (5.0f64.sqrt() - 1.0) / 2.0;
    let (mut a, mut b) = (lo, hi);
    let mut c = b - phi * (b - a);
    let mut d = a + phi * (b - a);
    let (mut fc, mut fd) = (
        nll_at_temperature(predictions, c),
        nll_at_temperature(predictions, d),
    );
    for _ in 0..60 {
        if (b - a).abs() < 1e-4 {
            break;
        }
        if fc < fd {
            b = d;
            d = c;
            fd = fc;
            c = b - phi * (b - a);
            fc = nll_at_temperature(predictions, c);
        } else {
            a = c;
            c = d;
            fc = fd;
            d = a + phi * (b - a);
            fd = nll_at_temperature(predictions, d);
        }
    }
    let t = (a + b) / 2.0;
    if nll_at_temperature(predictions, t) <= best.1 {
        t
    } else {
        best.0
    }
}

/// Apply a fitted temperature, returning rescaled predictions.
pub fn apply_temperature(predictions: &[Prediction], t: f64) -> Vec<Prediction> {
    let t = if t > 0.0 { t } else { 1.0 };
    predictions
        .iter()
        .map(|p| {
            let probs = rescale(&p.probs, t);
            Prediction {
                id: p.id.clone(),
                actual: p.actual,
                // Scaling by a positive constant cannot reorder classes, so the
                // prediction is carried over rather than recomputed.
                predicted: p.predicted,
                probs,
                slices: p.slices.clone(),
            }
        })
        .collect()
}

// ── Slicing ──────────────────────────────────────────────────────────────────

/// Metrics for one subgroup, e.g. `crop = rice`.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SliceMetrics {
    pub dimension: String,
    pub value: String,
    pub n: usize,
    pub accuracy: f64,
    pub macro_f1: f64,
    pub ece: f64,
    pub avg_confidence: f64,
    /// False when the slice is too small for its metrics to mean much.
    pub reliable: bool,
}

/// Every slice value seen, worst accuracy first within each dimension.
pub fn slice_metrics(
    predictions: &[Prediction],
    labels: &[String],
    min_samples: usize,
) -> Vec<SliceMetrics> {
    let dimensions: BTreeSet<&str> = predictions
        .iter()
        .flat_map(|p| p.slices.keys().map(String::as_str))
        .collect();

    let mut out = Vec::new();
    for dim in dimensions {
        let mut by_value: BTreeMap<&str, Vec<Prediction>> = BTreeMap::new();
        for p in predictions {
            if let Some(value) = p.slices.get(dim) {
                if !value.is_empty() {
                    by_value.entry(value.as_str()).or_default().push(p.clone());
                }
            }
        }
        let mut group: Vec<SliceMetrics> = by_value
            .into_iter()
            .map(|(value, preds)| {
                let cm = ConfusionMatrix::build(&preds, labels);
                let cal = calibrate(&preds, DEFAULT_BINS);
                SliceMetrics {
                    dimension: dim.to_string(),
                    value: value.to_string(),
                    n: preds.len(),
                    accuracy: cm.accuracy(),
                    macro_f1: cm.macro_f1(),
                    ece: cal.ece,
                    avg_confidence: cal.avg_confidence,
                    reliable: preds.len() >= min_samples,
                }
            })
            .collect();
        group.sort_by(|a, b| {
            a.accuracy
                .partial_cmp(&b.accuracy)
                .unwrap_or(std::cmp::Ordering::Equal)
                .then(a.value.cmp(&b.value))
        });
        out.extend(group);
    }
    out
}

/// The worst reliable slice, which is what a promotion gate should look at.
pub fn worst_slice(slices: &[SliceMetrics]) -> Option<&SliceMetrics> {
    slices.iter().filter(|s| s.reliable).min_by(|a, b| {
        a.accuracy
            .partial_cmp(&b.accuracy)
            .unwrap_or(std::cmp::Ordering::Equal)
    })
}

// ── Full report ──────────────────────────────────────────────────────────────

/// Everything an evaluation run produces.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EvaluationReport {
    pub task: String,
    pub model_version: String,
    pub n_samples: usize,
    pub accuracy: f64,
    pub balanced_accuracy: f64,
    pub macro_f1: f64,
    pub weighted_f1: f64,
    pub per_class: Vec<ClassMetrics>,
    pub confusion: ConfusionMatrix,
    pub top_confusions: Vec<Confusion>,
    pub calibration: Calibration,
    /// Temperature that minimises NLL on these predictions, and the
    /// calibration that results from applying it.
    pub suggested_temperature: f64,
    pub calibration_after_temperature: Calibration,
    pub slices: Vec<SliceMetrics>,
}

impl EvaluationReport {
    pub fn build(
        task: &str,
        model_version: &str,
        predictions: &[Prediction],
        labels: &[String],
    ) -> Self {
        let confusion = ConfusionMatrix::build(predictions, labels);
        let calibration = calibrate(predictions, DEFAULT_BINS);
        let temperature = fit_temperature(predictions);
        let after = calibrate(&apply_temperature(predictions, temperature), DEFAULT_BINS);
        Self {
            task: task.to_string(),
            model_version: model_version.to_string(),
            n_samples: predictions.len(),
            accuracy: confusion.accuracy(),
            balanced_accuracy: confusion.balanced_accuracy(),
            macro_f1: confusion.macro_f1(),
            weighted_f1: confusion.weighted_f1(),
            per_class: confusion.per_class(),
            top_confusions: confusion.top_confusions(5),
            confusion,
            calibration,
            suggested_temperature: temperature,
            calibration_after_temperature: after,
            slices: slice_metrics(predictions, labels, MIN_SLICE_SAMPLES),
        }
    }

    /// Human-readable summary for the terminal.
    pub fn render(&self) -> String {
        let mut out = String::new();
        out.push_str(&format!(
            "\nEvaluation: {} ({} samples, model {})\n",
            self.task, self.n_samples, self.model_version
        ));
        out.push_str(&"=".repeat(72));
        out.push('\n');
        out.push_str(&format!(
            "accuracy {:.4} | balanced {:.4} | macro F1 {:.4} | weighted F1 {:.4}\n",
            self.accuracy, self.balanced_accuracy, self.macro_f1, self.weighted_f1
        ));

        out.push_str(&format!(
            "\n{:<30} {:>10} {:>10} {:>10} {:>10}\n",
            "Class", "Precision", "Recall", "F1", "Support"
        ));
        out.push_str(&"-".repeat(72));
        out.push('\n');
        for m in &self.per_class {
            out.push_str(&format!(
                "{:<30} {:>10.4} {:>10.4} {:>10.4} {:>10}\n",
                m.label, m.precision, m.recall, m.f1, m.support
            ));
        }

        out.push_str("\nConfusion matrix\n");
        out.push_str(&self.confusion.render());

        if !self.top_confusions.is_empty() {
            out.push_str("\nMost frequent mistakes\n");
            for c in &self.top_confusions {
                out.push_str(&format!(
                    "  {:<20} -> {:<20} {:>5}  ({:.1}% of its class)\n",
                    c.actual,
                    c.predicted,
                    c.count,
                    c.rate * 100.0
                ));
            }
        }

        let cal = &self.calibration;
        out.push_str(&format!(
            "\nCalibration: ECE {:.4} | MCE {:.4} | Brier {:.4} | NLL {:.4}\n",
            cal.ece, cal.mce, cal.brier, cal.nll
        ));
        out.push_str(&format!(
            "  mean confidence {:.4} vs accuracy {:.4} ({} by {:.4})\n",
            cal.avg_confidence,
            cal.accuracy,
            if cal.overconfidence() >= 0.0 {
                "overconfident"
            } else {
                "underconfident"
            },
            cal.overconfidence().abs()
        ));
        out.push_str(&format!(
            "  temperature {:.3} would move ECE to {:.4}\n",
            self.suggested_temperature, self.calibration_after_temperature.ece
        ));
        out.push_str(&format!(
            "\n  {:>12} {:>8} {:>12} {:>10} {:>8}\n",
            "confidence", "count", "avg conf", "accuracy", "gap"
        ));
        for b in cal.bins.iter().filter(|b| b.count > 0) {
            out.push_str(&format!(
                "  {:>5.2}-{:<6.2} {:>8} {:>12.4} {:>10.4} {:>+8.4}\n",
                b.lower,
                b.upper,
                b.count,
                b.mean_confidence,
                b.accuracy,
                b.gap()
            ));
        }

        if !self.slices.is_empty() {
            out.push_str(&format!(
                "\n{:<16} {:<22} {:>7} {:>10} {:>10} {:>8}\n",
                "Dimension", "Value", "N", "Accuracy", "Macro F1", "ECE"
            ));
            out.push_str(&"-".repeat(78));
            out.push('\n');
            for s in &self.slices {
                out.push_str(&format!(
                    "{:<16} {:<22} {:>7} {:>10.4} {:>10.4} {:>8.4}{}\n",
                    s.dimension,
                    s.value.chars().take(22).collect::<String>(),
                    s.n,
                    s.accuracy,
                    s.macro_f1,
                    s.ece,
                    if s.reliable { "" } else { "  (small)" }
                ));
            }
            if let Some(worst) = worst_slice(&self.slices) {
                out.push_str(&format!(
                    "\n  worst reliable slice: {}={} at {:.4} accuracy ({} samples)\n",
                    worst.dimension, worst.value, worst.accuracy, worst.n
                ));
            }
        }
        out
    }
}

fn mean(values: &[f64]) -> f64 {
    if values.is_empty() {
        0.0
    } else {
        values.iter().sum::<f64>() / values.len() as f64
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn labels(n: usize) -> Vec<String> {
        (0..n).map(|i| format!("c{i}")).collect()
    }

    fn pred(actual: usize, probs: &[f64]) -> Prediction {
        Prediction {
            id: format!("s{actual}-{}", probs.len()),
            actual,
            predicted: argmax(probs),
            probs: probs.to_vec(),
            slices: BTreeMap::new(),
        }
    }

    fn sliced(actual: usize, probs: &[f64], dim: &str, value: &str) -> Prediction {
        let mut p = pred(actual, probs);
        p.slices.insert(dim.to_string(), value.to_string());
        p
    }

    #[test]
    fn softmax_is_stable_and_normalised() {
        let p = softmax(&[1.0, 2.0, 3.0]);
        assert!((p.iter().sum::<f64>() - 1.0).abs() < 1e-12);
        assert!(p[2] > p[1] && p[1] > p[0]);

        // Large logits must not overflow to NaN.
        let big = softmax(&[1000.0, 1001.0]);
        assert!((big.iter().sum::<f64>() - 1.0).abs() < 1e-12);
        assert!(big[1] > big[0]);

        // Shifting every logit leaves the distribution unchanged.
        let a = softmax(&[0.5, -1.0, 2.0]);
        let b = softmax(&[10.5, 9.0, 12.0]);
        for (x, y) in a.iter().zip(&b) {
            assert!((x - y).abs() < 1e-9);
        }

        // Degenerate rows spread mass rather than emitting NaN.
        let nan = softmax(&[f32::NAN, f32::NAN]);
        assert!(nan.iter().all(|v| (v - 0.5).abs() < 1e-12));
    }

    #[test]
    fn confusion_matrix_counts_and_metrics() {
        // Two classes: c0 perfect, c1 missed half the time.
        let preds = vec![
            pred(0, &[0.9, 0.1]),
            pred(0, &[0.8, 0.2]),
            pred(1, &[0.4, 0.6]),
            pred(1, &[0.7, 0.3]),
        ];
        let cm = ConfusionMatrix::build(&preds, &labels(2));

        assert_eq!(cm.counts, vec![vec![2, 0], vec![1, 1]]);
        assert_eq!(cm.total(), 4);
        assert_eq!(cm.correct(), 3);
        assert!((cm.accuracy() - 0.75).abs() < 1e-12);
        // Recall is 1.0 for c0 and 0.5 for c1.
        assert!((cm.balanced_accuracy() - 0.75).abs() < 1e-12);

        let per = cm.per_class();
        // c0: 2 of 3 predictions correct, all 2 true instances found.
        assert!((per[0].precision - 2.0 / 3.0).abs() < 1e-12);
        assert!((per[0].recall - 1.0).abs() < 1e-12);
        assert_eq!(per[0].support, 2);
        // c1: its one prediction was right, but it found only half.
        assert!((per[1].precision - 1.0).abs() < 1e-12);
        assert!((per[1].recall - 0.5).abs() < 1e-12);

        let expected_macro = (0.8 + 2.0 / 3.0) / 2.0;
        assert!((cm.macro_f1() - expected_macro).abs() < 1e-12);
        assert!(
            (cm.weighted_f1() - expected_macro).abs() < 1e-12,
            "equal support"
        );
    }

    #[test]
    fn confusion_matrix_ignores_out_of_range_classes() {
        let preds = vec![pred(0, &[0.9, 0.1]), pred(5, &[0.9, 0.1])];
        let cm = ConfusionMatrix::build(&preds, &labels(2));
        assert_eq!(cm.total(), 1, "the out-of-range sample is dropped");

        // An empty matrix must not divide by zero.
        let empty = ConfusionMatrix::build(&[], &labels(2));
        assert_eq!(empty.accuracy(), 0.0);
        assert_eq!(empty.macro_f1(), 0.0);
        assert_eq!(empty.weighted_f1(), 0.0);
        assert_eq!(empty.balanced_accuracy(), 0.0);
        assert!(empty.top_confusions(3).is_empty());
    }

    #[test]
    fn top_confusions_rank_by_frequency() {
        let mut preds = vec![pred(0, &[0.1, 0.9]); 5]; // c0 called c1 five times
        preds.extend(vec![pred(1, &[0.9, 0.1]); 2]); // c1 called c0 twice
        preds.extend(vec![pred(0, &[0.9, 0.1]); 5]); // c0 right five times
        let cm = ConfusionMatrix::build(&preds, &labels(2));

        let top = cm.top_confusions(5);
        assert_eq!(top.len(), 2);
        assert_eq!(
            (top[0].actual.as_str(), top[0].predicted.as_str()),
            ("c0", "c1")
        );
        assert_eq!(top[0].count, 5);
        // Five of c0's ten true instances went to c1.
        assert!((top[0].rate - 0.5).abs() < 1e-12);
        assert_eq!(top[1].count, 2);
        assert!((top[1].rate - 1.0).abs() < 1e-12);

        assert_eq!(cm.top_confusions(1).len(), 1, "respects the limit");
    }

    #[test]
    fn confusion_matrix_renders_a_square_table() {
        let preds = vec![pred(0, &[0.9, 0.1]), pred(1, &[0.4, 0.6])];
        let text = ConfusionMatrix::build(&preds, &labels(2)).render();
        let lines: Vec<&str> = text.lines().collect();
        assert_eq!(lines.len(), 3, "header plus one row per class");
        assert!(lines[0].contains("c0") && lines[0].contains("total"));
    }

    #[test]
    fn perfect_calibration_has_zero_error() {
        // 10 predictions at 100% confidence, all correct.
        let preds: Vec<Prediction> = (0..10).map(|_| pred(0, &[1.0, 0.0])).collect();
        let cal = calibrate(&preds, DEFAULT_BINS);
        assert!(cal.ece.abs() < 1e-12, "ece {}", cal.ece);
        assert!(cal.mce.abs() < 1e-12);
        assert!(cal.brier.abs() < 1e-12);
        assert!((cal.accuracy - 1.0).abs() < 1e-12);
        // A fully confident prediction belongs in the top bucket, not off the end.
        assert_eq!(cal.bins[DEFAULT_BINS - 1].count, 10);
    }

    #[test]
    fn overconfidence_shows_up_as_calibration_error() {
        // Claims 90% on every sample but is right only half the time.
        let mut preds = Vec::new();
        for i in 0..10 {
            let correct = i % 2 == 0;
            preds.push(Prediction {
                id: format!("s{i}"),
                actual: if correct { 0 } else { 1 },
                predicted: 0,
                probs: vec![0.9, 0.1],
                slices: BTreeMap::new(),
            });
        }
        let cal = calibrate(&preds, DEFAULT_BINS);
        assert!((cal.avg_confidence - 0.9).abs() < 1e-12);
        assert!((cal.accuracy - 0.5).abs() < 1e-12);
        assert!((cal.ece - 0.4).abs() < 1e-12, "ece {}", cal.ece);
        assert!((cal.mce - 0.4).abs() < 1e-12);
        assert!((cal.overconfidence() - 0.4).abs() < 1e-12);
        // Brier: 0.5*((0.9-1)^2+(0.1-0)^2) + 0.5*((0.9-0)^2+(0.1-1)^2)
        assert!((cal.brier - 0.82).abs() < 1e-9, "brier {}", cal.brier);
    }

    #[test]
    fn empty_input_calibrates_to_zero() {
        let cal = calibrate(&[], DEFAULT_BINS);
        assert_eq!(cal.n, 0);
        assert_eq!(cal.ece, 0.0);
        assert_eq!(cal.nll, 0.0);
        assert_eq!(cal.accuracy, 0.0);
    }

    #[test]
    fn temperature_scaling_cools_an_overconfident_model() {
        // Right 70% of the time while claiming 99%.
        let mut preds = Vec::new();
        for i in 0..100 {
            let correct = i % 10 < 7;
            preds.push(Prediction {
                id: format!("s{i}"),
                actual: if correct { 0 } else { 1 },
                predicted: 0,
                probs: vec![0.99, 0.01],
                slices: BTreeMap::new(),
            });
        }
        let before = calibrate(&preds, DEFAULT_BINS);
        let t = fit_temperature(&preds);
        assert!(t > 1.0, "an overconfident model needs cooling, got {t}");

        let after = calibrate(&apply_temperature(&preds, t), DEFAULT_BINS);
        assert!(
            after.ece < before.ece,
            "ece should improve: {} -> {}",
            before.ece,
            after.ece
        );
        // Confidence should land near the true accuracy.
        assert!(
            (after.avg_confidence - 0.7).abs() < 0.05,
            "confidence {} vs accuracy 0.7",
            after.avg_confidence
        );
        // Scaling must not change any decision.
        assert!((after.accuracy - before.accuracy).abs() < 1e-12);
    }

    #[test]
    fn temperature_scaling_preserves_ranking() {
        let preds = vec![
            pred(0, &[0.7, 0.2, 0.1]),
            pred(1, &[0.1, 0.6, 0.3]),
            pred(2, &[0.2, 0.2, 0.6]),
        ];
        for t in [0.5, 1.0, 2.0, 5.0] {
            for (before, after) in preds.iter().zip(apply_temperature(&preds, t)) {
                assert_eq!(argmax(&before.probs), argmax(&after.probs));
                assert!((after.probs.iter().sum::<f64>() - 1.0).abs() < 1e-9);
            }
        }
        // A degenerate temperature falls back to leaving probabilities alone.
        let same = apply_temperature(&preds, 0.0);
        for (a, b) in preds.iter().zip(&same) {
            for (x, y) in a.probs.iter().zip(&b.probs) {
                assert!((x - y).abs() < 1e-9);
            }
        }
    }

    #[test]
    fn temperature_is_neutral_on_calibrated_input() {
        // Confidence already matches accuracy: 8 of 10 correct at 0.8.
        let mut preds = Vec::new();
        for i in 0..50 {
            let correct = i % 10 < 8;
            preds.push(Prediction {
                id: format!("s{i}"),
                actual: if correct { 0 } else { 1 },
                predicted: 0,
                probs: vec![0.8, 0.2],
                slices: BTreeMap::new(),
            });
        }
        let t = fit_temperature(&preds);
        assert!((t - 1.0).abs() < 0.2, "expected no rescaling, got {t}");
        assert_eq!(fit_temperature(&[]), 1.0, "nothing to fit");
    }

    #[test]
    fn slices_expose_a_subgroup_the_average_hides() {
        // Wheat is perfect, rice is hopeless; overall accuracy looks acceptable.
        let mut preds = Vec::new();
        for i in 0..40 {
            preds.push(sliced(0, &[0.9, 0.1], "crop", "wheat"));
            preds[i].id = format!("w{i}");
        }
        for i in 0..40 {
            let mut p = sliced(0, &[0.1, 0.9], "crop", "rice");
            p.id = format!("r{i}");
            preds.push(p);
        }
        let slices = slice_metrics(&preds, &labels(2), MIN_SLICE_SAMPLES);
        assert_eq!(slices.len(), 2);
        // Worst first.
        assert_eq!(slices[0].value, "rice");
        assert!((slices[0].accuracy - 0.0).abs() < 1e-12);
        assert_eq!(slices[1].value, "wheat");
        assert!((slices[1].accuracy - 1.0).abs() < 1e-12);
        assert!(slices.iter().all(|s| s.reliable));

        let worst = worst_slice(&slices).unwrap();
        assert_eq!(worst.value, "rice");
    }

    #[test]
    fn small_slices_are_reported_but_flagged() {
        let mut preds = vec![sliced(0, &[0.9, 0.1], "crop", "wheat"); MIN_SLICE_SAMPLES];
        for (i, p) in preds.iter_mut().enumerate() {
            p.id = format!("w{i}");
        }
        preds.push(sliced(0, &[0.1, 0.9], "crop", "millet"));

        let slices = slice_metrics(&preds, &labels(2), MIN_SLICE_SAMPLES);
        let millet = slices.iter().find(|s| s.value == "millet").unwrap();
        assert_eq!(millet.n, 1);
        assert!(!millet.reliable);
        // The unreliable slice is worse but must not be chosen as the gate.
        assert_eq!(worst_slice(&slices).unwrap().value, "wheat");
    }

    #[test]
    fn slicing_covers_every_dimension_and_skips_blanks() {
        let mut a = sliced(0, &[0.9, 0.1], "crop", "wheat");
        a.slices.insert("provenance".into(), "human_review".into());
        let mut b = sliced(1, &[0.9, 0.1], "crop", "");
        b.slices.insert("provenance".into(), "external_api".into());

        let slices = slice_metrics(&[a, b], &labels(2), 1);
        let dims: BTreeSet<&str> = slices.iter().map(|s| s.dimension.as_str()).collect();
        assert_eq!(dims, ["crop", "provenance"].into_iter().collect());
        // The blank crop is not a slice value.
        assert_eq!(slices.iter().filter(|s| s.dimension == "crop").count(), 1);
        assert!(worst_slice(&slice_metrics(&[], &labels(2), 1)).is_none());
    }

    #[test]
    fn report_serialises_and_renders() {
        let preds = vec![
            sliced(0, &[0.9, 0.1], "crop", "wheat"),
            sliced(1, &[0.3, 0.7], "crop", "wheat"),
            sliced(1, &[0.6, 0.4], "crop", "rice"),
        ];
        let report = EvaluationReport::build("disease", "v1", &preds, &labels(2));

        assert_eq!(report.n_samples, 3);
        assert!((report.accuracy - 2.0 / 3.0).abs() < 1e-12);
        assert_eq!(report.per_class.len(), 2);
        assert_eq!(report.top_confusions.len(), 1);
        assert!(report.suggested_temperature > 0.0);

        let json = serde_json::to_string(&report).unwrap();
        let back: EvaluationReport = serde_json::from_str(&json).unwrap();
        assert_eq!(back.n_samples, 3);
        assert_eq!(back.confusion.counts, report.confusion.counts);

        let text = report.render();
        assert!(text.contains("Confusion matrix"));
        assert!(text.contains("Calibration"));
        assert!(text.contains("crop"));
    }
}
