// Package domain contains the pure domain model for the satellite-service.
package domain

import (
	"time"

	"p9e.in/samavaya/packages/models"
)

// SatelliteStatus represents the lifecycle status of a satellite.
type SatelliteStatus string

const (
	SatelliteStatusUnspecified SatelliteStatus = ""
	SatelliteStatusActive      SatelliteStatus = "ACTIVE"
	SatelliteStatusInactive    SatelliteStatus = "INACTIVE"
	SatelliteStatusArchived    SatelliteStatus = "ARCHIVED"
)

// IsValid checks if the satellite status is a recognized value.
func (s SatelliteStatus) IsValid() bool {
	switch s {
	case SatelliteStatusActive, SatelliteStatusInactive, SatelliteStatusArchived:
		return true
	}
	return false
}

// Satellite is the aggregate root for the satellite-service.
type Satellite struct {
	models.BaseModel
	TenantID string          `json:"tenant_id"`
	Name     string          `json:"name"`
	Status   SatelliteStatus `json:"status"`
	Notes    *string         `json:"notes,omitempty"`
	Version  int64           `json:"version"`
}

// ListSatelliteParams holds filter and pagination parameters for listing satellites.
type ListSatelliteParams struct {
	TenantID string
	Status   *SatelliteStatus
	Search   *string
	PageSize int32
	Offset   int32
}

// _ is used to avoid unused import
var _ = time.Now
