FROM rust:1.82-slim AS builder

WORKDIR /build
COPY Cargo.toml Cargo.lock* ./
COPY src/ src/

RUN cargo build --release

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates libssl3 && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /build/target/release/yp-ml-training /usr/local/bin/
COPY configs/ /app/configs/

WORKDIR /app
ENTRYPOINT ["yp-ml-training"]
CMD ["pipeline", "--tasks", "all", "--config", "configs/training_config.toml"]
