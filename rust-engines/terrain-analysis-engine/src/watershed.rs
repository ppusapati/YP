//! Watershed delineation using D8 flow direction.
//!
//! Identifies drainage basins by tracing flow paths from each cell to its outlet.

use ndarray::Array2;
use rayon::prelude::*;
use serde::{Deserialize, Serialize};

use crate::dem::{Dem, TerrainError};
use crate::flow_direction::{compute_flow_direction, direction_offset, D8_DIRECTIONS, D8_OFFSETS};

/// Delineate watersheds from a DEM.
///
/// Identifies all drainage basins. Each basin is assigned a unique ID.
/// Returns a grid where each cell contains its watershed ID.
pub fn delineate_watersheds(dem: &Dem) -> Result<Array2<u32>, TerrainError> {
    let flow_dir = compute_flow_direction(dem)?;
    delineate_from_flow_direction(&flow_dir)
}

/// Delineate watersheds from a pre-computed flow direction grid.
pub fn delineate_from_flow_direction(flow_dir: &Array2<u8>) -> Result<Array2<u32>, TerrainError> {
    let rows = flow_dir.nrows();
    let cols = flow_dir.ncols();

    if rows < 3 || cols < 3 {
        return Err(TerrainError::TooSmall {
            min_rows: 3,
            min_cols: 3,
            actual_rows: rows,
            actual_cols: cols,
        });
    }

    let mut watershed_id = Array2::<u32>::zeros((rows, cols));
    let mut current_id: u32 = 0;

    // For each cell, trace downstream to find its outlet, then label
    for r in 0..rows {
        for c in 0..cols {
            if watershed_id[[r, c]] != 0 {
                continue;
            }

            // Trace the flow path until we reach an already-labeled cell or an outlet
            let mut path: Vec<(usize, usize)> = Vec::new();
            let mut cr = r;
            let mut cc = c;
            let mut found_id: u32 = 0;

            loop {
                if watershed_id[[cr, cc]] != 0 {
                    found_id = watershed_id[[cr, cc]];
                    break;
                }

                path.push((cr, cc));

                let dir = flow_dir[[cr, cc]];
                if dir == 0 {
                    // Outlet or pit - new watershed
                    break;
                }

                if let Some(offset) = direction_offset(dir) {
                    let nr = cr as isize + offset.0;
                    let nc = cc as isize + offset.1;

                    if nr < 0 || nr >= rows as isize || nc < 0 || nc >= cols as isize {
                        // Edge outlet - new watershed
                        break;
                    }

                    let nr = nr as usize;
                    let nc = nc as usize;

                    // Check for cycle
                    if path.contains(&(nr, nc)) {
                        break;
                    }

                    cr = nr;
                    cc = nc;
                } else {
                    break;
                }
            }

            // Assign ID to all cells on this path
            let assign_id = if found_id != 0 {
                found_id
            } else {
                current_id += 1;
                current_id
            };

            for &(pr, pc) in &path {
                watershed_id[[pr, pc]] = assign_id;
            }
        }
    }

    Ok(watershed_id)
}

/// Delineate the upstream watershed for a specific pour point.
///
/// Returns a boolean mask of all cells that drain to the given point.
pub fn delineate_upstream(
    flow_dir: &Array2<u8>,
    pour_row: usize,
    pour_col: usize,
) -> Result<Array2<bool>, TerrainError> {
    let rows = flow_dir.nrows();
    let cols = flow_dir.ncols();

    if pour_row >= rows || pour_col >= cols {
        return Err(TerrainError::OutOfBounds {
            row: pour_row,
            col: pour_col,
            rows,
            cols,
        });
    }

    let mut upstream = Array2::from_elem((rows, cols), false);
    let mut queue = vec![(pour_row, pour_col)];
    upstream[[pour_row, pour_col]] = true;

    while let Some((r, c)) = queue.pop() {
        // Find all cells that flow into (r, c)
        for (i, &(dr, dc)) in D8_OFFSETS.iter().enumerate() {
            let nr = r as isize - dr; // Reverse direction
            let nc = c as isize - dc;

            if nr < 0 || nr >= rows as isize || nc < 0 || nc >= cols as isize {
                continue;
            }

            let nr = nr as usize;
            let nc = nc as usize;

            if upstream[[nr, nc]] {
                continue;
            }

            // Check if this neighbor flows into (r, c)
            if flow_dir[[nr, nc]] == D8_DIRECTIONS[i] {
                upstream[[nr, nc]] = true;
                queue.push((nr, nc));
            }
        }
    }

    Ok(upstream)
}

/// Watershed summary statistics.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WatershedInfo {
    pub id: u32,
    pub cell_count: usize,
    pub area_sq_m: f64,
    pub mean_elevation: f64,
    pub min_elevation: f64,
    pub max_elevation: f64,
    pub relief: f64,
}

/// Compute summary statistics for each watershed.
pub fn watershed_statistics(
    watershed_ids: &Array2<u32>,
    dem: &Dem,
) -> Result<Vec<WatershedInfo>, TerrainError> {
    let rows = watershed_ids.nrows();
    let cols = watershed_ids.ncols();

    if rows != dem.rows() || cols != dem.cols() {
        return Err(TerrainError::DimensionMismatch {
            expected_rows: dem.rows(),
            expected_cols: dem.cols(),
            actual_rows: rows,
            actual_cols: cols,
        });
    }

    // Collect elevation data per watershed
    let mut data: std::collections::HashMap<u32, Vec<f64>> = std::collections::HashMap::new();
    for r in 0..rows {
        for c in 0..cols {
            let wid = watershed_ids[[r, c]];
            if wid == 0 { continue; }
            if !dem.is_nodata(r, c) {
                data.entry(wid).or_default().push(dem.elevation[[r, c]]);
            }
        }
    }

    let cell_area = dem.cell_size * dem.cell_size;

    let mut results: Vec<WatershedInfo> = data
        .into_par_iter()
        .map(|(id, elevations)| {
            let count = elevations.len();
            let sum: f64 = elevations.iter().sum();
            let min = elevations.iter().cloned().fold(f64::INFINITY, f64::min);
            let max = elevations.iter().cloned().fold(f64::NEG_INFINITY, f64::max);

            WatershedInfo {
                id,
                cell_count: count,
                area_sq_m: count as f64 * cell_area,
                mean_elevation: sum / count as f64,
                min_elevation: min,
                max_elevation: max,
                relief: max - min,
            }
        })
        .collect();

    results.sort_by_key(|w| w.id);
    Ok(results)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_watershed_delineation() {
        // Two slopes draining in opposite directions
        let dem = Dem::from_vec(
            vec![
                10.0, 20.0, 30.0,
                10.0, 20.0, 30.0,
                10.0, 20.0, 30.0,
            ],
            3, 3, 10.0, -9999.0,
        ).unwrap();

        let watersheds = delineate_watersheds(&dem).unwrap();
        // All cells draining to the same outlet should have the same ID
        assert!(watersheds[[0, 0]] > 0);
    }

    #[test]
    fn test_upstream_delineation() {
        let dem = Dem::from_vec(
            vec![
                30.0, 20.0, 10.0,
                30.0, 20.0, 10.0,
                30.0, 20.0, 10.0,
            ],
            3, 3, 10.0, -9999.0,
        ).unwrap();

        let flow_dir = compute_flow_direction(&dem).unwrap();
        let upstream = delineate_upstream(&flow_dir, 1, 2).unwrap();

        // (1,2) is the outlet; upstream should include cells that drain to it
        assert!(upstream[[1, 2]]);
        assert!(upstream[[1, 1]]); // (1,1) flows east to (1,2)
    }

    #[test]
    fn test_watershed_statistics() {
        let dem = Dem::from_vec(
            vec![
                30.0, 20.0, 10.0,
                30.0, 20.0, 10.0,
                30.0, 20.0, 10.0,
            ],
            3, 3, 10.0, -9999.0,
        ).unwrap();

        let watersheds = delineate_watersheds(&dem).unwrap();
        let stats = watershed_statistics(&watersheds, &dem).unwrap();
        assert!(!stats.is_empty());
        for ws in &stats {
            assert!(ws.cell_count > 0);
            assert!(ws.area_sq_m > 0.0);
        }
    }

    #[test]
    fn test_upstream_out_of_bounds() {
        let flow_dir = Array2::from_shape_vec(
            (3, 3),
            vec![1u8; 9],
        ).unwrap();
        assert!(delineate_upstream(&flow_dir, 10, 10).is_err());
    }
}
