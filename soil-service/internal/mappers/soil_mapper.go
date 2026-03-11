package mappers

import (
	"time"

	pb "p9e.in/samavaya/agriculture/soil-service/api/v1"
	"p9e.in/samavaya/agriculture/soil-service/internal/models"
	"p9e.in/samavaya/packages/convert/ptr"

	"google.golang.org/protobuf/types/known/timestamppb"
)

// ---------------------------------------------------------------------------
// Proto enum <-> domain enum
// ---------------------------------------------------------------------------

func SoilTextureToProto(t models.SoilTexture) pb.SoilTexture {
	switch t {
	case models.SoilTextureSandy:
		return pb.SoilTexture_SOIL_TEXTURE_SANDY
	case models.SoilTextureLoamy:
		return pb.SoilTexture_SOIL_TEXTURE_LOAMY
	case models.SoilTextureClay:
		return pb.SoilTexture_SOIL_TEXTURE_CLAY
	case models.SoilTextureSilt:
		return pb.SoilTexture_SOIL_TEXTURE_SILT
	case models.SoilTexturePeat:
		return pb.SoilTexture_SOIL_TEXTURE_PEAT
	case models.SoilTextureChalk:
		return pb.SoilTexture_SOIL_TEXTURE_CHALK
	default:
		return pb.SoilTexture_SOIL_TEXTURE_UNSPECIFIED
	}
}

func SoilTextureFromProto(t pb.SoilTexture) models.SoilTexture {
	switch t {
	case pb.SoilTexture_SOIL_TEXTURE_SANDY:
		return models.SoilTextureSandy
	case pb.SoilTexture_SOIL_TEXTURE_LOAMY:
		return models.SoilTextureLoamy
	case pb.SoilTexture_SOIL_TEXTURE_CLAY:
		return models.SoilTextureClay
	case pb.SoilTexture_SOIL_TEXTURE_SILT:
		return models.SoilTextureSilt
	case pb.SoilTexture_SOIL_TEXTURE_PEAT:
		return models.SoilTexturePeat
	case pb.SoilTexture_SOIL_TEXTURE_CHALK:
		return models.SoilTextureChalk
	default:
		return models.SoilTextureUnspecified
	}
}

func AnalysisStatusToProto(s models.AnalysisStatus) pb.AnalysisStatus {
	switch s {
	case models.AnalysisStatusPending:
		return pb.AnalysisStatus_ANALYSIS_STATUS_PENDING
	case models.AnalysisStatusInProgress:
		return pb.AnalysisStatus_ANALYSIS_STATUS_IN_PROGRESS
	case models.AnalysisStatusCompleted:
		return pb.AnalysisStatus_ANALYSIS_STATUS_COMPLETED
	case models.AnalysisStatusFailed:
		return pb.AnalysisStatus_ANALYSIS_STATUS_FAILED
	default:
		return pb.AnalysisStatus_ANALYSIS_STATUS_UNSPECIFIED
	}
}

func AnalysisStatusFromProto(s pb.AnalysisStatus) models.AnalysisStatus {
	switch s {
	case pb.AnalysisStatus_ANALYSIS_STATUS_PENDING:
		return models.AnalysisStatusPending
	case pb.AnalysisStatus_ANALYSIS_STATUS_IN_PROGRESS:
		return models.AnalysisStatusInProgress
	case pb.AnalysisStatus_ANALYSIS_STATUS_COMPLETED:
		return models.AnalysisStatusCompleted
	case pb.AnalysisStatus_ANALYSIS_STATUS_FAILED:
		return models.AnalysisStatusFailed
	default:
		return models.AnalysisStatusPending
	}
}

func NutrientLevelToProto(l models.NutrientLevel) pb.NutrientLevel {
	switch l {
	case models.NutrientLevelDeficient:
		return pb.NutrientLevel_NUTRIENT_LEVEL_DEFICIENT
	case models.NutrientLevelLow:
		return pb.NutrientLevel_NUTRIENT_LEVEL_LOW
	case models.NutrientLevelAdequate:
		return pb.NutrientLevel_NUTRIENT_LEVEL_ADEQUATE
	case models.NutrientLevelHigh:
		return pb.NutrientLevel_NUTRIENT_LEVEL_HIGH
	case models.NutrientLevelExcessive:
		return pb.NutrientLevel_NUTRIENT_LEVEL_EXCESSIVE
	default:
		return pb.NutrientLevel_NUTRIENT_LEVEL_UNSPECIFIED
	}
}

func NutrientLevelFromProto(l pb.NutrientLevel) models.NutrientLevel {
	switch l {
	case pb.NutrientLevel_NUTRIENT_LEVEL_DEFICIENT:
		return models.NutrientLevelDeficient
	case pb.NutrientLevel_NUTRIENT_LEVEL_LOW:
		return models.NutrientLevelLow
	case pb.NutrientLevel_NUTRIENT_LEVEL_ADEQUATE:
		return models.NutrientLevelAdequate
	case pb.NutrientLevel_NUTRIENT_LEVEL_HIGH:
		return models.NutrientLevelHigh
	case pb.NutrientLevel_NUTRIENT_LEVEL_EXCESSIVE:
		return models.NutrientLevelExcessive
	default:
		return models.NutrientLevelAdequate
	}
}

func HealthCategoryToProto(c models.HealthCategory) pb.HealthCategory {
	switch c {
	case models.HealthCategoryCritical:
		return pb.HealthCategory_HEALTH_CATEGORY_CRITICAL
	case models.HealthCategoryPoor:
		return pb.HealthCategory_HEALTH_CATEGORY_POOR
	case models.HealthCategoryFair:
		return pb.HealthCategory_HEALTH_CATEGORY_FAIR
	case models.HealthCategoryGood:
		return pb.HealthCategory_HEALTH_CATEGORY_GOOD
	case models.HealthCategoryExcellent:
		return pb.HealthCategory_HEALTH_CATEGORY_EXCELLENT
	default:
		return pb.HealthCategory_HEALTH_CATEGORY_UNSPECIFIED
	}
}

func HealthCategoryFromProto(c pb.HealthCategory) models.HealthCategory {
	switch c {
	case pb.HealthCategory_HEALTH_CATEGORY_CRITICAL:
		return models.HealthCategoryCritical
	case pb.HealthCategory_HEALTH_CATEGORY_POOR:
		return models.HealthCategoryPoor
	case pb.HealthCategory_HEALTH_CATEGORY_FAIR:
		return models.HealthCategoryFair
	case pb.HealthCategory_HEALTH_CATEGORY_GOOD:
		return models.HealthCategoryGood
	case pb.HealthCategory_HEALTH_CATEGORY_EXCELLENT:
		return models.HealthCategoryExcellent
	default:
		return models.HealthCategoryFair
	}
}

// ---------------------------------------------------------------------------
// Timestamp helpers
// ---------------------------------------------------------------------------

func timeToProto(t time.Time) *timestamppb.Timestamp {
	if t.IsZero() {
		return nil
	}
	return timestamppb.New(t)
}

func timePtrToProto(t *time.Time) *timestamppb.Timestamp {
	if t == nil {
		return nil
	}
	return timestamppb.New(*t)
}

func protoToTime(ts *timestamppb.Timestamp) time.Time {
	if ts == nil {
		return time.Time{}
	}
	return ts.AsTime()
}

func protoToTimePtr(ts *timestamppb.Timestamp) *time.Time {
	if ts == nil {
		return nil
	}
	t := ts.AsTime()
	return &t
}

// ---------------------------------------------------------------------------
// SoilSample
// ---------------------------------------------------------------------------

func SoilSampleToProto(s *models.SoilSample) *pb.SoilSample {
	if s == nil {
		return nil
	}
	return &pb.SoilSample{
		Id:       s.UUID,
		TenantId: s.TenantID,
		FieldId:  s.FieldID,
		FarmId:   s.FarmID,
		SampleLocation: &pb.Location{
			Latitude:  s.Latitude,
			Longitude: s.Longitude,
		},
		SampleDepthCm:          s.SampleDepthCm,
		CollectionDate:          timeToProto(s.CollectionDate),
		PH:                     s.PH,
		OrganicMatterPct:        s.OrganicMatterPct,
		NitrogenPpm:            s.NitrogenPPM,
		PhosphorusPpm:          s.PhosphorusPPM,
		PotassiumPpm:           s.PotassiumPPM,
		CalciumPpm:             s.CalciumPPM,
		MagnesiumPpm:           s.MagnesiumPPM,
		SulfurPpm:              s.SulfurPPM,
		IronPpm:                s.IronPPM,
		ManganesePpm:           s.ManganesePPM,
		ZincPpm:                s.ZincPPM,
		CopperPpm:              s.CopperPPM,
		BoronPpm:               s.BoronPPM,
		MoisturePct:            s.MoisturePct,
		Texture:                SoilTextureToProto(s.Texture),
		BulkDensity:            s.BulkDensity,
		CationExchangeCapacity: s.CationExchangeCapacity,
		ElectricalConductivity: s.ElectricalConductivity,
		CollectedBy:            s.CollectedBy,
		Notes:                  s.Notes,
		CreatedAt:              timeToProto(s.CreatedAt),
		UpdatedAt:              timePtrToProto(s.UpdatedAt),
		Version:                s.Version,
	}
}

func SoilSampleFromCreateRequest(req *pb.CreateSoilSampleRequest, uuid, userID string) *models.SoilSample {
	if req == nil {
		return nil
	}
	s := &models.SoilSample{
		TenantID:               req.TenantId,
		FieldID:                req.FieldId,
		FarmID:                 req.FarmId,
		SampleDepthCm:          req.SampleDepthCm,
		CollectionDate:         protoToTime(req.CollectionDate),
		PH:                     req.PH,
		OrganicMatterPct:       req.OrganicMatterPct,
		NitrogenPPM:            req.NitrogenPpm,
		PhosphorusPPM:          req.PhosphorusPpm,
		PotassiumPPM:           req.PotassiumPpm,
		CalciumPPM:             req.CalciumPpm,
		MagnesiumPPM:           req.MagnesiumPpm,
		SulfurPPM:              req.SulfurPpm,
		IronPPM:                req.IronPpm,
		ManganesePPM:           req.ManganesePpm,
		ZincPPM:                req.ZincPpm,
		CopperPPM:              req.CopperPpm,
		BoronPPM:               req.BoronPpm,
		MoisturePct:            req.MoisturePct,
		Texture:                SoilTextureFromProto(req.Texture),
		BulkDensity:            req.BulkDensity,
		CationExchangeCapacity: req.CationExchangeCapacity,
		ElectricalConductivity: req.ElectricalConductivity,
		CollectedBy:            userID,
		Notes:                  req.Notes,
		Version:                1,
	}
	s.UUID = uuid
	s.CreatedBy = userID
	s.IsActive = true

	if req.SampleLocation != nil {
		s.Latitude = req.SampleLocation.Latitude
		s.Longitude = req.SampleLocation.Longitude
	}
	return s
}

func SoilSamplesToProto(samples []models.SoilSample) []*pb.SoilSample {
	result := make([]*pb.SoilSample, 0, len(samples))
	for i := range samples {
		result = append(result, SoilSampleToProto(&samples[i]))
	}
	return result
}

// ---------------------------------------------------------------------------
// SoilAnalysis
// ---------------------------------------------------------------------------

func SoilAnalysisToProto(a *models.SoilAnalysis) *pb.SoilAnalysis {
	if a == nil {
		return nil
	}
	return &pb.SoilAnalysis{
		Id:              a.UUID,
		TenantId:        a.TenantID,
		SampleId:        a.SampleID,
		FieldId:         a.FieldID,
		FarmId:          a.FarmID,
		Status:          AnalysisStatusToProto(a.Status),
		AnalysisType:    a.AnalysisType,
		SoilHealthScore: a.SoilHealthScore,
		HealthCategory:  HealthCategoryToProto(a.HealthCategory),
		Recommendations: a.Recommendations,
		AnalyzedBy:      a.AnalyzedBy,
		AnalyzedAt:      timePtrToProto(a.AnalyzedAt),
		Summary:         a.Summary,
		CreatedAt:       timeToProto(a.CreatedAt),
		UpdatedAt:       timePtrToProto(a.UpdatedAt),
		Version:         a.Version,
	}
}

func SoilAnalysesToProto(analyses []models.SoilAnalysis) []*pb.SoilAnalysis {
	result := make([]*pb.SoilAnalysis, 0, len(analyses))
	for i := range analyses {
		result = append(result, SoilAnalysisToProto(&analyses[i]))
	}
	return result
}

// ---------------------------------------------------------------------------
// SoilMap
// ---------------------------------------------------------------------------

func SoilMapToProto(m *models.SoilMap) *pb.SoilMap {
	if m == nil {
		return nil
	}
	return &pb.SoilMap{
		Id:       m.UUID,
		TenantId: m.TenantID,
		FieldId:  m.FieldID,
		FarmId:   m.FarmID,
		MapType:  m.MapType,
		RasterData: m.RasterData,
		Crs:        m.CRS,
		Resolution: m.Resolution,
		BboxMin: &pb.Location{
			Latitude:  m.BboxMinLat,
			Longitude: m.BboxMinLng,
		},
		BboxMax: &pb.Location{
			Latitude:  m.BboxMaxLat,
			Longitude: m.BboxMaxLng,
		},
		GeneratedBy: m.GeneratedBy,
		GeneratedAt: timePtrToProto(m.GeneratedAt),
		CreatedAt:   timeToProto(m.CreatedAt),
		UpdatedAt:   timePtrToProto(m.UpdatedAt),
		Version:     m.Version,
	}
}

// ---------------------------------------------------------------------------
// SoilNutrient
// ---------------------------------------------------------------------------

func SoilNutrientToProto(n *models.SoilNutrient) *pb.SoilNutrient {
	if n == nil {
		return nil
	}
	return &pb.SoilNutrient{
		Id:           n.UUID,
		TenantId:     n.TenantID,
		SampleId:     n.SampleID,
		NutrientName: n.NutrientName,
		ValuePpm:     n.ValuePPM,
		Level:        NutrientLevelToProto(n.Level),
		OptimalMin:   n.OptimalMin,
		OptimalMax:   n.OptimalMax,
		Unit:         n.Unit,
		CreatedAt:    timeToProto(n.CreatedAt),
	}
}

func SoilNutrientsToProto(nutrients []models.SoilNutrient) []*pb.SoilNutrient {
	result := make([]*pb.SoilNutrient, 0, len(nutrients))
	for i := range nutrients {
		result = append(result, SoilNutrientToProto(&nutrients[i]))
	}
	return result
}

// ---------------------------------------------------------------------------
// SoilHealthScore
// ---------------------------------------------------------------------------

func SoilHealthScoreToProto(h *models.SoilHealthScore) *pb.SoilHealthScore {
	if h == nil {
		return nil
	}
	pbHealth := &pb.SoilHealthScore{
		Id:              h.UUID,
		TenantId:        h.TenantID,
		FieldId:         h.FieldID,
		FarmId:          h.FarmID,
		OverallScore:    h.OverallScore,
		Category:        HealthCategoryToProto(h.Category),
		PhysicalScore:   h.PhysicalScore,
		ChemicalScore:   h.ChemicalScore,
		BiologicalScore: h.BiologicalScore,
		Recommendations: h.Recommendations,
		AssessedAt:      timePtrToProto(h.AssessedAt),
		CreatedAt:       timeToProto(h.CreatedAt),
		UpdatedAt:       timePtrToProto(h.UpdatedAt),
		Version:         h.Version,
	}
	return pbHealth
}

// ---------------------------------------------------------------------------
// NutrientDeficiency
// ---------------------------------------------------------------------------

func NutrientDeficiencyToProto(d *models.NutrientDeficiency) *pb.NutrientDeficiency {
	if d == nil {
		return nil
	}
	return &pb.NutrientDeficiency{
		NutrientName:   d.NutrientName,
		CurrentValue:   d.CurrentValue,
		OptimalValue:   d.OptimalValue,
		Level:          NutrientLevelToProto(d.Level),
		Recommendation: d.Recommendation,
	}
}

func NutrientDeficienciesToProto(defs []models.NutrientDeficiency) []*pb.NutrientDeficiency {
	result := make([]*pb.NutrientDeficiency, 0, len(defs))
	for i := range defs {
		result = append(result, NutrientDeficiencyToProto(&defs[i]))
	}
	return result
}

// ---------------------------------------------------------------------------
// SoilReport
// ---------------------------------------------------------------------------

func SoilReportToProto(r *models.SoilReport, id, tenantID, fieldID, farmID string) *pb.SoilReport {
	if r == nil {
		return nil
	}
	return &pb.SoilReport{
		Id:              id,
		TenantId:        tenantID,
		FieldId:         fieldID,
		FarmId:          farmID,
		Sample:          SoilSampleToProto(r.Sample),
		Analysis:        SoilAnalysisToProto(r.Analysis),
		HealthScore:     SoilHealthScoreToProto(r.HealthScore),
		Nutrients:       SoilNutrientsToProto(r.Nutrients),
		Recommendations: r.Recommendations,
		GeneratedAt:     timeToProto(r.GeneratedAt),
	}
}

// ---------------------------------------------------------------------------
// String <-> HealthCategory helper (DB row)
// ---------------------------------------------------------------------------

func HealthCategoryFromString(s string) models.HealthCategory {
	switch s {
	case "CRITICAL":
		return models.HealthCategoryCritical
	case "POOR":
		return models.HealthCategoryPoor
	case "FAIR":
		return models.HealthCategoryFair
	case "GOOD":
		return models.HealthCategoryGood
	case "EXCELLENT":
		return models.HealthCategoryExcellent
	default:
		return models.HealthCategoryFair
	}
}

func AnalysisStatusFromString(s string) models.AnalysisStatus {
	switch s {
	case "PENDING":
		return models.AnalysisStatusPending
	case "IN_PROGRESS":
		return models.AnalysisStatusInProgress
	case "COMPLETED":
		return models.AnalysisStatusCompleted
	case "FAILED":
		return models.AnalysisStatusFailed
	default:
		return models.AnalysisStatusPending
	}
}

func NutrientLevelFromString(s string) models.NutrientLevel {
	switch s {
	case "DEFICIENT":
		return models.NutrientLevelDeficient
	case "LOW":
		return models.NutrientLevelLow
	case "ADEQUATE":
		return models.NutrientLevelAdequate
	case "HIGH":
		return models.NutrientLevelHigh
	case "EXCESSIVE":
		return models.NutrientLevelExcessive
	default:
		return models.NutrientLevelAdequate
	}
}

// Ensure ptr import is used (used elsewhere in mapper callers).
var _ = ptr.Ptr[string]
