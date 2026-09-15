# CPU build. For CUDA, use Dockerfile.cuda.
#
# The backend is selected at compile time:
#   docker build -t yp-ml-training .
#   docker build --build-arg FEATURES=wgpu -t yp-ml-training:wgpu .
#
# A wgpu image still needs Vulkan drivers on the host at run time.
ARG FEATURES=""

FROM rust:1.91-bookworm AS builder
ARG FEATURES

WORKDIR /build
COPY Cargo.toml Cargo.lock* ./
COPY src/ src/
COPY examples/ examples/

RUN cargo build --release ${FEATURES:+--features ${FEATURES}}

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates libssl3 && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /build/target/release/yp-ml-training /usr/local/bin/
COPY configs/ /app/configs/

WORKDIR /app
ENTRYPOINT ["yp-ml-training"]
CMD ["pipeline", "--tasks", "all", "--config", "configs/training_config.toml"]
