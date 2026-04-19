// Package application contains the yield-service application service.
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

	"p9e.in/samavaya/agriculture/yield-service/internal/domain"
	"p9e.in/samavaya/agriculture/yield-service/internal/ports/inbound"
	"p9e.in/samavaya/agriculture/yield-service/internal/ports/outbound"
)

const (
	serviceName       = "yield-service"
	eventTopic        = "samavaya.agriculture.yield.events"
	maxPageSize int32 = 100
	defaultPageSize   = int32(20)
)

type yieldService struct {
	repo outbound.YieldRepository
	pub  outbound.EventPublisher
	fieldClient outbound.FieldClient
	soilClient outbound.SoilClient
	irrigationClient outbound.IrrigationClient
	pestClient outbound.PestClient
	pool *pgxpool.Pool
	log  *p9log.Helper
}

// NewYieldService creates a new application-layer YieldService.
func NewYieldService(
	repo outbound.YieldRepository,
	pub outbound.EventPublisher,
	fieldClient outbound.FieldClient,
	soilClient outbound.SoilClient,
	irrigationClient outbound.IrrigationClient,
	pestClient outbound.PestClient,
	pool *pgxpool.Pool,
	log p9log.Logger,
) inbound.YieldService {
	return &yieldService{
		repo: repo,
		pub:  pub,
		fieldClient: fieldClient,
		soilClient: soilClient,
		irrigationClient: irrigationClient,
		pestClient: pestClient,
		pool: pool,
		log:  p9log.NewHelper(p9log.With(log, "component", "YieldService")),
	}
}

func (s *yieldService) CreateYield(ctx context.Context, entity *domain.Yield) (*domain.Yield, error) {
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

	nameExists, err := s.repo.CheckYieldNameExists(ctx, entity.Name, tenantID)
	if err != nil {
		return nil, err
	}
	if nameExists {
		return nil, errors.Conflict("YIELD_NAME_EXISTS", fmt.Sprintf("yield with name '%s' already exists", entity.Name))
	}

	entity.TenantID = tenantID
	entity.CreatedBy = userID
	entity.Status = domain.YieldStatusActive

	created, err := s.repo.CreateYield(ctx, entity)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.yield.created", created.UUID, map[string]interface{}{
		"yield_id": created.UUID, "tenant_id": tenantID,
	})
	s.log.Infow("msg", "yield created", "uuid", created.UUID)
	return created, nil
}

func (s *yieldService) GetYield(ctx context.Context, uuid string) (*domain.Yield, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return nil, errors.BadRequest("MISSING_ID", "yield ID is required")
	}
	return s.repo.GetYieldByUUID(ctx, uuid, tenantID)
}

func (s *yieldService) ListYields(ctx context.Context, params domain.ListYieldParams) ([]domain.Yield, int32, error) {
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
	return s.repo.ListYields(ctx, params)
}

func (s *yieldService) UpdateYield(ctx context.Context, entity *domain.Yield) (*domain.Yield, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if entity.UUID == "" {
		return nil, errors.BadRequest("MISSING_ID", "yield ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	exists, err := s.repo.CheckYieldExists(ctx, entity.UUID, tenantID)
	if err != nil {
		return nil, err
	}
	if !exists {
		return nil, errors.NotFound("YIELD_NOT_FOUND", fmt.Sprintf("yield not found: %s", entity.UUID))
	}

	entity.TenantID = tenantID
	updatedBy := userID
	entity.UpdatedBy = &updatedBy

	updated, err := s.repo.UpdateYield(ctx, entity)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.yield.updated", updated.UUID, map[string]interface{}{
		"yield_id": updated.UUID, "tenant_id": tenantID,
	})
	return updated, nil
}

func (s *yieldService) DeleteYield(ctx context.Context, uuid string) error {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return errors.BadRequest("MISSING_ID", "yield ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	exists, err := s.repo.CheckYieldExists(ctx, uuid, tenantID)
	if err != nil {
		return err
	}
	if !exists {
		return errors.NotFound("YIELD_NOT_FOUND", fmt.Sprintf("yield not found: %s", uuid))
	}

	if err := s.repo.DeleteYield(ctx, uuid, tenantID, userID); err != nil {
		return err
	}

	s.emitEvent(ctx, "agriculture.yield.deleted", uuid, map[string]interface{}{
		"yield_id": uuid, "tenant_id": tenantID,
	})
	return nil
}

func (s *yieldService) emitEvent(ctx context.Context, eventType, aggregateID string, data map[string]interface{}) {
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
