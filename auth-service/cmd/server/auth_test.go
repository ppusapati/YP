package main

import (
	"net/http"
	"testing"
)

func TestClientAddr_XForwardedFor(t *testing.T) {
	tests := []struct {
		name string
		xff  string
		want string
	}{
		{"single IP", "1.2.3.4", "1.2.3.4"},
		{"multiple IPs", "1.2.3.4, 5.6.7.8", "1.2.3.4"},
		{"with spaces", "  1.2.3.4 , 5.6.7.8", "1.2.3.4"},
		{"empty", "", "192.168.1.1:1234"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			r := &http.Request{
				RemoteAddr: "192.168.1.1:1234",
				Header:     http.Header{},
			}
			if tt.xff != "" {
				r.Header.Set("X-Forwarded-For", tt.xff)
			}
			got := clientAddr(r)
			if got != tt.want {
				t.Errorf("clientAddr() = %q, want %q", got, tt.want)
			}
		})
	}
}

func TestHashToken_Deterministic(t *testing.T) {
	hash1 := hashToken("test-token")
	hash2 := hashToken("test-token")
	if hash1 != hash2 {
		t.Error("hashToken should be deterministic")
	}
	if hash1 == "" {
		t.Error("hashToken should not return empty string")
	}
}

func TestHashToken_Different(t *testing.T) {
	hash1 := hashToken("token-a")
	hash2 := hashToken("token-b")
	if hash1 == hash2 {
		t.Error("different tokens should produce different hashes")
	}
}

func TestGenerateRefreshToken(t *testing.T) {
	raw, hash := generateRefreshToken()
	if raw == "" || hash == "" {
		t.Error("generateRefreshToken should return non-empty values")
	}
	if hashToken(raw) != hash {
		t.Error("hash should match hashToken(raw)")
	}
	if len(raw) != 64 {
		t.Errorf("raw token should be 64 hex chars, got %d", len(raw))
	}
}
