package application

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/geojson"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"
	"p9e.in/samavaya/packages/uow"

	"p9e.in/samavaya/agriculture/field-service/internal/domain"
	"p9e.in/samavaya/agriculture/field-service/internal/ports/inbound"
	"p9e.in/samavaya/agriculture/field-service/internal/ports/outbound"
)

const (
	serviceName           = "field-service"
	fieldEventTopic       = "samavaya.agriculture.field.events"
	maxPageSize     int32 = 100
	defaultPageSize       = int32(20)
)

type fieldService struct {
	repo       outbound.FieldRepository
	pub        outbound.EventPublisher
	farmClient outbound.FarmClient
	cropClient outbound.CropClient
	pool       *pgxpool.Pool
	log        *p9log.Helper
}

func NewFieldService(
	repo outbound.FieldRepository,
	pub outbound.EventPublisher,
	farmClient outbound.FarmClient,
	cropClient outbound.CropClient,
	pool *pgxpool.Pool,
	log p9log.Logger,
) inbound.FieldService {
	return &fieldService{
		repo:       repo,
		pub:        pub,
		farmClient: farmClient,
		cropClient: cropClient,
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

	s.emitEvent(ctx, "agriculture.field.created", created.ID, map[string]interface{}{
		"field_id": created.ID, "farm_id": created.FarmID, "tenant_id": tenantID,
	})
	s.log.Infow("msg", "field created", "uuid", created.ID, "farm_id", created.FarmID)
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
	if field.ID == "" {
		return nil, errors.BadRequest("MISSING_FIELD_ID", "field ID is required")
	}
	if field.Status != domain.FieldStatusUnspecified && !field.Status.IsValid() {
		return nil, errors.BadRequest("INVALID_STATUS", "invalid field status")
	}
	if userID == "" {
		userID = "system"
	}

	exists, err := s.repo.CheckFieldExists(ctx, field.ID, tenantID)
	if err != nil {
		return nil, err
	}
	if !exists {
		return nil, errors.NotFound("FIELD_NOT_FOUND", fmt.Sprintf("field not found: %s", field.ID))
	}

	field.TenantID = tenantID
	updatedBy := userID
	field.UpdatedBy = &updatedBy

	updated, err := s.repo.UpdateField(ctx, field)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.field.updated", updated.ID, map[string]interface{}{
		"field_id": updated.ID, "tenant_id": tenantID,
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

func (s *fieldService) AssignCrop(ctx context.Context, params domain.AssignCropParams) (*domain.CropAssignment, error) {
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

	exists, err := s.cropClient.CropExists(ctx, params.CropID, tenantID)
	if err != nil {
		return nil, errors.InternalServer("CROP_CHECK_FAILED", fmt.Sprintf("failed to verify crop: %v", err))
	}
	if !exists {
		return nil, errors.NotFound("CROP_NOT_FOUND", "crop does not exist")
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

	_, err = s.repo.UpdateField(ctx, field)
	if err != nil {
		return nil, err
	}

	assignment := &domain.CropAssignment{
		TenantID:            tenantID,
		FieldID:             params.FieldUUID,
		CropID:              params.CropID,
		CropVariety:         params.CropVariety,
		PlantingDate:        &params.PlantingDate,
		ExpectedHarvestDate: params.ExpectedHarvestDate,
		GrowthStage:         params.GrowthStage,
		Season:              params.Season,
		Notes:               params.Notes,
	}

	created, err := s.repo.CreateCropAssignment(ctx, assignment)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.field.crop.assigned", field.ID, map[string]interface{}{
		"field_id": field.ID, "crop_id": params.CropID, "tenant_id": tenantID,
	})
	return created, nil
}

func (s *fieldService) GetFieldSummary(ctx context.Context, uuid string) (*domain.FieldSummary, error) {
	field, err := s.GetField(ctx, uuid)
	if err != nil {
		return nil, err
	}
	return &domain.FieldSummary{
		UUID:     field.ID,
		TenantID: field.TenantID,
		FarmID:   field.FarmID,
		Name:     field.Name,
		AreaHa:   field.AreaHectares,
		Status:   field.Status,
	}, nil
}

// ---------------------------------------------------------------------------
// New RPCs
// ---------------------------------------------------------------------------

func (s *fieldService) SetFieldBoundary(ctx context.Context, params domain.SetBoundaryParams) (*domain.FieldBoundary, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if params.FieldID == "" {
		return nil, errors.BadRequest("MISSING_FIELD_ID", "field ID is required")
	}
	if params.Polygon == "" {
		return nil, errors.BadRequest("MISSING_POLYGON", "polygon is required")
	}
	if err := geojson.ValidatePolygon(params.Polygon); err != nil {
		return nil, errors.BadRequest("INVALID_POLYGON", fmt.Sprintf("invalid polygon: %v", err))
	}

	exists, err := s.repo.CheckFieldExists(ctx, params.FieldID, tenantID)
	if err != nil {
		return nil, err
	}
	if !exists {
		return nil, errors.NotFound("FIELD_NOT_FOUND", fmt.Sprintf("field not found: %s", params.FieldID))
	}

	now := time.Now()
	b := &domain.FieldBoundary{
		TenantID:   tenantID,
		FieldID:    params.FieldID,
		Polygon:    params.Polygon,
		Source:     params.Source,
		RecordedAt: &now,
	}

	created, err := s.repo.SetFieldBoundary(ctx, b)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.field.boundary.set", params.FieldID, map[string]interface{}{
		"field_id": params.FieldID, "boundary_id": created.ID, "tenant_id": tenantID,
	})
	return created, nil
}

func (s *fieldService) ListFieldsByFarm(ctx context.Context, farmID string, pageSize, offset int32) ([]domain.Field, int32, error) {
	if farmID == "" {
		return nil, 0, errors.BadRequest("MISSING_FARM_ID", "farm ID is required")
	}
	params := domain.ListFieldsParams{
		FarmID:   &farmID,
		PageSize: pageSize,
		Offset:   offset,
	}
	return s.ListFields(ctx, params)
}

func (s *fieldService) SegmentField(ctx context.Context, params domain.SegmentFieldParams) ([]domain.FieldSegment, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if params.FieldID == "" {
		return nil, errors.BadRequest("MISSING_FIELD_ID", "field ID is required")
	}
	if len(params.Segments) == 0 {
		return nil, errors.BadRequest("MISSING_SEGMENTS", "at least one segment is required")
	}

	exists, err := s.repo.CheckFieldExists(ctx, params.FieldID, tenantID)
	if err != nil {
		return nil, err
	}
	if !exists {
		return nil, errors.NotFound("FIELD_NOT_FOUND", fmt.Sprintf("field not found: %s", params.FieldID))
	}

	var segments []domain.FieldSegment
	txErr := uow.WithTransaction(ctx, s.pool, func(u uow.UnitOfWork) error {
		txRepo := s.repo.WithTx(u.Tx())
		if err := txRepo.DeleteFieldSegments(ctx, params.FieldID, tenantID); err != nil {
			return err
		}
		created, err := txRepo.CreateFieldSegments(ctx, params.FieldID, tenantID, params.Segments)
		if err != nil {
			return err
		}
		segments = created
		return nil
	})
	if txErr != nil {
		return nil, txErr
	}

	s.emitEvent(ctx, "agriculture.field.segmented", params.FieldID, map[string]interface{}{
		"field_id": params.FieldID, "segment_count": len(segments), "tenant_id": tenantID,
	})
	return segments, nil
}

func (s *fieldService) GetFieldSegments(ctx context.Context, fieldID string) ([]domain.FieldSegment, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if fieldID == "" {
		return nil, errors.BadRequest("MISSING_FIELD_ID", "field ID is required")
	}
	return s.repo.GetFieldSegments(ctx, fieldID, tenantID)
}

func (s *fieldService) GetCropHistory(ctx context.Context, params domain.CropHistoryParams) ([]domain.CropAssignment, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if params.FieldID == "" {
		return nil, 0, errors.BadRequest("MISSING_FIELD_ID", "field ID is required")
	}
	if params.PageSize <= 0 {
		params.PageSize = defaultPageSize
	}
	if params.PageSize > maxPageSize {
		params.PageSize = maxPageSize
	}
	return s.repo.GetCropHistory(ctx, params.FieldID, tenantID, params.PageSize, params.Offset)
}

// ---------------------------------------------------------------------------
// Crop Cycles
// ---------------------------------------------------------------------------

func (s *fieldService) CreateCropCycle(ctx context.Context, cycle *domain.CropCycle) (*domain.CropCycle, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if cycle.FieldID == "" {
		return nil, errors.BadRequest("MISSING_FIELD_ID", "field_id is required")
	}
	if cycle.CropID == "" {
		return nil, errors.BadRequest("MISSING_CROP_ID", "crop_id is required")
	}
	if cycle.Season == "" {
		return nil, errors.BadRequest("MISSING_SEASON", "season is required")
	}
	if cycle.CycleYear <= 0 {
		return nil, errors.BadRequest("INVALID_CYCLE_YEAR", "cycle_year must be positive")
	}
	if userID == "" {
		userID = "system"
	}

	exists, err := s.repo.CheckFieldExists(ctx, cycle.FieldID, tenantID)
	if err != nil {
		return nil, err
	}
	if !exists {
		return nil, errors.NotFound("FIELD_NOT_FOUND", fmt.Sprintf("field not found: %s", cycle.FieldID))
	}

	cycle.TenantID = tenantID
	cycle.CreatedBy = userID
	cycle.Status = domain.CropCycleStatusPlanned

	created, err := s.repo.CreateCropCycle(ctx, cycle)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.field.crop_cycle.created", created.ID, map[string]interface{}{
		"cycle_id": created.ID, "field_id": created.FieldID, "crop_id": created.CropID,
	})
	return created, nil
}

func (s *fieldService) GetCropCycle(ctx context.Context, id string) (*domain.CropCycle, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if id == "" {
		return nil, errors.BadRequest("MISSING_CYCLE_ID", "crop cycle ID is required")
	}
	return s.repo.GetCropCycleByID(ctx, id, tenantID)
}

func (s *fieldService) ListCropCycles(ctx context.Context, params domain.ListCropCyclesParams) ([]domain.CropCycle, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if params.FieldID == "" {
		return nil, 0, errors.BadRequest("MISSING_FIELD_ID", "field_id is required")
	}
	params.TenantID = tenantID
	if params.PageSize <= 0 {
		params.PageSize = defaultPageSize
	}
	if params.PageSize > maxPageSize {
		params.PageSize = maxPageSize
	}
	return s.repo.ListCropCycles(ctx, params)
}

func (s *fieldService) UpdateCropCycle(ctx context.Context, cycle *domain.CropCycle) (*domain.CropCycle, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if cycle.ID == "" {
		return nil, errors.BadRequest("MISSING_CYCLE_ID", "crop cycle ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	cycle.TenantID = tenantID
	updatedBy := userID
	cycle.UpdatedBy = &updatedBy

	updated, err := s.repo.UpdateCropCycle(ctx, cycle)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.field.crop_cycle.updated", updated.ID, map[string]interface{}{
		"cycle_id": updated.ID, "field_id": updated.FieldID,
	})
	return updated, nil
}

// ---------------------------------------------------------------------------
// Activity Events
// ---------------------------------------------------------------------------

func (s *fieldService) LogActivityEvent(ctx context.Context, event *domain.ActivityEvent) (*domain.ActivityEvent, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if event.FieldID == "" {
		return nil, errors.BadRequest("MISSING_FIELD_ID", "field_id is required")
	}
	if event.ActivityType == "" {
		return nil, errors.BadRequest("MISSING_ACTIVITY_TYPE", "activity_type is required")
	}
	if event.StartedAt.IsZero() {
		return nil, errors.BadRequest("MISSING_STARTED_AT", "started_at is required")
	}
	if userID == "" {
		userID = "system"
	}

	exists, err := s.repo.CheckFieldExists(ctx, event.FieldID, tenantID)
	if err != nil {
		return nil, err
	}
	if !exists {
		return nil, errors.NotFound("FIELD_NOT_FOUND", fmt.Sprintf("field not found: %s", event.FieldID))
	}

	event.TenantID = tenantID
	event.PerformedBy = userID

	created, err := s.repo.CreateActivityEvent(ctx, event)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.field.activity.logged", created.ID, map[string]interface{}{
		"event_id": created.ID, "field_id": created.FieldID, "activity_type": created.ActivityType,
	})
	return created, nil
}

func (s *fieldService) ListActivityEvents(ctx context.Context, params domain.ListActivityEventsParams) ([]domain.ActivityEvent, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if params.FieldID == "" {
		return nil, 0, errors.BadRequest("MISSING_FIELD_ID", "field_id is required")
	}
	params.TenantID = tenantID
	if params.PageSize <= 0 {
		params.PageSize = defaultPageSize
	}
	if params.PageSize > maxPageSize {
		params.PageSize = maxPageSize
	}
	return s.repo.ListActivityEvents(ctx, params)
}

// ---------------------------------------------------------------------------
// Activity Evidence
// ---------------------------------------------------------------------------

func (s *fieldService) AddActivityEvidence(ctx context.Context, evidence *domain.ActivityEvidence) (*domain.ActivityEvidence, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if evidence.ActivityEventID == "" {
		return nil, errors.BadRequest("MISSING_ACTIVITY_EVENT_ID", "activity_event_id is required")
	}
	if evidence.FileURL == "" {
		return nil, errors.BadRequest("MISSING_FILE_URL", "file_url is required")
	}
	if userID == "" {
		userID = "system"
	}

	evidence.TenantID = tenantID
	evidence.CapturedBy = userID

	created, err := s.repo.CreateActivityEvidence(ctx, evidence)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.field.activity.evidence.added", created.ID, map[string]interface{}{
		"evidence_id": created.ID, "activity_event_id": created.ActivityEventID, "tenant_id": tenantID,
	})
	return created, nil
}

func (s *fieldService) ListActivityEvidence(ctx context.Context, params domain.ListActivityEvidenceParams) ([]domain.ActivityEvidence, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if params.ActivityEventID == "" {
		return nil, 0, errors.BadRequest("MISSING_ACTIVITY_EVENT_ID", "activity_event_id is required")
	}
	params.TenantID = tenantID
	if params.PageSize <= 0 {
		params.PageSize = defaultPageSize
	}
	if params.PageSize > maxPageSize {
		params.PageSize = maxPageSize
	}
	return s.repo.ListActivityEvidence(ctx, params)
}

func (s *fieldService) DeleteActivityEvidence(ctx context.Context, id string) error {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if id == "" {
		return errors.BadRequest("MISSING_EVIDENCE_ID", "evidence ID is required")
	}

	if err := s.repo.DeleteActivityEvidence(ctx, id, tenantID); err != nil {
		return err
	}

	s.emitEvent(ctx, "agriculture.field.activity.evidence.deleted", id, map[string]interface{}{
		"evidence_id": id, "tenant_id": tenantID,
	})
	return nil
}

// ---------------------------------------------------------------------------
// helpers
// ---------------------------------------------------------------------------

func (s *fieldService) emitEvent(ctx context.Context, eventType, aggregateID string, data map[string]interface{}) {
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
	if err := s.pub.Publish(ctx, fieldEventTopic, aggregateID, raw); err != nil {
		s.log.Errorw("msg", "failed to publish event", "event_type", eventType, "error", err)
	}
}
