// Package domain contains the pure domain model for the sensor-service.
package domain

import (
	"time"

	"p9e.in/samavaya/packages/models"
)

// SensorStatus represents the lifecycle status of a sensor.
type SensorStatus string

const (
	SensorStatusUnspecified SensorStatus = ""
	SensorStatusActive      SensorStatus = "ACTIVE"
	SensorStatusInactive    SensorStatus = "INACTIVE"
	SensorStatusArchived    SensorStatus = "ARCHIVED"
)

// IsValid checks if the sensor status is a recognized value.
func (s SensorStatus) IsValid() bool {
	switch s {
	case SensorStatusActive, SensorStatusInactive, SensorStatusArchived:
		return true
	}
	return false
}

// Sensor is the aggregate root for the sensor-service.
type Sensor struct {
	models.BaseModel
	TenantID string       `json:"tenant_id"`
	Name     string       `json:"name"`
	Status   SensorStatus `json:"status"`
	Notes    *string      `json:"notes,omitempty"`
	Version  int64        `json:"version"`
}

// ListSensorParams holds filter and pagination parameters for listing sensors.
type ListSensorParams struct {
	TenantID string
	Status   *SensorStatus
	Search   *string
	PageSize int32
	Offset   int32
}

// _ is used to avoid unused import
var _ = time.Now
