// Package inbound defines the primary ports for the sensor-service.
package inbound

import (
	"context"

	"p9e.in/samavaya/agriculture/sensor-service/internal/domain"
)

// SensorService is the primary port for all sensor business operations.
type SensorService interface {
	CreateSensor(ctx context.Context, entity *domain.Sensor) (*domain.Sensor, error)
	GetSensor(ctx context.Context, uuid string) (*domain.Sensor, error)
	ListSensors(ctx context.Context, params domain.ListSensorParams) ([]domain.Sensor, int32, error)
	UpdateSensor(ctx context.Context, entity *domain.Sensor) (*domain.Sensor, error)
	DeleteSensor(ctx context.Context, uuid string) error
}
