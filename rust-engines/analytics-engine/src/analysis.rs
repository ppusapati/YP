use chrono::Utc;

use crate::rotation::analyze_rotation;
use crate::trends::*;
use crate::types::*;

pub fn compute_field_analytics(
    records: &[SeasonRecord],
    ndvi_series: Option<&NdviTimeSeries>,
) -> FieldAnalytics {
    let field_id = records.first().map(|r| r.field_id.clone()).unwrap_or_default();
    let farm_id = records.first().map(|r| r.farm_id.clone()).unwrap_or_default();

    let yields: Vec<f64> = records.iter().filter_map(|r| r.yield_kg_per_ha).collect();
    let mean_yield = if yields.is_empty() { 0.0 } else { yields.iter().sum::<f64>() / yields.len() as f64 };
    let best_yield = yields.iter().copied().fold(f64::NEG_INFINITY, f64::max);
    let worst_yield = yields.iter().copied().fold(f64::INFINITY, f64::min);
    let yield_cv = coefficient_of_variation(&yields);

    let (y_trend, y_slope) = yield_trend(records);

    let (n_trend, n_slope) = ndvi_series
        .map(|ns| ndvi_trend(&ns.observations))
        .unwrap_or((TrendDirection::Insufficient, 0.0));

    let stress_per_season: Vec<f64> = records.iter().map(|r| r.stress_days as f64).collect();
    let mean_stress = if stress_per_season.is_empty() {
        0.0
    } else {
        stress_per_season.iter().sum::<f64>() / stress_per_season.len() as f64
    };

    let rotation = analyze_rotation(records);
    let intervention_impact = compute_intervention_impact(records);
    let season_comparisons = compute_season_comparisons(records, mean_yield, mean_stress, mean_yield);

    FieldAnalytics {
        field_id,
        farm_id,
        season_count: records.len(),
        yield_trend: y_trend,
        yield_trend_pct_per_year: y_slope,
        mean_yield,
        best_yield: if best_yield.is_finite() { best_yield } else { 0.0 },
        worst_yield: if worst_yield.is_finite() { worst_yield } else { 0.0 },
        yield_variability_cv: yield_cv,
        ndvi_trend: n_trend,
        ndvi_trend_per_year: n_slope,
        mean_stress_days_per_season: mean_stress,
        rotation_effectiveness: rotation,
        intervention_impact,
        season_comparisons,
        computed_at: Utc::now(),
    }
}

fn compute_intervention_impact(records: &[SeasonRecord]) -> Vec<InterventionImpact> {
    use std::collections::HashMap;

    let mean_yield: f64 = {
        let yields: Vec<f64> = records.iter().filter_map(|r| r.yield_kg_per_ha).collect();
        if yields.is_empty() { return vec![]; }
        yields.iter().sum::<f64>() / yields.len() as f64
    };

    let mut type_data: HashMap<InterventionType, Vec<(f64, f64)>> = HashMap::new();

    for record in records {
        if let Some(y) = record.yield_kg_per_ha {
            for intervention in &record.interventions {
                type_data
                    .entry(intervention.intervention_type)
                    .or_default()
                    .push((y, record.stress_days as f64));
            }
        }
    }

    let mean_stress: f64 = {
        let s: Vec<f64> = records.iter().map(|r| r.stress_days as f64).collect();
        s.iter().sum::<f64>() / s.len().max(1) as f64
    };

    type_data
        .into_iter()
        .map(|(itype, data)| {
            let avg_yield = data.iter().map(|(y, _)| y).sum::<f64>() / data.len() as f64;
            let avg_stress = data.iter().map(|(_, s)| s).sum::<f64>() / data.len() as f64;
            let yield_change = if mean_yield > 0.0 {
                ((avg_yield - mean_yield) / mean_yield) * 100.0
            } else {
                0.0
            };
            let stress_reduction = if mean_stress > 0.0 {
                ((mean_stress - avg_stress) / mean_stress) * 100.0
            } else {
                0.0
            };

            InterventionImpact {
                intervention_type: itype,
                count: data.len(),
                avg_yield_change_pct: yield_change,
                avg_stress_reduction: stress_reduction,
                roi_estimate: None,
            }
        })
        .collect()
}

fn compute_season_comparisons(
    records: &[SeasonRecord],
    mean_yield: f64,
    mean_stress: f64,
    _mean_ndvi_unused: f64,
) -> Vec<SeasonComparison> {
    records
        .iter()
        .map(|r| {
            let yield_vs = r.yield_kg_per_ha
                .map(|y| if mean_yield > 0.0 { ((y - mean_yield) / mean_yield) * 100.0 } else { 0.0 })
                .unwrap_or(0.0);

            let stress_vs = if mean_stress > 0.0 {
                ((r.stress_days as f64 - mean_stress) / mean_stress) * 100.0
            } else {
                0.0
            };

            let mean_ndvi_all = if records.is_empty() {
                0.0
            } else {
                records.iter().map(|rec| rec.mean_ndvi).sum::<f64>() / records.len() as f64
            };
            let ndvi_vs = if mean_ndvi_all > 0.0 {
                ((r.mean_ndvi - mean_ndvi_all) / mean_ndvi_all) * 100.0
            } else {
                0.0
            };

            let mut events = Vec::new();
            if r.frost_events > 0 {
                events.push(format!("{} frost events", r.frost_events));
            }
            if r.heat_events > 0 {
                events.push(format!("{} heat events", r.heat_events));
            }
            if r.drought_days > 5 {
                events.push(format!("{} drought days", r.drought_days));
            }

            SeasonComparison {
                season: r.season.clone(),
                year: r.year,
                crop_type: r.crop_type.clone(),
                yield_vs_mean_pct: yield_vs,
                stress_vs_mean_pct: stress_vs,
                ndvi_vs_mean_pct: ndvi_vs,
                notable_events: events,
            }
        })
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;
    use chrono::NaiveDate;

    fn make_records() -> Vec<SeasonRecord> {
        (2020..2026)
            .map(|y| SeasonRecord {
                field_id: "f1".into(),
                farm_id: "farm1".into(),
                crop_type: if y % 2 == 0 { "Rice" } else { "Soybean" }.into(),
                season: "kharif".into(),
                year: y,
                planting_date: NaiveDate::from_ymd_opt(y, 6, 1).unwrap(),
                harvest_date: Some(NaiveDate::from_ymd_opt(y, 11, 1).unwrap()),
                yield_kg_per_ha: Some(3000.0 + (y - 2020) as f64 * 100.0),
                target_yield_kg_per_ha: Some(4000.0),
                stress_days: (15 - (y - 2020) as u32).max(2),
                frost_events: 0,
                heat_events: if y == 2023 { 3 } else { 0 },
                drought_days: if y == 2022 { 8 } else { 1 },
                total_precipitation_mm: 750.0 + (y - 2020) as f64 * 20.0,
                mean_temperature: 27.0,
                mean_ndvi: 0.6 + (y - 2020) as f64 * 0.02,
                peak_ndvi: 0.8,
                total_thermal_time: 1500.0,
                interventions: vec![],
            })
            .collect()
    }

    #[test]
    fn test_field_analytics() {
        let records = make_records();
        let analytics = compute_field_analytics(&records, None);
        assert_eq!(analytics.season_count, 6);
        assert!(analytics.mean_yield > 0.0);
        assert!(analytics.best_yield >= analytics.worst_yield);
        assert_eq!(analytics.season_comparisons.len(), 6);
    }

    #[test]
    fn test_improving_trend() {
        let records = make_records();
        let analytics = compute_field_analytics(&records, None);
        assert!(matches!(
            analytics.yield_trend,
            TrendDirection::Increase | TrendDirection::StrongIncrease | TrendDirection::Stable
        ));
    }
}
