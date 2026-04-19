// Package application contains the crop-service application service.
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

	"p9e.in/samavaya/agriculture/crop-service/internal/domain"
	"p9e.in/samavaya/agriculture/crop-service/internal/ports/inbound"
	"p9e.in/samavaya/agriculture/crop-service/internal/ports/outbound"
)

const (
	serviceName           = "crop-service"
	eventTopic            = "samavaya.agriculture.crop.events"
	maxPageSize     int32 = 100
	defaultPageSize       = int32(20)
)

type cropService struct {
	repo outbound.CropRepository
	pub  outbound.EventPublisher
	pool *pgxpool.Pool
	log  *p9log.Helper
}

// NewCropService creates a new application-layer CropService.
func NewCropService(
	repo outbound.CropRepository,
	pub outbound.EventPublisher,
	pool *pgxpool.Pool,
	log p9log.Logger,
) inbound.CropService {
	return &cropService{
		repo: repo,
		pub:  pub,
		pool: pool,
		log:  p9log.NewHelper(p9log.With(log, "component", "CropService")),
	}
}

func (s *cropService) CreateCrop(ctx context.Context, entity *domain.Crop) (*domain.Crop, error) {
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

	nameExists, err := s.repo.CheckCropNameExists(ctx, entity.Name, tenantID)
	if err != nil {
		return nil, err
	}
	if nameExists {
		return nil, errors.Conflict("CROP_NAME_EXISTS", fmt.Sprintf("crop with name '%s' already exists", entity.Name))
	}

	entity.TenantID = tenantID
	entity.CreatedBy = userID
	entity.Status = domain.CropStatusActive

	created, err := s.repo.CreateCrop(ctx, entity)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.crop.created", created.UUID, map[string]interface{}{
		"crop_id": created.UUID, "tenant_id": tenantID,
	})
	s.log.Infow("msg", "crop created", "uuid", created.UUID)
	return created, nil
}

func (s *cropService) GetCrop(ctx context.Context, uuid string) (*domain.Crop, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return nil, errors.BadRequest("MISSING_ID", "crop ID is required")
	}
	return s.repo.GetCropByUUID(ctx, uuid, tenantID)
}

func (s *cropService) ListCrops(ctx context.Context, params domain.ListCropParams) ([]domain.Crop, int32, error) {
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
	return s.repo.ListCrops(ctx, params)
}

func (s *cropService) UpdateCrop(ctx context.Context, entity *domain.Crop) (*domain.Crop, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if entity.UUID == "" {
		return nil, errors.BadRequest("MISSING_ID", "crop ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	exists, err := s.repo.CheckCropExists(ctx, entity.UUID, tenantID)
	if err != nil {
		return nil, err
	}
	if !exists {
		return nil, errors.NotFound("CROP_NOT_FOUND", fmt.Sprintf("crop not found: %s", entity.UUID))
	}

	entity.TenantID = tenantID
	updatedBy := userID
	entity.UpdatedBy = &updatedBy

	updated, err := s.repo.UpdateCrop(ctx, entity)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.crop.updated", updated.UUID, map[string]interface{}{
		"crop_id": updated.UUID, "tenant_id": tenantID,
	})
	return updated, nil
}

func (s *cropService) DeleteCrop(ctx context.Context, uuid string) error {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return errors.BadRequest("MISSING_ID", "crop ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	exists, err := s.repo.CheckCropExists(ctx, uuid, tenantID)
	if err != nil {
		return err
	}
	if !exists {
		return errors.NotFound("CROP_NOT_FOUND", fmt.Sprintf("crop not found: %s", uuid))
	}

	if err := s.repo.DeleteCrop(ctx, uuid, tenantID, userID); err != nil {
		return err
	}

	s.emitEvent(ctx, "agriculture.crop.deleted", uuid, map[string]interface{}{
		"crop_id": uuid, "tenant_id": tenantID,
	})
	return nil
}

func (s *cropService) emitEvent(ctx context.Context, eventType, aggregateID string, data map[string]interface{}) {
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
