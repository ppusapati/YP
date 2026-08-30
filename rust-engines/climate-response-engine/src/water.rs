use crate::types::ClimateParams;

pub fn water_balance_step(
    soil_moisture: f64,
    precipitation_mm: f64,
    et_reference_mm: f64,
    params: &ClimateParams,
) -> (f64, f64) {
    let infiltration = precipitation_mm * 0.001;
    let et_actual = et_reference_mm * 0.001
        * water_stress_factor(soil_moisture, params);
    let drainage = if soil_moisture + infiltration > params.water_field_capacity {
        (soil_moisture + infiltration - params.water_field_capacity) * 0.5
    } else {
        0.0
    };

    let new_moisture = (soil_moisture + infiltration - et_actual - drainage)
        .max(0.0)
        .min(params.water_field_capacity * 1.1);
    let stress = water_stress_factor(new_moisture, params);
    (new_moisture, stress)
}

pub fn water_stress_factor(soil_moisture: f64, params: &ClimateParams) -> f64 {
    if soil_moisture >= params.water_field_capacity {
        1.0
    } else if soil_moisture <= params.water_wilting_point {
        0.0
    } else {
        (soil_moisture - params.water_wilting_point)
            / (params.water_field_capacity - params.water_wilting_point)
    }
}

pub fn drought_index(soil_moisture: f64, params: &ClimateParams) -> f64 {
    if soil_moisture >= params.drought_threshold {
        0.0
    } else {
        1.0 - soil_moisture / params.drought_threshold
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_water_stress_at_capacity() {
        let p = ClimateParams::default();
        assert_eq!(water_stress_factor(p.water_field_capacity, &p), 1.0);
    }

    #[test]
    fn test_water_stress_at_wilting() {
        let p = ClimateParams::default();
        assert_eq!(water_stress_factor(p.water_wilting_point, &p), 0.0);
    }

    #[test]
    fn test_drought_index() {
        let p = ClimateParams::default();
        assert_eq!(drought_index(p.drought_threshold, &p), 0.0);
        assert!(drought_index(0.05, &p) > 0.0);
    }
}
