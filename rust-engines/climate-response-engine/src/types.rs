use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ClimateParams {
    pub t_base: f64,
    pub t_opt_low: f64,
    pub t_opt_high: f64,
    pub t_max: f64,
    pub frost_threshold: f64,
    pub heat_threshold: f64,
    pub co2_reference: f64,
    pub co2_sensitivity: f64,
    pub water_field_capacity: f64,
    pub water_wilting_point: f64,
    pub drought_threshold: f64,
}

impl Default for ClimateParams {
    fn default() -> Self {
        Self {
            t_base: 8.0,
            t_opt_low: 20.0,
            t_opt_high: 30.0,
            t_max: 42.0,
            frost_threshold: 0.0,
            heat_threshold: 38.0,
            co2_reference: 400.0,
            co2_sensitivity: 0.4,
            water_field_capacity: 0.35,
            water_wilting_point: 0.12,
            drought_threshold: 0.15,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DailyClimate {
    pub temperature_mean: f64,
    pub temperature_min: f64,
    pub temperature_max: f64,
    pub precipitation_mm: f64,
    pub et_reference_mm: f64,
    pub co2_ppm: f64,
    pub solar_radiation_mj: f64,
}

impl Default for DailyClimate {
    fn default() -> Self {
        Self {
            temperature_mean: 22.0,
            temperature_min: 15.0,
            temperature_max: 29.0,
            precipitation_mm: 3.0,
            et_reference_mm: 4.5,
            co2_ppm: 420.0,
            solar_radiation_mj: 18.0,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StressFactors {
    pub temperature_stress: f64,
    pub heat_stress: f64,
    pub frost_stress: f64,
    pub water_stress: f64,
    pub drought_index: f64,
    pub co2_factor: f64,
    pub combined_stress: f64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CropResponse {
    pub thermal_time: f64,
    pub growth_factor: f64,
    pub stress: StressFactors,
    pub soil_moisture: f64,
    pub cumulative_thermal_time: f64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SeasonResult {
    pub daily_responses: Vec<CropResponse>,
    pub total_thermal_time: f64,
    pub mean_growth_factor: f64,
    pub stress_days: u32,
    pub frost_events: u32,
    pub heat_events: u32,
    pub drought_days: u32,
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_defaults() {
        let p = ClimateParams::default();
        assert!(p.t_opt_low < p.t_opt_high);
        assert!(p.t_base < p.t_opt_low);
    }
}
