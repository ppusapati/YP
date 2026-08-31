//! Image preprocessing for AI model inference.

use ndarray::Array3;
use rayon::prelude::*;
use serde::{Deserialize, Serialize};
use thiserror::Error;

/// Errors during image preprocessing.
#[derive(Debug, Error)]
pub enum PreprocessError {
    #[error("Invalid image dimensions: {width}x{height}, expected at least 1x1")]
    InvalidDimensions { width: u32, height: u32 },

    #[error("Unsupported channel count: {0} (expected 1, 3, or 4)")]
    UnsupportedChannels(usize),

    #[error("Image decode error: {0}")]
    DecodeError(String),

    #[error("Buffer size mismatch: expected {expected}, got {actual}")]
    BufferMismatch { expected: usize, actual: usize },

    #[error("Batch preprocessing failed for image {index}: {message}")]
    BatchError { index: usize, message: String },
}

/// Normalization parameters (typically ImageNet statistics).
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct NormalizationParams {
    /// Per-channel mean values.
    pub mean: [f64; 3],
    /// Per-channel standard deviation values.
    pub std: [f64; 3],
}

impl NormalizationParams {
    /// ImageNet normalization parameters.
    pub fn imagenet() -> Self {
        Self {
            mean: [0.485, 0.456, 0.406],
            std: [0.229, 0.224, 0.225],
        }
    }
}

impl Default for NormalizationParams {
    fn default() -> Self {
        Self::imagenet()
    }
}

/// Preprocessing configuration.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PreprocessConfig {
    /// Target width.
    pub target_width: u32,
    /// Target height.
    pub target_height: u32,
    /// Normalization parameters.
    pub normalization: NormalizationParams,
    /// Whether to center-crop after resizing to a larger size.
    pub center_crop: bool,
    /// Resize dimension before center crop (if center_crop is true).
    pub resize_size: Option<u32>,
}

impl Default for PreprocessConfig {
    fn default() -> Self {
        Self {
            target_width: 224,
            target_height: 224,
            normalization: NormalizationParams::default(),
            center_crop: true,
            resize_size: Some(256),
        }
    }
}

/// Raw image buffer in HWC (height, width, channels) format.
#[derive(Debug, Clone)]
pub struct ImageBuffer {
    /// Pixel data in HWC order, values in 0-255.
    pub data: Vec<u8>,
    /// Image width.
    pub width: u32,
    /// Image height.
    pub height: u32,
    /// Number of channels (1, 3, or 4).
    pub channels: u32,
}

impl ImageBuffer {
    /// Create from raw bytes.
    pub fn new(data: Vec<u8>, width: u32, height: u32, channels: u32) -> Result<Self, PreprocessError> {
        let expected = (width * height * channels) as usize;
        if data.len() != expected {
            return Err(PreprocessError::BufferMismatch {
                expected,
                actual: data.len(),
            });
        }
        if width == 0 || height == 0 {
            return Err(PreprocessError::InvalidDimensions { width, height });
        }
        Ok(Self { data, width, height, channels })
    }

    /// Get pixel value at (row, col, channel).
    pub fn pixel(&self, row: u32, col: u32, ch: u32) -> u8 {
        let idx = ((row * self.width + col) * self.channels + ch) as usize;
        self.data[idx]
    }

    /// Convert to 3-channel RGB if needed.
    pub fn to_rgb(&self) -> Result<ImageBuffer, PreprocessError> {
        match self.channels {
            3 => Ok(self.clone()),
            1 => {
                // Grayscale to RGB
                let mut rgb = Vec::with_capacity((self.width * self.height * 3) as usize);
                for &val in &self.data {
                    rgb.push(val);
                    rgb.push(val);
                    rgb.push(val);
                }
                ImageBuffer::new(rgb, self.width, self.height, 3)
            }
            4 => {
                // RGBA to RGB (drop alpha)
                let mut rgb = Vec::with_capacity((self.width * self.height * 3) as usize);
                for chunk in self.data.chunks(4) {
                    rgb.push(chunk[0]);
                    rgb.push(chunk[1]);
                    rgb.push(chunk[2]);
                }
                ImageBuffer::new(rgb, self.width, self.height, 3)
            }
            c => Err(PreprocessError::UnsupportedChannels(c as usize)),
        }
    }
}

/// Preprocess an image for model inference.
///
/// Steps:
/// 1. Convert to RGB
/// 2. Resize (bilinear interpolation)
/// 3. Center crop (optional)
/// 4. Normalize to float with given mean/std
///
/// Returns a CHW float tensor as Array3<f32>.
pub fn preprocess_image(
    image: &ImageBuffer,
    config: &PreprocessConfig,
) -> Result<Array3<f32>, PreprocessError> {
    let rgb = image.to_rgb()?;

    // Determine resize dimensions
    let (resize_w, resize_h) = if config.center_crop {
        let s = config.resize_size.unwrap_or(config.target_width.max(config.target_height) + 32);
        (s, s)
    } else {
        (config.target_width, config.target_height)
    };

    // Bilinear resize
    let resized = bilinear_resize(&rgb, resize_w, resize_h);

    // Center crop
    let (crop_x, crop_y) = if config.center_crop {
        (
            (resize_w.saturating_sub(config.target_width)) / 2,
            (resize_h.saturating_sub(config.target_height)) / 2,
        )
    } else {
        (0, 0)
    };

    let tw = config.target_width as usize;
    let th = config.target_height as usize;

    // Normalize and convert to CHW
    let norm = &config.normalization;
    let mut output = Array3::<f32>::zeros((3, th, tw));

    for row in 0..th {
        let src_row = (crop_y as usize + row).min(resize_h as usize - 1);
        for col in 0..tw {
            let src_col = (crop_x as usize + col).min(resize_w as usize - 1);
            for ch in 0..3 {
                let pixel_val = resized.pixel(src_row as u32, src_col as u32, ch as u32) as f32 / 255.0;
                output[[ch, row, col]] = ((pixel_val - norm.mean[ch] as f32) / norm.std[ch] as f32) as f32;
            }
        }
    }

    Ok(output)
}

/// Bilinear interpolation resize.
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
    ImageBuffer { data, width: target_w, height: target_h, channels: 3 }
}

/// Color space representation.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum ColorSpace {
    /// Red, Green, Blue.
    RGB,
    /// Blue, Green, Red (OpenCV default).
    BGR,
    /// Hue, Saturation, Value.
    HSV,
    /// Grayscale (single channel).
    Grayscale,
}

/// Convert an RGB ImageBuffer to BGR.
pub fn rgb_to_bgr(image: &ImageBuffer) -> Result<ImageBuffer, PreprocessError> {
    let rgb = image.to_rgb()?;
    let mut bgr_data = vec![0u8; rgb.data.len()];
    for i in (0..rgb.data.len()).step_by(3) {
        bgr_data[i] = rgb.data[i + 2];     // B
        bgr_data[i + 1] = rgb.data[i + 1]; // G
        bgr_data[i + 2] = rgb.data[i];     // R
    }
    ImageBuffer::new(bgr_data, rgb.width, rgb.height, 3)
}

/// Convert an RGB ImageBuffer to HSV.
///
/// H is in [0, 180], S in [0, 255], V in [0, 255] (OpenCV convention).
pub fn rgb_to_hsv(image: &ImageBuffer) -> Result<ImageBuffer, PreprocessError> {
    let rgb = image.to_rgb()?;
    let mut hsv_data = vec![0u8; rgb.data.len()];

    for i in (0..rgb.data.len()).step_by(3) {
        let r = rgb.data[i] as f64 / 255.0;
        let g = rgb.data[i + 1] as f64 / 255.0;
        let b = rgb.data[i + 2] as f64 / 255.0;

        let max_c = r.max(g).max(b);
        let min_c = r.min(g).min(b);
        let delta = max_c - min_c;

        // Hue
        let h = if delta < 1e-10 {
            0.0
        } else if (max_c - r).abs() < 1e-10 {
            60.0 * (((g - b) / delta) % 6.0)
        } else if (max_c - g).abs() < 1e-10 {
            60.0 * (((b - r) / delta) + 2.0)
        } else {
            60.0 * (((r - g) / delta) + 4.0)
        };
        let h = if h < 0.0 { h + 360.0 } else { h };

        // Saturation
        let s = if max_c < 1e-10 { 0.0 } else { delta / max_c };

        // Value
        let v = max_c;

        hsv_data[i] = (h / 2.0).clamp(0.0, 180.0) as u8;     // H: 0-180
        hsv_data[i + 1] = (s * 255.0).clamp(0.0, 255.0) as u8; // S: 0-255
        hsv_data[i + 2] = (v * 255.0).clamp(0.0, 255.0) as u8; // V: 0-255
    }

    ImageBuffer::new(hsv_data, rgb.width, rgb.height, 3)
}

/// Convert an RGB ImageBuffer to grayscale.
///
/// Uses the luminosity formula: 0.299*R + 0.587*G + 0.114*B
pub fn rgb_to_grayscale(image: &ImageBuffer) -> Result<ImageBuffer, PreprocessError> {
    let rgb = image.to_rgb()?;
    let n_pixels = (rgb.width * rgb.height) as usize;
    let mut gray_data = vec![0u8; n_pixels];

    for i in 0..n_pixels {
        let r = rgb.data[i * 3] as f64;
        let g = rgb.data[i * 3 + 1] as f64;
        let b = rgb.data[i * 3 + 2] as f64;
        gray_data[i] = (0.299 * r + 0.587 * g + 0.114 * b).clamp(0.0, 255.0) as u8;
    }

    ImageBuffer::new(gray_data, rgb.width, rgb.height, 1)
}

/// Preprocess a batch of images in parallel.
///
/// Returns a Vec of CHW float tensors, one per image.
pub fn preprocess_batch(
    images: &[ImageBuffer],
    config: &PreprocessConfig,
) -> Result<Vec<Array3<f32>>, PreprocessError> {
    let results: Result<Vec<_>, _> = images
        .par_iter()
        .enumerate()
        .map(|(i, img)| {
            preprocess_image(img, config).map_err(|e| PreprocessError::BatchError {
                index: i,
                message: e.to_string(),
            })
        })
        .collect();
    results
}

/// Nearest-neighbor resize (faster, lower quality).
pub fn nearest_resize(image: &ImageBuffer, target_w: u32, target_h: u32) -> ImageBuffer {
    let src_w = image.width as f64;
    let src_h = image.height as f64;
    let dst_w = target_w as f64;
    let dst_h = target_h as f64;
    let channels = image.channels;

    let rows: Vec<Vec<u8>> = (0..target_h)
        .into_par_iter()
        .map(|dst_row| {
            let mut row_data = Vec::with_capacity((target_w * channels) as usize);
            let src_row = ((dst_row as f64 + 0.5) * src_h / dst_h) as u32;
            let src_row = src_row.min(image.height - 1);

            for dst_col in 0..target_w {
                let src_col = ((dst_col as f64 + 0.5) * src_w / dst_w) as u32;
                let src_col = src_col.min(image.width - 1);

                for ch in 0..channels {
                    row_data.push(image.pixel(src_row, src_col, ch));
                }
            }
            row_data
        })
        .collect();

    let data: Vec<u8> = rows.into_iter().flatten().collect();
    ImageBuffer { data, width: target_w, height: target_h, channels }
}

/// Center crop an image to the given dimensions.
///
/// If the image is smaller than the target, returns the original image.
pub fn center_crop(image: &ImageBuffer, target_w: u32, target_h: u32) -> ImageBuffer {
    if image.width <= target_w && image.height <= target_h {
        return image.clone();
    }

    let crop_x = image.width.saturating_sub(target_w) / 2;
    let crop_y = image.height.saturating_sub(target_h) / 2;
    let out_w = target_w.min(image.width);
    let out_h = target_h.min(image.height);
    let channels = image.channels;

    let mut data = Vec::with_capacity((out_w * out_h * channels) as usize);
    for row in 0..out_h {
        let src_row = crop_y + row;
        for col in 0..out_w {
            let src_col = crop_x + col;
            for ch in 0..channels {
                data.push(image.pixel(src_row, src_col, ch));
            }
        }
    }

    ImageBuffer { data, width: out_w, height: out_h, channels }
}

/// Compute per-channel mean and standard deviation of an image.
pub fn channel_statistics(image: &ImageBuffer) -> Vec<(f64, f64)> {
    let n_pixels = (image.width * image.height) as f64;
    let channels = image.channels as usize;
    let mut stats = Vec::with_capacity(channels);

    for ch in 0..channels {
        let mut sum = 0.0f64;
        let mut sum_sq = 0.0f64;
        for row in 0..image.height {
            for col in 0..image.width {
                let v = image.pixel(row, col, ch as u32) as f64 / 255.0;
                sum += v;
                sum_sq += v * v;
            }
        }
        let mean = sum / n_pixels;
        let variance = (sum_sq / n_pixels - mean * mean).max(0.0);
        stats.push((mean, variance.sqrt()));
    }

    stats
}

#[cfg(test)]
mod tests {
    use super::*;

    fn make_red_image(w: u32, h: u32) -> ImageBuffer {
        let mut data = Vec::with_capacity((w * h * 3) as usize);
        for _ in 0..(w * h) {
            data.push(255); // R
            data.push(0);   // G
            data.push(0);   // B
        }
        ImageBuffer::new(data, w, h, 3).unwrap()
    }

    #[test]
    fn test_preprocess_output_shape() {
        let img = make_red_image(100, 80);
        let config = PreprocessConfig {
            target_width: 224,
            target_height: 224,
            center_crop: false,
            resize_size: None,
            ..Default::default()
        };
        let result = preprocess_image(&img, &config).unwrap();
        assert_eq!(result.shape(), &[3, 224, 224]);
    }

    #[test]
    fn test_preprocess_with_center_crop() {
        let img = make_red_image(300, 300);
        let config = PreprocessConfig::default();
        let result = preprocess_image(&img, &config).unwrap();
        assert_eq!(result.shape(), &[3, 224, 224]);
    }

    #[test]
    fn test_normalization_values() {
        // A pure red pixel (255, 0, 0) normalized with ImageNet stats
        let img = make_red_image(1, 1);
        let config = PreprocessConfig {
            target_width: 1,
            target_height: 1,
            center_crop: false,
            resize_size: None,
            ..Default::default()
        };
        let result = preprocess_image(&img, &config).unwrap();

        // R channel: (1.0 - 0.485) / 0.229 ≈ 2.2489
        let r_val = result[[0, 0, 0]];
        assert!((r_val - 2.2489).abs() < 0.01, "R={r_val}");

        // G channel: (0.0 - 0.456) / 0.224 ≈ -2.0357
        let g_val = result[[1, 0, 0]];
        assert!((g_val - (-2.0357)).abs() < 0.01, "G={g_val}");
    }

    #[test]
    fn test_grayscale_to_rgb() {
        let gray = ImageBuffer::new(vec![128; 4], 2, 2, 1).unwrap();
        let rgb = gray.to_rgb().unwrap();
        assert_eq!(rgb.channels, 3);
        assert_eq!(rgb.data.len(), 12);
        assert!(rgb.data.iter().all(|&v| v == 128));
    }

    #[test]
    fn test_rgba_to_rgb() {
        let rgba = ImageBuffer::new(vec![100, 150, 200, 255, 50, 60, 70, 128], 2, 1, 4).unwrap();
        let rgb = rgba.to_rgb().unwrap();
        assert_eq!(rgb.channels, 3);
        assert_eq!(rgb.data, vec![100, 150, 200, 50, 60, 70]);
    }

    #[test]
    fn test_invalid_buffer_size() {
        assert!(ImageBuffer::new(vec![0; 10], 2, 2, 3).is_err());
    }

    #[test]
    fn test_rgb_to_bgr() {
        let img = ImageBuffer::new(vec![255, 0, 128, 10, 20, 30], 2, 1, 3).unwrap();
        let bgr = rgb_to_bgr(&img).unwrap();
        assert_eq!(bgr.data, vec![128, 0, 255, 30, 20, 10]);
    }

    #[test]
    fn test_rgb_to_hsv() {
        // Pure red (255, 0, 0) -> H=0, S=255, V=255
        let img = ImageBuffer::new(vec![255, 0, 0], 1, 1, 3).unwrap();
        let hsv = rgb_to_hsv(&img).unwrap();
        assert_eq!(hsv.data[0], 0);   // H
        assert_eq!(hsv.data[1], 255); // S
        assert_eq!(hsv.data[2], 255); // V
    }

    #[test]
    fn test_rgb_to_grayscale() {
        let img = ImageBuffer::new(vec![255, 255, 255], 1, 1, 3).unwrap();
        let gray = rgb_to_grayscale(&img).unwrap();
        assert_eq!(gray.channels, 1);
        assert_eq!(gray.data[0], 255);
    }

    #[test]
    fn test_preprocess_batch() {
        let images = vec![make_red_image(50, 50), make_red_image(60, 40)];
        let config = PreprocessConfig {
            target_width: 32,
            target_height: 32,
            center_crop: false,
            resize_size: None,
            ..Default::default()
        };
        let results = preprocess_batch(&images, &config).unwrap();
        assert_eq!(results.len(), 2);
        assert_eq!(results[0].shape(), &[3, 32, 32]);
    }

    #[test]
    fn test_nearest_resize() {
        let img = make_red_image(100, 100);
        let resized = nearest_resize(&img, 50, 50);
        assert_eq!(resized.width, 50);
        assert_eq!(resized.height, 50);
        // Should still be red
        assert_eq!(resized.data[0], 255);
        assert_eq!(resized.data[1], 0);
    }

    #[test]
    fn test_center_crop() {
        let img = make_red_image(100, 100);
        let cropped = center_crop(&img, 50, 50);
        assert_eq!(cropped.width, 50);
        assert_eq!(cropped.height, 50);
    }

    #[test]
    fn test_center_crop_smaller_image() {
        let img = make_red_image(30, 30);
        let cropped = center_crop(&img, 50, 50);
        assert_eq!(cropped.width, 30);
        assert_eq!(cropped.height, 30);
    }

    #[test]
    fn test_channel_statistics() {
        // Uniform red image: R=1.0, G=0.0, B=0.0
        let img = make_red_image(10, 10);
        let stats = channel_statistics(&img);
        assert_eq!(stats.len(), 3);
        assert!((stats[0].0 - 1.0).abs() < 1e-6); // R mean = 1.0
        assert!((stats[1].0 - 0.0).abs() < 1e-6); // G mean = 0.0
        assert!((stats[0].1 - 0.0).abs() < 1e-6); // R std = 0.0 (uniform)
    }
}
