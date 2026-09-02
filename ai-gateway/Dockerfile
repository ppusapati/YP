# Multi-stage Dockerfile for the AI Gateway gRPC service.
# Build context must be the repository root (so rust-engines/ is accessible).
#
# Build:  docker build -f ai-gateway/Dockerfile -t ai-gateway .
# Run:    docker run -p 50051:50051 ai-gateway

# ── Stage 1: build ──────────────────────────────────────────────────────────
FROM rust:1.82-bookworm AS builder

# protobuf-compiler is required by tonic-build (build.rs compiles .proto files).
RUN apt-get update && apt-get install -y --no-install-recommends \
    protobuf-compiler \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy workspace-level Cargo files first for dependency caching.
COPY rust-engines/Cargo.toml                    rust-engines/Cargo.toml
COPY rust-engines/satellite-ndvi-engine/Cargo.toml       rust-engines/satellite-ndvi-engine/Cargo.toml
COPY rust-engines/terrain-analysis-engine/Cargo.toml     rust-engines/terrain-analysis-engine/Cargo.toml
COPY rust-engines/crop-recommendation-engine/Cargo.toml  rust-engines/crop-recommendation-engine/Cargo.toml
COPY rust-engines/water-flow-simulation-engine/Cargo.toml rust-engines/water-flow-simulation-engine/Cargo.toml
COPY rust-engines/plant-ai-inference-engine/Cargo.toml   rust-engines/plant-ai-inference-engine/Cargo.toml
COPY rust-engines/yield-prediction-engine/Cargo.toml     rust-engines/yield-prediction-engine/Cargo.toml
COPY rust-engines/disease-detection-engine/Cargo.toml    rust-engines/disease-detection-engine/Cargo.toml
COPY rust-engines/pest-detection-engine/Cargo.toml       rust-engines/pest-detection-engine/Cargo.toml
COPY rust-engines/plant-classification-engine/Cargo.toml rust-engines/plant-classification-engine/Cargo.toml
COPY rust-engines/nutrient-deficiency-engine/Cargo.toml  rust-engines/nutrient-deficiency-engine/Cargo.toml
COPY rust-engines/crop-growth-engine/Cargo.toml          rust-engines/crop-growth-engine/Cargo.toml
COPY rust-engines/soil-nutrient-engine/Cargo.toml        rust-engines/soil-nutrient-engine/Cargo.toml
COPY rust-engines/climate-response-engine/Cargo.toml     rust-engines/climate-response-engine/Cargo.toml
COPY rust-engines/alert-engine/Cargo.toml                rust-engines/alert-engine/Cargo.toml
COPY rust-engines/analytics-engine/Cargo.toml            rust-engines/analytics-engine/Cargo.toml
COPY rust-engines/prescription-engine/Cargo.toml         rust-engines/prescription-engine/Cargo.toml

COPY ai-gateway/Cargo.toml  ai-gateway/Cargo.toml
COPY ai-gateway/build.rs    ai-gateway/build.rs
COPY ai-gateway/proto/      ai-gateway/proto/

# Create dummy lib.rs for each engine crate so cargo can resolve the workspace
# and download/compile dependencies without the full source tree.
RUN for engine in \
        satellite-ndvi-engine terrain-analysis-engine crop-recommendation-engine \
        water-flow-simulation-engine plant-ai-inference-engine yield-prediction-engine \
        disease-detection-engine pest-detection-engine plant-classification-engine \
        nutrient-deficiency-engine crop-growth-engine soil-nutrient-engine \
        climate-response-engine alert-engine analytics-engine prescription-engine; do \
      mkdir -p "rust-engines/${engine}/src" && echo "" > "rust-engines/${engine}/src/lib.rs"; \
    done \
    && mkdir -p ai-gateway/src && echo "fn main() {}" > ai-gateway/src/main.rs

# Pre-build dependencies (this layer is cached until Cargo.toml files change).
RUN cd ai-gateway && cargo build --release 2>/dev/null || true

# Copy the full source trees.
COPY rust-engines/ rust-engines/
COPY ai-gateway/   ai-gateway/

# Touch source files so cargo detects they changed after the dummy build.
RUN find ai-gateway/src rust-engines/*/src -name '*.rs' -exec touch {} +

# Build the release binary.
RUN cd ai-gateway && cargo build --release

# ── Stage 2: minimal runtime ───────────────────────────────────────────────
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --system app && useradd --system --gid app app

WORKDIR /app

COPY --from=builder /app/ai-gateway/target/release/ai-gateway /app/ai-gateway

USER app

EXPOSE 50051

ENTRYPOINT ["/app/ai-gateway"]
