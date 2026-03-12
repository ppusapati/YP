//! Terrain Analysis Engine
//!
//! DEM processing for terrain analysis including slope, aspect, contour generation,
//! flow direction/accumulation, and watershed delineation.

pub mod dem;
pub mod slope;
pub mod aspect;
pub mod contour;
pub mod flow_direction;
pub mod flow_accumulation;
pub mod watershed;

pub use dem::{Dem, DemExtent, DemStatistics, TerrainError};
pub use slope::{compute_slope, classify_slope, slope_from_neighborhood, SlopeUnit, SlopeClass};
pub use aspect::{compute_aspect, classify_aspect, solar_exposure_index, CardinalDirection};
pub use contour::{generate_contours, generate_contours_at_levels, ContourPoint, ContourLine, ContourSet};
pub use flow_direction::{
    compute_flow_direction, compute_dinf_flow_direction, compute_dinf_accumulation,
    direction_offset, downstream_cell, trace_flow_path,
    D8_DIRECTIONS, D8_OFFSETS, D8_DISTANCES,
};
pub use flow_accumulation::{compute_flow_accumulation, extract_streams, compute_stream_order, flow_accumulation_stats, FlowAccumulationStats};
pub use watershed::{delineate_watersheds, delineate_from_flow_direction, delineate_upstream, watershed_statistics, WatershedInfo};

use ndarray::Array2;

/// High-level terrain analysis engine that ties all modules together.
///
/// Provides a convenient API for running complete terrain analysis pipelines
/// on a single DEM.
pub struct TerrainAnalysisEngine {
    dem: Dem,
}

impl TerrainAnalysisEngine {
    /// Create a new engine from a DEM.
    pub fn new(dem: Dem) -> Self {
        Self { dem }
    }

    /// Get a reference to the underlying DEM.
    pub fn dem(&self) -> &Dem {
        &self.dem
    }

    /// Compute slope in the specified units.
    pub fn compute_slope(&self, unit: SlopeUnit) -> Result<Array2<f64>, TerrainError> {
        compute_slope(&self.dem, unit)
    }

    /// Compute aspect in degrees clockwise from north.
    pub fn compute_aspect(&self) -> Result<Array2<f64>, TerrainError> {
        compute_aspect(&self.dem)
    }

    /// Compute hillshade with given sun parameters.
    pub fn compute_hillshade(&self, azimuth_deg: f64, altitude_deg: f64, z_factor: f64) -> Array2<f64> {
        self.dem.hillshade(azimuth_deg, altitude_deg, z_factor)
    }

    /// Compute the Terrain Ruggedness Index.
    pub fn compute_tri(&self) -> Array2<f64> {
        self.dem.terrain_ruggedness_index()
    }

    /// Compute the Topographic Position Index.
    pub fn compute_tpi(&self) -> Array2<f64> {
        self.dem.topographic_position_index()
    }

    /// Compute D8 flow direction.
    pub fn compute_flow_direction(&self) -> Result<Array2<u8>, TerrainError> {
        compute_flow_direction(&self.dem)
    }

    /// Compute D-infinity flow direction.
    pub fn compute_dinf_flow_direction(&self) -> Result<Array2<f64>, TerrainError> {
        compute_dinf_flow_direction(&self.dem)
    }

    /// Compute flow accumulation from D8 flow directions.
    pub fn compute_flow_accumulation(&self) -> Result<Array2<f64>, TerrainError> {
        let flow_dir = self.compute_flow_direction()?;
        compute_flow_accumulation(&flow_dir)
    }

    /// Compute D-infinity flow accumulation.
    pub fn compute_dinf_accumulation(&self) -> Result<Array2<f64>, TerrainError> {
        let dinf = self.compute_dinf_flow_direction()?;
        compute_dinf_accumulation(&self.dem, &dinf)
    }

    /// Extract stream network from flow accumulation using a threshold.
    pub fn extract_streams(&self, threshold: f64) -> Result<Array2<bool>, TerrainError> {
        let acc = self.compute_flow_accumulation()?;
        Ok(extract_streams(&acc, threshold))
    }

    /// Delineate all watersheds.
    pub fn delineate_watersheds(&self) -> Result<Array2<u32>, TerrainError> {
        delineate_watersheds(&self.dem)
    }

    /// Delineate the upstream area for a specific pour point.
    pub fn delineate_upstream(&self, pour_row: usize, pour_col: usize) -> Result<Array2<bool>, TerrainError> {
        let flow_dir = self.compute_flow_direction()?;
        delineate_upstream(&flow_dir, pour_row, pour_col)
    }

    /// Generate contour lines at a specified interval.
    pub fn generate_contours(&self, interval: f64) -> Result<ContourSet, TerrainError> {
        generate_contours(&self.dem, interval)
    }

    /// Run a complete terrain analysis and return all results.
    pub fn full_analysis(&self, contour_interval: f64, stream_threshold: f64) -> Result<TerrainAnalysisResult, TerrainError> {
        let slope = self.compute_slope(SlopeUnit::Degrees)?;
        let aspect = self.compute_aspect()?;
        let hillshade = self.compute_hillshade(315.0, 45.0, 1.0);
        let tri = self.compute_tri();
        let tpi = self.compute_tpi();
        let flow_dir = self.compute_flow_direction()?;
        let flow_acc = compute_flow_accumulation(&flow_dir)?;
        let streams = extract_streams(&flow_acc, stream_threshold);
        let watersheds = delineate_from_flow_direction(&flow_dir)?;
        let contours = generate_contours(&self.dem, contour_interval)?;
        let dem_stats = self.dem.statistics();
        let flow_stats = flow_accumulation_stats(&flow_acc, stream_threshold, self.dem.cell_size);
        let watershed_stats = watershed_statistics(&watersheds, &self.dem)?;
        let slope_classes = classify_slope(&slope);

        Ok(TerrainAnalysisResult {
            slope,
            aspect,
            hillshade,
            tri,
            tpi,
            flow_direction: flow_dir,
            flow_accumulation: flow_acc,
            streams,
            watersheds,
            contours,
            dem_stats,
            flow_stats,
            watershed_stats,
            slope_classes,
        })
    }
}

/// Complete terrain analysis result.
pub struct TerrainAnalysisResult {
    pub slope: Array2<f64>,
    pub aspect: Array2<f64>,
    pub hillshade: Array2<f64>,
    pub tri: Array2<f64>,
    pub tpi: Array2<f64>,
    pub flow_direction: Array2<u8>,
    pub flow_accumulation: Array2<f64>,
    pub streams: Array2<bool>,
    pub watersheds: Array2<u32>,
    pub contours: ContourSet,
    pub dem_stats: DemStatistics,
    pub flow_stats: FlowAccumulationStats,
    pub watershed_stats: Vec<WatershedInfo>,
    pub slope_classes: Array2<u8>,
}

#[cfg(test)]
mod tests {
    use super::*;

    fn test_dem() -> Dem {
        Dem::from_vec(
            vec![
                30.0, 25.0, 20.0, 15.0, 10.0,
                28.0, 23.0, 18.0, 13.0,  8.0,
                26.0, 21.0, 16.0, 11.0,  6.0,
                24.0, 19.0, 14.0,  9.0,  4.0,
                22.0, 17.0, 12.0,  7.0,  2.0,
            ],
            5, 5, 10.0, -9999.0,
        ).unwrap()
    }

    #[test]
    fn test_engine_creation() {
        let engine = TerrainAnalysisEngine::new(test_dem());
        assert_eq!(engine.dem().rows(), 5);
        assert_eq!(engine.dem().cols(), 5);
    }

    #[test]
    fn test_full_analysis() {
        let engine = TerrainAnalysisEngine::new(test_dem());
        let result = engine.full_analysis(5.0, 5.0).unwrap();
        assert_eq!(result.slope.nrows(), 5);
        assert_eq!(result.aspect.nrows(), 5);
        assert!(!result.contours.lines.is_empty());
        assert!(!result.watershed_stats.is_empty());
    }
}
