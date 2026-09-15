//! Shapley attribution: how much each input moved one prediction.
//!
//! A yield number on its own is not actionable. "1,850 kg/ha" does not tell a
//! farmer whether the figure is low because of the weather they cannot change
//! or the nitrogen they can. Shapley values answer that by splitting the gap
//! between this prediction and a typical one across the inputs, in the only
//! way that satisfies the properties you would want of a fair split:
//!
//! * **Efficiency** — the contributions sum exactly to `prediction − baseline`,
//!   so nothing is invented and nothing goes missing.
//! * **Dummy** — an input the model ignores gets exactly zero.
//! * **Symmetry** — two inputs that always act alike get the same number.
//!
//! The value of a feature subset is *interventional*: absent features are
//! replaced with values drawn from a reference set of real rows, and the
//! prediction is averaged over them. Using real rows rather than means keeps
//! the hybrid inputs on the data manifold — an "average" field with the
//! rainfall of one district and the soil of another is a field that does not
//! exist, and a model asked about it will say something arbitrary.
//!
//! Two estimators are provided. [`shapley_exact`] enumerates every coalition
//! and is correct by construction but costs `2^n`, so it is for small problems
//! and for checking the other one. [`shapley_sampling`] draws random feature
//! orderings and converges to the same answer at a cost linear in the number
//! of features; it is what serving uses.

use serde::{Deserialize, Serialize};

/// Default number of permutations drawn by [`shapley_sampling`].
pub const DEFAULT_SAMPLES: usize = 200;

/// Enumerating more than this many features is refused; `2^n` value-function
/// evaluations stops being reasonable somewhere around here.
pub const MAX_EXACT_FEATURES: usize = 16;

/// One feature's contribution to one prediction.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Attribution {
    pub feature: String,
    /// The feature's value for this prediction.
    pub value: f64,
    /// How much this feature moved the prediction away from the baseline, in
    /// the prediction's own units.
    pub contribution: f64,
}

/// Everything one attribution run produced.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AttributionReport {
    /// Mean prediction over the reference set: what the model says about a
    /// typical case, and the point contributions are measured from.
    pub baseline: f64,
    pub prediction: f64,
    /// Sorted by absolute contribution, largest first.
    pub attributions: Vec<Attribution>,
    pub method: String,
    /// Reference rows the baseline was averaged over.
    pub reference_size: usize,
}

impl AttributionReport {
    pub fn total(&self) -> f64 {
        self.attributions.iter().map(|a| a.contribution).sum()
    }

    /// Gap between what the contributions explain and what actually happened.
    ///
    /// Exactly zero for [`shapley_exact`]; for the sampled estimator it is the
    /// remaining Monte Carlo error, and a useful thing to watch.
    pub fn residual(&self) -> f64 {
        (self.prediction - self.baseline) - self.total()
    }

    pub fn top(&self, n: usize) -> &[Attribution] {
        &self.attributions[..n.min(self.attributions.len())]
    }

    /// One sentence naming the inputs that moved this prediction most.
    pub fn summary(&self, units: &str) -> String {
        let gap = self.prediction - self.baseline;
        if self.attributions.is_empty() {
            return "No inputs could be attributed.".to_string();
        }
        let direction = if gap >= 0.0 { "above" } else { "below" };
        let drivers: Vec<String> = self
            .top(3)
            .iter()
            .filter(|a| a.contribution.abs() > 1e-9)
            .map(|a| {
                format!(
                    "{} ({}{:.0} {units})",
                    a.feature.replace('_', " "),
                    if a.contribution >= 0.0 { "+" } else { "" },
                    a.contribution
                )
            })
            .collect();

        if drivers.is_empty() {
            return format!(
                "This prediction is typical: {:.0} {units}, the same as an average case.",
                self.prediction
            );
        }
        format!(
            "{:.0} {units} is {:.0} {units} {direction} a typical {:.0}, driven mostly by {}.",
            self.prediction,
            gap.abs(),
            self.baseline,
            drivers.join(", ")
        )
    }
}

/// Build a report from raw contributions, sorted by importance.
fn report(
    method: &str,
    x: &[f64],
    names: &[String],
    contributions: Vec<f64>,
    baseline: f64,
    prediction: f64,
    reference_size: usize,
) -> AttributionReport {
    let mut attributions: Vec<Attribution> = contributions
        .into_iter()
        .enumerate()
        .map(|(i, contribution)| Attribution {
            feature: names
                .get(i)
                .cloned()
                .unwrap_or_else(|| format!("feature_{i}")),
            value: x.get(i).copied().unwrap_or(0.0),
            contribution,
        })
        .collect();
    attributions.sort_by(|a, b| {
        b.contribution
            .abs()
            .partial_cmp(&a.contribution.abs())
            .unwrap_or(std::cmp::Ordering::Equal)
            .then_with(|| a.feature.cmp(&b.feature))
    });

    AttributionReport {
        baseline,
        prediction,
        attributions,
        method: method.to_string(),
        reference_size,
    }
}

/// Mean prediction over the reference set.
pub fn baseline_of(f: &dyn Fn(&[f64]) -> f64, reference: &[Vec<f64>]) -> f64 {
    if reference.is_empty() {
        return 0.0;
    }
    reference.iter().map(|b| f(b)).sum::<f64>() / reference.len() as f64
}

/// Value of a coalition: the prediction with `present` features taken from `x`
/// and the rest from each reference row, averaged.
fn coalition_value(
    f: &dyn Fn(&[f64]) -> f64,
    x: &[f64],
    reference: &[Vec<f64>],
    present: &[bool],
    scratch: &mut Vec<f64>,
) -> f64 {
    let mut total = 0.0;
    for row in reference {
        scratch.clear();
        scratch.extend((0..x.len()).map(|i| if present[i] { x[i] } else { row[i] }));
        total += f(scratch);
    }
    total / reference.len() as f64
}

/// Exact Shapley values by enumerating every coalition.
///
/// Correct by construction, and `2^n` in the number of features — use it for
/// small models and to check [`shapley_sampling`].
pub fn shapley_exact(
    f: &dyn Fn(&[f64]) -> f64,
    x: &[f64],
    reference: &[Vec<f64>],
    names: &[String],
) -> Result<AttributionReport, AttributionError> {
    let n = validate(x, reference)?;
    if n > MAX_EXACT_FEATURES {
        return Err(AttributionError::TooManyFeatures {
            features: n,
            limit: MAX_EXACT_FEATURES,
        });
    }

    // Weight of a coalition of size s in the Shapley sum: s!(n-s-1)!/n!
    let mut factorial = vec![1.0f64; n + 1];
    for i in 1..=n {
        factorial[i] = factorial[i - 1] * i as f64;
    }
    let weight = |s: usize| factorial[s] * factorial[n - s - 1] / factorial[n];

    let mut phi = vec![0.0f64; n];
    let mut present = vec![false; n];
    let mut scratch = Vec::with_capacity(n);

    for mask in 0u32..(1u32 << n) {
        for (i, p) in present.iter_mut().enumerate() {
            *p = mask & (1 << i) != 0;
        }
        let size = present.iter().filter(|p| **p).count();
        let without = coalition_value(f, x, reference, &present, &mut scratch);

        for i in 0..n {
            if present[i] {
                continue;
            }
            present[i] = true;
            let with = coalition_value(f, x, reference, &present, &mut scratch);
            present[i] = false;
            phi[i] += weight(size) * (with - without);
        }
    }

    let baseline = baseline_of(f, reference);
    Ok(report(
        "shapley-exact",
        x,
        names,
        phi,
        baseline,
        f(x),
        reference.len(),
    ))
}

/// Shapley values estimated by sampling feature orderings.
///
/// Each permutation is walked from the reference row towards `x`, one feature
/// at a time; the change each step produces is that feature's contribution in
/// that ordering. Averaging over orderings converges to the Shapley value.
/// Every permutation is also walked in reverse, which costs nothing extra in
/// draws and cancels much of the variance.
pub fn shapley_sampling(
    f: &dyn Fn(&[f64]) -> f64,
    x: &[f64],
    reference: &[Vec<f64>],
    names: &[String],
    samples: usize,
    seed: u64,
) -> Result<AttributionReport, AttributionError> {
    let n = validate(x, reference)?;
    // Round up to a whole number of passes over the reference set. Each
    // permutation uses one reference row, so an uneven pass would compare
    // against a different mix of rows than the reported baseline averages
    // over — a systematic gap rather than honest sampling noise.
    let rows = reference.len();
    let pairs = (samples.max(2) / 2).max(1).div_ceil(rows) * rows;

    let mut rng = Rng::new(seed);
    let mut phi = vec![0.0f64; n];
    let mut order: Vec<usize> = (0..n).collect();
    let mut hybrid = vec![0.0f64; n];

    for pair in 0..pairs {
        rng.shuffle(&mut order);
        // Walk the reference set in order rather than sampling it, so every
        // row is used exactly the same number of times.
        let row = &reference[pair % rows];

        for reverse in [false, true] {
            hybrid.copy_from_slice(row);
            let mut previous = f(&hybrid);

            for step in 0..n {
                let i = if reverse {
                    order[n - 1 - step]
                } else {
                    order[step]
                };
                hybrid[i] = x[i];
                let current = f(&hybrid);
                phi[i] += current - previous;
                previous = current;
            }
        }
    }

    let draws = (pairs * 2) as f64;
    for v in phi.iter_mut() {
        *v /= draws;
    }

    let baseline = baseline_of(f, reference);
    Ok(report(
        "shapley-sampling",
        x,
        names,
        phi,
        baseline,
        f(x),
        reference.len(),
    ))
}

fn validate(x: &[f64], reference: &[Vec<f64>]) -> Result<usize, AttributionError> {
    if x.is_empty() {
        return Err(AttributionError::NoFeatures);
    }
    if reference.is_empty() {
        return Err(AttributionError::NoReference);
    }
    if let Some(bad) = reference.iter().find(|r| r.len() != x.len()) {
        return Err(AttributionError::ReferenceWidth {
            got: bad.len(),
            expected: x.len(),
        });
    }
    Ok(x.len())
}

/// Why an attribution could not be produced.
#[derive(Debug, Clone, PartialEq, thiserror::Error)]
pub enum AttributionError {
    #[error("cannot attribute a prediction with no features")]
    NoFeatures,
    #[error(
        "attribution needs a reference set to compare against; none was stored with the model"
    )]
    NoReference,
    #[error("reference row has {got} features, expected {expected}")]
    ReferenceWidth { got: usize, expected: usize },
    #[error(
        "exact attribution over {features} features is infeasible (limit {limit}); use sampling"
    )]
    TooManyFeatures { features: usize, limit: usize },
}

/// A small deterministic PRNG (SplitMix64).
///
/// Attribution must reproduce exactly — the same inputs have to give the same
/// explanation every time, or two people looking at one prediction see
/// different reasons for it.
struct Rng(u64);

impl Rng {
    fn new(seed: u64) -> Self {
        // A zero seed would make the generator degenerate.
        Self(seed ^ 0x9E37_79B9_7F4A_7C15)
    }

    fn next_u64(&mut self) -> u64 {
        self.0 = self.0.wrapping_add(0x9E37_79B9_7F4A_7C15);
        let mut z = self.0;
        z = (z ^ (z >> 30)).wrapping_mul(0xBF58_476D_1CE4_E5B9);
        z = (z ^ (z >> 27)).wrapping_mul(0x94D0_49BB_1331_11EB);
        z ^ (z >> 31)
    }

    /// Uniform in `0..n`.
    fn below(&mut self, n: usize) -> usize {
        if n <= 1 {
            return 0;
        }
        (self.next_u64() % n as u64) as usize
    }

    fn shuffle(&mut self, items: &mut [usize]) {
        for i in (1..items.len()).rev() {
            items.swap(i, self.below(i + 1));
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn names(n: usize) -> Vec<String> {
        (0..n).map(|i| format!("f{i}")).collect()
    }

    /// Reference rows spanning a range, so features actually vary.
    fn reference(n: usize, rows: usize) -> Vec<Vec<f64>> {
        (0..rows)
            .map(|r| (0..n).map(|i| (r as f64) - (i as f64) * 0.5).collect())
            .collect()
    }

    #[test]
    fn exact_attribution_of_a_linear_model_is_the_closed_form() {
        // For a linear model the Shapley value of feature i is exactly
        // w_i * (x_i - mean_reference(x_i)), which makes this checkable by
        // hand rather than against another implementation of the same idea.
        let w = [2.0, -3.0, 0.5];
        let f = move |x: &[f64]| w[0] * x[0] + w[1] * x[1] + w[2] * x[2] + 7.0;
        let refs = reference(3, 5);
        let x = vec![4.0, 1.0, -2.0];

        let report = shapley_exact(&f, &x, &refs, &names(3)).unwrap();

        for (i, wi) in w.iter().enumerate() {
            let mean: f64 = refs.iter().map(|r| r[i]).sum::<f64>() / refs.len() as f64;
            let expected = wi * (x[i] - mean);
            let actual = report
                .attributions
                .iter()
                .find(|a| a.feature == format!("f{i}"))
                .unwrap()
                .contribution;
            assert!(
                (actual - expected).abs() < 1e-9,
                "feature {i}: expected {expected}, got {actual}"
            );
        }
    }

    #[test]
    fn contributions_sum_to_the_gap_they_explain() {
        // Efficiency, on a model with interaction so the axiom is not trivial.
        let f = |x: &[f64]| x[0] * x[1] + x[2].powi(2) - x[3];
        let refs = reference(4, 4);
        let x = vec![3.0, -2.0, 1.5, 0.5];

        let report = shapley_exact(&f, &x, &refs, &names(4)).unwrap();
        assert!(
            report.residual().abs() < 1e-9,
            "exact attribution must leave no residual, got {}",
            report.residual()
        );
        assert!((report.total() - (report.prediction - report.baseline)).abs() < 1e-9);
    }

    #[test]
    fn an_ignored_feature_gets_exactly_nothing() {
        // Dummy axiom: feature 1 never enters the model.
        let f = |x: &[f64]| x[0] * 3.0 + x[2];
        let refs = reference(3, 4);
        let x = vec![1.0, 99.0, 2.0];

        let report = shapley_exact(&f, &x, &refs, &names(3)).unwrap();
        let unused = report
            .attributions
            .iter()
            .find(|a| a.feature == "f1")
            .unwrap();
        assert_eq!(unused.contribution, 0.0);
        assert_eq!(unused.value, 99.0, "its value is still reported");
    }

    #[test]
    fn interchangeable_features_get_equal_credit() {
        // Symmetry axiom: the model cannot tell 0 and 1 apart.
        let f = |x: &[f64]| (x[0] + x[1]) * 2.0 + x[2];
        let refs = vec![vec![0.0, 0.0, 0.0], vec![1.0, 1.0, 1.0]];
        let x = vec![5.0, 5.0, 1.0];

        let report = shapley_exact(&f, &x, &refs, &names(3)).unwrap();
        let a = report
            .attributions
            .iter()
            .find(|a| a.feature == "f0")
            .unwrap();
        let b = report
            .attributions
            .iter()
            .find(|a| a.feature == "f1")
            .unwrap();
        assert!((a.contribution - b.contribution).abs() < 1e-12);
    }

    #[test]
    fn sampling_converges_to_the_exact_answer() {
        // A model with a genuine interaction, where a naive per-feature
        // difference would disagree with Shapley.
        let f = |x: &[f64]| x[0] * x[1] * 2.0 - x[2] + x[3] * x[3];
        let refs = reference(4, 6);
        let x = vec![2.5, -1.0, 3.0, 1.5];

        let exact = shapley_exact(&f, &x, &refs, &names(4)).unwrap();
        let sampled = shapley_sampling(&f, &x, &refs, &names(4), 4000, 42).unwrap();

        let scale = (exact.prediction - exact.baseline).abs().max(1.0);
        for e in &exact.attributions {
            let s = sampled
                .attributions
                .iter()
                .find(|a| a.feature == e.feature)
                .unwrap();
            assert!(
                (e.contribution - s.contribution).abs() < 0.05 * scale,
                "{}: exact {}, sampled {}",
                e.feature,
                e.contribution,
                s.contribution
            );
        }
        assert!(
            sampled.residual().abs() < 0.05 * scale,
            "residual {}",
            sampled.residual()
        );
    }

    #[test]
    fn sampling_is_exactly_reproducible() {
        // A three-way interaction, so ordering genuinely matters: with only a
        // pairwise one, walking each permutation forwards and backwards
        // cancels the ordering entirely and every seed would agree.
        let f = |x: &[f64]| x[0] * x[1] * x[2] + x[3];
        let refs = reference(4, 5);
        let x = vec![1.0, 2.0, 3.0, 4.0];

        let a = shapley_sampling(&f, &x, &refs, &names(4), 20, 7).unwrap();
        let b = shapley_sampling(&f, &x, &refs, &names(4), 20, 7).unwrap();
        assert_eq!(
            a.attributions, b.attributions,
            "same seed, same explanation"
        );

        // A different seed draws different orderings, so the seed is doing work.
        let c = shapley_sampling(&f, &x, &refs, &names(4), 20, 8).unwrap();
        assert_ne!(a.attributions, c.attributions);

        // Both remain valid attributions of the same prediction.
        assert!((a.prediction - c.prediction).abs() < 1e-12);
        assert!((a.baseline - c.baseline).abs() < 1e-12);
    }

    #[test]
    fn sampling_is_exact_for_an_additive_model_once_the_reference_is_covered() {
        // With no interactions every ordering gives the same marginal, so once
        // each reference row has been used the estimate is not an estimate.
        let f = |x: &[f64]| 3.0 * x[0] - 2.0 * x[1] + 0.5 * x[2];
        let refs = reference(3, 4);
        let x = vec![2.0, 5.0, -1.0];

        // Eight draws is four permutations, which is exactly one pass over
        // the four reference rows.
        let exact = shapley_exact(&f, &x, &refs, &names(3)).unwrap();
        let sampled = shapley_sampling(&f, &x, &refs, &names(3), 8, 1).unwrap();
        for e in &exact.attributions {
            let s = sampled
                .attributions
                .iter()
                .find(|a| a.feature == e.feature)
                .unwrap();
            assert!(
                (e.contribution - s.contribution).abs() < 1e-9,
                "{}: {} vs {}",
                e.feature,
                e.contribution,
                s.contribution
            );
        }
    }

    #[test]
    fn attributions_are_ordered_by_importance() {
        let f = |x: &[f64]| 10.0 * x[0] + 0.1 * x[1] - 5.0 * x[2];
        let refs = reference(3, 4);
        let report = shapley_exact(&f, &[1.0, 1.0, 1.0], &refs, &names(3)).unwrap();

        let magnitudes: Vec<f64> = report
            .attributions
            .iter()
            .map(|a| a.contribution.abs())
            .collect();
        for w in magnitudes.windows(2) {
            assert!(w[0] >= w[1], "not sorted: {magnitudes:?}");
        }
        assert_eq!(report.top(2).len(), 2);
        assert_eq!(
            report.top(99).len(),
            3,
            "asking for too many is not an error"
        );
    }

    #[test]
    fn unusable_input_is_refused_rather_than_guessed() {
        let f = |x: &[f64]| x.iter().sum();
        assert_eq!(
            shapley_exact(&f, &[], &reference(3, 2), &names(3)).unwrap_err(),
            AttributionError::NoFeatures
        );
        assert_eq!(
            shapley_exact(&f, &[1.0], &[], &names(1)).unwrap_err(),
            AttributionError::NoReference
        );
        assert_eq!(
            shapley_sampling(&f, &[1.0, 2.0], &[vec![0.0]], &names(2), 10, 1).unwrap_err(),
            AttributionError::ReferenceWidth {
                got: 1,
                expected: 2
            }
        );

        let wide = vec![0.0; MAX_EXACT_FEATURES + 1];
        assert!(matches!(
            shapley_exact(&f, &wide, &[wide.clone()], &names(wide.len())).unwrap_err(),
            AttributionError::TooManyFeatures { .. }
        ));
        // Sampling has no such limit.
        assert!(shapley_sampling(&f, &wide, &[wide.clone()], &names(wide.len()), 10, 1).is_ok());
    }

    #[test]
    fn summaries_name_the_drivers() {
        let f = |x: &[f64]| 100.0 * x[0] + 1.0 * x[1];
        let refs = vec![vec![0.0, 0.0], vec![0.0, 0.0]];
        let report = shapley_exact(&f, &[5.0, 3.0], &refs, &names(2)).unwrap();

        let text = report.summary("kg/ha");
        assert!(text.contains("above"), "{text}");
        assert!(text.contains("f0"), "{text}");
        assert!(text.contains("+500"), "{text}");

        // A prediction that matches the baseline says so rather than inventing
        // a driver.
        let flat = shapley_exact(&f, &[0.0, 0.0], &refs, &names(2)).unwrap();
        assert!(
            flat.summary("kg/ha").contains("typical"),
            "{}",
            flat.summary("kg/ha")
        );
    }

    #[test]
    fn the_prng_shuffles_without_losing_anything() {
        let mut rng = Rng::new(0);
        let mut items: Vec<usize> = (0..12).collect();
        rng.shuffle(&mut items);

        let mut sorted = items.clone();
        sorted.sort_unstable();
        assert_eq!(
            sorted,
            (0..12).collect::<Vec<_>>(),
            "shuffle lost an element"
        );
        assert_ne!(items, sorted, "a shuffle that changes nothing is not one");

        // Even a zero seed must not produce a degenerate stream.
        let mut zero = Rng::new(0);
        let draws: Vec<u64> = (0..4).map(|_| zero.next_u64()).collect();
        assert!(draws.windows(2).all(|w| w[0] != w[1]));
        assert!((0..100).all(|_| rng.below(5) < 5));
        assert_eq!(rng.below(1), 0, "a single choice is always index zero");
    }
}
