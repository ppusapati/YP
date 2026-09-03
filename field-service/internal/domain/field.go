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

// CropCycleStatus represents the lifecycle status of a crop cycle.
type CropCycleStatus string

const (
	CropCycleStatusUnspecified CropCycleStatus = ""
	CropCycleStatusPlanned    CropCycleStatus = "CYCLE_STATUS_PLANNED"
	CropCycleStatusActive     CropCycleStatus = "CYCLE_STATUS_ACTIVE"
	CropCycleStatusHarvesting CropCycleStatus = "CYCLE_STATUS_HARVESTING"
	CropCycleStatusCompleted  CropCycleStatus = "CYCLE_STATUS_COMPLETED"
	CropCycleStatusAbandoned  CropCycleStatus = "CYCLE_STATUS_ABANDONED"
)

func (s CropCycleStatus) IsValid() bool {
	switch s {
	case CropCycleStatusPlanned, CropCycleStatusActive, CropCycleStatusHarvesting,
		CropCycleStatusCompleted, CropCycleStatusAbandoned:
		return true
	}
	return false
}

// ActivityCategory classifies field activities.
type ActivityCategory string

const (
	ActivityCategoryUnspecified   ActivityCategory = ""
	ActivityCategoryLandPrep     ActivityCategory = "CATEGORY_LAND_PREP"
	ActivityCategoryPlanting     ActivityCategory = "CATEGORY_PLANTING"
	ActivityCategoryIrrigation   ActivityCategory = "CATEGORY_IRRIGATION"
	ActivityCategoryFertilization ActivityCategory = "CATEGORY_FERTILIZATION"
	ActivityCategoryPestControl  ActivityCategory = "CATEGORY_PEST_CONTROL"
	ActivityCategoryScouting     ActivityCategory = "CATEGORY_SCOUTING"
	ActivityCategoryHarvesting   ActivityCategory = "CATEGORY_HARVESTING"
	ActivityCategoryPostHarvest  ActivityCategory = "CATEGORY_POST_HARVEST"
	ActivityCategorySoilSampling ActivityCategory = "CATEGORY_SOIL_SAMPLING"
	ActivityCategoryMaintenance  ActivityCategory = "CATEGORY_MAINTENANCE"
)

// CropCycle is a season-level aggregate linking field, crop, and lifecycle data.
type CropCycle struct {
	ID                    string          `json:"id"`
	TenantID              string          `json:"tenant_id"`
	FieldID               string          `json:"field_id"`
	CropID                string          `json:"crop_id"`
	CropAssignmentID      *string         `json:"crop_assignment_id,omitempty"`
	ManagementUnitID      *string         `json:"management_unit_id,omitempty"`
	Season                string          `json:"season"`
	CycleYear             int32           `json:"cycle_year"`
	Name                  *string         `json:"name,omitempty"`
	PlannedPlantingDate   *time.Time      `json:"planned_planting_date,omitempty"`
	ActualPlantingDate    *time.Time      `json:"actual_planting_date,omitempty"`
	PlannedHarvestDate    *time.Time      `json:"planned_harvest_date,omitempty"`
	ActualHarvestDate     *time.Time      `json:"actual_harvest_date,omitempty"`
	Status                CropCycleStatus `json:"status"`
	TargetYieldPerHectare *float64        `json:"target_yield_per_hectare,omitempty"`
	ActualYieldPerHectare *float64        `json:"actual_yield_per_hectare,omitempty"`
	YieldUnit             *string         `json:"yield_unit,omitempty"`
	TotalInputCost        int64           `json:"total_input_cost"`
	TotalRevenue          int64           `json:"total_revenue"`
	Currency              string          `json:"currency"`
	Notes                 *string         `json:"notes,omitempty"`
	Version               int64           `json:"version"`
	CreatedBy             string          `json:"created_by"`
	UpdatedBy             *string         `json:"updated_by,omitempty"`
	CreatedAt             time.Time       `json:"created_at"`
	UpdatedAt             time.Time       `json:"updated_at"`
	DeletedAt             *time.Time      `json:"deleted_at,omitempty"`
}

type ListCropCyclesParams struct {
	TenantID string
	FieldID  string
	Status   *CropCycleStatus
	PageSize int32
	Offset   int32
}

// ActivityEvent is an immutable log entry for actions taken on a field.
type ActivityEvent struct {
	ID               string           `json:"id"`
	TenantID         string           `json:"tenant_id"`
	FieldID          string           `json:"field_id"`
	CropCycleID      *string          `json:"crop_cycle_id,omitempty"`
	PerformedBy      string           `json:"performed_by"`
	ActivityType     string           `json:"activity_type"`
	Category         ActivityCategory `json:"category"`
	StartedAt        time.Time        `json:"started_at"`
	CompletedAt      *time.Time       `json:"completed_at,omitempty"`
	DurationMinutes  *int32           `json:"duration_minutes,omitempty"`
	Description      *string          `json:"description,omitempty"`
	Notes            *string          `json:"notes,omitempty"`
	InputProductID   *string          `json:"input_product_id,omitempty"`
	InputQuantity    *float64         `json:"input_quantity,omitempty"`
	InputUnit        *string          `json:"input_unit,omitempty"`
	InputCost        int64            `json:"input_cost"`
	Currency         string           `json:"currency"`
	AreaHectares     *float64         `json:"area_hectares,omitempty"`
	WeatherTempC     *float64         `json:"weather_temp_celsius,omitempty"`
	WeatherHumidity  *float64         `json:"weather_humidity_pct,omitempty"`
	WeatherWindSpeed *float64         `json:"weather_wind_speed_kmh,omitempty"`
	WeatherConditions *string         `json:"weather_conditions,omitempty"`
	CreatedAt        time.Time        `json:"created_at"`
}

type ListActivityEventsParams struct {
	TenantID    string
	FieldID     string
	CropCycleID *string
	Category    *ActivityCategory
	PageSize    int32
	Offset      int32
}

// EvidenceType classifies activity evidence attachments.
type EvidenceType string

const (
	EvidenceTypePhoto    EvidenceType = "EVIDENCE_TYPE_PHOTO"
	EvidenceTypeDocument EvidenceType = "EVIDENCE_TYPE_DOCUMENT"
	EvidenceTypeVideo    EvidenceType = "EVIDENCE_TYPE_VIDEO"
	EvidenceTypeAudio    EvidenceType = "EVIDENCE_TYPE_AUDIO"
	EvidenceTypeOther    EvidenceType = "EVIDENCE_TYPE_OTHER"
)

// ActivityEvidence is a photo, document, or other attachment linked to an activity event.
type ActivityEvidence struct {
	ID              string       `json:"id"`
	TenantID        string       `json:"tenant_id"`
	ActivityEventID string       `json:"activity_event_id"`
	EvidenceType    EvidenceType `json:"evidence_type"`
	FileURL         string       `json:"file_url"`
	FileName        *string      `json:"file_name,omitempty"`
	FileSizeBytes   *int64       `json:"file_size_bytes,omitempty"`
	MimeType        *string      `json:"mime_type,omitempty"`
	ThumbnailURL    *string      `json:"thumbnail_url,omitempty"`
	Caption         *string      `json:"caption,omitempty"`
	Latitude        *float64     `json:"latitude,omitempty"`
	Longitude       *float64     `json:"longitude,omitempty"`
	CapturedAt      *time.Time   `json:"captured_at,omitempty"`
	CapturedBy      string       `json:"captured_by"`
	CreatedAt       time.Time    `json:"created_at"`
}

type ListActivityEvidenceParams struct {
	TenantID        string
	ActivityEventID string
	PageSize        int32
	Offset          int32
}
