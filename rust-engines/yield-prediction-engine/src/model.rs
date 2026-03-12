//! Yield prediction model configuration and crop parameters.

use serde::{Deserialize, Serialize};

/// Yield model parameters for a specific crop.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct YieldModelParams {
    /// Crop name.
    pub crop_name: String,
    /// Maximum attainable yield under ideal conditions (kg/ha).
    pub max_yield_kg_ha: f64,
    /// Optimal temperature range (°C).
    pub optimal_temp_range: (f64, f64),
    /// Water requirement for the growing season (mm).
    pub water_requirement_mm: f64,
    /// Nitrogen requirement (kg/ha).
    pub nitrogen_requirement_kg_ha: f64,
    /// Optimal pH range.
    pub optimal_ph_range: (f64, f64),
    /// Required growing degree days.
    pub required_gdd: f64,
    /// Optimal plant population (plants/ha).
    pub optimal_plant_population: f64,
}

impl YieldModelParams {
    /// Create parameters for common crops.
    pub fn wheat() -> Self {
        Self {
            crop_name: "Wheat".to_string(),
            max_yield_kg_ha: 8000.0,
            optimal_temp_range: (15.0, 25.0),
            water_requirement_mm: 500.0,
            nitrogen_requirement_kg_ha: 150.0,
            optimal_ph_range: (6.0, 7.5),
            required_gdd: 1500.0,
            optimal_plant_population: 3_500_000.0,
        }
    }

    pub fn corn() -> Self {
        Self {
            crop_name: "Corn".to_string(),
            max_yield_kg_ha: 12000.0,
            optimal_temp_range: (20.0, 30.0),
            water_requirement_mm: 600.0,
            nitrogen_requirement_kg_ha: 200.0,
            optimal_ph_range: (5.8, 7.0),
            required_gdd: 2500.0,
            optimal_plant_population: 80_000.0,
        }
    }

    pub fn soybean() -> Self {
        Self {
            crop_name: "Soybean".to_string(),
            max_yield_kg_ha: 4000.0,
            optimal_temp_range: (20.0, 30.0),
            water_requirement_mm: 500.0,
            nitrogen_requirement_kg_ha: 40.0, // N-fixing
            optimal_ph_range: (6.0, 7.0),
            required_gdd: 2200.0,
            optimal_plant_population: 350_000.0,
        }
    }

    pub fn rice() -> Self {
        Self {
            crop_name: "Rice".to_string(),
            max_yield_kg_ha: 9000.0,
            optimal_temp_range: (25.0, 35.0),
            water_requirement_mm: 1200.0,
            nitrogen_requirement_kg_ha: 120.0,
            optimal_ph_range: (5.5, 6.5),
            required_gdd: 2000.0,
            optimal_plant_population: 300_000.0,
        }
    }
}

/// The yield prediction model.
#[derive(Debug, Clone)]
pub struct YieldModel {
    pub params: YieldModelParams,
}

impl YieldModel {
    /// Create a new yield model for a crop.
    pub fn new(params: YieldModelParams) -> Self {
        Self { params }
    }

    /// Compute the plant population factor (0-1).
    pub fn population_factor(&self, actual_population: f64) -> f64 {
        let ratio = actual_population / self.params.optimal_plant_population;
        if ratio >= 0.8 && ratio <= 1.2 {
            1.0
        } else if ratio < 0.8 {
            (ratio / 0.8).clamp(0.0, 1.0)
        } else {
            // Overcrowding penalty
            (1.0 - (ratio - 1.2) * 0.5).clamp(0.5, 1.0)
        }
    }

    /// Compute the growing degree day factor (0-1).
    pub fn gdd_factor(&self, accumulated_gdd: f64) -> f64 {
        if accumulated_gdd >= self.params.required_gdd {
            1.0
        } else {
            (accumulated_gdd / self.params.required_gdd).clamp(0.0, 1.0)
        }
    }

    /// Compute the soil pH factor (0-1).
    pub fn ph_factor(&self, ph: f64) -> f64 {
        let (min_ph, max_ph) = self.params.optimal_ph_range;
        if ph >= min_ph && ph <= max_ph {
            1.0
        } else if ph < min_ph {
            (1.0 - (min_ph - ph) / 2.0).clamp(0.0, 1.0)
        } else {
            (1.0 - (ph - max_ph) / 2.0).clamp(0.0, 1.0)
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_wheat_params() {
        let wheat = YieldModelParams::wheat();
        assert_eq!(wheat.crop_name, "Wheat");
        assert!(wheat.max_yield_kg_ha > 0.0);
    }

    #[test]
    fn test_population_factor_optimal() {
        let model = YieldModel::new(YieldModelParams::wheat());
        let f = model.population_factor(model.params.optimal_plant_population);
        assert!((f - 1.0).abs() < 1e-10);
    }

    #[test]
    fn test_population_factor_low() {
        let model = YieldModel::new(YieldModelParams::wheat());
        let f = model.population_factor(model.params.optimal_plant_population * 0.5);
        assert!(f < 1.0);
        assert!(f > 0.0);
    }

    #[test]
    fn test_gdd_factor_sufficient() {
        let model = YieldModel::new(YieldModelParams::corn());
        let f = model.gdd_factor(3000.0);
        assert!((f - 1.0).abs() < 1e-10);
    }

    #[test]
    fn test_gdd_factor_insufficient() {
        let model = YieldModel::new(YieldModelParams::corn());
        let f = model.gdd_factor(1250.0); // Half of required
        assert!((f - 0.5).abs() < 1e-10);
    }

    #[test]
    fn test_ph_factor_optimal() {
        let model = YieldModel::new(YieldModelParams::wheat());
        assert!((model.ph_factor(6.5) - 1.0).abs() < 1e-10);
    }

    #[test]
    fn test_ph_factor_acidic() {
        let model = YieldModel::new(YieldModelParams::wheat());
        let f = model.ph_factor(4.0); // Far below optimal
        assert!(f < 1.0);
    }
}
