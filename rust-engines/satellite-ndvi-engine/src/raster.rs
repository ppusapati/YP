//! Raster band data structures and I/O for satellite imagery processing.

use ndarray::Array2;
use serde::{Deserialize, Serialize};
use thiserror::Error;

/// Errors that can occur during raster operations.
#[derive(Debug, Error)]
pub enum RasterError {
    #[error("Band dimension mismatch: expected {expected_rows}x{expected_cols}, got {actual_rows}x{actual_cols}")]
    DimensionMismatch {
        expected_rows: usize,
        expected_cols: usize,
        actual_rows: usize,
        actual_cols: usize,
    },

    #[error("Band index {index} out of range (available: 0..{count})")]
    BandIndexOutOfRange { index: usize, count: usize },

    #[error("Invalid pixel value at ({row}, {col}): {reason}")]
    InvalidPixelValue {
        row: usize,
        col: usize,
        reason: String,
    },

    #[error("Empty raster: no data provided")]
    EmptyRaster,

    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),

    #[error("JSON serialization error: {0}")]
    Json(#[from] serde_json::Error),
}

/// Geospatial extent (bounding box) of a raster.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GeoExtent {
    pub min_x: f64,
    pub min_y: f64,
    pub max_x: f64,
    pub max_y: f64,
}

impl GeoExtent {
    pub fn new(min_x: f64, min_y: f64, max_x: f64, max_y: f64) -> Self {
        Self {
            min_x,
            min_y,
            max_x,
            max_y,
        }
    }

    /// Width in coordinate units.
    pub fn width(&self) -> f64 {
        self.max_x - self.min_x
    }

    /// Height in coordinate units.
    pub fn height(&self) -> f64 {
        self.max_y - self.min_y
    }

    /// Pixel resolution given raster dimensions.
    pub fn pixel_size(&self, rows: usize, cols: usize) -> (f64, f64) {
        (self.width() / cols as f64, self.height() / rows as f64)
    }
}

/// A single spectral band stored as a 2D float array.
#[derive(Debug, Clone)]
pub struct RasterBand {
    pub data: Array2<f64>,
    pub nodata_value: Option<f64>,
}

impl RasterBand {
    /// Create a new raster band from raw data.
    pub fn new(data: Array2<f64>, nodata_value: Option<f64>) -> Self {
        Self { data, nodata_value }
    }

    /// Create a band from a flat vector of values.
    pub fn from_vec(values: Vec<f64>, rows: usize, cols: usize, nodata_value: Option<f64>) -> Result<Self, RasterError> {
        if values.is_empty() {
            return Err(RasterError::EmptyRaster);
        }
        if values.len() != rows * cols {
            return Err(RasterError::DimensionMismatch {
                expected_rows: rows,
                expected_cols: cols,
                actual_rows: values.len() / cols.max(1),
                actual_cols: if rows > 0 { values.len() / rows } else { 0 },
            });
        }
        let data = Array2::from_shape_vec((rows, cols), values)
            .map_err(|_| RasterError::DimensionMismatch {
                expected_rows: rows,
                expected_cols: cols,
                actual_rows: 0,
                actual_cols: 0,
            })?;
        Ok(Self { data, nodata_value })
    }

    /// Create a zero-filled band.
    pub fn zeros(rows: usize, cols: usize) -> Self {
        Self {
            data: Array2::zeros((rows, cols)),
            nodata_value: None,
        }
    }

    pub fn rows(&self) -> usize {
        self.data.nrows()
    }

    pub fn cols(&self) -> usize {
        self.data.ncols()
    }

    /// Check if a pixel is nodata.
    pub fn is_nodata(&self, row: usize, col: usize) -> bool {
        match self.nodata_value {
            Some(nd) => {
                let val = self.data[[row, col]];
                (val - nd).abs() < f64::EPSILON || val.is_nan()
            }
            None => self.data[[row, col]].is_nan(),
        }
    }

    /// Get valid (non-nodata) pixel count.
    pub fn valid_pixel_count(&self) -> usize {
        let mut count = 0;
        for row in 0..self.rows() {
            for col in 0..self.cols() {
                if !self.is_nodata(row, col) {
                    count += 1;
                }
            }
        }
        count
    }
}

/// Multi-band satellite raster image.
#[derive(Debug, Clone)]
pub struct MultiBandRaster {
    pub bands: Vec<RasterBand>,
    pub extent: Option<GeoExtent>,
    pub crs: Option<String>,
}

impl MultiBandRaster {
    /// Create a new multi-band raster, validating all bands have the same dimensions.
    pub fn new(bands: Vec<RasterBand>, extent: Option<GeoExtent>, crs: Option<String>) -> Result<Self, RasterError> {
        if bands.is_empty() {
            return Err(RasterError::EmptyRaster);
        }
        let (rows, cols) = (bands[0].rows(), bands[0].cols());
        for (i, band) in bands.iter().enumerate().skip(1) {
            if band.rows() != rows || band.cols() != cols {
                return Err(RasterError::DimensionMismatch {
                    expected_rows: rows,
                    expected_cols: cols,
                    actual_rows: band.rows(),
                    actual_cols: band.cols(),
                });
            }
        }
        Ok(Self { bands, extent, crs })
    }

    pub fn rows(&self) -> usize {
        self.bands[0].rows()
    }

    pub fn cols(&self) -> usize {
        self.bands[0].cols()
    }

    pub fn band_count(&self) -> usize {
        self.bands.len()
    }

    /// Get a specific band by index.
    pub fn band(&self, index: usize) -> Result<&RasterBand, RasterError> {
        self.bands.get(index).ok_or(RasterError::BandIndexOutOfRange {
            index,
            count: self.bands.len(),
        })
    }
}

/// Resample a raster band to new dimensions using bilinear interpolation.
pub fn resample_bilinear(band: &RasterBand, target_rows: usize, target_cols: usize) -> RasterBand {
    let src_rows = band.rows() as f64;
    let src_cols = band.cols() as f64;
    let dst_rows = target_rows as f64;
    let dst_cols = target_cols as f64;

    let result_rows: Vec<Vec<f64>> = (0..target_rows)
        .into_par_iter()
        .map(|r| {
            let mut row_vals = Vec::with_capacity(target_cols);
            let src_r = (r as f64 + 0.5) * src_rows / dst_rows - 0.5;
            let r0 = (src_r.floor() as isize).clamp(0, band.rows() as isize - 1) as usize;
            let r1 = (r0 + 1).min(band.rows() - 1);
            let fr = src_r - src_r.floor();

            for c in 0..target_cols {
                let src_c = (c as f64 + 0.5) * src_cols / dst_cols - 0.5;
                let c0 = (src_c.floor() as isize).clamp(0, band.cols() as isize - 1) as usize;
                let c1 = (c0 + 1).min(band.cols() - 1);
                let fc = src_c - src_c.floor();

                // Check for nodata
                if band.is_nodata(r0, c0) || band.is_nodata(r0, c1)
                    || band.is_nodata(r1, c0) || band.is_nodata(r1, c1)
                {
                    row_vals.push(band.nodata_value.unwrap_or(f64::NAN));
                    continue;
                }

                let v00 = band.data[[r0, c0]];
                let v01 = band.data[[r0, c1]];
                let v10 = band.data[[r1, c0]];
                let v11 = band.data[[r1, c1]];

                let val = v00 * (1.0 - fr) * (1.0 - fc)
                    + v01 * (1.0 - fr) * fc
                    + v10 * fr * (1.0 - fc)
                    + v11 * fr * fc;
                row_vals.push(val);
            }
            row_vals
        })
        .collect();

    let flat: Vec<f64> = result_rows.into_iter().flatten().collect();
    let data = ndarray::Array2::from_shape_vec((target_rows, target_cols), flat).unwrap();
    RasterBand::new(data, band.nodata_value)
}

/// Resample using nearest-neighbor interpolation.
pub fn resample_nearest(band: &RasterBand, target_rows: usize, target_cols: usize) -> RasterBand {
    let src_rows = band.rows() as f64;
    let src_cols = band.cols() as f64;
    let dst_rows = target_rows as f64;
    let dst_cols = target_cols as f64;

    let result_rows: Vec<Vec<f64>> = (0..target_rows)
        .into_par_iter()
        .map(|r| {
            let src_r = ((r as f64 + 0.5) * src_rows / dst_rows) as usize;
            let src_r = src_r.min(band.rows() - 1);
            (0..target_cols)
                .map(|c| {
                    let src_c = ((c as f64 + 0.5) * src_cols / dst_cols) as usize;
                    let src_c = src_c.min(band.cols() - 1);
                    band.data[[src_r, src_c]]
                })
                .collect()
        })
        .collect();

    let flat: Vec<f64> = result_rows.into_iter().flatten().collect();
    let data = ndarray::Array2::from_shape_vec((target_rows, target_cols), flat).unwrap();
    RasterBand::new(data, band.nodata_value)
}

/// Clip a raster band to a rectangular extent, returning the clipped sub-region.
///
/// `row_start`, `col_start` are the top-left corner of the clip window.
/// `clip_rows`, `clip_cols` define the size.
pub fn clip_to_window(
    band: &RasterBand,
    row_start: usize,
    col_start: usize,
    clip_rows: usize,
    clip_cols: usize,
) -> Result<RasterBand, RasterError> {
    if row_start + clip_rows > band.rows() || col_start + clip_cols > band.cols() {
        return Err(RasterError::DimensionMismatch {
            expected_rows: clip_rows,
            expected_cols: clip_cols,
            actual_rows: band.rows().saturating_sub(row_start),
            actual_cols: band.cols().saturating_sub(col_start),
        });
    }

    let slice = band.data.slice(ndarray::s![
        row_start..row_start + clip_rows,
        col_start..col_start + clip_cols
    ]);
    Ok(RasterBand::new(slice.to_owned(), band.nodata_value))
}

/// Clip a raster band using a polygon mask.
/// Pixels outside the polygon are set to nodata.
///
/// The polygon is specified as a list of (row, col) vertices.
/// Uses ray-casting for point-in-polygon testing.
pub fn clip_to_polygon(
    band: &RasterBand,
    polygon: &[(f64, f64)],
    nodata: f64,
) -> RasterBand {
    let rows = band.rows();
    let cols = band.cols();

    let result_rows: Vec<Vec<f64>> = (0..rows)
        .into_par_iter()
        .map(|r| {
            (0..cols)
                .map(|c| {
                    if point_in_polygon(r as f64 + 0.5, c as f64 + 0.5, polygon) {
                        band.data[[r, c]]
                    } else {
                        nodata
                    }
                })
                .collect()
        })
        .collect();

    let flat: Vec<f64> = result_rows.into_iter().flatten().collect();
    let data = ndarray::Array2::from_shape_vec((rows, cols), flat).unwrap();
    RasterBand::new(data, Some(nodata))
}

/// Ray-casting point-in-polygon test.
fn point_in_polygon(row: f64, col: f64, polygon: &[(f64, f64)]) -> bool {
    let n = polygon.len();
    if n < 3 {
        return false;
    }
    let mut inside = false;
    let mut j = n - 1;
    for i in 0..n {
        let (ri, ci) = polygon[i];
        let (rj, cj) = polygon[j];
        if ((ri > row) != (rj > row))
            && (col < (cj - ci) * (row - ri) / (rj - ri) + ci)
        {
            inside = !inside;
        }
        j = i;
    }
    inside
}

/// Apply a mathematical operation to every valid pixel in a band.
pub fn apply_operation(band: &RasterBand, f: impl Fn(f64) -> f64 + Sync) -> RasterBand {
    let rows = band.rows();
    let cols = band.cols();

    let result_rows: Vec<Vec<f64>> = (0..rows)
        .into_par_iter()
        .map(|r| {
            (0..cols)
                .map(|c| {
                    if band.is_nodata(r, c) {
                        band.nodata_value.unwrap_or(f64::NAN)
                    } else {
                        f(band.data[[r, c]])
                    }
                })
                .collect()
        })
        .collect();

    let flat: Vec<f64> = result_rows.into_iter().flatten().collect();
    let data = ndarray::Array2::from_shape_vec((rows, cols), flat).unwrap();
    RasterBand::new(data, band.nodata_value)
}

/// Metadata for raster datasets.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RasterMetadata {
    pub rows: usize,
    pub cols: usize,
    pub band_count: usize,
    pub pixel_size_x: Option<f64>,
    pub pixel_size_y: Option<f64>,
    pub crs: Option<String>,
    pub extent: Option<GeoExtent>,
    pub nodata_value: Option<f64>,
}

impl RasterMetadata {
    pub fn from_raster(raster: &MultiBandRaster) -> Self {
        let (px, py) = raster
            .extent
            .as_ref()
            .map(|e| e.pixel_size(raster.rows(), raster.cols()))
            .unwrap_or((1.0, 1.0));
        Self {
            rows: raster.rows(),
            cols: raster.cols(),
            band_count: raster.band_count(),
            pixel_size_x: Some(px),
            pixel_size_y: Some(py),
            crs: raster.crs.clone(),
            extent: raster.extent.clone(),
            nodata_value: raster.bands[0].nodata_value,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_raster_band_from_vec() {
        let band = RasterBand::from_vec(vec![1.0, 2.0, 3.0, 4.0, 5.0, 6.0], 2, 3, None).unwrap();
        assert_eq!(band.rows(), 2);
        assert_eq!(band.cols(), 3);
        assert_eq!(band.data[[0, 0]], 1.0);
        assert_eq!(band.data[[1, 2]], 6.0);
    }

    #[test]
    fn test_raster_band_dimension_mismatch() {
        let result = RasterBand::from_vec(vec![1.0, 2.0, 3.0], 2, 3, None);
        assert!(result.is_err());
    }

    #[test]
    fn test_raster_band_nodata() {
        let band = RasterBand::from_vec(vec![-9999.0, 2.0, 3.0, 4.0], 2, 2, Some(-9999.0)).unwrap();
        assert!(band.is_nodata(0, 0));
        assert!(!band.is_nodata(0, 1));
        assert_eq!(band.valid_pixel_count(), 3);
    }

    #[test]
    fn test_multi_band_raster() {
        let b1 = RasterBand::from_vec(vec![1.0; 9], 3, 3, None).unwrap();
        let b2 = RasterBand::from_vec(vec![2.0; 9], 3, 3, None).unwrap();
        let raster = MultiBandRaster::new(vec![b1, b2], None, None).unwrap();
        assert_eq!(raster.band_count(), 2);
        assert_eq!(raster.rows(), 3);
        assert_eq!(raster.cols(), 3);
    }

    #[test]
    fn test_multi_band_dimension_mismatch() {
        let b1 = RasterBand::from_vec(vec![1.0; 9], 3, 3, None).unwrap();
        let b2 = RasterBand::from_vec(vec![2.0; 4], 2, 2, None).unwrap();
        let result = MultiBandRaster::new(vec![b1, b2], None, None);
        assert!(result.is_err());
    }

    #[test]
    fn test_geo_extent() {
        let extent = GeoExtent::new(0.0, 0.0, 10.0, 20.0);
        assert_eq!(extent.width(), 10.0);
        assert_eq!(extent.height(), 20.0);
        let (px, py) = extent.pixel_size(20, 10);
        assert!((px - 1.0).abs() < f64::EPSILON);
        assert!((py - 1.0).abs() < f64::EPSILON);
    }
}
