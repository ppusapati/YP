package outbound

import "context"

// PestClient is the secondary port for calling pest-prediction-service.
type PestClient interface {
	PestExists(ctx context.Context, uuid, tenantID string) (bool, error)
	GetLatestPrediction(ctx context.Context, fieldUUID, tenantID string) (string, error)
}
