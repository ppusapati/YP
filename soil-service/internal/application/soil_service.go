// Package application contains the soil-service application service.
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

	"p9e.in/samavaya/agriculture/soil-service/internal/domain"
	"p9e.in/samavaya/agriculture/soil-service/internal/ports/inbound"
	"p9e.in/samavaya/agriculture/soil-service/internal/ports/outbound"
)

const (
	serviceName           = "soil-service"
	eventTopic            = "samavaya.agriculture.soil.events"
	maxPageSize     int32 = 100
	defaultPageSize       = int32(20)
)

type soilService struct {
	repo        outbound.SoilRepository
	pub         outbound.EventPublisher
	fieldClient outbound.FieldClient
	pool        *pgxpool.Pool
	log         *p9log.Helper
}

// NewSoilService creates a new application-layer SoilService.
func NewSoilService(
	repo outbound.SoilRepository,
	pub outbound.EventPublisher,
	fieldClient outbound.FieldClient,
	pool *pgxpool.Pool,
	log p9log.Logger,
) inbound.SoilService {
	return &soilService{
		repo:        repo,
		pub:         pub,
		fieldClient: fieldClient,
		pool:        pool,
		log:         p9log.NewHelper(p9log.With(log, "component", "SoilService")),
	}
}

func (s *soilService) CreateSoil(ctx context.Context, entity *domain.Soil) (*domain.Soil, error) {
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

	nameExists, err := s.repo.CheckSoilNameExists(ctx, entity.Name, tenantID)
	if err != nil {
		return nil, err
	}
	if nameExists {
		return nil, errors.Conflict("SOIL_NAME_EXISTS", fmt.Sprintf("soil with name '%s' already exists", entity.Name))
	}

	entity.TenantID = tenantID
	entity.CreatedBy = userID
	entity.Status = domain.SoilStatusActive

	created, err := s.repo.CreateSoil(ctx, entity)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.soil.created", created.UUID, map[string]interface{}{
		"soil_id": created.UUID, "tenant_id": tenantID,
	})
	s.log.Infow("msg", "soil created", "uuid", created.UUID)
	return created, nil
}

func (s *soilService) GetSoil(ctx context.Context, uuid string) (*domain.Soil, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return nil, errors.BadRequest("MISSING_ID", "soil ID is required")
	}
	return s.repo.GetSoilByUUID(ctx, uuid, tenantID)
}

func (s *soilService) ListSoils(ctx context.Context, params domain.ListSoilParams) ([]domain.Soil, int32, error) {
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
	return s.repo.ListSoils(ctx, params)
}

func (s *soilService) UpdateSoil(ctx context.Context, entity *domain.Soil) (*domain.Soil, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if entity.UUID == "" {
		return nil, errors.BadRequest("MISSING_ID", "soil ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	exists, err := s.repo.CheckSoilExists(ctx, entity.UUID, tenantID)
	if err != nil {
		return nil, err
	}
	if !exists {
		return nil, errors.NotFound("SOIL_NOT_FOUND", fmt.Sprintf("soil not found: %s", entity.UUID))
	}

	entity.TenantID = tenantID
	updatedBy := userID
	entity.UpdatedBy = &updatedBy

	updated, err := s.repo.UpdateSoil(ctx, entity)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.soil.updated", updated.UUID, map[string]interface{}{
		"soil_id": updated.UUID, "tenant_id": tenantID,
	})
	return updated, nil
}

func (s *soilService) DeleteSoil(ctx context.Context, uuid string) error {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return errors.BadRequest("MISSING_ID", "soil ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	exists, err := s.repo.CheckSoilExists(ctx, uuid, tenantID)
	if err != nil {
		return err
	}
	if !exists {
		return errors.NotFound("SOIL_NOT_FOUND", fmt.Sprintf("soil not found: %s", uuid))
	}

	if err := s.repo.DeleteSoil(ctx, uuid, tenantID, userID); err != nil {
		return err
	}

	s.emitEvent(ctx, "agriculture.soil.deleted", uuid, map[string]interface{}{
		"soil_id": uuid, "tenant_id": tenantID,
	})
	return nil
}

func (s *soilService) emitEvent(ctx context.Context, eventType, aggregateID string, data map[string]interface{}) {
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
