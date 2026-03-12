//! NDVI (Normalized Difference Vegetation Index) computation.
//!
//! NDVI = (NIR - RED) / (NIR + RED)
//! Range: -1.0 to 1.0
//! Values > 0.2 indicate vegetation; > 0.6 indicate dense, healthy vegetation.

use ndarray::Array2;
use rayon::prelude::*;

use crate::raster::{RasterBand, RasterError};

/// NDVI computation parameters.
#[derive(Debug, Clone)]
pub struct NdviParams {
    /// Minimum valid reflectance value (values below are treated as nodata).
    pub min_reflectance: f64,
    /// Maximum valid reflectance value.
    pub max_reflectance: f64,
    /// Output nodata value for invalid pixels.
    pub nodata_output: f64,
}

impl Default for NdviParams {
    fn default() -> Self {
        Self {
            min_reflectance: 0.0,
            max_reflectance: 1.0,
            nodata_output: -9999.0,
        }
    }
}

/// Compute NDVI from NIR and RED bands.
///
/// NDVI = (NIR - RED) / (NIR + RED)
///
/// Returns a new `RasterBand` with NDVI values in [-1.0, 1.0],
/// or `nodata_output` for invalid pixels.
pub fn compute_ndvi(
    nir: &RasterBand,
    red: &RasterBand,
    params: &NdviParams,
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

    // Process rows in parallel
    let result_rows: Vec<Vec<f64>> = (0..rows)
        .into_par_iter()
        .map(|r| {
            let mut row_vals = Vec::with_capacity(cols);
            for c in 0..cols {
                let n = nir_data[[r, c]];
                let rd = red_data[[r, c]];

                if n.is_nan()
                    || rd.is_nan()
                    || nir.is_nodata(r, c)
                    || red.is_nodata(r, c)
                    || n < params.min_reflectance
                    || rd < params.min_reflectance
                    || n > params.max_reflectance
                    || rd > params.max_reflectance
                {
                    row_vals.push(params.nodata_output);
                    continue;
                }

                let sum = n + rd;
                if sum.abs() < f64::EPSILON {
                    row_vals.push(0.0);
                } else {
                    let ndvi = (n - rd) / sum;
                    row_vals.push(ndvi.clamp(-1.0, 1.0));
                }
            }
            row_vals
        })
        .collect();

    let flat: Vec<f64> = result_rows.into_iter().flatten().collect();
    let data = Array2::from_shape_vec((rows, cols), flat).map_err(|_| RasterError::EmptyRaster)?;
    Ok(RasterBand::new(data, Some(params.nodata_output)))
}

/// Compute NDVI for a single pixel (convenience function).
pub fn ndvi_pixel(nir: f64, red: f64) -> f64 {
    let sum = nir + red;
    if sum.abs() < f64::EPSILON {
        return 0.0;
    }
    ((nir - red) / sum).clamp(-1.0, 1.0)
}

/// Classify NDVI values into vegetation categories.
#[derive(Debug, Clone, Copy, PartialEq, Eq, serde::Serialize, serde::Deserialize)]
pub enum NdviClass {
    Water,
    BareSoil,
    SparseVegetation,
    ModerateVegetation,
    DenseVegetation,
    NoData,
}

impl NdviClass {
    /// Classify a single NDVI value.
    pub fn from_ndvi(value: f64, nodata: f64) -> Self {
        if (value - nodata).abs() < f64::EPSILON || value.is_nan() {
            NdviClass::NoData
        } else if value < -0.1 {
            NdviClass::Water
        } else if value < 0.2 {
            NdviClass::BareSoil
        } else if value < 0.4 {
            NdviClass::SparseVegetation
        } else if value < 0.6 {
            NdviClass::ModerateVegetation
        } else {
            NdviClass::DenseVegetation
        }
    }
}

/// Classify an entire NDVI raster into vegetation categories.
pub fn classify_ndvi(ndvi_band: &RasterBand) -> Array2<u8> {
    let rows = ndvi_band.rows();
    let cols = ndvi_band.cols();
    let nodata = ndvi_band.nodata_value.unwrap_or(-9999.0);

    let result_rows: Vec<Vec<u8>> = (0..rows)
        .into_par_iter()
        .map(|r| {
            let mut row_vals = Vec::with_capacity(cols);
            for c in 0..cols {
                let class = NdviClass::from_ndvi(ndvi_band.data[[r, c]], nodata);
                row_vals.push(class as u8);
            }
            row_vals
        })
        .collect();

    let flat: Vec<u8> = result_rows.into_iter().flatten().collect();
    Array2::from_shape_vec((rows, cols), flat).unwrap()
}

#[cfg(test)]
mod tests {
    use super::*;

    fn make_band(values: Vec<f64>, rows: usize, cols: usize) -> RasterBand {
        RasterBand::from_vec(values, rows, cols, None).unwrap()
    }

    #[test]
    fn test_ndvi_basic() {
        let nir = make_band(vec![0.8, 0.6, 0.4, 0.2], 2, 2);
        let red = make_band(vec![0.2, 0.3, 0.4, 0.5], 2, 2);
        let result = compute_ndvi(&nir, &red, &NdviParams::default()).unwrap();

        // (0.8 - 0.2) / (0.8 + 0.2) = 0.6
        assert!((result.data[[0, 0]] - 0.6).abs() < 1e-10);
        // (0.6 - 0.3) / (0.6 + 0.3) = 0.333...
        assert!((result.data[[0, 1]] - 1.0 / 3.0).abs() < 1e-10);
        // (0.4 - 0.4) / (0.4 + 0.4) = 0.0
        assert!((result.data[[1, 0]] - 0.0).abs() < 1e-10);
        // (0.2 - 0.5) / (0.2 + 0.5) = -0.4286
        assert!((result.data[[1, 1]] - (-3.0 / 7.0)).abs() < 1e-10);
    }

    #[test]
    fn test_ndvi_dimension_mismatch() {
        let nir = make_band(vec![0.8; 4], 2, 2);
        let red = make_band(vec![0.2; 6], 2, 3);
        let result = compute_ndvi(&nir, &red, &NdviParams::default());
        assert!(result.is_err());
    }

    #[test]
    fn test_ndvi_nodata_handling() {
        let nir = RasterBand::from_vec(vec![-9999.0, 0.8], 1, 2, Some(-9999.0)).unwrap();
        let red = make_band(vec![0.2, 0.2], 1, 2);
        let result = compute_ndvi(&nir, &red, &NdviParams::default()).unwrap();
        assert_eq!(result.data[[0, 0]], -9999.0);
        assert!((result.data[[0, 1]] - 0.6).abs() < 1e-10);
    }

    #[test]
    fn test_ndvi_pixel() {
        assert!((ndvi_pixel(0.8, 0.2) - 0.6).abs() < 1e-10);
        assert!((ndvi_pixel(0.0, 0.0) - 0.0).abs() < 1e-10);
    }

    #[test]
    fn test_ndvi_classification() {
        assert_eq!(NdviClass::from_ndvi(-0.5, -9999.0), NdviClass::Water);
        assert_eq!(NdviClass::from_ndvi(0.1, -9999.0), NdviClass::BareSoil);
        assert_eq!(NdviClass::from_ndvi(0.3, -9999.0), NdviClass::SparseVegetation);
        assert_eq!(NdviClass::from_ndvi(0.5, -9999.0), NdviClass::ModerateVegetation);
        assert_eq!(NdviClass::from_ndvi(0.8, -9999.0), NdviClass::DenseVegetation);
        assert_eq!(NdviClass::from_ndvi(-9999.0, -9999.0), NdviClass::NoData);
    }

    #[test]
    fn test_classify_ndvi_raster() {
        let band = RasterBand::from_vec(vec![-0.5, 0.1, 0.3, 0.8], 2, 2, Some(-9999.0)).unwrap();
        let classified = classify_ndvi(&band);
        assert_eq!(classified[[0, 0]], NdviClass::Water as u8);
        assert_eq!(classified[[0, 1]], NdviClass::BareSoil as u8);
        assert_eq!(classified[[1, 0]], NdviClass::SparseVegetation as u8);
        assert_eq!(classified[[1, 1]], NdviClass::DenseVegetation as u8);
    }
}
