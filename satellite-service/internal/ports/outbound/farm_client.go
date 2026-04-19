package outbound

import "context"

// FarmClient is the secondary port for calling farm-service.
type FarmClient interface {
	FarmExists(ctx context.Context, uuid, tenantID string) (bool, error)
	GetFarmBoundary(ctx context.Context, farmUUID, tenantID string) (string, error)
}
