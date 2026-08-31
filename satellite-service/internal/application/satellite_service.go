// Package application contains the satellite-service application service.
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

	"p9e.in/samavaya/agriculture/satellite-service/internal/domain"
	"p9e.in/samavaya/agriculture/satellite-service/internal/ports/inbound"
	"p9e.in/samavaya/agriculture/satellite-service/internal/ports/outbound"
)

const (
	serviceName           = "satellite-service"
	eventTopic            = "samavaya.agriculture.satellite.events"
	maxPageSize     int32 = 100
	defaultPageSize       = int32(20)
)

type satelliteService struct {
	repo        outbound.SatelliteRepository
	pub         outbound.EventPublisher
	fieldClient outbound.FieldClient
	farmClient  outbound.FarmClient
	pool        *pgxpool.Pool
	log         *p9log.Helper
}

// NewSatelliteService creates a new application-layer SatelliteService.
func NewSatelliteService(
	repo outbound.SatelliteRepository,
	pub outbound.EventPublisher,
	fieldClient outbound.FieldClient,
	farmClient outbound.FarmClient,
	pool *pgxpool.Pool,
	log p9log.Logger,
) inbound.SatelliteService {
	return &satelliteService{
		repo:        repo,
		pub:         pub,
		fieldClient: fieldClient,
		farmClient:  farmClient,
		pool:        pool,
		log:         p9log.NewHelper(p9log.With(log, "component", "SatelliteService")),
	}
}

func (s *satelliteService) CreateSatellite(ctx context.Context, entity *domain.Satellite) (*domain.Satellite, error) {
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

	nameExists, err := s.repo.CheckSatelliteNameExists(ctx, entity.Name, tenantID)
	if err != nil {
		return nil, err
	}
	if nameExists {
		return nil, errors.Conflict("SATELLITE_NAME_EXISTS", fmt.Sprintf("satellite with name '%s' already exists", entity.Name))
	}

	entity.TenantID = tenantID
	entity.CreatedBy = userID
	entity.Status = domain.SatelliteStatusActive

	created, err := s.repo.CreateSatellite(ctx, entity)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.satellite.created", created.UUID, map[string]interface{}{
		"satellite_id": created.UUID, "tenant_id": tenantID,
	})
	s.log.Infow("msg", "satellite created", "uuid", created.UUID)
	return created, nil
}

func (s *satelliteService) GetSatellite(ctx context.Context, uuid string) (*domain.Satellite, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return nil, errors.BadRequest("MISSING_ID", "satellite ID is required")
	}
	return s.repo.GetSatelliteByUUID(ctx, uuid, tenantID)
}

func (s *satelliteService) ListSatellites(ctx context.Context, params domain.ListSatelliteParams) ([]domain.Satellite, int32, error) {
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
	return s.repo.ListSatellites(ctx, params)
}

func (s *satelliteService) UpdateSatellite(ctx context.Context, entity *domain.Satellite) (*domain.Satellite, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if entity.UUID == "" {
		return nil, errors.BadRequest("MISSING_ID", "satellite ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	exists, err := s.repo.CheckSatelliteExists(ctx, entity.UUID, tenantID)
	if err != nil {
		return nil, err
	}
	if !exists {
		return nil, errors.NotFound("SATELLITE_NOT_FOUND", fmt.Sprintf("satellite not found: %s", entity.UUID))
	}

	entity.TenantID = tenantID
	updatedBy := userID
	entity.UpdatedBy = &updatedBy

	updated, err := s.repo.UpdateSatellite(ctx, entity)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.satellite.updated", updated.UUID, map[string]interface{}{
		"satellite_id": updated.UUID, "tenant_id": tenantID,
	})
	return updated, nil
}

func (s *satelliteService) DeleteSatellite(ctx context.Context, uuid string) error {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return errors.BadRequest("MISSING_ID", "satellite ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	exists, err := s.repo.CheckSatelliteExists(ctx, uuid, tenantID)
	if err != nil {
		return err
	}
	if !exists {
		return errors.NotFound("SATELLITE_NOT_FOUND", fmt.Sprintf("satellite not found: %s", uuid))
	}

	if err := s.repo.DeleteSatellite(ctx, uuid, tenantID, userID); err != nil {
		return err
	}

	s.emitEvent(ctx, "agriculture.satellite.deleted", uuid, map[string]interface{}{
		"satellite_id": uuid, "tenant_id": tenantID,
	})
	return nil
}

func (s *satelliteService) emitEvent(ctx context.Context, eventType, aggregateID string, data map[string]interface{}) {
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
