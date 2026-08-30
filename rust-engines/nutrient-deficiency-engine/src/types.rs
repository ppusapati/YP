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
    Manganese = 7,
    Zinc = 8,
    Boron = 9,
}

/// Total number of nutrient classes.
pub const NUM_NUTRIENT_CLASSES: usize = 10;

impl Nutrient {
    /// All nutrient variants in index order.
    pub const ALL: [Nutrient; NUM_NUTRIENT_CLASSES] = [
        Self::Nitrogen, Self::Phosphorus, Self::Potassium, Self::Calcium,
        Self::Magnesium, Self::Sulfur, Self::Iron, Self::Manganese,
        Self::Zinc, Self::Boron,
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
}

/// Ordinal severity level for nutrient deficiency.
///
/// Derived via ordinal regression: the model outputs cumulative
/// probabilities for P(severity >= Mild), P(severity >= Moderate),
/// P(severity >= Severe), and the severity is the highest threshold
/// exceeded at 0.5.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Hash, Serialize, Deserialize)]
pub enum DeficiencySeverity {
    None = 0,
    Mild = 1,
    Moderate = 2,
    Severe = 3,
}

/// Number of ordinal severity thresholds (Mild, Moderate, Severe).
pub const NUM_SEVERITY_THRESHOLDS: usize = 3;

impl DeficiencySeverity {
    /// Determine severity from ordinal regression cumulative probabilities.
    ///
    /// `cumulative_probs` should have 3 values:
    ///   [P(sev >= Mild), P(sev >= Moderate), P(sev >= Severe)]
    pub fn from_ordinal_probs(cumulative_probs: &[f32]) -> Self {
        if cumulative_probs.len() >= 3 && cumulative_probs[2] >= 0.5 {
            Self::Severe
        } else if cumulative_probs.len() >= 2 && cumulative_probs[1] >= 0.5 {
            Self::Moderate
        } else if !cumulative_probs.is_empty() && cumulative_probs[0] >= 0.5 {
            Self::Mild
        } else {
            Self::None
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

/// Result for a single detected nutrient deficiency.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct NutrientDeficiency {
    /// The deficient nutrient.
    pub nutrient: Nutrient,
    /// Detection confidence (0.0-1.0).
    pub confidence: f32,
    /// Deficiency severity from ordinal regression.
    pub severity: DeficiencySeverity,
    /// Cumulative ordinal probabilities [P(>=Mild), P(>=Moderate), P(>=Severe)].
    pub ordinal_probs: Vec<f32>,
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
    fn test_severity_from_ordinal_probs() {
        assert_eq!(
            DeficiencySeverity::from_ordinal_probs(&[0.9, 0.8, 0.6]),
            DeficiencySeverity::Severe
        );
        assert_eq!(
            DeficiencySeverity::from_ordinal_probs(&[0.9, 0.7, 0.3]),
            DeficiencySeverity::Moderate
        );
        assert_eq!(
            DeficiencySeverity::from_ordinal_probs(&[0.6, 0.3, 0.1]),
            DeficiencySeverity::Mild
        );
        assert_eq!(
            DeficiencySeverity::from_ordinal_probs(&[0.2, 0.1, 0.05]),
            DeficiencySeverity::None
        );
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
}
