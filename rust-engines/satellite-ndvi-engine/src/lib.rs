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
pub use evi::{compute_evi, compute_evi2, EviParams};
pub use ndvi::{compute_ndvi, NdviClass, NdviParams};
pub use ndwi::{compute_ndwi, NdwiParams, WaterClass};
pub use raster::{GeoExtent, MultiBandRaster, RasterBand, RasterError, RasterMetadata};
pub use statistics::{compute_band_statistics, compute_zonal_statistics, BandStatistics, Histogram};
pub use stress_detector::{detect_pixel_stress, StressEvent, StressParams, StressType};
pub use vegetation_classifier::{
    classify_vegetation, ClassificationSummary, ClassificationThresholds, VegetationHealth,
};
