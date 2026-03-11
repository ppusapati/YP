//! Water Flow Simulation Engine
//!
//! Hydrological modeling for irrigation planning including pipe network
//! hydraulics, soil moisture simulation, and water balance computation.

pub mod hydraulics;
pub mod moisture;
pub mod water_balance;

pub use hydraulics::{Pipe, PipeNetwork, FlowResult, compute_pipe_flow};
pub use moisture::{SoilMoistureProfile, MoistureParams, simulate_moisture};
pub use water_balance::{WaterBalance, WaterBalanceParams, compute_water_balance};
