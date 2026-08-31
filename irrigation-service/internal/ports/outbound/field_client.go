package outbound

import "context"

// FieldClient is the secondary port for calling field-service.
type FieldClient interface {
	FieldExists(ctx context.Context, uuid, tenantID string) (bool, error)
}
