package outbound

import "context"

// SensorClient is the secondary port for calling sensor-service.
type SensorClient interface {
	SensorExists(ctx context.Context, uuid, tenantID string) (bool, error)
	GetLatestReading(ctx context.Context, sensorUUID, tenantID string) (float64, error)
}
