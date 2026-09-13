//! Leaf Area Index (LAI) estimation from optical vegetation indices.
//!
//! Uses the SAVI-based exponential relationship of Clevers (1989) /
//! Choudhury et al. (1994):
//!
//! ```text
//! LAI = -ln((0.69 - SAVI) / 0.59) / 0.91
//! ```
//!
//! which is widely used for row crops when no calibrated radiative-transfer
//! inversion is available. Values are clamped to a physically plausible range.

use ndarray::Array2;
use rayon::prelude::*;

use crate::evi::savi_pixel;
use crate::raster::{RasterBand, RasterError};

/// Parameters for LAI estimation.
#[derive(Debug, Clone)]
pub struct LaiParams {
    /// SAVI soil adjustment factor (0.5 for intermediate canopy cover).
    pub soil_factor: f64,
    /// Upper bound for LAI (dense broadleaf canopies rarely exceed ~8).
    pub max_lai: f64,
    /// Value written for nodata pixels.
    pub nodata_output: f64,
}

impl Default for LaiParams {
    fn default() -> Self {
        Self {
            soil_factor: 0.5,
            max_lai: 8.0,
            nodata_output: -9999.0,
        }
    }
}

const SAVI_ASYMPTOTE: f64 = 0.69;
const SAVI_SCALE: f64 = 0.59;
const EXTINCTION: f64 = 0.91;

/// Estimate LAI for a single SAVI value.
pub fn lai_from_savi(savi: f64, max_lai: f64) -> f64 {
    if savi.is_nan() {
        return f64::NAN;
    }
    // At or beyond the asymptote the canopy is effectively closed.
    if savi >= SAVI_ASYMPTOTE - 1e-9 {
        return max_lai;
    }
    let ratio = (SAVI_ASYMPTOTE - savi) / SAVI_SCALE;
    if ratio >= 1.0 {
        return 0.0;
    }
    (-ratio.ln() / EXTINCTION).clamp(0.0, max_lai)
}

/// Estimate LAI for one pixel from NIR and RED reflectance.
pub fn lai_pixel(nir: f64, red: f64, params: &LaiParams) -> f64 {
    let savi = savi_pixel(nir, red, params.soil_factor);
    lai_from_savi(savi, params.max_lai)
}

/// Compute an LAI raster from NIR and RED bands.
pub fn compute_lai(
    nir: &RasterBand,
    red: &RasterBand,
    params: &LaiParams,
) -> Result<RasterBand, RasterError> {
    let rows = nir.rows();
    let cols = nir.cols();
    if rows == 0 || cols == 0 {
        return Err(RasterError::EmptyRaster);
    }
    if red.rows() != rows || red.cols() != cols {
        return Err(RasterError::DimensionMismatch {
            expected_rows: rows,
            expected_cols: cols,
            actual_rows: red.rows(),
            actual_cols: red.cols(),
        });
    }

    let result_rows: Vec<Vec<f64>> = (0..rows)
        .into_par_iter()
        .map(|r| {
            (0..cols)
                .map(|c| {
                    if nir.is_nodata(r, c) || red.is_nodata(r, c) {
                        return params.nodata_output;
                    }
                    let v = lai_pixel(nir.data[[r, c]], red.data[[r, c]], params);
                    if v.is_nan() {
                        params.nodata_output
                    } else {
                        v
                    }
                })
                .collect()
        })
        .collect();

    let flat: Vec<f64> = result_rows.into_iter().flatten().collect();
    let data = Array2::from_shape_vec((rows, cols), flat).map_err(|_| RasterError::EmptyRaster)?;
    Ok(RasterBand::new(data, Some(params.nodata_output)))
}

#[cfg(test)]
mod tests {
    use super::*;

    fn make_band(values: Vec<f64>, rows: usize, cols: usize) -> RasterBand {
        RasterBand::from_vec(values, rows, cols, Some(-9999.0)).unwrap()
    }

    #[test]
    fn test_lai_from_savi_monotonic() {
        let a = lai_from_savi(0.1, 8.0);
        let b = lai_from_savi(0.3, 8.0);
        let c = lai_from_savi(0.5, 8.0);
        assert!(a < b && b < c, "LAI must increase with SAVI: {a} {b} {c}");
    }

    #[test]
    fn test_lai_from_savi_bounds() {
        assert_eq!(lai_from_savi(0.0, 8.0), 0.0);
        assert_eq!(lai_from_savi(-0.2, 8.0), 0.0);
        assert_eq!(lai_from_savi(0.69, 8.0), 8.0);
        assert_eq!(lai_from_savi(0.9, 8.0), 8.0);
        assert!(lai_from_savi(f64::NAN, 8.0).is_nan());
    }

    #[test]
    fn test_lai_from_savi_reference_value() {
        // SAVI = 0.5 -> ratio = 0.19/0.59 = 0.322 -> LAI = -ln(0.322)/0.91 ≈ 1.245
        let lai = lai_from_savi(0.5, 8.0);
        assert!((lai - 1.245).abs() < 0.01, "got {lai}");
    }

    #[test]
    fn test_compute_lai_raster() {
        let nir = make_band(vec![0.8, 0.5, 0.3, -9999.0], 2, 2);
        let red = make_band(vec![0.1, 0.2, 0.25, 0.1], 2, 2);
        let lai = compute_lai(&nir, &red, &LaiParams::default()).unwrap();

        assert!(lai.data[[0, 0]] > lai.data[[0, 1]]);
        assert!(lai.data[[0, 1]] > lai.data[[1, 0]]);
        assert!(lai.data[[1, 0]] >= 0.0);
        assert!(lai.is_nodata(1, 1), "nodata must propagate");
    }

    #[test]
    fn test_compute_lai_dimension_mismatch() {
        let nir = make_band(vec![0.8; 4], 2, 2);
        let red = make_band(vec![0.1; 6], 2, 3);
        assert!(matches!(
            compute_lai(&nir, &red, &LaiParams::default()),
            Err(RasterError::DimensionMismatch { .. })
        ));
    }
}
