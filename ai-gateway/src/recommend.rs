//! Crop recommendation operations.
//!
//! Wraps the `crop-recommendation-engine` for multi-criteria crop suitability analysis.

use std::time::Instant;

use crop_recommendation_engine::{
    CropCandidate, CropRecommendationEngine, GrowingConditions, RankedCrop,
    SoilConditions, SoilTexture, DrainageClass,
};

use crate::config::ModelPaths;
use crate::proto;

/// Handles crop recommendation operations.
pub struct RecommendEngine {
    model_paths: ModelPaths,
    /// The crop candidate database used for all recommendation queries.
    engine: CropRecommendationEngine,
}

impl RecommendEngine {
    pub fn new(model_paths: ModelPaths) -> Self {
        let candidates = default_crop_candidates();
        let engine = CropRecommendationEngine::new(candidates);
        Self {
            model_paths,
            engine,
        }
    }

    /// Recommend suitable crops based on soil, climate, and economic factors.
    pub fn recommend_crops(
        &self,
        request: &proto::RecommendCropsRequest,
    ) -> proto::RecommendCropsResponse {
        let start = Instant::now();

        let soil = convert_soil_conditions(&request.soil);
        let conditions = convert_growing_conditions(&request.climate);

        let max_recs = if request.max_recommendations > 0 {
            request.max_recommendations as usize
        } else {
            5
        };

        let ranked = self.engine.top_n(&soil, &conditions, max_recs);

        let recommendations: Vec<proto::CropRecommendation> = ranked
            .iter()
            .map(|r| proto::CropRecommendation {
                crop_name: r.candidate.name.clone(),
                scientific_name: String::new(),
                category: String::new(),
                suitability_score: r.score,
                confidence: r.confidence.unwrap_or(0.7),
                expected_yield_kg_per_ha: r.candidate.expected_yield_kg_ha,
                expected_profit_per_ha: 0.0, // would be computed with economics input
                water_requirement_mm: r.candidate.water_requirement_mm,
                rationale: format!(
                    "Suitability score {:.2} based on soil, climate, and water availability analysis",
                    r.score
                ),
                risk_factors: vec![],
            })
            .collect();

        let elapsed = start.elapsed();

        proto::RecommendCropsResponse {
            request_id: request.request_id.clone(),
            recommendations,
            model_version: self.model_paths.crop_recommendation_version.clone(),
            processing_time_ms: elapsed.as_millis() as i64,
        }
    }
}

/// Convert proto SoilConditions to engine SoilConditions.
fn convert_soil_conditions(
    proto_soil: &Option<proto::SoilConditions>,
) -> SoilConditions {
    match proto_soil {
        Some(soil) => SoilConditions {
            ph: soil.ph,
            organic_matter_pct: soil.organic_matter_pct,
            nitrogen_mg_kg: soil.nitrogen_ppm,
            phosphorus_mg_kg: soil.phosphorus_ppm,
            potassium_mg_kg: soil.potassium_ppm,
            texture: match soil.texture.to_lowercase().as_str() {
                "clay" => SoilTexture::Clay,
                "loam" => SoilTexture::Loam,
                "sandy" | "sand" => SoilTexture::Sand,
                "silt" => SoilTexture::Silt,
                "sandy_loam" => SoilTexture::SandyLoam,
                "silt_loam" => SoilTexture::SiltLoam,
                "clay_loam" => SoilTexture::ClayLoam,
                _ => SoilTexture::Loam,
            },
            drainage: match soil.drainage_class.to_lowercase().as_str() {
                "poor" => DrainageClass::Poor,
                "moderate" => DrainageClass::Moderate,
                "well" => DrainageClass::Well,
                "excessive" | "rapid" => DrainageClass::Rapid,
                _ => DrainageClass::Moderate,
            },
        },
        None => SoilConditions {
            ph: 6.5,
            organic_matter_pct: 3.0,
            nitrogen_mg_kg: 40.0,
            phosphorus_mg_kg: 20.0,
            potassium_mg_kg: 30.0,
            texture: SoilTexture::Loam,
            drainage: DrainageClass::Moderate,
        },
    }
}

/// Convert proto ClimateConditions to engine GrowingConditions.
fn convert_growing_conditions(
    proto_climate: &Option<proto::ClimateConditions>,
) -> GrowingConditions {
    match proto_climate {
        Some(climate) => GrowingConditions {
            avg_temperature_c: climate.avg_temperature_celsius,
            min_temperature_c: climate.avg_temperature_celsius - 10.0,
            max_temperature_c: climate.avg_temperature_celsius + 10.0,
            annual_rainfall_mm: climate.annual_rainfall_mm,
            irrigation_available_mm: 200.0,
            growing_season_days: climate.frost_free_days as u32,
            sunlight_hours_per_day: 8.0,
            elevation_m: 0.0,
        },
        None => GrowingConditions {
            avg_temperature_c: 20.0,
            min_temperature_c: 10.0,
            max_temperature_c: 30.0,
            annual_rainfall_mm: 800.0,
            irrigation_available_mm: 200.0,
            growing_season_days: 200,
            sunlight_hours_per_day: 8.0,
            elevation_m: 0.0,
        },
    }
}

/// Build the default set of crop candidates for the recommendation engine.
fn default_crop_candidates() -> Vec<CropCandidate> {
    vec![
        CropCandidate {
            name: "Wheat".to_string(),
            ph_range: (5.5, 7.5),
            temp_range_c: (10.0, 25.0),
            water_requirement_mm: 450.0,
            growing_season_days: 120,
            expected_yield_kg_ha: 3500.0,
            market_value_per_kg: 0.25,
            input_cost_per_ha: 500.0,
            drought_tolerance: 0.6,
            frost_tolerance: 0.8,
            suitable_textures: vec![SoilTexture::Loam, SoilTexture::SiltLoam, SoilTexture::ClayLoam],
        },
        CropCandidate {
            name: "Rice".to_string(),
            ph_range: (5.0, 7.0),
            temp_range_c: (20.0, 35.0),
            water_requirement_mm: 1200.0,
            growing_season_days: 150,
            expected_yield_kg_ha: 4500.0,
            market_value_per_kg: 0.35,
            input_cost_per_ha: 800.0,
            drought_tolerance: 0.2,
            frost_tolerance: 0.1,
            suitable_textures: vec![SoilTexture::Clay, SoilTexture::SiltyClay, SoilTexture::ClayLoam],
        },
        CropCandidate {
            name: "Corn".to_string(),
            ph_range: (5.8, 7.0),
            temp_range_c: (18.0, 32.0),
            water_requirement_mm: 600.0,
            growing_season_days: 130,
            expected_yield_kg_ha: 9000.0,
            market_value_per_kg: 0.18,
            input_cost_per_ha: 700.0,
            drought_tolerance: 0.4,
            frost_tolerance: 0.2,
            suitable_textures: vec![SoilTexture::Loam, SoilTexture::SiltLoam, SoilTexture::SandyLoam],
        },
        CropCandidate {
            name: "Soybean".to_string(),
            ph_range: (6.0, 7.0),
            temp_range_c: (15.0, 30.0),
            water_requirement_mm: 500.0,
            growing_season_days: 120,
            expected_yield_kg_ha: 2800.0,
            market_value_per_kg: 0.40,
            input_cost_per_ha: 400.0,
            drought_tolerance: 0.5,
            frost_tolerance: 0.3,
            suitable_textures: vec![SoilTexture::Loam, SoilTexture::SiltLoam, SoilTexture::SandyLoam],
        },
        CropCandidate {
            name: "Cotton".to_string(),
            ph_range: (5.8, 8.0),
            temp_range_c: (20.0, 35.0),
            water_requirement_mm: 700.0,
            growing_season_days: 180,
            expected_yield_kg_ha: 1800.0,
            market_value_per_kg: 1.50,
            input_cost_per_ha: 900.0,
            drought_tolerance: 0.6,
            frost_tolerance: 0.1,
            suitable_textures: vec![SoilTexture::Loam, SoilTexture::SandyLoam, SoilTexture::ClayLoam],
        },
        CropCandidate {
            name: "Potato".to_string(),
            ph_range: (4.8, 6.5),
            temp_range_c: (12.0, 24.0),
            water_requirement_mm: 500.0,
            growing_season_days: 100,
            expected_yield_kg_ha: 20000.0,
            market_value_per_kg: 0.20,
            input_cost_per_ha: 1200.0,
            drought_tolerance: 0.3,
            frost_tolerance: 0.4,
            suitable_textures: vec![SoilTexture::SandyLoam, SoilTexture::Loam, SoilTexture::SiltLoam],
        },
        CropCandidate {
            name: "Sugarcane".to_string(),
            ph_range: (5.0, 8.5),
            temp_range_c: (20.0, 38.0),
            water_requirement_mm: 1500.0,
            growing_season_days: 300,
            expected_yield_kg_ha: 70000.0,
            market_value_per_kg: 0.03,
            input_cost_per_ha: 1500.0,
            drought_tolerance: 0.4,
            frost_tolerance: 0.0,
            suitable_textures: vec![SoilTexture::Loam, SoilTexture::ClayLoam, SoilTexture::SiltLoam],
        },
    ]
}
