// Package domain contains the pure domain model for the pest-prediction-service.
package domain

import (
	"time"

	"p9e.in/samavaya/packages/models"
)

// PestStatus represents the lifecycle status of a pest.
type PestStatus string

const (
	PestStatusUnspecified PestStatus = ""
	PestStatusActive      PestStatus = "ACTIVE"
	PestStatusInactive    PestStatus = "INACTIVE"
	PestStatusArchived    PestStatus = "ARCHIVED"
)

// IsValid checks if the pest status is a recognized value.
func (s PestStatus) IsValid() bool {
	switch s {
	case PestStatusActive, PestStatusInactive, PestStatusArchived:
		return true
	}
	return false
}

// Pest is the aggregate root for the pest-prediction-service.
type Pest struct {
	models.BaseModel
	TenantID string     `json:"tenant_id"`
	Name     string     `json:"name"`
	Status   PestStatus `json:"status"`
	Notes    *string    `json:"notes,omitempty"`
	Version  int64      `json:"version"`
}

// ListPestPredictionParams holds filter and pagination parameters for listing pests.
type ListPestPredictionParams struct {
	TenantID string
	Status   *PestStatus
	Search   *string
	PageSize int32
	Offset   int32
}

// _ is used to avoid unused import
var _ = time.Now
