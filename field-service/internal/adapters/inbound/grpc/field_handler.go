package grpc

import (
	"context"
	"encoding/json"

	"connectrpc.com/connect"
	"google.golang.org/protobuf/types/known/timestamppb"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"

	pb "p9e.in/samavaya/agriculture/field-service/api/v1"
	"p9e.in/samavaya/agriculture/field-service/api/v1/fieldv1connect"
	"p9e.in/samavaya/agriculture/field-service/internal/domain"
	"p9e.in/samavaya/agriculture/field-service/internal/ports/inbound"
)

type FieldHandler struct {
	fieldv1connect.UnimplementedFieldServiceHandler
	svc inbound.FieldService
	log *p9log.Helper
}

func NewFieldHandler(svc inbound.FieldService, log p9log.Logger) *FieldHandler {
	return &FieldHandler{
		svc: svc,
		log: p9log.NewHelper(p9log.With(log, "component", "FieldHandler")),
	}
}

// ---------------------------------------------------------------------------
// Existing RPCs
// ---------------------------------------------------------------------------

func (h *FieldHandler) CreateField(ctx context.Context, req *connect.Request[pb.CreateFieldRequest]) (*connect.Response[pb.CreateFieldResponse], error) {
	h.log.Infow("msg", "CreateField request", "tenant_id", p9context.TenantID(ctx))

	if req.Msg.GetFarmId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "farm_id is required")
	}
	if req.Msg.GetName() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "name is required")
	}

	field := &domain.Field{
		FarmID:       req.Msg.GetFarmId(),
		Name:         req.Msg.GetName(),
		AreaHectares: req.Msg.GetAreaHectares(),
		FieldType:    protoFieldTypeToDomain(req.Msg.GetFieldType()),
		SoilType:     protoSoilTypeToDomain(req.Msg.GetSoilType()),
	}

	created, err := h.svc.CreateField(ctx, field)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.CreateFieldResponse{Field: fieldToProto(created)}), nil
}

func (h *FieldHandler) GetField(ctx context.Context, req *connect.Request[pb.GetFieldRequest]) (*connect.Response[pb.GetFieldResponse], error) {
	if req.Msg.GetId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "id is required")
	}
	field, err := h.svc.GetField(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.GetFieldResponse{Field: fieldToProto(field)}), nil
}

func (h *FieldHandler) ListFields(ctx context.Context, req *connect.Request[pb.ListFieldsRequest]) (*connect.Response[pb.ListFieldsResponse], error) {
	params := domain.ListFieldsParams{
		PageSize: req.Msg.GetPageSize(),
		Offset:   req.Msg.GetPageOffset(),
	}
	if farmID := req.Msg.GetFarmId(); farmID != "" {
		params.FarmID = &farmID
	}
	if req.Msg.GetStatus() != pb.FieldStatus_FIELD_STATUS_UNSPECIFIED {
		s := protoFieldStatusToDomain(req.Msg.GetStatus())
		params.Status = &s
	}
	if req.Msg.GetFieldType() != pb.FieldType_FIELD_TYPE_UNSPECIFIED {
		ft := protoFieldTypeToDomain(req.Msg.GetFieldType())
		params.FieldType = &ft
	}
	if search := req.Msg.GetSearch(); search != "" {
		params.Search = &search
	}

	fields, total, err := h.svc.ListFields(ctx, params)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	protos := make([]*pb.Field, 0, len(fields))
	for i := range fields {
		protos = append(protos, fieldToProto(&fields[i]))
	}
	return connect.NewResponse(&pb.ListFieldsResponse{Fields: protos, TotalCount: total}), nil
}

func (h *FieldHandler) UpdateField(ctx context.Context, req *connect.Request[pb.UpdateFieldRequest]) (*connect.Response[pb.UpdateFieldResponse], error) {
	if req.Msg.GetId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "id is required")
	}
	field := &domain.Field{}
	field.ID = req.Msg.GetId()
	if req.Msg.GetName() != "" {
		field.Name = req.Msg.GetName()
	}
	if req.Msg.GetStatus() != pb.FieldStatus_FIELD_STATUS_UNSPECIFIED {
		field.Status = protoFieldStatusToDomain(req.Msg.GetStatus())
	}
	updated, err := h.svc.UpdateField(ctx, field)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.UpdateFieldResponse{Field: fieldToProto(updated)}), nil
}

func (h *FieldHandler) DeleteField(ctx context.Context, req *connect.Request[pb.DeleteFieldRequest]) (*connect.Response[pb.DeleteFieldResponse], error) {
	if req.Msg.GetId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "id is required")
	}
	if err := h.svc.DeleteField(ctx, req.Msg.GetId()); err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.DeleteFieldResponse{}), nil
}

func (h *FieldHandler) AssignCrop(ctx context.Context, req *connect.Request[pb.AssignCropRequest]) (*connect.Response[pb.AssignCropResponse], error) {
	if req.Msg.GetFieldId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "field_id is required")
	}
	if req.Msg.GetCropId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "crop_id is required")
	}

	params := domain.AssignCropParams{
		FieldUUID:   req.Msg.GetFieldId(),
		CropID:      req.Msg.GetCropId(),
		CropVariety: req.Msg.GetCropVariety(),
		Season:      req.Msg.GetSeason(),
		Notes:       req.Msg.GetNotes(),
	}
	if req.Msg.GetPlantingDate() != nil {
		params.PlantingDate = req.Msg.GetPlantingDate().AsTime()
	}
	if req.Msg.GetExpectedHarvestDate() != nil {
		t := req.Msg.GetExpectedHarvestDate().AsTime()
		params.ExpectedHarvestDate = &t
	}

	assignment, err := h.svc.AssignCrop(ctx, params)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.AssignCropResponse{Assignment: cropAssignmentToProto(assignment)}), nil
}

// ---------------------------------------------------------------------------
// New RPCs
// ---------------------------------------------------------------------------

func (h *FieldHandler) SetFieldBoundary(ctx context.Context, req *connect.Request[pb.SetFieldBoundaryRequest]) (*connect.Response[pb.SetFieldBoundaryResponse], error) {
	if req.Msg.GetFieldId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "field_id is required")
	}
	if req.Msg.GetPolygon() == nil || len(req.Msg.GetPolygon().GetPoints()) < 3 {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "polygon must have at least 3 points")
	}

	polygonJSON, err := geoPolygonToJSON(req.Msg.GetPolygon())
	if err != nil {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "invalid polygon")
	}

	params := domain.SetBoundaryParams{
		FieldID: req.Msg.GetFieldId(),
		Polygon: polygonJSON,
		Source:  req.Msg.GetSource(),
	}

	boundary, err := h.svc.SetFieldBoundary(ctx, params)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.SetFieldBoundaryResponse{Boundary: boundaryToProto(boundary)}), nil
}

func (h *FieldHandler) ListFieldsByFarm(ctx context.Context, req *connect.Request[pb.ListFieldsByFarmRequest]) (*connect.Response[pb.ListFieldsByFarmResponse], error) {
	if req.Msg.GetFarmId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "farm_id is required")
	}

	fields, total, err := h.svc.ListFieldsByFarm(ctx, req.Msg.GetFarmId(), req.Msg.GetPageSize(), req.Msg.GetPageOffset())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	protos := make([]*pb.Field, 0, len(fields))
	for i := range fields {
		protos = append(protos, fieldToProto(&fields[i]))
	}
	return connect.NewResponse(&pb.ListFieldsByFarmResponse{Fields: protos, TotalCount: total}), nil
}

func (h *FieldHandler) SegmentField(ctx context.Context, req *connect.Request[pb.SegmentFieldRequest]) (*connect.Response[pb.SegmentFieldResponse], error) {
	if req.Msg.GetFieldId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "field_id is required")
	}
	if len(req.Msg.GetSegments()) == 0 {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "at least one segment is required")
	}

	inputs := make([]domain.FieldSegmentInput, 0, len(req.Msg.GetSegments()))
	for _, s := range req.Msg.GetSegments() {
		boundaryJSON := ""
		if s.GetBoundary() != nil {
			j, err := geoPolygonToJSON(s.GetBoundary())
			if err != nil {
				return nil, errors.BadRequest("INVALID_ARGUMENT", "invalid segment boundary")
			}
			boundaryJSON = j
		}
		inputs = append(inputs, domain.FieldSegmentInput{
			Name:         s.GetName(),
			Boundary:     boundaryJSON,
			AreaHectares: s.GetAreaHectares(),
			SoilType:     protoSoilTypeToDomain(s.GetSoilType()),
			Notes:        s.GetNotes(),
		})
	}

	segments, err := h.svc.SegmentField(ctx, domain.SegmentFieldParams{
		FieldID:  req.Msg.GetFieldId(),
		Segments: inputs,
	})
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	protos := make([]*pb.FieldSegment, 0, len(segments))
	for i := range segments {
		protos = append(protos, segmentToProto(&segments[i]))
	}
	return connect.NewResponse(&pb.SegmentFieldResponse{Segments: protos}), nil
}

func (h *FieldHandler) GetFieldSegments(ctx context.Context, req *connect.Request[pb.GetFieldSegmentsRequest]) (*connect.Response[pb.GetFieldSegmentsResponse], error) {
	if req.Msg.GetFieldId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "field_id is required")
	}

	segments, err := h.svc.GetFieldSegments(ctx, req.Msg.GetFieldId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	protos := make([]*pb.FieldSegment, 0, len(segments))
	for i := range segments {
		protos = append(protos, segmentToProto(&segments[i]))
	}
	return connect.NewResponse(&pb.GetFieldSegmentsResponse{Segments: protos}), nil
}

func (h *FieldHandler) GetCropHistory(ctx context.Context, req *connect.Request[pb.GetCropHistoryRequest]) (*connect.Response[pb.GetCropHistoryResponse], error) {
	if req.Msg.GetFieldId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "field_id is required")
	}

	assignments, total, err := h.svc.GetCropHistory(ctx, domain.CropHistoryParams{
		FieldID:  req.Msg.GetFieldId(),
		PageSize: req.Msg.GetPageSize(),
		Offset:   req.Msg.GetPageOffset(),
	})
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	protos := make([]*pb.FieldCropAssignment, 0, len(assignments))
	for i := range assignments {
		protos = append(protos, cropAssignmentToProto(&assignments[i]))
	}
	return connect.NewResponse(&pb.GetCropHistoryResponse{Assignments: protos, TotalCount: total}), nil
}

// ---------------------------------------------------------------------------
// Crop Cycle RPCs
// ---------------------------------------------------------------------------

func (h *FieldHandler) CreateCropCycle(ctx context.Context, req *connect.Request[pb.CreateCropCycleRequest]) (*connect.Response[pb.CreateCropCycleResponse], error) {
	h.log.Infow("msg", "CreateCropCycle request", "field_id", req.Msg.GetFieldId())
	if req.Msg.GetFieldId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "field_id is required")
	}
	if req.Msg.GetCropId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "crop_id is required")
	}
	if req.Msg.GetSeason() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "season is required")
	}
	if req.Msg.GetCycleYear() <= 0 {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "cycle_year must be positive")
	}

	cycle := &domain.CropCycle{
		FieldID:   req.Msg.GetFieldId(),
		CropID:    req.Msg.GetCropId(),
		Season:    req.Msg.GetSeason(),
		CycleYear: req.Msg.GetCycleYear(),
	}
	if req.Msg.GetName() != "" {
		s := req.Msg.GetName()
		cycle.Name = &s
	}
	if req.Msg.GetPlannedPlantingDate() != nil {
		t := req.Msg.GetPlannedPlantingDate().AsTime()
		cycle.PlannedPlantingDate = &t
	}
	if req.Msg.GetPlannedHarvestDate() != nil {
		t := req.Msg.GetPlannedHarvestDate().AsTime()
		cycle.PlannedHarvestDate = &t
	}
	if req.Msg.GetTargetYieldPerHectare() != 0 {
		f := req.Msg.GetTargetYieldPerHectare()
		cycle.TargetYieldPerHectare = &f
	}
	if req.Msg.GetYieldUnit() != "" {
		s := req.Msg.GetYieldUnit()
		cycle.YieldUnit = &s
	}
	if req.Msg.GetNotes() != "" {
		s := req.Msg.GetNotes()
		cycle.Notes = &s
	}
	if req.Msg.GetManagementUnitId() != "" {
		s := req.Msg.GetManagementUnitId()
		cycle.ManagementUnitID = &s
	}

	created, err := h.svc.CreateCropCycle(ctx, cycle)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.CreateCropCycleResponse{Cycle: cropCycleToProto(created)}), nil
}

func (h *FieldHandler) GetCropCycle(ctx context.Context, req *connect.Request[pb.GetCropCycleRequest]) (*connect.Response[pb.GetCropCycleResponse], error) {
	if req.Msg.GetId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "id is required")
	}
	cycle, err := h.svc.GetCropCycle(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.GetCropCycleResponse{Cycle: cropCycleToProto(cycle)}), nil
}

func (h *FieldHandler) ListCropCycles(ctx context.Context, req *connect.Request[pb.ListCropCyclesRequest]) (*connect.Response[pb.ListCropCyclesResponse], error) {
	if req.Msg.GetFieldId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "field_id is required")
	}
	params := domain.ListCropCyclesParams{
		FieldID:  req.Msg.GetFieldId(),
		PageSize: req.Msg.GetPageSize(),
		Offset:   req.Msg.GetPageOffset(),
	}
	if req.Msg.GetStatus() != pb.CropCycleStatus_CYCLE_STATUS_UNSPECIFIED {
		s := protoCropCycleStatusToDomain(req.Msg.GetStatus())
		params.Status = &s
	}
	cycles, total, err := h.svc.ListCropCycles(ctx, params)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	protos := make([]*pb.CropCycle, 0, len(cycles))
	for i := range cycles {
		protos = append(protos, cropCycleToProto(&cycles[i]))
	}
	return connect.NewResponse(&pb.ListCropCyclesResponse{Cycles: protos, TotalCount: total}), nil
}

func (h *FieldHandler) UpdateCropCycle(ctx context.Context, req *connect.Request[pb.UpdateCropCycleRequest]) (*connect.Response[pb.UpdateCropCycleResponse], error) {
	if req.Msg.GetId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "id is required")
	}
	cycle := &domain.CropCycle{ID: req.Msg.GetId()}
	if req.Msg.GetStatus() != pb.CropCycleStatus_CYCLE_STATUS_UNSPECIFIED {
		cycle.Status = protoCropCycleStatusToDomain(req.Msg.GetStatus())
	}
	if req.Msg.GetActualPlantingDate() != nil {
		t := req.Msg.GetActualPlantingDate().AsTime()
		cycle.ActualPlantingDate = &t
	}
	if req.Msg.GetActualHarvestDate() != nil {
		t := req.Msg.GetActualHarvestDate().AsTime()
		cycle.ActualHarvestDate = &t
	}
	if req.Msg.GetActualYieldPerHectare() != 0 {
		f := req.Msg.GetActualYieldPerHectare()
		cycle.ActualYieldPerHectare = &f
	}
	cycle.TotalInputCost = req.Msg.GetTotalInputCost()
	cycle.TotalRevenue = req.Msg.GetTotalRevenue()
	if req.Msg.GetNotes() != "" {
		s := req.Msg.GetNotes()
		cycle.Notes = &s
	}

	updated, err := h.svc.UpdateCropCycle(ctx, cycle)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.UpdateCropCycleResponse{Cycle: cropCycleToProto(updated)}), nil
}

// ---------------------------------------------------------------------------
// Activity Event RPCs
// ---------------------------------------------------------------------------

func (h *FieldHandler) LogActivityEvent(ctx context.Context, req *connect.Request[pb.LogActivityEventRequest]) (*connect.Response[pb.LogActivityEventResponse], error) {
	h.log.Infow("msg", "LogActivityEvent request", "field_id", req.Msg.GetFieldId())
	if req.Msg.GetFieldId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "field_id is required")
	}
	if req.Msg.GetActivityType() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "activity_type is required")
	}
	if req.Msg.GetStartedAt() == nil {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "started_at is required")
	}

	event := &domain.ActivityEvent{
		FieldID:      req.Msg.GetFieldId(),
		ActivityType: req.Msg.GetActivityType(),
		Category:     protoActivityCategoryToDomain(req.Msg.GetCategory()),
		StartedAt:    req.Msg.GetStartedAt().AsTime(),
		InputCost:    req.Msg.GetInputCost(),
	}
	if req.Msg.GetCropCycleId() != "" {
		s := req.Msg.GetCropCycleId()
		event.CropCycleID = &s
	}
	if req.Msg.GetCompletedAt() != nil {
		t := req.Msg.GetCompletedAt().AsTime()
		event.CompletedAt = &t
	}
	if req.Msg.GetDurationMinutes() != 0 {
		d := req.Msg.GetDurationMinutes()
		event.DurationMinutes = &d
	}
	if req.Msg.GetDescription() != "" {
		s := req.Msg.GetDescription()
		event.Description = &s
	}
	if req.Msg.GetNotes() != "" {
		s := req.Msg.GetNotes()
		event.Notes = &s
	}
	if req.Msg.GetInputProductId() != "" {
		s := req.Msg.GetInputProductId()
		event.InputProductID = &s
	}
	if req.Msg.GetInputQuantity() != 0 {
		f := req.Msg.GetInputQuantity()
		event.InputQuantity = &f
	}
	if req.Msg.GetInputUnit() != "" {
		s := req.Msg.GetInputUnit()
		event.InputUnit = &s
	}
	if req.Msg.GetCurrency() != "" {
		event.Currency = req.Msg.GetCurrency()
	}
	if req.Msg.GetAreaHectares() != 0 {
		f := req.Msg.GetAreaHectares()
		event.AreaHectares = &f
	}

	created, err := h.svc.LogActivityEvent(ctx, event)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.LogActivityEventResponse{Event: activityEventToProto(created)}), nil
}

func (h *FieldHandler) ListActivityEvents(ctx context.Context, req *connect.Request[pb.ListActivityEventsRequest]) (*connect.Response[pb.ListActivityEventsResponse], error) {
	if req.Msg.GetFieldId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "field_id is required")
	}
	params := domain.ListActivityEventsParams{
		FieldID:  req.Msg.GetFieldId(),
		PageSize: req.Msg.GetPageSize(),
		Offset:   req.Msg.GetPageOffset(),
	}
	if req.Msg.GetCropCycleId() != "" {
		s := req.Msg.GetCropCycleId()
		params.CropCycleID = &s
	}
	if req.Msg.GetCategory() != pb.ActivityCategory_CATEGORY_UNSPECIFIED {
		c := protoActivityCategoryToDomain(req.Msg.GetCategory())
		params.Category = &c
	}

	events, total, err := h.svc.ListActivityEvents(ctx, params)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	protos := make([]*pb.ActivityEvent, 0, len(events))
	for i := range events {
		protos = append(protos, activityEventToProto(&events[i]))
	}
	return connect.NewResponse(&pb.ListActivityEventsResponse{Events: protos, TotalCount: total}), nil
}

// ---------------------------------------------------------------------------
// Activity Evidence RPCs
// ---------------------------------------------------------------------------

func (h *FieldHandler) AddActivityEvidence(ctx context.Context, req *connect.Request[pb.AddActivityEvidenceRequest]) (*connect.Response[pb.AddActivityEvidenceResponse], error) {
	h.log.Infow("msg", "AddActivityEvidence request", "activity_event_id", req.Msg.GetActivityEventId())
	if req.Msg.GetActivityEventId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "activity_event_id is required")
	}
	if req.Msg.GetFileUrl() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "file_url is required")
	}

	evidence := &domain.ActivityEvidence{
		ActivityEventID: req.Msg.GetActivityEventId(),
		EvidenceType:    protoEvidenceTypeToDomain(req.Msg.GetEvidenceType()),
		FileURL:         req.Msg.GetFileUrl(),
	}
	if req.Msg.GetFileName() != "" {
		s := req.Msg.GetFileName()
		evidence.FileName = &s
	}
	if req.Msg.GetFileSizeBytes() != 0 {
		v := req.Msg.GetFileSizeBytes()
		evidence.FileSizeBytes = &v
	}
	if req.Msg.GetMimeType() != "" {
		s := req.Msg.GetMimeType()
		evidence.MimeType = &s
	}
	if req.Msg.GetThumbnailUrl() != "" {
		s := req.Msg.GetThumbnailUrl()
		evidence.ThumbnailURL = &s
	}
	if req.Msg.GetCaption() != "" {
		s := req.Msg.GetCaption()
		evidence.Caption = &s
	}
	if req.Msg.GetLatitude() != 0 {
		f := req.Msg.GetLatitude()
		evidence.Latitude = &f
	}
	if req.Msg.GetLongitude() != 0 {
		f := req.Msg.GetLongitude()
		evidence.Longitude = &f
	}
	if req.Msg.GetCapturedAt() != nil {
		t := req.Msg.GetCapturedAt().AsTime()
		evidence.CapturedAt = &t
	}

	created, err := h.svc.AddActivityEvidence(ctx, evidence)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.AddActivityEvidenceResponse{Evidence: activityEvidenceToProto(created)}), nil
}

func (h *FieldHandler) ListActivityEvidence(ctx context.Context, req *connect.Request[pb.ListActivityEvidenceRequest]) (*connect.Response[pb.ListActivityEvidenceResponse], error) {
	if req.Msg.GetActivityEventId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "activity_event_id is required")
	}
	params := domain.ListActivityEvidenceParams{
		ActivityEventID: req.Msg.GetActivityEventId(),
		PageSize:        req.Msg.GetPageSize(),
		Offset:          req.Msg.GetPageOffset(),
	}

	evidence, total, err := h.svc.ListActivityEvidence(ctx, params)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	protos := make([]*pb.ActivityEvidence, 0, len(evidence))
	for i := range evidence {
		protos = append(protos, activityEvidenceToProto(&evidence[i]))
	}
	return connect.NewResponse(&pb.ListActivityEvidenceResponse{Evidence: protos, TotalCount: total}), nil
}

func (h *FieldHandler) DeleteActivityEvidence(ctx context.Context, req *connect.Request[pb.DeleteActivityEvidenceRequest]) (*connect.Response[pb.DeleteActivityEvidenceResponse], error) {
	if req.Msg.GetId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "id is required")
	}
	if err := h.svc.DeleteActivityEvidence(ctx, req.Msg.GetId()); err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.DeleteActivityEvidenceResponse{}), nil
}

// ---------------------------------------------------------------------------
// Proto ↔ Domain converters
// ---------------------------------------------------------------------------

func fieldToProto(f *domain.Field) *pb.Field {
	out := &pb.Field{
		Id:              f.ID,
		TenantId:        f.TenantID,
		FarmId:          f.FarmID,
		Name:            f.Name,
		AreaHectares:    f.AreaHectares,
		FieldType:       domainFieldTypeToProto(f.FieldType),
		SoilType:        domainSoilTypeToProto(f.SoilType),
		IrrigationType:  domainIrrigationTypeToProto(f.IrrigationType),
		Status:          domainFieldStatusToProto(f.Status),
		GrowthStage:     domainGrowthStageToProto(f.GrowthStage),
		ElevationMeters: f.ElevationMeters,
		SlopeDegrees:    f.SlopeDegrees,
		AspectDirection: domainAspectDirectionToProto(f.AspectDirection),
		CreatedBy:       f.CreatedBy,
		Version:         f.Version,
	}
	if f.CurrentCropID != nil {
		out.CurrentCropId = *f.CurrentCropID
	}
	if f.UpdatedBy != nil {
		out.UpdatedBy = *f.UpdatedBy
	}
	if !f.CreatedAt.IsZero() {
		out.CreatedAt = timestamppb.New(f.CreatedAt)
	}
	if f.UpdatedAt != nil && !f.UpdatedAt.IsZero() {
		out.UpdatedAt = timestamppb.New(*f.UpdatedAt)
	}
	if f.PlantingDate != nil {
		out.PlantingDate = timestamppb.New(*f.PlantingDate)
	}
	if f.ExpectedHarvestDate != nil {
		out.ExpectedHarvestDate = timestamppb.New(*f.ExpectedHarvestDate)
	}
	return out
}

func boundaryToProto(b *domain.FieldBoundary) *pb.FieldBoundary {
	out := &pb.FieldBoundary{
		Id:              b.ID,
		FieldId:         b.FieldID,
		AreaHectares:    b.AreaHectares,
		PerimeterMeters: b.PerimeterMeters,
		Source:          b.Source,
	}
	if !b.CreatedAt.IsZero() {
		out.CreatedAt = timestamppb.New(b.CreatedAt)
	}
	if b.RecordedAt != nil {
		out.RecordedAt = timestamppb.New(*b.RecordedAt)
	}
	if b.Polygon != "" {
		out.Polygon = jsonToGeoPolygon(b.Polygon)
	}
	return out
}

func cropAssignmentToProto(a *domain.CropAssignment) *pb.FieldCropAssignment {
	out := &pb.FieldCropAssignment{
		Id:              a.ID,
		FieldId:         a.FieldID,
		CropId:          a.CropID,
		CropVariety:     a.CropVariety,
		GrowthStage:     domainGrowthStageToProto(a.GrowthStage),
		YieldPerHectare: a.YieldPerHectare,
		Notes:           a.Notes,
		Season:          a.Season,
	}
	if a.PlantingDate != nil {
		out.PlantingDate = timestamppb.New(*a.PlantingDate)
	}
	if a.ExpectedHarvestDate != nil {
		out.ExpectedHarvestDate = timestamppb.New(*a.ExpectedHarvestDate)
	}
	if a.ActualHarvestDate != nil {
		out.ActualHarvestDate = timestamppb.New(*a.ActualHarvestDate)
	}
	if !a.CreatedAt.IsZero() {
		out.CreatedAt = timestamppb.New(a.CreatedAt)
	}
	if !a.UpdatedAt.IsZero() {
		out.UpdatedAt = timestamppb.New(a.UpdatedAt)
	}
	return out
}

func segmentToProto(s *domain.FieldSegment) *pb.FieldSegment {
	out := &pb.FieldSegment{
		Id:            s.ID,
		FieldId:       s.FieldID,
		Name:          s.Name,
		AreaHectares:  s.AreaHectares,
		SoilType:      domainSoilTypeToProto(s.SoilType),
		CurrentCropId: s.CurrentCropID,
		Notes:         s.Notes,
		SegmentIndex:  s.SegmentIndex,
	}
	if s.Boundary != "" {
		out.Boundary = jsonToGeoPolygon(s.Boundary)
	}
	if !s.CreatedAt.IsZero() {
		out.CreatedAt = timestamppb.New(s.CreatedAt)
	}
	if !s.UpdatedAt.IsZero() {
		out.UpdatedAt = timestamppb.New(s.UpdatedAt)
	}
	return out
}

// ---------------------------------------------------------------------------
// GeoPolygon ↔ JSON
// ---------------------------------------------------------------------------

type geoPointJSON struct {
	Longitude float64 `json:"longitude"`
	Latitude  float64 `json:"latitude"`
}

func geoPolygonToJSON(p *pb.GeoPolygon) (string, error) {
	points := make([]geoPointJSON, 0, len(p.GetPoints()))
	for _, pt := range p.GetPoints() {
		points = append(points, geoPointJSON{Longitude: pt.GetLongitude(), Latitude: pt.GetLatitude()})
	}
	raw, err := json.Marshal(points)
	if err != nil {
		return "", err
	}
	return string(raw), nil
}

func jsonToGeoPolygon(s string) *pb.GeoPolygon {
	var points []geoPointJSON
	if err := json.Unmarshal([]byte(s), &points); err != nil {
		return nil
	}
	poly := &pb.GeoPolygon{Points: make([]*pb.GeoPoint, 0, len(points))}
	for _, p := range points {
		poly.Points = append(poly.Points, &pb.GeoPoint{Longitude: p.Longitude, Latitude: p.Latitude})
	}
	return poly
}

// ---------------------------------------------------------------------------
// Enum converters
// ---------------------------------------------------------------------------

func domainFieldTypeToProto(ft domain.FieldType) pb.FieldType {
	switch ft {
	case domain.FieldTypeCropland:
		return pb.FieldType_FIELD_TYPE_CROPLAND
	case domain.FieldTypePasture:
		return pb.FieldType_FIELD_TYPE_PASTURE
	case domain.FieldTypeOrchard:
		return pb.FieldType_FIELD_TYPE_ORCHARD
	case domain.FieldTypeVineyard:
		return pb.FieldType_FIELD_TYPE_VINEYARD
	case domain.FieldTypeGreenhouse:
		return pb.FieldType_FIELD_TYPE_GREENHOUSE
	case domain.FieldTypeNursery:
		return pb.FieldType_FIELD_TYPE_NURSERY
	case domain.FieldTypeAgroforest:
		return pb.FieldType_FIELD_TYPE_AGROFOREST
	default:
		return pb.FieldType_FIELD_TYPE_UNSPECIFIED
	}
}

func domainSoilTypeToProto(st domain.SoilType) pb.SoilType {
	switch st {
	case domain.SoilTypeClay:
		return pb.SoilType_SOIL_TYPE_CLAY
	case domain.SoilTypeSandy:
		return pb.SoilType_SOIL_TYPE_SANDY
	case domain.SoilTypeLoamy:
		return pb.SoilType_SOIL_TYPE_LOAMY
	case domain.SoilTypeSilt:
		return pb.SoilType_SOIL_TYPE_SILT
	case domain.SoilTypePeat:
		return pb.SoilType_SOIL_TYPE_PEAT
	case domain.SoilTypeChalk:
		return pb.SoilType_SOIL_TYPE_CHALK
	case domain.SoilTypeClayLoam:
		return pb.SoilType_SOIL_TYPE_CLAY_LOAM
	case domain.SoilTypeSandyLoam:
		return pb.SoilType_SOIL_TYPE_SANDY_LOAM
	default:
		return pb.SoilType_SOIL_TYPE_UNSPECIFIED
	}
}

func domainFieldStatusToProto(s domain.FieldStatus) pb.FieldStatus {
	switch s {
	case domain.FieldStatusActive:
		return pb.FieldStatus_FIELD_STATUS_ACTIVE
	case domain.FieldStatusFallow:
		return pb.FieldStatus_FIELD_STATUS_FALLOW
	case domain.FieldStatusPreparation:
		return pb.FieldStatus_FIELD_STATUS_PREPARATION
	case domain.FieldStatusPlanted:
		return pb.FieldStatus_FIELD_STATUS_PLANTED
	case domain.FieldStatusHarvesting:
		return pb.FieldStatus_FIELD_STATUS_HARVESTING
	case domain.FieldStatusRetired:
		return pb.FieldStatus_FIELD_STATUS_RETIRED
	default:
		return pb.FieldStatus_FIELD_STATUS_UNSPECIFIED
	}
}

func domainIrrigationTypeToProto(it domain.IrrigationType) pb.IrrigationType {
	switch it {
	case domain.IrrigationTypeRainfed:
		return pb.IrrigationType_IRRIGATION_TYPE_RAINFED
	case domain.IrrigationTypeDrip:
		return pb.IrrigationType_IRRIGATION_TYPE_DRIP
	case domain.IrrigationTypeSprinkler:
		return pb.IrrigationType_IRRIGATION_TYPE_SPRINKLER
	case domain.IrrigationTypeFlood:
		return pb.IrrigationType_IRRIGATION_TYPE_FLOOD
	case domain.IrrigationTypeCenterPivot:
		return pb.IrrigationType_IRRIGATION_TYPE_CENTER_PIVOT
	case domain.IrrigationTypeFurrow:
		return pb.IrrigationType_IRRIGATION_TYPE_FURROW
	case domain.IrrigationTypeSubsurface:
		return pb.IrrigationType_IRRIGATION_TYPE_SUBSURFACE
	default:
		return pb.IrrigationType_IRRIGATION_TYPE_UNSPECIFIED
	}
}

func domainGrowthStageToProto(gs domain.GrowthStage) pb.GrowthStage {
	switch gs {
	case domain.GrowthStageGermination:
		return pb.GrowthStage_GROWTH_STAGE_GERMINATION
	case domain.GrowthStageSeedling:
		return pb.GrowthStage_GROWTH_STAGE_SEEDLING
	case domain.GrowthStageVegetative:
		return pb.GrowthStage_GROWTH_STAGE_VEGETATIVE
	case domain.GrowthStageBudding:
		return pb.GrowthStage_GROWTH_STAGE_BUDDING
	case domain.GrowthStageFlowering:
		return pb.GrowthStage_GROWTH_STAGE_FLOWERING
	case domain.GrowthStageFruitSet:
		return pb.GrowthStage_GROWTH_STAGE_FRUIT_SET
	case domain.GrowthStageRipening:
		return pb.GrowthStage_GROWTH_STAGE_RIPENING
	case domain.GrowthStageMaturity:
		return pb.GrowthStage_GROWTH_STAGE_MATURITY
	case domain.GrowthStageSenescence:
		return pb.GrowthStage_GROWTH_STAGE_SENESCENCE
	default:
		return pb.GrowthStage_GROWTH_STAGE_UNSPECIFIED
	}
}

func domainAspectDirectionToProto(ad domain.AspectDirection) pb.AspectDirection {
	switch ad {
	case domain.AspectDirectionNorth:
		return pb.AspectDirection_ASPECT_DIRECTION_NORTH
	case domain.AspectDirectionNortheast:
		return pb.AspectDirection_ASPECT_DIRECTION_NORTHEAST
	case domain.AspectDirectionEast:
		return pb.AspectDirection_ASPECT_DIRECTION_EAST
	case domain.AspectDirectionSoutheast:
		return pb.AspectDirection_ASPECT_DIRECTION_SOUTHEAST
	case domain.AspectDirectionSouth:
		return pb.AspectDirection_ASPECT_DIRECTION_SOUTH
	case domain.AspectDirectionSouthwest:
		return pb.AspectDirection_ASPECT_DIRECTION_SOUTHWEST
	case domain.AspectDirectionWest:
		return pb.AspectDirection_ASPECT_DIRECTION_WEST
	case domain.AspectDirectionNorthwest:
		return pb.AspectDirection_ASPECT_DIRECTION_NORTHWEST
	case domain.AspectDirectionFlat:
		return pb.AspectDirection_ASPECT_DIRECTION_FLAT
	default:
		return pb.AspectDirection_ASPECT_DIRECTION_UNSPECIFIED
	}
}

func protoFieldTypeToDomain(ft pb.FieldType) domain.FieldType {
	switch ft {
	case pb.FieldType_FIELD_TYPE_CROPLAND:
		return domain.FieldTypeCropland
	case pb.FieldType_FIELD_TYPE_PASTURE:
		return domain.FieldTypePasture
	case pb.FieldType_FIELD_TYPE_ORCHARD:
		return domain.FieldTypeOrchard
	case pb.FieldType_FIELD_TYPE_VINEYARD:
		return domain.FieldTypeVineyard
	case pb.FieldType_FIELD_TYPE_GREENHOUSE:
		return domain.FieldTypeGreenhouse
	case pb.FieldType_FIELD_TYPE_NURSERY:
		return domain.FieldTypeNursery
	case pb.FieldType_FIELD_TYPE_AGROFOREST:
		return domain.FieldTypeAgroforest
	default:
		return domain.FieldTypeUnspecified
	}
}

func protoSoilTypeToDomain(st pb.SoilType) domain.SoilType {
	switch st {
	case pb.SoilType_SOIL_TYPE_CLAY:
		return domain.SoilTypeClay
	case pb.SoilType_SOIL_TYPE_SANDY:
		return domain.SoilTypeSandy
	case pb.SoilType_SOIL_TYPE_LOAMY:
		return domain.SoilTypeLoamy
	case pb.SoilType_SOIL_TYPE_SILT:
		return domain.SoilTypeSilt
	case pb.SoilType_SOIL_TYPE_PEAT:
		return domain.SoilTypePeat
	case pb.SoilType_SOIL_TYPE_CHALK:
		return domain.SoilTypeChalk
	case pb.SoilType_SOIL_TYPE_CLAY_LOAM:
		return domain.SoilTypeClayLoam
	case pb.SoilType_SOIL_TYPE_SANDY_LOAM:
		return domain.SoilTypeSandyLoam
	default:
		return domain.SoilTypeUnspecified
	}
}

func protoFieldStatusToDomain(s pb.FieldStatus) domain.FieldStatus {
	switch s {
	case pb.FieldStatus_FIELD_STATUS_ACTIVE:
		return domain.FieldStatusActive
	case pb.FieldStatus_FIELD_STATUS_FALLOW:
		return domain.FieldStatusFallow
	case pb.FieldStatus_FIELD_STATUS_PREPARATION:
		return domain.FieldStatusPreparation
	case pb.FieldStatus_FIELD_STATUS_PLANTED:
		return domain.FieldStatusPlanted
	case pb.FieldStatus_FIELD_STATUS_HARVESTING:
		return domain.FieldStatusHarvesting
	case pb.FieldStatus_FIELD_STATUS_RETIRED:
		return domain.FieldStatusRetired
	default:
		return domain.FieldStatusUnspecified
	}
}

// ---------------------------------------------------------------------------
// Crop Cycle converters
// ---------------------------------------------------------------------------

func cropCycleToProto(c *domain.CropCycle) *pb.CropCycle {
	if c == nil {
		return nil
	}
	out := &pb.CropCycle{
		Id:              c.ID,
		TenantId:        c.TenantID,
		FieldId:         c.FieldID,
		CropId:          c.CropID,
		Season:          c.Season,
		CycleYear:       c.CycleYear,
		Status:          domainCropCycleStatusToProto(c.Status),
		TotalInputCost:  c.TotalInputCost,
		TotalRevenue:    c.TotalRevenue,
		Currency:        c.Currency,
		Version:         c.Version,
		CreatedBy:       c.CreatedBy,
	}
	if c.CropAssignmentID != nil {
		out.CropAssignmentId = *c.CropAssignmentID
	}
	if c.ManagementUnitID != nil {
		out.ManagementUnitId = *c.ManagementUnitID
	}
	if c.Name != nil {
		out.Name = *c.Name
	}
	if c.PlannedPlantingDate != nil {
		out.PlannedPlantingDate = timestamppb.New(*c.PlannedPlantingDate)
	}
	if c.ActualPlantingDate != nil {
		out.ActualPlantingDate = timestamppb.New(*c.ActualPlantingDate)
	}
	if c.PlannedHarvestDate != nil {
		out.PlannedHarvestDate = timestamppb.New(*c.PlannedHarvestDate)
	}
	if c.ActualHarvestDate != nil {
		out.ActualHarvestDate = timestamppb.New(*c.ActualHarvestDate)
	}
	if c.TargetYieldPerHectare != nil {
		out.TargetYieldPerHectare = *c.TargetYieldPerHectare
	}
	if c.ActualYieldPerHectare != nil {
		out.ActualYieldPerHectare = *c.ActualYieldPerHectare
	}
	if c.YieldUnit != nil {
		out.YieldUnit = *c.YieldUnit
	}
	if c.Notes != nil {
		out.Notes = *c.Notes
	}
	if !c.CreatedAt.IsZero() {
		out.CreatedAt = timestamppb.New(c.CreatedAt)
	}
	if !c.UpdatedAt.IsZero() {
		out.UpdatedAt = timestamppb.New(c.UpdatedAt)
	}
	return out
}

func domainCropCycleStatusToProto(s domain.CropCycleStatus) pb.CropCycleStatus {
	switch s {
	case domain.CropCycleStatusPlanned:
		return pb.CropCycleStatus_CYCLE_STATUS_PLANNED
	case domain.CropCycleStatusActive:
		return pb.CropCycleStatus_CYCLE_STATUS_ACTIVE
	case domain.CropCycleStatusHarvesting:
		return pb.CropCycleStatus_CYCLE_STATUS_HARVESTING
	case domain.CropCycleStatusCompleted:
		return pb.CropCycleStatus_CYCLE_STATUS_COMPLETED
	case domain.CropCycleStatusAbandoned:
		return pb.CropCycleStatus_CYCLE_STATUS_ABANDONED
	default:
		return pb.CropCycleStatus_CYCLE_STATUS_UNSPECIFIED
	}
}

func protoCropCycleStatusToDomain(s pb.CropCycleStatus) domain.CropCycleStatus {
	switch s {
	case pb.CropCycleStatus_CYCLE_STATUS_PLANNED:
		return domain.CropCycleStatusPlanned
	case pb.CropCycleStatus_CYCLE_STATUS_ACTIVE:
		return domain.CropCycleStatusActive
	case pb.CropCycleStatus_CYCLE_STATUS_HARVESTING:
		return domain.CropCycleStatusHarvesting
	case pb.CropCycleStatus_CYCLE_STATUS_COMPLETED:
		return domain.CropCycleStatusCompleted
	case pb.CropCycleStatus_CYCLE_STATUS_ABANDONED:
		return domain.CropCycleStatusAbandoned
	default:
		return domain.CropCycleStatusUnspecified
	}
}

// ---------------------------------------------------------------------------
// Activity Event converters
// ---------------------------------------------------------------------------

func activityEventToProto(e *domain.ActivityEvent) *pb.ActivityEvent {
	if e == nil {
		return nil
	}
	out := &pb.ActivityEvent{
		Id:           e.ID,
		TenantId:     e.TenantID,
		FieldId:      e.FieldID,
		PerformedBy:  e.PerformedBy,
		ActivityType: e.ActivityType,
		Category:     domainActivityCategoryToProto(e.Category),
		StartedAt:    timestamppb.New(e.StartedAt),
		InputCost:    e.InputCost,
		Currency:     e.Currency,
	}
	if e.CropCycleID != nil {
		out.CropCycleId = *e.CropCycleID
	}
	if e.CompletedAt != nil {
		out.CompletedAt = timestamppb.New(*e.CompletedAt)
	}
	if e.DurationMinutes != nil {
		out.DurationMinutes = *e.DurationMinutes
	}
	if e.Description != nil {
		out.Description = *e.Description
	}
	if e.Notes != nil {
		out.Notes = *e.Notes
	}
	if e.InputProductID != nil {
		out.InputProductId = *e.InputProductID
	}
	if e.InputQuantity != nil {
		out.InputQuantity = *e.InputQuantity
	}
	if e.InputUnit != nil {
		out.InputUnit = *e.InputUnit
	}
	if e.AreaHectares != nil {
		out.AreaHectares = *e.AreaHectares
	}
	if e.WeatherTempC != nil {
		out.WeatherTempCelsius = *e.WeatherTempC
	}
	if e.WeatherHumidity != nil {
		out.WeatherHumidityPct = *e.WeatherHumidity
	}
	if e.WeatherWindSpeed != nil {
		out.WeatherWindSpeedKmh = *e.WeatherWindSpeed
	}
	if e.WeatherConditions != nil {
		out.WeatherConditions = *e.WeatherConditions
	}
	if !e.CreatedAt.IsZero() {
		out.CreatedAt = timestamppb.New(e.CreatedAt)
	}
	return out
}

func domainActivityCategoryToProto(c domain.ActivityCategory) pb.ActivityCategory {
	switch c {
	case domain.ActivityCategoryLandPrep:
		return pb.ActivityCategory_CATEGORY_LAND_PREP
	case domain.ActivityCategoryPlanting:
		return pb.ActivityCategory_CATEGORY_PLANTING
	case domain.ActivityCategoryIrrigation:
		return pb.ActivityCategory_CATEGORY_IRRIGATION
	case domain.ActivityCategoryFertilization:
		return pb.ActivityCategory_CATEGORY_FERTILIZATION
	case domain.ActivityCategoryPestControl:
		return pb.ActivityCategory_CATEGORY_PEST_CONTROL
	case domain.ActivityCategoryScouting:
		return pb.ActivityCategory_CATEGORY_SCOUTING
	case domain.ActivityCategoryHarvesting:
		return pb.ActivityCategory_CATEGORY_HARVESTING
	case domain.ActivityCategoryPostHarvest:
		return pb.ActivityCategory_CATEGORY_POST_HARVEST
	case domain.ActivityCategorySoilSampling:
		return pb.ActivityCategory_CATEGORY_SOIL_SAMPLING
	case domain.ActivityCategoryMaintenance:
		return pb.ActivityCategory_CATEGORY_MAINTENANCE
	default:
		return pb.ActivityCategory_CATEGORY_UNSPECIFIED
	}
}

func protoActivityCategoryToDomain(c pb.ActivityCategory) domain.ActivityCategory {
	switch c {
	case pb.ActivityCategory_CATEGORY_LAND_PREP:
		return domain.ActivityCategoryLandPrep
	case pb.ActivityCategory_CATEGORY_PLANTING:
		return domain.ActivityCategoryPlanting
	case pb.ActivityCategory_CATEGORY_IRRIGATION:
		return domain.ActivityCategoryIrrigation
	case pb.ActivityCategory_CATEGORY_FERTILIZATION:
		return domain.ActivityCategoryFertilization
	case pb.ActivityCategory_CATEGORY_PEST_CONTROL:
		return domain.ActivityCategoryPestControl
	case pb.ActivityCategory_CATEGORY_SCOUTING:
		return domain.ActivityCategoryScouting
	case pb.ActivityCategory_CATEGORY_HARVESTING:
		return domain.ActivityCategoryHarvesting
	case pb.ActivityCategory_CATEGORY_POST_HARVEST:
		return domain.ActivityCategoryPostHarvest
	case pb.ActivityCategory_CATEGORY_SOIL_SAMPLING:
		return domain.ActivityCategorySoilSampling
	case pb.ActivityCategory_CATEGORY_MAINTENANCE:
		return domain.ActivityCategoryMaintenance
	default:
		return domain.ActivityCategoryUnspecified
	}
}

// ---------------------------------------------------------------------------
// Activity Evidence converters
// ---------------------------------------------------------------------------

func activityEvidenceToProto(e *domain.ActivityEvidence) *pb.ActivityEvidence {
	if e == nil {
		return nil
	}
	out := &pb.ActivityEvidence{
		Id:              e.ID,
		TenantId:        e.TenantID,
		ActivityEventId: e.ActivityEventID,
		EvidenceType:    domainEvidenceTypeToProto(e.EvidenceType),
		FileUrl:         e.FileURL,
		CapturedBy:      e.CapturedBy,
	}
	if e.FileName != nil {
		out.FileName = *e.FileName
	}
	if e.FileSizeBytes != nil {
		out.FileSizeBytes = *e.FileSizeBytes
	}
	if e.MimeType != nil {
		out.MimeType = *e.MimeType
	}
	if e.ThumbnailURL != nil {
		out.ThumbnailUrl = *e.ThumbnailURL
	}
	if e.Caption != nil {
		out.Caption = *e.Caption
	}
	if e.Latitude != nil {
		out.Latitude = *e.Latitude
	}
	if e.Longitude != nil {
		out.Longitude = *e.Longitude
	}
	if e.CapturedAt != nil {
		out.CapturedAt = timestamppb.New(*e.CapturedAt)
	}
	if !e.CreatedAt.IsZero() {
		out.CreatedAt = timestamppb.New(e.CreatedAt)
	}
	return out
}

func domainEvidenceTypeToProto(et domain.EvidenceType) pb.EvidenceType {
	switch et {
	case domain.EvidenceTypePhoto:
		return pb.EvidenceType_EVIDENCE_TYPE_PHOTO
	case domain.EvidenceTypeDocument:
		return pb.EvidenceType_EVIDENCE_TYPE_DOCUMENT
	case domain.EvidenceTypeVideo:
		return pb.EvidenceType_EVIDENCE_TYPE_VIDEO
	case domain.EvidenceTypeAudio:
		return pb.EvidenceType_EVIDENCE_TYPE_AUDIO
	case domain.EvidenceTypeOther:
		return pb.EvidenceType_EVIDENCE_TYPE_OTHER
	default:
		return pb.EvidenceType_EVIDENCE_TYPE_UNSPECIFIED
	}
}

func protoEvidenceTypeToDomain(et pb.EvidenceType) domain.EvidenceType {
	switch et {
	case pb.EvidenceType_EVIDENCE_TYPE_PHOTO:
		return domain.EvidenceTypePhoto
	case pb.EvidenceType_EVIDENCE_TYPE_DOCUMENT:
		return domain.EvidenceTypeDocument
	case pb.EvidenceType_EVIDENCE_TYPE_VIDEO:
		return domain.EvidenceTypeVideo
	case pb.EvidenceType_EVIDENCE_TYPE_AUDIO:
		return domain.EvidenceTypeAudio
	case pb.EvidenceType_EVIDENCE_TYPE_OTHER:
		return domain.EvidenceTypeOther
	default:
		return domain.EvidenceTypeOther
	}
}
