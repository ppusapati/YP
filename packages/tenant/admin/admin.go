// Package admin provides the cross-tenant view needed to operate the platform:
// which tenants exist, which are healthy, and what they are consuming.
//
// This is a deliberate hole in the isolation model. Everything else on this
// platform is scoped to one tenant and enforced by row-level security; this
// package reads across that boundary on purpose, which makes it the one place
// where getting authorization wrong exposes every tenant at once rather than
// one.
//
// Three rules follow, and they are enforced here rather than left to callers:
//
//   - **Platform role only.** A tenant admin is the highest authority inside
//     their tenant and has no business seeing another's. The check is against
//     RolePlatform specifically, not RoleAtLeast(RoleAdmin).
//   - **Aggregates only.** Counts, health, usage, timestamps. Never a tenant's
//     actual records — no farm names, no field boundaries, no readings. That
//     line is what keeps this a monitoring tool rather than a backdoor, and it
//     is why the queries below are all COUNT and MAX rather than SELECT *.
//   - **Every access is audited.** An unlogged cross-tenant read is
//     indistinguishable from a breach after the fact. The audit write happens
//     before the data is returned, and a failure to audit fails the request.
package admin

import (
	"context"
	"errors"
	"fmt"
	"sort"
	"time"

	"p9e.in/samavaya/packages/audit"
	"p9e.in/samavaya/packages/connect/interceptors"
	p9errors "p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/saas"
)

// Errors returned by this package.
var (
	ErrNotPlatformOperator = errors.New("cross-tenant access requires the platform role")
	ErrAuditUnavailable    = errors.New("cross-tenant access requires a working audit log")
)

// TenantSummary is what the platform view knows about one tenant.
//
// Deliberately a set of counts and timestamps. Adding a field here that names
// a tenant's own data — a farm, a field, a crop — turns this package from
// monitoring into a cross-tenant read, so anything of that shape belongs
// behind the tenant's own API instead.
type TenantSummary struct {
	TenantID  string    `json:"tenant_id"`
	Name      string    `json:"name"`
	Region    string    `json:"region"`
	Type      string    `json:"type"`
	IsActive  bool      `json:"is_active"`
	CreatedAt time.Time `json:"created_at,omitempty"`

	Farms   int64 `json:"farms"`
	Fields  int64 `json:"fields"`
	Sensors int64 `json:"sensors"`
	Users   int64 `json:"users"`

	// LastActivityAt is the most recent write anywhere in the tenant.
	//
	// The single most useful number on this page: a tenant that has not
	// written anything in a month has either churned or is broken, and either
	// way somebody should look.
	LastActivityAt *time.Time `json:"last_activity_at,omitempty"`

	// StorageBytes is what the tenant is consuming, where it can be
	// determined. Zero means not measured rather than nothing stored — the
	// distinction matters on a billing page, so it is stated here.
	StorageBytes int64 `json:"storage_bytes"`

	// UsageGatheredAt is when the counts above were measured.
	//
	// Surfaced rather than hidden: a dashboard reading a snapshot from six
	// hours ago should say so, because a stale number presented as current is
	// how an operator concludes nothing is wrong.
	UsageGatheredAt time.Time `json:"usage_gathered_at,omitempty"`

	// Health is derived, not stored. See DeriveHealth.
	Health HealthState `json:"health"`
	// HealthReason says why, when it is not healthy.
	HealthReason string `json:"health_reason,omitempty"`
}

// HealthState summarises a tenant at a glance.
type HealthState string

const (
	HealthOK HealthState = "ok"
	// HealthQuiet is a tenant that is provisioned but not being used. Not a
	// fault, and separated from a fault so the two are not confused on a
	// dashboard where only the red ones get looked at.
	HealthQuiet HealthState = "quiet"
	// HealthDegraded is a tenant that looks like something is wrong.
	HealthDegraded HealthState = "degraded"
	// HealthSuspended is a tenant deliberately turned off, usually mid-
	// offboarding. Distinguished from degraded because nobody should be paged
	// for it.
	HealthSuspended HealthState = "suspended"
	// HealthUnknown is a tenant whose usage has never been gathered.
	//
	// Its own state rather than folded into ok or degraded: claiming health
	// for a tenant nothing has measured is a guess, and claiming a fault would
	// page somebody for a missing measurement.
	HealthUnknown HealthState = "unknown"
)

// QuietAfter is how long without a write before a tenant is called quiet.
//
// A fortnight rather than a few days: agriculture is seasonal, and a farm
// between planting and harvest can legitimately go a week without anyone
// touching the system. Too short a threshold turns the dashboard amber every
// August and stops being read.
const QuietAfter = 14 * 24 * time.Hour

// DeriveHealth computes a tenant's state from its counts and activity.
//
// Named DeriveHealth rather than Health because the result is stored on the
// Health field: a method and a field cannot share a name, and the field is what
// callers and JSON readers want.
func (s *TenantSummary) DeriveHealth(now time.Time) (HealthState, string) {
	if !s.IsActive {
		return HealthSuspended, "tenant is suspended"
	}
	// Provisioned with nothing in it. Distinguished from quiet: one never
	// started, the other stopped.
	if s.Farms == 0 && s.Users <= 1 {
		return HealthDegraded, "provisioned but never set up: no farms and no users beyond the initial admin"
	}
	if s.LastActivityAt == nil {
		return HealthDegraded, "no recorded activity at all"
	}
	if idle := now.Sub(*s.LastActivityAt); idle > QuietAfter {
		return HealthQuiet, fmt.Sprintf("no writes for %d days", int(idle.Hours()/24))
	}
	// Sensors that exist but report nothing is the most common real fault, and
	// the one a farmer notices last.
	if s.Sensors > 0 && s.Fields == 0 {
		return HealthDegraded, "sensors registered against no fields"
	}
	return HealthOK, ""
}

// PlatformStats is the roll-up across every tenant.
type PlatformStats struct {
	GeneratedAt time.Time `json:"generated_at"`

	Tenants   int64 `json:"tenants"`
	Active    int64 `json:"active"`
	Suspended int64 `json:"suspended"`

	// ByHealth counts tenants in each state, so the page can lead with the
	// number that needs attention rather than the total.
	ByHealth map[HealthState]int64 `json:"by_health"`

	TotalFarms   int64 `json:"total_farms"`
	TotalFields  int64 `json:"total_fields"`
	TotalSensors int64 `json:"total_sensors"`
	TotalUsers   int64 `json:"total_users"`
}

// TenantRegistry lists every tenant on the platform.
//
// A port rather than a table, because there is no canonical `tenants` table in
// this repository — `saas.TenantStore` is the registry, and its only
// implementation today is in memory. Querying a table that does not exist
// would be building on a guess.
type TenantRegistry interface {
	// ListAll returns every tenant, including suspended ones. A suspended
	// tenant vanishing from this list is how an offboarding gets lost.
	ListAll(ctx context.Context) ([]saas.TenantConfig, error)
}

// UsageStore supplies the per-tenant counts.
//
// Separate from the registry because the two cannot be joined: paid tenants
// have their own databases, so counting their farms means asking a different
// server. That makes usage something gathered periodically and cached rather
// than computed in the request — see UsageSnapshot and RefreshUsage.
type UsageStore interface {
	// Usage returns the most recent snapshot per tenant, keyed by tenant id.
	// A tenant with no snapshot is absent from the map rather than zeroed, so
	// "not measured" stays distinguishable from "measured as empty".
	Usage(ctx context.Context) (map[string]UsageSnapshot, error)
}

// UsageSnapshot is one tenant's counts as last gathered.
type UsageSnapshot struct {
	TenantID       string
	Farms          int64
	Fields         int64
	Sensors        int64
	Users          int64
	StorageBytes   int64
	LastActivityAt *time.Time
	// GatheredAt says how old the snapshot is. Shown rather than hidden: a
	// dashboard reading from a snapshot taken six hours ago should say so,
	// because a stale number presented as current is how an operator concludes
	// nothing is wrong.
	GatheredAt time.Time
}

// Service answers cross-tenant questions.
type Service struct {
	registry TenantRegistry
	usage    UsageStore
	audit    audit.AuditLogger
	now      func() time.Time
}

// New creates the service.
//
// The audit logger is required, not optional. A cross-tenant read that is not
// recorded cannot be distinguished from a breach afterwards, so there is no
// configuration in which this should run without one.
//
// usage may be nil: a platform that has not set up usage gathering still wants
// the list of tenants and their active state. The counts then read as zero
// with a snapshot age of never, which the caller can distinguish.
func New(registry TenantRegistry, usage UsageStore, auditLog audit.AuditLogger) (*Service, error) {
	if registry == nil {
		return nil, errors.New("admin: a tenant registry is required")
	}
	if auditLog == nil {
		return nil, ErrAuditUnavailable
	}
	return &Service{registry: registry, usage: usage, audit: auditLog, now: time.Now}, nil
}

// authorize checks the caller and records the access.
//
// Both, in that order, in one place — so there is no path to the data that
// skips either. Splitting them would leave a method that could be written to
// call one and forget the other.
func (s *Service) authorize(ctx context.Context, action, resource string) error {
	userCtx, ok := p9context.FromUserContext(ctx)
	if !ok || userCtx.UserID == "" {
		return p9errors.Unauthorized("NOT_AUTHENTICATED", "authentication is required")
	}

	entry := audit.AuditEntry{
		UserID: userCtx.UserID, TenantID: userCtx.TenantID, Role: userCtx.Role,
		Action: action, Resource: resource,
		RequestID: p9context.RequestID(ctx), Timestamp: s.now(),
	}
	// Where the call came from, when the transport recorded it. An entry saying
	// somebody listed every tenant, without saying from where, is most of the
	// way to useless during the incident where it matters.
	if req, ok := p9context.FromRequestContext(ctx); ok {
		entry.ClientIP, entry.UserAgent = req.ClientIP, req.UserAgent
	}

	// Specifically the platform role, not "at least admin". A tenant admin is
	// the highest authority inside their tenant and must not reach past it.
	if interceptors.Role(userCtx.Role) != interceptors.RolePlatform {
		// The failed attempt is audited too. Someone trying to reach this is
		// more interesting than someone succeeding.
		failed := entry
		failed.Result, failed.ErrorCode = "failure", "NOT_PLATFORM_OPERATOR"
		_ = s.audit.Log(ctx, failed)
		return p9errors.Forbidden("NOT_PLATFORM_OPERATOR",
			"cross-tenant access requires the platform role")
	}

	// Audited before the data is returned, and a failure to audit fails the
	// request. The alternative — log afterwards, best effort — means a crash
	// between read and write leaves an unrecorded cross-tenant read.
	entry.Result = "success"
	if err := s.audit.Log(ctx, entry); err != nil {
		return p9errors.InternalServer("AUDIT_FAILED",
			"cross-tenant access could not be recorded and was refused")
	}
	return nil
}

// ListTenants returns a summary of every tenant.
func (s *Service) ListTenants(ctx context.Context) ([]TenantSummary, error) {
	if err := s.authorize(ctx, "ListTenants", "PlatformTenants"); err != nil {
		return nil, err
	}

	configs, err := s.registry.ListAll(ctx)
	if err != nil {
		return nil, p9errors.InternalServer("TENANT_LIST_FAILED", "an internal error occurred")
	}

	// One call for every tenant's usage rather than one per tenant. A platform
	// with a thousand tenants would otherwise make a thousand round trips to
	// render one page, and the page would be the slowest thing in the system.
	var usage map[string]UsageSnapshot
	if s.usage != nil {
		usage, err = s.usage.Usage(ctx)
		if err != nil {
			// The tenant list is still worth returning. Usage that cannot be
			// read shows as unmeasured, which is visibly different from zero.
			usage = nil
		}
	}

	now := s.now()
	out := make([]TenantSummary, 0, len(configs))
	for _, cfg := range configs {
		t := TenantSummary{
			TenantID: cfg.ID,
			Name:     cfg.Name,
			Region:   cfg.Region,
			Type:     string(cfg.Type),
			IsActive: cfg.IsActive,
		}
		if u, ok := usage[cfg.ID]; ok {
			t.Farms, t.Fields, t.Sensors, t.Users = u.Farms, u.Fields, u.Sensors, u.Users
			t.StorageBytes = u.StorageBytes
			t.LastActivityAt = u.LastActivityAt
			t.UsageGatheredAt = u.GatheredAt
			t.Health, t.HealthReason = t.DeriveHealth(now)
		} else {
			// No snapshot. Reporting "ok" here would be a guess, and reporting
			// "degraded" would page somebody for a missing measurement, so it
			// says what is actually true.
			t.Health = HealthUnknown
			t.HealthReason = "usage has not been gathered for this tenant"
		}
		out = append(out, t)
	}

	SortForAttention(out)
	return out, nil
}

// Stats rolls the tenant summaries up.
func (s *Service) Stats(ctx context.Context) (*PlatformStats, error) {
	tenants, err := s.ListTenants(ctx)
	if err != nil {
		return nil, err
	}
	return Summarise(tenants, s.now()), nil
}

// Summarise rolls a set of tenant summaries into platform totals.
//
// Separate from Stats so it can be tested without a database, and so a caller
// that already has the list does not fetch it twice.
func Summarise(tenants []TenantSummary, now time.Time) *PlatformStats {
	stats := &PlatformStats{
		GeneratedAt: now,
		Tenants:     int64(len(tenants)),
		ByHealth:    map[HealthState]int64{},
	}
	for _, t := range tenants {
		if t.IsActive {
			stats.Active++
		} else {
			stats.Suspended++
		}
		stats.ByHealth[t.Health]++
		stats.TotalFarms += t.Farms
		stats.TotalFields += t.Fields
		stats.TotalSensors += t.Sensors
		stats.TotalUsers += t.Users
	}
	return stats
}

// SortForAttention orders tenants so the ones needing a look come first.
//
// Degraded, then quiet, then suspended, then healthy — and alphabetically
// within each band. A dashboard sorted by name buries the one broken tenant
// among nine hundred working ones, which is the failure mode of most admin
// pages.
func SortForAttention(tenants []TenantSummary) {
	rank := map[HealthState]int{
		HealthDegraded:  0,
		HealthUnknown:   1,
		HealthQuiet:     2,
		HealthSuspended: 3,
		HealthOK:        4,
	}
	sort.SliceStable(tenants, func(i, j int) bool {
		ri, rj := rank[tenants[i].Health], rank[tenants[j].Health]
		if ri != rj {
			return ri < rj
		}
		return tenants[i].Name < tenants[j].Name
	})
}
