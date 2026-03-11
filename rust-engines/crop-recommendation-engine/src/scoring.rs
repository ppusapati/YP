//! Suitability scoring for crop-condition pairs.

use serde::{Deserialize, Serialize};

use crate::criteria::{CropCandidate, GrowingConditions, SoilConditions};

/// Weights for each suitability dimension.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ScoringWeights {
    pub soil_ph: f64,
    pub temperature: f64,
    pub water: f64,
    pub nutrients: f64,
    pub growing_season: f64,
    pub sunlight: f64,
    pub economic: f64,
}

impl Default for ScoringWeights {
    fn default() -> Self {
        Self {
            soil_ph: 0.15,
            temperature: 0.20,
            water: 0.20,
            nutrients: 0.15,
            growing_season: 0.10,
            sunlight: 0.05,
            economic: 0.15,
        }
    }
}

/// Detailed suitability score breakdown.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SuitabilityScore {
    /// Overall weighted score (0.0 - 1.0).
    pub overall: f64,
    /// Individual dimension scores (0.0 - 1.0).
    pub soil_ph_score: f64,
    pub temperature_score: f64,
    pub water_score: f64,
    pub nutrient_score: f64,
    pub growing_season_score: f64,
    pub sunlight_score: f64,
    pub economic_score: f64,
    /// Estimated yield factor (0.0 - 1.0).
    pub yield_factor: f64,
    /// Estimated revenue per hectare.
    pub estimated_revenue_per_ha: f64,
}

/// Compute the suitability score for a crop given soil and growing conditions.
pub fn compute_suitability_score(
    crop: &CropCandidate,
    soil: &SoilConditions,
    conditions: &GrowingConditions,
    weights: &ScoringWeights,
) -> SuitabilityScore {
    // Soil pH
    let soil_ph_score = crop.ph_suitability(soil.ph);

    // Temperature
    let temperature_score = crop.temperature_suitability(conditions.avg_temperature_c);

    // Water availability (rainfall + irrigation)
    let total_water = conditions.annual_rainfall_mm + conditions.irrigation_available_mm;
    let water_score = crop.water_suitability(total_water);

    // Nutrients
    let n_score = nutrient_ratio(soil.nitrogen_mg_kg, crop.nitrogen_requirement);
    let p_score = nutrient_ratio(soil.phosphorus_mg_kg, crop.phosphorus_requirement);
    let k_score = nutrient_ratio(soil.potassium_mg_kg, crop.potassium_requirement);
    let nutrient_score = (n_score + p_score + k_score) / 3.0;

    // Growing season
    let growing_season_score = if conditions.growing_season_days >= crop.min_growing_days {
        1.0
    } else {
        (conditions.growing_season_days as f64 / crop.min_growing_days as f64).clamp(0.0, 1.0)
    };

    // Sunlight
    let sunlight_score = if conditions.sunlight_hours_per_day >= crop.min_sunlight_hours {
        1.0
    } else {
        (conditions.sunlight_hours_per_day / crop.min_sunlight_hours).clamp(0.0, 1.0)
    };

    // Yield factor is the geometric mean of limiting factors
    let yield_factor = (soil_ph_score
        * temperature_score
        * water_score
        * nutrient_score
        * growing_season_score
        * sunlight_score)
        .powf(1.0 / 6.0);

    // Economic score based on expected net revenue (normalized)
    let revenue = crop.expected_revenue_per_ha(yield_factor);
    let economic_score = if revenue > 0.0 {
        (revenue / (crop.ideal_yield_kg_ha * crop.market_price_per_kg)).clamp(0.0, 1.0)
    } else {
        0.0
    };

    // Weighted overall score
    let total_weight = weights.soil_ph
        + weights.temperature
        + weights.water
        + weights.nutrients
        + weights.growing_season
        + weights.sunlight
        + weights.economic;

    let overall = if total_weight > 0.0 {
        (weights.soil_ph * soil_ph_score
            + weights.temperature * temperature_score
            + weights.water * water_score
            + weights.nutrients * nutrient_score
            + weights.growing_season * growing_season_score
            + weights.sunlight * sunlight_score
            + weights.economic * economic_score)
            / total_weight
    } else {
        0.0
    };

    SuitabilityScore {
        overall: overall.clamp(0.0, 1.0),
        soil_ph_score,
        temperature_score,
        water_score,
        nutrient_score,
        growing_season_score,
        sunlight_score,
        economic_score,
        yield_factor,
        estimated_revenue_per_ha: revenue,
    }
}

/// Ratio of available nutrient to required (capped at 1.0).
fn nutrient_ratio(available: f64, required: f64) -> f64 {
    if required <= 0.0 {
        1.0
    } else {
        (available / required).clamp(0.0, 1.0)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::criteria::*;

    fn test_crop() -> CropCandidate {
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
            suitable_textures: vec![SoilTexture::Loam, SoilTexture::SiltLoam],
            suitable_drainage: vec![DrainageClass::Well, DrainageClass::Moderate],
            ideal_yield_kg_ha: 4000.0,
            market_price_per_kg: 0.25,
            production_cost_per_ha: 400.0,
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
            annual_rainfall_mm: 400.0,
            irrigation_available_mm: 200.0,
            growing_season_days: 150,
            sunlight_hours_per_day: 8.0,
            elevation_m: 200.0,
        }
    }

    #[test]
    fn test_ideal_conditions_score_near_one() {
        let score = compute_suitability_score(
            &test_crop(),
            &test_soil(),
            &test_conditions(),
            &ScoringWeights::default(),
        );
        // With ideal conditions, overall should be high
        assert!(score.overall > 0.8, "overall={}", score.overall);
        assert!(score.soil_ph_score > 0.9);
        assert!(score.temperature_score > 0.9);
        assert!(score.water_score > 0.9);
    }

    #[test]
    fn test_poor_conditions_score_low() {
        let soil = SoilConditions {
            ph: 4.0,
            organic_matter_pct: 0.5,
            nitrogen_mg_kg: 5.0,
            phosphorus_mg_kg: 2.0,
            potassium_mg_kg: 5.0,
            texture: SoilTexture::Sand,
            drainage: DrainageClass::VeryRapid,
        };
        let conditions = GrowingConditions {
            avg_temperature_c: 35.0,
            min_temperature_c: 25.0,
            max_temperature_c: 45.0,
            annual_rainfall_mm: 100.0,
            irrigation_available_mm: 0.0,
            growing_season_days: 60,
            sunlight_hours_per_day: 4.0,
            elevation_m: 2000.0,
        };
        let score = compute_suitability_score(
            &test_crop(),
            &soil,
            &conditions,
            &ScoringWeights::default(),
        );
        assert!(score.overall < 0.3, "overall={}", score.overall);
    }
}
