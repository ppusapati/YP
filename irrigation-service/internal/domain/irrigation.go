// Package domain contains the pure domain model for the irrigation-service.
package domain

import (
	"time"

	"p9e.in/samavaya/packages/models"
)

// IrrigationStatus represents the lifecycle status of a irrigation.
type IrrigationStatus string

const (
	IrrigationStatusUnspecified IrrigationStatus = ""
	IrrigationStatusActive      IrrigationStatus = "ACTIVE"
	IrrigationStatusInactive    IrrigationStatus = "INACTIVE"
	IrrigationStatusArchived    IrrigationStatus = "ARCHIVED"
)

// IsValid checks if the irrigation status is a recognized value.
func (s IrrigationStatus) IsValid() bool {
	switch s {
	case IrrigationStatusActive, IrrigationStatusInactive, IrrigationStatusArchived:
		return true
	}
	return false
}

// Irrigation is the aggregate root for the irrigation-service.
type Irrigation struct {
	models.BaseModel
	TenantID string       `json:"tenant_id"`
	Name     string       `json:"name"`
	Status   IrrigationStatus `json:"status"`
	Notes    *string      `json:"notes,omitempty"`
	Version  int64        `json:"version"`
}

// ListIrrigationParams holds filter and pagination parameters for listing irrigations.
type ListIrrigationParams struct {
	TenantID string
	Status   *IrrigationStatus
	Search   *string
	PageSize int32
	Offset   int32
}

// _ is used to avoid unused import
var _ = time.Now
