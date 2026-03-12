module ClimateResponse

using Statistics
using LinearAlgebra
using Dates

export ClimateScenario, CropClimateResponse, ClimateProjection,
       TemperatureResponse, PrecipitationResponse, CO2Response,
       compute_temperature_response, compute_precipitation_response,
       compute_co2_fertilization, project_yield_under_climate,
       heat_stress_index, drought_stress_index,
       growing_degree_days, frost_risk_probability,
       climate_suitability_score

# ---------------------------------------------------------------------------
# Data structures
# ---------------------------------------------------------------------------

"""
    ClimateScenario

Represents a climate change scenario with projected changes in temperature,
precipitation, and CO2 concentration relative to a baseline period.
"""
struct ClimateScenario
    name::String
    baseline_year::Int
    projection_year::Int
    delta_temp_mean::Float64      # °C change in mean temperature
    delta_temp_max::Float64       # °C change in max temperature
    delta_temp_min::Float64       # °C change in min temperature
    delta_precip_pct::Float64     # % change in precipitation
    co2_ppm::Float64              # projected CO2 concentration (ppm)
    baseline_co2_ppm::Float64     # baseline CO2 concentration (ppm)
end

"""
    TemperatureResponse

Crop-specific temperature response parameters defining cardinal temperatures.
"""
struct TemperatureResponse
    t_base::Float64    # base temperature (°C) - no growth below this
    t_opt_low::Float64 # lower optimum temperature (°C)
    t_opt_high::Float64 # upper optimum temperature (°C)
    t_max::Float64     # maximum temperature (°C) - lethal above this
    heat_stress_threshold::Float64  # °C above which heat stress accumulates
    frost_kill_threshold::Float64   # °C below which frost damage occurs
end

"""
    PrecipitationResponse

Crop water requirement parameters for precipitation response modeling.
"""
struct PrecipitationResponse
    optimal_precip_mm::Float64     # optimal growing season precipitation (mm)
    min_precip_mm::Float64         # minimum viable precipitation (mm)
    waterlogging_threshold_mm::Float64  # daily precipitation causing waterlogging
    drought_sensitivity::Float64   # 0-1 scale, higher = more sensitive
end

"""
    CO2Response

Parameters for CO2 fertilization effect on crop growth.
"""
struct CO2Response
    is_c3::Bool                    # true for C3 crops (wheat, rice), false for C4 (corn, sorghum)
    max_stimulation_pct::Float64   # maximum yield increase at saturating CO2 (%)
    half_saturation_ppm::Float64   # CO2 level for half-maximum response
    stomatal_closure_factor::Float64 # reduction in water use per unit CO2 increase
end

"""
    CropClimateResponse

Complete climate response profile for a specific crop.
"""
struct CropClimateResponse
    crop_name::String
    temp_response::TemperatureResponse
    precip_response::PrecipitationResponse
    co2_response::CO2Response
    growing_season_days::Int
    vernalization_required::Bool
    vernalization_days::Int
    photoperiod_sensitive::Bool
end

"""
    ClimateProjection

Results of a climate impact projection on crop yield.
"""
mutable struct ClimateProjection
    scenario::ClimateScenario
    crop::String
    baseline_yield_factor::Float64
    projected_yield_factor::Float64
    temperature_impact::Float64
    precipitation_impact::Float64
    co2_impact::Float64
    heat_stress_days::Float64
    frost_risk_change::Float64
    growing_season_change_days::Float64
    suitability_score::Float64
end

# ---------------------------------------------------------------------------
# Temperature response functions
# ---------------------------------------------------------------------------

"""
    compute_temperature_response(temp::Float64, params::TemperatureResponse) -> Float64

Compute the relative growth rate (0-1) based on temperature using a
beta-function response curve. Returns 0 below base or above max temperature,
and 1.0 at the optimum range.
"""
function compute_temperature_response(temp::Float64, params::TemperatureResponse)::Float64
    if temp <= params.t_base || temp >= params.t_max
        return 0.0
    end

    if params.t_opt_low <= temp <= params.t_opt_high
        return 1.0
    end

    if temp < params.t_opt_low
        # Rising limb: linear interpolation from base to optimum
        return (temp - params.t_base) / (params.t_opt_low - params.t_base)
    else
        # Falling limb: linear interpolation from optimum to max
        return (params.t_max - temp) / (params.t_max - params.t_opt_high)
    end
end

"""
    heat_stress_index(daily_max_temps::Vector{Float64}, threshold::Float64) -> Float64

Calculate cumulative heat stress index as the sum of degree-hours above
the heat stress threshold over the growing season.
"""
function heat_stress_index(daily_max_temps::Vector{Float64}, threshold::Float64)::Float64
    stress = 0.0
    for tmax in daily_max_temps
        if tmax > threshold
            stress += (tmax - threshold)
        end
    end
    return stress
end

"""
    frost_risk_probability(daily_min_temps::Vector{Float64}, threshold::Float64) -> Float64

Calculate the probability of frost events (fraction of days with
minimum temperature below the frost threshold).
"""
function frost_risk_probability(daily_min_temps::Vector{Float64}, threshold::Float64)::Float64
    if isempty(daily_min_temps)
        return 0.0
    end
    frost_days = count(t -> t < threshold, daily_min_temps)
    return frost_days / length(daily_min_temps)
end

"""
    growing_degree_days(daily_temps::Vector{Float64}, t_base::Float64) -> Float64

Calculate accumulated growing degree days (GDD) using the standard method.
GDD = Σ max(0, T_mean - T_base)
"""
function growing_degree_days(daily_temps::Vector{Float64}, t_base::Float64)::Float64
    gdd = 0.0
    for t in daily_temps
        gdd += max(0.0, t - t_base)
    end
    return gdd
end

# ---------------------------------------------------------------------------
# Precipitation response functions
# ---------------------------------------------------------------------------

"""
    compute_precipitation_response(total_precip_mm::Float64, params::PrecipitationResponse) -> Float64

Compute the relative yield factor (0-1) based on total growing season
precipitation. Uses a piecewise linear response with deficit and excess zones.
"""
function compute_precipitation_response(total_precip_mm::Float64, params::PrecipitationResponse)::Float64
    if total_precip_mm <= 0.0
        return 0.0
    end

    if total_precip_mm < params.min_precip_mm
        # Severe deficit - linear decline to zero
        return (total_precip_mm / params.min_precip_mm) * (1.0 - params.drought_sensitivity)
    elseif total_precip_mm <= params.optimal_precip_mm
        # Below optimum - linear increase
        deficit_ratio = (total_precip_mm - params.min_precip_mm) /
                        (params.optimal_precip_mm - params.min_precip_mm)
        return (1.0 - params.drought_sensitivity) + params.drought_sensitivity * deficit_ratio
    elseif total_precip_mm <= params.optimal_precip_mm * 1.5
        # Slightly above optimum - still good
        return 1.0
    else
        # Excess precipitation - waterlogging stress
        excess_ratio = (total_precip_mm - params.optimal_precip_mm * 1.5) /
                       (params.optimal_precip_mm * 1.5)
        return max(0.3, 1.0 - 0.5 * excess_ratio)
    end
end

"""
    drought_stress_index(daily_precip_mm::Vector{Float64}, et_mm::Vector{Float64}) -> Float64

Calculate cumulative drought stress as the ratio of water deficit days
to total growing days. ET = evapotranspiration demand.
"""
function drought_stress_index(daily_precip_mm::Vector{Float64}, et_mm::Vector{Float64})::Float64
    n = min(length(daily_precip_mm), length(et_mm))
    if n == 0
        return 0.0
    end

    soil_water = 50.0  # initial available soil water (mm)
    max_soil_water = 150.0
    deficit_days = 0

    for i in 1:n
        soil_water = min(max_soil_water, soil_water + daily_precip_mm[i])
        soil_water -= et_mm[i]
        if soil_water < 0.0
            deficit_days += 1
            soil_water = 0.0
        end
    end

    return deficit_days / n
end

# ---------------------------------------------------------------------------
# CO2 fertilization
# ---------------------------------------------------------------------------

"""
    compute_co2_fertilization(co2_ppm::Float64, baseline_co2::Float64, params::CO2Response) -> Float64

Compute the CO2 fertilization effect on yield using a Michaelis-Menten
saturation curve. C3 crops show stronger response than C4 crops.
Returns a multiplicative factor (e.g., 1.15 = 15% yield increase).
"""
function compute_co2_fertilization(co2_ppm::Float64, baseline_co2::Float64, params::CO2Response)::Float64
    if co2_ppm <= baseline_co2
        return 1.0
    end

    delta_co2 = co2_ppm - baseline_co2
    max_effect = params.max_stimulation_pct / 100.0

    # Michaelis-Menten response
    response = max_effect * delta_co2 / (params.half_saturation_ppm + delta_co2)

    return 1.0 + response
end

# ---------------------------------------------------------------------------
# Integrated climate projection
# ---------------------------------------------------------------------------

"""
    project_yield_under_climate(crop::CropClimateResponse,
                                scenario::ClimateScenario,
                                baseline_temps::Vector{Float64},
                                baseline_precip::Vector{Float64}) -> ClimateProjection

Project crop yield changes under a climate scenario by combining
temperature, precipitation, and CO2 effects multiplicatively.

The baseline temperatures and precipitation are daily values for the
growing season under current conditions.
"""
function project_yield_under_climate(
    crop::CropClimateResponse,
    scenario::ClimateScenario,
    baseline_temps::Vector{Float64},
    baseline_precip::Vector{Float64}
)::ClimateProjection

    # Baseline yield factors
    baseline_mean_temp = mean(baseline_temps)
    baseline_total_precip = sum(baseline_precip)

    base_temp_factor = compute_temperature_response(baseline_mean_temp, crop.temp_response)
    base_precip_factor = compute_precipitation_response(baseline_total_precip, crop.precip_response)

    baseline_yield = base_temp_factor * base_precip_factor

    # Projected conditions
    projected_temps = baseline_temps .+ scenario.delta_temp_mean
    projected_mean_temp = mean(projected_temps)
    projected_total_precip = baseline_total_precip * (1.0 + scenario.delta_precip_pct / 100.0)

    # Individual impact factors
    proj_temp_factor = compute_temperature_response(projected_mean_temp, crop.temp_response)
    proj_precip_factor = compute_precipitation_response(projected_total_precip, crop.precip_response)
    co2_factor = compute_co2_fertilization(scenario.co2_ppm, scenario.baseline_co2_ppm, crop.co2_response)

    # Heat stress change
    baseline_heat = heat_stress_index(baseline_temps, crop.temp_response.heat_stress_threshold)
    projected_heat = heat_stress_index(projected_temps, crop.temp_response.heat_stress_threshold)
    heat_stress_penalty = 1.0
    if projected_heat > 0
        heat_stress_penalty = max(0.5, 1.0 - (projected_heat - baseline_heat) / 500.0)
    end

    # Frost risk change
    baseline_frost = frost_risk_probability(baseline_temps, crop.temp_response.frost_kill_threshold)
    projected_frost = frost_risk_probability(projected_temps, crop.temp_response.frost_kill_threshold)

    # Growing season length change (approximation: +2.5 days per °C warming)
    season_change = scenario.delta_temp_mean * 2.5

    # Combined projected yield
    projected_yield = proj_temp_factor * proj_precip_factor * co2_factor * heat_stress_penalty

    # Suitability score
    suitability = climate_suitability_score(projected_mean_temp, projected_total_precip, crop)

    return ClimateProjection(
        scenario,
        crop.crop_name,
        baseline_yield,
        projected_yield,
        proj_temp_factor / max(base_temp_factor, 0.01),  # relative temperature impact
        proj_precip_factor / max(base_precip_factor, 0.01),  # relative precip impact
        co2_factor,
        projected_heat,
        projected_frost - baseline_frost,
        season_change,
        suitability
    )
end

"""
    climate_suitability_score(mean_temp::Float64, total_precip::Float64,
                              crop::CropClimateResponse) -> Float64

Compute a 0-100 suitability score for growing a crop under given
temperature and precipitation conditions.
"""
function climate_suitability_score(
    mean_temp::Float64,
    total_precip::Float64,
    crop::CropClimateResponse
)::Float64

    temp_score = compute_temperature_response(mean_temp, crop.temp_response)
    precip_score = compute_precipitation_response(total_precip, crop.precip_response)

    # Geometric mean gives balanced weighting
    combined = sqrt(temp_score * precip_score)

    return clamp(combined * 100.0, 0.0, 100.0)
end

end # module ClimateResponse
