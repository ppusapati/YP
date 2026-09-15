package featureflags

import (
	"path/filepath"
	"runtime"
	"testing"
)

// shippedConfig locates configs/feature-flags.yaml relative to this file, so
// the test does not depend on the working directory.
func shippedConfig(t *testing.T) string {
	t.Helper()
	_, thisFile, _, ok := runtime.Caller(0)
	if !ok {
		t.Skip("cannot locate the source tree")
	}
	return filepath.Join(filepath.Dir(thisFile), "..", "..", "configs", "feature-flags.yaml")
}

func TestShippedConfigurationLoads(t *testing.T) {
	// This is the test that would have caught the original bug: the file was
	// written as a map of flags with no `type` field, the loader wanted a list
	// with one, and nothing checked. The flags then evaluated as "not found",
	// which reads as "off", which is indistinguishable from a decision.
	cfg, err := LoadFlags(shippedConfig(t))
	if err != nil {
		t.Fatalf("the shipped flag configuration does not load: %v", err)
	}
	if len(cfg.Flags) == 0 {
		t.Fatal("the shipped configuration parsed to zero flags")
	}

	for _, f := range cfg.Flags {
		if f.Name == "" {
			t.Error("a flag came out with no name")
		}
		if f.Type == "" {
			t.Errorf("flag %q has no type; inference did not run", f.Name)
		}
	}
}

func TestFlagsMayBeWrittenAsAMapOrAList(t *testing.T) {
	asMap := []byte(`
flags:
  alpha:
    description: "first"
    enabled: true
  beta:
    description: "second"
    enabled: false
`)
	asList := []byte(`
flags:
  - name: alpha
    description: "first"
    enabled: true
  - name: beta
    description: "second"
    enabled: false
`)

	fromMap, err := ParseFlags(asMap, "flags.yaml")
	if err != nil {
		t.Fatalf("map form: %v", err)
	}
	fromList, err := ParseFlags(asList, "flags.yaml")
	if err != nil {
		t.Fatalf("list form: %v", err)
	}

	if len(fromMap.Flags) != 2 || len(fromList.Flags) != 2 {
		t.Fatalf("got %d and %d flags, want 2 each", len(fromMap.Flags), len(fromList.Flags))
	}
	// Declaration order is preserved for the map form, so a generated listing
	// does not churn between reads.
	for i := range fromMap.Flags {
		if fromMap.Flags[i].Name != fromList.Flags[i].Name {
			t.Errorf("flag %d: map form gave %q, list form gave %q",
				i, fromMap.Flags[i].Name, fromList.Flags[i].Name)
		}
	}
}

func TestFlagTypeIsInferredFromShape(t *testing.T) {
	// Restating in `type:` what the rest of the flag already says is a way of
	// collecting typos, so it is optional.
	data := []byte(`
flags:
  plain:
    enabled: true
  gradual:
    enabled: true
    rollout_percentage: 25
  switched:
    enabled: true
    kill_switch: true
  choices:
    enabled: true
    variants:
      - name: control
        weight: 50
      - name: treatment
        weight: 50
`)
	cfg, err := ParseFlags(data, "flags.yaml")
	if err != nil {
		t.Fatalf("ParseFlags: %v", err)
	}

	want := map[string]FlagType{
		"plain":    FlagTypeBoolean,
		"gradual":  FlagTypePercentage,
		"switched": FlagTypeKillSwitch,
		"choices":  FlagTypeMultivariate,
	}
	for _, f := range cfg.Flags {
		if got := f.Type; got != want[f.Name] {
			t.Errorf("flag %q inferred as %q, want %q", f.Name, got, want[f.Name])
		}
	}
}

func TestExplicitTypeWinsOverInference(t *testing.T) {
	data := []byte(`
flags:
  odd:
    type: boolean
    enabled: true
    rollout_percentage: 25
`)
	cfg, err := ParseFlags(data, "flags.yaml")
	if err != nil {
		t.Fatalf("ParseFlags: %v", err)
	}
	if cfg.Flags[0].Type != FlagTypeBoolean {
		t.Errorf("type %q, want the explicitly declared boolean", cfg.Flags[0].Type)
	}
}

func TestTargetingIsAnAliasForTargetingRules(t *testing.T) {
	data := []byte(`
flags:
  regional:
    enabled: true
    targeting:
      - attribute: region
        operator: in
        values: ["maharashtra", "karnataka"]
`)
	cfg, err := ParseFlags(data, "flags.yaml")
	if err != nil {
		t.Fatalf("ParseFlags: %v", err)
	}
	if len(cfg.Flags[0].TargetingRules) != 1 {
		t.Fatalf("got %d targeting rules, want 1", len(cfg.Flags[0].TargetingRules))
	}
	if cfg.Flags[0].TargetingRules[0].Attribute != "region" {
		t.Errorf("rule attribute %q", cfg.Flags[0].TargetingRules[0].Attribute)
	}
}

func TestVariantNameIsAnAliasForKey(t *testing.T) {
	data := []byte(`
flags:
  choices:
    enabled: true
    default_variant: control
    variants:
      - name: control
        weight: 100
      - key: treatment
        weight: 0
`)
	cfg, err := ParseFlags(data, "flags.yaml")
	if err != nil {
		t.Fatalf("ParseFlags: %v", err)
	}
	keys := []string{cfg.Flags[0].Variants[0].Key, cfg.Flags[0].Variants[1].Key}
	if keys[0] != "control" || keys[1] != "treatment" {
		t.Errorf("variant keys %v, want [control treatment]", keys)
	}
}

func TestTenantOverridesLoadFromConfig(t *testing.T) {
	data := []byte(`
flags:
  enhanced_irrigation:
    enabled: true
    rollout_percentage: 10
    tenants:
      tenant-a:
        enabled: true
        reason: "design partner, agreed early access"
        set_by: "ops@example.com"
      tenant-b:
        enabled: false
        reason: "SUP-1421: breaks their bulk import"
`)
	cfg, err := ParseFlags(data, "flags.yaml")
	if err != nil {
		t.Fatalf("ParseFlags: %v", err)
	}
	f := cfg.Flags[0]
	if len(f.TenantOverrides) != 2 {
		t.Fatalf("got %d overrides, want 2", len(f.TenantOverrides))
	}
	// Sorted by tenant, so repeated loads are identical.
	if f.TenantOverrides[0].TenantID != "tenant-a" {
		t.Errorf("overrides are not sorted: %v", f.TenantOverrides)
	}
	if f.TenantOverrides[0].FlagName != "enhanced_irrigation" {
		t.Error("the flag name was not filled in from the enclosing flag")
	}
	if !f.TenantOverrides[0].Enabled || f.TenantOverrides[1].Enabled {
		t.Error("override directions were not read correctly")
	}
	if f.TenantOverrides[1].Reason == "" {
		t.Error("the reason was dropped")
	}
}

func TestConfigRejectsAnOverridePinningAnUnknownVariant(t *testing.T) {
	// A pin to a variant that does not exist would silently evaluate to an
	// empty variant with no payload, which looks like a working flag.
	data := []byte(`
flags:
  ml_model_v2:
    enabled: true
    default_variant: v1
    variants:
      - name: v1
        weight: 100
    tenants:
      tenant-a:
        enabled: true
        variant: v3
`)
	if _, err := ParseFlags(data, "flags.yaml"); err == nil {
		t.Error("accepted an override pinned to a variant the flag does not define")
	}
}

func TestConfigRejectsTwoOverridesForOneTenant(t *testing.T) {
	// Not expressible in the map form — the key collides — so this is checked
	// through the list form, which is where it can happen.
	data := []byte(`
flags:
  - name: f
    enabled: true
    tenant_overrides:
      - tenant_id: t-1
        flag_name: f
        enabled: true
      - tenant_id: t-1
        flag_name: f
        enabled: false
`)
	if _, err := ParseFlags(data, "flags.yaml"); err == nil {
		t.Error("accepted two overrides for the same tenant, which resolve by declaration order")
	}
}

func TestJSONFlagsMayBeAnObjectOrAnArray(t *testing.T) {
	asObject := []byte(`{"flags":{"alpha":{"enabled":true},"beta":{"enabled":false}}}`)
	asArray := []byte(`{"flags":[{"name":"alpha","enabled":true},{"name":"beta","enabled":false}]}`)

	fromObject, err := ParseFlags(asObject, "flags.json")
	if err != nil {
		t.Fatalf("object form: %v", err)
	}
	fromArray, err := ParseFlags(asArray, "flags.json")
	if err != nil {
		t.Fatalf("array form: %v", err)
	}
	if len(fromObject.Flags) != 2 || len(fromArray.Flags) != 2 {
		t.Fatalf("got %d and %d flags, want 2 each", len(fromObject.Flags), len(fromArray.Flags))
	}
	// JSON objects have no defined order, so the object form is sorted to keep
	// repeated loads of the same file identical.
	if fromObject.Flags[0].Name != "alpha" || fromObject.Flags[1].Name != "beta" {
		t.Errorf("object form is not sorted by name: %v", fromObject.Flags)
	}
}
