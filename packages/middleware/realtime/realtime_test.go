package realtime

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"p9e.in/samavaya/packages/p9log"

	"github.com/stretchr/testify/assert"
)

func TestIsWebSocketUpgrade(t *testing.T) {
	tests := []struct {
		name     string
		headers  map[string]string
		expected bool
	}{
		{
			name:     "valid websocket upgrade",
			headers:  map[string]string{"Connection": "Upgrade", "Upgrade": "websocket"},
			expected: true,
		},
		{
			name:     "case insensitive",
			headers:  map[string]string{"Connection": "upgrade", "Upgrade": "WebSocket"},
			expected: true,
		},
		{
			name:     "missing upgrade header",
			headers:  map[string]string{"Connection": "Upgrade"},
			expected: false,
		},
		{
			name:     "missing connection header",
			headers:  map[string]string{"Upgrade": "websocket"},
			expected: false,
		},
		{
			name:     "no headers",
			headers:  map[string]string{},
			expected: false,
		},
		{
			name:     "wrong upgrade value",
			headers:  map[string]string{"Connection": "Upgrade", "Upgrade": "h2c"},
			expected: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			r := httptest.NewRequest(http.MethodGet, "/ws", nil)
			for k, v := range tt.headers {
				r.Header.Set(k, v)
			}
			assert.Equal(t, tt.expected, isWebSocketUpgrade(r))
		})
	}
}

func TestIsSSERequest(t *testing.T) {
	tests := []struct {
		name     string
		accept   string
		expected bool
	}{
		{"exact match", "text/event-stream", true},
		{"with other types", "text/event-stream, text/html", true},
		{"no match", "application/json", false},
		{"empty", "", false},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			r := httptest.NewRequest(http.MethodGet, "/events", nil)
			if tt.accept != "" {
				r.Header.Set("Accept", tt.accept)
			}
			assert.Equal(t, tt.expected, isSSERequest(r))
		})
	}
}

func TestMiddleware_NormalRequestPassesThrough(t *testing.T) {
	log := p9log.NewNopLogger()
	called := false
	next := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		called = true
		w.WriteHeader(http.StatusOK)
	})

	cfg := Config{Log: log}
	handler := Middleware(cfg, next)

	r := httptest.NewRequest(http.MethodGet, "/api/resource", nil)
	w := httptest.NewRecorder()
	handler.ServeHTTP(w, r)

	assert.True(t, called, "next handler should be called for normal requests")
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestMiddleware_WSRouting(t *testing.T) {
	log := p9log.NewNopLogger()
	wsCalled := false
	wsHandler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		wsCalled = true
	})
	nextCalled := false
	next := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		nextCalled = true
	})

	cfg := Config{
		WSHandler: wsHandler,
		WSPath:    "/ws",
		Log:       log,
	}
	handler := Middleware(cfg, next)

	// Request with WS upgrade headers to the WS path.
	r := httptest.NewRequest(http.MethodGet, "/ws", nil)
	r.Header.Set("Connection", "Upgrade")
	r.Header.Set("Upgrade", "websocket")
	w := httptest.NewRecorder()
	handler.ServeHTTP(w, r)

	assert.True(t, wsCalled)
	assert.False(t, nextCalled)
}

func TestMiddleware_WSWrongPath(t *testing.T) {
	log := p9log.NewNopLogger()
	wsCalled := false
	wsHandler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		wsCalled = true
	})
	nextCalled := false
	next := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		nextCalled = true
	})

	cfg := Config{
		WSHandler: wsHandler,
		WSPath:    "/ws",
		Log:       log,
	}
	handler := Middleware(cfg, next)

	// WS upgrade on wrong path should pass through.
	r := httptest.NewRequest(http.MethodGet, "/other", nil)
	r.Header.Set("Connection", "Upgrade")
	r.Header.Set("Upgrade", "websocket")
	w := httptest.NewRecorder()
	handler.ServeHTTP(w, r)

	assert.False(t, wsCalled)
	assert.True(t, nextCalled)
}

func TestMiddleware_SSERouting(t *testing.T) {
	log := p9log.NewNopLogger()
	sseCalled := false
	sseHandler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		sseCalled = true
	})
	nextCalled := false
	next := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		nextCalled = true
	})

	cfg := Config{
		SSEHandler: sseHandler,
		SSEPath:    "/events",
		Log:        log,
	}
	handler := Middleware(cfg, next)

	r := httptest.NewRequest(http.MethodGet, "/events", nil)
	r.Header.Set("Accept", "text/event-stream")
	w := httptest.NewRecorder()
	handler.ServeHTTP(w, r)

	assert.True(t, sseCalled)
	assert.False(t, nextCalled)
}

func TestWrap_ReturnsMiddlewareWrapper(t *testing.T) {
	log := p9log.NewNopLogger()
	cfg := Config{Log: log}
	wrapper := Wrap(cfg)

	next := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	})

	handler := wrapper(next)

	r := httptest.NewRequest(http.MethodGet, "/api", nil)
	w := httptest.NewRecorder()
	handler.ServeHTTP(w, r)

	assert.Equal(t, http.StatusOK, w.Code)
}
