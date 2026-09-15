// Package clients re-exports field-service's outbound service clients. See the
// application package for why this is an alias shim rather than a copy.
package clients

import (
	internalclients "p9e.in/samavaya/agriculture/field-service/internal/adapters/outbound/clients"
)

// Clients for the services a field reads from.
var (
	NewFarmClient = internalclients.NewFarmClient
	NewCropClient = internalclients.NewCropClient
)
