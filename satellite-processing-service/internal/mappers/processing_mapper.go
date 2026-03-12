package mappers

import (
	"google.golang.org/protobuf/types/known/timestamppb"

	pb "p9e.in/samavaya/agriculture/satellite-processing-service/api/v1"
	procmodels "p9e.in/samavaya/agriculture/satellite-processing-service/internal/models"
	"p9e.in/samavaya/packages/convert/ptr"
)

// ---- Proto enum <-> Domain enum conversions ----

// ProtoProcessingStatusToDomain converts a proto ProcessingStatus to the domain ProcessingStatus.
func ProtoProcessingStatusToDomain(s pb.ProcessingStatus) procmodels.ProcessingStatus {
	switch s {
	case pb.ProcessingStatus_PROCESSING_STATUS_QUEUED:
		return procmodels.ProcessingStatusQueued
	case pb.ProcessingStatus_PROCESSING_STATUS_PREPROCESSING:
		return procmodels.ProcessingStatusPreprocessing
	case pb.ProcessingStatus_PROCESSING_STATUS_ATMOSPHERIC_CORRECTION:
		return procmodels.ProcessingStatusAtmosphericCorrection
	case pb.ProcessingStatus_PROCESSING_STATUS_CLOUD_MASKING:
		return procmodels.ProcessingStatusCloudMasking
	case pb.ProcessingStatus_PROCESSING_STATUS_ORTHORECTIFICATION:
		return procmodels.ProcessingStatusOrthorectification
	case pb.ProcessingStatus_PROCESSING_STATUS_BAND_MATH:
		return procmodels.ProcessingStatusBandMath
	case pb.ProcessingStatus_PROCESSING_STATUS_COMPLETED:
		return procmodels.ProcessingStatusCompleted
	case pb.ProcessingStatus_PROCESSING_STATUS_FAILED:
		return procmodels.ProcessingStatusFailed
	default:
		return procmodels.ProcessingStatusUnspecified
	}
}

// DomainProcessingStatusToProto converts a domain ProcessingStatus to the proto ProcessingStatus.
func DomainProcessingStatusToProto(s procmodels.ProcessingStatus) pb.ProcessingStatus {
	switch s {
	case procmodels.ProcessingStatusQueued:
		return pb.ProcessingStatus_PROCESSING_STATUS_QUEUED
	case procmodels.ProcessingStatusPreprocessing:
		return pb.ProcessingStatus_PROCESSING_STATUS_PREPROCESSING
	case procmodels.ProcessingStatusAtmosphericCorrection:
		return pb.ProcessingStatus_PROCESSING_STATUS_ATMOSPHERIC_CORRECTION
	case procmodels.ProcessingStatusCloudMasking:
		return pb.ProcessingStatus_PROCESSING_STATUS_CLOUD_MASKING
	case procmodels.ProcessingStatusOrthorectification:
		return pb.ProcessingStatus_PROCESSING_STATUS_ORTHORECTIFICATION
	case procmodels.ProcessingStatusBandMath:
		return pb.ProcessingStatus_PROCESSING_STATUS_BAND_MATH
	case procmodels.ProcessingStatusCompleted:
		return pb.ProcessingStatus_PROCESSING_STATUS_COMPLETED
	case procmodels.ProcessingStatusFailed:
		return pb.ProcessingStatus_PROCESSING_STATUS_FAILED
	default:
		return pb.ProcessingStatus_PROCESSING_STATUS_UNSPECIFIED
	}
}

// ProtoProcessingLevelToDomain converts a proto ProcessingLevel to the domain ProcessingLevel.
func ProtoProcessingLevelToDomain(l pb.ProcessingLevel) procmodels.ProcessingLevel {
	switch l {
	case pb.ProcessingLevel_PROCESSING_LEVEL_L1C:
		return procmodels.ProcessingLevelL1C
	case pb.ProcessingLevel_PROCESSING_LEVEL_L2A:
		return procmodels.ProcessingLevelL2A
	case pb.ProcessingLevel_PROCESSING_LEVEL_L3:
		return procmodels.ProcessingLevelL3
	default:
		return procmodels.ProcessingLevelUnspecified
	}
}

// DomainProcessingLevelToProto converts a domain ProcessingLevel to the proto ProcessingLevel.
func DomainProcessingLevelToProto(l procmodels.ProcessingLevel) pb.ProcessingLevel {
	switch l {
	case procmodels.ProcessingLevelL1C:
		return pb.ProcessingLevel_PROCESSING_LEVEL_L1C
	case procmodels.ProcessingLevelL2A:
		return pb.ProcessingLevel_PROCESSING_LEVEL_L2A
	case procmodels.ProcessingLevelL3:
		return pb.ProcessingLevel_PROCESSING_LEVEL_L3
	default:
		return pb.ProcessingLevel_PROCESSING_LEVEL_UNSPECIFIED
	}
}

// ProtoCorrectionAlgorithmToDomain converts a proto CorrectionAlgorithm to the domain CorrectionAlgorithm.
func ProtoCorrectionAlgorithmToDomain(a pb.CorrectionAlgorithm) procmodels.CorrectionAlgorithm {
	switch a {
	case pb.CorrectionAlgorithm_CORRECTION_ALGORITHM_SEN2COR:
		return procmodels.CorrectionAlgorithmSen2Cor
	case pb.CorrectionAlgorithm_CORRECTION_ALGORITHM_LASRC:
		return procmodels.CorrectionAlgorithmLaSRC
	case pb.CorrectionAlgorithm_CORRECTION_ALGORITHM_FLAASH:
		return procmodels.CorrectionAlgorithmFLAASH
	case pb.CorrectionAlgorithm_CORRECTION_ALGORITHM_DOS:
		return procmodels.CorrectionAlgorithmDOS
	default:
		return procmodels.CorrectionAlgorithmUnspecified
	}
}

// DomainCorrectionAlgorithmToProto converts a domain CorrectionAlgorithm to the proto CorrectionAlgorithm.
func DomainCorrectionAlgorithmToProto(a procmodels.CorrectionAlgorithm) pb.CorrectionAlgorithm {
	switch a {
	case procmodels.CorrectionAlgorithmSen2Cor:
		return pb.CorrectionAlgorithm_CORRECTION_ALGORITHM_SEN2COR
	case procmodels.CorrectionAlgorithmLaSRC:
		return pb.CorrectionAlgorithm_CORRECTION_ALGORITHM_LASRC
	case procmodels.CorrectionAlgorithmFLAASH:
		return pb.CorrectionAlgorithm_CORRECTION_ALGORITHM_FLAASH
	case procmodels.CorrectionAlgorithmDOS:
		return pb.CorrectionAlgorithm_CORRECTION_ALGORITHM_DOS
	default:
		return pb.CorrectionAlgorithm_CORRECTION_ALGORITHM_UNSPECIFIED
	}
}

// ---- Domain -> Proto conversions ----

// ProcessingJobToProto converts a domain ProcessingJob to its proto representation.
func ProcessingJobToProto(j *procmodels.ProcessingJob) *pb.ProcessingJob {
	if j == nil {
		return nil
	}

	job := &pb.ProcessingJob{
		Id:                         j.UUID,
		TenantId:                   j.TenantID,
		IngestionTaskId:            j.IngestionTaskUUID,
		FarmId:                     j.FarmUUID,
		Status:                     DomainProcessingStatusToProto(j.Status),
		InputLevel:                 DomainProcessingLevelToProto(j.InputLevel),
		OutputLevel:                DomainProcessingLevelToProto(j.OutputLevel),
		Algorithm:                  DomainCorrectionAlgorithmToProto(j.Algorithm),
		InputS3Key:                 j.InputS3Key,
		OutputS3Key:                ptr.Deref(j.OutputS3Key),
		CloudMaskThreshold:         j.CloudMaskThreshold,
		ApplyAtmosphericCorrection: j.ApplyAtmosphericCorrection,
		ApplyCloudMasking:          j.ApplyCloudMasking,
		ApplyOrthorectification:    j.ApplyOrthorectification,
		OutputResolutionMeters:     j.OutputResolutionMeters,
		OutputCrs:                  j.OutputCRS,
		ErrorMessage:               ptr.Deref(j.ErrorMessage),
		ProcessingTimeSeconds:      ptr.Deref(j.ProcessingTimeSeconds),
		CreatedAt:                  timestamppb.New(j.CreatedAt),
	}

	if j.UpdatedAt != nil {
		job.UpdatedAt = timestamppb.New(*j.UpdatedAt)
	}

	if j.CompletedAt != nil {
		job.CompletedAt = timestamppb.New(*j.CompletedAt)
	}

	return job
}

// ProcessingJobsToProto converts a slice of domain ProcessingJobs to their proto representations.
func ProcessingJobsToProto(jobs []procmodels.ProcessingJob) []*pb.ProcessingJob {
	if jobs == nil {
		return nil
	}
	result := make([]*pb.ProcessingJob, len(jobs))
	for i := range jobs {
		result[i] = ProcessingJobToProto(&jobs[i])
	}
	return result
}

// ProcessingStatsToProto converts domain ProcessingStats to its proto representation.
func ProcessingStatsToProto(s *procmodels.ProcessingStats) *pb.GetProcessingStatsResponse {
	if s == nil {
		return nil
	}
	return &pb.GetProcessingStatsResponse{
		TotalJobs:                s.TotalJobs,
		CompletedJobs:            s.CompletedJobs,
		FailedJobs:               s.FailedJobs,
		PendingJobs:              s.PendingJobs,
		AvgProcessingTimeSeconds: s.AvgProcessingTimeSeconds,
	}
}

// ---- Proto -> Domain conversions ----

// SubmitProcessingJobRequestToDomain converts a SubmitProcessingJob proto request to a domain ProcessingJob.
func SubmitProcessingJobRequestToDomain(req *pb.SubmitProcessingJobRequest, tenantID, userID string) *procmodels.ProcessingJob {
	job := &procmodels.ProcessingJob{
		TenantID:                   tenantID,
		IngestionTaskUUID:          req.GetIngestionTaskId(),
		FarmUUID:                   req.GetFarmId(),
		Status:                     procmodels.ProcessingStatusQueued,
		InputLevel:                 procmodels.ProcessingLevelL1C,
		OutputLevel:                ProtoProcessingLevelToDomain(req.GetOutputLevel()),
		Algorithm:                  ProtoCorrectionAlgorithmToDomain(req.GetAlgorithm()),
		CloudMaskThreshold:         req.GetCloudMaskThreshold(),
		ApplyAtmosphericCorrection: req.GetApplyAtmosphericCorrection(),
		ApplyCloudMasking:          req.GetApplyCloudMasking(),
		ApplyOrthorectification:    req.GetApplyOrthorectification(),
		OutputResolutionMeters:     req.GetOutputResolutionMeters(),
		OutputCRS:                  req.GetOutputCrs(),
	}

	job.CreatedBy = userID

	// Set defaults
	if job.OutputLevel == procmodels.ProcessingLevelUnspecified {
		job.OutputLevel = procmodels.ProcessingLevelL2A
	}
	if job.Algorithm == procmodels.CorrectionAlgorithmUnspecified {
		job.Algorithm = procmodels.CorrectionAlgorithmSen2Cor
	}
	if job.CloudMaskThreshold == 0 {
		job.CloudMaskThreshold = 0.3
	}
	if job.OutputResolutionMeters == 0 {
		job.OutputResolutionMeters = 10
	}
	if job.OutputCRS == "" {
		job.OutputCRS = "EPSG:4326"
	}

	return job
}
