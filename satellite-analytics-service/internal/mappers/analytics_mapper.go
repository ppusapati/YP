package mappers

import (
	"google.golang.org/protobuf/types/known/timestamppb"

	pb "p9e.in/samavaya/agriculture/satellite-analytics-service/api/v1"
	analyticsmodels "p9e.in/samavaya/agriculture/satellite-analytics-service/internal/models"
	"p9e.in/samavaya/packages/convert/ptr"
)

// ---- Proto enum <-> Domain enum conversions ----

// ProtoStressTypeToDomain converts a proto StressType to the domain StressType.
func ProtoStressTypeToDomain(st pb.StressType) analyticsmodels.StressType {
	switch st {
	case pb.StressType_STRESS_TYPE_WATER:
		return analyticsmodels.StressTypeWater
	case pb.StressType_STRESS_TYPE_NUTRIENT:
		return analyticsmodels.StressTypeNutrient
	case pb.StressType_STRESS_TYPE_DISEASE:
		return analyticsmodels.StressTypeDisease
	case pb.StressType_STRESS_TYPE_PEST:
		return analyticsmodels.StressTypePest
	case pb.StressType_STRESS_TYPE_HEAT:
		return analyticsmodels.StressTypeHeat
	case pb.StressType_STRESS_TYPE_FROST:
		return analyticsmodels.StressTypeFrost
	default:
		return analyticsmodels.StressTypeUnspecified
	}
}

// DomainStressTypeToProto converts a domain StressType to the proto StressType.
func DomainStressTypeToProto(st analyticsmodels.StressType) pb.StressType {
	switch st {
	case analyticsmodels.StressTypeWater:
		return pb.StressType_STRESS_TYPE_WATER
	case analyticsmodels.StressTypeNutrient:
		return pb.StressType_STRESS_TYPE_NUTRIENT
	case analyticsmodels.StressTypeDisease:
		return pb.StressType_STRESS_TYPE_DISEASE
	case analyticsmodels.StressTypePest:
		return pb.StressType_STRESS_TYPE_PEST
	case analyticsmodels.StressTypeHeat:
		return pb.StressType_STRESS_TYPE_HEAT
	case analyticsmodels.StressTypeFrost:
		return pb.StressType_STRESS_TYPE_FROST
	default:
		return pb.StressType_STRESS_TYPE_UNSPECIFIED
	}
}

// ProtoSeverityLevelToDomain converts a proto SeverityLevel to the domain SeverityLevel.
func ProtoSeverityLevelToDomain(sl pb.SeverityLevel) analyticsmodels.SeverityLevel {
	switch sl {
	case pb.SeverityLevel_SEVERITY_LEVEL_LOW:
		return analyticsmodels.SeverityLevelLow
	case pb.SeverityLevel_SEVERITY_LEVEL_MEDIUM:
		return analyticsmodels.SeverityLevelMedium
	case pb.SeverityLevel_SEVERITY_LEVEL_HIGH:
		return analyticsmodels.SeverityLevelHigh
	case pb.SeverityLevel_SEVERITY_LEVEL_CRITICAL:
		return analyticsmodels.SeverityLevelCritical
	default:
		return analyticsmodels.SeverityLevelUnspecified
	}
}

// DomainSeverityLevelToProto converts a domain SeverityLevel to the proto SeverityLevel.
func DomainSeverityLevelToProto(sl analyticsmodels.SeverityLevel) pb.SeverityLevel {
	switch sl {
	case analyticsmodels.SeverityLevelLow:
		return pb.SeverityLevel_SEVERITY_LEVEL_LOW
	case analyticsmodels.SeverityLevelMedium:
		return pb.SeverityLevel_SEVERITY_LEVEL_MEDIUM
	case analyticsmodels.SeverityLevelHigh:
		return pb.SeverityLevel_SEVERITY_LEVEL_HIGH
	case analyticsmodels.SeverityLevelCritical:
		return pb.SeverityLevel_SEVERITY_LEVEL_CRITICAL
	default:
		return pb.SeverityLevel_SEVERITY_LEVEL_UNSPECIFIED
	}
}

// ProtoAnalysisTypeToDomain converts a proto AnalysisType to the domain AnalysisType.
func ProtoAnalysisTypeToDomain(at pb.AnalysisType) analyticsmodels.AnalysisType {
	switch at {
	case pb.AnalysisType_ANALYSIS_TYPE_STRESS_DETECTION:
		return analyticsmodels.AnalysisTypeStressDetection
	case pb.AnalysisType_ANALYSIS_TYPE_CHANGE_DETECTION:
		return analyticsmodels.AnalysisTypeChangeDetection
	case pb.AnalysisType_ANALYSIS_TYPE_TEMPORAL_TREND:
		return analyticsmodels.AnalysisTypeTemporalTrend
	case pb.AnalysisType_ANALYSIS_TYPE_ANOMALY_DETECTION:
		return analyticsmodels.AnalysisTypeAnomalyDetection
	case pb.AnalysisType_ANALYSIS_TYPE_CROP_CLASSIFICATION:
		return analyticsmodels.AnalysisTypeCropClassification
	default:
		return analyticsmodels.AnalysisTypeUnspecified
	}
}

// DomainAnalysisTypeToProto converts a domain AnalysisType to the proto AnalysisType.
func DomainAnalysisTypeToProto(at analyticsmodels.AnalysisType) pb.AnalysisType {
	switch at {
	case analyticsmodels.AnalysisTypeStressDetection:
		return pb.AnalysisType_ANALYSIS_TYPE_STRESS_DETECTION
	case analyticsmodels.AnalysisTypeChangeDetection:
		return pb.AnalysisType_ANALYSIS_TYPE_CHANGE_DETECTION
	case analyticsmodels.AnalysisTypeTemporalTrend:
		return pb.AnalysisType_ANALYSIS_TYPE_TEMPORAL_TREND
	case analyticsmodels.AnalysisTypeAnomalyDetection:
		return pb.AnalysisType_ANALYSIS_TYPE_ANOMALY_DETECTION
	case analyticsmodels.AnalysisTypeCropClassification:
		return pb.AnalysisType_ANALYSIS_TYPE_CROP_CLASSIFICATION
	default:
		return pb.AnalysisType_ANALYSIS_TYPE_UNSPECIFIED
	}
}

// ---- Domain -> Proto conversions ----

// StressAlertToProto converts a domain StressAlert to its proto representation.
func StressAlertToProto(a *analyticsmodels.StressAlert) *pb.StressAlert {
	if a == nil {
		return nil
	}

	alert := &pb.StressAlert{
		Id:                   a.UUID,
		TenantId:             a.TenantID,
		FarmId:               a.FarmID,
		FieldId:              a.FieldID,
		StressType:           DomainStressTypeToProto(a.StressType),
		Severity:             DomainSeverityLevelToProto(a.Severity),
		Confidence:           a.Confidence,
		AffectedAreaHectares: a.AffectedAreaHectares,
		AffectedPercentage:   a.AffectedPercentage,
		BboxGeojson:          ptr.Deref(a.BboxGeoJSON),
		Description:          ptr.Deref(a.Description),
		Recommendation:       ptr.Deref(a.Recommendation),
		Acknowledged:         a.Acknowledged,
		DetectedAt:           timestamppb.New(a.DetectedAt),
		CreatedAt:            timestamppb.New(a.CreatedAt),
	}

	return alert
}

// StressAlertsToProto converts a slice of domain StressAlerts to their proto representations.
func StressAlertsToProto(alerts []analyticsmodels.StressAlert) []*pb.StressAlert {
	if alerts == nil {
		return nil
	}
	result := make([]*pb.StressAlert, len(alerts))
	for i := range alerts {
		result[i] = StressAlertToProto(&alerts[i])
	}
	return result
}

// TemporalAnalysisToProto converts a domain TemporalAnalysis to its proto representation.
func TemporalAnalysisToProto(t *analyticsmodels.TemporalAnalysis) *pb.TemporalAnalysis {
	if t == nil {
		return nil
	}

	return &pb.TemporalAnalysis{
		Id:               t.UUID,
		TenantId:         t.TenantID,
		FarmId:           t.FarmID,
		FieldId:          t.FieldID,
		AnalysisType:     DomainAnalysisTypeToProto(t.AnalysisType),
		MetricName:       t.MetricName,
		TrendSlope:       t.TrendSlope,
		TrendRSquared:    t.TrendRSquared,
		CurrentValue:     t.CurrentValue,
		BaselineValue:    t.BaselineValue,
		DeviationPercent: t.DeviationPercent,
		PeriodStart:      timestamppb.New(t.PeriodStart),
		PeriodEnd:        timestamppb.New(t.PeriodEnd),
		CreatedAt:        timestamppb.New(t.CreatedAt),
	}
}

// FieldAnalyticsSummaryToProto converts a domain FieldAnalyticsSummary to its proto representation.
func FieldAnalyticsSummaryToProto(s *analyticsmodels.FieldAnalyticsSummary) *pb.GetFieldAnalyticsSummaryResponse {
	if s == nil {
		return nil
	}

	resp := &pb.GetFieldAnalyticsSummaryResponse{
		ActiveStressAlerts: s.ActiveStressAlerts,
		HealthScore:        s.HealthScore,
		NdviTrend:          s.NdviTrend,
		DominantStressType: s.DominantStressType,
	}

	if s.LastAnalysis != nil {
		resp.LastAnalysis = timestamppb.New(*s.LastAnalysis)
	}

	return resp
}
