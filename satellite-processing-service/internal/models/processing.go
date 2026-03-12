package models

import (
	"time"

	"p9e.in/samavaya/packages/models"
)

// ProcessingStatus represents the status of a satellite processing job.
type ProcessingStatus string

const (
	ProcessingStatusUnspecified          ProcessingStatus = ""
	ProcessingStatusQueued               ProcessingStatus = "QUEUED"
	ProcessingStatusPreprocessing        ProcessingStatus = "PREPROCESSING"
	ProcessingStatusAtmosphericCorrection ProcessingStatus = "ATMOSPHERIC_CORRECTION"
	ProcessingStatusCloudMasking         ProcessingStatus = "CLOUD_MASKING"
	ProcessingStatusOrthorectification   ProcessingStatus = "ORTHORECTIFICATION"
	ProcessingStatusBandMath             ProcessingStatus = "BAND_MATH"
	ProcessingStatusCompleted            ProcessingStatus = "COMPLETED"
	ProcessingStatusFailed               ProcessingStatus = "FAILED"
)

// IsValid checks if the processing status is a valid value.
func (ps ProcessingStatus) IsValid() bool {
	switch ps {
	case ProcessingStatusQueued, ProcessingStatusPreprocessing,
		ProcessingStatusAtmosphericCorrection, ProcessingStatusCloudMasking,
		ProcessingStatusOrthorectification, ProcessingStatusBandMath,
		ProcessingStatusCompleted, ProcessingStatusFailed:
		return true
	default:
		return false
	}
}

// IsTerminal returns true if the status is a final state.
func (ps ProcessingStatus) IsTerminal() bool {
	return ps == ProcessingStatusCompleted || ps == ProcessingStatusFailed
}

// ProcessingLevel represents the processing level of satellite imagery.
type ProcessingLevel string

const (
	ProcessingLevelUnspecified ProcessingLevel = ""
	ProcessingLevelL1C        ProcessingLevel = "L1C"
	ProcessingLevelL2A        ProcessingLevel = "L2A"
	ProcessingLevelL3         ProcessingLevel = "L3"
)

// IsValid checks if the processing level is a valid value.
func (pl ProcessingLevel) IsValid() bool {
	switch pl {
	case ProcessingLevelL1C, ProcessingLevelL2A, ProcessingLevelL3:
		return true
	default:
		return false
	}
}

// CorrectionAlgorithm represents the atmospheric correction algorithm.
type CorrectionAlgorithm string

const (
	CorrectionAlgorithmUnspecified CorrectionAlgorithm = ""
	CorrectionAlgorithmSen2Cor    CorrectionAlgorithm = "SEN2COR"
	CorrectionAlgorithmLaSRC      CorrectionAlgorithm = "LASRC"
	CorrectionAlgorithmFLAASH     CorrectionAlgorithm = "FLAASH"
	CorrectionAlgorithmDOS        CorrectionAlgorithm = "DOS"
)

// IsValid checks if the correction algorithm is a valid value.
func (ca CorrectionAlgorithm) IsValid() bool {
	switch ca {
	case CorrectionAlgorithmSen2Cor, CorrectionAlgorithmLaSRC,
		CorrectionAlgorithmFLAASH, CorrectionAlgorithmDOS:
		return true
	default:
		return false
	}
}

// ProcessingJob represents a satellite imagery processing job in the domain.
type ProcessingJob struct {
	models.BaseModel
	TenantID                   string              `json:"tenant_id" db:"tenant_id"`
	IngestionTaskUUID          string              `json:"ingestion_task_uuid" db:"ingestion_task_uuid"`
	FarmUUID                   string              `json:"farm_uuid" db:"farm_uuid"`
	Status                     ProcessingStatus    `json:"status" db:"status"`
	InputLevel                 ProcessingLevel     `json:"input_level" db:"input_level"`
	OutputLevel                ProcessingLevel     `json:"output_level" db:"output_level"`
	Algorithm                  CorrectionAlgorithm `json:"algorithm" db:"algorithm"`
	InputS3Key                 string              `json:"input_s3_key" db:"input_s3_key"`
	OutputS3Key                *string             `json:"output_s3_key,omitempty" db:"output_s3_key"`
	CloudMaskThreshold         float64             `json:"cloud_mask_threshold" db:"cloud_mask_threshold"`
	ApplyAtmosphericCorrection bool                `json:"apply_atmospheric_correction" db:"apply_atmospheric_correction"`
	ApplyCloudMasking          bool                `json:"apply_cloud_masking" db:"apply_cloud_masking"`
	ApplyOrthorectification    bool                `json:"apply_orthorectification" db:"apply_orthorectification"`
	OutputResolutionMeters     int32               `json:"output_resolution_meters" db:"output_resolution_meters"`
	OutputCRS                  string              `json:"output_crs" db:"output_crs"`
	ErrorMessage               *string             `json:"error_message,omitempty" db:"error_message"`
	ProcessingTimeSeconds      *float64            `json:"processing_time_seconds,omitempty" db:"processing_time_seconds"`
	CompletedAt                *time.Time          `json:"completed_at,omitempty" db:"completed_at"`
}

// GetID returns the primary key of the processing job.
func (j *ProcessingJob) GetID() int64 {
	return j.ID
}

// GetUUID returns the ULID identifier of the processing job.
func (j *ProcessingJob) GetUUID() string {
	return j.UUID
}

// ListProcessingJobsParams holds the filter and pagination parameters for listing processing jobs.
type ListProcessingJobsParams struct {
	TenantID string
	FarmUUID *string
	Status   *ProcessingStatus
	PageSize int32
	Offset   int32
}

// ProcessingStats holds aggregated statistics for processing jobs.
type ProcessingStats struct {
	TotalJobs                int64   `json:"total_jobs"`
	CompletedJobs            int64   `json:"completed_jobs"`
	FailedJobs               int64   `json:"failed_jobs"`
	PendingJobs              int64   `json:"pending_jobs"`
	AvgProcessingTimeSeconds float64 `json:"avg_processing_time_seconds"`
}
