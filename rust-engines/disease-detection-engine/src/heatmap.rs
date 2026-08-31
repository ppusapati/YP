//! Disease localization heatmap generation and analysis.
//!
//! Provides utilities for processing segmentation output into actionable
//! heatmaps, including thresholding, bounding box extraction, and
//! severity spatial analysis.

use serde::{Deserialize, Serialize};

/// A processed disease heatmap with spatial analysis results.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DiseaseHeatmap {
    /// Heatmap values in [0, 1], row-major order.
    pub values: Vec<f32>,
    /// Heatmap width.
    pub width: usize,
    /// Heatmap height.
    pub height: usize,
    /// Affected area percentage (pixels above threshold).
    pub affected_area_pct: f32,
    /// Bounding box of affected region (x1, y1, x2, y2) normalized to [0, 1].
    pub affected_bbox: Option<(f32, f32, f32, f32)>,
    /// Location of maximum activation (row, col).
    pub max_activation_point: (usize, usize),
    /// Maximum activation value.
    pub max_activation_value: f32,
}

impl DiseaseHeatmap {
    /// Analyze a raw heatmap (values in [0, 1]).
    ///
    /// # Arguments
    /// * `values` - Heatmap values, row-major, shape (height, width).
    /// * `width` - Heatmap width.
    /// * `height` - Heatmap height.
    /// * `threshold` - Activation threshold for affected area computation.
    pub fn from_raw(values: Vec<f32>, width: usize, height: usize, threshold: f32) -> Self {
        let total_pixels = width * height;

        // Find max activation
        let mut max_val = f32::NEG_INFINITY;
        let mut max_row = 0;
        let mut max_col = 0;
        let mut above_count = 0;

        let mut min_r = height;
        let mut max_r = 0usize;
        let mut min_c = width;
        let mut max_c = 0usize;

        for r in 0..height {
            for c in 0..width {
                let idx = r * width + c;
                let val = values.get(idx).copied().unwrap_or(0.0);
                if val > max_val {
                    max_val = val;
                    max_row = r;
                    max_col = c;
                }
                if val >= threshold {
                    above_count += 1;
                    min_r = min_r.min(r);
                    max_r = max_r.max(r);
                    min_c = min_c.min(c);
                    max_c = max_c.max(c);
                }
            }
        }

        let affected_area_pct = if total_pixels > 0 {
            above_count as f32 / total_pixels as f32 * 100.0
        } else {
            0.0
        };

        let affected_bbox = if above_count > 0 && width > 0 && height > 0 {
            Some((
                min_c as f32 / width as f32,
                min_r as f32 / height as f32,
                (max_c + 1) as f32 / width as f32,
                (max_r + 1) as f32 / height as f32,
            ))
        } else {
            None
        };

        Self {
            values,
            width,
            height,
            affected_area_pct,
            affected_bbox,
            max_activation_point: (max_row, max_col),
            max_activation_value: max_val.max(0.0),
        }
    }

    /// Get the heatmap value at a specific pixel.
    pub fn at(&self, row: usize, col: usize) -> f32 {
        if row < self.height && col < self.width {
            self.values[row * self.width + col]
        } else {
            0.0
        }
    }

    /// Generate a binary mask at the given threshold.
    pub fn binary_mask(&self, threshold: f32) -> Vec<bool> {
        self.values.iter().map(|&v| v >= threshold).collect()
    }

    /// Compute the mean activation value within the affected region.
    pub fn mean_activation(&self, threshold: f32) -> f32 {
        let (sum, count) = self.values.iter().fold((0.0f32, 0u32), |(s, c), &v| {
            if v >= threshold {
                (s + v, c + 1)
            } else {
                (s, c)
            }
        });
        if count > 0 { sum / count as f32 } else { 0.0 }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_heatmap_analysis() {
        // 4x4 heatmap with a hot spot in the center
        let mut values = vec![0.0f32; 16];
        values[5] = 0.8;
        values[6] = 0.9;
        values[9] = 0.7;
        values[10] = 0.6;

        let heatmap = DiseaseHeatmap::from_raw(values, 4, 4, 0.5);

        assert!((heatmap.affected_area_pct - 25.0).abs() < 0.1);
        assert_eq!(heatmap.max_activation_point, (1, 2)); // row 1, col 2 has 0.9
        assert!((heatmap.max_activation_value - 0.9).abs() < 1e-6);
        assert!(heatmap.affected_bbox.is_some());
    }

    #[test]
    fn test_heatmap_no_activation() {
        let values = vec![0.0f32; 16];
        let heatmap = DiseaseHeatmap::from_raw(values, 4, 4, 0.5);
        assert!(heatmap.affected_area_pct < 0.01);
        assert!(heatmap.affected_bbox.is_none());
    }

    #[test]
    fn test_binary_mask() {
        let values = vec![0.1, 0.6, 0.3, 0.8];
        let heatmap = DiseaseHeatmap::from_raw(values, 2, 2, 0.5);
        let mask = heatmap.binary_mask(0.5);
        assert_eq!(mask, vec![false, true, false, true]);
    }

    #[test]
    fn test_mean_activation() {
        let values = vec![0.1, 0.6, 0.3, 0.8];
        let heatmap = DiseaseHeatmap::from_raw(values, 2, 2, 0.5);
        let mean = heatmap.mean_activation(0.5);
        assert!((mean - 0.7).abs() < 1e-6); // (0.6 + 0.8) / 2
    }
}
