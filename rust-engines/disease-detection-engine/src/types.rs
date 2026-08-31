//! Disease detection types, enums, and result structures.
//!
//! Migrated from Python `disease_detection/model.py` and `disease_detection/inference.py`.

use serde::{Deserialize, Serialize};

/// All 38 PlantVillage disease classes.
///
/// Matches the Python `DISEASE_CLASSES` list exactly.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
#[repr(u8)]
pub enum DiseaseClass {
    AppleAppleScab = 0,
    AppleBlackRot = 1,
    AppleCedarAppleRust = 2,
    AppleHealthy = 3,
    BlueberryHealthy = 4,
    CherryPowderyMildew = 5,
    CherryHealthy = 6,
    CornCercosporaLeafSpot = 7,
    CornCommonRust = 8,
    CornNorthernLeafBlight = 9,
    CornHealthy = 10,
    GrapeBlackRot = 11,
    GrapeEscaBlackMeasles = 12,
    GrapeLeafBlightIsariopsis = 13,
    GrapeHealthy = 14,
    OrangeHaunglongbing = 15,
    PeachBacterialSpot = 16,
    PeachHealthy = 17,
    PepperBacterialSpot = 18,
    PepperHealthy = 19,
    PotatoEarlyBlight = 20,
    PotatoLateBlight = 21,
    PotatoHealthy = 22,
    RaspberryHealthy = 23,
    SoybeanHealthy = 24,
    SquashPowderyMildew = 25,
    StrawberryLeafScorch = 26,
    StrawberryHealthy = 27,
    TomatoBacterialSpot = 28,
    TomatoEarlyBlight = 29,
    TomatoLateBlight = 30,
    TomatoLeafMold = 31,
    TomatoSeptoriaLeafSpot = 32,
    TomatoSpiderMites = 33,
    TomatoTargetSpot = 34,
    TomatoYellowLeafCurlVirus = 35,
    TomatoTomatoMosaicVirus = 36,
    TomatoHealthy = 37,
}

/// Total number of disease classes.
pub const NUM_DISEASE_CLASSES: usize = 38;

impl DiseaseClass {
    /// All disease class variants in index order.
    pub const ALL: [DiseaseClass; NUM_DISEASE_CLASSES] = [
        Self::AppleAppleScab,
        Self::AppleBlackRot,
        Self::AppleCedarAppleRust,
        Self::AppleHealthy,
        Self::BlueberryHealthy,
        Self::CherryPowderyMildew,
        Self::CherryHealthy,
        Self::CornCercosporaLeafSpot,
        Self::CornCommonRust,
        Self::CornNorthernLeafBlight,
        Self::CornHealthy,
        Self::GrapeBlackRot,
        Self::GrapeEscaBlackMeasles,
        Self::GrapeLeafBlightIsariopsis,
        Self::GrapeHealthy,
        Self::OrangeHaunglongbing,
        Self::PeachBacterialSpot,
        Self::PeachHealthy,
        Self::PepperBacterialSpot,
        Self::PepperHealthy,
        Self::PotatoEarlyBlight,
        Self::PotatoLateBlight,
        Self::PotatoHealthy,
        Self::RaspberryHealthy,
        Self::SoybeanHealthy,
        Self::SquashPowderyMildew,
        Self::StrawberryLeafScorch,
        Self::StrawberryHealthy,
        Self::TomatoBacterialSpot,
        Self::TomatoEarlyBlight,
        Self::TomatoLateBlight,
        Self::TomatoLeafMold,
        Self::TomatoSeptoriaLeafSpot,
        Self::TomatoSpiderMites,
        Self::TomatoTargetSpot,
        Self::TomatoYellowLeafCurlVirus,
        Self::TomatoTomatoMosaicVirus,
        Self::TomatoHealthy,
    ];

    /// Human-readable display name matching the Python label.
    pub fn label(&self) -> &'static str {
        match self {
            Self::AppleAppleScab => "Apple___Apple_scab",
            Self::AppleBlackRot => "Apple___Black_rot",
            Self::AppleCedarAppleRust => "Apple___Cedar_apple_rust",
            Self::AppleHealthy => "Apple___healthy",
            Self::BlueberryHealthy => "Blueberry___healthy",
            Self::CherryPowderyMildew => "Cherry___Powdery_mildew",
            Self::CherryHealthy => "Cherry___healthy",
            Self::CornCercosporaLeafSpot => "Corn___Cercospora_leaf_spot",
            Self::CornCommonRust => "Corn___Common_rust",
            Self::CornNorthernLeafBlight => "Corn___Northern_Leaf_Blight",
            Self::CornHealthy => "Corn___healthy",
            Self::GrapeBlackRot => "Grape___Black_rot",
            Self::GrapeEscaBlackMeasles => "Grape___Esca_Black_Measles",
            Self::GrapeLeafBlightIsariopsis => "Grape___Leaf_blight_Isariopsis",
            Self::GrapeHealthy => "Grape___healthy",
            Self::OrangeHaunglongbing => "Orange___Haunglongbing",
            Self::PeachBacterialSpot => "Peach___Bacterial_spot",
            Self::PeachHealthy => "Peach___healthy",
            Self::PepperBacterialSpot => "Pepper___Bacterial_spot",
            Self::PepperHealthy => "Pepper___healthy",
            Self::PotatoEarlyBlight => "Potato___Early_blight",
            Self::PotatoLateBlight => "Potato___Late_blight",
            Self::PotatoHealthy => "Potato___healthy",
            Self::RaspberryHealthy => "Raspberry___healthy",
            Self::SoybeanHealthy => "Soybean___healthy",
            Self::SquashPowderyMildew => "Squash___Powdery_mildew",
            Self::StrawberryLeafScorch => "Strawberry___Leaf_scorch",
            Self::StrawberryHealthy => "Strawberry___healthy",
            Self::TomatoBacterialSpot => "Tomato___Bacterial_spot",
            Self::TomatoEarlyBlight => "Tomato___Early_blight",
            Self::TomatoLateBlight => "Tomato___Late_blight",
            Self::TomatoLeafMold => "Tomato___Leaf_Mold",
            Self::TomatoSeptoriaLeafSpot => "Tomato___Septoria_leaf_spot",
            Self::TomatoSpiderMites => "Tomato___Spider_mites",
            Self::TomatoTargetSpot => "Tomato___Target_Spot",
            Self::TomatoYellowLeafCurlVirus => "Tomato___Yellow_Leaf_Curl_Virus",
            Self::TomatoTomatoMosaicVirus => "Tomato___Tomato_mosaic_virus",
            Self::TomatoHealthy => "Tomato___healthy",
        }
    }

    /// Whether this class represents a healthy plant.
    pub fn is_healthy(&self) -> bool {
        matches!(
            self,
            Self::AppleHealthy
                | Self::BlueberryHealthy
                | Self::CherryHealthy
                | Self::CornHealthy
                | Self::GrapeHealthy
                | Self::PeachHealthy
                | Self::PepperHealthy
                | Self::PotatoHealthy
                | Self::RaspberryHealthy
                | Self::SoybeanHealthy
                | Self::StrawberryHealthy
                | Self::TomatoHealthy
        )
    }

    /// Get class from index.
    pub fn from_index(idx: usize) -> Option<Self> {
        Self::ALL.get(idx).copied()
    }

    /// Get numeric index.
    pub fn index(&self) -> usize {
        *self as usize
    }
}

/// Disease severity level, derived from affected area or confidence.
///
/// Mirrors the Python `_severity_from_area` / `_severity_from_confidence` logic.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Hash, Serialize, Deserialize)]
pub enum SeverityLevel {
    Mild,
    Moderate,
    Severe,
    Critical,
}

impl SeverityLevel {
    /// Determine severity from affected area percentage (from segmentation mask).
    pub fn from_area_percent(area_pct: f32) -> Self {
        if area_pct < 5.0 {
            Self::Mild
        } else if area_pct < 20.0 {
            Self::Moderate
        } else if area_pct < 50.0 {
            Self::Severe
        } else {
            Self::Critical
        }
    }

    /// Determine severity from classification confidence.
    pub fn from_confidence(confidence: f32) -> Self {
        if confidence < 0.4 {
            Self::Mild
        } else if confidence < 0.65 {
            Self::Moderate
        } else if confidence < 0.85 {
            Self::Severe
        } else {
            Self::Critical
        }
    }

    /// Human-readable label.
    pub fn label(&self) -> &'static str {
        match self {
            Self::Mild => "MILD",
            Self::Moderate => "MODERATE",
            Self::Severe => "SEVERE",
            Self::Critical => "CRITICAL",
        }
    }
}

/// Result for a single detected disease.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DiseaseResult {
    /// Detected disease class.
    pub disease_class: DiseaseClass,
    /// Classification confidence (0.0-1.0).
    pub confidence: f32,
    /// Disease severity.
    pub severity: SeverityLevel,
    /// Affected area percentage from segmentation (0-100).
    pub affected_area_percentage: f32,
}

/// Complete disease detection result for one image.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DiagnosisResult {
    /// All detected diseases, sorted by confidence descending.
    pub diseases: Vec<DiseaseResult>,
    /// Whether the plant appears healthy.
    pub is_healthy: bool,
    /// Overall severity (worst among detected diseases).
    pub overall_severity: SeverityLevel,
    /// Highest confidence among detected diseases (or healthy confidence).
    pub overall_confidence: f32,
    /// Disease localization heatmap, if computed. Values in [0, 1].
    /// Shape: (height, width) flattened in row-major order.
    pub heatmap: Option<Vec<f32>>,
    /// Heatmap dimensions (height, width).
    pub heatmap_size: Option<(usize, usize)>,
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_disease_class_count() {
        assert_eq!(DiseaseClass::ALL.len(), NUM_DISEASE_CLASSES);
    }

    #[test]
    fn test_disease_class_roundtrip() {
        for (i, class) in DiseaseClass::ALL.iter().enumerate() {
            assert_eq!(class.index(), i);
            assert_eq!(DiseaseClass::from_index(i), Some(*class));
        }
    }

    #[test]
    fn test_healthy_classes() {
        assert!(DiseaseClass::AppleHealthy.is_healthy());
        assert!(DiseaseClass::TomatoHealthy.is_healthy());
        assert!(!DiseaseClass::AppleAppleScab.is_healthy());
        assert!(!DiseaseClass::TomatoLateBlight.is_healthy());
    }

    #[test]
    fn test_severity_from_area() {
        assert_eq!(SeverityLevel::from_area_percent(2.0), SeverityLevel::Mild);
        assert_eq!(SeverityLevel::from_area_percent(10.0), SeverityLevel::Moderate);
        assert_eq!(SeverityLevel::from_area_percent(30.0), SeverityLevel::Severe);
        assert_eq!(SeverityLevel::from_area_percent(60.0), SeverityLevel::Critical);
    }

    #[test]
    fn test_severity_from_confidence() {
        assert_eq!(SeverityLevel::from_confidence(0.2), SeverityLevel::Mild);
        assert_eq!(SeverityLevel::from_confidence(0.5), SeverityLevel::Moderate);
        assert_eq!(SeverityLevel::from_confidence(0.75), SeverityLevel::Severe);
        assert_eq!(SeverityLevel::from_confidence(0.9), SeverityLevel::Critical);
    }
}
