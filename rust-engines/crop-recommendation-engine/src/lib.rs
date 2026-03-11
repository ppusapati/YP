//! Crop Recommendation Engine
//!
//! Multi-criteria analysis engine for recommending optimal crops based on
//! soil conditions, climate, water availability, and economic factors.

pub mod criteria;
pub mod ranking;
pub mod scoring;

pub use criteria::{CropCandidate, GrowingConditions, SoilConditions};
pub use ranking::{rank_crops, RankedCrop, RankingConfig};
pub use scoring::{compute_suitability_score, ScoringWeights, SuitabilityScore};
