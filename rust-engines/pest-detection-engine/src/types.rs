//! Pest detection types, enums, and result structures.
//!
//! Migrated from Python `pest_detection/model.py` and `pest_detection/inference.py`.

use serde::{Deserialize, Serialize};

/// All 23 pest species classes.
///
/// Matches the Python `PEST_CLASSES` list exactly.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
#[repr(u8)]
pub enum PestSpecies {
    Aphid = 0,
    Armyworm = 1,
    BeetleColoradoPotato = 2,
    BeetleFlea = 3,
    BeetleJapanese = 4,
    Bollworm = 5,
    BorerCorn = 6,
    BorerStem = 7,
    Caterpillar = 8,
    Cutworm = 9,
    Grasshopper = 10,
    Leafhopper = 11,
    Leafminer = 12,
    Mealybug = 13,
    MiteSpider = 14,
    MothCodling = 15,
    NematodeRootKnot = 16,
    ScaleInsect = 17,
    Slug = 18,
    Thrips = 19,
    Weevil = 20,
    Whitefly = 21,
    NoPest = 22,
}

/// Total number of pest classes.
pub const NUM_PEST_CLASSES: usize = 23;

impl PestSpecies {
    /// All pest species variants in index order.
    pub const ALL: [PestSpecies; NUM_PEST_CLASSES] = [
        Self::Aphid, Self::Armyworm, Self::BeetleColoradoPotato, Self::BeetleFlea,
        Self::BeetleJapanese, Self::Bollworm, Self::BorerCorn, Self::BorerStem,
        Self::Caterpillar, Self::Cutworm, Self::Grasshopper, Self::Leafhopper,
        Self::Leafminer, Self::Mealybug, Self::MiteSpider, Self::MothCodling,
        Self::NematodeRootKnot, Self::ScaleInsect, Self::Slug, Self::Thrips,
        Self::Weevil, Self::Whitefly, Self::NoPest,
    ];

    /// Human-readable label matching the Python class name.
    pub fn label(&self) -> &'static str {
        match self {
            Self::Aphid => "Aphid",
            Self::Armyworm => "Armyworm",
            Self::BeetleColoradoPotato => "Beetle_Colorado_Potato",
            Self::BeetleFlea => "Beetle_Flea",
            Self::BeetleJapanese => "Beetle_Japanese",
            Self::Bollworm => "Bollworm",
            Self::BorerCorn => "Borer_Corn",
            Self::BorerStem => "Borer_Stem",
            Self::Caterpillar => "Caterpillar",
            Self::Cutworm => "Cutworm",
            Self::Grasshopper => "Grasshopper",
            Self::Leafhopper => "Leafhopper",
            Self::Leafminer => "Leafminer",
            Self::Mealybug => "Mealybug",
            Self::MiteSpider => "Mite_Spider",
            Self::MothCodling => "Moth_Codling",
            Self::NematodeRootKnot => "Nematode_Root_Knot",
            Self::ScaleInsect => "Scale_Insect",
            Self::Slug => "Slug",
            Self::Thrips => "Thrips",
            Self::Weevil => "Weevil",
            Self::Whitefly => "Whitefly",
            Self::NoPest => "No_Pest",
        }
    }

    /// Treatment recommendation for this pest.
    ///
    /// Migrated from Python `TREATMENT_RECOMMENDATIONS` dict.
    pub fn treatment(&self) -> &'static str {
        match self {
            Self::Aphid => "Apply neem oil spray or introduce ladybugs as biological control. For severe infestations, use imidacloprid.",
            Self::Armyworm => "Apply Bt (Bacillus thuringiensis) for larvae. Use pheromone traps for monitoring adult moths.",
            Self::BeetleColoradoPotato => "Hand-pick adults, apply spinosad or neem. Rotate crops to break lifecycle.",
            Self::BeetleFlea => "Use row covers for seedlings. Apply diatomaceous earth or pyrethrin spray.",
            Self::BeetleJapanese => "Apply milky spore to soil for grubs. Use neem oil or carbaryl for adults.",
            Self::Bollworm => "Apply Bt sprays targeting larvae. Use pheromone traps for monitoring.",
            Self::BorerCorn => "Apply Bt at egg hatch. Use Trichogramma wasps as biological control.",
            Self::BorerStem => "Remove and destroy infested stems. Apply systemic insecticide at planting.",
            Self::Caterpillar => "Apply Bt (Bacillus thuringiensis). Hand-pick if infestation is small.",
            Self::Cutworm => "Use cardboard collars around seedling stems. Apply Bt or spinosad to soil surface.",
            Self::Grasshopper => "Apply Nosema locustae bait for biological control. Use carbaryl for severe outbreaks.",
            Self::Leafhopper => "Apply kaolin clay spray as deterrent. Use insecticidal soap or pyrethrin.",
            Self::Leafminer => "Remove affected leaves. Apply spinosad or neem oil. Introduce parasitic wasps.",
            Self::Mealybug => "Apply isopropyl alcohol directly. Use insecticidal soap. Introduce Cryptolaemus beetles.",
            Self::MiteSpider => "Increase humidity, apply miticide. Introduce predatory mites (Phytoseiulus persimilis).",
            Self::MothCodling => "Use pheromone traps. Apply Cydia pomonella granulosis virus. Thin fruit to reduce damage.",
            Self::NematodeRootKnot => "Solarize soil. Plant resistant varieties. Apply beneficial nematodes.",
            Self::ScaleInsect => "Apply horticultural oil spray. Use systemic insecticide. Introduce parasitic wasps.",
            Self::Slug => "Use iron phosphate bait. Set beer traps. Apply diatomaceous earth barriers.",
            Self::Thrips => "Apply spinosad or insecticidal soap. Use blue sticky traps for monitoring.",
            Self::Weevil => "Apply beneficial nematodes to soil. Use pyrethrin spray. Rotate crops.",
            Self::Whitefly => "Use yellow sticky traps. Apply insecticidal soap. Introduce Encarsia formosa wasps.",
            Self::NoPest => "No treatment needed. Continue regular monitoring.",
        }
    }

    /// Get species from index.
    pub fn from_index(idx: usize) -> Option<Self> {
        Self::ALL.get(idx).copied()
    }

    /// Get numeric index.
    pub fn index(&self) -> usize {
        *self as usize
    }

    /// Whether this is the "no pest" class.
    pub fn is_no_pest(&self) -> bool {
        *self == Self::NoPest
    }
}

/// Risk level for pest detection.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Hash, Serialize, Deserialize)]
pub enum RiskLevel {
    None,
    Low,
    Moderate,
    High,
    Critical,
}

impl RiskLevel {
    /// Determine risk from confidence and pest count.
    ///
    /// Mirrors Python `_risk_from_confidence()`.
    pub fn from_confidence_and_count(confidence: f32, pest_count: usize) -> Self {
        if pest_count == 0 {
            return Self::None;
        }
        let score = confidence * (1.0 + 0.2 * (pest_count as f32 - 1.0).min(4.0));
        if score < 0.3 {
            Self::Low
        } else if score < 0.55 {
            Self::Moderate
        } else if score < 0.8 {
            Self::High
        } else {
            Self::Critical
        }
    }

    /// Human-readable label.
    pub fn label(&self) -> &'static str {
        match self {
            Self::None => "NONE",
            Self::Low => "LOW",
            Self::Moderate => "MODERATE",
            Self::High => "HIGH",
            Self::Critical => "CRITICAL",
        }
    }
}

/// Normalized bounding box (x1, y1, x2, y2) in [0, 1].
#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
pub struct BoundingBox {
    pub x1: f32,
    pub y1: f32,
    pub x2: f32,
    pub y2: f32,
}

impl BoundingBox {
    /// Compute area.
    pub fn area(&self) -> f32 {
        (self.x2 - self.x1).max(0.0) * (self.y2 - self.y1).max(0.0)
    }

    /// Compute IoU with another box.
    pub fn iou(&self, other: &BoundingBox) -> f32 {
        let inter_x1 = self.x1.max(other.x1);
        let inter_y1 = self.y1.max(other.y1);
        let inter_x2 = self.x2.min(other.x2);
        let inter_y2 = self.y2.min(other.y2);

        let inter_area = (inter_x2 - inter_x1).max(0.0) * (inter_y2 - inter_y1).max(0.0);
        let union_area = self.area() + other.area() - inter_area;

        if union_area <= 0.0 { 0.0 } else { inter_area / union_area }
    }
}

/// Result for a single detected pest.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DetectedPest {
    pub pest_species: PestSpecies,
    pub confidence: f32,
    pub risk_level: RiskLevel,
    pub treatment: String,
}

/// Complete pest detection result for one image.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PestDetectionResult {
    pub pests: Vec<DetectedPest>,
    pub has_pest: bool,
    pub overall_risk: RiskLevel,
    pub overall_confidence: f32,
    pub bbox: Option<BoundingBox>,
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_pest_species_count() {
        assert_eq!(PestSpecies::ALL.len(), NUM_PEST_CLASSES);
    }

    #[test]
    fn test_pest_species_roundtrip() {
        for (i, species) in PestSpecies::ALL.iter().enumerate() {
            assert_eq!(species.index(), i);
            assert_eq!(PestSpecies::from_index(i), Some(*species));
        }
    }

    #[test]
    fn test_risk_level_from_confidence() {
        assert_eq!(RiskLevel::from_confidence_and_count(0.5, 0), RiskLevel::None);
        assert_eq!(RiskLevel::from_confidence_and_count(0.2, 1), RiskLevel::Low);
        assert_eq!(RiskLevel::from_confidence_and_count(0.5, 1), RiskLevel::Moderate);
        assert_eq!(RiskLevel::from_confidence_and_count(0.7, 1), RiskLevel::High);
        assert_eq!(RiskLevel::from_confidence_and_count(0.9, 1), RiskLevel::Critical);
    }

    #[test]
    fn test_bbox_iou() {
        let a = BoundingBox { x1: 0.0, y1: 0.0, x2: 1.0, y2: 1.0 };
        let b = BoundingBox { x1: 0.5, y1: 0.5, x2: 1.5, y2: 1.5 };
        let iou = a.iou(&b);
        assert!((iou - 0.25 / 1.75).abs() < 1e-5);
    }

    #[test]
    fn test_no_pest() {
        assert!(PestSpecies::NoPest.is_no_pest());
        assert!(!PestSpecies::Aphid.is_no_pest());
    }
}
