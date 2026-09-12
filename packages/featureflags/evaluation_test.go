package featureflags

import (
	"context"
	"fmt"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestEvaluator_BooleanFlag_Enabled(t *testing.T) {
	e := NewEvaluator()
	flag := &Flag{
		Name:    "bool_enabled",
		Type:    FlagTypeBoolean,
		Enabled: true,
	}

	result := e.Evaluate(flag, Attributes{})
	assert.True(t, result.Enabled)
	assert.Equal(t, "flag_enabled", result.Reason)
}

func TestEvaluator_BooleanFlag_Disabled(t *testing.T) {
	e := NewEvaluator()
	flag := &Flag{
		Name:    "bool_disabled",
		Type:    FlagTypeBoolean,
		Enabled: false,
	}

	result := e.Evaluate(flag, Attributes{})
	assert.False(t, result.Enabled)
	assert.Equal(t, "flag_disabled", result.Reason)
}

func TestEvaluator_PercentageRollout_FullRollout(t *testing.T) {
	e := NewEvaluator()
	flag := &Flag{
		Name:              "full_rollout",
		Type:              FlagTypePercentage,
		Enabled:           true,
		RolloutPercentage: 100,
	}

	// Every user should be enabled at 100%.
	for i := 0; i < 20; i++ {
		attrs := Attributes{"user_id": fmt.Sprintf("user_%d", i)}
		result := e.Evaluate(flag, attrs)
		assert.True(t, result.Enabled, "user_%d should be enabled at 100%%", i)
	}
}

func TestEvaluator_PercentageRollout_ZeroRollout(t *testing.T) {
	e := NewEvaluator()
	flag := &Flag{
		Name:              "zero_rollout",
		Type:              FlagTypePercentage,
		Enabled:           true,
		RolloutPercentage: 0,
	}

	// No user should be enabled at 0%.
	for i := 0; i < 20; i++ {
		attrs := Attributes{"user_id": fmt.Sprintf("user_%d", i)}
		result := e.Evaluate(flag, attrs)
		assert.False(t, result.Enabled, "user_%d should be disabled at 0%%", i)
	}
}

func TestEvaluator_PercentageRollout_ConsistentHashing(t *testing.T) {
	e := NewEvaluator()
	flag := &Flag{
		Name:              "partial_rollout",
		Type:              FlagTypePercentage,
		Enabled:           true,
		RolloutPercentage: 50,
	}

	// The same user should always get the same result (consistency).
	attrs := Attributes{"user_id": "consistent_user", "tenant_id": "tenant_1"}
	first := e.Evaluate(flag, attrs)
	for i := 0; i < 50; i++ {
		result := e.Evaluate(flag, attrs)
		assert.Equal(t, first.Enabled, result.Enabled, "evaluation should be consistent for the same user")
	}
}

func TestEvaluator_PercentageRollout_Distribution(t *testing.T) {
	e := NewEvaluator()
	flag := &Flag{
		Name:              "dist_rollout",
		Type:              FlagTypePercentage,
		Enabled:           true,
		RolloutPercentage: 50,
	}

	enabled := 0
	total := 1000
	for i := 0; i < total; i++ {
		attrs := Attributes{"user_id": fmt.Sprintf("user_%d", i)}
		result := e.Evaluate(flag, attrs)
		if result.Enabled {
			enabled++
		}
	}

	// With 1000 samples at 50%, we expect roughly 500 enabled.
	// Allow a generous margin for hash distribution (35%-65%).
	ratio := float64(enabled) / float64(total)
	assert.InDelta(t, 0.5, ratio, 0.15, "expected ~50%% enabled, got %.1f%%", ratio*100)
}

func TestEvaluator_TargetingRule_Eq(t *testing.T) {
	e := NewEvaluator()
	flag := &Flag{
		Name:    "targeted",
		Type:    FlagTypePercentage,
		Enabled: true,
		// 0% rollout, but with a targeting rule override.
		RolloutPercentage: 0,
		TargetingRules: []TargetingRule{
			{Attribute: "tenant_id", Operator: "eq", Values: []string{"premium_tenant"}},
		},
	}

	// Matching tenant is enabled despite 0% rollout.
	result := e.Evaluate(flag, Attributes{"tenant_id": "premium_tenant"})
	assert.True(t, result.Enabled)
	assert.Contains(t, result.Reason, "targeting_rule_match")

	// Non-matching tenant falls through to percentage.
	result = e.Evaluate(flag, Attributes{"tenant_id": "regular_tenant"})
	assert.False(t, result.Enabled)
}

func TestEvaluator_TargetingRule_In(t *testing.T) {
	e := NewEvaluator()
	flag := &Flag{
		Name:              "in_rule",
		Type:              FlagTypePercentage,
		Enabled:           true,
		RolloutPercentage: 0,
		TargetingRules: []TargetingRule{
			{Attribute: "region", Operator: "in", Values: []string{"us-east", "eu-west"}},
		},
	}

	assert.True(t, e.Evaluate(flag, Attributes{"region": "us-east"}).Enabled)
	assert.True(t, e.Evaluate(flag, Attributes{"region": "eu-west"}).Enabled)
	assert.False(t, e.Evaluate(flag, Attributes{"region": "ap-south"}).Enabled)
}

func TestEvaluator_TargetingRule_NotIn(t *testing.T) {
	e := NewEvaluator()
	flag := &Flag{
		Name:              "not_in_rule",
		Type:              FlagTypePercentage,
		Enabled:           true,
		RolloutPercentage: 0,
		TargetingRules: []TargetingRule{
			{Attribute: "user_role", Operator: "not_in", Values: []string{"guest", "banned"}},
		},
	}

	assert.True(t, e.Evaluate(flag, Attributes{"user_role": "admin"}).Enabled)
	assert.False(t, e.Evaluate(flag, Attributes{"user_role": "guest"}).Enabled)
	assert.False(t, e.Evaluate(flag, Attributes{"user_role": "banned"}).Enabled)
}

func TestEvaluator_TargetingRule_Neq(t *testing.T) {
	e := NewEvaluator()
	flag := &Flag{
		Name:              "neq_rule",
		Type:              FlagTypePercentage,
		Enabled:           true,
		RolloutPercentage: 0,
		TargetingRules: []TargetingRule{
			{Attribute: "user_role", Operator: "neq", Values: []string{"guest"}},
		},
	}

	assert.True(t, e.Evaluate(flag, Attributes{"user_role": "admin"}).Enabled)
	assert.False(t, e.Evaluate(flag, Attributes{"user_role": "guest"}).Enabled)
}

func TestEvaluator_TargetingRule_Contains(t *testing.T) {
	e := NewEvaluator()
	flag := &Flag{
		Name:              "contains_rule",
		Type:              FlagTypePercentage,
		Enabled:           true,
		RolloutPercentage: 0,
		TargetingRules: []TargetingRule{
			{Attribute: "tenant_id", Operator: "contains", Values: []string{"beta"}},
		},
	}

	assert.True(t, e.Evaluate(flag, Attributes{"tenant_id": "tenant_beta_1"}).Enabled)
	assert.False(t, e.Evaluate(flag, Attributes{"tenant_id": "tenant_prod_1"}).Enabled)
}

func TestEvaluator_TargetingRule_MissingAttribute(t *testing.T) {
	e := NewEvaluator()
	flag := &Flag{
		Name:              "missing_attr",
		Type:              FlagTypePercentage,
		Enabled:           true,
		RolloutPercentage: 0,
		TargetingRules: []TargetingRule{
			{Attribute: "region", Operator: "eq", Values: []string{"us-east"}},
		},
	}

	// Missing attribute should not match.
	result := e.Evaluate(flag, Attributes{"user_id": "u1"})
	assert.False(t, result.Enabled)
}

func TestEvaluator_Multivariate(t *testing.T) {
	e := NewEvaluator()
	flag := &Flag{
		Name:    "experiment",
		Type:    FlagTypeMultivariate,
		Enabled: true,
		Variants: []Variant{
			{Key: "control", Weight: 50, Payload: map[string]interface{}{"color": "blue"}},
			{Key: "treatment_a", Weight: 30, Payload: map[string]interface{}{"color": "red"}},
			{Key: "treatment_b", Weight: 20, Payload: map[string]interface{}{"color": "green"}},
		},
		DefaultVariant: "control",
	}

	attrs := Attributes{"user_id": "user_42"}
	result := e.Evaluate(flag, attrs)
	assert.True(t, result.Enabled)
	assert.NotEmpty(t, result.VariantKey)
	assert.NotNil(t, result.Payload)
	assert.Contains(t, result.Reason, "multivariate")

	// Consistency: same input should yield same variant.
	for i := 0; i < 20; i++ {
		r := e.Evaluate(flag, attrs)
		assert.Equal(t, result.VariantKey, r.VariantKey)
	}
}

func TestEvaluator_Multivariate_Disabled(t *testing.T) {
	e := NewEvaluator()
	flag := &Flag{
		Name:    "disabled_multi",
		Type:    FlagTypeMultivariate,
		Enabled: false,
		Variants: []Variant{
			{Key: "control", Weight: 50},
			{Key: "treatment", Weight: 50},
		},
		DefaultVariant: "control",
	}

	result := e.Evaluate(flag, Attributes{"user_id": "u1"})
	assert.False(t, result.Enabled)
	assert.Equal(t, "control", result.VariantKey)
	assert.Equal(t, "flag_disabled", result.Reason)
}

func TestEvaluator_Multivariate_ZeroWeights(t *testing.T) {
	e := NewEvaluator()
	flag := &Flag{
		Name:    "zero_weights",
		Type:    FlagTypeMultivariate,
		Enabled: true,
		Variants: []Variant{
			{Key: "a", Weight: 0},
			{Key: "b", Weight: 0},
		},
	}

	// Zero weights should default to equal distribution.
	result := e.Evaluate(flag, Attributes{"user_id": "u1"})
	assert.True(t, result.Enabled)
	assert.NotEmpty(t, result.VariantKey)
}

func TestEvaluator_KillSwitch(t *testing.T) {
	e := NewEvaluator()

	alive := &Flag{
		Name:    "api_alive",
		Type:    FlagTypeKillSwitch,
		Enabled: true,
	}
	result := e.Evaluate(alive, Attributes{})
	assert.True(t, result.Enabled)

	killed := &Flag{
		Name:    "api_killed",
		Type:    FlagTypeKillSwitch,
		Enabled: false,
	}
	result = e.Evaluate(killed, Attributes{})
	assert.False(t, result.Enabled)
}

func TestEvaluator_UnknownType(t *testing.T) {
	e := NewEvaluator()
	flag := &Flag{
		Name:    "unknown",
		Type:    FlagType("custom"),
		Enabled: true,
	}

	result := e.Evaluate(flag, Attributes{})
	assert.False(t, result.Enabled)
	assert.Equal(t, "unknown_flag_type", result.Reason)
}

func TestConsistentHash_Deterministic(t *testing.T) {
	key := "test_flag:tenant_1:user_42"
	first := consistentHash(key, 100)
	for i := 0; i < 100; i++ {
		assert.Equal(t, first, consistentHash(key, 100))
	}
}

func TestConsistentHash_ZeroBuckets(t *testing.T) {
	assert.Equal(t, 0, consistentHash("any", 0))
}

func TestConsistentHash_SingleBucket(t *testing.T) {
	assert.Equal(t, 0, consistentHash("any", 1))
}

func TestInMemoryEvaluationLogger(t *testing.T) {
	logger := NewInMemoryEvaluationLogger()
	ctx := context.Background()

	logger.LogEvaluation(ctx, EvaluationResult{
		FlagName: "test",
		Enabled:  true,
		Reason:   "flag_enabled",
	}, Attributes{"user_id": "u1"})

	entries := logger.Entries()
	require.Len(t, entries, 1)
	assert.Equal(t, "test", entries[0].FlagName)
	assert.True(t, entries[0].Enabled)
	assert.Equal(t, "u1", entries[0].Attributes["user_id"])

	logger.Clear()
	assert.Empty(t, logger.Entries())
}

func TestNopEvaluationLogger(t *testing.T) {
	// Verify it does not panic.
	nop := NopEvaluationLogger{}
	nop.LogEvaluation(context.Background(), EvaluationResult{}, Attributes{})
}

func TestEvaluator_TargetingRuleWithMultivariate(t *testing.T) {
	e := NewEvaluator()
	flag := &Flag{
		Name:    "targeted_multi",
		Type:    FlagTypeMultivariate,
		Enabled: true,
		Variants: []Variant{
			{Key: "control", Weight: 50},
			{Key: "treatment", Weight: 50},
		},
		TargetingRules: []TargetingRule{
			{Attribute: "tenant_id", Operator: "eq", Values: []string{"vip"}},
		},
		DefaultVariant: "control",
	}

	// VIP tenant is enabled with a variant selected.
	result := e.Evaluate(flag, Attributes{"tenant_id": "vip", "user_id": "u1"})
	assert.True(t, result.Enabled)
	assert.NotEmpty(t, result.VariantKey)
	assert.Contains(t, result.Reason, "targeting_rule_match")
}

func TestBuildHashKey_WithTenantAndUser(t *testing.T) {
	e := NewEvaluator()
	key := e.buildHashKey("flag", Attributes{"tenant_id": "t1", "user_id": "u1"})
	assert.Equal(t, "flag:t1:u1", key)
}

func TestBuildHashKey_TenantOnly(t *testing.T) {
	e := NewEvaluator()
	key := e.buildHashKey("flag", Attributes{"tenant_id": "t1"})
	assert.Equal(t, "flag:t1", key)
}

func TestBuildHashKey_NoIdentifiers(t *testing.T) {
	e := NewEvaluator()
	key := e.buildHashKey("flag", Attributes{"region": "us-east"})
	assert.Contains(t, key, "flag:")
	assert.Contains(t, key, "region=us-east")
}

func TestBuildHashKey_Empty(t *testing.T) {
	e := NewEvaluator()
	key := e.buildHashKey("flag", Attributes{})
	assert.Equal(t, "flag", key)
}
