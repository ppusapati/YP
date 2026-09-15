package featureflags

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestLoadFlags_JSON(t *testing.T) {
	dir := t.TempDir()
	path := filepath.Join(dir, "flags.json")
	content := `{
		"flags": [
			{"name": "test_bool", "type": "boolean", "enabled": true},
			{"name": "test_pct", "type": "percentage", "enabled": true, "rollout_percentage": 25}
		]
	}`
	require.NoError(t, os.WriteFile(path, []byte(content), 0644))

	config, err := LoadFlags(path)
	require.NoError(t, err)
	assert.Len(t, config.Flags, 2)
	assert.Equal(t, "test_bool", config.Flags[0].Name)
	assert.Equal(t, 25, config.Flags[1].RolloutPercentage)
}

func TestLoadFlags_YAML(t *testing.T) {
	dir := t.TempDir()
	path := filepath.Join(dir, "flags.yaml")
	content := `flags:
  - name: yaml_flag
    type: boolean
    enabled: true
    description: "A YAML flag"
  - name: yaml_pct
    type: percentage
    enabled: true
    rollout_percentage: 50
`
	require.NoError(t, os.WriteFile(path, []byte(content), 0644))

	config, err := LoadFlags(path)
	require.NoError(t, err)
	assert.Len(t, config.Flags, 2)
	assert.Equal(t, "yaml_flag", config.Flags[0].Name)
	assert.Equal(t, FlagTypeBoolean, config.Flags[0].Type)
}

func TestLoadFlags_YML(t *testing.T) {
	dir := t.TempDir()
	path := filepath.Join(dir, "flags.yml")
	content := `flags:
  - name: yml_flag
    type: boolean
    enabled: false
`
	require.NoError(t, os.WriteFile(path, []byte(content), 0644))

	config, err := LoadFlags(path)
	require.NoError(t, err)
	assert.Len(t, config.Flags, 1)
}

func TestLoadFlags_FileNotFound(t *testing.T) {
	_, err := LoadFlags("/nonexistent/flags.yaml")
	assert.Error(t, err)
}

func TestLoadFlags_UnsupportedFormat(t *testing.T) {
	dir := t.TempDir()
	path := filepath.Join(dir, "flags.toml")
	require.NoError(t, os.WriteFile(path, []byte(""), 0644))

	_, err := LoadFlags(path)
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "unsupported config format")
}

func TestFlagConfig_Validate_EmptyName(t *testing.T) {
	config := &FlagConfig{
		Flags: []Flag{{Name: "", Type: FlagTypeBoolean}},
	}
	err := config.Validate()
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "empty name")
}

func TestFlagConfig_Validate_DuplicateName(t *testing.T) {
	config := &FlagConfig{
		Flags: []Flag{
			{Name: "dup", Type: FlagTypeBoolean},
			{Name: "dup", Type: FlagTypeBoolean},
		},
	}
	err := config.Validate()
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "duplicate flag name")
}

func TestFlagConfig_Validate_InvalidPercentage(t *testing.T) {
	config := &FlagConfig{
		Flags: []Flag{
			{Name: "bad_pct", Type: FlagTypePercentage, RolloutPercentage: 101},
		},
	}
	err := config.Validate()
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "invalid rollout_percentage")

	config.Flags[0].RolloutPercentage = -1
	err = config.Validate()
	assert.Error(t, err)
}

func TestFlagConfig_Validate_MultivariateNoVariants(t *testing.T) {
	config := &FlagConfig{
		Flags: []Flag{
			{Name: "no_variants", Type: FlagTypeMultivariate},
		},
	}
	err := config.Validate()
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "no variants")
}

func TestFlagConfig_Validate_MultivariateEmptyVariantKey(t *testing.T) {
	config := &FlagConfig{
		Flags: []Flag{
			{Name: "empty_key", Type: FlagTypeMultivariate, Variants: []Variant{{Key: ""}}},
		},
	}
	err := config.Validate()
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "empty key")
}

func TestFlagConfig_Validate_MultivariatesDuplicateVariantKey(t *testing.T) {
	config := &FlagConfig{
		Flags: []Flag{
			{Name: "dup_variant", Type: FlagTypeMultivariate, Variants: []Variant{
				{Key: "a", Weight: 50},
				{Key: "a", Weight: 50},
			}},
		},
	}
	err := config.Validate()
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "duplicate variant key")
}

func TestFlagConfig_Validate_EmptyType(t *testing.T) {
	config := &FlagConfig{
		Flags: []Flag{{Name: "no_type", Type: ""}},
	}
	err := config.Validate()
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "empty type")
}

func TestFlagConfig_Validate_UnknownType(t *testing.T) {
	config := &FlagConfig{
		Flags: []Flag{{Name: "bad_type", Type: FlagType("custom")}},
	}
	err := config.Validate()
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "unknown type")
}

func TestFlagConfig_Validate_TargetingRuleEmptyAttribute(t *testing.T) {
	config := &FlagConfig{
		Flags: []Flag{
			{
				Name: "bad_rule", Type: FlagTypeBoolean,
				TargetingRules: []TargetingRule{{Attribute: "", Operator: "eq", Values: []string{"v"}}},
			},
		},
	}
	err := config.Validate()
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "empty attribute")
}

func TestFlagConfig_Validate_TargetingRuleUnknownOperator(t *testing.T) {
	config := &FlagConfig{
		Flags: []Flag{
			{
				Name: "bad_op", Type: FlagTypeBoolean,
				TargetingRules: []TargetingRule{{Attribute: "x", Operator: "gt", Values: []string{"v"}}},
			},
		},
	}
	err := config.Validate()
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "unknown operator")
}

func TestFlagConfig_Validate_TargetingRuleNoValues(t *testing.T) {
	config := &FlagConfig{
		Flags: []Flag{
			{
				Name: "no_vals", Type: FlagTypeBoolean,
				TargetingRules: []TargetingRule{{Attribute: "x", Operator: "eq", Values: []string{}}},
			},
		},
	}
	err := config.Validate()
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "no values")
}

func TestFlagConfig_Validate_Valid(t *testing.T) {
	config := &FlagConfig{
		Flags: []Flag{
			{Name: "bool", Type: FlagTypeBoolean, Enabled: true},
			{Name: "pct", Type: FlagTypePercentage, RolloutPercentage: 50},
			{Name: "multi", Type: FlagTypeMultivariate, Variants: []Variant{
				{Key: "a", Weight: 50}, {Key: "b", Weight: 50},
			}},
			{Name: "ks", Type: FlagTypeKillSwitch, Enabled: true},
		},
	}
	assert.NoError(t, config.Validate())
}

func TestLoadFlagsFromEnv(t *testing.T) {
	config := &FlagConfig{
		Flags: []Flag{
			{Name: "my_flag", Type: FlagTypeBoolean, Enabled: false},
			{Name: "other_flag", Type: FlagTypeBoolean, Enabled: true},
		},
	}

	t.Setenv("FF_MY_FLAG", "enabled")
	t.Setenv("FF_OTHER_FLAG", "disabled")

	LoadFlagsFromEnv(config)

	assert.True(t, config.Flags[0].Enabled)
	assert.False(t, config.Flags[1].Enabled)
}

func TestLoadFlagsFromEnv_VariousValues(t *testing.T) {
	tests := []struct {
		envValue string
		expected bool
	}{
		{"enabled", true},
		{"true", true},
		{"1", true},
		{"on", true},
		{"disabled", false},
		{"false", false},
		{"0", false},
		{"off", false},
	}

	for _, tt := range tests {
		t.Run(tt.envValue, func(t *testing.T) {
			config := &FlagConfig{
				Flags: []Flag{{Name: "env_flag", Type: FlagTypeBoolean, Enabled: !tt.expected}},
			}
			t.Setenv("FF_ENV_FLAG", tt.envValue)
			LoadFlagsFromEnv(config)
			assert.Equal(t, tt.expected, config.Flags[0].Enabled)
		})
	}
}

func TestLoadFlagsFromEnv_UnknownFlag(t *testing.T) {
	config := &FlagConfig{
		Flags: []Flag{{Name: "known", Type: FlagTypeBoolean, Enabled: false}},
	}
	t.Setenv("FF_UNKNOWN", "enabled")
	LoadFlagsFromEnv(config)
	// Unknown flags should be ignored.
	assert.False(t, config.Flags[0].Enabled)
}

func TestParseFlags_InvalidJSON(t *testing.T) {
	_, err := ParseFlags([]byte("not json"), "flags.json")
	assert.Error(t, err)
}

func TestParseFlags_InvalidYAML(t *testing.T) {
	_, err := ParseFlags([]byte("not:\nyaml: ["), "flags.yaml")
	assert.Error(t, err)
}

func TestParseFlags_ValidationError(t *testing.T) {
	// Valid YAML but invalid config (empty name).
	yaml := `flags:
  - name: ""
    type: boolean
`
	_, err := ParseFlags([]byte(yaml), "flags.yaml")
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "empty name")
}
