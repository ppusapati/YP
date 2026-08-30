use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Hash, Serialize, Deserialize)]
pub enum AlertSeverity {
    Info,
    Warning,
    Critical,
    Emergency,
}

impl AlertSeverity {
    pub fn label(&self) -> &'static str {
        match self {
            Self::Info => "INFO",
            Self::Warning => "WARNING",
            Self::Critical => "CRITICAL",
            Self::Emergency => "EMERGENCY",
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum AlertType {
    FrostRisk,
    HeatStress,
    DroughtWarning,
    ExcessiveRain,
    PestOutbreak,
    DiseaseDetected,
    NutrientDeficiency,
    WaterStress,
    GrowthAnomaly,
}

impl AlertType {
    pub fn label(&self) -> &'static str {
        match self {
            Self::FrostRisk => "Frost Risk",
            Self::HeatStress => "Heat Stress",
            Self::DroughtWarning => "Drought Warning",
            Self::ExcessiveRain => "Excessive Rainfall",
            Self::PestOutbreak => "Pest Outbreak",
            Self::DiseaseDetected => "Disease Detected",
            Self::NutrientDeficiency => "Nutrient Deficiency",
            Self::WaterStress => "Water Stress",
            Self::GrowthAnomaly => "Growth Anomaly",
        }
    }

    pub fn category(&self) -> AlertCategory {
        match self {
            Self::FrostRisk | Self::HeatStress => AlertCategory::Temperature,
            Self::DroughtWarning | Self::ExcessiveRain | Self::WaterStress => AlertCategory::Water,
            Self::PestOutbreak => AlertCategory::Pest,
            Self::DiseaseDetected => AlertCategory::Disease,
            Self::NutrientDeficiency => AlertCategory::Nutrient,
            Self::GrowthAnomaly => AlertCategory::Growth,
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum AlertCategory {
    Temperature,
    Water,
    Pest,
    Disease,
    Nutrient,
    Growth,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AlertThresholds {
    pub frost_temp_c: f64,
    pub heat_temp_c: f64,
    pub drought_soil_moisture: f64,
    pub excessive_rain_mm: f64,
    pub water_stress_threshold: f64,
    pub pest_confidence_threshold: f32,
    pub disease_confidence_threshold: f32,
    pub growth_deviation_pct: f64,
    pub nutrient_severity_threshold: f32,
}

impl Default for AlertThresholds {
    fn default() -> Self {
        Self {
            frost_temp_c: 2.0,
            heat_temp_c: 38.0,
            drought_soil_moisture: 0.15,
            excessive_rain_mm: 50.0,
            water_stress_threshold: 0.4,
            pest_confidence_threshold: 0.6,
            disease_confidence_threshold: 0.5,
            growth_deviation_pct: 20.0,
            nutrient_severity_threshold: 0.5,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FieldConditions {
    pub field_id: String,
    pub farm_id: String,
    pub crop_type: String,
    pub temperature_current: f64,
    pub temperature_min_forecast: f64,
    pub temperature_max_forecast: f64,
    pub precipitation_mm: f64,
    pub precipitation_forecast_mm: f64,
    pub soil_moisture: f64,
    pub et_reference_mm: f64,
    pub co2_ppm: f64,
    pub ndvi_current: Option<f64>,
    pub ndvi_previous: Option<f64>,
    pub pest_confidence: Option<f32>,
    pub pest_species: Option<String>,
    pub disease_confidence: Option<f32>,
    pub disease_name: Option<String>,
    pub nutrient_severity: Option<f32>,
    pub nutrient_type: Option<String>,
    pub growth_expected: Option<f64>,
    pub growth_actual: Option<f64>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Alert {
    pub alert_type: AlertType,
    pub severity: AlertSeverity,
    pub field_id: String,
    pub farm_id: String,
    pub title: String,
    pub message: String,
    pub recommendations: Vec<String>,
    pub metric_value: f64,
    pub threshold_value: f64,
    pub timestamp: DateTime<Utc>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FieldRiskScore {
    pub field_id: String,
    pub farm_id: String,
    pub overall_risk: f64,
    pub temperature_risk: f64,
    pub water_risk: f64,
    pub pest_risk: f64,
    pub disease_risk: f64,
    pub nutrient_risk: f64,
    pub growth_risk: f64,
    pub alerts: Vec<Alert>,
    pub evaluated_at: DateTime<Utc>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AlertRule {
    pub rule_id: String,
    pub field_id: String,
    pub alert_type: AlertType,
    pub enabled: bool,
    pub thresholds: AlertThresholds,
    pub notify_channels: Vec<NotifyChannel>,
    pub cooldown_minutes: u32,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum NotifyChannel {
    Push,
    InApp,
    Email,
    Sms,
    Webhook,
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_severity_ordering() {
        assert!(AlertSeverity::Info < AlertSeverity::Warning);
        assert!(AlertSeverity::Warning < AlertSeverity::Critical);
        assert!(AlertSeverity::Critical < AlertSeverity::Emergency);
    }

    #[test]
    fn test_alert_type_category() {
        assert_eq!(AlertType::FrostRisk.category(), AlertCategory::Temperature);
        assert_eq!(AlertType::DroughtWarning.category(), AlertCategory::Water);
        assert_eq!(AlertType::PestOutbreak.category(), AlertCategory::Pest);
    }

    #[test]
    fn test_default_thresholds() {
        let t = AlertThresholds::default();
        assert!(t.frost_temp_c > 0.0);
        assert!(t.heat_temp_c > t.frost_temp_c);
        assert!(t.drought_soil_moisture > 0.0);
    }
}
