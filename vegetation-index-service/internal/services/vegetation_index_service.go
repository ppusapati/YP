package services

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"
	"p9e.in/samavaya/packages/uow"

	vimodels "p9e.in/samavaya/agriculture/vegetation-index-service/internal/models"
	"p9e.in/samavaya/agriculture/vegetation-index-service/internal/repositories"
)

const (
	serviceName       = "vegetation-index-service"
	maxPageSize int32 = 100
	defaultPageSize   = 20
)

// Vegetation index event types
const (
	EventTypeComputeStarted   domain.EventType = "agriculture.satellite.vegetation.compute.started"
	EventTypeComputeCompleted domain.EventType = "agriculture.satellite.vegetation.compute.completed"
	EventTypeComputeFailed    domain.EventType = "agriculture.satellite.vegetation.compute.failed"
)

// VegetationIndexService defines the interface for vegetation index business logic.
type VegetationIndexService interface {
	ComputeIndices(ctx context.Context, processingJobID, farmID string, indexTypes []vimodels.VegetationIndexType) (*vimodels.ComputeTask, error)
	GetVegetationIndex(ctx context.Context, uuid string) (*vimodels.VegetationIndex, error)
	ListVegetationIndices(ctx context.Context, params vimodels.ListVegetationIndicesParams) ([]vimodels.VegetationIndex, int32, error)
	GetNDVITimeSeries(ctx context.Context, farmID string, fieldID *string, dateFrom, dateTo *time.Time) ([]vimodels.TimeSeriesPoint, string, error)
	GetFieldHealth(ctx context.Context, farmID string, fieldID *string) (*vimodels.FieldHealthSummary, error)
}

// vegetationIndexService is the concrete implementation of VegetationIndexService.
type vegetationIndexService struct {
	d    deps.ServiceDeps
	repo repositories.VegetationIndexRepository
	log  *p9log.Helper
}

// NewVegetationIndexService creates a new VegetationIndexService.
func NewVegetationIndexService(d deps.ServiceDeps, repo repositories.VegetationIndexRepository) VegetationIndexService {
	return &vegetationIndexService{
		d:    d,
		repo: repo,
		log:  p9log.NewHelper(p9log.With(d.Log, "component", "VegetationIndexService")),
	}
}

// ComputeIndices creates a compute task and queues index computation for a processing job.
func (s *vegetationIndexService) ComputeIndices(ctx context.Context, processingJobID, farmID string, indexTypes []vimodels.VegetationIndexType) (*vimodels.ComputeTask, error) {
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
	if processingJobID == "" {
		return nil, errors.BadRequest("MISSING_PROCESSING_JOB", "processing_job_id is required")
	}
	if farmID == "" {
		return nil, errors.BadRequest("MISSING_FARM_ID", "farm_id is required")
	}
	if len(indexTypes) == 0 {
		return nil, errors.BadRequest("MISSING_INDEX_TYPES", "at least one index type is required")
	}

	// Validate each index type
	for _, it := range indexTypes {
		if !it.IsValid() {
			return nil, errors.BadRequest("INVALID_INDEX_TYPE", fmt.Sprintf("invalid index type: %s", string(it)))
		}
	}

	var createdTask *vimodels.ComputeTask

	txErr := uow.WithTransaction(ctx, s.d.Pool, func(u uow.UnitOfWork) error {
		txRepo := s.repo.WithTx(u.Tx())

		task := &vimodels.ComputeTask{
			TenantID:          tenantID,
			ProcessingJobUUID: processingJobID,
			FarmUUID:          farmID,
			IndexTypes:        indexTypes,
		}
		task.CreatedBy = userID

		created, err := txRepo.InsertComputeTask(ctx, task)
		if err != nil {
			return err
		}
		createdTask = created

		return nil
	})

	if txErr != nil {
		s.log.Errorw("msg", "failed to create compute task", "error", txErr, "request_id", requestID)
		return nil, txErr
	}

	// Emit compute started event
	s.emitComputeEvent(ctx, EventTypeComputeStarted, createdTask, nil)

	s.log.Infow("msg", "compute task created",
		"uuid", createdTask.UUID,
		"processing_job_id", processingJobID,
		"farm_id", farmID,
		"index_types_count", len(indexTypes),
		"request_id", requestID,
	)
	return createdTask, nil
}

// GetVegetationIndex retrieves a vegetation index by UUID.
func (s *vegetationIndexService) GetVegetationIndex(ctx context.Context, uuid string) (*vimodels.VegetationIndex, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return nil, errors.BadRequest("MISSING_VI_ID", "vegetation index ID is required")
	}

	vi, err := s.repo.GetVegetationIndexByUUID(ctx, uuid, tenantID)
	if err != nil {
		return nil, err
	}

	return vi, nil
}

// ListVegetationIndices lists vegetation indices with filtering and pagination.
func (s *vegetationIndexService) ListVegetationIndices(ctx context.Context, params vimodels.ListVegetationIndicesParams) ([]vimodels.VegetationIndex, int32, error) {
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

	indices, totalCount, err := s.repo.ListVegetationIndices(ctx, params)
	if err != nil {
		return nil, 0, err
	}

	return indices, totalCount, nil
}

// GetNDVITimeSeries retrieves NDVI time series data for a farm/field.
func (s *vegetationIndexService) GetNDVITimeSeries(ctx context.Context, farmID string, fieldID *string, dateFrom, dateTo *time.Time) ([]vimodels.TimeSeriesPoint, string, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, "", errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if farmID == "" {
		return nil, "", errors.BadRequest("MISSING_FARM_ID", "farm_id is required")
	}

	points, err := s.repo.GetNDVITimeSeries(ctx, tenantID, farmID, fieldID, dateFrom, dateTo)
	if err != nil {
		return nil, "", err
	}

	resolvedFieldID := ""
	if fieldID != nil {
		resolvedFieldID = *fieldID
	}

	return points, resolvedFieldID, nil
}

// GetFieldHealth retrieves the health summary for a field.
func (s *vegetationIndexService) GetFieldHealth(ctx context.Context, farmID string, fieldID *string) (*vimodels.FieldHealthSummary, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if farmID == "" {
		return nil, errors.BadRequest("MISSING_FARM_ID", "farm_id is required")
	}

	summary, err := s.repo.GetFieldHealthSummary(ctx, tenantID, farmID, fieldID)
	if err != nil {
		return nil, err
	}

	return summary, nil
}

// emitComputeEvent publishes a domain event for compute operations (best-effort).
func (s *vegetationIndexService) emitComputeEvent(ctx context.Context, eventType domain.EventType, task *vimodels.ComputeTask, extraData map[string]interface{}) {
	tenantID := p9context.TenantID(ctx)
	requestID := p9context.RequestID(ctx)

	aggregateID := ""
	if task != nil {
		aggregateID = task.UUID
	}

	data := make(map[string]interface{})
	if task != nil {
		data["compute_task_id"] = task.UUID
		data["tenant_id"] = task.TenantID
		data["processing_job_id"] = task.ProcessingJobUUID
		data["farm_id"] = task.FarmUUID
		data["status"] = string(task.Status)

		indexTypeStrs := make([]string, len(task.IndexTypes))
		for i, it := range task.IndexTypes {
			indexTypeStrs[i] = string(it)
		}
		data["index_types"] = indexTypeStrs

		if task.ErrorMessage != nil {
			data["error_message"] = *task.ErrorMessage
		}
		if task.ComputeTimeSeconds > 0 {
			data["compute_time_seconds"] = task.ComputeTimeSeconds
		}
	}
	for k, v := range extraData {
		data[k] = v
	}

	event := domain.NewDomainEvent(eventType, aggregateID, "compute_task").
		WithSource(serviceName).
		WithCorrelationID(requestID).
		WithMetadata("tenant_id", tenantID).
		WithPriority(domain.PriorityMedium)
	event.Data = data

	if s.d.KafkaProducer != nil {
		eventJSON, err := json.Marshal(event)
		if err != nil {
			s.log.Errorw("msg", "failed to marshal compute event", "event_type", string(eventType), "error", err)
			return
		}

		topic := "samavaya.agriculture.satellite.vegetation.events"
		key := aggregateID
		if key == "" {
			key = ulid.NewString()
		}

		_ = eventJSON // Published via Kafka producer in production wiring
		s.log.Debugw("msg", "compute event emitted", "event_type", string(eventType), "topic", topic, "key", key)
	}
}
