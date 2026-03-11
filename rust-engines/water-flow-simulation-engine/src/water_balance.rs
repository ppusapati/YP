//! Water balance computation for irrigation scheduling.

use serde::{Deserialize, Serialize};

/// Water balance parameters for a field.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WaterBalanceParams {
    /// Field area in hectares.
    pub field_area_ha: f64,
    /// Crop coefficient (Kc) for current growth stage.
    pub crop_coefficient: f64,
    /// Reference evapotranspiration (ET0) in mm/day.
    pub reference_et_mm_day: f64,
    /// Effective root zone depth in meters.
    pub root_zone_depth_m: f64,
    /// Field capacity (volumetric, 0-1).
    pub field_capacity: f64,
    /// Wilting point (volumetric, 0-1).
    pub wilting_point: f64,
    /// Management allowed depletion (0-1, typically 0.5).
    pub management_allowed_depletion: f64,
}

impl Default for WaterBalanceParams {
    fn default() -> Self {
        Self {
            field_area_ha: 1.0,
            crop_coefficient: 1.0,
            reference_et_mm_day: 5.0,
            root_zone_depth_m: 0.6,
            field_capacity: 0.30,
            wilting_point: 0.10,
            management_allowed_depletion: 0.5,
        }
    }
}

/// Water balance result for a single day.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WaterBalance {
    /// Day number.
    pub day: usize,
    /// Crop evapotranspiration (ETc) in mm/day.
    pub etc_mm_day: f64,
    /// Current soil moisture depletion from field capacity (mm).
    pub depletion_mm: f64,
    /// Total available water in root zone (mm).
    pub total_available_water_mm: f64,
    /// Readily available water (mm).
    pub readily_available_water_mm: f64,
    /// Whether irrigation is recommended.
    pub irrigation_needed: bool,
    /// Recommended irrigation amount (mm).
    pub irrigation_amount_mm: f64,
    /// Effective rainfall (mm).
    pub effective_rainfall_mm: f64,
    /// Deep percolation loss (mm).
    pub deep_percolation_mm: f64,
}

/// Compute daily water balance over a period.
///
/// Implements the FAO-56 single crop coefficient approach for
/// irrigation scheduling.
///
/// # Arguments
/// * `params` - Water balance parameters
/// * `daily_rainfall_mm` - Rainfall for each day (mm)
/// * `initial_depletion_mm` - Initial soil water depletion from field capacity (mm)
pub fn compute_water_balance(
    params: &WaterBalanceParams,
    daily_rainfall_mm: &[f64],
    initial_depletion_mm: f64,
) -> Vec<WaterBalance> {
    let total_available_water = (params.field_capacity - params.wilting_point)
        * params.root_zone_depth_m
        * 1000.0; // mm

    let readily_available_water = total_available_water * params.management_allowed_depletion;

    let etc = params.crop_coefficient * params.reference_et_mm_day;

    let mut depletion = initial_depletion_mm.clamp(0.0, total_available_water);
    let mut results = Vec::with_capacity(daily_rainfall_mm.len());

    for (day, &rainfall) in daily_rainfall_mm.iter().enumerate() {
        // Effective rainfall (simple approach: 80% of rainfall up to a max)
        let effective_rain = (rainfall * 0.8).min(etc * 3.0);

        // Deep percolation if rain exceeds soil capacity
        let rain_excess = (effective_rain - depletion).max(0.0);
        let deep_percolation = rain_excess;

        // Update depletion
        depletion = (depletion - effective_rain + etc + deep_percolation).max(0.0);

        // Check if irrigation is needed
        let irrigation_needed = depletion >= readily_available_water;
        let irrigation_amount = if irrigation_needed {
            // Irrigate back to field capacity
            depletion
        } else {
            0.0
        };

        // Apply irrigation
        if irrigation_needed {
            depletion = 0.0;
        }

        // Cap depletion at total available water
        depletion = depletion.min(total_available_water);

        results.push(WaterBalance {
            day: day + 1,
            etc_mm_day: etc,
            depletion_mm: depletion,
            total_available_water_mm: total_available_water,
            readily_available_water_mm: readily_available_water,
            irrigation_needed,
            irrigation_amount_mm: irrigation_amount,
            effective_rainfall_mm: effective_rain,
            deep_percolation_mm: deep_percolation,
        });
    }

    results
}

/// Calculate irrigation schedule summary.
pub fn irrigation_summary(balances: &[WaterBalance]) -> IrrigationSummary {
    let total_irrigation: f64 = balances.iter().map(|b| b.irrigation_amount_mm).sum();
    let total_rainfall: f64 = balances.iter().map(|b| b.effective_rainfall_mm).sum();
    let total_et: f64 = balances.iter().map(|b| b.etc_mm_day).sum();
    let irrigation_events = balances.iter().filter(|b| b.irrigation_needed).count();
    let total_deep_percolation: f64 = balances.iter().map(|b| b.deep_percolation_mm).sum();

    let irrigation_days: Vec<usize> = balances
        .iter()
        .filter(|b| b.irrigation_needed)
        .map(|b| b.day)
        .collect();

    let avg_interval = if irrigation_days.len() > 1 {
        let intervals: Vec<f64> = irrigation_days
            .windows(2)
            .map(|w| (w[1] - w[0]) as f64)
            .collect();
        intervals.iter().sum::<f64>() / intervals.len() as f64
    } else {
        0.0
    };

    IrrigationSummary {
        total_irrigation_mm: total_irrigation,
        total_effective_rainfall_mm: total_rainfall,
        total_crop_et_mm: total_et,
        total_deep_percolation_mm: total_deep_percolation,
        irrigation_events,
        average_interval_days: avg_interval,
        water_use_efficiency: if total_irrigation + total_rainfall > 0.0 {
            total_et / (total_irrigation + total_rainfall)
        } else {
            0.0
        },
    }
}

/// Summary of irrigation scheduling over a period.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct IrrigationSummary {
    pub total_irrigation_mm: f64,
    pub total_effective_rainfall_mm: f64,
    pub total_crop_et_mm: f64,
    pub total_deep_percolation_mm: f64,
    pub irrigation_events: usize,
    pub average_interval_days: f64,
    pub water_use_efficiency: f64,
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_water_balance_no_rain() {
        let params = WaterBalanceParams::default();
        let rainfall = vec![0.0; 30]; // 30 days no rain
        let results = compute_water_balance(&params, &rainfall, 0.0);
        assert_eq!(results.len(), 30);
        // At some point irrigation should be triggered
        assert!(results.iter().any(|r| r.irrigation_needed));
    }

    #[test]
    fn test_water_balance_with_rain() {
        let params = WaterBalanceParams::default();
        let rainfall = vec![10.0; 30]; // 10mm rain every day
        let results = compute_water_balance(&params, &rainfall, 0.0);
        // With 10mm/day rain and ~5mm/day ET, irrigation may not be needed
        let irrigation_count = results.iter().filter(|r| r.irrigation_needed).count();
        // Rain exceeds ET, so minimal irrigation needed
        assert!(irrigation_count < 5);
    }

    #[test]
    fn test_total_available_water() {
        let params = WaterBalanceParams {
            field_capacity: 0.30,
            wilting_point: 0.10,
            root_zone_depth_m: 0.6,
            ..Default::default()
        };
        let rainfall = vec![0.0; 1];
        let results = compute_water_balance(&params, &rainfall, 0.0);
        let taw = results[0].total_available_water_mm;
        // TAW = (0.30 - 0.10) * 0.6 * 1000 = 120mm
        assert!((taw - 120.0).abs() < 1e-5);
    }

    #[test]
    fn test_irrigation_summary() {
        let params = WaterBalanceParams::default();
        let rainfall = vec![0.0; 20];
        let results = compute_water_balance(&params, &rainfall, 0.0);
        let summary = irrigation_summary(&results);
        assert!(summary.total_crop_et_mm > 0.0);
        assert!(summary.total_irrigation_mm >= 0.0);
    }
}
