module Phenology

using Dates
using Statistics

export PhenologyParameters, PhenologyState, VernalizationParams,
       PhotoperiodParams, PhenologyStage,
       SOWING, EMERGENCE, JUVENILE, FLORAL_INITIATION, FLOWERING,
       GRAIN_FILLING, PHYSIOLOGICAL_MATURITY,
       compute_photoperiod, vernalization_factor, photoperiod_factor,
       advance_phenology, predict_stage_durations, growing_degree_days_hourly

# ---------------------------------------------------------------------------
# Phenological stage enumeration
# ---------------------------------------------------------------------------
@enum PhenologyStage begin
    SOWING                  = 1
    EMERGENCE               = 2
    JUVENILE                = 3
    FLORAL_INITIATION       = 4
    FLOWERING               = 5
    GRAIN_FILLING           = 6
    PHYSIOLOGICAL_MATURITY  = 7
end

# ---------------------------------------------------------------------------
# Parameter structures
# ---------------------------------------------------------------------------

"""
    VernalizationParams

Parameters for vernalization response in winter crops (wheat, barley, etc.).
"""
struct VernalizationParams
    vern_base_temp::Float64       # Lower optimum for vernalization (degC)
    vern_opt_temp::Float64        # Optimum vernalization temperature (degC)
    vern_max_temp::Float64        # Upper limit for vernalization (degC)
    vern_days_required::Float64   # Vernalization days to saturate (d)
    vern_sensitivity::Float64     # Sensitivity coefficient (0-1)
    is_winter_crop::Bool          # Whether vernalization is required
end

function VernalizationParams(;
    vern_base_temp     = -1.0,
    vern_opt_temp      = 4.5,
    vern_max_temp      = 15.0,
    vern_days_required = 40.0,
    vern_sensitivity   = 0.5,
    is_winter_crop     = false
)
    VernalizationParams(vern_base_temp, vern_opt_temp, vern_max_temp,
                        vern_days_required, vern_sensitivity, is_winter_crop)
end

"""
    PhotoperiodParams

Parameters for photoperiod (daylength) response.
"""
struct PhotoperiodParams
    critical_photoperiod::Float64   # Hours below/above which development slows
    optimum_photoperiod::Float64    # Hours at which development is maximal
    sensitivity::Float64            # Photoperiod sensitivity (0 = day-neutral)
    is_long_day::Bool               # true = long-day plant, false = short-day
end

function PhotoperiodParams(;
    critical_photoperiod = 10.0,
    optimum_photoperiod  = 14.0,
    sensitivity          = 0.0,
    is_long_day          = true
)
    PhotoperiodParams(critical_photoperiod, optimum_photoperiod,
                      sensitivity, is_long_day)
end

"""
    PhenologyParameters

Complete phenology parameterisation.
"""
struct PhenologyParameters
    base_temperature::Float64
    optimum_temperature::Float64
    max_temperature::Float64

    # Thermal time thresholds (degree-days) for stage transitions
    tt_sowing_to_emergence::Float64
    tt_emergence_to_juvenile_end::Float64
    tt_juvenile_to_floral_init::Float64
    tt_floral_init_to_flowering::Float64
    tt_flowering_to_grain_fill_end::Float64
    tt_grain_fill_to_maturity::Float64

    vernalization::VernalizationParams
    photoperiod::PhotoperiodParams
end

function PhenologyParameters(;
    base_temperature               = 0.0,
    optimum_temperature            = 25.0,
    max_temperature                = 37.0,
    tt_sowing_to_emergence         = 120.0,
    tt_emergence_to_juvenile_end   = 400.0,
    tt_juvenile_to_floral_init     = 200.0,
    tt_floral_init_to_flowering    = 300.0,
    tt_flowering_to_grain_fill_end = 500.0,
    tt_grain_fill_to_maturity      = 250.0,
    vernalization                  = VernalizationParams(),
    photoperiod                    = PhotoperiodParams()
)
    PhenologyParameters(
        base_temperature, optimum_temperature, max_temperature,
        tt_sowing_to_emergence, tt_emergence_to_juvenile_end,
        tt_juvenile_to_floral_init, tt_floral_init_to_flowering,
        tt_flowering_to_grain_fill_end, tt_grain_fill_to_maturity,
        vernalization, photoperiod
    )
end

"""
    PhenologyState

Mutable state for phenology tracking.
"""
mutable struct PhenologyState
    current_stage::PhenologyStage
    thermal_time_accumulated::Float64
    thermal_time_in_stage::Float64
    vernalization_days::Float64
    vernalization_factor::Float64     # 0-1
    photoperiod_factor::Float64       # 0-1
    days_after_sowing::Int
    date_emergence::Union{Date, Nothing}
    date_flowering::Union{Date, Nothing}
    date_maturity::Union{Date, Nothing}
end

function PhenologyState()
    PhenologyState(SOWING, 0.0, 0.0, 0.0, 0.0, 1.0, 0,
                   nothing, nothing, nothing)
end

# ---------------------------------------------------------------------------
# Astronomical calculations
# ---------------------------------------------------------------------------

"""
    compute_photoperiod(latitude, day_of_year) -> Float64

Daylength in hours. Uses the CBM model (Civil twilight, when sun is 6 deg below
horizon, approximation used in most crop models).

Latitude in degrees (positive = North).
"""
function compute_photoperiod(latitude::Float64, day_of_year::Int)::Float64
    # Solar declination (radians)
    declination = -23.45 * cosd(360.0 / 365.0 * (day_of_year + 10))
    decl_rad = deg2rad(declination)
    lat_rad = deg2rad(latitude)

    # Civil twilight angle (-6 degrees below horizon -> -0.10472 rad)
    twilight_angle = deg2rad(-6.0)

    # Hour angle at sunrise/sunset
    cos_hour_angle = (sin(twilight_angle) - sin(lat_rad) * sin(decl_rad)) /
                     (cos(lat_rad) * cos(decl_rad))

    # Clamp for polar day/night
    if cos_hour_angle < -1.0
        return 24.0   # polar day
    elseif cos_hour_angle > 1.0
        return 0.0    # polar night
    end

    hour_angle = acos(cos_hour_angle)
    daylength = 2.0 * rad2deg(hour_angle) / 15.0  # Convert to hours
    return daylength
end

# ---------------------------------------------------------------------------
# Vernalization
# ---------------------------------------------------------------------------

"""
    daily_vernalization(temp_min, temp_max, params) -> Float64

Compute daily vernalization effectiveness (0-1 vernalization days).
Uses a triangular response: maximum at T_opt, zero outside [T_base, T_max].
"""
function daily_vernalization(temp_min::Float64, temp_max::Float64,
                              vp::VernalizationParams)::Float64
    if !vp.is_winter_crop
        return 0.0
    end

    t_avg = (temp_min + temp_max) / 2.0

    if t_avg <= vp.vern_base_temp || t_avg >= vp.vern_max_temp
        return 0.0
    elseif t_avg <= vp.vern_opt_temp
        return (t_avg - vp.vern_base_temp) / (vp.vern_opt_temp - vp.vern_base_temp)
    else
        return (vp.vern_max_temp - t_avg) / (vp.vern_max_temp - vp.vern_opt_temp)
    end
end

"""
    vernalization_factor(vern_days, vern_days_required, sensitivity) -> Float64

Vernalization factor (0-1) that modulates development rate.
0 = fully unvernalized, 1 = fully vernalized.
"""
function vernalization_factor(vern_days::Float64, vern_days_required::Float64,
                               sensitivity::Float64)::Float64
    if vern_days_required <= 0.0
        return 1.0
    end
    vf = min(1.0, vern_days / vern_days_required)
    # Apply sensitivity: at sensitivity=1, development fully blocked until vernalized
    return 1.0 - sensitivity * (1.0 - vf)
end

# ---------------------------------------------------------------------------
# Photoperiod response
# ---------------------------------------------------------------------------

"""
    photoperiod_factor(daylength, params) -> Float64

Photoperiod factor (0-1) modulating development rate.
"""
function photoperiod_factor(daylength::Float64, pp::PhotoperiodParams)::Float64
    if pp.sensitivity <= 0.0
        return 1.0  # Day-neutral
    end

    if pp.is_long_day
        # Long-day plant: development increases with daylength up to optimum
        if daylength >= pp.optimum_photoperiod
            pf = 1.0
        elseif daylength <= pp.critical_photoperiod
            pf = 0.0
        else
            pf = (daylength - pp.critical_photoperiod) /
                 (pp.optimum_photoperiod - pp.critical_photoperiod)
        end
    else
        # Short-day plant: development increases as daylength decreases
        if daylength <= pp.optimum_photoperiod
            pf = 1.0
        elseif daylength >= pp.critical_photoperiod
            pf = 0.0
        else
            pf = (pp.critical_photoperiod - daylength) /
                 (pp.critical_photoperiod - pp.optimum_photoperiod)
        end
    end

    # Scale by sensitivity
    return 1.0 - pp.sensitivity * (1.0 - pf)
end

# ---------------------------------------------------------------------------
# Thermal time with hourly resolution
# ---------------------------------------------------------------------------

"""
    growing_degree_days_hourly(temp_min, temp_max, base_temp, opt_temp, max_temp) -> Float64

Compute growing degree-days using an 8-point sinusoidal hourly temperature
approximation for improved accuracy versus the simple average method.
"""
function growing_degree_days_hourly(temp_min::Float64, temp_max::Float64,
                                     base_temp::Float64, opt_temp::Float64,
                                     max_temp::Float64)::Float64
    gdd = 0.0
    t_amp = (temp_max - temp_min) / 2.0
    t_mean = (temp_min + temp_max) / 2.0

    n_steps = 8  # 3-hourly
    for i in 0:(n_steps - 1)
        # Sinusoidal temperature approximation
        # Maximum at ~14:00 (hour 14), minimum at ~02:00 (hour 2)
        hour = i * (24.0 / n_steps)
        t_hour = t_mean + t_amp * sin(2.0 * pi * (hour - 8.0) / 24.0)

        if t_hour <= base_temp || t_hour >= max_temp
            contribution = 0.0
        elseif t_hour <= opt_temp
            contribution = t_hour - base_temp
        else
            # Linear decline above optimum
            contribution = (opt_temp - base_temp) * (max_temp - t_hour) / (max_temp - opt_temp)
            contribution = max(0.0, contribution)
        end
        gdd += contribution
    end

    return gdd / n_steps
end

# ---------------------------------------------------------------------------
# Main phenology advancement
# ---------------------------------------------------------------------------

"""
    get_stage_threshold(stage, params) -> Float64

Return the thermal time threshold for completing the given stage.
"""
function get_stage_threshold(stage::PhenologyStage,
                              params::PhenologyParameters)::Float64
    if stage == SOWING
        return params.tt_sowing_to_emergence
    elseif stage == EMERGENCE
        return params.tt_emergence_to_juvenile_end
    elseif stage == JUVENILE
        return params.tt_juvenile_to_floral_init
    elseif stage == FLORAL_INITIATION
        return params.tt_floral_init_to_flowering
    elseif stage == FLOWERING
        return params.tt_flowering_to_grain_fill_end
    elseif stage == GRAIN_FILLING
        return params.tt_grain_fill_to_maturity
    else
        return Inf  # Already at maturity
    end
end

"""
    next_stage(stage) -> PhenologyStage

Return the next phenological stage.
"""
function next_stage(stage::PhenologyStage)::PhenologyStage
    if stage == SOWING
        return EMERGENCE
    elseif stage == EMERGENCE
        return JUVENILE
    elseif stage == JUVENILE
        return FLORAL_INITIATION
    elseif stage == FLORAL_INITIATION
        return FLOWERING
    elseif stage == FLOWERING
        return GRAIN_FILLING
    elseif stage == GRAIN_FILLING
        return PHYSIOLOGICAL_MATURITY
    else
        return PHYSIOLOGICAL_MATURITY
    end
end

"""
    advance_phenology(state, params, temp_min, temp_max, latitude, current_date) -> PhenologyState

Advance phenology by one day. Updates vernalization, photoperiod,
thermal time, and stage transitions.
"""
function advance_phenology(state::PhenologyState, params::PhenologyParameters,
                            temp_min::Float64, temp_max::Float64,
                            latitude::Float64, current_date::Date)::PhenologyState

    s = deepcopy(state)
    s.days_after_sowing += 1

    if s.current_stage == PHYSIOLOGICAL_MATURITY
        return s
    end

    # 1. Growing degree-days (hourly method)
    gdd = growing_degree_days_hourly(temp_min, temp_max,
                                      params.base_temperature,
                                      params.optimum_temperature,
                                      params.max_temperature)

    # 2. Vernalization (only affects pre-floral stages)
    if params.vernalization.is_winter_crop &&
       Int(s.current_stage) <= Int(JUVENILE)
        dv = daily_vernalization(temp_min, temp_max, params.vernalization)
        s.vernalization_days += dv
        s.vernalization_factor = vernalization_factor(
            s.vernalization_days,
            params.vernalization.vern_days_required,
            params.vernalization.vern_sensitivity
        )
    else
        s.vernalization_factor = 1.0
    end

    # 3. Photoperiod response (affects JUVENILE and FLORAL_INITIATION stages)
    doy = Dates.dayofyear(current_date)
    daylength = compute_photoperiod(latitude, doy)
    if Int(s.current_stage) >= Int(JUVENILE) &&
       Int(s.current_stage) <= Int(FLORAL_INITIATION)
        s.photoperiod_factor = photoperiod_factor(daylength, params.photoperiod)
    else
        s.photoperiod_factor = 1.0
    end

    # 4. Effective thermal time (modulated by vernalization and photoperiod)
    effective_gdd = gdd * s.vernalization_factor * s.photoperiod_factor
    s.thermal_time_accumulated += effective_gdd
    s.thermal_time_in_stage += effective_gdd

    # 5. Check stage transition
    threshold = get_stage_threshold(s.current_stage, params)
    if s.thermal_time_in_stage >= threshold
        overflow = s.thermal_time_in_stage - threshold

        # Record key dates
        new_stg = next_stage(s.current_stage)
        if new_stg == EMERGENCE
            s.date_emergence = current_date
        elseif new_stg == FLOWERING
            s.date_flowering = current_date
        elseif new_stg == PHYSIOLOGICAL_MATURITY
            s.date_maturity = current_date
        end

        s.current_stage = new_stg
        s.thermal_time_in_stage = overflow
    end

    return s
end

# ---------------------------------------------------------------------------
# Stage duration prediction
# ---------------------------------------------------------------------------

"""
    predict_stage_durations(params, weather_temps, latitude, sowing_date) -> Dict{PhenologyStage, Int}

Predict the number of days each phenological stage will last given a
temperature time series. Returns a dictionary mapping each stage to its
predicted duration in days.

`weather_temps` should be a vector of `(temp_min, temp_max)` tuples.
"""
function predict_stage_durations(params::PhenologyParameters,
                                  weather_temps::Vector{Tuple{Float64,Float64}},
                                  latitude::Float64,
                                  sowing_date::Date)::Dict{PhenologyStage,Int}
    durations = Dict{PhenologyStage,Int}()
    state = PhenologyState()
    prev_stage = SOWING

    for (i, (tmin, tmax)) in enumerate(weather_temps)
        current_date = sowing_date + Dates.Day(i - 1)
        state = advance_phenology(state, params, tmin, tmax, latitude, current_date)

        if state.current_stage != prev_stage
            durations[prev_stage] = i
            prev_stage = state.current_stage
        end

        if state.current_stage == PHYSIOLOGICAL_MATURITY
            durations[PHYSIOLOGICAL_MATURITY] = 0
            break
        end
    end

    # Calculate actual durations from cumulative days
    stages_order = [SOWING, EMERGENCE, JUVENILE, FLORAL_INITIATION,
                    FLOWERING, GRAIN_FILLING, PHYSIOLOGICAL_MATURITY]
    prev_day = 0
    result = Dict{PhenologyStage,Int}()
    for stg in stages_order
        if haskey(durations, stg)
            result[stg] = durations[stg] - prev_day
            prev_day = durations[stg]
        end
    end

    return result
end

end # module Phenology
