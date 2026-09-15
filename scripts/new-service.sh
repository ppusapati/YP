#!/usr/bin/env bash
#
# new-service.sh — scaffold a new Go microservice for the YieldPoint platform.
#
# Usage:
#   ./scripts/new-service.sh <service-name>
#
# Example:
#   ./scripts/new-service.sh weather
#   # Creates weather-service/ with the standard directory layout.

set -euo pipefail

# ── Validate arguments ──────────────────────────────────────────────────────

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <service-name>"
  echo "Example: $0 weather"
  exit 1
fi

NAME="$1"
SERVICE_DIR="${NAME}-service"
MODULE="p9e.in/samavaya/agriculture"
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

if [[ -d "${ROOT_DIR}/${SERVICE_DIR}" ]]; then
  echo "Error: ${SERVICE_DIR}/ already exists."
  exit 1
fi

# Validate name: lowercase alphanumeric with optional hyphens
if ! [[ "$NAME" =~ ^[a-z][a-z0-9-]*$ ]]; then
  echo "Error: service name must be lowercase alphanumeric (hyphens allowed, must start with a letter)."
  exit 1
fi

# Convert hyphenated name to Go-friendly identifiers
GO_NAME="$(echo "$NAME" | sed -E 's/(^|-)([a-z])/\U\2/g')"  # weather-map -> WeatherMap
GO_NAME_LOWER="$(echo "$GO_NAME" | sed 's/^\(.\)/\L\1/')"     # WeatherMap -> weatherMap
PKG_NAME="$(echo "$NAME" | tr '-' '_')"                        # weather-map -> weather_map

echo "Scaffolding ${SERVICE_DIR}..."

# ── Create directory structure ──────────────────────────────────────────────

mkdir -p "${ROOT_DIR}/${SERVICE_DIR}/cmd/server"
mkdir -p "${ROOT_DIR}/${SERVICE_DIR}/internal/handlers"
mkdir -p "${ROOT_DIR}/${SERVICE_DIR}/internal/services"
mkdir -p "${ROOT_DIR}/${SERVICE_DIR}/internal/repositories"
mkdir -p "${ROOT_DIR}/${SERVICE_DIR}/migrations"
mkdir -p "${ROOT_DIR}/${SERVICE_DIR}/proto"

# ── cmd/server/main.go ──────────────────────────────────────────────────────

cat > "${ROOT_DIR}/${SERVICE_DIR}/cmd/server/main.go" << GOEOF
// Package main wires all ${NAME}-service layers together and starts the HTTP server.
package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"go.uber.org/zap"

	"${MODULE}/packages/authz"
	connectserver "${MODULE}/packages/connect/server"
	"${MODULE}/packages/connect/interceptors"
	"${MODULE}/packages/database/migrate"
	"${MODULE}/packages/p9log"
)

func main() {
	// ── Logger ──────────────────────────────────────────────────────────────
	zapLogger, err := zap.NewProduction()
	if err != nil {
		log.Fatalf("failed to create logger: %v", err)
	}
	defer zapLogger.Sync() //nolint:errcheck
	logger := p9log.NewLogger(zapLogger)

	// ── JWT ─────────────────────────────────────────────────────────────────
	if err := authz.InitJWTFromEnv(); err != nil {
		log.Fatalf("JWT not configured: %v — refusing to start without authentication", err)
	}
	_ = interceptors.NewAuthzJWTValidator()

	// ── Config from environment ──────────────────────────────────────────────
	port := envOr("PORT", "8080")

	// ── Database pool (uncomment when DATABASE_URL is wired) ─────────────────
	// dsn := mustEnv("DATABASE_URL", "postgres://localhost:5432/${PKG_NAME}_service?sslmode=disable")
	// ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	// defer cancel()
	// pool, err := pgxpool.New(ctx, dsn)
	// if err != nil {
	// 	log.Fatalf("failed to connect to database: %v", err)
	// }
	// defer pool.Close()

	// ── Auto-migrate (uncomment when database is wired) ─────────────────────
	// migrateCtx, migrateCancel := context.WithTimeout(context.Background(), 5*time.Minute)
	// defer migrateCancel()
	// if err := migrate.Up(migrateCtx, pool, os.DirFS(envOr("MIGRATIONS_DIR", "migrations")), zapLogger); err != nil {
	// 	log.Fatalf("migration failed: %v", err)
	// }
	_ = migrate.Up // silence unused import until database is wired

	// ── HTTP mux ─────────────────────────────────────────────────────────────
	mux := http.NewServeMux()

	// TODO: Register ConnectRPC handler once proto is generated:
	//   path, svcHandler := ${PKG_NAME}v1connect.New${GO_NAME}ServiceHandler(handler, connectOpt)
	//   mux.Handle(path, svcHandler)

	// Health / readiness probes
	mux.HandleFunc("/health", func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte(\`{"status":"ok"}\`))
	})
	mux.HandleFunc("/ready", func(w http.ResponseWriter, _ *http.Request) {
		// TODO: add database ping once pool is wired
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte(\`{"status":"ready"}\`))
	})

	serverCfg := connectserver.DefaultServerConfig(port)
	wrapped := connectserver.WrapAll(mux, serverCfg)
	srv := connectserver.NewHTTPServer(serverCfg, wrapped)

	// ── Graceful shutdown ────────────────────────────────────────────────────
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)

	go func() {
		p9log.NewHelper(logger).Infow("msg", "${NAME}-service starting", "port", port)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("server error: %v", err)
		}
	}()

	<-quit
	p9log.NewHelper(logger).Infow("msg", "shutting down ${NAME}-service")

	shutCtx, shutCancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer shutCancel()
	if err := srv.Shutdown(shutCtx); err != nil {
		log.Printf("graceful shutdown error: %v", err)
	}
}

func envOr(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
GOEOF

# ── internal/handlers/handler.go ────────────────────────────────────────────

cat > "${ROOT_DIR}/${SERVICE_DIR}/internal/handlers/handler.go" << GOEOF
// Package handlers contains the ConnectRPC inbound adapter for ${NAME}-service.
package handlers

// TODO: implement the ConnectRPC handler once proto is generated.
// See farm-service/adapters/inbound/grpc/farm_handler.go for reference.
//
// type ${GO_NAME}Handler struct {
// 	${PKG_NAME}v1connect.Unimplemented${GO_NAME}ServiceHandler
// 	svc services.${GO_NAME}Service
// 	log *p9log.Helper
// }
GOEOF

# ── internal/services/service.go ────────────────────────────────────────────

cat > "${ROOT_DIR}/${SERVICE_DIR}/internal/services/service.go" << GOEOF
// Package services contains the core business logic for ${NAME}-service.
package services

// TODO: define the ${GO_NAME}Service interface and implementation.
// See farm-service/application/farm_service.go for reference.
GOEOF

# ── internal/repositories/repository.go ─────────────────────────────────────

cat > "${ROOT_DIR}/${SERVICE_DIR}/internal/repositories/repository.go" << GOEOF
// Package repositories contains the outbound persistence adapters for ${NAME}-service.
package repositories

// TODO: define the ${GO_NAME}Repository interface and Postgres implementation.
// See farm-service/adapters/outbound/postgres/farm_repository.go for reference.
GOEOF

# ── proto/<name>.proto ──────────────────────────────────────────────────────

cat > "${ROOT_DIR}/${SERVICE_DIR}/proto/${NAME}.proto" << PROTOEOF
syntax = "proto3";

package yieldpoint.${PKG_NAME}.v1;

option go_package = "${MODULE}/${SERVICE_DIR}/api/v1;${PKG_NAME}v1";

// ${GO_NAME}Service provides the gRPC/ConnectRPC API for the ${NAME}-service.
service ${GO_NAME}Service {
  // TODO: add RPC methods here.
  // Example:
  //   rpc Get${GO_NAME}(Get${GO_NAME}Request) returns (Get${GO_NAME}Response) {}
}
PROTOEOF

# ── Dockerfile (symlink to root) ────────────────────────────────────────────
# The root Dockerfile handles all Go services via the SERVICE build arg.
# A symlink keeps things discoverable from within the service directory.
ln -s ../Dockerfile "${ROOT_DIR}/${SERVICE_DIR}/Dockerfile"

# ── migrations/.gitkeep ─────────────────────────────────────────────────────
touch "${ROOT_DIR}/${SERVICE_DIR}/migrations/.gitkeep"

# ── Summary ─────────────────────────────────────────────────────────────────

cat << EOF

  ${SERVICE_DIR}/ scaffolded successfully.

  Directory layout:
    ${SERVICE_DIR}/
    ├── cmd/server/main.go              # Entry point with health/ready endpoints
    ├── internal/
    │   ├── handlers/handler.go         # ConnectRPC handler stub
    │   ├── services/service.go         # Business logic stub
    │   └── repositories/repository.go  # Persistence stub
    ├── proto/${NAME}.proto             # Protobuf service definition
    ├── migrations/                     # SQL migration files
    └── Dockerfile -> ../Dockerfile     # Symlink to shared Dockerfile

  Next steps:
    1. Define your proto RPCs in ${SERVICE_DIR}/proto/${NAME}.proto
    2. Run \`buf generate\` to generate Go code
    3. Implement the handler, service, and repository
    4. Add the service to docker-compose.yml:

       ${NAME}-service:
         <<: *go-service
         build:
           context: .
           args:
             SERVICE: ${SERVICE_DIR}
         ports:
           - "<PORT>:8080"
         environment:
           <<: *go-env
           DATABASE_URL: \${$(echo "${NAME}_SERVICE_DATABASE_URL" | tr '[:lower:]-' '[:upper:]_'):-postgres://yieldpoint:yieldpoint@postgres:5432/${PKG_NAME}_service?sslmode=disable}

    5. Add "${SERVICE_DIR}" to the SERVICES list in the Makefile

EOF
