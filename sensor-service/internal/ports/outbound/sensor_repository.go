// Package outbound defines the secondary ports for the sensor-service.
package outbound

import (
	"context"

	"github.com/jackc/pgx/v5"

	"p9e.in/samavaya/agriculture/sensor-service/internal/domain"
)

// SensorRepository is the secondary port for sensor persistence.
type SensorRepository interface {
	CreateSensor(ctx context.Context, entity *domain.Sensor) (*domain.Sensor, error)
	GetSensorByUUID(ctx context.Context, uuid, tenantID string) (*domain.Sensor, error)
	ListSensors(ctx context.Context, params domain.ListSensorParams) ([]domain.Sensor, int32, error)
	UpdateSensor(ctx context.Context, entity *domain.Sensor) (*domain.Sensor, error)
	DeleteSensor(ctx context.Context, uuid, tenantID, deletedBy string) error
	CheckSensorExists(ctx context.Context, uuid, tenantID string) (bool, error)
	CheckSensorNameExists(ctx context.Context, name, tenantID string) (bool, error)

	WithTx(tx pgx.Tx) SensorRepository
}
