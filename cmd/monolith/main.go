// Package main is the modular monolith entry point for the YieldPoint agriculture
// platform. It wires all 23 services into a single binary sharing one database
// pool, one logger, and one ConnectRPC interceptor chain.
//
package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"connectrpc.com/connect"
	"github.com/jackc/pgx/v5/pgxpool"
	"go.uber.org/zap"

	"p9e.in/samavaya/packages/authz"
	"p9e.in/samavaya/packages/connect/interceptors"
	connectserver "p9e.in/samavaya/packages/connect/server"
	"p9e.in/samavaya/packages/p9log"
)

// sharedInfra holds infrastructure shared by all service modules.
type sharedInfra struct {
	pool       *pgxpool.Pool
	logger     p9log.Logger
	zapLogger  *zap.Logger
	connectOpt connect.Option
	baseURL    string // loopback URL for inter-service calls within the monolith
}

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
	jwtValidator := interceptors.NewAuthzJWTValidator()

	// ── Config from environment ─────────────────────────────────────────────
	dsn := envOr("DATABASE_URL", "postgres://localhost:5432/yieldpoint?sslmode=disable")
	port := envOr("PORT", "8080")
	baseURL := "http://localhost:" + port

	// ── Database pool (shared across all services) ──────────────────────────
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()

	pool, err := pgxpool.New(ctx, dsn)
	if err != nil {
		log.Fatalf("failed to connect to database: %v", err)
	}
	defer pool.Close()

	if err := pool.Ping(ctx); err != nil {
		log.Fatalf("database ping failed: %v", err)
	}

	// ── ConnectRPC interceptor chain (shared across all services) ────────────
	mwCfg := connectserver.MiddlewareConfig{
		EnableRecovery:  true,
		EnableRequestID: true,
		EnableLogging:   true,
		EnableDB:        true,
		DBPool:          pool,
		EnableAuth:      true,
		JWTValidator:    jwtValidator,
		EnableAuthz:     true,
		EnableRLS:       true,
		RLSLevel:        interceptors.ScopeLevelTenant,
	}
	connectOpt := connectserver.NewConnectOption(mwCfg)

	infra := &sharedInfra{
		pool:       pool,
		logger:     logger,
		zapLogger:  zapLogger,
		connectOpt: connectOpt,
		baseURL:    baseURL,
	}

	// ── Single HTTP mux for all services ────────────────────────────────────
	mux := http.NewServeMux()

	// ── Register ConnectRPC service modules ─────────────────────────────────
	// Hexagonal services (full adapter wiring with database)
	registerFarmModule(mux, infra)
	registerFieldModule(mux, infra)
	registerCropModule(mux, infra)
	registerSensorModule(mux, infra)
	registerSoilModule(mux, infra)
	registerIrrigationModule(mux, infra)
	registerYieldModule(mux, infra)
	registerSatelliteModule(mux, infra)
	registerPestPredictionModule(mux, infra)
	registerPlantDiagnosisModule(mux, infra)
	registerTraceabilityModule(mux, infra)
	registerCommerceModule(mux, infra)

	// Deps-based services (ServiceDeps pattern with database)
	registerTaskModule(mux, infra)
	registerAgronomyModule(mux, infra)
	registerVegetationIndexModule(mux, infra)
	registerSatelliteAnalyticsModule(mux, infra)
	registerSatelliteTileModule(mux, infra)
	registerSatelliteIngestionModule(mux, infra)
	registerSatelliteProcessingModule(mux, infra)

	// Stateless services (no database pool)
	registerAlertModule(mux, infra)
	registerAnalyticsModule(mux, infra)
	registerPrescriptionModule(mux, infra)

	// Auth service (plain HTTP handlers, no ConnectRPC)
	registerAuthModule(mux, infra)

	// ── Health / readiness probes ───────────────────────────────────────────
	mux.HandleFunc("/health", func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte(`{"status":"ok"}`))
	})
	mux.HandleFunc("/ready", func(w http.ResponseWriter, _ *http.Request) {
		if err := pool.Ping(context.Background()); err != nil {
			w.WriteHeader(http.StatusServiceUnavailable)
			return
		}
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte(`{"status":"ready"}`))
	})

	// ── Wrap with outer middleware and start server ──────────────────────────
	serverCfg := connectserver.DefaultServerConfig(port)
	wrapped := connectserver.WrapAll(mux, serverCfg)
	srv := connectserver.NewHTTPServer(serverCfg, wrapped)

	// ── Graceful shutdown ───────────────────────────────────────────────────
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)

	go func() {
		p9log.NewHelper(logger).Infow("msg", "monolith starting", "port", port, "services", 23)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("server error: %v", err)
		}
	}()

	<-quit
	p9log.NewHelper(logger).Infow("msg", "shutting down monolith")

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
