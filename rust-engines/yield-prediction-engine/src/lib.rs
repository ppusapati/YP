//! Yield Prediction Engine
//!
//! Multi-factor crop yield prediction using environmental inputs,
//! soil data, and management practices. Implements a multiplicative
//! yield model with stress factors.

pub mod factors;
pub mod model;
pub mod prediction;

pub use factors::{EnvironmentFactors, ManagementFactors, SoilFactors, StressFactor};
pub use model::{YieldModel, YieldModelParams};
pub use prediction::{YieldPrediction, predict_yield, predict_yield_batch};
