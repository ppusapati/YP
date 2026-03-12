//! EVI (Enhanced Vegetation Index) computation.
//!
//! EVI = G * ((NIR - RED) / (NIR + C1*RED - C2*BLUE + L))
//!
//! Standard coefficients (MODIS):
//!   G = 2.5, C1 = 6.0, C2 = 7.5, L = 1.0

use ndarray::Array2;
use rayon::prelude::*;

use crate::raster::{RasterBand, RasterError};

/// EVI computation parameters with standard MODIS coefficients.
#[derive(Debug, Clone)]
pub struct EviParams {
    /// Gain factor (G).
    pub gain: f64,
    /// Aerosol resistance coefficient for red (C1).
    pub c1: f64,
    /// Aerosol resistance coefficient for blue (C2).
    pub c2: f64,
    /// Canopy background adjustment (L).
    pub soil_adjustment: f64,
    /// Minimum valid reflectance.
    pub min_reflectance: f64,
    /// Maximum valid reflectance.
    pub max_reflectance: f64,
    /// Output nodata value.
    pub nodata_output: f64,
    /// Clamp EVI output to this range.
    pub output_min: f64,
    pub output_max: f64,
}

impl Default for EviParams {
    fn default() -> Self {
        Self {
            gain: 2.5,
            c1: 6.0,
            c2: 7.5,
            soil_adjustment: 1.0,
            min_reflectance: 0.0,
            max_reflectance: 1.0,
            nodata_output: -9999.0,
            output_min: -1.0,
            output_max: 1.0,
        }
    }
}

/// Compute EVI from NIR, RED, and BLUE bands.
///
/// EVI = G * ((NIR - RED) / (NIR + C1*RED - C2*BLUE + L))
pub fn compute_evi(
    nir: &RasterBand,
    red: &RasterBand,
    blue: &RasterBand,
    params: &EviParams,
) -> Result<RasterBand, RasterError> {
    let rows = nir.rows();
    let cols = nir.cols();

    if red.rows() != rows || red.cols() != cols {
        return Err(RasterError::DimensionMismatch {
            expected_rows: rows,
            expected_cols: cols,
            actual_rows: red.rows(),
            actual_cols: red.cols(),
        });
    }
    if blue.rows() != rows || blue.cols() != cols {
        return Err(RasterError::DimensionMismatch {
            expected_rows: rows,
            expected_cols: cols,
            actual_rows: blue.rows(),
            actual_cols: blue.cols(),
        });
    }

    let nir_data = &nir.data;
    let red_data = &red.data;
    let blue_data = &blue.data;

    let result_rows: Vec<Vec<f64>> = (0..rows)
        .into_par_iter()
        .map(|r| {
            let mut row_vals = Vec::with_capacity(cols);
            for c in 0..cols {
                let n = nir_data[[r, c]];
                let rd = red_data[[r, c]];
                let b = blue_data[[r, c]];

                if n.is_nan()
                    || rd.is_nan()
                    || b.is_nan()
                    || nir.is_nodata(r, c)
                    || red.is_nodata(r, c)
                    || blue.is_nodata(r, c)
                    || n < params.min_reflectance
                    || rd < params.min_reflectance
                    || b < params.min_reflectance
                    || n > params.max_reflectance
                    || rd > params.max_reflectance
                    || b > params.max_reflectance
                {
                    row_vals.push(params.nodata_output);
                    continue;
                }

                let denominator = n + params.c1 * rd - params.c2 * b + params.soil_adjustment;
                if denominator.abs() < f64::EPSILON {
                    row_vals.push(0.0);
                } else {
                    let evi = params.gain * (n - rd) / denominator;
                    row_vals.push(evi.clamp(params.output_min, params.output_max));
                }
            }
            row_vals
        })
        .collect();

    let flat: Vec<f64> = result_rows.into_iter().flatten().collect();
    let data = Array2::from_shape_vec((rows, cols), flat).map_err(|_| RasterError::EmptyRaster)?;
    Ok(RasterBand::new(data, Some(params.nodata_output)))
}

/// Compute EVI for a single pixel with default parameters.
pub fn evi_pixel(nir: f64, red: f64, blue: f64) -> f64 {
    evi_pixel_with_params(nir, red, blue, &EviParams::default())
}

/// Compute EVI for a single pixel with custom parameters.
pub fn evi_pixel_with_params(nir: f64, red: f64, blue: f64, params: &EviParams) -> f64 {
    let denominator = nir + params.c1 * red - params.c2 * blue + params.soil_adjustment;
    if denominator.abs() < f64::EPSILON {
        return 0.0;
    }
    let evi = params.gain * (nir - red) / denominator;
    evi.clamp(params.output_min, params.output_max)
}

/// Compute EVI2 (two-band EVI, no blue required).
///
/// EVI2 = 2.5 * (NIR - RED) / (NIR + 2.4 * RED + 1.0)
pub fn compute_evi2(
    nir: &RasterBand,
    red: &RasterBand,
    nodata_output: f64,
) -> Result<RasterBand, RasterError> {
    let rows = nir.rows();
    let cols = nir.cols();

    if red.rows() != rows || red.cols() != cols {
        return Err(RasterError::DimensionMismatch {
            expected_rows: rows,
            expected_cols: cols,
            actual_rows: red.rows(),
            actual_cols: red.cols(),
        });
    }

    let nir_data = &nir.data;
    let red_data = &red.data;

    let result_rows: Vec<Vec<f64>> = (0..rows)
        .into_par_iter()
        .map(|r| {
            let mut row_vals = Vec::with_capacity(cols);
            for c in 0..cols {
                let n = nir_data[[r, c]];
                let rd = red_data[[r, c]];

                if n.is_nan() || rd.is_nan() || nir.is_nodata(r, c) || red.is_nodata(r, c) {
                    row_vals.push(nodata_output);
                    continue;
                }

                let denominator = n + 2.4 * rd + 1.0;
                if denominator.abs() < f64::EPSILON {
                    row_vals.push(0.0);
                } else {
                    let evi2 = 2.5 * (n - rd) / denominator;
                    row_vals.push(evi2.clamp(-1.0, 1.0));
                }
            }
            row_vals
        })
        .collect();

    let flat: Vec<f64> = result_rows.into_iter().flatten().collect();
    let data = Array2::from_shape_vec((rows, cols), flat).map_err(|_| RasterError::EmptyRaster)?;
    Ok(RasterBand::new(data, Some(nodata_output)))
}

/// Compute SAVI (Soil Adjusted Vegetation Index).
///
/// SAVI = ((NIR - RED) / (NIR + RED + L)) * (1 + L)
/// where L is a soil brightness correction factor (typically 0.5).
pub fn compute_savi(
    nir: &RasterBand,
    red: &RasterBand,
    l_factor: f64,
    nodata_output: f64,
) -> Result<RasterBand, RasterError> {
    let rows = nir.rows();
    let cols = nir.cols();

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
                    let n = nir.data[[r, c]];
                    let rd = red.data[[r, c]];
                    if n.is_nan() || rd.is_nan() || nir.is_nodata(r, c) || red.is_nodata(r, c) {
                        return nodata_output;
                    }
                    let denom = n + rd + l_factor;
                    if denom.abs() < f64::EPSILON {
                        0.0
                    } else {
                        (((n - rd) / denom) * (1.0 + l_factor)).clamp(-1.0, 1.0)
                    }
                })
                .collect()
        })
        .collect();

    let flat: Vec<f64> = result_rows.into_iter().flatten().collect();
    let data = Array2::from_shape_vec((rows, cols), flat).map_err(|_| RasterError::EmptyRaster)?;
    Ok(RasterBand::new(data, Some(nodata_output)))
}

/// Compute SAVI for a single pixel.
pub fn savi_pixel(nir: f64, red: f64, l_factor: f64) -> f64 {
    let denom = nir + red + l_factor;
    if denom.abs() < f64::EPSILON {
        0.0
    } else {
        (((nir - red) / denom) * (1.0 + l_factor)).clamp(-1.0, 1.0)
    }
}

/// Compute MSAVI (Modified Soil Adjusted Vegetation Index).
///
/// MSAVI = (2*NIR + 1 - sqrt((2*NIR + 1)^2 - 8*(NIR - RED))) / 2
pub fn compute_msavi(
    nir: &RasterBand,
    red: &RasterBand,
    nodata_output: f64,
) -> Result<RasterBand, RasterError> {
    let rows = nir.rows();
    let cols = nir.cols();

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
                    let n = nir.data[[r, c]];
                    let rd = red.data[[r, c]];
                    if n.is_nan() || rd.is_nan() || nir.is_nodata(r, c) || red.is_nodata(r, c) {
                        return nodata_output;
                    }
                    msavi_pixel(n, rd)
                })
                .collect()
        })
        .collect();

    let flat: Vec<f64> = result_rows.into_iter().flatten().collect();
    let data = Array2::from_shape_vec((rows, cols), flat).map_err(|_| RasterError::EmptyRaster)?;
    Ok(RasterBand::new(data, Some(nodata_output)))
}

/// Compute MSAVI for a single pixel.
pub fn msavi_pixel(nir: f64, red: f64) -> f64 {
    let discriminant = (2.0 * nir + 1.0).powi(2) - 8.0 * (nir - red);
    if discriminant < 0.0 {
        return 0.0;
    }
    ((2.0 * nir + 1.0 - discriminant.sqrt()) / 2.0).clamp(-1.0, 1.0)
}

/// Compute NDRE (Normalized Difference Red Edge).
///
/// NDRE = (NIR - RED_EDGE) / (NIR + RED_EDGE)
/// Red Edge is typically Sentinel-2 Band 5 (~705nm).
pub fn compute_ndre(
    nir: &RasterBand,
    red_edge: &RasterBand,
    nodata_output: f64,
) -> Result<RasterBand, RasterError> {
    let rows = nir.rows();
    let cols = nir.cols();

    if red_edge.rows() != rows || red_edge.cols() != cols {
        return Err(RasterError::DimensionMismatch {
            expected_rows: rows,
            expected_cols: cols,
            actual_rows: red_edge.rows(),
            actual_cols: red_edge.cols(),
        });
    }

    let result_rows: Vec<Vec<f64>> = (0..rows)
        .into_par_iter()
        .map(|r| {
            (0..cols)
                .map(|c| {
                    let n = nir.data[[r, c]];
                    let re = red_edge.data[[r, c]];
                    if n.is_nan() || re.is_nan() || nir.is_nodata(r, c) || red_edge.is_nodata(r, c) {
                        return nodata_output;
                    }
                    let sum = n + re;
                    if sum.abs() < f64::EPSILON {
                        0.0
                    } else {
                        ((n - re) / sum).clamp(-1.0, 1.0)
                    }
                })
                .collect()
        })
        .collect();

    let flat: Vec<f64> = result_rows.into_iter().flatten().collect();
    let data = Array2::from_shape_vec((rows, cols), flat).map_err(|_| RasterError::EmptyRaster)?;
    Ok(RasterBand::new(data, Some(nodata_output)))
}

/// Compute GNDVI (Green Normalized Difference Vegetation Index).
///
/// GNDVI = (NIR - GREEN) / (NIR + GREEN)
pub fn compute_gndvi(
    nir: &RasterBand,
    green: &RasterBand,
    nodata_output: f64,
) -> Result<RasterBand, RasterError> {
    let rows = nir.rows();
    let cols = nir.cols();

    if green.rows() != rows || green.cols() != cols {
        return Err(RasterError::DimensionMismatch {
            expected_rows: rows,
            expected_cols: cols,
            actual_rows: green.rows(),
            actual_cols: green.cols(),
        });
    }

    let result_rows: Vec<Vec<f64>> = (0..rows)
        .into_par_iter()
        .map(|r| {
            (0..cols)
                .map(|c| {
                    let n = nir.data[[r, c]];
                    let g = green.data[[r, c]];
                    if n.is_nan() || g.is_nan() || nir.is_nodata(r, c) || green.is_nodata(r, c) {
                        return nodata_output;
                    }
                    let sum = n + g;
                    if sum.abs() < f64::EPSILON {
                        0.0
                    } else {
                        ((n - g) / sum).clamp(-1.0, 1.0)
                    }
                })
                .collect()
        })
        .collect();

    let flat: Vec<f64> = result_rows.into_iter().flatten().collect();
    let data = Array2::from_shape_vec((rows, cols), flat).map_err(|_| RasterError::EmptyRaster)?;
    Ok(RasterBand::new(data, Some(nodata_output)))
}

/// Compute GNDVI for a single pixel.
pub fn gndvi_pixel(nir: f64, green: f64) -> f64 {
    let sum = nir + green;
    if sum.abs() < f64::EPSILON {
        0.0
    } else {
        ((nir - green) / sum).clamp(-1.0, 1.0)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn make_band(values: Vec<f64>, rows: usize, cols: usize) -> RasterBand {
        RasterBand::from_vec(values, rows, cols, None).unwrap()
    }

    #[test]
    fn test_evi_basic() {
        // EVI = 2.5 * (0.8 - 0.2) / (0.8 + 6*0.2 - 7.5*0.1 + 1.0)
        // = 2.5 * 0.6 / (0.8 + 1.2 - 0.75 + 1.0)
        // = 1.5 / 2.25 = 0.6666...
        let nir = make_band(vec![0.8], 1, 1);
        let red = make_band(vec![0.2], 1, 1);
        let blue = make_band(vec![0.1], 1, 1);
        let result = compute_evi(&nir, &red, &blue, &EviParams::default()).unwrap();
        let expected = 2.5 * 0.6 / (0.8 + 6.0 * 0.2 - 7.5 * 0.1 + 1.0);
        assert!((result.data[[0, 0]] - expected).abs() < 1e-10);
    }

    #[test]
    fn test_evi_pixel() {
        let expected = 2.5 * (0.8 - 0.2) / (0.8 + 6.0 * 0.2 - 7.5 * 0.1 + 1.0);
        assert!((evi_pixel(0.8, 0.2, 0.1) - expected).abs() < 1e-10);
    }

    #[test]
    fn test_evi_clamping() {
        // With extreme values, should clamp to [-1, 1]
        let params = EviParams::default();
        let result = evi_pixel_with_params(1.0, 0.0, 0.0, &params);
        assert!(result >= params.output_min && result <= params.output_max);
    }

    #[test]
    fn test_evi2() {
        let nir = make_band(vec![0.8], 1, 1);
        let red = make_band(vec![0.2], 1, 1);
        let result = compute_evi2(&nir, &red, -9999.0).unwrap();
        let expected = 2.5 * (0.8 - 0.2) / (0.8 + 2.4 * 0.2 + 1.0);
        assert!((result.data[[0, 0]] - expected).abs() < 1e-10);
    }

    #[test]
    fn test_evi_nodata() {
        let nir = RasterBand::from_vec(vec![-9999.0], 1, 1, Some(-9999.0)).unwrap();
        let red = make_band(vec![0.2], 1, 1);
        let blue = make_band(vec![0.1], 1, 1);
        let result = compute_evi(&nir, &red, &blue, &EviParams::default()).unwrap();
        assert_eq!(result.data[[0, 0]], -9999.0);
    }

    #[test]
    fn test_evi_dimension_mismatch() {
        let nir = make_band(vec![0.8; 4], 2, 2);
        let red = make_band(vec![0.2; 6], 2, 3);
        let blue = make_band(vec![0.1; 4], 2, 2);
        assert!(compute_evi(&nir, &red, &blue, &EviParams::default()).is_err());
    }

    #[test]
    fn test_savi() {
        let nir = make_band(vec![0.8], 1, 1);
        let red = make_band(vec![0.2], 1, 1);
        let result = compute_savi(&nir, &red, 0.5, -9999.0).unwrap();
        let expected = ((0.8 - 0.2) / (0.8 + 0.2 + 0.5)) * 1.5;
        assert!((result.data[[0, 0]] - expected).abs() < 1e-10);
    }

    #[test]
    fn test_savi_pixel() {
        let expected = ((0.8 - 0.2) / (0.8 + 0.2 + 0.5)) * 1.5;
        assert!((savi_pixel(0.8, 0.2, 0.5) - expected).abs() < 1e-10);
    }

    #[test]
    fn test_msavi() {
        let nir = make_band(vec![0.8], 1, 1);
        let red = make_band(vec![0.2], 1, 1);
        let result = compute_msavi(&nir, &red, -9999.0).unwrap();
        assert!(result.data[[0, 0]] > 0.0);
        assert!(result.data[[0, 0]] <= 1.0);
    }

    #[test]
    fn test_ndre() {
        let nir = make_band(vec![0.8], 1, 1);
        let red_edge = make_band(vec![0.3], 1, 1);
        let result = compute_ndre(&nir, &red_edge, -9999.0).unwrap();
        let expected = (0.8 - 0.3) / (0.8 + 0.3);
        assert!((result.data[[0, 0]] - expected).abs() < 1e-10);
    }

    #[test]
    fn test_gndvi() {
        let nir = make_band(vec![0.8], 1, 1);
        let green = make_band(vec![0.3], 1, 1);
        let result = compute_gndvi(&nir, &green, -9999.0).unwrap();
        let expected = (0.8 - 0.3) / (0.8 + 0.3);
        assert!((result.data[[0, 0]] - expected).abs() < 1e-10);
    }

    #[test]
    fn test_gndvi_pixel() {
        let expected = (0.8 - 0.3) / (0.8 + 0.3);
        assert!((gndvi_pixel(0.8, 0.3) - expected).abs() < 1e-10);
    }
}
