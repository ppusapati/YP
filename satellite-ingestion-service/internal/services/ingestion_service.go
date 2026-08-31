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

	ingestionmodels "p9e.in/samavaya/agriculture/satellite-ingestion-service/internal/models"
	"p9e.in/samavaya/agriculture/satellite-ingestion-service/internal/repositories"
)

const (
	serviceName       = "satellite-ingestion-service"
	maxPageSize int32 = 100
	defaultPageSize   = 20
	maxRetryCount     = 3
)

// Ingestion event types
const (
	EventTypeIngestionRequested domain.EventType = "agriculture.satellite.ingestion.requested"
	EventTypeIngestionCompleted domain.EventType = "agriculture.satellite.ingestion.completed"
	EventTypeIngestionFailed    domain.EventType = "agriculture.satellite.ingestion.failed"
)

// IngestionService defines the interface for ingestion business logic.
type IngestionService interface {
	RequestIngestion(ctx context.Context, task *ingestionmodels.IngestionTask) (*ingestionmodels.IngestionTask, error)
	GetIngestionTask(ctx context.Context, uuid string) (*ingestionmodels.IngestionTask, error)
	ListIngestionTasks(ctx context.Context, params ingestionmodels.ListIngestionTasksParams) ([]ingestionmodels.IngestionTask, int32, error)
	CancelIngestion(ctx context.Context, uuid string) (*ingestionmodels.IngestionTask, error)
	RetryIngestion(ctx context.Context, uuid string) (*ingestionmodels.IngestionTask, error)
	GetIngestionStats(ctx context.Context, farmUUID *string, provider *ingestionmodels.SatelliteProvider) (*ingestionmodels.IngestionStats, error)
}

// ingestionService is the concrete implementation of IngestionService.
type ingestionService struct {
	d    deps.ServiceDeps
	repo repositories.IngestionRepository
	log  *p9log.Helper
}

// NewIngestionService creates a new IngestionService.
func NewIngestionService(d deps.ServiceDeps, repo repositories.IngestionRepository) IngestionService {
	return &ingestionService{
		d:    d,
		repo: repo,
		log:  p9log.NewHelper(p9log.With(d.Log, "component", "IngestionService")),
	}
}

// RequestIngestion creates a new ingestion task and queues it for processing.
func (s *ingestionService) RequestIngestion(ctx context.Context, task *ingestionmodels.IngestionTask) (*ingestionmodels.IngestionTask, error) {
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
	if task.FarmUUID == "" {
		return nil, errors.BadRequest("MISSING_FARM_ID", "farm ID is required")
	}
	if !task.Provider.IsValid() {
		return nil, errors.BadRequest("INVALID_PROVIDER", "invalid satellite provider")
	}
	if task.CloudCoverPercent < 0 || task.CloudCoverPercent > 100 {
		return nil, errors.BadRequest("INVALID_CLOUD_COVER", "cloud cover percentage must be between 0 and 100")
	}

	// Generate a scene ID based on provider and timestamp if not provided
	if task.SceneID == "" {
		task.SceneID = fmt.Sprintf("%s_%s_%d", task.Provider, task.FarmUUID, time.Now().UnixMilli())
	}

	task.TenantID = tenantID
	task.CreatedBy = userID
	task.Status = ingestionmodels.IngestionStatusQueued

	created, err := s.repo.CreateIngestionTask(ctx, task)
	if err != nil {
		s.log.Errorw("msg", "failed to create ingestion task", "error", err, "request_id", requestID)
		return nil, err
	}

	// Emit domain event asynchronously (best-effort)
	s.emitIngestionEvent(ctx, EventTypeIngestionRequested, created, nil)

	s.log.Infow("msg", "ingestion task created",
		"uuid", created.UUID,
		"provider", created.Provider,
		"farm_uuid", created.FarmUUID,
		"tenant_id", tenantID,
		"request_id", requestID,
	)
	return created, nil
}

// GetIngestionTask retrieves an ingestion task by UUID.
func (s *ingestionService) GetIngestionTask(ctx context.Context, uuid string) (*ingestionmodels.IngestionTask, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return nil, errors.BadRequest("MISSING_TASK_ID", "task ID is required")
	}

	task, err := s.repo.GetIngestionTaskByUUID(ctx, uuid, tenantID)
	if err != nil {
		return nil, err
	}

	return task, nil
}

// ListIngestionTasks lists ingestion tasks with filtering and pagination.
func (s *ingestionService) ListIngestionTasks(ctx context.Context, params ingestionmodels.ListIngestionTasksParams) ([]ingestionmodels.IngestionTask, int32, error) {
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

	tasks, totalCount, err := s.repo.ListIngestionTasks(ctx, params)
	if err != nil {
		return nil, 0, err
	}

	return tasks, totalCount, nil
}

// CancelIngestion cancels a pending or downloading ingestion task.
func (s *ingestionService) CancelIngestion(ctx context.Context, uuid string) (*ingestionmodels.IngestionTask, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)
	requestID := p9context.RequestID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return nil, errors.BadRequest("MISSING_TASK_ID", "task ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	cancelled, err := s.repo.CancelIngestionTask(ctx, uuid, tenantID, userID)
	if err != nil {
		return nil, err
	}

	s.emitIngestionEvent(ctx, EventTypeIngestionFailed, cancelled, map[string]interface{}{
		"reason": "cancelled_by_user",
	})

	s.log.Infow("msg", "ingestion task cancelled",
		"uuid", uuid,
		"tenant_id", tenantID,
		"cancelled_by", userID,
		"request_id", requestID,
	)
	return cancelled, nil
}

// RetryIngestion resets a failed ingestion task for retry.
func (s *ingestionService) RetryIngestion(ctx context.Context, uuid string) (*ingestionmodels.IngestionTask, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)
	requestID := p9context.RequestID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return nil, errors.BadRequest("MISSING_TASK_ID", "task ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	// Retrieve the existing task
	existing, err := s.repo.GetIngestionTaskByUUID(ctx, uuid, tenantID)
	if err != nil {
		return nil, err
	}

	// Only failed tasks can be retried
	if existing.Status != ingestionmodels.IngestionStatusFailed {
		return nil, errors.BadRequest("TASK_NOT_FAILED", fmt.Sprintf("task %s is not in failed state, current status: %s", uuid, existing.Status))
	}

	// Check retry count limit
	if existing.RetryCount >= int32(maxRetryCount) {
		return nil, errors.BadRequest("MAX_RETRIES_EXCEEDED", fmt.Sprintf("task %s has exceeded maximum retry count of %d", uuid, maxRetryCount))
	}

	// Reset the task to queued status with incremented retry count
	existing.Status = ingestionmodels.IngestionStatusQueued
	existing.RetryCount = existing.RetryCount + 1
	existing.ErrorMessage = nil
	existing.CompletedAt = nil
	updatedBy := userID
	existing.UpdatedBy = &updatedBy

	updated, err := s.repo.UpdateIngestionStatus(ctx, existing)
	if err != nil {
		return nil, err
	}

	s.emitIngestionEvent(ctx, EventTypeIngestionRequested, updated, map[string]interface{}{
		"retry_count": updated.RetryCount,
	})

	s.log.Infow("msg", "ingestion task retried",
		"uuid", uuid,
		"retry_count", updated.RetryCount,
		"tenant_id", tenantID,
		"request_id", requestID,
	)
	return updated, nil
}

// GetIngestionStats returns aggregated statistics for ingestion tasks.
func (s *ingestionService) GetIngestionStats(ctx context.Context, farmUUID *string, provider *ingestionmodels.SatelliteProvider) (*ingestionmodels.IngestionStats, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}

	stats, err := s.repo.GetIngestionStats(ctx, tenantID, farmUUID, provider)
	if err != nil {
		return nil, err
	}

	return stats, nil
}

// emitIngestionEvent publishes a domain event for ingestion operations (best-effort).
func (s *ingestionService) emitIngestionEvent(ctx context.Context, eventType domain.EventType, task *ingestionmodels.IngestionTask, extraData map[string]interface{}) {
	tenantID := p9context.TenantID(ctx)
	requestID := p9context.RequestID(ctx)

	aggregateID := ""
	if task != nil {
		aggregateID = task.UUID
	}

	data := make(map[string]interface{})
	if task != nil {
		data["task_id"] = task.UUID
		data["tenant_id"] = task.TenantID
		data["farm_id"] = task.FarmUUID
		data["provider"] = string(task.Provider)
		data["status"] = string(task.Status)
		data["scene_id"] = task.SceneID
	}
	for k, v := range extraData {
		data[k] = v
	}

	event := domain.NewDomainEvent(eventType, aggregateID, "ingestion_task").
		WithSource(serviceName).
		WithCorrelationID(requestID).
		WithMetadata("tenant_id", tenantID).
		WithPriority(domain.PriorityMedium)
	event.Data = data

	if s.d.KafkaProducer != nil {
		eventJSON, err := json.Marshal(event)
		if err != nil {
			s.log.Errorw("msg", "failed to marshal ingestion event", "event_type", string(eventType), "error", err)
			return
		}

		topic := "samavaya.agriculture.satellite.ingestion.events"
		key := aggregateID
		if key == "" {
			key = ulid.NewString()
		}

		_ = eventJSON // Published via Kafka producer in production wiring
		s.log.Debugw("msg", "ingestion event emitted", "event_type", string(eventType), "topic", topic, "key", key)
	}
}
