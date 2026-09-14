# Multi-stage Dockerfile for all Go agriculture services.
# Build:  docker build --build-arg SERVICE=farm-service -t farm-service .
# Run:    docker run -e DATABASE_URL=... -e PORT=8080 farm-service
#
# CMD_PATH overrides the package built, for the few binaries in this repo that
# are not a service at <name>/cmd/server — cmd/mockserver, for instance:
#   docker build --build-arg CMD_PATH=./cmd/mockserver -t mockserver .

# ── Stage 1: build ──────────────────────────────────────────────────────────
FROM golang:1.25-alpine AS builder

ARG SERVICE
ARG CMD_PATH
RUN test -n "$SERVICE" -o -n "$CMD_PATH" || \
    (echo "one of SERVICE or CMD_PATH is required" && exit 1)

RUN apk add --no-cache git ca-certificates

WORKDIR /src

# Cache dependency downloads.
COPY go.mod go.sum ./
COPY packages/go.mod packages/go.sum ./packages/
RUN go mod download

# Copy everything (monorepo layout — services reference packages/).
COPY . .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -trimpath -ldflags="-s -w" \
    -o /app/server "${CMD_PATH:-./${SERVICE}/cmd/server}"

# Copy migrations if they exist; create empty dir otherwise.
RUN if [ -n "${SERVICE}" ] && [ -d "${SERVICE}/migrations" ]; then \
      cp -r "${SERVICE}/migrations" /app/migrations; \
    else \
      mkdir -p /app/migrations; \
    fi

# ── Stage 2: minimal runtime ────────────────────────────────────────────────
FROM alpine:3.21

RUN apk add --no-cache ca-certificates tzdata \
    && addgroup -S app && adduser -S app -G app

COPY --from=builder /app/server /app/server
COPY --from=builder /app/migrations/ /app/migrations/

USER app
WORKDIR /app

EXPOSE 8080
ENTRYPOINT ["/app/server"]
