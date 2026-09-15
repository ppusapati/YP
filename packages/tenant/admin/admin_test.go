package admin

import (
	"context"
	"errors"
	"testing"
	"time"

	"p9e.in/samavaya/packages/audit"
	"p9e.in/samavaya/packages/connect/interceptors"
	p9context "p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/saas"
)

// This package reads across the tenant boundary that everything else on the
// platform enforces, so the authorization tests matter more than the
// aggregation ones. A bug here exposes every tenant at once rather than one.

var now = time.Date(2026, 6, 15, 12, 0, 0, 0, time.UTC)

// recordingAudit captures what was written, and can be made to fail.
type recordingAudit struct {
	entries []audit.AuditEntry
	err     error
}

func (a *recordingAudit) Log(_ context.Context, e audit.AuditEntry) error {
	if a.err != nil {
		return a.err
	}
	a.entries = append(a.entries, e)
	return nil
}

func (a *recordingAudit) Query(context.Context, audit.AuditFilter) ([]audit.AuditEntry, error) {
	return nil, nil
}

func (a *recordingAudit) EnsureSchema(context.Context) error { return nil }

// ctxAs builds a context for a user in a role.
func ctxAs(role interceptors.Role) context.Context {
	return p9context.NewUserContext(context.Background(), p9context.UserContext{
		UserID:   "u-1",
		TenantID: "t-1",
		Role:     string(role),
	})
}

// stubRegistry is a tenant registry with a fixed set of tenants.
type stubRegistry struct {
	tenants []saas.TenantConfig
	err     error
}

func (r *stubRegistry) ListAll(context.Context) ([]saas.TenantConfig, error) {
	return r.tenants, r.err
}

// stubUsage is a usage store with fixed snapshots.
type stubUsage struct {
	snapshots map[string]UsageSnapshot
	err       error
}

func (u *stubUsage) Usage(context.Context) (map[string]UsageSnapshot, error) {
	return u.snapshots, u.err
}

// newService builds a service whose registry is never reached: every test
// below stops at authorize, which runs first. That ordering is itself the
// point — there is no path to the data that skips the check.
func newService(a audit.AuditLogger) *Service {
	return &Service{
		registry: &stubRegistry{},
		audit:    a,
		now:      func() time.Time { return now },
	}
}

// newServiceWith builds a service over fixed data, for the listing tests.
func newServiceWith(tenants []saas.TenantConfig, usage map[string]UsageSnapshot) *Service {
	return &Service{
		registry: &stubRegistry{tenants: tenants},
		usage:    &stubUsage{snapshots: usage},
		audit:    &recordingAudit{},
		now:      func() time.Time { return now },
	}
}

// ── The boundary ────────────────────────────────────────────────────────────

func TestATenantAdminCannotReachAcrossTenants(t *testing.T) {
	// The single most important test in this package. A tenant admin is the
	// highest authority *inside* their tenant, and "admin" reads like it should
	// be enough — which is exactly why the check is against the platform role
	// specifically rather than RoleAtLeast(RoleAdmin).
	a := &recordingAudit{}
	svc := newService(a)

	err := svc.authorize(ctxAs(interceptors.RoleAdmin), "ListTenants", "PlatformTenants")
	if err == nil {
		t.Fatal("a tenant admin was allowed cross-tenant access")
	}
	if len(a.entries) != 1 || a.entries[0].Result != "failure" {
		t.Errorf("the refused attempt was not audited: %+v", a.entries)
	}
}

func TestEveryTenantScopedRoleIsRefused(t *testing.T) {
	for _, role := range []interceptors.Role{
		interceptors.RoleViewer,
		interceptors.RoleWorker,
		interceptors.RoleManager,
		interceptors.RoleAdmin,
	} {
		svc := newService(&recordingAudit{})
		if err := svc.authorize(ctxAs(role), "ListTenants", "PlatformTenants"); err == nil {
			t.Errorf("role %q was allowed cross-tenant access", role)
		}
	}
}

func TestAnUnknownRoleIsRefused(t *testing.T) {
	// A role string that does not match anything must fail closed. A token
	// carrying a role this build does not recognise is not a reason to grant
	// the widest access on the platform.
	svc := newService(&recordingAudit{})
	if err := svc.authorize(ctxAs("superuser"), "ListTenants", "PlatformTenants"); err == nil {
		t.Error("an unrecognised role was allowed cross-tenant access")
	}
}

func TestAnUnauthenticatedCallerIsRefused(t *testing.T) {
	svc := newService(&recordingAudit{})
	if err := svc.authorize(context.Background(), "ListTenants", "PlatformTenants"); err == nil {
		t.Error("a request with no user context was allowed")
	}
}

func TestThePlatformRoleIsAllowed(t *testing.T) {
	a := &recordingAudit{}
	svc := newService(a)

	if err := svc.authorize(ctxAs(interceptors.RolePlatform), "ListTenants", "PlatformTenants"); err != nil {
		t.Fatalf("the platform role was refused: %v", err)
	}
	if len(a.entries) != 1 || a.entries[0].Result != "success" {
		t.Errorf("the access was not audited as a success: %+v", a.entries)
	}
	if a.entries[0].UserID != "u-1" || a.entries[0].Action != "ListTenants" {
		t.Errorf("the audit entry does not say who did what: %+v", a.entries[0])
	}
}

func TestAnUnauditableAccessIsRefused(t *testing.T) {
	// A cross-tenant read that is not recorded cannot be distinguished from a
	// breach afterwards, so a broken audit log closes the door rather than
	// leaving it open and quiet.
	svc := newService(&recordingAudit{err: errors.New("audit table unavailable")})

	if err := svc.authorize(ctxAs(interceptors.RolePlatform), "ListTenants", "PlatformTenants"); err == nil {
		t.Error("access was granted while the audit log was failing")
	}
}

func TestTheServiceRefusesToStartWithoutAnAuditLog(t *testing.T) {
	if _, err := New(&stubRegistry{}, nil, nil); err == nil {
		t.Error("a service was constructed with no audit logger")
	}
}

func TestTheServiceRefusesToStartWithoutARegistry(t *testing.T) {
	if _, err := New(nil, nil, &recordingAudit{}); err == nil {
		t.Error("a service was constructed with no tenant registry")
	}
}

// ── Listing ─────────────────────────────────────────────────────────────────

func TestATenantWithNoSnapshotIsUnknownNotHealthy(t *testing.T) {
	// Claiming health for a tenant nothing has measured is a guess, and
	// claiming a fault would page somebody for a missing measurement.
	svc := newServiceWith([]saas.TenantConfig{
		{ID: "t-1", Name: "acme", IsActive: true},
	}, nil)

	got, err := svc.ListTenants(ctxAs(interceptors.RolePlatform))
	if err != nil {
		t.Fatalf("ListTenants: %v", err)
	}
	if len(got) != 1 {
		t.Fatalf("got %d tenants, want 1", len(got))
	}
	if got[0].Health != HealthUnknown {
		t.Errorf("health %q for an unmeasured tenant, want unknown", got[0].Health)
	}
	if got[0].HealthReason == "" {
		t.Error("no reason given for an unknown tenant")
	}
}

func TestASuspendedTenantStaysInTheListing(t *testing.T) {
	// A suspended tenant vanishing from this list is how an offboarding gets
	// lost: it is exactly the one an operator needs to be able to find.
	svc := newServiceWith([]saas.TenantConfig{
		{ID: "t-1", Name: "acme", IsActive: false},
	}, map[string]UsageSnapshot{
		"t-1": {TenantID: "t-1", Farms: 2, Fields: 5, Users: 3,
			LastActivityAt: ago(time.Hour), GatheredAt: now},
	})

	got, err := svc.ListTenants(ctxAs(interceptors.RolePlatform))
	if err != nil {
		t.Fatalf("ListTenants: %v", err)
	}
	if len(got) != 1 || got[0].Health != HealthSuspended {
		t.Errorf("suspended tenant listed as %v", got)
	}
}

func TestUsageAgeIsCarriedThrough(t *testing.T) {
	// A stale number presented as current is how an operator concludes nothing
	// is wrong.
	gathered := now.Add(-6 * time.Hour)
	svc := newServiceWith([]saas.TenantConfig{
		{ID: "t-1", Name: "acme", IsActive: true},
	}, map[string]UsageSnapshot{
		"t-1": {TenantID: "t-1", Farms: 2, Fields: 5, Users: 3,
			LastActivityAt: ago(time.Hour), GatheredAt: gathered},
	})

	got, err := svc.ListTenants(ctxAs(interceptors.RolePlatform))
	if err != nil {
		t.Fatalf("ListTenants: %v", err)
	}
	if !got[0].UsageGatheredAt.Equal(gathered) {
		t.Errorf("usage age %v, want %v", got[0].UsageGatheredAt, gathered)
	}
}

func TestATenantAdminCannotListTenants(t *testing.T) {
	// The full path, not just the authorize helper: no route to the data may
	// skip the check.
	svc := newServiceWith([]saas.TenantConfig{{ID: "t-1", Name: "acme", IsActive: true}}, nil)
	if _, err := svc.ListTenants(ctxAs(interceptors.RoleAdmin)); err == nil {
		t.Error("a tenant admin listed every tenant on the platform")
	}
}

// ── Health ──────────────────────────────────────────────────────────────────

func active(farms, fields, sensors, users int64, lastActivity *time.Time) TenantSummary {
	return TenantSummary{
		TenantID: "t-1", Name: "acme", IsActive: true,
		Farms: farms, Fields: fields, Sensors: sensors, Users: users,
		LastActivityAt: lastActivity,
	}
}

func ago(d time.Duration) *time.Time {
	t := now.Add(-d)
	return &t
}

func TestAWorkingTenantIsHealthy(t *testing.T) {
	s := active(3, 12, 8, 5, ago(2*time.Hour))
	if got, _ := s.DeriveHealth(now); got != HealthOK {
		t.Errorf("health %q, want ok", got)
	}
}

func TestASuspendedTenantIsNotReportedAsBroken(t *testing.T) {
	// Suspension is deliberate — usually mid-offboarding — and nobody should
	// be paged for it.
	s := active(3, 12, 8, 5, ago(2*time.Hour))
	s.IsActive = false

	got, reason := s.DeriveHealth(now)
	if got != HealthSuspended {
		t.Errorf("health %q, want suspended", got)
	}
	if reason == "" {
		t.Error("no reason given for a suspended tenant")
	}
}

func TestATenantThatNeverGotSetUpIsDegraded(t *testing.T) {
	// Provisioned, an admin created, and then nothing. Distinguished from
	// quiet: one never started, the other stopped.
	s := active(0, 0, 0, 1, nil)
	got, reason := s.DeriveHealth(now)
	if got != HealthDegraded {
		t.Errorf("health %q, want degraded", got)
	}
	if reason == "" {
		t.Error("no reason given")
	}
}

func TestAnIdleTenantIsQuietNotBroken(t *testing.T) {
	// Agriculture is seasonal. A farm between planting and harvest can go a
	// fortnight without anyone touching the system, and calling that a fault
	// turns the dashboard amber every August until nobody reads it.
	s := active(3, 12, 8, 5, ago(20*24*time.Hour))
	got, reason := s.DeriveHealth(now)
	if got != HealthQuiet {
		t.Errorf("health %q, want quiet", got)
	}
	if reason == "" {
		t.Error("no reason given")
	}

	// Inside the window it is simply healthy.
	s.LastActivityAt = ago(10 * 24 * time.Hour)
	if got, _ := s.DeriveHealth(now); got != HealthOK {
		t.Errorf("health %q after ten days, want ok", got)
	}
}

func TestSensorsWithNoFieldsIsDegraded(t *testing.T) {
	// The most common real fault, and the one a farmer notices last: hardware
	// installed and reporting against nothing.
	s := active(1, 0, 6, 3, ago(1*time.Hour))
	if got, _ := s.DeriveHealth(now); got != HealthDegraded {
		t.Errorf("health %q, want degraded", got)
	}
}

// ── Ordering and roll-up ────────────────────────────────────────────────────

func TestTenantsNeedingAttentionComeFirst(t *testing.T) {
	// A dashboard sorted by name buries the one broken tenant among nine
	// hundred working ones, which is the failure mode of most admin pages.
	tenants := []TenantSummary{
		{Name: "alpha", Health: HealthOK},
		{Name: "bravo", Health: HealthSuspended},
		{Name: "charlie", Health: HealthDegraded},
		{Name: "delta", Health: HealthQuiet},
		{Name: "echo", Health: HealthDegraded},
	}
	SortForAttention(tenants)

	want := []string{"charlie", "echo", "delta", "bravo", "alpha"}
	for i, name := range want {
		if tenants[i].Name != name {
			t.Fatalf("position %d is %q, want %q (full order: %v)", i, tenants[i].Name, name, names(tenants))
		}
	}
}

func TestTheOrderIsStableAcrossCalls(t *testing.T) {
	// A listing that reshuffles between refreshes is hard to read and harder
	// to trust.
	build := func() []TenantSummary {
		return []TenantSummary{
			{Name: "zulu", Health: HealthOK},
			{Name: "alpha", Health: HealthOK},
			{Name: "mike", Health: HealthOK},
		}
	}
	first := build()
	SortForAttention(first)
	for i := 0; i < 5; i++ {
		again := build()
		SortForAttention(again)
		for j := range first {
			if first[j].Name != again[j].Name {
				t.Fatalf("run %d differs: %v vs %v", i, names(first), names(again))
			}
		}
	}
}

func TestSummariseRollsUpTheTotals(t *testing.T) {
	stats := Summarise([]TenantSummary{
		{IsActive: true, Health: HealthOK, Farms: 3, Fields: 10, Sensors: 5, Users: 4},
		{IsActive: true, Health: HealthDegraded, Farms: 1, Fields: 0, Sensors: 6, Users: 2},
		{IsActive: false, Health: HealthSuspended, Farms: 2, Fields: 8, Sensors: 0, Users: 1},
	}, now)

	if stats.Tenants != 3 || stats.Active != 2 || stats.Suspended != 1 {
		t.Errorf("counts wrong: %+v", stats)
	}
	if stats.TotalFarms != 6 || stats.TotalFields != 18 || stats.TotalSensors != 11 || stats.TotalUsers != 7 {
		t.Errorf("totals wrong: %+v", stats)
	}
	// The number that leads the page is how many need attention, not the total.
	if stats.ByHealth[HealthDegraded] != 1 {
		t.Errorf("degraded count %d, want 1", stats.ByHealth[HealthDegraded])
	}
}

func TestSummariseHandlesNoTenants(t *testing.T) {
	stats := Summarise(nil, now)
	if stats.Tenants != 0 || stats.ByHealth == nil {
		t.Errorf("an empty platform produced %+v", stats)
	}
}

func names(ts []TenantSummary) []string {
	out := make([]string, len(ts))
	for i, t := range ts {
		out[i] = t.Name
	}
	return out
}
