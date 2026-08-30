//! Yield prediction and crop growth simulation.
//!
//! Wraps the `yield-prediction-engine` for multi-factor yield forecasting.

use std::time::Instant;

use yield_prediction_engine::{
    EnvironmentFactors, ManagementFactors, SoilFactors, YieldPredictionEngine,
    YieldModelParams, prediction_with_uncertainty,
};

use crate::config::ModelPaths;
use crate::proto;

/// Handles yield prediction and crop growth simulation operations.
pub struct YieldEngine {
    model_paths: ModelPaths,
}

impl YieldEngine {
    pub fn new(model_paths: ModelPaths) -> Self {
        Self { model_paths }
    }

    /// Predict crop yield from environmental, soil, and management factors.
    pub fn predict_yield(
        &self,
        request: &proto::PredictYieldRequest,
    ) -> proto::PredictYieldResponse {
        let start = Instant::now();

        // Select the appropriate crop-specific model parameters.
        let params = match request.crop_type.to_lowercase().as_str() {
            "wheat" => YieldModelParams::wheat(),
            "corn" | "maize" => YieldModelParams::corn(),
            "soybean" => YieldModelParams::soybean(),
            "rice" => YieldModelParams::rice(),
            _ => YieldModelParams::wheat(), // fallback
        };

        let engine = YieldPredictionEngine::new(params);

        // Convert proto factors to engine factors.
        let env = convert_environment(&request.environment);
        let soil = convert_soil(&request.soil);
        let mgmt = convert_management(&request.management);

        // Run prediction with uncertainty interval.
        let (prediction, (lower, upper)) = engine.uncertainty_interval(&env, &soil, &mgmt);

        // Convert stress factors to proto format.
        let stress_factors: Vec<proto::StressFactor> = prediction
            .stress_factors
            .iter()
            .map(|sf| proto::StressFactor {
                factor_name: sf.name.clone(),
                severity: sf.severity.value(),
                yield_impact_pct: sf.yield_impact_pct,
            })
            .collect();

        let elapsed = start.elapsed();

        proto::PredictYieldResponse {
            request_id: request.request_id.clone(),
            predicted_yield_kg_per_hectare: prediction.predicted_yield_kg_ha,
            confidence_pct: prediction.yield_pct,
            yield_lower_bound: lower,
            yield_upper_bound: upper,
            stress_factors,
            model_version: self.model_paths.yield_prediction_version.clone(),
            processing_time_ms: elapsed.as_millis() as i64,
        }
    }

    /// Simulate crop growth over time.
    pub fn simulate_crop_growth(
        &self,
        request: &proto::SimulateCropGrowthRequest,
    ) -> proto::SimulateCropGrowthResponse {
        let start = Instant::now();

        let params = match request.crop_type.to_lowercase().as_str() {
            "wheat" => YieldModelParams::wheat(),
            "corn" | "maize" => YieldModelParams::corn(),
            "soybean" => YieldModelParams::soybean(),
            "rice" => YieldModelParams::rice(),
            _ => YieldModelParams::wheat(),
        };

        let engine = YieldPredictionEngine::new(params);
        let env = convert_environment(&request.initial_environment);
        let soil = convert_soil(&request.initial_soil);
        let mgmt = ManagementFactors {
            planting_day: 1,
            plant_population_per_ha: request.planting_density,
            nitrogen_applied_kg_ha: 120.0,
            irrigation_mm: 200.0,
            pest_control_effectiveness: 0.85,
            weed_control_effectiveness: 0.85,
        };

        // Run a single prediction to get the final yield estimate.
        let prediction = engine.predict(&env, &soil, &mgmt);

        // Simulate growth stages based on the prediction.
        let simulation_days = request.simulation_days.max(1);
        let stages = simulate_stages(simulation_days, prediction.predicted_yield_kg_ha);

        let elapsed = start.elapsed();

        proto::SimulateCropGrowthResponse {
            request_id: request.request_id.clone(),
            stages,
            final_biomass_kg_per_ha: prediction.predicted_yield_kg_ha * 2.5, // harvest index ~0.4
            estimated_days_to_maturity: simulation_days,
            model_version: self.model_paths.crop_growth_version.clone(),
            processing_time_ms: elapsed.as_millis() as i64,
        }
    }
}

/// Simulate growth stage progression over the specified number of days.
fn simulate_stages(days: i32, final_yield: f64) -> Vec<proto::GrowthStageResult> {
    let stage_defs = [
        ("germination", 0.0, 0.05),
        ("seedling", 0.05, 0.15),
        ("vegetative", 0.15, 0.45),
        ("flowering", 0.45, 0.70),
        ("grain_fill", 0.70, 0.90),
        ("maturation", 0.90, 1.0),
    ];

    let mut results = Vec::new();
    for (name, start_frac, end_frac) in &stage_defs {
        let stage_start_day = (*start_frac * days as f64) as i32;
        let stage_end_day = (*end_frac * days as f64) as i32;
        let mid_day = (stage_start_day + stage_end_day) / 2;
        let biomass = final_yield * 2.5 * end_frac; // total biomass at end of stage
        let lai = 3.5 * end_frac.min(&0.8); // leaf area index peaks mid-season
        let height = 120.0 * end_frac; // max canopy height ~120cm
        let water_demand = 6.0 * (0.3 + 0.7 * end_frac); // mm/day

        results.push(proto::GrowthStageResult {
            day: mid_day,
            stage_name: name.to_string(),
            biomass_kg_per_ha: biomass,
            leaf_area_index: *lai,
            canopy_height_cm: height,
            water_demand_mm: water_demand,
        });
    }

    results
}

/// Convert proto environment factors to engine EnvironmentFactors.
fn convert_environment(proto_env: &Option<proto::EnvironmentFactors>) -> EnvironmentFactors {
    match proto_env {
        Some(env) => EnvironmentFactors {
            avg_temperature_c: env.temperature_celsius,
            total_precipitation_mm: env.rainfall_mm,
            solar_radiation_mj_m2_day: env.solar_radiation,
            growing_degree_days: env.growing_degree_days,
            frost_days: 0,
            heat_stress_days: if env.temperature_celsius > 35.0 { 10 } else { 0 },
            relative_humidity_pct: env.humidity_pct,
        },
        None => EnvironmentFactors {
            avg_temperature_c: 20.0,
            total_precipitation_mm: 400.0,
            solar_radiation_mj_m2_day: 20.0,
            growing_degree_days: 2000.0,
            frost_days: 0,
            heat_stress_days: 0,
            relative_humidity_pct: 60.0,
        },
    }
}

/// Convert proto soil factors to engine SoilFactors.
fn convert_soil(proto_soil: &Option<proto::SoilFactors>) -> SoilFactors {
    match proto_soil {
        Some(soil) => SoilFactors {
            organic_matter_pct: soil.organic_matter_pct,
            ph: soil.ph,
            nitrogen_kg_ha: soil.nitrogen_ppm * 2.0, // approximate ppm to kg/ha conversion
            phosphorus_kg_ha: soil.phosphorus_ppm * 2.0,
            potassium_kg_ha: soil.potassium_ppm * 2.0,
            water_holding_capacity_mm_m: soil.moisture_pct * 3.0,
            compaction_index: soil.compaction_index,
        },
        None => SoilFactors {
            organic_matter_pct: 3.0,
            ph: 6.5,
            nitrogen_kg_ha: 80.0,
            phosphorus_kg_ha: 40.0,
            potassium_kg_ha: 60.0,
            water_holding_capacity_mm_m: 200.0,
            compaction_index: 0.0,
        },
    }
}

/// Convert proto management factors to engine ManagementFactors.
fn convert_management(proto_mgmt: &Option<proto::ManagementFactors>) -> ManagementFactors {
    match proto_mgmt {
        Some(mgmt) => ManagementFactors {
            planting_day: 100,
            plant_population_per_ha: mgmt.planting_density,
            nitrogen_applied_kg_ha: mgmt.fertilizer_rate_kg_per_ha,
            irrigation_mm: mgmt.irrigation_efficiency * 300.0, // approximate
            pest_control_effectiveness: match mgmt.pest_management_level.as_str() {
                "high" => 0.95,
                "medium" => 0.80,
                "low" => 0.60,
                _ => 0.75,
            },
            weed_control_effectiveness: 0.85,
        },
        None => ManagementFactors {
            planting_day: 100,
            plant_population_per_ha: 3_500_000.0,
            nitrogen_applied_kg_ha: 120.0,
            irrigation_mm: 200.0,
            pest_control_effectiveness: 0.85,
            weed_control_effectiveness: 0.85,
        },
    }
}
