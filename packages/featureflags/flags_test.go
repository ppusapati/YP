package featureflags

import (
	"context"
	"encoding/json"
	"os"
	"path/filepath"
	"sync"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestInMemoryFlagService_SetAndGet(t *testing.T) {
	svc := NewInMemoryFlagService()

	flag := Flag{
		Name:    "test_flag",
		Type:    FlagTypeBoolean,
		Enabled: true,
	}
	svc.SetFlag(flag)

	got := svc.GetFlag("test_flag")
	require.NotNil(t, got)
	assert.Equal(t, "test_flag", got.Name)
	assert.True(t, got.Enabled)
	assert.False(t, got.UpdatedAt.IsZero())
}

func TestInMemoryFlagService_GetFlag_NotFound(t *testing.T) {
	svc := NewInMemoryFlagService()
	got := svc.GetFlag("nonexistent")
	assert.Nil(t, got)
}

func TestInMemoryFlagService_RemoveFlag(t *testing.T) {
	svc := NewInMemoryFlagService()
	svc.SetFlag(Flag{Name: "to_remove", Type: FlagTypeBoolean, Enabled: true})
	assert.Equal(t, 1, svc.FlagCount())

	svc.RemoveFlag("to_remove")
	assert.Equal(t, 0, svc.FlagCount())
	assert.Nil(t, svc.GetFlag("to_remove"))
}

func TestInMemoryFlagService_IsEnabled_BooleanFlag(t *testing.T) {
	svc := NewInMemoryFlagService()
	ctx := context.Background()

	svc.SetFlag(Flag{Name: "enabled_flag", Type: FlagTypeBoolean, Enabled: true})
	svc.SetFlag(Flag{Name: "disabled_flag", Type: FlagTypeBoolean, Enabled: false})

	assert.True(t, svc.IsEnabled(ctx, "enabled_flag", Attributes{}))
	assert.False(t, svc.IsEnabled(ctx, "disabled_flag", Attributes{}))
	assert.False(t, svc.IsEnabled(ctx, "nonexistent", Attributes{}))
}

func TestInMemoryFlagService_GetVariant_NotFound(t *testing.T) {
	svc := NewInMemoryFlagService()
	ctx := context.Background()

	result := svc.GetVariant(ctx, "nonexistent", Attributes{})
	assert.False(t, result.Enabled)
	assert.Equal(t, "flag_not_found", result.Reason)
}

func TestInMemoryFlagService_ListFlags(t *testing.T) {
	svc := NewInMemoryFlagService()
	ctx := context.Background()

	svc.SetFlag(Flag{Name: "flag_a", Type: FlagTypeBoolean, Enabled: true})
	svc.SetFlag(Flag{Name: "flag_b", Type: FlagTypeBoolean, Enabled: false})

	flags := svc.ListFlags(ctx)
	assert.Len(t, flags, 2)

	names := make(map[string]bool)
	for _, f := range flags {
		names[f.Name] = true
	}
	assert.True(t, names["flag_a"])
	assert.True(t, names["flag_b"])
}

func TestInMemoryFlagService_ReplaceAll(t *testing.T) {
	svc := NewInMemoryFlagService()

	svc.SetFlag(Flag{Name: "old_flag", Type: FlagTypeBoolean, Enabled: true})
	assert.Equal(t, 1, svc.FlagCount())

	svc.ReplaceAll([]Flag{
		{Name: "new_a", Type: FlagTypeBoolean, Enabled: true},
		{Name: "new_b", Type: FlagTypeBoolean, Enabled: false},
	})

	assert.Equal(t, 2, svc.FlagCount())
	assert.Nil(t, svc.GetFlag("old_flag"))
	assert.NotNil(t, svc.GetFlag("new_a"))
	assert.NotNil(t, svc.GetFlag("new_b"))
}

func TestInMemoryFlagService_LoadFromJSON(t *testing.T) {
	dir := t.TempDir()
	path := filepath.Join(dir, "flags.json")

	config := map[string]interface{}{
		"flags": []map[string]interface{}{
			{
				"name":    "json_flag",
				"type":    "boolean",
				"enabled": true,
			},
			{
				"name":               "rollout_flag",
				"type":               "percentage",
				"enabled":            true,
				"rollout_percentage": 50,
			},
		},
	}
	data, err := json.Marshal(config)
	require.NoError(t, err)
	require.NoError(t, os.WriteFile(path, data, 0644))

	svc := NewInMemoryFlagService()
	err = svc.LoadFromJSON(path)
	require.NoError(t, err)

	assert.Equal(t, 2, svc.FlagCount())

	f := svc.GetFlag("json_flag")
	require.NotNil(t, f)
	assert.True(t, f.Enabled)

	f = svc.GetFlag("rollout_flag")
	require.NotNil(t, f)
	assert.Equal(t, 50, f.RolloutPercentage)
}

func TestInMemoryFlagService_LoadFromJSON_FileNotFound(t *testing.T) {
	svc := NewInMemoryFlagService()
	err := svc.LoadFromJSON("/nonexistent/path.json")
	assert.Error(t, err)
}

func TestInMemoryFlagService_LoadFromJSON_InvalidJSON(t *testing.T) {
	dir := t.TempDir()
	path := filepath.Join(dir, "bad.json")
	require.NoError(t, os.WriteFile(path, []byte("not json"), 0644))

	svc := NewInMemoryFlagService()
	err := svc.LoadFromJSON(path)
	assert.Error(t, err)
}

func TestInMemoryFlagService_ConcurrentAccess(t *testing.T) {
	svc := NewInMemoryFlagService()
	ctx := context.Background()

	var wg sync.WaitGroup
	for i := 0; i < 100; i++ {
		wg.Add(3)
		name := "flag"
		go func() {
			defer wg.Done()
			svc.SetFlag(Flag{Name: name, Type: FlagTypeBoolean, Enabled: true})
		}()
		go func() {
			defer wg.Done()
			svc.IsEnabled(ctx, name, Attributes{"user_id": "u1"})
		}()
		go func() {
			defer wg.Done()
			svc.ListFlags(ctx)
		}()
	}
	wg.Wait()
}

func TestInMemoryFlagService_WithEvaluationLogger(t *testing.T) {
	logger := NewInMemoryEvaluationLogger()
	svc := NewInMemoryFlagService(WithEvaluationLogger(logger))
	ctx := context.Background()

	svc.SetFlag(Flag{Name: "logged_flag", Type: FlagTypeBoolean, Enabled: true})
	svc.IsEnabled(ctx, "logged_flag", Attributes{"user_id": "u1"})
	svc.IsEnabled(ctx, "nonexistent", Attributes{"user_id": "u2"})

	entries := logger.Entries()
	require.Len(t, entries, 2)
	assert.Equal(t, "logged_flag", entries[0].FlagName)
	assert.True(t, entries[0].Enabled)
	assert.Equal(t, "nonexistent", entries[1].FlagName)
	assert.False(t, entries[1].Enabled)
}

func TestInMemoryFlagService_GetVariant_ReturnsPayload(t *testing.T) {
	svc := NewInMemoryFlagService()
	ctx := context.Background()

	svc.SetFlag(Flag{
		Name:    "multi_flag",
		Type:    FlagTypeMultivariate,
		Enabled: true,
		Variants: []Variant{
			{Key: "control", Weight: 50, Payload: map[string]interface{}{"color": "blue"}},
			{Key: "treatment", Weight: 50, Payload: map[string]interface{}{"color": "red"}},
		},
		DefaultVariant: "control",
	})

	result := svc.GetVariant(ctx, "multi_flag", Attributes{"user_id": "user123"})
	assert.True(t, result.Enabled)
	assert.NotEmpty(t, result.VariantKey)
	assert.NotNil(t, result.Payload)
}
