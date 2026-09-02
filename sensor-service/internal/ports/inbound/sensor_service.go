// Package inbound defines the primary ports for the sensor-service.
package inbound

import (
	"context"
	"encoding/json"
	"time"

	"p9e.in/samavaya/agriculture/sensor-service/internal/domain"
)

// SensorService is the primary port for all sensor business operations.
type SensorService interface {
	// Sensor lifecycle
	RegisterSensor(ctx context.Context, sensor *domain.Sensor) (*domain.Sensor, error)
	GetSensor(ctx context.Context, id string) (*domain.Sensor, error)
	ListSensors(ctx context.Context, filter domain.SensorListFilter) ([]domain.Sensor, int32, error)
	UpdateSensor(ctx context.Context, sensor *domain.Sensor) (*domain.Sensor, error)
	DecommissionSensor(ctx context.Context, id, reason string) (*domain.Sensor, error)

	// Data ingestion
	IngestReading(ctx context.Context, sensorID string, value float64, unit string, timestamp time.Time, quality domain.ReadingQuality, batteryPct, signalDbm *float64, metadata json.RawMessage) (*domain.SensorReading, *domain.SensorAlert, error)
	BatchIngestReadings(ctx context.Context, readings []domain.ReadingInput) (int32, int32, []string, []domain.SensorAlert, error)
	GetLatestReading(ctx context.Context, sensorID string) (*domain.SensorReading, error)
	GetReadingHistory(ctx context.Context, sensorID string, start, end time.Time, minQuality string, pageSize, pageOffset int32) ([]domain.SensorReading, int32, error)

	// Alerting
	CreateAlert(ctx context.Context, alert *domain.SensorAlert) (*domain.SensorAlert, error)
	ListAlerts(ctx context.Context, filter domain.AlertListFilter) ([]domain.SensorAlert, int32, error)
	AcknowledgeAlert(ctx context.Context, id string) (*domain.SensorAlert, error)

	// Network and calibration
	GetSensorNetwork(ctx context.Context, id, farmID string) (*domain.SensorNetwork, error)
	CalibrateSensor(ctx context.Context, sensorID string, offset, scaleFactor float64, notes string, nextCalDate *time.Time) (*domain.SensorCalibration, error)
}
