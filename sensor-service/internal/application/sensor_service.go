// Package application contains the sensor-service application service.
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

	"p9e.in/samavaya/agriculture/sensor-service/internal/domain"
	"p9e.in/samavaya/agriculture/sensor-service/internal/ports/inbound"
	"p9e.in/samavaya/agriculture/sensor-service/internal/ports/outbound"
)

const (
	serviceName           = "sensor-service"
	eventTopic            = "samavaya.agriculture.sensor.events"
	maxPageSize     int32 = 100
	defaultPageSize       = int32(20)
)

type sensorService struct {
	repo        outbound.SensorRepository
	pub         outbound.EventPublisher
	fieldClient outbound.FieldClient
	pool        *pgxpool.Pool
	log         *p9log.Helper
}

// NewSensorService creates a new application-layer SensorService.
func NewSensorService(
	repo outbound.SensorRepository,
	pub outbound.EventPublisher,
	fieldClient outbound.FieldClient,
	pool *pgxpool.Pool,
	log p9log.Logger,
) inbound.SensorService {
	return &sensorService{
		repo:        repo,
		pub:         pub,
		fieldClient: fieldClient,
		pool:        pool,
		log:         p9log.NewHelper(p9log.With(log, "component", "SensorService")),
	}
}

func (s *sensorService) CreateSensor(ctx context.Context, entity *domain.Sensor) (*domain.Sensor, error) {
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

	nameExists, err := s.repo.CheckSensorNameExists(ctx, entity.Name, tenantID)
	if err != nil {
		return nil, err
	}
	if nameExists {
		return nil, errors.Conflict("SENSOR_NAME_EXISTS", fmt.Sprintf("sensor with name '%s' already exists", entity.Name))
	}

	entity.TenantID = tenantID
	entity.CreatedBy = userID
	entity.Status = domain.SensorStatusActive

	created, err := s.repo.CreateSensor(ctx, entity)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.sensor.created", created.UUID, map[string]interface{}{
		"sensor_id": created.UUID, "tenant_id": tenantID,
	})
	s.log.Infow("msg", "sensor created", "uuid", created.UUID)
	return created, nil
}

func (s *sensorService) GetSensor(ctx context.Context, uuid string) (*domain.Sensor, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return nil, errors.BadRequest("MISSING_ID", "sensor ID is required")
	}
	return s.repo.GetSensorByUUID(ctx, uuid, tenantID)
}

func (s *sensorService) ListSensors(ctx context.Context, params domain.ListSensorParams) ([]domain.Sensor, int32, error) {
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
	return s.repo.ListSensors(ctx, params)
}

func (s *sensorService) UpdateSensor(ctx context.Context, entity *domain.Sensor) (*domain.Sensor, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if entity.UUID == "" {
		return nil, errors.BadRequest("MISSING_ID", "sensor ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	exists, err := s.repo.CheckSensorExists(ctx, entity.UUID, tenantID)
	if err != nil {
		return nil, err
	}
	if !exists {
		return nil, errors.NotFound("SENSOR_NOT_FOUND", fmt.Sprintf("sensor not found: %s", entity.UUID))
	}

	entity.TenantID = tenantID
	updatedBy := userID
	entity.UpdatedBy = &updatedBy

	updated, err := s.repo.UpdateSensor(ctx, entity)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.sensor.updated", updated.UUID, map[string]interface{}{
		"sensor_id": updated.UUID, "tenant_id": tenantID,
	})
	return updated, nil
}

func (s *sensorService) DeleteSensor(ctx context.Context, uuid string) error {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return errors.BadRequest("MISSING_ID", "sensor ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	exists, err := s.repo.CheckSensorExists(ctx, uuid, tenantID)
	if err != nil {
		return err
	}
	if !exists {
		return errors.NotFound("SENSOR_NOT_FOUND", fmt.Sprintf("sensor not found: %s", uuid))
	}

	if err := s.repo.DeleteSensor(ctx, uuid, tenantID, userID); err != nil {
		return err
	}

	s.emitEvent(ctx, "agriculture.sensor.deleted", uuid, map[string]interface{}{
		"sensor_id": uuid, "tenant_id": tenantID,
	})
	return nil
}

func (s *sensorService) emitEvent(ctx context.Context, eventType, aggregateID string, data map[string]interface{}) {
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
