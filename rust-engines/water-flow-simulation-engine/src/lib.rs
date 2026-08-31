//! Water Flow Simulation Engine
//!
//! Hydrological modeling for irrigation planning including pipe network
//! hydraulics, soil moisture simulation, and water balance computation.

pub mod hydraulics;
pub mod moisture;
pub mod water_balance;

pub use hydraulics::{
    Pipe, PipeNetwork, FlowResult, OpenChannelParams,
    compute_pipe_flow, compute_parallel_pipes, max_sustainable_flow,
    hazen_williams_head_loss, flow_from_head,
    manning_velocity, manning_flow_rate,
    darcy_weisbach_head_loss, colebrook_white_friction_factor, reynolds_number,
    christiansen_uniformity, distribution_uniformity,
    sprinkler_overlap_pct, total_pressure_loss,
    channel_geometry,
};
pub use moisture::{
    SoilMoistureProfile, MoistureParams, simulate_moisture,
    GreenAmptParams, InfiltrationResult, green_ampt_infiltration,
    available_water_content, depletion_fraction, drainage_rate_mm_day,
};
pub use water_balance::{
    WaterBalance, WaterBalanceParams, IrrigationSummary,
    compute_water_balance, irrigation_summary,
    PenmanMonteithParams, penman_monteith_et0,
    CropCoefficients, effective_rainfall_scs, effective_rainfall_daily,
};

/// High-level water flow simulation engine.
pub struct WaterFlowSimulationEngine {
    /// Soil moisture parameters.
    pub moisture_params: MoistureParams,
    /// Water balance parameters.
    pub balance_params: WaterBalanceParams,
}

impl WaterFlowSimulationEngine {
    /// Create a new engine with default parameters.
    pub fn new() -> Self {
        Self {
            moisture_params: MoistureParams::default(),
            balance_params: WaterBalanceParams::default(),
        }
    }

    /// Create with custom parameters.
    pub fn with_params(moisture_params: MoistureParams, balance_params: WaterBalanceParams) -> Self {
        Self {
            moisture_params,
            balance_params,
        }
    }

    /// Simulate soil moisture over a period.
    pub fn simulate_moisture(
        &self,
        rainfall_mm_day: f64,
        et_mm_day: f64,
        irrigation_mm_day: f64,
        days: f64,
    ) -> Result<Vec<SoilMoistureProfile>, moisture::MoistureError> {
        let initial = vec![self.moisture_params.field_capacity; self.moisture_params.num_layers];
        simulate_moisture(
            &self.moisture_params,
            &initial,
            rainfall_mm_day,
            et_mm_day,
            irrigation_mm_day,
            days,
            1.0,
        )
    }

    /// Compute daily water balance.
    pub fn compute_water_balance(&self, daily_rainfall_mm: &[f64]) -> Vec<WaterBalance> {
        compute_water_balance(&self.balance_params, daily_rainfall_mm, 0.0)
    }

    /// Compute irrigation schedule with summary.
    pub fn irrigation_schedule(&self, daily_rainfall_mm: &[f64]) -> (Vec<WaterBalance>, IrrigationSummary) {
        let balances = self.compute_water_balance(daily_rainfall_mm);
        let summary = irrigation_summary(&balances);
        (balances, summary)
    }

    /// Compute reference ET using Penman-Monteith.
    pub fn compute_et0(&self, params: &PenmanMonteithParams) -> f64 {
        penman_monteith_et0(params)
    }

    /// Compute Green-Ampt infiltration.
    pub fn compute_infiltration(
        &self,
        ga_params: &GreenAmptParams,
        rainfall_rate_mm_hr: f64,
        duration_hr: f64,
    ) -> Vec<InfiltrationResult> {
        green_ampt_infiltration(ga_params, rainfall_rate_mm_hr, duration_hr, 0.1)
    }

    /// Analyze a pipe network for a given demand.
    pub fn analyze_pipe_network(
        &self,
        network: &PipeNetwork,
        demand_m3s: f64,
    ) -> Vec<FlowResult> {
        compute_pipe_flow(network, demand_m3s)
    }
}

impl Default for WaterFlowSimulationEngine {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_engine_creation() {
        let engine = WaterFlowSimulationEngine::new();
        assert_eq!(engine.moisture_params.num_layers, 10);
    }

    #[test]
    fn test_engine_moisture_simulation() {
        let engine = WaterFlowSimulationEngine::new();
        let profiles = engine.simulate_moisture(5.0, 3.0, 0.0, 7.0).unwrap();
        assert_eq!(profiles.len(), 8); // 7 days + initial
    }

    #[test]
    fn test_engine_water_balance() {
        let engine = WaterFlowSimulationEngine::new();
        let rainfall = vec![0.0; 30];
        let (balances, summary) = engine.irrigation_schedule(&rainfall);
        assert_eq!(balances.len(), 30);
        assert!(summary.total_crop_et_mm > 0.0);
    }

    #[test]
    fn test_engine_et0() {
        let engine = WaterFlowSimulationEngine::new();
        let et0 = engine.compute_et0(&PenmanMonteithParams::default());
        assert!(et0 > 0.0);
    }
}
