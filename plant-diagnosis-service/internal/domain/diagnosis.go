// Package domain contains the pure domain model for the plant-diagnosis-service.
package domain

import (
	"time"

	"p9e.in/samavaya/packages/models"
)

// DiagnosisStatus represents the lifecycle status of a diagnosis.
type DiagnosisStatus string

const (
	DiagnosisStatusUnspecified DiagnosisStatus = ""
	DiagnosisStatusActive      DiagnosisStatus = "ACTIVE"
	DiagnosisStatusInactive    DiagnosisStatus = "INACTIVE"
	DiagnosisStatusArchived    DiagnosisStatus = "ARCHIVED"
)

// IsValid checks if the diagnosis status is a recognized value.
func (s DiagnosisStatus) IsValid() bool {
	switch s {
	case DiagnosisStatusActive, DiagnosisStatusInactive, DiagnosisStatusArchived:
		return true
	}
	return false
}

// Diagnosis is the aggregate root for the plant-diagnosis-service.
type Diagnosis struct {
	models.BaseModel
	TenantID string       `json:"tenant_id"`
	Name     string       `json:"name"`
	Status   DiagnosisStatus `json:"status"`
	Notes    *string      `json:"notes,omitempty"`
	Version  int64        `json:"version"`
}

// ListPlantDiagnosisParams holds filter and pagination parameters for listing diagnosiss.
type ListPlantDiagnosisParams struct {
	TenantID string
	Status   *DiagnosisStatus
	Search   *string
	PageSize int32
	Offset   int32
}

// _ is used to avoid unused import
var _ = time.Now
