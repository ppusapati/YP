package featureflags

import (
	"context"
	"testing"
	"time"
)

// A rollout flag that is on for a tenth of tenants: the setting in which every
// override question below is actually asked.
func rolloutFlag() Flag {
	return Flag{
		Name:              "enhanced_irrigation",
		Type:              FlagTypePercentage,
		Enabled:           true,
		RolloutPercentage: 10,
	}
}

// bucketedTenants finds one tenant the rollout includes and one it excludes, so
// the tests can assert an override changes the answer rather than agreeing with
// it by luck.
func bucketedTenants(t *testing.T, flag Flag) (included, excluded string) {
	t.Helper()
	e := NewEvaluator()
	for i := 0; i < 500; i++ {
		id := "tenant-" + itoa(i)
		f := flag
		if e.Evaluate(&f, Attributes{"tenant_id": id}).Enabled {
			if included == "" {
				included = id
			}
		} else if excluded == "" {
			excluded = id
		}
		if included != "" && excluded != "" {
			return included, excluded
		}
	}
	t.Fatalf("could not find both an included and an excluded tenant at %d%%", flag.RolloutPercentage)
	return "", ""
}

func itoa(i int) string {
	if i == 0 {
		return "0"
	}
	var b []byte
	for i > 0 {
		b = append([]byte{byte('0' + i%10)}, b...)
		i /= 10
	}
	return string(b)
}

func TestOverrideCanTurnAFlagOffForOneTenant(t *testing.T) {
	// This is the case targeting rules cannot express at all: a matching rule
	// only ever enables, and `not_in` enables everyone else instead. It is also
	// the request support actually receives most often — "this is breaking our
	// workflow, turn it off for us".
	flag := rolloutFlag()
	included, _ := bucketedTenants(t, flag)

	flag.TenantOverrides = []TenantOverride{{
		TenantID: included, FlagName: flag.Name, Enabled: false,
		Reason: "SUP-1421: breaks their bulk import",
	}}

	got := NewEvaluator().Evaluate(&flag, Attributes{"tenant_id": included})
	if got.Enabled {
		t.Error("override did not turn the flag off for the pinned tenant")
	}
	if got.Reason != "tenant_override:"+included {
		t.Errorf("reason %q does not say the override decided it", got.Reason)
	}
}

func TestOverrideCanTurnAFlagOnForOneTenant(t *testing.T) {
	flag := rolloutFlag()
	_, excluded := bucketedTenants(t, flag)

	flag.TenantOverrides = []TenantOverride{{
		TenantID: excluded, FlagName: flag.Name, Enabled: true,
		Reason: "design partner, agreed early access",
	}}

	if !NewEvaluator().Evaluate(&flag, Attributes{"tenant_id": excluded}).Enabled {
		t.Error("override did not turn the flag on for the pinned tenant")
	}
}

func TestOverrideBeatsAGloballyDisabledFlag(t *testing.T) {
	// "Turn it on for us early" is by definition a request about a flag that is
	// globally off. Checking Enabled before the override would make that the
	// one thing an override could never do.
	flag := Flag{Name: "new_dashboard_ui", Type: FlagTypeBoolean, Enabled: false}
	flag.TenantOverrides = []TenantOverride{{
		TenantID: "t-1", FlagName: flag.Name, Enabled: true, Reason: "pilot",
	}}

	if !NewEvaluator().Evaluate(&flag, Attributes{"tenant_id": "t-1"}).Enabled {
		t.Error("override could not enable a globally disabled flag")
	}
}

func TestOverrideBeatsAMatchingTargetingRule(t *testing.T) {
	// A region-wide rollout with one tenant in that region opted out. Without
	// precedence the rule wins and the opt-out is silently ignored.
	flag := Flag{
		Name: "enhanced_irrigation", Type: FlagTypeBoolean, Enabled: true,
		TargetingRules: []TargetingRule{
			{Attribute: "region", Operator: "in", Values: []string{"maharashtra"}},
		},
		TenantOverrides: []TenantOverride{
			{TenantID: "t-9", FlagName: "enhanced_irrigation", Enabled: false, Reason: "opted out"},
		},
	}

	attrs := Attributes{"tenant_id": "t-9", "region": "maharashtra"}
	if NewEvaluator().Evaluate(&flag, attrs).Enabled {
		t.Error("the targeting rule overrode the tenant's opt-out")
	}

	// And a different tenant in the same region is unaffected.
	other := Attributes{"tenant_id": "t-8", "region": "maharashtra"}
	if !NewEvaluator().Evaluate(&flag, other).Enabled {
		t.Error("the override leaked to a tenant it was not set for")
	}
}

func TestOverrideOnlyAppliesToItsOwnTenant(t *testing.T) {
	flag := rolloutFlag()
	included, excluded := bucketedTenants(t, flag)
	flag.TenantOverrides = []TenantOverride{{
		TenantID: included, FlagName: flag.Name, Enabled: false,
	}}

	// The excluded tenant should still be excluded by the rollout, not by the
	// override — a check that would pass for the wrong reason if the override
	// applied to everybody, so the included tenant is asserted too.
	if NewEvaluator().Evaluate(&flag, Attributes{"tenant_id": excluded}).Enabled {
		t.Error("an excluded tenant became enabled")
	}
	got := NewEvaluator().Evaluate(&flag, Attributes{"tenant_id": included})
	if got.Reason != "tenant_override:"+included {
		t.Errorf("the pinned tenant was decided by %q, not the override", got.Reason)
	}
}

func TestAnExpiredOverrideStopsApplying(t *testing.T) {
	// An override meant to cover an incident should not outlive it.
	flag := Flag{Name: "f", Type: FlagTypeBoolean, Enabled: true}
	past := time.Now().Add(-time.Hour)
	flag.TenantOverrides = []TenantOverride{{
		TenantID: "t-1", FlagName: "f", Enabled: false, ExpiresAt: &past,
	}}

	got := NewEvaluator().Evaluate(&flag, Attributes{"tenant_id": "t-1"})
	if !got.Enabled {
		t.Error("an expired override is still being applied")
	}
	if got.Reason == "tenant_override:t-1" {
		t.Error("the expired override still claims to have decided the result")
	}
}

func TestOverrideIsIgnoredWithoutATenant(t *testing.T) {
	// Background work with no tenant must not pick up somebody else's pin.
	flag := Flag{Name: "f", Type: FlagTypeBoolean, Enabled: true}
	flag.TenantOverrides = []TenantOverride{{TenantID: "t-1", FlagName: "f", Enabled: false}}

	if !NewEvaluator().Evaluate(&flag, Attributes{}).Enabled {
		t.Error("an override applied to an evaluation with no tenant")
	}
}

func TestOverrideCanPinAVariant(t *testing.T) {
	flag := Flag{
		Name: "ml_model_v2", Type: FlagTypeMultivariate, Enabled: true,
		DefaultVariant: "v1",
		Variants: []Variant{
			{Key: "v1", Weight: 100, Payload: map[string]interface{}{"model": "v1"}},
			{Key: "v2", Weight: 0, Payload: map[string]interface{}{"model": "v2"}},
		},
		TenantOverrides: []TenantOverride{
			{TenantID: "t-1", FlagName: "ml_model_v2", Enabled: true, Variant: "v2"},
		},
	}

	got := NewEvaluator().Evaluate(&flag, Attributes{"tenant_id": "t-1"})
	if got.VariantKey != "v2" {
		t.Errorf("variant %q, want the pinned v2", got.VariantKey)
	}
	// The payload has to follow the variant, or the caller gets v2 as a label
	// and v1's configuration to run it with.
	if got.Payload["model"] != "v2" {
		t.Errorf("payload %v does not match the pinned variant", got.Payload)
	}
}

// ── Runtime store ───────────────────────────────────────────────────────────

func TestRuntimeOverrideAppliesThroughTheService(t *testing.T) {
	store := NewInMemoryOverrideStore()
	svc := NewInMemoryFlagService(WithOverrideStore(store))
	svc.SetFlag(Flag{Name: "beta", Type: FlagTypeBoolean, Enabled: false})

	ctx := context.Background()
	if svc.IsEnabled(ctx, "beta", Attributes{"tenant_id": "t-1"}) {
		t.Fatal("flag started enabled")
	}

	// The point of a store rather than a config file: this takes effect now,
	// not at the next deploy.
	if err := store.SetOverride(ctx, TenantOverride{
		TenantID: "t-1", FlagName: "beta", Enabled: true, Reason: "SUP-77",
	}); err != nil {
		t.Fatalf("SetOverride: %v", err)
	}
	if !svc.IsEnabled(ctx, "beta", Attributes{"tenant_id": "t-1"}) {
		t.Error("the runtime override did not take effect")
	}
	if svc.IsEnabled(ctx, "beta", Attributes{"tenant_id": "t-2"}) {
		t.Error("the override leaked to another tenant")
	}

	if err := store.ClearOverride(ctx, "t-1", "beta"); err != nil {
		t.Fatalf("ClearOverride: %v", err)
	}
	if svc.IsEnabled(ctx, "beta", Attributes{"tenant_id": "t-1"}) {
		t.Error("the override survived being cleared")
	}
}

func TestRuntimeOverrideBeatsAConfigDeclaredOne(t *testing.T) {
	// The file carries the long-lived decision; the store carries the one made
	// in response to something happening right now, so the store wins.
	store := NewInMemoryOverrideStore()
	svc := NewInMemoryFlagService(WithOverrideStore(store))
	svc.SetFlag(Flag{
		Name: "beta", Type: FlagTypeBoolean, Enabled: true,
		TenantOverrides: []TenantOverride{
			{TenantID: "t-1", FlagName: "beta", Enabled: true, Reason: "contract"},
		},
	})

	ctx := context.Background()
	if err := store.SetOverride(ctx, TenantOverride{
		TenantID: "t-1", FlagName: "beta", Enabled: false, Reason: "incident INC-3",
	}); err != nil {
		t.Fatalf("SetOverride: %v", err)
	}
	if svc.IsEnabled(ctx, "beta", Attributes{"tenant_id": "t-1"}) {
		t.Error("the config-declared override outranked the runtime one")
	}
}

func TestStoreRejectsAnOverrideThatIdentifiesNothing(t *testing.T) {
	store := NewInMemoryOverrideStore()
	ctx := context.Background()

	if err := store.SetOverride(ctx, TenantOverride{FlagName: "beta", Enabled: true}); err == nil {
		t.Error("accepted an override with no tenant")
	}
	if err := store.SetOverride(ctx, TenantOverride{TenantID: "t-1", Enabled: true}); err == nil {
		t.Error("accepted an override with no flag")
	}

	past := time.Now().Add(-time.Hour)
	err := store.SetOverride(ctx, TenantOverride{
		TenantID: "t-1", FlagName: "beta", SetAt: time.Now(), ExpiresAt: &past,
	})
	if err == nil {
		t.Error("accepted an override that expired before it was set")
	}
}

func TestStoreStampsSetAt(t *testing.T) {
	// An override with no timestamp cannot be reviewed later, which is how one
	// becomes permanent.
	store := NewInMemoryOverrideStore()
	ctx := context.Background()
	if err := store.SetOverride(ctx, TenantOverride{
		TenantID: "t-1", FlagName: "beta", Enabled: true,
	}); err != nil {
		t.Fatalf("SetOverride: %v", err)
	}
	o, ok := store.Override(ctx, "t-1", "beta")
	if !ok {
		t.Fatal("override not found")
	}
	if o.SetAt.IsZero() {
		t.Error("SetAt was not stamped")
	}
}

func TestExpiredOverridesAreHiddenAndPrunable(t *testing.T) {
	store := NewInMemoryOverrideStore()
	ctx := context.Background()
	past := time.Now().Add(-time.Hour)
	future := time.Now().Add(time.Hour)

	// SetAt is left in the past so the expiry is after it and passes validation.
	mustSet(t, store, TenantOverride{
		TenantID: "t-1", FlagName: "gone", Enabled: true,
		SetAt: past.Add(-time.Hour), ExpiresAt: &past,
	})
	mustSet(t, store, TenantOverride{
		TenantID: "t-1", FlagName: "live", Enabled: true, ExpiresAt: &future,
	})

	if _, ok := store.Override(ctx, "t-1", "gone"); ok {
		t.Error("an expired override was returned")
	}
	if _, ok := store.Override(ctx, "t-1", "live"); !ok {
		t.Error("a live override was not returned")
	}

	// The listing has to agree with evaluation, or an operator reading it sees
	// overrides that are not actually in force.
	list, err := store.ListOverrides(ctx, "t-1")
	if err != nil {
		t.Fatalf("ListOverrides: %v", err)
	}
	if len(list) != 1 || list[0].FlagName != "live" {
		t.Errorf("listing returned %v, want only the live override", list)
	}

	if n := store.PruneExpired(); n != 1 {
		t.Errorf("pruned %d, want 1", n)
	}
	if n := store.PruneExpired(); n != 0 {
		t.Errorf("pruned %d on a second pass, want 0", n)
	}
}

func TestListOverridesAcrossAllTenants(t *testing.T) {
	store := NewInMemoryOverrideStore()
	mustSet(t, store, TenantOverride{TenantID: "t-2", FlagName: "b", Enabled: true})
	mustSet(t, store, TenantOverride{TenantID: "t-1", FlagName: "a", Enabled: false})

	list, err := store.ListOverrides(context.Background(), "")
	if err != nil {
		t.Fatalf("ListOverrides: %v", err)
	}
	if len(list) != 2 {
		t.Fatalf("got %d overrides, want 2", len(list))
	}
	// Sorted, so an audit listing does not reshuffle between reads.
	if list[0].TenantID != "t-1" || list[1].TenantID != "t-2" {
		t.Errorf("listing is not sorted by tenant: %v", list)
	}
}

func TestIsEnabledForTenant(t *testing.T) {
	svc := NewInMemoryFlagService()
	svc.SetFlag(Flag{
		Name: "f", Type: FlagTypeBoolean, Enabled: false,
		TenantOverrides: []TenantOverride{{TenantID: "t-1", FlagName: "f", Enabled: true}},
	})

	ctx := context.Background()
	if !IsEnabledForTenant(ctx, svc, "f", "t-1") {
		t.Error("IsEnabledForTenant did not apply the tenant's override")
	}
	if IsEnabledForTenant(ctx, svc, "f", "t-2") {
		t.Error("IsEnabledForTenant enabled the flag for the wrong tenant")
	}
	// A nil service is what a caller gets when flags were never wired up; it
	// must read as "off" rather than panicking mid-request.
	if IsEnabledForTenant(ctx, nil, "f", "t-1") {
		t.Error("a nil service reported a flag as enabled")
	}
}

func mustSet(t *testing.T, store *InMemoryOverrideStore, o TenantOverride) {
	t.Helper()
	if err := store.SetOverride(context.Background(), o); err != nil {
		t.Fatalf("SetOverride(%s/%s): %v", o.TenantID, o.FlagName, err)
	}
}
