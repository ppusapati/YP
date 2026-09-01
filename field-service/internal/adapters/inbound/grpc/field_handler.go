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
	field.UUID = req.Msg.GetId()
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
// Proto ↔ Domain converters
// ---------------------------------------------------------------------------

func fieldToProto(f *domain.Field) *pb.Field {
	out := &pb.Field{
		Id:              f.UUID,
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
