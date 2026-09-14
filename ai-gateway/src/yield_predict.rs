//! Yield prediction and crop growth simulation.
//!
//! Wraps the `yield-prediction-engine`. The parametric stress-factor model is
//! always available; when a trained gradient-boosted model is configured its
//! estimate is blended in, weighted by that model's held-out R², and its
//! conformal interval replaces the heuristic one.

use std::time::Instant;

use yield_prediction_engine::{
    AttributionReport, EnvironmentFactors, GradientBoostedModel, ManagementFactors, SoilFactors,
    YieldFeatures, YieldModelParams, YieldPredictionEngine, DEFAULT_SAMPLES,
};

use crate::config::ModelPaths;
use crate::proto;

/// Handles yield prediction and crop growth simulation operations.
pub struct YieldEngine {
    model_paths: ModelPaths,
    tabular: Option<GradientBoostedModel>,
}

/// How the point estimate was produced.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ModelSource {
    Parametric,
    Tabular,
    Blended,
}

impl ModelSource {
    fn as_str(self) -> &'static str {
        match self {
            Self::Parametric => "parametric",
            Self::Tabular => "tabular",
            Self::Blended => "blended",
        }
    }
}

/// Fixed so the same prediction always comes with the same reasons; two people
/// looking at one number must not see different explanations for it.
const ATTRIBUTION_SEED: u64 = 0x5969_656C_6421;

/// Yield contributions are in the prediction's own units.
const YIELD_UNITS: &str = "kg/ha";

/// Render an attribution report for the wire.
///
/// Shared with prescriptions, which attribute in their own units.
pub fn attribution_proto(
    report: &AttributionReport,
    attributed_share: f64,
    units: &str,
) -> proto::AttributionSummary {
    proto::AttributionSummary {
        baseline: report.baseline,
        prediction: report.prediction,
        features: report
            .attributions
            .iter()
            .map(|a| proto::FeatureAttribution {
                feature: a.feature.clone(),
                value: a.value,
                contribution: a.contribution,
            })
            .collect(),
        attributed_share,
        method: report.method.clone(),
        residual: report.residual(),
        summary: report.summary(units),
        units: units.to_string(),
    }
}

impl YieldEngine {
    pub fn new(model_paths: ModelPaths) -> Self {
        let tabular = load_tabular_model(&model_paths.yield_tabular_model);
        Self {
            model_paths,
            tabular,
        }
    }

    /// Construct with an in-memory tabular model (tests and embedding).
    pub fn with_tabular(model_paths: ModelPaths, tabular: Option<GradientBoostedModel>) -> Self {
        Self {
            model_paths,
            tabular,
        }
    }

    pub fn has_tabular_model(&self) -> bool {
        self.tabular.is_some()
    }

    /// Predict crop yield from environmental, soil, and management factors.
    pub fn predict_yield(
        &self,
        request: &proto::PredictYieldRequest,
    ) -> proto::PredictYieldResponse {
        let start = Instant::now();

        let (params, crop_supported) = match YieldModelParams::for_crop(&request.crop_type) {
            Some(p) => (p, true),
            None => (YieldModelParams::wheat(), false),
        };
        let engine = YieldPredictionEngine::new(params);

        let env = convert_environment(&request.environment);
        let soil = convert_soil(&request.soil);
        let mgmt = convert_management(&request.management);

        let (prediction, (heur_lower, heur_upper)) =
            engine.uncertainty_interval(&env, &soil, &mgmt);
        let parametric = prediction.predicted_yield_kg_ha;

        let mut point = parametric;
        let mut lower = heur_lower;
        let mut upper = heur_upper;
        let mut source = ModelSource::Parametric;
        let mut tabular_weight = 0.0;
        let mut interval_coverage = 0.0;
        let mut model_version = self.model_paths.yield_prediction_version.clone();

        let mut attribution = None;
        if let (Some(model), true) = (&self.tabular, crop_supported) {
            let features =
                YieldFeatures::from_factors(&request.crop_type, &env, &soil, &mgmt).to_vec();
            if let Ok((tab_point, tab_lower, tab_upper)) = model.predict_interval(&features) {
                // Trust the learned model in proportion to how well it validated.
                tabular_weight = model.validation.r_squared.clamp(0.0, 1.0);
                point = tabular_weight * tab_point + (1.0 - tabular_weight) * parametric;
                source = if tabular_weight >= 0.999 {
                    ModelSource::Tabular
                } else {
                    ModelSource::Blended
                };
                if model.interval_half_width().is_some() {
                    let shift = point - tab_point;
                    lower = (tab_lower + shift).max(0.0);
                    upper = tab_upper + shift;
                    interval_coverage = model.interval_coverage();
                } else {
                    let rel_lo = if parametric > 0.0 {
                        heur_lower / parametric
                    } else {
                        0.85
                    };
                    let rel_hi = if parametric > 0.0 {
                        heur_upper / parametric
                    } else {
                        1.15
                    };
                    lower = point * rel_lo;
                    upper = point * rel_hi;
                }
                if !model.version.is_empty() {
                    model_version = format!("{}+{}", model_version, model.version);
                }

                // Explain the learned component, which is the part a farmer
                // cannot reason about from the inputs alone. The parametric
                // component explains itself through its stress factors, which
                // are already in this response.
                match model.attribute(&features, DEFAULT_SAMPLES, ATTRIBUTION_SEED) {
                    Ok(report) => {
                        attribution = Some(attribution_proto(&report, tabular_weight, YIELD_UNITS));
                    }
                    Err(e) => {
                        tracing::debug!(error = %e, "yield prediction not attributed");
                    }
                }
            }
        }

        let stress_factors: Vec<proto::StressFactor> = prediction
            .stress_factors
            .iter()
            .map(|sf| proto::StressFactor {
                factor_name: sf.name.clone(),
                severity: 1.0 - sf.factor,
                yield_impact_pct: (1.0 - sf.factor) * 100.0,
            })
            .collect();

        proto::PredictYieldResponse {
            request_id: request.request_id.clone(),
            predicted_yield_kg_per_hectare: point,
            confidence_pct: prediction.yield_pct,
            yield_lower_bound: lower,
            yield_upper_bound: upper,
            stress_factors,
            model_version,
            processing_time_ms: start.elapsed().as_millis() as i64,
            model_source: source.as_str().to_string(),
            tabular_weight,
            crop_supported,
            interval_coverage,
            parametric_yield_kg_per_hectare: parametric,
            attribution,
        }
    }

    /// Simulate crop growth over time.
    pub fn simulate_crop_growth(
        &self,
        request: &proto::SimulateCropGrowthRequest,
    ) -> proto::SimulateCropGrowthResponse {
        let start = Instant::now();

        let params =
            YieldModelParams::for_crop(&request.crop_type).unwrap_or_else(YieldModelParams::wheat);
        let engine = YieldPredictionEngine::new(params);
        let env = convert_environment(&request.initial_environment);
        let soil = convert_soil(&request.initial_soil);
        let mgmt = ManagementFactors {
            planting_day: 1,
            plant_population_per_ha: request.planting_density,
            nitrogen_applied_kg_ha: 120.0,
            irrigation_mm: 200.0,
            pest_control_effectiveness: 0.85,
            weed_control_effectiveness: 0.85,
        };

        let prediction = engine.predict(&env, &soil, &mgmt);
        let simulation_days = request.simulation_days.max(1);
        let stages = simulate_stages(simulation_days, prediction.predicted_yield_kg_ha);

        proto::SimulateCropGrowthResponse {
            request_id: request.request_id.clone(),
            stages,
            final_biomass_kg_per_ha: prediction.predicted_yield_kg_ha * 2.5, // harvest index ~0.4
            estimated_days_to_maturity: simulation_days,
            model_version: self.model_paths.crop_growth_version.clone(),
            processing_time_ms: start.elapsed().as_millis() as i64,
        }
    }
}

fn load_tabular_model(path: &str) -> Option<GradientBoostedModel> {
    if path.trim().is_empty() {
        return None;
    }
    match std::fs::read_to_string(path) {
        Ok(json) => match GradientBoostedModel::from_json(&json) {
            Ok(m) => {
                tracing::info!(
                    path,
                    version = %m.version,
                    r2 = m.validation.r_squared,
                    trees = m.n_trees(),
                    "loaded tabular yield model"
                );
                Some(m)
            }
            Err(e) => {
                tracing::warn!(path, error = %e, "tabular yield model unreadable; using parametric model only");
                None
            }
        },
        Err(e) => {
            tracing::warn!(path, error = %e, "tabular yield model not found; using parametric model only");
            None
        }
    }
}

/// Simulate growth stage progression over the specified number of days.
fn simulate_stages(days: i32, final_yield: f64) -> Vec<proto::GrowthStageResult> {
    let stage_defs = [
        ("germination", 0.0, 0.05),
        ("seedling", 0.05, 0.15),
        ("vegetative", 0.15, 0.45),
        ("flowering", 0.45, 0.70),
        ("grain_fill", 0.70, 0.90),
        ("maturation", 0.90, 1.0),
    ];

    let mut results = Vec::new();
    for (name, start_frac, end_frac) in &stage_defs {
        let stage_start_day = (*start_frac * days as f64) as i32;
        let stage_end_day = (*end_frac * days as f64) as i32;
        let mid_day = (stage_start_day + stage_end_day) / 2;
        let biomass = final_yield * 2.5 * end_frac;
        let lai = 3.5 * end_frac.min(0.8);
        let height = 120.0 * end_frac;
        let water_demand = 6.0 * (0.3 + 0.7 * end_frac);

        results.push(proto::GrowthStageResult {
            day: mid_day,
            stage_name: name.to_string(),
            biomass_kg_per_ha: biomass,
            leaf_area_index: lai,
            canopy_height_cm: height,
            water_demand_mm: water_demand,
        });
    }

    results
}

/// Convert proto environment factors to engine EnvironmentFactors.
fn convert_environment(proto_env: &Option<proto::EnvironmentFactors>) -> EnvironmentFactors {
    match proto_env {
        Some(env) => EnvironmentFactors {
            avg_temperature_c: env.temperature_celsius,
            total_precipitation_mm: env.rainfall_mm,
            solar_radiation_mj_m2_day: env.solar_radiation,
            growing_degree_days: env.growing_degree_days,
            frost_days: env.frost_days.max(0) as u32,
            heat_stress_days: if env.heat_stress_days > 0 {
                env.heat_stress_days as u32
            } else if env.temperature_celsius > 35.0 {
                10
            } else {
                0
            },
            relative_humidity_pct: env.humidity_pct,
        },
        None => EnvironmentFactors {
            avg_temperature_c: 20.0,
            total_precipitation_mm: 400.0,
            solar_radiation_mj_m2_day: 20.0,
            growing_degree_days: 2000.0,
            frost_days: 0,
            heat_stress_days: 0,
            relative_humidity_pct: 60.0,
        },
    }
}

/// Convert proto soil factors to engine SoilFactors.
fn convert_soil(proto_soil: &Option<proto::SoilFactors>) -> SoilFactors {
    match proto_soil {
        Some(soil) => SoilFactors {
            organic_matter_pct: soil.organic_matter_pct,
            ph: soil.ph,
            nitrogen_kg_ha: soil.nitrogen_ppm * 2.0, // approximate ppm to kg/ha conversion
            phosphorus_kg_ha: soil.phosphorus_ppm * 2.0,
            potassium_kg_ha: soil.potassium_ppm * 2.0,
            water_holding_capacity_mm_m: soil.moisture_pct * 3.0,
            compaction_index: soil.compaction_index,
        },
        None => SoilFactors {
            organic_matter_pct: 3.0,
            ph: 6.5,
            nitrogen_kg_ha: 80.0,
            phosphorus_kg_ha: 40.0,
            potassium_kg_ha: 60.0,
            water_holding_capacity_mm_m: 200.0,
            compaction_index: 0.0,
        },
    }
}

/// Convert proto management factors to engine ManagementFactors.
fn convert_management(proto_mgmt: &Option<proto::ManagementFactors>) -> ManagementFactors {
    match proto_mgmt {
        Some(mgmt) => ManagementFactors {
            planting_day: if mgmt.planting_day > 0 {
                mgmt.planting_day as u32
            } else {
                100
            },
            plant_population_per_ha: mgmt.planting_density,
            nitrogen_applied_kg_ha: mgmt.fertilizer_rate_kg_per_ha,
            irrigation_mm: if mgmt.irrigation_mm > 0.0 {
                mgmt.irrigation_mm
            } else {
                mgmt.irrigation_efficiency * 300.0
            },
            pest_control_effectiveness: match mgmt.pest_management_level.as_str() {
                "high" => 0.95,
                "medium" => 0.80,
                "low" => 0.60,
                _ => 0.75,
            },
            weed_control_effectiveness: 0.85,
        },
        None => ManagementFactors {
            planting_day: 100,
            plant_population_per_ha: 3_500_000.0,
            nitrogen_applied_kg_ha: 120.0,
            irrigation_mm: 200.0,
            pest_control_effectiveness: 0.85,
            weed_control_effectiveness: 0.85,
        },
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use yield_prediction_engine::{GbmParams, FEATURE_NAMES};

    fn request(crop: &str) -> proto::PredictYieldRequest {
        proto::PredictYieldRequest {
            request_id: "r".into(),
            crop_type: crop.into(),
            environment: Some(proto::EnvironmentFactors {
                temperature_celsius: 22.0,
                humidity_pct: 60.0,
                rainfall_mm: 500.0,
                solar_radiation: 20.0,
                wind_speed_kmh: 8.0,
                growing_degree_days: 2000.0,
                ..Default::default()
            }),
            soil: Some(proto::SoilFactors {
                ph: 6.5,
                organic_matter_pct: 3.0,
                nitrogen_ppm: 40.0,
                phosphorus_ppm: 20.0,
                potassium_ppm: 30.0,
                moisture_pct: 60.0,
                texture: "loam".into(),
                compaction_index: 0.1,
            }),
            management: Some(proto::ManagementFactors {
                irrigation_efficiency: 0.7,
                fertilizer_rate_kg_per_ha: 120.0,
                tillage_type: "conventional".into(),
                planting_density: 3_000_000.0,
                pest_management_level: "medium".into(),
                ..Default::default()
            }),
            field_area_hectares: 1.0,
        }
    }

    /// A tiny model trained to always predict a constant so blending is checkable.
    fn constant_model(value: f64, r2: f64) -> GradientBoostedModel {
        let names: Vec<String> = FEATURE_NAMES.iter().map(|s| s.to_string()).collect();
        let x: Vec<Vec<f64>> = (0..40)
            .map(|i| {
                let mut v = vec![0.0; FEATURE_NAMES.len()];
                v[1] = i as f64;
                v
            })
            .collect();
        let y = vec![value; 40];
        let mut m = GradientBoostedModel::train(
            &x,
            &y,
            names,
            GbmParams {
                n_trees: 5,
                ..Default::default()
            },
        )
        .unwrap();
        m.calibrate(&x, &y, 0.9).unwrap();
        m.validation.r_squared = r2;
        m.version = "yield-gbm-test".into();
        m
    }

    /// A model that actually responds to one input, so attribution has
    /// something real to find.
    fn responsive_model() -> GradientBoostedModel {
        let names: Vec<String> = FEATURE_NAMES.iter().map(|s| s.to_string()).collect();
        let nitrogen = FEATURE_NAMES
            .iter()
            .position(|n| *n == "nitrogen_applied_kg_ha")
            .unwrap();
        let x: Vec<Vec<f64>> = (0..80)
            .map(|i| {
                let mut v = vec![0.0; FEATURE_NAMES.len()];
                v[1] = 18.0 + (i % 10) as f64;
                v[nitrogen] = (i % 20) as f64 * 10.0;
                v
            })
            .collect();
        let y: Vec<f64> = x.iter().map(|r| 2000.0 + 8.0 * r[nitrogen]).collect();

        let mut m = GradientBoostedModel::train(
            &x,
            &y,
            names,
            GbmParams {
                n_trees: 40,
                max_depth: 3,
                ..Default::default()
            },
        )
        .unwrap();
        m.calibrate(&x, &y, 0.9).unwrap();
        m.validation.r_squared = 1.0;
        m.version = "yield-gbm-attrib".into();
        m
    }

    #[test]
    fn a_served_prediction_says_which_inputs_moved_it() {
        let engine = YieldEngine::with_tabular(ModelPaths::default(), Some(responsive_model()));
        let mut req = request("wheat");
        if let Some(m) = req.management.as_mut() {
            m.fertilizer_rate_kg_per_ha = 190.0;
        }

        let response = engine.predict_yield(&req);
        let attribution = response
            .attribution
            .expect("a trained model with a reference set explains itself");

        assert_eq!(attribution.units, "kg/ha");
        assert_eq!(attribution.method, "shapley-sampling");
        assert_eq!(attribution.features.len(), FEATURE_NAMES.len());
        // Full weight on the learned model means it explains the whole number.
        assert!((attribution.attributed_share - 1.0).abs() < 1e-9);

        // Nitrogen is the only input the model was fitted to respond to, so it
        // must come out on top.
        assert_eq!(
            attribution.features[0].feature,
            "nitrogen_applied_kg_ha",
            "ranked: {:?}",
            attribution
                .features
                .iter()
                .take(3)
                .map(|f| (&f.feature, f.contribution))
                .collect::<Vec<_>>()
        );
        assert!((attribution.features[0].value - 190.0).abs() < 1e-9);

        // The split must account for the gap it claims to explain.
        let gap = attribution.prediction - attribution.baseline;
        let total: f64 = attribution.features.iter().map(|f| f.contribution).sum();
        assert!(
            (total - gap).abs() < 0.02 * gap.abs().max(1.0),
            "contributions {total} vs gap {gap}"
        );
        assert!(attribution.residual.abs() < 0.02 * gap.abs().max(1.0));
        assert!(!attribution.summary.is_empty());

        // Two identical requests must produce identical explanations.
        let again = engine.predict_yield(&req).attribution.unwrap();
        assert_eq!(again.features, attribution.features);
    }

    #[test]
    fn a_blended_prediction_reports_how_much_it_explains() {
        let mut model = responsive_model();
        model.validation.r_squared = 0.6;
        let engine = YieldEngine::with_tabular(ModelPaths::default(), Some(model));

        let attribution = engine.predict_yield(&request("wheat")).attribution.unwrap();
        // Only 60% of the served number comes from the attributed model, and
        // the response says so rather than implying it explains everything.
        assert!((attribution.attributed_share - 0.6).abs() < 1e-9);
    }

    #[test]
    fn predictions_with_no_learned_component_carry_no_attribution() {
        // No tabular model at all.
        let engine = YieldEngine::with_tabular(ModelPaths::default(), None);
        assert!(engine
            .predict_yield(&request("wheat"))
            .attribution
            .is_none());

        // An unknown crop is never blended, so there is nothing to attribute.
        let engine = YieldEngine::with_tabular(ModelPaths::default(), Some(responsive_model()));
        let response = engine.predict_yield(&request("dragonfruit"));
        assert!(!response.crop_supported);
        assert!(response.attribution.is_none());

        // A model trained before reference sets existed reports nothing rather
        // than inventing a baseline.
        let mut old = responsive_model();
        old.set_reference(&[]);
        let engine = YieldEngine::with_tabular(ModelPaths::default(), Some(old));
        assert!(engine
            .predict_yield(&request("wheat"))
            .attribution
            .is_none());
    }

    #[test]
    fn parametric_only_when_no_tabular_model() {
        let e = YieldEngine::with_tabular(ModelPaths::default(), None);
        let r = e.predict_yield(&request("wheat"));
        assert_eq!(r.model_source, "parametric");
        assert!(r.crop_supported);
        assert_eq!(r.tabular_weight, 0.0);
        assert!(r.predicted_yield_kg_per_hectare > 0.0);
        assert!(
            r.yield_lower_bound < r.predicted_yield_kg_per_hectare
                && r.yield_upper_bound > r.predicted_yield_kg_per_hectare
        );
        assert_eq!(
            r.parametric_yield_kg_per_hectare,
            r.predicted_yield_kg_per_hectare
        );
    }

    #[test]
    fn unknown_crop_flagged_and_never_blended() {
        let e = YieldEngine::with_tabular(ModelPaths::default(), Some(constant_model(5000.0, 0.9)));
        let r = e.predict_yield(&request("dragonfruit"));
        assert!(!r.crop_supported);
        assert_eq!(r.model_source, "parametric");
    }

    #[test]
    fn blends_by_validation_r2_and_uses_conformal_interval() {
        let e = YieldEngine::with_tabular(ModelPaths::default(), Some(constant_model(6000.0, 0.5)));
        let r = e.predict_yield(&request("cotton"));
        assert_eq!(r.model_source, "blended");
        assert!((r.tabular_weight - 0.5).abs() < 1e-9);
        let expected = 0.5 * 6000.0 + 0.5 * r.parametric_yield_kg_per_hectare;
        assert!((r.predicted_yield_kg_per_hectare - expected).abs() < 1e-6);
        assert!((r.interval_coverage - 0.9).abs() < 1e-9);
        assert!(r.model_version.ends_with("+yield-gbm-test"));
    }

    #[test]
    fn full_weight_reports_tabular_source() {
        let e = YieldEngine::with_tabular(ModelPaths::default(), Some(constant_model(4000.0, 1.0)));
        let r = e.predict_yield(&request("potato"));
        assert_eq!(r.model_source, "tabular");
        assert!((r.predicted_yield_kg_per_hectare - 4000.0).abs() < 1e-6);
    }

    #[test]
    fn new_crops_have_distinct_parametric_ceilings() {
        let e = YieldEngine::with_tabular(ModelPaths::default(), None);
        let cane = e
            .predict_yield(&request("sugarcane"))
            .predicted_yield_kg_per_hectare;
        let chickpea = e
            .predict_yield(&request("chickpea"))
            .predicted_yield_kg_per_hectare;
        assert!(cane > 5.0 * chickpea, "cane {cane} vs chickpea {chickpea}");
    }
}
