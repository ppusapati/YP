//! Yield Prediction Engine
//!
//! Multi-factor crop yield prediction using environmental inputs,
//! soil data, and management practices. Implements a multiplicative
//! yield model with stress factors.

pub mod factors;
pub mod model;
pub mod prediction;

pub use factors::{
    EnvironmentFactors, ManagementFactors, SoilFactors, StressFactor, StressSeverity,
    temperature_stress, water_stress, nitrogen_stress, pest_stress, compaction_stress, frost_stress,
};
pub use model::{
    YieldModel, YieldModelParams, LinearRegressionModel,
    r_squared, rmse, mae, mape,
};
pub use prediction::{
    YieldPrediction, predict_yield, predict_yield_batch,
    HistoricalYield, HistoricalComparison, compare_with_historical,
    SeasonalAdjustment, apply_seasonal_adjustment, prediction_with_uncertainty,
};

/// High-level yield prediction engine.
pub struct YieldPredictionEngine {
    /// Default model parameters.
    pub params: YieldModelParams,
}

impl YieldPredictionEngine {
    /// Create an engine for a specific crop.
    pub fn new(params: YieldModelParams) -> Self {
        Self { params }
    }

    /// Create an engine for wheat.
    pub fn wheat() -> Self {
        Self::new(YieldModelParams::wheat())
    }

    /// Create an engine for corn.
    pub fn corn() -> Self {
        Self::new(YieldModelParams::corn())
    }

    /// Create an engine for soybean.
    pub fn soybean() -> Self {
        Self::new(YieldModelParams::soybean())
    }

    /// Create an engine for rice.
    pub fn rice() -> Self {
        Self::new(YieldModelParams::rice())
    }

    /// Predict yield for given conditions.
    pub fn predict(
        &self,
        env: &EnvironmentFactors,
        soil: &SoilFactors,
        mgmt: &ManagementFactors,
    ) -> YieldPrediction {
        predict_yield(&self.params, env, soil, mgmt)
    }

    /// Predict yields for multiple fields.
    pub fn predict_batch(
        &self,
        inputs: &[(EnvironmentFactors, SoilFactors, ManagementFactors)],
    ) -> Vec<YieldPrediction> {
        let full_inputs: Vec<_> = inputs
            .iter()
            .map(|(env, soil, mgmt)| (self.params.clone(), env.clone(), soil.clone(), mgmt.clone()))
            .collect();
        predict_yield_batch(&full_inputs)
    }

    /// Predict yield and compare against historical data.
    pub fn predict_with_history(
        &self,
        env: &EnvironmentFactors,
        soil: &SoilFactors,
        mgmt: &ManagementFactors,
        historical: &[HistoricalYield],
    ) -> (YieldPrediction, Option<HistoricalComparison>) {
        let pred = self.predict(env, soil, mgmt);
        let comparison = compare_with_historical(&pred, historical);
        (pred, comparison)
    }

    /// Predict yield with seasonal adjustment.
    pub fn predict_with_season(
        &self,
        env: &EnvironmentFactors,
        soil: &SoilFactors,
        mgmt: &ManagementFactors,
        planting_month: u32,
        optimal_months: &[u32],
    ) -> (YieldPrediction, f64, SeasonalAdjustment) {
        let pred = self.predict(env, soil, mgmt);
        let (adjusted_yield, adjustment) = apply_seasonal_adjustment(&pred, planting_month, optimal_months);
        (pred, adjusted_yield, adjustment)
    }

    /// Get the uncertainty-adjusted confidence interval for a prediction.
    pub fn uncertainty_interval(
        &self,
        env: &EnvironmentFactors,
        soil: &SoilFactors,
        mgmt: &ManagementFactors,
    ) -> (YieldPrediction, (f64, f64)) {
        let pred = self.predict(env, soil, mgmt);
        let interval = prediction_with_uncertainty(&pred);
        (pred, interval)
    }

    /// Train a linear regression model from historical feature data.
    pub fn train_regression(
        features: &[Vec<f64>],
        targets: &[f64],
        feature_names: Vec<String>,
    ) -> Option<LinearRegressionModel> {
        LinearRegressionModel::train(features, targets, feature_names)
    }

    /// Evaluate prediction accuracy against actual yields.
    pub fn evaluate(predicted: &[f64], actual: &[f64]) -> ModelEvaluation {
        ModelEvaluation {
            r_squared: r_squared(predicted, actual),
            rmse: rmse(predicted, actual),
            mae: mae(predicted, actual),
            mape: mape(predicted, actual),
            n_samples: predicted.len().min(actual.len()),
        }
    }
}

/// Model evaluation metrics.
#[derive(Debug, Clone)]
pub struct ModelEvaluation {
    /// R-squared score.
    pub r_squared: f64,
    /// Root mean squared error.
    pub rmse: f64,
    /// Mean absolute error.
    pub mae: f64,
    /// Mean absolute percentage error.
    pub mape: f64,
    /// Number of samples evaluated.
    pub n_samples: usize,
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
    fn test_engine_creation() {
        let engine = YieldPredictionEngine::wheat();
        assert_eq!(engine.params.crop_name, "Wheat");
    }

    #[test]
    fn test_engine_predict() {
        let engine = YieldPredictionEngine::wheat();
        let pred = engine.predict(&good_env(), &good_soil(), &good_mgmt());
        assert!(pred.predicted_yield_kg_ha > 0.0);
        assert!(pred.yield_pct > 50.0);
    }

    #[test]
    fn test_engine_predict_batch() {
        let engine = YieldPredictionEngine::corn();
        let inputs = vec![
            (good_env(), good_soil(), good_mgmt()),
            (good_env(), good_soil(), good_mgmt()),
        ];
        let results = engine.predict_batch(&inputs);
        assert_eq!(results.len(), 2);
    }

    #[test]
    fn test_engine_with_history() {
        let engine = YieldPredictionEngine::wheat();
        let historical = vec![
            HistoricalYield { year: 2020, yield_kg_ha: 5000.0 },
            HistoricalYield { year: 2021, yield_kg_ha: 5500.0 },
            HistoricalYield { year: 2022, yield_kg_ha: 4800.0 },
        ];
        let (pred, comparison) = engine.predict_with_history(
            &good_env(), &good_soil(), &good_mgmt(), &historical,
        );
        assert!(pred.predicted_yield_kg_ha > 0.0);
        assert!(comparison.is_some());
    }

    #[test]
    fn test_engine_with_season() {
        let engine = YieldPredictionEngine::wheat();
        let (pred, adjusted, adjustment) = engine.predict_with_season(
            &good_env(), &good_soil(), &good_mgmt(), 4, &[3, 4, 5],
        );
        assert!(pred.predicted_yield_kg_ha > 0.0);
        assert!((adjustment.adjustment_factor - 1.0).abs() < 1e-10);
        assert!((adjusted - pred.predicted_yield_kg_ha).abs() < 1e-6);
    }

    #[test]
    fn test_engine_evaluate() {
        let predicted = vec![100.0, 200.0, 300.0];
        let actual = vec![100.0, 200.0, 300.0];
        let eval = YieldPredictionEngine::evaluate(&predicted, &actual);
        assert!((eval.r_squared - 1.0).abs() < 1e-10);
        assert!((eval.rmse - 0.0).abs() < 1e-10);
    }
}
