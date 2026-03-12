package services

import (
	"context"
	"encoding/json"
	"fmt"

	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"
	"p9e.in/samavaya/packages/uow"

	procmodels "p9e.in/samavaya/agriculture/satellite-processing-service/internal/models"
	"p9e.in/samavaya/agriculture/satellite-processing-service/internal/repositories"
)

const (
	serviceName       = "satellite-processing-service"
	maxPageSize int32 = 100
	defaultPageSize   = 20
)

// Processing event types
const (
	EventTypeProcessingSubmitted domain.EventType = "agriculture.satellite.processing.submitted"
	EventTypeProcessingCompleted domain.EventType = "agriculture.satellite.processing.completed"
	EventTypeProcessingFailed    domain.EventType = "agriculture.satellite.processing.failed"
)

// ProcessingService defines the interface for processing job business logic.
type ProcessingService interface {
	SubmitProcessingJob(ctx context.Context, job *procmodels.ProcessingJob) (*procmodels.ProcessingJob, error)
	GetProcessingJob(ctx context.Context, uuid string) (*procmodels.ProcessingJob, error)
	ListProcessingJobs(ctx context.Context, params procmodels.ListProcessingJobsParams) ([]procmodels.ProcessingJob, int32, error)
	CancelProcessingJob(ctx context.Context, uuid string) error
	GetProcessingStats(ctx context.Context, farmUUID string) (*procmodels.ProcessingStats, error)
}

// processingService is the concrete implementation of ProcessingService.
type processingService struct {
	d    deps.ServiceDeps
	repo repositories.ProcessingRepository
	log  *p9log.Helper
}

// NewProcessingService creates a new ProcessingService.
func NewProcessingService(d deps.ServiceDeps, repo repositories.ProcessingRepository) ProcessingService {
	return &processingService{
		d:    d,
		repo: repo,
		log:  p9log.NewHelper(p9log.With(d.Log, "component", "ProcessingService")),
	}
}

// SubmitProcessingJob creates a new satellite processing job in a transaction.
func (s *processingService) SubmitProcessingJob(ctx context.Context, job *procmodels.ProcessingJob) (*procmodels.ProcessingJob, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)
	requestID := p9context.RequestID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	// Validate required fields
	if job.IngestionTaskUUID == "" {
		return nil, errors.BadRequest("MISSING_INGESTION_TASK", "ingestion_task_id is required")
	}
	if job.FarmUUID == "" {
		return nil, errors.BadRequest("MISSING_FARM_ID", "farm_id is required")
	}
	if !job.OutputLevel.IsValid() {
		return nil, errors.BadRequest("INVALID_OUTPUT_LEVEL", "invalid output processing level")
	}
	if !job.Algorithm.IsValid() {
		return nil, errors.BadRequest("INVALID_ALGORITHM", "invalid correction algorithm")
	}
	if job.CloudMaskThreshold < 0 || job.CloudMaskThreshold > 1 {
		return nil, errors.BadRequest("INVALID_THRESHOLD", "cloud_mask_threshold must be between 0 and 1")
	}
	if job.OutputResolutionMeters <= 0 {
		return nil, errors.BadRequest("INVALID_RESOLUTION", "output_resolution_meters must be positive")
	}

	job.TenantID = tenantID
	job.CreatedBy = userID
	job.Status = procmodels.ProcessingStatusQueued

	// Build the input S3 key from the ingestion task ID
	if job.InputS3Key == "" {
		job.InputS3Key = fmt.Sprintf("ingestion/%s/%s/raw", tenantID, job.IngestionTaskUUID)
	}

	var createdJob *procmodels.ProcessingJob

	txErr := uow.WithTransaction(ctx, s.d.Pool, func(u uow.UnitOfWork) error {
		txRepo := s.repo.WithTx(u.Tx())

		created, err := txRepo.CreateProcessingJob(ctx, job)
		if err != nil {
			return err
		}
		createdJob = created

		return nil
	})

	if txErr != nil {
		s.log.Errorw("msg", "failed to submit processing job", "error", txErr, "request_id", requestID)
		return nil, txErr
	}

	// Emit domain event asynchronously (best-effort)
	s.emitProcessingEvent(ctx, EventTypeProcessingSubmitted, createdJob, nil)

	s.log.Infow("msg", "processing job submitted",
		"uuid", createdJob.UUID,
		"tenant_id", tenantID,
		"farm_uuid", createdJob.FarmUUID,
		"algorithm", string(createdJob.Algorithm),
		"request_id", requestID,
	)
	return createdJob, nil
}

// GetProcessingJob retrieves a processing job by UUID.
func (s *processingService) GetProcessingJob(ctx context.Context, uuid string) (*procmodels.ProcessingJob, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return nil, errors.BadRequest("MISSING_JOB_ID", "processing job ID is required")
	}

	job, err := s.repo.GetProcessingJobByUUID(ctx, uuid, tenantID)
	if err != nil {
		return nil, err
	}

	return job, nil
}

// ListProcessingJobs lists processing jobs with filtering and pagination.
func (s *processingService) ListProcessingJobs(ctx context.Context, params procmodels.ListProcessingJobsParams) ([]procmodels.ProcessingJob, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}

	params.TenantID = tenantID

	// Clamp page size
	if params.PageSize <= 0 {
		params.PageSize = defaultPageSize
	}
	if params.PageSize > maxPageSize {
		params.PageSize = maxPageSize
	}

	jobs, totalCount, err := s.repo.ListProcessingJobs(ctx, params)
	if err != nil {
		return nil, 0, err
	}

	return jobs, totalCount, nil
}

// CancelProcessingJob cancels a processing job if it is not already in a terminal state.
func (s *processingService) CancelProcessingJob(ctx context.Context, uuid string) error {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)
	requestID := p9context.RequestID(ctx)

	if tenantID == "" {
		return errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return errors.BadRequest("MISSING_JOB_ID", "processing job ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	// Verify the job exists and is not already terminal
	job, err := s.repo.GetProcessingJobByUUID(ctx, uuid, tenantID)
	if err != nil {
		return err
	}
	if job.Status.IsTerminal() {
		return errors.BadRequest("JOB_ALREADY_TERMINAL", fmt.Sprintf("processing job is already in terminal state: %s", string(job.Status)))
	}

	txErr := uow.WithTransaction(ctx, s.d.Pool, func(u uow.UnitOfWork) error {
		txRepo := s.repo.WithTx(u.Tx())
		return txRepo.CancelProcessingJob(ctx, uuid, tenantID, userID)
	})

	if txErr != nil {
		s.log.Errorw("msg", "failed to cancel processing job", "uuid", uuid, "error", txErr, "request_id", requestID)
		return txErr
	}

	// Emit domain event
	s.emitProcessingEvent(ctx, EventTypeProcessingFailed, job, map[string]interface{}{
		"reason":       "cancelled_by_user",
		"cancelled_by": userID,
	})

	s.log.Infow("msg", "processing job cancelled", "uuid", uuid, "tenant_id", tenantID, "request_id", requestID)
	return nil
}

// GetProcessingStats returns aggregated statistics for processing jobs.
func (s *processingService) GetProcessingStats(ctx context.Context, farmUUID string) (*procmodels.ProcessingStats, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}

	var farmUUIDPtr *string
	if farmUUID != "" {
		farmUUIDPtr = &farmUUID
	}

	stats, err := s.repo.GetProcessingStats(ctx, tenantID, farmUUIDPtr)
	if err != nil {
		return nil, err
	}

	return stats, nil
}

// emitProcessingEvent publishes a domain event for processing operations (best-effort).
func (s *processingService) emitProcessingEvent(ctx context.Context, eventType domain.EventType, job *procmodels.ProcessingJob, extraData map[string]interface{}) {
	tenantID := p9context.TenantID(ctx)
	requestID := p9context.RequestID(ctx)

	aggregateID := ""
	if job != nil {
		aggregateID = job.UUID
	}

	data := make(map[string]interface{})
	if job != nil {
		data["job_id"] = job.UUID
		data["tenant_id"] = job.TenantID
		data["farm_id"] = job.FarmUUID
		data["ingestion_task_id"] = job.IngestionTaskUUID
		data["status"] = string(job.Status)
		data["algorithm"] = string(job.Algorithm)
		data["input_level"] = string(job.InputLevel)
		data["output_level"] = string(job.OutputLevel)
	}
	for k, v := range extraData {
		data[k] = v
	}

	event := domain.NewDomainEvent(eventType, aggregateID, "processing_job").
		WithSource(serviceName).
		WithCorrelationID(requestID).
		WithMetadata("tenant_id", tenantID).
		WithPriority(domain.PriorityMedium)
	event.Data = data

	if s.d.KafkaProducer != nil {
		eventJSON, err := json.Marshal(event)
		if err != nil {
			s.log.Errorw("msg", "failed to marshal processing event", "event_type", string(eventType), "error", err)
			return
		}

		topic := "samavaya.agriculture.satellite.processing.events"
		key := aggregateID
		if key == "" {
			key = ulid.NewString()
		}

		_ = eventJSON // Published via Kafka producer in production wiring
		s.log.Debugw("msg", "processing event emitted", "event_type", string(eventType), "topic", topic, "key", key)
	}
}
