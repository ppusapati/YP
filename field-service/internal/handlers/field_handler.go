package handlers

import (
	"context"

	pb "p9e.in/samavaya/agriculture/field-service/api/v1"
	"p9e.in/samavaya/agriculture/field-service/internal/mappers"
	"p9e.in/samavaya/agriculture/field-service/internal/models"
	"p9e.in/samavaya/agriculture/field-service/internal/services"
	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"
)

// FieldHandler implements the gRPC FieldServiceServer interface.
type FieldHandler struct {
	pb.UnimplementedFieldServiceServer

	service services.FieldService
	deps    deps.ServiceDeps
	logger  *p9log.Helper
}

// NewFieldHandler creates a new FieldHandler.
func NewFieldHandler(d deps.ServiceDeps, svc services.FieldService) *FieldHandler {
	return &FieldHandler{
		service: svc,
		deps:    d,
		logger:  p9log.NewHelper(p9log.With(d.Log, "component", "field_handler")),
	}
}

// CreateField handles the CreateField RPC.
func (h *FieldHandler) CreateField(ctx context.Context, req *pb.CreateFieldRequest) (*pb.CreateFieldResponse, error) {
	if req == nil {
		return nil, errors.BadRequest("INVALID_REQUEST", "request must not be nil")
	}
	if req.GetFarmId() == "" {
		return nil, errors.BadRequest("MISSING_FARM_ID", "farm_id is required")
	}
	if req.GetName() == "" {
		return nil, errors.BadRequest("MISSING_NAME", "name is required")
	}

	input := mappers.ProtoToCreateFieldInput(req)

	field, err := h.service.CreateField(ctx, input)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.CreateFieldResponse{
		Field: mappers.FieldToProto(field),
	}, nil
}

// GetField handles the GetField RPC.
func (h *FieldHandler) GetField(ctx context.Context, req *pb.GetFieldRequest) (*pb.GetFieldResponse, error) {
	if req == nil {
		return nil, errors.BadRequest("INVALID_REQUEST", "request must not be nil")
	}
	if req.GetId() == "" {
		return nil, errors.BadRequest("MISSING_ID", "id is required")
	}

	field, err := h.service.GetField(ctx, req.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetFieldResponse{
		Field: mappers.FieldToProto(field),
	}, nil
}

// ListFields handles the ListFields RPC.
func (h *FieldHandler) ListFields(ctx context.Context, req *pb.ListFieldsRequest) (*pb.ListFieldsResponse, error) {
	if req == nil {
		return nil, errors.BadRequest("INVALID_REQUEST", "request must not be nil")
	}

	input := models.ListFieldsInput{
		PageSize:   req.GetPageSize(),
		PageOffset: req.GetPageOffset(),
	}
	if req.GetFarmId() != "" {
		fid := req.GetFarmId()
		input.FarmID = &fid
	}
	if req.GetStatus() != pb.FieldStatus_FIELD_STATUS_UNSPECIFIED {
		s := req.GetStatus().String()
		input.Status = &s
	}
	if req.GetFieldType() != pb.FieldType_FIELD_TYPE_UNSPECIFIED {
		ft := req.GetFieldType().String()
		input.FieldType = &ft
	}
	if req.GetSearch() != "" {
		search := req.GetSearch()
		input.Search = &search
	}

	// Map proto enum values to domain strings for filtering.
	if req.GetStatus() != pb.FieldStatus_FIELD_STATUS_UNSPECIFIED {
		s := protoStatusToString(req.GetStatus())
		input.Status = &s
	}
	if req.GetFieldType() != pb.FieldType_FIELD_TYPE_UNSPECIFIED {
		ft := protoFieldTypeToString(req.GetFieldType())
		input.FieldType = &ft
	}

	fields, total, err := h.service.ListFields(ctx, input)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.ListFieldsResponse{
		Fields:     mappers.FieldsToProto(fields),
		TotalCount: int32(total),
	}, nil
}

// UpdateField handles the UpdateField RPC.
func (h *FieldHandler) UpdateField(ctx context.Context, req *pb.UpdateFieldRequest) (*pb.UpdateFieldResponse, error) {
	if req == nil {
		return nil, errors.BadRequest("INVALID_REQUEST", "request must not be nil")
	}
	if req.GetId() == "" {
		return nil, errors.BadRequest("MISSING_ID", "id is required")
	}

	input := mappers.ProtoToUpdateFieldInput(req)

	field, err := h.service.UpdateField(ctx, input)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.UpdateFieldResponse{
		Field: mappers.FieldToProto(field),
	}, nil
}

// DeleteField handles the DeleteField RPC.
func (h *FieldHandler) DeleteField(ctx context.Context, req *pb.DeleteFieldRequest) (*pb.DeleteFieldResponse, error) {
	if req == nil {
		return nil, errors.BadRequest("INVALID_REQUEST", "request must not be nil")
	}
	if req.GetId() == "" {
		return nil, errors.BadRequest("MISSING_ID", "id is required")
	}

	err := h.service.DeleteField(ctx, req.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.DeleteFieldResponse{}, nil
}

// SetFieldBoundary handles the SetFieldBoundary RPC.
func (h *FieldHandler) SetFieldBoundary(ctx context.Context, req *pb.SetFieldBoundaryRequest) (*pb.SetFieldBoundaryResponse, error) {
	if req == nil {
		return nil, errors.BadRequest("INVALID_REQUEST", "request must not be nil")
	}
	if req.GetFieldId() == "" {
		return nil, errors.BadRequest("MISSING_FIELD_ID", "field_id is required")
	}
	if req.GetPolygon() == nil || len(req.GetPolygon().GetPoints()) < 3 {
		return nil, errors.BadRequest("INVALID_POLYGON", "polygon must have at least 3 points")
	}

	input := mappers.ProtoToSetBoundaryInput(req)

	boundary, err := h.service.SetFieldBoundary(ctx, input)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.SetFieldBoundaryResponse{
		Boundary: mappers.FieldBoundaryToProto(boundary),
	}, nil
}

// AssignCrop handles the AssignCrop RPC.
func (h *FieldHandler) AssignCrop(ctx context.Context, req *pb.AssignCropRequest) (*pb.AssignCropResponse, error) {
	if req == nil {
		return nil, errors.BadRequest("INVALID_REQUEST", "request must not be nil")
	}
	if req.GetFieldId() == "" {
		return nil, errors.BadRequest("MISSING_FIELD_ID", "field_id is required")
	}
	if req.GetCropId() == "" {
		return nil, errors.BadRequest("MISSING_CROP_ID", "crop_id is required")
	}

	input := mappers.ProtoToAssignCropInput(req)

	assignment, err := h.service.AssignCrop(ctx, input)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.AssignCropResponse{
		Assignment: mappers.CropAssignmentToProto(assignment),
	}, nil
}

// ListFieldsByFarm handles the ListFieldsByFarm RPC.
func (h *FieldHandler) ListFieldsByFarm(ctx context.Context, req *pb.ListFieldsByFarmRequest) (*pb.ListFieldsByFarmResponse, error) {
	if req == nil {
		return nil, errors.BadRequest("INVALID_REQUEST", "request must not be nil")
	}
	if req.GetFarmId() == "" {
		return nil, errors.BadRequest("MISSING_FARM_ID", "farm_id is required")
	}

	fields, total, err := h.service.ListFieldsByFarm(ctx, req.GetFarmId(), req.GetPageSize(), req.GetPageOffset())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.ListFieldsByFarmResponse{
		Fields:     mappers.FieldsToProto(fields),
		TotalCount: int32(total),
	}, nil
}

// SegmentField handles the SegmentField RPC.
func (h *FieldHandler) SegmentField(ctx context.Context, req *pb.SegmentFieldRequest) (*pb.SegmentFieldResponse, error) {
	if req == nil {
		return nil, errors.BadRequest("INVALID_REQUEST", "request must not be nil")
	}
	if req.GetFieldId() == "" {
		return nil, errors.BadRequest("MISSING_FIELD_ID", "field_id is required")
	}
	if len(req.GetSegments()) == 0 {
		return nil, errors.BadRequest("MISSING_SEGMENTS", "at least one segment is required")
	}

	inputs := mappers.ProtoToSegmentInputs(req.GetSegments())

	segments, err := h.service.SegmentField(ctx, req.GetFieldId(), inputs)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.SegmentFieldResponse{
		Segments: mappers.FieldSegmentsToProto(segments),
	}, nil
}

// GetFieldSegments handles the GetFieldSegments RPC.
func (h *FieldHandler) GetFieldSegments(ctx context.Context, req *pb.GetFieldSegmentsRequest) (*pb.GetFieldSegmentsResponse, error) {
	if req == nil {
		return nil, errors.BadRequest("INVALID_REQUEST", "request must not be nil")
	}
	if req.GetFieldId() == "" {
		return nil, errors.BadRequest("MISSING_FIELD_ID", "field_id is required")
	}

	segments, err := h.service.GetFieldSegments(ctx, req.GetFieldId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetFieldSegmentsResponse{
		Segments: mappers.FieldSegmentsToProto(segments),
	}, nil
}

// GetCropHistory handles the GetCropHistory RPC.
func (h *FieldHandler) GetCropHistory(ctx context.Context, req *pb.GetCropHistoryRequest) (*pb.GetCropHistoryResponse, error) {
	if req == nil {
		return nil, errors.BadRequest("INVALID_REQUEST", "request must not be nil")
	}
	if req.GetFieldId() == "" {
		return nil, errors.BadRequest("MISSING_FIELD_ID", "field_id is required")
	}

	assignments, total, err := h.service.GetCropHistory(ctx, req.GetFieldId(), req.GetPageSize(), req.GetPageOffset())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetCropHistoryResponse{
		Assignments: mappers.CropAssignmentsToProto(assignments),
		TotalCount:  int32(total),
	}, nil
}

// ---------------------------------------------------------------------------
// Helper enum mappers for handler-level filtering
// ---------------------------------------------------------------------------

func protoStatusToString(s pb.FieldStatus) string {
	switch s {
	case pb.FieldStatus_FIELD_STATUS_ACTIVE:
		return string(models.FieldStatusActive)
	case pb.FieldStatus_FIELD_STATUS_FALLOW:
		return string(models.FieldStatusFallow)
	case pb.FieldStatus_FIELD_STATUS_PREPARATION:
		return string(models.FieldStatusPreparation)
	case pb.FieldStatus_FIELD_STATUS_PLANTED:
		return string(models.FieldStatusPlanted)
	case pb.FieldStatus_FIELD_STATUS_HARVESTING:
		return string(models.FieldStatusHarvesting)
	case pb.FieldStatus_FIELD_STATUS_RETIRED:
		return string(models.FieldStatusRetired)
	default:
		return ""
	}
}

func protoFieldTypeToString(t pb.FieldType) string {
	switch t {
	case pb.FieldType_FIELD_TYPE_CROPLAND:
		return string(models.FieldTypeCropland)
	case pb.FieldType_FIELD_TYPE_PASTURE:
		return string(models.FieldTypePasture)
	case pb.FieldType_FIELD_TYPE_ORCHARD:
		return string(models.FieldTypeOrchard)
	case pb.FieldType_FIELD_TYPE_VINEYARD:
		return string(models.FieldTypeVineyard)
	case pb.FieldType_FIELD_TYPE_GREENHOUSE:
		return string(models.FieldTypeGreenhouse)
	case pb.FieldType_FIELD_TYPE_NURSERY:
		return string(models.FieldTypeNursery)
	case pb.FieldType_FIELD_TYPE_AGROFOREST:
		return string(models.FieldTypeAgroforest)
	default:
		return ""
	}
}
