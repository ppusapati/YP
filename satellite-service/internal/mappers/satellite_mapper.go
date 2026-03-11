package mappers

import (
	"time"

	pb "p9e.in/samavaya/agriculture/satellite-service/api/v1"
	"p9e.in/samavaya/agriculture/satellite-service/internal/models"

	"google.golang.org/protobuf/types/known/timestamppb"
)

// ---------------------------------------------------------------------------
// SatelliteProvider mapping
// ---------------------------------------------------------------------------

func ProviderToProto(p models.SatelliteProvider) pb.SatelliteProvider {
	switch p {
	case models.SatelliteProviderSentinel2:
		return pb.SatelliteProvider_SATELLITE_PROVIDER_SENTINEL2
	case models.SatelliteProviderLandsat8:
		return pb.SatelliteProvider_SATELLITE_PROVIDER_LANDSAT8
	case models.SatelliteProviderPlanet:
		return pb.SatelliteProvider_SATELLITE_PROVIDER_PLANET
	case models.SatelliteProviderCustom:
		return pb.SatelliteProvider_SATELLITE_PROVIDER_CUSTOM
	default:
		return pb.SatelliteProvider_SATELLITE_PROVIDER_UNSPECIFIED
	}
}

func ProviderFromProto(p pb.SatelliteProvider) models.SatelliteProvider {
	switch p {
	case pb.SatelliteProvider_SATELLITE_PROVIDER_SENTINEL2:
		return models.SatelliteProviderSentinel2
	case pb.SatelliteProvider_SATELLITE_PROVIDER_LANDSAT8:
		return models.SatelliteProviderLandsat8
	case pb.SatelliteProvider_SATELLITE_PROVIDER_PLANET:
		return models.SatelliteProviderPlanet
	case pb.SatelliteProvider_SATELLITE_PROVIDER_CUSTOM:
		return models.SatelliteProviderCustom
	default:
		return models.SatelliteProviderSentinel2
	}
}

// ---------------------------------------------------------------------------
// SpectralBand mapping
// ---------------------------------------------------------------------------

func BandToProto(b string) pb.SpectralBand {
	switch models.SpectralBand(b) {
	case models.SpectralBandRed:
		return pb.SpectralBand_SPECTRAL_BAND_RED
	case models.SpectralBandGreen:
		return pb.SpectralBand_SPECTRAL_BAND_GREEN
	case models.SpectralBandBlue:
		return pb.SpectralBand_SPECTRAL_BAND_BLUE
	case models.SpectralBandNIR:
		return pb.SpectralBand_SPECTRAL_BAND_NIR
	case models.SpectralBandSWIR:
		return pb.SpectralBand_SPECTRAL_BAND_SWIR
	case models.SpectralBandRedEdge:
		return pb.SpectralBand_SPECTRAL_BAND_REDEDGE
	default:
		return pb.SpectralBand_SPECTRAL_BAND_UNSPECIFIED
	}
}

func BandFromProto(b pb.SpectralBand) string {
	switch b {
	case pb.SpectralBand_SPECTRAL_BAND_RED:
		return string(models.SpectralBandRed)
	case pb.SpectralBand_SPECTRAL_BAND_GREEN:
		return string(models.SpectralBandGreen)
	case pb.SpectralBand_SPECTRAL_BAND_BLUE:
		return string(models.SpectralBandBlue)
	case pb.SpectralBand_SPECTRAL_BAND_NIR:
		return string(models.SpectralBandNIR)
	case pb.SpectralBand_SPECTRAL_BAND_SWIR:
		return string(models.SpectralBandSWIR)
	case pb.SpectralBand_SPECTRAL_BAND_REDEDGE:
		return string(models.SpectralBandRedEdge)
	default:
		return ""
	}
}

func BandsToProto(bands []string) []pb.SpectralBand {
	out := make([]pb.SpectralBand, 0, len(bands))
	for _, b := range bands {
		if pb := BandToProto(b); pb != pb.Number() { // always add
			out = append(out, BandToProto(b))
		}
	}
	return out
}

func BandsFromProto(bands []pb.SpectralBand) []string {
	out := make([]string, 0, len(bands))
	for _, b := range bands {
		if s := BandFromProto(b); s != "" {
			out = append(out, s)
		}
	}
	return out
}

// ---------------------------------------------------------------------------
// ProcessingStatus mapping
// ---------------------------------------------------------------------------

func StatusToProto(s models.ProcessingStatus) pb.ProcessingStatus {
	switch s {
	case models.ProcessingStatusPending:
		return pb.ProcessingStatus_PROCESSING_STATUS_PENDING
	case models.ProcessingStatusProcessing:
		return pb.ProcessingStatus_PROCESSING_STATUS_PROCESSING
	case models.ProcessingStatusCompleted:
		return pb.ProcessingStatus_PROCESSING_STATUS_COMPLETED
	case models.ProcessingStatusFailed:
		return pb.ProcessingStatus_PROCESSING_STATUS_FAILED
	default:
		return pb.ProcessingStatus_PROCESSING_STATUS_UNSPECIFIED
	}
}

func StatusFromProto(s pb.ProcessingStatus) models.ProcessingStatus {
	switch s {
	case pb.ProcessingStatus_PROCESSING_STATUS_PENDING:
		return models.ProcessingStatusPending
	case pb.ProcessingStatus_PROCESSING_STATUS_PROCESSING:
		return models.ProcessingStatusProcessing
	case pb.ProcessingStatus_PROCESSING_STATUS_COMPLETED:
		return models.ProcessingStatusCompleted
	case pb.ProcessingStatus_PROCESSING_STATUS_FAILED:
		return models.ProcessingStatusFailed
	default:
		return models.ProcessingStatusPending
	}
}

// ---------------------------------------------------------------------------
// StressType mapping
// ---------------------------------------------------------------------------

func StressTypeToProto(s models.StressType) pb.StressType {
	switch s {
	case models.StressTypeWater:
		return pb.StressType_STRESS_TYPE_WATER
	case models.StressTypeNutrient:
		return pb.StressType_STRESS_TYPE_NUTRIENT
	case models.StressTypeDisease:
		return pb.StressType_STRESS_TYPE_DISEASE
	case models.StressTypePest:
		return pb.StressType_STRESS_TYPE_PEST
	default:
		return pb.StressType_STRESS_TYPE_UNSPECIFIED
	}
}

func StressTypeFromProto(s pb.StressType) models.StressType {
	switch s {
	case pb.StressType_STRESS_TYPE_WATER:
		return models.StressTypeWater
	case pb.StressType_STRESS_TYPE_NUTRIENT:
		return models.StressTypeNutrient
	case pb.StressType_STRESS_TYPE_DISEASE:
		return models.StressTypeDisease
	case pb.StressType_STRESS_TYPE_PEST:
		return models.StressTypePest
	default:
		return models.StressTypeWater
	}
}

// ---------------------------------------------------------------------------
// BoundingBox mapping
// ---------------------------------------------------------------------------

func BboxToProto(b *models.BoundingBox) *pb.BoundingBox {
	if b == nil {
		return nil
	}
	return &pb.BoundingBox{
		MinLat: b.MinLat,
		MinLon: b.MinLon,
		MaxLat: b.MaxLat,
		MaxLon: b.MaxLon,
	}
}

func BboxFromProto(b *pb.BoundingBox) *models.BoundingBox {
	if b == nil {
		return nil
	}
	return &models.BoundingBox{
		MinLat: b.MinLat,
		MinLon: b.MinLon,
		MaxLat: b.MaxLat,
		MaxLon: b.MaxLon,
	}
}

// ---------------------------------------------------------------------------
// Timestamp helpers
// ---------------------------------------------------------------------------

func TimeToProto(t time.Time) *timestamppb.Timestamp {
	if t.IsZero() {
		return nil
	}
	return timestamppb.New(t)
}

func TimeFromProto(t *timestamppb.Timestamp) time.Time {
	if t == nil {
		return time.Time{}
	}
	return t.AsTime()
}

func OptionalTimeToProto(t *time.Time) *timestamppb.Timestamp {
	if t == nil {
		return nil
	}
	return timestamppb.New(*t)
}

// ---------------------------------------------------------------------------
// SatelliteImage mapping
// ---------------------------------------------------------------------------

func SatelliteImageToProto(m *models.SatelliteImage) *pb.SatelliteImage {
	if m == nil {
		return nil
	}
	img := &pb.SatelliteImage{
		Id:                m.UUID,
		TenantId:          m.TenantID,
		FieldId:           m.FieldID,
		FarmId:            m.FarmID,
		SatelliteProvider: ProviderToProto(m.SatelliteProvider),
		AcquisitionDate:   TimeToProto(m.AcquisitionDate),
		CloudCoverPct:     m.CloudCoverPct,
		ResolutionMeters:  m.ResolutionMeters,
		Bands:             BandsToProto(m.Bands),
		Bbox:              BboxToProto(m.Bbox),
		ImageUrl:          m.ImageURL,
		ProcessingStatus:  StatusToProto(m.ProcessingStatus),
		Version:           m.Version,
		CreatedAt:         TimeToProto(m.CreatedAt),
		UpdatedAt:         OptionalTimeToProto(m.UpdatedAt),
	}
	return img
}

func SatelliteImageFromProto(p *pb.SatelliteImage) *models.SatelliteImage {
	if p == nil {
		return nil
	}
	return &models.SatelliteImage{
		TenantID:          p.TenantId,
		FieldID:           p.FieldId,
		FarmID:            p.FarmId,
		SatelliteProvider: ProviderFromProto(p.SatelliteProvider),
		AcquisitionDate:   TimeFromProto(p.AcquisitionDate),
		CloudCoverPct:     p.CloudCoverPct,
		ResolutionMeters:  p.ResolutionMeters,
		Bands:             BandsFromProto(p.Bands),
		Bbox:              BboxFromProto(p.Bbox),
		ImageURL:          p.ImageUrl,
		ProcessingStatus:  StatusFromProto(p.ProcessingStatus),
		Version:           p.Version,
	}
}

func SatelliteImagesToProto(imgs []*models.SatelliteImage) []*pb.SatelliteImage {
	out := make([]*pb.SatelliteImage, len(imgs))
	for i, m := range imgs {
		out[i] = SatelliteImageToProto(m)
	}
	return out
}

// ---------------------------------------------------------------------------
// VegetationIndex mapping
// ---------------------------------------------------------------------------

func VegetationIndexToProto(m *models.VegetationIndex) *pb.VegetationIndex {
	if m == nil {
		return nil
	}
	return &pb.VegetationIndex{
		Id:         m.UUID,
		TenantId:   m.TenantID,
		ImageId:    m.ImageID,
		FieldId:    m.FieldID,
		IndexType:  string(m.IndexType),
		MinValue:   m.MinValue,
		MaxValue:   m.MaxValue,
		MeanValue:  m.MeanValue,
		StdDev:     m.StdDev,
		RasterUrl:  m.RasterURL,
		ComputedAt: TimeToProto(m.ComputedAt),
		Version:    m.Version,
		CreatedAt:  TimeToProto(m.CreatedAt),
		UpdatedAt:  OptionalTimeToProto(m.UpdatedAt),
	}
}

func VegetationIndicesToProto(indices []*models.VegetationIndex) []*pb.VegetationIndex {
	out := make([]*pb.VegetationIndex, len(indices))
	for i, m := range indices {
		out[i] = VegetationIndexToProto(m)
	}
	return out
}

// ---------------------------------------------------------------------------
// CropStressAlert mapping
// ---------------------------------------------------------------------------

func CropStressAlertToProto(m *models.CropStressAlert) *pb.CropStressAlert {
	if m == nil {
		return nil
	}
	return &pb.CropStressAlert{
		Id:              m.UUID,
		TenantId:        m.TenantID,
		FieldId:         m.FieldID,
		ImageId:         m.ImageID,
		StressDetected:  m.StressDetected,
		StressType:      StressTypeToProto(m.StressType),
		StressSeverity:  m.StressSeverity,
		AffectedAreaPct: m.AffectedAreaPct,
		Description:     m.Description,
		Recommendation:  m.Recommendation,
		AffectedBbox:    BboxToProto(m.AffectedBbox),
		Version:         m.Version,
		DetectedAt:      TimeToProto(m.DetectedAt),
		CreatedAt:       TimeToProto(m.CreatedAt),
		UpdatedAt:       OptionalTimeToProto(m.UpdatedAt),
	}
}

func CropStressAlertsToProto(alerts []*models.CropStressAlert) []*pb.CropStressAlert {
	out := make([]*pb.CropStressAlert, len(alerts))
	for i, m := range alerts {
		out[i] = CropStressAlertToProto(m)
	}
	return out
}

// ---------------------------------------------------------------------------
// TemporalAnalysis mapping
// ---------------------------------------------------------------------------

func TemporalDataPointToProto(dp models.TemporalDataPoint) *pb.TemporalDataPoint {
	return &pb.TemporalDataPoint{
		Date:      TimeToProto(dp.Date),
		MeanValue: dp.MeanValue,
		MinValue:  dp.MinValue,
		MaxValue:  dp.MaxValue,
	}
}

func TemporalDataPointsToProto(dps []models.TemporalDataPoint) []*pb.TemporalDataPoint {
	out := make([]*pb.TemporalDataPoint, len(dps))
	for i, dp := range dps {
		out[i] = TemporalDataPointToProto(dp)
	}
	return out
}

func TemporalAnalysisToProto(m *models.TemporalAnalysis) *pb.TemporalAnalysis {
	if m == nil {
		return nil
	}
	return &pb.TemporalAnalysis{
		Id:             m.UUID,
		TenantId:       m.TenantID,
		FieldId:        m.FieldID,
		IndexType:      string(m.IndexType),
		StartDate:      TimeToProto(m.StartDate),
		EndDate:        TimeToProto(m.EndDate),
		DataPoints:     TemporalDataPointsToProto(m.DataPoints),
		TrendSlope:     m.TrendSlope,
		TrendDirection: string(m.TrendDirection),
		ChangePct:      m.ChangePct,
		Version:        m.Version,
		CreatedAt:      TimeToProto(m.CreatedAt),
		UpdatedAt:      OptionalTimeToProto(m.UpdatedAt),
	}
}

// ---------------------------------------------------------------------------
// SatelliteTask mapping
// ---------------------------------------------------------------------------

func SatelliteTaskToProto(m *models.SatelliteTask) *pb.SatelliteTask {
	if m == nil {
		return nil
	}
	return &pb.SatelliteTask{
		Id:           m.UUID,
		TenantId:     m.TenantID,
		FieldId:      m.FieldID,
		TaskType:     m.TaskType,
		Status:       StatusToProto(m.Status),
		InputImageId: m.InputImageID,
		ResultId:     m.ResultID,
		ErrorMessage: m.ErrorMessage,
		RetryCount:   m.RetryCount,
		Version:      m.Version,
		CreatedAt:    TimeToProto(m.CreatedAt),
		UpdatedAt:    OptionalTimeToProto(m.UpdatedAt),
	}
}
