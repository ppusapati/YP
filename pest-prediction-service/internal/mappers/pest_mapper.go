package mappers

import (
	"encoding/json"

	"google.golang.org/protobuf/types/known/timestamppb"

	pb "p9e.in/samavaya/agriculture/pest-prediction-service/api/v1"
	pestmodels "p9e.in/samavaya/agriculture/pest-prediction-service/internal/models"
	"p9e.in/samavaya/packages/convert/ptr"
)

// ---------------------------------------------------------------------------
// Enum converters: Proto <-> Domain
// ---------------------------------------------------------------------------

// ProtoRiskLevelToDomain converts a proto RiskLevel to the domain RiskLevel.
func ProtoRiskLevelToDomain(r pb.RiskLevel) pestmodels.RiskLevel {
	switch r {
	case pb.RiskLevel_RISK_LEVEL_NONE:
		return pestmodels.RiskLevelNone
	case pb.RiskLevel_RISK_LEVEL_LOW:
		return pestmodels.RiskLevelLow
	case pb.RiskLevel_RISK_LEVEL_MODERATE:
		return pestmodels.RiskLevelModerate
	case pb.RiskLevel_RISK_LEVEL_HIGH:
		return pestmodels.RiskLevelHigh
	case pb.RiskLevel_RISK_LEVEL_CRITICAL:
		return pestmodels.RiskLevelCritical
	default:
		return pestmodels.RiskLevelUnspecified
	}
}

// DomainRiskLevelToProto converts a domain RiskLevel to the proto RiskLevel.
func DomainRiskLevelToProto(r pestmodels.RiskLevel) pb.RiskLevel {
	switch r {
	case pestmodels.RiskLevelNone:
		return pb.RiskLevel_RISK_LEVEL_NONE
	case pestmodels.RiskLevelLow:
		return pb.RiskLevel_RISK_LEVEL_LOW
	case pestmodels.RiskLevelModerate:
		return pb.RiskLevel_RISK_LEVEL_MODERATE
	case pestmodels.RiskLevelHigh:
		return pb.RiskLevel_RISK_LEVEL_HIGH
	case pestmodels.RiskLevelCritical:
		return pb.RiskLevel_RISK_LEVEL_CRITICAL
	default:
		return pb.RiskLevel_RISK_LEVEL_UNSPECIFIED
	}
}

// ProtoTreatmentTypeToDomain converts a proto TreatmentType to the domain TreatmentType.
func ProtoTreatmentTypeToDomain(t pb.TreatmentType) pestmodels.TreatmentType {
	switch t {
	case pb.TreatmentType_TREATMENT_TYPE_CHEMICAL:
		return pestmodels.TreatmentTypeChemical
	case pb.TreatmentType_TREATMENT_TYPE_BIOLOGICAL:
		return pestmodels.TreatmentTypeBiological
	case pb.TreatmentType_TREATMENT_TYPE_CULTURAL:
		return pestmodels.TreatmentTypeCultural
	case pb.TreatmentType_TREATMENT_TYPE_MECHANICAL:
		return pestmodels.TreatmentTypeMechanical
	default:
		return pestmodels.TreatmentTypeUnspecified
	}
}

// DomainTreatmentTypeToProto converts a domain TreatmentType to the proto TreatmentType.
func DomainTreatmentTypeToProto(t pestmodels.TreatmentType) pb.TreatmentType {
	switch t {
	case pestmodels.TreatmentTypeChemical:
		return pb.TreatmentType_TREATMENT_TYPE_CHEMICAL
	case pestmodels.TreatmentTypeBiological:
		return pb.TreatmentType_TREATMENT_TYPE_BIOLOGICAL
	case pestmodels.TreatmentTypeCultural:
		return pb.TreatmentType_TREATMENT_TYPE_CULTURAL
	case pestmodels.TreatmentTypeMechanical:
		return pb.TreatmentType_TREATMENT_TYPE_MECHANICAL
	default:
		return pb.TreatmentType_TREATMENT_TYPE_UNSPECIFIED
	}
}

// ProtoAlertStatusToDomain converts a proto AlertStatus to the domain AlertStatus.
func ProtoAlertStatusToDomain(s pb.AlertStatus) pestmodels.AlertStatus {
	switch s {
	case pb.AlertStatus_ALERT_STATUS_ACTIVE:
		return pestmodels.AlertStatusActive
	case pb.AlertStatus_ALERT_STATUS_ACKNOWLEDGED:
		return pestmodels.AlertStatusAcknowledged
	case pb.AlertStatus_ALERT_STATUS_RESOLVED:
		return pestmodels.AlertStatusResolved
	case pb.AlertStatus_ALERT_STATUS_EXPIRED:
		return pestmodels.AlertStatusExpired
	default:
		return pestmodels.AlertStatusUnspecified
	}
}

// DomainAlertStatusToProto converts a domain AlertStatus to the proto AlertStatus.
func DomainAlertStatusToProto(s pestmodels.AlertStatus) pb.AlertStatus {
	switch s {
	case pestmodels.AlertStatusActive:
		return pb.AlertStatus_ALERT_STATUS_ACTIVE
	case pestmodels.AlertStatusAcknowledged:
		return pb.AlertStatus_ALERT_STATUS_ACKNOWLEDGED
	case pestmodels.AlertStatusResolved:
		return pb.AlertStatus_ALERT_STATUS_RESOLVED
	case pestmodels.AlertStatusExpired:
		return pb.AlertStatus_ALERT_STATUS_EXPIRED
	default:
		return pb.AlertStatus_ALERT_STATUS_UNSPECIFIED
	}
}

// ProtoDamageLevelToDomain converts a proto DamageLevel to the domain DamageLevel.
func ProtoDamageLevelToDomain(d pb.DamageLevel) pestmodels.DamageLevel {
	switch d {
	case pb.DamageLevel_DAMAGE_LEVEL_NONE:
		return pestmodels.DamageLevelNone
	case pb.DamageLevel_DAMAGE_LEVEL_LIGHT:
		return pestmodels.DamageLevelLight
	case pb.DamageLevel_DAMAGE_LEVEL_MODERATE:
		return pestmodels.DamageLevelModerate
	case pb.DamageLevel_DAMAGE_LEVEL_SEVERE:
		return pestmodels.DamageLevelSevere
	case pb.DamageLevel_DAMAGE_LEVEL_DEVASTATING:
		return pestmodels.DamageLevelDevastating
	default:
		return pestmodels.DamageLevelUnspecified
	}
}

// DomainDamageLevelToProto converts a domain DamageLevel to the proto DamageLevel.
func DomainDamageLevelToProto(d pestmodels.DamageLevel) pb.DamageLevel {
	switch d {
	case pestmodels.DamageLevelNone:
		return pb.DamageLevel_DAMAGE_LEVEL_NONE
	case pestmodels.DamageLevelLight:
		return pb.DamageLevel_DAMAGE_LEVEL_LIGHT
	case pestmodels.DamageLevelModerate:
		return pb.DamageLevel_DAMAGE_LEVEL_MODERATE
	case pestmodels.DamageLevelSevere:
		return pb.DamageLevel_DAMAGE_LEVEL_SEVERE
	case pestmodels.DamageLevelDevastating:
		return pb.DamageLevel_DAMAGE_LEVEL_DEVASTATING
	default:
		return pb.DamageLevel_DAMAGE_LEVEL_UNSPECIFIED
	}
}

// ProtoGrowthStageToDomain converts a proto GrowthStage to the domain GrowthStage.
func ProtoGrowthStageToDomain(g pb.GrowthStage) pestmodels.GrowthStage {
	switch g {
	case pb.GrowthStage_GROWTH_STAGE_GERMINATION:
		return pestmodels.GrowthStageGermination
	case pb.GrowthStage_GROWTH_STAGE_SEEDLING:
		return pestmodels.GrowthStageSeedling
	case pb.GrowthStage_GROWTH_STAGE_VEGETATIVE:
		return pestmodels.GrowthStageVegetative
	case pb.GrowthStage_GROWTH_STAGE_FLOWERING:
		return pestmodels.GrowthStageFlowering
	case pb.GrowthStage_GROWTH_STAGE_FRUITING:
		return pestmodels.GrowthStageFruiting
	case pb.GrowthStage_GROWTH_STAGE_MATURATION:
		return pestmodels.GrowthStageMaturation
	case pb.GrowthStage_GROWTH_STAGE_HARVEST:
		return pestmodels.GrowthStageHarvest
	default:
		return pestmodels.GrowthStageUnspecified
	}
}

// DomainGrowthStageToProto converts a domain GrowthStage to the proto GrowthStage.
func DomainGrowthStageToProto(g pestmodels.GrowthStage) pb.GrowthStage {
	switch g {
	case pestmodels.GrowthStageGermination:
		return pb.GrowthStage_GROWTH_STAGE_GERMINATION
	case pestmodels.GrowthStageSeedling:
		return pb.GrowthStage_GROWTH_STAGE_SEEDLING
	case pestmodels.GrowthStageVegetative:
		return pb.GrowthStage_GROWTH_STAGE_VEGETATIVE
	case pestmodels.GrowthStageFlowering:
		return pb.GrowthStage_GROWTH_STAGE_FLOWERING
	case pestmodels.GrowthStageFruiting:
		return pb.GrowthStage_GROWTH_STAGE_FRUITING
	case pestmodels.GrowthStageMaturation:
		return pb.GrowthStage_GROWTH_STAGE_MATURATION
	case pestmodels.GrowthStageHarvest:
		return pb.GrowthStage_GROWTH_STAGE_HARVEST
	default:
		return pb.GrowthStage_GROWTH_STAGE_UNSPECIFIED
	}
}

// ---------------------------------------------------------------------------
// Domain -> Proto converters
// ---------------------------------------------------------------------------

// PestSpeciesToProto converts a domain PestSpecies to its proto representation.
func PestSpeciesToProto(s *pestmodels.PestSpecies) *pb.PestSpecies {
	if s == nil {
		return nil
	}

	species := &pb.PestSpecies{
		Id:             s.UUID,
		TenantId:       s.TenantID,
		CommonName:     s.CommonName,
		ScientificName: s.ScientificName,
		Family:         ptr.Deref(s.Family),
		Description:    ptr.Deref(s.Description),
		ImageUrl:       ptr.Deref(s.ImageURL),
		Version:        s.Version,
		CreatedAt:      timestamppb.New(s.CreatedAt),
	}

	if s.UpdatedAt != nil {
		species.UpdatedAt = timestamppb.New(*s.UpdatedAt)
	}

	// Unmarshal affected crops
	if len(s.AffectedCrops) > 0 {
		var crops []string
		_ = json.Unmarshal(s.AffectedCrops, &crops)
		species.AffectedCrops = crops
	}

	// Unmarshal favorable conditions
	if len(s.FavorableConditions) > 0 {
		var conditions []string
		_ = json.Unmarshal(s.FavorableConditions, &conditions)
		species.FavorableConditions = conditions
	}

	return species
}

// PestSpeciesListToProto converts a slice of domain PestSpecies to proto.
func PestSpeciesListToProto(species []pestmodels.PestSpecies) []*pb.PestSpecies {
	if species == nil {
		return nil
	}
	result := make([]*pb.PestSpecies, len(species))
	for i := range species {
		result[i] = PestSpeciesToProto(&species[i])
	}
	return result
}

// PestPredictionToProto converts a domain PestPrediction to its proto representation.
func PestPredictionToProto(p *pestmodels.PestPrediction) *pb.PestPrediction {
	if p == nil {
		return nil
	}

	prediction := &pb.PestPrediction{
		Id:                        p.UUID,
		TenantId:                  p.TenantID,
		FarmId:                    p.FarmID,
		FieldId:                   p.FieldID,
		PestSpeciesId:             p.PestSpeciesUUID,
		PredictionDate:            timestamppb.New(p.PredictionDate),
		RiskLevel:                 DomainRiskLevelToProto(p.RiskLevel),
		RiskScore:                 int32(p.RiskScore),
		ConfidencePct:             p.ConfidencePct,
		CropType:                  p.CropType,
		GeographicRiskFactor:      p.GeographicRiskFactor,
		HistoricalOccurrenceCount: int32(p.HistoricalOccurrenceCount),
		Version:                   p.Version,
		CreatedBy:                 p.CreatedBy,
		CreatedAt:                 timestamppb.New(p.CreatedAt),
	}

	// Weather factors
	if p.TemperatureCelsius != nil || p.HumidityPct != nil || p.RainfallMm != nil || p.WindSpeedKmh != nil {
		prediction.WeatherFactors = &pb.WeatherFactors{
			TemperatureCelsius: ptr.Deref(p.TemperatureCelsius),
			HumidityPct:        ptr.Deref(p.HumidityPct),
			RainfallMm:         ptr.Deref(p.RainfallMm),
			WindSpeedKmh:       ptr.Deref(p.WindSpeedKmh),
		}
	}

	// Growth stage
	if p.GrowthStage != nil {
		prediction.GrowthStage = DomainGrowthStageToProto(*p.GrowthStage)
	}

	// Dates
	if p.PredictedOnsetDate != nil {
		prediction.PredictedOnsetDate = timestamppb.New(*p.PredictedOnsetDate)
	}
	if p.PredictedPeakDate != nil {
		prediction.PredictedPeakDate = timestamppb.New(*p.PredictedPeakDate)
	}
	if p.TreatmentWindowStart != nil {
		prediction.TreatmentWindowStart = timestamppb.New(*p.TreatmentWindowStart)
	}
	if p.TreatmentWindowEnd != nil {
		prediction.TreatmentWindowEnd = timestamppb.New(*p.TreatmentWindowEnd)
	}
	if p.UpdatedAt != nil {
		prediction.UpdatedAt = timestamppb.New(*p.UpdatedAt)
	}

	// Recommended treatments
	if len(p.RecommendedTreatments) > 0 {
		var treatments []pestmodels.RecommendedTreatment
		if err := json.Unmarshal(p.RecommendedTreatments, &treatments); err == nil {
			prediction.RecommendedTreatments = make([]*pb.RecommendedTreatment, len(treatments))
			for i, t := range treatments {
				prediction.RecommendedTreatments[i] = &pb.RecommendedTreatment{
					TreatmentType:     DomainTreatmentTypeToProto(t.TreatmentType),
					ProductName:       t.ProductName,
					ApplicationRate:   t.ApplicationRate,
					ApplicationMethod: t.ApplicationMethod,
					Timing:            t.Timing,
					SafetyInterval:    t.SafetyInterval,
				}
			}
		}
	}

	return prediction
}

// PestPredictionsToProto converts a slice of domain PestPrediction to proto.
func PestPredictionsToProto(predictions []pestmodels.PestPrediction) []*pb.PestPrediction {
	if predictions == nil {
		return nil
	}
	result := make([]*pb.PestPrediction, len(predictions))
	for i := range predictions {
		result[i] = PestPredictionToProto(&predictions[i])
	}
	return result
}

// PestAlertToProto converts a domain PestAlert to its proto representation.
func PestAlertToProto(a *pestmodels.PestAlert) *pb.PestAlert {
	if a == nil {
		return nil
	}

	alert := &pb.PestAlert{
		Id:            a.UUID,
		TenantId:      a.TenantID,
		PredictionId:  a.PredictionUUID,
		FarmId:        a.FarmID,
		FieldId:       a.FieldID,
		PestSpeciesId: a.PestSpeciesUUID,
		RiskLevel:     DomainRiskLevelToProto(a.RiskLevel),
		Status:        DomainAlertStatusToProto(a.Status),
		Title:         a.Title,
		Message:       a.Message,
		Version:       a.Version,
		CreatedAt:     timestamppb.New(a.CreatedAt),
	}

	if a.AcknowledgedAt != nil {
		alert.AcknowledgedAt = timestamppb.New(*a.AcknowledgedAt)
	}
	if a.AcknowledgedBy != nil {
		alert.AcknowledgedBy = *a.AcknowledgedBy
	}
	if a.UpdatedAt != nil {
		alert.UpdatedAt = timestamppb.New(*a.UpdatedAt)
	}

	return alert
}

// PestAlertsToProto converts a slice of domain PestAlert to proto.
func PestAlertsToProto(alerts []pestmodels.PestAlert) []*pb.PestAlert {
	if alerts == nil {
		return nil
	}
	result := make([]*pb.PestAlert, len(alerts))
	for i := range alerts {
		result[i] = PestAlertToProto(&alerts[i])
	}
	return result
}

// PestObservationToProto converts a domain PestObservation to its proto representation.
func PestObservationToProto(o *pestmodels.PestObservation) *pb.PestObservation {
	if o == nil {
		return nil
	}

	obs := &pb.PestObservation{
		Id:            o.UUID,
		TenantId:      o.TenantID,
		FarmId:        o.FarmID,
		FieldId:       o.FieldID,
		PestSpeciesId: o.PestSpeciesUUID,
		PestCount:     int32(o.PestCount),
		DamageLevel:   DomainDamageLevelToProto(o.DamageLevel),
		TrapType:      ptr.Deref(o.TrapType),
		ImageUrl:      ptr.Deref(o.ImageURL),
		Latitude:      ptr.Deref(o.Latitude),
		Longitude:     ptr.Deref(o.Longitude),
		Notes:         ptr.Deref(o.Notes),
		ObservedBy:    o.ObservedBy,
		ObservedAt:    timestamppb.New(o.ObservedAt),
		Version:       o.Version,
		CreatedAt:     timestamppb.New(o.CreatedAt),
	}

	if o.UpdatedAt != nil {
		obs.UpdatedAt = timestamppb.New(*o.UpdatedAt)
	}

	return obs
}

// PestObservationsToProto converts a slice of domain PestObservation to proto.
func PestObservationsToProto(observations []pestmodels.PestObservation) []*pb.PestObservation {
	if observations == nil {
		return nil
	}
	result := make([]*pb.PestObservation, len(observations))
	for i := range observations {
		result[i] = PestObservationToProto(&observations[i])
	}
	return result
}

// PestRiskMapToProto converts a domain PestRiskMap to its proto representation.
func PestRiskMapToProto(m *pestmodels.PestRiskMap) *pb.PestRiskMap {
	if m == nil {
		return nil
	}

	riskMap := &pb.PestRiskMap{
		Id:               m.UUID,
		TenantId:         m.TenantID,
		PestSpeciesId:    m.PestSpeciesUUID,
		Region:           m.Region,
		OverallRiskLevel: DomainRiskLevelToProto(m.OverallRiskLevel),
		Geojson:          m.GeoJSON,
		ValidFrom:        timestamppb.New(m.ValidFrom),
		ValidUntil:       timestamppb.New(m.ValidUntil),
		Version:          m.Version,
		CreatedAt:        timestamppb.New(m.CreatedAt),
	}

	if m.UpdatedAt != nil {
		riskMap.UpdatedAt = timestamppb.New(*m.UpdatedAt)
	}

	return riskMap
}

// RecommendedTreatmentsToProto converts a slice of domain RecommendedTreatment to proto.
func RecommendedTreatmentsToProto(treatments []pestmodels.RecommendedTreatment) []*pb.RecommendedTreatment {
	if treatments == nil {
		return nil
	}
	result := make([]*pb.RecommendedTreatment, len(treatments))
	for i, t := range treatments {
		result[i] = &pb.RecommendedTreatment{
			TreatmentType:     DomainTreatmentTypeToProto(t.TreatmentType),
			ProductName:       t.ProductName,
			ApplicationRate:   t.ApplicationRate,
			ApplicationMethod: t.ApplicationMethod,
			Timing:            t.Timing,
			SafetyInterval:    t.SafetyInterval,
		}
	}
	return result
}

// ---------------------------------------------------------------------------
// Proto -> Domain converters
// ---------------------------------------------------------------------------

// ProtoWeatherFactorsToDomain converts proto WeatherFactors to domain.
func ProtoWeatherFactorsToDomain(w *pb.WeatherFactors) pestmodels.WeatherFactors {
	if w == nil {
		return pestmodels.WeatherFactors{}
	}
	return pestmodels.WeatherFactors{
		TemperatureCelsius: w.GetTemperatureCelsius(),
		HumidityPct:        w.GetHumidityPct(),
		RainfallMm:         w.GetRainfallMm(),
		WindSpeedKmh:       w.GetWindSpeedKmh(),
	}
}

// PredictPestRiskRequestToDomain converts a proto PredictPestRiskRequest to domain params.
func PredictPestRiskRequestToDomain(req *pb.PredictPestRiskRequest, tenantID string) *pestmodels.PredictPestRiskParams {
	params := &pestmodels.PredictPestRiskParams{
		TenantID:      tenantID,
		FarmID:        req.GetFarmId(),
		FieldID:       req.GetFieldId(),
		PestSpeciesID: req.GetPestSpeciesId(),
		CropType:      req.GetCropType(),
		Weather:       ProtoWeatherFactorsToDomain(req.GetWeather()),
		Latitude:      req.GetLatitude(),
		Longitude:     req.GetLongitude(),
	}

	if req.GetGrowthStage() != pb.GrowthStage_GROWTH_STAGE_UNSPECIFIED {
		gs := ProtoGrowthStageToDomain(req.GetGrowthStage())
		params.GrowthStage = &gs
	}

	return params
}

// ReportObservationRequestToDomain converts a proto ReportObservationRequest to domain params.
func ReportObservationRequestToDomain(req *pb.ReportObservationRequest, tenantID, userID string) *pestmodels.ReportObservationParams {
	params := &pestmodels.ReportObservationParams{
		TenantID:      tenantID,
		FarmID:        req.GetFarmId(),
		FieldID:       req.GetFieldId(),
		PestSpeciesID: req.GetPestSpeciesId(),
		PestCount:     int(req.GetPestCount()),
		DamageLevel:   ProtoDamageLevelToDomain(req.GetDamageLevel()),
		TrapType:      ptr.StringOrNil(req.GetTrapType()),
		ImageURL:      ptr.StringOrNil(req.GetImageUrl()),
		Notes:         ptr.StringOrNil(req.GetNotes()),
		ObservedBy:    userID,
	}

	if req.GetLatitude() != 0 {
		params.Latitude = ptr.Float64(req.GetLatitude())
	}
	if req.GetLongitude() != 0 {
		params.Longitude = ptr.Float64(req.GetLongitude())
	}

	return params
}
