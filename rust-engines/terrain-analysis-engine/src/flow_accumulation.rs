//! Flow accumulation computation.
//!
//! Counts the number of upstream cells that flow into each cell,
//! used to identify streams and drainage patterns.

use ndarray::Array2;

use crate::dem::TerrainError;
use crate::flow_direction::{direction_offset, D8_DIRECTIONS, D8_OFFSETS};

/// Compute flow accumulation from a D8 flow direction grid.
///
/// Each cell receives a count of how many upstream cells drain through it.
/// Cells with no upstream contributions have accumulation = 1 (just themselves).
///
/// Uses a topological sort approach: process cells with no remaining
/// upstream dependencies first, propagating accumulation downstream.
pub fn compute_flow_accumulation(flow_dir: &Array2<u8>) -> Result<Array2<f64>, TerrainError> {
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

    // Count how many cells flow into each cell (in-degree)
    let mut in_degree = Array2::<usize>::zeros((rows, cols));

    for r in 0..rows {
        for c in 0..cols {
            let dir = flow_dir[[r, c]];
            if dir == 0 {
                continue;
            }
            if let Some(offset) = direction_offset(dir) {
                let nr = r as isize + offset.0;
                let nc = c as isize + offset.1;
                if nr >= 0 && nr < rows as isize && nc >= 0 && nc < cols as isize {
                    in_degree[[nr as usize, nc as usize]] += 1;
                }
            }
        }
    }

    // Initialize accumulation to 1 for each cell (self)
    let mut accumulation = Array2::<f64>::ones((rows, cols));

    // Queue all cells with in-degree 0 (headwater cells)
    let mut queue: Vec<(usize, usize)> = Vec::new();
    for r in 0..rows {
        for c in 0..cols {
            if in_degree[[r, c]] == 0 {
                queue.push((r, c));
            }
        }
    }

    // Process in topological order
    while let Some((r, c)) = queue.pop() {
        let dir = flow_dir[[r, c]];
        if dir == 0 {
            continue;
        }

        if let Some(offset) = direction_offset(dir) {
            let nr = r as isize + offset.0;
            let nc = c as isize + offset.1;
            if nr >= 0 && nr < rows as isize && nc >= 0 && nc < cols as isize {
                let nr = nr as usize;
                let nc = nc as usize;
                accumulation[[nr, nc]] += accumulation[[r, c]];
                in_degree[[nr, nc]] -= 1;
                if in_degree[[nr, nc]] == 0 {
                    queue.push((nr, nc));
                }
            }
        }
    }

    Ok(accumulation)
}

/// Extract stream cells from flow accumulation using a threshold.
///
/// Cells with accumulation >= threshold are classified as streams.
pub fn extract_streams(
    accumulation: &Array2<f64>,
    threshold: f64,
) -> Array2<bool> {
    let rows = accumulation.nrows();
    let cols = accumulation.ncols();
    let mut streams = Array2::from_elem((rows, cols), false);

    for r in 0..rows {
        for c in 0..cols {
            if accumulation[[r, c]] >= threshold {
                streams[[r, c]] = true;
            }
        }
    }

    streams
}

/// Compute the Strahler stream order from a stream network and flow direction.
///
/// Stream order rules:
/// - Headwater streams (no upstream tributaries) = order 1
/// - When two streams of same order merge = order + 1
/// - When two streams of different order merge = max order
pub fn compute_stream_order(
    streams: &Array2<bool>,
    flow_dir: &Array2<u8>,
) -> Array2<u8> {
    let rows = streams.nrows();
    let cols = streams.ncols();
    let mut order = Array2::<u8>::zeros((rows, cols));

    // Count in-degree for stream cells only
    let mut in_degree = Array2::<usize>::zeros((rows, cols));
    for r in 0..rows {
        for c in 0..cols {
            if !streams[[r, c]] {
                continue;
            }
            let dir = flow_dir[[r, c]];
            if dir == 0 { continue; }
            if let Some(offset) = direction_offset(dir) {
                let nr = r as isize + offset.0;
                let nc = c as isize + offset.1;
                if nr >= 0 && nr < rows as isize && nc >= 0 && nc < cols as isize {
                    let nr = nr as usize;
                    let nc = nc as usize;
                    if streams[[nr, nc]] {
                        in_degree[[nr, nc]] += 1;
                    }
                }
            }
        }
    }

    // Queue headwater stream cells
    let mut queue: Vec<(usize, usize)> = Vec::new();
    for r in 0..rows {
        for c in 0..cols {
            if streams[[r, c]] && in_degree[[r, c]] == 0 {
                order[[r, c]] = 1;
                queue.push((r, c));
            }
        }
    }

    // Track incoming orders at each junction
    let mut incoming_orders: std::collections::HashMap<(usize, usize), Vec<u8>> =
        std::collections::HashMap::new();

    while let Some((r, c)) = queue.pop() {
        let dir = flow_dir[[r, c]];
        if dir == 0 { continue; }

        if let Some(offset) = direction_offset(dir) {
            let nr = r as isize + offset.0;
            let nc = c as isize + offset.1;
            if nr >= 0 && nr < rows as isize && nc >= 0 && nc < cols as isize {
                let nr = nr as usize;
                let nc = nc as usize;
                if !streams[[nr, nc]] { continue; }

                let incoming = incoming_orders.entry((nr, nc)).or_default();
                incoming.push(order[[r, c]]);
                in_degree[[nr, nc]] -= 1;

                if in_degree[[nr, nc]] == 0 {
                    // Compute Strahler order
                    let all_incoming = incoming_orders.remove(&(nr, nc)).unwrap_or_default();
                    if all_incoming.is_empty() {
                        order[[nr, nc]] = 1;
                    } else {
                        let max_order = *all_incoming.iter().max().unwrap();
                        let max_count = all_incoming.iter().filter(|&&o| o == max_order).count();
                        if max_count >= 2 {
                            order[[nr, nc]] = max_order + 1;
                        } else {
                            order[[nr, nc]] = max_order;
                        }
                    }
                    queue.push((nr, nc));
                }
            }
        }
    }

    order
}

/// Summary statistics for flow accumulation.
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct FlowAccumulationStats {
    pub max_accumulation: f64,
    pub mean_accumulation: f64,
    pub stream_cell_count: usize,
    pub total_cells: usize,
    pub drainage_density: f64,
}

/// Compute summary statistics for flow accumulation.
pub fn flow_accumulation_stats(
    accumulation: &Array2<f64>,
    stream_threshold: f64,
    cell_size: f64,
) -> FlowAccumulationStats {
    let total = accumulation.len();
    let max_acc = accumulation.iter().cloned().fold(0.0f64, f64::max);
    let sum: f64 = accumulation.iter().sum();
    let stream_cells = accumulation.iter().filter(|&&v| v >= stream_threshold).count();

    // Drainage density = total stream length / total area
    let total_area = total as f64 * cell_size * cell_size;
    let stream_length = stream_cells as f64 * cell_size;
    let drainage_density = if total_area > 0.0 { stream_length / total_area } else { 0.0 };

    FlowAccumulationStats {
        max_accumulation: max_acc,
        mean_accumulation: sum / total as f64,
        stream_cell_count: stream_cells,
        total_cells: total,
        drainage_density,
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::dem::Dem;
    use crate::flow_direction::compute_flow_direction;

    #[test]
    fn test_simple_accumulation() {
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
        let acc = compute_flow_accumulation(&flow_dir).unwrap();

        // Rightmost column should have highest accumulation
        assert!(acc[[1, 2]] >= acc[[1, 1]]);
        assert!(acc[[1, 1]] >= acc[[1, 0]]);
    }

    #[test]
    fn test_stream_extraction() {
        let acc = Array2::from_shape_vec(
            (3, 3),
            vec![1.0, 1.0, 1.0, 1.0, 5.0, 1.0, 1.0, 1.0, 9.0],
        ).unwrap();

        let streams = extract_streams(&acc, 5.0);
        assert!(streams[[1, 1]]);
        assert!(streams[[2, 2]]);
        assert!(!streams[[0, 0]]);
    }

    #[test]
    fn test_flow_accumulation_stats() {
        let acc = Array2::from_shape_vec(
            (3, 3),
            vec![1.0, 1.0, 1.0, 1.0, 3.0, 1.0, 1.0, 1.0, 9.0],
        ).unwrap();

        let stats = flow_accumulation_stats(&acc, 3.0, 10.0);
        assert!((stats.max_accumulation - 9.0).abs() < 1e-10);
        assert_eq!(stats.stream_cell_count, 2);
        assert_eq!(stats.total_cells, 9);
    }

    #[test]
    fn test_stream_order() {
        // Simple convergent network
        let flow_dir = Array2::from_shape_vec(
            (3, 3),
            vec![
                2u8, 4, 8,
                1, 4, 16,
                0, 0, 0,
            ],
        ).unwrap();
        let streams = Array2::from_elem((3, 3), true);
        let order = compute_stream_order(&streams, &flow_dir);
        // Bottom cells receive flow and should have higher order
        assert!(order[[2, 1]] >= 1);
    }
}
