// Package main wires all weather-service layers together and starts the HTTP server.
package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"strings"
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
	kafkaconfig "p9e.in/samavaya/packages/events/config"
	kafkaconsumer "p9e.in/samavaya/packages/events/consumer"
	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/middleware"
	"p9e.in/samavaya/packages/outbox"
	"p9e.in/samavaya/packages/p9log"

	"p9e.in/samavaya/agriculture/weather-service/api/v1/weatherv1connect"
	eventsadapter "p9e.in/samavaya/agriculture/weather-service/internal/adapters/inbound/events"
	grpcadapter "p9e.in/samavaya/agriculture/weather-service/internal/adapters/inbound/grpc"
	clientsadapter "p9e.in/samavaya/agriculture/weather-service/internal/adapters/outbound/clients"
	kafkaadapter "p9e.in/samavaya/agriculture/weather-service/internal/adapters/outbound/kafka"
	postgresadapter "p9e.in/samavaya/agriculture/weather-service/internal/adapters/outbound/postgres"
	"p9e.in/samavaya/agriculture/weather-service/internal/adapters/outbound/providers"
	"p9e.in/samavaya/agriculture/weather-service/internal/application"
	wdomain "p9e.in/samavaya/agriculture/weather-service/internal/domain"
	"p9e.in/samavaya/agriculture/weather-service/internal/ports/outbound"
)

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

	dsn := envOr("DATABASE_URL", "postgres://localhost:5432/weather_service?sslmode=disable")
	kafkaBroker := os.Getenv("KAFKA_BROKER")
	port := envOr("PORT", "8080")
	fieldServiceURL := envOr("FIELD_SERVICE_URL", "http://localhost:8082")
	pollInterval, err := time.ParseDuration(envOr("WEATHER_POLL_INTERVAL", "1h"))
	if err != nil {
		log.Fatalf("invalid WEATHER_POLL_INTERVAL: %v", err)
	}

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
			log.Printf("WARNING: failed to create Kafka producer: %v", err)
		} else {
			defer kafkaProducer.Close() //nolint:errcheck
		}
	}

	// ── Providers ────────────────────────────────────────────────────────
	registry := buildProviderRegistry()
	helper.Infow("msg", "weather providers configured", "default", string(registry.Default()))

	// ── Hexagonal wiring ─────────────────────────────────────────────────
	repo := postgresadapter.NewWeatherRepository(pool, logger)
	outboxPub := outbox.NewPublisher(pool, zapLogger)
	kafkaPub := kafkaadapter.NewEventPublisher(kafkaProducer, logger)
	fieldClient := clientsadapter.NewFieldClient(fieldServiceURL,
		connectclient.NewHTTPClient(connectclient.DefaultConfig(fieldServiceURL)),
		connect.WithInterceptors(connectclient.ContextPropagator()))
	svc := application.NewWeatherService(repo, registry, outboxPub, fieldClient, logger)
	handler := grpcadapter.NewWeatherHandler(svc, logger)

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
	const serviceName = "weather-service"
	path, weatherHandler := weatherv1connect.NewWeatherServiceHandler(handler,
		connect.WithInterceptors(
			middleware.MetricsInterceptor(serviceName),
			middleware.TracingInterceptor(serviceName),
		),
		connectOpt,
	)
	mux.Handle(path, weatherHandler)

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
	relay := outbox.NewRelay(pool, kafkaPub, zapLogger)
	go relay.Run(relayCtx)

	// ── Hourly poller (background) ───────────────────────────────────────
	pollCtx, pollCancel := context.WithCancel(context.Background())
	defer pollCancel()
	go func() {
		ticker := time.NewTicker(pollInterval)
		defer ticker.Stop()
		if err := svc.RefreshAll(pollCtx); err != nil {
			helper.Warnw("msg", "initial weather refresh had failures", "error", err)
		}
		for {
			select {
			case <-pollCtx.Done():
				return
			case <-ticker.C:
				if err := svc.RefreshAll(pollCtx); err != nil {
					helper.Warnw("msg", "scheduled weather refresh had failures", "error", err)
				}
			}
		}
	}()

	// ── Kafka event consumer (background) ────────────────────────────────
	if kafkaBroker != "" {
		eventConsumer := eventsadapter.NewWeatherConsumer(svc, logger)
		kc := kafkaconsumer.NewKafkaConsumer(&kafkaconfig.KafkaConfig{
			Broker:       kafkaBroker,
			Group:        serviceName,
			KafkaVersion: "3.5.0",
			Assignor:     "sticky",
		}, logger)
		consumerCtx, consumerCancel := context.WithCancel(context.Background())
		defer consumerCancel()
		for _, topic := range eventConsumer.Topics() {
			if err := kc.Subscribe(consumerCtx, topic, func(ctx context.Context, data []byte) error {
				var event domain.DomainEvent
				if err := json.Unmarshal(data, &event); err != nil {
					return fmt.Errorf("unmarshal domain event: %w", err)
				}
				return eventConsumer.HandleEvent(ctx, &event)
			}); err != nil {
				log.Printf("WARNING: failed to subscribe to %s: %v", topic, err)
			}
		}
	}

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)

	go func() {
		helper.Infow("msg", "weather-service starting", "port", port, "poll_interval", pollInterval.String())
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("server error: %v", err)
		}
	}()

	<-quit
	helper.Infow("msg", "shutting down weather-service")

	shutCtx, shutCancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer shutCancel()
	if err := srv.Shutdown(shutCtx); err != nil {
		log.Printf("graceful shutdown error: %v", err)
	}
}

// buildProviderRegistry orders providers so WEATHER_DEFAULT_PROVIDER wins;
// Open-Meteo is always present because it needs no API key and serves backfill.
func buildProviderRegistry() *providers.Registry {
	httpClient := &http.Client{Timeout: 20 * time.Second}
	openMeteo := providers.NewOpenMeteo(httpClient, os.Getenv("OPEN_METEO_FORECAST_URL"), os.Getenv("OPEN_METEO_ARCHIVE_URL"))

	var openWeather outbound.WeatherProvider
	if key := os.Getenv("OPENWEATHER_API_KEY"); key != "" {
		openWeather = providers.NewOpenWeather(httpClient, os.Getenv("OPENWEATHER_BASE_URL"), key)
	}

	switch strings.ToUpper(envOr("WEATHER_DEFAULT_PROVIDER", string(wdomain.ProviderOpenMeteo))) {
	case string(wdomain.ProviderOpenWeather):
		if openWeather != nil {
			return providers.NewRegistry(openWeather, openMeteo)
		}
		log.Printf("WARNING: WEATHER_DEFAULT_PROVIDER=OPENWEATHER but OPENWEATHER_API_KEY is unset; falling back to Open-Meteo")
	}
	return providers.NewRegistry(openMeteo, openWeather)
}

func envOr(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
