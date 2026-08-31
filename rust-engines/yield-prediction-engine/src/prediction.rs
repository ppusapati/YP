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

/// Historical yield data for comparison.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HistoricalYield {
    /// Year.
    pub year: u32,
    /// Actual yield (kg/ha).
    pub yield_kg_ha: f64,
}

/// Comparison of predicted yield against historical data.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HistoricalComparison {
    /// Predicted yield.
    pub predicted_yield_kg_ha: f64,
    /// Historical average yield.
    pub historical_avg_kg_ha: f64,
    /// Historical standard deviation.
    pub historical_std_kg_ha: f64,
    /// Z-score of prediction relative to historical distribution.
    pub z_score: f64,
    /// Percentile rank relative to historical yields.
    pub percentile: f64,
    /// Whether the prediction is within 1 standard deviation of historical average.
    pub within_normal_range: bool,
    /// Year-over-year trend (slope of linear regression on historical data).
    pub trend_kg_ha_per_year: f64,
    /// Best historical yield.
    pub best_historical_kg_ha: f64,
    /// Worst historical yield.
    pub worst_historical_kg_ha: f64,
}

/// Compare a predicted yield against historical yields.
pub fn compare_with_historical(
    prediction: &YieldPrediction,
    historical: &[HistoricalYield],
) -> Option<HistoricalComparison> {
    if historical.is_empty() {
        return None;
    }

    let yields: Vec<f64> = historical.iter().map(|h| h.yield_kg_ha).collect();
    let n = yields.len() as f64;
    let avg = yields.iter().sum::<f64>() / n;
    let variance = yields.iter().map(|y| (y - avg).powi(2)).sum::<f64>() / n;
    let std_dev = variance.sqrt();

    let z_score = if std_dev > f64::EPSILON {
        (prediction.predicted_yield_kg_ha - avg) / std_dev
    } else {
        0.0
    };

    // Compute percentile
    let mut sorted = yields.clone();
    sorted.sort_by(|a, b| a.partial_cmp(b).unwrap_or(std::cmp::Ordering::Equal));
    let below_count = sorted.iter().filter(|&&y| y < prediction.predicted_yield_kg_ha).count();
    let percentile = (below_count as f64 / n) * 100.0;

    // Compute trend
    let sum_x: f64 = historical.iter().map(|h| h.year as f64).sum();
    let sum_y: f64 = yields.iter().sum();
    let sum_xy: f64 = historical.iter().map(|h| h.year as f64 * h.yield_kg_ha).sum();
    let sum_x2: f64 = historical.iter().map(|h| (h.year as f64).powi(2)).sum();
    let denom = n * sum_x2 - sum_x * sum_x;
    let trend = if denom.abs() > f64::EPSILON {
        (n * sum_xy - sum_x * sum_y) / denom
    } else {
        0.0
    };

    let best = sorted.last().copied().unwrap_or(0.0);
    let worst = sorted.first().copied().unwrap_or(0.0);

    Some(HistoricalComparison {
        predicted_yield_kg_ha: prediction.predicted_yield_kg_ha,
        historical_avg_kg_ha: avg,
        historical_std_kg_ha: std_dev,
        z_score,
        percentile,
        within_normal_range: z_score.abs() <= 1.0,
        trend_kg_ha_per_year: trend,
        best_historical_kg_ha: best,
        worst_historical_kg_ha: worst,
    })
}

/// Seasonal adjustment factors.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SeasonalAdjustment {
    /// Month of planting (1-12).
    pub planting_month: u32,
    /// Adjustment factor for yield (0.5-1.5 typically).
    pub adjustment_factor: f64,
    /// Reason for adjustment.
    pub reason: String,
}

/// Apply seasonal adjustment to a yield prediction.
pub fn apply_seasonal_adjustment(
    prediction: &YieldPrediction,
    planting_month: u32,
    optimal_planting_months: &[u32],
) -> (f64, SeasonalAdjustment) {
    let is_optimal = optimal_planting_months.contains(&planting_month);

    let (factor, reason) = if is_optimal {
        (1.0, "Planted within optimal window".to_string())
    } else {
        // Compute how far from optimal
        let min_distance = optimal_planting_months
            .iter()
            .map(|&m| {
                let diff = (planting_month as i32 - m as i32).abs();
                diff.min(12 - diff) as f64
            })
            .fold(f64::INFINITY, f64::min);

        let factor = (1.0 - min_distance * 0.08).clamp(0.5, 1.0);
        let reason = format!(
            "Planted {} month(s) from optimal window, yield reduced by {:.0}%",
            min_distance as u32,
            (1.0 - factor) * 100.0,
        );
        (factor, reason)
    };

    let adjusted_yield = prediction.predicted_yield_kg_ha * factor;

    (
        adjusted_yield,
        SeasonalAdjustment {
            planting_month,
            adjustment_factor: factor,
            reason,
        },
    )
}

/// Compute yield prediction with a wider confidence interval based on
/// the number and severity of stress factors.
pub fn prediction_with_uncertainty(prediction: &YieldPrediction) -> (f64, f64) {
    // Base uncertainty is 15%
    let base_uncertainty = 0.15;

    // Increase uncertainty for each significant stress factor
    let stress_count = prediction
        .stress_factors
        .iter()
        .filter(|s| s.factor < 0.8)
        .count();

    let uncertainty = base_uncertainty + stress_count as f64 * 0.05;
    let uncertainty = uncertainty.min(0.5); // Cap at 50%

    let low = (prediction.predicted_yield_kg_ha * (1.0 - uncertainty)).max(0.0);
    let high = prediction.predicted_yield_kg_ha * (1.0 + uncertainty);
    (low, high)
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
