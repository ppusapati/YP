//! Crop selection criteria and input data structures.

use serde::{Deserialize, Serialize};

/// Soil conditions at the target field.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SoilConditions {
    /// Soil pH (0-14).
    pub ph: f64,
    /// Organic matter percentage.
    pub organic_matter_pct: f64,
    /// Available nitrogen in mg/kg.
    pub nitrogen_mg_kg: f64,
    /// Available phosphorus in mg/kg.
    pub phosphorus_mg_kg: f64,
    /// Available potassium in mg/kg.
    pub potassium_mg_kg: f64,
    /// Soil texture class.
    pub texture: SoilTexture,
    /// Drainage quality.
    pub drainage: DrainageClass,
}

/// Growing conditions at the target location.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GrowingConditions {
    /// Average temperature during growing season (°C).
    pub avg_temperature_c: f64,
    /// Minimum temperature during growing season (°C).
    pub min_temperature_c: f64,
    /// Maximum temperature during growing season (°C).
    pub max_temperature_c: f64,
    /// Annual rainfall (mm).
    pub annual_rainfall_mm: f64,
    /// Available irrigation water (mm per season).
    pub irrigation_available_mm: f64,
    /// Growing season length (days).
    pub growing_season_days: u32,
    /// Sunlight hours per day during growing season.
    pub sunlight_hours_per_day: f64,
    /// Elevation in meters above sea level.
    pub elevation_m: f64,
}

/// Soil texture classification.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum SoilTexture {
    Sand,
    LoamySand,
    SandyLoam,
    Loam,
    SiltLoam,
    Silt,
    SandyClayLoam,
    ClayLoam,
    SiltyClayLoam,
    SandyCite,
    SiltyClay,
    Clay,
}

/// Soil drainage classification.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum DrainageClass {
    VeryPoor,
    Poor,
    Imperfect,
    Moderate,
    Well,
    Rapid,
    VeryRapid,
}

/// A crop candidate with its ideal growing requirements.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CropCandidate {
    /// Crop name.
    pub name: String,
    /// Optimal pH range.
    pub ph_range: (f64, f64),
    /// Optimal temperature range (°C).
    pub temperature_range: (f64, f64),
    /// Minimum water requirement (mm per season).
    pub water_requirement_mm: f64,
    /// Minimum growing season length (days).
    pub min_growing_days: u32,
    /// Minimum sunlight hours per day.
    pub min_sunlight_hours: f64,
    /// Minimum nitrogen requirement (mg/kg).
    pub nitrogen_requirement: f64,
    /// Minimum phosphorus requirement (mg/kg).
    pub phosphorus_requirement: f64,
    /// Minimum potassium requirement (mg/kg).
    pub potassium_requirement: f64,
    /// Suitable soil textures.
    pub suitable_textures: Vec<SoilTexture>,
    /// Suitable drainage classes.
    pub suitable_drainage: Vec<DrainageClass>,
    /// Expected yield (kg/hectare) under ideal conditions.
    pub ideal_yield_kg_ha: f64,
    /// Market price (currency units per kg).
    pub market_price_per_kg: f64,
    /// Production cost (currency units per hectare).
    pub production_cost_per_ha: f64,
}

impl CropCandidate {
    /// Check if soil pH is within the acceptable range (with tolerance).
    pub fn ph_suitability(&self, ph: f64) -> f64 {
        range_suitability(ph, self.ph_range.0, self.ph_range.1, 1.0)
    }

    /// Check if temperature is within the acceptable range.
    pub fn temperature_suitability(&self, avg_temp: f64) -> f64 {
        range_suitability(avg_temp, self.temperature_range.0, self.temperature_range.1, 5.0)
    }

    /// Check if available water meets the crop's requirement.
    pub fn water_suitability(&self, total_water_mm: f64) -> f64 {
        if total_water_mm >= self.water_requirement_mm {
            1.0
        } else {
            (total_water_mm / self.water_requirement_mm).clamp(0.0, 1.0)
        }
    }

    /// Expected net revenue per hectare.
    pub fn expected_revenue_per_ha(&self, yield_factor: f64) -> f64 {
        let actual_yield = self.ideal_yield_kg_ha * yield_factor;
        actual_yield * self.market_price_per_kg - self.production_cost_per_ha
    }
}

/// Compute how well a value fits within an optimal range.
/// Returns 1.0 if within range, decaying toward 0.0 outside by `tolerance`.
fn range_suitability(value: f64, min: f64, max: f64, tolerance: f64) -> f64 {
    if value >= min && value <= max {
        1.0
    } else if value < min {
        let deficit = min - value;
        (1.0 - deficit / tolerance).clamp(0.0, 1.0)
    } else {
        let excess = value - max;
        (1.0 - excess / tolerance).clamp(0.0, 1.0)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_range_suitability_within() {
        assert!((range_suitability(6.5, 6.0, 7.0, 1.0) - 1.0).abs() < 1e-10);
    }

    #[test]
    fn test_range_suitability_below() {
        let s = range_suitability(5.5, 6.0, 7.0, 1.0);
        assert!((s - 0.5).abs() < 1e-10);
    }

    #[test]
    fn test_range_suitability_above() {
        let s = range_suitability(8.0, 6.0, 7.0, 1.0);
        assert!((s - 0.0).abs() < 1e-10);
    }

    #[test]
    fn test_range_suitability_far_below() {
        let s = range_suitability(3.0, 6.0, 7.0, 1.0);
        assert!((s - 0.0).abs() < 1e-10);
    }
}
