//! Heatmaps that say *where* in an image a prediction came from.
//!
//! A confidence score tells a farmer how sure the model is; it does not tell
//! them whether the model looked at the lesion or at the shadow of the hand
//! holding the leaf. A Grad-CAM map does, and it is the difference between an
//! answer someone can check and one they must simply trust.
//!
//! The maps arrive at the backbone's feature resolution — typically a coarse
//! grid such as 7x7 — because that is the last point where activations still
//! carry position. Everything here works at that resolution and only
//! interpolates when something needs to be drawn over the original image.

use serde::{Deserialize, Serialize};

/// Values below this share of the peak are treated as background when the
/// focus region is measured.
pub const DEFAULT_FOCUS_THRESHOLD: f32 = 0.5;

/// A per-class activation map, normalised so its peak is 1.0.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Heatmap {
    pub task: String,
    pub class_index: usize,
    pub class_name: String,
    pub width: usize,
    pub height: usize,
    /// Row-major, `width * height` values in `[0, 1]`.
    pub values: Vec<f32>,
    /// The map's maximum before normalisation.
    ///
    /// Normalised values answer "where"; this answers "how strongly", and
    /// keeps the raw map recoverable as `values[i] * peak`.
    pub peak: f32,
    /// False when the map was entirely flat, so nothing can be pointed at.
    pub localised: bool,
}

/// A normalised region of the image, with `0,0` at the top left and all values
/// in `[0, 1]` so it survives any later resize.
#[derive(Debug, Clone, Copy, PartialEq, Serialize, Deserialize)]
pub struct FocusRegion {
    pub x: f64,
    pub y: f64,
    pub width: f64,
    pub height: f64,
    /// Share of the image inside the region.
    pub coverage: f64,
}

impl Heatmap {
    /// Build from raw Grad-CAM values, normalising by the peak.
    pub fn new(
        task: impl Into<String>,
        class_index: usize,
        class_name: impl Into<String>,
        width: usize,
        height: usize,
        raw: &[f32],
    ) -> Self {
        let expected = width * height;
        let mut values: Vec<f32> = raw
            .iter()
            .take(expected)
            .map(|v| if v.is_finite() { v.max(0.0) } else { 0.0 })
            .collect();
        values.resize(expected, 0.0);

        let peak = values.iter().copied().fold(0.0f32, f32::max);
        // A map with no positive evidence anywhere carries no location. Scaling
        // it up would turn rounding noise into a confident-looking hotspot.
        let localised = peak > 0.0;
        if localised {
            for v in values.iter_mut() {
                *v /= peak;
            }
        }

        Self {
            task: task.into(),
            class_index,
            class_name: class_name.into(),
            width,
            height,
            values,
            peak,
            localised,
        }
    }

    pub fn value_at(&self, x: usize, y: usize) -> f32 {
        if x >= self.width || y >= self.height {
            return 0.0;
        }
        self.values[y * self.width + x]
    }

    /// Share of the map at or above `threshold` of the peak.
    pub fn coverage(&self, threshold: f32) -> f64 {
        if self.values.is_empty() {
            return 0.0;
        }
        let hot = self.values.iter().filter(|&&v| v >= threshold).count();
        hot as f64 / self.values.len() as f64
    }

    /// Bounding box of everything at or above `threshold` of the peak.
    ///
    /// Coordinates are normalised, and a cell's extent is its whole cell, not
    /// its corner — a single hot cell in a 7x7 map is a seventh of the image
    /// wide, not a point.
    pub fn focus_region(&self, threshold: f32) -> Option<FocusRegion> {
        if !self.localised || self.width == 0 || self.height == 0 {
            return None;
        }
        let (mut min_x, mut min_y) = (usize::MAX, usize::MAX);
        let (mut max_x, mut max_y) = (0usize, 0usize);
        let mut hot = 0usize;

        for y in 0..self.height {
            for x in 0..self.width {
                if self.value_at(x, y) >= threshold {
                    min_x = min_x.min(x);
                    min_y = min_y.min(y);
                    max_x = max_x.max(x);
                    max_y = max_y.max(y);
                    hot += 1;
                }
            }
        }
        if hot == 0 {
            return None;
        }

        let w = self.width as f64;
        let h = self.height as f64;
        Some(FocusRegion {
            x: min_x as f64 / w,
            y: min_y as f64 / h,
            width: (max_x - min_x + 1) as f64 / w,
            height: (max_y - min_y + 1) as f64 / h,
            coverage: hot as f64 / (w * h),
        })
    }

    /// Cell with the highest activation, as normalised centre coordinates.
    pub fn peak_position(&self) -> Option<(f64, f64)> {
        if !self.localised {
            return None;
        }
        let idx = self
            .values
            .iter()
            .enumerate()
            .fold(
                (0usize, f32::MIN),
                |best, (i, &v)| {
                    if v > best.1 {
                        (i, v)
                    } else {
                        best
                    }
                },
            )
            .0;
        let x = (idx % self.width) as f64 + 0.5;
        let y = (idx / self.width) as f64 + 0.5;
        Some((x / self.width as f64, y / self.height as f64))
    }

    /// Bilinear resize, for drawing over the original image.
    pub fn resized(&self, width: usize, height: usize) -> Heatmap {
        if width == 0 || height == 0 || self.width == 0 || self.height == 0 {
            return Heatmap {
                width: 0,
                height: 0,
                values: Vec::new(),
                localised: false,
                ..self.clone()
            };
        }
        let mut values = vec![0.0f32; width * height];
        for y in 0..height {
            // Map destination cell centres onto source cell centres, so the
            // result is not shifted by half a cell.
            let sy = ((y as f32 + 0.5) * self.height as f32 / height as f32 - 0.5)
                .clamp(0.0, (self.height - 1) as f32);
            let y0 = sy.floor() as usize;
            let y1 = (y0 + 1).min(self.height - 1);
            let fy = sy - y0 as f32;

            for x in 0..width {
                let sx = ((x as f32 + 0.5) * self.width as f32 / width as f32 - 0.5)
                    .clamp(0.0, (self.width - 1) as f32);
                let x0 = sx.floor() as usize;
                let x1 = (x0 + 1).min(self.width - 1);
                let fx = sx - x0 as f32;

                let top = self.value_at(x0, y0) * (1.0 - fx) + self.value_at(x1, y0) * fx;
                let bottom = self.value_at(x0, y1) * (1.0 - fx) + self.value_at(x1, y1) * fx;
                values[y * width + x] = top * (1.0 - fy) + bottom * fy;
            }
        }
        Heatmap {
            task: self.task.clone(),
            class_index: self.class_index,
            class_name: self.class_name.clone(),
            width,
            height,
            values,
            peak: self.peak,
            localised: self.localised,
        }
    }

    /// Encode as an 8-bit greyscale PNG, white where the evidence is.
    pub fn to_png(&self) -> Result<Vec<u8>, String> {
        if self.width == 0 || self.height == 0 {
            return Err("cannot encode an empty heatmap".to_string());
        }
        let buffer: Vec<u8> = self
            .values
            .iter()
            .map(|v| (v.clamp(0.0, 1.0) * 255.0).round() as u8)
            .collect();
        let img = image::GrayImage::from_raw(self.width as u32, self.height as u32, buffer)
            .ok_or_else(|| "heatmap dimensions do not match its values".to_string())?;

        let mut out = std::io::Cursor::new(Vec::new());
        image::DynamicImage::ImageLuma8(img)
            .write_to(&mut out, image::ImageFormat::Png)
            .map_err(|e| format!("failed to encode heatmap: {e}"))?;
        Ok(out.into_inner())
    }

    /// One sentence a farmer can read, describing where the model looked.
    ///
    /// Deliberately about *location and spread*, not about correctness: the
    /// map shows what drove the answer, which is useful precisely when the
    /// answer is wrong.
    pub fn summary(&self, threshold: f32) -> String {
        let Some(region) = self.focus_region(threshold) else {
            return format!(
                "No single area drove the {} result; the model used the whole image.",
                self.class_name
            );
        };
        let (cx, cy) = self.peak_position().unwrap_or((
            region.x + region.width / 2.0,
            region.y + region.height / 2.0,
        ));

        let vertical = match cy {
            v if v < 0.33 => "upper",
            v if v < 0.67 => "middle",
            _ => "lower",
        };
        let horizontal = match cx {
            h if h < 0.33 => "left",
            h if h < 0.67 => "centre",
            _ => "right",
        };
        let spread = match region.coverage {
            c if c < 0.15 => "a small area",
            c if c < 0.5 => "part",
            _ => "most",
        };

        let where_ = if vertical == "middle" && horizontal == "centre" {
            "the centre".to_string()
        } else {
            format!("the {vertical} {horizontal}")
        };
        format!(
            "The {} result came mainly from {spread} of {where_} of the image ({:.0}% of it).",
            self.class_name,
            region.coverage * 100.0
        )
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn map(width: usize, height: usize, raw: &[f32]) -> Heatmap {
        Heatmap::new("disease", 1, "leaf_rust", width, height, raw)
    }

    #[test]
    fn values_are_normalised_by_the_peak() {
        let h = map(2, 2, &[1.0, 2.0, 0.0, 4.0]);
        assert_eq!(h.values, vec![0.25, 0.5, 0.0, 1.0]);
        assert_eq!(h.peak, 4.0, "the raw scale stays recoverable");
        assert!(h.localised);
        assert_eq!(h.value_at(1, 1), 1.0);
        // Out-of-range lookups read as background rather than panicking.
        assert_eq!(h.value_at(9, 0), 0.0);
    }

    #[test]
    fn negatives_and_non_finite_values_are_clamped_away() {
        let h = map(2, 2, &[-3.0, f32::NAN, f32::INFINITY, 2.0]);
        assert_eq!(h.values, vec![0.0, 0.0, 0.0, 1.0]);
    }

    #[test]
    fn a_flat_map_is_not_localised() {
        let h = map(2, 2, &[0.0, 0.0, 0.0, 0.0]);
        assert!(!h.localised);
        assert_eq!(h.peak, 0.0);
        assert!(h.focus_region(DEFAULT_FOCUS_THRESHOLD).is_none());
        assert!(h.peak_position().is_none());
        assert!(h
            .summary(DEFAULT_FOCUS_THRESHOLD)
            .contains("No single area"));
        // Values stay zero rather than being scaled up into noise.
        assert!(h.values.iter().all(|&v| v == 0.0));
    }

    #[test]
    fn short_or_long_input_is_padded_or_truncated() {
        let short = map(2, 2, &[1.0, 0.5]);
        assert_eq!(short.values.len(), 4);
        assert_eq!(short.values[2..], [0.0, 0.0]);

        let long = map(2, 2, &[1.0, 1.0, 1.0, 1.0, 9.0]);
        assert_eq!(long.values.len(), 4);
        assert!(
            long.values.iter().all(|&v| v == 1.0),
            "the extra is ignored"
        );
    }

    #[test]
    fn focus_region_bounds_the_hot_cells() {
        // One hot cell at (2,1) of a 4x4 grid.
        let mut raw = vec![0.0f32; 16];
        raw[1 * 4 + 2] = 1.0;
        let h = map(4, 4, &raw);

        let r = h.focus_region(0.5).unwrap();
        assert!((r.x - 0.5).abs() < 1e-9);
        assert!((r.y - 0.25).abs() < 1e-9);
        // A cell covers its whole extent, not a point.
        assert!((r.width - 0.25).abs() < 1e-9);
        assert!((r.height - 0.25).abs() < 1e-9);
        assert!((r.coverage - 1.0 / 16.0).abs() < 1e-9);

        // The peak is reported at the cell's centre.
        let (cx, cy) = h.peak_position().unwrap();
        assert!((cx - 0.625).abs() < 1e-9);
        assert!((cy - 0.375).abs() < 1e-9);
    }

    #[test]
    fn a_threshold_above_every_value_selects_nothing() {
        let h = map(2, 2, &[1.0, 0.1, 0.1, 0.1]);
        assert!(h.focus_region(1.5).is_none());
        assert_eq!(h.coverage(1.5), 0.0);
        // The peak itself is always included at threshold 1.0.
        assert_eq!(h.coverage(1.0), 0.25);
    }

    #[test]
    fn coverage_counts_the_hot_share() {
        let h = map(2, 2, &[1.0, 1.0, 0.0, 0.0]);
        assert!((h.coverage(0.5) - 0.5).abs() < 1e-12);
        assert!((h.coverage(0.0) - 1.0).abs() < 1e-12);
    }

    #[test]
    fn resizing_preserves_the_peak_and_the_range() {
        let mut raw = vec![0.0f32; 16];
        raw[1 * 4 + 2] = 1.0;
        let big = map(4, 4, &raw).resized(64, 64);

        assert_eq!(big.width, 64);
        assert_eq!(big.height, 64);
        assert_eq!(big.values.len(), 64 * 64);
        assert!(big.values.iter().all(|&v| (0.0..=1.0).contains(&v)));
        assert!(big.class_name == "leaf_rust" && big.localised);

        // The hot cell must land where it was, not shifted by interpolation.
        let peak = big.peak_position().unwrap();
        let original = map(4, 4, &raw).peak_position().unwrap();
        assert!(
            (peak.0 - original.0).abs() < 0.05 && (peak.1 - original.1).abs() < 0.05,
            "peak moved from {original:?} to {peak:?}"
        );
    }

    #[test]
    fn resizing_is_smooth_between_cells() {
        // A left-to-right ramp must stay monotonic after upsampling.
        let h = map(2, 1, &[0.0, 1.0]).resized(8, 1);
        for i in 1..8 {
            assert!(
                h.values[i] >= h.values[i - 1],
                "not monotonic at {i}: {:?}",
                h.values
            );
        }
        assert!(h.values[0] < h.values[7]);
    }

    #[test]
    fn degenerate_resizes_are_refused_not_guessed() {
        let h = map(4, 4, &[1.0; 16]).resized(0, 10);
        assert_eq!(h.width, 0);
        assert!(h.values.is_empty());
        assert!(!h.localised);
    }

    #[test]
    fn png_encoding_round_trips_the_dimensions() {
        let h = map(4, 2, &[1.0, 0.5, 0.0, 0.25, 0.75, 1.0, 0.0, 0.5]);
        let png = h.to_png().unwrap();
        assert_eq!(&png[1..4], b"PNG");

        let decoded = image::load_from_memory(&png).unwrap().to_luma8();
        assert_eq!(decoded.dimensions(), (4, 2));
        assert_eq!(decoded.get_pixel(0, 0)[0], 255);
        assert_eq!(decoded.get_pixel(2, 0)[0], 0);

        assert!(map(0, 0, &[]).to_png().is_err());
    }

    #[test]
    fn summaries_name_where_the_model_looked() {
        // Hot in the top-left corner of an 8x8 grid.
        let mut raw = vec![0.0f32; 64];
        raw[0] = 1.0;
        let text = map(8, 8, &raw).summary(0.5);
        assert!(text.contains("upper left"), "{text}");
        assert!(text.contains("leaf_rust"), "{text}");
        assert!(text.contains("small area"), "{text}");

        // Hot in the middle.
        let mut centre = vec![0.0f32; 64];
        centre[4 * 8 + 4] = 1.0;
        let text = map(8, 8, &centre).summary(0.5);
        assert!(text.contains("the centre"), "{text}");

        // Hot everywhere: the model used the whole image.
        let text = map(8, 8, &[1.0; 64]).summary(0.5);
        assert!(text.contains("most"), "{text}");
        assert!(text.contains("100%"), "{text}");
    }

    #[test]
    fn heatmaps_round_trip_through_json() {
        let h = map(2, 2, &[1.0, 2.0, 0.0, 4.0]);
        let back: Heatmap = serde_json::from_str(&serde_json::to_string(&h).unwrap()).unwrap();
        assert_eq!(back, h);
    }
}
