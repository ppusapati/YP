package mappers

import (
	"time"

	pb "p9e.in/samavaya/agriculture/yield-service/api/v1"
	"p9e.in/samavaya/agriculture/yield-service/internal/models"
	"p9e.in/samavaya/packages/convert/ptr"

	"google.golang.org/protobuf/types/known/timestamppb"
)

// --- YieldPrediction mappers ---

// YieldPredictionToProto converts a domain YieldPrediction to its protobuf representation.
func YieldPredictionToProto(m *models.YieldPrediction) *pb.YieldPrediction {
	if m == nil {
		return nil
	}
	p := &pb.YieldPrediction{
		Id:                         m.UUID,
		TenantId:                   m.TenantID,
		FarmId:                     m.FarmID,
		FieldId:                    m.FieldID,
		CropId:                     m.CropID,
		Season:                     m.Season,
		Year:                       m.Year,
		PredictedYieldKgPerHectare: m.PredictedYieldKgPerHectare,
		PredictionConfidencePct:    m.PredictionConfidencePct,
		PredictionModelVersion:     m.PredictionModelVersion,
		Status:                     mapPredictionStatusToProto(m.Status),
		YieldFactors:               YieldFactorsToProto(m.GetYieldFactors()),
		CreatedBy:                  m.CreatedBy,
		UpdatedBy:                  ptr.StringValue(m.UpdatedBy),
		Version:                    m.Version,
		CreatedAt:                  timestamppb.New(m.CreatedAt),
	}
	if m.UpdatedAt != nil {
		p.UpdatedAt = timestamppb.New(*m.UpdatedAt)
	}
	return p
}

// YieldPredictionsToProto converts a slice of domain YieldPredictions to protobuf.
func YieldPredictionsToProto(ms []*models.YieldPrediction) []*pb.YieldPrediction {
	result := make([]*pb.YieldPrediction, 0, len(ms))
	for _, m := range ms {
		result = append(result, YieldPredictionToProto(m))
	}
	return result
}

// --- YieldRecord mappers ---

// YieldRecordToProto converts a domain YieldRecord to its protobuf representation.
func YieldRecordToProto(m *models.YieldRecord) *pb.YieldRecord {
	if m == nil {
		return nil
	}
	r := &pb.YieldRecord{
		Id:                         m.UUID,
		TenantId:                   m.TenantID,
		FarmId:                     m.FarmID,
		FieldId:                    m.FieldID,
		CropId:                     m.CropID,
		Season:                     m.Season,
		Year:                       m.Year,
		ActualYieldKgPerHectare:    m.ActualYieldKgPerHectare,
		TotalAreaHarvestedHectares: m.TotalAreaHarvestedHectares,
		TotalYieldKg:               m.TotalYieldKg,
		HarvestQualityGrade:        mapQualityGradeToProto(m.HarvestQualityGrade),
		MoistureContentPct:         m.MoistureContentPct,
		RevenuePerHectare:          m.RevenuePerHectare,
		CostPerHectare:             m.CostPerHectare,
		ProfitPerHectare:           m.ProfitPerHectare,
		PredictionId:               ptr.StringValue(m.PredictionID),
		CreatedBy:                  m.CreatedBy,
		UpdatedBy:                  ptr.StringValue(m.UpdatedBy),
		Version:                    m.Version,
		CreatedAt:                  timestamppb.New(m.CreatedAt),
	}
	if m.HarvestDate != nil {
		r.HarvestDate = timestamppb.New(*m.HarvestDate)
	}
	if m.UpdatedAt != nil {
		r.UpdatedAt = timestamppb.New(*m.UpdatedAt)
	}
	return r
}

// YieldRecordsToProto converts a slice of domain YieldRecords to protobuf.
func YieldRecordsToProto(ms []*models.YieldRecord) []*pb.YieldRecord {
	result := make([]*pb.YieldRecord, 0, len(ms))
	for _, m := range ms {
		result = append(result, YieldRecordToProto(m))
	}
	return result
}

// --- HarvestPlan mappers ---

// HarvestPlanToProto converts a domain HarvestPlan to its protobuf representation.
func HarvestPlanToProto(m *models.HarvestPlan) *pb.HarvestPlan {
	if m == nil {
		return nil
	}
	h := &pb.HarvestPlan{
		Id:                m.UUID,
		TenantId:          m.TenantID,
		FarmId:            m.FarmID,
		FieldId:           m.FieldID,
		CropId:            m.CropID,
		Season:            m.Season,
		Year:              m.Year,
		PlannedStartDate:  timestamppb.New(m.PlannedStartDate),
		PlannedEndDate:    timestamppb.New(m.PlannedEndDate),
		EstimatedYieldKg:  m.EstimatedYieldKg,
		TotalAreaHectares: m.TotalAreaHectares,
		Status:            mapHarvestPlanStatusToProto(m.Status),
		Notes:             ptr.StringValue(m.Notes),
		CreatedBy:         m.CreatedBy,
		UpdatedBy:         ptr.StringValue(m.UpdatedBy),
		Version:           m.Version,
		CreatedAt:         timestamppb.New(m.CreatedAt),
	}
	if m.UpdatedAt != nil {
		h.UpdatedAt = timestamppb.New(*m.UpdatedAt)
	}
	return h
}

// HarvestPlansToProto converts a slice of domain HarvestPlans to protobuf.
func HarvestPlansToProto(ms []*models.HarvestPlan) []*pb.HarvestPlan {
	result := make([]*pb.HarvestPlan, 0, len(ms))
	for _, m := range ms {
		result = append(result, HarvestPlanToProto(m))
	}
	return result
}

// --- CropPerformance mappers ---

// CropPerformanceToProto converts a domain CropPerformance to its protobuf representation.
func CropPerformanceToProto(m *models.CropPerformance) *pb.CropPerformance {
	if m == nil {
		return nil
	}
	cp := &pb.CropPerformance{
		Id:                            m.UUID,
		TenantId:                      m.TenantID,
		FarmId:                        m.FarmID,
		FieldId:                       m.FieldID,
		CropId:                        m.CropID,
		Season:                        m.Season,
		Year:                          m.Year,
		ActualYieldKgPerHectare:       m.ActualYieldKgPerHectare,
		PredictedYieldKgPerHectare:    m.PredictedYieldKgPerHectare,
		YieldVariancePct:              m.YieldVariancePct,
		ComparisonToRegionalAvgPct:    m.ComparisonToRegionalAvgPct,
		ComparisonToHistoricalAvgPct:  m.ComparisonToHistoricalAvgPct,
		RevenuePerHectare:             m.RevenuePerHectare,
		CostPerHectare:                m.CostPerHectare,
		ProfitPerHectare:              m.ProfitPerHectare,
		YieldFactors:                  YieldFactorsToProto(m.GetYieldFactors()),
		Version:                       m.Version,
		CreatedAt:                     timestamppb.New(m.CreatedAt),
	}
	if m.UpdatedAt != nil {
		cp.UpdatedAt = timestamppb.New(*m.UpdatedAt)
	}
	return cp
}

// --- YieldFactors mappers ---

// YieldFactorsToProto converts domain YieldFactors to protobuf.
func YieldFactorsToProto(f models.YieldFactors) *pb.YieldFactors {
	return &pb.YieldFactors{
		SoilQualityScore:  f.SoilQualityScore,
		WeatherScore:      f.WeatherScore,
		IrrigationScore:   f.IrrigationScore,
		PestPressureScore: f.PestPressureScore,
		NutrientScore:     f.NutrientScore,
		ManagementScore:   f.ManagementScore,
	}
}

// YieldFactorsFromProto converts protobuf YieldFactors to domain.
func YieldFactorsFromProto(f *pb.YieldFactors) models.YieldFactors {
	if f == nil {
		return models.YieldFactors{}
	}
	return models.YieldFactors{
		SoilQualityScore:  f.SoilQualityScore,
		WeatherScore:      f.WeatherScore,
		IrrigationScore:   f.IrrigationScore,
		PestPressureScore: f.PestPressureScore,
		NutrientScore:     f.NutrientScore,
		ManagementScore:   f.ManagementScore,
	}
}

// --- Enum mappers ---

func mapPredictionStatusToProto(status string) pb.PredictionStatus {
	switch status {
	case models.PredictionStatusPending:
		return pb.PredictionStatus_PREDICTION_STATUS_PENDING
	case models.PredictionStatusCompleted:
		return pb.PredictionStatus_PREDICTION_STATUS_COMPLETED
	case models.PredictionStatusFailed:
		return pb.PredictionStatus_PREDICTION_STATUS_FAILED
	case models.PredictionStatusSuperseded:
		return pb.PredictionStatus_PREDICTION_STATUS_SUPERSEDED
	default:
		return pb.PredictionStatus_PREDICTION_STATUS_UNSPECIFIED
	}
}

// PredictionStatusFromProto converts a proto PredictionStatus to a string.
func PredictionStatusFromProto(status pb.PredictionStatus) string {
	switch status {
	case pb.PredictionStatus_PREDICTION_STATUS_PENDING:
		return models.PredictionStatusPending
	case pb.PredictionStatus_PREDICTION_STATUS_COMPLETED:
		return models.PredictionStatusCompleted
	case pb.PredictionStatus_PREDICTION_STATUS_FAILED:
		return models.PredictionStatusFailed
	case pb.PredictionStatus_PREDICTION_STATUS_SUPERSEDED:
		return models.PredictionStatusSuperseded
	default:
		return ""
	}
}

func mapQualityGradeToProto(grade string) pb.HarvestQualityGrade {
	switch grade {
	case models.HarvestQualityGradeA:
		return pb.HarvestQualityGrade_HARVEST_QUALITY_GRADE_A
	case models.HarvestQualityGradeB:
		return pb.HarvestQualityGrade_HARVEST_QUALITY_GRADE_B
	case models.HarvestQualityGradeC:
		return pb.HarvestQualityGrade_HARVEST_QUALITY_GRADE_C
	case models.HarvestQualityGradeD:
		return pb.HarvestQualityGrade_HARVEST_QUALITY_GRADE_D
	default:
		return pb.HarvestQualityGrade_HARVEST_QUALITY_GRADE_UNSPECIFIED
	}
}

// QualityGradeFromProto converts a proto HarvestQualityGrade to a string.
func QualityGradeFromProto(grade pb.HarvestQualityGrade) string {
	switch grade {
	case pb.HarvestQualityGrade_HARVEST_QUALITY_GRADE_A:
		return models.HarvestQualityGradeA
	case pb.HarvestQualityGrade_HARVEST_QUALITY_GRADE_B:
		return models.HarvestQualityGradeB
	case pb.HarvestQualityGrade_HARVEST_QUALITY_GRADE_C:
		return models.HarvestQualityGradeC
	case pb.HarvestQualityGrade_HARVEST_QUALITY_GRADE_D:
		return models.HarvestQualityGradeD
	default:
		return models.HarvestQualityGradeB
	}
}

func mapHarvestPlanStatusToProto(status string) pb.HarvestPlanStatus {
	switch status {
	case models.HarvestPlanStatusDraft:
		return pb.HarvestPlanStatus_HARVEST_PLAN_STATUS_DRAFT
	case models.HarvestPlanStatusScheduled:
		return pb.HarvestPlanStatus_HARVEST_PLAN_STATUS_SCHEDULED
	case models.HarvestPlanStatusInProgress:
		return pb.HarvestPlanStatus_HARVEST_PLAN_STATUS_IN_PROGRESS
	case models.HarvestPlanStatusCompleted:
		return pb.HarvestPlanStatus_HARVEST_PLAN_STATUS_COMPLETED
	case models.HarvestPlanStatusCancelled:
		return pb.HarvestPlanStatus_HARVEST_PLAN_STATUS_CANCELLED
	default:
		return pb.HarvestPlanStatus_HARVEST_PLAN_STATUS_UNSPECIFIED
	}
}

// HarvestPlanStatusFromProto converts a proto HarvestPlanStatus to a string.
func HarvestPlanStatusFromProto(status pb.HarvestPlanStatus) string {
	switch status {
	case pb.HarvestPlanStatus_HARVEST_PLAN_STATUS_DRAFT:
		return models.HarvestPlanStatusDraft
	case pb.HarvestPlanStatus_HARVEST_PLAN_STATUS_SCHEDULED:
		return models.HarvestPlanStatusScheduled
	case pb.HarvestPlanStatus_HARVEST_PLAN_STATUS_IN_PROGRESS:
		return models.HarvestPlanStatusInProgress
	case pb.HarvestPlanStatus_HARVEST_PLAN_STATUS_COMPLETED:
		return models.HarvestPlanStatusCompleted
	case pb.HarvestPlanStatus_HARVEST_PLAN_STATUS_CANCELLED:
		return models.HarvestPlanStatusCancelled
	default:
		return ""
	}
}

// --- Timestamp helpers ---

// TimeToTimestamppb converts a time.Time pointer to a protobuf Timestamp pointer.
func TimeToTimestamppb(t *time.Time) *timestamppb.Timestamp {
	if t == nil {
		return nil
	}
	return timestamppb.New(*t)
}

// TimestamppbToTime converts a protobuf Timestamp to a time.Time pointer.
func TimestamppbToTime(ts *timestamppb.Timestamp) *time.Time {
	if ts == nil {
		return nil
	}
	t := ts.AsTime()
	return &t
}
