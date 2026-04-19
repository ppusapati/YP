// Package domain contains the pure domain model for the crop-service.
package domain

import (
	"time"

	"p9e.in/samavaya/packages/models"
)

// CropStatus represents the lifecycle status of a crop.
type CropStatus string

const (
	CropStatusUnspecified CropStatus = ""
	CropStatusActive      CropStatus = "ACTIVE"
	CropStatusInactive    CropStatus = "INACTIVE"
	CropStatusArchived    CropStatus = "ARCHIVED"
)

// IsValid checks if the crop status is a recognized value.
func (s CropStatus) IsValid() bool {
	switch s {
	case CropStatusActive, CropStatusInactive, CropStatusArchived:
		return true
	}
	return false
}

// Crop is the aggregate root for the crop-service.
type Crop struct {
	models.BaseModel
	TenantID string       `json:"tenant_id"`
	Name     string       `json:"name"`
	Status   CropStatus `json:"status"`
	Notes    *string      `json:"notes,omitempty"`
	Version  int64        `json:"version"`
}

// ListCropParams holds filter and pagination parameters for listing crops.
type ListCropParams struct {
	TenantID string
	Status   *CropStatus
	Search   *string
	PageSize int32
	Offset   int32
}

// _ is used to avoid unused import
var _ = time.Now
