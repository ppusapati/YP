//! Aspect (direction) calculation from DEM.
//!
//! Aspect represents the compass direction that a slope faces.
//! Computed from the same partial derivatives as slope using Horn's method.

use ndarray::Array2;
use rayon::prelude::*;

use crate::dem::{Dem, TerrainError};

/// Compute aspect from a DEM using Horn's method.
///
/// Returns aspect in degrees clockwise from north (0-360).
/// Flat areas (slope = 0) are assigned -1.0.
///
/// Neighborhood layout:
/// a b c
/// d e f
/// g h i
pub fn compute_aspect(dem: &Dem) -> Result<Array2<f64>, TerrainError> {
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
                let a = n[0]; let b = n[1]; let cc = n[2];
                let d = n[3]; let f = n[5];
                let g = n[6]; let h = n[7]; let i = n[8];

                let dz_dx = ((cc + 2.0 * f + i) - (a + 2.0 * d + g)) / (8.0 * cs);
                let dz_dy = ((g + 2.0 * h + i) - (a + 2.0 * b + cc)) / (8.0 * cs);

                if dz_dx.abs() < f64::EPSILON && dz_dy.abs() < f64::EPSILON {
                    row_vals.push(-1.0); // Flat
                    continue;
                }

                // atan2 gives angle in radians from east, counter-clockwise
                // Convert to degrees clockwise from north
                let aspect_rad = dz_dy.atan2(-dz_dx);
                let mut aspect_deg = aspect_rad.to_degrees();

                // Convert from mathematical convention to compass bearing
                aspect_deg = 180.0 - aspect_deg;

                // Normalize to 0-360
                if aspect_deg < 0.0 {
                    aspect_deg += 360.0;
                }
                if aspect_deg >= 360.0 {
                    aspect_deg -= 360.0;
                }

                row_vals.push(aspect_deg);
            }
            row_vals
        })
        .collect();

    let flat: Vec<f64> = result_rows.into_iter().flatten().collect();
    Ok(Array2::from_shape_vec((rows, cols), flat).unwrap())
}

/// Cardinal direction from aspect angle.
#[derive(Debug, Clone, Copy, PartialEq, Eq, serde::Serialize, serde::Deserialize)]
pub enum CardinalDirection {
    North,
    NorthEast,
    East,
    SouthEast,
    South,
    SouthWest,
    West,
    NorthWest,
    Flat,
}

impl CardinalDirection {
    /// Convert aspect angle (degrees clockwise from north) to cardinal direction.
    pub fn from_aspect(aspect_deg: f64) -> Self {
        if aspect_deg < 0.0 {
            return CardinalDirection::Flat;
        }
        let normalized = aspect_deg % 360.0;
        if normalized < 22.5 || normalized >= 337.5 {
            CardinalDirection::North
        } else if normalized < 67.5 {
            CardinalDirection::NorthEast
        } else if normalized < 112.5 {
            CardinalDirection::East
        } else if normalized < 157.5 {
            CardinalDirection::SouthEast
        } else if normalized < 202.5 {
            CardinalDirection::South
        } else if normalized < 247.5 {
            CardinalDirection::SouthWest
        } else if normalized < 292.5 {
            CardinalDirection::West
        } else {
            CardinalDirection::NorthWest
        }
    }

    pub fn label(&self) -> &'static str {
        match self {
            CardinalDirection::North => "N",
            CardinalDirection::NorthEast => "NE",
            CardinalDirection::East => "E",
            CardinalDirection::SouthEast => "SE",
            CardinalDirection::South => "S",
            CardinalDirection::SouthWest => "SW",
            CardinalDirection::West => "W",
            CardinalDirection::NorthWest => "NW",
            CardinalDirection::Flat => "Flat",
        }
    }
}

/// Classify an aspect raster into cardinal directions.
pub fn classify_aspect(aspect: &Array2<f64>) -> Array2<u8> {
    let rows = aspect.nrows();
    let cols = aspect.ncols();

    let result_rows: Vec<Vec<u8>> = (0..rows)
        .into_par_iter()
        .map(|r| {
            (0..cols)
                .map(|c| CardinalDirection::from_aspect(aspect[[r, c]]) as u8)
                .collect()
        })
        .collect();

    let flat: Vec<u8> = result_rows.into_iter().flatten().collect();
    Array2::from_shape_vec((rows, cols), flat).unwrap()
}

/// Compute solar exposure index based on aspect.
/// South-facing slopes (in Northern Hemisphere) get more sun.
/// Returns a value from 0.0 (least exposure) to 1.0 (most exposure).
pub fn solar_exposure_index(aspect_deg: f64, latitude: f64) -> f64 {
    if aspect_deg < 0.0 {
        return 0.5; // Flat areas get average exposure
    }

    // In Northern Hemisphere, south-facing is optimal (180 degrees)
    // In Southern Hemisphere, north-facing is optimal (0/360 degrees)
    let optimal_aspect = if latitude >= 0.0 { 180.0 } else { 0.0 };

    let diff = (aspect_deg - optimal_aspect).abs();
    let diff = if diff > 180.0 { 360.0 - diff } else { diff };

    // Cosine transform: 0 degrees difference = 1.0, 180 degrees = 0.0
    (1.0 + (diff * std::f64::consts::PI / 180.0).cos()) / 2.0
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_flat_terrain_aspect() {
        let dem = Dem::from_vec(
            vec![100.0; 9], 3, 3, 10.0, -9999.0,
        ).unwrap();
        let aspect = compute_aspect(&dem).unwrap();
        // Flat terrain should have aspect = -1
        assert!((aspect[[1, 1]] - (-1.0)).abs() < 1e-10);
    }

    #[test]
    fn test_south_facing_slope() {
        // Elevation decreases going south (rows increase)
        let dem = Dem::from_vec(
            vec![
                30.0, 30.0, 30.0,
                20.0, 20.0, 20.0,
                10.0, 10.0, 10.0,
            ],
            3, 3, 10.0, -9999.0,
        ).unwrap();
        let aspect = compute_aspect(&dem).unwrap();
        // South-facing: aspect should be ~180 degrees
        assert!((aspect[[1, 1]] - 180.0).abs() < 1.0);
    }

    #[test]
    fn test_cardinal_directions() {
        assert_eq!(CardinalDirection::from_aspect(0.0), CardinalDirection::North);
        assert_eq!(CardinalDirection::from_aspect(90.0), CardinalDirection::East);
        assert_eq!(CardinalDirection::from_aspect(180.0), CardinalDirection::South);
        assert_eq!(CardinalDirection::from_aspect(270.0), CardinalDirection::West);
        assert_eq!(CardinalDirection::from_aspect(-1.0), CardinalDirection::Flat);
    }

    #[test]
    fn test_solar_exposure() {
        // In Northern Hemisphere, south-facing = max exposure
        let south = solar_exposure_index(180.0, 45.0);
        let north = solar_exposure_index(0.0, 45.0);
        assert!(south > north);
        assert!((south - 1.0).abs() < 1e-10);
        assert!((north - 0.0).abs() < 1e-10);
    }

    #[test]
    fn test_too_small() {
        let dem = Dem::from_vec(vec![1.0; 4], 2, 2, 10.0, -9999.0).unwrap();
        assert!(compute_aspect(&dem).is_err());
    }
}
