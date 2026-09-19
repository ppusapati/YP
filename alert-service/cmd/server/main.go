// Package main wires all alert-service layers together and starts the HTTP server.
package main

import (
	"context"
	"encoding/json"
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
	"p9e.in/samavaya/packages/database/migrate"
	"p9e.in/samavaya/packages/deps"
	kafkaconfig "p9e.in/samavaya/packages/events/config"
	kafkaconsumer "p9e.in/samavaya/packages/events/consumer"
	eventsdomain "p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/middleware"
	"p9e.in/samavaya/packages/p9log"

	"p9e.in/samavaya/agriculture/alert-service/api/v1/v1connect"
	"p9e.in/samavaya/agriculture/alert-service/internal/ai"
	alertevents "p9e.in/samavaya/agriculture/alert-service/internal/events"
	"p9e.in/samavaya/agriculture/alert-service/internal/handlers"
	"p9e.in/samavaya/agriculture/alert-service/internal/repositories"
	"p9e.in/samavaya/agriculture/alert-service/internal/scheduler"
	"p9e.in/samavaya/agriculture/alert-service/internal/services"
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

	port := envOr("PORT", "8080")
	aiGatewayAddr := envOr("AI_GATEWAY_ADDR", "localhost:9090")
	kafkaBroker := os.Getenv("KAFKA_BROKER")

	dsn := os.Getenv("DATABASE_URL")
	if dsn == "" {
		log.Fatal("DATABASE_URL is required")
	}

	ctx := context.Background()
	pool, err := pgxpool.New(ctx, dsn)
	if err != nil {
		log.Fatalf("failed to create database pool: %v", err)
	}
	defer pool.Close()
	if err := pool.Ping(ctx); err != nil {
		log.Fatalf("database not reachable: %v", err)
	}

	migrateCtx, migrateCancel := context.WithTimeout(context.Background(), 5*time.Minute)
	defer migrateCancel()
	if err := migrate.Up(migrateCtx, pool, os.DirFS(envOr("MIGRATIONS_DIR", "migrations")), zapLogger); err != nil {
		log.Fatalf("migrations failed: %v", err)
	}

	// ── AI Client (optional) ────────────────────────────────────────────────
	logHelper := p9log.NewHelper(p9log.With(logger, "component", "ai_client"))
	aiClient, err := ai.NewAIClient(aiGatewayAddr, logHelper)
	if err != nil {
		log.Printf("WARNING: failed to create AI client: %v", err)
	}

	d := deps.ServiceDeps{
		Log:  logger,
		Pool: pool,
	}

	// Application service
	repo := repositories.NewAlertRepository(pool, logger)
	svc := services.NewAlertService(d, repo, aiClient)

	// Handler
	handler := handlers.NewAlertHandler(d, svc)

	mwCfg := connectserver.MiddlewareConfig{
		EnableRecovery:  true,
		EnableRequestID: true,
		EnableLogging:   true,
		EnableAuth:      true,
		JWTValidator:    jwtValidator,
		EnableAuthz:     true,
		EnableRLS:       true,
		RLSLevel:        interceptors.ScopeLevelTenant,
	}
	connectOpt := connectserver.NewConnectOption(mwCfg)

	mux := http.NewServeMux()
	const serviceName = "alert-service"
	path, svcHandler := v1connect.NewAlertServiceHandler(handler,
		connect.WithInterceptors(
			middleware.MetricsInterceptor(serviceName),
			middleware.TracingInterceptor(serviceName),
		),
		connectOpt,
	)
	mux.Handle(path, svcHandler)

	mux.HandleFunc("/health", func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte(`{"status":"ok"}`))
	})
	mux.HandleFunc("/ready", func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte(`{"status":"ready"}`))
	})

	serverCfg := connectserver.DefaultServerConfig(port)
	wrapped := connectserver.WrapAll(mux, serverCfg)
	srv := connectserver.NewHTTPServer(serverCfg, wrapped)

	// ── Kafka consumer: alerts raised by other services ─────────────────────
	//
	// Without this the service only holds alerts created through its own API,
	// which is nothing: weather, sensor and pest all raise theirs as events.
	// It is optional so the service still starts in a deployment with no
	// broker — it is then a store with no writer, and says so in the log.
	if kafkaBroker == "" {
		p9log.NewHelper(logger).Warnw("msg",
			"KAFKA_BROKER not set; weather, sensor and pest alerts will not be ingested")
	} else {
		alertConsumer := alertevents.NewAlertConsumer(svc, logger)
		kc := kafkaconsumer.NewKafkaConsumer(&kafkaconfig.KafkaConfig{
			Broker:       kafkaBroker,
			Group:        serviceName,
			KafkaVersion: "3.5.0",
			Assignor:     "sticky",
		}, logger)
		consumerCtx, consumerCancel := context.WithCancel(context.Background())
		defer consumerCancel()
		for _, topic := range alertConsumer.Topics() {
			if err := kc.Subscribe(consumerCtx, topic, func(ctx context.Context, data []byte) error {
				var event eventsdomain.DomainEvent
				if err := json.Unmarshal(data, &event); err != nil {
					// Not returned: a message that will never parse would be
					// retried forever and block the partition for every alert
					// behind it.
					p9log.NewHelper(logger).Errorw("msg", "unparseable event; skipping",
						"topic", topic, "error", err)
					return nil
				}
				return alertConsumer.HandleEvent(ctx, &event)
			}); err != nil {
				log.Printf("WARNING: failed to subscribe to %s: %v", topic, err)
			}
		}
	}

	// ── Rule scanner: the alerts the farmer asked for in advance ────────────
	//
	// The consumer above ingests what other services noticed. This is the
	// other half: rules somebody configured through the web or the app, which
	// nothing evaluated until it was wired here. A rule that is written and
	// never read is worse than no rule, because the farmer believes they will
	// be told.
	//
	// It needs the AI gateway to score a field, so it is skipped when there is
	// no gateway client rather than run against nothing.
	if aiClient == nil {
		p9log.NewHelper(logger).Warnw("msg",
			"AI gateway client unavailable; configured alert rules will not be evaluated")
	} else if interval := scanInterval(); interval > 0 {
		scanner := scheduler.NewRuleScanner(repo, svc, logger)
		scannerCtx, scannerCancel := context.WithCancel(context.Background())
		defer scannerCancel()
		go scanner.Run(scannerCtx, interval)
	} else {
		p9log.NewHelper(logger).Infow("msg",
			"ALERT_SCAN_INTERVAL is 0; configured alert rules will not be evaluated")
	}

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)

	go func() {
		p9log.NewHelper(logger).Infow("msg", "alert-service starting", "port", port)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("server error: %v", err)
		}
	}()

	<-quit
	p9log.NewHelper(logger).Infow("msg", "shutting down alert-service")

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

// scanInterval reads ALERT_SCAN_INTERVAL as a Go duration. An explicit "0"
// disables the scanner; an unparseable value falls back to the default rather
// than stopping the service, but says so, since the alternative is a
// deployment that refuses to start over a typo in an optional knob.
func scanInterval() time.Duration {
	raw := os.Getenv("ALERT_SCAN_INTERVAL")
	if raw == "" {
		return scheduler.DefaultInterval
	}
	d, err := time.ParseDuration(raw)
	if err != nil {
		log.Printf("WARNING: ALERT_SCAN_INTERVAL=%q is not a duration; using %s", raw, scheduler.DefaultInterval)
		return scheduler.DefaultInterval
	}
	return d
}
