package outbound

import "context"

// YieldClient is the secondary port for calling yield-service.
type YieldClient interface {
	YieldExists(ctx context.Context, uuid, tenantID string) (bool, error)
	GetYieldRecord(ctx context.Context, fieldUUID, tenantID string) (float64, error)
}
