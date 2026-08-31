package outbound

import "context"

// IrrigationClient is the secondary port for calling irrigation-service.
type IrrigationClient interface {
	IrrigationExists(ctx context.Context, uuid, tenantID string) (bool, error)
	GetWaterUsage(ctx context.Context, fieldUUID, tenantID string) (float64, error)
}
