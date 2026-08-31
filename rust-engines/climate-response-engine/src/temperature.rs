use crate::types::ClimateParams;

pub fn thermal_time(temp_mean: f64, params: &ClimateParams) -> f64 {
    if temp_mean <= params.t_base || temp_mean >= params.t_max {
        0.0
    } else {
        (temp_mean - params.t_base).min(params.t_opt_high - params.t_base)
    }
}

pub fn temperature_stress_factor(temp_mean: f64, params: &ClimateParams) -> f64 {
    if temp_mean <= params.t_base || temp_mean >= params.t_max {
        0.0
    } else if temp_mean >= params.t_opt_low && temp_mean <= params.t_opt_high {
        1.0
    } else if temp_mean < params.t_opt_low {
        (temp_mean - params.t_base) / (params.t_opt_low - params.t_base)
    } else {
        (params.t_max - temp_mean) / (params.t_max - params.t_opt_high)
    }
}

pub fn frost_stress(temp_min: f64, params: &ClimateParams) -> f64 {
    if temp_min >= params.frost_threshold {
        0.0
    } else {
        ((params.frost_threshold - temp_min) / 5.0).min(1.0)
    }
}

pub fn heat_stress(temp_max: f64, params: &ClimateParams) -> f64 {
    if temp_max <= params.heat_threshold {
        0.0
    } else {
        ((temp_max - params.heat_threshold) / 5.0).min(1.0)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_thermal_time() {
        let p = ClimateParams::default();
        assert_eq!(thermal_time(5.0, &p), 0.0);
        assert!((thermal_time(20.0, &p) - 12.0).abs() < 1e-10);
        assert_eq!(thermal_time(45.0, &p), 0.0);
    }

    #[test]
    fn test_temp_stress_optimal() {
        let p = ClimateParams::default();
        assert_eq!(temperature_stress_factor(25.0, &p), 1.0);
    }

    #[test]
    fn test_frost() {
        let p = ClimateParams::default();
        assert_eq!(frost_stress(5.0, &p), 0.0);
        assert!(frost_stress(-3.0, &p) > 0.0);
    }
}
