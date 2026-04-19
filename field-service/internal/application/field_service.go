// Package application contains the field-service application service.
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

"p9e.in/samavaya/agriculture/field-service/internal/domain"
"p9e.in/samavaya/agriculture/field-service/internal/ports/inbound"
"p9e.in/samavaya/agriculture/field-service/internal/ports/outbound"
)

const (
serviceName       = "field-service"
fieldEventTopic   = "samavaya.agriculture.field.events"
maxPageSize int32 = 100
defaultPageSize   = int32(20)
)

type fieldService struct {
repo       outbound.FieldRepository
pub        outbound.EventPublisher
farmClient outbound.FarmClient
pool       *pgxpool.Pool
log        *p9log.Helper
}

// NewFieldService creates a new application-layer FieldService.
func NewFieldService(
repo outbound.FieldRepository,
pub outbound.EventPublisher,
farmClient outbound.FarmClient,
pool *pgxpool.Pool,
log p9log.Logger,
) inbound.FieldService {
return &fieldService{
repo:       repo,
pub:        pub,
farmClient: farmClient,
pool:       pool,
log:        p9log.NewHelper(p9log.With(log, "component", "FieldService")),
}
}

func (s *fieldService) CreateField(ctx context.Context, field *domain.Field) (*domain.Field, error) {
tenantID := p9context.TenantID(ctx)
userID := p9context.UserID(ctx)

if tenantID == "" {
return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
}
if field.FarmID == "" {
return nil, errors.BadRequest("MISSING_FARM_ID", "farm ID is required")
}
if field.Name == "" {
return nil, errors.BadRequest("INVALID_FIELD_NAME", "field name is required")
}
if field.AreaHectares < 0 {
return nil, errors.BadRequest("INVALID_AREA", "area must be non-negative")
}
if field.FieldType != domain.FieldTypeUnspecified && !field.FieldType.IsValid() {
return nil, errors.BadRequest("INVALID_FIELD_TYPE", "invalid field type")
}
if userID == "" {
userID = "system"
}

// Validate farm exists via outbound port
if s.farmClient != nil {
exists, err := s.farmClient.FarmExists(ctx, field.FarmID, tenantID)
if err != nil {
return nil, errors.InternalServer("FARM_CHECK_FAILED", "could not validate farm")
}
if !exists {
return nil, errors.NotFound("FARM_NOT_FOUND", fmt.Sprintf("farm not found: %s", field.FarmID))
}
}

nameExists, err := s.repo.CheckFieldNameExists(ctx, field.Name, field.FarmID, tenantID)
if err != nil {
return nil, err
}
if nameExists {
return nil, errors.Conflict("FIELD_NAME_EXISTS", fmt.Sprintf("field with name '%s' already exists in farm", field.Name))
}

field.TenantID = tenantID
field.CreatedBy = userID
field.Status = domain.FieldStatusActive

created, err := s.repo.CreateField(ctx, field)
if err != nil {
return nil, err
}

s.emitEvent(ctx, "agriculture.field.created", created.UUID, map[string]interface{}{
"field_id": created.UUID, "farm_id": created.FarmID, "tenant_id": tenantID,
})
s.log.Infow("msg", "field created", "uuid", created.UUID, "farm_id", created.FarmID)
return created, nil
}

func (s *fieldService) GetField(ctx context.Context, uuid string) (*domain.Field, error) {
tenantID := p9context.TenantID(ctx)
if tenantID == "" {
return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
}
if uuid == "" {
return nil, errors.BadRequest("MISSING_FIELD_ID", "field ID is required")
}
return s.repo.GetFieldByUUID(ctx, uuid, tenantID)
}

func (s *fieldService) ListFields(ctx context.Context, params domain.ListFieldsParams) ([]domain.Field, int32, error) {
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
return s.repo.ListFields(ctx, params)
}

func (s *fieldService) UpdateField(ctx context.Context, field *domain.Field) (*domain.Field, error) {
tenantID := p9context.TenantID(ctx)
userID := p9context.UserID(ctx)

if tenantID == "" {
return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
}
if field.UUID == "" {
return nil, errors.BadRequest("MISSING_FIELD_ID", "field ID is required")
}
if field.Status != domain.FieldStatusUnspecified && !field.Status.IsValid() {
return nil, errors.BadRequest("INVALID_STATUS", "invalid field status")
}
if userID == "" {
userID = "system"
}

exists, err := s.repo.CheckFieldExists(ctx, field.UUID, tenantID)
if err != nil {
return nil, err
}
if !exists {
return nil, errors.NotFound("FIELD_NOT_FOUND", fmt.Sprintf("field not found: %s", field.UUID))
}

field.TenantID = tenantID
updatedBy := userID
field.UpdatedBy = &updatedBy

updated, err := s.repo.UpdateField(ctx, field)
if err != nil {
return nil, err
}

s.emitEvent(ctx, "agriculture.field.updated", updated.UUID, map[string]interface{}{
"field_id": updated.UUID, "tenant_id": tenantID,
})
return updated, nil
}

func (s *fieldService) DeleteField(ctx context.Context, uuid string) error {
tenantID := p9context.TenantID(ctx)
userID := p9context.UserID(ctx)

if tenantID == "" {
return errors.BadRequest("MISSING_TENANT", "tenant ID is required")
}
if uuid == "" {
return errors.BadRequest("MISSING_FIELD_ID", "field ID is required")
}
if userID == "" {
userID = "system"
}

exists, err := s.repo.CheckFieldExists(ctx, uuid, tenantID)
if err != nil {
return err
}
if !exists {
return errors.NotFound("FIELD_NOT_FOUND", fmt.Sprintf("field not found: %s", uuid))
}

if err := s.repo.DeleteField(ctx, uuid, tenantID, userID); err != nil {
return err
}

s.emitEvent(ctx, "agriculture.field.deleted", uuid, map[string]interface{}{
"field_id": uuid, "tenant_id": tenantID,
})
return nil
}

func (s *fieldService) AssignCrop(ctx context.Context, params domain.AssignCropParams) (*domain.Field, error) {
tenantID := p9context.TenantID(ctx)
userID := p9context.UserID(ctx)

if tenantID == "" {
return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
}
if params.FieldUUID == "" {
return nil, errors.BadRequest("MISSING_FIELD_ID", "field ID is required")
}
if params.CropID == "" {
return nil, errors.BadRequest("MISSING_CROP_ID", "crop ID is required")
}
if userID == "" {
userID = "system"
}

field, err := s.repo.GetFieldByUUID(ctx, params.FieldUUID, tenantID)
if err != nil {
return nil, err
}

field.CurrentCropID = &params.CropID
field.PlantingDate = &params.PlantingDate
field.ExpectedHarvestDate = params.ExpectedHarvestDate
field.GrowthStage = params.GrowthStage
field.Status = domain.FieldStatusPlanted
updatedBy := userID
field.UpdatedBy = &updatedBy

updated, err := s.repo.UpdateField(ctx, field)
if err != nil {
return nil, err
}

s.emitEvent(ctx, "agriculture.field.crop.assigned", updated.UUID, map[string]interface{}{
"field_id": updated.UUID, "crop_id": params.CropID, "tenant_id": tenantID,
})
return updated, nil
}

func (s *fieldService) GetFieldSummary(ctx context.Context, uuid string) (*domain.FieldSummary, error) {
field, err := s.GetField(ctx, uuid)
if err != nil {
return nil, err
}
return &domain.FieldSummary{
UUID:     field.UUID,
TenantID: field.TenantID,
FarmID:   field.FarmID,
Name:     field.Name,
AreaHa:   field.AreaHectares,
Status:   field.Status,
}, nil
}

func (s *fieldService) emitEvent(ctx context.Context, eventType, aggregateID string, data map[string]interface{}) {
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
if err := s.pub.Publish(ctx, fieldEventTopic, aggregateID, raw); err != nil {
s.log.Errorw("msg", "failed to publish event", "event_type", eventType, "error", err)
}
}
