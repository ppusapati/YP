//! Plant classification types and the 38 PlantVillage classes.
//!
//! Migrated from Python `plant_classification/model.py`.

use serde::{Deserialize, Serialize};

/// All 38 PlantVillage classes with full descriptive names.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
#[repr(u8)]
pub enum PlantClass {
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
    PepperBellBacterialSpot = 18,
    PepperBellHealthy = 19,
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
    TomatoSpiderMitesTwoSpotted = 33,
    TomatoTargetSpot = 34,
    TomatoYellowLeafCurlVirus = 35,
    TomatoMosaicVirus = 36,
    TomatoHealthy = 37,
}

pub const NUM_CLASSES: usize = 38;

impl PlantClass {
    pub const ALL: [PlantClass; NUM_CLASSES] = [
        Self::AppleAppleScab, Self::AppleBlackRot, Self::AppleCedarAppleRust, Self::AppleHealthy,
        Self::BlueberryHealthy, Self::CherryPowderyMildew, Self::CherryHealthy,
        Self::CornCercosporaLeafSpot, Self::CornCommonRust, Self::CornNorthernLeafBlight,
        Self::CornHealthy, Self::GrapeBlackRot, Self::GrapeEscaBlackMeasles,
        Self::GrapeLeafBlightIsariopsis, Self::GrapeHealthy, Self::OrangeHaunglongbing,
        Self::PeachBacterialSpot, Self::PeachHealthy, Self::PepperBellBacterialSpot,
        Self::PepperBellHealthy, Self::PotatoEarlyBlight, Self::PotatoLateBlight,
        Self::PotatoHealthy, Self::RaspberryHealthy, Self::SoybeanHealthy,
        Self::SquashPowderyMildew, Self::StrawberryLeafScorch, Self::StrawberryHealthy,
        Self::TomatoBacterialSpot, Self::TomatoEarlyBlight, Self::TomatoLateBlight,
        Self::TomatoLeafMold, Self::TomatoSeptoriaLeafSpot, Self::TomatoSpiderMitesTwoSpotted,
        Self::TomatoTargetSpot, Self::TomatoYellowLeafCurlVirus, Self::TomatoMosaicVirus,
        Self::TomatoHealthy,
    ];

    /// PlantVillage label string.
    pub fn label(&self) -> &'static str {
        match self {
            Self::AppleAppleScab => "Apple___Apple_scab",
            Self::AppleBlackRot => "Apple___Black_rot",
            Self::AppleCedarAppleRust => "Apple___Cedar_apple_rust",
            Self::AppleHealthy => "Apple___healthy",
            Self::BlueberryHealthy => "Blueberry___healthy",
            Self::CherryPowderyMildew => "Cherry_(including_sour)___Powdery_mildew",
            Self::CherryHealthy => "Cherry_(including_sour)___healthy",
            Self::CornCercosporaLeafSpot => "Corn_(maize)___Cercospora_leaf_spot_Gray_leaf_spot",
            Self::CornCommonRust => "Corn_(maize)___Common_rust_",
            Self::CornNorthernLeafBlight => "Corn_(maize)___Northern_Leaf_Blight",
            Self::CornHealthy => "Corn_(maize)___healthy",
            Self::GrapeBlackRot => "Grape___Black_rot",
            Self::GrapeEscaBlackMeasles => "Grape___Esca_(Black_Measles)",
            Self::GrapeLeafBlightIsariopsis => "Grape___Leaf_blight_(Isariopsis_Leaf_Spot)",
            Self::GrapeHealthy => "Grape___healthy",
            Self::OrangeHaunglongbing => "Orange___Haunglongbing_(Citrus_greening)",
            Self::PeachBacterialSpot => "Peach___Bacterial_spot",
            Self::PeachHealthy => "Peach___healthy",
            Self::PepperBellBacterialSpot => "Pepper,_bell___Bacterial_spot",
            Self::PepperBellHealthy => "Pepper,_bell___healthy",
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
            Self::TomatoSpiderMitesTwoSpotted => "Tomato___Spider_mites_Two-spotted_spider_mite",
            Self::TomatoTargetSpot => "Tomato___Target_Spot",
            Self::TomatoYellowLeafCurlVirus => "Tomato___Tomato_Yellow_Leaf_Curl_Virus",
            Self::TomatoMosaicVirus => "Tomato___Tomato_mosaic_virus",
            Self::TomatoHealthy => "Tomato___healthy",
        }
    }

    pub fn from_index(idx: usize) -> Option<Self> {
        Self::ALL.get(idx).copied()
    }

    pub fn index(&self) -> usize {
        *self as usize
    }
}

/// A single top-k classification prediction.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TopKPrediction {
    pub class: PlantClass,
    pub probability: f32,
}

/// Classification result for one image.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ClassificationResult {
    pub predicted_class: PlantClass,
    pub confidence: f32,
    pub top_k: Vec<TopKPrediction>,
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_class_count() {
        assert_eq!(PlantClass::ALL.len(), NUM_CLASSES);
    }

    #[test]
    fn test_roundtrip() {
        for (i, c) in PlantClass::ALL.iter().enumerate() {
            assert_eq!(c.index(), i);
            assert_eq!(PlantClass::from_index(i), Some(*c));
        }
    }
}
