use crate::types::{CropParams, DailyWeather};
use crate::ode::StateVec;

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

pub fn growth_derivatives(
    _t: f64,
    state: &StateVec,
    params: &CropParams,
    weather: &DailyWeather,
) -> StateVec {
    let biomass = state[IDX_BIOMASS];
    let lai = state[IDX_LAI];
    let dvs = state[IDX_DVS];
    let root_depth = state[IDX_ROOT_DEPTH];
    let soil_moisture = state[IDX_SOIL_MOISTURE];

    let temp_f = temperature_factor(weather.temperature, params.t_base, params.t_opt, params.t_max);
    let f_rad = radiation_interception(lai, params.k_ext);
    let water_stress = (soil_moisture / 100.0).min(1.0);

    // Biomass accumulation: RUE * intercepted radiation * stress factors
    let d_biomass = params.rue * weather.radiation * f_rad * temp_f * water_stress;

    // LAI growth: proportional to biomass growth during vegetative phase
    let d_lai = if dvs < 1.0 && lai < params.max_lai {
        d_biomass * params.sla * (1.0 - lai / params.max_lai)
    } else if dvs >= 1.5 {
        -0.02 * lai // senescence
    } else {
        0.0
    };

    // Development stage: thermal time accumulation
    let gdd = (weather.temperature - params.t_base).max(0.0);
    let d_dvs = gdd / params.dvs_maturity;

    // Root growth
    let d_root = if root_depth < params.root_depth_max && dvs < 1.0 {
        params.root_growth_rate * temp_f
    } else {
        0.0
    };

    // Soil moisture: rainfall input minus crop water use
    let et = 0.004 * weather.temperature.max(0.0) * f_rad * water_stress;
    let d_moisture = weather.rainfall - et - 0.001 * soil_moisture;

    let _ = biomass; // already used via d_biomass calculation context
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
        let derivs = growth_derivatives(0.0, &state, &params, &weather);
        assert!(derivs[IDX_BIOMASS] > 0.0);
    }
}
