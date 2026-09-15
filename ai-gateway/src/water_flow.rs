//! Water flow simulation wrapper.
//!
//! Wraps the `water-flow-simulation-engine` for soil moisture simulation,
//! water balance computation, and irrigation scheduling.

use std::time::Instant;

use water_flow_simulation_engine::water_balance::CropCoefficients;
use water_flow_simulation_engine::{
    compute_water_balance, irrigation_summary, MoistureParams, WaterBalanceParams,
    WaterFlowSimulationEngine,
};

use crate::proto;

/// Explicit Kc wins; otherwise resolve from the FAO-56 crop table by days
/// after planting (preferred) or named growth stage; unknown crops use 1.0.
fn resolve_kc(bp: &proto::WaterFlowBalanceParams) -> f64 {
    if bp.crop_coefficient > 0.0 {
        return bp.crop_coefficient;
    }
    match CropCoefficients::for_crop(&bp.crop_type) {
        Some(kc) if bp.days_after_planting > 0 => kc.kc_at_day(bp.days_after_planting as u32),
        Some(kc) if !bp.growth_stage.trim().is_empty() => kc.kc_for_stage(&bp.growth_stage),
        Some(kc) => kc.kc_mid,
        None => 1.0,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn kc_resolution_order() {
        let mut bp = proto::WaterFlowBalanceParams {
            crop_coefficient: 0.77,
            crop_type: "wheat".into(),
            ..Default::default()
        };
        assert_eq!(resolve_kc(&bp), 0.77);
        bp.crop_coefficient = 0.0;
        bp.days_after_planting = 80; // mid-season for wheat
        assert!((resolve_kc(&bp) - 1.15).abs() < 1e-9);
        bp.days_after_planting = 0;
        bp.growth_stage = "seedling".into();
        assert!((resolve_kc(&bp) - 0.3).abs() < 1e-9);
        bp.crop_type = "unknown-crop".into();
        assert_eq!(resolve_kc(&bp), 1.0);
    }

    #[test]
    fn initial_depletion_triggers_earlier_irrigation() {
        let engine = WaterFlowEngine::new();
        let base = proto::SimulateWaterFlowRequest {
            request_id: "r".into(),
            balance_params: Some(proto::WaterFlowBalanceParams {
                crop_type: "cotton".into(),
                growth_stage: "flowering".into(),
                reference_et_mm_day: 6.0,
                ..Default::default()
            }),
            daily_rainfall_mm: vec![0.0; 10],
            simulation_days: 10.0,
            ..Default::default()
        };
        let dry = proto::SimulateWaterFlowRequest {
            initial_depletion_mm: 40.0,
            ..base.clone()
        };
        let first_event = |r: &proto::SimulateWaterFlowResponse| {
            r.water_balance.iter().position(|d| d.irrigation_needed)
        };
        let wet_first = first_event(&engine.simulate(&base));
        let dry_first = first_event(&engine.simulate(&dry));
        assert!(dry_first.is_some());
        assert!(
            wet_first.map_or(true, |w| dry_first.unwrap() < w),
            "dry {dry_first:?} vs wet {wet_first:?}"
        );
    }
}

/// Handles water flow simulation operations.
pub struct WaterFlowEngine;

impl WaterFlowEngine {
    pub fn new() -> Self {
        Self
    }

    /// Run water flow simulation.
    pub fn simulate(
        &self,
        req: &proto::SimulateWaterFlowRequest,
    ) -> proto::SimulateWaterFlowResponse {
        let start = Instant::now();

        // Build moisture params from request or use defaults.
        let moisture_params = if let Some(ref mp) = req.moisture_params {
            MoistureParams {
                num_layers: if mp.num_layers > 0 {
                    mp.num_layers as usize
                } else {
                    10
                },
                layer_thickness_m: if mp.layer_thickness_m > 0.0 {
                    mp.layer_thickness_m
                } else {
                    0.1
                },
                k_sat_m_day: if mp.k_sat_m_day > 0.0 {
                    mp.k_sat_m_day
                } else {
                    0.05
                },
                field_capacity: if mp.field_capacity > 0.0 {
                    mp.field_capacity
                } else {
                    0.30
                },
                wilting_point: if mp.wilting_point > 0.0 {
                    mp.wilting_point
                } else {
                    0.10
                },
                saturation: if mp.saturation > 0.0 {
                    mp.saturation
                } else {
                    0.45
                },
                root_zone_depth_m: if mp.root_zone_depth_m > 0.0 {
                    mp.root_zone_depth_m
                } else {
                    0.6
                },
            }
        } else {
            MoistureParams::default()
        };

        // Build water balance params from request or use defaults.
        let balance_params = if let Some(ref bp) = req.balance_params {
            WaterBalanceParams {
                field_area_ha: if bp.field_area_ha > 0.0 {
                    bp.field_area_ha
                } else {
                    1.0
                },
                crop_coefficient: resolve_kc(bp),
                reference_et_mm_day: if bp.reference_et_mm_day > 0.0 {
                    bp.reference_et_mm_day
                } else {
                    5.0
                },
                root_zone_depth_m: if bp.root_zone_depth_m > 0.0 {
                    bp.root_zone_depth_m
                } else {
                    0.6
                },
                field_capacity: if bp.field_capacity > 0.0 {
                    bp.field_capacity
                } else {
                    0.30
                },
                wilting_point: if bp.wilting_point > 0.0 {
                    bp.wilting_point
                } else {
                    0.10
                },
                management_allowed_depletion: if bp.management_allowed_depletion > 0.0 {
                    bp.management_allowed_depletion
                } else {
                    0.5
                },
            }
        } else {
            WaterBalanceParams::default()
        };

        let engine =
            WaterFlowSimulationEngine::with_params(moisture_params, balance_params.clone());

        let mut resp = proto::SimulateWaterFlowResponse {
            request_id: req.request_id.clone(),
            ..Default::default()
        };

        // Run soil moisture simulation.
        let days = if req.simulation_days > 0.0 {
            req.simulation_days
        } else {
            30.0
        };
        let rainfall = if req.rainfall_mm_day >= 0.0 {
            req.rainfall_mm_day
        } else {
            0.0
        };
        let et = if req.et_mm_day >= 0.0 {
            req.et_mm_day
        } else {
            5.0
        };
        let irrigation = if req.irrigation_mm_day >= 0.0 {
            req.irrigation_mm_day
        } else {
            0.0
        };

        if let Ok(profiles) = engine.simulate_moisture(rainfall, et, irrigation, days) {
            resp.moisture_profiles = profiles
                .iter()
                .map(|p| proto::SoilMoistureSnapshot {
                    time_days: p.time_days,
                    layer_moisture: p.moisture.clone(),
                    root_zone_water_mm: p.root_zone_water_mm,
                    available_water_mm: p.available_water_mm,
                    drainage_mm_day: p.drainage_mm_day,
                })
                .collect();
        }

        // Run water balance computation.
        let daily_rain: Vec<f64> = if !req.daily_rainfall_mm.is_empty() {
            req.daily_rainfall_mm.clone()
        } else {
            // Generate a uniform rainfall series for the simulation period.
            vec![rainfall; days as usize]
        };

        let initial_depletion = req.initial_depletion_mm.max(0.0);
        let balances = compute_water_balance(&balance_params, &daily_rain, initial_depletion);
        resp.water_balance = balances
            .iter()
            .map(|b| proto::WaterBalanceDay {
                day: b.day as i32,
                etc_mm_day: b.etc_mm_day,
                depletion_mm: b.depletion_mm,
                total_available_water_mm: b.total_available_water_mm,
                readily_available_water_mm: b.readily_available_water_mm,
                irrigation_needed: b.irrigation_needed,
                irrigation_amount_mm: b.irrigation_amount_mm,
                effective_rainfall_mm: b.effective_rainfall_mm,
                deep_percolation_mm: b.deep_percolation_mm,
            })
            .collect();

        // Compute irrigation summary.
        let summary = irrigation_summary(&balances);
        resp.irrigation_summary = Some(proto::WaterFlowIrrigationSummary {
            total_irrigation_mm: summary.total_irrigation_mm,
            total_effective_rainfall_mm: summary.total_effective_rainfall_mm,
            total_crop_et_mm: summary.total_crop_et_mm,
            total_deep_percolation_mm: summary.total_deep_percolation_mm,
            irrigation_events: summary.irrigation_events as i32,
            average_interval_days: summary.average_interval_days,
            water_use_efficiency: summary.water_use_efficiency,
        });

        resp.processing_time_ms = start.elapsed().as_millis() as i64;
        resp
    }
}
