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
