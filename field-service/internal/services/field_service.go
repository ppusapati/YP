package services

import (
	"context"
	"fmt"
	"time"

	"p9e.in/samavaya/agriculture/field-service/internal/models"
	"p9e.in/samavaya/agriculture/field-service/internal/repositories"
	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
)

// FieldService defines the business-logic contract for field management.
type FieldService interface {
	CreateField(ctx context.Context, input models.CreateFieldInput) (*models.Field, error)
	GetField(ctx context.Context, fieldID string) (*models.Field, error)
	ListFields(ctx context.Context, input models.ListFieldsInput) ([]models.Field, int64, error)
	UpdateField(ctx context.Context, input models.UpdateFieldInput) (*models.Field, error)
	DeleteField(ctx context.Context, fieldID string) error
	ListFieldsByFarm(ctx context.Context, farmID string, pageSize, pageOffset int32) ([]models.Field, int64, error)
	SetFieldBoundary(ctx context.Context, input models.SetBoundaryInput) (*models.FieldBoundary, error)
	AssignCrop(ctx context.Context, input models.AssignCropInput) (*models.FieldCropAssignment, error)
	SegmentField(ctx context.Context, fieldID string, inputs []models.SegmentFieldInput) ([]models.FieldSegment, error)
	GetFieldSegments(ctx context.Context, fieldID string) ([]models.FieldSegment, error)
	GetCropHistory(ctx context.Context, fieldID string, pageSize, pageOffset int32) ([]models.FieldCropAssignment, int64, error)
}

type fieldService struct {
	repo   repositories.FieldRepository
	deps   deps.ServiceDeps
	logger *p9log.Helper
}

// NewFieldService creates a new FieldService with the given dependencies.
func NewFieldService(d deps.ServiceDeps, repo repositories.FieldRepository) FieldService {
	return &fieldService{
		repo:   repo,
		deps:   d,
		logger: p9log.NewHelper(p9log.With(d.Log, "component", "field_service")),
	}
}

// ---------------------------------------------------------------------------
// CreateField
// ---------------------------------------------------------------------------

func (s *fieldService) CreateField(ctx context.Context, input models.CreateFieldInput) (*models.Field, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}

	if err := validateCreateFieldInput(input); err != nil {
		return nil, err
	}

	// Ensure name is unique within the farm.
	exists, err := s.repo.FieldNameExists(ctx, tenantID, input.FarmID, input.Name)
	if err != nil {
		return nil, err
	}
	if exists {
		return nil, errors.Conflict("FIELD_NAME_DUPLICATE",
			fmt.Sprintf("field with name %q already exists in farm %s", input.Name, input.FarmID))
	}

	field, err := s.repo.CreateField(ctx, tenantID, userID, input)
	if err != nil {
		return nil, err
	}

	s.publishEvent(ctx, EventTypeFieldCreated, field.ID, map[string]interface{}{
		"field_id":  field.ID,
		"farm_id":   field.FarmID,
		"name":      field.Name,
		"tenant_id": tenantID,
	})

	s.logger.Infow("msg", "field created", "field_id", field.ID, "farm_id", field.FarmID)
	return field, nil
}

// ---------------------------------------------------------------------------
// GetField
// ---------------------------------------------------------------------------

func (s *fieldService) GetField(ctx context.Context, fieldID string) (*models.Field, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if fieldID == "" {
		return nil, errors.BadRequest("MISSING_FIELD_ID", "field ID is required")
	}

	field, err := s.repo.GetFieldByID(ctx, tenantID, fieldID)
	if err != nil {
		return nil, err
	}
	return field, nil
}

// ---------------------------------------------------------------------------
// ListFields
// ---------------------------------------------------------------------------

func (s *fieldService) ListFields(ctx context.Context, input models.ListFieldsInput) ([]models.Field, int64, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}

	if input.PageSize <= 0 {
		input.PageSize = 20
	}
	if input.PageSize > 100 {
		input.PageSize = 100
	}

	return s.repo.ListFields(ctx, tenantID, input)
}

// ---------------------------------------------------------------------------
// UpdateField
// ---------------------------------------------------------------------------

func (s *fieldService) UpdateField(ctx context.Context, input models.UpdateFieldInput) (*models.Field, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if input.ID == "" {
		return nil, errors.BadRequest("MISSING_FIELD_ID", "field ID is required")
	}

	// Validate status if provided.
	if input.Status != nil && !input.Status.IsValid() {
		return nil, errors.BadRequest("INVALID_STATUS", fmt.Sprintf("invalid field status: %s", *input.Status))
	}

	field, err := s.repo.UpdateField(ctx, tenantID, userID, input)
	if err != nil {
		return nil, err
	}

	s.publishEvent(ctx, EventTypeFieldUpdated, field.ID, map[string]interface{}{
		"field_id":  field.ID,
		"tenant_id": tenantID,
	})

	s.logger.Infow("msg", "field updated", "field_id", field.ID)
	return field, nil
}

// ---------------------------------------------------------------------------
// DeleteField
// ---------------------------------------------------------------------------

func (s *fieldService) DeleteField(ctx context.Context, fieldID string) error {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)
	if tenantID == "" {
		return errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if fieldID == "" {
		return errors.BadRequest("MISSING_FIELD_ID", "field ID is required")
	}

	err := s.repo.DeleteField(ctx, tenantID, userID, fieldID)
	if err != nil {
		return err
	}

	s.publishEvent(ctx, EventTypeFieldDeleted, fieldID, map[string]interface{}{
		"field_id":  fieldID,
		"tenant_id": tenantID,
	})

	s.logger.Infow("msg", "field deleted", "field_id", fieldID)
	return nil
}

// ---------------------------------------------------------------------------
// ListFieldsByFarm
// ---------------------------------------------------------------------------

func (s *fieldService) ListFieldsByFarm(ctx context.Context, farmID string, pageSize, pageOffset int32) ([]models.Field, int64, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if farmID == "" {
		return nil, 0, errors.BadRequest("MISSING_FARM_ID", "farm ID is required")
	}
	return s.repo.ListFieldsByFarm(ctx, tenantID, farmID, pageSize, pageOffset)
}

// ---------------------------------------------------------------------------
// SetFieldBoundary
// ---------------------------------------------------------------------------

func (s *fieldService) SetFieldBoundary(ctx context.Context, input models.SetBoundaryInput) (*models.FieldBoundary, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if input.FieldID == "" {
		return nil, errors.BadRequest("MISSING_FIELD_ID", "field ID is required")
	}
	if input.PolygonGeoJSON == "" {
		return nil, errors.BadRequest("MISSING_POLYGON", "polygon is required")
	}
	if input.Source == "" {
		input.Source = "manual"
	}

	// Verify the field exists.
	exists, err := s.repo.FieldExists(ctx, tenantID, input.FieldID)
	if err != nil {
		return nil, err
	}
	if !exists {
		return nil, errors.NotFound("FIELD_NOT_FOUND", fmt.Sprintf("field %s not found", input.FieldID))
	}

	boundary, err := s.repo.SetFieldBoundary(ctx, tenantID, userID, input)
	if err != nil {
		return nil, err
	}

	s.publishEvent(ctx, EventTypeFieldMapped, input.FieldID, map[string]interface{}{
		"field_id":    input.FieldID,
		"boundary_id": boundary.ID,
		"source":      input.Source,
		"tenant_id":   tenantID,
	})

	s.logger.Infow("msg", "field boundary set", "field_id", input.FieldID, "boundary_id", boundary.ID)
	return boundary, nil
}

// ---------------------------------------------------------------------------
// AssignCrop
// ---------------------------------------------------------------------------

func (s *fieldService) AssignCrop(ctx context.Context, input models.AssignCropInput) (*models.FieldCropAssignment, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if input.FieldID == "" {
		return nil, errors.BadRequest("MISSING_FIELD_ID", "field ID is required")
	}
	if input.CropID == "" {
		return nil, errors.BadRequest("MISSING_CROP_ID", "crop ID is required")
	}
	if input.PlantingDate.IsZero() {
		return nil, errors.BadRequest("MISSING_PLANTING_DATE", "planting date is required")
	}

	// Verify the field exists.
	exists, err := s.repo.FieldExists(ctx, tenantID, input.FieldID)
	if err != nil {
		return nil, err
	}
	if !exists {
		return nil, errors.NotFound("FIELD_NOT_FOUND", fmt.Sprintf("field %s not found", input.FieldID))
	}

	assignment, err := s.repo.AssignCrop(ctx, tenantID, userID, input)
	if err != nil {
		return nil, err
	}

	s.publishEvent(ctx, EventTypeCropAssigned, input.FieldID, map[string]interface{}{
		"field_id":      input.FieldID,
		"crop_id":       input.CropID,
		"assignment_id": assignment.ID,
		"season":        input.Season,
		"tenant_id":     tenantID,
	})

	s.logger.Infow("msg", "crop assigned", "field_id", input.FieldID, "crop_id", input.CropID)
	return assignment, nil
}

// ---------------------------------------------------------------------------
// SegmentField
// ---------------------------------------------------------------------------

func (s *fieldService) SegmentField(ctx context.Context, fieldID string, inputs []models.SegmentFieldInput) ([]models.FieldSegment, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if fieldID == "" {
		return nil, errors.BadRequest("MISSING_FIELD_ID", "field ID is required")
	}
	if len(inputs) == 0 {
		return nil, errors.BadRequest("MISSING_SEGMENTS", "at least one segment is required")
	}

	exists, err := s.repo.FieldExists(ctx, tenantID, fieldID)
	if err != nil {
		return nil, err
	}
	if !exists {
		return nil, errors.NotFound("FIELD_NOT_FOUND", fmt.Sprintf("field %s not found", fieldID))
	}

	segments, err := s.repo.CreateFieldSegments(ctx, fieldID, inputs)
	if err != nil {
		return nil, err
	}

	s.publishEvent(ctx, EventTypeFieldSegmented, fieldID, map[string]interface{}{
		"field_id":      fieldID,
		"segment_count": len(segments),
		"tenant_id":     tenantID,
	})

	s.logger.Infow("msg", "field segmented", "field_id", fieldID, "segments", len(segments))
	return segments, nil
}

// ---------------------------------------------------------------------------
// GetFieldSegments
// ---------------------------------------------------------------------------

func (s *fieldService) GetFieldSegments(ctx context.Context, fieldID string) ([]models.FieldSegment, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if fieldID == "" {
		return nil, errors.BadRequest("MISSING_FIELD_ID", "field ID is required")
	}

	exists, err := s.repo.FieldExists(ctx, tenantID, fieldID)
	if err != nil {
		return nil, err
	}
	if !exists {
		return nil, errors.NotFound("FIELD_NOT_FOUND", fmt.Sprintf("field %s not found", fieldID))
	}

	return s.repo.ListFieldSegments(ctx, fieldID)
}

// ---------------------------------------------------------------------------
// GetCropHistory
// ---------------------------------------------------------------------------

func (s *fieldService) GetCropHistory(ctx context.Context, fieldID string, pageSize, pageOffset int32) ([]models.FieldCropAssignment, int64, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if fieldID == "" {
		return nil, 0, errors.BadRequest("MISSING_FIELD_ID", "field ID is required")
	}

	exists, err := s.repo.FieldExists(ctx, tenantID, fieldID)
	if err != nil {
		return nil, 0, err
	}
	if !exists {
		return nil, 0, errors.NotFound("FIELD_NOT_FOUND", fmt.Sprintf("field %s not found", fieldID))
	}

	return s.repo.ListCropAssignments(ctx, fieldID, pageSize, pageOffset)
}

// ---------------------------------------------------------------------------
// Validation helpers
// ---------------------------------------------------------------------------

func validateCreateFieldInput(input models.CreateFieldInput) error {
	if input.FarmID == "" {
		return errors.BadRequest("MISSING_FARM_ID", "farm ID is required")
	}
	if input.Name == "" {
		return errors.BadRequest("MISSING_NAME", "field name is required")
	}
	if len(input.Name) > 255 {
		return errors.BadRequest("INVALID_NAME", "field name must be at most 255 characters")
	}
	if input.AreaHectares < 0 {
		return errors.BadRequest("INVALID_AREA", "area must be non-negative")
	}
	if input.SlopeDegrees < 0 || input.SlopeDegrees > 90 {
		return errors.BadRequest("INVALID_SLOPE", "slope must be between 0 and 90 degrees")
	}
	return nil
}

// ---------------------------------------------------------------------------
// Event publishing
// ---------------------------------------------------------------------------

// Event types used by the field service.
const (
	EventTypeFieldCreated   domain.EventType = "agriculture.field.created"
	EventTypeFieldUpdated   domain.EventType = "agriculture.field.updated"
	EventTypeFieldDeleted   domain.EventType = "agriculture.field.deleted"
	EventTypeFieldMapped    domain.EventType = "agriculture.field.mapped"
	EventTypeCropAssigned   domain.EventType = "agriculture.field.crop.assigned"
	EventTypeFieldSegmented domain.EventType = "agriculture.field.segmented"
)

func (s *fieldService) publishEvent(ctx context.Context, eventType domain.EventType, aggregateID string, data map[string]interface{}) {
	if s.deps.KafkaProducer == nil {
		return
	}

	evt := domain.NewDomainEvent(eventType, aggregateID, "field", data).
		WithSource("field-service").
		WithCorrelationID(p9context.RequestID(ctx))

	tenantID := p9context.TenantID(ctx)
	if tenantID != "" {
		evt.WithMetadata("tenant_id", tenantID)
	}

	go func() {
		if err := s.deps.KafkaProducer.Publish(ctx, evt.GetTopic(), evt.ID, evt); err != nil {
			s.logger.Errorw("msg", "failed to publish event",
				"event_type", string(eventType),
				"aggregate_id", aggregateID,
				"error", err.Error(),
			)
		}
	}()
}

// ensure import is used
var _ = time.Now
