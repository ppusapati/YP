//go:build integration

package tests

import (
	"os"
	"testing"

	"p9e.in/samavaya/packages/testutil"
)

func TestContractHealth(t *testing.T) {
	baseURL := os.Getenv("SERVICE_BASE_URL")
	if baseURL == "" {
		baseURL = "http://localhost:8086"
	}
	testutil.AssertHealthEndpoint(t, baseURL)
}

func TestContractReady(t *testing.T) {
	baseURL := os.Getenv("SERVICE_BASE_URL")
	if baseURL == "" {
		baseURL = "http://localhost:8086"
	}
	testutil.AssertReadyEndpoint(t, baseURL)
}
