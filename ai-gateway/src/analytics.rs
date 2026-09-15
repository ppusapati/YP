use crate::proto;
use analytics_engine::analysis::compute_field_analytics;
use analytics_engine::types::{NdviObservation, NdviTimeSeries, SeasonRecord};
use chrono::NaiveDate;
use std::time::Instant;

pub struct AnalyticsEngine;

impl AnalyticsEngine {
    pub fn new() -> Self {
        Self
    }

    pub fn compute_field_analytics(&self, req: &proto::ComputeFieldAnalyticsRequest) -> proto::ComputeFieldAnalyticsResponse {
        let start = Instant::now();

        let records: Vec<SeasonRecord> = req.seasons.iter().map(|s| {
            SeasonRecord {
                field_id: req.field_id.clone(),
                farm_id: req.farm_id.clone(),
                crop_type: s.crop_type.clone(),
                season: s.season.clone(),
                year: s.year,
                planting_date: NaiveDate::from_ymd_opt(s.year, 6, 1).unwrap_or_default(),
                harvest_date: Some(NaiveDate::from_ymd_opt(s.year, 11, 1).unwrap_or_default()),
                yield_kg_per_ha: if s.yield_kg_per_ha > 0.0 { Some(s.yield_kg_per_ha) } else { None },
                target_yield_kg_per_ha: None,
                stress_days: s.stress_days,
                frost_events: s.frost_events,
                heat_events: s.heat_events,
                drought_days: s.drought_days,
                total_precipitation_mm: s.total_precipitation_mm,
                mean_temperature: s.mean_temperature,
                mean_ndvi: s.mean_ndvi,
                peak_ndvi: s.peak_ndvi,
                total_thermal_time: s.total_thermal_time,
                interventions: vec![],
            }
        }).collect();

        let ndvi_series = if req.ndvi_series.is_empty() {
            None
        } else {
            Some(NdviTimeSeries {
                field_id: req.field_id.clone(),
                observations: req.ndvi_series.iter().filter_map(|n| {
                    let date = NaiveDate::parse_from_str(&n.date, "%Y-%m-%d").ok()?;
                    Some(NdviObservation {
                        date,
                        mean_ndvi: n.mean_ndvi,
                        min_ndvi: n.min_ndvi,
                        max_ndvi: n.max_ndvi,
                        std_dev: n.std_dev,
                        cloud_cover_pct: 0.0,
                    })
                }).collect(),
            })
        };

        let result = compute_field_analytics(&records, ndvi_series.as_ref());

        let rotation = result.rotation_effectiveness.map(|r| proto::RotationAnalysis {
            rotation_pattern: r.rotation_pattern,
            effectiveness_score: r.effectiveness_score,
            yield_impact_pct: r.yield_impact_pct,
            stress_reduction_pct: r.stress_reduction_pct,
            recommendation: r.recommendation,
        });

        let comparisons = result.season_comparisons.iter().map(|c| proto::SeasonComparisonResult {
            season: c.season.clone(),
            year: c.year,
            crop_type: c.crop_type.clone(),
            yield_vs_mean_pct: c.yield_vs_mean_pct,
            stress_vs_mean_pct: c.stress_vs_mean_pct,
            ndvi_vs_mean_pct: c.ndvi_vs_mean_pct,
            notable_events: c.notable_events.clone(),
        }).collect();

        proto::ComputeFieldAnalyticsResponse {
            request_id: req.request_id.clone(),
            field_id: req.field_id.clone(),
            season_count: result.season_count as i32,
            yield_trend: result.yield_trend.label().to_string(),
            yield_trend_pct_per_year: result.yield_trend_pct_per_year,
            mean_yield: result.mean_yield,
            best_yield: result.best_yield,
            worst_yield: result.worst_yield,
            yield_variability_cv: result.yield_variability_cv,
            ndvi_trend: result.ndvi_trend.label().to_string(),
            ndvi_trend_per_year: result.ndvi_trend_per_year,
            mean_stress_days_per_season: result.mean_stress_days_per_season,
            rotation,
            season_comparisons: comparisons,
            processing_time_ms: start.elapsed().as_millis() as i64,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn analytics_engine_constructs() {
        let _engine = AnalyticsEngine::new();
    }

    #[test]
    fn compute_with_empty_seasons() {
        let engine = AnalyticsEngine::new();
        let req = proto::ComputeFieldAnalyticsRequest {
            request_id: "analytics-001".to_string(),
            field_id: "field-x".to_string(),
            farm_id: "farm-1".to_string(),
            seasons: vec![],
            ndvi_series: vec![],
        };
        let resp = engine.compute_field_analytics(&req);
        assert_eq!(resp.request_id, "analytics-001");
        assert_eq!(resp.field_id, "field-x");
        assert_eq!(resp.season_count, 0);
        assert!(resp.processing_time_ms >= 0);
    }

    #[test]
    fn compute_with_single_season() {
        let engine = AnalyticsEngine::new();
        let req = proto::ComputeFieldAnalyticsRequest {
            request_id: "analytics-002".to_string(),
            field_id: "field-y".to_string(),
            farm_id: "farm-2".to_string(),
            seasons: vec![proto::SeasonRecord {
                crop_type: "corn".to_string(),
                season: "summer".to_string(),
                year: 2025,
                yield_kg_per_ha: 8500.0,
                stress_days: 5,
                frost_events: 0,
                heat_events: 2,
                drought_days: 3,
                total_precipitation_mm: 350.0,
                mean_temperature: 24.0,
                mean_ndvi: 0.72,
                peak_ndvi: 0.85,
                total_thermal_time: 1800.0,
            }],
            ndvi_series: vec![],
        };
        let resp = engine.compute_field_analytics(&req);
        assert_eq!(resp.season_count, 1);
        assert!(resp.mean_yield.is_finite());
    }

    #[test]
    fn compute_with_multiple_seasons() {
        let engine = AnalyticsEngine::new();
        let seasons: Vec<proto::SeasonRecord> = (2020..=2025)
            .map(|year| proto::SeasonRecord {
                crop_type: "wheat".to_string(),
                season: "winter".to_string(),
                year,
                yield_kg_per_ha: 6000.0 + (year as f64 - 2020.0) * 100.0,
                stress_days: 3,
                frost_events: 1,
                heat_events: 0,
                drought_days: 2,
                total_precipitation_mm: 400.0,
                mean_temperature: 18.0,
                mean_ndvi: 0.65,
                peak_ndvi: 0.78,
                total_thermal_time: 1500.0,
            })
            .collect();
        let req = proto::ComputeFieldAnalyticsRequest {
            request_id: "analytics-003".to_string(),
            field_id: "field-z".to_string(),
            farm_id: "farm-3".to_string(),
            seasons,
            ndvi_series: vec![],
        };
        let resp = engine.compute_field_analytics(&req);
        assert_eq!(resp.season_count, 6);
        assert!(resp.mean_yield > 0.0);
        assert!(resp.best_yield >= resp.worst_yield);
        assert!(!resp.yield_trend.is_empty());
    }

    #[test]
    fn compute_preserves_ids() {
        let engine = AnalyticsEngine::new();
        let req = proto::ComputeFieldAnalyticsRequest {
            request_id: "id-preserve-test".to_string(),
            field_id: "my-field".to_string(),
            farm_id: "my-farm".to_string(),
            seasons: vec![],
            ndvi_series: vec![],
        };
        let resp = engine.compute_field_analytics(&req);
        assert_eq!(resp.request_id, "id-preserve-test");
        assert_eq!(resp.field_id, "my-field");
    }
}
