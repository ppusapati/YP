// Package main wires finance-service's layers together and starts the server.
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
	"go.uber.org/zap"

	"p9e.in/samavaya/packages/authz"
	connectclient "p9e.in/samavaya/packages/connect/client"
	"p9e.in/samavaya/packages/connect/interceptors"
	connectserver "p9e.in/samavaya/packages/connect/server"
	"p9e.in/samavaya/packages/database/migrate"
	"p9e.in/samavaya/packages/database/rlspool"
	"p9e.in/samavaya/packages/middleware"
	"p9e.in/samavaya/packages/p9log"

	"p9e.in/samavaya/agriculture/finance-service/api/v1/financev1connect"
	grpcadapter "p9e.in/samavaya/agriculture/finance-service/internal/adapters/inbound/grpc"
	clientsadapter "p9e.in/samavaya/agriculture/finance-service/internal/adapters/outbound/clients"
	kafkaadapter "p9e.in/samavaya/agriculture/finance-service/internal/adapters/outbound/kafka"
	postgresadapter "p9e.in/samavaya/agriculture/finance-service/internal/adapters/outbound/postgres"
	"p9e.in/samavaya/agriculture/finance-service/internal/application"
	"p9e.in/samavaya/agriculture/finance-service/internal/ports/outbound"
)

const serviceName = "finance-service"

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

	dsn := envOr("DATABASE_URL", "postgres://localhost:5432/finance_service?sslmode=disable")
	kafkaBroker := os.Getenv("KAFKA_BROKER")
	port := envOr("PORT", "8080")
	yieldServiceURL := os.Getenv("YIELD_SERVICE_URL")
	satelliteServiceURL := os.Getenv("SATELLITE_SERVICE_URL")
	weatherServiceURL := os.Getenv("WEATHER_SERVICE_URL")

	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()

	pool, err := rlspool.New(ctx, dsn)
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
			// A warning rather than a fatal: quoting, scoring and claims all
			// work without Kafka. What is lost is the claim-filed event an
			// insurer's queue listens for, which the log says plainly.
			log.Printf("WARNING: failed to create Kafka producer: %v", err)
		} else {
			defer kafkaProducer.Close() //nolint:errcheck
		}
	}

	// One postgres type serves all three repository ports. Quotes, credit
	// assessments and claims are read together — a claim is assessed against
	// the quote it was written on — and splitting them would buy nothing but
	// three pools.
	repo := postgresadapter.NewRepository(pool, logger)
	pub := kafkaadapter.NewEventPublisher(kafkaProducer, logger)

	// yield-service is what everything here rests on: without it a quote is
	// priced from a crop benchmark and a credit assessment cannot be produced
	// at all. Left nil when unset, and the service says which it is rather
	// than quietly benchmarking everything as though it had looked.
	var yieldClient outbound.YieldClient
	if yieldServiceURL != "" {
		yieldClient = clientsadapter.NewYieldClient(yieldServiceURL,
			connectclient.NewHTTPClient(connectclient.DefaultConfig(yieldServiceURL)),
			connect.WithInterceptors(connectclient.ContextPropagator()))
	} else {
		helper.Warnw("msg", "YIELD_SERVICE_URL is not set: quotes will be priced from "+
			"crop benchmarks and credit assessments will be refused")
	}

	// Both claim-evidence sources are optional. A missing one produces an
	// INCONCLUSIVE entry in the pack rather than a silently shorter pack: a
	// pack with no satellite entry looks like one nobody bothered to build,
	// while one that says why is a fact about the claim.
	var satelliteClient outbound.SatelliteClient
	if satelliteServiceURL != "" {
		satelliteClient = clientsadapter.NewSatelliteClient(satelliteServiceURL,
			connectclient.NewHTTPClient(connectclient.DefaultConfig(satelliteServiceURL)),
			connect.WithInterceptors(connectclient.ContextPropagator()))
	}

	var weatherClient outbound.WeatherClient
	if weatherServiceURL != "" {
		weatherClient = clientsadapter.NewWeatherClient(weatherServiceURL,
			connectclient.NewHTTPClient(connectclient.DefaultConfig(weatherServiceURL)),
			connect.WithInterceptors(connectclient.ContextPropagator()))
	}

	svc := application.NewFinanceService(repo, repo, repo,
		yieldClient, satelliteClient, weatherClient, pub, logger)
	handler := grpcadapter.NewFinanceHandler(svc, logger)

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
	path, financeHandler := financev1connect.NewFinanceServiceHandler(handler,
		connect.WithInterceptors(
			middleware.MetricsInterceptor(serviceName),
			middleware.TracingInterceptor(serviceName),
		),
		connectOpt,
	)
	mux.Handle(path, financeHandler)

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
