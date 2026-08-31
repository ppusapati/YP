//! Pipe network hydraulics using the Hazen-Williams equation.

use rayon::prelude::*;
use serde::{Deserialize, Serialize};
use thiserror::Error;

/// Errors from hydraulic calculations.
#[derive(Debug, Error)]
pub enum HydraulicsError {
    #[error("Invalid pipe diameter: {0} (must be > 0)")]
    InvalidDiameter(f64),

    #[error("Invalid pipe length: {0} (must be > 0)")]
    InvalidLength(f64),

    #[error("Invalid roughness coefficient: {0} (must be > 0)")]
    InvalidRoughness(f64),

    #[error("No pipes in network")]
    EmptyNetwork,

    #[error("Pipe index out of bounds: {index} (network has {count} pipes)")]
    PipeNotFound { index: usize, count: usize },
}

/// A pipe segment in the irrigation network.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Pipe {
    /// Internal diameter in meters.
    pub diameter_m: f64,
    /// Length in meters.
    pub length_m: f64,
    /// Hazen-Williams roughness coefficient (C factor, typically 100-150).
    pub roughness_c: f64,
    /// Elevation difference (outlet - inlet) in meters (positive = uphill).
    pub elevation_diff_m: f64,
    /// Flow rate in cubic meters per second (set after solving).
    pub flow_rate_m3s: Option<f64>,
}

impl Pipe {
    /// Create a new pipe segment.
    pub fn new(diameter_m: f64, length_m: f64, roughness_c: f64, elevation_diff_m: f64) -> Result<Self, HydraulicsError> {
        if diameter_m <= 0.0 {
            return Err(HydraulicsError::InvalidDiameter(diameter_m));
        }
        if length_m <= 0.0 {
            return Err(HydraulicsError::InvalidLength(length_m));
        }
        if roughness_c <= 0.0 {
            return Err(HydraulicsError::InvalidRoughness(roughness_c));
        }
        Ok(Self {
            diameter_m,
            length_m,
            roughness_c,
            elevation_diff_m,
            flow_rate_m3s: None,
        })
    }

    /// Cross-sectional area in square meters.
    pub fn cross_section_area(&self) -> f64 {
        std::f64::consts::PI * (self.diameter_m / 2.0).powi(2)
    }

    /// Flow velocity in m/s given a flow rate in m³/s.
    pub fn velocity(&self, flow_rate_m3s: f64) -> f64 {
        let area = self.cross_section_area();
        if area <= 0.0 { 0.0 } else { flow_rate_m3s / area }
    }
}

/// Result of a flow calculation for a single pipe.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FlowResult {
    /// Pipe index in the network.
    pub pipe_index: usize,
    /// Flow rate in m³/s.
    pub flow_rate_m3s: f64,
    /// Flow velocity in m/s.
    pub velocity_ms: f64,
    /// Head loss in meters.
    pub head_loss_m: f64,
    /// Pressure at outlet in meters of head.
    pub outlet_pressure_m: f64,
}

/// A network of pipe segments.
#[derive(Debug, Clone)]
pub struct PipeNetwork {
    pub pipes: Vec<Pipe>,
    /// Inlet pressure in meters of head.
    pub inlet_pressure_m: f64,
}

impl PipeNetwork {
    /// Create a new pipe network.
    pub fn new(pipes: Vec<Pipe>, inlet_pressure_m: f64) -> Result<Self, HydraulicsError> {
        if pipes.is_empty() {
            return Err(HydraulicsError::EmptyNetwork);
        }
        Ok(Self { pipes, inlet_pressure_m })
    }

    /// Total length of the network.
    pub fn total_length(&self) -> f64 {
        self.pipes.iter().map(|p| p.length_m).sum()
    }

    /// Total elevation change.
    pub fn total_elevation_change(&self) -> f64 {
        self.pipes.iter().map(|p| p.elevation_diff_m).sum()
    }
}

/// Compute head loss using the Hazen-Williams equation.
///
/// h_f = (10.67 * L * Q^1.852) / (C^1.852 * D^4.87)
///
/// where:
/// - L = pipe length (m)
/// - Q = flow rate (m³/s)
/// - C = roughness coefficient
/// - D = diameter (m)
pub fn hazen_williams_head_loss(pipe: &Pipe, flow_rate_m3s: f64) -> f64 {
    if flow_rate_m3s.abs() < f64::EPSILON {
        return 0.0;
    }
    10.67 * pipe.length_m * flow_rate_m3s.abs().powf(1.852)
        / (pipe.roughness_c.powf(1.852) * pipe.diameter_m.powf(4.87))
}

/// Compute flow through a pipe given available head (pressure difference).
///
/// Rearranges Hazen-Williams to solve for Q given head loss.
/// Q = C * D^2.63 * (h_f / L)^0.54 * 0.2785
pub fn flow_from_head(pipe: &Pipe, available_head_m: f64) -> f64 {
    if available_head_m <= 0.0 || pipe.length_m <= 0.0 {
        return 0.0;
    }
    let slope = available_head_m / pipe.length_m;
    0.2785 * pipe.roughness_c * pipe.diameter_m.powf(2.63) * slope.powf(0.54)
}

/// Compute flow results for each pipe in a series network.
pub fn compute_pipe_flow(
    network: &PipeNetwork,
    demand_m3s: f64,
) -> Vec<FlowResult> {
    let mut results = Vec::with_capacity(network.pipes.len());
    let mut current_pressure = network.inlet_pressure_m;

    for (i, pipe) in network.pipes.iter().enumerate() {
        let head_loss = hazen_williams_head_loss(pipe, demand_m3s);
        let outlet_pressure = current_pressure - head_loss - pipe.elevation_diff_m;
        let velocity = pipe.velocity(demand_m3s);

        results.push(FlowResult {
            pipe_index: i,
            flow_rate_m3s: demand_m3s,
            velocity_ms: velocity,
            head_loss_m: head_loss,
            outlet_pressure_m: outlet_pressure,
        });

        current_pressure = outlet_pressure;
    }

    results
}

/// Compute maximum flow rate that maintains positive pressure at outlet.
///
/// Uses bisection method to find the flow rate where outlet pressure = 0.
pub fn max_sustainable_flow(network: &PipeNetwork, tolerance: f64) -> f64 {
    let mut low = 0.0;
    let mut high = 1.0; // Start with 1 m³/s and expand if needed

    // Expand upper bound until outlet pressure goes negative
    loop {
        let results = compute_pipe_flow(network, high);
        if let Some(last) = results.last() {
            if last.outlet_pressure_m < 0.0 {
                break;
            }
        }
        high *= 2.0;
        if high > 1000.0 {
            return high; // Effectively unlimited
        }
    }

    // Bisection
    for _ in 0..100 {
        let mid = (low + high) / 2.0;
        if (high - low) < tolerance {
            return mid;
        }
        let results = compute_pipe_flow(network, mid);
        if let Some(last) = results.last() {
            if last.outlet_pressure_m > 0.0 {
                low = mid;
            } else {
                high = mid;
            }
        } else {
            break;
        }
    }

    (low + high) / 2.0
}

/// Compute flow results for independent pipe segments in parallel.
pub fn compute_parallel_pipes(
    pipes: &[Pipe],
    inlet_pressure_m: f64,
) -> Vec<FlowResult> {
    pipes
        .par_iter()
        .enumerate()
        .map(|(i, pipe)| {
            let available_head = inlet_pressure_m - pipe.elevation_diff_m;
            let flow = flow_from_head(pipe, available_head.max(0.0));
            let head_loss = hazen_williams_head_loss(pipe, flow);
            let velocity = pipe.velocity(flow);

            FlowResult {
                pipe_index: i,
                flow_rate_m3s: flow,
                velocity_ms: velocity,
                head_loss_m: head_loss,
                outlet_pressure_m: inlet_pressure_m - head_loss - pipe.elevation_diff_m,
            }
        })
        .collect()
}

/// Open channel flow parameters for Manning's equation.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OpenChannelParams {
    /// Manning's roughness coefficient (n).
    pub manning_n: f64,
    /// Channel slope (m/m).
    pub slope: f64,
    /// Hydraulic radius (m) = A / P where A = cross-sectional area, P = wetted perimeter.
    pub hydraulic_radius_m: f64,
    /// Cross-sectional area of flow (m^2).
    pub cross_section_area_m2: f64,
}

/// Compute flow velocity using Manning's equation.
///
/// V = (1/n) * R^(2/3) * S^(1/2)
///
/// where:
/// - n = Manning's roughness coefficient
/// - R = hydraulic radius (m)
/// - S = channel slope (m/m)
pub fn manning_velocity(manning_n: f64, hydraulic_radius: f64, slope: f64) -> f64 {
    if manning_n <= 0.0 || hydraulic_radius <= 0.0 || slope <= 0.0 {
        return 0.0;
    }
    (1.0 / manning_n) * hydraulic_radius.powf(2.0 / 3.0) * slope.sqrt()
}

/// Compute flow rate using Manning's equation.
///
/// Q = A * V = A * (1/n) * R^(2/3) * S^(1/2)
pub fn manning_flow_rate(params: &OpenChannelParams) -> f64 {
    let velocity = manning_velocity(params.manning_n, params.hydraulic_radius_m, params.slope);
    params.cross_section_area_m2 * velocity
}

/// Compute the hydraulic radius for common channel shapes.
pub mod channel_geometry {
    /// Rectangular channel hydraulic radius.
    /// R = (b * y) / (b + 2*y) where b = bottom width, y = water depth.
    pub fn rectangular_hydraulic_radius(bottom_width: f64, depth: f64) -> f64 {
        let area = bottom_width * depth;
        let perimeter = bottom_width + 2.0 * depth;
        if perimeter <= 0.0 { return 0.0; }
        area / perimeter
    }

    /// Rectangular channel cross-section area.
    pub fn rectangular_area(bottom_width: f64, depth: f64) -> f64 {
        bottom_width * depth
    }

    /// Trapezoidal channel hydraulic radius.
    /// side_slope = horizontal / vertical (z:1).
    pub fn trapezoidal_hydraulic_radius(bottom_width: f64, depth: f64, side_slope: f64) -> f64 {
        let area = (bottom_width + side_slope * depth) * depth;
        let perimeter = bottom_width + 2.0 * depth * (1.0 + side_slope * side_slope).sqrt();
        if perimeter <= 0.0 { return 0.0; }
        area / perimeter
    }

    /// Trapezoidal channel cross-section area.
    pub fn trapezoidal_area(bottom_width: f64, depth: f64, side_slope: f64) -> f64 {
        (bottom_width + side_slope * depth) * depth
    }

    /// Circular pipe flowing full - hydraulic radius.
    pub fn circular_full_hydraulic_radius(diameter: f64) -> f64 {
        diameter / 4.0
    }

    /// Circular pipe flowing full - area.
    pub fn circular_full_area(diameter: f64) -> f64 {
        std::f64::consts::PI * (diameter / 2.0).powi(2)
    }
}

/// Compute head loss using the Darcy-Weisbach equation.
///
/// h_f = f * (L/D) * (V^2 / (2*g))
///
/// where:
/// - f = Darcy friction factor
/// - L = pipe length (m)
/// - D = pipe diameter (m)
/// - V = flow velocity (m/s)
/// - g = gravitational acceleration (9.81 m/s^2)
pub fn darcy_weisbach_head_loss(
    friction_factor: f64,
    length_m: f64,
    diameter_m: f64,
    velocity_ms: f64,
) -> f64 {
    if diameter_m <= 0.0 {
        return 0.0;
    }
    friction_factor * (length_m / diameter_m) * (velocity_ms.powi(2) / (2.0 * 9.81))
}

/// Compute the Darcy friction factor using the Colebrook-White equation.
///
/// Solved iteratively: 1/sqrt(f) = -2*log10(e/(3.7*D) + 2.51/(Re*sqrt(f)))
///
/// # Arguments
/// * `reynolds` - Reynolds number
/// * `roughness` - Pipe absolute roughness (m)
/// * `diameter` - Pipe diameter (m)
pub fn colebrook_white_friction_factor(reynolds: f64, roughness: f64, diameter: f64) -> f64 {
    if reynolds < 2300.0 {
        // Laminar flow
        return if reynolds > 0.0 { 64.0 / reynolds } else { 0.064 };
    }

    // Initial guess using Swamee-Jain approximation
    let e_d = roughness / diameter;
    let mut f = 0.25 / (((e_d / 3.7) + 5.74 / reynolds.powf(0.9)).log10()).powi(2);

    // Iterate Colebrook-White
    for _ in 0..50 {
        let rhs = -2.0 * ((e_d / 3.7) + 2.51 / (reynolds * f.sqrt())).log10();
        let f_new = 1.0 / (rhs * rhs);
        if (f_new - f).abs() < 1e-8 {
            break;
        }
        f = f_new;
    }

    f
}

/// Compute Reynolds number for pipe flow.
pub fn reynolds_number(velocity: f64, diameter: f64, kinematic_viscosity: f64) -> f64 {
    if kinematic_viscosity <= 0.0 {
        return 0.0;
    }
    velocity * diameter / kinematic_viscosity
}

/// Compute drip irrigation uniformity using Christiansen's coefficient of uniformity.
///
/// CU = 100 * (1 - sum(|qi - q_mean|) / (n * q_mean))
///
/// where qi = individual emitter flow rate, q_mean = mean flow rate.
pub fn christiansen_uniformity(flow_rates: &[f64]) -> f64 {
    if flow_rates.is_empty() {
        return 0.0;
    }
    let n = flow_rates.len() as f64;
    let mean: f64 = flow_rates.iter().sum::<f64>() / n;
    if mean <= 0.0 {
        return 0.0;
    }
    let sum_abs_dev: f64 = flow_rates.iter().map(|q| (q - mean).abs()).sum();
    100.0 * (1.0 - sum_abs_dev / (n * mean))
}

/// Compute distribution uniformity (DU) for irrigation.
///
/// DU = (average of lowest quartile) / (overall average) * 100
pub fn distribution_uniformity(flow_rates: &[f64]) -> f64 {
    if flow_rates.is_empty() {
        return 0.0;
    }
    let mut sorted = flow_rates.to_vec();
    sorted.sort_by(|a, b| a.partial_cmp(b).unwrap_or(std::cmp::Ordering::Equal));

    let n = sorted.len();
    let quarter = (n / 4).max(1);
    let low_quarter_avg: f64 = sorted[..quarter].iter().sum::<f64>() / quarter as f64;
    let overall_avg: f64 = sorted.iter().sum::<f64>() / n as f64;

    if overall_avg <= 0.0 {
        return 0.0;
    }
    (low_quarter_avg / overall_avg) * 100.0
}

/// Compute pressure loss in a pipe due to friction and fittings.
///
/// Total loss = friction_loss + sum(K * V^2 / (2*g))
/// where K = minor loss coefficients for fittings.
pub fn total_pressure_loss(
    friction_head_loss: f64,
    velocity_ms: f64,
    minor_loss_coefficients: &[f64],
) -> f64 {
    let v2_2g = velocity_ms.powi(2) / (2.0 * 9.81);
    let minor_losses: f64 = minor_loss_coefficients.iter().sum::<f64>() * v2_2g;
    friction_head_loss + minor_losses
}

/// Sprinkler overlap computation.
///
/// Given sprinkler spacing and throw radius, compute the overlap percentage.
pub fn sprinkler_overlap_pct(spacing_m: f64, throw_radius_m: f64) -> f64 {
    if spacing_m <= 0.0 || throw_radius_m <= 0.0 {
        return 0.0;
    }
    if spacing_m >= 2.0 * throw_radius_m {
        return 0.0; // No overlap
    }
    let overlap_distance = 2.0 * throw_radius_m - spacing_m;
    (overlap_distance / (2.0 * throw_radius_m) * 100.0).clamp(0.0, 100.0)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_pipe_creation() {
        let pipe = Pipe::new(0.1, 100.0, 130.0, 0.0).unwrap();
        assert!((pipe.diameter_m - 0.1).abs() < 1e-10);
    }

    #[test]
    fn test_invalid_pipe() {
        assert!(Pipe::new(-0.1, 100.0, 130.0, 0.0).is_err());
        assert!(Pipe::new(0.1, -100.0, 130.0, 0.0).is_err());
        assert!(Pipe::new(0.1, 100.0, 0.0, 0.0).is_err());
    }

    #[test]
    fn test_cross_section_area() {
        let pipe = Pipe::new(0.1, 100.0, 130.0, 0.0).unwrap();
        let expected = std::f64::consts::PI * 0.05_f64.powi(2);
        assert!((pipe.cross_section_area() - expected).abs() < 1e-10);
    }

    #[test]
    fn test_zero_flow_no_head_loss() {
        let pipe = Pipe::new(0.1, 100.0, 130.0, 0.0).unwrap();
        assert!((hazen_williams_head_loss(&pipe, 0.0) - 0.0).abs() < 1e-10);
    }

    #[test]
    fn test_head_loss_increases_with_flow() {
        let pipe = Pipe::new(0.1, 100.0, 130.0, 0.0).unwrap();
        let h1 = hazen_williams_head_loss(&pipe, 0.001);
        let h2 = hazen_williams_head_loss(&pipe, 0.01);
        assert!(h2 > h1);
    }

    #[test]
    fn test_series_network_flow() {
        let pipes = vec![
            Pipe::new(0.1, 50.0, 130.0, 0.0).unwrap(),
            Pipe::new(0.1, 50.0, 130.0, 0.0).unwrap(),
        ];
        let network = PipeNetwork::new(pipes, 30.0).unwrap();
        let results = compute_pipe_flow(&network, 0.005);
        assert_eq!(results.len(), 2);
        // Second pipe outlet pressure should be less than first
        assert!(results[1].outlet_pressure_m < results[0].outlet_pressure_m);
    }

    #[test]
    fn test_max_sustainable_flow() {
        let pipes = vec![Pipe::new(0.05, 200.0, 120.0, 5.0).unwrap()];
        let network = PipeNetwork::new(pipes, 20.0).unwrap();
        let max_flow = max_sustainable_flow(&network, 1e-6);
        assert!(max_flow > 0.0);
        // Verify outlet pressure is near zero at max flow
        let results = compute_pipe_flow(&network, max_flow);
        assert!(results.last().unwrap().outlet_pressure_m.abs() < 0.1);
    }

    #[test]
    fn test_manning_velocity() {
        // n=0.03 (earth channel), R=0.5m, S=0.001
        let v = manning_velocity(0.03, 0.5, 0.001);
        assert!(v > 0.0);
        // V = (1/0.03) * 0.5^(2/3) * 0.001^(1/2)
        let expected = (1.0 / 0.03) * 0.5_f64.powf(2.0 / 3.0) * 0.001_f64.sqrt();
        assert!((v - expected).abs() < 1e-10);
    }

    #[test]
    fn test_manning_flow_rate() {
        let params = OpenChannelParams {
            manning_n: 0.03,
            slope: 0.001,
            hydraulic_radius_m: 0.5,
            cross_section_area_m2: 2.0,
        };
        let q = manning_flow_rate(&params);
        assert!(q > 0.0);
    }

    #[test]
    fn test_rectangular_channel() {
        let r = channel_geometry::rectangular_hydraulic_radius(2.0, 1.0);
        // A = 2, P = 4, R = 0.5
        assert!((r - 0.5).abs() < 1e-10);
    }

    #[test]
    fn test_darcy_weisbach() {
        let hl = darcy_weisbach_head_loss(0.02, 100.0, 0.1, 1.0);
        // h_f = 0.02 * (100/0.1) * (1^2 / (2*9.81)) = 0.02 * 1000 * 0.051 = 1.02
        let expected = 0.02 * (100.0 / 0.1) * (1.0 / (2.0 * 9.81));
        assert!((hl - expected).abs() < 1e-10);
    }

    #[test]
    fn test_colebrook_white_laminar() {
        let f = colebrook_white_friction_factor(1000.0, 0.001, 0.1);
        assert!((f - 0.064).abs() < 1e-10);
    }

    #[test]
    fn test_colebrook_white_turbulent() {
        let f = colebrook_white_friction_factor(100_000.0, 0.0001, 0.1);
        assert!(f > 0.0);
        assert!(f < 0.1);
    }

    #[test]
    fn test_christiansen_uniformity() {
        // All same flow => 100% uniformity
        let cu = christiansen_uniformity(&[10.0, 10.0, 10.0, 10.0]);
        assert!((cu - 100.0).abs() < 1e-10);

        // Some variation
        let cu2 = christiansen_uniformity(&[10.0, 9.0, 11.0, 10.0]);
        assert!(cu2 > 90.0);
        assert!(cu2 < 100.0);
    }

    #[test]
    fn test_distribution_uniformity() {
        let du = distribution_uniformity(&[10.0, 10.0, 10.0, 10.0]);
        assert!((du - 100.0).abs() < 1e-10);
    }

    #[test]
    fn test_sprinkler_overlap() {
        let overlap = sprinkler_overlap_pct(10.0, 8.0);
        // overlap_distance = 2*8 - 10 = 6, pct = 6/16 * 100 = 37.5%
        assert!((overlap - 37.5).abs() < 1e-10);

        // No overlap
        let no_overlap = sprinkler_overlap_pct(20.0, 8.0);
        assert!((no_overlap - 0.0).abs() < 1e-10);
    }

    #[test]
    fn test_total_pressure_loss() {
        let total = total_pressure_loss(5.0, 2.0, &[0.5, 1.0]);
        let v2_2g = 4.0 / (2.0 * 9.81);
        let expected = 5.0 + 1.5 * v2_2g;
        assert!((total - expected).abs() < 1e-10);
    }
}
