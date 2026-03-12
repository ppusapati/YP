//! Slope calculation from DEM using Horn's method.
//!
//! Horn's method uses a 3x3 kernel to estimate the gradient of the surface
//! in both x and y directions, then computes the slope from these components.

use ndarray::Array2;
use rayon::prelude::*;

use crate::dem::{Dem, TerrainError};

/// Slope output units.
#[derive(Debug, Clone, Copy)]
pub enum SlopeUnit {
    /// Slope in degrees (0-90).
    Degrees,
    /// Slope in percent (0-infinity, 100% = 45 degrees).
    Percent,
    /// Slope as radians (0-pi/2).
    Radians,
}

/// Compute slope from a DEM using Horn's method.
///
/// Horn's method applies weighted differences over a 3x3 neighborhood:
/// dz/dx = ((c + 2f + i) - (a + 2d + g)) / (8 * cell_size)
/// dz/dy = ((g + 2h + i) - (a + 2b + c)) / (8 * cell_size)
/// slope = atan(sqrt(dz/dx^2 + dz/dy^2))
///
/// Neighborhood layout:
/// a b c
/// d e f
/// g h i
pub fn compute_slope(dem: &Dem, unit: SlopeUnit) -> Result<Array2<f64>, TerrainError> {
    if dem.rows() < 3 || dem.cols() < 3 {
        return Err(TerrainError::TooSmall {
            min_rows: 3,
            min_cols: 3,
            actual_rows: dem.rows(),
            actual_cols: dem.cols(),
        });
    }

    let rows = dem.rows();
    let cols = dem.cols();
    let cs = dem.cell_size;

    let result_rows: Vec<Vec<f64>> = (0..rows)
        .into_par_iter()
        .map(|r| {
            let mut row_vals = Vec::with_capacity(cols);
            for c in 0..cols {
                if dem.is_nodata(r, c) {
                    row_vals.push(dem.nodata);
                    continue;
                }

                let n = dem.neighborhood_3x3(r, c);
                // n = [a, b, c, d, e, f, g, h, i]
                let a = n[0]; let b = n[1]; let cc = n[2];
                let d = n[3]; let f = n[5];
                let g = n[6]; let h = n[7]; let i = n[8];

                let dz_dx = ((cc + 2.0 * f + i) - (a + 2.0 * d + g)) / (8.0 * cs);
                let dz_dy = ((g + 2.0 * h + i) - (a + 2.0 * b + cc)) / (8.0 * cs);
                let rise = (dz_dx * dz_dx + dz_dy * dz_dy).sqrt();

                let slope_val = match unit {
                    SlopeUnit::Degrees => rise.atan().to_degrees(),
                    SlopeUnit::Percent => rise * 100.0,
                    SlopeUnit::Radians => rise.atan(),
                };

                row_vals.push(slope_val);
            }
            row_vals
        })
        .collect();

    let flat: Vec<f64> = result_rows.into_iter().flatten().collect();
    Ok(Array2::from_shape_vec((rows, cols), flat).unwrap())
}

/// Compute slope for a single pixel given a 3x3 neighborhood and cell size.
pub fn slope_from_neighborhood(neighborhood: &[f64; 9], cell_size: f64, unit: SlopeUnit) -> f64 {
    let a = neighborhood[0]; let b = neighborhood[1]; let c = neighborhood[2];
    let d = neighborhood[3]; let f = neighborhood[5];
    let g = neighborhood[6]; let h = neighborhood[7]; let i = neighborhood[8];

    let dz_dx = ((c + 2.0 * f + i) - (a + 2.0 * d + g)) / (8.0 * cell_size);
    let dz_dy = ((g + 2.0 * h + i) - (a + 2.0 * b + c)) / (8.0 * cell_size);
    let rise = (dz_dx * dz_dx + dz_dy * dz_dy).sqrt();

    match unit {
        SlopeUnit::Degrees => rise.atan().to_degrees(),
        SlopeUnit::Percent => rise * 100.0,
        SlopeUnit::Radians => rise.atan(),
    }
}

/// Classify slope into categories useful for agriculture.
#[derive(Debug, Clone, Copy, PartialEq, Eq, serde::Serialize, serde::Deserialize)]
pub enum SlopeClass {
    Flat,        // 0-2 degrees
    Gentle,      // 2-5 degrees
    Moderate,    // 5-10 degrees
    Steep,       // 10-20 degrees
    VerySteep,   // 20-45 degrees
    Cliff,       // > 45 degrees
}

impl SlopeClass {
    pub fn from_degrees(slope_deg: f64) -> Self {
        if slope_deg < 2.0 {
            SlopeClass::Flat
        } else if slope_deg < 5.0 {
            SlopeClass::Gentle
        } else if slope_deg < 10.0 {
            SlopeClass::Moderate
        } else if slope_deg < 20.0 {
            SlopeClass::Steep
        } else if slope_deg < 45.0 {
            SlopeClass::VerySteep
        } else {
            SlopeClass::Cliff
        }
    }

    /// Whether this slope class is suitable for mechanized agriculture.
    pub fn is_cultivable(&self) -> bool {
        matches!(self, SlopeClass::Flat | SlopeClass::Gentle | SlopeClass::Moderate)
    }
}

/// Classify an entire slope raster.
pub fn classify_slope(slope_degrees: &Array2<f64>) -> Array2<u8> {
    let rows = slope_degrees.nrows();
    let cols = slope_degrees.ncols();

    let result_rows: Vec<Vec<u8>> = (0..rows)
        .into_par_iter()
        .map(|r| {
            (0..cols)
                .map(|c| SlopeClass::from_degrees(slope_degrees[[r, c]]) as u8)
                .collect()
        })
        .collect();

    let flat: Vec<u8> = result_rows.into_iter().flatten().collect();
    Array2::from_shape_vec((rows, cols), flat).unwrap()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_flat_terrain_slope() {
        // All same elevation => slope = 0
        let dem = Dem::from_vec(
            vec![100.0; 9], 3, 3, 10.0, -9999.0,
        ).unwrap();
        let slope = compute_slope(&dem, SlopeUnit::Degrees).unwrap();
        for &val in slope.iter() {
            assert!(val.abs() < 1e-10 || (val - (-9999.0)).abs() < 1e-10);
        }
    }

    #[test]
    fn test_tilted_terrain_slope() {
        // Linear slope in x direction: elevation increases by 10m per cell
        let dem = Dem::from_vec(
            vec![
                0.0, 10.0, 20.0,
                0.0, 10.0, 20.0,
                0.0, 10.0, 20.0,
            ],
            3, 3, 10.0, -9999.0,
        ).unwrap();
        let slope = compute_slope(&dem, SlopeUnit::Degrees).unwrap();
        // Center pixel: dz/dx = 1.0, dz/dy = 0.0, slope = atan(1) = 45 degrees
        assert!((slope[[1, 1]] - 45.0).abs() < 1e-10);
    }

    #[test]
    fn test_slope_percent() {
        let dem = Dem::from_vec(
            vec![
                0.0, 10.0, 20.0,
                0.0, 10.0, 20.0,
                0.0, 10.0, 20.0,
            ],
            3, 3, 10.0, -9999.0,
        ).unwrap();
        let slope = compute_slope(&dem, SlopeUnit::Percent).unwrap();
        // Center pixel: rise = 1.0, percent = 100%
        assert!((slope[[1, 1]] - 100.0).abs() < 1e-10);
    }

    #[test]
    fn test_slope_classification() {
        assert_eq!(SlopeClass::from_degrees(1.0), SlopeClass::Flat);
        assert!(SlopeClass::Flat.is_cultivable());
        assert_eq!(SlopeClass::from_degrees(3.0), SlopeClass::Gentle);
        assert_eq!(SlopeClass::from_degrees(7.0), SlopeClass::Moderate);
        assert_eq!(SlopeClass::from_degrees(15.0), SlopeClass::Steep);
        assert!(!SlopeClass::Steep.is_cultivable());
        assert_eq!(SlopeClass::from_degrees(30.0), SlopeClass::VerySteep);
        assert_eq!(SlopeClass::from_degrees(60.0), SlopeClass::Cliff);
    }

    #[test]
    fn test_too_small_dem() {
        let dem = Dem::from_vec(vec![1.0; 4], 2, 2, 10.0, -9999.0).unwrap();
        assert!(compute_slope(&dem, SlopeUnit::Degrees).is_err());
    }
}
