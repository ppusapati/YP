// Package main serves the platform's real-time transport: /ws and /events.
//
// This replaces cmd/monolith, which served the same two endpoints alongside a
// second copy of twenty-two services.
//
// The monolith existed because Go will not let a package outside a directory
// import that directory's `internal/`, so wiring services into one binary
// meant keeping a duplicate of each one outside its `internal/` tree. Twenty-two
// services carried that duplicate and fifteen of them had drifted: the
// monolith's yield-service had no weather client, its irrigation-service had no
// AI adapter and no actuator, and its field and traceability services were a
// whole architecture generation behind — no Kafka consumer, no repository. It
// was built and pushed by CD and offered in DEPLOYMENT.md, so the stale copy
// was shipped.
//
// The single-binary deployment it promised is already served better by
// docker-compose, which runs all thirty-one services on one host rather than
// twenty-two stale ones. What was *not* replaceable was this: the hub, the SSE
// broker, the Kafka bridge and the routing middleware were all written and
// nothing else mounts any of them. `/ws` and `/events` existed only here, and
// the live field map and collaborative inspection ride on them.
//
// So the services are gone and the transport stays, in a binary whose name says
// what it does. It needs no database: the hub, broker, presence and session
// store are all in memory, and durable state belongs to the services that own it.
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

	"p9e.in/samavaya/packages/authz"
	connectserver "p9e.in/samavaya/packages/connect/server"
	"p9e.in/samavaya/packages/p9log"
)

func main() {
	zapLogger, err := zap.NewProduction()
	if err != nil {
		log.Fatalf("failed to create logger: %v", err)
	}
	defer zapLogger.Sync() //nolint:errcheck
	logger := p9log.NewLogger(zapLogger)
	helper := p9log.NewHelper(logger)

	// Refused rather than defaulted. A WebSocket carries a tenant's live
	// machine positions, and an unauthenticated upgrade would stream one
	// tenant's tractors to anyone who connected.
	if err := authz.InitJWTFromEnv(); err != nil {
		log.Fatalf("JWT not configured: %v — refusing to start without authentication", err)
	}

	port := envOr("PORT", "8080")

	mux := http.NewServeMux()

	rtCtx, rtCancel := context.WithCancel(context.Background())
	defer rtCancel()
	// Assigned and not otherwise used: the module registers its own handlers on
	// the mux and its background sweep stops when rtCtx is cancelled. It is
	// returned so a caller that publishes through the hub can hold it, which is
	// what the monolith did; nothing in this process publishes.
	_ = registerRealtimeModule(rtCtx, mux, logger)

	mux.HandleFunc("/health", func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte(`{"status":"ok"}`))
	})

	// Readiness is liveness here, deliberately. This process has no database
	// and no downstream dependency: once it is listening it can accept a
	// connection. A /ready that pinged something it does not use would take the
	// transport out of the load balancer for a fault it is unaffected by.
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
		helper.Infow("msg", "realtime transport starting", "port", port,
			"endpoints", "/ws, /events")
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("server error: %v", err)
		}
	}()

	<-quit
	helper.Infow("msg", "shutting down realtime transport")

	// Cancel first, then shut the server down: cancelling stops the presence
	// sweep and lets the hub close its connections, where shutting the listener
	// first would cut them mid-frame.
	rtCancel()

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
