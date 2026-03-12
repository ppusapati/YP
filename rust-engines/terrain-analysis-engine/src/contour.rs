//! Contour line generation from DEM data.
//!
//! Uses the marching squares algorithm to extract iso-elevation contour lines.

use serde::{Deserialize, Serialize};

use crate::dem::{Dem, TerrainError};

/// A point on a contour line.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ContourPoint {
    pub x: f64,
    pub y: f64,
}

/// A single contour line at a specific elevation.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ContourLine {
    pub elevation: f64,
    pub points: Vec<ContourPoint>,
}

/// Collection of contour lines.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ContourSet {
    pub contour_interval: f64,
    pub lines: Vec<ContourLine>,
    pub min_elevation: f64,
    pub max_elevation: f64,
}

/// Generate contour lines from a DEM at a specified interval.
///
/// Uses the marching squares algorithm to trace iso-elevation lines through
/// the DEM grid. Each cell is examined for crossings of the contour level.
pub fn generate_contours(dem: &Dem, interval: f64) -> Result<ContourSet, TerrainError> {
    if interval <= 0.0 || interval.is_nan() {
        return Err(TerrainError::InvalidCellSize(interval));
    }

    let stats = dem.statistics();
    if stats.valid_cells == 0 {
        return Err(TerrainError::EmptyDem);
    }

    let min_elev = (stats.min_elevation / interval).floor() * interval;
    let max_elev = stats.max_elevation;

    let mut lines = Vec::new();
    let mut level = min_elev + interval;

    while level <= max_elev {
        let contour_lines = trace_contour_level(dem, level);
        lines.extend(contour_lines);
        level += interval;
    }

    Ok(ContourSet {
        contour_interval: interval,
        lines,
        min_elevation: stats.min_elevation,
        max_elevation: stats.max_elevation,
    })
}

/// Trace all contour line segments at a specific elevation level.
///
/// Implements marching squares: for each 2x2 cell group, determine which
/// edges the contour crosses and compute the crossing point by linear
/// interpolation.
fn trace_contour_level(dem: &Dem, level: f64) -> Vec<ContourLine> {
    let rows = dem.rows();
    let cols = dem.cols();
    let cs = dem.cell_size;

    if rows < 2 || cols < 2 {
        return Vec::new();
    }

    let mut segments: Vec<(ContourPoint, ContourPoint)> = Vec::new();

    for r in 0..rows - 1 {
        for c in 0..cols - 1 {
            // Four corners of the cell (top-left, top-right, bottom-right, bottom-left)
            let tl = dem.elevation[[r, c]];
            let tr = dem.elevation[[r, c + 1]];
            let br = dem.elevation[[r + 1, c + 1]];
            let bl = dem.elevation[[r + 1, c]];

            // Skip cells with nodata
            if tl == dem.nodata || tr == dem.nodata || br == dem.nodata || bl == dem.nodata {
                continue;
            }
            if tl.is_nan() || tr.is_nan() || br.is_nan() || bl.is_nan() {
                continue;
            }

            // Marching squares case index (4-bit)
            let mut case_index = 0u8;
            if tl >= level { case_index |= 8; }
            if tr >= level { case_index |= 4; }
            if br >= level { case_index |= 2; }
            if bl >= level { case_index |= 1; }

            // No contour crosses this cell
            if case_index == 0 || case_index == 15 {
                continue;
            }

            let x0 = c as f64 * cs;
            let y0 = r as f64 * cs;

            // Interpolation positions along edges
            let top = lerp_position(tl, tr, level);
            let right = lerp_position(tr, br, level);
            let bottom = lerp_position(bl, br, level);
            let left = lerp_position(tl, bl, level);

            let top_pt = ContourPoint { x: x0 + top * cs, y: y0 };
            let right_pt = ContourPoint { x: x0 + cs, y: y0 + right * cs };
            let bottom_pt = ContourPoint { x: x0 + bottom * cs, y: y0 + cs };
            let left_pt = ContourPoint { x: x0, y: y0 + left * cs };

            // Generate line segments based on case
            match case_index {
                1 | 14 => segments.push((left_pt, bottom_pt)),
                2 | 13 => segments.push((bottom_pt, right_pt)),
                3 | 12 => segments.push((left_pt, right_pt)),
                4 | 11 => segments.push((top_pt, right_pt)),
                5 => {
                    // Saddle point - ambiguous case, use center average
                    let center = (tl + tr + br + bl) / 4.0;
                    if center >= level {
                        segments.push((top_pt.clone(), left_pt.clone()));
                        segments.push((bottom_pt, right_pt));
                    } else {
                        segments.push((top_pt, right_pt));
                        segments.push((left_pt, bottom_pt));
                    }
                }
                6 | 9 => segments.push((top_pt, bottom_pt)),
                7 | 8 => segments.push((top_pt, left_pt)),
                10 => {
                    // Saddle point
                    let center = (tl + tr + br + bl) / 4.0;
                    if center >= level {
                        segments.push((top_pt.clone(), right_pt.clone()));
                        segments.push((left_pt, bottom_pt));
                    } else {
                        segments.push((top_pt, left_pt));
                        segments.push((bottom_pt, right_pt));
                    }
                }
                _ => {} // 0 and 15 already handled
            }
        }
    }

    // Chain segments into contour lines
    chain_segments(segments, level)
}

/// Linear interpolation position along an edge between two values.
fn lerp_position(v0: f64, v1: f64, level: f64) -> f64 {
    let diff = v1 - v0;
    if diff.abs() < f64::EPSILON {
        0.5
    } else {
        ((level - v0) / diff).clamp(0.0, 1.0)
    }
}

/// Chain individual line segments into connected contour lines.
fn chain_segments(segments: Vec<(ContourPoint, ContourPoint)>, elevation: f64) -> Vec<ContourLine> {
    if segments.is_empty() {
        return Vec::new();
    }

    let mut remaining: Vec<(ContourPoint, ContourPoint)> = segments;
    let mut lines = Vec::new();
    let tolerance = 1e-6;

    while !remaining.is_empty() {
        let (start, end) = remaining.remove(0);
        let mut chain = vec![start, end];
        let mut changed = true;

        while changed {
            changed = false;
            let mut i = 0;
            while i < remaining.len() {
                let chain_end = chain.last().unwrap();
                let chain_start = chain.first().unwrap();

                let (ref seg_start, ref seg_end) = remaining[i];

                if distance(chain_end, seg_start) < tolerance {
                    chain.push(seg_end.clone());
                    remaining.remove(i);
                    changed = true;
                } else if distance(chain_end, seg_end) < tolerance {
                    chain.push(seg_start.clone());
                    remaining.remove(i);
                    changed = true;
                } else if distance(chain_start, seg_end) < tolerance {
                    chain.insert(0, seg_start.clone());
                    remaining.remove(i);
                    changed = true;
                } else if distance(chain_start, seg_start) < tolerance {
                    chain.insert(0, seg_end.clone());
                    remaining.remove(i);
                    changed = true;
                } else {
                    i += 1;
                }
            }
        }

        lines.push(ContourLine {
            elevation,
            points: chain,
        });
    }

    lines
}

/// Euclidean distance between two contour points.
fn distance(a: &ContourPoint, b: &ContourPoint) -> f64 {
    ((a.x - b.x).powi(2) + (a.y - b.y).powi(2)).sqrt()
}

/// Generate contour lines at specific elevation levels.
pub fn generate_contours_at_levels(dem: &Dem, levels: &[f64]) -> Result<ContourSet, TerrainError> {
    let stats = dem.statistics();
    if stats.valid_cells == 0 {
        return Err(TerrainError::EmptyDem);
    }

    let mut lines = Vec::new();
    for &level in levels {
        let contour_lines = trace_contour_level(dem, level);
        lines.extend(contour_lines);
    }

    let interval = if levels.len() >= 2 {
        levels[1] - levels[0]
    } else {
        0.0
    };

    Ok(ContourSet {
        contour_interval: interval,
        lines,
        min_elevation: stats.min_elevation,
        max_elevation: stats.max_elevation,
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_contour_generation() {
        // A simple slope from 0 to 100
        let dem = Dem::from_vec(
            vec![
                0.0,  25.0, 50.0,  75.0, 100.0,
                0.0,  25.0, 50.0,  75.0, 100.0,
                0.0,  25.0, 50.0,  75.0, 100.0,
                0.0,  25.0, 50.0,  75.0, 100.0,
                0.0,  25.0, 50.0,  75.0, 100.0,
            ],
            5, 5, 10.0, -9999.0,
        ).unwrap();

        let contours = generate_contours(&dem, 25.0).unwrap();
        // Should generate contours at 25, 50, 75
        assert!(!contours.lines.is_empty());
        assert!(contours.lines.iter().any(|l| (l.elevation - 25.0).abs() < 1e-10));
        assert!(contours.lines.iter().any(|l| (l.elevation - 50.0).abs() < 1e-10));
        assert!(contours.lines.iter().any(|l| (l.elevation - 75.0).abs() < 1e-10));
    }

    #[test]
    fn test_flat_terrain_no_contours() {
        let dem = Dem::from_vec(
            vec![100.0; 25],
            5, 5, 10.0, -9999.0,
        ).unwrap();

        let contours = generate_contours(&dem, 10.0).unwrap();
        // Flat terrain: no contour crossings between cells
        assert!(contours.lines.is_empty());
    }

    #[test]
    fn test_contour_at_specific_levels() {
        let dem = Dem::from_vec(
            vec![
                0.0,  50.0, 100.0,
                0.0,  50.0, 100.0,
                0.0,  50.0, 100.0,
            ],
            3, 3, 10.0, -9999.0,
        ).unwrap();

        let contours = generate_contours_at_levels(&dem, &[25.0, 75.0]).unwrap();
        assert!(!contours.lines.is_empty());
    }

    #[test]
    fn test_invalid_interval() {
        let dem = Dem::from_vec(vec![1.0; 9], 3, 3, 10.0, -9999.0).unwrap();
        assert!(generate_contours(&dem, -1.0).is_err());
        assert!(generate_contours(&dem, 0.0).is_err());
    }

    #[test]
    fn test_lerp_position() {
        assert!((lerp_position(0.0, 100.0, 50.0) - 0.5).abs() < 1e-10);
        assert!((lerp_position(0.0, 100.0, 25.0) - 0.25).abs() < 1e-10);
        assert!((lerp_position(0.0, 100.0, 0.0) - 0.0).abs() < 1e-10);
        assert!((lerp_position(0.0, 100.0, 100.0) - 1.0).abs() < 1e-10);
    }

    #[test]
    fn test_contour_points_non_empty() {
        let dem = Dem::from_vec(
            vec![
                0.0,  50.0, 100.0,
                0.0,  50.0, 100.0,
                0.0,  50.0, 100.0,
            ],
            3, 3, 10.0, -9999.0,
        ).unwrap();

        let contours = generate_contours(&dem, 25.0).unwrap();
        for line in &contours.lines {
            assert!(line.points.len() >= 2);
        }
    }
}
