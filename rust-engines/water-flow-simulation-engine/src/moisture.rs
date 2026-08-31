//! Soil moisture simulation using a simplified Richards equation approach.

use ndarray::Array1;
use serde::{Deserialize, Serialize};
use thiserror::Error;

/// Errors from moisture simulation.
#[derive(Debug, Error)]
pub enum MoistureError {
    #[error("Invalid layer count: {0} (must be >= 1)")]
    InvalidLayers(usize),

    #[error("Invalid time step: {0} (must be > 0)")]
    InvalidTimeStep(f64),

    #[error("Moisture out of range at layer {layer}: {value} (must be 0-1)")]
    MoistureOutOfRange { layer: usize, value: f64 },
}

/// Soil moisture simulation parameters.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MoistureParams {
    /// Number of soil layers.
    pub num_layers: usize,
    /// Layer thickness in meters.
    pub layer_thickness_m: f64,
    /// Saturated hydraulic conductivity (m/day).
    pub k_sat_m_day: f64,
    /// Field capacity (volumetric water content, 0-1).
    pub field_capacity: f64,
    /// Wilting point (volumetric water content, 0-1).
    pub wilting_point: f64,
    /// Saturation water content (0-1).
    pub saturation: f64,
    /// Root zone depth (m).
    pub root_zone_depth_m: f64,
}

impl Default for MoistureParams {
    fn default() -> Self {
        Self {
            num_layers: 10,
            layer_thickness_m: 0.1,
            k_sat_m_day: 0.05,
            field_capacity: 0.30,
            wilting_point: 0.10,
            saturation: 0.45,
            root_zone_depth_m: 0.6,
        }
    }
}

/// Soil moisture state at a point in time.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SoilMoistureProfile {
    /// Volumetric water content per layer (0-1).
    pub moisture: Vec<f64>,
    /// Layer thickness (m).
    pub layer_thickness_m: f64,
    /// Time in days.
    pub time_days: f64,
    /// Total water stored in root zone (mm).
    pub root_zone_water_mm: f64,
    /// Available water in root zone (mm, above wilting point).
    pub available_water_mm: f64,
    /// Drainage from bottom layer (mm/day).
    pub drainage_mm_day: f64,
}

/// Simulate soil moisture evolution over time.
///
/// Uses a simplified bucket model with downward percolation between layers.
///
/// # Arguments
/// * `params` - Soil parameters
/// * `initial_moisture` - Initial volumetric water content per layer (0-1)
/// * `rainfall_mm_day` - Daily rainfall input (mm)
/// * `et_mm_day` - Daily evapotranspiration (mm)
/// * `irrigation_mm_day` - Daily irrigation input (mm)
/// * `days` - Number of days to simulate
/// * `time_step_days` - Simulation time step (days)
pub fn simulate_moisture(
    params: &MoistureParams,
    initial_moisture: &[f64],
    rainfall_mm_day: f64,
    et_mm_day: f64,
    irrigation_mm_day: f64,
    days: f64,
    time_step_days: f64,
) -> Result<Vec<SoilMoistureProfile>, MoistureError> {
    if params.num_layers == 0 {
        return Err(MoistureError::InvalidLayers(params.num_layers));
    }
    if time_step_days <= 0.0 {
        return Err(MoistureError::InvalidTimeStep(time_step_days));
    }

    let n = params.num_layers;
    let mut moisture = Array1::from_vec(
        if initial_moisture.len() == n {
            initial_moisture.to_vec()
        } else {
            vec![params.field_capacity; n]
        },
    );

    let steps = (days / time_step_days).ceil() as usize;
    let root_layers = (params.root_zone_depth_m / params.layer_thickness_m).ceil() as usize;
    let root_layers = root_layers.min(n);

    let mut results = Vec::with_capacity(steps + 1);

    // Record initial state
    results.push(make_profile(&moisture, params, root_layers, 0.0, 0.0));

    let layer_capacity_mm = params.layer_thickness_m * 1000.0; // 1m of soil = 1000mm

    for step in 0..steps {
        let t = (step + 1) as f64 * time_step_days;

        // Infiltration: add rainfall + irrigation to top layer
        let infiltration_mm = (rainfall_mm_day + irrigation_mm_day) * time_step_days;
        let infiltration_vol = infiltration_mm / (params.layer_thickness_m * 1000.0);
        moisture[0] = (moisture[0] + infiltration_vol).min(params.saturation);

        // ET extraction from root zone layers (distributed by depth)
        let et_mm = et_mm_day * time_step_days;
        let et_per_layer_vol = et_mm / (root_layers as f64 * params.layer_thickness_m * 1000.0);
        for i in 0..root_layers {
            let depth_factor = 1.0 - (i as f64 / root_layers as f64) * 0.5;
            let extraction = et_per_layer_vol * depth_factor;
            moisture[i] = (moisture[i] - extraction).max(params.wilting_point);
        }

        // Percolation: water above field capacity drains to next layer
        let mut drainage = 0.0;
        for i in 0..n {
            if moisture[i] > params.field_capacity {
                let excess = moisture[i] - params.field_capacity;
                let drain_rate = (excess / (params.saturation - params.field_capacity))
                    * params.k_sat_m_day
                    * time_step_days
                    / params.layer_thickness_m;
                let actual_drain = excess.min(drain_rate);
                moisture[i] -= actual_drain;

                if i + 1 < n {
                    let space = params.saturation - moisture[i + 1];
                    let added = actual_drain.min(space);
                    moisture[i + 1] += added;
                    if actual_drain > added {
                        // Excess stays in current layer
                        moisture[i] += actual_drain - added;
                    }
                } else {
                    drainage = actual_drain * params.layer_thickness_m * 1000.0 / time_step_days;
                }
            }
        }

        results.push(make_profile(&moisture, params, root_layers, t, drainage));
    }

    Ok(results)
}

fn make_profile(
    moisture: &Array1<f64>,
    params: &MoistureParams,
    root_layers: usize,
    time: f64,
    drainage: f64,
) -> SoilMoistureProfile {
    let root_zone_water_mm: f64 = moisture
        .iter()
        .take(root_layers)
        .map(|&m| m * params.layer_thickness_m * 1000.0)
        .sum();

    let available_water_mm: f64 = moisture
        .iter()
        .take(root_layers)
        .map(|&m| (m - params.wilting_point).max(0.0) * params.layer_thickness_m * 1000.0)
        .sum();

    SoilMoistureProfile {
        moisture: moisture.to_vec(),
        layer_thickness_m: params.layer_thickness_m,
        time_days: time,
        root_zone_water_mm,
        available_water_mm,
        drainage_mm_day: drainage,
    }
}

/// Green-Ampt infiltration model parameters.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GreenAmptParams {
    /// Saturated hydraulic conductivity (mm/hr).
    pub k_sat_mm_hr: f64,
    /// Wetting front suction head (mm).
    pub suction_head_mm: f64,
    /// Initial moisture deficit (porosity - initial moisture, 0-1).
    pub moisture_deficit: f64,
    /// Porosity (0-1).
    pub porosity: f64,
}

impl Default for GreenAmptParams {
    fn default() -> Self {
        Self {
            k_sat_mm_hr: 10.0,    // Typical loam
            suction_head_mm: 110.0, // Typical loam
            moisture_deficit: 0.15,
            porosity: 0.45,
        }
    }
}

/// Green-Ampt infiltration result for a single time step.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct InfiltrationResult {
    /// Cumulative infiltration (mm).
    pub cumulative_infiltration_mm: f64,
    /// Infiltration rate at this time (mm/hr).
    pub infiltration_rate_mm_hr: f64,
    /// Ponding time (hr), if ponding has occurred.
    pub ponding_time_hr: Option<f64>,
    /// Runoff generated (mm).
    pub runoff_mm: f64,
    /// Time (hr).
    pub time_hr: f64,
}

/// Compute Green-Ampt infiltration over time.
///
/// The Green-Ampt model computes cumulative infiltration as:
/// F = K_s * t + psi * dtheta * ln(1 + F / (psi * dtheta))
///
/// Solved iteratively using Newton's method.
///
/// # Arguments
/// * `params` - Green-Ampt parameters
/// * `rainfall_rate_mm_hr` - Constant rainfall rate (mm/hr)
/// * `duration_hr` - Total simulation duration (hr)
/// * `time_step_hr` - Time step (hr)
pub fn green_ampt_infiltration(
    params: &GreenAmptParams,
    rainfall_rate_mm_hr: f64,
    duration_hr: f64,
    time_step_hr: f64,
) -> Vec<InfiltrationResult> {
    let ks = params.k_sat_mm_hr;
    let psi = params.suction_head_mm;
    let dtheta = params.moisture_deficit;
    let psi_dtheta = psi * dtheta;

    let steps = (duration_hr / time_step_hr).ceil() as usize;
    let mut results = Vec::with_capacity(steps + 1);
    let mut cumulative_f = 0.0;
    let mut ponding_time: Option<f64> = None;
    let mut ponded = false;

    // Check if rainfall exceeds Ksat from the start
    if rainfall_rate_mm_hr <= ks {
        // All rainfall infiltrates
        for step in 0..=steps {
            let t = step as f64 * time_step_hr;
            cumulative_f = rainfall_rate_mm_hr * t;
            let rate = rainfall_rate_mm_hr;
            results.push(InfiltrationResult {
                cumulative_infiltration_mm: cumulative_f,
                infiltration_rate_mm_hr: rate,
                ponding_time_hr: None,
                runoff_mm: 0.0,
                time_hr: t,
            });
        }
        return results;
    }

    // Compute ponding time: tp = Ks * psi * dtheta / (R * (R - Ks))
    let tp = ks * psi_dtheta / (rainfall_rate_mm_hr * (rainfall_rate_mm_hr - ks));
    let fp_at_ponding = rainfall_rate_mm_hr * tp;

    for step in 0..=steps {
        let t = step as f64 * time_step_hr;

        if !ponded && t < tp {
            // Before ponding: all rainfall infiltrates
            cumulative_f = rainfall_rate_mm_hr * t;
            results.push(InfiltrationResult {
                cumulative_infiltration_mm: cumulative_f,
                infiltration_rate_mm_hr: rainfall_rate_mm_hr,
                ponding_time_hr: None,
                runoff_mm: 0.0,
                time_hr: t,
            });
        } else {
            if !ponded {
                ponded = true;
                ponding_time = Some(tp);
                cumulative_f = fp_at_ponding;
            }

            // After ponding: solve Green-Ampt equation iteratively
            let t_since_ponding = t - tp;
            let target = ks * t_since_ponding + fp_at_ponding;

            // Newton's method to solve: F - psi*dtheta*ln(1 + F/(psi*dtheta)) = target
            let mut f_guess = cumulative_f;
            for _ in 0..50 {
                let g = f_guess - psi_dtheta * (1.0 + f_guess / psi_dtheta).ln() - target;
                let g_prime = 1.0 - psi_dtheta / (psi_dtheta + f_guess);
                if g_prime.abs() < 1e-12 {
                    break;
                }
                let correction = g / g_prime;
                f_guess -= correction;
                if correction.abs() < 1e-8 {
                    break;
                }
            }
            f_guess = f_guess.max(cumulative_f);

            let rate = ks * (1.0 + psi_dtheta / f_guess);
            let total_rain = rainfall_rate_mm_hr * t;
            let runoff = (total_rain - f_guess).max(0.0);

            cumulative_f = f_guess;

            results.push(InfiltrationResult {
                cumulative_infiltration_mm: cumulative_f,
                infiltration_rate_mm_hr: rate.min(rainfall_rate_mm_hr),
                ponding_time_hr: ponding_time,
                runoff_mm: runoff,
                time_hr: t,
            });
        }
    }

    results
}

/// Compute available water content (AWC) in mm for a soil layer.
///
/// AWC = (field_capacity - wilting_point) * depth_mm
pub fn available_water_content(field_capacity: f64, wilting_point: f64, depth_mm: f64) -> f64 {
    ((field_capacity - wilting_point) * depth_mm).max(0.0)
}

/// Compute soil moisture depletion fraction (0 = field capacity, 1 = wilting point).
pub fn depletion_fraction(current_moisture: f64, field_capacity: f64, wilting_point: f64) -> f64 {
    if field_capacity <= wilting_point {
        return 1.0;
    }
    (1.0 - (current_moisture - wilting_point) / (field_capacity - wilting_point)).clamp(0.0, 1.0)
}

/// Compute drainage rate from a soil layer given current moisture and parameters.
/// Uses a simple power-law relationship.
pub fn drainage_rate_mm_day(
    current_moisture: f64,
    field_capacity: f64,
    saturation: f64,
    k_sat_mm_day: f64,
) -> f64 {
    if current_moisture <= field_capacity {
        return 0.0;
    }
    let excess = (current_moisture - field_capacity) / (saturation - field_capacity);
    k_sat_mm_day * excess.powf(2.0)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_default_params() {
        let params = MoistureParams::default();
        assert_eq!(params.num_layers, 10);
        assert!(params.field_capacity > params.wilting_point);
        assert!(params.saturation > params.field_capacity);
    }

    #[test]
    fn test_simulation_produces_output() {
        let params = MoistureParams::default();
        let initial = vec![params.field_capacity; params.num_layers];
        let results = simulate_moisture(
            &params, &initial, 5.0, 3.0, 0.0, 7.0, 1.0,
        ).unwrap();
        // 7 days with dt=1 => 7 steps + initial = 8 profiles
        assert_eq!(results.len(), 8);
    }

    #[test]
    fn test_drying_without_rain() {
        let params = MoistureParams::default();
        let initial = vec![params.field_capacity; params.num_layers];
        let results = simulate_moisture(
            &params, &initial, 0.0, 5.0, 0.0, 10.0, 1.0,
        ).unwrap();
        let first = &results[0];
        let last = &results[results.len() - 1];
        // Available water should decrease with ET and no rain
        assert!(last.available_water_mm < first.available_water_mm);
    }

    #[test]
    fn test_wetting_with_irrigation() {
        let params = MoistureParams::default();
        let initial = vec![params.wilting_point + 0.01; params.num_layers];
        let results = simulate_moisture(
            &params, &initial, 0.0, 0.0, 10.0, 5.0, 1.0,
        ).unwrap();
        let first = &results[0];
        let last = &results[results.len() - 1];
        // Root zone water should increase with irrigation
        assert!(last.root_zone_water_mm > first.root_zone_water_mm);
    }

    #[test]
    fn test_invalid_layers() {
        let mut params = MoistureParams::default();
        params.num_layers = 0;
        assert!(simulate_moisture(&params, &[], 0.0, 0.0, 0.0, 1.0, 1.0).is_err());
    }

    #[test]
    fn test_invalid_time_step() {
        let params = MoistureParams::default();
        assert!(simulate_moisture(&params, &[], 0.0, 0.0, 0.0, 1.0, 0.0).is_err());
    }

    #[test]
    fn test_green_ampt_low_rainfall() {
        let params = GreenAmptParams::default();
        let results = green_ampt_infiltration(&params, 5.0, 2.0, 0.5);
        // Rainfall below Ksat: all infiltrates, no runoff
        for r in &results {
            assert!((r.runoff_mm - 0.0).abs() < 1e-8);
        }
    }

    #[test]
    fn test_green_ampt_high_rainfall() {
        let params = GreenAmptParams::default();
        let results = green_ampt_infiltration(&params, 50.0, 2.0, 0.1);
        // High rainfall: ponding should occur, runoff should be generated
        let last = results.last().unwrap();
        assert!(last.runoff_mm > 0.0);
        assert!(last.ponding_time_hr.is_some());
    }

    #[test]
    fn test_available_water_content() {
        let awc = available_water_content(0.30, 0.10, 600.0);
        assert!((awc - 120.0).abs() < 1e-10);
    }

    #[test]
    fn test_depletion_fraction() {
        assert!((depletion_fraction(0.30, 0.30, 0.10) - 0.0).abs() < 1e-10);
        assert!((depletion_fraction(0.10, 0.30, 0.10) - 1.0).abs() < 1e-10);
        assert!((depletion_fraction(0.20, 0.30, 0.10) - 0.5).abs() < 1e-10);
    }

    #[test]
    fn test_drainage_rate() {
        let rate = drainage_rate_mm_day(0.30, 0.30, 0.45, 50.0);
        assert!((rate - 0.0).abs() < 1e-10);

        let rate2 = drainage_rate_mm_day(0.45, 0.30, 0.45, 50.0);
        assert!((rate2 - 50.0).abs() < 1e-10);
    }
}
