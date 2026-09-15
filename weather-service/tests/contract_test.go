//go:build integration

package tests

import (
	"os"
	"testing"

	"p9e.in/samavaya/packages/testutil"
)

func baseURL() string {
	if v := os.Getenv("SERVICE_BASE_URL"); v != "" {
		return v
	}
	return "http://localhost:8108"
}

func TestContractHealth(t *testing.T) {
	testutil.AssertHealthEndpoint(t, baseURL())
}

func TestContractReady(t *testing.T) {
	testutil.AssertReadyEndpoint(t, baseURL())
}
