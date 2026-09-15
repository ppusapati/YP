//! Terrain analysis wrapper.
//!
//! Wraps the `terrain-analysis-engine` for DEM-based terrain analysis
//! including slope, aspect, contour generation, flow direction/accumulation,
//! and watershed delineation.

use std::time::Instant;

use terrain_analysis_engine::{
    Dem, TerrainAnalysisEngine, SlopeUnit,
};

use crate::proto;

/// Handles terrain analysis operations.
pub struct TerrainEngine;

impl TerrainEngine {
    pub fn new() -> Self {
        Self
    }

    /// Run terrain analyses according to the requested operations.
    pub fn analyze(&self, req: &proto::AnalyzeTerrainRequest) -> proto::AnalyzeTerrainResponse {
        let start = Instant::now();
        let width = req.width as usize;
        let height = req.height as usize;

        if width == 0 || height == 0 || req.elevation.is_empty() {
            return empty_terrain_response(&req.request_id, start);
        }

        if req.elevation.len() != width * height {
            return empty_terrain_response(&req.request_id, start);
        }

        let cell_size = if req.cell_size > 0.0 { req.cell_size } else { 10.0 };
        let nodata = if req.nodata_value != 0.0 { req.nodata_value } else { -9999.0 };

        let dem = match Dem::from_vec(req.elevation.clone(), height, width, cell_size, nodata) {
            Ok(d) => d,
            Err(_) => return empty_terrain_response(&req.request_id, start),
        };

        let engine = TerrainAnalysisEngine::new(dem);

        // Normalise requested analyses to uppercase for matching.
        let analyses: Vec<String> = req.analyses.iter().map(|a| a.to_uppercase()).collect();
        let run_all = analyses.is_empty() || analyses.contains(&"FULL".to_string());

        let mut resp = proto::AnalyzeTerrainResponse {
            request_id: req.request_id.clone(),
            width: width as i32,
            height: height as i32,
            ..Default::default()
        };

        // Slope
        if run_all || analyses.contains(&"SLOPE".to_string()) {
            if let Ok(slope) = engine.compute_slope(SlopeUnit::Degrees) {
                resp.slope = slope.iter().cloned().collect();
            }
        }

        // Aspect
        if run_all || analyses.contains(&"ASPECT".to_string()) {
            if let Ok(aspect) = engine.compute_aspect() {
                resp.aspect = aspect.iter().cloned().collect();
            }
        }

        // Hillshade
        if run_all || analyses.contains(&"HILLSHADE".to_string()) {
            let azimuth = if req.hillshade_azimuth > 0.0 { req.hillshade_azimuth } else { 315.0 };
            let altitude = if req.hillshade_altitude > 0.0 { req.hillshade_altitude } else { 45.0 };
            let z_factor = if req.hillshade_z_factor > 0.0 { req.hillshade_z_factor } else { 1.0 };
            let hs = engine.compute_hillshade(azimuth, altitude, z_factor);
            resp.hillshade = hs.iter().cloned().collect();
        }

        // TRI
        if run_all || analyses.contains(&"TRI".to_string()) {
            let tri = engine.compute_tri();
            resp.tri = tri.iter().cloned().collect();
        }

        // TPI
        if run_all || analyses.contains(&"TPI".to_string()) {
            let tpi = engine.compute_tpi();
            resp.tpi = tpi.iter().cloned().collect();
        }

        // Flow direction
        if run_all || analyses.contains(&"FLOW_DIRECTION".to_string()) {
            if let Ok(fd) = engine.compute_flow_direction() {
                resp.flow_direction = fd.iter().map(|&v| v as i32).collect();
            }
        }

        // Flow accumulation
        if run_all || analyses.contains(&"FLOW_ACCUMULATION".to_string()) {
            if let Ok(fa) = engine.compute_flow_accumulation() {
                resp.flow_accumulation = fa.iter().cloned().collect();
            }
        }

        // Watershed
        if run_all || analyses.contains(&"WATERSHED".to_string()) {
            if let Ok(ws) = engine.delineate_watersheds() {
                resp.watershed_ids = ws.iter().cloned().collect();
            }
        }

        // Contour
        if run_all || analyses.contains(&"CONTOUR".to_string()) {
            let interval = if req.contour_interval > 0.0 { req.contour_interval } else { 5.0 };
            if let Ok(contour_set) = engine.generate_contours(interval) {
                resp.contour_lines = contour_set
                    .lines
                    .iter()
                    .map(|line| {
                        let mut coords = Vec::with_capacity(line.points.len() * 2);
                        for pt in &line.points {
                            coords.push(pt.x);
                            coords.push(pt.y);
                        }
                        proto::TerrainContourLine {
                            elevation: line.elevation,
                            coordinates: coords,
                        }
                    })
                    .collect();
            }
        }

        // DEM statistics (always included when any analysis is run).
        let stats = engine.dem().statistics();
        resp.dem_statistics = Some(proto::TerrainDemStatistics {
            min_elevation: stats.min_elevation,
            max_elevation: stats.max_elevation,
            mean_elevation: stats.mean_elevation,
            elevation_range: stats.elevation_range,
            valid_cells: stats.valid_cells as i64,
            total_cells: stats.total_cells as i64,
        });

        // Flow stats (if flow accumulation was computed).
        if !resp.flow_accumulation.is_empty() {
            let threshold = if req.stream_threshold > 0.0 { req.stream_threshold } else { 100.0 };
            // Reconstruct Array2 for stats computation.
            if let Ok(fa_array) = ndarray::Array2::from_shape_vec(
                (height, width),
                resp.flow_accumulation.clone(),
            ) {
                let fs = terrain_analysis_engine::flow_accumulation_stats(&fa_array, threshold, cell_size);
                resp.flow_statistics = Some(proto::TerrainFlowStats {
                    max_accumulation: fs.max_accumulation,
                    mean_accumulation: fs.mean_accumulation,
                    stream_cell_count: fs.stream_cell_count as i64,
                    total_cells: fs.total_cells as i64,
                    drainage_density: fs.drainage_density,
                });
            }
        }

        // Watershed statistics (if watersheds were computed).
        if !resp.watershed_ids.is_empty() {
            if let Ok(ws_array) = ndarray::Array2::from_shape_vec(
                (height, width),
                resp.watershed_ids.clone(),
            ) {
                if let Ok(ws_stats) = terrain_analysis_engine::watershed_statistics(&ws_array, engine.dem()) {
                    resp.watershed_statistics = ws_stats
                        .iter()
                        .map(|w| proto::TerrainWatershedInfo {
                            id: w.id,
                            cell_count: w.cell_count as i64,
                            area_sq_m: w.area_sq_m,
                            mean_elevation: w.mean_elevation,
                            min_elevation: w.min_elevation,
                            max_elevation: w.max_elevation,
                            relief: w.relief,
                        })
                        .collect();
                }
            }
        }

        resp.processing_time_ms = start.elapsed().as_millis() as i64;
        resp
    }
}

fn empty_terrain_response(request_id: &str, start: Instant) -> proto::AnalyzeTerrainResponse {
    proto::AnalyzeTerrainResponse {
        request_id: request_id.to_string(),
        processing_time_ms: start.elapsed().as_millis() as i64,
        ..Default::default()
    }
}
