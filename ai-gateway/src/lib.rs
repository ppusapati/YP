//! AI Gateway — gRPC service wrapping Rust AI/ML engines.
//!
//! This crate provides the `AIGatewayService` gRPC server that Go microservices
//! call for all ML/AI operations. It initializes the Rust engines (disease
//! detection, pest detection, yield prediction, satellite NDVI, crop
//! recommendation, plant AI inference) and exposes them through a unified gRPC API
//! defined in `proto/ai_gateway.proto`.

pub mod alerting;
pub mod analytics;
pub mod config;
pub mod diagnosis;
pub mod prescription;
pub mod recommend;
pub mod satellite;
pub mod service;
pub mod yield_predict;

/// Generated protobuf types and gRPC server trait.
pub mod proto {
    tonic::include_proto!("agriculture.ai.v1");
}
