//! Image preprocessing for pest detection inference.
//!
//! Mirrors the Python transforms from `pest_detection/transforms.py`:
//! Input size 320, resize to 352 (320 * 1.1), center crop to 320,
//! ImageNet normalization.

use ndarray::Array3;
use rayon::prelude::*;
use thiserror::Error;

/// Default input image size for pest detection (MobileNetV3-Large).
pub const DEFAULT_IMAGE_SIZE: u32 = 320;

/// ImageNet normalization constants.
pub const IMAGENET_MEAN: [f32; 3] = [0.485, 0.456, 0.406];
pub const IMAGENET_STD: [f32; 3] = [0.229, 0.224, 0.225];

/// Errors during preprocessing.
#[derive(Debug, Error)]
pub enum PreprocessError {
    #[error("Invalid image dimensions: {width}x{height}")]
    InvalidDimensions { width: u32, height: u32 },

    #[error("Buffer size mismatch: expected {expected}, got {actual}")]
    BufferMismatch { expected: usize, actual: usize },
}

/// Raw RGB image buffer.
#[derive(Debug, Clone)]
pub struct ImageBuffer {
    pub data: Vec<u8>,
    pub width: u32,
    pub height: u32,
}

impl ImageBuffer {
    /// Create from raw RGB bytes.
    pub fn from_rgb(data: Vec<u8>, width: u32, height: u32) -> Result<Self, PreprocessError> {
        let expected = (width * height * 3) as usize;
        if data.len() != expected {
            return Err(PreprocessError::BufferMismatch { expected, actual: data.len() });
        }
        if width == 0 || height == 0 {
            return Err(PreprocessError::InvalidDimensions { width, height });
        }
        Ok(Self { data, width, height })
    }

    #[inline]
    pub fn pixel(&self, row: u32, col: u32, ch: u32) -> u8 {
        self.data[((row * self.width + col) * 3 + ch) as usize]
    }
}

/// Preprocessing configuration.
#[derive(Debug, Clone)]
pub struct PreprocessConfig {
    pub target_size: u32,
    pub resize_size: u32,
    pub mean: [f32; 3],
    pub std: [f32; 3],
}

impl Default for PreprocessConfig {
    fn default() -> Self {
        let target = DEFAULT_IMAGE_SIZE;
        Self {
            target_size: target,
            resize_size: (target as f32 * 1.1) as u32,
            mean: IMAGENET_MEAN,
            std: IMAGENET_STD,
        }
    }
}

/// Preprocess an image for pest detection inference.
pub fn preprocess_image(
    image: &ImageBuffer,
    config: &PreprocessConfig,
) -> Result<Array3<f32>, PreprocessError> {
    let resized = bilinear_resize(image, config.resize_size, config.resize_size);
    let crop_offset = (config.resize_size - config.target_size) / 2;
    let ts = config.target_size as usize;

    let mut output = Array3::<f32>::zeros((3, ts, ts));
    for row in 0..ts {
        let src_row = (crop_offset as usize + row).min(config.resize_size as usize - 1);
        for col in 0..ts {
            let src_col = (crop_offset as usize + col).min(config.resize_size as usize - 1);
            for ch in 0..3 {
                let val = resized.pixel(src_row as u32, src_col as u32, ch as u32) as f32 / 255.0;
                output[[ch, row, col]] = (val - config.mean[ch]) / config.std[ch];
            }
        }
    }

    Ok(output)
}

/// Preprocess a batch of images in parallel.
pub fn preprocess_batch(
    images: &[ImageBuffer],
    config: &PreprocessConfig,
) -> Result<Vec<Array3<f32>>, PreprocessError> {
    images.par_iter().map(|img| preprocess_image(img, config)).collect()
}

fn bilinear_resize(image: &ImageBuffer, target_w: u32, target_h: u32) -> ImageBuffer {
    let src_w = image.width as f64;
    let src_h = image.height as f64;
    let dst_w = target_w as f64;
    let dst_h = target_h as f64;

    let rows: Vec<Vec<u8>> = (0..target_h)
        .into_par_iter()
        .map(|dst_row| {
            let mut row_data = Vec::with_capacity((target_w * 3) as usize);
            let src_y = (dst_row as f64 + 0.5) * src_h / dst_h - 0.5;
            let y0 = (src_y.floor() as i64).clamp(0, image.height as i64 - 1) as u32;
            let y1 = (y0 + 1).min(image.height - 1);
            let fy = (src_y - src_y.floor()) as f32;

            for dst_col in 0..target_w {
                let src_x = (dst_col as f64 + 0.5) * src_w / dst_w - 0.5;
                let x0 = (src_x.floor() as i64).clamp(0, image.width as i64 - 1) as u32;
                let x1 = (x0 + 1).min(image.width - 1);
                let fx = (src_x - src_x.floor()) as f32;

                for ch in 0..3u32 {
                    let v00 = image.pixel(y0, x0, ch) as f32;
                    let v10 = image.pixel(y0, x1, ch) as f32;
                    let v01 = image.pixel(y1, x0, ch) as f32;
                    let v11 = image.pixel(y1, x1, ch) as f32;
                    let v = v00 * (1.0 - fx) * (1.0 - fy)
                        + v10 * fx * (1.0 - fy)
                        + v01 * (1.0 - fx) * fy
                        + v11 * fx * fy;
                    row_data.push(v.round().clamp(0.0, 255.0) as u8);
                }
            }
            row_data
        })
        .collect();

    let data: Vec<u8> = rows.into_iter().flatten().collect();
    ImageBuffer { data, width: target_w, height: target_h }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_preprocess_shape() {
        let img = ImageBuffer::from_rgb(vec![128; 300 * 300 * 3], 300, 300).unwrap();
        let config = PreprocessConfig::default();
        let tensor = preprocess_image(&img, &config).unwrap();
        assert_eq!(tensor.shape(), &[3, 320, 320]);
    }
}
