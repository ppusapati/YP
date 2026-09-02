/// Physics-based soil transport coefficients.
///
/// Ported from the Julia `NutrientDiffusion` module.

// ---------------------------------------------------------------------------
// 6. Millington-Quirk tortuosity model
// ---------------------------------------------------------------------------

/// Effective diffusion coefficient through porous media (m^2 / s).
///
/// Millington-Quirk model:
///     D_eff = D_0 * theta^(10/3) / porosity^2
///
/// `d0`       -- free-water diffusion coefficient (m^2/s)
/// `theta`    -- volumetric water content (m^3/m^3)
/// `porosity` -- total porosity (m^3/m^3)
pub fn effective_diffusion(d0: f64, theta: f64, porosity: f64) -> f64 {
    let theta = f64::max(theta, 1e-6);
    let porosity = f64::max(porosity, 1e-6);
    d0 * theta.powf(10.0 / 3.0) / (porosity * porosity)
}

// ---------------------------------------------------------------------------
// 7. Stokes-Einstein temperature correction
// ---------------------------------------------------------------------------

/// Temperature-corrected diffusion coefficient (m^2/s).
///
/// Approximate Stokes-Einstein: D ~ T / viscosity.  The full treatment
/// requires viscosity data; the Julia code uses the simplified ~2 % per deg C
/// exponential:
///     D(T) = D_ref * exp(0.02 * (T - T_ref))
///
/// `d_ref`       -- reference diffusion coefficient (m^2/s)
/// `t_ref`       -- reference temperature (deg C), typically 25
/// `temperature` -- actual soil temperature (deg C)
pub fn temperature_corrected_diffusion(d_ref: f64, t_ref: f64, temperature: f64) -> f64 {
    d_ref * (0.02_f64 * (temperature - t_ref)).exp()
}

// ---------------------------------------------------------------------------
// 8. Darcy's law advection
// ---------------------------------------------------------------------------

/// Pore-water velocity (m / day) using Darcy's law with unsaturated
/// hydraulic conductivity.
///
/// K_unsat = K_sat * (theta / field_capacity)^3      (power-law model)
/// q       = K_unsat * hydraulic_gradient              (Darcy flux, m/day)
/// v       = q / theta                                 (pore velocity)
///
/// `k_sat`               -- saturated hydraulic conductivity (m/day)
/// `theta`               -- volumetric water content (m^3/m^3)
/// `field_capacity`      -- field capacity (m^3/m^3)
/// `hydraulic_gradient`  -- total hydraulic gradient (dimensionless,
///                          includes gravity = 1 + matric component)
pub fn darcy_velocity(
    k_sat: f64,
    theta: f64,
    field_capacity: f64,
    hydraulic_gradient: f64,
) -> f64 {
    let theta = f64::max(theta, 0.01);
    let fc = f64::max(field_capacity, 0.01);
    let k_unsat = k_sat * (theta / fc).powi(3);
    let q = k_unsat * hydraulic_gradient; // Darcy flux (m/day)
    q / theta // pore velocity (m/day)
}

// ---------------------------------------------------------------------------
// Convenience: compute effective diffusion for a named nutrient
// ---------------------------------------------------------------------------

/// Free-water diffusion coefficients at 25 deg C (m^2/s) from literature.
pub fn free_water_d0(nutrient: &str) -> f64 {
    match nutrient {
        "no3" | "nitrogen" => 1.902e-9,
        "nh4" => 1.957e-9,
        "phosphorus" | "h2po4" => 0.891e-9,
        "potassium" | "k" => 1.960e-9,
        _ => 1.5e-9,
    }
}

/// Combined Millington-Quirk + Stokes-Einstein effective diffusion for a
/// nutrient species, returned in m^2/day (the Julia code converts to daily
/// by multiplying by 86400).
pub fn nutrient_effective_diffusion(
    nutrient: &str,
    theta: f64,
    temperature: f64,
    porosity: f64,
) -> f64 {
    let d0 = free_water_d0(nutrient);
    let d0_t = temperature_corrected_diffusion(d0, 25.0, temperature);
    let d_eff = effective_diffusion(d0_t, theta, porosity);
    // Convert m^2/s -> m^2/day
    d_eff * 86_400.0
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_effective_diffusion_dry() {
        // Very dry soil should have tiny effective diffusion
        let d = effective_diffusion(1.9e-9, 0.05, 0.45);
        assert!(d > 0.0);
        assert!(d < 1e-11, "dry soil D_eff should be very small");
    }

    #[test]
    fn test_effective_diffusion_wet() {
        let d_dry = effective_diffusion(1.9e-9, 0.10, 0.45);
        let d_wet = effective_diffusion(1.9e-9, 0.40, 0.45);
        assert!(d_wet > d_dry, "wetter soil should diffuse faster");
    }

    #[test]
    fn test_temperature_correction_increases() {
        let d25 = temperature_corrected_diffusion(1.9e-9, 25.0, 25.0);
        let d35 = temperature_corrected_diffusion(1.9e-9, 25.0, 35.0);
        assert!((d25 - 1.9e-9).abs() < 1e-15, "at T_ref, should equal D_ref");
        assert!(d35 > d25, "warmer -> faster diffusion");
    }

    #[test]
    fn test_darcy_velocity_positive() {
        let v = darcy_velocity(0.5, 0.30, 0.30, 1.0);
        assert!(v > 0.0);
    }

    #[test]
    fn test_darcy_velocity_dry_slower() {
        let v_wet = darcy_velocity(0.5, 0.30, 0.30, 1.0);
        let v_dry = darcy_velocity(0.5, 0.15, 0.30, 1.0);
        assert!(v_wet > v_dry, "drier soil should have slower Darcy velocity");
    }

    #[test]
    fn test_nutrient_effective_diffusion_m2_per_day() {
        let d = nutrient_effective_diffusion("no3", 0.30, 25.0, 0.45);
        // Should be in m^2/day range, on the order of 1e-6 to 1e-4
        assert!(d > 1e-8);
        assert!(d < 1e-2);
    }

    #[test]
    fn test_free_water_d0_known() {
        assert!((free_water_d0("no3") - 1.902e-9).abs() < 1e-15);
        assert!((free_water_d0("phosphorus") - 0.891e-9).abs() < 1e-15);
    }
}
