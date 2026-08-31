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

/// Compute D-infinity flow direction from a DEM.
///
/// The D-infinity algorithm (Tarboton, 1997) determines the steepest
/// downslope direction as a continuous angle (0 to 2*PI) rather than
/// restricting to 8 discrete directions.
///
/// Returns a grid of flow angles in radians (0 = east, counter-clockwise).
/// Flat/pit cells are assigned -1.0.
pub fn compute_dinf_flow_direction(dem: &Dem) -> Result<Array2<f64>, TerrainError> {
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
    let cs = dem.cell_size;

    // The 8 triangular facets defined by pairs of adjacent neighbors
    // Each facet is defined by (neighbor1, neighbor2) indices into D8_OFFSETS
    // and the base angle of the first edge
    let facets: [(usize, usize, f64); 8] = [
        (0, 7, 0.0),                           // E-NE
        (7, 6, std::f64::consts::FRAC_PI_4),   // NE-N
        (6, 5, std::f64::consts::FRAC_PI_2),   // N-NW
        (5, 4, 3.0 * std::f64::consts::FRAC_PI_4), // NW-W
        (4, 3, std::f64::consts::PI),           // W-SW
        (3, 2, 5.0 * std::f64::consts::FRAC_PI_4), // SW-S
        (2, 1, 3.0 * std::f64::consts::FRAC_PI_2), // S-SE
        (1, 0, 7.0 * std::f64::consts::FRAC_PI_4), // SE-E
    ];

    let result_rows: Vec<Vec<f64>> = (0..rows)
        .into_par_iter()
        .map(|r| {
            let mut row_vals = Vec::with_capacity(cols);
            for c in 0..cols {
                if dem.is_nodata(r, c) {
                    row_vals.push(-1.0);
                    continue;
                }

                let center = dem.elevation[[r, c]];
                let mut max_slope = 0.0f64;
                let mut best_angle = -1.0f64;

                for &(n1_idx, n2_idx, base_angle) in &facets {
                    let (dr1, dc1) = D8_OFFSETS[n1_idx];
                    let (dr2, dc2) = D8_OFFSETS[n2_idx];

                    let nr1 = r as isize + dr1;
                    let nc1 = c as isize + dc1;
                    let nr2 = r as isize + dr2;
                    let nc2 = c as isize + dc2;

                    if nr1 < 0 || nr1 >= rows as isize || nc1 < 0 || nc1 >= cols as isize
                        || nr2 < 0 || nr2 >= rows as isize || nc2 < 0 || nc2 >= cols as isize
                    {
                        continue;
                    }

                    let e1 = dem.elevation[[nr1 as usize, nc1 as usize]];
                    let e2 = dem.elevation[[nr2 as usize, nc2 as usize]];

                    if dem.is_nodata(nr1 as usize, nc1 as usize)
                        || dem.is_nodata(nr2 as usize, nc2 as usize)
                    {
                        continue;
                    }

                    let d1 = cs * D8_DISTANCES[n1_idx];
                    let d2 = cs * D8_DISTANCES[n2_idx];

                    // Slope along the first edge
                    let s1 = (center - e1) / d1;
                    // Slope along the second edge
                    let s2 = (e1 - e2) / d2;

                    let (slope, angle);
                    if s1 > 0.0 {
                        let r_val = (s2 / s1).atan();
                        if r_val >= 0.0 && r_val <= std::f64::consts::FRAC_PI_4 {
                            slope = (s1 * s1 + s2 * s2).sqrt();
                            angle = base_angle + r_val;
                        } else if r_val < 0.0 {
                            slope = s1;
                            angle = base_angle;
                        } else {
                            slope = (center - e2) / (d1 * std::f64::consts::SQRT_2);
                            angle = base_angle + std::f64::consts::FRAC_PI_4;
                        }
                    } else {
                        let s_direct = (center - e2) / (d1 * std::f64::consts::SQRT_2);
                        if s_direct > 0.0 {
                            slope = s_direct;
                            angle = base_angle + std::f64::consts::FRAC_PI_4;
                        } else {
                            continue;
                        }
                    }

                    if slope > max_slope {
                        max_slope = slope;
                        best_angle = angle;
                    }
                }

                row_vals.push(best_angle);
            }
            row_vals
        })
        .collect();

    let flat: Vec<f64> = result_rows.into_iter().flatten().collect();
    Ok(Array2::from_shape_vec((rows, cols), flat).unwrap())
}

/// Compute D-infinity flow accumulation using the proportional distribution method.
///
/// Unlike D8 which routes all flow to a single neighbor, D-infinity distributes
/// flow proportionally between the two neighbors that bound the steepest facet.
pub fn compute_dinf_accumulation(
    dem: &Dem,
    dinf_angles: &Array2<f64>,
) -> Result<Array2<f64>, TerrainError> {
    let rows = dem.rows();
    let cols = dem.cols();

    if dinf_angles.nrows() != rows || dinf_angles.ncols() != cols {
        return Err(TerrainError::DimensionMismatch {
            expected_rows: rows,
            expected_cols: cols,
            actual_rows: dinf_angles.nrows(),
            actual_cols: dinf_angles.ncols(),
        });
    }

    // Collect all cells with their elevations and sort by elevation (highest first)
    let mut cells: Vec<(usize, usize, f64)> = Vec::with_capacity(rows * cols);
    for r in 0..rows {
        for c in 0..cols {
            let elev = if dem.is_nodata(r, c) { f64::NEG_INFINITY } else { dem.elevation[[r, c]] };
            cells.push((r, c, elev));
        }
    }
    cells.sort_by(|a, b| b.2.partial_cmp(&a.2).unwrap_or(std::cmp::Ordering::Equal));

    let mut accum = Array2::<f64>::ones((rows, cols));

    for &(r, c, _) in &cells {
        let angle = dinf_angles[[r, c]];
        if angle < 0.0 {
            continue;
        }

        // Determine which two D8 neighbors bound this angle
        let sector = (angle / std::f64::consts::FRAC_PI_4).floor() as usize;
        let sector = sector % 8;
        let next_sector = (sector + 1) % 8;

        let base_angle = sector as f64 * std::f64::consts::FRAC_PI_4;
        let alpha = angle - base_angle;
        let prop2 = alpha / std::f64::consts::FRAC_PI_4;
        let prop1 = 1.0 - prop2;

        let current_acc = accum[[r, c]];

        // Distribute to first neighbor
        let (dr1, dc1) = D8_OFFSETS[sector];
        let nr1 = r as isize + dr1;
        let nc1 = c as isize + dc1;
        if nr1 >= 0 && nr1 < rows as isize && nc1 >= 0 && nc1 < cols as isize {
            accum[[nr1 as usize, nc1 as usize]] += current_acc * prop1;
        }

        // Distribute to second neighbor
        let (dr2, dc2) = D8_OFFSETS[next_sector];
        let nr2 = r as isize + dr2;
        let nc2 = c as isize + dc2;
        if nr2 >= 0 && nr2 < rows as isize && nc2 >= 0 && nc2 < cols as isize {
            accum[[nr2 as usize, nc2 as usize]] += current_acc * prop2;
        }
    }

    Ok(accum)
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

    #[test]
    fn test_dinf_flow_direction() {
        let dem = Dem::from_vec(
            vec![
                30.0, 20.0, 10.0,
                30.0, 20.0, 10.0,
                30.0, 20.0, 10.0,
            ],
            3, 3, 10.0, -9999.0,
        ).unwrap();

        let dinf = compute_dinf_flow_direction(&dem).unwrap();
        // Center should flow roughly east (angle near 0)
        let angle = dinf[[1, 1]];
        assert!(angle >= 0.0);
        assert!(angle < std::f64::consts::FRAC_PI_4);
    }

    #[test]
    fn test_dinf_accumulation() {
        let dem = Dem::from_vec(
            vec![
                30.0, 20.0, 10.0,
                30.0, 20.0, 10.0,
                30.0, 20.0, 10.0,
            ],
            3, 3, 10.0, -9999.0,
        ).unwrap();

        let dinf = compute_dinf_flow_direction(&dem).unwrap();
        let accum = compute_dinf_accumulation(&dem, &dinf).unwrap();
        // Rightmost column should have higher accumulation
        assert!(accum[[1, 2]] > accum[[1, 0]]);
    }
}
