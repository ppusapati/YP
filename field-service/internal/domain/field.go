package domain

import (
	"time"

	"p9e.in/samavaya/packages/models"
)

type FieldStatus string

const (
	FieldStatusUnspecified FieldStatus = ""
	FieldStatusActive     FieldStatus = "ACTIVE"
	FieldStatusFallow     FieldStatus = "FALLOW"
	FieldStatusPreparation FieldStatus = "PREPARATION"
	FieldStatusPlanted    FieldStatus = "PLANTED"
	FieldStatusHarvesting FieldStatus = "HARVESTING"
	FieldStatusRetired    FieldStatus = "RETIRED"
)

func (s FieldStatus) IsValid() bool {
	switch s {
	case FieldStatusActive, FieldStatusFallow, FieldStatusPreparation,
		FieldStatusPlanted, FieldStatusHarvesting, FieldStatusRetired:
		return true
	}
	return false
}

type FieldType string

const (
	FieldTypeUnspecified FieldType = ""
	FieldTypeCropland   FieldType = "CROPLAND"
	FieldTypePasture    FieldType = "PASTURE"
	FieldTypeOrchard    FieldType = "ORCHARD"
	FieldTypeVineyard   FieldType = "VINEYARD"
	FieldTypeGreenhouse FieldType = "GREENHOUSE"
	FieldTypeNursery    FieldType = "NURSERY"
	FieldTypeAgroforest FieldType = "AGROFOREST"
)

func (t FieldType) IsValid() bool {
	switch t {
	case FieldTypeCropland, FieldTypePasture, FieldTypeOrchard,
		FieldTypeVineyard, FieldTypeGreenhouse, FieldTypeNursery, FieldTypeAgroforest:
		return true
	}
	return false
}

type SoilType string

const (
	SoilTypeUnspecified SoilType = ""
	SoilTypeClay       SoilType = "CLAY"
	SoilTypeSandy      SoilType = "SANDY"
	SoilTypeLoamy      SoilType = "LOAMY"
	SoilTypeSilt       SoilType = "SILT"
	SoilTypePeat       SoilType = "PEAT"
	SoilTypeChalk      SoilType = "CHALK"
	SoilTypeClayLoam   SoilType = "CLAY_LOAM"
	SoilTypeSandyLoam  SoilType = "SANDY_LOAM"
)

type IrrigationType string

const (
	IrrigationTypeUnspecified IrrigationType = ""
	IrrigationTypeRainfed    IrrigationType = "RAINFED"
	IrrigationTypeDrip       IrrigationType = "DRIP"
	IrrigationTypeSprinkler  IrrigationType = "SPRINKLER"
	IrrigationTypeFlood      IrrigationType = "FLOOD"
	IrrigationTypeCenterPivot IrrigationType = "CENTER_PIVOT"
	IrrigationTypeFurrow     IrrigationType = "FURROW"
	IrrigationTypeSubsurface IrrigationType = "SUBSURFACE"
)

type GrowthStage string

const (
	GrowthStageUnspecified GrowthStage = ""
	GrowthStageGermination GrowthStage = "GERMINATION"
	GrowthStageSeedling   GrowthStage = "SEEDLING"
	GrowthStageVegetative GrowthStage = "VEGETATIVE"
	GrowthStageBudding    GrowthStage = "BUDDING"
	GrowthStageFlowering  GrowthStage = "FLOWERING"
	GrowthStageFruitSet   GrowthStage = "FRUIT_SET"
	GrowthStageRipening   GrowthStage = "RIPENING"
	GrowthStageMaturity   GrowthStage = "MATURITY"
	GrowthStageSenescence GrowthStage = "SENESCENCE"
)

type AspectDirection string

const (
	AspectDirectionUnspecified AspectDirection = ""
	AspectDirectionNorth      AspectDirection = "NORTH"
	AspectDirectionNortheast  AspectDirection = "NORTHEAST"
	AspectDirectionEast       AspectDirection = "EAST"
	AspectDirectionSoutheast  AspectDirection = "SOUTHEAST"
	AspectDirectionSouth      AspectDirection = "SOUTH"
	AspectDirectionSouthwest  AspectDirection = "SOUTHWEST"
	AspectDirectionWest       AspectDirection = "WEST"
	AspectDirectionNorthwest  AspectDirection = "NORTHWEST"
	AspectDirectionFlat       AspectDirection = "FLAT"
)

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

type FieldSummary struct {
	UUID     string      `json:"uuid"`
	TenantID string      `json:"tenant_id"`
	FarmID   string      `json:"farm_id"`
	Name     string      `json:"name"`
	AreaHa   float64     `json:"area_ha"`
	Status   FieldStatus `json:"status"`
}

type FieldBoundary struct {
	ID              string     `json:"id"`
	TenantID        string     `json:"tenant_id"`
	FieldID         string     `json:"field_id"`
	Polygon         string     `json:"polygon"`
	AreaHectares    float64    `json:"area_hectares"`
	PerimeterMeters float64    `json:"perimeter_meters"`
	Source          string     `json:"source"`
	RecordedAt      *time.Time `json:"recorded_at,omitempty"`
	CreatedAt       time.Time  `json:"created_at"`
}

type CropAssignment struct {
	ID                  string      `json:"id"`
	TenantID            string      `json:"tenant_id"`
	FieldID             string      `json:"field_id"`
	CropID              string      `json:"crop_id"`
	CropVariety         string      `json:"crop_variety"`
	PlantingDate        *time.Time  `json:"planting_date,omitempty"`
	ExpectedHarvestDate *time.Time  `json:"expected_harvest_date,omitempty"`
	ActualHarvestDate   *time.Time  `json:"actual_harvest_date,omitempty"`
	GrowthStage         GrowthStage `json:"growth_stage"`
	YieldPerHectare     float64     `json:"yield_per_hectare"`
	Season              string      `json:"season"`
	Notes               string      `json:"notes"`
	CreatedAt           time.Time   `json:"created_at"`
	UpdatedAt           time.Time   `json:"updated_at"`
}

type FieldSegment struct {
	ID            string   `json:"id"`
	TenantID      string   `json:"tenant_id"`
	FieldID       string   `json:"field_id"`
	Name          string   `json:"name"`
	Boundary      string   `json:"boundary"`
	AreaHectares  float64  `json:"area_hectares"`
	SoilType      SoilType `json:"soil_type"`
	CurrentCropID string   `json:"current_crop_id"`
	Notes         string   `json:"notes"`
	SegmentIndex  int32    `json:"segment_index"`
	CreatedAt     time.Time `json:"created_at"`
	UpdatedAt     time.Time `json:"updated_at"`
}

type ListFieldsParams struct {
	TenantID  string
	FarmID    *string
	Status    *FieldStatus
	FieldType *FieldType
	Search    *string
	PageSize  int32
	Offset    int32
}

type AssignCropParams struct {
	FieldUUID           string
	CropID              string
	CropVariety         string
	PlantingDate        time.Time
	ExpectedHarvestDate *time.Time
	GrowthStage         GrowthStage
	Season              string
	Notes               string
}

type SetBoundaryParams struct {
	FieldID string
	Polygon string
	Source  string
}

type SegmentFieldParams struct {
	FieldID  string
	Segments []FieldSegmentInput
}

type FieldSegmentInput struct {
	Name         string
	Boundary     string
	AreaHectares float64
	SoilType     SoilType
	Notes        string
}

type CropHistoryParams struct {
	FieldID  string
	PageSize int32
	Offset   int32
}
