//! Crop Recommendation Engine
//!
//! Multi-criteria analysis engine for recommending optimal crops based on
//! soil conditions, climate, water availability, and economic factors.

pub mod criteria;
pub mod ranking;
pub mod scoring;

pub use criteria::{CropCandidate, GrowingConditions, SoilConditions, SoilTexture, DrainageClass};
pub use ranking::{
    rank_crops, rank_with_confidence, pareto_optimal, diversification_score,
    select_diversified_portfolio, RankedCrop, RankingConfig,
};
pub use scoring::{compute_suitability_score, ScoringWeights, SuitabilityScore};

/// High-level crop recommendation engine.
pub struct CropRecommendationEngine {
    /// Available crop candidates.
    candidates: Vec<CropCandidate>,
    /// Ranking configuration.
    config: RankingConfig,
}

impl CropRecommendationEngine {
    /// Create a new engine with crop candidates and default configuration.
    pub fn new(candidates: Vec<CropCandidate>) -> Self {
        Self {
            candidates,
            config: RankingConfig::default(),
        }
    }

    /// Create with custom configuration.
    pub fn with_config(candidates: Vec<CropCandidate>, config: RankingConfig) -> Self {
        Self { candidates, config }
    }

    /// Set the ranking configuration.
    pub fn set_config(&mut self, config: RankingConfig) {
        self.config = config;
    }

    /// Add a crop candidate.
    pub fn add_candidate(&mut self, candidate: CropCandidate) {
        self.candidates.push(candidate);
    }

    /// Get the number of candidates.
    pub fn candidate_count(&self) -> usize {
        self.candidates.len()
    }

    /// Recommend crops for given conditions.
    pub fn recommend(
        &self,
        soil: &SoilConditions,
        conditions: &GrowingConditions,
    ) -> Vec<RankedCrop> {
        rank_crops(&self.candidates, soil, conditions, &self.config)
    }

    /// Recommend crops with confidence scores.
    pub fn recommend_with_confidence(
        &self,
        soil: &SoilConditions,
        conditions: &GrowingConditions,
    ) -> Vec<RankedCrop> {
        rank_with_confidence(&self.candidates, soil, conditions, &self.config)
    }

    /// Get top-N recommendations.
    pub fn top_n(
        &self,
        soil: &SoilConditions,
        conditions: &GrowingConditions,
        n: usize,
    ) -> Vec<RankedCrop> {
        let mut results = self.recommend(soil, conditions);
        results.truncate(n);
        results
    }

    /// Score a single crop against conditions.
    pub fn score_crop(
        &self,
        crop: &CropCandidate,
        soil: &SoilConditions,
        conditions: &GrowingConditions,
    ) -> SuitabilityScore {
        compute_suitability_score(crop, soil, conditions, &self.config.weights)
    }

    /// Get Pareto-optimal crops (non-dominated solutions).
    pub fn pareto_optimal(
        &self,
        soil: &SoilConditions,
        conditions: &GrowingConditions,
    ) -> Vec<usize> {
        let scores: Vec<(usize, SuitabilityScore)> = self
            .candidates
            .iter()
            .enumerate()
            .map(|(i, crop)| {
                let score = compute_suitability_score(crop, soil, conditions, &self.config.weights);
                (i, score)
            })
            .collect();
        pareto_optimal(&scores)
    }

    /// Recommend a diversified portfolio of crops.
    pub fn diversified_portfolio(
        &self,
        soil: &SoilConditions,
        conditions: &GrowingConditions,
        max_crops: usize,
    ) -> Vec<RankedCrop> {
        let ranked = self.recommend(soil, conditions);
        let indices = select_diversified_portfolio(&ranked, &self.candidates, max_crops);
        indices.into_iter().filter_map(|i| ranked.get(i).cloned()).collect()
    }

    /// Get a summary of all candidate suitability scores.
    pub fn summary(
        &self,
        soil: &SoilConditions,
        conditions: &GrowingConditions,
    ) -> Vec<(String, f64)> {
        self.candidates
            .iter()
            .map(|crop| {
                let score = compute_suitability_score(crop, soil, conditions, &self.config.weights);
                (crop.name.clone(), score.overall)
            })
            .collect()
    }
}

/// Create a default set of common crop candidates.
pub fn default_crop_library() -> Vec<CropCandidate> {
    vec![
        CropCandidate {
            name: "Wheat".to_string(),
            ph_range: (6.0, 7.5),
            temperature_range: (15.0, 25.0),
            water_requirement_mm: 500.0,
            min_growing_days: 120,
            min_sunlight_hours: 6.0,
            nitrogen_requirement: 40.0,
            phosphorus_requirement: 20.0,
            potassium_requirement: 30.0,
            suitable_textures: vec![SoilTexture::Loam, SoilTexture::SiltLoam, SoilTexture::ClayLoam],
            suitable_drainage: vec![DrainageClass::Well, DrainageClass::Moderate],
            ideal_yield_kg_ha: 4000.0,
            market_price_per_kg: 0.25,
            production_cost_per_ha: 400.0,
        },
        CropCandidate {
            name: "Corn".to_string(),
            ph_range: (5.8, 7.0),
            temperature_range: (20.0, 30.0),
            water_requirement_mm: 600.0,
            min_growing_days: 100,
            min_sunlight_hours: 8.0,
            nitrogen_requirement: 60.0,
            phosphorus_requirement: 25.0,
            potassium_requirement: 35.0,
            suitable_textures: vec![SoilTexture::Loam, SoilTexture::SiltLoam],
            suitable_drainage: vec![DrainageClass::Well],
            ideal_yield_kg_ha: 10000.0,
            market_price_per_kg: 0.18,
            production_cost_per_ha: 600.0,
        },
        CropCandidate {
            name: "Soybean".to_string(),
            ph_range: (6.0, 7.0),
            temperature_range: (20.0, 30.0),
            water_requirement_mm: 500.0,
            min_growing_days: 100,
            min_sunlight_hours: 7.0,
            nitrogen_requirement: 10.0,
            phosphorus_requirement: 15.0,
            potassium_requirement: 25.0,
            suitable_textures: vec![SoilTexture::Loam, SoilTexture::SiltLoam, SoilTexture::SandyLoam],
            suitable_drainage: vec![DrainageClass::Well, DrainageClass::Moderate],
            ideal_yield_kg_ha: 3000.0,
            market_price_per_kg: 0.40,
            production_cost_per_ha: 350.0,
        },
        CropCandidate {
            name: "Rice".to_string(),
            ph_range: (5.5, 6.5),
            temperature_range: (25.0, 35.0),
            water_requirement_mm: 1200.0,
            min_growing_days: 120,
            min_sunlight_hours: 6.0,
            nitrogen_requirement: 50.0,
            phosphorus_requirement: 20.0,
            potassium_requirement: 30.0,
            suitable_textures: vec![SoilTexture::Clay, SoilTexture::SiltyClay, SoilTexture::ClayLoam],
            suitable_drainage: vec![DrainageClass::Poor, DrainageClass::Imperfect],
            ideal_yield_kg_ha: 6000.0,
            market_price_per_kg: 0.35,
            production_cost_per_ha: 500.0,
        },
        CropCandidate {
            name: "Potato".to_string(),
            ph_range: (5.0, 6.5),
            temperature_range: (15.0, 22.0),
            water_requirement_mm: 500.0,
            min_growing_days: 90,
            min_sunlight_hours: 6.0,
            nitrogen_requirement: 45.0,
            phosphorus_requirement: 30.0,
            potassium_requirement: 50.0,
            suitable_textures: vec![SoilTexture::SandyLoam, SoilTexture::Loam],
            suitable_drainage: vec![DrainageClass::Well],
            ideal_yield_kg_ha: 30000.0,
            market_price_per_kg: 0.15,
            production_cost_per_ha: 700.0,
        },
    ]
}

#[cfg(test)]
mod tests {
    use super::*;

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
    fn test_engine_creation() {
        let engine = CropRecommendationEngine::new(default_crop_library());
        assert_eq!(engine.candidate_count(), 5);
    }

    #[test]
    fn test_engine_recommend() {
        let engine = CropRecommendationEngine::new(default_crop_library());
        let results = engine.recommend(&test_soil(), &test_conditions());
        assert!(!results.is_empty());
        assert_eq!(results[0].rank, 1);
    }

    #[test]
    fn test_engine_top_n() {
        let engine = CropRecommendationEngine::new(default_crop_library());
        let results = engine.top_n(&test_soil(), &test_conditions(), 3);
        assert!(results.len() <= 3);
    }

    #[test]
    fn test_engine_pareto() {
        let engine = CropRecommendationEngine::new(default_crop_library());
        let pareto = engine.pareto_optimal(&test_soil(), &test_conditions());
        assert!(!pareto.is_empty());
    }

    #[test]
    fn test_engine_summary() {
        let engine = CropRecommendationEngine::new(default_crop_library());
        let summary = engine.summary(&test_soil(), &test_conditions());
        assert_eq!(summary.len(), 5);
    }
}
