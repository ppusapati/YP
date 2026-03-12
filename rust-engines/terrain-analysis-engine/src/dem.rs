//! DEM (Digital Elevation Model) data structures.

use ndarray::Array2;
use serde::{Deserialize, Serialize};
use thiserror::Error;

/// Errors from terrain analysis operations.
#[derive(Debug, Error)]
pub enum TerrainError {
    #[error("DEM dimension mismatch: expected {expected_rows}x{expected_cols}, got {actual_rows}x{actual_cols}")]
    DimensionMismatch {
        expected_rows: usize,
        expected_cols: usize,
        actual_rows: usize,
        actual_cols: usize,
    },

    #[error("DEM is too small: minimum {min_rows}x{min_cols} required, got {actual_rows}x{actual_cols}")]
    TooSmall {
        min_rows: usize,
        min_cols: usize,
        actual_rows: usize,
        actual_cols: usize,
    },

    #[error("Invalid nodata value at ({row}, {col})")]
    NoDataPixel { row: usize, col: usize },

    #[error("Empty DEM")]
    EmptyDem,

    #[error("Invalid cell size: {0}")]
    InvalidCellSize(f64),

    #[error("Coordinate out of bounds: ({row}, {col}) in {rows}x{cols} grid")]
    OutOfBounds {
        row: usize,
        col: usize,
        rows: usize,
        cols: usize,
    },

    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),

    #[error("JSON error: {0}")]
    Json(#[from] serde_json::Error),
}

/// Geospatial extent of a DEM.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DemExtent {
    pub min_x: f64,
    pub min_y: f64,
    pub max_x: f64,
    pub max_y: f64,
}

/// Digital Elevation Model.
#[derive(Debug, Clone)]
pub struct Dem {
    /// Elevation data in meters.
    pub elevation: Array2<f64>,
    /// Cell size in meters (assumed square cells).
    pub cell_size: f64,
    /// Nodata value.
    pub nodata: f64,
    /// Spatial extent.
    pub extent: Option<DemExtent>,
    /// Coordinate reference system identifier.
    pub crs: Option<String>,
}

impl Dem {
    /// Create a new DEM from an elevation array.
    pub fn new(elevation: Array2<f64>, cell_size: f64, nodata: f64) -> Result<Self, TerrainError> {
        if elevation.is_empty() {
            return Err(TerrainError::EmptyDem);
        }
        if cell_size <= 0.0 || cell_size.is_nan() {
            return Err(TerrainError::InvalidCellSize(cell_size));
        }
        Ok(Self {
            elevation,
            cell_size,
            nodata,
            extent: None,
            crs: None,
        })
    }

    /// Create from a flat vector of elevation values.
    pub fn from_vec(
        values: Vec<f64>,
        rows: usize,
        cols: usize,
        cell_size: f64,
        nodata: f64,
    ) -> Result<Self, TerrainError> {
        if values.is_empty() {
            return Err(TerrainError::EmptyDem);
        }
        let elevation = Array2::from_shape_vec((rows, cols), values).map_err(|_| {
            TerrainError::DimensionMismatch {
                expected_rows: rows,
                expected_cols: cols,
                actual_rows: 0,
                actual_cols: 0,
            }
        })?;
        Self::new(elevation, cell_size, nodata)
    }

    pub fn rows(&self) -> usize {
        self.elevation.nrows()
    }

    pub fn cols(&self) -> usize {
        self.elevation.ncols()
    }

    /// Check if a pixel is nodata.
    pub fn is_nodata(&self, row: usize, col: usize) -> bool {
        let val = self.elevation[[row, col]];
        (val - self.nodata).abs() < f64::EPSILON || val.is_nan()
    }

    /// Get elevation at a pixel, returning None for nodata.
    pub fn elevation_at(&self, row: usize, col: usize) -> Option<f64> {
        if row >= self.rows() || col >= self.cols() {
            return None;
        }
        if self.is_nodata(row, col) {
            None
        } else {
            Some(self.elevation[[row, col]])
        }
    }

    /// Get the 3x3 neighborhood around a pixel (with boundary handling).
    /// Returns values in row-major order: [NW, N, NE, W, C, E, SW, S, SE].
    /// Uses edge replication for boundary pixels.
    pub fn neighborhood_3x3(&self, row: usize, col: usize) -> [f64; 9] {
        let rows = self.rows();
        let cols = self.cols();
        let r = |r: isize| r.clamp(0, rows as isize - 1) as usize;
        let c = |c: isize| c.clamp(0, cols as isize - 1) as usize;
        let ri = row as isize;
        let ci = col as isize;

        [
            self.elevation[[r(ri - 1), c(ci - 1)]],
            self.elevation[[r(ri - 1), c(ci)]],
            self.elevation[[r(ri - 1), c(ci + 1)]],
            self.elevation[[r(ri), c(ci - 1)]],
            self.elevation[[r(ri), c(ci)]],
            self.elevation[[r(ri), c(ci + 1)]],
            self.elevation[[r(ri + 1), c(ci - 1)]],
            self.elevation[[r(ri + 1), c(ci)]],
            self.elevation[[r(ri + 1), c(ci + 1)]],
        ]
    }

    /// Basic statistics of the DEM.
    pub fn statistics(&self) -> DemStatistics {
        let mut min = f64::INFINITY;
        let mut max = f64::NEG_INFINITY;
        let mut sum = 0.0;
        let mut count = 0usize;

        for r in 0..self.rows() {
            for c in 0..self.cols() {
                if !self.is_nodata(r, c) {
                    let val = self.elevation[[r, c]];
                    if val < min { min = val; }
                    if val > max { max = val; }
                    sum += val;
                    count += 1;
                }
            }
        }

        let mean = if count > 0 { sum / count as f64 } else { 0.0 };

        DemStatistics {
            min_elevation: if count > 0 { min } else { 0.0 },
            max_elevation: if count > 0 { max } else { 0.0 },
            mean_elevation: mean,
            elevation_range: if count > 0 { max - min } else { 0.0 },
            valid_cells: count,
            total_cells: self.rows() * self.cols(),
        }
    }
}

/// Summary statistics for a DEM.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DemStatistics {
    pub min_elevation: f64,
    pub max_elevation: f64,
    pub mean_elevation: f64,
    pub elevation_range: f64,
    pub valid_cells: usize,
    pub total_cells: usize,
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_dem_creation() {
        let dem = Dem::from_vec(
            vec![100.0, 200.0, 150.0, 300.0],
            2, 2, 10.0, -9999.0,
        ).unwrap();
        assert_eq!(dem.rows(), 2);
        assert_eq!(dem.cols(), 2);
        assert_eq!(dem.cell_size, 10.0);
    }

    #[test]
    fn test_dem_nodata() {
        let dem = Dem::from_vec(
            vec![-9999.0, 200.0, 150.0, 300.0],
            2, 2, 10.0, -9999.0,
        ).unwrap();
        assert!(dem.is_nodata(0, 0));
        assert!(!dem.is_nodata(0, 1));
        assert!(dem.elevation_at(0, 0).is_none());
        assert_eq!(dem.elevation_at(0, 1), Some(200.0));
    }

    #[test]
    fn test_dem_neighborhood() {
        let dem = Dem::from_vec(
            vec![1.0, 2.0, 3.0,
                 4.0, 5.0, 6.0,
                 7.0, 8.0, 9.0],
            3, 3, 10.0, -9999.0,
        ).unwrap();
        let n = dem.neighborhood_3x3(1, 1);
        assert_eq!(n, [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0]);
    }

    #[test]
    fn test_dem_corner_neighborhood() {
        let dem = Dem::from_vec(
            vec![1.0, 2.0,
                 3.0, 4.0],
            2, 2, 10.0, -9999.0,
        ).unwrap();
        let n = dem.neighborhood_3x3(0, 0);
        // Corner: edge replication
        assert_eq!(n, [1.0, 1.0, 2.0, 1.0, 1.0, 2.0, 3.0, 3.0, 4.0]);
    }

    #[test]
    fn test_dem_statistics() {
        let dem = Dem::from_vec(
            vec![100.0, 200.0, 300.0, 400.0],
            2, 2, 10.0, -9999.0,
        ).unwrap();
        let stats = dem.statistics();
        assert!((stats.min_elevation - 100.0).abs() < 1e-10);
        assert!((stats.max_elevation - 400.0).abs() < 1e-10);
        assert!((stats.mean_elevation - 250.0).abs() < 1e-10);
        assert_eq!(stats.valid_cells, 4);
    }

    #[test]
    fn test_invalid_cell_size() {
        assert!(Dem::from_vec(vec![1.0], 1, 1, -1.0, -9999.0).is_err());
        assert!(Dem::from_vec(vec![1.0], 1, 1, 0.0, -9999.0).is_err());
    }
}
