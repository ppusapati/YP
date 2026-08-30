use chrono::Utc;
use climate_response_engine::types::{ClimateParams, DailyClimate};
use climate_response_engine::response::daily_response;

use crate::types::*;

pub struct AlertEvaluator {
    thresholds: AlertThresholds,
    climate_params: ClimateParams,
}

impl AlertEvaluator {
    pub fn new(thresholds: AlertThresholds, climate_params: ClimateParams) -> Self {
        Self { thresholds, climate_params }
    }

    pub fn with_defaults() -> Self {
        Self::new(AlertThresholds::default(), ClimateParams::default())
    }

    pub fn evaluate(&self, conditions: &FieldConditions) -> FieldRiskScore {
        let mut alerts = Vec::new();
        let now = Utc::now();

        let temp_risk = self.evaluate_temperature(conditions, &mut alerts, now);
        let water_risk = self.evaluate_water(conditions, &mut alerts, now);
        let pest_risk = self.evaluate_pest(conditions, &mut alerts, now);
        let disease_risk = self.evaluate_disease(conditions, &mut alerts, now);
        let nutrient_risk = self.evaluate_nutrient(conditions, &mut alerts, now);
        let growth_risk = self.evaluate_growth(conditions, &mut alerts, now);

        let overall_risk = [temp_risk, water_risk, pest_risk, disease_risk, nutrient_risk, growth_risk]
            .iter()
            .copied()
            .fold(0.0_f64, f64::max);

        FieldRiskScore {
            field_id: conditions.field_id.clone(),
            farm_id: conditions.farm_id.clone(),
            overall_risk,
            temperature_risk: temp_risk,
            water_risk,
            pest_risk,
            disease_risk,
            nutrient_risk,
            growth_risk,
            alerts,
            evaluated_at: now,
        }
    }

    fn evaluate_temperature(
        &self,
        cond: &FieldConditions,
        alerts: &mut Vec<Alert>,
        now: chrono::DateTime<Utc>,
    ) -> f64 {
        let mut risk = 0.0;

        if cond.temperature_min_forecast <= self.thresholds.frost_temp_c {
            let severity_val = (self.thresholds.frost_temp_c - cond.temperature_min_forecast) / 5.0;
            let severity = if severity_val > 0.8 {
                AlertSeverity::Emergency
            } else if severity_val > 0.5 {
                AlertSeverity::Critical
            } else if severity_val > 0.2 {
                AlertSeverity::Warning
            } else {
                AlertSeverity::Info
            };

            risk = severity_val.min(1.0);
            alerts.push(Alert {
                alert_type: AlertType::FrostRisk,
                severity,
                field_id: cond.field_id.clone(),
                farm_id: cond.farm_id.clone(),
                title: format!("Frost risk: {:.1}°C forecast", cond.temperature_min_forecast),
                message: format!(
                    "Minimum temperature forecast of {:.1}°C is below the frost threshold of {:.1}°C for {}.",
                    cond.temperature_min_forecast, self.thresholds.frost_temp_c, cond.crop_type
                ),
                recommendations: vec![
                    "Cover sensitive crops with frost cloth or row covers".into(),
                    "Irrigate fields before frost — wet soil retains heat".into(),
                    "Harvest mature crops if possible".into(),
                ],
                metric_value: cond.temperature_min_forecast,
                threshold_value: self.thresholds.frost_temp_c,
                timestamp: now,
            });
        }

        if cond.temperature_max_forecast >= self.thresholds.heat_temp_c {
            let severity_val = (cond.temperature_max_forecast - self.thresholds.heat_temp_c) / 5.0;
            let severity = if severity_val > 0.8 {
                AlertSeverity::Emergency
            } else if severity_val > 0.5 {
                AlertSeverity::Critical
            } else {
                AlertSeverity::Warning
            };

            risk = risk.max(severity_val.min(1.0));
            alerts.push(Alert {
                alert_type: AlertType::HeatStress,
                severity,
                field_id: cond.field_id.clone(),
                farm_id: cond.farm_id.clone(),
                title: format!("Heat stress: {:.1}°C forecast", cond.temperature_max_forecast),
                message: format!(
                    "Maximum temperature forecast of {:.1}°C exceeds heat stress threshold of {:.1}°C.",
                    cond.temperature_max_forecast, self.thresholds.heat_temp_c
                ),
                recommendations: vec![
                    "Increase irrigation frequency to compensate evapotranspiration".into(),
                    "Apply mulch to reduce soil temperature".into(),
                    "Consider shade structures for sensitive crops".into(),
                ],
                metric_value: cond.temperature_max_forecast,
                threshold_value: self.thresholds.heat_temp_c,
                timestamp: now,
            });
        }

        risk
    }

    fn evaluate_water(
        &self,
        cond: &FieldConditions,
        alerts: &mut Vec<Alert>,
        now: chrono::DateTime<Utc>,
    ) -> f64 {
        let mut risk = 0.0;

        let climate = DailyClimate {
            temperature_mean: cond.temperature_current,
            temperature_min: cond.temperature_min_forecast,
            temperature_max: cond.temperature_max_forecast,
            precipitation_mm: cond.precipitation_mm,
            et_reference_mm: cond.et_reference_mm,
            co2_ppm: cond.co2_ppm,
            solar_radiation_mj: 18.0,
        };
        let resp = daily_response(&climate, cond.soil_moisture, &self.climate_params);

        if resp.stress.drought_index > 0.3 {
            let severity = if resp.stress.drought_index > 0.7 {
                AlertSeverity::Emergency
            } else if resp.stress.drought_index > 0.5 {
                AlertSeverity::Critical
            } else {
                AlertSeverity::Warning
            };

            risk = resp.stress.drought_index;
            alerts.push(Alert {
                alert_type: AlertType::DroughtWarning,
                severity,
                field_id: cond.field_id.clone(),
                farm_id: cond.farm_id.clone(),
                title: format!("Drought warning: soil moisture {:.0}%", cond.soil_moisture * 100.0),
                message: format!(
                    "Soil moisture at {:.1}% is below drought threshold. Drought index: {:.2}.",
                    cond.soil_moisture * 100.0, resp.stress.drought_index
                ),
                recommendations: vec![
                    "Increase irrigation immediately".into(),
                    "Apply organic mulch to reduce evaporation".into(),
                    "Prioritize water-sensitive growth stages".into(),
                ],
                metric_value: cond.soil_moisture,
                threshold_value: self.thresholds.drought_soil_moisture,
                timestamp: now,
            });
        }

        if cond.precipitation_forecast_mm > self.thresholds.excessive_rain_mm {
            let rain_severity = (cond.precipitation_forecast_mm - self.thresholds.excessive_rain_mm)
                / self.thresholds.excessive_rain_mm;
            let severity = if rain_severity > 1.0 {
                AlertSeverity::Emergency
            } else if rain_severity > 0.5 {
                AlertSeverity::Critical
            } else {
                AlertSeverity::Warning
            };

            risk = risk.max(rain_severity.min(1.0));
            alerts.push(Alert {
                alert_type: AlertType::ExcessiveRain,
                severity,
                field_id: cond.field_id.clone(),
                farm_id: cond.farm_id.clone(),
                title: format!("Heavy rain: {:.0}mm forecast", cond.precipitation_forecast_mm),
                message: format!(
                    "Forecast rainfall of {:.0}mm exceeds threshold of {:.0}mm. Risk of waterlogging and erosion.",
                    cond.precipitation_forecast_mm, self.thresholds.excessive_rain_mm
                ),
                recommendations: vec![
                    "Ensure drainage channels are clear".into(),
                    "Delay fertilizer application to prevent runoff".into(),
                    "Inspect fields for standing water after rain".into(),
                ],
                metric_value: cond.precipitation_forecast_mm,
                threshold_value: self.thresholds.excessive_rain_mm,
                timestamp: now,
            });
        }

        if resp.stress.water_stress > self.thresholds.water_stress_threshold {
            risk = risk.max(resp.stress.water_stress);
            alerts.push(Alert {
                alert_type: AlertType::WaterStress,
                severity: if resp.stress.water_stress > 0.7 {
                    AlertSeverity::Critical
                } else {
                    AlertSeverity::Warning
                },
                field_id: cond.field_id.clone(),
                farm_id: cond.farm_id.clone(),
                title: format!("Water stress detected: {:.0}%", resp.stress.water_stress * 100.0),
                message: format!(
                    "Water stress factor at {:.1}% — crop water demand exceeds availability.",
                    resp.stress.water_stress * 100.0
                ),
                recommendations: vec![
                    "Adjust irrigation schedule to match ET demand".into(),
                    "Check irrigation system for blockages".into(),
                ],
                metric_value: resp.stress.water_stress,
                threshold_value: self.thresholds.water_stress_threshold,
                timestamp: now,
            });
        }

        risk
    }

    fn evaluate_pest(
        &self,
        cond: &FieldConditions,
        alerts: &mut Vec<Alert>,
        now: chrono::DateTime<Utc>,
    ) -> f64 {
        let confidence = match cond.pest_confidence {
            Some(c) if c >= self.thresholds.pest_confidence_threshold => c,
            _ => return 0.0,
        };

        let risk = confidence as f64;
        let species = cond.pest_species.as_deref().unwrap_or("Unknown");
        let severity = if confidence > 0.85 {
            AlertSeverity::Emergency
        } else if confidence > 0.7 {
            AlertSeverity::Critical
        } else {
            AlertSeverity::Warning
        };

        alerts.push(Alert {
            alert_type: AlertType::PestOutbreak,
            severity,
            field_id: cond.field_id.clone(),
            farm_id: cond.farm_id.clone(),
            title: format!("Pest detected: {} ({:.0}% confidence)", species, confidence * 100.0),
            message: format!(
                "{} detected with {:.1}% confidence in field {}. Immediate inspection recommended.",
                species, confidence * 100.0, cond.field_id
            ),
            recommendations: vec![
                format!("Scout field {} for {} presence and damage", cond.field_id, species),
                "Consult agronomist for targeted treatment plan".into(),
                "Monitor adjacent fields for spread".into(),
            ],
            metric_value: confidence as f64,
            threshold_value: self.thresholds.pest_confidence_threshold as f64,
            timestamp: now,
        });

        risk
    }

    fn evaluate_disease(
        &self,
        cond: &FieldConditions,
        alerts: &mut Vec<Alert>,
        now: chrono::DateTime<Utc>,
    ) -> f64 {
        let confidence = match cond.disease_confidence {
            Some(c) if c >= self.thresholds.disease_confidence_threshold => c,
            _ => return 0.0,
        };

        let risk = confidence as f64;
        let disease = cond.disease_name.as_deref().unwrap_or("Unknown");
        let severity = if confidence > 0.85 {
            AlertSeverity::Emergency
        } else if confidence > 0.65 {
            AlertSeverity::Critical
        } else {
            AlertSeverity::Warning
        };

        alerts.push(Alert {
            alert_type: AlertType::DiseaseDetected,
            severity,
            field_id: cond.field_id.clone(),
            farm_id: cond.farm_id.clone(),
            title: format!("Disease detected: {} ({:.0}%)", disease, confidence * 100.0),
            message: format!(
                "{} detected with {:.1}% confidence. Early intervention can limit spread.",
                disease, confidence * 100.0
            ),
            recommendations: vec![
                "Isolate affected plants to prevent spread".into(),
                format!("Apply recommended fungicide/bactericide for {}", disease),
                "Remove and destroy severely affected plant material".into(),
            ],
            metric_value: confidence as f64,
            threshold_value: self.thresholds.disease_confidence_threshold as f64,
            timestamp: now,
        });

        risk
    }

    fn evaluate_nutrient(
        &self,
        cond: &FieldConditions,
        alerts: &mut Vec<Alert>,
        now: chrono::DateTime<Utc>,
    ) -> f64 {
        let severity_score = match cond.nutrient_severity {
            Some(s) if s >= self.thresholds.nutrient_severity_threshold => s,
            _ => return 0.0,
        };

        let risk = severity_score as f64;
        let nutrient = cond.nutrient_type.as_deref().unwrap_or("Unknown");
        let severity = if severity_score > 0.8 {
            AlertSeverity::Critical
        } else {
            AlertSeverity::Warning
        };

        alerts.push(Alert {
            alert_type: AlertType::NutrientDeficiency,
            severity,
            field_id: cond.field_id.clone(),
            farm_id: cond.farm_id.clone(),
            title: format!("{} deficiency detected", nutrient),
            message: format!(
                "{} deficiency detected with severity {:.0}%. Yield impact likely without correction.",
                nutrient, severity_score * 100.0
            ),
            recommendations: vec![
                format!("Apply {} fertilizer based on soil test results", nutrient),
                "Retest soil in 2 weeks to verify correction".into(),
                "Check soil pH — deficiency may indicate pH imbalance".into(),
            ],
            metric_value: severity_score as f64,
            threshold_value: self.thresholds.nutrient_severity_threshold as f64,
            timestamp: now,
        });

        risk
    }

    fn evaluate_growth(
        &self,
        cond: &FieldConditions,
        alerts: &mut Vec<Alert>,
        now: chrono::DateTime<Utc>,
    ) -> f64 {
        let (expected, actual) = match (cond.growth_expected, cond.growth_actual) {
            (Some(e), Some(a)) if e > 0.0 => (e, a),
            _ => return 0.0,
        };

        let deviation_pct = ((actual - expected) / expected).abs() * 100.0;
        if deviation_pct < self.thresholds.growth_deviation_pct {
            return 0.0;
        }

        let risk = (deviation_pct / 100.0).min(1.0);
        let direction = if actual < expected { "below" } else { "above" };
        let severity = if deviation_pct > 50.0 {
            AlertSeverity::Critical
        } else {
            AlertSeverity::Warning
        };

        alerts.push(Alert {
            alert_type: AlertType::GrowthAnomaly,
            severity,
            field_id: cond.field_id.clone(),
            farm_id: cond.farm_id.clone(),
            title: format!("Growth anomaly: {:.0}% {} expected", deviation_pct, direction),
            message: format!(
                "Actual growth ({:.2}) is {:.0}% {} expected ({:.2}). NDVI: current={}, previous={}.",
                actual, deviation_pct, direction, expected,
                cond.ndvi_current.map_or("N/A".into(), |v| format!("{:.3}", v)),
                cond.ndvi_previous.map_or("N/A".into(), |v| format!("{:.3}", v)),
            ),
            recommendations: vec![
                "Investigate potential causes: pest, disease, nutrient, or water stress".into(),
                "Compare satellite imagery for spatial patterns".into(),
                "Schedule field inspection for ground-truth assessment".into(),
            ],
            metric_value: deviation_pct,
            threshold_value: self.thresholds.growth_deviation_pct,
            timestamp: now,
        });

        risk
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn test_conditions() -> FieldConditions {
        FieldConditions {
            field_id: "field-001".into(),
            farm_id: "farm-001".into(),
            crop_type: "wheat".into(),
            temperature_current: 22.0,
            temperature_min_forecast: 15.0,
            temperature_max_forecast: 29.0,
            precipitation_mm: 3.0,
            precipitation_forecast_mm: 5.0,
            soil_moisture: 0.30,
            et_reference_mm: 4.5,
            co2_ppm: 420.0,
            ndvi_current: Some(0.7),
            ndvi_previous: Some(0.65),
            pest_confidence: None,
            pest_species: None,
            disease_confidence: None,
            disease_name: None,
            nutrient_severity: None,
            nutrient_type: None,
            growth_expected: Some(0.8),
            growth_actual: Some(0.75),
        }
    }

    #[test]
    fn test_no_alerts_normal_conditions() {
        let eval = AlertEvaluator::with_defaults();
        let result = eval.evaluate(&test_conditions());
        assert!(result.alerts.is_empty());
        assert!(result.overall_risk < 0.1);
    }

    #[test]
    fn test_frost_alert() {
        let eval = AlertEvaluator::with_defaults();
        let mut cond = test_conditions();
        cond.temperature_min_forecast = -3.0;
        let result = eval.evaluate(&cond);
        assert!(result.alerts.iter().any(|a| a.alert_type == AlertType::FrostRisk));
        assert!(result.temperature_risk > 0.0);
    }

    #[test]
    fn test_heat_alert() {
        let eval = AlertEvaluator::with_defaults();
        let mut cond = test_conditions();
        cond.temperature_max_forecast = 42.0;
        let result = eval.evaluate(&cond);
        assert!(result.alerts.iter().any(|a| a.alert_type == AlertType::HeatStress));
    }

    #[test]
    fn test_drought_alert() {
        let eval = AlertEvaluator::with_defaults();
        let mut cond = test_conditions();
        cond.soil_moisture = 0.05;
        let result = eval.evaluate(&cond);
        assert!(result.alerts.iter().any(|a| a.alert_type == AlertType::DroughtWarning));
    }

    #[test]
    fn test_pest_alert() {
        let eval = AlertEvaluator::with_defaults();
        let mut cond = test_conditions();
        cond.pest_confidence = Some(0.85);
        cond.pest_species = Some("Aphid".into());
        let result = eval.evaluate(&cond);
        assert!(result.alerts.iter().any(|a| a.alert_type == AlertType::PestOutbreak));
        assert!(result.pest_risk > 0.5);
    }

    #[test]
    fn test_disease_alert() {
        let eval = AlertEvaluator::with_defaults();
        let mut cond = test_conditions();
        cond.disease_confidence = Some(0.75);
        cond.disease_name = Some("Tomato Late Blight".into());
        let result = eval.evaluate(&cond);
        assert!(result.alerts.iter().any(|a| a.alert_type == AlertType::DiseaseDetected));
    }

    #[test]
    fn test_growth_anomaly() {
        let eval = AlertEvaluator::with_defaults();
        let mut cond = test_conditions();
        cond.growth_expected = Some(0.8);
        cond.growth_actual = Some(0.4);
        let result = eval.evaluate(&cond);
        assert!(result.alerts.iter().any(|a| a.alert_type == AlertType::GrowthAnomaly));
    }

    #[test]
    fn test_multiple_alerts() {
        let eval = AlertEvaluator::with_defaults();
        let mut cond = test_conditions();
        cond.temperature_min_forecast = -2.0;
        cond.pest_confidence = Some(0.9);
        cond.pest_species = Some("Armyworm".into());
        cond.soil_moisture = 0.05;
        let result = eval.evaluate(&cond);
        assert!(result.alerts.len() >= 2);
        assert!(result.overall_risk > 0.5);
    }
}
