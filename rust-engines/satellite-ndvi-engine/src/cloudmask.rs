//! Per-pixel cloud, shadow, and snow masking from sensor QA layers.
//!
//! Supports the Sentinel-2 L2A Scene Classification Layer (SCL) and the
//! Landsat Collection 2 `QA_PIXEL` bit mask. A [`CloudMask`] is a boolean
//! validity grid plus summary fractions, and can be dilated to buffer cloud
//! edges before being applied to reflectance or index bands.

use ndarray::Array2;

use crate::raster::{RasterBand, RasterError};

/// Sentinel-2 SCL class codes.
pub mod scl {
    pub const NO_DATA: u8 = 0;
    pub const SATURATED_OR_DEFECTIVE: u8 = 1;
    pub const DARK_AREA: u8 = 2;
    pub const CLOUD_SHADOW: u8 = 3;
    pub const VEGETATION: u8 = 4;
    pub const NOT_VEGETATED: u8 = 5;
    pub const WATER: u8 = 6;
    pub const UNCLASSIFIED: u8 = 7;
    pub const CLOUD_MEDIUM_PROBABILITY: u8 = 8;
    pub const CLOUD_HIGH_PROBABILITY: u8 = 9;
    pub const THIN_CIRRUS: u8 = 10;
    pub const SNOW_OR_ICE: u8 = 11;
}

/// Landsat Collection 2 QA_PIXEL bit positions.
pub mod qa_pixel {
    pub const FILL: u16 = 1 << 0;
    pub const DILATED_CLOUD: u16 = 1 << 1;
    pub const CIRRUS: u16 = 1 << 2;
    pub const CLOUD: u16 = 1 << 3;
    pub const CLOUD_SHADOW: u16 = 1 << 4;
    pub const SNOW: u16 = 1 << 5;
    pub const CLEAR: u16 = 1 << 6;
    pub const WATER: u16 = 1 << 7;
}

/// Controls which QA classes are treated as invalid.
#[derive(Debug, Clone)]
pub struct MaskParams {
    /// Mask thin cirrus (SCL 10 / QA cirrus bit).
    pub mask_cirrus: bool,
    /// Mask snow and ice.
    pub mask_snow: bool,
    /// Mask SCL medium-probability cloud (8). High probability (9) is always masked.
    pub mask_medium_probability_cloud: bool,
    /// Mask SCL unclassified (7) and dark-area (2) pixels.
    pub mask_unclassified: bool,
    /// Mask Landsat dilated-cloud bit.
    pub mask_dilated_cloud: bool,
    /// Grow invalid regions by this many pixels to suppress cloud-edge contamination.
    pub buffer_pixels: usize,
}

impl Default for MaskParams {
    fn default() -> Self {
        Self {
            mask_cirrus: true,
            mask_snow: true,
            mask_medium_probability_cloud: true,
            mask_unclassified: false,
            mask_dilated_cloud: true,
            buffer_pixels: 1,
        }
    }
}

/// A per-pixel validity mask with summary fractions.
#[derive(Debug, Clone)]
pub struct CloudMask {
    /// `true` where the pixel is usable.
    pub valid: Array2<bool>,
    pub cloud_fraction: f64,
    pub shadow_fraction: f64,
    pub snow_fraction: f64,
    pub nodata_fraction: f64,
}

impl CloudMask {
    /// A mask that keeps every pixel.
    pub fn all_valid(rows: usize, cols: usize) -> Self {
        Self {
            valid: Array2::from_elem((rows, cols), true),
            cloud_fraction: 0.0,
            shadow_fraction: 0.0,
            snow_fraction: 0.0,
            nodata_fraction: 0.0,
        }
    }

    pub fn rows(&self) -> usize {
        self.valid.nrows()
    }

    pub fn cols(&self) -> usize {
        self.valid.ncols()
    }

    /// Fraction of pixels that remain valid.
    pub fn valid_fraction(&self) -> f64 {
        let total = self.valid.len();
        if total == 0 {
            return 0.0;
        }
        self.valid.iter().filter(|v| **v).count() as f64 / total as f64
    }

    /// Build a mask from a Sentinel-2 SCL band (values 0..=11).
    pub fn from_scl(scl_band: &RasterBand, params: &MaskParams) -> Self {
        let rows = scl_band.rows();
        let cols = scl_band.cols();
        let mut valid = Array2::from_elem((rows, cols), true);
        let (mut cloud, mut shadow, mut snow, mut nodata) = (0usize, 0usize, 0usize, 0usize);

        for r in 0..rows {
            for c in 0..cols {
                let v = scl_band.data[[r, c]];
                let code = if v.is_nan() || v < 0.0 {
                    scl::NO_DATA
                } else {
                    v.round() as u8
                };
                let invalid = match code {
                    scl::NO_DATA | scl::SATURATED_OR_DEFECTIVE => {
                        nodata += 1;
                        true
                    }
                    scl::CLOUD_HIGH_PROBABILITY => {
                        cloud += 1;
                        true
                    }
                    scl::CLOUD_MEDIUM_PROBABILITY => {
                        cloud += 1;
                        params.mask_medium_probability_cloud
                    }
                    scl::THIN_CIRRUS => {
                        cloud += 1;
                        params.mask_cirrus
                    }
                    scl::CLOUD_SHADOW => {
                        shadow += 1;
                        true
                    }
                    scl::SNOW_OR_ICE => {
                        snow += 1;
                        params.mask_snow
                    }
                    scl::DARK_AREA | scl::UNCLASSIFIED => params.mask_unclassified,
                    _ => false,
                };
                if invalid {
                    valid[[r, c]] = false;
                }
            }
        }

        let total = (rows * cols).max(1) as f64;
        let mut mask = Self {
            valid,
            cloud_fraction: cloud as f64 / total,
            shadow_fraction: shadow as f64 / total,
            snow_fraction: snow as f64 / total,
            nodata_fraction: nodata as f64 / total,
        };
        mask.dilate(params.buffer_pixels);
        mask
    }

    /// Build a mask from a Landsat Collection 2 QA_PIXEL band.
    pub fn from_qa_pixel(qa_band: &RasterBand, params: &MaskParams) -> Self {
        let rows = qa_band.rows();
        let cols = qa_band.cols();
        let mut valid = Array2::from_elem((rows, cols), true);
        let (mut cloud, mut shadow, mut snow, mut nodata) = (0usize, 0usize, 0usize, 0usize);

        for r in 0..rows {
            for c in 0..cols {
                let v = qa_band.data[[r, c]];
                let bits = if v.is_nan() || v < 0.0 {
                    qa_pixel::FILL
                } else {
                    v.round() as u16
                };
                let mut invalid = false;
                if bits & qa_pixel::FILL != 0 {
                    nodata += 1;
                    invalid = true;
                }
                if bits & qa_pixel::CLOUD != 0 {
                    cloud += 1;
                    invalid = true;
                }
                if bits & qa_pixel::DILATED_CLOUD != 0 {
                    cloud += 1;
                    invalid |= params.mask_dilated_cloud;
                }
                if bits & qa_pixel::CIRRUS != 0 {
                    cloud += 1;
                    invalid |= params.mask_cirrus;
                }
                if bits & qa_pixel::CLOUD_SHADOW != 0 {
                    shadow += 1;
                    invalid = true;
                }
                if bits & qa_pixel::SNOW != 0 {
                    snow += 1;
                    invalid |= params.mask_snow;
                }
                if invalid {
                    valid[[r, c]] = false;
                }
            }
        }

        let total = (rows * cols).max(1) as f64;
        let mut mask = Self {
            valid,
            cloud_fraction: (cloud as f64 / total).min(1.0),
            shadow_fraction: shadow as f64 / total,
            snow_fraction: snow as f64 / total,
            nodata_fraction: nodata as f64 / total,
        };
        mask.dilate(params.buffer_pixels);
        mask
    }

    /// Grow invalid regions by `pixels` in every direction (square structuring element).
    pub fn dilate(&mut self, pixels: usize) {
        if pixels == 0 {
            return;
        }
        let rows = self.rows();
        let cols = self.cols();
        let src = self.valid.clone();
        let p = pixels as isize;
        for r in 0..rows {
            for c in 0..cols {
                if src[[r, c]] {
                    continue;
                }
                let r0 = (r as isize - p).max(0) as usize;
                let r1 = (r as isize + p).min(rows as isize - 1) as usize;
                let c0 = (c as isize - p).max(0) as usize;
                let c1 = (c as isize + p).min(cols as isize - 1) as usize;
                for rr in r0..=r1 {
                    for cc in c0..=c1 {
                        self.valid[[rr, cc]] = false;
                    }
                }
            }
        }
    }

    /// Combine two masks; a pixel is valid only if valid in both.
    pub fn intersect(&self, other: &CloudMask) -> Result<CloudMask, RasterError> {
        if self.rows() != other.rows() || self.cols() != other.cols() {
            return Err(RasterError::DimensionMismatch {
                expected_rows: self.rows(),
                expected_cols: self.cols(),
                actual_rows: other.rows(),
                actual_cols: other.cols(),
            });
        }
        let valid = Array2::from_shape_fn((self.rows(), self.cols()), |(r, c)| {
            self.valid[[r, c]] && other.valid[[r, c]]
        });
        Ok(CloudMask {
            valid,
            cloud_fraction: self.cloud_fraction.max(other.cloud_fraction),
            shadow_fraction: self.shadow_fraction.max(other.shadow_fraction),
            snow_fraction: self.snow_fraction.max(other.snow_fraction),
            nodata_fraction: self.nodata_fraction.max(other.nodata_fraction),
        })
    }

    /// Return a copy of `band` with invalid pixels set to `nodata_output`.
    pub fn apply(&self, band: &RasterBand, nodata_output: f64) -> Result<RasterBand, RasterError> {
        if band.rows() != self.rows() || band.cols() != self.cols() {
            return Err(RasterError::DimensionMismatch {
                expected_rows: self.rows(),
                expected_cols: self.cols(),
                actual_rows: band.rows(),
                actual_cols: band.cols(),
            });
        }
        let mut data = band.data.clone();
        for r in 0..self.rows() {
            for c in 0..self.cols() {
                if !self.valid[[r, c]] || band.is_nodata(r, c) {
                    data[[r, c]] = nodata_output;
                }
            }
        }
        Ok(RasterBand::new(data, Some(nodata_output)))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn band(values: Vec<f64>, rows: usize, cols: usize) -> RasterBand {
        RasterBand::from_vec(values, rows, cols, None).unwrap()
    }

    fn no_buffer() -> MaskParams {
        MaskParams {
            buffer_pixels: 0,
            ..MaskParams::default()
        }
    }

    #[test]
    fn test_scl_classes() {
        // row 0: veg, cloud-high, shadow ; row 1: cirrus, snow, nodata
        let scl = band(vec![4.0, 9.0, 3.0, 10.0, 11.0, 0.0], 2, 3);
        let m = CloudMask::from_scl(&scl, &no_buffer());
        assert!(m.valid[[0, 0]]);
        assert!(!m.valid[[0, 1]]);
        assert!(!m.valid[[0, 2]]);
        assert!(!m.valid[[1, 0]]);
        assert!(!m.valid[[1, 1]]);
        assert!(!m.valid[[1, 2]]);
        assert!((m.cloud_fraction - 2.0 / 6.0).abs() < 1e-12);
        assert!((m.shadow_fraction - 1.0 / 6.0).abs() < 1e-12);
        assert!((m.snow_fraction - 1.0 / 6.0).abs() < 1e-12);
        assert!((m.nodata_fraction - 1.0 / 6.0).abs() < 1e-12);
        assert!((m.valid_fraction() - 1.0 / 6.0).abs() < 1e-12);
    }

    #[test]
    fn test_scl_optional_classes() {
        let scl = band(vec![8.0, 10.0, 11.0, 7.0], 2, 2);
        let lenient = MaskParams {
            mask_cirrus: false,
            mask_snow: false,
            mask_medium_probability_cloud: false,
            mask_unclassified: false,
            buffer_pixels: 0,
            ..MaskParams::default()
        };
        let m = CloudMask::from_scl(&scl, &lenient);
        assert_eq!(m.valid_fraction(), 1.0);

        let strict = MaskParams {
            mask_unclassified: true,
            buffer_pixels: 0,
            ..MaskParams::default()
        };
        let m = CloudMask::from_scl(&scl, &strict);
        assert_eq!(m.valid_fraction(), 0.0);
    }

    #[test]
    fn test_qa_pixel_bits() {
        let clear = qa_pixel::CLEAR as f64;
        let cloud = (qa_pixel::CLOUD | qa_pixel::DILATED_CLOUD) as f64;
        let shadow = qa_pixel::CLOUD_SHADOW as f64;
        let fill = qa_pixel::FILL as f64;
        let qa = band(vec![clear, cloud, shadow, fill], 2, 2);
        let m = CloudMask::from_qa_pixel(&qa, &no_buffer());
        assert!(m.valid[[0, 0]]);
        assert!(!m.valid[[0, 1]]);
        assert!(!m.valid[[1, 0]]);
        assert!(!m.valid[[1, 1]]);
        assert!((m.shadow_fraction - 0.25).abs() < 1e-12);
        assert!((m.nodata_fraction - 0.25).abs() < 1e-12);
    }

    #[test]
    fn test_dilation_buffers_cloud_edges() {
        // Single cloud pixel in the centre of a 5x5 grid.
        let mut v = vec![4.0; 25];
        v[12] = 9.0;
        let scl = band(v, 5, 5);
        let m = CloudMask::from_scl(
            &scl,
            &MaskParams {
                buffer_pixels: 1,
                ..MaskParams::default()
            },
        );
        // 3x3 neighbourhood masked
        assert_eq!(m.valid.iter().filter(|x| !**x).count(), 9);
        assert!(!m.valid[[1, 1]] && !m.valid[[3, 3]]);
        assert!(m.valid[[0, 0]] && m.valid[[4, 4]]);
    }

    #[test]
    fn test_apply_and_intersect() {
        let scl = band(vec![4.0, 9.0, 4.0, 4.0], 2, 2);
        let m1 = CloudMask::from_scl(&scl, &no_buffer());
        let qa = band(vec![64.0, 64.0, 64.0, 8.0], 2, 2);
        let m2 = CloudMask::from_qa_pixel(&qa, &no_buffer());
        let both = m1.intersect(&m2).unwrap();
        assert_eq!(both.valid.iter().filter(|x| **x).count(), 2);

        let ndvi = band(vec![0.5, 0.6, 0.7, 0.8], 2, 2);
        let masked = both.apply(&ndvi, -9999.0).unwrap();
        assert_eq!(masked.data[[0, 0]], 0.5);
        assert!(masked.is_nodata(0, 1));
        assert_eq!(masked.data[[1, 0]], 0.7);
        assert!(masked.is_nodata(1, 1));
        assert_eq!(masked.valid_pixel_count(), 2);
    }

    #[test]
    fn test_dimension_mismatch() {
        let m = CloudMask::all_valid(2, 2);
        let b = band(vec![0.0; 6], 2, 3);
        assert!(matches!(
            m.apply(&b, -1.0),
            Err(RasterError::DimensionMismatch { .. })
        ));
        let other = CloudMask::all_valid(3, 3);
        assert!(m.intersect(&other).is_err());
    }
}
