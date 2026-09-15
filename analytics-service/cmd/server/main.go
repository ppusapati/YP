// Package main wires all analytics-service layers together and starts the HTTP server.
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
	"go.uber.org/zap"

	"p9e.in/samavaya/packages/authz"
	connectserver "p9e.in/samavaya/packages/connect/server"
	"p9e.in/samavaya/packages/connect/interceptors"
	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/middleware"
	"p9e.in/samavaya/packages/p9log"

	"p9e.in/samavaya/agriculture/analytics-service/api/v1/v1connect"
	"p9e.in/samavaya/agriculture/analytics-service/internal/handlers"
	"p9e.in/samavaya/agriculture/analytics-service/internal/services"
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

	// ── Service deps (stateless — no database pool) ─────────────────────────
	d := deps.ServiceDeps{
		Log: logger,
	}

	// Application service
	svc := services.NewAnalyticsService(d)

	// Handler
	handler := handlers.NewAnalyticsHandler(d, svc)

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
	const serviceName = "analytics-service"
	path, svcHandler := v1connect.NewFieldAnalyticsServiceHandler(handler,
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

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)

	go func() {
		p9log.NewHelper(logger).Infow("msg", "analytics-service starting", "port", port)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("server error: %v", err)
		}
	}()

	<-quit
	p9log.NewHelper(logger).Infow("msg", "shutting down analytics-service")

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
