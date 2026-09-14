//! How much two reviewers agree, and whether that is more than chance.
//!
//! Raw agreement flatters a labelling task badly. If nine samples in ten are
//! healthy leaves, two reviewers who both answer "healthy" every time agree 90%
//! of the time while having demonstrated nothing at all. Cohen's kappa measures
//! agreement *above* what their individual answer rates would produce by
//! chance, which is why it is the number worth reporting to someone deciding
//! whether a label set can be trusted.
//!
//! Kappa needs care at the edges. Two reviewers who both answer one class for
//! everything have expected agreement of 1, so the usual formula divides by
//! zero; the convention taken here is that perfect agreement scores 1 and
//! anything else scores 0, since with no variation there is nothing to agree
//! about.

use std::collections::{BTreeMap, BTreeSet};

use serde::{Deserialize, Serialize};

/// One sample as two reviewers labelled it.
#[derive(Debug, Clone, PartialEq)]
pub struct LabelPair {
    pub sample_id: String,
    pub first: String,
    pub second: String,
}

/// Agreement between reviewers over a set of doubly-reviewed samples.
#[derive(Debug, Clone, Default, PartialEq, Serialize, Deserialize)]
pub struct AgreementReport {
    /// Samples two reviewers both labelled.
    pub compared: usize,
    /// Share where they chose the same label.
    pub raw_agreement: f64,
    /// Cohen's kappa: agreement above chance.
    pub kappa: f64,
    /// A plain reading of the kappa, by the usual Landis–Koch bands.
    pub strength: String,
    /// Label pairs they disagreed on, most frequent first.
    pub disagreements: Vec<Disagreement>,
}

/// One pair of labels reviewers chose differently, and how often.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Disagreement {
    pub first: String,
    pub second: String,
    pub count: usize,
}

/// Landis–Koch bands, which is what most readers will assume is meant.
pub fn strength_of(kappa: f64) -> &'static str {
    match kappa {
        k if k < 0.0 => "worse than chance",
        k if k < 0.21 => "slight",
        k if k < 0.41 => "fair",
        k if k < 0.61 => "moderate",
        k if k < 0.81 => "substantial",
        _ => "almost perfect",
    }
}

/// Compare two reviewers' labels across the samples both reviewed.
pub fn agreement(pairs: &[LabelPair]) -> AgreementReport {
    if pairs.is_empty() {
        return AgreementReport {
            strength: "no overlap".to_string(),
            ..Default::default()
        };
    }

    let n = pairs.len() as f64;
    let agreed = pairs.iter().filter(|p| p.first == p.second).count();
    let raw = agreed as f64 / n;

    // Marginal rates: how often each reviewer chose each label at all. Chance
    // agreement is the probability they would coincide labelling independently
    // at those rates.
    let labels: BTreeSet<&str> = pairs
        .iter()
        .flat_map(|p| [p.first.as_str(), p.second.as_str()])
        .collect();
    let mut first_counts: BTreeMap<&str, usize> = BTreeMap::new();
    let mut second_counts: BTreeMap<&str, usize> = BTreeMap::new();
    for p in pairs {
        *first_counts.entry(p.first.as_str()).or_default() += 1;
        *second_counts.entry(p.second.as_str()).or_default() += 1;
    }
    let expected: f64 = labels
        .iter()
        .map(|l| {
            let a = *first_counts.get(l).unwrap_or(&0) as f64 / n;
            let b = *second_counts.get(l).unwrap_or(&0) as f64 / n;
            a * b
        })
        .sum();

    // With no variation there is nothing to agree about: call unanimity
    // perfect and anything else zero, rather than dividing by zero.
    let kappa = if (1.0 - expected).abs() < f64::EPSILON {
        if agreed == pairs.len() {
            1.0
        } else {
            0.0
        }
    } else {
        (raw - expected) / (1.0 - expected)
    };

    let mut counts: BTreeMap<(&str, &str), usize> = BTreeMap::new();
    for p in pairs.iter().filter(|p| p.first != p.second) {
        *counts
            .entry((p.first.as_str(), p.second.as_str()))
            .or_default() += 1;
    }
    let mut disagreements: Vec<Disagreement> = counts
        .into_iter()
        .map(|((first, second), count)| Disagreement {
            first: first.to_string(),
            second: second.to_string(),
            count,
        })
        .collect();
    disagreements.sort_by(|a, b| {
        b.count
            .cmp(&a.count)
            .then_with(|| a.first.cmp(&b.first))
            .then_with(|| a.second.cmp(&b.second))
    });

    AgreementReport {
        compared: pairs.len(),
        raw_agreement: raw,
        kappa,
        strength: strength_of(kappa).to_string(),
        disagreements,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn pair(id: &str, a: &str, b: &str) -> LabelPair {
        LabelPair {
            sample_id: id.to_string(),
            first: a.to_string(),
            second: b.to_string(),
        }
    }

    #[test]
    fn total_agreement_on_a_varied_set_is_perfect() {
        let pairs = vec![
            pair("1", "healthy", "healthy"),
            pair("2", "rust", "rust"),
            pair("3", "blight", "blight"),
            pair("4", "rust", "rust"),
        ];
        let report = agreement(&pairs);
        assert_eq!(report.compared, 4);
        assert!((report.raw_agreement - 1.0).abs() < 1e-12);
        assert!((report.kappa - 1.0).abs() < 1e-12);
        assert_eq!(report.strength, "almost perfect");
        assert!(report.disagreements.is_empty());
    }

    #[test]
    fn raw_agreement_flatters_an_imbalanced_task() {
        // Nine healthy leaves and one rust. The second reviewer answers
        // "healthy" every time: 90% raw agreement, having demonstrated
        // nothing. Kappa should say so.
        let mut pairs: Vec<LabelPair> = (0..9)
            .map(|i| pair(&i.to_string(), "healthy", "healthy"))
            .collect();
        pairs.push(pair("9", "rust", "healthy"));

        let report = agreement(&pairs);
        assert!((report.raw_agreement - 0.9).abs() < 1e-12);
        assert!(
            report.kappa < 0.2,
            "kappa {} should expose the imbalance",
            report.kappa
        );
        assert_eq!(report.strength, "slight");
    }

    #[test]
    fn unanimity_on_a_single_label_is_not_evidence_but_is_not_a_failure() {
        // Both reviewers answer "healthy" for everything. Expected agreement
        // is 1, so the usual formula divides by zero.
        let pairs: Vec<LabelPair> = (0..5)
            .map(|i| pair(&i.to_string(), "healthy", "healthy"))
            .collect();
        let report = agreement(&pairs);
        assert!((report.raw_agreement - 1.0).abs() < 1e-12);
        assert!((report.kappa - 1.0).abs() < 1e-12);
        assert!(report.kappa.is_finite());
    }

    #[test]
    fn total_disagreement_scores_below_chance() {
        let pairs = vec![
            pair("1", "healthy", "rust"),
            pair("2", "rust", "healthy"),
            pair("3", "healthy", "rust"),
            pair("4", "rust", "healthy"),
        ];
        let report = agreement(&pairs);
        assert_eq!(report.raw_agreement, 0.0);
        assert!(report.kappa < 0.0, "kappa {}", report.kappa);
        assert_eq!(report.strength, "worse than chance");
    }

    #[test]
    fn kappa_matches_a_worked_example() {
        // The textbook 2x2 case: 20 agree positive, 15 agree negative,
        // 10 and 5 disagree. Raw = 35/50 = 0.70.
        // Expected = (30/50)(25/50) + (20/50)(25/50) = 0.30 + 0.20 = 0.50.
        // Kappa = (0.70 - 0.50) / (1 - 0.50) = 0.40.
        let mut pairs = Vec::new();
        for i in 0..20 {
            pairs.push(pair(&format!("a{i}"), "yes", "yes"));
        }
        for i in 0..15 {
            pairs.push(pair(&format!("b{i}"), "no", "no"));
        }
        for i in 0..10 {
            pairs.push(pair(&format!("c{i}"), "yes", "no"));
        }
        for i in 0..5 {
            pairs.push(pair(&format!("d{i}"), "no", "yes"));
        }

        let report = agreement(&pairs);
        assert!((report.raw_agreement - 0.70).abs() < 1e-12);
        assert!((report.kappa - 0.40).abs() < 1e-12, "kappa {}", report.kappa);
        assert_eq!(report.strength, "fair");
    }

    #[test]
    fn disagreements_are_ranked_so_the_worst_confusion_is_obvious() {
        let mut pairs = vec![pair("1", "rust", "blight"); 5];
        for (i, p) in pairs.iter_mut().enumerate() {
            p.sample_id = format!("r{i}");
        }
        pairs.push(pair("x", "healthy", "rust"));
        pairs.push(pair("y", "healthy", "healthy"));

        let report = agreement(&pairs);
        assert_eq!(report.disagreements.len(), 2);
        assert_eq!(report.disagreements[0].count, 5);
        assert_eq!(report.disagreements[0].first, "rust");
        assert_eq!(report.disagreements[0].second, "blight");
        assert_eq!(report.disagreements[1].count, 1);
    }

    #[test]
    fn no_overlap_is_reported_rather_than_scored() {
        let report = agreement(&[]);
        assert_eq!(report.compared, 0);
        assert_eq!(report.kappa, 0.0);
        assert_eq!(report.strength, "no overlap");
        assert!(report.disagreements.is_empty());
    }

    #[test]
    fn strength_bands_cover_the_range() {
        assert_eq!(strength_of(-0.1), "worse than chance");
        assert_eq!(strength_of(0.0), "slight");
        assert_eq!(strength_of(0.3), "fair");
        assert_eq!(strength_of(0.5), "moderate");
        assert_eq!(strength_of(0.7), "substantial");
        assert_eq!(strength_of(0.95), "almost perfect");
        // The boundaries belong to the band above.
        assert_eq!(strength_of(0.21), "fair");
        assert_eq!(strength_of(0.81), "almost perfect");
    }
}
