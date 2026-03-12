//! Yield factor definitions and stress computation.

use serde::{Deserialize, Serialize};

/// Environmental factors affecting yield.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EnvironmentFactors {
    /// Average temperature during growing season (°C).
    pub avg_temperature_c: f64,
    /// Total growing season precipitation (mm).
    pub total_precipitation_mm: f64,
    /// Average solar radiation (MJ/m²/day).
    pub solar_radiation_mj_m2_day: f64,
    /// Growing degree days accumulated.
    pub growing_degree_days: f64,
    /// Number of frost days during growing season.
    pub frost_days: u32,
    /// Number of heat stress days (>35°C).
    pub heat_stress_days: u32,
    /// Relative humidity (%).
    pub relative_humidity_pct: f64,
}

/// Soil factors affecting yield.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SoilFactors {
    /// Soil organic matter (%).
    pub organic_matter_pct: f64,
    /// Soil pH.
    pub ph: f64,
    /// Available nitrogen (kg/ha).
    pub nitrogen_kg_ha: f64,
    /// Available phosphorus (kg/ha).
    pub phosphorus_kg_ha: f64,
    /// Available potassium (kg/ha).
    pub potassium_kg_ha: f64,
    /// Soil water holding capacity (mm/m).
    pub water_holding_capacity_mm_m: f64,
    /// Soil compaction index (0-1, 0=no compaction).
    pub compaction_index: f64,
}

/// Management factors affecting yield.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ManagementFactors {
    /// Planting date (day of year, 1-366).
    pub planting_day: u32,
    /// Plant population (plants/ha).
    pub plant_population_per_ha: f64,
    /// Total nitrogen fertilizer applied (kg/ha).
    pub nitrogen_applied_kg_ha: f64,
    /// Total irrigation applied (mm).
    pub irrigation_mm: f64,
    /// Pest control effectiveness (0-1).
    pub pest_control_effectiveness: f64,
    /// Weed control effectiveness (0-1).
    pub weed_control_effectiveness: f64,
}

/// A stress factor with its impact on yield.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StressFactor {
    /// Name of the stress factor.
    pub name: String,
    /// Yield reduction factor (0-1, where 1 = no stress).
    pub factor: f64,
    /// Severity description.
    pub severity: StressSeverity,
}

/// Stress severity classification.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum StressSeverity {
    None,
    Low,
    Moderate,
    High,
    Critical,
}

impl StressSeverity {
    pub fn from_factor(factor: f64) -> Self {
        if factor >= 0.95 {
            StressSeverity::None
        } else if factor >= 0.80 {
            StressSeverity::Low
        } else if factor >= 0.60 {
            StressSeverity::Moderate
        } else if factor >= 0.40 {
            StressSeverity::High
        } else {
            StressSeverity::Critical
        }
    }
}

/// Compute temperature stress factor.
pub fn temperature_stress(avg_temp: f64, optimal_min: f64, optimal_max: f64) -> StressFactor {
    let factor = if avg_temp >= optimal_min && avg_temp <= optimal_max {
        1.0
    } else if avg_temp < optimal_min {
        let deficit = optimal_min - avg_temp;
        (1.0 - deficit / 15.0).clamp(0.0, 1.0)
    } else {
        let excess = avg_temp - optimal_max;
        (1.0 - excess / 10.0).clamp(0.0, 1.0)
    };

    StressFactor {
        name: "Temperature".to_string(),
        factor,
        severity: StressSeverity::from_factor(factor),
    }
}

/// Compute water stress factor.
pub fn water_stress(
    total_water_mm: f64,
    crop_water_requirement_mm: f64,
) -> StressFactor {
    let factor = if total_water_mm >= crop_water_requirement_mm {
        // Excess water can also cause stress
        let excess_ratio = total_water_mm / crop_water_requirement_mm;
        if excess_ratio > 1.5 {
            (1.0 - (excess_ratio - 1.5) / 2.0).clamp(0.3, 1.0)
        } else {
            1.0
        }
    } else {
        (total_water_mm / crop_water_requirement_mm).clamp(0.0, 1.0)
    };

    StressFactor {
        name: "Water".to_string(),
        factor,
        severity: StressSeverity::from_factor(factor),
    }
}

/// Compute nitrogen stress factor.
pub fn nitrogen_stress(
    available_n: f64,
    applied_n: f64,
    crop_requirement: f64,
) -> StressFactor {
    let total_n = available_n + applied_n * 0.7; // 70% uptake efficiency
    let factor = (total_n / crop_requirement).clamp(0.0, 1.0);

    StressFactor {
        name: "Nitrogen".to_string(),
        factor,
        severity: StressSeverity::from_factor(factor),
    }
}

/// Compute pest/disease pressure stress factor.
pub fn pest_stress(pest_control_effectiveness: f64) -> StressFactor {
    let factor = 0.7 + 0.3 * pest_control_effectiveness.clamp(0.0, 1.0);

    StressFactor {
        name: "Pest pressure".to_string(),
        factor,
        severity: StressSeverity::from_factor(factor),
    }
}

/// Compute soil compaction stress factor.
pub fn compaction_stress(compaction_index: f64) -> StressFactor {
    let factor = (1.0 - compaction_index * 0.5).clamp(0.5, 1.0);

    StressFactor {
        name: "Soil compaction".to_string(),
        factor,
        severity: StressSeverity::from_factor(factor),
    }
}

/// Compute frost damage stress factor.
pub fn frost_stress(frost_days: u32) -> StressFactor {
    let factor = if frost_days == 0 {
        1.0
    } else {
        (1.0 - frost_days as f64 * 0.05).clamp(0.1, 1.0)
    };

    StressFactor {
        name: "Frost damage".to_string(),
        factor,
        severity: StressSeverity::from_factor(factor),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_temperature_stress_optimal() {
        let s = temperature_stress(20.0, 15.0, 25.0);
        assert!((s.factor - 1.0).abs() < 1e-10);
        assert_eq!(s.severity, StressSeverity::None);
    }

    #[test]
    fn test_temperature_stress_cold() {
        let s = temperature_stress(5.0, 15.0, 25.0);
        assert!(s.factor < 1.0);
        assert!(s.factor > 0.0);
    }

    #[test]
    fn test_temperature_stress_hot() {
        let s = temperature_stress(35.0, 15.0, 25.0);
        assert!((s.factor - 0.0).abs() < 1e-10);
    }

    #[test]
    fn test_water_stress_adequate() {
        let s = water_stress(500.0, 500.0);
        assert!((s.factor - 1.0).abs() < 1e-10);
    }

    #[test]
    fn test_water_stress_deficit() {
        let s = water_stress(250.0, 500.0);
        assert!((s.factor - 0.5).abs() < 1e-10);
    }

    #[test]
    fn test_water_stress_excess() {
        let s = water_stress(1000.0, 500.0);
        assert!(s.factor < 1.0); // Excess water causes some stress
    }

    #[test]
    fn test_frost_stress_no_frost() {
        let s = frost_stress(0);
        assert!((s.factor - 1.0).abs() < 1e-10);
    }

    #[test]
    fn test_frost_stress_some_frost() {
        let s = frost_stress(5);
        assert!((s.factor - 0.75).abs() < 1e-10);
    }

    #[test]
    fn test_severity_classification() {
        assert_eq!(StressSeverity::from_factor(1.0), StressSeverity::None);
        assert_eq!(StressSeverity::from_factor(0.9), StressSeverity::Low);
        assert_eq!(StressSeverity::from_factor(0.7), StressSeverity::Moderate);
        assert_eq!(StressSeverity::from_factor(0.5), StressSeverity::High);
        assert_eq!(StressSeverity::from_factor(0.2), StressSeverity::Critical);
    }
}
