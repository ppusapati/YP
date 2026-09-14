package featureflags

import (
	"context"
	"fmt"
	"sort"
	"sync"
	"time"
)

// Per-tenant overrides.
//
// Targeting rules already match on tenant_id, so it looks at first as though
// this is covered. It is not, and the gap is one-directional: a matching rule
// sets `Enabled = true` and returns. There is no way to express "off".
//
// `not_in: [tenant-42]` does not help — it matches every tenant except 42 and
// forces all of them on, cancelling the rollout percentage entirely. So the
// two requests a support engineer actually receives —
//
//	"turn this on for us early, we want to test it"
//	"turn this off for us, it is breaking our workflow"
//
// were one easy and one impossible.
//
// An override is a pin. It is checked before targeting and before the rollout
// percentage, it can point either way, and it carries the reason it exists.
// That last part is not bookkeeping: an override with no recorded reason and no
// expiry becomes permanent by default, and a flag pinned off for a tenant
// nobody remembers pinning is how a tenant ends up a year behind everyone else.

// TenantOverride pins a flag's value for one tenant.
type TenantOverride struct {
	// TenantID is the tenant this override applies to.
	TenantID string `json:"tenant_id" yaml:"tenant_id"`
	// FlagName is the flag being pinned.
	FlagName string `json:"flag_name" yaml:"flag_name"`
	// Enabled is the value the flag takes for this tenant.
	Enabled bool `json:"enabled" yaml:"enabled"`
	// Variant optionally pins a multivariate flag to one variant. Empty means
	// the variant is selected normally.
	Variant string `json:"variant,omitempty" yaml:"variant,omitempty"`
	// Reason records why the override exists — a support ticket, a contractual
	// commitment, an incident. Overrides outlive the people who set them.
	Reason string `json:"reason,omitempty" yaml:"reason,omitempty"`
	// SetBy identifies who set it.
	SetBy string `json:"set_by,omitempty" yaml:"set_by,omitempty"`
	// SetAt records when.
	SetAt time.Time `json:"set_at,omitempty" yaml:"set_at,omitempty"`
	// ExpiresAt optionally ends the override. Nil means it lasts until
	// removed, which should be the exception: an override meant to cover a
	// migration or an incident has an end, and giving it one is the difference
	// between a temporary measure and a permanent fork.
	ExpiresAt *time.Time `json:"expires_at,omitempty" yaml:"expires_at,omitempty"`
}

// Active reports whether the override applies at the given time.
func (o TenantOverride) Active(now time.Time) bool {
	return o.ExpiresAt == nil || now.Before(*o.ExpiresAt)
}

// Validate checks an override for the mistakes that make one useless.
func (o TenantOverride) Validate() error {
	if o.TenantID == "" {
		return fmt.Errorf("featureflags: override has no tenant_id")
	}
	if o.FlagName == "" {
		return fmt.Errorf("featureflags: override for tenant %q has no flag_name", o.TenantID)
	}
	if o.ExpiresAt != nil && !o.SetAt.IsZero() && !o.ExpiresAt.After(o.SetAt) {
		return fmt.Errorf("featureflags: override %s/%s expires at or before it was set",
			o.TenantID, o.FlagName)
	}
	return nil
}

// rawTenantOverride is the shape written under a flag's `tenants:` key, where
// the tenant id is the map key and the flag name is already known.
type rawTenantOverride struct {
	Enabled   bool       `json:"enabled" yaml:"enabled"`
	Variant   string     `json:"variant" yaml:"variant"`
	Reason    string     `json:"reason" yaml:"reason"`
	SetBy     string     `json:"set_by" yaml:"set_by"`
	ExpiresAt *time.Time `json:"expires_at" yaml:"expires_at"`
}

func (r rawTenantOverride) override(tenantID, flagName string) TenantOverride {
	return TenantOverride{
		TenantID:  tenantID,
		FlagName:  flagName,
		Enabled:   r.Enabled,
		Variant:   r.Variant,
		Reason:    r.Reason,
		SetBy:     r.SetBy,
		ExpiresAt: r.ExpiresAt,
	}
}

// sortOverrides orders overrides by tenant so repeated loads of one file are
// identical. Stable, because duplicates are only rejected later in validation
// and an unstable sort would make the error name a different one each run.
func sortOverrides(os []TenantOverride) {
	sort.SliceStable(os, func(i, j int) bool { return os[i].TenantID < os[j].TenantID })
}

func sortStrings(s []string) { sort.Strings(s) }

// OverrideStore holds overrides that are set at runtime rather than declared in
// a configuration file.
//
// A file-declared override needs a deploy to change, which is the wrong
// timescale for "this is breaking our workflow, turn it off". A store lets that
// happen in seconds and, because the two sources are consulted in order, lets
// the file keep expressing the long-lived decisions.
type OverrideStore interface {
	// Override returns the override for a tenant and flag, if one is set.
	Override(ctx context.Context, tenantID, flagName string) (TenantOverride, bool)
	// SetOverride adds or replaces an override.
	SetOverride(ctx context.Context, o TenantOverride) error
	// ClearOverride removes an override. Removing one that is not set is not
	// an error.
	ClearOverride(ctx context.Context, tenantID, flagName string) error
	// ListOverrides returns every override for a tenant. An empty tenantID
	// returns all of them.
	ListOverrides(ctx context.Context, tenantID string) ([]TenantOverride, error)
}

// InMemoryOverrideStore is a concurrency-safe OverrideStore held in process.
//
// It is the right store for tests and for a single instance. It is the wrong
// one for a fleet: an override set on one replica is invisible to the other
// five, so a tenant sees the flag flip depending on which pod answered. Back
// it with something shared before relying on it in production.
type InMemoryOverrideStore struct {
	mu  sync.RWMutex
	byT map[string]map[string]TenantOverride // tenant -> flag -> override
	now func() time.Time
}

// NewInMemoryOverrideStore creates an empty store.
func NewInMemoryOverrideStore() *InMemoryOverrideStore {
	return &InMemoryOverrideStore{
		byT: make(map[string]map[string]TenantOverride),
		now: time.Now,
	}
}

// Override returns the override for a tenant and flag if one is set and has not
// expired.
func (s *InMemoryOverrideStore) Override(_ context.Context, tenantID, flagName string) (TenantOverride, bool) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	o, ok := s.byT[tenantID][flagName]
	if !ok || !o.Active(s.now()) {
		return TenantOverride{}, false
	}
	return o, true
}

// SetOverride adds or replaces an override.
func (s *InMemoryOverrideStore) SetOverride(_ context.Context, o TenantOverride) error {
	if err := o.Validate(); err != nil {
		return err
	}
	if o.SetAt.IsZero() {
		o.SetAt = s.now()
	}
	s.mu.Lock()
	defer s.mu.Unlock()
	if s.byT[o.TenantID] == nil {
		s.byT[o.TenantID] = make(map[string]TenantOverride)
	}
	s.byT[o.TenantID][o.FlagName] = o
	return nil
}

// ClearOverride removes an override.
func (s *InMemoryOverrideStore) ClearOverride(_ context.Context, tenantID, flagName string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	delete(s.byT[tenantID], flagName)
	if len(s.byT[tenantID]) == 0 {
		delete(s.byT, tenantID)
	}
	return nil
}

// ListOverrides returns a tenant's overrides, or every override when tenantID
// is empty. Expired entries are excluded, so the listing matches what
// evaluation would actually do.
func (s *InMemoryOverrideStore) ListOverrides(_ context.Context, tenantID string) ([]TenantOverride, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	now := s.now()
	var out []TenantOverride
	collect := func(m map[string]TenantOverride) {
		for _, o := range m {
			if o.Active(now) {
				out = append(out, o)
			}
		}
	}
	if tenantID != "" {
		collect(s.byT[tenantID])
	} else {
		for _, m := range s.byT {
			collect(m)
		}
	}
	sort.Slice(out, func(i, j int) bool {
		if out[i].TenantID != out[j].TenantID {
			return out[i].TenantID < out[j].TenantID
		}
		return out[i].FlagName < out[j].FlagName
	})
	return out, nil
}

// PruneExpired removes expired overrides and reports how many went. Calling it
// is optional — expired overrides are ignored either way — but it keeps a
// long-lived process from accumulating them.
func (s *InMemoryOverrideStore) PruneExpired() int {
	s.mu.Lock()
	defer s.mu.Unlock()

	now := s.now()
	var removed int
	for tenantID, m := range s.byT {
		for flagName, o := range m {
			if !o.Active(now) {
				delete(m, flagName)
				removed++
			}
		}
		if len(m) == 0 {
			delete(s.byT, tenantID)
		}
	}
	return removed
}

// WithOverrideStore attaches a runtime override store to an InMemoryFlagService.
func WithOverrideStore(store OverrideStore) InMemoryOption {
	return func(s *InMemoryFlagService) { s.overrides = store }
}

// IsEnabledForTenant evaluates a flag for one tenant, without the caller having
// to assemble an attribute map.
//
// This is the call for background work — a scheduled job, a Kafka consumer —
// which has no request to take a tenant from and would otherwise evaluate with
// no tenant at all. An empty tenant is not a neutral default: it lands every
// such job in the same consistent-hash bucket, so a 10% rollout reaches either
// all of them or none.
func IsEnabledForTenant(ctx context.Context, svc FlagService, flagName, tenantID string) bool {
	if svc == nil {
		return false
	}
	return svc.IsEnabled(ctx, flagName, Attributes{"tenant_id": tenantID})
}
