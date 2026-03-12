package mappers

import (
	"google.golang.org/protobuf/types/known/timestamppb"

	pb "p9e.in/samavaya/agriculture/vegetation-index-service/api/v1"
	vimodels "p9e.in/samavaya/agriculture/vegetation-index-service/internal/models"
	"p9e.in/samavaya/packages/convert/ptr"
)

// ---- Proto enum <-> Domain enum conversions ----

// ProtoIndexTypeToDomain converts a proto VegetationIndexType to the domain VegetationIndexType.
func ProtoIndexTypeToDomain(t pb.VegetationIndexType) vimodels.VegetationIndexType {
	switch t {
	case pb.VegetationIndexType_VEGETATION_INDEX_TYPE_NDVI:
		return vimodels.VegetationIndexTypeNDVI
	case pb.VegetationIndexType_VEGETATION_INDEX_TYPE_NDWI:
		return vimodels.VegetationIndexTypeNDWI
	case pb.VegetationIndexType_VEGETATION_INDEX_TYPE_EVI:
		return vimodels.VegetationIndexTypeEVI
	case pb.VegetationIndexType_VEGETATION_INDEX_TYPE_SAVI:
		return vimodels.VegetationIndexTypeSAVI
	case pb.VegetationIndexType_VEGETATION_INDEX_TYPE_MSAVI:
		return vimodels.VegetationIndexTypeMSAVI
	case pb.VegetationIndexType_VEGETATION_INDEX_TYPE_NDRE:
		return vimodels.VegetationIndexTypeNDRE
	case pb.VegetationIndexType_VEGETATION_INDEX_TYPE_GNDVI:
		return vimodels.VegetationIndexTypeGNDVI
	case pb.VegetationIndexType_VEGETATION_INDEX_TYPE_LAI:
		return vimodels.VegetationIndexTypeLAI
	default:
		return vimodels.VegetationIndexTypeUnspecified
	}
}

// DomainIndexTypeToProto converts a domain VegetationIndexType to the proto VegetationIndexType.
func DomainIndexTypeToProto(t vimodels.VegetationIndexType) pb.VegetationIndexType {
	switch t {
	case vimodels.VegetationIndexTypeNDVI:
		return pb.VegetationIndexType_VEGETATION_INDEX_TYPE_NDVI
	case vimodels.VegetationIndexTypeNDWI:
		return pb.VegetationIndexType_VEGETATION_INDEX_TYPE_NDWI
	case vimodels.VegetationIndexTypeEVI:
		return pb.VegetationIndexType_VEGETATION_INDEX_TYPE_EVI
	case vimodels.VegetationIndexTypeSAVI:
		return pb.VegetationIndexType_VEGETATION_INDEX_TYPE_SAVI
	case vimodels.VegetationIndexTypeMSAVI:
		return pb.VegetationIndexType_VEGETATION_INDEX_TYPE_MSAVI
	case vimodels.VegetationIndexTypeNDRE:
		return pb.VegetationIndexType_VEGETATION_INDEX_TYPE_NDRE
	case vimodels.VegetationIndexTypeGNDVI:
		return pb.VegetationIndexType_VEGETATION_INDEX_TYPE_GNDVI
	case vimodels.VegetationIndexTypeLAI:
		return pb.VegetationIndexType_VEGETATION_INDEX_TYPE_LAI
	default:
		return pb.VegetationIndexType_VEGETATION_INDEX_TYPE_UNSPECIFIED
	}
}

// ProtoComputeStatusToDomain converts a proto ComputeStatus to the domain ComputeStatus.
func ProtoComputeStatusToDomain(s pb.ComputeStatus) vimodels.ComputeStatus {
	switch s {
	case pb.ComputeStatus_COMPUTE_STATUS_QUEUED:
		return vimodels.ComputeStatusQueued
	case pb.ComputeStatus_COMPUTE_STATUS_COMPUTING:
		return vimodels.ComputeStatusComputing
	case pb.ComputeStatus_COMPUTE_STATUS_INTERSECTING:
		return vimodels.ComputeStatusIntersecting
	case pb.ComputeStatus_COMPUTE_STATUS_COMPLETED:
		return vimodels.ComputeStatusCompleted
	case pb.ComputeStatus_COMPUTE_STATUS_FAILED:
		return vimodels.ComputeStatusFailed
	default:
		return vimodels.ComputeStatusUnspecified
	}
}

// DomainComputeStatusToProto converts a domain ComputeStatus to the proto ComputeStatus.
func DomainComputeStatusToProto(s vimodels.ComputeStatus) pb.ComputeStatus {
	switch s {
	case vimodels.ComputeStatusQueued:
		return pb.ComputeStatus_COMPUTE_STATUS_QUEUED
	case vimodels.ComputeStatusComputing:
		return pb.ComputeStatus_COMPUTE_STATUS_COMPUTING
	case vimodels.ComputeStatusIntersecting:
		return pb.ComputeStatus_COMPUTE_STATUS_INTERSECTING
	case vimodels.ComputeStatusCompleted:
		return pb.ComputeStatus_COMPUTE_STATUS_COMPLETED
	case vimodels.ComputeStatusFailed:
		return pb.ComputeStatus_COMPUTE_STATUS_FAILED
	default:
		return pb.ComputeStatus_COMPUTE_STATUS_UNSPECIFIED
	}
}

// ---- Domain -> Proto conversions ----

// VegetationIndexToProto converts a domain VegetationIndex to its proto representation.
func VegetationIndexToProto(vi *vimodels.VegetationIndex) *pb.VegetationIndex {
	if vi == nil {
		return nil
	}

	result := &pb.VegetationIndex{
		Id:               vi.UUID,
		TenantId:         vi.TenantID,
		FarmId:           vi.FarmUUID,
		FieldId:          ptr.Deref(vi.FieldUUID),
		ProcessingJobId:  vi.ProcessingJobUUID,
		IndexType:        DomainIndexTypeToProto(vi.IndexType),
		MeanValue:        vi.MeanValue,
		MinValue:         vi.MinValue,
		MaxValue:         vi.MaxValue,
		StdDeviation:     vi.StdDeviation,
		MedianValue:      vi.MedianValue,
		PixelCount:       vi.PixelCount,
		CoveragePercent:  vi.CoveragePercent,
		RasterS3Key:      ptr.Deref(vi.RasterS3Key),
		AcquisitionDate:  timestamppb.New(vi.AcquisitionDate),
		ComputedAt:       timestamppb.New(vi.ComputedAt),
		CreatedAt:        timestamppb.New(vi.CreatedAt),
	}

	return result
}

// VegetationIndicesToProto converts a slice of domain VegetationIndex to their proto representations.
func VegetationIndicesToProto(indices []vimodels.VegetationIndex) []*pb.VegetationIndex {
	if indices == nil {
		return nil
	}
	result := make([]*pb.VegetationIndex, len(indices))
	for i := range indices {
		result[i] = VegetationIndexToProto(&indices[i])
	}
	return result
}

// ComputeTaskToProto converts a domain ComputeTask to its proto representation.
func ComputeTaskToProto(ct *vimodels.ComputeTask) *pb.ComputeTask {
	if ct == nil {
		return nil
	}

	indexTypes := make([]pb.VegetationIndexType, len(ct.IndexTypes))
	for i, it := range ct.IndexTypes {
		indexTypes[i] = DomainIndexTypeToProto(it)
	}

	result := &pb.ComputeTask{
		Id:                 ct.UUID,
		TenantId:           ct.TenantID,
		ProcessingJobId:    ct.ProcessingJobUUID,
		FarmId:             ct.FarmUUID,
		IndexTypes:         indexTypes,
		Status:             DomainComputeStatusToProto(ct.Status),
		ErrorMessage:       ptr.Deref(ct.ErrorMessage),
		ComputeTimeSeconds: ct.ComputeTimeSeconds,
		CreatedAt:          timestamppb.New(ct.CreatedAt),
	}

	if ct.CompletedAt != nil {
		result.CompletedAt = timestamppb.New(*ct.CompletedAt)
	}

	return result
}

// TimeSeriesPointToProto converts a domain TimeSeriesPoint to its proto representation.
func TimeSeriesPointToProto(p *vimodels.TimeSeriesPoint) *pb.TimeSeriesPoint {
	if p == nil {
		return nil
	}
	return &pb.TimeSeriesPoint{
		Date:         timestamppb.New(p.Date),
		Value:        p.Value,
		StdDeviation: p.StdDeviation,
	}
}

// TimeSeriesPointsToProto converts a slice of domain TimeSeriesPoint to their proto representations.
func TimeSeriesPointsToProto(points []vimodels.TimeSeriesPoint) []*pb.TimeSeriesPoint {
	if points == nil {
		return nil
	}
	result := make([]*pb.TimeSeriesPoint, len(points))
	for i := range points {
		result[i] = TimeSeriesPointToProto(&points[i])
	}
	return result
}

// ProtoIndexTypesToDomain converts a slice of proto VegetationIndexType to domain types.
func ProtoIndexTypesToDomain(types []pb.VegetationIndexType) []vimodels.VegetationIndexType {
	if types == nil {
		return nil
	}
	result := make([]vimodels.VegetationIndexType, len(types))
	for i, t := range types {
		result[i] = ProtoIndexTypeToDomain(t)
	}
	return result
}
