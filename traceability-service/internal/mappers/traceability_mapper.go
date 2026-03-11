package mappers

import (
	"encoding/json"
	"time"

	pb "p9e.in/samavaya/agriculture/traceability-service/api/v1"
	"p9e.in/samavaya/agriculture/traceability-service/internal/models"

	"google.golang.org/protobuf/types/known/timestamppb"
)

// --- Timestamp helpers ---

func toTimestampPb(t *time.Time) *timestamppb.Timestamp {
	if t == nil {
		return nil
	}
	return timestamppb.New(*t)
}

func fromTimestampPb(ts *timestamppb.Timestamp) *time.Time {
	if ts == nil {
		return nil
	}
	t := ts.AsTime()
	return &t
}

func timeFromTimestampPb(ts *timestamppb.Timestamp) time.Time {
	if ts == nil {
		return time.Time{}
	}
	return ts.AsTime()
}

// --- Metadata helpers ---

func metadataToJSON(m map[string]string) json.RawMessage {
	if m == nil || len(m) == 0 {
		return json.RawMessage("{}")
	}
	b, err := json.Marshal(m)
	if err != nil {
		return json.RawMessage("{}")
	}
	return b
}

func metadataFromJSON(raw json.RawMessage) map[string]string {
	if len(raw) == 0 {
		return nil
	}
	var m map[string]string
	if err := json.Unmarshal(raw, &m); err != nil {
		return nil
	}
	return m
}

// --- Supply Chain Event Type mappings ---

func SupplyChainEventTypeToProto(t models.SupplyChainEventType) pb.SupplyChainEventType {
	switch t {
	case models.SupplyChainEventTypePlanted:
		return pb.SupplyChainEventType_SUPPLY_CHAIN_EVENT_TYPE_PLANTED
	case models.SupplyChainEventTypeFertilized:
		return pb.SupplyChainEventType_SUPPLY_CHAIN_EVENT_TYPE_FERTILIZED
	case models.SupplyChainEventTypeIrrigated:
		return pb.SupplyChainEventType_SUPPLY_CHAIN_EVENT_TYPE_IRRIGATED
	case models.SupplyChainEventTypeSprayed:
		return pb.SupplyChainEventType_SUPPLY_CHAIN_EVENT_TYPE_SPRAYED
	case models.SupplyChainEventTypeHarvested:
		return pb.SupplyChainEventType_SUPPLY_CHAIN_EVENT_TYPE_HARVESTED
	case models.SupplyChainEventTypeProcessed:
		return pb.SupplyChainEventType_SUPPLY_CHAIN_EVENT_TYPE_PROCESSED
	case models.SupplyChainEventTypePackaged:
		return pb.SupplyChainEventType_SUPPLY_CHAIN_EVENT_TYPE_PACKAGED
	case models.SupplyChainEventTypeShipped:
		return pb.SupplyChainEventType_SUPPLY_CHAIN_EVENT_TYPE_SHIPPED
	case models.SupplyChainEventTypeReceived:
		return pb.SupplyChainEventType_SUPPLY_CHAIN_EVENT_TYPE_RECEIVED
	case models.SupplyChainEventTypeSold:
		return pb.SupplyChainEventType_SUPPLY_CHAIN_EVENT_TYPE_SOLD
	default:
		return pb.SupplyChainEventType_SUPPLY_CHAIN_EVENT_TYPE_UNSPECIFIED
	}
}

func SupplyChainEventTypeFromProto(t pb.SupplyChainEventType) models.SupplyChainEventType {
	switch t {
	case pb.SupplyChainEventType_SUPPLY_CHAIN_EVENT_TYPE_PLANTED:
		return models.SupplyChainEventTypePlanted
	case pb.SupplyChainEventType_SUPPLY_CHAIN_EVENT_TYPE_FERTILIZED:
		return models.SupplyChainEventTypeFertilized
	case pb.SupplyChainEventType_SUPPLY_CHAIN_EVENT_TYPE_IRRIGATED:
		return models.SupplyChainEventTypeIrrigated
	case pb.SupplyChainEventType_SUPPLY_CHAIN_EVENT_TYPE_SPRAYED:
		return models.SupplyChainEventTypeSprayed
	case pb.SupplyChainEventType_SUPPLY_CHAIN_EVENT_TYPE_HARVESTED:
		return models.SupplyChainEventTypeHarvested
	case pb.SupplyChainEventType_SUPPLY_CHAIN_EVENT_TYPE_PROCESSED:
		return models.SupplyChainEventTypeProcessed
	case pb.SupplyChainEventType_SUPPLY_CHAIN_EVENT_TYPE_PACKAGED:
		return models.SupplyChainEventTypePackaged
	case pb.SupplyChainEventType_SUPPLY_CHAIN_EVENT_TYPE_SHIPPED:
		return models.SupplyChainEventTypeShipped
	case pb.SupplyChainEventType_SUPPLY_CHAIN_EVENT_TYPE_RECEIVED:
		return models.SupplyChainEventTypeReceived
	case pb.SupplyChainEventType_SUPPLY_CHAIN_EVENT_TYPE_SOLD:
		return models.SupplyChainEventTypeSold
	default:
		return ""
	}
}

// --- Certification Type mappings ---

func CertificationTypeToProto(t models.CertificationType) pb.CertificationType {
	switch t {
	case models.CertificationTypeOrganic:
		return pb.CertificationType_CERTIFICATION_TYPE_ORGANIC
	case models.CertificationTypeGAP:
		return pb.CertificationType_CERTIFICATION_TYPE_GAP
	case models.CertificationTypeFairtrade:
		return pb.CertificationType_CERTIFICATION_TYPE_FAIRTRADE
	case models.CertificationTypeRainforestAlliance:
		return pb.CertificationType_CERTIFICATION_TYPE_RAINFOREST_ALLIANCE
	case models.CertificationTypeUSDAOrganic:
		return pb.CertificationType_CERTIFICATION_TYPE_USDA_ORGANIC
	case models.CertificationTypeEUOrganic:
		return pb.CertificationType_CERTIFICATION_TYPE_EU_ORGANIC
	default:
		return pb.CertificationType_CERTIFICATION_TYPE_UNSPECIFIED
	}
}

func CertificationTypeFromProto(t pb.CertificationType) models.CertificationType {
	switch t {
	case pb.CertificationType_CERTIFICATION_TYPE_ORGANIC:
		return models.CertificationTypeOrganic
	case pb.CertificationType_CERTIFICATION_TYPE_GAP:
		return models.CertificationTypeGAP
	case pb.CertificationType_CERTIFICATION_TYPE_FAIRTRADE:
		return models.CertificationTypeFairtrade
	case pb.CertificationType_CERTIFICATION_TYPE_RAINFOREST_ALLIANCE:
		return models.CertificationTypeRainforestAlliance
	case pb.CertificationType_CERTIFICATION_TYPE_USDA_ORGANIC:
		return models.CertificationTypeUSDAOrganic
	case pb.CertificationType_CERTIFICATION_TYPE_EU_ORGANIC:
		return models.CertificationTypeEUOrganic
	default:
		return ""
	}
}

// --- Certification Status mappings ---

func CertificationStatusToProto(s models.CertificationStatus) pb.CertificationStatus {
	switch s {
	case models.CertificationStatusActive:
		return pb.CertificationStatus_CERTIFICATION_STATUS_ACTIVE
	case models.CertificationStatusExpired:
		return pb.CertificationStatus_CERTIFICATION_STATUS_EXPIRED
	case models.CertificationStatusRevoked:
		return pb.CertificationStatus_CERTIFICATION_STATUS_REVOKED
	case models.CertificationStatusPending:
		return pb.CertificationStatus_CERTIFICATION_STATUS_PENDING
	default:
		return pb.CertificationStatus_CERTIFICATION_STATUS_UNSPECIFIED
	}
}

func CertificationStatusFromProto(s pb.CertificationStatus) models.CertificationStatus {
	switch s {
	case pb.CertificationStatus_CERTIFICATION_STATUS_ACTIVE:
		return models.CertificationStatusActive
	case pb.CertificationStatus_CERTIFICATION_STATUS_EXPIRED:
		return models.CertificationStatusExpired
	case pb.CertificationStatus_CERTIFICATION_STATUS_REVOKED:
		return models.CertificationStatusRevoked
	case pb.CertificationStatus_CERTIFICATION_STATUS_PENDING:
		return models.CertificationStatusPending
	default:
		return ""
	}
}

// --- Compliance Status mappings ---

func ComplianceStatusToProto(s models.ComplianceStatusType) pb.ComplianceStatus {
	switch s {
	case models.ComplianceStatusCompliant:
		return pb.ComplianceStatus_COMPLIANCE_STATUS_COMPLIANT
	case models.ComplianceStatusNonCompliant:
		return pb.ComplianceStatus_COMPLIANCE_STATUS_NON_COMPLIANT
	case models.ComplianceStatusPending:
		return pb.ComplianceStatus_COMPLIANCE_STATUS_PENDING_REVIEW
	default:
		return pb.ComplianceStatus_COMPLIANCE_STATUS_UNSPECIFIED
	}
}

func ComplianceStatusFromProto(s pb.ComplianceStatus) models.ComplianceStatusType {
	switch s {
	case pb.ComplianceStatus_COMPLIANCE_STATUS_COMPLIANT:
		return models.ComplianceStatusCompliant
	case pb.ComplianceStatus_COMPLIANCE_STATUS_NON_COMPLIANT:
		return models.ComplianceStatusNonCompliant
	case pb.ComplianceStatus_COMPLIANCE_STATUS_PENDING_REVIEW:
		return models.ComplianceStatusPending
	default:
		return ""
	}
}

// --- TraceabilityRecord mappings ---

func TraceabilityRecordToProto(r *models.TraceabilityRecord) *pb.TraceabilityRecord {
	if r == nil {
		return nil
	}
	proto := &pb.TraceabilityRecord{
		Id:               r.ID,
		TenantId:         r.TenantID,
		FarmId:           r.FarmID,
		FieldId:          r.FieldID,
		CropId:           r.CropID,
		BatchNumber:      r.BatchNumber,
		ProductType:      r.ProductType,
		OriginCountry:    r.OriginCountry,
		OriginRegion:     r.OriginRegion,
		SeedSource:       r.SeedSource,
		PlantingDate:     toTimestampPb(r.PlantingDate),
		HarvestDate:      toTimestampPb(r.HarvestDate),
		ProcessingDate:   toTimestampPb(r.ProcessingDate),
		PackagingDate:    toTimestampPb(r.PackagingDate),
		QrCodeData:       r.QRCodeData,
		BlockchainHash:   r.BlockchainHash,
		ChainOfCustody:   r.ChainOfCustody,
		ComplianceStatus: ComplianceStatusToProto(r.ComplianceStatus),
		Metadata:         metadataFromJSON(r.Metadata),
		Version:          r.Version,
		CreatedBy:        r.CreatedBy,
		UpdatedBy:        r.UpdatedBy,
		CreatedAt:        timestamppb.New(r.CreatedAt),
		UpdatedAt:        timestamppb.New(r.UpdatedAt),
	}

	if len(r.SupplyChainEvents) > 0 {
		proto.SupplyChainEvents = make([]*pb.SupplyChainEvent, len(r.SupplyChainEvents))
		for i, e := range r.SupplyChainEvents {
			proto.SupplyChainEvents[i] = SupplyChainEventToProto(&e)
		}
	}

	if len(r.Certifications) > 0 {
		proto.Certifications = make([]*pb.Certification, len(r.Certifications))
		for i, c := range r.Certifications {
			proto.Certifications[i] = CertificationToProto(&c)
		}
	}

	return proto
}

func TraceabilityRecordsToProto(records []models.TraceabilityRecord) []*pb.TraceabilityRecord {
	if records == nil {
		return nil
	}
	result := make([]*pb.TraceabilityRecord, len(records))
	for i := range records {
		result[i] = TraceabilityRecordToProto(&records[i])
	}
	return result
}

// --- SupplyChainEvent mappings ---

func SupplyChainEventToProto(e *models.SupplyChainEvent) *pb.SupplyChainEvent {
	if e == nil {
		return nil
	}
	return &pb.SupplyChainEvent{
		Id:               e.ID,
		RecordId:         e.RecordID,
		EventType:        SupplyChainEventTypeToProto(e.EventType),
		Timestamp:        timestamppb.New(e.EventTimestamp),
		Location:         e.Location,
		Actor:            e.Actor,
		Details:          e.Details,
		VerificationHash: e.VerificationHash,
		CreatedAt:        timestamppb.New(e.CreatedAt),
	}
}

func SupplyChainEventsToProto(events []models.SupplyChainEvent) []*pb.SupplyChainEvent {
	if events == nil {
		return nil
	}
	result := make([]*pb.SupplyChainEvent, len(events))
	for i := range events {
		result[i] = SupplyChainEventToProto(&events[i])
	}
	return result
}

// --- Certification mappings ---

func CertificationToProto(c *models.Certification) *pb.Certification {
	if c == nil {
		return nil
	}
	return &pb.Certification{
		Id:         c.ID,
		TenantId:   c.TenantID,
		RecordId:   c.RecordID,
		CertType:   CertificationTypeToProto(c.CertType),
		CertNumber: c.CertNumber,
		IssuedBy:   c.IssuedBy,
		IssuedDate: toTimestampPb(c.IssuedDate),
		ExpiryDate: toTimestampPb(c.ExpiryDate),
		Status:     CertificationStatusToProto(c.Status),
		VerifiedBy: c.VerifiedBy,
		VerifiedAt: toTimestampPb(c.VerifiedAt),
		Metadata:   metadataFromJSON(c.Metadata),
		CreatedAt:  timestamppb.New(c.CreatedAt),
		UpdatedAt:  timestamppb.New(c.UpdatedAt),
		Version:    c.Version,
	}
}

func CertificationsToProto(certs []models.Certification) []*pb.Certification {
	if certs == nil {
		return nil
	}
	result := make([]*pb.Certification, len(certs))
	for i := range certs {
		result[i] = CertificationToProto(&certs[i])
	}
	return result
}

// --- BatchRecord mappings ---

func BatchRecordToProto(b *models.BatchRecord) *pb.BatchRecord {
	if b == nil {
		return nil
	}
	return &pb.BatchRecord{
		Id:                b.ID,
		TenantId:          b.TenantID,
		RecordId:          b.RecordID,
		BatchNumber:       b.BatchNumber,
		Quantity:          b.Quantity,
		Unit:              b.Unit,
		ProductionDate:    toTimestampPb(b.ProductionDate),
		ExpiryDate:        toTimestampPb(b.ExpiryDate),
		StorageConditions: b.StorageConditions,
		QualityGrade:      b.QualityGrade,
		Metadata:          metadataFromJSON(b.Metadata),
		CreatedAt:         timestamppb.New(b.CreatedAt),
		UpdatedAt:         timestamppb.New(b.UpdatedAt),
		Version:           b.Version,
	}
}

func BatchRecordsToProto(batches []models.BatchRecord) []*pb.BatchRecord {
	if batches == nil {
		return nil
	}
	result := make([]*pb.BatchRecord, len(batches))
	for i := range batches {
		result[i] = BatchRecordToProto(&batches[i])
	}
	return result
}

// --- QRCode mappings ---

func QRCodeToProto(q *models.QRCodeRecord) *pb.QRCode {
	if q == nil {
		return nil
	}
	return &pb.QRCode{
		Id:          q.ID,
		RecordId:    q.RecordID,
		BatchId:     q.BatchID,
		QrData:      q.QRData,
		QrImageUrl:  q.QRImageURL,
		ScanUrl:     q.ScanURL,
		GeneratedAt: timestamppb.New(q.GeneratedAt),
		ExpiresAt:   toTimestampPb(q.ExpiresAt),
		IsActive:    q.IsActive,
	}
}

// --- ComplianceReport mappings ---

func ComplianceReportToProto(r *models.ComplianceReport) *pb.ComplianceReport {
	if r == nil {
		return nil
	}
	return &pb.ComplianceReport{
		Id:              r.ID,
		TenantId:        r.TenantID,
		RecordId:        r.RecordID,
		Status:          ComplianceStatusToProto(r.Status),
		ReportType:      r.ReportType,
		Findings:        r.Findings,
		Recommendations: r.Recommendations,
		Auditor:         r.Auditor,
		AuditDate:       toTimestampPb(r.AuditDate),
		NextAuditDate:   toTimestampPb(r.NextAuditDate),
		ComplianceScore: r.ComplianceScore,
		Metadata:        metadataFromJSON(r.Metadata),
		CreatedAt:       timestamppb.New(r.CreatedAt),
	}
}
