//! YieldPoint ML Training Pipeline — library crate.
//!
//! Provides the core training pipeline components for building custom ONNX
//! vision models from data collected by the AI gateway. This library is used
//! by the CLI binary (`main.rs`) and can also be consumed programmatically.

pub mod augment;
pub mod backbone;
pub mod backend;
pub mod benchmark;
pub mod compose;
pub mod config;
pub mod dataset;
pub mod eval;
pub mod export;
pub mod feedback;
pub mod model;
pub mod monitoring;
pub mod multitask;
pub mod onnx_proto;
pub mod quantize;
pub mod registry;
pub mod tabular;
pub mod training;
pub mod triggers;
pub mod validate;
