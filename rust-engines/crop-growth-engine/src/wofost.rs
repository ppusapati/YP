use crate::types::{CropParams, DailyWeather, PartitionFractions};
use crate::ode::StateVec;
use crate::photosynthesis::{canopy_photosynthesis, co2_to_biomass};

// State vector indices
pub const IDX_BIOMASS: usize = 0;
pub const IDX_LAI: usize = 1;
pub const IDX_DVS: usize = 2;
pub const IDX_ROOT_DEPTH: usize = 3;
pub const IDX_SOIL_MOISTURE: usize = 4;
pub const STATE_SIZE: usize = 5;

fn temperature_factor(temp: f64, t_base: f64, t_opt: f64, t_max: f64) -> f64 {
    if temp <= t_base || temp >= t_max {
        0.0
    } else if temp <= t_opt {
        (temp - t_base) / (t_opt - t_base)
    } else {
        (t_max - temp) / (t_max - t_opt)
    }
}

fn radiation_interception(lai: f64, k_ext: f64) -> f64 {
    1.0 - (-k_ext * lai).exp()
}

/// FAO-56 water stress factor.
///
/// Uses the depletion model: no stress while soil moisture is above the
/// readily-available-water threshold, linear reduction to zero at the
/// wilting point.
///
/// `soil_moisture`: state variable on a 0-100 scale (100 = field capacity).
/// `p`: management-allowed depletion fraction (0-1, default 0.55).
pub fn fao56_water_stress(soil_moisture: f64, p: f64) -> f64 {
    let available_frac = (soil_moisture / 100.0).clamp(0.0, 1.0);
    let threshold = 1.0 - p;
    if threshold <= 0.0 {
        return if available_frac > 0.0 { 1.0 } else { 0.0 };
    }
    if available_frac >= threshold {
        1.0
    } else {
        (available_frac / threshold).clamp(0.0, 1.0)
    }
}

/// Linearly interpolate a value from a DVS-indexed table.
fn interpolate_table(dvs: f64, dvs_points: &[f64], values: &[f64]) -> f64 {
    if dvs_points.is_empty() || values.is_empty() {
        return 0.0;
    }
    if dvs <= dvs_points[0] {
        return values[0];
    }
    let last = dvs_points.len() - 1;
    if dvs >= dvs_points[last] {
        return values[last];
    }
    for i in 0..last {
        if dvs >= dvs_points[i] && dvs < dvs_points[i + 1] {
            let t = (dvs - dvs_points[i]) / (dvs_points[i + 1] - dvs_points[i]);
            return values[i] + t * (values[i + 1] - values[i]);
        }
    }
    values[last]
}

/// WOFOST-style biomass partitioning based on development stage (DVS).
///
/// Returns `(root, leaf, stem, storage)` allocations of `daily_growth`.
pub fn partition_biomass(
    dvs: f64,
    daily_growth: f64,
    fractions: &PartitionFractions,
) -> (f64, f64, f64, f64) {
    let fr_root = interpolate_table(dvs, &fractions.dvs_points, &fractions.fr_root);
    let fr_leaf = interpolate_table(dvs, &fractions.dvs_points, &fractions.fr_leaf);
    let fr_stem = interpolate_table(dvs, &fractions.dvs_points, &fractions.fr_stem);
    let fr_storage = interpolate_table(dvs, &fractions.dvs_points, &fractions.fr_storage);

    let total = fr_root + fr_leaf + fr_stem + fr_storage;
    if total <= 0.0 || daily_growth <= 0.0 {
        return (0.0, 0.0, 0.0, 0.0);
    }

    (
        daily_growth * fr_root / total,
        daily_growth * fr_leaf / total,
        daily_growth * fr_stem / total,
        daily_growth * fr_storage / total,
    )
}

pub fn growth_derivatives(
    _t: f64,
    state: &StateVec,
    params: &CropParams,
    weather: &DailyWeather,
    phenology_gdd: Option<f64>,
) -> StateVec {
    let biomass = state[IDX_BIOMASS];
    let lai = state[IDX_LAI];
    let dvs = state[IDX_DVS];
    let root_depth = state[IDX_ROOT_DEPTH];
    let soil_moisture = state[IDX_SOIL_MOISTURE];

    let temp_f = temperature_factor(weather.temperature, params.t_base, params.t_opt, params.t_max);
    let f_rad = radiation_interception(lai, params.k_ext);

    // FAO-56 water stress (replaces crude soil_moisture/100)
    let water_stress = fao56_water_stress(soil_moisture, params.depletion_fraction_p);

    // Biomass accumulation: Farquhar photosynthesis when configured, RUE fallback
    let d_biomass = if let Some(ref photo_config) = params.photosynthesis {
        // Farquhar-von Caemmerer-Berry mechanistic photosynthesis model.
        // Convert day_length (hours) to seconds for the canopy model.
        let day_seconds = weather.day_length * 3600.0;
        let co2_ppm = photo_config.default_co2_ppm;
        let humidity = photo_config.default_humidity;
        let result = canopy_photosynthesis(
            &photo_config.farquhar,
            &photo_config.canopy,
            lai,
            weather.temperature,
            weather.radiation,
            co2_ppm,
            humidity,
            day_seconds,
        );
        // Convert g CO2/m^2/day to g dry matter/m^2/day, then apply water stress
        co2_to_biomass(result.daily_assimilation_g, photo_config.growth_efficiency)
            * water_stress
    } else {
        // Original RUE model: RUE * intercepted radiation * stress factors
        params.rue * weather.radiation * f_rad * temp_f * water_stress
    };

    // LAI growth: proportional to biomass growth during vegetative phase
    let d_lai = if dvs < 1.0 && lai < params.max_lai {
        d_biomass * params.sla * (1.0 - lai / params.max_lai)
    } else if dvs >= 1.5 {
        -0.02 * lai // senescence
    } else {
        0.0
    };

    // Development stage: thermal time accumulation.
    // If phenology model provides effective GDD, use it; otherwise simple
    // method with T_max ceiling cap.
    let d_dvs = if let Some(eff_gdd) = phenology_gdd {
        eff_gdd / params.dvs_maturity
    } else {
        // T_max ceiling cap: cap temperature at t_max before computing GDD
        let gdd = (weather.temperature.min(params.t_max) - params.t_base).max(0.0);
        gdd / params.dvs_maturity
    };

    // Root growth
    let d_root = if root_depth < params.root_depth_max && dvs < 1.0 {
        params.root_growth_rate * temp_f
    } else {
        0.0
    };

    // Soil moisture: rainfall input minus crop water use
    let et = 0.004 * weather.temperature.max(0.0) * f_rad * water_stress;
    let d_moisture = weather.rainfall - et - 0.001 * soil_moisture;

    let _ = biomass;
    vec![d_biomass, d_lai, d_dvs, d_root, d_moisture]
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_temperature_factor() {
        let params = CropParams::default();
        assert_eq!(temperature_factor(5.0, params.t_base, params.t_opt, params.t_max), 0.0);
        assert!((temperature_factor(params.t_opt, params.t_base, params.t_opt, params.t_max) - 1.0).abs() < 1e-10);
        assert_eq!(temperature_factor(45.0, params.t_base, params.t_opt, params.t_max), 0.0);
    }

    #[test]
    fn test_radiation_interception() {
        assert!((radiation_interception(0.0, 0.6) - 0.0).abs() < 1e-10);
        assert!(radiation_interception(6.0, 0.6) > 0.95);
    }

    #[test]
    fn test_growth_positive() {
        let state = vec![1.0, 0.5, 0.3, 0.1, 50.0];
        let params = CropParams::default();
        let weather = DailyWeather::default();
        let derivs = growth_derivatives(0.0, &state, &params, &weather, None);
        assert!(derivs[IDX_BIOMASS] > 0.0);
    }

    #[test]
    fn test_fao56_water_stress() {
        // At field capacity (100): no stress
        assert_eq!(fao56_water_stress(100.0, 0.55), 1.0);
        // At wilting point (0): full stress
        assert_eq!(fao56_water_stress(0.0, 0.55), 0.0);
        // At threshold (45% = 1 - 0.55): just at transition
        let ws = fao56_water_stress(45.0, 0.55);
        assert!((ws - 1.0).abs() < 1e-10, "at threshold: {ws}");
        // Below threshold: linear reduction
        let ws = fao56_water_stress(22.5, 0.55);
        assert!((ws - 0.5).abs() < 1e-10, "half way: {ws}");
    }

    #[test]
    fn test_partition_biomass() {
        let pf = PartitionFractions::default();
        // At DVS=0 (germination): root=0.40, leaf=0.45, stem=0.15, storage=0.0
        let (r, l, s, st) = partition_biomass(0.0, 100.0, &pf);
        assert!((r - 40.0).abs() < 1e-6);
        assert!((l - 45.0).abs() < 1e-6);
        assert!((s - 15.0).abs() < 1e-6);
        assert!((st - 0.0).abs() < 1e-6);

        // At DVS=2.0 (maturity): storage dominates
        let (r, l, s, st) = partition_biomass(2.0, 100.0, &pf);
        assert!(st > 90.0, "storage at maturity: {st}");
        assert!(r < 1.0, "root at maturity: {r}");
        assert!((r + l + s + st - 100.0).abs() < 1e-6);
    }

    #[test]
    fn test_gdd_tmax_cap() {
        // When temperature exceeds t_max, GDD should be capped
        let state = vec![1.0, 0.5, 0.3, 0.1, 50.0];
        let params = CropParams::default(); // t_max = 40
        let hot_weather = DailyWeather {
            temperature: 45.0,
            ..Default::default()
        };
        let derivs = growth_derivatives(0.0, &state, &params, &hot_weather, None);
        // DVS rate should use capped temp: min(45, 40) - 8 = 32
        let expected_d_dvs = (45.0_f64.min(40.0) - 8.0).max(0.0) / 1600.0;
        assert!((derivs[IDX_DVS] - expected_d_dvs).abs() < 1e-10);
    }

    #[test]
    fn test_phenology_gdd_override() {
        let state = vec![1.0, 0.5, 0.3, 0.1, 50.0];
        let params = CropParams::default();
        let weather = DailyWeather::default();
        let eff_gdd = 15.0;
        let derivs = growth_derivatives(0.0, &state, &params, &weather, Some(eff_gdd));
        let expected_d_dvs = eff_gdd / params.dvs_maturity;
        assert!((derivs[IDX_DVS] - expected_d_dvs).abs() < 1e-10);
    }
}
