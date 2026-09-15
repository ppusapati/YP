// Package main wires planning-service's layers together and starts the server.
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
	connectclient "p9e.in/samavaya/packages/connect/client"
	"p9e.in/samavaya/packages/connect/interceptors"
	connectserver "p9e.in/samavaya/packages/connect/server"
	"p9e.in/samavaya/packages/database/migrate"
	"p9e.in/samavaya/packages/middleware"
	"p9e.in/samavaya/packages/p9log"

	"p9e.in/samavaya/agriculture/planning-service/api/v1/planningv1connect"
	grpcadapter "p9e.in/samavaya/agriculture/planning-service/internal/adapters/inbound/grpc"
	clientsadapter "p9e.in/samavaya/agriculture/planning-service/internal/adapters/outbound/clients"
	kafkaadapter "p9e.in/samavaya/agriculture/planning-service/internal/adapters/outbound/kafka"
	postgresadapter "p9e.in/samavaya/agriculture/planning-service/internal/adapters/outbound/postgres"
	"p9e.in/samavaya/agriculture/planning-service/internal/application"
	"p9e.in/samavaya/agriculture/planning-service/internal/ports/outbound"
)

const serviceName = "planning-service"

func main() {
	zapLogger, err := zap.NewProduction()
	if err != nil {
		log.Fatalf("failed to create logger: %v", err)
	}
	defer zapLogger.Sync() //nolint:errcheck
	logger := p9log.NewLogger(zapLogger)
	helper := p9log.NewHelper(logger)

	if err := authz.InitJWTFromEnv(); err != nil {
		log.Fatalf("JWT not configured: %v — refusing to start without authentication", err)
	}
	jwtValidator := interceptors.NewAuthzJWTValidator()

	dsn := envOr("DATABASE_URL", "postgres://localhost:5432/planning_service?sslmode=disable")
	kafkaBroker := os.Getenv("KAFKA_BROKER")
	port := envOr("PORT", "8080")
	weatherServiceURL := os.Getenv("WEATHER_SERVICE_URL")

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

	migrateCtx, migrateCancel := context.WithTimeout(context.Background(), 5*time.Minute)
	defer migrateCancel()
	if err := migrate.Up(migrateCtx, pool, os.DirFS(envOr("MIGRATIONS_DIR", "migrations")), zapLogger); err != nil {
		log.Fatalf("migration failed: %v", err)
	}

	var kafkaProducer sarama.SyncProducer
	if kafkaBroker != "" {
		cfg := sarama.NewConfig()
		cfg.Producer.Return.Successes = true
		kafkaProducer, err = sarama.NewSyncProducer([]string{kafkaBroker}, cfg)
		if err != nil {
			// A warning rather than a fatal: planning works without Kafka. What
			// is lost is the plan.committed event that procurement and advisory
			// listen for, which the log says out loud.
			log.Printf("WARNING: failed to create Kafka producer: %v", err)
		} else {
			defer kafkaProducer.Close() //nolint:errcheck
		}
	}

	repo := postgresadapter.NewPlanRepository(pool, logger)
	pub := kafkaadapter.NewEventPublisher(kafkaProducer, logger)

	// The weather client is optional, and left nil when WEATHER_SERVICE_URL is
	// unset. Without it a sowing window comes from the crop calendar and says
	// so in its basis; with it the window follows the monsoon's local onset,
	// which is what actually decides when a kharif crop goes in. A deployment
	// that has no weather-service still plans — it just plans with less.
	var weatherClient outbound.WeatherClient
	if weatherServiceURL != "" {
		weatherClient = clientsadapter.NewWeatherClient(weatherServiceURL,
			connectclient.NewHTTPClient(connectclient.DefaultConfig(weatherServiceURL)),
			connect.WithInterceptors(connectclient.ContextPropagator()))
	} else {
		helper.Infow("msg", "WEATHER_SERVICE_URL is not set; sowing windows will come "+
			"from the crop calendar rather than this field's rainfall history")
	}

	svc := application.NewPlanningService(repo, weatherClient, pub, logger)
	handler := grpcadapter.NewPlanningHandler(svc, logger)

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
	path, planningHandler := planningv1connect.NewPlanningServiceHandler(handler,
		connect.WithInterceptors(
			middleware.MetricsInterceptor(serviceName),
			middleware.TracingInterceptor(serviceName),
		),
		connectOpt,
	)
	mux.Handle(path, planningHandler)

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

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)

	go func() {
		helper.Infow("msg", serviceName+" starting", "port", port)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("server error: %v", err)
		}
	}()

	<-quit
	helper.Infow("msg", "shutting down "+serviceName)

	shutCtx, shutCancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer shutCancel()
	if err := srv.Shutdown(shutCtx); err != nil {
		log.Printf("graceful shutdown failed: %v", err)
	}
}

func envOr(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
