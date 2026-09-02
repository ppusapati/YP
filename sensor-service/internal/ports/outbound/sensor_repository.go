// Package outbound defines the secondary ports for the sensor-service.
package outbound

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5"

	"p9e.in/samavaya/agriculture/sensor-service/internal/domain"
)

// SensorRepository is the secondary port for sensor persistence.
type SensorRepository interface {
	// Sensor lifecycle
	CreateSensor(ctx context.Context, entity *domain.Sensor) (*domain.Sensor, error)
	GetSensorByUUID(ctx context.Context, uuid, tenantID string) (*domain.Sensor, error)
	GetSensorByDeviceID(ctx context.Context, deviceID, tenantID string) (*domain.Sensor, error)
	ListSensors(ctx context.Context, filter domain.SensorListFilter) ([]domain.Sensor, int32, error)
	UpdateSensor(ctx context.Context, entity *domain.Sensor) (*domain.Sensor, error)
	DecommissionSensor(ctx context.Context, uuid, tenantID, userID string) (*domain.Sensor, error)
	UpdateSensorLastReading(ctx context.Context, uuid, tenantID string, readingTime time.Time, batteryPct, signalDbm *float64) error

	// Sensor readings
	CreateReading(ctx context.Context, reading *domain.SensorReading) (*domain.SensorReading, error)
	GetLatestReading(ctx context.Context, sensorID, tenantID string) (*domain.SensorReading, error)
	GetReadingHistory(ctx context.Context, sensorID, tenantID string, start, end time.Time, minQuality string, pageSize, pageOffset int32) ([]domain.SensorReading, int32, error)

	// Sensor alerts
	CreateAlert(ctx context.Context, alert *domain.SensorAlert) (*domain.SensorAlert, error)
	ListAlerts(ctx context.Context, filter domain.AlertListFilter) ([]domain.SensorAlert, int32, error)
	AcknowledgeAlert(ctx context.Context, uuid, tenantID, userID string) (*domain.SensorAlert, error)
	GetActiveAlertsForSensor(ctx context.Context, sensorID, tenantID string) ([]domain.SensorAlert, error)

	// Sensor networks
	GetSensorNetworkByUUID(ctx context.Context, uuid, tenantID string) (*domain.SensorNetwork, error)
	GetSensorNetworkByFarm(ctx context.Context, farmID, tenantID string) (*domain.SensorNetwork, error)

	// Sensor calibrations
	CreateCalibration(ctx context.Context, cal *domain.SensorCalibration) (*domain.SensorCalibration, error)
	GetLatestCalibration(ctx context.Context, sensorID, tenantID string) (*domain.SensorCalibration, error)

	WithTx(tx pgx.Tx) SensorRepository
}
