//! Crop ranking engine using parallel multi-criteria analysis.

use rayon::prelude::*;
use serde::{Deserialize, Serialize};

use crate::criteria::{CropCandidate, GrowingConditions, SoilConditions};
use crate::scoring::{compute_suitability_score, ScoringWeights, SuitabilityScore};

/// Configuration for crop ranking.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RankingConfig {
    /// Scoring weights.
    pub weights: ScoringWeights,
    /// Minimum overall score threshold (crops below this are excluded).
    pub min_score_threshold: f64,
    /// Maximum number of recommendations to return.
    pub max_recommendations: usize,
}

impl Default for RankingConfig {
    fn default() -> Self {
        Self {
            weights: ScoringWeights::default(),
            min_score_threshold: 0.3,
            max_recommendations: 10,
        }
    }
}

/// A ranked crop recommendation.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RankedCrop {
    /// Rank (1-based, 1 = best).
    pub rank: usize,
    /// Crop name.
    pub name: String,
    /// Suitability score breakdown.
    pub score: SuitabilityScore,
    /// Limiting factors (dimensions with score < 0.5).
    pub limiting_factors: Vec<String>,
    /// Recommendation notes.
    pub notes: Vec<String>,
}

/// Rank crops against given conditions.
///
/// Evaluates all crop candidates in parallel, filters by minimum threshold,
/// sorts by overall score, and returns top recommendations.
pub fn rank_crops(
    candidates: &[CropCandidate],
    soil: &SoilConditions,
    conditions: &GrowingConditions,
    config: &RankingConfig,
) -> Vec<RankedCrop> {
    // Score all candidates in parallel
    let mut scored: Vec<(usize, &CropCandidate, SuitabilityScore)> = candidates
        .par_iter()
        .enumerate()
        .map(|(i, crop)| {
            let score = compute_suitability_score(crop, soil, conditions, &config.weights);
            (i, crop, score)
        })
        .filter(|(_, _, score)| score.overall >= config.min_score_threshold)
        .collect();

    // Sort by overall score descending
    scored.sort_by(|a, b| b.2.overall.partial_cmp(&a.2.overall).unwrap_or(std::cmp::Ordering::Equal));

    // Truncate to max recommendations
    scored.truncate(config.max_recommendations);

    // Build ranked results
    scored
        .into_iter()
        .enumerate()
        .map(|(rank_idx, (_, crop, score))| {
            let mut limiting_factors = Vec::new();
            let mut notes = Vec::new();

            if score.soil_ph_score < 0.5 {
                limiting_factors.push("Soil pH".to_string());
                notes.push(format!(
                    "Soil pH is outside optimal range for {} (score: {:.2})",
                    crop.name, score.soil_ph_score
                ));
            }
            if score.temperature_score < 0.5 {
                limiting_factors.push("Temperature".to_string());
                notes.push(format!(
                    "Temperature conditions are suboptimal (score: {:.2})",
                    score.temperature_score
                ));
            }
            if score.water_score < 0.5 {
                limiting_factors.push("Water availability".to_string());
                notes.push(format!(
                    "Insufficient water supply (score: {:.2}). Consider additional irrigation.",
                    score.water_score
                ));
            }
            if score.nutrient_score < 0.5 {
                limiting_factors.push("Soil nutrients".to_string());
                notes.push(format!(
                    "Nutrient levels below requirements (score: {:.2}). Fertilization recommended.",
                    score.nutrient_score
                ));
            }
            if score.growing_season_score < 0.5 {
                limiting_factors.push("Growing season".to_string());
                notes.push(format!(
                    "Growing season may be too short (score: {:.2})",
                    score.growing_season_score
                ));
            }
            if score.sunlight_score < 0.5 {
                limiting_factors.push("Sunlight".to_string());
            }

            if limiting_factors.is_empty() {
                notes.push(format!(
                    "{} is well-suited to these conditions with estimated yield factor {:.0}%.",
                    crop.name,
                    score.yield_factor * 100.0
                ));
            }

            RankedCrop {
                rank: rank_idx + 1,
                name: crop.name.clone(),
                score,
                limiting_factors,
                notes,
            }
        })
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::criteria::*;

    fn make_crop(name: &str, ph_range: (f64, f64), temp_range: (f64, f64)) -> CropCandidate {
        CropCandidate {
            name: name.to_string(),
            ph_range,
            temperature_range: temp_range,
            water_requirement_mm: 400.0,
            min_growing_days: 100,
            min_sunlight_hours: 6.0,
            nitrogen_requirement: 30.0,
            phosphorus_requirement: 15.0,
            potassium_requirement: 20.0,
            suitable_textures: vec![SoilTexture::Loam],
            suitable_drainage: vec![DrainageClass::Well],
            ideal_yield_kg_ha: 3000.0,
            market_price_per_kg: 0.30,
            production_cost_per_ha: 350.0,
        }
    }

    fn test_soil() -> SoilConditions {
        SoilConditions {
            ph: 6.5,
            organic_matter_pct: 3.0,
            nitrogen_mg_kg: 50.0,
            phosphorus_mg_kg: 25.0,
            potassium_mg_kg: 40.0,
            texture: SoilTexture::Loam,
            drainage: DrainageClass::Well,
        }
    }

    fn test_conditions() -> GrowingConditions {
        GrowingConditions {
            avg_temperature_c: 20.0,
            min_temperature_c: 10.0,
            max_temperature_c: 30.0,
            annual_rainfall_mm: 600.0,
            irrigation_available_mm: 100.0,
            growing_season_days: 150,
            sunlight_hours_per_day: 8.0,
            elevation_m: 200.0,
        }
    }

    #[test]
    fn test_ranking_order() {
        let candidates = vec![
            make_crop("Wheat", (6.0, 7.5), (15.0, 25.0)),     // good match for pH 6.5, temp 20
            make_crop("Rice", (5.0, 6.0), (25.0, 35.0)),       // poor match
            make_crop("Barley", (6.0, 8.0), (12.0, 22.0)),    // good match
        ];

        let results = rank_crops(&candidates, &test_soil(), &test_conditions(), &RankingConfig::default());

        assert!(!results.is_empty());
        assert_eq!(results[0].rank, 1);

        // Wheat and Barley should rank above Rice
        let names: Vec<&str> = results.iter().map(|r| r.name.as_str()).collect();
        if names.contains(&"Rice") {
            let rice_rank = results.iter().find(|r| r.name == "Rice").unwrap().rank;
            let wheat_rank = results.iter().find(|r| r.name == "Wheat").unwrap().rank;
            assert!(rice_rank > wheat_rank);
        }
    }

    #[test]
    fn test_threshold_filtering() {
        let candidates = vec![
            make_crop("Suitable", (6.0, 7.0), (15.0, 25.0)),
            make_crop("Unsuitable", (2.0, 3.0), (40.0, 50.0)),
        ];

        let config = RankingConfig {
            min_score_threshold: 0.5,
            ..Default::default()
        };

        let results = rank_crops(&candidates, &test_soil(), &test_conditions(), &config);
        assert!(results.iter().all(|r| r.score.overall >= 0.5));
    }

    #[test]
    fn test_max_recommendations() {
        let candidates: Vec<CropCandidate> = (0..20)
            .map(|i| make_crop(&format!("Crop{i}"), (5.0, 8.0), (10.0, 30.0)))
            .collect();

        let config = RankingConfig {
            max_recommendations: 5,
            min_score_threshold: 0.0,
            ..Default::default()
        };

        let results = rank_crops(&candidates, &test_soil(), &test_conditions(), &config);
        assert!(results.len() <= 5);
    }
}
