package models

import (
	"time"

	"p9e.in/samavaya/packages/models"
)

// SatelliteProvider represents the satellite data provider.
type SatelliteProvider string

const (
	SatelliteProviderUnspecified SatelliteProvider = ""
	SatelliteProviderSentinel2  SatelliteProvider = "SENTINEL2"
	SatelliteProviderLandsat    SatelliteProvider = "LANDSAT"
	SatelliteProviderPlanetScope SatelliteProvider = "PLANETSCOPE"
)

// IsValid checks if the satellite provider is a valid value.
func (sp SatelliteProvider) IsValid() bool {
	switch sp {
	case SatelliteProviderSentinel2, SatelliteProviderLandsat, SatelliteProviderPlanetScope:
		return true
	default:
		return false
	}
}

// IngestionStatus represents the status of an ingestion task.
type IngestionStatus string

const (
	IngestionStatusUnspecified IngestionStatus = ""
	IngestionStatusQueued      IngestionStatus = "QUEUED"
	IngestionStatusDownloading IngestionStatus = "DOWNLOADING"
	IngestionStatusValidating  IngestionStatus = "VALIDATING"
	IngestionStatusStored      IngestionStatus = "STORED"
	IngestionStatusFailed      IngestionStatus = "FAILED"
)

// IsValid checks if the ingestion status is a valid value.
func (is IngestionStatus) IsValid() bool {
	switch is {
	case IngestionStatusQueued, IngestionStatusDownloading, IngestionStatusValidating,
		IngestionStatusStored, IngestionStatusFailed:
		return true
	default:
		return false
	}
}

// SpectralBand represents a spectral band in satellite imagery.
type SpectralBand string

const (
	SpectralBandUnspecified SpectralBand = ""
	SpectralBandBlue       SpectralBand = "BLUE"
	SpectralBandGreen      SpectralBand = "GREEN"
	SpectralBandRed        SpectralBand = "RED"
	SpectralBandNIR        SpectralBand = "NIR"
	SpectralBandSWIR1      SpectralBand = "SWIR1"
	SpectralBandSWIR2      SpectralBand = "SWIR2"
	SpectralBandRedEdge1   SpectralBand = "RED_EDGE1"
	SpectralBandRedEdge2   SpectralBand = "RED_EDGE2"
	SpectralBandRedEdge3   SpectralBand = "RED_EDGE3"
)

// IsValid checks if the spectral band is a valid value.
func (sb SpectralBand) IsValid() bool {
	switch sb {
	case SpectralBandBlue, SpectralBandGreen, SpectralBandRed, SpectralBandNIR,
		SpectralBandSWIR1, SpectralBandSWIR2,
		SpectralBandRedEdge1, SpectralBandRedEdge2, SpectralBandRedEdge3:
		return true
	default:
		return false
	}
}

// IngestionTask represents a satellite imagery ingestion task in the domain.
type IngestionTask struct {
	models.BaseModel
	TenantID          string            `json:"tenant_id" db:"tenant_id"`
	FarmID            int64             `json:"farm_id" db:"farm_id"`
	FarmUUID          string            `json:"farm_uuid" db:"farm_uuid"`
	Provider          SatelliteProvider `json:"provider" db:"provider"`
	SceneID           string            `json:"scene_id" db:"scene_id"`
	Status            IngestionStatus   `json:"status" db:"status"`
	S3Bucket          *string           `json:"s3_bucket,omitempty" db:"s3_bucket"`
	S3Key             *string           `json:"s3_key,omitempty" db:"s3_key"`
	CloudCoverPercent float64           `json:"cloud_cover_percent" db:"cloud_cover_percent"`
	ResolutionMeters  float64           `json:"resolution_meters" db:"resolution_meters"`
	Bands             []SpectralBand    `json:"bands" db:"bands"`
	BboxGeoJSON       *string           `json:"bbox_geojson,omitempty" db:"bbox_geojson"`
	FileSizeBytes     int64             `json:"file_size_bytes" db:"file_size_bytes"`
	ChecksumSHA256    *string           `json:"checksum_sha256,omitempty" db:"checksum_sha256"`
	ErrorMessage      *string           `json:"error_message,omitempty" db:"error_message"`
	RetryCount        int32             `json:"retry_count" db:"retry_count"`
	AcquisitionDate   *time.Time        `json:"acquisition_date,omitempty" db:"acquisition_date"`
	CompletedAt       *time.Time        `json:"completed_at,omitempty" db:"completed_at"`
	Version           int64             `json:"version" db:"version"`
}

// GetID returns the primary key of the ingestion task.
func (t *IngestionTask) GetID() int64 {
	return t.ID
}

// GetUUID returns the ULID identifier of the ingestion task.
func (t *IngestionTask) GetUUID() string {
	return t.UUID
}

// ListIngestionTasksParams holds the filter and pagination parameters for listing ingestion tasks.
type ListIngestionTasksParams struct {
	TenantID string
	FarmUUID *string
	Provider *SatelliteProvider
	Status   *IngestionStatus
	PageSize int32
	Offset   int32
}

// IngestionStats holds aggregated statistics for ingestion tasks.
type IngestionStats struct {
	TotalTasks       int64 `json:"total_tasks"`
	CompletedTasks   int64 `json:"completed_tasks"`
	FailedTasks      int64 `json:"failed_tasks"`
	PendingTasks     int64 `json:"pending_tasks"`
	TotalBytesStored int64 `json:"total_bytes_stored"`
}
