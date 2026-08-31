//! Yield prediction model configuration and crop parameters.

use serde::{Deserialize, Serialize};

/// Yield model parameters for a specific crop.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct YieldModelParams {
    /// Crop name.
    pub crop_name: String,
    /// Maximum attainable yield under ideal conditions (kg/ha).
    pub max_yield_kg_ha: f64,
    /// Optimal temperature range (°C).
    pub optimal_temp_range: (f64, f64),
    /// Water requirement for the growing season (mm).
    pub water_requirement_mm: f64,
    /// Nitrogen requirement (kg/ha).
    pub nitrogen_requirement_kg_ha: f64,
    /// Optimal pH range.
    pub optimal_ph_range: (f64, f64),
    /// Required growing degree days.
    pub required_gdd: f64,
    /// Optimal plant population (plants/ha).
    pub optimal_plant_population: f64,
}

impl YieldModelParams {
    /// Create parameters for common crops.
    pub fn wheat() -> Self {
        Self {
            crop_name: "Wheat".to_string(),
            max_yield_kg_ha: 8000.0,
            optimal_temp_range: (15.0, 25.0),
            water_requirement_mm: 500.0,
            nitrogen_requirement_kg_ha: 150.0,
            optimal_ph_range: (6.0, 7.5),
            required_gdd: 1500.0,
            optimal_plant_population: 3_500_000.0,
        }
    }

    pub fn corn() -> Self {
        Self {
            crop_name: "Corn".to_string(),
            max_yield_kg_ha: 12000.0,
            optimal_temp_range: (20.0, 30.0),
            water_requirement_mm: 600.0,
            nitrogen_requirement_kg_ha: 200.0,
            optimal_ph_range: (5.8, 7.0),
            required_gdd: 2500.0,
            optimal_plant_population: 80_000.0,
        }
    }

    pub fn soybean() -> Self {
        Self {
            crop_name: "Soybean".to_string(),
            max_yield_kg_ha: 4000.0,
            optimal_temp_range: (20.0, 30.0),
            water_requirement_mm: 500.0,
            nitrogen_requirement_kg_ha: 40.0, // N-fixing
            optimal_ph_range: (6.0, 7.0),
            required_gdd: 2200.0,
            optimal_plant_population: 350_000.0,
        }
    }

    pub fn rice() -> Self {
        Self {
            crop_name: "Rice".to_string(),
            max_yield_kg_ha: 9000.0,
            optimal_temp_range: (25.0, 35.0),
            water_requirement_mm: 1200.0,
            nitrogen_requirement_kg_ha: 120.0,
            optimal_ph_range: (5.5, 6.5),
            required_gdd: 2000.0,
            optimal_plant_population: 300_000.0,
        }
    }
}

/// The yield prediction model.
#[derive(Debug, Clone)]
pub struct YieldModel {
    pub params: YieldModelParams,
}

impl YieldModel {
    /// Create a new yield model for a crop.
    pub fn new(params: YieldModelParams) -> Self {
        Self { params }
    }

    /// Compute the plant population factor (0-1).
    pub fn population_factor(&self, actual_population: f64) -> f64 {
        let ratio = actual_population / self.params.optimal_plant_population;
        if ratio >= 0.8 && ratio <= 1.2 {
            1.0
        } else if ratio < 0.8 {
            (ratio / 0.8).clamp(0.0, 1.0)
        } else {
            // Overcrowding penalty
            (1.0 - (ratio - 1.2) * 0.5).clamp(0.5, 1.0)
        }
    }

    /// Compute the growing degree day factor (0-1).
    pub fn gdd_factor(&self, accumulated_gdd: f64) -> f64 {
        if accumulated_gdd >= self.params.required_gdd {
            1.0
        } else {
            (accumulated_gdd / self.params.required_gdd).clamp(0.0, 1.0)
        }
    }

    /// Compute the soil pH factor (0-1).
    pub fn ph_factor(&self, ph: f64) -> f64 {
        let (min_ph, max_ph) = self.params.optimal_ph_range;
        if ph >= min_ph && ph <= max_ph {
            1.0
        } else if ph < min_ph {
            (1.0 - (min_ph - ph) / 2.0).clamp(0.0, 1.0)
        } else {
            (1.0 - (ph - max_ph) / 2.0).clamp(0.0, 1.0)
        }
    }
}

/// Simple linear regression model for yield prediction.
///
/// y = b0 + b1*x1 + b2*x2 + ... + bn*xn
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LinearRegressionModel {
    /// Intercept (b0).
    pub intercept: f64,
    /// Coefficients (b1..bn).
    pub coefficients: Vec<f64>,
    /// Feature names for interpretability.
    pub feature_names: Vec<String>,
    /// R-squared score from training.
    pub r_squared: f64,
    /// Root mean squared error from training.
    pub rmse: f64,
    /// Number of training samples.
    pub n_samples: usize,
}

impl LinearRegressionModel {
    /// Train a linear regression model using ordinary least squares.
    ///
    /// # Arguments
    /// * `features` - Matrix of features, each inner Vec is one sample
    /// * `targets` - Target values (yields)
    /// * `feature_names` - Names for each feature
    pub fn train(
        features: &[Vec<f64>],
        targets: &[f64],
        feature_names: Vec<String>,
    ) -> Option<Self> {
        if features.is_empty() || targets.is_empty() || features.len() != targets.len() {
            return None;
        }
        let n = features.len();
        let p = features[0].len();

        if feature_names.len() != p {
            return None;
        }

        // Simple OLS using normal equations (X^T X)^-1 X^T y
        // For production, you'd use a proper linear algebra library.
        // Here we implement a simplified approach using gradient descent.

        let mut weights = vec![0.0; p];
        let mut bias = 0.0;
        let learning_rate = 0.001;
        let iterations = 1000;

        // Normalize features for better convergence
        let mut means = vec![0.0; p];
        let mut stds = vec![1.0; p];
        for j in 0..p {
            let vals: Vec<f64> = features.iter().map(|f| f[j]).collect();
            let mean = vals.iter().sum::<f64>() / n as f64;
            let var = vals.iter().map(|v| (v - mean).powi(2)).sum::<f64>() / n as f64;
            means[j] = mean;
            stds[j] = var.sqrt().max(1e-8);
        }

        let target_mean = targets.iter().sum::<f64>() / n as f64;
        let target_std = (targets.iter().map(|t| (t - target_mean).powi(2)).sum::<f64>() / n as f64).sqrt().max(1e-8);

        let normalized_features: Vec<Vec<f64>> = features
            .iter()
            .map(|f| f.iter().enumerate().map(|(j, v)| (v - means[j]) / stds[j]).collect())
            .collect();

        let normalized_targets: Vec<f64> = targets.iter().map(|t| (t - target_mean) / target_std).collect();

        for _ in 0..iterations {
            let mut grad_w = vec![0.0; p];
            let mut grad_b = 0.0;

            for i in 0..n {
                let pred: f64 = normalized_features[i].iter().zip(weights.iter()).map(|(x, w)| x * w).sum::<f64>() + bias;
                let err = pred - normalized_targets[i];
                for j in 0..p {
                    grad_w[j] += err * normalized_features[i][j];
                }
                grad_b += err;
            }

            for j in 0..p {
                weights[j] -= learning_rate * grad_w[j] / n as f64;
            }
            bias -= learning_rate * grad_b / n as f64;
        }

        // Convert back to original scale
        let mut original_weights = vec![0.0; p];
        let mut original_bias = target_mean + bias * target_std;
        for j in 0..p {
            original_weights[j] = weights[j] * target_std / stds[j];
            original_bias -= original_weights[j] * means[j];
        }

        // Compute R^2 and RMSE
        let predictions: Vec<f64> = features
            .iter()
            .map(|f| {
                f.iter().zip(original_weights.iter()).map(|(x, w)| x * w).sum::<f64>() + original_bias
            })
            .collect();

        let ss_res: f64 = predictions
            .iter()
            .zip(targets.iter())
            .map(|(p, t)| (p - t).powi(2))
            .sum();
        let ss_tot: f64 = targets.iter().map(|t| (t - target_mean).powi(2)).sum();

        let r_squared = if ss_tot > 0.0 { 1.0 - ss_res / ss_tot } else { 0.0 };
        let rmse = (ss_res / n as f64).sqrt();

        Some(LinearRegressionModel {
            intercept: original_bias,
            coefficients: original_weights,
            feature_names,
            r_squared,
            rmse,
            n_samples: n,
        })
    }

    /// Predict yield for a single feature vector.
    pub fn predict(&self, features: &[f64]) -> f64 {
        let mut result = self.intercept;
        for (i, &f) in features.iter().enumerate() {
            if i < self.coefficients.len() {
                result += self.coefficients[i] * f;
            }
        }
        result.max(0.0)
    }

    /// Predict yields for multiple samples.
    pub fn predict_batch(&self, features: &[Vec<f64>]) -> Vec<f64> {
        features.iter().map(|f| self.predict(f)).collect()
    }

    /// Serialize model to JSON.
    pub fn to_json(&self) -> Result<String, serde_json::Error> {
        serde_json::to_string(self)
    }

    /// Deserialize model from JSON.
    pub fn from_json(json: &str) -> Result<Self, serde_json::Error> {
        serde_json::from_str(json)
    }
}

/// Compute R-squared score between predicted and actual values.
pub fn r_squared(predicted: &[f64], actual: &[f64]) -> f64 {
    if predicted.len() != actual.len() || actual.is_empty() {
        return 0.0;
    }
    let n = actual.len() as f64;
    let mean = actual.iter().sum::<f64>() / n;
    let ss_res: f64 = predicted.iter().zip(actual.iter()).map(|(p, a)| (p - a).powi(2)).sum();
    let ss_tot: f64 = actual.iter().map(|a| (a - mean).powi(2)).sum();
    if ss_tot > 0.0 { 1.0 - ss_res / ss_tot } else { 0.0 }
}

/// Compute Root Mean Squared Error.
pub fn rmse(predicted: &[f64], actual: &[f64]) -> f64 {
    if predicted.len() != actual.len() || actual.is_empty() {
        return 0.0;
    }
    let n = actual.len() as f64;
    let ss: f64 = predicted.iter().zip(actual.iter()).map(|(p, a)| (p - a).powi(2)).sum();
    (ss / n).sqrt()
}

/// Compute Mean Absolute Error.
pub fn mae(predicted: &[f64], actual: &[f64]) -> f64 {
    if predicted.len() != actual.len() || actual.is_empty() {
        return 0.0;
    }
    let n = actual.len() as f64;
    let sum: f64 = predicted.iter().zip(actual.iter()).map(|(p, a)| (p - a).abs()).sum();
    sum / n
}

/// Compute Mean Absolute Percentage Error.
pub fn mape(predicted: &[f64], actual: &[f64]) -> f64 {
    if predicted.len() != actual.len() || actual.is_empty() {
        return 0.0;
    }
    let n = actual.len() as f64;
    let sum: f64 = predicted
        .iter()
        .zip(actual.iter())
        .filter(|(_, a)| a.abs() > f64::EPSILON)
        .map(|(p, a)| ((p - a) / a).abs())
        .sum();
    (sum / n) * 100.0
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_wheat_params() {
        let wheat = YieldModelParams::wheat();
        assert_eq!(wheat.crop_name, "Wheat");
        assert!(wheat.max_yield_kg_ha > 0.0);
    }

    #[test]
    fn test_population_factor_optimal() {
        let model = YieldModel::new(YieldModelParams::wheat());
        let f = model.population_factor(model.params.optimal_plant_population);
        assert!((f - 1.0).abs() < 1e-10);
    }

    #[test]
    fn test_population_factor_low() {
        let model = YieldModel::new(YieldModelParams::wheat());
        let f = model.population_factor(model.params.optimal_plant_population * 0.5);
        assert!(f < 1.0);
        assert!(f > 0.0);
    }

    #[test]
    fn test_gdd_factor_sufficient() {
        let model = YieldModel::new(YieldModelParams::corn());
        let f = model.gdd_factor(3000.0);
        assert!((f - 1.0).abs() < 1e-10);
    }

    #[test]
    fn test_gdd_factor_insufficient() {
        let model = YieldModel::new(YieldModelParams::corn());
        let f = model.gdd_factor(1250.0); // Half of required
        assert!((f - 0.5).abs() < 1e-10);
    }

    #[test]
    fn test_ph_factor_optimal() {
        let model = YieldModel::new(YieldModelParams::wheat());
        assert!((model.ph_factor(6.5) - 1.0).abs() < 1e-10);
    }

    #[test]
    fn test_ph_factor_acidic() {
        let model = YieldModel::new(YieldModelParams::wheat());
        let f = model.ph_factor(4.0); // Far below optimal
        assert!(f < 1.0);
    }

    #[test]
    fn test_linear_regression_train() {
        // Simple linear relationship: y = 2*x + 1
        let features = vec![
            vec![1.0], vec![2.0], vec![3.0], vec![4.0], vec![5.0],
            vec![6.0], vec![7.0], vec![8.0], vec![9.0], vec![10.0],
        ];
        let targets = vec![3.0, 5.0, 7.0, 9.0, 11.0, 13.0, 15.0, 17.0, 19.0, 21.0];
        let model = LinearRegressionModel::train(
            &features, &targets, vec!["x".to_string()],
        ).unwrap();

        assert!(model.r_squared > 0.9, "R^2 = {}", model.r_squared);
        assert!(model.rmse < 1.0, "RMSE = {}", model.rmse);

        // Predict
        let pred = model.predict(&[5.5]);
        assert!((pred - 12.0).abs() < 1.0, "pred = {}", pred);
    }

    #[test]
    fn test_linear_regression_serialization() {
        let model = LinearRegressionModel {
            intercept: 1.0,
            coefficients: vec![2.0, 3.0],
            feature_names: vec!["a".to_string(), "b".to_string()],
            r_squared: 0.95,
            rmse: 10.0,
            n_samples: 100,
        };
        let json = model.to_json().unwrap();
        let loaded = LinearRegressionModel::from_json(&json).unwrap();
        assert!((loaded.intercept - 1.0).abs() < 1e-10);
        assert_eq!(loaded.coefficients.len(), 2);
    }

    #[test]
    fn test_r_squared() {
        let predicted = vec![1.0, 2.0, 3.0, 4.0, 5.0];
        let actual = vec![1.0, 2.0, 3.0, 4.0, 5.0];
        assert!((r_squared(&predicted, &actual) - 1.0).abs() < 1e-10);
    }

    #[test]
    fn test_rmse_perfect() {
        let predicted = vec![1.0, 2.0, 3.0];
        let actual = vec![1.0, 2.0, 3.0];
        assert!((rmse(&predicted, &actual) - 0.0).abs() < 1e-10);
    }

    #[test]
    fn test_rmse_with_error() {
        let predicted = vec![1.0, 2.0, 3.0];
        let actual = vec![1.5, 2.5, 3.5];
        let r = rmse(&predicted, &actual);
        assert!((r - 0.5).abs() < 1e-10);
    }

    #[test]
    fn test_mae() {
        let predicted = vec![1.0, 2.0, 3.0];
        let actual = vec![1.5, 2.5, 3.5];
        assert!((mae(&predicted, &actual) - 0.5).abs() < 1e-10);
    }
}
