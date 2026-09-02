package testutil

import (
	"net/http"
	"testing"

	"github.com/stretchr/testify/assert"
)

// AssertHealthEndpoint checks that a service's /health endpoint returns 200.
func AssertHealthEndpoint(t *testing.T, baseURL string) {
	t.Helper()
	resp, err := http.Get(baseURL + "/health")
	if err != nil {
		t.Skipf("service not reachable at %s: %v", baseURL, err)
		return
	}
	defer resp.Body.Close()
	assert.Equal(t, http.StatusOK, resp.StatusCode, "health endpoint should return 200")
}

// AssertReadyEndpoint checks that a service's /ready endpoint returns 200.
func AssertReadyEndpoint(t *testing.T, baseURL string) {
	t.Helper()
	resp, err := http.Get(baseURL + "/ready")
	if err != nil {
		t.Skipf("service not reachable at %s: %v", baseURL, err)
		return
	}
	defer resp.Body.Close()
	assert.Equal(t, http.StatusOK, resp.StatusCode, "ready endpoint should return 200")
}
