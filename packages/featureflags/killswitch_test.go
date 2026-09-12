package featureflags

import (
	"context"
	"fmt"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestKillSwitch_IsAlive(t *testing.T) {
	svc := NewInMemoryFlagService()
	svc.SetFlag(Flag{Name: "api_flag", Type: FlagTypeKillSwitch, Enabled: true})

	ks := NewKillSwitch("api_flag", svc)
	ctx := context.Background()

	assert.True(t, ks.IsAlive(ctx, Attributes{}))

	// Kill the API.
	svc.SetFlag(Flag{Name: "api_flag", Type: FlagTypeKillSwitch, Enabled: false})
	assert.False(t, ks.IsAlive(ctx, Attributes{}))
}

func TestKillSwitch_IsAlive_NonexistentFlag(t *testing.T) {
	svc := NewInMemoryFlagService()
	ks := NewKillSwitch("nonexistent", svc)

	assert.False(t, ks.IsAlive(context.Background(), Attributes{}))
}

func TestExecute_Alive(t *testing.T) {
	svc := NewInMemoryFlagService()
	svc.SetFlag(Flag{Name: "api", Type: FlagTypeKillSwitch, Enabled: true})
	ks := NewKillSwitch("api", svc)
	ctx := context.Background()

	called := false
	result, err := Execute(ctx, ks, Attributes{}, func(_ context.Context) (string, error) {
		called = true
		return "api_response", nil
	}, "fallback")

	require.NoError(t, err)
	assert.True(t, called)
	assert.Equal(t, "api_response", result)
}

func TestExecute_Killed(t *testing.T) {
	svc := NewInMemoryFlagService()
	svc.SetFlag(Flag{Name: "api", Type: FlagTypeKillSwitch, Enabled: false})
	ks := NewKillSwitch("api", svc)
	ctx := context.Background()

	called := false
	result, err := Execute(ctx, ks, Attributes{}, func(_ context.Context) (string, error) {
		called = true
		return "should_not_reach", nil
	}, "fallback")

	require.NoError(t, err)
	assert.False(t, called)
	assert.Equal(t, "fallback", result)
}

func TestExecute_APIError(t *testing.T) {
	svc := NewInMemoryFlagService()
	svc.SetFlag(Flag{Name: "api", Type: FlagTypeKillSwitch, Enabled: true})
	ks := NewKillSwitch("api", svc)
	ctx := context.Background()

	result, err := Execute(ctx, ks, Attributes{}, func(_ context.Context) (string, error) {
		return "", fmt.Errorf("api error")
	}, "fallback")

	assert.Error(t, err)
	assert.Equal(t, "", result)
}

func TestExecuteWithError_Alive(t *testing.T) {
	svc := NewInMemoryFlagService()
	svc.SetFlag(Flag{Name: "api", Type: FlagTypeKillSwitch, Enabled: true})
	ks := NewKillSwitch("api", svc)
	ctx := context.Background()

	result, err := ExecuteWithError(ctx, ks, Attributes{}, func(_ context.Context) (int, error) {
		return 42, nil
	})

	require.NoError(t, err)
	assert.Equal(t, 42, result)
}

func TestExecuteWithError_Killed(t *testing.T) {
	svc := NewInMemoryFlagService()
	svc.SetFlag(Flag{Name: "api", Type: FlagTypeKillSwitch, Enabled: false})
	ks := NewKillSwitch("api", svc)
	ctx := context.Background()

	result, err := ExecuteWithError(ctx, ks, Attributes{}, func(_ context.Context) (int, error) {
		return 42, nil
	})

	assert.ErrorIs(t, err, ErrAPIKilled)
	assert.Equal(t, 0, result)
}

func TestPlantNetKillSwitch(t *testing.T) {
	svc := NewInMemoryFlagService()
	svc.SetFlag(Flag{Name: FlagPlantNetAPI, Type: FlagTypeKillSwitch, Enabled: true})

	ks := PlantNetKillSwitch(svc)
	assert.True(t, ks.IsAlive(context.Background(), Attributes{}))
	assert.Equal(t, FlagPlantNetAPI, ks.flagName)
}

func TestGoogleVisionKillSwitch(t *testing.T) {
	svc := NewInMemoryFlagService()
	svc.SetFlag(Flag{Name: FlagGoogleVisionAPI, Type: FlagTypeKillSwitch, Enabled: true})

	ks := GoogleVisionKillSwitch(svc)
	assert.True(t, ks.IsAlive(context.Background(), Attributes{}))
	assert.Equal(t, FlagGoogleVisionAPI, ks.flagName)
}

func TestDefaultPlantNetFallback(t *testing.T) {
	fb := DefaultPlantNetFallback()
	assert.Equal(t, "unknown", fb.Species)
	assert.Equal(t, float64(0), fb.Confidence)
}

func TestDefaultGoogleVisionFallback(t *testing.T) {
	fb := DefaultGoogleVisionFallback()
	assert.Nil(t, fb.Labels)
	assert.Equal(t, float64(0), fb.Confidence)
}

func TestExecute_WithPlantNetTypes(t *testing.T) {
	svc := NewInMemoryFlagService()
	svc.SetFlag(Flag{Name: FlagPlantNetAPI, Type: FlagTypeKillSwitch, Enabled: false})
	ks := PlantNetKillSwitch(svc)
	ctx := context.Background()

	result, err := Execute(ctx, ks, Attributes{}, func(_ context.Context) (PlantNetIdentification, error) {
		return PlantNetIdentification{Species: "Rosa canina", CommonName: "Dog rose", Confidence: 0.95}, nil
	}, DefaultPlantNetFallback())

	require.NoError(t, err)
	assert.Equal(t, "unknown", result.Species)
	assert.Equal(t, float64(0), result.Confidence)
}

func TestExecute_WithGoogleVisionTypes(t *testing.T) {
	svc := NewInMemoryFlagService()
	svc.SetFlag(Flag{Name: FlagGoogleVisionAPI, Type: FlagTypeKillSwitch, Enabled: true})
	ks := GoogleVisionKillSwitch(svc)
	ctx := context.Background()

	result, err := Execute(ctx, ks, Attributes{}, func(_ context.Context) (GoogleVisionResult, error) {
		return GoogleVisionResult{Labels: []string{"plant", "leaf"}, Confidence: 0.88}, nil
	}, DefaultGoogleVisionFallback())

	require.NoError(t, err)
	assert.Equal(t, []string{"plant", "leaf"}, result.Labels)
	assert.Equal(t, 0.88, result.Confidence)
}
