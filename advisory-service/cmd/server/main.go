// Package main wires advisory-service's layers together and starts the server.
package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"strconv"
	"syscall"
	"time"

	"connectrpc.com/connect"
	"github.com/IBM/sarama"
	"github.com/jackc/pgx/v5/pgxpool"
	"go.uber.org/zap"

	"p9e.in/samavaya/packages/authz"
	"p9e.in/samavaya/packages/connect/interceptors"
	connectserver "p9e.in/samavaya/packages/connect/server"
	"p9e.in/samavaya/packages/database/migrate"
	"p9e.in/samavaya/packages/featureflags"
	"p9e.in/samavaya/packages/middleware"
	"p9e.in/samavaya/packages/p9log"

	"p9e.in/samavaya/agriculture/advisory-service/api/v1/advisoryv1connect"
	grpcadapter "p9e.in/samavaya/agriculture/advisory-service/internal/adapters/inbound/grpc"
	"p9e.in/samavaya/agriculture/advisory-service/internal/adapters/outbound/embedding"
	kafkaadapter "p9e.in/samavaya/agriculture/advisory-service/internal/adapters/outbound/kafka"
	"p9e.in/samavaya/agriculture/advisory-service/internal/adapters/outbound/llm"
	postgresadapter "p9e.in/samavaya/agriculture/advisory-service/internal/adapters/outbound/postgres"
	"p9e.in/samavaya/agriculture/advisory-service/internal/adapters/outbound/tools"
	"p9e.in/samavaya/agriculture/advisory-service/internal/application"
	"p9e.in/samavaya/agriculture/advisory-service/internal/domain"
	"p9e.in/samavaya/agriculture/advisory-service/internal/ports/outbound"
)

const serviceName = "advisory-service"

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

	dsn := envOr("DATABASE_URL", "postgres://localhost:5432/advisory_service?sslmode=disable")
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

	// The first migration creates the pgvector extension and fails if it is
	// not available. That failure is deliberate and is not worth working
	// around: a service that starts against a database with no vector support
	// would accept documents, answer questions and retrieve nothing relevant —
	// healthy from the outside and useless from the inside.
	migrateCtx, migrateCancel := context.WithTimeout(context.Background(), 5*time.Minute)
	defer migrateCancel()
	if err := migrate.Up(migrateCtx, pool, os.DirFS(envOr("MIGRATIONS_DIR", "migrations")), zapLogger); err != nil {
		log.Fatalf("migration failed (advisory-service needs a PostgreSQL with pgvector): %v", err)
	}

	var kafkaProducer sarama.SyncProducer
	if kafkaBroker != "" {
		cfg := sarama.NewConfig()
		cfg.Producer.Return.Successes = true
		kafkaProducer, err = sarama.NewSyncProducer([]string{kafkaBroker}, cfg)
		if err != nil {
			// A warning rather than a fatal: the assistant answers without
			// Kafka. What is lost is the review_required event an agronomist's
			// queue subscribes to, which the log says out loud.
			log.Printf("WARNING: failed to create Kafka producer: %v", err)
		} else {
			defer kafkaProducer.Close() //nolint:errcheck
		}
	}

	embedder := buildEmbedder(helper)
	llmClient := buildLLM(helper)
	clients := tools.NewClients(tools.Endpoints{
		FieldURL:        os.Getenv("FIELD_SERVICE_URL"),
		YieldURL:        os.Getenv("YIELD_SERVICE_URL"),
		IrrigationURL:   os.Getenv("IRRIGATION_SERVICE_URL"),
		PestURL:         os.Getenv("PEST_PREDICTION_SERVICE_URL"),
		WeatherURL:      os.Getenv("WEATHER_SERVICE_URL"),
		AlertURL:        os.Getenv("ALERT_SERVICE_URL"),
		PrescriptionURL: os.Getenv("PRESCRIPTION_SERVICE_URL"),
		DiagnosisURL:    os.Getenv("PLANT_DIAGNOSIS_SERVICE_URL"),
	})
	registry := clients.Registry()

	toolNames := make([]string, 0, len(registry))
	for _, t := range registry {
		toolNames = append(toolNames, t.Name())
	}

	// Said at startup, every time, because these three lines are the
	// difference between an assistant that answers from this farm's data and
	// one that quotes a crop guide. Every one of them is a silent degradation
	// otherwise: the service starts, serves, and answers worse.
	helper.Infow("msg", "advisory retrieval configured", "embedder", embedder.Name(), "dim", embedder.Dim())
	if llmClient == nil {
		helper.Infow("msg", "no language model configured; answers will be extractive quotations "+
			"from the retrieved passages and will say so")
	} else {
		helper.Infow("msg", "language model configured", "model", llmClient.Model())
	}
	helper.Infow("msg", "advisory tools available", "count", len(registry), "tools", toolNames)

	svc := application.NewAdvisoryService(application.Deps{
		Conversations: postgresadapter.NewConversationRepository(pool, logger),
		Documents:     postgresadapter.NewDocumentRepository(pool, logger),
		Budgets:       postgresadapter.NewBudgetRepository(pool, logger),
		Embedder:      embedder,
		LLM:           llmClient,
		Tools:         registry,
		FarmContext:   tools.NewFarmContextSource(clients, logger),
		KillSwitch:    buildKillSwitch(helper),
		Publisher:     kafkaadapter.NewEventPublisher(kafkaProducer, logger),
		Config:        buildConfig(),
	}, logger)

	handler := grpcadapter.NewAdvisoryHandler(svc, logger)

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
	path, advisoryHandler := advisoryv1connect.NewAdvisoryServiceHandler(handler,
		connect.WithInterceptors(
			middleware.MetricsInterceptor(serviceName),
			middleware.TracingInterceptor(serviceName),
		),
		connectOpt,
	)
	mux.Handle(path, advisoryHandler)

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

// buildEmbedder picks the hosted embedder when one is configured.
//
// Falls back to the local lexical embedder rather than to nothing. The
// fallback is visibly worse and is named as such in the log and on every
// document row it indexes, which is the difference between a known limitation
// and a mystery.
func buildEmbedder(helper *p9log.Helper) outbound.Embedder {
	dim := envInt("EMBEDDING_DIM", domain.DefaultEmbeddingDim)

	url := os.Getenv("EMBEDDING_URL")
	if url == "" {
		return embedding.NewLexicalEmbedder(dim)
	}

	embedder, err := embedding.NewHTTPEmbedder(embedding.HTTPConfig{
		URL:       url,
		APIKey:    os.Getenv("EMBEDDING_API_KEY"),
		Model:     os.Getenv("EMBEDDING_MODEL"),
		Dim:       dim,
		BatchSize: envInt("EMBEDDING_BATCH_SIZE", 32),
	})
	if err != nil {
		helper.Errorw("msg", "EMBEDDING_URL is set but the embedder could not be built; "+
			"falling back to lexical retrieval", "error", err)
		return embedding.NewLexicalEmbedder(dim)
	}
	return embedder
}

// buildLLM returns nil when no model is configured.
//
// nil is a supported state, not a failure. Everything except the generated
// prose still runs, and the answer says it was assembled rather than written.
func buildLLM(helper *p9log.Helper) outbound.LLMClient {
	apiKey := os.Getenv("ADVISORY_LLM_API_KEY")
	model := os.Getenv("ADVISORY_LLM_MODEL")
	if apiKey == "" || model == "" {
		return nil
	}

	client, err := llm.NewAnthropicClient(llm.Config{
		BaseURL:     envOr("ADVISORY_LLM_BASE_URL", llm.DefaultBaseURL),
		APIKey:      apiKey,
		Model:       model,
		MaxTokens:   envInt("ADVISORY_LLM_MAX_TOKENS", 1024),
		Temperature: envFloat("ADVISORY_LLM_TEMPERATURE", 0),
		Timeout:     time.Duration(envInt("ADVISORY_LLM_TIMEOUT_SECONDS", 30)) * time.Second,
		// Prices are configuration rather than a table compiled in here: they
		// change, they differ per contract, and a stale constant would enforce
		// a budget against a figure that no longer matches the invoice. Left
		// unset, an exchange is costed at zero and only the question limit
		// bites — which the startup log below says out loud.
		Price: domain.ModelPrice{
			InputMicrosPerMillion:  int64(envInt("ADVISORY_LLM_INPUT_MICROS_PER_MTOK", 0)),
			OutputMicrosPerMillion: int64(envInt("ADVISORY_LLM_OUTPUT_MICROS_PER_MTOK", 0)),
		},
	})
	if err != nil {
		helper.Errorw("msg", "the advisory model is configured but could not be built; "+
			"answers will be extractive", "error", err)
		return nil
	}

	if client.Price().InputMicrosPerMillion == 0 && client.Price().OutputMicrosPerMillion == 0 {
		helper.Warnw("msg", "no token prices configured — every exchange will be costed at zero "+
			"and only the daily question limit will bound spend. Set "+
			"ADVISORY_LLM_INPUT_MICROS_PER_MTOK and ADVISORY_LLM_OUTPUT_MICROS_PER_MTOK.")
	}
	return client
}

// buildKillSwitch gates the generative path behind a feature flag.
//
// The flag is registered enabled by default before any config file is read,
// because the flag service treats an unknown flag as disabled — so relying on
// the file alone would leave the assistant permanently extractive in every
// deployment that has no flag configuration, with nothing to say why.
func buildKillSwitch(helper *p9log.Helper) *featureflags.KillSwitch {
	flags := featureflags.NewInMemoryFlagService()
	flags.SetFlag(featureflags.Flag{
		Name:        application.FlagAdvisoryLLM,
		Description: "Generative advisory answers. Off falls back to extractive retrieval.",
		Type:        featureflags.FlagTypeKillSwitch,
		Enabled:     true,
	})

	if path := os.Getenv("FEATURE_FLAGS_FILE"); path != "" {
		if err := flags.LoadFromJSON(path); err != nil {
			helper.Warnw("msg", "could not load the feature flag file; using defaults",
				"path", path, "error", err)
		} else if flags.GetFlag(application.FlagAdvisoryLLM) == nil {
			// The file replaced the flag set and did not mention this flag.
			// Re-registered rather than left absent, so an unrelated flag file
			// cannot silently switch the assistant to extractive answers.
			flags.SetFlag(featureflags.Flag{
				Name:    application.FlagAdvisoryLLM,
				Type:    featureflags.FlagTypeKillSwitch,
				Enabled: true,
			})
		}
	}

	// FF_ADVISORY_LLM=disabled is the operator's immediate off switch.
	cfg := &featureflags.FlagConfig{Flags: flags.ListFlags(context.Background())}
	featureflags.LoadFlagsFromEnv(cfg)
	flags.ReplaceAll(cfg.Flags)

	if f := flags.GetFlag(application.FlagAdvisoryLLM); f != nil && !f.Enabled {
		helper.Warnw("msg", "the advisory language model is switched off by feature flag; "+
			"answers will be extractive")
	}
	return featureflags.NewKillSwitch(application.FlagAdvisoryLLM, flags)
}

func buildConfig() application.Config {
	cfg := application.DefaultConfig()
	cfg.MaxToolIterations = envInt("ADVISORY_MAX_TOOL_ITERATIONS", cfg.MaxToolIterations)
	cfg.HistoryTurns = envInt("ADVISORY_HISTORY_TURNS", cfg.HistoryTurns)
	cfg.RetrievalLimit = envInt("ADVISORY_RETRIEVAL_LIMIT", cfg.RetrievalLimit)
	cfg.MaxAnswerTokens = envInt("ADVISORY_MAX_ANSWER_TOKENS", cfg.MaxAnswerTokens)
	return cfg
}

func envOr(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

func envInt(key string, fallback int) int {
	v := os.Getenv(key)
	if v == "" {
		return fallback
	}
	parsed, err := strconv.Atoi(v)
	if err != nil {
		// The default rather than a crash, and said out loud. A typo in one
		// tuning variable should not stop a service from starting.
		log.Printf("WARNING: %s=%q is not a number; using %d", key, v, fallback)
		return fallback
	}
	return parsed
}

func envFloat(key string, fallback float64) float64 {
	v := os.Getenv(key)
	if v == "" {
		return fallback
	}
	parsed, err := strconv.ParseFloat(v, 64)
	if err != nil {
		log.Printf("WARNING: %s=%q is not a number; using %v", key, v, fallback)
		return fallback
	}
	return parsed
}
