// Package application contains the irrigation-service application service.
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

	"p9e.in/samavaya/agriculture/irrigation-service/internal/domain"
	"p9e.in/samavaya/agriculture/irrigation-service/internal/ports/inbound"
	"p9e.in/samavaya/agriculture/irrigation-service/internal/ports/outbound"
)

const (
	serviceName       = "irrigation-service"
	eventTopic        = "samavaya.agriculture.irrigation.events"
	maxPageSize int32 = 100
	defaultPageSize   = int32(20)
)

type irrigationService struct {
	repo outbound.IrrigationRepository
	pub  outbound.EventPublisher
	fieldClient outbound.FieldClient
	pool *pgxpool.Pool
	log  *p9log.Helper
}

// NewIrrigationService creates a new application-layer IrrigationService.
func NewIrrigationService(
	repo outbound.IrrigationRepository,
	pub outbound.EventPublisher,
	fieldClient outbound.FieldClient,
	pool *pgxpool.Pool,
	log p9log.Logger,
) inbound.IrrigationService {
	return &irrigationService{
		repo: repo,
		pub:  pub,
		fieldClient: fieldClient,
		pool: pool,
		log:  p9log.NewHelper(p9log.With(log, "component", "IrrigationService")),
	}
}

func (s *irrigationService) CreateIrrigation(ctx context.Context, entity *domain.Irrigation) (*domain.Irrigation, error) {
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

	nameExists, err := s.repo.CheckIrrigationNameExists(ctx, entity.Name, tenantID)
	if err != nil {
		return nil, err
	}
	if nameExists {
		return nil, errors.Conflict("IRRIGATION_NAME_EXISTS", fmt.Sprintf("irrigation with name '%s' already exists", entity.Name))
	}

	entity.TenantID = tenantID
	entity.CreatedBy = userID
	entity.Status = domain.IrrigationStatusActive

	created, err := s.repo.CreateIrrigation(ctx, entity)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.irrigation.created", created.UUID, map[string]interface{}{
		"irrigation_id": created.UUID, "tenant_id": tenantID,
	})
	s.log.Infow("msg", "irrigation created", "uuid", created.UUID)
	return created, nil
}

func (s *irrigationService) GetIrrigation(ctx context.Context, uuid string) (*domain.Irrigation, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return nil, errors.BadRequest("MISSING_ID", "irrigation ID is required")
	}
	return s.repo.GetIrrigationByUUID(ctx, uuid, tenantID)
}

func (s *irrigationService) ListIrrigations(ctx context.Context, params domain.ListIrrigationParams) ([]domain.Irrigation, int32, error) {
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
	return s.repo.ListIrrigations(ctx, params)
}

func (s *irrigationService) UpdateIrrigation(ctx context.Context, entity *domain.Irrigation) (*domain.Irrigation, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if entity.UUID == "" {
		return nil, errors.BadRequest("MISSING_ID", "irrigation ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	exists, err := s.repo.CheckIrrigationExists(ctx, entity.UUID, tenantID)
	if err != nil {
		return nil, err
	}
	if !exists {
		return nil, errors.NotFound("IRRIGATION_NOT_FOUND", fmt.Sprintf("irrigation not found: %s", entity.UUID))
	}

	entity.TenantID = tenantID
	updatedBy := userID
	entity.UpdatedBy = &updatedBy

	updated, err := s.repo.UpdateIrrigation(ctx, entity)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.irrigation.updated", updated.UUID, map[string]interface{}{
		"irrigation_id": updated.UUID, "tenant_id": tenantID,
	})
	return updated, nil
}

func (s *irrigationService) DeleteIrrigation(ctx context.Context, uuid string) error {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return errors.BadRequest("MISSING_ID", "irrigation ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	exists, err := s.repo.CheckIrrigationExists(ctx, uuid, tenantID)
	if err != nil {
		return err
	}
	if !exists {
		return errors.NotFound("IRRIGATION_NOT_FOUND", fmt.Sprintf("irrigation not found: %s", uuid))
	}

	if err := s.repo.DeleteIrrigation(ctx, uuid, tenantID, userID); err != nil {
		return err
	}

	s.emitEvent(ctx, "agriculture.irrigation.deleted", uuid, map[string]interface{}{
		"irrigation_id": uuid, "tenant_id": tenantID,
	})
	return nil
}

func (s *irrigationService) emitEvent(ctx context.Context, eventType, aggregateID string, data map[string]interface{}) {
	if s.pub == nil {
		return
	}
	payload := map[string]interface{}{
		"id":           ulid.NewString(),
		"type":         eventType,
		"aggregate_id": aggregateID,
		"source":       serviceName,
		"correlation_id": p9context.RequestID(ctx),
		"data":         data,
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
