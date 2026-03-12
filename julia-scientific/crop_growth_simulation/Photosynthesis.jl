module Photosynthesis

using Statistics

export FarquharParameters, CanopyParameters, LeafPhotosynthesisResult,
       CanopyPhotosynthesisResult,
       farquhar_leaf_photosynthesis, canopy_photosynthesis,
       stomatal_conductance_ball_berry, co2_compensation_point,
       michaelis_menten_co2, michaelis_menten_o2,
       electron_transport_rate, vcmax_temperature_response,
       jmax_temperature_response

# ---------------------------------------------------------------------------
# Physical constants
# ---------------------------------------------------------------------------
const R_GAS = 8.314          # Universal gas constant (J/mol/K)
const O2_PARTIAL = 210.0     # Atmospheric O2 partial pressure (mmol/mol)
const KELVIN_OFFSET = 273.15

# ---------------------------------------------------------------------------
# Parameter structures
# ---------------------------------------------------------------------------

"""
    FarquharParameters

Parameters for the Farquhar-von Caemmerer-Berry (FvCB) model of C3
photosynthesis at the leaf level.
"""
struct FarquharParameters
    vcmax_25::Float64     # Max carboxylation rate at 25degC (umol/m^2/s)
    jmax_25::Float64      # Max electron transport rate at 25degC (umol/m^2/s)
    rd_25::Float64        # Dark respiration rate at 25degC (umol/m^2/s)
    kc_25::Float64        # Michaelis constant CO2 at 25degC (umol/mol)
    ko_25::Float64        # Michaelis constant O2 at 25degC (mmol/mol)
    gamma_star_25::Float64 # CO2 compensation point at 25degC (umol/mol)
    theta_j::Float64      # Curvature of electron transport light response (-)
    alpha_j::Float64      # Quantum yield of electron transport (mol e-/mol photons)

    # Activation energies (J/mol)
    ea_vcmax::Float64
    ea_jmax::Float64
    ea_rd::Float64
    ea_kc::Float64
    ea_ko::Float64
    ea_gamma_star::Float64

    # Deactivation parameters for Jmax
    hd_jmax::Float64      # Deactivation energy (J/mol)
    ds_jmax::Float64      # Entropy term (J/mol/K)
end

function FarquharParameters(;
    vcmax_25       = 80.0,
    jmax_25        = 140.0,
    rd_25          = 1.5,
    kc_25          = 404.9,     # Bernacchi et al. 2001
    ko_25          = 278.4,     # mmol/mol
    gamma_star_25  = 42.75,     # Bernacchi et al. 2001
    theta_j        = 0.7,
    alpha_j        = 0.3,
    ea_vcmax       = 65330.0,
    ea_jmax        = 43540.0,
    ea_rd          = 46390.0,
    ea_kc          = 79430.0,
    ea_ko          = 36380.0,
    ea_gamma_star  = 37830.0,
    hd_jmax        = 200000.0,
    ds_jmax        = 650.0
)
    FarquharParameters(vcmax_25, jmax_25, rd_25, kc_25, ko_25, gamma_star_25,
                       theta_j, alpha_j, ea_vcmax, ea_jmax, ea_rd,
                       ea_kc, ea_ko, ea_gamma_star, hd_jmax, ds_jmax)
end

"""
    CanopyParameters

Parameters for scaling leaf-level photosynthesis to the canopy.
"""
struct CanopyParameters
    lai::Float64                    # Leaf area index (m^2/m^2)
    extinction_coefficient::Float64 # PAR extinction (-)
    leaf_angle_distribution::Float64 # Spherical = 1.0, planophile < 1, erectophile > 1
    clumping_factor::Float64        # Canopy clumping (0-1, 1 = uniform)
    n_layers::Int                   # Number of canopy layers for integration
    leaf_width::Float64             # Mean leaf width (m)
    canopy_height::Float64          # Canopy height (m)
end

function CanopyParameters(;
    lai                    = 4.0,
    extinction_coefficient = 0.65,
    leaf_angle_distribution = 1.0,
    clumping_factor        = 0.85,
    n_layers               = 5,
    leaf_width             = 0.05,
    canopy_height          = 1.5
)
    CanopyParameters(lai, extinction_coefficient, leaf_angle_distribution,
                     clumping_factor, n_layers, leaf_width, canopy_height)
end

"""
    LeafPhotosynthesisResult

Output from leaf-level Farquhar model.
"""
struct LeafPhotosynthesisResult
    an::Float64      # Net assimilation rate (umol CO2/m^2/s)
    ac::Float64      # Rubisco-limited rate (umol/m^2/s)
    aj::Float64      # RuBP-regeneration (light) limited rate (umol/m^2/s)
    ap::Float64      # TPU-limited rate (umol/m^2/s)
    rd::Float64      # Dark respiration (umol/m^2/s)
    gs::Float64      # Stomatal conductance (mol/m^2/s)
    ci::Float64      # Intercellular CO2 (umol/mol)
end

"""
    CanopyPhotosynthesisResult

Output from canopy-level photosynthesis integration.
"""
struct CanopyPhotosynthesisResult
    gross_assimilation::Float64  # Canopy gross photosynthesis (umol CO2/m^2 ground/s)
    net_assimilation::Float64    # Canopy net photosynthesis (umol CO2/m^2 ground/s)
    total_respiration::Float64   # Canopy dark respiration (umol CO2/m^2 ground/s)
    mean_stomatal_conductance::Float64  # Mean canopy gs (mol/m^2/s)
    daily_assimilation_g::Float64       # Daily gross assimilation (g CO2/m^2/day)
end

# ---------------------------------------------------------------------------
# Temperature response functions (Arrhenius / peaked Arrhenius)
# ---------------------------------------------------------------------------

"""
    arrhenius(parameter_25, ea, temperature_c) -> Float64

Standard Arrhenius temperature response.
"""
function arrhenius(parameter_25::Float64, ea::Float64,
                   temperature_c::Float64)::Float64
    tk = temperature_c + KELVIN_OFFSET
    tk25 = 25.0 + KELVIN_OFFSET
    return parameter_25 * exp(ea * (tk - tk25) / (R_GAS * tk * tk25))
end

"""
    peaked_arrhenius(parameter_25, ea, hd, ds, temperature_c) -> Float64

Peaked Arrhenius (modified) temperature response for parameters that
decline at high temperatures (e.g., Jmax).
"""
function peaked_arrhenius(parameter_25::Float64, ea::Float64,
                          hd::Float64, ds::Float64,
                          temperature_c::Float64)::Float64
    tk = temperature_c + KELVIN_OFFSET
    tk25 = 25.0 + KELVIN_OFFSET

    numerator = parameter_25 * exp(ea * (tk - tk25) / (R_GAS * tk * tk25))
    denom_25 = 1.0 + exp((ds * tk25 - hd) / (R_GAS * tk25))
    denom_t  = 1.0 + exp((ds * tk - hd) / (R_GAS * tk))

    return numerator * denom_25 / denom_t
end

"""
    vcmax_temperature_response(vcmax_25, ea, temperature_c) -> Float64

Vcmax temperature dependence using Arrhenius equation.
"""
function vcmax_temperature_response(vcmax_25::Float64, ea::Float64,
                                     temperature_c::Float64)::Float64
    return arrhenius(vcmax_25, ea, temperature_c)
end

"""
    jmax_temperature_response(jmax_25, ea, hd, ds, temperature_c) -> Float64

Jmax temperature dependence using peaked Arrhenius equation.
"""
function jmax_temperature_response(jmax_25::Float64, ea::Float64,
                                    hd::Float64, ds::Float64,
                                    temperature_c::Float64)::Float64
    return peaked_arrhenius(jmax_25, ea, hd, ds, temperature_c)
end

"""
    co2_compensation_point(gamma_star_25, ea, temperature_c) -> Float64

CO2 compensation point in the absence of dark respiration (Gamma*).
"""
function co2_compensation_point(gamma_star_25::Float64, ea::Float64,
                                 temperature_c::Float64)::Float64
    return arrhenius(gamma_star_25, ea, temperature_c)
end

"""
    michaelis_menten_co2(kc_25, ea, temperature_c) -> Float64

Michaelis-Menten constant for CO2 carboxylation.
"""
function michaelis_menten_co2(kc_25::Float64, ea::Float64,
                               temperature_c::Float64)::Float64
    return arrhenius(kc_25, ea, temperature_c)
end

"""
    michaelis_menten_o2(ko_25, ea, temperature_c) -> Float64

Michaelis-Menten constant for O2 oxygenation.
"""
function michaelis_menten_o2(ko_25::Float64, ea::Float64,
                              temperature_c::Float64)::Float64
    return arrhenius(ko_25, ea, temperature_c)
end

"""
    electron_transport_rate(par_absorbed, jmax, alpha, theta) -> Float64

Actual electron transport rate J, solved from the quadratic:
    theta * J^2 - (alpha*Q + Jmax)*J + alpha*Q*Jmax = 0

where Q = absorbed PAR (umol/m^2/s).
"""
function electron_transport_rate(par_absorbed::Float64, jmax::Float64,
                                  alpha::Float64, theta::Float64)::Float64
    a = theta
    b = -(alpha * par_absorbed + jmax)
    c = alpha * par_absorbed * jmax

    discriminant = b^2 - 4.0 * a * c
    if discriminant < 0.0
        return jmax  # Fallback to Jmax
    end

    # Smaller root is the physiologically meaningful one
    j = (-b - sqrt(discriminant)) / (2.0 * a)
    return max(0.0, j)
end

# ---------------------------------------------------------------------------
# Stomatal conductance
# ---------------------------------------------------------------------------

"""
    stomatal_conductance_ball_berry(an, cs, hs; g0, g1) -> Float64

Ball-Berry stomatal conductance model:
    gs = g0 + g1 * (An * hs / cs)

where An = net assimilation, cs = leaf surface CO2 (umol/mol),
hs = relative humidity at leaf surface (fraction).
Returns gs in mol H2O/m^2/s.
"""
function stomatal_conductance_ball_berry(an::Float64, cs::Float64, hs::Float64;
                                          g0::Float64 = 0.01,
                                          g1::Float64 = 9.0)::Float64
    if an <= 0.0 || cs <= 0.0
        return g0
    end
    return max(g0, g0 + g1 * an * hs / cs)
end

# ---------------------------------------------------------------------------
# Leaf-level Farquhar model
# ---------------------------------------------------------------------------

"""
    farquhar_leaf_photosynthesis(params, temperature_c, par_umol, co2_ppm, humidity_frac;
                                 o2_mmol=210.0) -> LeafPhotosynthesisResult

Compute leaf-level net CO2 assimilation using the Farquhar-von Caemmerer-Berry
(FvCB) model.

Parameters:
- `temperature_c`: Leaf temperature (degC)
- `par_umol`: Incident PAR (umol photons/m^2/s)
- `co2_ppm`: Atmospheric CO2 concentration (umol/mol)
- `humidity_frac`: Relative humidity at leaf surface (0-1)
- `o2_mmol`: O2 concentration (mmol/mol), default 210
"""
function farquhar_leaf_photosynthesis(params::FarquharParameters,
                                      temperature_c::Float64,
                                      par_umol::Float64,
                                      co2_ppm::Float64,
                                      humidity_frac::Float64;
                                      o2_mmol::Float64 = O2_PARTIAL)::LeafPhotosynthesisResult

    # Temperature-adjusted parameters
    vcmax = vcmax_temperature_response(params.vcmax_25, params.ea_vcmax, temperature_c)
    jmax  = jmax_temperature_response(params.jmax_25, params.ea_jmax,
                                       params.hd_jmax, params.ds_jmax, temperature_c)
    rd    = arrhenius(params.rd_25, params.ea_rd, temperature_c)
    kc    = michaelis_menten_co2(params.kc_25, params.ea_kc, temperature_c)
    ko    = michaelis_menten_o2(params.ko_25, params.ea_ko, temperature_c)
    gamma_star = co2_compensation_point(params.gamma_star_25,
                                         params.ea_gamma_star, temperature_c)

    # Effective Michaelis-Menten constant accounting for O2 competition
    km = kc * (1.0 + o2_mmol / ko)

    # Iterative solution for Ci using Ball-Berry coupling
    # Initial guess: Ci = 0.7 * Ca (typical for C3 plants)
    ci = 0.7 * co2_ppm
    gs = 0.01  # Initial conductance

    for iteration in 1:20
        # Rubisco-limited assimilation (Ac)
        ac = vcmax * (ci - gamma_star) / (ci + km)

        # RuBP-regeneration (light) limited assimilation (Aj)
        j = electron_transport_rate(par_umol * 0.85, jmax,
                                     params.alpha_j, params.theta_j)
        aj = j * (ci - gamma_star) / (4.0 * ci + 8.0 * gamma_star)

        # Triose phosphate utilisation (TPU) limited rate
        # TPU = Vcmax / 6 (approximate)
        tpu = vcmax / 6.0
        ap = 3.0 * tpu * (ci - gamma_star) / (ci - (1.0 + 3.0 * 0.5) * gamma_star + 1e-6)
        ap = max(0.0, ap)

        # Net assimilation = min of three limitations minus Rd
        an_gross = min(ac, aj, ap)
        an_net = an_gross - rd

        # Stomatal conductance (Ball-Berry)
        cs = co2_ppm  # Simplified: leaf surface CO2 ~ ambient
        gs_new = stomatal_conductance_ball_berry(max(0.0, an_net), cs, humidity_frac)

        # Update Ci from stomatal conductance
        # An = gs * (Ca - Ci) / 1.6   (1.6 = ratio of diffusivities H2O/CO2)
        if gs_new > 0.001
            ci_new = co2_ppm - 1.6 * max(0.0, an_net) / gs_new
            ci_new = clamp(ci_new, gamma_star, co2_ppm)
        else
            ci_new = gamma_star
        end

        # Convergence check
        if abs(ci_new - ci) < 0.1
            ci = ci_new
            gs = gs_new
            break
        end

        ci = 0.5 * ci + 0.5 * ci_new  # Damped update
        gs = gs_new
    end

    # Final calculation with converged Ci
    ac_final = vcmax * (ci - gamma_star) / (ci + km)
    j_final = electron_transport_rate(par_umol * 0.85, jmax,
                                       params.alpha_j, params.theta_j)
    aj_final = j_final * (ci - gamma_star) / (4.0 * ci + 8.0 * gamma_star)
    tpu_final = vcmax / 6.0
    denom_ap = ci - (1.0 + 1.5) * gamma_star + 1e-6
    ap_final = 3.0 * tpu_final * (ci - gamma_star) / denom_ap
    ap_final = max(0.0, ap_final)

    an_net = min(ac_final, aj_final, ap_final) - rd

    return LeafPhotosynthesisResult(an_net, ac_final, aj_final, ap_final, rd, gs, ci)
end

# ---------------------------------------------------------------------------
# Canopy-level photosynthesis
# ---------------------------------------------------------------------------

"""
    canopy_photosynthesis(leaf_params, canopy_params, temperature_c,
                          solar_radiation_mj, co2_ppm, humidity_frac;
                          day_seconds=43200.0) -> CanopyPhotosynthesisResult

Scale leaf-level Farquhar photosynthesis to the canopy using a multi-layer
sunlit/shaded leaf model.

`solar_radiation_mj` is daily total solar radiation in MJ/m^2/day.
Conversion to instantaneous PAR assumes a daylength of `day_seconds` seconds
and that PAR = 0.5 * total radiation.
"""
function canopy_photosynthesis(leaf_params::FarquharParameters,
                                canopy_params::CanopyParameters,
                                temperature_c::Float64,
                                solar_radiation_mj::Float64,
                                co2_ppm::Float64,
                                humidity_frac::Float64;
                                day_seconds::Float64 = 43200.0)::CanopyPhotosynthesisResult

    k = canopy_params.extinction_coefficient * canopy_params.clumping_factor
    total_lai = canopy_params.lai
    n_layers = canopy_params.n_layers
    dlai = total_lai / n_layers

    # Convert daily MJ/m^2 to instantaneous umol photons/m^2/s
    # 1 MJ = 1e6 J; PAR = 0.5 * total; ~4.57 umol/J for PAR
    par_top = solar_radiation_mj * 0.5 * 1e6 * 4.57 / day_seconds

    total_an = 0.0
    total_rd = 0.0
    total_gs = 0.0

    for layer in 1:n_layers
        # Cumulative LAI from top of canopy to middle of current layer
        lai_cum = (layer - 0.5) * dlai

        # Sunlit/shaded leaf fractions
        f_sunlit = exp(-k * lai_cum)
        f_shaded = 1.0 - f_sunlit

        # PAR at this layer
        par_direct = par_top * exp(-k * lai_cum)
        # Diffuse PAR (simplified: 20% of above-canopy PAR attenuated differently)
        par_diffuse = par_top * 0.2 * exp(-0.5 * k * lai_cum)

        # Sunlit leaf PAR = direct beam + diffuse
        par_sunlit = par_direct + par_diffuse
        # Shaded leaf PAR = diffuse only
        par_shaded = par_diffuse

        # Vcmax and Jmax decline with depth (nitrogen gradient)
        # Exponential decline: parameter at depth = parameter_top * exp(-kn * LAI_cum)
        kn = 0.3  # Nitrogen extinction coefficient
        vcmax_layer = leaf_params.vcmax_25 * exp(-kn * lai_cum)
        jmax_layer = leaf_params.jmax_25 * exp(-kn * lai_cum)
        rd_layer = leaf_params.rd_25 * exp(-kn * lai_cum)

        # Create layer-specific parameters
        layer_params = FarquharParameters(
            vcmax_layer, jmax_layer, rd_layer,
            leaf_params.kc_25, leaf_params.ko_25, leaf_params.gamma_star_25,
            leaf_params.theta_j, leaf_params.alpha_j,
            leaf_params.ea_vcmax, leaf_params.ea_jmax, leaf_params.ea_rd,
            leaf_params.ea_kc, leaf_params.ea_ko, leaf_params.ea_gamma_star,
            leaf_params.hd_jmax, leaf_params.ds_jmax
        )

        # Sunlit leaves
        result_sun = farquhar_leaf_photosynthesis(
            layer_params, temperature_c, par_sunlit, co2_ppm, humidity_frac
        )

        # Shaded leaves
        result_shade = farquhar_leaf_photosynthesis(
            layer_params, temperature_c, par_shaded, co2_ppm, humidity_frac
        )

        # Weight by sunlit/shaded fraction and LAI in layer
        layer_an = (f_sunlit * result_sun.an + f_shaded * result_shade.an) * dlai
        layer_rd = (f_sunlit * result_sun.rd + f_shaded * result_shade.rd) * dlai
        layer_gs = (f_sunlit * result_sun.gs + f_shaded * result_shade.gs) * dlai

        total_an += layer_an
        total_rd += layer_rd
        total_gs += layer_gs
    end

    # Mean stomatal conductance
    mean_gs = total_lai > 0.0 ? total_gs / total_lai : 0.0

    # Gross assimilation (net + respiration)
    gross = total_an + total_rd

    # Convert instantaneous umol CO2/m^2/s to daily g CO2/m^2
    # umol/s * seconds * 44e-6 g/umol = g/day
    daily_g = gross * day_seconds * 44.0e-6

    return CanopyPhotosynthesisResult(gross, total_an, total_rd, mean_gs, daily_g)
end

end # module Photosynthesis
