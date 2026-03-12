//! Satellite NDVI Engine
//!
//! Processes satellite rasters to compute vegetation indices including NDVI, NDWI, and EVI.
//! Provides vegetation classification, stress detection, and zonal statistics.

pub mod evi;
pub mod ndvi;
pub mod ndwi;
pub mod raster;
pub mod statistics;
pub mod stress_detector;
pub mod vegetation_classifier;

// Re-export key types for convenience.
pub use evi::{
    compute_evi, compute_evi2, compute_gndvi, compute_msavi, compute_ndre, compute_savi,
    EviParams,
};
pub use ndvi::{compute_ndvi, classify_ndvi, ndvi_pixel, NdviClass, NdviParams};
pub use ndwi::{compute_ndwi, classify_ndwi, ndwi_pixel, NdwiParams, WaterClass};
pub use raster::{
    clip_to_polygon, clip_to_window, resample_bilinear, resample_nearest, apply_operation,
    GeoExtent, MultiBandRaster, RasterBand, RasterError, RasterMetadata,
};
pub use statistics::{
    compute_band_statistics, compute_histogram, compute_masked_statistics,
    compute_zonal_statistics, BandStatistics, Histogram, HistogramBin,
};
pub use stress_detector::{
    detect_pixel_stress, detect_raster_stress, summarize_stress,
    FieldStressSummary, NdviObservation, PixelStressResult, StressEvent, StressParams, StressType,
};
pub use vegetation_classifier::{
    classify_and_summarize, classify_multi_index, classify_vegetation,
    ClassificationSummary, ClassificationThresholds, MoistureStatus, MultiIndexClassification,
    VegetationHealth, VigorLevel,
};

use ndarray::Array2;

/// High-level satellite NDVI engine that coordinates all vegetation index computations.
pub struct SatelliteNDVIEngine {
    /// NIR band.
    nir: RasterBand,
    /// RED band.
    red: RasterBand,
    /// GREEN band (optional).
    green: Option<RasterBand>,
    /// BLUE band (optional).
    blue: Option<RasterBand>,
    /// RED EDGE band (optional).
    red_edge: Option<RasterBand>,
    /// Spatial extent.
    extent: Option<GeoExtent>,
}

impl SatelliteNDVIEngine {
    /// Create a new engine with the minimum required bands (NIR and RED).
    pub fn new(nir: RasterBand, red: RasterBand) -> Result<Self, RasterError> {
        if nir.rows() != red.rows() || nir.cols() != red.cols() {
            return Err(RasterError::DimensionMismatch {
                expected_rows: nir.rows(),
                expected_cols: nir.cols(),
                actual_rows: red.rows(),
                actual_cols: red.cols(),
            });
        }
        Ok(Self {
            nir,
            red,
            green: None,
            blue: None,
            red_edge: None,
            extent: None,
        })
    }

    /// Set the GREEN band.
    pub fn with_green(mut self, green: RasterBand) -> Self {
        self.green = Some(green);
        self
    }

    /// Set the BLUE band.
    pub fn with_blue(mut self, blue: RasterBand) -> Self {
        self.blue = Some(blue);
        self
    }

    /// Set the RED EDGE band.
    pub fn with_red_edge(mut self, red_edge: RasterBand) -> Self {
        self.red_edge = Some(red_edge);
        self
    }

    /// Set the spatial extent.
    pub fn with_extent(mut self, extent: GeoExtent) -> Self {
        self.extent = Some(extent);
        self
    }

    /// Compute NDVI.
    pub fn compute_ndvi(&self) -> Result<RasterBand, RasterError> {
        compute_ndvi(&self.nir, &self.red, &NdviParams::default())
    }

    /// Compute NDWI (requires GREEN band).
    pub fn compute_ndwi(&self) -> Result<RasterBand, RasterError> {
        let green = self.green.as_ref().ok_or(RasterError::EmptyRaster)?;
        compute_ndwi(green, &self.nir, &NdwiParams::default())
    }

    /// Compute EVI (requires BLUE band).
    pub fn compute_evi(&self) -> Result<RasterBand, RasterError> {
        let blue = self.blue.as_ref().ok_or(RasterError::EmptyRaster)?;
        compute_evi(&self.nir, &self.red, blue, &EviParams::default())
    }

    /// Compute EVI2 (no BLUE required).
    pub fn compute_evi2(&self) -> Result<RasterBand, RasterError> {
        compute_evi2(&self.nir, &self.red, -9999.0)
    }

    /// Compute SAVI with default L=0.5.
    pub fn compute_savi(&self) -> Result<RasterBand, RasterError> {
        compute_savi(&self.nir, &self.red, 0.5, -9999.0)
    }

    /// Compute MSAVI.
    pub fn compute_msavi(&self) -> Result<RasterBand, RasterError> {
        compute_msavi(&self.nir, &self.red, -9999.0)
    }

    /// Compute NDRE (requires RED EDGE band).
    pub fn compute_ndre(&self) -> Result<RasterBand, RasterError> {
        let re = self.red_edge.as_ref().ok_or(RasterError::EmptyRaster)?;
        compute_ndre(&self.nir, re, -9999.0)
    }

    /// Compute GNDVI (requires GREEN band).
    pub fn compute_gndvi(&self) -> Result<RasterBand, RasterError> {
        let green = self.green.as_ref().ok_or(RasterError::EmptyRaster)?;
        compute_gndvi(&self.nir, green, -9999.0)
    }

    /// Classify vegetation health from NDVI.
    pub fn classify_vegetation(&self) -> Result<(Array2<u8>, ClassificationSummary), RasterError> {
        let ndvi = self.compute_ndvi()?;
        Ok(classify_and_summarize(&ndvi, &ClassificationThresholds::default()))
    }

    /// Compute all available vegetation indices at once.
    pub fn compute_all_indices(&self) -> VegetationIndices {
        VegetationIndices {
            ndvi: self.compute_ndvi().ok(),
            ndwi: self.compute_ndwi().ok(),
            evi: self.compute_evi().ok(),
            evi2: self.compute_evi2().ok(),
            savi: self.compute_savi().ok(),
            msavi: self.compute_msavi().ok(),
            ndre: self.compute_ndre().ok(),
            gndvi: self.compute_gndvi().ok(),
        }
    }
}

/// Collection of all computed vegetation indices.
pub struct VegetationIndices {
    pub ndvi: Option<RasterBand>,
    pub ndwi: Option<RasterBand>,
    pub evi: Option<RasterBand>,
    pub evi2: Option<RasterBand>,
    pub savi: Option<RasterBand>,
    pub msavi: Option<RasterBand>,
    pub ndre: Option<RasterBand>,
    pub gndvi: Option<RasterBand>,
}

#[cfg(test)]
mod tests {
    use super::*;

    fn make_band(val: f64, rows: usize, cols: usize) -> RasterBand {
        RasterBand::from_vec(vec![val; rows * cols], rows, cols, None).unwrap()
    }

    #[test]
    fn test_engine_creation() {
        let nir = make_band(0.8, 3, 3);
        let red = make_band(0.2, 3, 3);
        let engine = SatelliteNDVIEngine::new(nir, red).unwrap();
        let ndvi = engine.compute_ndvi().unwrap();
        assert!((ndvi.data[[0, 0]] - 0.6).abs() < 1e-10);
    }

    #[test]
    fn test_engine_all_indices() {
        let nir = make_band(0.8, 3, 3);
        let red = make_band(0.2, 3, 3);
        let green = make_band(0.3, 3, 3);
        let blue = make_band(0.1, 3, 3);

        let engine = SatelliteNDVIEngine::new(nir, red)
            .unwrap()
            .with_green(green)
            .with_blue(blue);

        let indices = engine.compute_all_indices();
        assert!(indices.ndvi.is_some());
        assert!(indices.ndwi.is_some());
        assert!(indices.evi.is_some());
        assert!(indices.evi2.is_some());
        assert!(indices.savi.is_some());
        assert!(indices.msavi.is_some());
        assert!(indices.gndvi.is_some());
    }

    #[test]
    fn test_engine_classify() {
        let nir = make_band(0.8, 3, 3);
        let red = make_band(0.2, 3, 3);
        let engine = SatelliteNDVIEngine::new(nir, red).unwrap();
        let (classified, summary) = engine.classify_vegetation().unwrap();
        assert_eq!(classified.nrows(), 3);
        assert_eq!(summary.total_pixels, 9);
    }
}
