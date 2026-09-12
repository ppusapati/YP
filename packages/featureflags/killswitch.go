package featureflags

import (
	"context"
	"fmt"
)

// KillSwitch wraps an external API call behind a feature flag. When the flag
// is disabled (killed), the API call is skipped and a fallback response is
// returned instead. This allows operators to instantly disable external API
// calls without deploying new code.
type KillSwitch struct {
	flagName    string
	flagService FlagService
}

// NewKillSwitch creates a kill switch that checks the named flag before allowing
// external API calls through.
func NewKillSwitch(flagName string, flagService FlagService) *KillSwitch {
	return &KillSwitch{
		flagName:    flagName,
		flagService: flagService,
	}
}

// IsAlive returns true if the external API should be called (flag is enabled),
// or false if the API has been killed (flag is disabled).
func (ks *KillSwitch) IsAlive(ctx context.Context, attrs Attributes) bool {
	return ks.flagService.IsEnabled(ctx, ks.flagName, attrs)
}

// ErrAPIKilled is returned when an external API call is blocked by a kill switch.
var ErrAPIKilled = fmt.Errorf("featureflags: external API call blocked by kill switch")

// Execute runs apiCall if the kill switch flag is enabled. If the flag is
// disabled, it returns the fallback value instead. This provides a clean
// abstraction for gating external dependencies.
func Execute[T any](ctx context.Context, ks *KillSwitch, attrs Attributes, apiCall func(ctx context.Context) (T, error), fallback T) (T, error) {
	if !ks.IsAlive(ctx, attrs) {
		return fallback, nil
	}
	return apiCall(ctx)
}

// ExecuteWithError is like Execute but returns ErrAPIKilled when the switch is off,
// allowing callers to distinguish between a fallback and an actual API response.
func ExecuteWithError[T any](ctx context.Context, ks *KillSwitch, attrs Attributes, apiCall func(ctx context.Context) (T, error)) (T, error) {
	var zero T
	if !ks.IsAlive(ctx, attrs) {
		return zero, ErrAPIKilled
	}
	return apiCall(ctx)
}

// Pre-defined kill switch flag names for external APIs used by the platform.
const (
	// FlagPlantNetAPI is the kill switch flag for the PlantNet plant identification API.
	FlagPlantNetAPI = "plantnet_api"
	// FlagGoogleVisionAPI is the kill switch flag for the Google Vision API.
	FlagGoogleVisionAPI = "google_vision_api"
)

// PlantNetKillSwitch creates a kill switch for the PlantNet API.
func PlantNetKillSwitch(flagService FlagService) *KillSwitch {
	return NewKillSwitch(FlagPlantNetAPI, flagService)
}

// GoogleVisionKillSwitch creates a kill switch for the Google Vision API.
func GoogleVisionKillSwitch(flagService FlagService) *KillSwitch {
	return NewKillSwitch(FlagGoogleVisionAPI, flagService)
}

// PlantNetIdentification represents a response from the PlantNet API.
type PlantNetIdentification struct {
	Species    string  `json:"species"`
	CommonName string  `json:"common_name"`
	Confidence float64 `json:"confidence"`
}

// DefaultPlantNetFallback returns an empty identification result to use
// when the PlantNet API is killed.
func DefaultPlantNetFallback() PlantNetIdentification {
	return PlantNetIdentification{
		Species:    "unknown",
		CommonName: "Service temporarily unavailable",
		Confidence: 0,
	}
}

// GoogleVisionResult represents a response from the Google Vision API.
type GoogleVisionResult struct {
	Labels      []string `json:"labels"`
	Description string   `json:"description"`
	Confidence  float64  `json:"confidence"`
}

// DefaultGoogleVisionFallback returns an empty vision result to use
// when the Google Vision API is killed.
func DefaultGoogleVisionFallback() GoogleVisionResult {
	return GoogleVisionResult{
		Labels:      nil,
		Description: "Service temporarily unavailable",
		Confidence:  0,
	}
}
