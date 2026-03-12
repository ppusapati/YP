//! NDWI (Normalized Difference Water Index) computation.
//!
//! NDWI = (GREEN - NIR) / (GREEN + NIR)
//! Range: -1.0 to 1.0
//! Positive values indicate water surfaces; negative indicate non-water.

use ndarray::Array2;
use rayon::prelude::*;

use crate::raster::{RasterBand, RasterError};

/// NDWI computation parameters.
#[derive(Debug, Clone)]
pub struct NdwiParams {
    pub min_reflectance: f64,
    pub max_reflectance: f64,
    pub nodata_output: f64,
}

impl Default for NdwiParams {
    fn default() -> Self {
        Self {
            min_reflectance: 0.0,
            max_reflectance: 1.0,
            nodata_output: -9999.0,
        }
    }
}

/// Compute NDWI from GREEN and NIR bands.
///
/// NDWI = (GREEN - NIR) / (GREEN + NIR)
pub fn compute_ndwi(
    green: &RasterBand,
    nir: &RasterBand,
    params: &NdwiParams,
) -> Result<RasterBand, RasterError> {
    let rows = green.rows();
    let cols = green.cols();

    if nir.rows() != rows || nir.cols() != cols {
        return Err(RasterError::DimensionMismatch {
            expected_rows: rows,
            expected_cols: cols,
            actual_rows: nir.rows(),
            actual_cols: nir.cols(),
        });
    }

    let green_data = &green.data;
    let nir_data = &nir.data;

    let result_rows: Vec<Vec<f64>> = (0..rows)
        .into_par_iter()
        .map(|r| {
            let mut row_vals = Vec::with_capacity(cols);
            for c in 0..cols {
                let g = green_data[[r, c]];
                let n = nir_data[[r, c]];

                if g.is_nan()
                    || n.is_nan()
                    || green.is_nodata(r, c)
                    || nir.is_nodata(r, c)
                    || g < params.min_reflectance
                    || n < params.min_reflectance
                    || g > params.max_reflectance
                    || n > params.max_reflectance
                {
                    row_vals.push(params.nodata_output);
                    continue;
                }

                let sum = g + n;
                if sum.abs() < f64::EPSILON {
                    row_vals.push(0.0);
                } else {
                    let ndwi = (g - n) / sum;
                    row_vals.push(ndwi.clamp(-1.0, 1.0));
                }
            }
            row_vals
        })
        .collect();

    let flat: Vec<f64> = result_rows.into_iter().flatten().collect();
    let data = Array2::from_shape_vec((rows, cols), flat).map_err(|_| RasterError::EmptyRaster)?;
    Ok(RasterBand::new(data, Some(params.nodata_output)))
}

/// Compute NDWI for a single pixel.
pub fn ndwi_pixel(green: f64, nir: f64) -> f64 {
    let sum = green + nir;
    if sum.abs() < f64::EPSILON {
        return 0.0;
    }
    ((green - nir) / sum).clamp(-1.0, 1.0)
}

/// Water body classification from NDWI values.
#[derive(Debug, Clone, Copy, PartialEq, Eq, serde::Serialize, serde::Deserialize)]
pub enum WaterClass {
    /// NDWI > 0.3: open water
    OpenWater,
    /// NDWI 0.0 to 0.3: shallow or turbid water / wetland
    ShallowWater,
    /// NDWI -0.3 to 0.0: moist soil / partial vegetation
    MoistSoil,
    /// NDWI < -0.3: dry land / dense vegetation
    DryLand,
    NoData,
}

impl WaterClass {
    pub fn from_ndwi(value: f64, nodata: f64) -> Self {
        if (value - nodata).abs() < f64::EPSILON || value.is_nan() {
            WaterClass::NoData
        } else if value > 0.3 {
            WaterClass::OpenWater
        } else if value > 0.0 {
            WaterClass::ShallowWater
        } else if value > -0.3 {
            WaterClass::MoistSoil
        } else {
            WaterClass::DryLand
        }
    }
}

/// Classify an NDWI raster into water categories.
pub fn classify_ndwi(ndwi_band: &RasterBand) -> Array2<u8> {
    let rows = ndwi_band.rows();
    let cols = ndwi_band.cols();
    let nodata = ndwi_band.nodata_value.unwrap_or(-9999.0);

    let result_rows: Vec<Vec<u8>> = (0..rows)
        .into_par_iter()
        .map(|r| {
            (0..cols)
                .map(|c| WaterClass::from_ndwi(ndwi_band.data[[r, c]], nodata) as u8)
                .collect()
        })
        .collect();

    let flat: Vec<u8> = result_rows.into_iter().flatten().collect();
    Array2::from_shape_vec((rows, cols), flat).unwrap()
}

/// Estimate water content percentage from NDWI (heuristic mapping).
pub fn estimate_water_content(ndwi: f64) -> f64 {
    if ndwi.is_nan() {
        return 0.0;
    }
    // Linear mapping: NDWI -1 -> 0%, NDWI 1 -> 100%
    ((ndwi + 1.0) / 2.0 * 100.0).clamp(0.0, 100.0)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn make_band(values: Vec<f64>, rows: usize, cols: usize) -> RasterBand {
        RasterBand::from_vec(values, rows, cols, None).unwrap()
    }

    #[test]
    fn test_ndwi_basic() {
        let green = make_band(vec![0.6, 0.2], 1, 2);
        let nir = make_band(vec![0.2, 0.8], 1, 2);
        let result = compute_ndwi(&green, &nir, &NdwiParams::default()).unwrap();

        // (0.6 - 0.2) / (0.6 + 0.2) = 0.5
        assert!((result.data[[0, 0]] - 0.5).abs() < 1e-10);
        // (0.2 - 0.8) / (0.2 + 0.8) = -0.6
        assert!((result.data[[0, 1]] - (-0.6)).abs() < 1e-10);
    }

    #[test]
    fn test_ndwi_pixel() {
        assert!((ndwi_pixel(0.6, 0.2) - 0.5).abs() < 1e-10);
        assert!((ndwi_pixel(0.0, 0.0) - 0.0).abs() < 1e-10);
    }

    #[test]
    fn test_water_classification() {
        assert_eq!(WaterClass::from_ndwi(0.5, -9999.0), WaterClass::OpenWater);
        assert_eq!(WaterClass::from_ndwi(0.15, -9999.0), WaterClass::ShallowWater);
        assert_eq!(WaterClass::from_ndwi(-0.1, -9999.0), WaterClass::MoistSoil);
        assert_eq!(WaterClass::from_ndwi(-0.5, -9999.0), WaterClass::DryLand);
    }

    #[test]
    fn test_water_content_estimation() {
        assert!((estimate_water_content(1.0) - 100.0).abs() < 1e-10);
        assert!((estimate_water_content(-1.0) - 0.0).abs() < 1e-10);
        assert!((estimate_water_content(0.0) - 50.0).abs() < 1e-10);
    }

    #[test]
    fn test_ndwi_dimension_mismatch() {
        let green = make_band(vec![0.6; 4], 2, 2);
        let nir = make_band(vec![0.2; 6], 2, 3);
        assert!(compute_ndwi(&green, &nir, &NdwiParams::default()).is_err());
    }
}
