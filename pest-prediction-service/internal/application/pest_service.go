// Package application contains the pest-prediction-service application service.
package application

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	"p9e.in/samavaya/agriculture/pest-prediction-service/internal/domain"
	"p9e.in/samavaya/agriculture/pest-prediction-service/internal/ports/inbound"
	"p9e.in/samavaya/agriculture/pest-prediction-service/internal/ports/outbound"
)

const (
	serviceName           = "pest-prediction-service"
	eventTopic            = "samavaya.agriculture.pest-prediction.events"
	maxPageSize     int32 = 100
	defaultPageSize       = int32(20)
)

type pestService struct {
	repo         outbound.PestRepository
	pub          outbound.EventPublisher
	fieldClient  outbound.FieldClient
	sensorClient outbound.SensorClient
	pool         *pgxpool.Pool
	log          *p9log.Helper
}

// NewPestService creates a new application-layer PestService.
func NewPestService(
	repo outbound.PestRepository,
	pub outbound.EventPublisher,
	fieldClient outbound.FieldClient,
	sensorClient outbound.SensorClient,
	pool *pgxpool.Pool,
	log p9log.Logger,
) inbound.PestService {
	return &pestService{
		repo:         repo,
		pub:          pub,
		fieldClient:  fieldClient,
		sensorClient: sensorClient,
		pool:         pool,
		log:          p9log.NewHelper(p9log.With(log, "component", "PestService")),
	}
}

func (s *pestService) CreatePest(ctx context.Context, entity *domain.Pest) (*domain.Pest, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if entity.Name == "" {
		return nil, errors.BadRequest("INVALID_NAME", "name is required")
	}
	if userID == "" {
		userID = "system"
	}

	nameExists, err := s.repo.CheckPestNameExists(ctx, entity.Name, tenantID)
	if err != nil {
		return nil, err
	}
	if nameExists {
		return nil, errors.Conflict("PEST_NAME_EXISTS", fmt.Sprintf("pest with name '%s' already exists", entity.Name))
	}

	entity.TenantID = tenantID
	entity.CreatedBy = userID
	entity.Status = domain.PestStatusActive

	created, err := s.repo.CreatePest(ctx, entity)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.pest-prediction.created", created.UUID, map[string]interface{}{
		"pest_prediction_id": created.UUID, "tenant_id": tenantID,
	})
	s.log.Infow("msg", "pest created", "uuid", created.UUID)
	return created, nil
}

func (s *pestService) GetPest(ctx context.Context, uuid string) (*domain.Pest, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return nil, errors.BadRequest("MISSING_ID", "pest ID is required")
	}
	return s.repo.GetPestByUUID(ctx, uuid, tenantID)
}

func (s *pestService) ListPestPredictions(ctx context.Context, params domain.ListPestPredictionParams) ([]domain.Pest, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	params.TenantID = tenantID
	if params.PageSize <= 0 {
		params.PageSize = defaultPageSize
	}
	if params.PageSize > maxPageSize {
		params.PageSize = maxPageSize
	}
	return s.repo.ListPestPredictions(ctx, params)
}

func (s *pestService) UpdatePest(ctx context.Context, entity *domain.Pest) (*domain.Pest, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if entity.UUID == "" {
		return nil, errors.BadRequest("MISSING_ID", "pest ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	exists, err := s.repo.CheckPestExists(ctx, entity.UUID, tenantID)
	if err != nil {
		return nil, err
	}
	if !exists {
		return nil, errors.NotFound("PEST_NOT_FOUND", fmt.Sprintf("pest not found: %s", entity.UUID))
	}

	entity.TenantID = tenantID
	updatedBy := userID
	entity.UpdatedBy = &updatedBy

	updated, err := s.repo.UpdatePest(ctx, entity)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.pest-prediction.updated", updated.UUID, map[string]interface{}{
		"pest_prediction_id": updated.UUID, "tenant_id": tenantID,
	})
	return updated, nil
}

func (s *pestService) DeletePest(ctx context.Context, uuid string) error {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return errors.BadRequest("MISSING_ID", "pest ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	exists, err := s.repo.CheckPestExists(ctx, uuid, tenantID)
	if err != nil {
		return err
	}
	if !exists {
		return errors.NotFound("PEST_NOT_FOUND", fmt.Sprintf("pest not found: %s", uuid))
	}

	if err := s.repo.DeletePest(ctx, uuid, tenantID, userID); err != nil {
		return err
	}

	s.emitEvent(ctx, "agriculture.pest-prediction.deleted", uuid, map[string]interface{}{
		"pest_prediction_id": uuid, "tenant_id": tenantID,
	})
	return nil
}

func (s *pestService) emitEvent(ctx context.Context, eventType, aggregateID string, data map[string]interface{}) {
	if s.pub == nil {
		return
	}
	payload := map[string]interface{}{
		"id":             ulid.NewString(),
		"type":           eventType,
		"aggregate_id":   aggregateID,
		"source":         serviceName,
		"correlation_id": p9context.RequestID(ctx),
		"data":           data,
	}
	raw, err := json.Marshal(payload)
	if err != nil {
		s.log.Errorw("msg", "failed to marshal event", "error", err)
		return
	}
	if err := s.pub.Publish(ctx, eventTopic, aggregateID, raw); err != nil {
		s.log.Errorw("msg", "failed to publish event", "event_type", eventType, "error", err)
	}
}
