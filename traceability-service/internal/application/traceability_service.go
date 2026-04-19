// Package application contains the traceability-service application service.
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

	"p9e.in/samavaya/agriculture/traceability-service/internal/domain"
	"p9e.in/samavaya/agriculture/traceability-service/internal/ports/inbound"
	"p9e.in/samavaya/agriculture/traceability-service/internal/ports/outbound"
)

const (
	serviceName       = "traceability-service"
	eventTopic        = "samavaya.agriculture.traceability.events"
	maxPageSize int32 = 100
	defaultPageSize   = int32(20)
)

type traceabilityService struct {
	repo outbound.TraceabilityRepository
	pub  outbound.EventPublisher
	farmClient outbound.FarmClient
	fieldClient outbound.FieldClient
	yieldClient outbound.YieldClient
	pool *pgxpool.Pool
	log  *p9log.Helper
}

// NewTraceabilityService creates a new application-layer TraceabilityService.
func NewTraceabilityService(
	repo outbound.TraceabilityRepository,
	pub outbound.EventPublisher,
	farmClient outbound.FarmClient,
	fieldClient outbound.FieldClient,
	yieldClient outbound.YieldClient,
	pool *pgxpool.Pool,
	log p9log.Logger,
) inbound.TraceabilityService {
	return &traceabilityService{
		repo: repo,
		pub:  pub,
		farmClient: farmClient,
		fieldClient: fieldClient,
		yieldClient: yieldClient,
		pool: pool,
		log:  p9log.NewHelper(p9log.With(log, "component", "TraceabilityService")),
	}
}

func (s *traceabilityService) CreateTraceability(ctx context.Context, entity *domain.Traceability) (*domain.Traceability, error) {
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

	nameExists, err := s.repo.CheckTraceabilityNameExists(ctx, entity.Name, tenantID)
	if err != nil {
		return nil, err
	}
	if nameExists {
		return nil, errors.Conflict("TRACEABILITY_NAME_EXISTS", fmt.Sprintf("traceability with name '%s' already exists", entity.Name))
	}

	entity.TenantID = tenantID
	entity.CreatedBy = userID
	entity.Status = domain.TraceabilityStatusActive

	created, err := s.repo.CreateTraceability(ctx, entity)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.traceability.created", created.UUID, map[string]interface{}{
		"traceability_id": created.UUID, "tenant_id": tenantID,
	})
	s.log.Infow("msg", "traceability created", "uuid", created.UUID)
	return created, nil
}

func (s *traceabilityService) GetTraceability(ctx context.Context, uuid string) (*domain.Traceability, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return nil, errors.BadRequest("MISSING_ID", "traceability ID is required")
	}
	return s.repo.GetTraceabilityByUUID(ctx, uuid, tenantID)
}

func (s *traceabilityService) ListTraceabilitys(ctx context.Context, params domain.ListTraceabilityParams) ([]domain.Traceability, int32, error) {
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
	return s.repo.ListTraceabilitys(ctx, params)
}

func (s *traceabilityService) UpdateTraceability(ctx context.Context, entity *domain.Traceability) (*domain.Traceability, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if entity.UUID == "" {
		return nil, errors.BadRequest("MISSING_ID", "traceability ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	exists, err := s.repo.CheckTraceabilityExists(ctx, entity.UUID, tenantID)
	if err != nil {
		return nil, err
	}
	if !exists {
		return nil, errors.NotFound("TRACEABILITY_NOT_FOUND", fmt.Sprintf("traceability not found: %s", entity.UUID))
	}

	entity.TenantID = tenantID
	updatedBy := userID
	entity.UpdatedBy = &updatedBy

	updated, err := s.repo.UpdateTraceability(ctx, entity)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.traceability.updated", updated.UUID, map[string]interface{}{
		"traceability_id": updated.UUID, "tenant_id": tenantID,
	})
	return updated, nil
}

func (s *traceabilityService) DeleteTraceability(ctx context.Context, uuid string) error {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return errors.BadRequest("MISSING_ID", "traceability ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	exists, err := s.repo.CheckTraceabilityExists(ctx, uuid, tenantID)
	if err != nil {
		return err
	}
	if !exists {
		return errors.NotFound("TRACEABILITY_NOT_FOUND", fmt.Sprintf("traceability not found: %s", uuid))
	}

	if err := s.repo.DeleteTraceability(ctx, uuid, tenantID, userID); err != nil {
		return err
	}

	s.emitEvent(ctx, "agriculture.traceability.deleted", uuid, map[string]interface{}{
		"traceability_id": uuid, "tenant_id": tenantID,
	})
	return nil
}

func (s *traceabilityService) emitEvent(ctx context.Context, eventType, aggregateID string, data map[string]interface{}) {
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
