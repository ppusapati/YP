module IrrigationSimulation

using DifferentialEquations
using Statistics
using LinearAlgebra
using Dates

export IrrigationParams, SoilHydraulicParams, CropWaterParams,
       IrrigationSchedule, IrrigationEvent, SimulationResult,
       simulate_irrigation, compute_et0_penman_monteith,
       compute_crop_et, soil_water_balance,
       optimal_irrigation_schedule, deficit_irrigation_strategy,
       water_use_efficiency, irrigation_uniformity

# ---------------------------------------------------------------------------
# Data structures
# ---------------------------------------------------------------------------

"""
    SoilHydraulicParams

Soil hydraulic properties following van Genuchten-Mualem model parameters.
"""
struct SoilHydraulicParams
    theta_sat::Float64      # saturated water content (m³/m³)
    theta_fc::Float64       # field capacity (m³/m³)
    theta_wp::Float64       # wilting point (m³/m³)
    theta_r::Float64        # residual water content (m³/m³)
    k_sat::Float64          # saturated hydraulic conductivity (mm/day)
    alpha::Float64          # van Genuchten α parameter (1/cm)
    n_vg::Float64           # van Genuchten n parameter
    root_depth_m::Float64   # effective root zone depth (m)
end

"""
    CropWaterParams

Crop-specific water requirement parameters following FAO-56 guidelines.
"""
struct CropWaterParams
    kc_ini::Float64         # crop coefficient - initial stage
    kc_mid::Float64         # crop coefficient - mid season
    kc_end::Float64         # crop coefficient - late season
    p_depletion::Float64    # allowable depletion fraction (0-1)
    stress_threshold::Float64  # soil moisture below which stress occurs (fraction of TAW)
    season_length_days::Int # total growing season length
    ini_days::Int           # initial stage duration
    dev_days::Int           # development stage duration
    mid_days::Int           # mid-season stage duration
    late_days::Int          # late-season stage duration
end

"""
    IrrigationParams

Parameters controlling irrigation system and strategy.
"""
struct IrrigationParams
    method::Symbol          # :drip, :sprinkler, :furrow, :pivot
    efficiency::Float64     # application efficiency (0-1)
    max_application_mm::Float64  # maximum single application (mm)
    min_interval_days::Int  # minimum days between irrigations
    cost_per_mm_ha::Float64 # cost per mm of water per hectare
end

"""
    IrrigationEvent

Record of a single irrigation application.
"""
mutable struct IrrigationEvent
    day::Int
    amount_mm::Float64
    effective_mm::Float64
    soil_moisture_before::Float64
    soil_moisture_after::Float64
end

"""
    IrrigationSchedule

Complete irrigation schedule for a growing season.
"""
mutable struct IrrigationSchedule
    events::Vector{IrrigationEvent}
    total_applied_mm::Float64
    total_effective_mm::Float64
    total_cost::Float64
    num_applications::Int
end

"""
    SimulationResult

Complete results from an irrigation simulation run.
"""
mutable struct SimulationResult
    daily_theta::Vector{Float64}       # daily soil water content
    daily_et::Vector{Float64}          # daily crop ET
    daily_drainage::Vector{Float64}    # daily deep percolation
    daily_stress::Vector{Float64}      # daily water stress factor (0=full stress, 1=no stress)
    schedule::IrrigationSchedule
    total_et_mm::Float64
    total_drainage_mm::Float64
    total_rainfall_mm::Float64
    water_use_eff::Float64             # kg yield per m³ water
    relative_yield::Float64            # 0-1 yield factor
end

# ---------------------------------------------------------------------------
# Reference evapotranspiration (ET0)
# ---------------------------------------------------------------------------

"""
    compute_et0_penman_monteith(t_max::Float64, t_min::Float64, rh_mean::Float64,
                                 wind_speed_ms::Float64, solar_rad_mj::Float64,
                                 elevation_m::Float64, lat_rad::Float64,
                                 day_of_year::Int) -> Float64

Compute reference evapotranspiration using the FAO-56 Penman-Monteith equation.
Returns ET0 in mm/day.
"""
function compute_et0_penman_monteith(
    t_max::Float64, t_min::Float64, rh_mean::Float64,
    wind_speed_ms::Float64, solar_rad_mj::Float64,
    elevation_m::Float64, lat_rad::Float64,
    day_of_year::Int
)::Float64

    t_mean = (t_max + t_min) / 2.0

    # Atmospheric pressure (kPa)
    P = 101.3 * ((293.0 - 0.0065 * elevation_m) / 293.0)^5.26

    # Psychrometric constant (kPa/°C)
    γ = 0.000665 * P

    # Slope of saturation vapor pressure curve (kPa/°C)
    Δ = 4098.0 * (0.6108 * exp(17.27 * t_mean / (t_mean + 237.3))) /
        (t_mean + 237.3)^2

    # Saturation vapor pressure (kPa)
    e_s = (0.6108 * exp(17.27 * t_max / (t_max + 237.3)) +
           0.6108 * exp(17.27 * t_min / (t_min + 237.3))) / 2.0

    # Actual vapor pressure (kPa)
    e_a = e_s * rh_mean / 100.0

    # Net radiation estimate (MJ/m²/day)
    # Simplified: using incoming solar radiation with albedo
    albedo = 0.23
    rns = (1.0 - albedo) * solar_rad_mj

    # Net longwave radiation (simplified Stefan-Boltzmann)
    σ = 4.903e-9  # Stefan-Boltzmann (MJ/m²/day/K⁴)
    t_max_k = t_max + 273.16
    t_min_k = t_min + 273.16
    rnl = σ * ((t_max_k^4 + t_min_k^4) / 2.0) *
          (0.34 - 0.14 * sqrt(e_a)) *
          (1.35 * solar_rad_mj / max(solar_rad_mj * 1.2, 0.1) - 0.35)

    rn = rns - max(rnl, 0.0)

    # Soil heat flux (negligible for daily calculations)
    G = 0.0

    # FAO-56 Penman-Monteith
    numerator = 0.408 * Δ * (rn - G) + γ * (900.0 / (t_mean + 273.0)) * wind_speed_ms * (e_s - e_a)
    denominator = Δ + γ * (1.0 + 0.34 * wind_speed_ms)

    et0 = numerator / denominator
    return max(0.0, et0)
end

"""
    compute_crop_et(et0::Float64, kc::Float64, ks::Float64) -> Float64

Compute actual crop evapotranspiration.
ETc_adj = ET0 × Kc × Ks
where Ks is the water stress coefficient (0-1).
"""
function compute_crop_et(et0::Float64, kc::Float64, ks::Float64)::Float64
    return et0 * kc * ks
end

"""
    get_kc(day::Int, params::CropWaterParams) -> Float64

Get the crop coefficient for a given day of the growing season
using linear interpolation between growth stages.
"""
function get_kc(day::Int, params::CropWaterParams)::Float64
    if day <= 0
        return params.kc_ini
    end

    ini_end = params.ini_days
    dev_end = ini_end + params.dev_days
    mid_end = dev_end + params.mid_days

    if day <= ini_end
        return params.kc_ini
    elseif day <= dev_end
        # Linear interpolation from kc_ini to kc_mid
        frac = (day - ini_end) / params.dev_days
        return params.kc_ini + frac * (params.kc_mid - params.kc_ini)
    elseif day <= mid_end
        return params.kc_mid
    else
        # Linear interpolation from kc_mid to kc_end
        frac = min(1.0, (day - mid_end) / max(1, params.late_days))
        return params.kc_mid + frac * (params.kc_end - params.kc_mid)
    end
end

# ---------------------------------------------------------------------------
# Soil water balance
# ---------------------------------------------------------------------------

"""
    soil_water_balance(theta::Float64, precip_mm::Float64, irrigation_mm::Float64,
                       et_mm::Float64, soil::SoilHydraulicParams) -> Tuple{Float64, Float64}

Compute daily soil water balance. Returns (new_theta, drainage_mm).
"""
function soil_water_balance(
    theta::Float64, precip_mm::Float64, irrigation_mm::Float64,
    et_mm::Float64, soil::SoilHydraulicParams
)::Tuple{Float64, Float64}

    root_depth_mm = soil.root_depth_m * 1000.0

    # Add water inputs
    theta_new = theta + (precip_mm + irrigation_mm) / root_depth_mm

    # Remove ET
    theta_new -= et_mm / root_depth_mm

    # Compute drainage (water above field capacity drains)
    drainage_mm = 0.0
    if theta_new > soil.theta_fc
        excess = theta_new - soil.theta_fc
        # Drainage rate depends on how much above FC
        drain_frac = min(1.0, excess / (soil.theta_sat - soil.theta_fc))
        drainage_mm = excess * root_depth_mm * drain_frac
        theta_new -= drainage_mm / root_depth_mm
    end

    # Cannot go below residual water content
    theta_new = max(soil.theta_r, theta_new)

    # Cannot exceed saturation
    if theta_new > soil.theta_sat
        drainage_mm += (theta_new - soil.theta_sat) * root_depth_mm
        theta_new = soil.theta_sat
    end

    return (theta_new, drainage_mm)
end

"""
    water_stress_factor(theta::Float64, soil::SoilHydraulicParams,
                        crop::CropWaterParams) -> Float64

Compute water stress coefficient Ks (0-1) based on soil moisture.
Returns 1.0 when soil moisture is above the stress threshold,
decreasing linearly to 0.0 at wilting point.
"""
function water_stress_factor(theta::Float64, soil::SoilHydraulicParams,
                             crop::CropWaterParams)::Float64
    taw = (soil.theta_fc - soil.theta_wp) * soil.root_depth_m * 1000.0  # mm
    raw = taw * crop.p_depletion  # readily available water (mm)
    current_depletion = (soil.theta_fc - theta) * soil.root_depth_m * 1000.0

    if current_depletion <= raw
        return 1.0  # no stress
    elseif theta <= soil.theta_wp
        return 0.0  # full stress
    else
        return max(0.0, (theta - soil.theta_wp) / (soil.theta_fc - soil.theta_wp - raw / (soil.root_depth_m * 1000.0)))
    end
end

# ---------------------------------------------------------------------------
# Irrigation simulation
# ---------------------------------------------------------------------------

"""
    simulate_irrigation(et0_daily::Vector{Float64}, precip_daily::Vector{Float64},
                        soil::SoilHydraulicParams, crop::CropWaterParams,
                        irrig::IrrigationParams;
                        initial_theta::Float64=0.0) -> SimulationResult

Run a complete irrigation simulation for a growing season.
Automatically triggers irrigation when soil moisture drops below
the management allowable depletion level.
"""
function simulate_irrigation(
    et0_daily::Vector{Float64},
    precip_daily::Vector{Float64},
    soil::SoilHydraulicParams,
    crop::CropWaterParams,
    irrig::IrrigationParams;
    initial_theta::Float64=0.0
)::SimulationResult

    n_days = min(length(et0_daily), length(precip_daily), crop.season_length_days)

    # Initialize at field capacity if not specified
    theta = initial_theta > 0.0 ? initial_theta : soil.theta_fc

    daily_theta = zeros(n_days)
    daily_et = zeros(n_days)
    daily_drainage = zeros(n_days)
    daily_stress = zeros(n_days)
    events = IrrigationEvent[]

    last_irrigation_day = -irrig.min_interval_days  # allow irrigation on day 1
    total_applied = 0.0
    total_effective = 0.0
    cumulative_stress = 0.0

    for day in 1:n_days
        kc = get_kc(day, crop)
        ks = water_stress_factor(theta, soil, crop)

        # Crop ET
        et = compute_crop_et(et0_daily[day], kc, ks)

        # Check if irrigation is needed
        irrigation_mm = 0.0
        taw = (soil.theta_fc - soil.theta_wp) * soil.root_depth_m * 1000.0
        current_depletion = (soil.theta_fc - theta) * soil.root_depth_m * 1000.0
        raw = taw * crop.p_depletion

        if current_depletion >= raw && (day - last_irrigation_day) >= irrig.min_interval_days
            # Refill to field capacity
            deficit = current_depletion
            irrigation_mm = min(deficit / irrig.efficiency, irrig.max_application_mm)
            effective_mm = irrigation_mm * irrig.efficiency

            theta_before = theta
            theta, drainage = soil_water_balance(theta, precip_daily[day], effective_mm, et, soil)

            push!(events, IrrigationEvent(day, irrigation_mm, effective_mm, theta_before, theta))
            total_applied += irrigation_mm
            total_effective += effective_mm
            last_irrigation_day = day
        else
            theta, drainage = soil_water_balance(theta, precip_daily[day], 0.0, et, soil)
        end

        daily_theta[day] = theta
        daily_et[day] = et
        daily_drainage[day] = day == 1 ? 0.0 : daily_drainage[day]  # already computed
        daily_stress[day] = ks
        cumulative_stress += (1.0 - ks)
    end

    # Relative yield (Jensen model: product of daily stress factors)
    relative_yield = 1.0 - (cumulative_stress / n_days) * 0.5

    schedule = IrrigationSchedule(
        events,
        total_applied,
        total_effective,
        total_applied * irrig.cost_per_mm_ha,
        length(events)
    )

    return SimulationResult(
        daily_theta, daily_et, daily_drainage, daily_stress,
        schedule,
        sum(daily_et),
        sum(daily_drainage),
        sum(precip_daily[1:n_days]),
        0.0,  # WUE computed separately with actual yield
        relative_yield
    )
end

# ---------------------------------------------------------------------------
# Scheduling strategies
# ---------------------------------------------------------------------------

"""
    optimal_irrigation_schedule(et0_daily::Vector{Float64}, precip_daily::Vector{Float64},
                                soil::SoilHydraulicParams, crop::CropWaterParams,
                                irrig::IrrigationParams) -> IrrigationSchedule

Generate an optimal irrigation schedule that minimizes water use while
maintaining soil moisture above the stress threshold at all times.
"""
function optimal_irrigation_schedule(
    et0_daily::Vector{Float64},
    precip_daily::Vector{Float64},
    soil::SoilHydraulicParams,
    crop::CropWaterParams,
    irrig::IrrigationParams
)::IrrigationSchedule

    result = simulate_irrigation(et0_daily, precip_daily, soil, crop, irrig)
    return result.schedule
end

"""
    deficit_irrigation_strategy(et0_daily::Vector{Float64}, precip_daily::Vector{Float64},
                                 soil::SoilHydraulicParams, crop::CropWaterParams,
                                 irrig::IrrigationParams, deficit_fraction::Float64) -> SimulationResult

Apply regulated deficit irrigation where only a fraction of the full
water requirement is applied. Useful for water-scarce regions.
deficit_fraction: 0.0-1.0 (e.g., 0.7 = apply 70% of full requirement)
"""
function deficit_irrigation_strategy(
    et0_daily::Vector{Float64},
    precip_daily::Vector{Float64},
    soil::SoilHydraulicParams,
    crop::CropWaterParams,
    irrig::IrrigationParams,
    deficit_fraction::Float64
)::SimulationResult

    # Modify irrigation params to apply reduced amounts
    reduced_irrig = IrrigationParams(
        irrig.method,
        irrig.efficiency,
        irrig.max_application_mm * clamp(deficit_fraction, 0.1, 1.0),
        irrig.min_interval_days,
        irrig.cost_per_mm_ha
    )

    return simulate_irrigation(et0_daily, precip_daily, soil, crop, reduced_irrig)
end

# ---------------------------------------------------------------------------
# Efficiency metrics
# ---------------------------------------------------------------------------

"""
    water_use_efficiency(yield_kg_ha::Float64, total_water_mm::Float64) -> Float64

Calculate water use efficiency in kg yield per m³ of water applied.
1 mm over 1 hectare = 10 m³
"""
function water_use_efficiency(yield_kg_ha::Float64, total_water_mm::Float64)::Float64
    if total_water_mm <= 0.0
        return 0.0
    end
    total_m3 = total_water_mm * 10.0  # mm/ha to m³/ha
    return yield_kg_ha / total_m3
end

"""
    irrigation_uniformity(application_depths::Vector{Float64}) -> Float64

Calculate Christiansen's uniformity coefficient (CU) for irrigation.
CU = 1 - (Σ|xi - x̄|) / (n × x̄)
Returns a value between 0 and 1, where 1 is perfectly uniform.
"""
function irrigation_uniformity(application_depths::Vector{Float64})::Float64
    if isempty(application_depths)
        return 0.0
    end

    x_mean = mean(application_depths)
    if x_mean <= 0.0
        return 0.0
    end

    n = length(application_depths)
    abs_dev_sum = sum(abs.(application_depths .- x_mean))

    cu = 1.0 - abs_dev_sum / (n * x_mean)
    return clamp(cu, 0.0, 1.0)
end

end # module IrrigationSimulation
