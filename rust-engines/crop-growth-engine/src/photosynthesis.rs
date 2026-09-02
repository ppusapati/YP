//! Farquhar-von Caemmerer-Berry (FvCB) photosynthesis model.
//!
//! Ported from the Julia implementation in Photosynthesis.jl.
//! Implements C3 leaf-level photosynthesis with:
//!   - Arrhenius and peaked-Arrhenius temperature responses
//!   - Rubisco-limited, RuBP-regeneration-limited, and TPU-limited rates
//!   - Ball-Berry stomatal conductance coupling
//!   - Multi-layer sunlit/shaded canopy integration via Beer-Lambert extinction

use serde::{Deserialize, Serialize};

// ---------------------------------------------------------------------------
// Physical constants
// ---------------------------------------------------------------------------

/// Universal gas constant (J/mol/K)
pub const R_GAS: f64 = 8.314;
/// Atmospheric O2 partial pressure (mmol/mol)
pub const O2_PARTIAL: f64 = 210.0;
/// Offset from Celsius to Kelvin
pub const KELVIN_OFFSET: f64 = 273.15;

// ---------------------------------------------------------------------------
// Parameter structures
// ---------------------------------------------------------------------------

/// Parameters for the Farquhar-von Caemmerer-Berry (FvCB) model of C3
/// photosynthesis at the leaf level.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FarquharParams {
    /// Max carboxylation rate at 25 deg C (umol/m^2/s)
    pub vcmax_25: f64,
    /// Max electron transport rate at 25 deg C (umol/m^2/s)
    pub jmax_25: f64,
    /// Dark respiration rate at 25 deg C (umol/m^2/s)
    pub rd_25: f64,
    /// Michaelis constant for CO2 at 25 deg C (umol/mol)
    pub kc_25: f64,
    /// Michaelis constant for O2 at 25 deg C (mmol/mol)
    pub ko_25: f64,
    /// CO2 compensation point at 25 deg C (umol/mol)
    pub gamma_star_25: f64,
    /// Curvature of electron transport light response (dimensionless)
    pub theta_j: f64,
    /// Quantum yield of electron transport (mol e-/mol photons)
    pub alpha_j: f64,

    // Activation energies (J/mol)
    pub ea_vcmax: f64,
    pub ea_jmax: f64,
    pub ea_rd: f64,
    pub ea_kc: f64,
    pub ea_ko: f64,
    pub ea_gamma_star: f64,

    /// Deactivation energy for Jmax (J/mol)
    pub hd_jmax: f64,
    /// Entropy term for Jmax (J/mol/K)
    pub ds_jmax: f64,
}

impl Default for FarquharParams {
    fn default() -> Self {
        Self {
            vcmax_25: 80.0,
            jmax_25: 140.0,
            rd_25: 1.5,
            kc_25: 404.9,         // Bernacchi et al. 2001
            ko_25: 278.4,         // mmol/mol
            gamma_star_25: 42.75, // Bernacchi et al. 2001
            theta_j: 0.7,
            alpha_j: 0.3,
            ea_vcmax: 65330.0,
            ea_jmax: 43540.0,
            ea_rd: 46390.0,
            ea_kc: 79430.0,
            ea_ko: 36380.0,
            ea_gamma_star: 37830.0,
            hd_jmax: 200000.0,
            ds_jmax: 650.0,
        }
    }
}

/// Parameters for scaling leaf-level photosynthesis to the canopy.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CanopyParams {
    /// PAR extinction coefficient (dimensionless)
    pub extinction_coefficient: f64,
    /// Leaf angle distribution: spherical = 1.0, planophile < 1, erectophile > 1
    pub leaf_angle_distribution: f64,
    /// Canopy clumping factor (0-1, 1 = uniform)
    pub clumping_factor: f64,
    /// Number of canopy layers for integration
    pub n_layers: usize,
    /// Mean leaf width (m)
    pub leaf_width: f64,
    /// Canopy height (m)
    pub canopy_height: f64,
}

impl Default for CanopyParams {
    fn default() -> Self {
        Self {
            extinction_coefficient: 0.65,
            leaf_angle_distribution: 1.0,
            clumping_factor: 0.85,
            n_layers: 5,
            leaf_width: 0.05,
            canopy_height: 1.5,
        }
    }
}

/// Combined configuration for Farquhar photosynthesis, used as an optional
/// override for the RUE model in [`CropParams`](crate::types::CropParams).
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PhotosynthesisConfig {
    pub farquhar: FarquharParams,
    pub canopy: CanopyParams,
    /// Default atmospheric CO2 (umol/mol) when not provided per-day
    #[serde(default = "default_co2")]
    pub default_co2_ppm: f64,
    /// Default relative humidity (fraction 0-1) when not provided per-day
    #[serde(default = "default_humidity")]
    pub default_humidity: f64,
    /// Growth respiration efficiency factor (dimensionless, typically ~0.7)
    #[serde(default = "default_growth_efficiency")]
    pub growth_efficiency: f64,
}

fn default_co2() -> f64 {
    415.0
}
fn default_humidity() -> f64 {
    0.7
}
fn default_growth_efficiency() -> f64 {
    0.7
}

impl Default for PhotosynthesisConfig {
    fn default() -> Self {
        Self {
            farquhar: FarquharParams::default(),
            canopy: CanopyParams::default(),
            default_co2_ppm: default_co2(),
            default_humidity: default_humidity(),
            growth_efficiency: default_growth_efficiency(),
        }
    }
}

// ---------------------------------------------------------------------------
// Result structures
// ---------------------------------------------------------------------------

/// Output from leaf-level Farquhar model.
#[derive(Debug, Clone)]
pub struct LeafPhotosynthesisResult {
    /// Net assimilation rate (umol CO2/m^2/s)
    pub an: f64,
    /// Rubisco-limited rate (umol/m^2/s)
    pub ac: f64,
    /// RuBP-regeneration (light) limited rate (umol/m^2/s)
    pub aj: f64,
    /// TPU-limited rate (umol/m^2/s)
    pub ap: f64,
    /// Dark respiration (umol/m^2/s)
    pub rd: f64,
    /// Stomatal conductance (mol/m^2/s)
    pub gs: f64,
    /// Intercellular CO2 (umol/mol)
    pub ci: f64,
}

/// Output from canopy-level photosynthesis integration.
#[derive(Debug, Clone)]
pub struct CanopyPhotosynthesisResult {
    /// Canopy gross photosynthesis (umol CO2/m^2 ground/s)
    pub gross_assimilation: f64,
    /// Canopy net photosynthesis (umol CO2/m^2 ground/s)
    pub net_assimilation: f64,
    /// Canopy dark respiration (umol CO2/m^2 ground/s)
    pub total_respiration: f64,
    /// Mean canopy stomatal conductance (mol/m^2/s)
    pub mean_stomatal_conductance: f64,
    /// Daily gross assimilation (g CO2/m^2/day)
    pub daily_assimilation_g: f64,
}

// ---------------------------------------------------------------------------
// Temperature response functions (Arrhenius / peaked Arrhenius)
// ---------------------------------------------------------------------------

/// Standard Arrhenius temperature response.
///
/// Computes the value of a parameter at `temperature_c` given its value at
/// 25 deg C and its activation energy `ea` (J/mol).
pub fn arrhenius(parameter_25: f64, ea: f64, temperature_c: f64) -> f64 {
    let tk = temperature_c + KELVIN_OFFSET;
    let tk25 = 25.0 + KELVIN_OFFSET;
    parameter_25 * ((ea * (tk - tk25)) / (R_GAS * tk * tk25)).exp()
}

/// Peaked Arrhenius (modified) temperature response for parameters that
/// decline at high temperatures (e.g. Jmax).
///
/// Includes a deactivation term with enthalpy `hd` (J/mol) and entropy `ds`
/// (J/mol/K).
pub fn peaked_arrhenius(
    parameter_25: f64,
    ea: f64,
    hd: f64,
    ds: f64,
    temperature_c: f64,
) -> f64 {
    let tk = temperature_c + KELVIN_OFFSET;
    let tk25 = 25.0 + KELVIN_OFFSET;

    let numerator = parameter_25 * ((ea * (tk - tk25)) / (R_GAS * tk * tk25)).exp();
    let denom_25 = 1.0 + ((ds * tk25 - hd) / (R_GAS * tk25)).exp();
    let denom_t = 1.0 + ((ds * tk - hd) / (R_GAS * tk)).exp();

    numerator * denom_25 / denom_t
}

/// Vcmax temperature dependence using the standard Arrhenius equation.
pub fn vcmax_temperature_response(vcmax_25: f64, ea: f64, temperature_c: f64) -> f64 {
    arrhenius(vcmax_25, ea, temperature_c)
}

/// Jmax temperature dependence using the peaked Arrhenius equation.
pub fn jmax_temperature_response(
    jmax_25: f64,
    ea: f64,
    hd: f64,
    ds: f64,
    temperature_c: f64,
) -> f64 {
    peaked_arrhenius(jmax_25, ea, hd, ds, temperature_c)
}

/// CO2 compensation point in the absence of dark respiration (Gamma*).
pub fn co2_compensation_point(gamma_star_25: f64, ea: f64, temperature_c: f64) -> f64 {
    arrhenius(gamma_star_25, ea, temperature_c)
}

/// Michaelis-Menten constant for CO2 carboxylation (Kc).
pub fn michaelis_menten_co2(kc_25: f64, ea: f64, temperature_c: f64) -> f64 {
    arrhenius(kc_25, ea, temperature_c)
}

/// Michaelis-Menten constant for O2 oxygenation (Ko).
pub fn michaelis_menten_o2(ko_25: f64, ea: f64, temperature_c: f64) -> f64 {
    arrhenius(ko_25, ea, temperature_c)
}

// ---------------------------------------------------------------------------
// Electron transport
// ---------------------------------------------------------------------------

/// Actual electron transport rate J, solved from the quadratic:
///
/// ```text
/// theta * J^2 - (alpha*Q + Jmax)*J + alpha*Q*Jmax = 0
/// ```
///
/// where Q = absorbed PAR (umol/m^2/s). Returns the smaller (physiologically
/// meaningful) root, clamped to >= 0.
pub fn electron_transport_rate(
    par_absorbed: f64,
    jmax: f64,
    alpha: f64,
    theta: f64,
) -> f64 {
    let a = theta;
    let b = -(alpha * par_absorbed + jmax);
    let c = alpha * par_absorbed * jmax;

    let discriminant = b * b - 4.0 * a * c;
    if discriminant < 0.0 {
        return jmax; // Fallback to Jmax
    }

    // Smaller root is the physiologically meaningful one
    let j = (-b - discriminant.sqrt()) / (2.0 * a);
    j.max(0.0)
}

// ---------------------------------------------------------------------------
// Stomatal conductance
// ---------------------------------------------------------------------------

/// Ball-Berry stomatal conductance model:
///
/// ```text
/// gs = g0 + g1 * (An * hs / cs)
/// ```
///
/// where `an` = net assimilation (umol/m^2/s), `cs` = leaf surface CO2
/// (umol/mol), `hs` = relative humidity at leaf surface (fraction 0-1).
/// `g0` is the minimum conductance (mol/m^2/s) and `g1` is the slope
/// (dimensionless). Returns gs in mol H2O/m^2/s.
pub fn stomatal_conductance_ball_berry(
    an: f64,
    cs: f64,
    hs: f64,
    g0: f64,
    g1: f64,
) -> f64 {
    if an <= 0.0 || cs <= 0.0 {
        return g0;
    }
    (g0 + g1 * an * hs / cs).max(g0)
}

// ---------------------------------------------------------------------------
// Leaf-level Farquhar model
// ---------------------------------------------------------------------------

/// Compute leaf-level net CO2 assimilation using the Farquhar-von
/// Caemmerer-Berry (FvCB) model.
///
/// Iteratively solves for intercellular CO2 (`Ci`) by coupling the
/// biochemical demand function with Ball-Berry stomatal conductance.
///
/// # Arguments
/// * `params` - Farquhar model parameters (kinetic constants, activation energies)
/// * `temperature_c` - Leaf temperature (deg C)
/// * `par_umol` - Incident PAR (umol photons/m^2/s)
/// * `co2_ppm` - Atmospheric CO2 concentration (umol/mol)
/// * `humidity_frac` - Relative humidity at leaf surface (0-1)
/// * `o2_mmol` - O2 concentration (mmol/mol), typically 210
pub fn farquhar_leaf_photosynthesis(
    params: &FarquharParams,
    temperature_c: f64,
    par_umol: f64,
    co2_ppm: f64,
    humidity_frac: f64,
    o2_mmol: f64,
) -> LeafPhotosynthesisResult {
    // Temperature-adjusted parameters
    let vcmax = vcmax_temperature_response(params.vcmax_25, params.ea_vcmax, temperature_c);
    let jmax = jmax_temperature_response(
        params.jmax_25,
        params.ea_jmax,
        params.hd_jmax,
        params.ds_jmax,
        temperature_c,
    );
    let rd = arrhenius(params.rd_25, params.ea_rd, temperature_c);
    let kc = michaelis_menten_co2(params.kc_25, params.ea_kc, temperature_c);
    let ko = michaelis_menten_o2(params.ko_25, params.ea_ko, temperature_c);
    let gamma_star =
        co2_compensation_point(params.gamma_star_25, params.ea_gamma_star, temperature_c);

    // Effective Michaelis-Menten constant accounting for O2 competition
    let km = kc * (1.0 + o2_mmol / ko);

    // Iterative solution for Ci using Ball-Berry coupling.
    // Initial guess: Ci = 0.7 * Ca (typical for C3 plants)
    let mut ci = 0.7 * co2_ppm;
    let mut gs = 0.01_f64;

    for _iteration in 0..20 {
        // Rubisco-limited assimilation (Ac)
        let ac = vcmax * (ci - gamma_star) / (ci + km);

        // RuBP-regeneration (light) limited assimilation (Aj)
        let j = electron_transport_rate(par_umol * 0.85, jmax, params.alpha_j, params.theta_j);
        let aj = j * (ci - gamma_star) / (4.0 * ci + 8.0 * gamma_star);

        // Triose phosphate utilisation (TPU) limited rate.
        // TPU = Vcmax / 6 (approximate)
        let tpu = vcmax / 6.0;
        let ap = (3.0 * tpu * (ci - gamma_star)
            / (ci - (1.0 + 3.0 * 0.5) * gamma_star + 1e-6))
            .max(0.0);

        // Net assimilation = min of three limitations minus Rd
        let an_gross = ac.min(aj).min(ap);
        let an_net = an_gross - rd;

        // Stomatal conductance (Ball-Berry).
        // Simplified: leaf surface CO2 ~ ambient.
        let cs = co2_ppm;
        let gs_new =
            stomatal_conductance_ball_berry(an_net.max(0.0), cs, humidity_frac, 0.01, 9.0);

        // Update Ci from stomatal conductance.
        // An = gs * (Ca - Ci) / 1.6   (1.6 = ratio of diffusivities H2O/CO2)
        let ci_new = if gs_new > 0.001 {
            (co2_ppm - 1.6 * an_net.max(0.0) / gs_new).clamp(gamma_star, co2_ppm)
        } else {
            gamma_star
        };

        // Convergence check
        if (ci_new - ci).abs() < 0.1 {
            ci = ci_new;
            gs = gs_new;
            break;
        }

        ci = 0.5 * ci + 0.5 * ci_new; // Damped update
        gs = gs_new;
    }

    // Final calculation with converged Ci
    let ac_final = vcmax * (ci - gamma_star) / (ci + km);
    let j_final =
        electron_transport_rate(par_umol * 0.85, jmax, params.alpha_j, params.theta_j);
    let aj_final = j_final * (ci - gamma_star) / (4.0 * ci + 8.0 * gamma_star);
    let tpu_final = vcmax / 6.0;
    let denom_ap = ci - (1.0 + 1.5) * gamma_star + 1e-6;
    let ap_final = (3.0 * tpu_final * (ci - gamma_star) / denom_ap).max(0.0);

    let an_net = ac_final.min(aj_final).min(ap_final) - rd;

    LeafPhotosynthesisResult {
        an: an_net,
        ac: ac_final,
        aj: aj_final,
        ap: ap_final,
        rd,
        gs,
        ci,
    }
}

// ---------------------------------------------------------------------------
// Canopy-level photosynthesis
// ---------------------------------------------------------------------------

/// Scale leaf-level Farquhar photosynthesis to the canopy using a multi-layer
/// sunlit/shaded leaf model with Beer-Lambert light extinction.
///
/// # Arguments
/// * `leaf_params` - Farquhar model parameters for the top-of-canopy leaf
/// * `canopy_params` - Canopy structure parameters (extinction, layers, etc.)
/// * `lai` - Leaf area index (m^2/m^2)
/// * `temperature_c` - Air/leaf temperature (deg C)
/// * `solar_radiation_mj` - Daily total solar radiation (MJ/m^2/day)
/// * `co2_ppm` - Atmospheric CO2 concentration (umol/mol)
/// * `humidity_frac` - Relative humidity (fraction 0-1)
/// * `day_seconds` - Daylength in seconds (e.g. 43200 for 12 h)
pub fn canopy_photosynthesis(
    leaf_params: &FarquharParams,
    canopy_params: &CanopyParams,
    lai: f64,
    temperature_c: f64,
    solar_radiation_mj: f64,
    co2_ppm: f64,
    humidity_frac: f64,
    day_seconds: f64,
) -> CanopyPhotosynthesisResult {
    let k = canopy_params.extinction_coefficient * canopy_params.clumping_factor;
    let total_lai = lai;
    let n_layers = canopy_params.n_layers;

    // Guard: zero LAI or degenerate inputs
    if n_layers == 0 || total_lai <= 0.0 || day_seconds <= 0.0 {
        return CanopyPhotosynthesisResult {
            gross_assimilation: 0.0,
            net_assimilation: 0.0,
            total_respiration: 0.0,
            mean_stomatal_conductance: 0.0,
            daily_assimilation_g: 0.0,
        };
    }

    let dlai = total_lai / n_layers as f64;

    // Convert daily MJ/m^2 to instantaneous umol photons/m^2/s.
    // 1 MJ = 1e6 J; PAR = 0.5 * total; ~4.57 umol/J for PAR
    let par_top = solar_radiation_mj * 0.5 * 1e6 * 4.57 / day_seconds;

    let mut total_an = 0.0_f64;
    let mut total_rd = 0.0_f64;
    let mut total_gs = 0.0_f64;

    // Nitrogen extinction coefficient for Vcmax/Jmax decline with depth
    let kn = 0.3;

    for layer in 0..n_layers {
        // Cumulative LAI from top of canopy to middle of current layer
        let lai_cum = (layer as f64 + 0.5) * dlai;

        // Sunlit / shaded leaf fractions
        let f_sunlit = (-k * lai_cum).exp();
        let f_shaded = 1.0 - f_sunlit;

        // PAR at this layer
        let par_direct = par_top * (-k * lai_cum).exp();
        // Diffuse PAR (simplified: 20% of above-canopy PAR attenuated differently)
        let par_diffuse = par_top * 0.2 * (-0.5 * k * lai_cum).exp();

        // Sunlit leaf PAR = direct beam + diffuse
        let par_sunlit = par_direct + par_diffuse;
        // Shaded leaf PAR = diffuse only
        let par_shaded = par_diffuse;

        // Vcmax, Jmax, and Rd decline with depth (nitrogen gradient)
        let vcmax_layer = leaf_params.vcmax_25 * (-kn * lai_cum).exp();
        let jmax_layer = leaf_params.jmax_25 * (-kn * lai_cum).exp();
        let rd_layer = leaf_params.rd_25 * (-kn * lai_cum).exp();

        // Create layer-specific parameters, keeping kinetic constants from top leaf
        let layer_params = FarquharParams {
            vcmax_25: vcmax_layer,
            jmax_25: jmax_layer,
            rd_25: rd_layer,
            ..leaf_params.clone()
        };

        // Sunlit leaves
        let result_sun = farquhar_leaf_photosynthesis(
            &layer_params,
            temperature_c,
            par_sunlit,
            co2_ppm,
            humidity_frac,
            O2_PARTIAL,
        );

        // Shaded leaves
        let result_shade = farquhar_leaf_photosynthesis(
            &layer_params,
            temperature_c,
            par_shaded,
            co2_ppm,
            humidity_frac,
            O2_PARTIAL,
        );

        // Weight by sunlit/shaded fraction and LAI in layer
        let layer_an = (f_sunlit * result_sun.an + f_shaded * result_shade.an) * dlai;
        let layer_rd = (f_sunlit * result_sun.rd + f_shaded * result_shade.rd) * dlai;
        let layer_gs = (f_sunlit * result_sun.gs + f_shaded * result_shade.gs) * dlai;

        total_an += layer_an;
        total_rd += layer_rd;
        total_gs += layer_gs;
    }

    // Mean stomatal conductance
    let mean_gs = if total_lai > 0.0 {
        total_gs / total_lai
    } else {
        0.0
    };

    // Gross assimilation (net + respiration)
    let gross = total_an + total_rd;

    // Convert instantaneous umol CO2/m^2/s to daily g CO2/m^2.
    // umol/s * seconds * 44e-6 g/umol = g/day
    let daily_g = gross * day_seconds * 44.0e-6;

    CanopyPhotosynthesisResult {
        gross_assimilation: gross,
        net_assimilation: total_an,
        total_respiration: total_rd,
        mean_stomatal_conductance: mean_gs,
        daily_assimilation_g: daily_g,
    }
}

/// Convert daily CO2 assimilation (g CO2/m^2/day) to daily biomass
/// accumulation (g dry matter/m^2/day).
///
/// Uses the standard conversion: g CO2 * (30/44) = g CH2O (carbohydrate),
/// then applies a growth respiration efficiency factor (typically ~0.7).
pub fn co2_to_biomass(daily_co2_g: f64, growth_efficiency: f64) -> f64 {
    daily_co2_g * (30.0 / 44.0) * growth_efficiency
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_arrhenius_at_25c() {
        // At 25 deg C, arrhenius should return the parameter value at 25 deg C
        let val = arrhenius(100.0, 65330.0, 25.0);
        assert!(
            (val - 100.0).abs() < 1e-10,
            "arrhenius at 25C should return param_25, got {}",
            val
        );
    }

    #[test]
    fn test_arrhenius_increases_with_temperature() {
        let val_25 = arrhenius(100.0, 65330.0, 25.0);
        let val_35 = arrhenius(100.0, 65330.0, 35.0);
        assert!(
            val_35 > val_25,
            "arrhenius should increase: val_25={}, val_35={}",
            val_25,
            val_35
        );
    }

    #[test]
    fn test_peaked_arrhenius_at_25c() {
        let val = peaked_arrhenius(100.0, 43540.0, 200000.0, 650.0, 25.0);
        assert!(
            (val - 100.0).abs() < 1e-10,
            "peaked_arrhenius at 25C should return param_25, got {}",
            val
        );
    }

    #[test]
    fn test_peaked_arrhenius_declines_at_high_temp() {
        let val_35 = peaked_arrhenius(100.0, 43540.0, 200000.0, 650.0, 35.0);
        let val_50 = peaked_arrhenius(100.0, 43540.0, 200000.0, 650.0, 50.0);
        assert!(
            val_50 < val_35,
            "peaked_arrhenius should decline at high temp: val_35={}, val_50={}",
            val_35,
            val_50
        );
    }

    #[test]
    fn test_electron_transport_rate_bounded() {
        let j = electron_transport_rate(1000.0, 140.0, 0.3, 0.7);
        assert!(j > 0.0, "J should be positive, got {}", j);
        assert!(j <= 140.0, "J should not exceed Jmax, got {}", j);
    }

    #[test]
    fn test_electron_transport_dark() {
        let j = electron_transport_rate(0.0, 140.0, 0.3, 0.7);
        assert!(
            j.abs() < 1e-10,
            "J should be zero in the dark, got {}",
            j
        );
    }

    #[test]
    fn test_stomatal_conductance_positive_an() {
        let gs = stomatal_conductance_ball_berry(10.0, 400.0, 0.7, 0.01, 9.0);
        assert!(
            gs > 0.01,
            "gs should exceed g0 with positive An, got {}",
            gs
        );
    }

    #[test]
    fn test_stomatal_conductance_negative_an() {
        let gs = stomatal_conductance_ball_berry(-5.0, 400.0, 0.7, 0.01, 9.0);
        assert!(
            (gs - 0.01).abs() < 1e-10,
            "gs should equal g0 with negative An, got {}",
            gs
        );
    }

    #[test]
    fn test_farquhar_leaf_typical_conditions() {
        let params = FarquharParams::default();
        let result =
            farquhar_leaf_photosynthesis(&params, 25.0, 1000.0, 400.0, 0.7, O2_PARTIAL);
        assert!(result.an > 0.0, "An = {} should be positive", result.an);
        assert!(result.ac > 0.0, "Ac = {} should be positive", result.ac);
        assert!(result.aj > 0.0, "Aj = {} should be positive", result.aj);
        assert!(result.gs > 0.0, "gs = {} should be positive", result.gs);
        assert!(result.ci > 0.0, "Ci = {} should be positive", result.ci);
        assert!(
            result.ci < 400.0,
            "Ci = {} should be less than ambient CO2",
            result.ci
        );
    }

    #[test]
    fn test_farquhar_leaf_dark() {
        let params = FarquharParams::default();
        let result =
            farquhar_leaf_photosynthesis(&params, 25.0, 0.0, 400.0, 0.7, O2_PARTIAL);
        assert!(
            result.an < 0.0,
            "An = {} should be negative in dark (respiration only)",
            result.an
        );
    }

    #[test]
    fn test_farquhar_leaf_high_co2_increases_an() {
        let params = FarquharParams::default();
        let result_400 =
            farquhar_leaf_photosynthesis(&params, 25.0, 1000.0, 400.0, 0.7, O2_PARTIAL);
        let result_800 =
            farquhar_leaf_photosynthesis(&params, 25.0, 1000.0, 800.0, 0.7, O2_PARTIAL);
        assert!(
            result_800.an > result_400.an,
            "Higher CO2 should increase An: An_400={}, An_800={}",
            result_400.an,
            result_800.an
        );
    }

    #[test]
    fn test_canopy_photosynthesis_typical() {
        let leaf_params = FarquharParams::default();
        let canopy_params = CanopyParams::default();
        let result = canopy_photosynthesis(
            &leaf_params,
            &canopy_params,
            4.0,
            25.0,
            20.0,
            400.0,
            0.7,
            43200.0,
        );
        assert!(
            result.gross_assimilation > 0.0,
            "Gross assimilation should be positive"
        );
        assert!(
            result.daily_assimilation_g > 0.0,
            "Daily assimilation (g) should be positive"
        );
        assert!(
            result.mean_stomatal_conductance > 0.0,
            "Mean gs should be positive"
        );
    }

    #[test]
    fn test_canopy_photosynthesis_zero_lai() {
        let leaf_params = FarquharParams::default();
        let canopy_params = CanopyParams::default();
        let result = canopy_photosynthesis(
            &leaf_params,
            &canopy_params,
            0.0,
            25.0,
            20.0,
            400.0,
            0.7,
            43200.0,
        );
        assert!(
            result.gross_assimilation.abs() < 1e-10,
            "Zero LAI should yield zero assimilation"
        );
        assert!(
            result.daily_assimilation_g.abs() < 1e-10,
            "Zero LAI should yield zero daily g"
        );
    }

    #[test]
    fn test_canopy_photosynthesis_more_lai_more_assimilation() {
        let leaf_params = FarquharParams::default();
        let canopy_params = CanopyParams::default();
        let result_2 = canopy_photosynthesis(
            &leaf_params,
            &canopy_params,
            2.0,
            25.0,
            20.0,
            400.0,
            0.7,
            43200.0,
        );
        let result_6 = canopy_photosynthesis(
            &leaf_params,
            &canopy_params,
            6.0,
            25.0,
            20.0,
            400.0,
            0.7,
            43200.0,
        );
        assert!(
            result_6.gross_assimilation > result_2.gross_assimilation,
            "Higher LAI should increase canopy assimilation"
        );
    }

    #[test]
    fn test_co2_to_biomass() {
        let biomass = co2_to_biomass(44.0, 0.7);
        // 44 g CO2 * (30/44) * 0.7 = 21.0 g DM
        assert!(
            (biomass - 21.0).abs() < 1e-10,
            "Expected 21.0, got {}",
            biomass
        );
    }
}
