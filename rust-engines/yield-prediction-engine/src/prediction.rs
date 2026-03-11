//! Yield prediction computation.

use rayon::prelude::*;
use serde::{Deserialize, Serialize};

use crate::factors::*;
use crate::model::{YieldModel, YieldModelParams};

/// Complete yield prediction result.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct YieldPrediction {
    /// Crop name.
    pub crop_name: String,
    /// Predicted yield (kg/ha).
    pub predicted_yield_kg_ha: f64,
    /// Maximum attainable yield (kg/ha).
    pub max_yield_kg_ha: f64,
    /// Yield as percentage of maximum.
    pub yield_pct: f64,
    /// Overall yield factor (product of all stress factors).
    pub overall_factor: f64,
    /// Individual stress factors.
    pub stress_factors: Vec<StressFactor>,
    /// Most limiting factor.
    pub limiting_factor: String,
    /// Confidence interval (low, high) in kg/ha.
    pub confidence_interval: (f64, f64),
}

/// Predict yield for a single field.
pub fn predict_yield(
    model_params: &YieldModelParams,
    env: &EnvironmentFactors,
    soil: &SoilFactors,
    mgmt: &ManagementFactors,
) -> YieldPrediction {
    let model = YieldModel::new(model_params.clone());
    let mut stress_factors = Vec::new();

    // Temperature stress
    let temp_stress = temperature_stress(
        env.avg_temperature_c,
        model_params.optimal_temp_range.0,
        model_params.optimal_temp_range.1,
    );
    stress_factors.push(temp_stress);

    // Water stress
    let total_water = env.total_precipitation_mm + mgmt.irrigation_mm;
    let water_s = water_stress(total_water, model_params.water_requirement_mm);
    stress_factors.push(water_s);

    // Nitrogen stress
    let n_stress = nitrogen_stress(
        soil.nitrogen_kg_ha,
        mgmt.nitrogen_applied_kg_ha,
        model_params.nitrogen_requirement_kg_ha,
    );
    stress_factors.push(n_stress);

    // Pest/disease stress
    let pest_s = pest_stress(mgmt.pest_control_effectiveness);
    stress_factors.push(pest_s);

    // Soil compaction
    let compact_s = compaction_stress(soil.compaction_index);
    stress_factors.push(compact_s);

    // Frost damage
    let frost_s = frost_stress(env.frost_days);
    stress_factors.push(frost_s);

    // Model-specific factors
    let pop_factor = model.population_factor(mgmt.plant_population_per_ha);
    stress_factors.push(StressFactor {
        name: "Plant population".to_string(),
        factor: pop_factor,
        severity: StressSeverity::from_factor(pop_factor),
    });

    let gdd_factor = model.gdd_factor(env.growing_degree_days);
    stress_factors.push(StressFactor {
        name: "Growing degree days".to_string(),
        factor: gdd_factor,
        severity: StressSeverity::from_factor(gdd_factor),
    });

    let ph_factor = model.ph_factor(soil.ph);
    stress_factors.push(StressFactor {
        name: "Soil pH".to_string(),
        factor: ph_factor,
        severity: StressSeverity::from_factor(ph_factor),
    });

    // Overall yield factor (multiplicative model)
    let overall_factor = stress_factors
        .iter()
        .map(|s| s.factor)
        .fold(1.0, |acc, f| acc * f);

    let predicted = model_params.max_yield_kg_ha * overall_factor;

    // Limiting factor
    let limiting = stress_factors
        .iter()
        .min_by(|a, b| a.factor.partial_cmp(&b.factor).unwrap_or(std::cmp::Ordering::Equal))
        .map(|s| s.name.clone())
        .unwrap_or_else(|| "None".to_string());

    // Confidence interval (±15% uncertainty)
    let uncertainty = 0.15;
    let ci_low = (predicted * (1.0 - uncertainty)).max(0.0);
    let ci_high = predicted * (1.0 + uncertainty);

    YieldPrediction {
        crop_name: model_params.crop_name.clone(),
        predicted_yield_kg_ha: predicted,
        max_yield_kg_ha: model_params.max_yield_kg_ha,
        yield_pct: (overall_factor * 100.0).clamp(0.0, 100.0),
        overall_factor,
        stress_factors,
        limiting_factor: limiting,
        confidence_interval: (ci_low, ci_high),
    }
}

/// Predict yields for multiple fields in parallel.
pub fn predict_yield_batch(
    inputs: &[(YieldModelParams, EnvironmentFactors, SoilFactors, ManagementFactors)],
) -> Vec<YieldPrediction> {
    inputs
        .par_iter()
        .map(|(model, env, soil, mgmt)| predict_yield(model, env, soil, mgmt))
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    fn good_env() -> EnvironmentFactors {
        EnvironmentFactors {
            avg_temperature_c: 20.0,
            total_precipitation_mm: 400.0,
            solar_radiation_mj_m2_day: 20.0,
            growing_degree_days: 2000.0,
            frost_days: 0,
            heat_stress_days: 0,
            relative_humidity_pct: 60.0,
        }
    }

    fn good_soil() -> SoilFactors {
        SoilFactors {
            organic_matter_pct: 3.0,
            ph: 6.5,
            nitrogen_kg_ha: 80.0,
            phosphorus_kg_ha: 40.0,
            potassium_kg_ha: 60.0,
            water_holding_capacity_mm_m: 200.0,
            compaction_index: 0.0,
        }
    }

    fn good_mgmt() -> ManagementFactors {
        ManagementFactors {
            planting_day: 100,
            plant_population_per_ha: 3_500_000.0,
            nitrogen_applied_kg_ha: 120.0,
            irrigation_mm: 200.0,
            pest_control_effectiveness: 0.9,
            weed_control_effectiveness: 0.9,
        }
    }

    #[test]
    fn test_good_conditions_high_yield() {
        let params = YieldModelParams::wheat();
        let pred = predict_yield(&params, &good_env(), &good_soil(), &good_mgmt());
        // Under good conditions, yield should be > 60% of max
        assert!(pred.yield_pct > 60.0, "yield_pct={}", pred.yield_pct);
        assert!(pred.predicted_yield_kg_ha > 0.0);
    }

    #[test]
    fn test_poor_conditions_low_yield() {
        let params = YieldModelParams::wheat();
        let env = EnvironmentFactors {
            avg_temperature_c: 35.0,
            total_precipitation_mm: 100.0,
            solar_radiation_mj_m2_day: 15.0,
            growing_degree_days: 500.0,
            frost_days: 10,
            heat_stress_days: 30,
            relative_humidity_pct: 30.0,
        };
        let soil = SoilFactors {
            organic_matter_pct: 0.5,
            ph: 4.0,
            nitrogen_kg_ha: 10.0,
            phosphorus_kg_ha: 5.0,
            potassium_kg_ha: 10.0,
            water_holding_capacity_mm_m: 50.0,
            compaction_index: 0.8,
        };
        let mgmt = ManagementFactors {
            planting_day: 100,
            plant_population_per_ha: 100_000.0,
            nitrogen_applied_kg_ha: 0.0,
            irrigation_mm: 0.0,
            pest_control_effectiveness: 0.0,
            weed_control_effectiveness: 0.0,
        };
        let pred = predict_yield(&params, &env, &soil, &mgmt);
        assert!(pred.yield_pct < 30.0, "yield_pct={}", pred.yield_pct);
    }

    #[test]
    fn test_confidence_interval() {
        let params = YieldModelParams::wheat();
        let pred = predict_yield(&params, &good_env(), &good_soil(), &good_mgmt());
        assert!(pred.confidence_interval.0 < pred.predicted_yield_kg_ha);
        assert!(pred.confidence_interval.1 > pred.predicted_yield_kg_ha);
    }

    #[test]
    fn test_batch_prediction() {
        let inputs: Vec<_> = (0..5)
            .map(|_| {
                (
                    YieldModelParams::wheat(),
                    good_env(),
                    good_soil(),
                    good_mgmt(),
                )
            })
            .collect();
        let results = predict_yield_batch(&inputs);
        assert_eq!(results.len(), 5);
    }

    #[test]
    fn test_stress_factors_present() {
        let params = YieldModelParams::corn();
        let pred = predict_yield(&params, &good_env(), &good_soil(), &good_mgmt());
        assert!(!pred.stress_factors.is_empty());
        assert!(!pred.limiting_factor.is_empty());
    }
}
