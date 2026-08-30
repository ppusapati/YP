use crate::types::ClimateParams;

pub fn co2_fertilization_factor(co2_ppm: f64, params: &ClimateParams) -> f64 {
    if co2_ppm <= 0.0 {
        return 0.0;
    }
    let ratio = co2_ppm / params.co2_reference;
    1.0 + params.co2_sensitivity * (ratio.ln())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_co2_at_reference() {
        let p = ClimateParams::default();
        let f = co2_fertilization_factor(p.co2_reference, &p);
        assert!((f - 1.0).abs() < 1e-10);
    }

    #[test]
    fn test_elevated_co2() {
        let p = ClimateParams::default();
        let f = co2_fertilization_factor(560.0, &p);
        assert!(f > 1.0);
    }

    #[test]
    fn test_low_co2() {
        let p = ClimateParams::default();
        let f = co2_fertilization_factor(280.0, &p);
        assert!(f < 1.0);
    }
}
