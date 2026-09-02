use serde::{Deserialize, Serialize};

use crate::photosynthesis::PhotosynthesisConfig;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum GrowthStage {
    Germination,
    Emergence,
    Vegetative,
    Flowering,
    GrainFilling,
    Maturity,
}

impl GrowthStage {
    pub fn from_dvs(dvs: f64) -> Self {
        if dvs < 0.0 { Self::Germination }
        else if dvs < 0.1 { Self::Emergence }
        else if dvs < 0.5 { Self::Vegetative }
        else if dvs < 1.0 { Self::Flowering }
        else if dvs < 2.0 { Self::GrainFilling }
        else { Self::Maturity }
    }

    pub fn label(&self) -> &'static str {
        match self {
            Self::Germination => "Germination",
            Self::Emergence => "Emergence",
            Self::Vegetative => "Vegetative",
            Self::Flowering => "Flowering",
            Self::GrainFilling => "Grain Filling",
            Self::Maturity => "Maturity",
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CropParams {
    pub name: String,
    pub t_base: f64,
    pub t_opt: f64,
    pub t_max: f64,
    pub rue: f64,
    pub k_ext: f64,
    pub sla: f64,
    pub max_lai: f64,
    pub root_depth_max: f64,
    pub root_growth_rate: f64,
    pub dvs_emergence: f64,
    pub dvs_flowering: f64,
    pub dvs_maturity: f64,
    pub water_use_efficiency: f64,
    pub harvest_index: f64,
    /// Optional Farquhar photosynthesis model configuration.
    /// When present, overrides the RUE-based biomass accumulation in
    /// growth_derivatives with the mechanistic FvCB model.
    #[serde(default)]
    pub photosynthesis: Option<PhotosynthesisConfig>,
}

impl Default for CropParams {
    fn default() -> Self {
        Self {
            name: "Generic Cereal".to_string(),
            t_base: 8.0,
            t_opt: 25.0,
            t_max: 40.0,
            rue: 3.0,
            k_ext: 0.6,
            sla: 0.002,
            max_lai: 6.0,
            root_depth_max: 1.5,
            root_growth_rate: 0.012,
            dvs_emergence: 50.0,
            dvs_flowering: 800.0,
            dvs_maturity: 1600.0,
            water_use_efficiency: 4.0,
            harvest_index: 0.45,
            photosynthesis: None,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SimulationState {
    pub day: u32,
    pub biomass: f64,
    pub lai: f64,
    pub dvs: f64,
    pub root_depth: f64,
    pub soil_moisture: f64,
    pub stage: GrowthStage,
    pub canopy_height: f64,
    pub water_demand: f64,
}

impl SimulationState {
    pub fn initial(soil_moisture: f64) -> Self {
        Self {
            day: 0,
            biomass: 0.5,
            lai: 0.01,
            dvs: 0.0,
            root_depth: 0.05,
            soil_moisture,
            stage: GrowthStage::Germination,
            canopy_height: 0.0,
            water_demand: 0.0,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DailyWeather {
    pub temperature: f64,
    pub radiation: f64,
    pub rainfall: f64,
    pub day_length: f64,
}

impl Default for DailyWeather {
    fn default() -> Self {
        Self { temperature: 22.0, radiation: 18.0, rainfall: 3.0, day_length: 12.0 }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SimulationResult {
    pub daily_states: Vec<SimulationState>,
    pub final_biomass: f64,
    pub estimated_yield: f64,
    pub days_to_maturity: u32,
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_growth_stage_from_dvs() {
        assert_eq!(GrowthStage::from_dvs(-0.1), GrowthStage::Germination);
        assert_eq!(GrowthStage::from_dvs(0.3), GrowthStage::Vegetative);
        assert_eq!(GrowthStage::from_dvs(0.8), GrowthStage::Flowering);
        assert_eq!(GrowthStage::from_dvs(1.5), GrowthStage::GrainFilling);
        assert_eq!(GrowthStage::from_dvs(2.5), GrowthStage::Maturity);
    }
}
