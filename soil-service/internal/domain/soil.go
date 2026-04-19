// Package domain contains the pure domain model for the soil-service.
package domain

import (
	"time"

	"p9e.in/samavaya/packages/models"
)

// SoilStatus represents the lifecycle status of a soil.
type SoilStatus string

const (
	SoilStatusUnspecified SoilStatus = ""
	SoilStatusActive      SoilStatus = "ACTIVE"
	SoilStatusInactive    SoilStatus = "INACTIVE"
	SoilStatusArchived    SoilStatus = "ARCHIVED"
)

// IsValid checks if the soil status is a recognized value.
func (s SoilStatus) IsValid() bool {
	switch s {
	case SoilStatusActive, SoilStatusInactive, SoilStatusArchived:
		return true
	}
	return false
}

// Soil is the aggregate root for the soil-service.
type Soil struct {
	models.BaseModel
	TenantID string       `json:"tenant_id"`
	Name     string       `json:"name"`
	Status   SoilStatus `json:"status"`
	Notes    *string      `json:"notes,omitempty"`
	Version  int64        `json:"version"`
}

// ListSoilParams holds filter and pagination parameters for listing soils.
type ListSoilParams struct {
	TenantID string
	Status   *SoilStatus
	Search   *string
	PageSize int32
	Offset   int32
}

// _ is used to avoid unused import
var _ = time.Now
