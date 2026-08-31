//! DEM (Digital Elevation Model) data structures.

use ndarray::Array2;
use rayon::prelude::*;
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

    /// Set the spatial extent.
    pub fn with_extent(mut self, extent: DemExtent) -> Self {
        self.extent = Some(extent);
        self
    }

    /// Set the CRS.
    pub fn with_crs(mut self, crs: String) -> Self {
        self.crs = Some(crs);
        self
    }

    /// Bilinear interpolation at fractional row/col coordinates.
    /// Returns None if out of bounds or if any contributing pixel is nodata.
    pub fn interpolate_bilinear(&self, row: f64, col: f64) -> Option<f64> {
        if row < 0.0 || col < 0.0 {
            return None;
        }
        let r0 = row.floor() as usize;
        let c0 = col.floor() as usize;
        let r1 = r0 + 1;
        let c1 = c0 + 1;

        if r1 >= self.rows() || c1 >= self.cols() {
            return None;
        }

        let v00 = self.elevation_at(r0, c0)?;
        let v10 = self.elevation_at(r1, c0)?;
        let v01 = self.elevation_at(r0, c1)?;
        let v11 = self.elevation_at(r1, c1)?;

        let fr = row - r0 as f64;
        let fc = col - c0 as f64;

        let val = v00 * (1.0 - fr) * (1.0 - fc)
            + v01 * (1.0 - fr) * fc
            + v10 * fr * (1.0 - fc)
            + v11 * fr * fc;
        Some(val)
    }

    /// Bicubic interpolation at fractional row/col coordinates.
    /// Uses Catmull-Rom spline (a = -0.5).
    pub fn interpolate_bicubic(&self, row: f64, col: f64) -> Option<f64> {
        if row < 1.0 || col < 1.0 {
            return None;
        }
        let r0 = row.floor() as usize;
        let c0 = col.floor() as usize;

        if r0 + 2 >= self.rows() || c0 + 2 >= self.cols() || r0 < 1 || c0 < 1 {
            return None;
        }

        let fr = row - r0 as f64;
        let fc = col - c0 as f64;

        let mut result = 0.0;
        for m in 0..4 {
            let ri = (r0 as isize + m as isize - 1) as usize;
            let mut row_val = 0.0;
            for n in 0..4 {
                let ci = (c0 as isize + n as isize - 1) as usize;
                let v = self.elevation_at(ri, ci)?;
                row_val += v * cubic_weight(fc - (n as f64 - 1.0));
            }
            result += row_val * cubic_weight(fr - (m as f64 - 1.0));
        }
        Some(result)
    }

    /// Compute hillshade for the entire DEM.
    ///
    /// # Arguments
    /// * `azimuth_deg` - Sun azimuth in degrees (0=North, clockwise)
    /// * `altitude_deg` - Sun altitude in degrees above horizon (0-90)
    /// * `z_factor` - Vertical exaggeration factor (typically 1.0)
    ///
    /// Returns a grid of hillshade values in [0, 255].
    pub fn hillshade(&self, azimuth_deg: f64, altitude_deg: f64, z_factor: f64) -> Array2<f64> {
        let rows = self.rows();
        let cols = self.cols();
        let cs = self.cell_size;

        let azimuth_rad = (360.0 - azimuth_deg + 90.0).to_radians();
        let altitude_rad = altitude_deg.to_radians();

        let result_rows: Vec<Vec<f64>> = (0..rows)
            .into_par_iter()
            .map(|r| {
                let mut row_vals = Vec::with_capacity(cols);
                for c in 0..cols {
                    if self.is_nodata(r, c) {
                        row_vals.push(self.nodata);
                        continue;
                    }

                    let n = self.neighborhood_3x3(r, c);
                    let a = n[0]; let b = n[1]; let cc_v = n[2];
                    let d = n[3]; let f = n[5];
                    let g = n[6]; let h = n[7]; let i = n[8];

                    let dz_dx = ((cc_v + 2.0 * f + i) - (a + 2.0 * d + g)) / (8.0 * cs) * z_factor;
                    let dz_dy = ((g + 2.0 * h + i) - (a + 2.0 * b + cc_v)) / (8.0 * cs) * z_factor;

                    let slope = (dz_dx * dz_dx + dz_dy * dz_dy).sqrt().atan();
                    let aspect = dz_dy.atan2(-dz_dx);

                    let hs = 255.0
                        * ((altitude_rad.sin() * slope.cos())
                            + (altitude_rad.cos() * slope.sin() * (azimuth_rad - aspect).cos()))
                            .max(0.0);

                    row_vals.push(hs);
                }
                row_vals
            })
            .collect();

        let flat: Vec<f64> = result_rows.into_iter().flatten().collect();
        Array2::from_shape_vec((rows, cols), flat).unwrap()
    }

    /// Terrain Ruggedness Index (TRI).
    ///
    /// TRI measures the absolute differences between a central cell and its 8 neighbors.
    /// TRI = sqrt(sum((z_i - z_center)^2) / 8)
    pub fn terrain_ruggedness_index(&self) -> Array2<f64> {
        let rows = self.rows();
        let cols = self.cols();

        let result_rows: Vec<Vec<f64>> = (0..rows)
            .into_par_iter()
            .map(|r| {
                let mut row_vals = Vec::with_capacity(cols);
                for c in 0..cols {
                    if self.is_nodata(r, c) {
                        row_vals.push(self.nodata);
                        continue;
                    }
                    let n = self.neighborhood_3x3(r, c);
                    let center = n[4];
                    let sum_sq: f64 = n.iter()
                        .enumerate()
                        .filter(|&(idx, _)| idx != 4)
                        .map(|(_, &v)| (v - center).powi(2))
                        .sum();
                    row_vals.push((sum_sq / 8.0).sqrt());
                }
                row_vals
            })
            .collect();

        let flat: Vec<f64> = result_rows.into_iter().flatten().collect();
        Array2::from_shape_vec((rows, cols), flat).unwrap()
    }

    /// Topographic Position Index (TPI).
    ///
    /// TPI = elevation of center cell - mean elevation of surrounding cells.
    /// Positive TPI = ridges, negative TPI = valleys, near-zero = slopes/flats.
    pub fn topographic_position_index(&self) -> Array2<f64> {
        let rows = self.rows();
        let cols = self.cols();

        let result_rows: Vec<Vec<f64>> = (0..rows)
            .into_par_iter()
            .map(|r| {
                let mut row_vals = Vec::with_capacity(cols);
                for c in 0..cols {
                    if self.is_nodata(r, c) {
                        row_vals.push(self.nodata);
                        continue;
                    }
                    let n = self.neighborhood_3x3(r, c);
                    let center = n[4];
                    let neighbor_sum: f64 = n.iter()
                        .enumerate()
                        .filter(|&(idx, _)| idx != 4)
                        .map(|(_, &v)| v)
                        .sum();
                    let neighbor_mean = neighbor_sum / 8.0;
                    row_vals.push(center - neighbor_mean);
                }
                row_vals
            })
            .collect();

        let flat: Vec<f64> = result_rows.into_iter().flatten().collect();
        Array2::from_shape_vec((rows, cols), flat).unwrap()
    }

    /// Topographic Wetness Index (TWI).
    ///
    /// TWI = ln(a / tan(b)) where a = upslope contributing area, b = slope.
    /// Requires flow accumulation and slope grids.
    pub fn topographic_wetness_index(
        &self,
        flow_accumulation: &Array2<f64>,
        slope_radians: &Array2<f64>,
    ) -> Array2<f64> {
        let rows = self.rows();
        let cols = self.cols();
        let cell_area = self.cell_size * self.cell_size;

        let result_rows: Vec<Vec<f64>> = (0..rows)
            .into_par_iter()
            .map(|r| {
                let mut row_vals = Vec::with_capacity(cols);
                for c in 0..cols {
                    if self.is_nodata(r, c) {
                        row_vals.push(self.nodata);
                        continue;
                    }
                    let a = flow_accumulation[[r, c]] * cell_area / self.cell_size;
                    let slope_tan = slope_radians[[r, c]].tan().max(0.001);
                    row_vals.push((a / slope_tan).ln());
                }
                row_vals
            })
            .collect();

        let flat: Vec<f64> = result_rows.into_iter().flatten().collect();
        Array2::from_shape_vec((rows, cols), flat).unwrap()
    }

    /// Load DEM from a raw binary file (row-major f64 values).
    pub fn load_raw_f64(
        path: &std::path::Path,
        rows: usize,
        cols: usize,
        cell_size: f64,
        nodata: f64,
    ) -> Result<Self, TerrainError> {
        let data = std::fs::read(path)?;
        let expected_bytes = rows * cols * 8;
        if data.len() != expected_bytes {
            return Err(TerrainError::DimensionMismatch {
                expected_rows: rows,
                expected_cols: cols,
                actual_rows: data.len() / (cols * 8),
                actual_cols: cols,
            });
        }
        let values: Vec<f64> = data
            .chunks_exact(8)
            .map(|chunk| f64::from_le_bytes(chunk.try_into().unwrap()))
            .collect();
        Self::from_vec(values, rows, cols, cell_size, nodata)
    }

    /// Save DEM to a raw binary file (row-major f64 values).
    pub fn save_raw_f64(&self, path: &std::path::Path) -> Result<(), TerrainError> {
        let bytes: Vec<u8> = self
            .elevation
            .iter()
            .flat_map(|v| v.to_le_bytes())
            .collect();
        std::fs::write(path, bytes)?;
        Ok(())
    }

    /// Save DEM to JSON format.
    pub fn to_json(&self) -> Result<String, TerrainError> {
        let data = DemSerializable {
            rows: self.rows(),
            cols: self.cols(),
            cell_size: self.cell_size,
            nodata: self.nodata,
            extent: self.extent.clone(),
            crs: self.crs.clone(),
            elevation: self.elevation.iter().cloned().collect(),
        };
        Ok(serde_json::to_string(&data)?)
    }

    /// Load DEM from JSON format.
    pub fn from_json(json: &str) -> Result<Self, TerrainError> {
        let data: DemSerializable = serde_json::from_str(json)?;
        let mut dem = Self::from_vec(data.elevation, data.rows, data.cols, data.cell_size, data.nodata)?;
        dem.extent = data.extent;
        dem.crs = data.crs;
        Ok(dem)
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

/// Serializable form of a DEM for JSON I/O.
#[derive(Debug, Clone, Serialize, Deserialize)]
struct DemSerializable {
    rows: usize,
    cols: usize,
    cell_size: f64,
    nodata: f64,
    extent: Option<DemExtent>,
    crs: Option<String>,
    elevation: Vec<f64>,
}

/// Catmull-Rom cubic weight function (a = -0.5).
fn cubic_weight(t: f64) -> f64 {
    let t = t.abs();
    if t <= 1.0 {
        (1.5 * t - 2.5) * t * t + 1.0
    } else if t <= 2.0 {
        ((-0.5 * t + 2.5) * t - 4.0) * t + 2.0
    } else {
        0.0
    }
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

    #[test]
    fn test_bilinear_interpolation() {
        let dem = Dem::from_vec(
            vec![0.0, 10.0, 0.0, 10.0],
            2, 2, 10.0, -9999.0,
        ).unwrap();
        let val = dem.interpolate_bilinear(0.5, 0.5).unwrap();
        assert!((val - 5.0).abs() < 1e-10);
    }

    #[test]
    fn test_hillshade() {
        let dem = Dem::from_vec(
            vec![100.0; 9], 3, 3, 10.0, -9999.0,
        ).unwrap();
        let hs = dem.hillshade(315.0, 45.0, 1.0);
        // Flat terrain should have uniform hillshade
        assert!(hs[[1, 1]] > 0.0);
    }

    #[test]
    fn test_terrain_ruggedness_index() {
        let dem = Dem::from_vec(
            vec![100.0; 9], 3, 3, 10.0, -9999.0,
        ).unwrap();
        let tri = dem.terrain_ruggedness_index();
        assert!((tri[[1, 1]] - 0.0).abs() < 1e-10);
    }

    #[test]
    fn test_topographic_position_index() {
        // Center is higher than neighbors
        let dem = Dem::from_vec(
            vec![10.0, 10.0, 10.0,
                 10.0, 20.0, 10.0,
                 10.0, 10.0, 10.0],
            3, 3, 10.0, -9999.0,
        ).unwrap();
        let tpi = dem.topographic_position_index();
        assert!((tpi[[1, 1]] - 10.0).abs() < 1e-10);
    }

    #[test]
    fn test_json_roundtrip() {
        let dem = Dem::from_vec(
            vec![100.0, 200.0, 150.0, 300.0],
            2, 2, 10.0, -9999.0,
        ).unwrap();
        let json = dem.to_json().unwrap();
        let dem2 = Dem::from_json(&json).unwrap();
        assert_eq!(dem2.rows(), 2);
        assert_eq!(dem2.cols(), 2);
        assert!((dem2.elevation[[0, 0]] - 100.0).abs() < 1e-10);
    }
}
