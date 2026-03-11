module CropGrowth

using DifferentialEquations
using LinearAlgebra
using Statistics
using Dates

export CropParameters, GrowthState, WeatherInput, SoilParameters,
       GrowthStage, GERMINATION, VEGETATIVE, REPRODUCTIVE, MATURITY,
       simulate_growth, thermal_time, light_interception, biomass_partitioning,
       phenology_update, water_stress, nitrogen_uptake

# ---------------------------------------------------------------------------
# Growth stage enumeration
# ---------------------------------------------------------------------------
@enum GrowthStage begin
    GERMINATION      = 1
    VEGETATIVE       = 2
    REPRODUCTIVE     = 3
    MATURITY         = 4
end

# ---------------------------------------------------------------------------
# Data structures
# ---------------------------------------------------------------------------

"""
    CropParameters

Crop-specific physiological parameters following WOFOST/DSSAT conventions.
"""
struct CropParameters
    base_temperature::Float64           # Minimum temperature for growth (degC)
    optimum_temperature::Float64        # Optimum temperature for growth (degC)
    max_temperature::Float64            # Maximum temperature for growth (degC)
    photoperiod_sensitivity::Float64    # Sensitivity to daylength (h^-1)
    radiation_use_efficiency::Float64   # g DM / MJ intercepted PAR
    max_leaf_area_index::Float64        # Maximum LAI (m^2/m^2)
    specific_leaf_area::Float64         # m^2 leaf / kg leaf DM
    root_depth_rate::Float64            # Root elongation rate (m / degree-day)
    harvest_index_max::Float64          # Maximum harvest index (-)
    water_stress_coefficient::Float64   # Sensitivity to water stress (-)
    nitrogen_stress_coefficient::Float64 # Sensitivity to nitrogen stress (-)

    # Phenology thresholds (thermal time, degree-days)
    tt_germination::Float64             # Thermal time to emerge
    tt_vegetative_end::Float64          # Thermal time end of vegetative stage
    tt_reproductive_end::Float64        # Thermal time end of reproductive stage
    tt_maturity::Float64                # Thermal time to maturity

    # Extinction coefficient for Beer-Lambert light interception
    extinction_coefficient::Float64
end

"""
Default maize-like crop parameters.
"""
function CropParameters(;
    base_temperature       = 8.0,
    optimum_temperature    = 30.0,
    max_temperature        = 42.0,
    photoperiod_sensitivity = 0.0,
    radiation_use_efficiency = 3.5,
    max_leaf_area_index    = 6.0,
    specific_leaf_area     = 22.0,
    root_depth_rate        = 0.0012,
    harvest_index_max      = 0.50,
    water_stress_coefficient = 0.60,
    nitrogen_stress_coefficient = 0.50,
    tt_germination         = 80.0,
    tt_vegetative_end      = 800.0,
    tt_reproductive_end    = 1400.0,
    tt_maturity            = 1800.0,
    extinction_coefficient = 0.65
)
    CropParameters(
        base_temperature, optimum_temperature, max_temperature,
        photoperiod_sensitivity, radiation_use_efficiency,
        max_leaf_area_index, specific_leaf_area, root_depth_rate,
        harvest_index_max, water_stress_coefficient, nitrogen_stress_coefficient,
        tt_germination, tt_vegetative_end, tt_reproductive_end, tt_maturity,
        extinction_coefficient
    )
end

"""
    GrowthState

Mutable state vector of the growing crop.
"""
mutable struct GrowthState
    day_of_year::Int
    thermal_time_accumulated::Float64
    leaf_area_index::Float64
    biomass_total_kg::Float64       # kg DM / ha
    biomass_root_kg::Float64
    biomass_leaf_kg::Float64
    biomass_stem_kg::Float64
    biomass_fruit_kg::Float64
    root_depth_m::Float64
    growth_stage::GrowthStage
    water_stress_factor::Float64    # 0-1, 1 = no stress
    nitrogen_stress_factor::Float64 # 0-1, 1 = no stress
end

function GrowthState(; day_of_year::Int = 1)
    GrowthState(
        day_of_year, 0.0, 0.01, 0.0, 0.0, 0.0, 0.0, 0.0,
        0.05, GERMINATION, 1.0, 1.0
    )
end

"""
    WeatherInput

Daily weather observations.
"""
struct WeatherInput
    date::Date
    temp_min::Float64           # degC
    temp_max::Float64           # degC
    solar_radiation_mj::Float64 # MJ / m^2 / day
    rainfall_mm::Float64        # mm / day
    humidity_pct::Float64       # %
    wind_speed_ms::Float64      # m / s
end

"""
    SoilParameters

Simplified soil characterisation for crop growth coupling.
"""
struct SoilParameters
    field_capacity::Float64      # volumetric water content (m^3/m^3)
    wilting_point::Float64       # volumetric water content (m^3/m^3)
    saturation::Float64          # volumetric water content (m^3/m^3)
    initial_moisture::Float64    # volumetric water content (m^3/m^3)
    soil_nitrogen_kg_ha::Float64 # available N (kg/ha)
    max_root_depth_m::Float64    # maximum depth roots can reach (m)
    organic_matter_pct::Float64  # organic matter (%)
end

function SoilParameters(;
    field_capacity      = 0.30,
    wilting_point       = 0.12,
    saturation          = 0.45,
    initial_moisture    = 0.28,
    soil_nitrogen_kg_ha = 150.0,
    max_root_depth_m    = 1.5,
    organic_matter_pct  = 2.5
)
    SoilParameters(field_capacity, wilting_point, saturation,
                   initial_moisture, soil_nitrogen_kg_ha,
                   max_root_depth_m, organic_matter_pct)
end

# ---------------------------------------------------------------------------
# Core scientific functions
# ---------------------------------------------------------------------------

"""
    thermal_time(temp_min, temp_max, base_temp) -> Float64

Growing degree-days (GDD) using the daily average method with a ceiling
at the crop's maximum temperature.

    GDD = max(0, T_avg - T_base)

where T_avg = (T_min + T_max) / 2, capped at T_max_crop.
"""
function thermal_time(temp_min::Float64, temp_max::Float64, base_temp::Float64;
                      max_temp::Float64 = 42.0)::Float64
    t_avg = (min(temp_min, max_temp) + min(temp_max, max_temp)) / 2.0
    return max(0.0, t_avg - base_temp)
end

"""
    light_interception(lai, extinction_coefficient) -> Float64

Fraction of photosynthetically active radiation intercepted by the canopy
according to the Beer-Lambert law:

    f_int = 1 - exp(-k * LAI)
"""
function light_interception(lai::Float64, extinction_coefficient::Float64)::Float64
    return 1.0 - exp(-extinction_coefficient * lai)
end

"""
    biomass_partitioning(growth_stage, thermal_time) -> (f_root, f_leaf, f_stem, f_fruit)

Return fractional allocation of daily assimilate to each organ pool.
Partitioning coefficients shift with phenological development following
WOFOST-style tables.
"""
function biomass_partitioning(growth_stage::GrowthStage,
                              thermal_time_acc::Float64)::NTuple{4,Float64}
    if growth_stage == GERMINATION
        # Predominantly root and leaf growth during emergence
        return (0.40, 0.45, 0.15, 0.0)
    elseif growth_stage == VEGETATIVE
        # Gradual shift from leaf to stem
        # Linearly interpolate stem fraction as thermal time progresses
        veg_progress = min(thermal_time_acc / 800.0, 1.0)
        f_root = 0.20 - 0.10 * veg_progress
        f_leaf = 0.45 - 0.20 * veg_progress
        f_stem = 0.30 + 0.15 * veg_progress
        f_fruit = 0.05 * veg_progress
        total = f_root + f_leaf + f_stem + f_fruit
        return (f_root / total, f_leaf / total, f_stem / total, f_fruit / total)
    elseif growth_stage == REPRODUCTIVE
        # Assimilate primarily to grain/fruit
        return (0.05, 0.05, 0.10, 0.80)
    else  # MATURITY
        # Remobilisation to fruit, negligible new growth
        return (0.0, 0.0, 0.05, 0.95)
    end
end

"""
    phenology_update(state, daily_tt, params) -> GrowthStage

Determine growth stage based on accumulated thermal time thresholds.
"""
function phenology_update(state::GrowthState, daily_tt::Float64,
                          params::CropParameters)::GrowthStage
    tt = state.thermal_time_accumulated + daily_tt

    if tt < params.tt_germination
        return GERMINATION
    elseif tt < params.tt_vegetative_end
        return VEGETATIVE
    elseif tt < params.tt_reproductive_end
        return REPRODUCTIVE
    else
        return MATURITY
    end
end

"""
    water_stress(soil_moisture, field_capacity, wilting_point) -> Float64

Water stress factor in [0, 1].  1 = no stress, 0 = permanent wilting.
Uses a linear reduction between a critical threshold (p * FC) and
wilting point.  The critical depletion fraction p = 0.55 (FAO-56 default).
"""
function water_stress(soil_moisture::Float64, field_capacity::Float64,
                      wilting_point::Float64)::Float64
    p = 0.55  # management-allowed depletion fraction
    theta_critical = wilting_point + p * (field_capacity - wilting_point)
    if soil_moisture >= theta_critical
        return 1.0
    elseif soil_moisture <= wilting_point
        return 0.0
    else
        return (soil_moisture - wilting_point) / (theta_critical - wilting_point)
    end
end

"""
    nitrogen_uptake(root_depth, soil_nitrogen_kg, demand_kg) -> Float64

Simple N uptake model: uptake is the minimum of demand and supply.
Supply scales with root depth (deeper roots access more N).
Michaelis-Menten kinetics modulate concentration-dependent uptake.

Returns actual N uptake (kg/ha).
"""
function nitrogen_uptake(root_depth::Float64, soil_nitrogen_kg::Float64,
                         demand_kg::Float64;
                         max_root_depth::Float64 = 1.5,
                         km::Float64 = 20.0)::Float64
    depth_fraction = min(root_depth / max_root_depth, 1.0)
    available_n = soil_nitrogen_kg * depth_fraction
    # Michaelis-Menten uptake
    uptake_potential = available_n * demand_kg / (km + available_n)
    return min(uptake_potential, demand_kg, available_n)
end

"""
    temperature_response(temp, t_base, t_opt, t_max) -> Float64

Beta-function temperature response curve.
Returns a value in [0, 1], peaking at T_opt.
"""
function temperature_response(temp::Float64, t_base::Float64,
                               t_opt::Float64, t_max::Float64)::Float64
    if temp <= t_base || temp >= t_max
        return 0.0
    end
    alpha = log(2.0) / log((t_max - t_base) / (t_opt - t_base))
    numerator = (temp - t_base)^alpha * (t_max - temp)
    denom = (t_opt - t_base)^alpha * (t_max - t_opt)
    return max(0.0, min(1.0, numerator / denom))
end

# ---------------------------------------------------------------------------
# Daily growth step (used inside the ODE or explicit Euler loop)
# ---------------------------------------------------------------------------

"""
    daily_growth!(state, weather, params, soil, soil_moisture, soil_n_available)

Advance the crop state by one day. Modifies `state` in-place.
Returns the daily biomass increment (kg DM/ha).
"""
function daily_growth!(state::GrowthState, weather::WeatherInput,
                       params::CropParameters, soil::SoilParameters,
                       soil_moisture::Float64, soil_n_available::Float64)::Float64
    # 1. Thermal time
    dt_tt = thermal_time(weather.temp_min, weather.temp_max,
                         params.base_temperature; max_temp=params.max_temperature)

    # 2. Phenology
    new_stage = phenology_update(state, dt_tt, params)
    state.growth_stage = new_stage
    state.thermal_time_accumulated += dt_tt

    # If mature, no further growth
    if state.growth_stage == MATURITY
        return 0.0
    end

    # 3. Temperature response
    t_avg = (weather.temp_min + weather.temp_max) / 2.0
    t_resp = temperature_response(t_avg, params.base_temperature,
                                   params.optimum_temperature,
                                   params.max_temperature)

    # 4. Light interception (PAR = 0.5 * total solar radiation)
    par = weather.solar_radiation_mj * 0.5  # MJ / m^2 / day
    f_int = light_interception(state.leaf_area_index, params.extinction_coefficient)
    intercepted_par = par * f_int  # MJ / m^2 / day

    # 5. Potential biomass production (kg DM / ha)
    # RUE in g/MJ -> convert to kg/ha: g/MJ * MJ/m^2 * 10000 m^2/ha / 1000 g/kg = *10
    potential_growth = params.radiation_use_efficiency * intercepted_par * 10.0 * t_resp

    # 6. Stress factors
    state.water_stress_factor = water_stress(soil_moisture,
                                             soil.field_capacity, soil.wilting_point)
    ws = 1.0 - params.water_stress_coefficient * (1.0 - state.water_stress_factor)

    # Nitrogen stress
    n_demand = potential_growth * 0.025  # ~2.5% N in new DM
    n_uptake_actual = nitrogen_uptake(state.root_depth_m, soil_n_available, n_demand;
                                      max_root_depth=soil.max_root_depth_m)
    n_satisfaction = n_demand > 0.0 ? n_uptake_actual / n_demand : 1.0
    state.nitrogen_stress_factor = min(1.0, n_satisfaction)
    ns = 1.0 - params.nitrogen_stress_coefficient * (1.0 - state.nitrogen_stress_factor)

    # 7. Actual growth
    actual_growth = potential_growth * ws * ns
    actual_growth = max(0.0, actual_growth)

    # 8. Biomass partitioning
    (f_root, f_leaf, f_stem, f_fruit) = biomass_partitioning(state.growth_stage,
                                                              state.thermal_time_accumulated)
    state.biomass_root_kg += actual_growth * f_root
    state.biomass_leaf_kg += actual_growth * f_leaf
    state.biomass_stem_kg += actual_growth * f_stem
    state.biomass_fruit_kg += actual_growth * f_fruit
    state.biomass_total_kg += actual_growth

    # 9. Leaf area index update
    # New leaf area from new leaf biomass via specific leaf area (m^2/kg)
    # SLA in m^2/kg; biomass_leaf_kg in kg/ha
    state.leaf_area_index = min(
        params.max_leaf_area_index,
        state.biomass_leaf_kg * params.specific_leaf_area / 10000.0
    )
    # Ensure LAI doesn't go below a minimum for established crops
    if state.growth_stage != GERMINATION
        state.leaf_area_index = max(state.leaf_area_index, 0.01)
    end

    # 10. Root depth
    state.root_depth_m = min(
        soil.max_root_depth_m,
        state.root_depth_m + params.root_depth_rate * dt_tt
    )

    # 11. Day counter
    state.day_of_year = Dates.dayofyear(weather.date)

    return actual_growth
end

# ---------------------------------------------------------------------------
# Simple daily soil water balance (used internally)
# ---------------------------------------------------------------------------

function daily_water_balance(soil_moisture::Float64, weather::WeatherInput,
                              lai::Float64, soil::SoilParameters)::Float64
    # Simple Priestley-Taylor approximation for ET
    alpha_pt = 1.26
    # Net radiation approximation (MJ/m^2/day)
    rn = weather.solar_radiation_mj * 0.75 * (1.0 - 0.23)
    # Slope of saturation vapour pressure curve
    t_avg = (weather.temp_min + weather.temp_max) / 2.0
    svp = 0.6108 * exp(17.27 * t_avg / (t_avg + 237.3))
    delta = 4098.0 * svp / (t_avg + 237.3)^2
    gamma = 0.0665  # psychrometric constant kPa/degC (at ~100m)
    # Reference ET (mm/day)
    et0 = alpha_pt * delta / (delta + gamma) * rn / 2.45
    et0 = max(0.0, et0)

    # Crop ET (simple Kc from LAI)
    kc = min(1.15, 0.3 + 0.7 * min(lai / 3.0, 1.0))
    etc = et0 * kc

    # Water balance (in mm equivalent, 1mm = 0.001 m^3/m^2)
    # Convert volumetric to mm over 1m depth: theta * 1000
    sw_mm = soil_moisture * 1000.0
    sw_mm += weather.rainfall_mm - etc
    # Drainage if above field capacity
    fc_mm = soil.field_capacity * 1000.0
    wp_mm = soil.wilting_point * 1000.0
    if sw_mm > fc_mm
        sw_mm = fc_mm
    end
    sw_mm = max(wp_mm, sw_mm)

    return sw_mm / 1000.0  # back to volumetric
end

# ---------------------------------------------------------------------------
# ODE-based growth simulation
# ---------------------------------------------------------------------------

"""
    simulate_growth(params, weather, soil, initial_state) -> Vector{GrowthState}

Full-season crop growth simulation. Uses an explicit daily time-step loop
coupled with DifferentialEquations.jl for the internal biomass ODE integration
within each day (sub-daily resolution for numerical stability).

Returns a vector of daily `GrowthState` snapshots.
"""
function simulate_growth(params::CropParameters, weather::Vector{WeatherInput},
                         soil::SoilParameters,
                         initial_state::GrowthState = GrowthState(
                             day_of_year=Dates.dayofyear(weather[1].date)))

    n_days = length(weather)
    history = Vector{GrowthState}(undef, n_days)
    state = deepcopy(initial_state)
    soil_moisture = soil.initial_moisture
    soil_n = soil.soil_nitrogen_kg_ha

    for d in 1:n_days
        w = weather[d]

        # ODE formulation for sub-daily biomass integration
        # State vector: [biomass_total, biomass_root, biomass_leaf, biomass_stem, biomass_fruit, LAI, root_depth, thermal_time_acc]
        u0 = [state.biomass_total_kg, state.biomass_root_kg,
              state.biomass_leaf_kg, state.biomass_stem_kg,
              state.biomass_fruit_kg, state.leaf_area_index,
              state.root_depth_m, state.thermal_time_accumulated]

        # Cache per-day constants
        t_avg = (w.temp_min + w.temp_max) / 2.0
        dt_tt = thermal_time(w.temp_min, w.temp_max, params.base_temperature;
                             max_temp=params.max_temperature)
        t_resp = temperature_response(t_avg, params.base_temperature,
                                       params.optimum_temperature,
                                       params.max_temperature)
        par = w.solar_radiation_mj * 0.5
        ws_factor = water_stress(soil_moisture, soil.field_capacity, soil.wilting_point)
        ws = 1.0 - params.water_stress_coefficient * (1.0 - ws_factor)

        function growth_ode!(du, u, p, t)
            # u = [total, root, leaf, stem, fruit, lai, rdepth, tt]
            current_lai = max(u[6], 0.001)
            current_tt = u[8]

            # Determine stage from thermal time
            local stage::GrowthStage
            if current_tt < params.tt_germination
                stage = GERMINATION
            elseif current_tt < params.tt_vegetative_end
                stage = VEGETATIVE
            elseif current_tt < params.tt_reproductive_end
                stage = REPRODUCTIVE
            else
                stage = MATURITY
            end

            if stage == MATURITY
                du .= 0.0
                return
            end

            f_int = light_interception(current_lai, params.extinction_coefficient)
            intercepted = par * f_int
            pot_growth = params.radiation_use_efficiency * intercepted * 10.0 * t_resp

            # N stress (simplified for ODE)
            n_demand = pot_growth * 0.025
            depth_frac = min(u[7] / soil.max_root_depth_m, 1.0)
            avail_n = soil_n * depth_frac
            n_uptake_val = min(avail_n * n_demand / (20.0 + avail_n), n_demand, avail_n)
            n_sat = n_demand > 0.0 ? n_uptake_val / n_demand : 1.0
            ns = 1.0 - params.nitrogen_stress_coefficient * (1.0 - min(1.0, n_sat))

            actual_rate = max(0.0, pot_growth * ws * ns)

            (f_r, f_l, f_s, f_f) = biomass_partitioning(stage, current_tt)

            du[1] = actual_rate        # total biomass
            du[2] = actual_rate * f_r  # root
            du[3] = actual_rate * f_l  # leaf
            du[4] = actual_rate * f_s  # stem
            du[5] = actual_rate * f_f  # fruit
            # LAI rate: d(LAI)/dt = SLA * d(leaf)/dt / 10000
            du[6] = actual_rate * f_l * params.specific_leaf_area / 10000.0
            # Root depth rate
            du[7] = params.root_depth_rate * dt_tt
            # Thermal time accumulation
            du[8] = dt_tt
        end

        tspan = (0.0, 1.0)  # One day
        prob = ODEProblem(growth_ode!, u0, tspan)
        sol = solve(prob, Tsit5(); reltol=1e-6, abstol=1e-8, save_everystep=false)

        u_end = sol.u[end]

        state.biomass_total_kg = max(0.0, u_end[1])
        state.biomass_root_kg = max(0.0, u_end[2])
        state.biomass_leaf_kg = max(0.0, u_end[3])
        state.biomass_stem_kg = max(0.0, u_end[4])
        state.biomass_fruit_kg = max(0.0, u_end[5])
        state.leaf_area_index = clamp(u_end[6], 0.001, params.max_leaf_area_index)
        state.root_depth_m = clamp(u_end[7], 0.05, soil.max_root_depth_m)
        state.thermal_time_accumulated = max(0.0, u_end[8])

        # Update phenology
        state.growth_stage = phenology_update(
            GrowthState(day_of_year=0, thermal_time_accumulated=state.thermal_time_accumulated - dt_tt,
                        leaf_area_index=0.0, biomass_total_kg=0.0, biomass_root_kg=0.0,
                        biomass_leaf_kg=0.0, biomass_stem_kg=0.0, biomass_fruit_kg=0.0,
                        root_depth_m=0.0, growth_stage=GERMINATION,
                        water_stress_factor=1.0, nitrogen_stress_factor=1.0),
            dt_tt, params)

        state.water_stress_factor = ws_factor
        state.day_of_year = Dates.dayofyear(w.date)

        # Soil water balance
        soil_moisture = daily_water_balance(soil_moisture, w,
                                            state.leaf_area_index, soil)

        # Soil nitrogen depletion
        n_used = state.biomass_total_kg * 0.025 * 0.01  # rough daily N use
        soil_n = max(0.0, soil_n - n_used)

        history[d] = deepcopy(state)
    end

    return history
end

end # module CropGrowth
