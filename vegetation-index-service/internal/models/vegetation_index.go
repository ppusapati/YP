package models

import (
	"time"

	"p9e.in/samavaya/packages/models"
)

// VegetationIndexType represents the type of vegetation index.
type VegetationIndexType string

const (
	VegetationIndexTypeUnspecified VegetationIndexType = ""
	VegetationIndexTypeNDVI       VegetationIndexType = "NDVI"
	VegetationIndexTypeNDWI       VegetationIndexType = "NDWI"
	VegetationIndexTypeEVI        VegetationIndexType = "EVI"
	VegetationIndexTypeSAVI       VegetationIndexType = "SAVI"
	VegetationIndexTypeMSAVI      VegetationIndexType = "MSAVI"
	VegetationIndexTypeNDRE       VegetationIndexType = "NDRE"
	VegetationIndexTypeGNDVI      VegetationIndexType = "GNDVI"
	VegetationIndexTypeLAI        VegetationIndexType = "LAI"
)

// IsValid checks if the vegetation index type is a valid value.
func (v VegetationIndexType) IsValid() bool {
	switch v {
	case VegetationIndexTypeNDVI, VegetationIndexTypeNDWI, VegetationIndexTypeEVI,
		VegetationIndexTypeSAVI, VegetationIndexTypeMSAVI, VegetationIndexTypeNDRE,
		VegetationIndexTypeGNDVI, VegetationIndexTypeLAI:
		return true
	default:
		return false
	}
}

// ComputeStatus represents the status of a compute task.
type ComputeStatus string

const (
	ComputeStatusUnspecified  ComputeStatus = ""
	ComputeStatusQueued       ComputeStatus = "QUEUED"
	ComputeStatusComputing    ComputeStatus = "COMPUTING"
	ComputeStatusIntersecting ComputeStatus = "INTERSECTING"
	ComputeStatusCompleted    ComputeStatus = "COMPLETED"
	ComputeStatusFailed       ComputeStatus = "FAILED"
)

// IsValid checks if the compute status is a valid value.
func (cs ComputeStatus) IsValid() bool {
	switch cs {
	case ComputeStatusQueued, ComputeStatusComputing, ComputeStatusIntersecting,
		ComputeStatusCompleted, ComputeStatusFailed:
		return true
	default:
		return false
	}
}

// IsTerminal returns true if the status is a terminal state.
func (cs ComputeStatus) IsTerminal() bool {
	return cs == ComputeStatusCompleted || cs == ComputeStatusFailed
}

// ComputeTask represents an index computation task.
type ComputeTask struct {
	models.BaseModel
	TenantID            string                `json:"tenant_id" db:"tenant_id"`
	ProcessingJobUUID   string                `json:"processing_job_uuid" db:"processing_job_uuid"`
	FarmUUID            string                `json:"farm_uuid" db:"farm_uuid"`
	IndexTypes          []VegetationIndexType `json:"index_types" db:"index_types"`
	Status              ComputeStatus         `json:"status" db:"status"`
	ErrorMessage        *string               `json:"error_message,omitempty" db:"error_message"`
	ComputeTimeSeconds  float64               `json:"compute_time_seconds" db:"compute_time_seconds"`
	Version             int64                 `json:"version" db:"version"`
	CompletedAt         *time.Time            `json:"completed_at,omitempty" db:"completed_at"`
}

// GetID returns the primary key of the compute task.
func (ct *ComputeTask) GetID() int64 {
	return ct.ID
}

// GetUUID returns the ULID identifier of the compute task.
func (ct *ComputeTask) GetUUID() string {
	return ct.UUID
}

// VegetationIndex represents a computed vegetation index for a field/farm.
type VegetationIndex struct {
	ID                int64       `json:"id" db:"id"`
	UUID              string      `json:"uuid" db:"uuid"`
	TenantID          string      `json:"tenant_id" db:"tenant_id"`
	FarmUUID          string      `json:"farm_uuid" db:"farm_uuid"`
	FieldUUID         *string     `json:"field_uuid,omitempty" db:"field_uuid"`
	ProcessingJobUUID string      `json:"processing_job_uuid" db:"processing_job_uuid"`
	ComputeTaskUUID   string      `json:"compute_task_uuid" db:"compute_task_uuid"`
	IndexType         VegetationIndexType `json:"index_type" db:"index_type"`
	MeanValue         float64     `json:"mean_value" db:"mean_value"`
	MinValue          float64     `json:"min_value" db:"min_value"`
	MaxValue          float64     `json:"max_value" db:"max_value"`
	StdDeviation      float64     `json:"std_deviation" db:"std_deviation"`
	MedianValue       float64     `json:"median_value" db:"median_value"`
	PixelCount        int64       `json:"pixel_count" db:"pixel_count"`
	CoveragePercent   float64     `json:"coverage_percent" db:"coverage_percent"`
	RasterS3Key       *string     `json:"raster_s3_key,omitempty" db:"raster_s3_key"`
	AcquisitionDate   time.Time   `json:"acquisition_date" db:"acquisition_date"`
	ComputedAt        time.Time   `json:"computed_at" db:"computed_at"`
	IsActive          bool        `json:"is_active" db:"is_active"`
	CreatedBy         string      `json:"created_by" db:"created_by"`
	CreatedAt         time.Time   `json:"created_at" db:"created_at"`
	DeletedAt         *time.Time  `json:"deleted_at,omitempty" db:"deleted_at"`
	DeletedBy         *string     `json:"deleted_by,omitempty" db:"deleted_by"`
}

// GetID returns the primary key of the vegetation index.
func (vi *VegetationIndex) GetID() int64 {
	return vi.ID
}

// GetUUID returns the ULID identifier of the vegetation index.
func (vi *VegetationIndex) GetUUID() string {
	return vi.UUID
}

// TimeSeriesPoint represents a single point in a vegetation index time series.
type TimeSeriesPoint struct {
	Date         time.Time `json:"date" db:"acquisition_date"`
	Value        float64   `json:"value" db:"mean_value"`
	StdDeviation float64   `json:"std_deviation" db:"std_deviation"`
}

// FieldHealthSummary represents the health summary for a field.
type FieldHealthSummary struct {
	CurrentNDVI    float64    `json:"current_ndvi" db:"current_ndvi"`
	NDVITrend      float64    `json:"ndvi_trend" db:"ndvi_trend"`
	HealthScore    float64    `json:"health_score"`
	HealthCategory string     `json:"health_category"`
	LastComputed   time.Time  `json:"last_computed" db:"last_computed"`
}

// ListVegetationIndicesParams holds the filter and pagination parameters for listing indices.
type ListVegetationIndicesParams struct {
	TenantID  string
	FarmUUID  *string
	FieldUUID *string
	IndexType *VegetationIndexType
	DateFrom  *time.Time
	DateTo    *time.Time
	PageSize  int32
	Offset    int32
}

// ListComputeTasksParams holds the filter and pagination parameters for listing compute tasks.
type ListComputeTasksParams struct {
	TenantID string
	FarmUUID *string
	Status   *ComputeStatus
	PageSize int32
	Offset   int32
}
