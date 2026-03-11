//! Classify pixels by vegetation health using multiple vegetation indices.

use ndarray::Array2;
use rayon::prelude::*;
use serde::{Deserialize, Serialize};

use crate::raster::{RasterBand, RasterError};

/// Vegetation health category.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum VegetationHealth {
    NoVegetation,
    Critical,
    Poor,
    Moderate,
    Good,
    Excellent,
    NoData,
}

impl VegetationHealth {
    pub fn label(&self) -> &'static str {
        match self {
            VegetationHealth::NoVegetation => "No Vegetation",
            VegetationHealth::Critical => "Critical",
            VegetationHealth::Poor => "Poor",
            VegetationHealth::Moderate => "Moderate",
            VegetationHealth::Good => "Good",
            VegetationHealth::Excellent => "Excellent",
            VegetationHealth::NoData => "No Data",
        }
    }

    pub fn numeric_code(&self) -> u8 {
        match self {
            VegetationHealth::NoVegetation => 0,
            VegetationHealth::Critical => 1,
            VegetationHealth::Poor => 2,
            VegetationHealth::Moderate => 3,
            VegetationHealth::Good => 4,
            VegetationHealth::Excellent => 5,
            VegetationHealth::NoData => 255,
        }
    }

    pub fn from_code(code: u8) -> Self {
        match code {
            0 => VegetationHealth::NoVegetation,
            1 => VegetationHealth::Critical,
            2 => VegetationHealth::Poor,
            3 => VegetationHealth::Moderate,
            4 => VegetationHealth::Good,
            5 => VegetationHealth::Excellent,
            _ => VegetationHealth::NoData,
        }
    }
}

/// Thresholds for vegetation classification.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ClassificationThresholds {
    /// NDVI threshold below which there is no vegetation.
    pub no_vegetation_max: f64,
    /// NDVI threshold for critical health.
    pub critical_max: f64,
    /// NDVI threshold for poor health.
    pub poor_max: f64,
    /// NDVI threshold for moderate health.
    pub moderate_max: f64,
    /// NDVI threshold for good health.
    pub good_max: f64,
    // Above good_max => Excellent
}

impl Default for ClassificationThresholds {
    fn default() -> Self {
        Self {
            no_vegetation_max: 0.1,
            critical_max: 0.2,
            poor_max: 0.35,
            moderate_max: 0.5,
            good_max: 0.7,
        }
    }
}

/// Classify a single NDVI value into a vegetation health category.
pub fn classify_pixel(ndvi: f64, nodata: f64, thresholds: &ClassificationThresholds) -> VegetationHealth {
    if (ndvi - nodata).abs() < f64::EPSILON || ndvi.is_nan() {
        VegetationHealth::NoData
    } else if ndvi <= thresholds.no_vegetation_max {
        VegetationHealth::NoVegetation
    } else if ndvi <= thresholds.critical_max {
        VegetationHealth::Critical
    } else if ndvi <= thresholds.poor_max {
        VegetationHealth::Poor
    } else if ndvi <= thresholds.moderate_max {
        VegetationHealth::Moderate
    } else if ndvi <= thresholds.good_max {
        VegetationHealth::Good
    } else {
        VegetationHealth::Excellent
    }
}

/// Classify an entire NDVI raster into vegetation health.
pub fn classify_vegetation(
    ndvi_band: &RasterBand,
    thresholds: &ClassificationThresholds,
) -> Array2<u8> {
    let rows = ndvi_band.rows();
    let cols = ndvi_band.cols();
    let nodata = ndvi_band.nodata_value.unwrap_or(-9999.0);

    let result_rows: Vec<Vec<u8>> = (0..rows)
        .into_par_iter()
        .map(|r| {
            (0..cols)
                .map(|c| {
                    classify_pixel(ndvi_band.data[[r, c]], nodata, thresholds).numeric_code()
                })
                .collect()
        })
        .collect();

    let flat: Vec<u8> = result_rows.into_iter().flatten().collect();
    Array2::from_shape_vec((rows, cols), flat).unwrap()
}

/// Multi-index vegetation classification using NDVI, NDWI, and EVI.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MultiIndexClassification {
    pub health: VegetationHealth,
    pub moisture_status: MoistureStatus,
    pub vigor: VigorLevel,
}

/// Moisture status derived from NDWI.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum MoistureStatus {
    VeryDry,
    Dry,
    Adequate,
    Wet,
    Saturated,
    NoData,
}

impl MoistureStatus {
    pub fn from_ndwi(ndwi: f64, nodata: f64) -> Self {
        if (ndwi - nodata).abs() < f64::EPSILON || ndwi.is_nan() {
            MoistureStatus::NoData
        } else if ndwi < -0.4 {
            MoistureStatus::VeryDry
        } else if ndwi < -0.1 {
            MoistureStatus::Dry
        } else if ndwi < 0.1 {
            MoistureStatus::Adequate
        } else if ndwi < 0.3 {
            MoistureStatus::Wet
        } else {
            MoistureStatus::Saturated
        }
    }
}

/// Vigor level derived from EVI.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum VigorLevel {
    None,
    Low,
    Medium,
    High,
    VeryHigh,
    NoData,
}

impl VigorLevel {
    pub fn from_evi(evi: f64, nodata: f64) -> Self {
        if (evi - nodata).abs() < f64::EPSILON || evi.is_nan() {
            VigorLevel::NoData
        } else if evi < 0.1 {
            VigorLevel::None
        } else if evi < 0.25 {
            VigorLevel::Low
        } else if evi < 0.4 {
            VigorLevel::Medium
        } else if evi < 0.6 {
            VigorLevel::High
        } else {
            VigorLevel::VeryHigh
        }
    }
}

/// Perform multi-index classification on a single pixel.
pub fn classify_multi_index(
    ndvi: f64,
    ndwi: f64,
    evi: f64,
    nodata: f64,
    thresholds: &ClassificationThresholds,
) -> MultiIndexClassification {
    MultiIndexClassification {
        health: classify_pixel(ndvi, nodata, thresholds),
        moisture_status: MoistureStatus::from_ndwi(ndwi, nodata),
        vigor: VigorLevel::from_evi(evi, nodata),
    }
}

/// Classification summary statistics.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ClassificationSummary {
    pub total_pixels: usize,
    pub nodata_pixels: usize,
    pub no_vegetation_pixels: usize,
    pub critical_pixels: usize,
    pub poor_pixels: usize,
    pub moderate_pixels: usize,
    pub good_pixels: usize,
    pub excellent_pixels: usize,
}

impl ClassificationSummary {
    pub fn from_classified(classified: &Array2<u8>) -> Self {
        let mut summary = ClassificationSummary {
            total_pixels: classified.len(),
            nodata_pixels: 0,
            no_vegetation_pixels: 0,
            critical_pixels: 0,
            poor_pixels: 0,
            moderate_pixels: 0,
            good_pixels: 0,
            excellent_pixels: 0,
        };

        for &val in classified.iter() {
            match VegetationHealth::from_code(val) {
                VegetationHealth::NoData => summary.nodata_pixels += 1,
                VegetationHealth::NoVegetation => summary.no_vegetation_pixels += 1,
                VegetationHealth::Critical => summary.critical_pixels += 1,
                VegetationHealth::Poor => summary.poor_pixels += 1,
                VegetationHealth::Moderate => summary.moderate_pixels += 1,
                VegetationHealth::Good => summary.good_pixels += 1,
                VegetationHealth::Excellent => summary.excellent_pixels += 1,
            }
        }

        summary
    }

    /// Fraction of valid pixels in healthy condition (Good + Excellent).
    pub fn healthy_fraction(&self) -> f64 {
        let valid = self.total_pixels - self.nodata_pixels;
        if valid == 0 {
            return 0.0;
        }
        (self.good_pixels + self.excellent_pixels) as f64 / valid as f64
    }

    /// Fraction of valid pixels in stressed condition (Critical + Poor).
    pub fn stressed_fraction(&self) -> f64 {
        let valid = self.total_pixels - self.nodata_pixels;
        if valid == 0 {
            return 0.0;
        }
        (self.critical_pixels + self.poor_pixels) as f64 / valid as f64
    }
}

/// Compute classification from NDVI band and return both classification raster and summary.
pub fn classify_and_summarize(
    ndvi_band: &RasterBand,
    thresholds: &ClassificationThresholds,
) -> (Array2<u8>, ClassificationSummary) {
    let classified = classify_vegetation(ndvi_band, thresholds);
    let summary = ClassificationSummary::from_classified(&classified);
    (classified, summary)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_classify_pixel() {
        let t = ClassificationThresholds::default();
        assert_eq!(classify_pixel(-9999.0, -9999.0, &t), VegetationHealth::NoData);
        assert_eq!(classify_pixel(0.05, -9999.0, &t), VegetationHealth::NoVegetation);
        assert_eq!(classify_pixel(0.15, -9999.0, &t), VegetationHealth::Critical);
        assert_eq!(classify_pixel(0.25, -9999.0, &t), VegetationHealth::Poor);
        assert_eq!(classify_pixel(0.45, -9999.0, &t), VegetationHealth::Moderate);
        assert_eq!(classify_pixel(0.65, -9999.0, &t), VegetationHealth::Good);
        assert_eq!(classify_pixel(0.85, -9999.0, &t), VegetationHealth::Excellent);
    }

    #[test]
    fn test_classify_vegetation_raster() {
        let band = RasterBand::from_vec(
            vec![0.05, 0.15, 0.45, 0.85],
            2,
            2,
            Some(-9999.0),
        )
        .unwrap();
        let (classified, summary) = classify_and_summarize(&band, &ClassificationThresholds::default());
        assert_eq!(classified[[0, 0]], VegetationHealth::NoVegetation.numeric_code());
        assert_eq!(classified[[1, 1]], VegetationHealth::Excellent.numeric_code());
        assert_eq!(summary.total_pixels, 4);
        assert_eq!(summary.excellent_pixels, 1);
    }

    #[test]
    fn test_classification_summary_fractions() {
        let band = RasterBand::from_vec(
            vec![0.15, 0.25, 0.65, 0.85],
            2,
            2,
            Some(-9999.0),
        )
        .unwrap();
        let (_, summary) = classify_and_summarize(&band, &ClassificationThresholds::default());
        assert!((summary.healthy_fraction() - 0.5).abs() < 1e-10);
        assert!((summary.stressed_fraction() - 0.5).abs() < 1e-10);
    }

    #[test]
    fn test_moisture_status() {
        assert_eq!(MoistureStatus::from_ndwi(-0.5, -9999.0), MoistureStatus::VeryDry);
        assert_eq!(MoistureStatus::from_ndwi(-0.2, -9999.0), MoistureStatus::Dry);
        assert_eq!(MoistureStatus::from_ndwi(0.0, -9999.0), MoistureStatus::Adequate);
        assert_eq!(MoistureStatus::from_ndwi(0.2, -9999.0), MoistureStatus::Wet);
        assert_eq!(MoistureStatus::from_ndwi(0.5, -9999.0), MoistureStatus::Saturated);
    }

    #[test]
    fn test_vigor_level() {
        assert_eq!(VigorLevel::from_evi(0.05, -9999.0), VigorLevel::None);
        assert_eq!(VigorLevel::from_evi(0.15, -9999.0), VigorLevel::Low);
        assert_eq!(VigorLevel::from_evi(0.35, -9999.0), VigorLevel::Medium);
        assert_eq!(VigorLevel::from_evi(0.5, -9999.0), VigorLevel::High);
        assert_eq!(VigorLevel::from_evi(0.8, -9999.0), VigorLevel::VeryHigh);
    }

    #[test]
    fn test_multi_index_classification() {
        let t = ClassificationThresholds::default();
        let result = classify_multi_index(0.65, -0.2, 0.5, -9999.0, &t);
        assert_eq!(result.health, VegetationHealth::Good);
        assert_eq!(result.moisture_status, MoistureStatus::Dry);
        assert_eq!(result.vigor, VigorLevel::High);
    }
}
