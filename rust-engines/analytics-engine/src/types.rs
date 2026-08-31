use chrono::{DateTime, NaiveDate, Utc};
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SeasonRecord {
    pub field_id: String,
    pub farm_id: String,
    pub crop_type: String,
    pub season: String,
    pub year: i32,
    pub planting_date: NaiveDate,
    pub harvest_date: Option<NaiveDate>,
    pub yield_kg_per_ha: Option<f64>,
    pub target_yield_kg_per_ha: Option<f64>,
    pub stress_days: u32,
    pub frost_events: u32,
    pub heat_events: u32,
    pub drought_days: u32,
    pub total_precipitation_mm: f64,
    pub mean_temperature: f64,
    pub mean_ndvi: f64,
    pub peak_ndvi: f64,
    pub total_thermal_time: f64,
    pub interventions: Vec<Intervention>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Intervention {
    pub date: NaiveDate,
    pub intervention_type: InterventionType,
    pub description: String,
    pub cost_per_ha: Option<f64>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum InterventionType {
    Fertilizer,
    Pesticide,
    Fungicide,
    Irrigation,
    Pruning,
    Replanting,
    SoilAmendment,
    CoverCrop,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct NdviTimeSeries {
    pub field_id: String,
    pub observations: Vec<NdviObservation>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct NdviObservation {
    pub date: NaiveDate,
    pub mean_ndvi: f64,
    pub min_ndvi: f64,
    pub max_ndvi: f64,
    pub std_dev: f64,
    pub cloud_cover_pct: f64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FieldAnalytics {
    pub field_id: String,
    pub farm_id: String,
    pub season_count: usize,
    pub yield_trend: TrendDirection,
    pub yield_trend_pct_per_year: f64,
    pub mean_yield: f64,
    pub best_yield: f64,
    pub worst_yield: f64,
    pub yield_variability_cv: f64,
    pub ndvi_trend: TrendDirection,
    pub ndvi_trend_per_year: f64,
    pub mean_stress_days_per_season: f64,
    pub rotation_effectiveness: Option<RotationScore>,
    pub intervention_impact: Vec<InterventionImpact>,
    pub season_comparisons: Vec<SeasonComparison>,
    pub computed_at: DateTime<Utc>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum TrendDirection {
    StrongIncrease,
    Increase,
    Stable,
    Decrease,
    StrongDecrease,
    Insufficient,
}

impl TrendDirection {
    pub fn from_slope(slope: f64) -> Self {
        if slope > 5.0 {
            Self::StrongIncrease
        } else if slope > 1.0 {
            Self::Increase
        } else if slope > -1.0 {
            Self::Stable
        } else if slope > -5.0 {
            Self::Decrease
        } else {
            Self::StrongDecrease
        }
    }

    pub fn label(&self) -> &'static str {
        match self {
            Self::StrongIncrease => "Strong Increase",
            Self::Increase => "Increasing",
            Self::Stable => "Stable",
            Self::Decrease => "Decreasing",
            Self::StrongDecrease => "Strong Decrease",
            Self::Insufficient => "Insufficient Data",
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RotationScore {
    pub rotation_pattern: Vec<String>,
    pub effectiveness_score: f64,
    pub yield_impact_pct: f64,
    pub stress_reduction_pct: f64,
    pub recommendation: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct InterventionImpact {
    pub intervention_type: InterventionType,
    pub count: usize,
    pub avg_yield_change_pct: f64,
    pub avg_stress_reduction: f64,
    pub roi_estimate: Option<f64>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SeasonComparison {
    pub season: String,
    pub year: i32,
    pub crop_type: String,
    pub yield_vs_mean_pct: f64,
    pub stress_vs_mean_pct: f64,
    pub ndvi_vs_mean_pct: f64,
    pub notable_events: Vec<String>,
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_trend_direction() {
        assert_eq!(TrendDirection::from_slope(10.0), TrendDirection::StrongIncrease);
        assert_eq!(TrendDirection::from_slope(3.0), TrendDirection::Increase);
        assert_eq!(TrendDirection::from_slope(0.0), TrendDirection::Stable);
        assert_eq!(TrendDirection::from_slope(-3.0), TrendDirection::Decrease);
        assert_eq!(TrendDirection::from_slope(-10.0), TrendDirection::StrongDecrease);
    }
}
