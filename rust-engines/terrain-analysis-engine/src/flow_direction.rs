//! D8 flow direction algorithm.
//!
//! The D8 algorithm assigns flow to the steepest downslope neighbor
//! out of the 8 surrounding cells.

use ndarray::Array2;
use rayon::prelude::*;

use crate::dem::{Dem, TerrainError};

/// D8 flow direction encoding (powers of 2, following ESRI convention).
///
/// ```text
///  32  64  128
///  16   X   1
///   8   4   2
/// ```
pub const D8_DIRECTIONS: [u8; 8] = [1, 2, 4, 8, 16, 32, 64, 128];

/// Row/column offsets for D8 neighbors.
/// Order: E, SE, S, SW, W, NW, N, NE
pub const D8_OFFSETS: [(isize, isize); 8] = [
    (0, 1),   // E   = 1
    (1, 1),   // SE  = 2
    (1, 0),   // S   = 4
    (1, -1),  // SW  = 8
    (0, -1),  // W   = 16
    (-1, -1), // NW  = 32
    (-1, 0),  // N   = 64
    (-1, 1),  // NE  = 128
];

/// Distance weights for D8 (diagonal = sqrt(2), cardinal = 1.0).
pub const D8_DISTANCES: [f64; 8] = [
    1.0,
    std::f64::consts::SQRT_2,
    1.0,
    std::f64::consts::SQRT_2,
    1.0,
    std::f64::consts::SQRT_2,
    1.0,
    std::f64::consts::SQRT_2,
];

/// Compute D8 flow direction from a DEM.
///
/// Returns a grid where each cell contains the D8 direction code indicating
/// which of the 8 neighbors receives the flow. Cells with no downslope
/// neighbor (pits or flat areas) are assigned 0.
pub fn compute_flow_direction(dem: &Dem) -> Result<Array2<u8>, TerrainError> {
    if dem.rows() < 3 || dem.cols() < 3 {
        return Err(TerrainError::TooSmall {
            min_rows: 3,
            min_cols: 3,
            actual_rows: dem.rows(),
            actual_cols: dem.cols(),
        });
    }

    let rows = dem.rows();
    let cols = dem.cols();

    let result_rows: Vec<Vec<u8>> = (0..rows)
        .into_par_iter()
        .map(|r| {
            let mut row_vals = Vec::with_capacity(cols);
            for c in 0..cols {
                if dem.is_nodata(r, c) {
                    row_vals.push(0);
                    continue;
                }

                let center_elev = dem.elevation[[r, c]];
                let mut max_drop = 0.0f64;
                let mut best_dir: u8 = 0;

                for (i, &(dr, dc)) in D8_OFFSETS.iter().enumerate() {
                    let nr = r as isize + dr;
                    let nc = c as isize + dc;

                    if nr < 0 || nr >= rows as isize || nc < 0 || nc >= cols as isize {
                        continue;
                    }

                    let nr = nr as usize;
                    let nc = nc as usize;

                    if dem.is_nodata(nr, nc) {
                        continue;
                    }

                    let neighbor_elev = dem.elevation[[nr, nc]];
                    let drop = (center_elev - neighbor_elev) / (dem.cell_size * D8_DISTANCES[i]);

                    if drop > max_drop {
                        max_drop = drop;
                        best_dir = D8_DIRECTIONS[i];
                    }
                }

                row_vals.push(best_dir);
            }
            row_vals
        })
        .collect();

    let flat: Vec<u8> = result_rows.into_iter().flatten().collect();
    Ok(Array2::from_shape_vec((rows, cols), flat).unwrap())
}

/// Get the row/column offset for a given D8 direction code.
pub fn direction_offset(direction: u8) -> Option<(isize, isize)> {
    for (i, &dir) in D8_DIRECTIONS.iter().enumerate() {
        if dir == direction {
            return Some(D8_OFFSETS[i]);
        }
    }
    None
}

/// Get the downstream cell for a given position and flow direction grid.
pub fn downstream_cell(
    row: usize,
    col: usize,
    flow_dir: &Array2<u8>,
) -> Option<(usize, usize)> {
    let dir = flow_dir[[row, col]];
    let offset = direction_offset(dir)?;
    let nr = row as isize + offset.0;
    let nc = col as isize + offset.1;

    if nr < 0 || nr >= flow_dir.nrows() as isize || nc < 0 || nc >= flow_dir.ncols() as isize {
        return None;
    }

    Some((nr as usize, nc as usize))
}

/// Trace a flow path from a starting cell to its outlet.
pub fn trace_flow_path(
    start_row: usize,
    start_col: usize,
    flow_dir: &Array2<u8>,
    max_steps: usize,
) -> Vec<(usize, usize)> {
    let mut path = vec![(start_row, start_col)];
    let mut current = (start_row, start_col);

    for _ in 0..max_steps {
        match downstream_cell(current.0, current.1, flow_dir) {
            Some(next) => {
                if path.contains(&next) {
                    break; // Avoid infinite loops
                }
                path.push(next);
                current = next;
            }
            None => break,
        }
    }

    path
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_simple_flow_direction() {
        // Elevation decreases to the east
        let dem = Dem::from_vec(
            vec![
                30.0, 20.0, 10.0,
                30.0, 20.0, 10.0,
                30.0, 20.0, 10.0,
            ],
            3, 3, 10.0, -9999.0,
        ).unwrap();

        let flow_dir = compute_flow_direction(&dem).unwrap();
        // Center cell should flow east (direction = 1)
        assert_eq!(flow_dir[[1, 1]], 1);
    }

    #[test]
    fn test_flow_direction_south() {
        let dem = Dem::from_vec(
            vec![
                30.0, 30.0, 30.0,
                20.0, 20.0, 20.0,
                10.0, 10.0, 10.0,
            ],
            3, 3, 10.0, -9999.0,
        ).unwrap();

        let flow_dir = compute_flow_direction(&dem).unwrap();
        // Center cell should flow south (direction = 4)
        assert_eq!(flow_dir[[1, 1]], 4);
    }

    #[test]
    fn test_pit_cell() {
        // Center is lowest
        let dem = Dem::from_vec(
            vec![
                20.0, 20.0, 20.0,
                20.0, 10.0, 20.0,
                20.0, 20.0, 20.0,
            ],
            3, 3, 10.0, -9999.0,
        ).unwrap();

        let flow_dir = compute_flow_direction(&dem).unwrap();
        // Center is a pit, direction = 0
        assert_eq!(flow_dir[[1, 1]], 0);
    }

    #[test]
    fn test_direction_offset() {
        assert_eq!(direction_offset(1), Some((0, 1)));   // E
        assert_eq!(direction_offset(4), Some((1, 0)));   // S
        assert_eq!(direction_offset(16), Some((0, -1))); // W
        assert_eq!(direction_offset(64), Some((-1, 0))); // N
        assert_eq!(direction_offset(0), None);
    }

    #[test]
    fn test_trace_flow_path() {
        let dem = Dem::from_vec(
            vec![
                30.0, 20.0, 10.0,
                30.0, 20.0, 10.0,
                30.0, 20.0, 10.0,
            ],
            3, 3, 10.0, -9999.0,
        ).unwrap();

        let flow_dir = compute_flow_direction(&dem).unwrap();
        let path = trace_flow_path(1, 0, &flow_dir, 100);
        // Should flow from (1,0) -> (1,1) -> (1,2) -> boundary
        assert!(path.len() >= 3);
        assert_eq!(path[0], (1, 0));
    }

    #[test]
    fn test_downstream_cell() {
        let flow_dir = Array2::from_shape_vec(
            (3, 3),
            vec![2, 4, 8, 1, 4, 16, 128, 64, 32],
        ).unwrap();
        assert_eq!(downstream_cell(1, 1, &flow_dir), Some((2, 1))); // S
    }
}
