package mappers

import (
	"encoding/json"
	"fmt"
	"time"

	pb "p9e.in/samavaya/agriculture/field-service/api/v1"
	"p9e.in/samavaya/agriculture/field-service/internal/models"

	"google.golang.org/protobuf/types/known/timestamppb"
)

// FieldToProto converts a domain Field to its protobuf representation.
func FieldToProto(f *models.Field) *pb.Field {
	if f == nil {
		return nil
	}

	out := &pb.Field{
		Id:               f.ID,
		TenantId:         f.TenantID,
		FarmId:           f.FarmID,
		Name:             f.Name,
		AreaHectares:     f.AreaHectares,
		GrowthStage:      growthStageToProto(f.GrowthStage),
		SoilType:         soilTypeToProto(f.SoilType),
		IrrigationType:   irrigationTypeToProto(f.IrrigationType),
		FieldType:        fieldTypeToProto(f.FieldType),
		Status:           fieldStatusToProto(f.Status),
		ElevationMeters:  f.ElevationMeters,
		SlopeDegrees:     f.SlopeDegrees,
		AspectDirection:  aspectDirectionToProto(f.AspectDirection),
		CreatedBy:        f.CreatedBy,
		UpdatedBy:        f.UpdatedBy,
		CreatedAt:        timestamppb.New(f.CreatedAt),
		UpdatedAt:        timestamppb.New(f.UpdatedAt),
		Version:          f.Version,
	}

	if f.CurrentCropID != nil {
		out.CurrentCropId = *f.CurrentCropID
	}

	if f.PlantingDate != nil {
		out.PlantingDate = timestamppb.New(*f.PlantingDate)
	}

	if f.ExpectedHarvestDate != nil {
		out.ExpectedHarvestDate = timestamppb.New(*f.ExpectedHarvestDate)
	}

	if f.Boundary != nil {
		out.Boundary = geoPolygonToProto(f.Boundary)
	} else if f.BoundaryGeoJSON != nil {
		poly, err := geoJSONToGeoPolygon(*f.BoundaryGeoJSON)
		if err == nil && poly != nil {
			out.Boundary = geoPolygonToProto(poly)
		}
	}

	return out
}

// FieldsToProto converts a slice of domain Fields to protobuf representations.
func FieldsToProto(fields []models.Field) []*pb.Field {
	result := make([]*pb.Field, 0, len(fields))
	for i := range fields {
		result = append(result, FieldToProto(&fields[i]))
	}
	return result
}

// FieldBoundaryToProto converts a domain FieldBoundary to its protobuf representation.
func FieldBoundaryToProto(b *models.FieldBoundary) *pb.FieldBoundary {
	if b == nil {
		return nil
	}

	out := &pb.FieldBoundary{
		Id:              b.ID,
		FieldId:         b.FieldID,
		AreaHectares:    b.AreaHectares,
		PerimeterMeters: b.PerimeterMeters,
		Source:          b.Source,
		RecordedAt:      timestamppb.New(b.RecordedAt),
		CreatedAt:       timestamppb.New(b.CreatedAt),
	}

	if b.Polygon != nil {
		out.Polygon = geoPolygonToProto(b.Polygon)
	} else if b.PolygonGeoJSON != nil {
		poly, err := geoJSONToGeoPolygon(*b.PolygonGeoJSON)
		if err == nil && poly != nil {
			out.Polygon = geoPolygonToProto(poly)
		}
	}

	return out
}

// CropAssignmentToProto converts a domain FieldCropAssignment to protobuf.
func CropAssignmentToProto(a *models.FieldCropAssignment) *pb.FieldCropAssignment {
	if a == nil {
		return nil
	}

	out := &pb.FieldCropAssignment{
		Id:           a.ID,
		FieldId:      a.FieldID,
		CropId:       a.CropID,
		CropVariety:  a.CropVariety,
		PlantingDate: timestamppb.New(a.PlantingDate),
		GrowthStage:  growthStageToProto(a.GrowthStage),
		YieldPerHectare: a.YieldPerHectare,
		Notes:        a.Notes,
		Season:       a.Season,
		CreatedAt:    timestamppb.New(a.CreatedAt),
		UpdatedAt:    timestamppb.New(a.UpdatedAt),
	}

	if a.ExpectedHarvestDate != nil {
		out.ExpectedHarvestDate = timestamppb.New(*a.ExpectedHarvestDate)
	}
	if a.ActualHarvestDate != nil {
		out.ActualHarvestDate = timestamppb.New(*a.ActualHarvestDate)
	}

	return out
}

// CropAssignmentsToProto converts a slice of crop assignments.
func CropAssignmentsToProto(assignments []models.FieldCropAssignment) []*pb.FieldCropAssignment {
	result := make([]*pb.FieldCropAssignment, 0, len(assignments))
	for i := range assignments {
		result = append(result, CropAssignmentToProto(&assignments[i]))
	}
	return result
}

// FieldSegmentToProto converts a domain FieldSegment to protobuf.
func FieldSegmentToProto(s *models.FieldSegment) *pb.FieldSegment {
	if s == nil {
		return nil
	}

	out := &pb.FieldSegment{
		Id:            s.ID,
		FieldId:       s.FieldID,
		Name:          s.Name,
		AreaHectares:  s.AreaHectares,
		SoilType:      soilTypeToProto(s.SoilType),
		Notes:         s.Notes,
		SegmentIndex:  s.SegmentIndex,
		CreatedAt:     timestamppb.New(s.CreatedAt),
		UpdatedAt:     timestamppb.New(s.UpdatedAt),
	}

	if s.CurrentCropID != nil {
		out.CurrentCropId = *s.CurrentCropID
	}

	if s.Boundary != nil {
		out.Boundary = geoPolygonToProto(s.Boundary)
	} else if s.BoundaryGeoJSON != nil {
		poly, err := geoJSONToGeoPolygon(*s.BoundaryGeoJSON)
		if err == nil && poly != nil {
			out.Boundary = geoPolygonToProto(poly)
		}
	}

	return out
}

// FieldSegmentsToProto converts a slice of segments to protobuf.
func FieldSegmentsToProto(segments []models.FieldSegment) []*pb.FieldSegment {
	result := make([]*pb.FieldSegment, 0, len(segments))
	for i := range segments {
		result = append(result, FieldSegmentToProto(&segments[i]))
	}
	return result
}

// ProtoToCreateFieldInput converts a protobuf CreateFieldRequest to domain input.
func ProtoToCreateFieldInput(req *pb.CreateFieldRequest) models.CreateFieldInput {
	input := models.CreateFieldInput{
		FarmID:          req.GetFarmId(),
		Name:            req.GetName(),
		AreaHectares:    req.GetAreaHectares(),
		FieldType:       fieldTypeFromProto(req.GetFieldType()),
		SoilType:        soilTypeFromProto(req.GetSoilType()),
		IrrigationType:  irrigationTypeFromProto(req.GetIrrigationType()),
		ElevationMeters: req.GetElevationMeters(),
		SlopeDegrees:    req.GetSlopeDegrees(),
		AspectDirection: aspectDirectionFromProto(req.GetAspectDirection()),
	}

	if req.GetBoundary() != nil {
		gj := geoPolygonToGeoJSON(protoToGeoPolygon(req.GetBoundary()))
		input.BoundaryGeoJSON = &gj
	}

	return input
}

// ProtoToUpdateFieldInput converts a protobuf UpdateFieldRequest to domain input.
func ProtoToUpdateFieldInput(req *pb.UpdateFieldRequest) models.UpdateFieldInput {
	input := models.UpdateFieldInput{
		ID: req.GetId(),
	}

	if req.GetName() != "" {
		name := req.GetName()
		input.Name = &name
	}
	if req.GetAreaHectares() != 0 {
		ah := req.GetAreaHectares()
		input.AreaHectares = &ah
	}
	if req.GetFieldType() != pb.FieldType_FIELD_TYPE_UNSPECIFIED {
		ft := fieldTypeFromProto(req.GetFieldType())
		input.FieldType = &ft
	}
	if req.GetSoilType() != pb.SoilType_SOIL_TYPE_UNSPECIFIED {
		st := soilTypeFromProto(req.GetSoilType())
		input.SoilType = &st
	}
	if req.GetIrrigationType() != pb.IrrigationType_IRRIGATION_TYPE_UNSPECIFIED {
		it := irrigationTypeFromProto(req.GetIrrigationType())
		input.IrrigationType = &it
	}
	if req.GetStatus() != pb.FieldStatus_FIELD_STATUS_UNSPECIFIED {
		fs := fieldStatusFromProto(req.GetStatus())
		input.Status = &fs
	}
	if req.GetElevationMeters() != 0 {
		em := req.GetElevationMeters()
		input.ElevationMeters = &em
	}
	if req.GetSlopeDegrees() != 0 {
		sd := req.GetSlopeDegrees()
		input.SlopeDegrees = &sd
	}
	if req.GetAspectDirection() != pb.AspectDirection_ASPECT_DIRECTION_UNSPECIFIED {
		ad := aspectDirectionFromProto(req.GetAspectDirection())
		input.AspectDirection = &ad
	}
	if req.GetGrowthStage() != pb.GrowthStage_GROWTH_STAGE_UNSPECIFIED {
		gs := growthStageFromProto(req.GetGrowthStage())
		input.GrowthStage = &gs
	}

	return input
}

// ProtoToAssignCropInput converts a protobuf AssignCropRequest to domain input.
func ProtoToAssignCropInput(req *pb.AssignCropRequest) models.AssignCropInput {
	input := models.AssignCropInput{
		FieldID:     req.GetFieldId(),
		CropID:      req.GetCropId(),
		CropVariety: req.GetCropVariety(),
		Season:      req.GetSeason(),
		Notes:       req.GetNotes(),
	}

	if req.GetPlantingDate() != nil {
		input.PlantingDate = req.GetPlantingDate().AsTime()
	}
	if req.GetExpectedHarvestDate() != nil {
		t := req.GetExpectedHarvestDate().AsTime()
		input.ExpectedHarvestDate = &t
	}

	return input
}

// ProtoToSetBoundaryInput converts a protobuf SetFieldBoundaryRequest to domain input.
func ProtoToSetBoundaryInput(req *pb.SetFieldBoundaryRequest) models.SetBoundaryInput {
	input := models.SetBoundaryInput{
		FieldID: req.GetFieldId(),
		Source:  req.GetSource(),
	}

	if req.GetPolygon() != nil {
		poly := protoToGeoPolygon(req.GetPolygon())
		input.PolygonGeoJSON = geoPolygonToGeoJSON(poly)
	}

	return input
}

// ProtoToSegmentInputs converts protobuf FieldSegmentInput slice to domain inputs.
func ProtoToSegmentInputs(inputs []*pb.FieldSegmentInput) []models.SegmentFieldInput {
	result := make([]models.SegmentFieldInput, 0, len(inputs))
	for _, in := range inputs {
		si := models.SegmentFieldInput{
			Name:         in.GetName(),
			AreaHectares: in.GetAreaHectares(),
			SoilType:     soilTypeFromProto(in.GetSoilType()),
			Notes:        in.GetNotes(),
		}
		if in.GetBoundary() != nil {
			gj := geoPolygonToGeoJSON(protoToGeoPolygon(in.GetBoundary()))
			si.BoundaryGeoJSON = &gj
		}
		result = append(result, si)
	}
	return result
}

// ---------------------------------------------------------------------------
// GeoJSON helpers
// ---------------------------------------------------------------------------

type geoJSONPolygon struct {
	Type        string        `json:"type"`
	Coordinates [][][]float64 `json:"coordinates"`
}

// geoPolygonToGeoJSON serialises a domain GeoPolygon to a GeoJSON string.
func geoPolygonToGeoJSON(poly *models.GeoPolygon) string {
	if poly == nil || len(poly.Points) == 0 {
		return `{"type":"Polygon","coordinates":[[]]}`
	}

	ring := make([][]float64, 0, len(poly.Points)+1)
	for _, pt := range poly.Points {
		ring = append(ring, []float64{pt.Longitude, pt.Latitude})
	}
	// Close the ring if not already closed.
	first := poly.Points[0]
	last := poly.Points[len(poly.Points)-1]
	if first.Longitude != last.Longitude || first.Latitude != last.Latitude {
		ring = append(ring, []float64{first.Longitude, first.Latitude})
	}

	g := geoJSONPolygon{
		Type:        "Polygon",
		Coordinates: [][][]float64{ring},
	}
	b, _ := json.Marshal(g)
	return string(b)
}

// geoJSONToGeoPolygon parses a GeoJSON polygon string into a domain GeoPolygon.
func geoJSONToGeoPolygon(geoJSON string) (*models.GeoPolygon, error) {
	if geoJSON == "" {
		return nil, nil
	}

	var g geoJSONPolygon
	if err := json.Unmarshal([]byte(geoJSON), &g); err != nil {
		return nil, fmt.Errorf("invalid GeoJSON polygon: %w", err)
	}

	if len(g.Coordinates) == 0 || len(g.Coordinates[0]) == 0 {
		return nil, nil
	}

	ring := g.Coordinates[0]
	points := make([]models.GeoPoint, 0, len(ring))
	for _, coord := range ring {
		if len(coord) < 2 {
			continue
		}
		points = append(points, models.GeoPoint{
			Longitude: coord[0],
			Latitude:  coord[1],
		})
	}

	// Remove closing duplicate point if present.
	if len(points) > 1 {
		first := points[0]
		last := points[len(points)-1]
		if first.Longitude == last.Longitude && first.Latitude == last.Latitude {
			points = points[:len(points)-1]
		}
	}

	return &models.GeoPolygon{Points: points}, nil
}

// protoToGeoPolygon converts a protobuf GeoPolygon to domain model.
func protoToGeoPolygon(p *pb.GeoPolygon) *models.GeoPolygon {
	if p == nil || len(p.Points) == 0 {
		return nil
	}
	points := make([]models.GeoPoint, 0, len(p.Points))
	for _, pt := range p.Points {
		points = append(points, models.GeoPoint{
			Longitude: pt.Longitude,
			Latitude:  pt.Latitude,
		})
	}
	return &models.GeoPolygon{Points: points}
}

// geoPolygonToProto converts a domain GeoPolygon to protobuf.
func geoPolygonToProto(poly *models.GeoPolygon) *pb.GeoPolygon {
	if poly == nil || len(poly.Points) == 0 {
		return nil
	}
	points := make([]*pb.GeoPoint, 0, len(poly.Points))
	for _, pt := range poly.Points {
		points = append(points, &pb.GeoPoint{
			Longitude: pt.Longitude,
			Latitude:  pt.Latitude,
		})
	}
	return &pb.GeoPolygon{Points: points}
}

// ---------------------------------------------------------------------------
// Enum mappers: domain <-> proto
// ---------------------------------------------------------------------------

func fieldStatusToProto(s models.FieldStatus) pb.FieldStatus {
	switch s {
	case models.FieldStatusActive:
		return pb.FieldStatus_FIELD_STATUS_ACTIVE
	case models.FieldStatusFallow:
		return pb.FieldStatus_FIELD_STATUS_FALLOW
	case models.FieldStatusPreparation:
		return pb.FieldStatus_FIELD_STATUS_PREPARATION
	case models.FieldStatusPlanted:
		return pb.FieldStatus_FIELD_STATUS_PLANTED
	case models.FieldStatusHarvesting:
		return pb.FieldStatus_FIELD_STATUS_HARVESTING
	case models.FieldStatusRetired:
		return pb.FieldStatus_FIELD_STATUS_RETIRED
	default:
		return pb.FieldStatus_FIELD_STATUS_UNSPECIFIED
	}
}

func fieldStatusFromProto(s pb.FieldStatus) models.FieldStatus {
	switch s {
	case pb.FieldStatus_FIELD_STATUS_ACTIVE:
		return models.FieldStatusActive
	case pb.FieldStatus_FIELD_STATUS_FALLOW:
		return models.FieldStatusFallow
	case pb.FieldStatus_FIELD_STATUS_PREPARATION:
		return models.FieldStatusPreparation
	case pb.FieldStatus_FIELD_STATUS_PLANTED:
		return models.FieldStatusPlanted
	case pb.FieldStatus_FIELD_STATUS_HARVESTING:
		return models.FieldStatusHarvesting
	case pb.FieldStatus_FIELD_STATUS_RETIRED:
		return models.FieldStatusRetired
	default:
		return models.FieldStatusUnspecified
	}
}

func fieldTypeToProto(t models.FieldType) pb.FieldType {
	switch t {
	case models.FieldTypeCropland:
		return pb.FieldType_FIELD_TYPE_CROPLAND
	case models.FieldTypePasture:
		return pb.FieldType_FIELD_TYPE_PASTURE
	case models.FieldTypeOrchard:
		return pb.FieldType_FIELD_TYPE_ORCHARD
	case models.FieldTypeVineyard:
		return pb.FieldType_FIELD_TYPE_VINEYARD
	case models.FieldTypeGreenhouse:
		return pb.FieldType_FIELD_TYPE_GREENHOUSE
	case models.FieldTypeNursery:
		return pb.FieldType_FIELD_TYPE_NURSERY
	case models.FieldTypeAgroforest:
		return pb.FieldType_FIELD_TYPE_AGROFOREST
	default:
		return pb.FieldType_FIELD_TYPE_UNSPECIFIED
	}
}

func fieldTypeFromProto(t pb.FieldType) models.FieldType {
	switch t {
	case pb.FieldType_FIELD_TYPE_CROPLAND:
		return models.FieldTypeCropland
	case pb.FieldType_FIELD_TYPE_PASTURE:
		return models.FieldTypePasture
	case pb.FieldType_FIELD_TYPE_ORCHARD:
		return models.FieldTypeOrchard
	case pb.FieldType_FIELD_TYPE_VINEYARD:
		return models.FieldTypeVineyard
	case pb.FieldType_FIELD_TYPE_GREENHOUSE:
		return models.FieldTypeGreenhouse
	case pb.FieldType_FIELD_TYPE_NURSERY:
		return models.FieldTypeNursery
	case pb.FieldType_FIELD_TYPE_AGROFOREST:
		return models.FieldTypeAgroforest
	default:
		return models.FieldTypeUnspecified
	}
}

func soilTypeToProto(s models.SoilType) pb.SoilType {
	switch s {
	case models.SoilTypeCite:
		return pb.SoilType_SOIL_TYPE_CLAY
	case models.SoilTypeSandy:
		return pb.SoilType_SOIL_TYPE_SANDY
	case models.SoilTypeLoamy:
		return pb.SoilType_SOIL_TYPE_LOAMY
	case models.SoilTypeSilt:
		return pb.SoilType_SOIL_TYPE_SILT
	case models.SoilTypePeat:
		return pb.SoilType_SOIL_TYPE_PEAT
	case models.SoilTypeChalk:
		return pb.SoilType_SOIL_TYPE_CHALK
	case models.SoilTypeClayLoam:
		return pb.SoilType_SOIL_TYPE_CLAY_LOAM
	case models.SoilTypeSandyLoam:
		return pb.SoilType_SOIL_TYPE_SANDY_LOAM
	default:
		return pb.SoilType_SOIL_TYPE_UNSPECIFIED
	}
}

func soilTypeFromProto(s pb.SoilType) models.SoilType {
	switch s {
	case pb.SoilType_SOIL_TYPE_CLAY:
		return models.SoilTypeCite
	case pb.SoilType_SOIL_TYPE_SANDY:
		return models.SoilTypeSandy
	case pb.SoilType_SOIL_TYPE_LOAMY:
		return models.SoilTypeLoamy
	case pb.SoilType_SOIL_TYPE_SILT:
		return models.SoilTypeSilt
	case pb.SoilType_SOIL_TYPE_PEAT:
		return models.SoilTypePeat
	case pb.SoilType_SOIL_TYPE_CHALK:
		return models.SoilTypeChalk
	case pb.SoilType_SOIL_TYPE_CLAY_LOAM:
		return models.SoilTypeClayLoam
	case pb.SoilType_SOIL_TYPE_SANDY_LOAM:
		return models.SoilTypeSandyLoam
	default:
		return models.SoilTypeUnspecified
	}
}

func irrigationTypeToProto(t models.IrrigationType) pb.IrrigationType {
	switch t {
	case models.IrrigationTypeRainfed:
		return pb.IrrigationType_IRRIGATION_TYPE_RAINFED
	case models.IrrigationTypeDrip:
		return pb.IrrigationType_IRRIGATION_TYPE_DRIP
	case models.IrrigationTypeSprinkler:
		return pb.IrrigationType_IRRIGATION_TYPE_SPRINKLER
	case models.IrrigationTypeFlood:
		return pb.IrrigationType_IRRIGATION_TYPE_FLOOD
	case models.IrrigationTypeCenterPivot:
		return pb.IrrigationType_IRRIGATION_TYPE_CENTER_PIVOT
	case models.IrrigationTypeFurrow:
		return pb.IrrigationType_IRRIGATION_TYPE_FURROW
	case models.IrrigationTypeSubsurface:
		return pb.IrrigationType_IRRIGATION_TYPE_SUBSURFACE
	default:
		return pb.IrrigationType_IRRIGATION_TYPE_UNSPECIFIED
	}
}

func irrigationTypeFromProto(t pb.IrrigationType) models.IrrigationType {
	switch t {
	case pb.IrrigationType_IRRIGATION_TYPE_RAINFED:
		return models.IrrigationTypeRainfed
	case pb.IrrigationType_IRRIGATION_TYPE_DRIP:
		return models.IrrigationTypeDrip
	case pb.IrrigationType_IRRIGATION_TYPE_SPRINKLER:
		return models.IrrigationTypeSprinkler
	case pb.IrrigationType_IRRIGATION_TYPE_FLOOD:
		return models.IrrigationTypeFlood
	case pb.IrrigationType_IRRIGATION_TYPE_CENTER_PIVOT:
		return models.IrrigationTypeCenterPivot
	case pb.IrrigationType_IRRIGATION_TYPE_FURROW:
		return models.IrrigationTypeFurrow
	case pb.IrrigationType_IRRIGATION_TYPE_SUBSURFACE:
		return models.IrrigationTypeSubsurface
	default:
		return models.IrrigationTypeUnspecified
	}
}

func growthStageToProto(g models.GrowthStage) pb.GrowthStage {
	switch g {
	case models.GrowthStageGermination:
		return pb.GrowthStage_GROWTH_STAGE_GERMINATION
	case models.GrowthStageSeedling:
		return pb.GrowthStage_GROWTH_STAGE_SEEDLING
	case models.GrowthStageVegetative:
		return pb.GrowthStage_GROWTH_STAGE_VEGETATIVE
	case models.GrowthStageBudding:
		return pb.GrowthStage_GROWTH_STAGE_BUDDING
	case models.GrowthStageFlowering:
		return pb.GrowthStage_GROWTH_STAGE_FLOWERING
	case models.GrowthStageFruitSet:
		return pb.GrowthStage_GROWTH_STAGE_FRUIT_SET
	case models.GrowthStageRipening:
		return pb.GrowthStage_GROWTH_STAGE_RIPENING
	case models.GrowthStageMaturity:
		return pb.GrowthStage_GROWTH_STAGE_MATURITY
	case models.GrowthStageSenescence:
		return pb.GrowthStage_GROWTH_STAGE_SENESCENCE
	default:
		return pb.GrowthStage_GROWTH_STAGE_UNSPECIFIED
	}
}

func growthStageFromProto(g pb.GrowthStage) models.GrowthStage {
	switch g {
	case pb.GrowthStage_GROWTH_STAGE_GERMINATION:
		return models.GrowthStageGermination
	case pb.GrowthStage_GROWTH_STAGE_SEEDLING:
		return models.GrowthStageSeedling
	case pb.GrowthStage_GROWTH_STAGE_VEGETATIVE:
		return models.GrowthStageVegetative
	case pb.GrowthStage_GROWTH_STAGE_BUDDING:
		return models.GrowthStageBudding
	case pb.GrowthStage_GROWTH_STAGE_FLOWERING:
		return models.GrowthStageFlowering
	case pb.GrowthStage_GROWTH_STAGE_FRUIT_SET:
		return models.GrowthStageFruitSet
	case pb.GrowthStage_GROWTH_STAGE_RIPENING:
		return models.GrowthStageRipening
	case pb.GrowthStage_GROWTH_STAGE_MATURITY:
		return models.GrowthStageMaturity
	case pb.GrowthStage_GROWTH_STAGE_SENESCENCE:
		return models.GrowthStageSenescence
	default:
		return models.GrowthStageUnspecified
	}
}

func aspectDirectionToProto(d models.AspectDirection) pb.AspectDirection {
	switch d {
	case models.AspectDirectionNorth:
		return pb.AspectDirection_ASPECT_DIRECTION_NORTH
	case models.AspectDirectionNortheast:
		return pb.AspectDirection_ASPECT_DIRECTION_NORTHEAST
	case models.AspectDirectionEast:
		return pb.AspectDirection_ASPECT_DIRECTION_EAST
	case models.AspectDirectionSoutheast:
		return pb.AspectDirection_ASPECT_DIRECTION_SOUTHEAST
	case models.AspectDirectionSouth:
		return pb.AspectDirection_ASPECT_DIRECTION_SOUTH
	case models.AspectDirectionSouthwest:
		return pb.AspectDirection_ASPECT_DIRECTION_SOUTHWEST
	case models.AspectDirectionWest:
		return pb.AspectDirection_ASPECT_DIRECTION_WEST
	case models.AspectDirectionNorthwest:
		return pb.AspectDirection_ASPECT_DIRECTION_NORTHWEST
	case models.AspectDirectionFlat:
		return pb.AspectDirection_ASPECT_DIRECTION_FLAT
	default:
		return pb.AspectDirection_ASPECT_DIRECTION_UNSPECIFIED
	}
}

func aspectDirectionFromProto(d pb.AspectDirection) models.AspectDirection {
	switch d {
	case pb.AspectDirection_ASPECT_DIRECTION_NORTH:
		return models.AspectDirectionNorth
	case pb.AspectDirection_ASPECT_DIRECTION_NORTHEAST:
		return models.AspectDirectionNortheast
	case pb.AspectDirection_ASPECT_DIRECTION_EAST:
		return models.AspectDirectionEast
	case pb.AspectDirection_ASPECT_DIRECTION_SOUTHEAST:
		return models.AspectDirectionSoutheast
	case pb.AspectDirection_ASPECT_DIRECTION_SOUTH:
		return models.AspectDirectionSouth
	case pb.AspectDirection_ASPECT_DIRECTION_SOUTHWEST:
		return models.AspectDirectionSouthwest
	case pb.AspectDirection_ASPECT_DIRECTION_WEST:
		return models.AspectDirectionWest
	case pb.AspectDirection_ASPECT_DIRECTION_NORTHWEST:
		return models.AspectDirectionNorthwest
	case pb.AspectDirection_ASPECT_DIRECTION_FLAT:
		return models.AspectDirectionFlat
	default:
		return models.AspectDirectionUnspecified
	}
}

// TimePtrFromTimestamppb converts a protobuf Timestamp to a *time.Time.
func TimePtrFromTimestamppb(ts *timestamppb.Timestamp) *time.Time {
	if ts == nil || ts.AsTime().IsZero() {
		return nil
	}
	t := ts.AsTime()
	return &t
}
