//! Gradient-boosted regression trees for tabular yield prediction.
//!
//! A dependency-free implementation so the same model can be trained by the
//! ML pipeline and served by the AI gateway without an ONNX runtime. Trees
//! are grown greedily on squared error with shrinkage and row subsampling;
//! prediction intervals come from split-conformal calibration on held-out
//! residuals, which gives distribution-free coverage guarantees.

use serde::{Deserialize, Serialize};
use thiserror::Error;

use crate::factors::{EnvironmentFactors, ManagementFactors, SoilFactors};
use crate::model::YieldModelParams;

/// Errors raised while training or loading a boosted model.
#[derive(Debug, Error)]
pub enum GbmError {
    #[error("training requires at least {min} samples, got {got}")]
    TooFewSamples { min: usize, got: usize },
    #[error("feature count mismatch: expected {expected}, got {got}")]
    FeatureMismatch { expected: usize, got: usize },
    #[error("targets and features have different lengths ({targets} vs {features})")]
    LengthMismatch { targets: usize, features: usize },
    #[error("model has no trees")]
    EmptyModel,
    #[error("serialization: {0}")]
    Json(#[from] serde_json::Error),
}

/// Ordered feature names for [`YieldFeatures::to_vec`]. Training data and
/// serving requests must agree on this order; the model stores it for checks.
pub const FEATURE_NAMES: [&str; 22] = [
    "crop_code",
    "avg_temperature_c",
    "total_precipitation_mm",
    "solar_radiation_mj_m2_day",
    "growing_degree_days",
    "frost_days",
    "heat_stress_days",
    "relative_humidity_pct",
    "organic_matter_pct",
    "ph",
    "nitrogen_kg_ha",
    "phosphorus_kg_ha",
    "potassium_kg_ha",
    "water_holding_capacity_mm_m",
    "compaction_index",
    "planting_day",
    "plant_population_per_ha",
    "nitrogen_applied_kg_ha",
    "irrigation_mm",
    "pest_control_effectiveness",
    "ndvi_peak",
    "prior_yield_mean_kg_ha",
];

/// Model input row. Remote-sensing and history features default to zero when
/// unavailable; trees treat zero as "unknown" once trained that way.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct YieldFeatures {
    pub crop_code: f64,
    pub avg_temperature_c: f64,
    pub total_precipitation_mm: f64,
    pub solar_radiation_mj_m2_day: f64,
    pub growing_degree_days: f64,
    pub frost_days: f64,
    pub heat_stress_days: f64,
    pub relative_humidity_pct: f64,
    pub organic_matter_pct: f64,
    pub ph: f64,
    pub nitrogen_kg_ha: f64,
    pub phosphorus_kg_ha: f64,
    pub potassium_kg_ha: f64,
    pub water_holding_capacity_mm_m: f64,
    pub compaction_index: f64,
    pub planting_day: f64,
    pub plant_population_per_ha: f64,
    pub nitrogen_applied_kg_ha: f64,
    pub irrigation_mm: f64,
    pub pest_control_effectiveness: f64,
    pub ndvi_peak: f64,
    pub prior_yield_mean_kg_ha: f64,
}

impl YieldFeatures {
    /// Build features from the parametric model inputs.
    pub fn from_factors(
        crop: &str,
        env: &EnvironmentFactors,
        soil: &SoilFactors,
        mgmt: &ManagementFactors,
    ) -> Self {
        Self {
            crop_code: YieldModelParams::crop_code(crop)
                .map(|c| c as f64)
                .unwrap_or(-1.0),
            avg_temperature_c: env.avg_temperature_c,
            total_precipitation_mm: env.total_precipitation_mm,
            solar_radiation_mj_m2_day: env.solar_radiation_mj_m2_day,
            growing_degree_days: env.growing_degree_days,
            frost_days: env.frost_days as f64,
            heat_stress_days: env.heat_stress_days as f64,
            relative_humidity_pct: env.relative_humidity_pct,
            organic_matter_pct: soil.organic_matter_pct,
            ph: soil.ph,
            nitrogen_kg_ha: soil.nitrogen_kg_ha,
            phosphorus_kg_ha: soil.phosphorus_kg_ha,
            potassium_kg_ha: soil.potassium_kg_ha,
            water_holding_capacity_mm_m: soil.water_holding_capacity_mm_m,
            compaction_index: soil.compaction_index,
            planting_day: mgmt.planting_day as f64,
            plant_population_per_ha: mgmt.plant_population_per_ha,
            nitrogen_applied_kg_ha: mgmt.nitrogen_applied_kg_ha,
            irrigation_mm: mgmt.irrigation_mm,
            pest_control_effectiveness: mgmt.pest_control_effectiveness,
            ndvi_peak: 0.0,
            prior_yield_mean_kg_ha: 0.0,
        }
    }

    pub fn with_ndvi_peak(mut self, ndvi_peak: f64) -> Self {
        self.ndvi_peak = ndvi_peak;
        self
    }

    pub fn with_prior_yield(mut self, prior_yield_mean_kg_ha: f64) -> Self {
        self.prior_yield_mean_kg_ha = prior_yield_mean_kg_ha;
        self
    }

    /// Feature vector in [`FEATURE_NAMES`] order.
    pub fn to_vec(&self) -> Vec<f64> {
        vec![
            self.crop_code,
            self.avg_temperature_c,
            self.total_precipitation_mm,
            self.solar_radiation_mj_m2_day,
            self.growing_degree_days,
            self.frost_days,
            self.heat_stress_days,
            self.relative_humidity_pct,
            self.organic_matter_pct,
            self.ph,
            self.nitrogen_kg_ha,
            self.phosphorus_kg_ha,
            self.potassium_kg_ha,
            self.water_holding_capacity_mm_m,
            self.compaction_index,
            self.planting_day,
            self.plant_population_per_ha,
            self.nitrogen_applied_kg_ha,
            self.irrigation_mm,
            self.pest_control_effectiveness,
            self.ndvi_peak,
            self.prior_yield_mean_kg_ha,
        ]
    }

    /// Parse a row given column names (any order, extra columns ignored).
    pub fn from_named(columns: &[String], values: &[f64]) -> Option<Self> {
        let get = |name: &str| -> Option<f64> {
            columns
                .iter()
                .position(|c| c == name)
                .and_then(|i| values.get(i).copied())
        };
        Some(Self {
            crop_code: get("crop_code")?,
            avg_temperature_c: get("avg_temperature_c")?,
            total_precipitation_mm: get("total_precipitation_mm")?,
            solar_radiation_mj_m2_day: get("solar_radiation_mj_m2_day").unwrap_or(0.0),
            growing_degree_days: get("growing_degree_days")?,
            frost_days: get("frost_days").unwrap_or(0.0),
            heat_stress_days: get("heat_stress_days").unwrap_or(0.0),
            relative_humidity_pct: get("relative_humidity_pct").unwrap_or(0.0),
            organic_matter_pct: get("organic_matter_pct").unwrap_or(0.0),
            ph: get("ph").unwrap_or(0.0),
            nitrogen_kg_ha: get("nitrogen_kg_ha").unwrap_or(0.0),
            phosphorus_kg_ha: get("phosphorus_kg_ha").unwrap_or(0.0),
            potassium_kg_ha: get("potassium_kg_ha").unwrap_or(0.0),
            water_holding_capacity_mm_m: get("water_holding_capacity_mm_m").unwrap_or(0.0),
            compaction_index: get("compaction_index").unwrap_or(0.0),
            planting_day: get("planting_day").unwrap_or(0.0),
            plant_population_per_ha: get("plant_population_per_ha").unwrap_or(0.0),
            nitrogen_applied_kg_ha: get("nitrogen_applied_kg_ha").unwrap_or(0.0),
            irrigation_mm: get("irrigation_mm").unwrap_or(0.0),
            pest_control_effectiveness: get("pest_control_effectiveness").unwrap_or(0.0),
            ndvi_peak: get("ndvi_peak").unwrap_or(0.0),
            prior_yield_mean_kg_ha: get("prior_yield_mean_kg_ha").unwrap_or(0.0),
        })
    }
}

/// Boosting hyper-parameters.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GbmParams {
    pub n_trees: usize,
    pub max_depth: usize,
    pub learning_rate: f64,
    pub min_samples_leaf: usize,
    /// Fraction of rows used per tree (stochastic gradient boosting).
    pub subsample: f64,
    pub seed: u64,
}

impl Default for GbmParams {
    fn default() -> Self {
        Self {
            n_trees: 200,
            max_depth: 4,
            learning_rate: 0.05,
            min_samples_leaf: 5,
            subsample: 0.8,
            seed: 42,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct Node {
    feature: usize,
    threshold: f64,
    left: usize,
    right: usize,
    value: f64,
    leaf: bool,
}

/// A single regression tree stored as a flat node array.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RegressionTree {
    nodes: Vec<Node>,
}

impl RegressionTree {
    fn predict(&self, x: &[f64]) -> f64 {
        let mut i = 0;
        loop {
            let n = &self.nodes[i];
            if n.leaf {
                return n.value;
            }
            i = if x[n.feature] <= n.threshold {
                n.left
            } else {
                n.right
            };
        }
    }
}

/// Validation metrics recorded at training time.
#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct GbmValidation {
    pub r_squared: f64,
    pub rmse: f64,
    pub mae: f64,
    pub n_samples: usize,
}

/// Take up to `max` rows spread evenly through `rows`.
///
/// Striding rather than sampling keeps the choice deterministic and keeps the
/// spread of the data, which random picks from a sorted file would not.
fn subsample(rows: &[Vec<f64>], max: usize) -> Vec<Vec<f64>> {
    if rows.is_empty() || max == 0 {
        return Vec::new();
    }
    if rows.len() <= max {
        return rows.to_vec();
    }
    (0..max)
        .map(|i| rows[i * rows.len() / max].clone())
        .collect()
}

/// Trained boosted ensemble with conformal interval calibration.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GradientBoostedModel {
    pub version: String,
    pub feature_names: Vec<String>,
    pub params: GbmParams,
    base_score: f64,
    trees: Vec<RegressionTree>,
    /// Absolute-residual quantile from calibration; `None` until calibrated.
    interval_half_width: Option<f64>,
    interval_coverage: f64,
    pub validation: GbmValidation,
    /// A spread of training rows kept so a prediction can be attributed.
    ///
    /// Shapley values need something to compare against: "what would this
    /// model say about a typical field?" Without real rows to fall back on,
    /// absent features would have to be filled with means, and a field with
    /// one district's rainfall and another's soil is not a field the model was
    /// ever fitted on. Empty on models trained before attribution existed,
    /// which report that rather than guessing.
    #[serde(default)]
    reference: Vec<Vec<f64>>,
}

/// How many training rows a model keeps for attribution.
///
/// Enough to span the data, few enough that the extra JSON is noise next to
/// the trees and that attribution stays fast.
pub const REFERENCE_ROWS: usize = 32;

impl GradientBoostedModel {
    /// Train on rows `x` (each `feature_names.len()` long) with targets `y`.
    pub fn train(
        x: &[Vec<f64>],
        y: &[f64],
        feature_names: Vec<String>,
        params: GbmParams,
    ) -> Result<Self, GbmError> {
        if x.len() != y.len() {
            return Err(GbmError::LengthMismatch {
                targets: y.len(),
                features: x.len(),
            });
        }
        let min = params.min_samples_leaf.max(2) * 2;
        if x.len() < min {
            return Err(GbmError::TooFewSamples { min, got: x.len() });
        }
        let n_features = feature_names.len();
        if let Some(bad) = x.iter().find(|r| r.len() != n_features) {
            return Err(GbmError::FeatureMismatch {
                expected: n_features,
                got: bad.len(),
            });
        }

        let base_score = y.iter().sum::<f64>() / y.len() as f64;
        let mut pred = vec![base_score; y.len()];
        let mut trees = Vec::with_capacity(params.n_trees);
        let mut rng = Lcg::new(params.seed);

        for _ in 0..params.n_trees {
            let residuals: Vec<f64> = y.iter().zip(&pred).map(|(t, p)| t - p).collect();
            let rows: Vec<usize> = (0..y.len())
                .filter(|_| rng.next_f64() < params.subsample)
                .collect();
            let rows = if rows.len() < min {
                (0..y.len()).collect()
            } else {
                rows
            };

            let tree = grow_tree(x, &residuals, &rows, &params);
            for (i, p) in pred.iter_mut().enumerate() {
                *p += params.learning_rate * tree.predict(&x[i]);
            }
            trees.push(tree);
        }

        Ok(Self {
            version: String::new(),
            feature_names,
            params,
            base_score,
            trees,
            interval_half_width: None,
            interval_coverage: 0.0,
            validation: GbmValidation::default(),
            reference: subsample(x, REFERENCE_ROWS),
        })
    }

    pub fn n_trees(&self) -> usize {
        self.trees.len()
    }

    /// Training rows kept for attribution; empty if the model predates it.
    pub fn reference(&self) -> &[Vec<f64>] {
        &self.reference
    }

    pub fn explains(&self) -> bool {
        !self.reference.is_empty()
    }

    /// Replace the stored reference set, evenly subsampled.
    pub fn set_reference(&mut self, rows: &[Vec<f64>]) {
        self.reference = subsample(rows, REFERENCE_ROWS);
    }

    /// Split this prediction's distance from a typical one across the features.
    ///
    /// `samples` trades accuracy for time; [`crate::DEFAULT_SAMPLES`] is a
    /// reasonable default. The seed makes the explanation reproducible, so the
    /// same prediction always comes with the same reasons.
    pub fn attribute(
        &self,
        x: &[f64],
        samples: usize,
        seed: u64,
    ) -> Result<crate::AttributionReport, crate::AttributionError> {
        let predict = |row: &[f64]| self.predict(row).unwrap_or(f64::NAN);
        crate::shapley_sampling(
            &predict,
            x,
            &self.reference,
            &self.feature_names,
            samples,
            seed,
        )
    }

    /// Point prediction.
    pub fn predict(&self, x: &[f64]) -> Result<f64, GbmError> {
        if self.trees.is_empty() {
            return Err(GbmError::EmptyModel);
        }
        if x.len() != self.feature_names.len() {
            return Err(GbmError::FeatureMismatch {
                expected: self.feature_names.len(),
                got: x.len(),
            });
        }
        Ok(self.base_score
            + self.params.learning_rate * self.trees.iter().map(|t| t.predict(x)).sum::<f64>())
    }

    /// Prediction with a split-conformal interval `(point, lower, upper)`.
    /// Before calibration the interval collapses to the point prediction.
    pub fn predict_interval(&self, x: &[f64]) -> Result<(f64, f64, f64), GbmError> {
        let p = self.predict(x)?;
        let hw = self.interval_half_width.unwrap_or(0.0);
        Ok((p, (p - hw).max(0.0), p + hw))
    }

    /// Calibrate intervals on held-out rows so that roughly `coverage` of
    /// future targets fall inside `predict_interval`.
    pub fn calibrate(&mut self, x: &[Vec<f64>], y: &[f64], coverage: f64) -> Result<(), GbmError> {
        if x.len() != y.len() {
            return Err(GbmError::LengthMismatch {
                targets: y.len(),
                features: x.len(),
            });
        }
        let mut abs_res: Vec<f64> = Vec::with_capacity(x.len());
        for (row, t) in x.iter().zip(y) {
            abs_res.push((t - self.predict(row)?).abs());
        }
        if abs_res.is_empty() {
            return Ok(());
        }
        abs_res.sort_by(|a, b| a.partial_cmp(b).unwrap_or(std::cmp::Ordering::Equal));
        let coverage = coverage.clamp(0.5, 0.999);
        // Finite-sample correction: ceil((n+1)*coverage)-th smallest residual.
        let n = abs_res.len();
        let k = (((n + 1) as f64) * coverage).ceil() as usize;
        let idx = k.clamp(1, n) - 1;
        self.interval_half_width = Some(abs_res[idx]);
        self.interval_coverage = coverage;
        Ok(())
    }

    /// Evaluate on held-out rows and record the metrics on the model.
    pub fn validate(&mut self, x: &[Vec<f64>], y: &[f64]) -> Result<GbmValidation, GbmError> {
        let mut preds = Vec::with_capacity(x.len());
        for row in x {
            preds.push(self.predict(row)?);
        }
        let v = GbmValidation {
            r_squared: crate::model::r_squared(&preds, y),
            rmse: crate::model::rmse(&preds, y),
            mae: crate::model::mae(&preds, y),
            n_samples: y.len(),
        };
        self.validation = v.clone();
        Ok(v)
    }

    pub fn interval_half_width(&self) -> Option<f64> {
        self.interval_half_width
    }

    pub fn interval_coverage(&self) -> f64 {
        self.interval_coverage
    }

    /// Split-count importance per feature, normalized to sum to 1.
    pub fn feature_importance(&self) -> Vec<(String, f64)> {
        let mut counts = vec![0.0; self.feature_names.len()];
        for t in &self.trees {
            for n in &t.nodes {
                if !n.leaf {
                    counts[n.feature] += 1.0;
                }
            }
        }
        let total: f64 = counts.iter().sum();
        self.feature_names
            .iter()
            .cloned()
            .zip(
                counts
                    .into_iter()
                    .map(|c| if total > 0.0 { c / total } else { 0.0 }),
            )
            .collect()
    }

    pub fn to_json(&self) -> Result<String, GbmError> {
        Ok(serde_json::to_string(self)?)
    }

    pub fn from_json(s: &str) -> Result<Self, GbmError> {
        let m: Self = serde_json::from_str(s)?;
        if m.trees.is_empty() {
            return Err(GbmError::EmptyModel);
        }
        Ok(m)
    }
}

// ---------------------------------------------------------------------------
// Tree growing
// ---------------------------------------------------------------------------

fn grow_tree(x: &[Vec<f64>], target: &[f64], rows: &[usize], params: &GbmParams) -> RegressionTree {
    let mut nodes = Vec::new();
    build_node(x, target, rows, 0, params, &mut nodes);
    RegressionTree { nodes }
}

fn build_node(
    x: &[Vec<f64>],
    target: &[f64],
    rows: &[usize],
    depth: usize,
    params: &GbmParams,
    nodes: &mut Vec<Node>,
) -> usize {
    let idx = nodes.len();
    let mean = rows.iter().map(|&i| target[i]).sum::<f64>() / rows.len().max(1) as f64;
    nodes.push(Node {
        feature: 0,
        threshold: 0.0,
        left: 0,
        right: 0,
        value: mean,
        leaf: true,
    });

    if depth >= params.max_depth || rows.len() < 2 * params.min_samples_leaf {
        return idx;
    }
    let Some((feature, threshold)) = best_split(x, target, rows, params.min_samples_leaf) else {
        return idx;
    };
    let (left_rows, right_rows): (Vec<usize>, Vec<usize>) =
        rows.iter().partition(|&&i| x[i][feature] <= threshold);
    if left_rows.is_empty() || right_rows.is_empty() {
        return idx;
    }
    let left = build_node(x, target, &left_rows, depth + 1, params, nodes);
    let right = build_node(x, target, &right_rows, depth + 1, params, nodes);
    let node = &mut nodes[idx];
    node.feature = feature;
    node.threshold = threshold;
    node.left = left;
    node.right = right;
    node.leaf = false;
    idx
}

/// Exhaustive best split by SSE reduction using prefix sums over sorted rows.
fn best_split(
    x: &[Vec<f64>],
    target: &[f64],
    rows: &[usize],
    min_leaf: usize,
) -> Option<(usize, f64)> {
    let n = rows.len();
    let total_sum: f64 = rows.iter().map(|&i| target[i]).sum();
    let total_sq: f64 = rows.iter().map(|&i| target[i] * target[i]).sum();
    let parent_sse = total_sq - total_sum * total_sum / n as f64;

    let n_features = x[rows[0]].len();
    let mut best: Option<(usize, f64, f64)> = None; // (feature, threshold, gain)
    let mut order: Vec<usize> = rows.to_vec();

    for f in 0..n_features {
        order.sort_by(|&a, &b| {
            x[a][f]
                .partial_cmp(&x[b][f])
                .unwrap_or(std::cmp::Ordering::Equal)
        });
        let mut left_sum = 0.0;
        let mut left_sq = 0.0;
        for k in 0..n - 1 {
            let i = order[k];
            left_sum += target[i];
            left_sq += target[i] * target[i];
            let nl = k + 1;
            let nr = n - nl;
            if nl < min_leaf || nr < min_leaf {
                continue;
            }
            let v = x[i][f];
            let next = x[order[k + 1]][f];
            if next <= v {
                continue; // cannot split between equal values
            }
            let right_sum = total_sum - left_sum;
            let right_sq = total_sq - left_sq;
            let sse = (left_sq - left_sum * left_sum / nl as f64)
                + (right_sq - right_sum * right_sum / nr as f64);
            let gain = parent_sse - sse;
            if gain > 1e-12 && best.map_or(true, |b| gain > b.2) {
                best = Some((f, (v + next) / 2.0, gain));
            }
        }
    }
    best.map(|(f, t, _)| (f, t))
}

/// Small deterministic PRNG so training is reproducible without extra deps.
struct Lcg(u64);

impl Lcg {
    fn new(seed: u64) -> Self {
        Self(
            seed.wrapping_mul(6364136223846793005)
                .wrapping_add(1442695040888963407)
                | 1,
        )
    }
    fn next_f64(&mut self) -> f64 {
        self.0 = self
            .0
            .wrapping_mul(6364136223846793005)
            .wrapping_add(1442695040888963407);
        (self.0 >> 11) as f64 / (1u64 << 53) as f64
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    /// Synthetic yield surface: nonlinear in GDD and rainfall with an
    /// interaction, plus crop-level offsets and mild noise.
    fn synth(n: usize, seed: u64) -> (Vec<Vec<f64>>, Vec<f64>) {
        let mut rng = Lcg::new(seed);
        let mut xs = Vec::with_capacity(n);
        let mut ys = Vec::with_capacity(n);
        for _ in 0..n {
            let crop = (rng.next_f64() * 4.0).floor();
            let gdd = 1200.0 + rng.next_f64() * 1800.0;
            let rain = 200.0 + rng.next_f64() * 800.0;
            let n_kg = rng.next_f64() * 200.0;
            let ph = 5.0 + rng.next_f64() * 3.0;
            let mut f = YieldFeatures::from_factors(
                "wheat",
                &EnvironmentFactors {
                    avg_temperature_c: 22.0,
                    total_precipitation_mm: rain,
                    solar_radiation_mj_m2_day: 20.0,
                    growing_degree_days: gdd,
                    frost_days: 0,
                    heat_stress_days: 0,
                    relative_humidity_pct: 60.0,
                },
                &SoilFactors {
                    organic_matter_pct: 3.0,
                    ph,
                    nitrogen_kg_ha: n_kg,
                    phosphorus_kg_ha: 40.0,
                    potassium_kg_ha: 60.0,
                    water_holding_capacity_mm_m: 200.0,
                    compaction_index: 0.1,
                },
                &ManagementFactors {
                    planting_day: 100,
                    plant_population_per_ha: 3_000_000.0,
                    nitrogen_applied_kg_ha: 100.0,
                    irrigation_mm: 100.0,
                    pest_control_effectiveness: 0.8,
                    weed_control_effectiveness: 0.8,
                },
            );
            f.crop_code = crop;
            let water = (rain / 600.0).min(1.0);
            let heat = (gdd / 2500.0).min(1.0);
            let ph_pen = 1.0 - ((ph - 6.5).abs() / 3.0);
            let y = 1500.0 * (crop + 1.0)
                + 6000.0 * water * heat * ph_pen
                + 8.0 * n_kg
                + (rng.next_f64() - 0.5) * 300.0;
            xs.push(f.to_vec());
            ys.push(y);
        }
        (xs, ys)
    }

    fn names() -> Vec<String> {
        FEATURE_NAMES.iter().map(|s| s.to_string()).collect()
    }

    #[test]
    fn train_fits_nonlinear_surface() {
        let (x, y) = synth(600, 1);
        let (xv, yv) = synth(200, 2);
        let mut m = GradientBoostedModel::train(&x, &y, names(), GbmParams::default()).unwrap();
        let v = m.validate(&xv, &yv).unwrap();
        assert!(v.r_squared > 0.9, "held-out R2 = {}", v.r_squared);
        assert!(v.rmse < 700.0, "rmse = {}", v.rmse);
        assert_eq!(m.n_trees(), 200);
    }

    #[test]
    fn conformal_intervals_cover_target() {
        let (x, y) = synth(600, 3);
        let (xc, yc) = synth(300, 4);
        let (xt, yt) = synth(400, 5);
        let mut m = GradientBoostedModel::train(&x, &y, names(), GbmParams::default()).unwrap();
        m.calibrate(&xc, &yc, 0.9).unwrap();
        assert!(m.interval_half_width().unwrap() > 0.0);
        let covered = xt
            .iter()
            .zip(&yt)
            .filter(|(row, t)| {
                let (_, lo, hi) = m.predict_interval(row).unwrap();
                **t >= lo && **t <= hi
            })
            .count() as f64
            / yt.len() as f64;
        assert!(covered > 0.85 && covered < 0.97, "coverage = {covered}");
    }

    #[test]
    fn json_roundtrip_preserves_predictions() {
        let (x, y) = synth(120, 7);
        let mut m = GradientBoostedModel::train(
            &x,
            &y,
            names(),
            GbmParams {
                n_trees: 30,
                ..Default::default()
            },
        )
        .unwrap();
        m.calibrate(&x, &y, 0.9).unwrap();
        m.version = "yield-gbm-test".into();
        let json = m.to_json().unwrap();
        let back = GradientBoostedModel::from_json(&json).unwrap();
        assert_eq!(back.version, "yield-gbm-test");
        for row in x.iter().take(10) {
            assert!((m.predict(row).unwrap() - back.predict(row).unwrap()).abs() < 1e-9);
        }
        let (a, b) = (
            back.interval_half_width().unwrap(),
            m.interval_half_width().unwrap(),
        );
        assert!((a - b).abs() < 1e-6, "half-width {a} vs {b}");
    }

    #[test]
    fn rejects_bad_inputs() {
        let (x, y) = synth(4, 9);
        assert!(matches!(
            GradientBoostedModel::train(&x, &y, names(), GbmParams::default()),
            Err(GbmError::TooFewSamples { .. })
        ));
        let (x, y) = synth(60, 9);
        let m = GradientBoostedModel::train(
            &x,
            &y,
            names(),
            GbmParams {
                n_trees: 5,
                ..Default::default()
            },
        )
        .unwrap();
        assert!(matches!(
            m.predict(&[1.0, 2.0]),
            Err(GbmError::FeatureMismatch { .. })
        ));
        assert!(GradientBoostedModel::from_json("{\"version\":\"\",\"feature_names\":[],\"params\":{\"n_trees\":1,\"max_depth\":1,\"learning_rate\":0.1,\"min_samples_leaf\":1,\"subsample\":1.0,\"seed\":1},\"base_score\":0.0,\"trees\":[],\"interval_half_width\":null,\"interval_coverage\":0.0,\"validation\":{\"r_squared\":0.0,\"rmse\":0.0,\"mae\":0.0,\"n_samples\":0}}").is_err());
    }

    #[test]
    fn feature_importance_highlights_drivers() {
        let (x, y) = synth(500, 11);
        let m = GradientBoostedModel::train(&x, &y, names(), GbmParams::default()).unwrap();
        let imp = m.feature_importance();
        let total: f64 = imp.iter().map(|(_, v)| v).sum();
        assert!((total - 1.0).abs() < 1e-9);
        let mut sorted = imp.clone();
        sorted.sort_by(|a, b| b.1.partial_cmp(&a.1).unwrap());
        let top: Vec<String> = sorted.iter().take(4).map(|(n, _)| n.clone()).collect();
        // Continuous drivers dominate split counts; the categorical crop code
        // needs only a few splits but must still register.
        assert!(
            top.iter().any(|n| n == "total_precipitation_mm")
                && top.iter().any(|n| n == "growing_degree_days"),
            "top = {top:?}"
        );
        let crop = imp
            .iter()
            .find(|(n, _)| n == "crop_code")
            .map(|(_, v)| *v)
            .unwrap();
        assert!(crop > 0.0, "crop_code should be used for splits");
        let unused = imp
            .iter()
            .find(|(n, _)| n == "ndvi_peak")
            .map(|(_, v)| *v)
            .unwrap();
        assert_eq!(unused, 0.0, "constant feature must never be split on");
    }

    #[test]
    fn features_roundtrip_by_name() {
        let cols: Vec<String> = names();
        let (x, _) = synth(1, 13);
        let f = YieldFeatures::from_named(&cols, &x[0]).unwrap();
        assert_eq!(f.to_vec(), x[0]);
        assert!(YieldFeatures::from_named(&["ph".to_string()], &[6.5]).is_none());
    }

    #[test]
    fn crop_lookup_and_codes() {
        assert_eq!(
            YieldModelParams::for_crop("MAIZE").unwrap().crop_name,
            "Corn"
        );
        assert_eq!(
            YieldModelParams::for_crop("pigeon pea").unwrap().crop_name,
            "Pigeon Pea"
        );
        assert_eq!(
            YieldModelParams::for_crop("Sugar-cane").unwrap().crop_name,
            "Sugarcane"
        );
        assert!(YieldModelParams::for_crop("kiwi").is_none());
        assert_eq!(YieldModelParams::crop_code("wheat"), Some(0));
        assert_eq!(YieldModelParams::crop_code("onion"), Some(12));
        assert_eq!(YieldModelParams::crop_code("nope"), None);
        for c in YieldModelParams::SUPPORTED_CROPS {
            assert!(YieldModelParams::for_crop(c).is_some(), "{c}");
        }
    }
    #[test]
    fn subsampling_spans_the_data_deterministically() {
        let rows: Vec<Vec<f64>> = (0..100).map(|i| vec![i as f64]).collect();
        let picked = subsample(&rows, 10);
        assert_eq!(picked.len(), 10);
        assert_eq!(picked[0][0], 0.0);
        assert_eq!(picked[9][0], 90.0, "the sample reaches the far end");
        assert_eq!(subsample(&rows, 10), picked, "the choice is not random");

        // Fewer rows than asked for are all kept.
        assert_eq!(subsample(&rows[..4], 10).len(), 4);
        assert!(subsample(&[], 10).is_empty());
        assert!(subsample(&rows, 0).is_empty());
    }

    #[test]
    fn a_trained_model_can_attribute_its_own_predictions() {
        // A target driven mostly by feature 0, with feature 2 ignored entirely.
        let x: Vec<Vec<f64>> = (0..120)
            .map(|i| {
                let a = (i % 12) as f64;
                let b = ((i / 12) % 10) as f64;
                vec![a, b, 42.0]
            })
            .collect();
        let y: Vec<f64> = x.iter().map(|r| 10.0 * r[0] + r[1]).collect();

        let model = GradientBoostedModel::train(
            &x,
            &y,
            vec!["driver".into(), "minor".into(), "ignored".into()],
            GbmParams {
                n_trees: 60,
                max_depth: 3,
                learning_rate: 0.15,
                ..GbmParams::default()
            },
        )
        .unwrap();

        assert!(model.explains());
        assert_eq!(model.reference().len(), REFERENCE_ROWS);

        // A high-feature-0 row should be attributed mostly to feature 0.
        let row = vec![11.0, 5.0, 42.0];
        let report = model.attribute(&row, 200, 1).unwrap();
        assert_eq!(report.attributions.len(), 3);
        assert_eq!(report.attributions[0].feature, "driver");

        // The ignored feature is constant across the data, so it can move
        // nothing: its contribution must be zero, not merely small.
        let ignored = report
            .attributions
            .iter()
            .find(|a| a.feature == "ignored")
            .unwrap();
        assert_eq!(ignored.contribution, 0.0);

        // What the split explains must match the gap it is splitting.
        let scale = (report.prediction - report.baseline).abs().max(1.0);
        assert!(
            report.residual().abs() < 0.05 * scale,
            "residual {} on a gap of {}",
            report.residual(),
            report.prediction - report.baseline
        );
        assert!((report.prediction - model.predict(&row).unwrap()).abs() < 1e-12);
    }

    #[test]
    fn a_model_without_a_reference_set_says_so() {
        let x: Vec<Vec<f64>> = (0..40).map(|i| vec![i as f64, (i % 3) as f64]).collect();
        let y: Vec<f64> = x.iter().map(|r| r[0] * 2.0).collect();
        let mut model =
            GradientBoostedModel::train(&x, &y, vec!["a".into(), "b".into()], GbmParams::default())
                .unwrap();

        model.set_reference(&[]);
        assert!(!model.explains());
        assert_eq!(
            model.attribute(&[1.0, 2.0], 50, 1).unwrap_err(),
            crate::AttributionError::NoReference
        );

        // And it can be given one after the fact.
        model.set_reference(&x);
        assert!(model.explains());
        assert!(model.attribute(&[1.0, 2.0], 50, 1).is_ok());
    }

    #[test]
    fn the_reference_set_survives_serialisation() {
        let x: Vec<Vec<f64>> = (0..50).map(|i| vec![i as f64, (i % 5) as f64]).collect();
        let y: Vec<f64> = x.iter().map(|r| r[0] + r[1]).collect();
        let model =
            GradientBoostedModel::train(&x, &y, vec!["a".into(), "b".into()], GbmParams::default())
                .unwrap();

        let json = serde_json::to_string(&model).unwrap();
        let back: GradientBoostedModel = serde_json::from_str(&json).unwrap();
        assert_eq!(back.reference(), model.reference());
        assert!(back.explains());

        // A model file written before attribution existed still loads.
        let mut value: serde_json::Value = serde_json::from_str(&json).unwrap();
        value.as_object_mut().unwrap().remove("reference");
        let old: GradientBoostedModel = serde_json::from_value(value).unwrap();
        assert!(!old.explains());
        assert!(
            (old.predict(&[1.0, 2.0]).unwrap() - model.predict(&[1.0, 2.0]).unwrap()).abs() < 1e-12
        );
    }
}
