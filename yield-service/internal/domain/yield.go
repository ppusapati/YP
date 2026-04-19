// Package domain contains the pure domain model for the yield-service.
package domain

import (
	"time"

	"p9e.in/samavaya/packages/models"
)

// YieldStatus represents the lifecycle status of a yield.
type YieldStatus string

const (
	YieldStatusUnspecified YieldStatus = ""
	YieldStatusActive      YieldStatus = "ACTIVE"
	YieldStatusInactive    YieldStatus = "INACTIVE"
	YieldStatusArchived    YieldStatus = "ARCHIVED"
)

// IsValid checks if the yield status is a recognized value.
func (s YieldStatus) IsValid() bool {
	switch s {
	case YieldStatusActive, YieldStatusInactive, YieldStatusArchived:
		return true
	}
	return false
}

// Yield is the aggregate root for the yield-service.
type Yield struct {
	models.BaseModel
	TenantID string       `json:"tenant_id"`
	Name     string       `json:"name"`
	Status   YieldStatus `json:"status"`
	Notes    *string      `json:"notes,omitempty"`
	Version  int64        `json:"version"`
}

// ListYieldParams holds filter and pagination parameters for listing yields.
type ListYieldParams struct {
	TenantID string
	Status   *YieldStatus
	Search   *string
	PageSize int32
	Offset   int32
}

// _ is used to avoid unused import
var _ = time.Now
