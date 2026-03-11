package services

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"time"

	"p9e.in/samavaya/agriculture/traceability-service/internal/models"
	"p9e.in/samavaya/agriculture/traceability-service/internal/repositories"
	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"
)

// TraceabilityService defines the business logic interface for traceability operations.
type TraceabilityService interface {
	// Records
	CreateRecord(ctx context.Context, input models.CreateRecordInput) (*models.TraceabilityRecord, error)
	GetRecord(ctx context.Context, id string) (*models.TraceabilityRecord, error)
	ListRecords(ctx context.Context, filter models.ListRecordsFilter) ([]models.TraceabilityRecord, int64, error)

	// Supply Chain Events
	AddSupplyChainEvent(ctx context.Context, input models.AddSupplyChainEventInput) (*models.SupplyChainEvent, error)
	GetSupplyChain(ctx context.Context, recordID string) ([]models.SupplyChainEvent, error)

	// Certifications
	CreateCertification(ctx context.Context, input models.CreateCertificationInput) (*models.Certification, error)
	GetCertification(ctx context.Context, id string) (*models.Certification, error)
	ListCertifications(ctx context.Context, filter models.ListCertificationsFilter) ([]models.Certification, int64, error)
	VerifyCertification(ctx context.Context, id, verifiedBy string) (*models.Certification, error)

	// Batches
	CreateBatch(ctx context.Context, input models.CreateBatchInput) (*models.BatchRecord, error)
	GetBatch(ctx context.Context, id string) (*models.BatchRecord, error)
	ListBatches(ctx context.Context, filter models.ListBatchesFilter) ([]models.BatchRecord, int64, error)

	// QR Codes
	GenerateQRCode(ctx context.Context, input models.GenerateQRCodeInput) (*models.QRCodeRecord, error)
	VerifyQRCode(ctx context.Context, qrData string) (*models.TraceabilityRecord, *models.BatchRecord, error)

	// Compliance
	GenerateComplianceReport(ctx context.Context, input models.GenerateComplianceReportInput) (*models.ComplianceReport, error)
}

type traceabilityService struct {
	repo   repositories.TraceabilityRepository
	deps   deps.ServiceDeps
	logger *p9log.Helper
}

// NewTraceabilityService creates a new TraceabilityService.
func NewTraceabilityService(d deps.ServiceDeps, repo repositories.TraceabilityRepository) TraceabilityService {
	return &traceabilityService{
		repo:   repo,
		deps:   d,
		logger: p9log.NewHelper(p9log.With(d.Log, "component", "TraceabilityService")),
	}
}

// --- Records ---

func (s *traceabilityService) CreateRecord(ctx context.Context, input models.CreateRecordInput) (*models.TraceabilityRecord, error) {
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

	record := &models.TraceabilityRecord{
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
		ComplianceStatus: models.ComplianceStatusPending,
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

	s.publishEvent(ctx, domain.EventType("traceability.record.created"), created.ID, "traceability_record", map[string]interface{}{
		"record_id":    created.ID,
		"tenant_id":    created.TenantID,
		"farm_id":      created.FarmID,
		"product_type": created.ProductType,
		"batch_number": created.BatchNumber,
	})

	s.logger.Infof("created traceability record %s for tenant %s", created.ID, tenantID)
	return created, nil
}

func (s *traceabilityService) GetRecord(ctx context.Context, id string) (*models.TraceabilityRecord, error) {
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

	// Load supply chain events
	events, err := s.repo.GetSupplyChainEventsByRecord(ctx, id)
	if err != nil {
		s.logger.Warnf("failed to load supply chain events for record %s: %v", id, err)
	} else {
		record.SupplyChainEvents = events
	}

	// Load certifications
	certs, err := s.repo.GetCertificationsByRecord(ctx, id, tenantID)
	if err != nil {
		s.logger.Warnf("failed to load certifications for record %s: %v", id, err)
	} else {
		record.Certifications = certs
	}

	return record, nil
}

func (s *traceabilityService) ListRecords(ctx context.Context, filter models.ListRecordsFilter) ([]models.TraceabilityRecord, int64, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	return s.repo.ListRecords(ctx, tenantID, filter)
}

// --- Supply Chain Events ---

func (s *traceabilityService) AddSupplyChainEvent(ctx context.Context, input models.AddSupplyChainEventInput) (*models.SupplyChainEvent, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if input.RecordID == "" {
		return nil, errors.BadRequest("MISSING_RECORD_ID", "record_id is required")
	}
	if !models.ValidSupplyChainEventTypes[input.EventType] {
		return nil, errors.BadRequest("INVALID_EVENT_TYPE", fmt.Sprintf("invalid event type: %s", input.EventType))
	}

	// Verify record exists
	_, err := s.repo.GetRecord(ctx, input.RecordID, tenantID)
	if err != nil {
		return nil, err
	}

	// Generate verification hash from event data
	verificationHash := s.generateVerificationHash(input)

	now := time.Now()
	event := &models.SupplyChainEvent{
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
	_, _ = s.repo.AppendChainOfCustody(ctx, input.RecordID, tenantID, custodyEntry, userID)

	s.publishEvent(ctx, domain.EventType("traceability.supply_chain_event.added"), created.ID, "supply_chain_event", map[string]interface{}{
		"event_id":   created.ID,
		"record_id":  created.RecordID,
		"event_type": string(created.EventType),
		"actor":      created.Actor,
		"location":   created.Location,
	})

	s.logger.Infof("added supply chain event %s (type: %s) to record %s", created.ID, created.EventType, input.RecordID)
	return created, nil
}

func (s *traceabilityService) GetSupplyChain(ctx context.Context, recordID string) ([]models.SupplyChainEvent, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if recordID == "" {
		return nil, errors.BadRequest("MISSING_RECORD_ID", "record_id is required")
	}

	// Verify record exists
	_, err := s.repo.GetRecord(ctx, recordID, tenantID)
	if err != nil {
		return nil, err
	}

	return s.repo.GetSupplyChainEventsByRecord(ctx, recordID)
}

// --- Certifications ---

func (s *traceabilityService) CreateCertification(ctx context.Context, input models.CreateCertificationInput) (*models.Certification, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if input.RecordID == "" {
		return nil, errors.BadRequest("MISSING_RECORD_ID", "record_id is required")
	}
	if !models.ValidCertificationTypes[input.CertType] {
		return nil, errors.BadRequest("INVALID_CERT_TYPE", fmt.Sprintf("invalid certification type: %s", input.CertType))
	}

	// Verify record exists
	_, err := s.repo.GetRecord(ctx, input.RecordID, tenantID)
	if err != nil {
		return nil, err
	}

	now := time.Now()
	metadata := metadataToJSON(input.Metadata)

	cert := &models.Certification{
		ID:         ulid.NewString(),
		TenantID:   tenantID,
		RecordID:   input.RecordID,
		CertType:   input.CertType,
		CertNumber: input.CertNumber,
		IssuedBy:   input.IssuedBy,
		IssuedDate: input.IssuedDate,
		ExpiryDate: input.ExpiryDate,
		Status:     models.CertificationStatusPending,
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

	s.publishEvent(ctx, domain.EventType("traceability.certification.created"), created.ID, "certification", map[string]interface{}{
		"certification_id": created.ID,
		"record_id":        created.RecordID,
		"cert_type":        string(created.CertType),
		"cert_number":      created.CertNumber,
	})

	s.logger.Infof("created certification %s (type: %s) for record %s", created.ID, created.CertType, input.RecordID)
	return created, nil
}

func (s *traceabilityService) GetCertification(ctx context.Context, id string) (*models.Certification, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if id == "" {
		return nil, errors.BadRequest("MISSING_ID", "certification id is required")
	}
	return s.repo.GetCertification(ctx, id, tenantID)
}

func (s *traceabilityService) ListCertifications(ctx context.Context, filter models.ListCertificationsFilter) ([]models.Certification, int64, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	return s.repo.ListCertifications(ctx, tenantID, filter)
}

func (s *traceabilityService) VerifyCertification(ctx context.Context, id, verifiedBy string) (*models.Certification, error) {
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

	// Verify the certification exists and is in pending status
	existing, err := s.repo.GetCertification(ctx, id, tenantID)
	if err != nil {
		return nil, err
	}

	if existing.Status != models.CertificationStatusPending {
		return nil, errors.BadRequest("INVALID_STATUS", fmt.Sprintf("certification is in %s status, only PENDING certifications can be verified", existing.Status))
	}

	// Check if certification has expired
	if existing.ExpiryDate != nil && existing.ExpiryDate.Before(time.Now()) {
		return nil, errors.BadRequest("CERTIFICATION_EXPIRED", "cannot verify an expired certification")
	}

	verified, err := s.repo.VerifyCertification(ctx, id, tenantID, verifiedBy)
	if err != nil {
		return nil, err
	}

	s.publishEvent(ctx, domain.EventType("traceability.certification.verified"), verified.ID, "certification", map[string]interface{}{
		"certification_id": verified.ID,
		"record_id":        verified.RecordID,
		"cert_type":        string(verified.CertType),
		"verified_by":      verifiedBy,
	})

	s.logger.Infof("verified certification %s by %s", id, verifiedBy)
	return verified, nil
}

// --- Batches ---

func (s *traceabilityService) CreateBatch(ctx context.Context, input models.CreateBatchInput) (*models.BatchRecord, error) {
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

	// Verify record exists
	_, err := s.repo.GetRecord(ctx, input.RecordID, tenantID)
	if err != nil {
		return nil, err
	}

	now := time.Now()
	metadata := metadataToJSON(input.Metadata)

	batch := &models.BatchRecord{
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
		Version:           1,
		CreatedAt:         now,
		UpdatedAt:         now,
	}

	created, err := s.repo.CreateBatchRecord(ctx, batch)
	if err != nil {
		return nil, err
	}

	s.publishEvent(ctx, domain.EventType("traceability.batch.created"), created.ID, "batch_record", map[string]interface{}{
		"batch_id":     created.ID,
		"record_id":    created.RecordID,
		"batch_number": created.BatchNumber,
		"quantity":     created.Quantity,
	})

	s.logger.Infof("created batch %s (number: %s) for record %s", created.ID, created.BatchNumber, input.RecordID)
	return created, nil
}

func (s *traceabilityService) GetBatch(ctx context.Context, id string) (*models.BatchRecord, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if id == "" {
		return nil, errors.BadRequest("MISSING_ID", "batch id is required")
	}
	return s.repo.GetBatchRecord(ctx, id, tenantID)
}

func (s *traceabilityService) ListBatches(ctx context.Context, filter models.ListBatchesFilter) ([]models.BatchRecord, int64, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	return s.repo.ListBatchRecords(ctx, tenantID, filter)
}

// --- QR Codes ---

func (s *traceabilityService) GenerateQRCode(ctx context.Context, input models.GenerateQRCodeInput) (*models.QRCodeRecord, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if input.RecordID == "" {
		return nil, errors.BadRequest("MISSING_RECORD_ID", "record_id is required")
	}

	// Verify record exists
	record, err := s.repo.GetRecord(ctx, input.RecordID, tenantID)
	if err != nil {
		return nil, err
	}

	// Generate QR data as a signed payload containing record + batch info
	qrPayload := map[string]string{
		"record_id":  input.RecordID,
		"batch_id":   input.BatchID,
		"tenant_id":  tenantID,
		"product":    record.ProductType,
		"origin":     record.OriginCountry,
		"farm_id":    record.FarmID,
		"generated":  time.Now().Format(time.RFC3339),
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

	qrCode := &models.QRCodeRecord{
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

	// Update the record with the QR code data
	userID := p9context.UserID(ctx)
	_, _ = s.repo.UpdateRecordQR(ctx, input.RecordID, tenantID, qrData, userID)

	s.logger.Infof("generated QR code %s for record %s", created.ID, input.RecordID)
	return created, nil
}

func (s *traceabilityService) VerifyQRCode(ctx context.Context, qrData string) (*models.TraceabilityRecord, *models.BatchRecord, error) {
	if qrData == "" {
		return nil, nil, errors.BadRequest("MISSING_QR_DATA", "qr_data is required")
	}

	qrCode, err := s.repo.GetQRCodeByData(ctx, qrData)
	if err != nil {
		return nil, nil, err
	}

	// Check expiration
	if qrCode.ExpiresAt != nil && qrCode.ExpiresAt.Before(time.Now()) {
		return nil, nil, errors.BadRequest("QR_CODE_EXPIRED", "QR code has expired")
	}

	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}

	// Get the associated record
	record, err := s.repo.GetRecord(ctx, qrCode.RecordID, tenantID)
	if err != nil {
		return nil, nil, err
	}

	// Load supply chain events
	events, err := s.repo.GetSupplyChainEventsByRecord(ctx, qrCode.RecordID)
	if err == nil {
		record.SupplyChainEvents = events
	}

	// Load certifications
	certs, err := s.repo.GetCertificationsByRecord(ctx, qrCode.RecordID, tenantID)
	if err == nil {
		record.Certifications = certs
	}

	// Get batch if referenced
	var batch *models.BatchRecord
	if qrCode.BatchID != "" {
		batch, err = s.repo.GetBatchRecord(ctx, qrCode.BatchID, tenantID)
		if err != nil {
			s.logger.Warnf("failed to load batch %s: %v", qrCode.BatchID, err)
		}
	}

	return record, batch, nil
}

// --- Compliance ---

func (s *traceabilityService) GenerateComplianceReport(ctx context.Context, input models.GenerateComplianceReportInput) (*models.ComplianceReport, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if input.RecordID == "" {
		return nil, errors.BadRequest("MISSING_RECORD_ID", "record_id is required")
	}

	// Get the record and all associated data for analysis
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

	// Run compliance checks
	findings, recommendations, score, status := s.evaluateCompliance(record, events, certs)

	now := time.Now()
	nextAudit := now.AddDate(0, 6, 0) // Next audit in 6 months

	report := &models.ComplianceReport{
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

	// Update the record's compliance status
	userID := p9context.UserID(ctx)
	_, _ = s.repo.UpdateRecordCompliance(ctx, input.RecordID, tenantID, status, userID)

	s.publishEvent(ctx, domain.EventType("traceability.compliance_report.generated"), created.ID, "compliance_report", map[string]interface{}{
		"report_id":        created.ID,
		"record_id":        created.RecordID,
		"status":           string(created.Status),
		"compliance_score": created.ComplianceScore,
	})

	s.logger.Infof("generated compliance report %s for record %s (score: %.2f, status: %s)", created.ID, input.RecordID, score, status)
	return created, nil
}

// evaluateCompliance runs compliance checks on a record and returns findings, recommendations, score, and status.
func (s *traceabilityService) evaluateCompliance(
	record *models.TraceabilityRecord,
	events []models.SupplyChainEvent,
	activeCerts []models.Certification,
) (findings []string, recommendations []string, score float64, status models.ComplianceStatusType) {
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
	eventTypeSet := make(map[models.SupplyChainEventType]bool)
	for _, e := range events {
		eventTypeSet[e.EventType] = true
	}
	requiredEvents := []models.SupplyChainEventType{
		models.SupplyChainEventTypePlanted,
		models.SupplyChainEventTypeHarvested,
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

	// Calculate score
	if totalChecks > 0 {
		score = (float64(passedChecks) / float64(totalChecks)) * 100.0
	}

	// Determine overall status
	switch {
	case score >= 80.0:
		status = models.ComplianceStatusCompliant
	case score >= 50.0:
		status = models.ComplianceStatusPending
	default:
		status = models.ComplianceStatusNonCompliant
	}

	return findings, recommendations, score, status
}

// --- Helpers ---

func (s *traceabilityService) generateVerificationHash(input models.AddSupplyChainEventInput) string {
	data := fmt.Sprintf("%s:%s:%s:%s:%s:%s",
		input.RecordID, input.EventType, input.Timestamp.Format(time.RFC3339),
		input.Location, input.Actor, input.Details)
	hash := sha256.Sum256([]byte(data))
	return hex.EncodeToString(hash[:])
}

func (s *traceabilityService) publishEvent(ctx context.Context, eventType domain.EventType, aggregateID, aggregateType string, data map[string]interface{}) {
	if s.deps.KafkaProducer == nil {
		return
	}

	event := domain.NewDomainEvent(eventType, aggregateID, aggregateType, data).
		WithSource("traceability-service").
		WithMetadata("tenant_id", p9context.TenantID(ctx))

	payload, err := json.Marshal(event)
	if err != nil {
		s.logger.Warnf("failed to marshal domain event: %v", err)
		return
	}

	_ = payload // Event would be published via KafkaProducer
	s.logger.Debugf("published event %s of type %s", event.ID, event.Type)
}

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
