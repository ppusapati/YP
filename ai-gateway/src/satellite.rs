//! Satellite vegetation index computation and stress detection.
//!
//! Wraps the `satellite-ndvi-engine` for NDVI computation, per-pixel cloud
//! masking, processing-level checks, cross-sensor harmonization, and
//! vegetation stress analysis.

use std::collections::HashMap;
use std::time::Instant;

use ndarray::Array2;
use satellite_ndvi_engine::{
    classify_ndvi, compute_band_statistics, compute_ndvi, detect_raster_stress,
    harmonize_ndvi_band, summarize_stress, BandStatistics, CloudMask, MaskParams, NdviParams,
    ProcessingLevel, RasterBand, Sensor, StressParams,
};

use crate::config::ModelPaths;
use crate::proto;

const MASKED_NODATA: f64 = -9999.0;

/// Handles satellite vegetation analysis operations.
pub struct SatelliteEngine {
    model_paths: ModelPaths,
}

/// Bands after QA masking, plus the quality metadata derived on the way.
struct PreparedBands {
    nir: RasterBand,
    red: RasterBand,
    width: usize,
    height: usize,
    cloud_masked: bool,
    cloud_fraction: f64,
    valid_pixel_fraction: f64,
    level: ProcessingLevel,
    sensor: Sensor,
}

/// Validate dimensions, build the cloud mask from whichever QA layers are
/// present, and apply it to the reflectance bands.
fn prepare_bands(bands: &proto::RasterBands) -> Option<PreparedBands> {
    let width = bands.width as usize;
    let height = bands.height as usize;
    if width == 0 || height == 0 {
        return None;
    }
    let n = width * height;
    if bands.nir_band.len() != n || bands.red_band.len() != n {
        return None;
    }

    let to_band = |v: &[f64]| -> Option<RasterBand> {
        Array2::from_shape_vec((height, width), v.to_vec())
            .ok()
            .map(|a| RasterBand::new(a, None))
    };

    let mut nir = to_band(&bands.nir_band)?;
    let mut red = to_band(&bands.red_band)?;

    let mask_params = MaskParams {
        buffer_pixels: if bands.cloud_buffer_pixels < 0 {
            1
        } else {
            bands.cloud_buffer_pixels as usize
        },
        ..MaskParams::default()
    };

    let scl_mask = if bands.scl_band.len() == n {
        to_band(&bands.scl_band).map(|b| CloudMask::from_scl(&b, &mask_params))
    } else {
        None
    };
    let qa_mask = if bands.qa_pixel_band.len() == n {
        to_band(&bands.qa_pixel_band).map(|b| CloudMask::from_qa_pixel(&b, &mask_params))
    } else {
        None
    };
    let mask = match (scl_mask, qa_mask) {
        (Some(a), Some(b)) => a.intersect(&b).ok(),
        (Some(a), None) | (None, Some(a)) => Some(a),
        (None, None) => None,
    };

    let (cloud_masked, cloud_fraction, valid_pixel_fraction) = match &mask {
        Some(m) => {
            nir = m.apply(&nir, MASKED_NODATA).ok()?;
            red = m.apply(&red, MASKED_NODATA).ok()?;
            (true, m.cloud_fraction, m.valid_fraction())
        }
        None => (false, 0.0, 1.0),
    };

    Some(PreparedBands {
        nir,
        red,
        width,
        height,
        cloud_masked,
        cloud_fraction,
        valid_pixel_fraction,
        level: ProcessingLevel::parse(&bands.processing_level),
        sensor: Sensor::parse(&bands.sensor),
    })
}

impl SatelliteEngine {
    pub fn new(model_paths: ModelPaths) -> Self {
        Self { model_paths }
    }

    /// Compute NDVI from raster band data, applying cloud masking and
    /// cross-sensor harmonization when the request carries the metadata.
    pub fn compute_ndvi(&self, request: &proto::ComputeNdviRequest) -> proto::ComputeNdviResponse {
        let start = Instant::now();

        let Some(bands) = request.bands.as_ref() else {
            return empty_ndvi_response(&request.request_id, start);
        };
        let Some(prepared) = prepare_bands(bands) else {
            return empty_ndvi_response(&request.request_id, start);
        };

        let params = NdviParams::default();
        let raw_ndvi = match compute_ndvi(&prepared.nir, &prepared.red, &params) {
            Ok(band) => band,
            Err(_) => return empty_ndvi_response(&request.request_id, start),
        };

        let harmonized = matches!(prepared.sensor, Sensor::Landsat8 | Sensor::Landsat9);
        let ndvi_result = if harmonized {
            harmonize_ndvi_band(&raw_ndvi, prepared.sensor)
        } else {
            raw_ndvi
        };

        let ndvi_values: Vec<f64> = ndvi_result.data.iter().cloned().collect();
        let stats = compute_band_statistics(&ndvi_result);

        let classification = classify_ndvi(&ndvi_result);
        let total_pixels = (prepared.width * prepared.height) as f64;
        let mut class_counts: HashMap<u8, usize> = HashMap::new();
        for &class_val in classification.iter() {
            *class_counts.entry(class_val).or_insert(0) += 1;
        }
        let class_names = [
            "Water",
            "BareSoil",
            "SparseVegetation",
            "ModerateVegetation",
            "DenseVegetation",
            "NoData",
        ];
        let zones = class_counts
            .iter()
            .map(|(&class_val, &count)| {
                let name = class_names.get(class_val as usize).unwrap_or(&"Unknown");
                proto::NdviZone {
                    classification: name.to_string(),
                    min_value: 0.0,
                    max_value: 1.0,
                    pixel_count: count as i64,
                    area_pct: (count as f64 / total_pixels) * 100.0,
                }
            })
            .collect();

        proto::ComputeNdviResponse {
            request_id: request.request_id.clone(),
            ndvi_values,
            width: prepared.width as i32,
            height: prepared.height as i32,
            statistics: stats.map(|s| convert_stats(&s)),
            zones,
            model_version: self.model_paths.satellite_ndvi_version.clone(),
            processing_time_ms: start.elapsed().as_millis() as i64,
            cloud_masked: prepared.cloud_masked,
            cloud_fraction: prepared.cloud_fraction,
            valid_pixel_fraction: prepared.valid_pixel_fraction,
            processing_level: prepared.level.as_str().to_string(),
            processing_advisory: prepared.level.advisory().unwrap_or("").to_string(),
            sensor: prepared.sensor.as_str().to_string(),
            harmonized,
        }
    }

    /// Detect vegetation stress from satellite imagery.
    pub fn detect_vegetation_stress(
        &self,
        request: &proto::DetectVegetationStressRequest,
    ) -> proto::DetectVegetationStressResponse {
        let start = Instant::now();

        let Some(bands) = request.bands.as_ref() else {
            return empty_stress_response(&request.request_id, start);
        };
        let Some(prepared) = prepare_bands(bands) else {
            return empty_stress_response(&request.request_id, start);
        };

        let params = NdviParams::default();
        let ndvi_band = match compute_ndvi(&prepared.nir, &prepared.red, &params) {
            Ok(band) => band,
            Err(_) => return empty_stress_response(&request.request_id, start),
        };

        let ndvi_threshold = if request.ndvi_stress_threshold > 0.0 {
            request.ndvi_stress_threshold
        } else {
            0.3
        };
        let stress_params = StressParams {
            absolute_stress_threshold: ndvi_threshold,
            ..StressParams::default()
        };

        // detect_raster_stress expects a time series of (day, &RasterBand) pairs;
        // a single snapshot is a one-element series.
        let ndvi_series: Vec<(u32, &RasterBand)> = vec![(0, &ndvi_band)];
        let severity_band = match detect_raster_stress(&ndvi_series, &stress_params) {
            Ok(band) => band,
            Err(_) => return empty_stress_response(&request.request_id, start),
        };
        let summary = summarize_stress(&severity_band, ndvi_threshold);
        let stats = compute_band_statistics(&ndvi_band);

        let stress_zones: Vec<proto::StressZone> = if summary.stress_fraction > 0.0 {
            let stress_type_str = summary
                .dominant_stress_type
                .as_ref()
                .map(|t| format!("{:?}", t))
                .unwrap_or_else(|| "Unknown".to_string());
            vec![proto::StressZone {
                stress_type: stress_type_str,
                severity: if summary.mean_severity > 0.7 {
                    "SEVERE".to_string()
                } else if summary.mean_severity > 0.4 {
                    "MODERATE".to_string()
                } else {
                    "MILD".to_string()
                },
                affected_area_pct: summary.stress_fraction * 100.0,
                confidence: 1.0 - summary.stress_fraction.min(1.0) * 0.2,
                bounds: None,
            }]
        } else {
            vec![]
        };

        proto::DetectVegetationStressResponse {
            request_id: request.request_id.clone(),
            stress_zones,
            overall_stress_pct: summary.stress_fraction * 100.0,
            healthy_pct: (1.0 - summary.stress_fraction) * 100.0,
            ndvi_statistics: stats.map(|s| convert_stats(&s)),
            model_version: self.model_paths.satellite_ndvi_version.clone(),
            processing_time_ms: start.elapsed().as_millis() as i64,
        }
    }
}

fn convert_stats(stats: &BandStatistics) -> proto::BandStatistics {
    proto::BandStatistics {
        min: stats.min,
        max: stats.max,
        mean: stats.mean,
        std_dev: stats.std_dev,
        median: stats.median,
        valid_pixel_count: stats.valid_count as i64,
    }
}

fn empty_ndvi_response(request_id: &str, start: Instant) -> proto::ComputeNdviResponse {
    proto::ComputeNdviResponse {
        request_id: request_id.to_string(),
        ndvi_values: vec![],
        width: 0,
        height: 0,
        statistics: None,
        zones: vec![],
        model_version: String::new(),
        processing_time_ms: start.elapsed().as_millis() as i64,
        cloud_masked: false,
        cloud_fraction: 0.0,
        valid_pixel_fraction: 0.0,
        processing_level: String::new(),
        processing_advisory: String::new(),
        sensor: String::new(),
        harmonized: false,
    }
}

fn empty_stress_response(
    request_id: &str,
    start: Instant,
) -> proto::DetectVegetationStressResponse {
    proto::DetectVegetationStressResponse {
        request_id: request_id.to_string(),
        stress_zones: vec![],
        overall_stress_pct: 0.0,
        healthy_pct: 100.0,
        ndvi_statistics: None,
        model_version: String::new(),
        processing_time_ms: start.elapsed().as_millis() as i64,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn bands(w: i32, h: i32) -> proto::RasterBands {
        let n = (w * h) as usize;
        proto::RasterBands {
            nir_band: vec![0.8; n],
            red_band: vec![0.2; n],
            width: w,
            height: h,
            ..Default::default()
        }
    }

    fn engine() -> SatelliteEngine {
        SatelliteEngine::new(ModelPaths::default())
    }

    #[test]
    fn compute_ndvi_without_qa_layers() {
        let resp = engine().compute_ndvi(&proto::ComputeNdviRequest {
            request_id: "r1".into(),
            bands: Some(bands(2, 2)),
            ..Default::default()
        });
        assert_eq!(resp.ndvi_values.len(), 4);
        assert!((resp.ndvi_values[0] - 0.6).abs() < 1e-9);
        assert!(!resp.cloud_masked);
        assert_eq!(resp.valid_pixel_fraction, 1.0);
        assert_eq!(resp.processing_level, "UNKNOWN");
        assert!(!resp.processing_advisory.is_empty());
        assert!(!resp.harmonized);
    }

    #[test]
    fn compute_ndvi_applies_scl_mask_and_level() {
        let mut b = bands(2, 2);
        b.scl_band = vec![4.0, 9.0, 4.0, 3.0];
        b.cloud_buffer_pixels = 0;
        b.processing_level = "L2A".into();
        b.sensor = "S2".into();
        let resp = engine().compute_ndvi(&proto::ComputeNdviRequest {
            request_id: "r2".into(),
            bands: Some(b),
            ..Default::default()
        });
        assert!(resp.cloud_masked);
        assert!((resp.cloud_fraction - 0.25).abs() < 1e-12);
        assert!((resp.valid_pixel_fraction - 0.5).abs() < 1e-12);
        assert_eq!(resp.statistics.unwrap().valid_pixel_count, 2);
        assert_eq!(resp.processing_level, "L2A");
        assert!(resp.processing_advisory.is_empty());
        assert_eq!(resp.sensor, "SENTINEL2");
    }

    #[test]
    fn compute_ndvi_harmonizes_landsat() {
        let mut b = bands(1, 1);
        b.sensor = "LC08".into();
        b.processing_level = "L1TP".into();
        let resp = engine().compute_ndvi(&proto::ComputeNdviRequest {
            request_id: "r3".into(),
            bands: Some(b),
            ..Default::default()
        });
        assert!(resp.harmonized);
        assert!((resp.ndvi_values[0] - (0.0149 + 0.9723 * 0.6)).abs() < 1e-9);
        assert!(resp.processing_advisory.contains("Level-1"));
    }

    #[test]
    fn compute_ndvi_rejects_bad_dimensions() {
        let mut b = bands(2, 2);
        b.red_band.pop();
        let resp = engine().compute_ndvi(&proto::ComputeNdviRequest {
            request_id: "r4".into(),
            bands: Some(b),
            ..Default::default()
        });
        assert!(resp.ndvi_values.is_empty());
        assert_eq!(resp.width, 0);
    }
}
