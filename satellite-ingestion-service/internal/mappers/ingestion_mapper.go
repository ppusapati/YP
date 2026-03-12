package mappers

import (
	"google.golang.org/protobuf/types/known/timestamppb"

	pb "p9e.in/samavaya/agriculture/satellite-ingestion-service/api/v1"
	ingestionmodels "p9e.in/samavaya/agriculture/satellite-ingestion-service/internal/models"
	"p9e.in/samavaya/packages/convert/ptr"
)

// ---- Proto enum <-> Domain enum conversions ----

// ProtoProviderToDomain converts a proto SatelliteProvider to the domain SatelliteProvider.
func ProtoProviderToDomain(p pb.SatelliteProvider) ingestionmodels.SatelliteProvider {
	switch p {
	case pb.SatelliteProvider_SATELLITE_PROVIDER_SENTINEL2:
		return ingestionmodels.SatelliteProviderSentinel2
	case pb.SatelliteProvider_SATELLITE_PROVIDER_LANDSAT:
		return ingestionmodels.SatelliteProviderLandsat
	case pb.SatelliteProvider_SATELLITE_PROVIDER_PLANETSCOPE:
		return ingestionmodels.SatelliteProviderPlanetScope
	default:
		return ingestionmodels.SatelliteProviderUnspecified
	}
}

// DomainProviderToProto converts a domain SatelliteProvider to the proto SatelliteProvider.
func DomainProviderToProto(p ingestionmodels.SatelliteProvider) pb.SatelliteProvider {
	switch p {
	case ingestionmodels.SatelliteProviderSentinel2:
		return pb.SatelliteProvider_SATELLITE_PROVIDER_SENTINEL2
	case ingestionmodels.SatelliteProviderLandsat:
		return pb.SatelliteProvider_SATELLITE_PROVIDER_LANDSAT
	case ingestionmodels.SatelliteProviderPlanetScope:
		return pb.SatelliteProvider_SATELLITE_PROVIDER_PLANETSCOPE
	default:
		return pb.SatelliteProvider_SATELLITE_PROVIDER_UNSPECIFIED
	}
}

// ProtoIngestionStatusToDomain converts a proto IngestionStatus to the domain IngestionStatus.
func ProtoIngestionStatusToDomain(s pb.IngestionStatus) ingestionmodels.IngestionStatus {
	switch s {
	case pb.IngestionStatus_INGESTION_STATUS_QUEUED:
		return ingestionmodels.IngestionStatusQueued
	case pb.IngestionStatus_INGESTION_STATUS_DOWNLOADING:
		return ingestionmodels.IngestionStatusDownloading
	case pb.IngestionStatus_INGESTION_STATUS_VALIDATING:
		return ingestionmodels.IngestionStatusValidating
	case pb.IngestionStatus_INGESTION_STATUS_STORED:
		return ingestionmodels.IngestionStatusStored
	case pb.IngestionStatus_INGESTION_STATUS_FAILED:
		return ingestionmodels.IngestionStatusFailed
	default:
		return ingestionmodels.IngestionStatusUnspecified
	}
}

// DomainIngestionStatusToProto converts a domain IngestionStatus to the proto IngestionStatus.
func DomainIngestionStatusToProto(s ingestionmodels.IngestionStatus) pb.IngestionStatus {
	switch s {
	case ingestionmodels.IngestionStatusQueued:
		return pb.IngestionStatus_INGESTION_STATUS_QUEUED
	case ingestionmodels.IngestionStatusDownloading:
		return pb.IngestionStatus_INGESTION_STATUS_DOWNLOADING
	case ingestionmodels.IngestionStatusValidating:
		return pb.IngestionStatus_INGESTION_STATUS_VALIDATING
	case ingestionmodels.IngestionStatusStored:
		return pb.IngestionStatus_INGESTION_STATUS_STORED
	case ingestionmodels.IngestionStatusFailed:
		return pb.IngestionStatus_INGESTION_STATUS_FAILED
	default:
		return pb.IngestionStatus_INGESTION_STATUS_UNSPECIFIED
	}
}

// ProtoSpectralBandToDomain converts a proto SpectralBand to the domain SpectralBand.
func ProtoSpectralBandToDomain(b pb.SpectralBand) ingestionmodels.SpectralBand {
	switch b {
	case pb.SpectralBand_SPECTRAL_BAND_BLUE:
		return ingestionmodels.SpectralBandBlue
	case pb.SpectralBand_SPECTRAL_BAND_GREEN:
		return ingestionmodels.SpectralBandGreen
	case pb.SpectralBand_SPECTRAL_BAND_RED:
		return ingestionmodels.SpectralBandRed
	case pb.SpectralBand_SPECTRAL_BAND_NIR:
		return ingestionmodels.SpectralBandNIR
	case pb.SpectralBand_SPECTRAL_BAND_SWIR1:
		return ingestionmodels.SpectralBandSWIR1
	case pb.SpectralBand_SPECTRAL_BAND_SWIR2:
		return ingestionmodels.SpectralBandSWIR2
	case pb.SpectralBand_SPECTRAL_BAND_RED_EDGE1:
		return ingestionmodels.SpectralBandRedEdge1
	case pb.SpectralBand_SPECTRAL_BAND_RED_EDGE2:
		return ingestionmodels.SpectralBandRedEdge2
	case pb.SpectralBand_SPECTRAL_BAND_RED_EDGE3:
		return ingestionmodels.SpectralBandRedEdge3
	default:
		return ingestionmodels.SpectralBandUnspecified
	}
}

// DomainSpectralBandToProto converts a domain SpectralBand to the proto SpectralBand.
func DomainSpectralBandToProto(b ingestionmodels.SpectralBand) pb.SpectralBand {
	switch b {
	case ingestionmodels.SpectralBandBlue:
		return pb.SpectralBand_SPECTRAL_BAND_BLUE
	case ingestionmodels.SpectralBandGreen:
		return pb.SpectralBand_SPECTRAL_BAND_GREEN
	case ingestionmodels.SpectralBandRed:
		return pb.SpectralBand_SPECTRAL_BAND_RED
	case ingestionmodels.SpectralBandNIR:
		return pb.SpectralBand_SPECTRAL_BAND_NIR
	case ingestionmodels.SpectralBandSWIR1:
		return pb.SpectralBand_SPECTRAL_BAND_SWIR1
	case ingestionmodels.SpectralBandSWIR2:
		return pb.SpectralBand_SPECTRAL_BAND_SWIR2
	case ingestionmodels.SpectralBandRedEdge1:
		return pb.SpectralBand_SPECTRAL_BAND_RED_EDGE1
	case ingestionmodels.SpectralBandRedEdge2:
		return pb.SpectralBand_SPECTRAL_BAND_RED_EDGE2
	case ingestionmodels.SpectralBandRedEdge3:
		return pb.SpectralBand_SPECTRAL_BAND_RED_EDGE3
	default:
		return pb.SpectralBand_SPECTRAL_BAND_UNSPECIFIED
	}
}

// ---- Domain -> Proto conversions ----

// IngestionTaskToProto converts a domain IngestionTask to its proto representation.
func IngestionTaskToProto(t *ingestionmodels.IngestionTask) *pb.IngestionTask {
	if t == nil {
		return nil
	}

	task := &pb.IngestionTask{
		Id:                t.UUID,
		TenantId:          t.TenantID,
		FarmId:            t.FarmUUID,
		Provider:          DomainProviderToProto(t.Provider),
		SceneId:           t.SceneID,
		Status:            DomainIngestionStatusToProto(t.Status),
		S3Bucket:          ptr.Deref(t.S3Bucket),
		S3Key:             ptr.Deref(t.S3Key),
		CloudCoverPercent: t.CloudCoverPercent,
		ResolutionMeters:  t.ResolutionMeters,
		BboxGeojson:       ptr.Deref(t.BboxGeoJSON),
		FileSizeBytes:     t.FileSizeBytes,
		ChecksumSha256:    ptr.Deref(t.ChecksumSHA256),
		ErrorMessage:      ptr.Deref(t.ErrorMessage),
		RetryCount:        t.RetryCount,
		CreatedAt:         timestamppb.New(t.CreatedAt),
	}

	// Convert bands
	if len(t.Bands) > 0 {
		task.Bands = make([]pb.SpectralBand, len(t.Bands))
		for i, band := range t.Bands {
			task.Bands[i] = DomainSpectralBandToProto(band)
		}
	}

	if t.AcquisitionDate != nil {
		task.AcquisitionDate = timestamppb.New(*t.AcquisitionDate)
	}

	if t.UpdatedAt != nil {
		task.UpdatedAt = timestamppb.New(*t.UpdatedAt)
	}

	if t.CompletedAt != nil {
		task.CompletedAt = timestamppb.New(*t.CompletedAt)
	}

	return task
}

// IngestionTasksToProto converts a slice of domain IngestionTasks to their proto representations.
func IngestionTasksToProto(tasks []ingestionmodels.IngestionTask) []*pb.IngestionTask {
	if tasks == nil {
		return nil
	}
	result := make([]*pb.IngestionTask, len(tasks))
	for i := range tasks {
		result[i] = IngestionTaskToProto(&tasks[i])
	}
	return result
}

// ---- Proto -> Domain conversions ----

// RequestIngestionToDomain converts a RequestIngestion proto request to a domain IngestionTask.
func RequestIngestionToDomain(req *pb.RequestIngestionRequest, tenantID, userID string) *ingestionmodels.IngestionTask {
	task := &ingestionmodels.IngestionTask{
		TenantID:          tenantID,
		FarmUUID:          req.GetFarmId(),
		Provider:          ProtoProviderToDomain(req.GetProvider()),
		CloudCoverPercent: req.GetMaxCloudCover(),
		Status:            ingestionmodels.IngestionStatusQueued,
	}

	task.CreatedBy = userID

	// Convert bands
	if len(req.GetBands()) > 0 {
		task.Bands = make([]ingestionmodels.SpectralBand, 0, len(req.GetBands()))
		for _, b := range req.GetBands() {
			band := ProtoSpectralBandToDomain(b)
			if band != ingestionmodels.SpectralBandUnspecified {
				task.Bands = append(task.Bands, band)
			}
		}
	}

	if req.GetDateFrom() != nil {
		acqDate := req.GetDateFrom().AsTime()
		task.AcquisitionDate = &acqDate
	}

	return task
}
