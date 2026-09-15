package gateway

import (
	"net/http"
	"net/http/httptest"
	"testing"
	"time"
)

func TestRateLimiter_Allow(t *testing.T) {
	rl := NewRateLimiter(RateLimitConfig{
		RequestsPerSecond: 10,
		BurstSize:         5,
		CleanupInterval:   time.Minute,
	})
	defer rl.Close()

	for i := 0; i < 5; i++ {
		if !rl.Allow("test-key") {
			t.Errorf("request %d should be allowed", i)
		}
	}

	if rl.Allow("test-key") {
		t.Error("request 6 should be rate limited after burst exhausted")
	}
}

func TestRateLimiter_Refill(t *testing.T) {
	rl := NewRateLimiter(RateLimitConfig{
		RequestsPerSecond: 1000,
		BurstSize:         1,
		CleanupInterval:   time.Minute,
	})
	defer rl.Close()

	if !rl.Allow("refill-key") {
		t.Error("first request should be allowed")
	}
	if rl.Allow("refill-key") {
		t.Error("second request should be blocked")
	}

	time.Sleep(5 * time.Millisecond)

	if !rl.Allow("refill-key") {
		t.Error("request after refill should be allowed")
	}
}

func TestRateLimiter_Middleware(t *testing.T) {
	rl := NewRateLimiter(RateLimitConfig{
		RequestsPerSecond: 10,
		BurstSize:         2,
		CleanupInterval:   time.Minute,
	})
	defer rl.Close()

	handler := rl.Middleware(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	}))

	for i := 0; i < 2; i++ {
		rec := httptest.NewRecorder()
		req := httptest.NewRequest("GET", "/api/farms", nil)
		req.RemoteAddr = "10.0.0.1:1234"
		handler.ServeHTTP(rec, req)
		if rec.Code != http.StatusOK {
			t.Errorf("request %d: expected 200, got %d", i, rec.Code)
		}
		if rec.Header().Get("X-RateLimit-Limit") == "" {
			t.Error("missing X-RateLimit-Limit header")
		}
	}

	rec := httptest.NewRecorder()
	req := httptest.NewRequest("GET", "/api/farms", nil)
	req.RemoteAddr = "10.0.0.1:1234"
	handler.ServeHTTP(rec, req)
	if rec.Code != http.StatusTooManyRequests {
		t.Errorf("expected 429, got %d", rec.Code)
	}
}

func TestRateLimiter_TenantIsolation(t *testing.T) {
	rl := NewRateLimiter(RateLimitConfig{
		RequestsPerSecond: 10,
		BurstSize:         1,
		CleanupInterval:   time.Minute,
	})
	defer rl.Close()

	handler := rl.Middleware(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	}))

	rec := httptest.NewRecorder()
	req := httptest.NewRequest("GET", "/api/farms", nil)
	req.RemoteAddr = "10.0.0.1:1234"
	req.Header.Set("X-Tenant-ID", "tenant-a")
	handler.ServeHTTP(rec, req)
	if rec.Code != http.StatusOK {
		t.Error("tenant-a first request should pass")
	}

	rec = httptest.NewRecorder()
	req = httptest.NewRequest("GET", "/api/farms", nil)
	req.RemoteAddr = "10.0.0.1:1234"
	req.Header.Set("X-Tenant-ID", "tenant-b")
	handler.ServeHTTP(rec, req)
	if rec.Code != http.StatusOK {
		t.Error("tenant-b first request should pass (separate bucket)")
	}
}

func TestRateLimiter_EndpointLimits(t *testing.T) {
	rl := NewRateLimiter(RateLimitConfig{
		RequestsPerSecond: 100,
		BurstSize:         10,
		CleanupInterval:   time.Minute,
	})
	defer rl.Close()

	rl.SetEndpointLimit("/api/auth/login", RateLimitConfig{
		RequestsPerSecond: 1,
		BurstSize:         2,
		CleanupInterval:   time.Minute,
	})

	handler := rl.Middleware(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	}))

	for i := 0; i < 2; i++ {
		rec := httptest.NewRecorder()
		req := httptest.NewRequest("POST", "/api/auth/login", nil)
		req.RemoteAddr = "10.0.0.1:1234"
		handler.ServeHTTP(rec, req)
		if rec.Code != http.StatusOK {
			t.Errorf("login request %d should pass", i)
		}
	}

	rec := httptest.NewRecorder()
	req := httptest.NewRequest("POST", "/api/auth/login", nil)
	req.RemoteAddr = "10.0.0.1:1234"
	handler.ServeHTTP(rec, req)
	if rec.Code != http.StatusTooManyRequests {
		t.Errorf("login request 3 should be rate limited, got %d", rec.Code)
	}
}

func TestRateLimiter_RateLimitHeaders(t *testing.T) {
	rl := NewRateLimiter(RateLimitConfig{
		RequestsPerSecond: 50,
		BurstSize:         10,
		CleanupInterval:   time.Minute,
	})
	defer rl.Close()

	handler := rl.Middleware(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	}))

	rec := httptest.NewRecorder()
	req := httptest.NewRequest("GET", "/api/farms", nil)
	req.RemoteAddr = "10.0.0.2:1234"
	handler.ServeHTTP(rec, req)

	if rec.Header().Get("X-RateLimit-Limit") != "50" {
		t.Errorf("expected limit 50, got %s", rec.Header().Get("X-RateLimit-Limit"))
	}
	if rec.Header().Get("X-RateLimit-Remaining") == "" {
		t.Error("missing X-RateLimit-Remaining")
	}
	if rec.Header().Get("X-RateLimit-Reset") == "" {
		t.Error("missing X-RateLimit-Reset")
	}
}
