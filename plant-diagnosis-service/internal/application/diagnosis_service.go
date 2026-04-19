// Package application contains the plant-diagnosis-service application service.
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

	"p9e.in/samavaya/agriculture/plant-diagnosis-service/internal/domain"
	"p9e.in/samavaya/agriculture/plant-diagnosis-service/internal/ports/inbound"
	"p9e.in/samavaya/agriculture/plant-diagnosis-service/internal/ports/outbound"
)

const (
	serviceName           = "plant-diagnosis-service"
	eventTopic            = "samavaya.agriculture.plant-diagnosis.events"
	maxPageSize     int32 = 100
	defaultPageSize       = int32(20)
)

type diagnosisService struct {
	repo        outbound.DiagnosisRepository
	pub         outbound.EventPublisher
	fieldClient outbound.FieldClient
	pool        *pgxpool.Pool
	log         *p9log.Helper
}

// NewDiagnosisService creates a new application-layer DiagnosisService.
func NewDiagnosisService(
	repo outbound.DiagnosisRepository,
	pub outbound.EventPublisher,
	fieldClient outbound.FieldClient,
	pool *pgxpool.Pool,
	log p9log.Logger,
) inbound.DiagnosisService {
	return &diagnosisService{
		repo:        repo,
		pub:         pub,
		fieldClient: fieldClient,
		pool:        pool,
		log:         p9log.NewHelper(p9log.With(log, "component", "DiagnosisService")),
	}
}

func (s *diagnosisService) CreateDiagnosis(ctx context.Context, entity *domain.Diagnosis) (*domain.Diagnosis, error) {
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

	nameExists, err := s.repo.CheckDiagnosisNameExists(ctx, entity.Name, tenantID)
	if err != nil {
		return nil, err
	}
	if nameExists {
		return nil, errors.Conflict("DIAGNOSIS_NAME_EXISTS", fmt.Sprintf("diagnosis with name '%s' already exists", entity.Name))
	}

	entity.TenantID = tenantID
	entity.CreatedBy = userID
	entity.Status = domain.DiagnosisStatusActive

	created, err := s.repo.CreateDiagnosis(ctx, entity)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.plant-diagnosis.created", created.UUID, map[string]interface{}{
		"plant_diagnosis_id": created.UUID, "tenant_id": tenantID,
	})
	s.log.Infow("msg", "diagnosis created", "uuid", created.UUID)
	return created, nil
}

func (s *diagnosisService) GetDiagnosis(ctx context.Context, uuid string) (*domain.Diagnosis, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return nil, errors.BadRequest("MISSING_ID", "diagnosis ID is required")
	}
	return s.repo.GetDiagnosisByUUID(ctx, uuid, tenantID)
}

func (s *diagnosisService) ListPlantDiagnoses(ctx context.Context, params domain.ListPlantDiagnosisParams) ([]domain.Diagnosis, int32, error) {
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
	return s.repo.ListPlantDiagnoses(ctx, params)
}

func (s *diagnosisService) UpdateDiagnosis(ctx context.Context, entity *domain.Diagnosis) (*domain.Diagnosis, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if entity.UUID == "" {
		return nil, errors.BadRequest("MISSING_ID", "diagnosis ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	exists, err := s.repo.CheckDiagnosisExists(ctx, entity.UUID, tenantID)
	if err != nil {
		return nil, err
	}
	if !exists {
		return nil, errors.NotFound("DIAGNOSIS_NOT_FOUND", fmt.Sprintf("diagnosis not found: %s", entity.UUID))
	}

	entity.TenantID = tenantID
	updatedBy := userID
	entity.UpdatedBy = &updatedBy

	updated, err := s.repo.UpdateDiagnosis(ctx, entity)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.plant-diagnosis.updated", updated.UUID, map[string]interface{}{
		"plant_diagnosis_id": updated.UUID, "tenant_id": tenantID,
	})
	return updated, nil
}

func (s *diagnosisService) DeleteDiagnosis(ctx context.Context, uuid string) error {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return errors.BadRequest("MISSING_ID", "diagnosis ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	exists, err := s.repo.CheckDiagnosisExists(ctx, uuid, tenantID)
	if err != nil {
		return err
	}
	if !exists {
		return errors.NotFound("DIAGNOSIS_NOT_FOUND", fmt.Sprintf("diagnosis not found: %s", uuid))
	}

	if err := s.repo.DeleteDiagnosis(ctx, uuid, tenantID, userID); err != nil {
		return err
	}

	s.emitEvent(ctx, "agriculture.plant-diagnosis.deleted", uuid, map[string]interface{}{
		"plant_diagnosis_id": uuid, "tenant_id": tenantID,
	})
	return nil
}

func (s *diagnosisService) emitEvent(ctx context.Context, eventType, aggregateID string, data map[string]interface{}) {
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
