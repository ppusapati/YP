// Package application contains the traceability-service application service — the
// implementation of the TraceabilityService primary port. It orchestrates domain
// objects and drives outbound ports (repository, event publisher). It has NO
// knowledge of ConnectRPC, HTTP, SQL, or Kafka.
package application

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	"p9e.in/samavaya/agriculture/traceability-service/internal/domain"
	"p9e.in/samavaya/agriculture/traceability-service/internal/ports/inbound"
	"p9e.in/samavaya/agriculture/traceability-service/internal/ports/outbound"
)

const (
	serviceName           = "traceability-service"
	eventTopic            = "samavaya.agriculture.traceability.events"
	maxPageSize     int32 = 100
	defaultPageSize       = int32(20)
)

// traceabilityService implements inbound.TraceabilityService.
type traceabilityService struct {
	repo        outbound.TraceabilityRepository
	pub         outbound.EventPublisher
	farmClient  outbound.FarmClient
	fieldClient outbound.FieldClient
	yieldClient outbound.YieldClient
	cropClient  outbound.CropClient
	pool        *pgxpool.Pool // reserved for future transactional operations
	log         *p9log.Helper
}

// NewTraceabilityService creates a new application-layer TraceabilityService.
// Dependencies are injected from outside (cmd/server/main.go), keeping the
// application layer free of infrastructure wiring.
func NewTraceabilityService(
	repo outbound.TraceabilityRepository,
	pub outbound.EventPublisher,
	farmClient outbound.FarmClient,
	fieldClient outbound.FieldClient,
	yieldClient outbound.YieldClient,
	cropClient outbound.CropClient,
	pool *pgxpool.Pool,
	log p9log.Logger,
) inbound.TraceabilityService {
	return &traceabilityService{
		repo:        repo,
		pub:         pub,
		farmClient:  farmClient,
		fieldClient: fieldClient,
		yieldClient: yieldClient,
		cropClient:  cropClient,
		pool:        pool,
		log:         p9log.NewHelper(p9log.With(log, "component", "TraceabilityService")),
	}
}

// --- Records ---

func (s *traceabilityService) CreateRecord(ctx context.Context, input domain.CreateRecordInput) (*domain.TraceabilityRecord, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	userID := p9context.UserID(ctx)

	if input.FarmID == "" {
		return nil, errors.BadRequest("MISSING_FARM_ID", "farm_id is required")
	}

	now := time.Now()
	metadata := metadataToJSON(input.Metadata)

	record := &domain.TraceabilityRecord{
		ID:               ulid.NewString(),
		TenantID:         tenantID,
		FarmID:           input.FarmID,
		FieldID:          input.FieldID,
		CropID:           input.CropID,
		BatchNumber:      input.BatchNumber,
		ProductType:      input.ProductType,
		OriginCountry:    input.OriginCountry,
		OriginRegion:     input.OriginRegion,
		SeedSource:       input.SeedSource,
		PlantingDate:     input.PlantingDate,
		HarvestDate:      input.HarvestDate,
		ProcessingDate:   input.ProcessingDate,
		PackagingDate:    input.PackagingDate,
		QRCodeData:       "",
		BlockchainHash:   "",
		ChainOfCustody:   []string{},
		ComplianceStatus: domain.ComplianceStatusPending,
		Metadata:         metadata,
		Version:          1,
		CreatedBy:        userID,
		UpdatedBy:        userID,
		CreatedAt:        now,
		UpdatedAt:        now,
	}

	created, err := s.repo.CreateRecord(ctx, record)
	if err != nil {
		return nil, err
	}

	s.publishEvent(ctx, "traceability.record.created", created.ID, map[string]interface{}{
		"record_id":    created.ID,
		"tenant_id":    created.TenantID,
		"farm_id":      created.FarmID,
		"product_type": created.ProductType,
		"batch_number": created.BatchNumber,
	})

	s.log.Infow("msg", "created traceability record", "record_id", created.ID, "tenant_id", tenantID)
	return created, nil
}

func (s *traceabilityService) GetRecord(ctx context.Context, id string) (*domain.TraceabilityRecord, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if id == "" {
		return nil, errors.BadRequest("MISSING_ID", "record id is required")
	}

	record, err := s.repo.GetRecord(ctx, id, tenantID)
	if err != nil {
		return nil, err
	}

	events, err := s.repo.GetSupplyChainEventsByRecord(ctx, id)
	if err != nil {
		s.log.Warnw("msg", "failed to load supply chain events", "record_id", id, "error", err)
	} else {
		record.SupplyChainEvents = events
	}

	certs, err := s.repo.GetCertificationsByRecord(ctx, id, tenantID)
	if err != nil {
		s.log.Warnw("msg", "failed to load certifications", "record_id", id, "error", err)
	} else {
		record.Certifications = certs
	}

	return record, nil
}

func (s *traceabilityService) ListRecords(ctx context.Context, filter domain.ListRecordsFilter) ([]domain.TraceabilityRecord, int64, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if filter.PageSize <= 0 {
		filter.PageSize = defaultPageSize
	}
	if filter.PageSize > maxPageSize {
		filter.PageSize = maxPageSize
	}
	return s.repo.ListRecords(ctx, tenantID, filter)
}

// --- Supply Chain Events ---

func (s *traceabilityService) AddSupplyChainEvent(ctx context.Context, input domain.AddSupplyChainEventInput) (*domain.SupplyChainEvent, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if input.RecordID == "" {
		return nil, errors.BadRequest("MISSING_RECORD_ID", "record_id is required")
	}
	if !domain.ValidSupplyChainEventTypes[input.EventType] {
		return nil, errors.BadRequest("INVALID_EVENT_TYPE", fmt.Sprintf("invalid event type: %s", input.EventType))
	}

	// Verify record exists
	if _, err := s.repo.GetRecord(ctx, input.RecordID, tenantID); err != nil {
		return nil, err
	}

	verificationHash := generateVerificationHash(input)

	now := time.Now()
	event := &domain.SupplyChainEvent{
		ID:               ulid.NewString(),
		RecordID:         input.RecordID,
		EventType:        input.EventType,
		EventTimestamp:   input.Timestamp,
		Location:         input.Location,
		Actor:            input.Actor,
		Details:          input.Details,
		VerificationHash: verificationHash,
		CreatedAt:        now,
	}

	created, err := s.repo.CreateSupplyChainEvent(ctx, event)
	if err != nil {
		return nil, err
	}

	// Append to chain of custody
	custodyEntry := fmt.Sprintf("%s:%s:%s:%s", created.EventType, created.Actor, created.Location, created.EventTimestamp.Format(time.RFC3339))
	userID := p9context.UserID(ctx)
	if _, err := s.repo.AppendChainOfCustody(ctx, input.RecordID, tenantID, custodyEntry, userID); err != nil {
		s.log.Warnw("msg", "failed to append chain of custody", "record_id", input.RecordID, "error", err)
	}

	s.publishEvent(ctx, "traceability.supply_chain_event.added", created.ID, map[string]interface{}{
		"event_id":   created.ID,
		"record_id":  created.RecordID,
		"event_type": string(created.EventType),
		"actor":      created.Actor,
		"location":   created.Location,
	})

	s.log.Infow("msg", "added supply chain event", "event_id", created.ID, "event_type", created.EventType, "record_id", input.RecordID)
	return created, nil
}

func (s *traceabilityService) GetSupplyChain(ctx context.Context, recordID string) ([]domain.SupplyChainEvent, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if recordID == "" {
		return nil, errors.BadRequest("MISSING_RECORD_ID", "record_id is required")
	}

	if _, err := s.repo.GetRecord(ctx, recordID, tenantID); err != nil {
		return nil, err
	}

	return s.repo.GetSupplyChainEventsByRecord(ctx, recordID)
}

// --- Certifications ---

func (s *traceabilityService) CreateCertification(ctx context.Context, input domain.CreateCertificationInput) (*domain.Certification, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if input.RecordID == "" {
		return nil, errors.BadRequest("MISSING_RECORD_ID", "record_id is required")
	}
	if !domain.ValidCertificationTypes[input.CertType] {
		return nil, errors.BadRequest("INVALID_CERT_TYPE", fmt.Sprintf("invalid certification type: %s", input.CertType))
	}

	if _, err := s.repo.GetRecord(ctx, input.RecordID, tenantID); err != nil {
		return nil, err
	}

	now := time.Now()
	metadata := metadataToJSON(input.Metadata)

	cert := &domain.Certification{
		ID:         ulid.NewString(),
		TenantID:   tenantID,
		RecordID:   input.RecordID,
		CertType:   input.CertType,
		CertNumber: input.CertNumber,
		IssuedBy:   input.IssuedBy,
		IssuedDate: input.IssuedDate,
		ExpiryDate: input.ExpiryDate,
		Status:     domain.CertificationStatusPending,
		VerifiedBy: "",
		VerifiedAt: nil,
		Metadata:   metadata,
		Version:    1,
		CreatedAt:  now,
		UpdatedAt:  now,
	}

	created, err := s.repo.CreateCertification(ctx, cert)
	if err != nil {
		return nil, err
	}

	s.publishEvent(ctx, "traceability.certification.created", created.ID, map[string]interface{}{
		"certification_id": created.ID,
		"record_id":        created.RecordID,
		"cert_type":        string(created.CertType),
		"cert_number":      created.CertNumber,
	})

	s.log.Infow("msg", "created certification", "certification_id", created.ID, "cert_type", created.CertType, "record_id", input.RecordID)
	return created, nil
}

func (s *traceabilityService) GetCertification(ctx context.Context, id string) (*domain.Certification, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if id == "" {
		return nil, errors.BadRequest("MISSING_ID", "certification id is required")
	}
	return s.repo.GetCertification(ctx, id, tenantID)
}

func (s *traceabilityService) ListCertifications(ctx context.Context, filter domain.ListCertificationsFilter) ([]domain.Certification, int64, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if filter.PageSize <= 0 {
		filter.PageSize = defaultPageSize
	}
	if filter.PageSize > maxPageSize {
		filter.PageSize = maxPageSize
	}
	return s.repo.ListCertifications(ctx, tenantID, filter)
}

func (s *traceabilityService) VerifyCertification(ctx context.Context, id, verifiedBy string) (*domain.Certification, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if id == "" {
		return nil, errors.BadRequest("MISSING_ID", "certification id is required")
	}
	if verifiedBy == "" {
		return nil, errors.BadRequest("MISSING_VERIFIER", "verified_by is required")
	}

	existing, err := s.repo.GetCertification(ctx, id, tenantID)
	if err != nil {
		return nil, err
	}

	if existing.Status != domain.CertificationStatusPending {
		return nil, errors.BadRequest("INVALID_STATUS", fmt.Sprintf("certification is in %s status, only PENDING certifications can be verified", existing.Status))
	}

	if existing.ExpiryDate != nil && existing.ExpiryDate.Before(time.Now()) {
		return nil, errors.BadRequest("CERTIFICATION_EXPIRED", "cannot verify an expired certification")
	}

	verified, err := s.repo.VerifyCertification(ctx, id, tenantID, verifiedBy)
	if err != nil {
		return nil, err
	}

	s.publishEvent(ctx, "traceability.certification.verified", verified.ID, map[string]interface{}{
		"certification_id": verified.ID,
		"record_id":        verified.RecordID,
		"cert_type":        string(verified.CertType),
		"verified_by":      verifiedBy,
	})

	s.log.Infow("msg", "verified certification", "certification_id", id, "verified_by", verifiedBy)
	return verified, nil
}

// --- Batches ---

func (s *traceabilityService) CreateBatch(ctx context.Context, input domain.CreateBatchInput) (*domain.BatchRecord, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if input.RecordID == "" {
		return nil, errors.BadRequest("MISSING_RECORD_ID", "record_id is required")
	}
	if input.BatchNumber == "" {
		return nil, errors.BadRequest("MISSING_BATCH_NUMBER", "batch_number is required")
	}

	if _, err := s.repo.GetRecord(ctx, input.RecordID, tenantID); err != nil {
		return nil, err
	}

	now := time.Now()
	metadata := metadataToJSON(input.Metadata)

	batch := &domain.BatchRecord{
		ID:                ulid.NewString(),
		TenantID:          tenantID,
		RecordID:          input.RecordID,
		BatchNumber:       input.BatchNumber,
		Quantity:          input.Quantity,
		Unit:              input.Unit,
		ProductionDate:    input.ProductionDate,
		ExpiryDate:        input.ExpiryDate,
		StorageConditions: input.StorageConditions,
		QualityGrade:      input.QualityGrade,
		Metadata:          metadata,
		CropCycleID:       input.CropCycleID,
		YieldRecordID:     input.YieldRecordID,
		WeightKg:          input.WeightKg,
		Version:           1,
		CreatedAt:         now,
		UpdatedAt:         now,
	}

	created, err := s.repo.CreateBatchRecord(ctx, batch)
	if err != nil {
		return nil, err
	}

	s.publishEvent(ctx, "traceability.batch.created", created.ID, map[string]interface{}{
		"batch_id":     created.ID,
		"record_id":    created.RecordID,
		"batch_number": created.BatchNumber,
		"quantity":     created.Quantity,
	})

	s.log.Infow("msg", "created batch", "batch_id", created.ID, "batch_number", created.BatchNumber, "record_id", input.RecordID)
	return created, nil
}

func (s *traceabilityService) GetBatch(ctx context.Context, id string) (*domain.BatchRecord, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if id == "" {
		return nil, errors.BadRequest("MISSING_ID", "batch id is required")
	}
	return s.repo.GetBatchRecord(ctx, id, tenantID)
}

func (s *traceabilityService) ListBatches(ctx context.Context, filter domain.ListBatchesFilter) ([]domain.BatchRecord, int64, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if filter.PageSize <= 0 {
		filter.PageSize = defaultPageSize
	}
	if filter.PageSize > maxPageSize {
		filter.PageSize = maxPageSize
	}
	return s.repo.ListBatchRecords(ctx, tenantID, filter)
}

// --- QR Codes ---

func (s *traceabilityService) GenerateQRCode(ctx context.Context, input domain.GenerateQRCodeInput) (*domain.QRCodeRecord, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if input.RecordID == "" {
		return nil, errors.BadRequest("MISSING_RECORD_ID", "record_id is required")
	}

	record, err := s.repo.GetRecord(ctx, input.RecordID, tenantID)
	if err != nil {
		return nil, err
	}

	qrPayload := map[string]string{
		"record_id": input.RecordID,
		"batch_id":  input.BatchID,
		"tenant_id": tenantID,
		"product":   record.ProductType,
		"origin":    record.OriginCountry,
		"farm_id":   record.FarmID,
		"generated": time.Now().Format(time.RFC3339),
	}
	payloadBytes, _ := json.Marshal(qrPayload)
	hash := sha256.Sum256(payloadBytes)
	qrData := hex.EncodeToString(hash[:]) + ":" + string(payloadBytes)

	baseURL := input.BaseURL
	if baseURL == "" {
		baseURL = "https://trace.agriculture.p9e.in"
	}
	scanURL := fmt.Sprintf("%s/verify/%s", baseURL, input.RecordID)

	now := time.Now()
	expiresAt := now.AddDate(1, 0, 0) // QR codes expire after 1 year

	qrCode := &domain.QRCodeRecord{
		ID:          ulid.NewString(),
		RecordID:    input.RecordID,
		BatchID:     input.BatchID,
		QRData:      qrData,
		QRImageURL:  "", // Image generation handled by separate service
		ScanURL:     scanURL,
		GeneratedAt: now,
		ExpiresAt:   &expiresAt,
		IsActive:    true,
	}

	created, err := s.repo.CreateQRCode(ctx, qrCode)
	if err != nil {
		return nil, err
	}

	userID := p9context.UserID(ctx)
	if _, err := s.repo.UpdateRecordQR(ctx, input.RecordID, tenantID, qrData, userID); err != nil {
		s.log.Warnw("msg", "failed to update record QR data", "record_id", input.RecordID, "error", err)
	}

	s.log.Infow("msg", "generated QR code", "qr_id", created.ID, "record_id", input.RecordID)
	return created, nil
}

func (s *traceabilityService) VerifyQRCode(ctx context.Context, qrData string) (*domain.TraceabilityRecord, *domain.BatchRecord, error) {
	if qrData == "" {
		return nil, nil, errors.BadRequest("MISSING_QR_DATA", "qr_data is required")
	}

	qrCode, err := s.repo.GetQRCodeByData(ctx, qrData)
	if err != nil {
		return nil, nil, err
	}

	if qrCode.ExpiresAt != nil && qrCode.ExpiresAt.Before(time.Now()) {
		return nil, nil, errors.BadRequest("QR_CODE_EXPIRED", "QR code has expired")
	}

	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}

	record, err := s.repo.GetRecord(ctx, qrCode.RecordID, tenantID)
	if err != nil {
		return nil, nil, err
	}

	if events, err := s.repo.GetSupplyChainEventsByRecord(ctx, qrCode.RecordID); err == nil {
		record.SupplyChainEvents = events
	}

	if certs, err := s.repo.GetCertificationsByRecord(ctx, qrCode.RecordID, tenantID); err == nil {
		record.Certifications = certs
	}

	var batch *domain.BatchRecord
	if qrCode.BatchID != "" {
		batch, err = s.repo.GetBatchRecord(ctx, qrCode.BatchID, tenantID)
		if err != nil {
			s.log.Warnw("msg", "failed to load batch", "batch_id", qrCode.BatchID, "error", err)
			batch = nil
		}
	}

	return record, batch, nil
}

// --- Compliance ---

func (s *traceabilityService) GenerateComplianceReport(ctx context.Context, input domain.GenerateComplianceReportInput) (*domain.ComplianceReport, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if input.RecordID == "" {
		return nil, errors.BadRequest("MISSING_RECORD_ID", "record_id is required")
	}

	record, err := s.repo.GetRecord(ctx, input.RecordID, tenantID)
	if err != nil {
		return nil, err
	}

	events, err := s.repo.GetSupplyChainEventsByRecord(ctx, input.RecordID)
	if err != nil {
		return nil, errors.Internal("failed to load supply chain events for compliance check: %v", err)
	}

	certs, err := s.repo.GetActiveCertificationsByRecord(ctx, input.RecordID, tenantID)
	if err != nil {
		return nil, errors.Internal("failed to load certifications for compliance check: %v", err)
	}

	findings, recommendations, score, status := evaluateCompliance(record, events, certs)

	now := time.Now()
	nextAudit := now.AddDate(0, 6, 0) // Next audit in 6 months

	report := &domain.ComplianceReport{
		ID:              ulid.NewString(),
		TenantID:        tenantID,
		RecordID:        input.RecordID,
		Status:          status,
		ReportType:      input.ReportType,
		Findings:        findings,
		Recommendations: recommendations,
		Auditor:         input.Auditor,
		AuditDate:       &now,
		NextAuditDate:   &nextAudit,
		ComplianceScore: score,
		Metadata:        json.RawMessage("{}"),
		CreatedAt:       now,
	}

	created, err := s.repo.CreateComplianceReport(ctx, report)
	if err != nil {
		return nil, err
	}

	userID := p9context.UserID(ctx)
	if _, err := s.repo.UpdateRecordCompliance(ctx, input.RecordID, tenantID, status, userID); err != nil {
		s.log.Warnw("msg", "failed to update record compliance status", "record_id", input.RecordID, "error", err)
	}

	s.publishEvent(ctx, "traceability.compliance_report.generated", created.ID, map[string]interface{}{
		"report_id":        created.ID,
		"record_id":        created.RecordID,
		"status":           string(created.Status),
		"compliance_score": created.ComplianceScore,
	})

	s.log.Infow("msg", "generated compliance report", "report_id", created.ID, "record_id", input.RecordID, "score", score, "status", status)
	return created, nil
}

// evaluateCompliance runs compliance checks on a record and returns findings, recommendations, score, and status.
func evaluateCompliance(
	record *domain.TraceabilityRecord,
	events []domain.SupplyChainEvent,
	activeCerts []domain.Certification,
) (findings []string, recommendations []string, score float64, status domain.ComplianceStatusType) {
	findings = make([]string, 0)
	recommendations = make([]string, 0)
	totalChecks := 0
	passedChecks := 0

	// Check 1: Origin information completeness
	totalChecks++
	if record.OriginCountry != "" && record.OriginRegion != "" && record.FarmID != "" {
		passedChecks++
	} else {
		findings = append(findings, "Incomplete origin information: country, region, and farm must all be specified")
		recommendations = append(recommendations, "Complete origin traceability data for full compliance")
	}

	// Check 2: Seed source documentation
	totalChecks++
	if record.SeedSource != "" {
		passedChecks++
	} else {
		findings = append(findings, "Seed source not documented")
		recommendations = append(recommendations, "Document seed source for organic traceability requirements")
	}

	// Check 3: Supply chain event coverage - key lifecycle events present
	totalChecks++
	eventTypeSet := make(map[domain.SupplyChainEventType]bool)
	for _, e := range events {
		eventTypeSet[e.EventType] = true
	}
	requiredEvents := []domain.SupplyChainEventType{
		domain.SupplyChainEventTypePlanted,
		domain.SupplyChainEventTypeHarvested,
	}
	allRequiredPresent := true
	for _, req := range requiredEvents {
		if !eventTypeSet[req] {
			allRequiredPresent = false
			findings = append(findings, fmt.Sprintf("Missing required supply chain event: %s", req))
		}
	}
	if allRequiredPresent {
		passedChecks++
	} else {
		recommendations = append(recommendations, "Ensure all critical lifecycle events (PLANTED, HARVESTED) are recorded")
	}

	// Check 4: Verification hashes present on supply chain events
	totalChecks++
	allVerified := true
	for _, e := range events {
		if e.VerificationHash == "" {
			allVerified = false
			break
		}
	}
	if allVerified && len(events) > 0 {
		passedChecks++
	} else {
		findings = append(findings, "Some supply chain events lack verification hashes")
		recommendations = append(recommendations, "Ensure all supply chain events have verification hashes for tamper-proof audit trails")
	}

	// Check 5: Active certifications present
	totalChecks++
	if len(activeCerts) > 0 {
		passedChecks++
	} else {
		findings = append(findings, "No active certifications found")
		recommendations = append(recommendations, "Obtain and verify at least one organic or quality certification")
	}

	// Check 6: Certification expiry check
	totalChecks++
	allCertsValid := true
	now := time.Now()
	for _, cert := range activeCerts {
		if cert.ExpiryDate != nil && cert.ExpiryDate.Before(now) {
			allCertsValid = false
			findings = append(findings, fmt.Sprintf("Certification %s (type: %s) has expired", cert.CertNumber, cert.CertType))
		}
	}
	if allCertsValid && len(activeCerts) > 0 {
		passedChecks++
	} else if len(activeCerts) > 0 {
		recommendations = append(recommendations, "Renew expired certifications to maintain compliance")
	}

	// Check 7: Date chain consistency (planting before harvest before processing before packaging)
	totalChecks++
	dateChainValid := true
	dates := []*time.Time{record.PlantingDate, record.HarvestDate, record.ProcessingDate, record.PackagingDate}
	for i := 0; i < len(dates)-1; i++ {
		if dates[i] != nil && dates[i+1] != nil && dates[i].After(*dates[i+1]) {
			dateChainValid = false
			findings = append(findings, "Date chain inconsistency detected: dates must follow planting -> harvest -> processing -> packaging order")
			break
		}
	}
	if dateChainValid {
		passedChecks++
	} else {
		recommendations = append(recommendations, "Correct date chain to ensure chronological consistency")
	}

	if totalChecks > 0 {
		score = (float64(passedChecks) / float64(totalChecks)) * 100.0
	}

	switch {
	case score >= 80.0:
		status = domain.ComplianceStatusCompliant
	case score >= 50.0:
		status = domain.ComplianceStatusPending
	default:
		status = domain.ComplianceStatusNonCompliant
	}

	return findings, recommendations, score, status
}

// --- Quality Checkpoints ---

func (s *traceabilityService) CreateQualityCheckpoint(ctx context.Context, input domain.CreateQualityCheckpointInput) (*domain.QualityCheckpoint, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if input.RecordID == "" {
		return nil, errors.BadRequest("MISSING_RECORD_ID", "record_id is required")
	}
	if !domain.ValidQualityCheckTypes[input.CheckType] {
		return nil, errors.BadRequest("INVALID_CHECK_TYPE", fmt.Sprintf("invalid quality check type: %s", input.CheckType))
	}
	if input.Result != domain.QualityCheckResultPass && input.Result != domain.QualityCheckResultFail {
		return nil, errors.BadRequest("INVALID_RESULT", fmt.Sprintf("invalid quality check result: %s", input.Result))
	}
	if input.InspectorName == "" {
		return nil, errors.BadRequest("MISSING_INSPECTOR_NAME", "inspector_name is required")
	}
	if input.InspectedAt.IsZero() {
		return nil, errors.BadRequest("MISSING_INSPECTED_AT", "inspected_at is required")
	}

	// Verify record exists
	if _, err := s.repo.GetRecord(ctx, input.RecordID, tenantID); err != nil {
		return nil, err
	}

	userID := p9context.UserID(ctx)
	now := time.Now()
	metadata := metadataToJSON(input.Metadata)

	var supplyChainEventID *string
	if input.SupplyChainEventID != nil && *input.SupplyChainEventID != "" {
		supplyChainEventID = input.SupplyChainEventID
	}

	checkpoint := &domain.QualityCheckpoint{
		ID:                 ulid.NewString(),
		TenantID:           tenantID,
		RecordID:           input.RecordID,
		SupplyChainEventID: supplyChainEventID,
		CheckType:          input.CheckType,
		Result:             input.Result,
		InspectorID:        userID,
		InspectorName:      input.InspectorName,
		InspectedAt:        input.InspectedAt,
		Location:           input.Location,
		MeasurementValue:   input.MeasurementValue,
		MeasurementUnit:    input.MeasurementUnit,
		MinThreshold:       input.MinThreshold,
		MaxThreshold:       input.MaxThreshold,
		Notes:              input.Notes,
		EvidenceURLs:       input.EvidenceURLs,
		Metadata:           metadata,
		Grade:              input.Grade,
		LabReportURL:       input.LabReportURL,
		CreatedAt:          now,
		BatchID:            input.BatchID,
	}

	created, err := s.repo.CreateQualityCheckpoint(ctx, checkpoint)
	if err != nil {
		return nil, err
	}

	s.publishEvent(ctx, "agriculture.traceability.quality_checkpoint.created", created.ID, map[string]interface{}{
		"checkpoint_id": created.ID,
		"record_id":     created.RecordID,
		"check_type":    string(created.CheckType),
		"result":        string(created.Result),
		"inspector":     created.InspectorName,
	})

	s.log.Infow("msg", "created quality checkpoint", "checkpoint_id", created.ID, "record_id", input.RecordID, "check_type", input.CheckType)
	return created, nil
}

func (s *traceabilityService) GetQualityCheckpoint(ctx context.Context, id string) (*domain.QualityCheckpoint, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if id == "" {
		return nil, errors.BadRequest("MISSING_ID", "checkpoint id is required")
	}
	return s.repo.GetQualityCheckpoint(ctx, id, tenantID)
}

func (s *traceabilityService) ListQualityCheckpoints(ctx context.Context, filter domain.ListQualityCheckpointsFilter) ([]domain.QualityCheckpoint, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if filter.RecordID == "" {
		return nil, 0, errors.BadRequest("MISSING_RECORD_ID", "record_id is required")
	}
	if filter.PageSize <= 0 {
		filter.PageSize = defaultPageSize
	}
	if filter.PageSize > maxPageSize {
		filter.PageSize = maxPageSize
	}
	return s.repo.ListQualityCheckpoints(ctx, filter, tenantID)
}

// --- Record Update ---

func (s *traceabilityService) UpdateRecord(ctx context.Context, id string, input domain.UpdateRecordInput) (*domain.TraceabilityRecord, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if id == "" {
		return nil, errors.BadRequest("MISSING_ID", "record id is required")
	}

	userID := p9context.UserID(ctx)
	updated, err := s.repo.UpdateRecord(ctx, id, tenantID, input, userID)
	if err != nil {
		return nil, err
	}

	s.publishEvent(ctx, "agriculture.traceability.record.updated", updated.ID, map[string]interface{}{
		"record_id": updated.ID,
		"tenant_id": updated.TenantID,
	})

	s.log.Infow("msg", "updated traceability record", "record_id", updated.ID, "tenant_id", tenantID)
	return updated, nil
}

// --- Certification Revocation ---

func (s *traceabilityService) RevokeCertification(ctx context.Context, id, reason string) (*domain.Certification, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if id == "" {
		return nil, errors.BadRequest("MISSING_ID", "certification id is required")
	}

	existing, err := s.repo.GetCertification(ctx, id, tenantID)
	if err != nil {
		return nil, err
	}
	if existing.Status != domain.CertificationStatusActive {
		return nil, errors.BadRequest("INVALID_STATUS", fmt.Sprintf("certification is in %s status, only ACTIVE certifications can be revoked", existing.Status))
	}

	revoked, err := s.repo.RevokeCertification(ctx, id, tenantID, reason)
	if err != nil {
		return nil, err
	}

	s.publishEvent(ctx, "agriculture.traceability.certification.revoked", revoked.ID, map[string]interface{}{
		"certification_id": revoked.ID,
		"record_id":        revoked.RecordID,
		"cert_type":        string(revoked.CertType),
		"reason":           reason,
	})

	s.log.Infow("msg", "revoked certification", "certification_id", id, "reason", reason)
	return revoked, nil
}

// --- Compliance Report Retrieval ---

func (s *traceabilityService) GetComplianceReport(ctx context.Context, id string) (*domain.ComplianceReport, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if id == "" {
		return nil, errors.BadRequest("MISSING_ID", "compliance report id is required")
	}
	return s.repo.GetComplianceReport(ctx, id, tenantID)
}

func (s *traceabilityService) ListComplianceReports(ctx context.Context, filter domain.ListComplianceReportsFilter) ([]domain.ComplianceReport, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if filter.RecordID == "" {
		return nil, 0, errors.BadRequest("MISSING_RECORD_ID", "record_id is required")
	}
	if filter.PageSize <= 0 {
		filter.PageSize = defaultPageSize
	}
	if filter.PageSize > maxPageSize {
		filter.PageSize = maxPageSize
	}
	return s.repo.ListComplianceReports(ctx, filter, tenantID)
}

// --- Helpers ---

func generateVerificationHash(input domain.AddSupplyChainEventInput) string {
	data := fmt.Sprintf("%s:%s:%s:%s:%s:%s",
		input.RecordID, input.EventType, input.Timestamp.Format(time.RFC3339),
		input.Location, input.Actor, input.Details)
	hash := sha256.Sum256([]byte(data))
	return hex.EncodeToString(hash[:])
}

func (s *traceabilityService) publishEvent(ctx context.Context, eventType, aggregateID string, data map[string]interface{}) {
	if s.pub == nil {
		return
	}
	payload := map[string]interface{}{
		"id":             ulid.NewString(),
		"type":           eventType,
		"aggregate_id":   aggregateID,
		"source":         serviceName,
		"correlation_id": p9context.RequestID(ctx),
		"tenant_id":      p9context.TenantID(ctx),
		"data":           data,
	}
	raw, err := json.Marshal(payload)
	if err != nil {
		s.log.Errorw("msg", "failed to marshal event", "error", err)
		return
	}
	if err := s.pub.Publish(ctx, eventTopic, aggregateID, raw); err != nil {
		s.log.Errorw("msg", "failed to publish event", "event_type", eventType, "error", err)
	}
}

func metadataToJSON(m map[string]string) json.RawMessage {
	if len(m) == 0 {
		return json.RawMessage("{}")
	}
	b, err := json.Marshal(m)
	if err != nil {
		return json.RawMessage("{}")
	}
	return b
}
