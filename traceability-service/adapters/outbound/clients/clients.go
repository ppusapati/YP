// Package clients re-exports traceability-service's outbound service clients.
// See the application package for why this is an alias shim rather than a copy.
package clients

import (
	internalclients "p9e.in/samavaya/agriculture/traceability-service/internal/adapters/outbound/clients"
)

// Clients for the services traceability reads from when building a chain.
var (
	NewFarmClient  = internalclients.NewFarmClient
	NewFieldClient = internalclients.NewFieldClient
	NewYieldClient = internalclients.NewYieldClient
	NewCropClient  = internalclients.NewCropClient
)
