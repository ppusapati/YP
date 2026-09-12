// Package main wires all agronomy-service layers together and starts the HTTP server.
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
	"github.com/IBM/sarama"
	"github.com/jackc/pgx/v5/pgxpool"
	"go.uber.org/zap"

	"p9e.in/samavaya/packages/authz"
	connectserver "p9e.in/samavaya/packages/connect/server"
	"p9e.in/samavaya/packages/connect/interceptors"
	"p9e.in/samavaya/packages/database/migrate"
	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/middleware"
	"p9e.in/samavaya/packages/outbox"
	"p9e.in/samavaya/packages/p9log"

	"p9e.in/samavaya/agriculture/agronomy-service/api/v1/v1connect"
	"p9e.in/samavaya/agriculture/agronomy-service/internal/handlers"
	"p9e.in/samavaya/agriculture/agronomy-service/internal/repositories"
	"p9e.in/samavaya/agriculture/agronomy-service/internal/services"
)

func main() {
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

	dsn := envOr("DATABASE_URL", "postgres://localhost:5432/agronomy_service?sslmode=disable")
	kafkaBroker := os.Getenv("KAFKA_BROKER")
	port := envOr("PORT", "8080")

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

	// ── Auto-migrate ─────────────────────────────────────────────────────
	migrateCtx, migrateCancel := context.WithTimeout(context.Background(), 5*time.Minute)
	defer migrateCancel()
	if err := migrate.Up(migrateCtx, pool, os.DirFS(envOr("MIGRATIONS_DIR", "migrations")), zapLogger); err != nil {
		log.Fatalf("migration failed: %v", err)
	}

	// ── Kafka producer (optional) ────────────────────────────────────────
	var kafkaProducer sarama.SyncProducer
	if kafkaBroker != "" {
		cfg := sarama.NewConfig()
		cfg.Producer.Return.Successes = true
		kafkaProducer, err = sarama.NewSyncProducer([]string{kafkaBroker}, cfg)
		if err != nil {
			log.Printf("WARNING: failed to create Kafka producer: %v", err)
		} else {
			defer kafkaProducer.Close() //nolint:errcheck
		}
	}

	// ── Service deps ────────────────────────────────────────────────────────
	d := deps.ServiceDeps{
		Pool: pool,
		Log:  logger,
	}

	// Outbox publisher
	outboxPub := outbox.NewPublisher(pool, zapLogger)

	// Repositories
	advisoryRepo := repositories.NewAdvisoryRepository(d)
	inspectionRepo := repositories.NewInspectionRepository(d)

	// Application services
	advisorySvc := services.NewAdvisoryService(d, advisoryRepo, outboxPub)
	inspectionSvc := services.NewInspectionService(d, inspectionRepo, outboxPub)

	// Handlers
	advisoryHandler := handlers.NewAdvisoryHandler(d, advisorySvc)
	inspectionHandler := handlers.NewInspectionHandler(d, inspectionSvc)

	// ── ConnectRPC middleware ────────────────────────────────────────────────
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

	mux := http.NewServeMux()
	const serviceName = "agronomy-service"

	// Register AdvisoryService handler
	advisoryPath, advisorySvcHandler := v1connect.NewAdvisoryServiceHandler(advisoryHandler,
		connect.WithInterceptors(
			middleware.MetricsInterceptor(serviceName),
			middleware.TracingInterceptor(serviceName),
		),
		connectOpt,
	)
	mux.Handle(advisoryPath, advisorySvcHandler)

	// Register InspectionService handler
	inspectionPath, inspectionSvcHandler := v1connect.NewInspectionServiceHandler(inspectionHandler,
		connect.WithInterceptors(
			middleware.MetricsInterceptor(serviceName),
			middleware.TracingInterceptor(serviceName),
		),
		connectOpt,
	)
	mux.Handle(inspectionPath, inspectionSvcHandler)

	// ── Health / readiness ──────────────────────────────────────────────────
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

	serverCfg := connectserver.DefaultServerConfig(port)
	wrapped := connectserver.WrapAll(mux, serverCfg)
	srv := connectserver.NewHTTPServer(serverCfg, wrapped)

	// ── Outbox relay (background) ────────────────────────────────────────
	relayCtx, relayCancel := context.WithCancel(context.Background())
	defer relayCancel()
	if kafkaProducer != nil {
		relay := outbox.NewRelay(pool, outbox.NewKafkaForwarder(kafkaProducer), zapLogger)
		go relay.Run(relayCtx)
	}

	// ── Start server ────────────────────────────────────────────────────────
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)

	go func() {
		p9log.NewHelper(logger).Infow("msg", "agronomy-service starting", "port", port)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("server error: %v", err)
		}
	}()

	<-quit
	p9log.NewHelper(logger).Infow("msg", "shutting down agronomy-service")

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
