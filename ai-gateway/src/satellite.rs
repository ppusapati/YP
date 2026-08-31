//! Satellite vegetation index computation and stress detection.
//!
//! Wraps the `satellite-ndvi-engine` for NDVI/NDWI/EVI computation and
//! vegetation stress analysis.

use std::time::Instant;

use ndarray::Array2;
use satellite_ndvi_engine::{
    compute_ndvi, classify_ndvi, NdviParams,
    compute_band_statistics, BandStatistics,
    detect_raster_stress, summarize_stress, StressParams,
    RasterBand,
};

use crate::config::ModelPaths;
use crate::proto;

/// Handles satellite vegetation analysis operations.
pub struct SatelliteEngine {
    model_paths: ModelPaths,
}

impl SatelliteEngine {
    pub fn new(model_paths: ModelPaths) -> Self {
        Self { model_paths }
    }

    /// Compute NDVI from raster band data.
    pub fn compute_ndvi(
        &self,
        request: &proto::ComputeNdviRequest,
    ) -> proto::ComputeNdviResponse {
        let start = Instant::now();

        if let Some(ref bands) = request.bands {
            let width = bands.width as usize;
            let height = bands.height as usize;

            if width == 0 || height == 0 {
                return empty_ndvi_response(&request.request_id, start);
            }

            // Reconstruct raster bands from flat arrays.
            let nir_data: Vec<f64> = bands.nir_band.clone();
            let red_data: Vec<f64> = bands.red_band.clone();

            if nir_data.len() != width * height || red_data.len() != width * height {
                return empty_ndvi_response(&request.request_id, start);
            }

            let nir_array = Array2::from_shape_vec((height, width), nir_data)
                .unwrap_or_else(|_| Array2::zeros((height, width)));
            let red_array = Array2::from_shape_vec((height, width), red_data)
                .unwrap_or_else(|_| Array2::zeros((height, width)));

            let nir_band = RasterBand::from_array(nir_array.clone());
            let red_band = RasterBand::from_array(red_array.clone());

            // Compute NDVI using the satellite-ndvi-engine.
            let params = NdviParams::default();
            let ndvi_result = compute_ndvi(&nir_band, &red_band, &params);

            // Flatten NDVI grid to row-major array.
            let ndvi_values: Vec<f64> = ndvi_result.data().iter().cloned().collect();

            // Compute statistics.
            let stats = compute_band_statistics(&ndvi_result);

            // Classify NDVI values into zones.
            let classification = classify_ndvi(&ndvi_result);
            let total_pixels = (width * height) as f64;

            let zones = classification
                .iter()
                .map(|(class, count)| proto::NdviZone {
                    classification: format!("{:?}", class),
                    min_value: 0.0,
                    max_value: 1.0,
                    pixel_count: *count as i64,
                    area_pct: (*count as f64 / total_pixels) * 100.0,
                })
                .collect();

            let elapsed = start.elapsed();

            proto::ComputeNdviResponse {
                request_id: request.request_id.clone(),
                ndvi_values,
                width: width as i32,
                height: height as i32,
                statistics: Some(convert_stats(&stats)),
                zones,
                model_version: self.model_paths.satellite_ndvi_version.clone(),
                processing_time_ms: elapsed.as_millis() as i64,
            }
        } else {
            empty_ndvi_response(&request.request_id, start)
        }
    }

    /// Detect vegetation stress from satellite imagery.
    pub fn detect_vegetation_stress(
        &self,
        request: &proto::DetectVegetationStressRequest,
    ) -> proto::DetectVegetationStressResponse {
        let start = Instant::now();

        if let Some(ref bands) = request.bands {
            let width = bands.width as usize;
            let height = bands.height as usize;

            if width == 0 || height == 0 {
                return empty_stress_response(&request.request_id, start);
            }

            let nir_data: Vec<f64> = bands.nir_band.clone();
            let red_data: Vec<f64> = bands.red_band.clone();

            if nir_data.len() != width * height || red_data.len() != width * height {
                return empty_stress_response(&request.request_id, start);
            }

            let nir_array = Array2::from_shape_vec((height, width), nir_data)
                .unwrap_or_else(|_| Array2::zeros((height, width)));
            let red_array = Array2::from_shape_vec((height, width), red_data)
                .unwrap_or_else(|_| Array2::zeros((height, width)));

            let nir_band = RasterBand::from_array(nir_array);
            let red_band = RasterBand::from_array(red_array);

            // Compute NDVI first.
            let params = NdviParams::default();
            let ndvi_result = compute_ndvi(&nir_band, &red_band, &params);

            // Run stress detection.
            let ndvi_threshold = if request.ndvi_stress_threshold > 0.0 {
                request.ndvi_stress_threshold
            } else {
                0.3
            };

            let stress_params = StressParams {
                ndvi_threshold,
                window_size: 5,
                min_cluster_size: 4,
            };

            let stress_results = detect_raster_stress(&ndvi_result, &stress_params);
            let summary = summarize_stress(&stress_results, width, height);

            // Compute NDVI statistics.
            let stats = compute_band_statistics(&ndvi_result);

            // Convert stress zones.
            let stress_zones: Vec<proto::StressZone> = summary
                .stress_events
                .iter()
                .map(|event| proto::StressZone {
                    stress_type: format!("{:?}", event.stress_type),
                    severity: event.severity.clone(),
                    affected_area_pct: event.affected_pct,
                    confidence: event.confidence,
                    bounds: None,
                })
                .collect();

            let elapsed = start.elapsed();

            proto::DetectVegetationStressResponse {
                request_id: request.request_id.clone(),
                stress_zones,
                overall_stress_pct: summary.stressed_pct,
                healthy_pct: summary.healthy_pct,
                ndvi_statistics: Some(convert_stats(&stats)),
                model_version: self.model_paths.satellite_ndvi_version.clone(),
                processing_time_ms: elapsed.as_millis() as i64,
            }
        } else {
            empty_stress_response(&request.request_id, start)
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
    let elapsed = start.elapsed();
    proto::ComputeNdviResponse {
        request_id: request_id.to_string(),
        ndvi_values: vec![],
        width: 0,
        height: 0,
        statistics: None,
        zones: vec![],
        model_version: String::new(),
        processing_time_ms: elapsed.as_millis() as i64,
    }
}

fn empty_stress_response(
    request_id: &str,
    start: Instant,
) -> proto::DetectVegetationStressResponse {
    let elapsed = start.elapsed();
    proto::DetectVegetationStressResponse {
        request_id: request_id.to_string(),
        stress_zones: vec![],
        overall_stress_pct: 0.0,
        healthy_pct: 100.0,
        ndvi_statistics: None,
        model_version: String::new(),
        processing_time_ms: elapsed.as_millis() as i64,
    }
}
