package outbound

import "context"

// CropClient is the secondary port for calling crop-service.
type CropClient interface {
	CropExists(ctx context.Context, uuid, tenantID string) (bool, error)
}
