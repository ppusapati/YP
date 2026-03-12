package handlers

import (
	"context"
	"fmt"
	"strconv"
	"time"

	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"

	pb "p9e.in/samavaya/agriculture/traceability-service/api/v1"
	"p9e.in/samavaya/agriculture/traceability-service/internal/mappers"
	"p9e.in/samavaya/agriculture/traceability-service/internal/models"
	"p9e.in/samavaya/agriculture/traceability-service/internal/services"

	"google.golang.org/protobuf/types/known/timestamppb"
)

// TraceabilityHandler implements the ConnectRPC TraceabilityService handler.
type TraceabilityHandler struct {
	d       deps.ServiceDeps
	service services.TraceabilityService
	log     *p9log.Helper
}

// NewTraceabilityHandler creates a new TraceabilityHandler.
func NewTraceabilityHandler(d deps.ServiceDeps, service services.TraceabilityService) *TraceabilityHandler {
	return &TraceabilityHandler{
		d:       d,
		service: service,
		log:     p9log.NewHelper(p9log.With(d.Log, "component", "TraceabilityHandler")),
	}
}

// CreateRecord handles traceability record creation requests.
func (h *TraceabilityHandler) CreateRecord(ctx context.Context, req *pb.CreateRecordRequest) (*pb.CreateRecordResponse, error) {
	requestID := p9context.RequestID(ctx)
	tenantID := p9context.TenantID(ctx)

	h.log.Infow("msg", "CreateRecord request", "tenant_id", tenantID, "request_id", requestID)

	if req.GetFarmId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "farm_id is required")
	}

	input := models.CreateRecordInput{
		FarmID:         req.GetFarmId(),
		FieldID:        req.GetFieldId(),
		CropID:         req.GetCropId(),
		BatchNumber:    req.GetBatchNumber(),
		ProductType:    req.GetProductType(),
		OriginCountry:  req.GetOriginCountry(),
		OriginRegion:   req.GetOriginRegion(),
		SeedSource:     req.GetSeedSource(),
		PlantingDate:   timestampToTimePtr(req.GetPlantingDate()),
		HarvestDate:    timestampToTimePtr(req.GetHarvestDate()),
		ProcessingDate: timestampToTimePtr(req.GetProcessingDate()),
		PackagingDate:  timestampToTimePtr(req.GetPackagingDate()),
		Metadata:       req.GetMetadata(),
	}

	record, err := h.service.CreateRecord(ctx, input)
	if err != nil {
		h.log.Errorw("msg", "CreateRecord failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	return &pb.CreateRecordResponse{
		Record: mappers.TraceabilityRecordToProto(record),
	}, nil
}

// GetRecord handles get traceability record requests.
func (h *TraceabilityHandler) GetRecord(ctx context.Context, req *pb.GetRecordRequest) (*pb.GetRecordResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GetRecord request", "id", req.GetId(), "request_id", requestID)

	if req.GetId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "record ID is required")
	}

	record, err := h.service.GetRecord(ctx, req.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetRecordResponse{
		Record: mappers.TraceabilityRecordToProto(record),
	}, nil
}

// ListRecords handles list traceability records requests with filtering and pagination.
func (h *TraceabilityHandler) ListRecords(ctx context.Context, req *pb.ListRecordsRequest) (*pb.ListRecordsResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "ListRecords request", "request_id", requestID)

	filter := models.ListRecordsFilter{
		PageSize: req.GetPageSize(),
	}

	// Parse page token as offset
	if req.GetPageToken() != "" {
		offset, err := strconv.ParseInt(req.GetPageToken(), 10, 32)
		if err == nil {
			filter.PageOffset = int32(offset)
		}
	}

	// Apply filters
	if req.GetFarmId() != "" {
		filter.FarmID = req.GetFarmId()
	}
	if req.GetCropId() != "" {
		filter.CropID = req.GetCropId()
	}
	if req.GetProductType() != "" {
		filter.ProductType = req.GetProductType()
	}
	if req.GetOriginCountry() != "" {
		filter.OriginCountry = req.GetOriginCountry()
	}
	if req.GetComplianceStatus() != pb.ComplianceStatus_COMPLIANCE_STATUS_UNSPECIFIED {
		filter.ComplianceStatus = string(mappers.ComplianceStatusFromProto(req.GetComplianceStatus()))
	}
	if req.GetSearch() != "" {
		filter.Search = req.GetSearch()
	}

	records, totalCount, err := h.service.ListRecords(ctx, filter)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	resp := &pb.ListRecordsResponse{
		Records:    mappers.TraceabilityRecordsToProto(records),
		TotalCount: int32(totalCount),
	}

	// Compute next page token
	nextOffset := filter.PageOffset + filter.PageSize
	if int64(nextOffset) < totalCount {
		resp.NextPageToken = fmt.Sprintf("%d", nextOffset)
	}

	return resp, nil
}

// AddSupplyChainEvent handles adding a supply chain event to a record.
func (h *TraceabilityHandler) AddSupplyChainEvent(ctx context.Context, req *pb.AddSupplyChainEventRequest) (*pb.AddSupplyChainEventResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "AddSupplyChainEvent request", "record_id", req.GetRecordId(), "request_id", requestID)

	if req.GetRecordId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "record_id is required")
	}
	if req.GetEventType() == pb.SupplyChainEventType_SUPPLY_CHAIN_EVENT_TYPE_UNSPECIFIED {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "event_type is required")
	}

	input := models.AddSupplyChainEventInput{
		RecordID:  req.GetRecordId(),
		EventType: mappers.SupplyChainEventTypeFromProto(req.GetEventType()),
		Timestamp: req.GetTimestamp().AsTime(),
		Location:  req.GetLocation(),
		Actor:     req.GetActor(),
		Details:   req.GetDetails(),
	}

	event, err := h.service.AddSupplyChainEvent(ctx, input)
	if err != nil {
		h.log.Errorw("msg", "AddSupplyChainEvent failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	return &pb.AddSupplyChainEventResponse{
		Event: mappers.SupplyChainEventToProto(event),
	}, nil
}

// GetSupplyChain handles retrieving the full supply chain for a record.
func (h *TraceabilityHandler) GetSupplyChain(ctx context.Context, req *pb.GetSupplyChainRequest) (*pb.GetSupplyChainResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GetSupplyChain request", "record_id", req.GetRecordId(), "request_id", requestID)

	if req.GetRecordId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "record_id is required")
	}

	events, err := h.service.GetSupplyChain(ctx, req.GetRecordId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetSupplyChainResponse{
		Events: mappers.SupplyChainEventsToProto(events),
	}, nil
}

// CreateCertification handles certification creation requests.
func (h *TraceabilityHandler) CreateCertification(ctx context.Context, req *pb.CreateCertificationRequest) (*pb.CreateCertificationResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "CreateCertification request", "record_id", req.GetRecordId(), "request_id", requestID)

	if req.GetRecordId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "record_id is required")
	}
	if req.GetCertType() == pb.CertificationType_CERTIFICATION_TYPE_UNSPECIFIED {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "cert_type is required")
	}

	input := models.CreateCertificationInput{
		RecordID:   req.GetRecordId(),
		CertType:   mappers.CertificationTypeFromProto(req.GetCertType()),
		CertNumber: req.GetCertNumber(),
		IssuedBy:   req.GetIssuedBy(),
		IssuedDate: timestampToTimePtr(req.GetIssuedDate()),
		ExpiryDate: timestampToTimePtr(req.GetExpiryDate()),
		Metadata:   req.GetMetadata(),
	}

	cert, err := h.service.CreateCertification(ctx, input)
	if err != nil {
		h.log.Errorw("msg", "CreateCertification failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	return &pb.CreateCertificationResponse{
		Certification: mappers.CertificationToProto(cert),
	}, nil
}

// GetCertification handles get certification requests.
func (h *TraceabilityHandler) GetCertification(ctx context.Context, req *pb.GetCertificationRequest) (*pb.GetCertificationResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GetCertification request", "id", req.GetId(), "request_id", requestID)

	if req.GetId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "certification ID is required")
	}

	cert, err := h.service.GetCertification(ctx, req.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetCertificationResponse{
		Certification: mappers.CertificationToProto(cert),
	}, nil
}

// ListCertifications handles list certifications requests with filtering and pagination.
func (h *TraceabilityHandler) ListCertifications(ctx context.Context, req *pb.ListCertificationsRequest) (*pb.ListCertificationsResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "ListCertifications request", "request_id", requestID)

	filter := models.ListCertificationsFilter{
		PageSize: req.GetPageSize(),
	}

	// Parse page token as offset
	if req.GetPageToken() != "" {
		offset, err := strconv.ParseInt(req.GetPageToken(), 10, 32)
		if err == nil {
			filter.PageOffset = int32(offset)
		}
	}

	// Apply filters
	if req.GetRecordId() != "" {
		filter.RecordID = req.GetRecordId()
	}
	if req.GetCertType() != pb.CertificationType_CERTIFICATION_TYPE_UNSPECIFIED {
		filter.CertType = string(mappers.CertificationTypeFromProto(req.GetCertType()))
	}
	if req.GetStatus() != pb.CertificationStatus_CERTIFICATION_STATUS_UNSPECIFIED {
		filter.Status = string(mappers.CertificationStatusFromProto(req.GetStatus()))
	}

	certs, totalCount, err := h.service.ListCertifications(ctx, filter)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	resp := &pb.ListCertificationsResponse{
		Certifications: mappers.CertificationsToProto(certs),
		TotalCount:     int32(totalCount),
	}

	// Compute next page token
	nextOffset := filter.PageOffset + filter.PageSize
	if int64(nextOffset) < totalCount {
		resp.NextPageToken = fmt.Sprintf("%d", nextOffset)
	}

	return resp, nil
}

// VerifyCertification handles certification verification requests.
func (h *TraceabilityHandler) VerifyCertification(ctx context.Context, req *pb.VerifyCertificationRequest) (*pb.VerifyCertificationResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "VerifyCertification request", "id", req.GetId(), "request_id", requestID)

	if req.GetId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "certification ID is required")
	}
	if req.GetVerifiedBy() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "verified_by is required")
	}

	cert, err := h.service.VerifyCertification(ctx, req.GetId(), req.GetVerifiedBy())
	if err != nil {
		h.log.Errorw("msg", "VerifyCertification failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	return &pb.VerifyCertificationResponse{
		Certification: mappers.CertificationToProto(cert),
	}, nil
}

// CreateBatch handles batch record creation requests.
func (h *TraceabilityHandler) CreateBatch(ctx context.Context, req *pb.CreateBatchRequest) (*pb.CreateBatchResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "CreateBatch request", "record_id", req.GetRecordId(), "request_id", requestID)

	if req.GetRecordId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "record_id is required")
	}
	if req.GetBatchNumber() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "batch_number is required")
	}

	input := models.CreateBatchInput{
		RecordID:          req.GetRecordId(),
		BatchNumber:       req.GetBatchNumber(),
		Quantity:          req.GetQuantity(),
		Unit:              req.GetUnit(),
		ProductionDate:    timestampToTimePtr(req.GetProductionDate()),
		ExpiryDate:        timestampToTimePtr(req.GetExpiryDate()),
		StorageConditions: req.GetStorageConditions(),
		QualityGrade:      req.GetQualityGrade(),
		Metadata:          req.GetMetadata(),
	}

	batch, err := h.service.CreateBatch(ctx, input)
	if err != nil {
		h.log.Errorw("msg", "CreateBatch failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	return &pb.CreateBatchResponse{
		Batch: mappers.BatchRecordToProto(batch),
	}, nil
}

// GetBatch handles get batch record requests.
func (h *TraceabilityHandler) GetBatch(ctx context.Context, req *pb.GetBatchRequest) (*pb.GetBatchResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GetBatch request", "id", req.GetId(), "request_id", requestID)

	if req.GetId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "batch ID is required")
	}

	batch, err := h.service.GetBatch(ctx, req.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetBatchResponse{
		Batch: mappers.BatchRecordToProto(batch),
	}, nil
}

// ListBatches handles list batch records requests with filtering and pagination.
func (h *TraceabilityHandler) ListBatches(ctx context.Context, req *pb.ListBatchesRequest) (*pb.ListBatchesResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "ListBatches request", "request_id", requestID)

	filter := models.ListBatchesFilter{
		PageSize: req.GetPageSize(),
	}

	// Parse page token as offset
	if req.GetPageToken() != "" {
		offset, err := strconv.ParseInt(req.GetPageToken(), 10, 32)
		if err == nil {
			filter.PageOffset = int32(offset)
		}
	}

	// Apply filters
	if req.GetRecordId() != "" {
		filter.RecordID = req.GetRecordId()
	}

	batches, totalCount, err := h.service.ListBatches(ctx, filter)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	resp := &pb.ListBatchesResponse{
		Batches:    mappers.BatchRecordsToProto(batches),
		TotalCount: int32(totalCount),
	}

	// Compute next page token
	nextOffset := filter.PageOffset + filter.PageSize
	if int64(nextOffset) < totalCount {
		resp.NextPageToken = fmt.Sprintf("%d", nextOffset)
	}

	return resp, nil
}

// GenerateQRCode handles QR code generation requests.
func (h *TraceabilityHandler) GenerateQRCode(ctx context.Context, req *pb.GenerateQRCodeRequest) (*pb.GenerateQRCodeResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GenerateQRCode request", "record_id", req.GetRecordId(), "request_id", requestID)

	if req.GetRecordId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "record_id is required")
	}

	input := models.GenerateQRCodeInput{
		RecordID: req.GetRecordId(),
		BatchID:  req.GetBatchId(),
		BaseURL:  req.GetBaseUrl(),
	}

	qrCode, err := h.service.GenerateQRCode(ctx, input)
	if err != nil {
		h.log.Errorw("msg", "GenerateQRCode failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	return &pb.GenerateQRCodeResponse{
		QrCode: mappers.QRCodeToProto(qrCode),
	}, nil
}

// VerifyQRCode handles QR code verification requests.
func (h *TraceabilityHandler) VerifyQRCode(ctx context.Context, req *pb.VerifyQRCodeRequest) (*pb.VerifyQRCodeResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "VerifyQRCode request", "request_id", requestID)

	if req.GetQrData() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "qr_data is required")
	}

	record, batch, err := h.service.VerifyQRCode(ctx, req.GetQrData())
	if err != nil {
		h.log.Errorw("msg", "VerifyQRCode failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	resp := &pb.VerifyQRCodeResponse{
		Valid:  true,
		Record: mappers.TraceabilityRecordToProto(record),
	}
	if batch != nil {
		resp.Batch = mappers.BatchRecordToProto(batch)
	}

	return resp, nil
}

// GenerateComplianceReport handles compliance report generation requests.
func (h *TraceabilityHandler) GenerateComplianceReport(ctx context.Context, req *pb.GenerateComplianceReportRequest) (*pb.GenerateComplianceReportResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GenerateComplianceReport request", "record_id", req.GetRecordId(), "request_id", requestID)

	if req.GetRecordId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "record_id is required")
	}

	input := models.GenerateComplianceReportInput{
		RecordID:   req.GetRecordId(),
		ReportType: req.GetReportType(),
		Auditor:    req.GetAuditor(),
	}

	report, err := h.service.GenerateComplianceReport(ctx, input)
	if err != nil {
		h.log.Errorw("msg", "GenerateComplianceReport failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	return &pb.GenerateComplianceReportResponse{
		Report: mappers.ComplianceReportToProto(report),
	}, nil
}

// timestampToTimePtr converts a protobuf Timestamp to a *time.Time.
func timestampToTimePtr(ts *timestamppb.Timestamp) *time.Time {
	if ts == nil {
		return nil
	}
	t := ts.AsTime()
	return &t
}
