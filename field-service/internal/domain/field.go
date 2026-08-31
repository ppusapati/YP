// Package domain contains the pure domain model for the field service.
// It has no imports from infrastructure packages (databases, HTTP, Kafka, proto).
package domain

import (
	"time"

	"p9e.in/samavaya/packages/models"
)

// FieldStatus represents the lifecycle status of a field.
type FieldStatus string

const (
	FieldStatusUnspecified FieldStatus = ""
	FieldStatusActive      FieldStatus = "ACTIVE"
	FieldStatusFallow      FieldStatus = "FALLOW"
	FieldStatusPreparation FieldStatus = "PREPARATION"
	FieldStatusPlanted     FieldStatus = "PLANTED"
	FieldStatusHarvesting  FieldStatus = "HARVESTING"
	FieldStatusRetired     FieldStatus = "RETIRED"
)

// IsValid returns true if the status is a recognized value.
func (s FieldStatus) IsValid() bool {
	switch s {
	case FieldStatusActive, FieldStatusFallow, FieldStatusPreparation,
		FieldStatusPlanted, FieldStatusHarvesting, FieldStatusRetired:
		return true
	}
	return false
}

// FieldType represents the category of the field.
type FieldType string

const (
	FieldTypeUnspecified FieldType = ""
	FieldTypeCropland    FieldType = "CROPLAND"
	FieldTypePasture     FieldType = "PASTURE"
	FieldTypeOrchard     FieldType = "ORCHARD"
	FieldTypeVineyard    FieldType = "VINEYARD"
	FieldTypeGreenhouse  FieldType = "GREENHOUSE"
	FieldTypeNursery     FieldType = "NURSERY"
	FieldTypeAgroforest  FieldType = "AGROFOREST"
)

// IsValid returns true if the field type is recognized.
func (t FieldType) IsValid() bool {
	switch t {
	case FieldTypeCropland, FieldTypePasture, FieldTypeOrchard,
		FieldTypeVineyard, FieldTypeGreenhouse, FieldTypeNursery, FieldTypeAgroforest:
		return true
	}
	return false
}

// SoilType represents the soil composition of a field.
type SoilType string

const (
	SoilTypeUnspecified SoilType = ""
	SoilTypeClay        SoilType = "CLAY"
	SoilTypeSandy       SoilType = "SANDY"
	SoilTypeLoamy       SoilType = "LOAMY"
	SoilTypeSilt        SoilType = "SILT"
	SoilTypePeat        SoilType = "PEAT"
	SoilTypeChalk       SoilType = "CHALK"
	SoilTypeClayLoam    SoilType = "CLAY_LOAM"
	SoilTypeSandyLoam   SoilType = "SANDY_LOAM"
)

// IrrigationType represents the irrigation method.
type IrrigationType string

const (
	IrrigationTypeUnspecified IrrigationType = ""
	IrrigationTypeRainfed     IrrigationType = "RAINFED"
	IrrigationTypeDrip        IrrigationType = "DRIP"
	IrrigationTypeSprinkler   IrrigationType = "SPRINKLER"
	IrrigationTypeFlood       IrrigationType = "FLOOD"
	IrrigationTypeCenterPivot IrrigationType = "CENTER_PIVOT"
	IrrigationTypeFurrow      IrrigationType = "FURROW"
	IrrigationTypeSubsurface  IrrigationType = "SUBSURFACE"
)

// GrowthStage represents the crop growth phase.
type GrowthStage string

const (
	GrowthStageUnspecified GrowthStage = ""
	GrowthStageGermination GrowthStage = "GERMINATION"
	GrowthStageSeedling    GrowthStage = "SEEDLING"
	GrowthStageVegetative  GrowthStage = "VEGETATIVE"
	GrowthStageBudding     GrowthStage = "BUDDING"
	GrowthStageFlowering   GrowthStage = "FLOWERING"
	GrowthStageFruitSet    GrowthStage = "FRUIT_SET"
	GrowthStageRipening    GrowthStage = "RIPENING"
	GrowthStageMaturity    GrowthStage = "MATURITY"
	GrowthStageSenescence  GrowthStage = "SENESCENCE"
)

// AspectDirection represents the compass direction a slope faces.
type AspectDirection string

const (
	AspectDirectionUnspecified AspectDirection = ""
	AspectDirectionNorth       AspectDirection = "NORTH"
	AspectDirectionNortheast   AspectDirection = "NORTHEAST"
	AspectDirectionEast        AspectDirection = "EAST"
	AspectDirectionSoutheast   AspectDirection = "SOUTHEAST"
	AspectDirectionSouth       AspectDirection = "SOUTH"
	AspectDirectionSouthwest   AspectDirection = "SOUTHWEST"
	AspectDirectionWest        AspectDirection = "WEST"
	AspectDirectionNorthwest   AspectDirection = "NORTHWEST"
	AspectDirectionFlat        AspectDirection = "FLAT"
)

// Field is the core domain entity representing an agricultural field.
type Field struct {
	models.BaseModel
	TenantID            string          `json:"tenant_id"`
	FarmID              string          `json:"farm_id"`
	Name                string          `json:"name"`
	AreaHectares        float64         `json:"area_hectares"`
	BoundaryGeoJSON     *string         `json:"boundary_geojson,omitempty"`
	CurrentCropID       *string         `json:"current_crop_id,omitempty"`
	PlantingDate        *time.Time      `json:"planting_date,omitempty"`
	ExpectedHarvestDate *time.Time      `json:"expected_harvest_date,omitempty"`
	GrowthStage         GrowthStage     `json:"growth_stage"`
	SoilType            SoilType        `json:"soil_type"`
	IrrigationType      IrrigationType  `json:"irrigation_type"`
	FieldType           FieldType       `json:"field_type"`
	Status              FieldStatus     `json:"status"`
	ElevationMeters     float64         `json:"elevation_meters"`
	SlopeDegrees        float64         `json:"slope_degrees"`
	AspectDirection     AspectDirection `json:"aspect_direction"`
	Version             int64           `json:"version"`
}

// FieldSummary is a lightweight representation used by other services.
type FieldSummary struct {
	UUID     string      `json:"uuid"`
	TenantID string      `json:"tenant_id"`
	FarmID   string      `json:"farm_id"`
	Name     string      `json:"name"`
	AreaHa   float64     `json:"area_ha"`
	Status   FieldStatus `json:"status"`
}

// ListFieldsParams holds filter and pagination parameters for listing fields.
type ListFieldsParams struct {
	TenantID  string
	FarmID    *string
	Status    *FieldStatus
	FieldType *FieldType
	Search    *string
	PageSize  int32
	Offset    int32
}

// AssignCropParams holds parameters for assigning a crop to a field.
type AssignCropParams struct {
	FieldUUID           string
	CropID              string
	PlantingDate        time.Time
	ExpectedHarvestDate *time.Time
	GrowthStage         GrowthStage
}
