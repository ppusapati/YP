use serde::{Deserialize, Serialize};

use crate::photosynthesis::PhotosynthesisConfig;

// ---------------------------------------------------------------------------
// Growth stages (simple WOFOST layer)
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// Phenology parameter types
// ---------------------------------------------------------------------------

/// Thermal time thresholds (degree-days) for each phenological stage
/// transition.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StageThresholds {
    pub tt_sowing_to_emergence: f64,
    pub tt_emergence_to_juvenile_end: f64,
    pub tt_juvenile_to_floral_init: f64,
    pub tt_floral_init_to_flowering: f64,
    pub tt_flowering_to_grain_fill_end: f64,
    pub tt_grain_fill_to_maturity: f64,
}

impl Default for StageThresholds {
    fn default() -> Self {
        Self {
            tt_sowing_to_emergence: 120.0,
            tt_emergence_to_juvenile_end: 400.0,
            tt_juvenile_to_floral_init: 200.0,
            tt_floral_init_to_flowering: 300.0,
            tt_flowering_to_grain_fill_end: 500.0,
            tt_grain_fill_to_maturity: 250.0,
        }
    }
}

/// Full phenology parameters including vernalization, photoperiod response,
/// and thermal time configuration.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PhenologyParams {
    /// Whether vernalization is required (winter crops).
    pub vernalization_required: bool,
    /// Lower temperature limit for vernalization (deg C).
    pub vern_base: f64,
    /// Optimum vernalization temperature (deg C).
    pub vern_optimal: f64,
    /// Upper temperature limit for vernalization (deg C).
    pub vern_ceiling: f64,
    /// Vernalization days needed for saturation.
    pub vern_requirement: f64,
    /// Vernalization sensitivity coefficient (0-1).
    pub vern_sensitivity: f64,

    /// Critical photoperiod threshold (hours).
    pub critical_photoperiod: f64,
    /// Optimum photoperiod for maximum development (hours).
    pub optimum_photoperiod: f64,
    /// Photoperiod sensitivity (0 = day-neutral, 1 = fully sensitive).
    pub photoperiod_sensitivity: f64,
    /// Whether this is a long-day plant.
    pub is_long_day: bool,

    /// Upper temperature ceiling for thermal time (deg C).
    pub t_ceiling: f64,

    /// Site latitude in degrees (positive = North).
    pub latitude: f64,
    /// Sowing day of year (1-366) for photoperiod calculation.
    pub sowing_day_of_year: u32,

    /// Thermal time thresholds for stage transitions.
    pub stage_thresholds: StageThresholds,
}

impl Default for PhenologyParams {
    fn default() -> Self {
        Self {
            vernalization_required: false,
            vern_base: -1.0,
            vern_optimal: 4.5,
            vern_ceiling: 15.0,
            vern_requirement: 40.0,
            vern_sensitivity: 0.5,
            critical_photoperiod: 10.0,
            optimum_photoperiod: 14.0,
            photoperiod_sensitivity: 0.0,
            is_long_day: true,
            t_ceiling: 37.0,
            latitude: 40.0,
            sowing_day_of_year: 100,
            stage_thresholds: StageThresholds::default(),
        }
    }
}

// ---------------------------------------------------------------------------
// Biomass partition fractions (WOFOST-style DVS-dependent table)
// ---------------------------------------------------------------------------

/// DVS-dependent biomass partitioning fractions for root, leaf, stem, and
/// storage organs.  Fractions are linearly interpolated between breakpoints.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PartitionFractions {
    /// DVS breakpoints (must be sorted ascending).
    pub dvs_points: Vec<f64>,
    /// Root fraction at each DVS breakpoint.
    pub fr_root: Vec<f64>,
    /// Leaf fraction at each DVS breakpoint.
    pub fr_leaf: Vec<f64>,
    /// Stem fraction at each DVS breakpoint.
    pub fr_stem: Vec<f64>,
    /// Storage organ fraction at each DVS breakpoint.
    pub fr_storage: Vec<f64>,
}

impl Default for PartitionFractions {
    fn default() -> Self {
        Self {
            dvs_points: vec![0.00, 0.10, 0.50, 1.00, 1.50, 2.00],
            fr_root:    vec![0.40, 0.30, 0.20, 0.10, 0.05, 0.00],
            fr_leaf:    vec![0.45, 0.40, 0.30, 0.05, 0.00, 0.00],
            fr_stem:    vec![0.15, 0.25, 0.35, 0.10, 0.05, 0.05],
            fr_storage: vec![0.00, 0.05, 0.15, 0.75, 0.90, 0.95],
        }
    }
}

// ---------------------------------------------------------------------------
// Crop parameters
// ---------------------------------------------------------------------------

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

    /// Optional full phenology model.  When `Some`, the phenology model
    /// (vernalization, photoperiod, improved thermal time) is used instead
    /// of simple DVS thermal-time accumulation.
    #[serde(default)]
    pub phenology: Option<PhenologyParams>,

    /// DVS-dependent biomass partitioning fractions.
    #[serde(default)]
    pub partition: PartitionFractions,

    /// Soil field capacity (volumetric, m^3/m^3).  Used by FAO-56 water
    /// stress model.
    #[serde(default = "default_field_capacity")]
    pub field_capacity: f64,
    /// Soil wilting point (volumetric, m^3/m^3).  Used by FAO-56 water
    /// stress model.
    #[serde(default = "default_wilting_point")]
    pub wilting_point: f64,
    /// FAO-56 management-allowed depletion fraction (0-1).
    #[serde(default = "default_depletion_p")]
    pub depletion_fraction_p: f64,
}

fn default_field_capacity() -> f64 { 0.30 }
fn default_wilting_point() -> f64 { 0.12 }
fn default_depletion_p() -> f64 { 0.55 }

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
            phenology: None,
            partition: PartitionFractions::default(),
            field_capacity: 0.30,
            wilting_point: 0.12,
            depletion_fraction_p: 0.55,
        }
    }
}

// ---------------------------------------------------------------------------
// Simulation state
// ---------------------------------------------------------------------------

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
    /// Biomass allocated to roots (kg DM / ha).
    #[serde(default)]
    pub biomass_root: f64,
    /// Biomass allocated to leaves (kg DM / ha).
    #[serde(default)]
    pub biomass_leaf: f64,
    /// Biomass allocated to stem (kg DM / ha).
    #[serde(default)]
    pub biomass_stem: f64,
    /// Biomass allocated to storage organs (kg DM / ha).
    #[serde(default)]
    pub biomass_storage: f64,
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
            biomass_root: 0.0,
            biomass_leaf: 0.0,
            biomass_stem: 0.0,
            biomass_storage: 0.0,
        }
    }
}

// ---------------------------------------------------------------------------
// Daily weather
// ---------------------------------------------------------------------------

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DailyWeather {
    pub temperature: f64,
    pub radiation: f64,
    pub rainfall: f64,
    pub day_length: f64,
    /// Minimum daily temperature (deg C).  If absent, derived as
    /// `temperature - 5`.
    #[serde(default)]
    pub t_min: Option<f64>,
    /// Maximum daily temperature (deg C).  If absent, derived as
    /// `temperature + 5`.
    #[serde(default)]
    pub t_max: Option<f64>,
}

impl DailyWeather {
    /// Minimum daily temperature, defaulting to `temperature - 5`.
    pub fn temp_min(&self) -> f64 {
        self.t_min.unwrap_or(self.temperature - 5.0)
    }

    /// Maximum daily temperature, defaulting to `temperature + 5`.
    pub fn temp_max(&self) -> f64 {
        self.t_max.unwrap_or(self.temperature + 5.0)
    }
}

impl Default for DailyWeather {
    fn default() -> Self {
        Self {
            temperature: 22.0,
            radiation: 18.0,
            rainfall: 3.0,
            day_length: 12.0,
            t_min: None,
            t_max: None,
        }
    }
}

// ---------------------------------------------------------------------------
// Simulation result
// ---------------------------------------------------------------------------

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SimulationResult {
    pub daily_states: Vec<SimulationState>,
    pub final_biomass: f64,
    pub estimated_yield: f64,
    pub days_to_maturity: u32,
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

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

    #[test]
    fn test_daily_weather_temp_helpers() {
        let w = DailyWeather::default();
        assert_eq!(w.temp_min(), 17.0);
        assert_eq!(w.temp_max(), 27.0);

        let w2 = DailyWeather {
            t_min: Some(10.0),
            t_max: Some(30.0),
            ..Default::default()
        };
        assert_eq!(w2.temp_min(), 10.0);
        assert_eq!(w2.temp_max(), 30.0);
    }

    #[test]
    fn test_partition_fractions_default_sums() {
        let pf = PartitionFractions::default();
        for i in 0..pf.dvs_points.len() {
            let sum =
                pf.fr_root[i] + pf.fr_leaf[i] + pf.fr_stem[i] + pf.fr_storage[i];
            assert!(
                (sum - 1.0).abs() < 1e-10,
                "fractions at DVS {} sum to {sum}, expected 1.0",
                pf.dvs_points[i]
            );
        }
    }
}
