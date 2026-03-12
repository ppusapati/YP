//! Detect crop stress from temporal NDVI changes.
//!
//! Analyzes time series of NDVI values to identify stress events,
//! decline trends, and anomalous drops.

use rayon::prelude::*;
use serde::{Deserialize, Serialize};

use crate::raster::{RasterBand, RasterError};

/// A timestamped NDVI observation.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct NdviObservation {
    /// Days since epoch or start of season.
    pub day: u32,
    /// NDVI value.
    pub value: f64,
}

/// Stress detection parameters.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StressParams {
    /// Minimum NDVI decline between consecutive observations to flag as stress.
    pub decline_threshold: f64,
    /// Number of consecutive declining observations to confirm a stress event.
    pub min_consecutive_declines: usize,
    /// NDVI absolute threshold below which the crop is considered stressed.
    pub absolute_stress_threshold: f64,
    /// Z-score threshold for anomaly detection.
    pub anomaly_z_threshold: f64,
    /// Minimum number of observations for reliable trend analysis.
    pub min_observations: usize,
}

impl Default for StressParams {
    fn default() -> Self {
        Self {
            decline_threshold: 0.05,
            min_consecutive_declines: 2,
            absolute_stress_threshold: 0.25,
            anomaly_z_threshold: 2.0,
            min_observations: 4,
        }
    }
}

/// Type of stress event detected.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum StressType {
    /// Rapid decline in NDVI.
    RapidDecline,
    /// Sustained declining trend.
    SustainedDecline,
    /// NDVI dropped below absolute threshold.
    BelowThreshold,
    /// Anomalous drop (z-score based).
    AnomalousDrop,
    /// Recovery after stress.
    Recovery,
}

/// A detected stress event.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StressEvent {
    pub stress_type: StressType,
    /// Day at which the stress was first detected.
    pub onset_day: u32,
    /// Duration in days (if applicable).
    pub duration_days: Option<u32>,
    /// Magnitude of NDVI change.
    pub magnitude: f64,
    /// Severity score (0.0 - 1.0).
    pub severity: f64,
}

/// Pixel-level stress analysis result.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PixelStressResult {
    pub events: Vec<StressEvent>,
    pub trend_slope: f64,
    pub mean_ndvi: f64,
    pub min_ndvi: f64,
    pub max_ndvi: f64,
    pub ndvi_range: f64,
    pub is_currently_stressed: bool,
}

/// Compute the linear trend slope of a time series using least-squares regression.
fn linear_trend_slope(observations: &[NdviObservation]) -> f64 {
    let n = observations.len() as f64;
    if n < 2.0 {
        return 0.0;
    }

    let sum_x: f64 = observations.iter().map(|o| o.day as f64).sum();
    let sum_y: f64 = observations.iter().map(|o| o.value).sum();
    let sum_xy: f64 = observations.iter().map(|o| o.day as f64 * o.value).sum();
    let sum_x2: f64 = observations.iter().map(|o| (o.day as f64).powi(2)).sum();

    let denominator = n * sum_x2 - sum_x * sum_x;
    if denominator.abs() < f64::EPSILON {
        return 0.0;
    }
    (n * sum_xy - sum_x * sum_y) / denominator
}

/// Compute mean and standard deviation of NDVI values.
fn mean_std(values: &[f64]) -> (f64, f64) {
    if values.is_empty() {
        return (0.0, 0.0);
    }
    let n = values.len() as f64;
    let mean = values.iter().sum::<f64>() / n;
    let variance = values.iter().map(|v| (v - mean).powi(2)).sum::<f64>() / n;
    (mean, variance.sqrt())
}

/// Detect stress events in a pixel's NDVI time series.
pub fn detect_pixel_stress(
    observations: &[NdviObservation],
    params: &StressParams,
) -> PixelStressResult {
    let valid: Vec<&NdviObservation> = observations
        .iter()
        .filter(|o| !o.value.is_nan() && o.value > -1.0)
        .collect();

    if valid.len() < params.min_observations {
        return PixelStressResult {
            events: Vec::new(),
            trend_slope: 0.0,
            mean_ndvi: 0.0,
            min_ndvi: 0.0,
            max_ndvi: 0.0,
            ndvi_range: 0.0,
            is_currently_stressed: false,
        };
    }

    let values: Vec<f64> = valid.iter().map(|o| o.value).collect();
    let (mean_val, std_val) = mean_std(&values);
    let min_val = values.iter().cloned().fold(f64::INFINITY, f64::min);
    let max_val = values.iter().cloned().fold(f64::NEG_INFINITY, f64::max);

    let valid_obs: Vec<NdviObservation> = valid.iter().map(|o| (*o).clone()).collect();
    let trend_slope = linear_trend_slope(&valid_obs);

    let mut events = Vec::new();

    // Detect rapid declines
    for i in 1..valid.len() {
        let decline = valid[i - 1].value - valid[i].value;
        if decline > params.decline_threshold * 2.0 {
            let severity = (decline / max_val).clamp(0.0, 1.0);
            events.push(StressEvent {
                stress_type: StressType::RapidDecline,
                onset_day: valid[i].day,
                duration_days: Some(valid[i].day.saturating_sub(valid[i - 1].day)),
                magnitude: decline,
                severity,
            });
        }
    }

    // Detect sustained decline
    let mut consecutive_declines = 0usize;
    let mut decline_start = 0usize;
    for i in 1..valid.len() {
        let decline = valid[i - 1].value - valid[i].value;
        if decline > params.decline_threshold {
            if consecutive_declines == 0 {
                decline_start = i - 1;
            }
            consecutive_declines += 1;
        } else {
            if consecutive_declines >= params.min_consecutive_declines {
                let total_decline = valid[decline_start].value - valid[i - 1].value;
                let severity = (total_decline / max_val).clamp(0.0, 1.0);
                events.push(StressEvent {
                    stress_type: StressType::SustainedDecline,
                    onset_day: valid[decline_start].day,
                    duration_days: Some(valid[i - 1].day.saturating_sub(valid[decline_start].day)),
                    magnitude: total_decline,
                    severity,
                });
            }
            consecutive_declines = 0;
        }
    }
    // Handle case where sustained decline extends to the last observation.
    if consecutive_declines >= params.min_consecutive_declines {
        let last = valid.len() - 1;
        let total_decline = valid[decline_start].value - valid[last].value;
        let severity = (total_decline / max_val).clamp(0.0, 1.0);
        events.push(StressEvent {
            stress_type: StressType::SustainedDecline,
            onset_day: valid[decline_start].day,
            duration_days: Some(valid[last].day.saturating_sub(valid[decline_start].day)),
            magnitude: total_decline,
            severity,
        });
    }

    // Detect below-threshold periods
    for obs in &valid {
        if obs.value < params.absolute_stress_threshold {
            let severity = (1.0 - obs.value / params.absolute_stress_threshold).clamp(0.0, 1.0);
            events.push(StressEvent {
                stress_type: StressType::BelowThreshold,
                onset_day: obs.day,
                duration_days: None,
                magnitude: params.absolute_stress_threshold - obs.value,
                severity,
            });
        }
    }

    // Detect anomalous drops via z-score
    if std_val > f64::EPSILON {
        for obs in &valid {
            let z_score = (mean_val - obs.value) / std_val;
            if z_score > params.anomaly_z_threshold {
                let severity = (z_score / (params.anomaly_z_threshold * 2.0)).clamp(0.0, 1.0);
                events.push(StressEvent {
                    stress_type: StressType::AnomalousDrop,
                    onset_day: obs.day,
                    duration_days: None,
                    magnitude: mean_val - obs.value,
                    severity,
                });
            }
        }
    }

    // Detect recovery events (significant increase after decline)
    for i in 1..valid.len() {
        let increase = valid[i].value - valid[i - 1].value;
        if increase > params.decline_threshold * 2.0 && valid[i - 1].value < params.absolute_stress_threshold {
            let severity = (increase / max_val).clamp(0.0, 1.0);
            events.push(StressEvent {
                stress_type: StressType::Recovery,
                onset_day: valid[i].day,
                duration_days: Some(valid[i].day.saturating_sub(valid[i - 1].day)),
                magnitude: increase,
                severity,
            });
        }
    }

    let is_currently_stressed = valid
        .last()
        .map(|o| o.value < params.absolute_stress_threshold)
        .unwrap_or(false);

    PixelStressResult {
        events,
        trend_slope,
        mean_ndvi: mean_val,
        min_ndvi: min_val,
        max_ndvi: max_val,
        ndvi_range: max_val - min_val,
        is_currently_stressed,
    }
}

/// Detect stress across an entire raster time series.
///
/// Each element in `ndvi_series` is one temporal observation.
/// Returns a raster of severity values (0.0 = no stress, 1.0 = maximum stress).
pub fn detect_raster_stress(
    ndvi_series: &[(u32, &RasterBand)],
    params: &StressParams,
) -> Result<RasterBand, RasterError> {
    if ndvi_series.is_empty() {
        return Err(RasterError::EmptyRaster);
    }

    let rows = ndvi_series[0].1.rows();
    let cols = ndvi_series[0].1.cols();

    // Verify all bands have the same dimensions
    for (_, band) in ndvi_series.iter().skip(1) {
        if band.rows() != rows || band.cols() != cols {
            return Err(RasterError::DimensionMismatch {
                expected_rows: rows,
                expected_cols: cols,
                actual_rows: band.rows(),
                actual_cols: band.cols(),
            });
        }
    }

    let result_rows: Vec<Vec<f64>> = (0..rows)
        .into_par_iter()
        .map(|r| {
            let mut row_vals = Vec::with_capacity(cols);
            for c in 0..cols {
                let observations: Vec<NdviObservation> = ndvi_series
                    .iter()
                    .map(|(day, band)| NdviObservation {
                        day: *day,
                        value: band.data[[r, c]],
                    })
                    .collect();

                let result = detect_pixel_stress(&observations, params);
                let max_severity = result
                    .events
                    .iter()
                    .map(|e| e.severity)
                    .fold(0.0f64, f64::max);
                row_vals.push(max_severity);
            }
            row_vals
        })
        .collect();

    let flat: Vec<f64> = result_rows.into_iter().flatten().collect();
    let data = ndarray::Array2::from_shape_vec((rows, cols), flat)
        .map_err(|_| RasterError::EmptyRaster)?;
    Ok(RasterBand::new(data, None))
}

/// Summary of stress detection across a field.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FieldStressSummary {
    pub total_pixels: usize,
    pub stressed_pixels: usize,
    pub stress_fraction: f64,
    pub mean_severity: f64,
    pub max_severity: f64,
    pub dominant_stress_type: Option<StressType>,
}

/// Compute a summary of stress across a severity raster.
pub fn summarize_stress(severity_band: &RasterBand, threshold: f64) -> FieldStressSummary {
    let total = severity_band.rows() * severity_band.cols();
    let mut stressed = 0usize;
    let mut sum = 0.0;
    let mut max_sev = 0.0f64;

    for &val in severity_band.data.iter() {
        if val > threshold {
            stressed += 1;
        }
        sum += val;
        if val > max_sev {
            max_sev = val;
        }
    }

    FieldStressSummary {
        total_pixels: total,
        stressed_pixels: stressed,
        stress_fraction: if total > 0 { stressed as f64 / total as f64 } else { 0.0 },
        mean_severity: if total > 0 { sum / total as f64 } else { 0.0 },
        max_severity: max_sev,
        dominant_stress_type: None, // Would need full event data to determine
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_linear_trend_slope_positive() {
        let obs = vec![
            NdviObservation { day: 0, value: 0.3 },
            NdviObservation { day: 10, value: 0.4 },
            NdviObservation { day: 20, value: 0.5 },
            NdviObservation { day: 30, value: 0.6 },
        ];
        let slope = linear_trend_slope(&obs);
        assert!(slope > 0.0);
        assert!((slope - 0.01).abs() < 1e-10);
    }

    #[test]
    fn test_linear_trend_slope_negative() {
        let obs = vec![
            NdviObservation { day: 0, value: 0.8 },
            NdviObservation { day: 10, value: 0.6 },
            NdviObservation { day: 20, value: 0.4 },
            NdviObservation { day: 30, value: 0.2 },
        ];
        let slope = linear_trend_slope(&obs);
        assert!(slope < 0.0);
        assert!((slope - (-0.02)).abs() < 1e-10);
    }

    #[test]
    fn test_detect_rapid_decline() {
        let obs = vec![
            NdviObservation { day: 0, value: 0.8 },
            NdviObservation { day: 10, value: 0.7 },
            NdviObservation { day: 20, value: 0.3 }, // Rapid drop
            NdviObservation { day: 30, value: 0.3 },
        ];
        let result = detect_pixel_stress(&obs, &StressParams::default());
        let rapid = result
            .events
            .iter()
            .any(|e| e.stress_type == StressType::RapidDecline);
        assert!(rapid);
    }

    #[test]
    fn test_detect_sustained_decline() {
        let obs = vec![
            NdviObservation { day: 0, value: 0.8 },
            NdviObservation { day: 10, value: 0.7 },
            NdviObservation { day: 20, value: 0.6 },
            NdviObservation { day: 30, value: 0.5 },
        ];
        let result = detect_pixel_stress(&obs, &StressParams::default());
        let sustained = result
            .events
            .iter()
            .any(|e| e.stress_type == StressType::SustainedDecline);
        assert!(sustained);
    }

    #[test]
    fn test_detect_below_threshold() {
        let obs = vec![
            NdviObservation { day: 0, value: 0.5 },
            NdviObservation { day: 10, value: 0.3 },
            NdviObservation { day: 20, value: 0.1 }, // Below default threshold 0.25
            NdviObservation { day: 30, value: 0.2 },
        ];
        let result = detect_pixel_stress(&obs, &StressParams::default());
        let below = result
            .events
            .iter()
            .any(|e| e.stress_type == StressType::BelowThreshold);
        assert!(below);
    }

    #[test]
    fn test_currently_stressed() {
        let obs = vec![
            NdviObservation { day: 0, value: 0.8 },
            NdviObservation { day: 10, value: 0.6 },
            NdviObservation { day: 20, value: 0.4 },
            NdviObservation { day: 30, value: 0.15 },
        ];
        let result = detect_pixel_stress(&obs, &StressParams::default());
        assert!(result.is_currently_stressed);
    }

    #[test]
    fn test_not_stressed() {
        let obs = vec![
            NdviObservation { day: 0, value: 0.6 },
            NdviObservation { day: 10, value: 0.65 },
            NdviObservation { day: 20, value: 0.7 },
            NdviObservation { day: 30, value: 0.72 },
        ];
        let result = detect_pixel_stress(&obs, &StressParams::default());
        assert!(!result.is_currently_stressed);
        assert!(result.trend_slope > 0.0);
    }

    #[test]
    fn test_insufficient_observations() {
        let obs = vec![
            NdviObservation { day: 0, value: 0.1 },
        ];
        let result = detect_pixel_stress(&obs, &StressParams::default());
        assert!(result.events.is_empty());
    }

    #[test]
    fn test_raster_stress_detection() {
        let b1 = RasterBand::from_vec(vec![0.8, 0.7, 0.6, 0.5], 2, 2, None).unwrap();
        let b2 = RasterBand::from_vec(vec![0.7, 0.6, 0.5, 0.4], 2, 2, None).unwrap();
        let b3 = RasterBand::from_vec(vec![0.6, 0.5, 0.4, 0.3], 2, 2, None).unwrap();
        let b4 = RasterBand::from_vec(vec![0.5, 0.4, 0.3, 0.2], 2, 2, None).unwrap();

        let series: Vec<(u32, &RasterBand)> = vec![
            (0, &b1), (10, &b2), (20, &b3), (30, &b4),
        ];
        let severity = detect_raster_stress(&series, &StressParams::default()).unwrap();
        assert_eq!(severity.rows(), 2);
        assert_eq!(severity.cols(), 2);
    }

    #[test]
    fn test_stress_summary() {
        let band = RasterBand::from_vec(vec![0.0, 0.5, 0.8, 0.3], 2, 2, None).unwrap();
        let summary = summarize_stress(&band, 0.2);
        assert_eq!(summary.total_pixels, 4);
        assert_eq!(summary.stressed_pixels, 3);
        assert!((summary.max_severity - 0.8).abs() < 1e-10);
    }
}
