package admin

import (
	"context"
	"errors"

	"p9e.in/samavaya/packages/saas"
)

// Where the list of tenants comes from.
//
// There is no `tenants` table in this repository. The tenant registry is
// saas.TenantStore, whose one implementation — saas.MemoryTenantStore — is
// loaded from configuration at startup. TenantStore itself only answers
// GetByNameOrId, which is all the request path needs and none of what a
// platform view needs, so the adapter below reaches for the store's backing
// slice rather than inventing a query against a table that does not exist.
//
// When a real registry arrives, it implements TenantRegistry and this file
// stops being the only option. Nothing else has to change.

// MemoryRegistry lists the tenants a MemoryTenantStore was configured with.
type MemoryRegistry struct {
	store *saas.MemoryTenantStore
}

// RegistryFromMemoryStore adapts the configured tenant store.
func RegistryFromMemoryStore(store *saas.MemoryTenantStore) (*MemoryRegistry, error) {
	if store == nil {
		return nil, errors.New("admin: a tenant store is required")
	}
	return &MemoryRegistry{store: store}, nil
}

// ListAll returns every configured tenant, suspended ones included.
func (r *MemoryRegistry) ListAll(context.Context) ([]saas.TenantConfig, error) {
	// Copied rather than handed out. The store's slice is shared with every
	// request that resolves a tenant, and SortForAttention reorders what it is
	// given — sorting the live registry underneath concurrent readers is a data
	// race that would show up as the wrong database connection for a request.
	out := make([]saas.TenantConfig, len(r.store.TenantConfig))
	copy(out, r.store.TenantConfig)
	return out, nil
}

// StaticRegistry is a fixed list, for a deployment that configures its tenants
// somewhere other than a saas.MemoryTenantStore.
type StaticRegistry struct {
	Tenants []saas.TenantConfig
}

// ListAll returns the configured tenants.
func (r *StaticRegistry) ListAll(context.Context) ([]saas.TenantConfig, error) {
	out := make([]saas.TenantConfig, len(r.Tenants))
	copy(out, r.Tenants)
	return out, nil
}
