/// Soil biogeochemistry reaction pathways.
///
/// Ported from the Julia `NutrientDiffusion` module. All concentrations
/// in mg/kg (ppm dry soil), rates in mg/kg/day, temperatures in degrees C.

// ---------------------------------------------------------------------------
// 1. Mineralization: organic N -> NH4
// ---------------------------------------------------------------------------

/// Organic-N mineralization rate (mg N / kg / day).
///
/// First-order kinetics modulated by temperature (Q10 = 2.0, T_ref = 25 C)
/// and a piecewise moisture factor with optimum at field capacity.
///
/// `organic_n`     -- organic N pool (mg/kg)
/// `temperature`   -- soil temperature (deg C)
/// `moisture`      -- volumetric water content (m3/m3)
/// `clay_fraction` -- clay mass fraction 0-1 (used as a proxy; the Julia
///                    code derives the organic-N pool from OM% instead, but
///                    here we accept the pool directly and use `clay_fraction`
///                    to scale the potential rate: higher clay -> slower
///                    turnover because of physical protection).
pub fn mineralization_rate(
    organic_n: f64,
    temperature: f64,
    moisture: f64,
    clay_fraction: f64,
) -> f64 {
    mineralization_rate_params(organic_n, temperature, moisture, clay_fraction, 0.01, 0.30)
}

/// Full-parameter version exposed for testing / advanced callers.
pub fn mineralization_rate_params(
    organic_n: f64,
    temperature: f64,
    moisture: f64,
    clay_fraction: f64,
    potential_rate: f64,
    field_capacity: f64,
) -> f64 {
    // Temperature factor -- Q10 model (Q10 = 2.0, T_ref = 25 C)
    let f_temp = f64::max(0.0, 2.0_f64.powf((temperature - 25.0) / 10.0));

    // Moisture factor -- optimum at field capacity, declines wet and dry
    let relative_moisture = if field_capacity > 0.0 {
        moisture / field_capacity
    } else {
        0.0
    };
    let f_moist = if relative_moisture <= 0.0 {
        0.0
    } else if relative_moisture <= 1.0 {
        // Linear increase to field capacity
        relative_moisture
    } else if relative_moisture <= 1.5 {
        // Slight decline above FC (anaerobic inhibition)
        1.0 - (relative_moisture - 1.0) / 0.5 * 0.5
    } else {
        0.5 // Saturated conditions
    };

    // Clay protection factor: higher clay slows decomposition
    let clay_factor = 1.0 - 0.5 * clay_fraction.clamp(0.0, 1.0);

    // Rate = k_pot * organic_N_pool * f(T) * f(theta) * f(clay)
    let rate = potential_rate * organic_n * f_temp * f_moist * clay_factor;
    f64::max(0.0, rate)
}

// ---------------------------------------------------------------------------
// 2. Nitrification: NH4 -> NO3
// ---------------------------------------------------------------------------

/// Nitrification rate (mg N / kg / day).
///
/// Modulated by substrate (Michaelis-Menten, K_m = 10 mg/kg), temperature
/// (piecewise: zero below 5 C / above 50 C, optimum 30 C), moisture
/// (optimum at 60 % of FC), and pH (optimum 6-8).
pub fn nitrification_rate(nh4: f64, temperature: f64, moisture: f64, ph: f64) -> f64 {
    nitrification_rate_params(nh4, temperature, moisture, ph, 5.0, 0.30)
}

/// Full-parameter version.
pub fn nitrification_rate_params(
    nh4: f64,
    temperature: f64,
    moisture: f64,
    ph: f64,
    max_rate: f64,
    field_capacity: f64,
) -> f64 {
    if nh4 <= 0.0 {
        return 0.0;
    }

    // Substrate limitation (Michaelis-Menten)
    let km_nh4 = 10.0; // mg/kg
    let f_substrate = nh4 / (km_nh4 + nh4);

    // Temperature factor (optimum ~30 C, zero below 5 / above 50)
    let f_temp = if temperature < 5.0 || temperature > 50.0 {
        0.0
    } else if temperature <= 30.0 {
        (temperature - 5.0) / 25.0
    } else {
        (50.0 - temperature) / 20.0
    };
    let f_temp = f64::max(0.0, f_temp);

    // Moisture factor (optimum at 60 % of FC)
    let wfps = if field_capacity > 0.0 {
        moisture / field_capacity
    } else {
        0.0
    };
    let f_moist = if wfps <= 0.2 {
        0.0
    } else if wfps <= 0.6 {
        (wfps - 0.2) / 0.4
    } else if wfps <= 1.0 {
        1.0
    } else {
        // Decline under waterlogged conditions (O2 limitation)
        f64::max(0.0, 1.0 - (wfps - 1.0) / 0.5)
    };

    // pH factor (optimum 6-8)
    let f_ph = if ph < 4.0 {
        0.0
    } else if ph < 6.0 {
        (ph - 4.0) / 2.0
    } else if ph <= 8.0 {
        1.0
    } else if ph <= 9.5 {
        (9.5 - ph) / 1.5
    } else {
        0.0
    };

    let rate = max_rate * f_substrate * f_temp * f_moist * f_ph;
    f64::max(0.0, rate)
}

// ---------------------------------------------------------------------------
// 3. Denitrification: NO3 -> N2O / N2
// ---------------------------------------------------------------------------

/// Denitrification rate (mg N / kg / day).
///
/// Occurs under anaerobic conditions. Substrate limitation (K_m = 5 mg/kg),
/// Q10 = 2.5 temperature response, moisture threshold at WFPS > 60 %.
///
/// `organic_c` acts as an electron-donor scaling factor (the Julia reference
/// uses a fixed `max_rate`; here we additionally allow organic-C to modulate
/// the ceiling rate so carbon-poor soils denitrify less).
pub fn denitrification_rate(
    no3: f64,
    organic_c: f64,
    moisture: f64,
    temperature: f64,
) -> f64 {
    denitrification_rate_params(no3, organic_c, moisture, temperature, 3.0, 0.30, 0.45)
}

/// Full-parameter version.
pub fn denitrification_rate_params(
    no3: f64,
    organic_c: f64,
    moisture: f64,
    temperature: f64,
    max_rate: f64,
    _field_capacity: f64,
    porosity: f64,
) -> f64 {
    if no3 <= 0.0 {
        return 0.0;
    }

    // Substrate limitation
    let km_no3 = 5.0; // mg/kg
    let f_substrate = no3 / (km_no3 + no3);

    // Temperature factor (Q10 = 2.5)
    let f_temp = if temperature < 2.0 {
        0.0
    } else {
        f64::max(0.0, 2.5_f64.powf((temperature - 25.0) / 10.0))
    };

    // Moisture factor: significant only when WFPS > 60 %
    let wfps = if porosity > 0.0 {
        moisture / porosity
    } else {
        0.0
    };
    let f_moist = if wfps < 0.60 {
        0.0
    } else if wfps < 0.80 {
        (wfps - 0.60) / 0.20
    } else {
        1.0
    };

    // Organic carbon modulation: scale max_rate by available C
    // Normalised so that organic_c ~ 20_000 mg/kg (2 % SOM) gives factor 1.0
    let c_factor = (organic_c / 20_000.0).clamp(0.0, 2.0);

    let rate = max_rate * f_substrate * f_temp * f_moist * c_factor;
    f64::max(0.0, rate)
}

// ---------------------------------------------------------------------------
// 4. Phosphorus sorption (Freundlich isotherm)
// ---------------------------------------------------------------------------

/// Sorbed phosphorus (mg/kg) from solution concentration via Freundlich
/// isotherm: S = K_f * C^(1/n).
///
/// `p_solution`   -- solution-phase P (mg/kg)
/// `kf`           -- Freundlich coefficient
/// `n_freundlich` -- Freundlich exponent (dimensionless, typically 0.3-0.8)
pub fn phosphorus_sorption(p_solution: f64, kf: f64, n_freundlich: f64) -> f64 {
    if p_solution <= 0.0 {
        return 0.0;
    }
    let kf_eff = f64::max(0.01, kf);
    let exponent = if n_freundlich.abs() > 1e-12 {
        1.0 / n_freundlich
    } else {
        1.0
    };
    kf_eff * p_solution.powf(exponent)
}

// ---------------------------------------------------------------------------
// 5. Root nutrient uptake (Michaelis-Menten)
// ---------------------------------------------------------------------------

/// Root nutrient uptake rate (mg / kg / day) using Michaelis-Menten kinetics:
///
/// `uptake = V_max * C / (K_m + C) * root_density`
///
/// `concentration` -- nutrient concentration in soil solution (mg/kg)
/// `vmax`          -- maximum uptake rate (mg/kg/day per unit root density)
/// `km`            -- half-saturation constant (mg/kg)
/// `root_density`  -- normalised root density (dimensionless, 0-1)
pub fn root_uptake(concentration: f64, vmax: f64, km: f64, root_density: f64) -> f64 {
    if concentration <= 0.0 {
        return 0.0;
    }
    vmax * concentration / (km + concentration) * root_density
}

// ---------------------------------------------------------------------------
// Convenience: run the full biogeochemistry pipeline for one cell/layer
// ---------------------------------------------------------------------------

use crate::types::SoilLayerProperties;

/// Reaction deltas for one layer over one time-step.
#[derive(Debug, Clone, Default)]
pub struct ReactionDeltas {
    pub d_nh4: f64,
    pub d_no3: f64,
    pub d_organic_n: f64,
    pub d_phosphorus: f64,
    pub d_potassium: f64,
}

/// Run the full biogeochemistry pipeline for a single layer and return the
/// concentration changes (deltas in mg/kg/day, NOT yet multiplied by dt).
///
/// Sequence: mineralization -> nitrification -> denitrification -> uptake -> sorption.
pub fn compute_reactions(
    nh4: f64,
    no3: f64,
    organic_n: f64,
    organic_c: f64,
    phosphorus: f64,
    potassium: f64,
    temperature: f64,
    moisture: f64,
    root_density: f64,
    props: &SoilLayerProperties,
) -> ReactionDeltas {
    // 1. Mineralization: organic N -> NH4
    let miner = mineralization_rate_params(
        organic_n,
        temperature,
        moisture,
        props.clay_fraction,
        0.01,
        props.field_capacity,
    );

    // 2. Nitrification: NH4 -> NO3
    let nitrif = nitrification_rate_params(
        f64::max(0.0, nh4),
        temperature,
        moisture,
        props.ph,
        5.0,
        props.field_capacity,
    );

    // 3. Denitrification: NO3 -> N2 (loss)
    let denitrif = denitrification_rate_params(
        f64::max(0.0, no3),
        organic_c,
        moisture,
        temperature,
        3.0,
        props.field_capacity,
        props.porosity,
    );

    // 4. Root uptake (Michaelis-Menten)
    let uptake_no3 = root_uptake(f64::max(0.0, no3), 8.0, 5.0, root_density);
    let uptake_nh4 = root_uptake(f64::max(0.0, nh4), 4.0, 3.0, root_density);
    let uptake_p = root_uptake(f64::max(0.0, phosphorus), 1.5, 0.5, root_density);
    let uptake_k = root_uptake(f64::max(0.0, potassium), 5.0, 2.0, root_density);

    // 5. P sorption (not a delta per se, but reduces available P towards equilibrium)
    let p_sorbed_eq = phosphorus_sorption(
        f64::max(0.0, phosphorus),
        props.kf_phosphorus(),
        0.7,
    );
    // Drive available P toward sorption equilibrium at a rate proportional to
    // the difference (simple relaxation, ~10 % per day toward equilibrium).
    let sorption_rate = 0.1 * (p_sorbed_eq - f64::max(0.0, phosphorus)).min(0.0);

    ReactionDeltas {
        d_nh4: miner - nitrif - uptake_nh4,
        d_no3: nitrif - denitrif - uptake_no3,
        d_organic_n: -miner * 0.1, // slow decline of organic pool
        d_phosphorus: -uptake_p + sorption_rate,
        d_potassium: -uptake_k,
    }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_mineralization_positive() {
        let rate = mineralization_rate(200.0, 25.0, 0.30, 0.25);
        assert!(rate > 0.0, "mineralization should be positive at reference conditions");
    }

    #[test]
    fn test_mineralization_zero_moisture() {
        let rate = mineralization_rate(200.0, 25.0, 0.0, 0.25);
        assert_eq!(rate, 0.0, "zero moisture should give zero mineralization");
    }

    #[test]
    fn test_nitrification_substrate() {
        let rate_low = nitrification_rate(1.0, 25.0, 0.25, 6.5);
        let rate_high = nitrification_rate(50.0, 25.0, 0.25, 6.5);
        assert!(rate_high > rate_low, "more NH4 should give higher nitrification");
    }

    #[test]
    fn test_nitrification_zero_nh4() {
        let rate = nitrification_rate(0.0, 25.0, 0.25, 6.5);
        assert_eq!(rate, 0.0);
    }

    #[test]
    fn test_nitrification_extreme_temp() {
        assert_eq!(nitrification_rate(10.0, 3.0, 0.25, 6.5), 0.0);
        assert_eq!(nitrification_rate(10.0, 55.0, 0.25, 6.5), 0.0);
    }

    #[test]
    fn test_denitrification_dry() {
        // Dry soil (moisture well below 60 % WFPS) should give zero
        let rate = denitrification_rate(20.0, 20000.0, 0.10, 25.0);
        assert_eq!(rate, 0.0, "dry soil should not denitrify");
    }

    #[test]
    fn test_denitrification_wet() {
        let rate = denitrification_rate(20.0, 20000.0, 0.40, 25.0);
        assert!(rate > 0.0, "wet soil with NO3 should denitrify");
    }

    #[test]
    fn test_phosphorus_sorption_zero() {
        assert_eq!(phosphorus_sorption(0.0, 0.5, 0.7), 0.0);
    }

    #[test]
    fn test_phosphorus_sorption_positive() {
        let s = phosphorus_sorption(10.0, 0.5, 0.7);
        assert!(s > 0.0, "positive P should give positive sorption");
    }

    #[test]
    fn test_root_uptake_zero_conc() {
        assert_eq!(root_uptake(0.0, 8.0, 5.0, 1.0), 0.0);
    }

    #[test]
    fn test_root_uptake_michaelis_menten() {
        let u1 = root_uptake(5.0, 8.0, 5.0, 1.0);  // C = K_m -> V_max/2
        assert!((u1 - 4.0).abs() < 1e-10, "at C=K_m, uptake should be Vmax/2");
    }

    #[test]
    fn test_compute_reactions_does_not_panic() {
        let props = SoilLayerProperties::default();
        let deltas = compute_reactions(
            5.0, 15.0, 200.0, 20000.0, 20.0, 150.0,
            20.0, 0.25, 0.5, &props,
        );
        // NH4 should change (mineralization adds, nitrification removes)
        // Just check it doesn't panic and produces finite values
        assert!(deltas.d_nh4.is_finite());
        assert!(deltas.d_no3.is_finite());
        assert!(deltas.d_organic_n.is_finite());
        assert!(deltas.d_phosphorus.is_finite());
        assert!(deltas.d_potassium.is_finite());
    }
}
