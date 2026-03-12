//! Zonal statistics computation for raster data.
//!
//! Computes min, max, mean, standard deviation, percentiles,
//! and histogram for raster bands within defined zones.

use rayon::prelude::*;
use serde::{Deserialize, Serialize};

use crate::raster::{RasterBand, RasterError};

/// Statistical summary of a raster band or zone.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BandStatistics {
    pub min: f64,
    pub max: f64,
    pub mean: f64,
    pub median: f64,
    pub std_dev: f64,
    pub variance: f64,
    pub count: usize,
    pub valid_count: usize,
    pub sum: f64,
    pub percentile_5: f64,
    pub percentile_25: f64,
    pub percentile_75: f64,
    pub percentile_95: f64,
}

impl BandStatistics {
    /// Compute statistics from a slice of valid (non-nodata) values.
    pub fn compute(values: &[f64]) -> Option<Self> {
        if values.is_empty() {
            return None;
        }

        let mut sorted = values.to_vec();
        sorted.sort_by(|a, b| a.partial_cmp(b).unwrap_or(std::cmp::Ordering::Equal));

        let n = sorted.len();
        let sum: f64 = sorted.iter().sum();
        let mean = sum / n as f64;
        let variance = sorted.iter().map(|v| (v - mean).powi(2)).sum::<f64>() / n as f64;
        let std_dev = variance.sqrt();

        Some(BandStatistics {
            min: sorted[0],
            max: sorted[n - 1],
            mean,
            median: percentile_sorted(&sorted, 50.0),
            std_dev,
            variance,
            count: n,
            valid_count: n,
            sum,
            percentile_5: percentile_sorted(&sorted, 5.0),
            percentile_25: percentile_sorted(&sorted, 25.0),
            percentile_75: percentile_sorted(&sorted, 75.0),
            percentile_95: percentile_sorted(&sorted, 95.0),
        })
    }
}

/// Compute a percentile from a pre-sorted slice using linear interpolation.
fn percentile_sorted(sorted: &[f64], pct: f64) -> f64 {
    if sorted.is_empty() {
        return 0.0;
    }
    if sorted.len() == 1 {
        return sorted[0];
    }

    let pct = pct.clamp(0.0, 100.0);
    let rank = (pct / 100.0) * (sorted.len() - 1) as f64;
    let lower = rank.floor() as usize;
    let upper = rank.ceil() as usize;

    if lower == upper {
        sorted[lower]
    } else {
        let frac = rank - lower as f64;
        sorted[lower] * (1.0 - frac) + sorted[upper] * frac
    }
}

/// Compute statistics for an entire raster band, excluding nodata values.
pub fn compute_band_statistics(band: &RasterBand) -> Option<BandStatistics> {
    let values: Vec<f64> = band
        .data
        .iter()
        .enumerate()
        .filter_map(|(idx, &val)| {
            let row = idx / band.cols();
            let col = idx % band.cols();
            if band.is_nodata(row, col) {
                None
            } else {
                Some(val)
            }
        })
        .collect();

    BandStatistics::compute(&values)
}

/// Histogram of raster values.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Histogram {
    pub bins: Vec<HistogramBin>,
    pub total_count: usize,
}

/// A single histogram bin.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HistogramBin {
    pub lower: f64,
    pub upper: f64,
    pub count: usize,
    pub frequency: f64,
}

/// Compute a histogram for a raster band.
pub fn compute_histogram(band: &RasterBand, num_bins: usize) -> Option<Histogram> {
    let values: Vec<f64> = band
        .data
        .iter()
        .enumerate()
        .filter_map(|(idx, &val)| {
            let row = idx / band.cols();
            let col = idx % band.cols();
            if band.is_nodata(row, col) || val.is_nan() {
                None
            } else {
                Some(val)
            }
        })
        .collect();

    if values.is_empty() || num_bins == 0 {
        return None;
    }

    let min_val = values.iter().cloned().fold(f64::INFINITY, f64::min);
    let max_val = values.iter().cloned().fold(f64::NEG_INFINITY, f64::max);

    let range = max_val - min_val;
    let bin_width = if range.abs() < f64::EPSILON {
        1.0
    } else {
        range / num_bins as f64
    };

    let mut counts = vec![0usize; num_bins];
    for &val in &values {
        let bin_idx = if range.abs() < f64::EPSILON {
            0
        } else {
            let idx = ((val - min_val) / bin_width) as usize;
            idx.min(num_bins - 1)
        };
        counts[bin_idx] += 1;
    }

    let total = values.len();
    let bins: Vec<HistogramBin> = (0..num_bins)
        .map(|i| {
            let lower = min_val + i as f64 * bin_width;
            let upper = lower + bin_width;
            HistogramBin {
                lower,
                upper,
                count: counts[i],
                frequency: counts[i] as f64 / total as f64,
            }
        })
        .collect();

    Some(Histogram {
        bins,
        total_count: total,
    })
}

/// Zonal statistics: compute statistics for each zone defined by an integer mask.
///
/// `zones` is a raster where each pixel contains a zone ID (0 = no zone).
/// Returns a map of zone_id -> BandStatistics.
pub fn compute_zonal_statistics(
    band: &RasterBand,
    zones: &ndarray::Array2<u32>,
) -> Result<std::collections::HashMap<u32, BandStatistics>, RasterError> {
    let rows = band.rows();
    let cols = band.cols();

    if zones.nrows() != rows || zones.ncols() != cols {
        return Err(RasterError::DimensionMismatch {
            expected_rows: rows,
            expected_cols: cols,
            actual_rows: zones.nrows(),
            actual_cols: zones.ncols(),
        });
    }

    // Collect values per zone in parallel (per row, then merge)
    let row_maps: Vec<std::collections::HashMap<u32, Vec<f64>>> = (0..rows)
        .into_par_iter()
        .map(|r| {
            let mut map: std::collections::HashMap<u32, Vec<f64>> = std::collections::HashMap::new();
            for c in 0..cols {
                let zone_id = zones[[r, c]];
                if zone_id == 0 {
                    continue;
                }
                if !band.is_nodata(r, c) {
                    map.entry(zone_id).or_default().push(band.data[[r, c]]);
                }
            }
            map
        })
        .collect();

    // Merge row-level maps
    let mut merged: std::collections::HashMap<u32, Vec<f64>> = std::collections::HashMap::new();
    for row_map in row_maps {
        for (zone_id, values) in row_map {
            merged.entry(zone_id).or_default().extend(values);
        }
    }

    // Compute statistics for each zone
    let result: std::collections::HashMap<u32, BandStatistics> = merged
        .into_par_iter()
        .filter_map(|(zone_id, values)| {
            BandStatistics::compute(&values).map(|stats| (zone_id, stats))
        })
        .collect();

    Ok(result)
}

/// Compute statistics for a subset of pixels defined by a boolean mask.
pub fn compute_masked_statistics(
    band: &RasterBand,
    mask: &ndarray::Array2<bool>,
) -> Result<Option<BandStatistics>, RasterError> {
    let rows = band.rows();
    let cols = band.cols();

    if mask.nrows() != rows || mask.ncols() != cols {
        return Err(RasterError::DimensionMismatch {
            expected_rows: rows,
            expected_cols: cols,
            actual_rows: mask.nrows(),
            actual_cols: mask.ncols(),
        });
    }

    let values: Vec<f64> = (0..rows)
        .into_par_iter()
        .flat_map(|r| {
            let mut row_vals = Vec::new();
            for c in 0..cols {
                if mask[[r, c]] && !band.is_nodata(r, c) {
                    row_vals.push(band.data[[r, c]]);
                }
            }
            row_vals
        })
        .collect();

    Ok(BandStatistics::compute(&values))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_band_statistics() {
        let band = RasterBand::from_vec(
            vec![1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0],
            3,
            3,
            None,
        )
        .unwrap();

        let stats = compute_band_statistics(&band).unwrap();
        assert!((stats.min - 1.0).abs() < 1e-10);
        assert!((stats.max - 9.0).abs() < 1e-10);
        assert!((stats.mean - 5.0).abs() < 1e-10);
        assert!((stats.median - 5.0).abs() < 1e-10);
        assert_eq!(stats.valid_count, 9);
    }

    #[test]
    fn test_statistics_with_nodata() {
        let band = RasterBand::from_vec(
            vec![-9999.0, 2.0, 3.0, 4.0],
            2,
            2,
            Some(-9999.0),
        )
        .unwrap();

        let stats = compute_band_statistics(&band).unwrap();
        assert_eq!(stats.valid_count, 3);
        assert!((stats.min - 2.0).abs() < 1e-10);
        assert!((stats.mean - 3.0).abs() < 1e-10);
    }

    #[test]
    fn test_percentile() {
        let sorted = vec![1.0, 2.0, 3.0, 4.0, 5.0];
        assert!((percentile_sorted(&sorted, 0.0) - 1.0).abs() < 1e-10);
        assert!((percentile_sorted(&sorted, 50.0) - 3.0).abs() < 1e-10);
        assert!((percentile_sorted(&sorted, 100.0) - 5.0).abs() < 1e-10);
        assert!((percentile_sorted(&sorted, 25.0) - 2.0).abs() < 1e-10);
    }

    #[test]
    fn test_histogram() {
        let band = RasterBand::from_vec(
            vec![0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9],
            2,
            5,
            None,
        )
        .unwrap();

        let hist = compute_histogram(&band, 5).unwrap();
        assert_eq!(hist.total_count, 10);
        assert_eq!(hist.bins.len(), 5);
        let total_count: usize = hist.bins.iter().map(|b| b.count).sum();
        assert_eq!(total_count, 10);
    }

    #[test]
    fn test_zonal_statistics() {
        let band = RasterBand::from_vec(
            vec![1.0, 2.0, 3.0, 4.0],
            2,
            2,
            None,
        )
        .unwrap();

        let zones = ndarray::Array2::from_shape_vec(
            (2, 2),
            vec![1, 1, 2, 2],
        )
        .unwrap();

        let zonal = compute_zonal_statistics(&band, &zones).unwrap();
        assert_eq!(zonal.len(), 2);

        let zone1 = zonal.get(&1).unwrap();
        assert!((zone1.mean - 1.5).abs() < 1e-10);

        let zone2 = zonal.get(&2).unwrap();
        assert!((zone2.mean - 3.5).abs() < 1e-10);
    }

    #[test]
    fn test_masked_statistics() {
        let band = RasterBand::from_vec(
            vec![1.0, 2.0, 3.0, 4.0],
            2,
            2,
            None,
        )
        .unwrap();

        let mask = ndarray::Array2::from_shape_vec(
            (2, 2),
            vec![true, false, true, false],
        )
        .unwrap();

        let stats = compute_masked_statistics(&band, &mask).unwrap().unwrap();
        assert_eq!(stats.valid_count, 2);
        assert!((stats.mean - 2.0).abs() < 1e-10);
    }

    #[test]
    fn test_empty_statistics() {
        let result = BandStatistics::compute(&[]);
        assert!(result.is_none());
    }
}
