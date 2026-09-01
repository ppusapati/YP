// Package inbound defines the primary ports for the sensor-service.
package inbound

import (
	"context"
	"encoding/json"
	"time"

	"p9e.in/samavaya/agriculture/sensor-service/internal/models"
)

// SensorService is the primary port for all sensor business operations.
type SensorService interface {
	// Sensor lifecycle
	RegisterSensor(ctx context.Context, sensor *models.Sensor) (*models.Sensor, error)
	GetSensor(ctx context.Context, id string) (*models.Sensor, error)
	ListSensors(ctx context.Context, filter models.SensorListFilter) ([]models.Sensor, int32, error)
	UpdateSensor(ctx context.Context, sensor *models.Sensor) (*models.Sensor, error)
	DecommissionSensor(ctx context.Context, id, reason string) (*models.Sensor, error)

	// Data ingestion
	IngestReading(ctx context.Context, sensorID string, value float64, unit string, timestamp time.Time, quality models.ReadingQuality, batteryPct, signalDbm *float64, metadata json.RawMessage) (*models.SensorReading, *models.SensorAlert, error)
	BatchIngestReadings(ctx context.Context, readings []models.ReadingInput) (int32, int32, []string, []models.SensorAlert, error)
	GetLatestReading(ctx context.Context, sensorID string) (*models.SensorReading, error)
	GetReadingHistory(ctx context.Context, sensorID string, start, end time.Time, minQuality string, pageSize, pageOffset int32) ([]models.SensorReading, int32, error)

	// Alerting
	CreateAlert(ctx context.Context, alert *models.SensorAlert) (*models.SensorAlert, error)
	ListAlerts(ctx context.Context, filter models.AlertListFilter) ([]models.SensorAlert, int32, error)
	AcknowledgeAlert(ctx context.Context, id string) (*models.SensorAlert, error)

	// Network and calibration
	GetSensorNetwork(ctx context.Context, id, farmID string) (*models.SensorNetwork, error)
	CalibrateSensor(ctx context.Context, sensorID string, offset, scaleFactor float64, notes string, nextCalDate *time.Time) (*models.SensorCalibration, error)
}
