package gateway

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestWAF_SQLInjection(t *testing.T) {
	waf, err := NewWAF(DefaultWAFConfig())
	if err != nil {
		t.Fatal(err)
	}

	tests := []struct {
		name    string
		query   string
		blocked bool
	}{
		{"normal query", "search=wheat+crop", false},
		{"union select", "id=1+UNION+SELECT+*+FROM+users", true},
		{"or 1=1", "user=admin'+OR+'1'='1", true},
		{"drop table", "id=1;+DROP+TABLE+farms", true},
		{"comment injection", "id=1--+", true},
		{"normal number", "page=1&limit=20", false},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			req := httptest.NewRequest("GET", "/?"+tt.query, nil)
			reason := waf.Check(req)
			if tt.blocked && reason == "" {
				t.Errorf("expected blocked, got allowed")
			}
			if !tt.blocked && reason != "" {
				t.Errorf("expected allowed, got blocked: %s", reason)
			}
		})
	}
}

func TestWAF_XSS(t *testing.T) {
	waf, err := NewWAF(DefaultWAFConfig())
	if err != nil {
		t.Fatal(err)
	}

	tests := []struct {
		name    string
		query   string
		blocked bool
	}{
		{"normal text", "name=John+Doe", false},
		{"script tag", "name=<script>alert(1)</script>", true},
		{"javascript protocol", "url=javascript:alert(1)", true},
		{"event handler", "val=x+onerror=alert(1)", true},
		{"iframe", "html=<iframe+src=evil.com>", true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			req := httptest.NewRequest("GET", "/?"+tt.query, nil)
			reason := waf.Check(req)
			if tt.blocked && reason == "" {
				t.Errorf("expected blocked, got allowed")
			}
			if !tt.blocked && reason != "" {
				t.Errorf("expected allowed, got blocked: %s", reason)
			}
		})
	}
}

func TestWAF_PathTraversal(t *testing.T) {
	waf, err := NewWAF(DefaultWAFConfig())
	if err != nil {
		t.Fatal(err)
	}

	tests := []struct {
		name    string
		path    string
		blocked bool
	}{
		{"normal path", "/api/farms/123", false},
		{"dot dot slash", "/api/../../../etc/passwd", true},
		{"encoded traversal", "/api/%2e%2e/secret", true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			req := httptest.NewRequest("GET", tt.path, nil)
			reason := waf.Check(req)
			if tt.blocked && reason == "" {
				t.Errorf("expected blocked, got allowed")
			}
			if !tt.blocked && reason != "" {
				t.Errorf("expected allowed, got blocked: %s", reason)
			}
		})
	}
}

func TestWAF_IPDenylist(t *testing.T) {
	waf, err := NewWAF(WAFConfig{
		MaxBodySize:       10 * 1024 * 1024,
		EnableSQLi:        true,
		EnableXSS:         true,
		EnablePathTraversal: true,
		IPDenylist:        []string{"10.0.0.1/32", "192.168.1.0/24"},
	})
	if err != nil {
		t.Fatal(err)
	}

	req := httptest.NewRequest("GET", "/api/farms", nil)
	req.RemoteAddr = "10.0.0.1:1234"
	if reason := waf.Check(req); reason != "ip_denied" {
		t.Errorf("expected ip_denied, got %q", reason)
	}

	req.RemoteAddr = "192.168.1.55:1234"
	if reason := waf.Check(req); reason != "ip_denied" {
		t.Errorf("expected ip_denied, got %q", reason)
	}

	req.RemoteAddr = "172.16.0.1:1234"
	if reason := waf.Check(req); reason != "" {
		t.Errorf("expected allowed, got %q", reason)
	}
}

func TestWAF_IPAllowlist(t *testing.T) {
	waf, err := NewWAF(WAFConfig{
		MaxBodySize: 10 * 1024 * 1024,
		IPAllowlist: []string{"10.0.0.0/8"},
	})
	if err != nil {
		t.Fatal(err)
	}

	req := httptest.NewRequest("GET", "/api/farms", nil)
	req.RemoteAddr = "10.0.0.1:1234"
	if reason := waf.Check(req); reason != "" {
		t.Errorf("expected allowed, got %q", reason)
	}

	req.RemoteAddr = "192.168.1.1:1234"
	if reason := waf.Check(req); reason != "ip_not_allowed" {
		t.Errorf("expected ip_not_allowed, got %q", reason)
	}
}

func TestWAF_BodySizeLimit(t *testing.T) {
	waf, err := NewWAF(WAFConfig{MaxBodySize: 100})
	if err != nil {
		t.Fatal(err)
	}

	req := httptest.NewRequest("POST", "/api/farms", strings.NewReader("x"))
	req.ContentLength = 200
	if reason := waf.Check(req); reason != "body_too_large" {
		t.Errorf("expected body_too_large, got %q", reason)
	}
}

func TestWAF_Middleware(t *testing.T) {
	waf, err := NewWAF(DefaultWAFConfig())
	if err != nil {
		t.Fatal(err)
	}

	handler := waf.Middleware(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	}))

	rec := httptest.NewRecorder()
	req := httptest.NewRequest("GET", "/?id=1+UNION+SELECT+*+FROM+users", nil)
	handler.ServeHTTP(rec, req)
	if rec.Code != http.StatusForbidden {
		t.Errorf("expected 403, got %d", rec.Code)
	}

	rec = httptest.NewRecorder()
	req = httptest.NewRequest("GET", "/api/farms?page=1", nil)
	handler.ServeHTTP(rec, req)
	if rec.Code != http.StatusOK {
		t.Errorf("expected 200, got %d", rec.Code)
	}
}

func TestWAF_XForwardedFor(t *testing.T) {
	waf, err := NewWAF(WAFConfig{
		MaxBodySize: 10 * 1024 * 1024,
		IPDenylist:  []string{"10.0.0.1/32"},
	})
	if err != nil {
		t.Fatal(err)
	}

	req := httptest.NewRequest("GET", "/", nil)
	req.RemoteAddr = "172.16.0.1:1234"
	req.Header.Set("X-Forwarded-For", "10.0.0.1, 172.16.0.1")
	if reason := waf.Check(req); reason != "ip_denied" {
		t.Errorf("expected ip_denied via XFF, got %q", reason)
	}
}
