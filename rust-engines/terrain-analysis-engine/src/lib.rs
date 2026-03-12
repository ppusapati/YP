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
pub use flow_direction::{compute_flow_direction, direction_offset, downstream_cell, trace_flow_path, D8_DIRECTIONS, D8_OFFSETS, D8_DISTANCES};
pub use flow_accumulation::{compute_flow_accumulation, extract_streams, compute_stream_order, flow_accumulation_stats, FlowAccumulationStats};
pub use watershed::{delineate_watersheds, delineate_from_flow_direction, delineate_upstream, watershed_statistics, WatershedInfo};
