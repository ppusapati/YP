package models

import (
	"time"
)

// GeoPoint represents a geographic coordinate.
type GeoPoint struct {
	Longitude float64 `json:"longitude"`
	Latitude  float64 `json:"latitude"`
}

// GeoPolygon represents a closed polygon of geographic coordinates.
type GeoPolygon struct {
	Points []GeoPoint `json:"points"`
}

// FieldStatus represents the lifecycle status of a field.
type FieldStatus string

const (
	FieldStatusUnspecified FieldStatus = "unspecified"
	FieldStatusActive      FieldStatus = "active"
	FieldStatusFallow      FieldStatus = "fallow"
	FieldStatusPreparation FieldStatus = "preparation"
	FieldStatusPlanted     FieldStatus = "planted"
	FieldStatusHarvesting  FieldStatus = "harvesting"
	FieldStatusRetired     FieldStatus = "retired"
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
	FieldTypeUnspecified FieldType = "unspecified"
	FieldTypeCropland    FieldType = "cropland"
	FieldTypePasture     FieldType = "pasture"
	FieldTypeOrchard     FieldType = "orchard"
	FieldTypeVineyard    FieldType = "vineyard"
	FieldTypeGreenhouse  FieldType = "greenhouse"
	FieldTypeNursery     FieldType = "nursery"
	FieldTypeAgroforest  FieldType = "agroforest"
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
	SoilTypeUnspecified SoilType = "unspecified"
	SoilTypeCite        SoilType = "clay"
	SoilTypeSandy       SoilType = "sandy"
	SoilTypeLoamy       SoilType = "loamy"
	SoilTypeSilt        SoilType = "silt"
	SoilTypePeat        SoilType = "peat"
	SoilTypeChalk       SoilType = "chalk"
	SoilTypeClayLoam    SoilType = "clay_loam"
	SoilTypeSandyLoam   SoilType = "sandy_loam"
)

// IrrigationType represents the irrigation method.
type IrrigationType string

const (
	IrrigationTypeUnspecified  IrrigationType = "unspecified"
	IrrigationTypeRainfed      IrrigationType = "rainfed"
	IrrigationTypeDrip         IrrigationType = "drip"
	IrrigationTypeSprinkler    IrrigationType = "sprinkler"
	IrrigationTypeFlood        IrrigationType = "flood"
	IrrigationTypeCenterPivot  IrrigationType = "center_pivot"
	IrrigationTypeFurrow       IrrigationType = "furrow"
	IrrigationTypeSubsurface   IrrigationType = "subsurface"
)

// GrowthStage represents the crop growth phase.
type GrowthStage string

const (
	GrowthStageUnspecified GrowthStage = "unspecified"
	GrowthStageGermination GrowthStage = "germination"
	GrowthStageSeedling    GrowthStage = "seedling"
	GrowthStageVegetative  GrowthStage = "vegetative"
	GrowthStageBudding     GrowthStage = "budding"
	GrowthStageFlowering   GrowthStage = "flowering"
	GrowthStageFruitSet    GrowthStage = "fruit_set"
	GrowthStageRipening    GrowthStage = "ripening"
	GrowthStageMaturity    GrowthStage = "maturity"
	GrowthStageSenescence  GrowthStage = "senescence"
)

// AspectDirection represents the compass direction a slope faces.
type AspectDirection string

const (
	AspectDirectionUnspecified AspectDirection = "unspecified"
	AspectDirectionNorth       AspectDirection = "north"
	AspectDirectionNortheast   AspectDirection = "northeast"
	AspectDirectionEast        AspectDirection = "east"
	AspectDirectionSoutheast   AspectDirection = "southeast"
	AspectDirectionSouth       AspectDirection = "south"
	AspectDirectionSouthwest   AspectDirection = "southwest"
	AspectDirectionWest        AspectDirection = "west"
	AspectDirectionNorthwest   AspectDirection = "northwest"
	AspectDirectionFlat        AspectDirection = "flat"
)

// Field is the core domain entity representing an agricultural field.
type Field struct {
	ID                  string          `json:"id" db:"id"`
	TenantID            string          `json:"tenant_id" db:"tenant_id"`
	FarmID              string          `json:"farm_id" db:"farm_id"`
	Name                string          `json:"name" db:"name"`
	AreaHectares        float64         `json:"area_hectares" db:"area_hectares"`
	Boundary            *GeoPolygon     `json:"boundary,omitempty"`
	BoundaryGeoJSON     *string         `json:"boundary_geojson,omitempty" db:"boundary_geojson"`
	CurrentCropID       *string         `json:"current_crop_id,omitempty" db:"current_crop_id"`
	PlantingDate        *time.Time      `json:"planting_date,omitempty" db:"planting_date"`
	ExpectedHarvestDate *time.Time      `json:"expected_harvest_date,omitempty" db:"expected_harvest_date"`
	GrowthStage         GrowthStage     `json:"growth_stage" db:"growth_stage"`
	SoilType            SoilType        `json:"soil_type" db:"soil_type"`
	IrrigationType      IrrigationType  `json:"irrigation_type" db:"irrigation_type"`
	FieldType           FieldType       `json:"field_type" db:"field_type"`
	Status              FieldStatus     `json:"status" db:"status"`
	ElevationMeters     float64         `json:"elevation_meters" db:"elevation_meters"`
	SlopeDegrees        float64         `json:"slope_degrees" db:"slope_degrees"`
	AspectDirection     AspectDirection `json:"aspect_direction" db:"aspect_direction"`
	CreatedBy           string          `json:"created_by" db:"created_by"`
	UpdatedBy           string          `json:"updated_by" db:"updated_by"`
	CreatedAt           time.Time       `json:"created_at" db:"created_at"`
	UpdatedAt           time.Time       `json:"updated_at" db:"updated_at"`
	DeletedAt           *time.Time      `json:"deleted_at,omitempty" db:"deleted_at"`
	Version             int64           `json:"version" db:"version"`
}

// GetID returns the ID field for the Entity interface.
func (f *Field) GetID() int64 { return 0 }

// GetUUID returns the UUID/ULID field for the Entity interface.
func (f *Field) GetUUID() string { return f.ID }

// FieldBoundary stores a historical boundary recording for a field.
type FieldBoundary struct {
	ID              string     `json:"id" db:"id"`
	FieldID         string     `json:"field_id" db:"field_id"`
	PolygonGeoJSON  *string    `json:"polygon_geojson,omitempty" db:"polygon_geojson"`
	Polygon         *GeoPolygon `json:"polygon,omitempty"`
	AreaHectares    float64    `json:"area_hectares" db:"area_hectares"`
	PerimeterMeters float64   `json:"perimeter_meters" db:"perimeter_meters"`
	Source          string     `json:"source" db:"source"`
	RecordedAt      time.Time  `json:"recorded_at" db:"recorded_at"`
	CreatedAt       time.Time  `json:"created_at" db:"created_at"`
}

// FieldCropAssignment represents a crop planted on a field in a specific season.
type FieldCropAssignment struct {
	ID                  string     `json:"id" db:"id"`
	FieldID             string     `json:"field_id" db:"field_id"`
	CropID              string     `json:"crop_id" db:"crop_id"`
	CropVariety         string     `json:"crop_variety" db:"crop_variety"`
	PlantingDate        time.Time  `json:"planting_date" db:"planting_date"`
	ExpectedHarvestDate *time.Time `json:"expected_harvest_date,omitempty" db:"expected_harvest_date"`
	ActualHarvestDate   *time.Time `json:"actual_harvest_date,omitempty" db:"actual_harvest_date"`
	GrowthStage         GrowthStage `json:"growth_stage" db:"growth_stage"`
	YieldPerHectare     float64    `json:"yield_per_hectare" db:"yield_per_hectare"`
	Notes               string     `json:"notes" db:"notes"`
	Season              string     `json:"season" db:"season"`
	CreatedAt           time.Time  `json:"created_at" db:"created_at"`
	UpdatedAt           time.Time  `json:"updated_at" db:"updated_at"`
}

// FieldSegment represents a sub-division of a field for zone management.
type FieldSegment struct {
	ID              string      `json:"id" db:"id"`
	FieldID         string      `json:"field_id" db:"field_id"`
	Name            string      `json:"name" db:"name"`
	BoundaryGeoJSON *string     `json:"boundary_geojson,omitempty" db:"boundary_geojson"`
	Boundary        *GeoPolygon `json:"boundary,omitempty"`
	AreaHectares    float64     `json:"area_hectares" db:"area_hectares"`
	SoilType        SoilType    `json:"soil_type" db:"soil_type"`
	CurrentCropID   *string     `json:"current_crop_id,omitempty" db:"current_crop_id"`
	Notes           string      `json:"notes" db:"notes"`
	SegmentIndex    int32       `json:"segment_index" db:"segment_index"`
	CreatedAt       time.Time   `json:"created_at" db:"created_at"`
	UpdatedAt       time.Time   `json:"updated_at" db:"updated_at"`
}

// CreateFieldInput encapsulates the data needed to create a new field.
type CreateFieldInput struct {
	FarmID          string
	Name            string
	AreaHectares    float64
	BoundaryGeoJSON *string
	FieldType       FieldType
	SoilType        SoilType
	IrrigationType  IrrigationType
	ElevationMeters float64
	SlopeDegrees    float64
	AspectDirection AspectDirection
}

// UpdateFieldInput encapsulates the data for updating an existing field.
type UpdateFieldInput struct {
	ID              string
	Name            *string
	AreaHectares    *float64
	FieldType       *FieldType
	SoilType        *SoilType
	IrrigationType  *IrrigationType
	Status          *FieldStatus
	ElevationMeters *float64
	SlopeDegrees    *float64
	AspectDirection *AspectDirection
	GrowthStage     *GrowthStage
}

// ListFieldsInput encapsulates filter/pagination parameters for listing fields.
type ListFieldsInput struct {
	FarmID    *string
	Status    *string
	FieldType *string
	Search    *string
	PageSize  int32
	PageOffset int32
}

// AssignCropInput encapsulates the data to assign a crop to a field.
type AssignCropInput struct {
	FieldID             string
	CropID              string
	CropVariety         string
	PlantingDate        time.Time
	ExpectedHarvestDate *time.Time
	Season              string
	Notes               string
}

// SegmentFieldInput represents input for creating a single segment.
type SegmentFieldInput struct {
	Name            string
	BoundaryGeoJSON *string
	AreaHectares    float64
	SoilType        SoilType
	Notes           string
}

// SetBoundaryInput encapsulates data for setting a field boundary.
type SetBoundaryInput struct {
	FieldID        string
	PolygonGeoJSON string
	AreaHectares   float64
	PerimeterMeters float64
	Source         string
}
