use chrono::Datelike;

use crate::types::*;

pub fn linear_regression(xs: &[f64], ys: &[f64]) -> (f64, f64) {
    let n = xs.len() as f64;
    if n < 2.0 {
        return (0.0, ys.first().copied().unwrap_or(0.0));
    }

    let sum_x: f64 = xs.iter().sum();
    let sum_y: f64 = ys.iter().sum();
    let sum_xy: f64 = xs.iter().zip(ys.iter()).map(|(x, y)| x * y).sum();
    let sum_x2: f64 = xs.iter().map(|x| x * x).sum();

    let denom = n * sum_x2 - sum_x * sum_x;
    if denom.abs() < 1e-12 {
        return (0.0, sum_y / n);
    }

    let slope = (n * sum_xy - sum_x * sum_y) / denom;
    let intercept = (sum_y - slope * sum_x) / n;
    (slope, intercept)
}

pub fn coefficient_of_variation(values: &[f64]) -> f64 {
    if values.is_empty() {
        return 0.0;
    }
    let mean = values.iter().sum::<f64>() / values.len() as f64;
    if mean.abs() < 1e-12 {
        return 0.0;
    }
    let variance = values.iter().map(|v| (v - mean).powi(2)).sum::<f64>() / values.len() as f64;
    (variance.sqrt() / mean) * 100.0
}

pub fn yield_trend(records: &[SeasonRecord]) -> (TrendDirection, f64) {
    let yields: Vec<(f64, f64)> = records
        .iter()
        .filter_map(|r| r.yield_kg_per_ha.map(|y| (r.year as f64, y)))
        .collect();

    if yields.len() < 3 {
        return (TrendDirection::Insufficient, 0.0);
    }

    let xs: Vec<f64> = yields.iter().map(|(x, _)| *x).collect();
    let ys: Vec<f64> = yields.iter().map(|(_, y)| *y).collect();
    let (slope, _) = linear_regression(&xs, &ys);

    let mean_yield = ys.iter().sum::<f64>() / ys.len() as f64;
    let pct_per_year = if mean_yield > 0.0 {
        (slope / mean_yield) * 100.0
    } else {
        0.0
    };

    (TrendDirection::from_slope(pct_per_year), pct_per_year)
}

pub fn ndvi_trend(observations: &[NdviObservation]) -> (TrendDirection, f64) {
    if observations.len() < 5 {
        return (TrendDirection::Insufficient, 0.0);
    }

    let xs: Vec<f64> = observations
        .iter()
        .map(|o| {
            let days = (o.date - observations[0].date).num_days() as f64;
            days / 365.25
        })
        .collect();
    let ys: Vec<f64> = observations.iter().map(|o| o.mean_ndvi).collect();
    let (slope, _) = linear_regression(&xs, &ys);

    let mean_ndvi = ys.iter().sum::<f64>() / ys.len() as f64;
    let pct_per_year = if mean_ndvi > 0.0 {
        (slope / mean_ndvi) * 100.0
    } else {
        0.0
    };

    (TrendDirection::from_slope(pct_per_year), slope)
}

pub fn seasonal_pattern(observations: &[NdviObservation]) -> Vec<(u32, f64)> {
    let mut monthly: Vec<Vec<f64>> = vec![vec![]; 12];
    for obs in observations {
        let month = obs.date.month0() as usize;
        monthly[month].push(obs.mean_ndvi);
    }

    monthly
        .iter()
        .enumerate()
        .map(|(i, vals)| {
            let avg = if vals.is_empty() {
                0.0
            } else {
                vals.iter().sum::<f64>() / vals.len() as f64
            };
            ((i + 1) as u32, avg)
        })
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_linear_regression_perfect() {
        let xs = vec![1.0, 2.0, 3.0, 4.0, 5.0];
        let ys = vec![2.0, 4.0, 6.0, 8.0, 10.0];
        let (slope, intercept) = linear_regression(&xs, &ys);
        assert!((slope - 2.0).abs() < 1e-10);
        assert!(intercept.abs() < 1e-10);
    }

    #[test]
    fn test_linear_regression_constant() {
        let xs = vec![1.0, 2.0, 3.0];
        let ys = vec![5.0, 5.0, 5.0];
        let (slope, intercept) = linear_regression(&xs, &ys);
        assert!(slope.abs() < 1e-10);
        assert!((intercept - 5.0).abs() < 1e-10);
    }

    #[test]
    fn test_cv() {
        let values = vec![10.0, 10.0, 10.0];
        assert!(coefficient_of_variation(&values).abs() < 1e-10);

        let values2 = vec![10.0, 20.0, 30.0];
        assert!(coefficient_of_variation(&values2) > 0.0);
    }

    #[test]
    fn test_yield_trend_insufficient() {
        let records = vec![];
        let (trend, _) = yield_trend(&records);
        assert_eq!(trend, TrendDirection::Insufficient);
    }
}
