//! Phenology model: vernalization, photoperiod, improved thermal time.
//!
//! Ported from the Julia `Phenology.jl` module. All angles are in degrees
//! at the API boundary and converted to radians internally.

use std::f64::consts::PI;
use serde::{Deserialize, Serialize};

use crate::types::{GrowthStage, PhenologyParams, StageThresholds};

// ---------------------------------------------------------------------------
// Phenological stage enumeration
// ---------------------------------------------------------------------------

/// Phenological stages following the detailed BBCH-like progression.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
#[repr(u8)]
pub enum PhenologyStage {
    Sowing = 1,
    Emergence = 2,
    Juvenile = 3,
    FloralInitiation = 4,
    Flowering = 5,
    GrainFilling = 6,
    PhysiologicalMaturity = 7,
}

impl PhenologyStage {
    /// Return the next stage in the phenological sequence.
    pub fn next(self) -> Self {
        match self {
            Self::Sowing => Self::Emergence,
            Self::Emergence => Self::Juvenile,
            Self::Juvenile => Self::FloralInitiation,
            Self::FloralInitiation => Self::Flowering,
            Self::Flowering => Self::GrainFilling,
            Self::GrainFilling => Self::PhysiologicalMaturity,
            Self::PhysiologicalMaturity => Self::PhysiologicalMaturity,
        }
    }

    pub fn label(&self) -> &'static str {
        match self {
            Self::Sowing => "Sowing",
            Self::Emergence => "Emergence",
            Self::Juvenile => "Juvenile",
            Self::FloralInitiation => "Floral Initiation",
            Self::Flowering => "Flowering",
            Self::GrainFilling => "Grain Filling",
            Self::PhysiologicalMaturity => "Physiological Maturity",
        }
    }

    /// Convert to the simpler `GrowthStage` used by the WOFOST ODE layer.
    pub fn to_growth_stage(self) -> GrowthStage {
        match self {
            Self::Sowing => GrowthStage::Germination,
            Self::Emergence => GrowthStage::Emergence,
            Self::Juvenile | Self::FloralInitiation => GrowthStage::Vegetative,
            Self::Flowering => GrowthStage::Flowering,
            Self::GrainFilling => GrowthStage::GrainFilling,
            Self::PhysiologicalMaturity => GrowthStage::Maturity,
        }
    }

    /// Get the thermal time threshold for completing this stage.
    pub fn threshold(self, st: &StageThresholds) -> f64 {
        match self {
            Self::Sowing => st.tt_sowing_to_emergence,
            Self::Emergence => st.tt_emergence_to_juvenile_end,
            Self::Juvenile => st.tt_juvenile_to_floral_init,
            Self::FloralInitiation => st.tt_floral_init_to_flowering,
            Self::Flowering => st.tt_flowering_to_grain_fill_end,
            Self::GrainFilling => st.tt_grain_fill_to_maturity,
            Self::PhysiologicalMaturity => f64::INFINITY,
        }
    }

    /// Approximate DVS (development stage, 0-2) from the stage and the
    /// fractional progress through it.
    pub fn to_dvs(self, progress_in_stage: f64) -> f64 {
        let p = progress_in_stage.clamp(0.0, 1.0);
        match self {
            Self::Sowing => p * 0.05,
            Self::Emergence => 0.05 + p * 0.05,
            Self::Juvenile => 0.10 + p * 0.30,
            Self::FloralInitiation => 0.40 + p * 0.30,
            Self::Flowering => 0.70 + p * 0.30,
            Self::GrainFilling => 1.0 + p * 1.0,
            Self::PhysiologicalMaturity => 2.0,
        }
    }
}

// ---------------------------------------------------------------------------
// Phenology state
// ---------------------------------------------------------------------------

/// Mutable state for phenology tracking across daily time steps.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PhenologyState {
    pub current_stage: PhenologyStage,
    pub thermal_time_accumulated: f64,
    pub thermal_time_in_stage: f64,
    pub vernalization_days: f64,
    pub vernalization_factor: f64,
    pub photoperiod_factor: f64,
    pub days_after_sowing: u32,
}

impl Default for PhenologyState {
    fn default() -> Self {
        Self {
            current_stage: PhenologyStage::Sowing,
            thermal_time_accumulated: 0.0,
            thermal_time_in_stage: 0.0,
            vernalization_days: 0.0,
            vernalization_factor: 0.0,
            photoperiod_factor: 1.0,
            days_after_sowing: 0,
        }
    }
}

impl PhenologyState {
    /// Progress fraction (0-1) through the current stage.
    pub fn stage_progress(&self, thresholds: &StageThresholds) -> f64 {
        let threshold = self.current_stage.threshold(thresholds);
        if threshold <= 0.0 || threshold.is_infinite() {
            0.0
        } else {
            (self.thermal_time_in_stage / threshold).clamp(0.0, 1.0)
        }
    }

    /// Approximate DVS from the current phenology state.
    pub fn to_dvs(&self, thresholds: &StageThresholds) -> f64 {
        self.current_stage
            .to_dvs(self.stage_progress(thresholds))
    }
}

// ---------------------------------------------------------------------------
// 1. Astronomical photoperiod
// ---------------------------------------------------------------------------

/// Compute daylength in hours using the CBM model with civil twilight
/// correction (sun 6 degrees below horizon).
///
/// - `latitude_deg`: latitude in degrees (positive = North).
/// - `day_of_year`: ordinal day (1-366).
pub fn compute_photoperiod(latitude_deg: f64, day_of_year: u32) -> f64 {
    let doy = day_of_year as f64;

    // Solar declination (degrees), then convert to radians
    let declination_deg =
        -23.45 * (360.0_f64 / 365.0 * (doy + 10.0)).to_radians().cos();
    let decl_rad = declination_deg.to_radians();
    let lat_rad = latitude_deg.to_radians();

    // Civil twilight angle: -6 degrees below horizon
    let twilight_rad = (-6.0_f64).to_radians();

    let denominator = lat_rad.cos() * decl_rad.cos();
    if denominator.abs() < 1e-12 {
        return if lat_rad.sin() * decl_rad.sin() > 0.0 {
            24.0
        } else {
            0.0
        };
    }

    let cos_hour_angle =
        (twilight_rad.sin() - lat_rad.sin() * decl_rad.sin()) / denominator;

    // Polar day / polar night
    if cos_hour_angle < -1.0 {
        return 24.0;
    } else if cos_hour_angle > 1.0 {
        return 0.0;
    }

    let hour_angle = cos_hour_angle.acos();
    2.0 * hour_angle.to_degrees() / 15.0
}

// ---------------------------------------------------------------------------
// 2. Vernalization
// ---------------------------------------------------------------------------

/// Compute daily vernalization effectiveness (0-1 vernalization days) using
/// a triangular response function.
///
/// Maximum effectiveness at `vern_optimal`, zero outside
/// `[vern_base, vern_ceiling]`.
pub fn daily_vernalization(
    t_min: f64,
    t_max: f64,
    vern_base: f64,
    vern_optimal: f64,
    vern_ceiling: f64,
) -> f64 {
    let t_avg = (t_min + t_max) / 2.0;

    if t_avg <= vern_base || t_avg >= vern_ceiling {
        0.0
    } else if t_avg <= vern_optimal {
        (t_avg - vern_base) / (vern_optimal - vern_base)
    } else {
        (vern_ceiling - t_avg) / (vern_ceiling - vern_optimal)
    }
}

/// Compute the vernalization factor from a series of daily average
/// temperatures, accumulating vernalization days with the triangular
/// response.
///
/// - `daily_temps`: slice of daily average temperatures.
/// - Returns a factor in `[0, 1]` where 1 = fully vernalized.
pub fn vernalization_factor(
    daily_temps: &[f64],
    vern_base: f64,
    vern_optimal: f64,
    vern_ceiling: f64,
    vern_requirement: f64,
) -> f64 {
    if vern_requirement <= 0.0 {
        return 1.0;
    }

    let vern_days: f64 = daily_temps
        .iter()
        .map(|&t_avg| {
            if t_avg <= vern_base || t_avg >= vern_ceiling {
                0.0
            } else if t_avg <= vern_optimal {
                (t_avg - vern_base) / (vern_optimal - vern_base)
            } else {
                (vern_ceiling - t_avg) / (vern_ceiling - vern_optimal)
            }
        })
        .sum();

    (vern_days / vern_requirement).min(1.0)
}

/// Compute vernalization factor from already-accumulated vernalization days.
///
/// - `vern_days`: accumulated effective vernalization days.
/// - `vern_requirement`: days needed for full vernalization.
/// - `sensitivity`: 0 = no effect, 1 = development fully blocked until
///   vernalized.
pub fn vernalization_factor_from_days(
    vern_days: f64,
    vern_requirement: f64,
    sensitivity: f64,
) -> f64 {
    if vern_requirement <= 0.0 {
        return 1.0;
    }
    let vf = (vern_days / vern_requirement).min(1.0);
    // At sensitivity=1, development fully blocked until vernalized
    1.0 - sensitivity * (1.0 - vf)
}

// ---------------------------------------------------------------------------
// 3. Photoperiod response
// ---------------------------------------------------------------------------

/// Photoperiod factor modulating development rate.
///
/// - `daylength`: hours of daylight.
/// - `critical_photoperiod`: threshold daylength below/above which
///   development slows (hours).
/// - `optimum_photoperiod`: daylength at which development is maximal (hours).
/// - `sensitivity`: 0 = day-neutral, 1 = fully sensitive.
/// - `is_long_day`: `true` for long-day plants, `false` for short-day.
///
/// Returns a factor in `[0, 1]` where 1 = no photoperiod limitation.
pub fn photoperiod_factor(
    daylength: f64,
    critical_photoperiod: f64,
    optimum_photoperiod: f64,
    sensitivity: f64,
    is_long_day: bool,
) -> f64 {
    if sensitivity <= 0.0 {
        return 1.0; // Day-neutral
    }

    let pf = if is_long_day {
        // Long-day plant: development increases with daylength up to optimum
        if daylength >= optimum_photoperiod {
            1.0
        } else if daylength <= critical_photoperiod {
            0.0
        } else {
            (daylength - critical_photoperiod)
                / (optimum_photoperiod - critical_photoperiod)
        }
    } else {
        // Short-day plant: development increases as daylength decreases
        if daylength <= optimum_photoperiod {
            1.0
        } else if daylength >= critical_photoperiod {
            0.0
        } else {
            (critical_photoperiod - daylength)
                / (critical_photoperiod - optimum_photoperiod)
        }
    };

    // Scale by sensitivity
    1.0 - sensitivity * (1.0 - pf)
}

// ---------------------------------------------------------------------------
// 4. Improved thermal time (8-point sinusoidal)
// ---------------------------------------------------------------------------

/// Compute growing degree-days using an 8-point sinusoidal hourly
/// temperature approximation.
///
/// More accurate than the simple `(T_avg - T_base)` daily average method
/// because it accounts for the non-linear temperature response across the
/// diurnal cycle.
pub fn hourly_thermal_time(
    t_min: f64,
    t_max: f64,
    t_base: f64,
    t_optimal: f64,
    t_ceiling: f64,
) -> f64 {
    let t_amp = (t_max - t_min) / 2.0;
    let t_mean = (t_min + t_max) / 2.0;
    let n_steps: usize = 8; // 3-hourly intervals

    let mut gdd = 0.0;
    for i in 0..n_steps {
        let hour = i as f64 * (24.0 / n_steps as f64);
        // Sinusoidal temperature: maximum at ~14:00, minimum at ~02:00
        let t_hour = t_mean + t_amp * (2.0 * PI * (hour - 8.0) / 24.0).sin();

        let contribution = if t_hour <= t_base || t_hour >= t_ceiling {
            0.0
        } else if t_hour <= t_optimal {
            t_hour - t_base
        } else {
            // Linear decline above optimum
            ((t_optimal - t_base) * (t_ceiling - t_hour)
                / (t_ceiling - t_optimal))
                .max(0.0)
        };

        gdd += contribution;
    }

    gdd / n_steps as f64
}

// ---------------------------------------------------------------------------
// 5. Beta-function temperature response
// ---------------------------------------------------------------------------

/// Beta-function temperature response curve, returning a value in `[0, 1]`
/// peaking at `t_optimal`.
///
/// More biologically realistic than the piecewise-linear `temperature_factor`
/// used in the base WOFOST layer.
pub fn beta_temperature_response(
    temp: f64,
    t_base: f64,
    t_optimal: f64,
    t_ceiling: f64,
) -> f64 {
    if temp <= t_base || temp >= t_ceiling {
        return 0.0;
    }
    let ratio = (t_ceiling - t_base) / (t_optimal - t_base);
    if ratio <= 1.0 {
        return 0.0;
    }
    let alpha = 2.0_f64.ln() / ratio.ln();
    let numerator = (temp - t_base).powf(alpha) * (t_ceiling - temp);
    let denom = (t_optimal - t_base).powf(alpha) * (t_ceiling - t_optimal);
    if denom <= 0.0 {
        return 0.0;
    }
    (numerator / denom).clamp(0.0, 1.0)
}

// ---------------------------------------------------------------------------
// 6. Phenological stage advancement
// ---------------------------------------------------------------------------

/// Advance phenology by one daily time step.
///
/// Applies vernalization and photoperiod modifiers to the thermal time
/// increment, accumulates thermal time, and manages stage transitions
/// using the configured thresholds.
///
/// Returns the updated `PhenologyState`.
pub fn advance_phenology(
    state: &PhenologyState,
    thermal_time_increment: f64,
    vern_factor: f64,
    pp_factor: f64,
    thresholds: &StageThresholds,
) -> PhenologyState {
    let mut s = state.clone();
    s.days_after_sowing += 1;

    if s.current_stage == PhenologyStage::PhysiologicalMaturity {
        return s;
    }

    // Effective thermal time modulated by vernalization and photoperiod
    let effective_gdd = thermal_time_increment * vern_factor * pp_factor;
    s.thermal_time_accumulated += effective_gdd;
    s.thermal_time_in_stage += effective_gdd;
    s.vernalization_factor = vern_factor;
    s.photoperiod_factor = pp_factor;

    // Check stage transition
    let threshold = s.current_stage.threshold(thresholds);
    if s.thermal_time_in_stage >= threshold {
        let overflow = s.thermal_time_in_stage - threshold;
        s.current_stage = s.current_stage.next();
        s.thermal_time_in_stage = overflow;
    }

    s
}

// ---------------------------------------------------------------------------
// Convenience: full daily phenology step
// ---------------------------------------------------------------------------

/// Perform a complete daily phenology step: compute thermal time, update
/// vernalization, compute photoperiod, and advance the stage.
///
/// Returns `(new_state, effective_gdd)` where `effective_gdd` is the
/// phenology-adjusted growing degree-days for the day (for use in the
/// biomass ODE).
pub fn step_phenology(
    state: &PhenologyState,
    t_min: f64,
    t_max: f64,
    t_base: f64,
    t_opt: f64,
    pheno: &PhenologyParams,
    day_of_year: u32,
) -> (PhenologyState, f64) {
    if state.current_stage == PhenologyStage::PhysiologicalMaturity {
        let mut s = state.clone();
        s.days_after_sowing += 1;
        return (s, 0.0);
    }

    // 1. Growing degree-days (hourly method)
    let gdd = hourly_thermal_time(t_min, t_max, t_base, t_opt, pheno.t_ceiling);

    // 2. Vernalization (only affects pre-floral stages)
    let (vern_days, vern_f) = if pheno.vernalization_required
        && (state.current_stage as u8) <= (PhenologyStage::Juvenile as u8)
    {
        let dv = daily_vernalization(
            t_min,
            t_max,
            pheno.vern_base,
            pheno.vern_optimal,
            pheno.vern_ceiling,
        );
        let new_vern_days = state.vernalization_days + dv;
        let vf = vernalization_factor_from_days(
            new_vern_days,
            pheno.vern_requirement,
            pheno.vern_sensitivity,
        );
        (new_vern_days, vf)
    } else {
        (state.vernalization_days, 1.0)
    };

    // 3. Photoperiod (affects JUVENILE and FLORAL_INITIATION stages)
    let daylength = compute_photoperiod(pheno.latitude, day_of_year);
    let pp_f = if (state.current_stage as u8) >= (PhenologyStage::Juvenile as u8)
        && (state.current_stage as u8) <= (PhenologyStage::FloralInitiation as u8)
    {
        photoperiod_factor(
            daylength,
            pheno.critical_photoperiod,
            pheno.optimum_photoperiod,
            pheno.photoperiod_sensitivity,
            pheno.is_long_day,
        )
    } else {
        1.0
    };

    let effective_gdd = gdd * vern_f * pp_f;

    // Build intermediate state with updated vernalization days, then advance
    let mut intermediate = state.clone();
    intermediate.vernalization_days = vern_days;

    let new_state =
        advance_phenology(&intermediate, gdd, vern_f, pp_f, &pheno.stage_thresholds);

    (new_state, effective_gdd)
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_photoperiod_equinox_equator() {
        // Near equinox (day ~80) at equator: approximately 12h
        let dl = compute_photoperiod(0.0, 80);
        assert!(
            (dl - 12.0).abs() < 1.5,
            "equator equinox daylength: {dl}"
        );
    }

    #[test]
    fn test_photoperiod_polar_summer() {
        // High latitude in summer: near 24h
        let dl = compute_photoperiod(70.0, 172);
        assert!(dl > 22.0, "arctic summer daylength: {dl}");
    }

    #[test]
    fn test_photoperiod_polar_winter() {
        // High latitude in winter: short day (civil twilight adds ~1h each side)
        let dl = compute_photoperiod(70.0, 355);
        assert!(dl < 6.0, "arctic winter daylength: {dl}");
    }

    #[test]
    fn test_vernalization_triangular() {
        // At optimal temperature -> near 1.0 effectiveness
        let vd = daily_vernalization(4.0, 5.0, -1.0, 4.5, 15.0);
        assert!(vd > 0.9, "at optimum: {vd}");

        // Below base -> 0.0
        let vd = daily_vernalization(-5.0, -3.0, -1.0, 4.5, 15.0);
        assert_eq!(vd, 0.0);

        // Above ceiling -> 0.0
        let vd = daily_vernalization(16.0, 20.0, -1.0, 4.5, 15.0);
        assert_eq!(vd, 0.0);
    }

    #[test]
    fn test_vernalization_factor_accumulation() {
        // 40 days at optimal temperature = full vernalization
        let temps: Vec<f64> = vec![4.5; 40];
        let vf = vernalization_factor(&temps, -1.0, 4.5, 15.0, 40.0);
        assert!(
            (vf - 1.0).abs() < 0.01,
            "fully vernalized: {vf}"
        );

        // 20 days at optimal = half
        let temps: Vec<f64> = vec![4.5; 20];
        let vf = vernalization_factor(&temps, -1.0, 4.5, 15.0, 40.0);
        assert!(
            (vf - 0.5).abs() < 0.01,
            "half vernalized: {vf}"
        );

        // Zero requirement = always vernalized
        let vf = vernalization_factor(&[0.0], -1.0, 4.5, 15.0, 0.0);
        assert_eq!(vf, 1.0);
    }

    #[test]
    fn test_vernalization_factor_from_days() {
        // Fully vernalized with sensitivity 0.5
        let vf = vernalization_factor_from_days(40.0, 40.0, 0.5);
        assert!((vf - 1.0).abs() < 1e-10);

        // Unvernalized with sensitivity 0.5
        let vf = vernalization_factor_from_days(0.0, 40.0, 0.5);
        assert!((vf - 0.5).abs() < 1e-10);

        // Unvernalized with sensitivity 1.0
        let vf = vernalization_factor_from_days(0.0, 40.0, 1.0);
        assert!((vf - 0.0).abs() < 1e-10);
    }

    #[test]
    fn test_photoperiod_factor_long_day() {
        // Long-day plant at optimum daylength
        let pf = photoperiod_factor(14.0, 10.0, 14.0, 0.5, true);
        assert!((pf - 1.0).abs() < 1e-10);

        // At critical daylength with sensitivity 0.5
        let pf = photoperiod_factor(10.0, 10.0, 14.0, 0.5, true);
        assert!((pf - 0.5).abs() < 1e-10, "at critical: {pf}");
    }

    #[test]
    fn test_photoperiod_factor_short_day() {
        // Short-day plant below optimum -> full development
        let pf = photoperiod_factor(10.0, 14.0, 10.0, 0.5, false);
        assert!((pf - 1.0).abs() < 1e-10);

        // Short-day at critical (too long day)
        let pf = photoperiod_factor(14.0, 14.0, 10.0, 0.5, false);
        assert!((pf - 0.5).abs() < 1e-10, "short-day at critical: {pf}");
    }

    #[test]
    fn test_photoperiod_factor_day_neutral() {
        let pf = photoperiod_factor(8.0, 10.0, 14.0, 0.0, true);
        assert_eq!(pf, 1.0);
    }

    #[test]
    fn test_hourly_thermal_time_within_range() {
        let gdd = hourly_thermal_time(10.0, 30.0, 8.0, 25.0, 37.0);
        assert!(gdd > 0.0, "GDD should be positive: {gdd}");
        assert!(gdd < 22.0, "GDD should be bounded: {gdd}");
    }

    #[test]
    fn test_hourly_thermal_time_cold() {
        // All temperatures below base
        let gdd = hourly_thermal_time(0.0, 5.0, 8.0, 25.0, 37.0);
        assert_eq!(gdd, 0.0);
    }

    #[test]
    fn test_hourly_thermal_time_hot() {
        // Very hot: all temperatures above ceiling should give 0
        let gdd = hourly_thermal_time(38.0, 45.0, 8.0, 25.0, 37.0);
        assert_eq!(gdd, 0.0);
    }

    #[test]
    fn test_beta_temperature_response() {
        // At optimum -> 1.0
        let r = beta_temperature_response(25.0, 8.0, 25.0, 40.0);
        assert!(
            (r - 1.0).abs() < 1e-6,
            "at optimum: {r}"
        );

        // Below base -> 0.0
        let r = beta_temperature_response(5.0, 8.0, 25.0, 40.0);
        assert_eq!(r, 0.0);

        // Above ceiling -> 0.0
        let r = beta_temperature_response(42.0, 8.0, 25.0, 40.0);
        assert_eq!(r, 0.0);

        // Midpoint should be positive but less than 1
        let r = beta_temperature_response(16.0, 8.0, 25.0, 40.0);
        assert!(r > 0.0 && r < 1.0, "midpoint: {r}");
    }

    #[test]
    fn test_advance_phenology_stage_transition() {
        let thresholds = StageThresholds::default();
        let state = PhenologyState::default();

        // Accumulate enough thermal time to pass sowing -> emergence (120 dd)
        let mut s = state;
        for _ in 0..15 {
            s = advance_phenology(&s, 10.0, 1.0, 1.0, &thresholds);
        }
        // 15 * 10 = 150 > 120 threshold
        assert_eq!(s.current_stage, PhenologyStage::Emergence);
        assert_eq!(s.days_after_sowing, 15);
    }

    #[test]
    fn test_advance_phenology_maturity_stops() {
        let thresholds = StageThresholds::default();
        let state = PhenologyState {
            current_stage: PhenologyStage::PhysiologicalMaturity,
            ..Default::default()
        };
        let s = advance_phenology(&state, 100.0, 1.0, 1.0, &thresholds);
        assert_eq!(s.current_stage, PhenologyStage::PhysiologicalMaturity);
        assert_eq!(s.thermal_time_in_stage, 0.0); // no accumulation
    }

    #[test]
    fn test_step_phenology_integration() {
        let pheno = PhenologyParams::default();
        let state = PhenologyState::default();
        let (new_state, eff_gdd) =
            step_phenology(&state, 15.0, 30.0, 8.0, 25.0, &pheno, 100);
        assert!(eff_gdd > 0.0, "effective GDD: {eff_gdd}");
        assert_eq!(new_state.days_after_sowing, 1);
        assert_eq!(new_state.current_stage, PhenologyStage::Sowing);
    }

    #[test]
    fn test_phenology_stage_to_dvs() {
        let thresholds = StageThresholds::default();
        let state = PhenologyState {
            current_stage: PhenologyStage::GrainFilling,
            thermal_time_in_stage: 125.0, // half of 250
            ..Default::default()
        };
        let dvs = state.to_dvs(&thresholds);
        // GrainFilling at 50% progress -> 1.0 + 0.5 * 1.0 = 1.5
        assert!(
            (dvs - 1.5).abs() < 0.01,
            "grain filling DVS: {dvs}"
        );
    }
}
