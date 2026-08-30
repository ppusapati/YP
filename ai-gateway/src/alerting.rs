use crate::proto;
use alert_engine::evaluator::AlertEvaluator;
use alert_engine::types::{AlertThresholds, FieldConditions};
use climate_response_engine::types::ClimateParams;
use std::time::Instant;

pub struct AlertingEngine {
    evaluator: AlertEvaluator,
}

impl AlertingEngine {
    pub fn new() -> Self {
        Self {
            evaluator: AlertEvaluator::new(AlertThresholds::default(), ClimateParams::default()),
        }
    }

    pub fn evaluate_field_risk(&self, req: &proto::EvaluateFieldRiskRequest) -> proto::EvaluateFieldRiskResponse {
        let start = Instant::now();

        let weather = req.weather.as_ref();
        let soil = req.soil_state.as_ref();
        let detections = req.detections.as_ref();
        let growth = req.growth.as_ref();

        let conditions = FieldConditions {
            field_id: req.field_id.clone(),
            farm_id: req.farm_id.clone(),
            crop_type: req.crop_type.clone(),
            temperature_current: weather.map(|w| w.temperature_current).unwrap_or(22.0),
            temperature_min_forecast: weather.map(|w| w.temperature_min_forecast).unwrap_or(15.0),
            temperature_max_forecast: weather.map(|w| w.temperature_max_forecast).unwrap_or(29.0),
            precipitation_mm: weather.map(|w| w.precipitation_mm).unwrap_or(3.0),
            precipitation_forecast_mm: weather.map(|w| w.precipitation_forecast_mm).unwrap_or(5.0),
            et_reference_mm: weather.map(|w| w.et_reference_mm).unwrap_or(4.5),
            co2_ppm: weather.map(|w| w.co2_ppm).unwrap_or(420.0),
            soil_moisture: soil.map(|s| s.soil_moisture).unwrap_or(0.30),
            ndvi_current: growth.map(|g| g.ndvi_current),
            ndvi_previous: growth.map(|g| g.ndvi_previous),
            pest_confidence: detections.map(|d| d.pest_confidence as f32),
            pest_species: detections.and_then(|d| {
                if d.pest_species.is_empty() { None } else { Some(d.pest_species.clone()) }
            }),
            disease_confidence: detections.map(|d| d.disease_confidence as f32),
            disease_name: detections.and_then(|d| {
                if d.disease_name.is_empty() { None } else { Some(d.disease_name.clone()) }
            }),
            nutrient_severity: detections.map(|d| d.nutrient_severity as f32),
            nutrient_type: detections.and_then(|d| {
                if d.nutrient_type.is_empty() { None } else { Some(d.nutrient_type.clone()) }
            }),
            growth_expected: growth.map(|g| g.growth_expected),
            growth_actual: growth.map(|g| g.growth_actual),
        };

        let result = self.evaluator.evaluate(&conditions);

        let alerts = result.alerts.iter().map(|a| proto::FieldAlert {
            alert_type: format!("{:?}", a.alert_type),
            severity: a.severity.label().to_string(),
            title: a.title.clone(),
            message: a.message.clone(),
            recommendations: a.recommendations.clone(),
            metric_value: a.metric_value,
            threshold_value: a.threshold_value,
        }).collect();

        proto::EvaluateFieldRiskResponse {
            request_id: req.request_id.clone(),
            field_id: req.field_id.clone(),
            overall_risk: result.overall_risk,
            temperature_risk: result.temperature_risk,
            water_risk: result.water_risk,
            pest_risk: result.pest_risk,
            disease_risk: result.disease_risk,
            nutrient_risk: result.nutrient_risk,
            growth_risk: result.growth_risk,
            alerts,
            processing_time_ms: start.elapsed().as_millis() as i64,
        }
    }
}
