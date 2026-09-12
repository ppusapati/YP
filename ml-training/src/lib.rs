//! YieldPoint ML Training Pipeline — library crate.
//!
//! Provides the core training pipeline components for building custom ONNX
//! vision models from data collected by the AI gateway. This library is used
//! by the CLI binary (`main.rs`) and can also be consumed programmatically.

pub mod config;
pub mod dataset;
pub mod export;
pub mod model;
pub mod monitoring;
pub mod registry;
pub mod training;
pub mod triggers;
pub mod validate;
