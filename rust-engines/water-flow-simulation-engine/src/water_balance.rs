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

/// Penman-Monteith reference evapotranspiration (ET0) parameters for a single day.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PenmanMonteithParams {
    /// Mean daily air temperature (degrees C).
    pub temperature_c: f64,
    /// Mean daily relative humidity (%).
    pub relative_humidity_pct: f64,
    /// Wind speed at 2m height (m/s).
    pub wind_speed_2m_ms: f64,
    /// Net solar radiation (MJ/m^2/day).
    pub net_radiation_mj_m2_day: f64,
    /// Soil heat flux density (MJ/m^2/day), typically small.
    pub soil_heat_flux_mj_m2_day: f64,
    /// Atmospheric pressure (kPa).
    pub pressure_kpa: f64,
    /// Elevation above sea level (m), used if pressure not provided.
    pub elevation_m: f64,
}

impl Default for PenmanMonteithParams {
    fn default() -> Self {
        Self {
            temperature_c: 25.0,
            relative_humidity_pct: 60.0,
            wind_speed_2m_ms: 2.0,
            net_radiation_mj_m2_day: 15.0,
            soil_heat_flux_mj_m2_day: 0.0,
            pressure_kpa: 101.3,
            elevation_m: 0.0,
        }
    }
}

/// Compute FAO-56 Penman-Monteith reference ET0 (mm/day).
///
/// ET0 = [0.408 * Delta * (Rn - G) + gamma * (900/(T+273)) * u2 * (es - ea)]
///       / [Delta + gamma * (1 + 0.34 * u2)]
///
/// where:
/// - Delta = slope of the saturation vapor pressure curve (kPa/°C)
/// - Rn = net radiation (MJ/m²/day)
/// - G = soil heat flux (MJ/m²/day)
/// - gamma = psychrometric constant (kPa/°C)
/// - T = mean temperature (°C)
/// - u2 = wind speed at 2m (m/s)
/// - es = saturation vapor pressure (kPa)
/// - ea = actual vapor pressure (kPa)
pub fn penman_monteith_et0(params: &PenmanMonteithParams) -> f64 {
    let t = params.temperature_c;
    let rh = params.relative_humidity_pct / 100.0;
    let u2 = params.wind_speed_2m_ms;
    let rn = params.net_radiation_mj_m2_day;
    let g = params.soil_heat_flux_mj_m2_day;

    // Atmospheric pressure from elevation if needed
    let p = if params.pressure_kpa > 0.0 {
        params.pressure_kpa
    } else {
        101.3 * ((293.0 - 0.0065 * params.elevation_m) / 293.0).powf(5.26)
    };

    // Psychrometric constant
    let gamma = 0.000665 * p;

    // Saturation vapor pressure
    let es = 0.6108 * (17.27 * t / (t + 237.3)).exp();

    // Actual vapor pressure
    let ea = es * rh;

    // Slope of saturation vapor pressure curve
    let delta = 4098.0 * es / (t + 237.3).powi(2);

    // FAO-56 PM equation
    let numerator = 0.408 * delta * (rn - g) + gamma * (900.0 / (t + 273.0)) * u2 * (es - ea);
    let denominator = delta + gamma * (1.0 + 0.34 * u2);

    (numerator / denominator).max(0.0)
}

/// Crop coefficient (Kc) for different growth stages.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CropCoefficients {
    /// Initial stage Kc (planting to 10% canopy cover).
    pub kc_ini: f64,
    /// Mid-season Kc (full canopy to start of maturation).
    pub kc_mid: f64,
    /// Late-season Kc (maturation to harvest).
    pub kc_end: f64,
    /// Duration of initial stage (days).
    pub days_ini: u32,
    /// Duration of development stage (days).
    pub days_dev: u32,
    /// Duration of mid-season stage (days).
    pub days_mid: u32,
    /// Duration of late-season stage (days).
    pub days_late: u32,
}

impl CropCoefficients {
    /// Kc for wheat (typical values).
    pub fn wheat() -> Self {
        Self {
            kc_ini: 0.3, kc_mid: 1.15, kc_end: 0.25,
            days_ini: 30, days_dev: 40, days_mid: 40, days_late: 30,
        }
    }

    /// Kc for corn (typical values).
    pub fn corn() -> Self {
        Self {
            kc_ini: 0.3, kc_mid: 1.20, kc_end: 0.35,
            days_ini: 25, days_dev: 35, days_mid: 45, days_late: 25,
        }
    }

    /// Kc for rice (typical values).
    pub fn rice() -> Self {
        Self {
            kc_ini: 1.05, kc_mid: 1.20, kc_end: 0.90,
            days_ini: 30, days_dev: 30, days_mid: 60, days_late: 30,
        }
    }

    /// Get the Kc value for a given day after planting.
    pub fn kc_at_day(&self, day: u32) -> f64 {
        let end_ini = self.days_ini;
        let end_dev = end_ini + self.days_dev;
        let end_mid = end_dev + self.days_mid;
        let end_late = end_mid + self.days_late;

        if day <= end_ini {
            self.kc_ini
        } else if day <= end_dev {
            // Linear interpolation from kc_ini to kc_mid
            let frac = (day - end_ini) as f64 / self.days_dev as f64;
            self.kc_ini + frac * (self.kc_mid - self.kc_ini)
        } else if day <= end_mid {
            self.kc_mid
        } else if day <= end_late {
            // Linear interpolation from kc_mid to kc_end
            let frac = (day - end_mid) as f64 / self.days_late as f64;
            self.kc_mid + frac * (self.kc_end - self.kc_mid)
        } else {
            self.kc_end
        }
    }

    /// Total growing season length.
    pub fn total_days(&self) -> u32 {
        self.days_ini + self.days_dev + self.days_mid + self.days_late
    }
}

/// Compute effective rainfall using the USDA SCS method.
///
/// For rainfall <= 250 mm/month:
///   P_eff = P * (125 - 0.2*P) / 125
/// For rainfall > 250 mm/month:
///   P_eff = 125 + 0.1*P
pub fn effective_rainfall_scs(rainfall_mm: f64) -> f64 {
    if rainfall_mm <= 0.0 {
        0.0
    } else if rainfall_mm <= 250.0 {
        rainfall_mm * (125.0 - 0.2 * rainfall_mm) / 125.0
    } else {
        125.0 + 0.1 * rainfall_mm
    }
}

/// Compute effective rainfall (daily, simple approach).
/// Uses a fixed efficiency factor that decreases with heavy rainfall.
pub fn effective_rainfall_daily(rainfall_mm: f64, et_mm: f64) -> f64 {
    if rainfall_mm <= 0.0 {
        return 0.0;
    }
    // Light rain: high efficiency; heavy rain: excess runs off
    let max_effective = et_mm * 3.0;
    let efficiency = if rainfall_mm <= 5.0 {
        0.6 // Light rain has lower efficiency (interception)
    } else if rainfall_mm <= 20.0 {
        0.8
    } else {
        0.7
    };
    (rainfall_mm * efficiency).min(max_effective)
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

    #[test]
    fn test_penman_monteith_et0() {
        let params = PenmanMonteithParams::default();
        let et0 = penman_monteith_et0(&params);
        // ET0 should be positive and reasonable (1-10 mm/day typically)
        assert!(et0 > 0.0);
        assert!(et0 < 15.0);
    }

    #[test]
    fn test_penman_monteith_hot_dry() {
        let params = PenmanMonteithParams {
            temperature_c: 35.0,
            relative_humidity_pct: 20.0,
            wind_speed_2m_ms: 3.0,
            net_radiation_mj_m2_day: 22.0,
            ..Default::default()
        };
        let et0 = penman_monteith_et0(&params);
        // Hot dry conditions should have high ET
        assert!(et0 > 5.0);
    }

    #[test]
    fn test_crop_coefficients_wheat() {
        let kc = CropCoefficients::wheat();
        assert!((kc.kc_at_day(1) - kc.kc_ini).abs() < 1e-10);
        // Mid-season
        let mid_day = kc.days_ini + kc.days_dev + kc.days_mid / 2;
        assert!((kc.kc_at_day(mid_day) - kc.kc_mid).abs() < 1e-10);
        // After harvest
        let total = kc.total_days();
        assert!((kc.kc_at_day(total + 10) - kc.kc_end).abs() < 1e-10);
    }

    #[test]
    fn test_crop_kc_interpolation() {
        let kc = CropCoefficients::wheat();
        // Development stage: should interpolate between kc_ini and kc_mid
        let dev_mid = kc.days_ini + kc.days_dev / 2;
        let val = kc.kc_at_day(dev_mid);
        assert!(val > kc.kc_ini);
        assert!(val < kc.kc_mid);
    }

    #[test]
    fn test_effective_rainfall_scs() {
        assert!((effective_rainfall_scs(0.0) - 0.0).abs() < 1e-10);
        let eff = effective_rainfall_scs(100.0);
        // Should be less than actual rainfall
        assert!(eff > 0.0);
        assert!(eff < 100.0);
    }

    #[test]
    fn test_effective_rainfall_daily() {
        let eff = effective_rainfall_daily(10.0, 5.0);
        assert!(eff > 0.0);
        assert!(eff <= 15.0); // Max is et * 3
    }
}
