// Package domain contains the pure domain model for the traceability-service.
package domain

import (
	"time"

	"p9e.in/samavaya/packages/models"
)

// TraceabilityStatus represents the lifecycle status of a traceability.
type TraceabilityStatus string

const (
	TraceabilityStatusUnspecified TraceabilityStatus = ""
	TraceabilityStatusActive      TraceabilityStatus = "ACTIVE"
	TraceabilityStatusInactive    TraceabilityStatus = "INACTIVE"
	TraceabilityStatusArchived    TraceabilityStatus = "ARCHIVED"
)

// IsValid checks if the traceability status is a recognized value.
func (s TraceabilityStatus) IsValid() bool {
	switch s {
	case TraceabilityStatusActive, TraceabilityStatusInactive, TraceabilityStatusArchived:
		return true
	}
	return false
}

// Traceability is the aggregate root for the traceability-service.
type Traceability struct {
	models.BaseModel
	TenantID string       `json:"tenant_id"`
	Name     string       `json:"name"`
	Status   TraceabilityStatus `json:"status"`
	Notes    *string      `json:"notes,omitempty"`
	Version  int64        `json:"version"`
}

// ListTraceabilityParams holds filter and pagination parameters for listing traceabilitys.
type ListTraceabilityParams struct {
	TenantID string
	Status   *TraceabilityStatus
	Search   *string
	PageSize int32
	Offset   int32
}

// _ is used to avoid unused import
var _ = time.Now
