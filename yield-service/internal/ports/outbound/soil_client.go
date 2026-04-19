package outbound

import "context"

// SoilClient is the secondary port for calling soil-service.
type SoilClient interface {
	SoilExists(ctx context.Context, uuid, tenantID string) (bool, error)
	GetLatestAnalysis(ctx context.Context, fieldUUID, tenantID string) (float64, error)
}
