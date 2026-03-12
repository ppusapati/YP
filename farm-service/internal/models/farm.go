package models

import (
	"encoding/json"
	"time"

	"p9e.in/samavaya/packages/models"
)

// FarmType represents the type of farming operation.
type FarmType string

const (
	FarmTypeUnspecified FarmType = ""
	FarmTypeCrop       FarmType = "CROP"
	FarmTypeLivestock  FarmType = "LIVESTOCK"
	FarmTypeMixed      FarmType = "MIXED"
	FarmTypeAquaculture FarmType = "AQUACULTURE"
)

// IsValid checks if the farm type is a valid value.
func (ft FarmType) IsValid() bool {
	switch ft {
	case FarmTypeCrop, FarmTypeLivestock, FarmTypeMixed, FarmTypeAquaculture:
		return true
	default:
		return false
	}
}

// FarmStatus represents the operational status of a farm.
type FarmStatus string

const (
	FarmStatusUnspecified FarmStatus = ""
	FarmStatusActive     FarmStatus = "ACTIVE"
	FarmStatusInactive   FarmStatus = "INACTIVE"
	FarmStatusPending    FarmStatus = "PENDING"
	FarmStatusSuspended  FarmStatus = "SUSPENDED"
	FarmStatusArchived   FarmStatus = "ARCHIVED"
)

// IsValid checks if the farm status is a valid value.
func (fs FarmStatus) IsValid() bool {
	switch fs {
	case FarmStatusActive, FarmStatusInactive, FarmStatusPending, FarmStatusSuspended, FarmStatusArchived:
		return true
	default:
		return false
	}
}

// SoilType represents the soil classification.
type SoilType string

const (
	SoilTypeUnspecified SoilType = ""
	SoilTypeClay       SoilType = "CLAY"
	SoilTypeSandy      SoilType = "SANDY"
	SoilTypeLoamy      SoilType = "LOAMY"
	SoilTypeSilt       SoilType = "SILT"
	SoilTypePeat       SoilType = "PEAT"
	SoilTypeChalky     SoilType = "CHALKY"
	SoilTypeLaterite   SoilType = "LATERITE"
	SoilTypeBlack      SoilType = "BLACK"
	SoilTypeRed        SoilType = "RED"
	SoilTypeAlluvial   SoilType = "ALLUVIAL"
)

// IsValid checks if the soil type is a valid value.
func (st SoilType) IsValid() bool {
	switch st {
	case SoilTypeClay, SoilTypeSandy, SoilTypeLoamy, SoilTypeSilt,
		SoilTypePeat, SoilTypeChalky, SoilTypeLaterite, SoilTypeBlack,
		SoilTypeRed, SoilTypeAlluvial:
		return true
	case SoilTypeUnspecified:
		return true
	default:
		return false
	}
}

// ClimateZone represents the climate zone classification.
type ClimateZone string

const (
	ClimateZoneUnspecified    ClimateZone = ""
	ClimateZoneTropical       ClimateZone = "TROPICAL"
	ClimateZoneSubtropical    ClimateZone = "SUBTROPICAL"
	ClimateZoneArid           ClimateZone = "ARID"
	ClimateZoneSemiarid       ClimateZone = "SEMIARID"
	ClimateZoneTemperate      ClimateZone = "TEMPERATE"
	ClimateZoneContinental    ClimateZone = "CONTINENTAL"
	ClimateZonePolar          ClimateZone = "POLAR"
	ClimateZoneMediterranean  ClimateZone = "MEDITERRANEAN"
	ClimateZoneMonsoon        ClimateZone = "MONSOON"
)

// IsValid checks if the climate zone is a valid value.
func (cz ClimateZone) IsValid() bool {
	switch cz {
	case ClimateZoneTropical, ClimateZoneSubtropical, ClimateZoneArid,
		ClimateZoneSemiarid, ClimateZoneTemperate, ClimateZoneContinental,
		ClimateZonePolar, ClimateZoneMediterranean, ClimateZoneMonsoon:
		return true
	case ClimateZoneUnspecified:
		return true
	default:
		return false
	}
}

// Farm represents a registered farm in the domain.
type Farm struct {
	models.BaseModel
	TenantID          string            `json:"tenant_id" db:"tenant_id"`
	Name              string            `json:"name" db:"name"`
	Description       *string           `json:"description,omitempty" db:"description"`
	TotalAreaHectares float64           `json:"total_area_hectares" db:"total_area_hectares"`
	Latitude          *float64          `json:"latitude,omitempty" db:"latitude"`
	Longitude         *float64          `json:"longitude,omitempty" db:"longitude"`
	ElevationMeters   *float64          `json:"elevation_meters,omitempty" db:"elevation_meters"`
	FarmType          FarmType          `json:"farm_type" db:"farm_type"`
	Status            FarmStatus        `json:"status" db:"status"`
	SoilType          *SoilType         `json:"soil_type,omitempty" db:"soil_type"`
	ClimateZone       *ClimateZone      `json:"climate_zone,omitempty" db:"climate_zone"`
	Address           *string           `json:"address,omitempty" db:"address"`
	Region            *string           `json:"region,omitempty" db:"region"`
	Country           *string           `json:"country,omitempty" db:"country"`
	Metadata          json.RawMessage   `json:"metadata,omitempty" db:"metadata"`
	Version           int64             `json:"version" db:"version"`

	// Loaded associations (not DB columns)
	Boundary *FarmBoundary `json:"boundary,omitempty" db:"-"`
	Owners   []FarmOwner   `json:"owners,omitempty" db:"-"`
}

// GetID returns the primary key of the farm.
func (f *Farm) GetID() int64 {
	return f.ID
}

// GetUUID returns the ULID identifier of the farm.
func (f *Farm) GetUUID() string {
	return f.UUID
}

// FarmBoundary represents the geographic boundary of a farm.
type FarmBoundary struct {
	ID              int64      `json:"id" db:"id"`
	UUID            string     `json:"uuid" db:"uuid"`
	FarmID          int64      `json:"farm_id" db:"farm_id"`
	FarmUUID        string     `json:"farm_uuid" db:"farm_uuid"`
	TenantID        string     `json:"tenant_id" db:"tenant_id"`
	GeoJSON         string     `json:"geojson" db:"geojson"`
	AreaHectares    float64    `json:"area_hectares" db:"area_hectares"`
	PerimeterMeters float64    `json:"perimeter_meters" db:"perimeter_meters"`
	IsActive        bool       `json:"is_active" db:"is_active"`
	CreatedBy       string     `json:"created_by" db:"created_by"`
	CreatedAt       time.Time  `json:"created_at" db:"created_at"`
	UpdatedBy       *string    `json:"updated_by,omitempty" db:"updated_by"`
	UpdatedAt       *time.Time `json:"updated_at,omitempty" db:"updated_at"`
	DeletedBy       *string    `json:"deleted_by,omitempty" db:"deleted_by"`
	DeletedAt       *time.Time `json:"deleted_at,omitempty" db:"deleted_at"`
}

// GetID returns the primary key of the boundary.
func (b *FarmBoundary) GetID() int64 {
	return b.ID
}

// GetUUID returns the ULID identifier of the boundary.
func (b *FarmBoundary) GetUUID() string {
	return b.UUID
}

// FarmOwner represents ownership information for a farm.
type FarmOwner struct {
	ID                   int64      `json:"id" db:"id"`
	UUID                 string     `json:"uuid" db:"uuid"`
	FarmID               int64      `json:"farm_id" db:"farm_id"`
	FarmUUID             string     `json:"farm_uuid" db:"farm_uuid"`
	TenantID             string     `json:"tenant_id" db:"tenant_id"`
	UserID               string     `json:"user_id" db:"user_id"`
	OwnerName            string     `json:"owner_name" db:"owner_name"`
	Email                *string    `json:"email,omitempty" db:"email"`
	Phone                *string    `json:"phone,omitempty" db:"phone"`
	IsPrimary            bool       `json:"is_primary" db:"is_primary"`
	OwnershipPercentage  float64    `json:"ownership_percentage" db:"ownership_percentage"`
	AcquiredAt           time.Time  `json:"acquired_at" db:"acquired_at"`
	IsActive             bool       `json:"is_active" db:"is_active"`
	CreatedBy            string     `json:"created_by" db:"created_by"`
	CreatedAt            time.Time  `json:"created_at" db:"created_at"`
	UpdatedBy            *string    `json:"updated_by,omitempty" db:"updated_by"`
	UpdatedAt            *time.Time `json:"updated_at,omitempty" db:"updated_at"`
	DeletedBy            *string    `json:"deleted_by,omitempty" db:"deleted_by"`
	DeletedAt            *time.Time `json:"deleted_at,omitempty" db:"deleted_at"`
}

// GetID returns the primary key of the owner.
func (o *FarmOwner) GetID() int64 {
	return o.ID
}

// GetUUID returns the ULID identifier of the owner.
func (o *FarmOwner) GetUUID() string {
	return o.UUID
}

// ListFarmsParams holds the filter and pagination parameters for listing farms.
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
