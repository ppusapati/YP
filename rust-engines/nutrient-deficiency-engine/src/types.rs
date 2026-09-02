//! Nutrient deficiency detection types, enums, and result structures.
//!
//! Migrated from Python `nutrient_deficiency/model.py` and `nutrient_deficiency/inference.py`.

use serde::{Deserialize, Serialize};

/// The 10 nutrient classes monitored for deficiency.
///
/// Matches the Python `NUTRIENT_CLASSES` list exactly.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
#[repr(u8)]
pub enum Nutrient {
    Nitrogen = 0,
    Phosphorus = 1,
    Potassium = 2,
    Calcium = 3,
    Magnesium = 4,
    Sulfur = 5,
    Iron = 6,
    Zinc = 7,
    Manganese = 8,
    Boron = 9,
}

/// Total number of nutrient classes.
pub const NUM_NUTRIENT_CLASSES: usize = 10;

impl Nutrient {
    /// All nutrient variants in index order.
    pub const ALL: [Nutrient; NUM_NUTRIENT_CLASSES] = [
        Self::Nitrogen, Self::Phosphorus, Self::Potassium, Self::Calcium,
        Self::Magnesium, Self::Sulfur, Self::Iron, Self::Zinc,
        Self::Manganese, Self::Boron,
    ];

    /// Human-readable display name.
    pub fn label(&self) -> &'static str {
        match self {
            Self::Nitrogen => "Nitrogen",
            Self::Phosphorus => "Phosphorus",
            Self::Potassium => "Potassium",
            Self::Calcium => "Calcium",
            Self::Magnesium => "Magnesium",
            Self::Sulfur => "Sulfur",
            Self::Iron => "Iron",
            Self::Manganese => "Manganese",
            Self::Zinc => "Zinc",
            Self::Boron => "Boron",
        }
    }

    /// Chemical symbol.
    pub fn symbol(&self) -> &'static str {
        match self {
            Self::Nitrogen => "N",
            Self::Phosphorus => "P",
            Self::Potassium => "K",
            Self::Calcium => "Ca",
            Self::Magnesium => "Mg",
            Self::Sulfur => "S",
            Self::Iron => "Fe",
            Self::Manganese => "Mn",
            Self::Zinc => "Zn",
            Self::Boron => "B",
        }
    }

    /// Whether this is a macronutrient (N, P, K, Ca, Mg, S).
    pub fn is_macronutrient(&self) -> bool {
        matches!(
            self,
            Self::Nitrogen
                | Self::Phosphorus
                | Self::Potassium
                | Self::Calcium
                | Self::Magnesium
                | Self::Sulfur
        )
    }

    /// Get nutrient from index.
    pub fn from_index(idx: usize) -> Option<Self> {
        Self::ALL.get(idx).copied()
    }

    /// Get numeric index.
    pub fn index(&self) -> usize {
        *self as usize
    }

    /// Supplementation recommendation for this nutrient deficiency.
    ///
    /// Returns a treatment plan string matching the Python `SUPPLEMENTATION_MAP`.
    pub fn recommendation(&self) -> &'static str {
        match self {
            Self::Nitrogen => "Apply urea at 50-100 kg/ha or ammonium sulfate. Split application recommended.",
            Self::Phosphorus => "Apply triple superphosphate or DAP at 40-80 kg/ha.",
            Self::Potassium => "Apply muriate of potash (KCl) at 50-100 kg/ha.",
            Self::Calcium => "Apply gypsum or agricultural lime at 1-2 tonnes/ha.",
            Self::Magnesium => "Apply dolomitic limestone or Epsom salt foliar spray.",
            Self::Sulfur => "Apply elemental sulfur or gypsum at 20-40 kg/ha.",
            Self::Iron => "Apply chelated iron (Fe-EDDHA) foliar spray at 0.5-1%.",
            Self::Zinc => "Apply zinc sulfate at 10-25 kg/ha or chelated zinc foliar spray.",
            Self::Manganese => "Apply manganese sulfate at 5-15 kg/ha or foliar spray at 0.5%.",
            Self::Boron => "Apply borax at 5-15 kg/ha. Caution: narrow margin between deficiency and toxicity.",
        }
    }
}

/// Severity level for nutrient deficiency.
///
/// Derived via softmax + argmax: the model outputs 4 logits
/// (one per severity class), softmax converts them to probabilities,
/// and argmax selects the predicted class.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Hash, Serialize, Deserialize)]
pub enum DeficiencySeverity {
    None = 0,
    Mild = 1,
    Moderate = 2,
    Severe = 3,
}

/// Number of severity classes (None, Mild, Moderate, Severe).
pub const NUM_SEVERITY_CLASSES: usize = 4;

impl DeficiencySeverity {
    /// All severity variants in index order.
    pub const ALL: [DeficiencySeverity; NUM_SEVERITY_CLASSES] = [
        Self::None,
        Self::Mild,
        Self::Moderate,
        Self::Severe,
    ];

    /// Determine severity from softmax logits via argmax.
    ///
    /// `logits` should have 4 values corresponding to [None, Mild, Moderate, Severe].
    /// Softmax is applied internally to convert logits to probabilities,
    /// then argmax selects the predicted severity class.
    pub fn from_softmax_logits(logits: &[f32]) -> (Self, Vec<f32>) {
        let probs = softmax(logits);
        let argmax_idx = probs
            .iter()
            .enumerate()
            .max_by(|(_, a), (_, b)| a.partial_cmp(b).unwrap_or(std::cmp::Ordering::Equal))
            .map(|(i, _)| i)
            .unwrap_or(0);
        let severity = Self::from_index(argmax_idx);
        (severity, probs)
    }

    /// Get severity from a class index (0-3).
    pub fn from_index(idx: usize) -> Self {
        match idx {
            0 => Self::None,
            1 => Self::Mild,
            2 => Self::Moderate,
            3 => Self::Severe,
            _ => Self::None,
        }
    }

    /// Determine severity from a raw confidence score (fallback).
    pub fn from_confidence(confidence: f32) -> Self {
        if confidence < 0.3 {
            Self::None
        } else if confidence < 0.5 {
            Self::Mild
        } else if confidence < 0.75 {
            Self::Moderate
        } else {
            Self::Severe
        }
    }

    /// Human-readable label.
    pub fn label(&self) -> &'static str {
        match self {
            Self::None => "NONE",
            Self::Mild => "MILD",
            Self::Moderate => "MODERATE",
            Self::Severe => "SEVERE",
        }
    }

    /// Numeric ordinal value (0-3).
    pub fn ordinal(&self) -> u8 {
        *self as u8
    }
}

/// Compute softmax over a slice of logits.
fn softmax(logits: &[f32]) -> Vec<f32> {
    if logits.is_empty() {
        return vec![];
    }
    let max_logit = logits.iter().cloned().fold(f32::NEG_INFINITY, f32::max);
    let exps: Vec<f32> = logits.iter().map(|&l| (l - max_logit).exp()).collect();
    let sum: f32 = exps.iter().sum();
    exps.iter().map(|&e| e / sum).collect()
}

/// Result for a single detected nutrient deficiency.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct NutrientDeficiency {
    /// The deficient nutrient.
    pub nutrient: Nutrient,
    /// Detection confidence (0.0-1.0).
    pub confidence: f32,
    /// Deficiency severity from softmax classification.
    pub severity: DeficiencySeverity,
    /// Softmax probabilities for each severity class [None, Mild, Moderate, Severe].
    pub severity_probs: Vec<f32>,
    /// Supplementation recommendation for this nutrient deficiency.
    pub recommendation: String,
}

/// Complete deficiency detection result for one image.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DeficiencyResult {
    /// All detected deficiencies, sorted by severity descending then confidence.
    pub deficiencies: Vec<NutrientDeficiency>,
    /// Whether the plant appears healthy (no deficiencies detected).
    pub is_healthy: bool,
    /// Worst severity among detected deficiencies.
    pub worst_severity: DeficiencySeverity,
    /// Highest confidence among detected deficiencies.
    pub overall_confidence: f32,
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_nutrient_count() {
        assert_eq!(Nutrient::ALL.len(), NUM_NUTRIENT_CLASSES);
    }

    #[test]
    fn test_nutrient_roundtrip() {
        for (i, nutrient) in Nutrient::ALL.iter().enumerate() {
            assert_eq!(nutrient.index(), i);
            assert_eq!(Nutrient::from_index(i), Some(*nutrient));
        }
    }

    #[test]
    fn test_macronutrients() {
        assert!(Nutrient::Nitrogen.is_macronutrient());
        assert!(Nutrient::Potassium.is_macronutrient());
        assert!(!Nutrient::Iron.is_macronutrient());
        assert!(!Nutrient::Zinc.is_macronutrient());
    }

    #[test]
    fn test_severity_from_softmax_logits() {
        // Highest logit at index 3 (Severe)
        let (sev, probs) = DeficiencySeverity::from_softmax_logits(&[-1.0, 0.0, 1.0, 3.0]);
        assert_eq!(sev, DeficiencySeverity::Severe);
        assert_eq!(probs.len(), 4);
        let sum: f32 = probs.iter().sum();
        assert!((sum - 1.0).abs() < 1e-5);

        // Highest logit at index 2 (Moderate)
        let (sev, _) = DeficiencySeverity::from_softmax_logits(&[-1.0, 0.0, 3.0, 1.0]);
        assert_eq!(sev, DeficiencySeverity::Moderate);

        // Highest logit at index 1 (Mild)
        let (sev, _) = DeficiencySeverity::from_softmax_logits(&[-1.0, 3.0, 0.0, 1.0]);
        assert_eq!(sev, DeficiencySeverity::Mild);

        // Highest logit at index 0 (None)
        let (sev, _) = DeficiencySeverity::from_softmax_logits(&[5.0, 0.0, 1.0, 1.0]);
        assert_eq!(sev, DeficiencySeverity::None);
    }

    #[test]
    fn test_severity_from_confidence() {
        assert_eq!(DeficiencySeverity::from_confidence(0.1), DeficiencySeverity::None);
        assert_eq!(DeficiencySeverity::from_confidence(0.4), DeficiencySeverity::Mild);
        assert_eq!(DeficiencySeverity::from_confidence(0.6), DeficiencySeverity::Moderate);
        assert_eq!(DeficiencySeverity::from_confidence(0.9), DeficiencySeverity::Severe);
    }

    #[test]
    fn test_chemical_symbols() {
        assert_eq!(Nutrient::Nitrogen.symbol(), "N");
        assert_eq!(Nutrient::Potassium.symbol(), "K");
        assert_eq!(Nutrient::Iron.symbol(), "Fe");
    }

    #[test]
    fn test_nutrient_index_order() {
        // Must match Python: N=0, P=1, K=2, Ca=3, Mg=4, S=5, Fe=6, Zn=7, Mn=8, B=9
        assert_eq!(Nutrient::Nitrogen.index(), 0);
        assert_eq!(Nutrient::Phosphorus.index(), 1);
        assert_eq!(Nutrient::Potassium.index(), 2);
        assert_eq!(Nutrient::Calcium.index(), 3);
        assert_eq!(Nutrient::Magnesium.index(), 4);
        assert_eq!(Nutrient::Sulfur.index(), 5);
        assert_eq!(Nutrient::Iron.index(), 6);
        assert_eq!(Nutrient::Zinc.index(), 7);
        assert_eq!(Nutrient::Manganese.index(), 8);
        assert_eq!(Nutrient::Boron.index(), 9);
    }

    #[test]
    fn test_recommendations() {
        assert!(Nutrient::Nitrogen.recommendation().contains("urea"));
        assert!(Nutrient::Phosphorus.recommendation().contains("superphosphate"));
        assert!(Nutrient::Potassium.recommendation().contains("KCl"));
        assert!(Nutrient::Iron.recommendation().contains("Fe-EDDHA"));
        assert!(Nutrient::Boron.recommendation().contains("borax"));
    }
}
