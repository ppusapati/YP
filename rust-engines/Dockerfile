# Dockerfile for the Rust computation engines workspace.
# These are library crates — the image builds all members and runs tests by default.
#
# Build:  docker build -t rust-engines rust-engines/
# Test:   docker run rust-engines

# ── Stage 1: build & test ──────────────────────────────────────────────────
FROM rust:1.82-bookworm AS builder

WORKDIR /app

# Copy workspace Cargo.toml and all member Cargo.toml files for dependency caching.
COPY Cargo.toml ./
COPY satellite-ndvi-engine/Cargo.toml       satellite-ndvi-engine/Cargo.toml
COPY terrain-analysis-engine/Cargo.toml     terrain-analysis-engine/Cargo.toml
COPY crop-recommendation-engine/Cargo.toml  crop-recommendation-engine/Cargo.toml
COPY water-flow-simulation-engine/Cargo.toml water-flow-simulation-engine/Cargo.toml
COPY plant-ai-inference-engine/Cargo.toml   plant-ai-inference-engine/Cargo.toml
COPY yield-prediction-engine/Cargo.toml     yield-prediction-engine/Cargo.toml
COPY disease-detection-engine/Cargo.toml    disease-detection-engine/Cargo.toml
COPY pest-detection-engine/Cargo.toml       pest-detection-engine/Cargo.toml
COPY plant-classification-engine/Cargo.toml plant-classification-engine/Cargo.toml
COPY nutrient-deficiency-engine/Cargo.toml  nutrient-deficiency-engine/Cargo.toml
COPY crop-growth-engine/Cargo.toml          crop-growth-engine/Cargo.toml
COPY soil-nutrient-engine/Cargo.toml        soil-nutrient-engine/Cargo.toml
COPY climate-response-engine/Cargo.toml     climate-response-engine/Cargo.toml
COPY alert-engine/Cargo.toml               alert-engine/Cargo.toml
COPY analytics-engine/Cargo.toml           analytics-engine/Cargo.toml
COPY prescription-engine/Cargo.toml        prescription-engine/Cargo.toml

# Create dummy lib.rs for each engine crate so cargo can download dependencies.
RUN for engine in \
        satellite-ndvi-engine terrain-analysis-engine crop-recommendation-engine \
        water-flow-simulation-engine plant-ai-inference-engine yield-prediction-engine \
        disease-detection-engine pest-detection-engine plant-classification-engine \
        nutrient-deficiency-engine crop-growth-engine soil-nutrient-engine \
        climate-response-engine alert-engine analytics-engine prescription-engine; do \
      mkdir -p "${engine}/src" && echo "" > "${engine}/src/lib.rs"; \
    done

# Pre-build dependencies (cached until Cargo.toml files change).
RUN cargo build --release --workspace 2>/dev/null || true

# Copy the full source tree.
COPY . .

# Touch source files so cargo detects they changed after the dummy build.
RUN find . -path '*/src/*.rs' -exec touch {} +

# Build all workspace members in release mode.
RUN cargo build --release --workspace

# Default command: run the full test suite (for CI validation).
CMD ["cargo", "test", "--release", "--workspace"]
