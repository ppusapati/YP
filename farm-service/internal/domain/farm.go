// Package domain contains the pure domain model for the farm service.
// It has no imports from infrastructure packages (databases, HTTP, Kafka, proto).
package domain

import (
	"encoding/json"
	"time"

	"p9e.in/samavaya/packages/models"
)

// FarmType represents the type of farming operation.
type FarmType string

const (
	FarmTypeUnspecified  FarmType = ""
	FarmTypeCrop         FarmType = "CROP"
	FarmTypeLivestock    FarmType = "LIVESTOCK"
	FarmTypeMixed        FarmType = "MIXED"
	FarmTypeAquaculture  FarmType = "AQUACULTURE"
)

// IsValid checks if the farm type is a valid value.
func (ft FarmType) IsValid() bool {
	switch ft {
	case FarmTypeCrop, FarmTypeLivestock, FarmTypeMixed, FarmTypeAquaculture:
		return true
	}
	return false
}

// FarmStatus represents the operational status of a farm.
type FarmStatus string

const (
	FarmStatusUnspecified FarmStatus = ""
	FarmStatusActive      FarmStatus = "ACTIVE"
	FarmStatusInactive    FarmStatus = "INACTIVE"
	FarmStatusPending     FarmStatus = "PENDING"
	FarmStatusSuspended   FarmStatus = "SUSPENDED"
	FarmStatusArchived    FarmStatus = "ARCHIVED"
)

// IsValid checks if the farm status is a valid value.
func (fs FarmStatus) IsValid() bool {
	switch fs {
	case FarmStatusActive, FarmStatusInactive, FarmStatusPending, FarmStatusSuspended, FarmStatusArchived:
		return true
	}
	return false
}

// SoilType represents the soil classification.
type SoilType string

const (
	SoilTypeUnspecified SoilType = ""
	SoilTypeClay        SoilType = "CLAY"
	SoilTypeSandy       SoilType = "SANDY"
	SoilTypeLoamy       SoilType = "LOAMY"
	SoilTypeSilt        SoilType = "SILT"
	SoilTypePeat        SoilType = "PEAT"
	SoilTypeChalky      SoilType = "CHALKY"
	SoilTypeLaterite    SoilType = "LATERITE"
	SoilTypeBlack       SoilType = "BLACK"
	SoilTypeRed         SoilType = "RED"
	SoilTypeAlluvial    SoilType = "ALLUVIAL"
)

// ClimateZone represents the climate zone classification.
type ClimateZone string

const (
	ClimateZoneUnspecified   ClimateZone = ""
	ClimateZoneTropical      ClimateZone = "TROPICAL"
	ClimateZoneSubtropical   ClimateZone = "SUBTROPICAL"
	ClimateZoneArid          ClimateZone = "ARID"
	ClimateZoneSemiarid      ClimateZone = "SEMIARID"
	ClimateZoneTemperate     ClimateZone = "TEMPERATE"
	ClimateZoneContinental   ClimateZone = "CONTINENTAL"
	ClimateZonePolar         ClimateZone = "POLAR"
	ClimateZoneMediterranean ClimateZone = "MEDITERRANEAN"
	ClimateZoneMonsoon       ClimateZone = "MONSOON"
)

// Farm represents a registered farm — the aggregate root.
type Farm struct {
	models.BaseModel
	TenantID          string          `json:"tenant_id"`
	Name              string          `json:"name"`
	Description       *string         `json:"description,omitempty"`
	TotalAreaHectares float64         `json:"total_area_hectares"`
	Latitude          *float64        `json:"latitude,omitempty"`
	Longitude         *float64        `json:"longitude,omitempty"`
	ElevationMeters   *float64        `json:"elevation_meters,omitempty"`
	FarmType          FarmType        `json:"farm_type"`
	Status            FarmStatus      `json:"status"`
	SoilType          *SoilType       `json:"soil_type,omitempty"`
	ClimateZone       *ClimateZone    `json:"climate_zone,omitempty"`
	Address           *string         `json:"address,omitempty"`
	Region            *string         `json:"region,omitempty"`
	Country           *string         `json:"country,omitempty"`
	Metadata          json.RawMessage `json:"metadata,omitempty"`
	Version           int64           `json:"version"`

	// Loaded associations (not DB columns)
	Boundary *FarmBoundary `json:"boundary,omitempty"`
	Owners   []FarmOwner   `json:"owners,omitempty"`
}

// FarmBoundary represents the geographic boundary of a farm.
type FarmBoundary struct {
	ID              int64      `json:"id"`
	UUID            string     `json:"uuid"`
	FarmID          int64      `json:"farm_id"`
	FarmUUID        string     `json:"farm_uuid"`
	TenantID        string     `json:"tenant_id"`
	GeoJSON         string     `json:"geojson"`
	AreaHectares    float64    `json:"area_hectares"`
	PerimeterMeters float64    `json:"perimeter_meters"`
	IsActive        bool       `json:"is_active"`
	CreatedBy       string     `json:"created_by"`
	CreatedAt       time.Time  `json:"created_at"`
	UpdatedBy       *string    `json:"updated_by,omitempty"`
	UpdatedAt       *time.Time `json:"updated_at,omitempty"`
	DeletedBy       *string    `json:"deleted_by,omitempty"`
	DeletedAt       *time.Time `json:"deleted_at,omitempty"`
}

// FarmOwner represents ownership information for a farm.
type FarmOwner struct {
	ID                  int64      `json:"id"`
	UUID                string     `json:"uuid"`
	FarmID              int64      `json:"farm_id"`
	FarmUUID            string     `json:"farm_uuid"`
	TenantID            string     `json:"tenant_id"`
	UserID              string     `json:"user_id"`
	OwnerName           string     `json:"owner_name"`
	Email               *string    `json:"email,omitempty"`
	Phone               *string    `json:"phone,omitempty"`
	IsPrimary           bool       `json:"is_primary"`
	OwnershipPercentage float64    `json:"ownership_percentage"`
	AcquiredAt          time.Time  `json:"acquired_at"`
	IsActive            bool       `json:"is_active"`
	CreatedBy           string     `json:"created_by"`
	CreatedAt           time.Time  `json:"created_at"`
	UpdatedBy           *string    `json:"updated_by,omitempty"`
	UpdatedAt           *time.Time `json:"updated_at,omitempty"`
}

// ListFarmsParams holds filter and pagination parameters for listing farms.
type ListFarmsParams struct {
	TenantID    string
	FarmType    *FarmType
	Status      *FarmStatus
	Region      *string
	Country     *string
	ClimateZone *ClimateZone
	Search      *string
	PageSize    int32
	Offset      int32
}

// TransferOwnershipParams holds the parameters for an ownership transfer.
type TransferOwnershipParams struct {
	FarmUUID            string
	FromUserID          string
	ToUserID            string
	ToOwnerName         string
	ToEmail             string
	ToPhone             string
	OwnershipPercentage float64
}
