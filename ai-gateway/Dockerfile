# Multi-stage Dockerfile for the Rust AI Gateway + ML engines.
# Build:  docker build -t ai-gateway -f ai-gateway/Dockerfile .
# Run:    docker run -p 50051:50051 ai-gateway

# ── Stage 1: build ──────────────────────────────────────────────────────────
FROM rust:1.82-alpine AS builder

RUN apk add --no-cache musl-dev protobuf-dev

WORKDIR /src

# Cache dependency compilation: copy manifests first.
COPY ai-gateway/Cargo.toml ai-gateway/Cargo.toml
COPY rust-engines/Cargo.toml rust-engines/Cargo.toml

# Copy all workspace member Cargo.toml files.
COPY rust-engines/satellite-ndvi-engine/Cargo.toml rust-engines/satellite-ndvi-engine/Cargo.toml
COPY rust-engines/terrain-analysis-engine/Cargo.toml rust-engines/terrain-analysis-engine/Cargo.toml
COPY rust-engines/crop-recommendation-engine/Cargo.toml rust-engines/crop-recommendation-engine/Cargo.toml
COPY rust-engines/water-flow-simulation-engine/Cargo.toml rust-engines/water-flow-simulation-engine/Cargo.toml
COPY rust-engines/plant-ai-inference-engine/Cargo.toml rust-engines/plant-ai-inference-engine/Cargo.toml
COPY rust-engines/yield-prediction-engine/Cargo.toml rust-engines/yield-prediction-engine/Cargo.toml
COPY rust-engines/disease-detection-engine/Cargo.toml rust-engines/disease-detection-engine/Cargo.toml
COPY rust-engines/pest-detection-engine/Cargo.toml rust-engines/pest-detection-engine/Cargo.toml
COPY rust-engines/plant-classification-engine/Cargo.toml rust-engines/plant-classification-engine/Cargo.toml
COPY rust-engines/nutrient-deficiency-engine/Cargo.toml rust-engines/nutrient-deficiency-engine/Cargo.toml
COPY rust-engines/crop-growth-engine/Cargo.toml rust-engines/crop-growth-engine/Cargo.toml
COPY rust-engines/soil-nutrient-engine/Cargo.toml rust-engines/soil-nutrient-engine/Cargo.toml
COPY rust-engines/climate-response-engine/Cargo.toml rust-engines/climate-response-engine/Cargo.toml
COPY rust-engines/alert-engine/Cargo.toml rust-engines/alert-engine/Cargo.toml
COPY rust-engines/analytics-engine/Cargo.toml rust-engines/analytics-engine/Cargo.toml
COPY rust-engines/prescription-engine/Cargo.toml rust-engines/prescription-engine/Cargo.toml

# Copy all source code.
COPY ai-gateway/ ai-gateway/
COPY rust-engines/ rust-engines/

WORKDIR /src/ai-gateway
RUN cargo build --release

# ── Stage 2: minimal runtime ────────────────────────────────────────────────
FROM alpine:3.21

RUN apk add --no-cache ca-certificates \
    && addgroup -S app && adduser -S app -G app

COPY --from=builder /src/ai-gateway/target/release/ai-gateway /app/ai-gateway
COPY ai-gateway/config.toml /app/config.toml

USER app
WORKDIR /app

EXPOSE 50051
ENTRYPOINT ["/app/ai-gateway"]
