package sse

import (
	"fmt"
	"net/http"
	"strings"

	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"

	"github.com/google/uuid"
)

// HandlerConfig configures the SSE HTTP handler.
type HandlerConfig struct {
	// Broker is the SSE broker that manages subscriptions.
	Broker *Broker
	// Log is the logger.
	Log p9log.Logger
}

// NewHandler returns an http.Handler that streams SSE events to clients.
//
// Clients subscribe by connecting with Accept: text/event-stream and
// optionally passing a "topics" query parameter (comma-separated list).
// Example: GET /events?topics=sensor.field-1,alert.farm-2
//
// The tenant comes from the authenticated request context, never from the
// query string, and each requested topic is scoped to it. A request that
// arrives with no tenant is refused rather than subscribed to everything —
// which is what an empty topic list used to mean.
//
// The handler sets the required SSE response headers and keeps the
// connection open until the client disconnects or the server shuts down.
func NewHandler(cfg HandlerConfig) http.Handler {
	log := p9log.NewHelper(p9log.With(cfg.Log, "module", "sse-handler"))

	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Verify that the response writer supports flushing.
		flusher, ok := w.(http.Flusher)
		if !ok {
			http.Error(w, "streaming unsupported", http.StatusInternalServerError)
			return
		}

		// The tenant is taken from the request context — put there by the auth
		// middleware — and never from anything the client sends. A connection
		// with no tenant cannot be scoped, so it is refused.
		tenantID := p9context.UserTenantID(r.Context())
		if tenantID == "" {
			http.Error(w, "not authenticated", http.StatusUnauthorized)
			return
		}

		// Parse requested topics from query parameter.
		var topics []string
		if raw := r.URL.Query().Get("topics"); raw != "" {
			for _, t := range strings.Split(raw, ",") {
				t = strings.TrimSpace(t)
				if t != "" {
					topics = append(topics, t)
				}
			}
		}

		subscriberID := uuid.New().String()

		// Set SSE headers.
		w.Header().Set("Content-Type", "text/event-stream")
		w.Header().Set("Cache-Control", "no-cache")
		w.Header().Set("Connection", "keep-alive")
		w.Header().Set("X-Accel-Buffering", "no") // Disable nginx buffering.

		// Register with the broker.
		events, cleanup := cfg.Broker.Subscribe(subscriberID, tenantID, topics)
		defer cleanup()

		log.Debugf("SSE client connected: %s (tenant=%s, topics=%v)", subscriberID, tenantID, topics)

		// If the client sent Last-Event-ID, we could resume from there.
		// This is a hook for future implementation with event persistence.
		if lastID := r.Header.Get("Last-Event-ID"); lastID != "" {
			log.Debugf("client %s reconnecting from event %s", subscriberID, lastID)
		}

		// Send an initial comment to flush headers and confirm the connection.
		fmt.Fprintf(w, ": connected\n\n")
		flusher.Flush()

		// Stream events until the client disconnects.
		ctx := r.Context()
		for {
			select {
			case <-ctx.Done():
				log.Debugf("SSE client disconnected: %s", subscriberID)
				return

			case event, ok := <-events:
				if !ok {
					// Broker closed the channel (shutdown).
					return
				}
				data := event.Format()
				if _, err := w.Write(data); err != nil {
					log.Debugf("SSE write error for client %s: %v", subscriberID, err)
					return
				}
				flusher.Flush()
			}
		}
	})
}
