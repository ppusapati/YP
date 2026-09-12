// Package realtime provides HTTP middleware that detects WebSocket upgrade
// requests and SSE (Accept: text/event-stream) requests and routes them to
// the appropriate real-time handler, allowing the rest of the middleware chain
// to handle normal HTTP/gRPC traffic.
package realtime

import (
	"net/http"
	"strings"

	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/sse"
	"p9e.in/samavaya/packages/websocket"
)

// Config holds the dependencies for the real-time middleware.
type Config struct {
	// WSHandler is the HTTP handler that performs the WebSocket upgrade.
	// If nil, WebSocket upgrade requests will pass through to the next handler.
	WSHandler http.Handler
	// SSEHandler is the HTTP handler that streams Server-Sent Events.
	// If nil, SSE requests will pass through to the next handler.
	SSEHandler http.Handler
	// WSPath restricts WebSocket upgrades to a specific path (e.g. "/ws").
	// If empty, any request with an Upgrade: websocket header is routed.
	WSPath string
	// SSEPath restricts SSE connections to a specific path (e.g. "/events").
	// If empty, any request with Accept: text/event-stream is routed.
	SSEPath string
	// Log is the logger.
	Log p9log.Logger
}

// NewFromHub creates a Config with handlers built from a WebSocket hub
// and SSE broker. This is the common setup path.
func NewFromHub(hub *websocket.Hub, broker *sse.Broker, auth websocket.Authenticator, log p9log.Logger) Config {
	cfg := Config{Log: log}
	if hub != nil && auth != nil {
		cfg.WSHandler = websocket.NewHandler(websocket.HandlerConfig{
			Hub:  hub,
			Auth: auth,
			Log:  log,
		})
	}
	if broker != nil {
		cfg.SSEHandler = sse.NewHandler(sse.HandlerConfig{
			Broker: broker,
			Log:    log,
		})
	}
	return cfg
}

// Middleware returns an http.Handler that inspects each request and routes
// WebSocket upgrades and SSE requests to their respective handlers. All
// other requests are forwarded to next.
func Middleware(cfg Config, next http.Handler) http.Handler {
	log := p9log.NewHelper(p9log.With(cfg.Log, "module", "realtime-middleware"))

	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Check for WebSocket upgrade.
		if cfg.WSHandler != nil && isWebSocketUpgrade(r) {
			if cfg.WSPath == "" || r.URL.Path == cfg.WSPath {
				log.Debugf("routing WebSocket upgrade: %s", r.URL.Path)
				cfg.WSHandler.ServeHTTP(w, r)
				return
			}
		}

		// Check for SSE request.
		if cfg.SSEHandler != nil && isSSERequest(r) {
			if cfg.SSEPath == "" || r.URL.Path == cfg.SSEPath {
				log.Debugf("routing SSE request: %s", r.URL.Path)
				cfg.SSEHandler.ServeHTTP(w, r)
				return
			}
		}

		// Normal request; pass through.
		next.ServeHTTP(w, r)
	})
}

// Wrap returns a function that wraps an http.Handler with the real-time
// middleware. This is convenient for composing with other middleware.
func Wrap(cfg Config) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return Middleware(cfg, next)
	}
}

// isWebSocketUpgrade checks whether the request is a WebSocket upgrade request
// per RFC 6455 section 4.2.1.
func isWebSocketUpgrade(r *http.Request) bool {
	for _, v := range r.Header.Values("Connection") {
		if strings.EqualFold(strings.TrimSpace(v), "upgrade") {
			for _, u := range r.Header.Values("Upgrade") {
				if strings.EqualFold(strings.TrimSpace(u), "websocket") {
					return true
				}
			}
		}
	}
	return false
}

// isSSERequest checks whether the request accepts text/event-stream.
func isSSERequest(r *http.Request) bool {
	accept := r.Header.Get("Accept")
	return strings.Contains(accept, "text/event-stream")
}
