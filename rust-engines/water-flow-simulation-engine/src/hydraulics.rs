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
}
