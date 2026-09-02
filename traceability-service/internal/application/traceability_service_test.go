package application

import (
	"context"
	"encoding/json"
	"fmt"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/saas"

	"p9e.in/samavaya/agriculture/traceability-service/internal/domain"
)

// ---------------------------------------------------------------------------
// No-op logger satisfying p9log.Logger
// ---------------------------------------------------------------------------

type nopLogger struct{}

func (nopLogger) Log(_ p9log.Level, _ ...interface{}) error { return nil }

// ---------------------------------------------------------------------------
// Mock: EventPublisher
// ---------------------------------------------------------------------------

type mockEventPublisher struct {
	published []publishedEvent
}

type publishedEvent struct {
	topic, key string
	payload    []byte
}

func (m *mockEventPublisher) Publish(_ context.Context, topic, key string, payload []byte) error {
	m.published = append(m.published, publishedEvent{topic, key, payload})
	return nil
}

// ---------------------------------------------------------------------------
// Mock: FarmClient, FieldClient, YieldClient, CropClient
// ---------------------------------------------------------------------------

type mockFarmClient struct {
	existing map[string]bool
}

func (m *mockFarmClient) FarmExists(_ context.Context, uuid, _ string) (bool, error) {
	return m.existing[uuid], nil
}

type mockFieldClient struct {
	existing map[string]bool
}

func (m *mockFieldClient) FieldExists(_ context.Context, uuid, _ string) (bool, error) {
	return m.existing[uuid], nil
}

type mockYieldClient struct{}

func (m *mockYieldClient) YieldExists(_ context.Context, _, _ string) (bool, error) {
	return true, nil
}

func (m *mockYieldClient) GetYieldRecord(_ context.Context, _, _ string) (float64, error) {
	return 100.0, nil
}

type mockCropClient struct {
	existing map[string]bool
}

func (m *mockCropClient) CropExists(_ context.Context, uuid, _ string) (bool, error) {
	return m.existing[uuid], nil
}

// ---------------------------------------------------------------------------
// Mock: TraceabilityRepository
// ---------------------------------------------------------------------------

type mockTraceabilityRepo struct {
	records       map[string]*domain.TraceabilityRecord
	events        map[string][]domain.SupplyChainEvent // keyed by recordID
	certifications map[string]*domain.Certification
	certsByRecord map[string][]domain.Certification
	batches       map[string]*domain.BatchRecord
	qrCodes       map[string]*domain.QRCodeRecord // keyed by ID
	qrByData      map[string]*domain.QRCodeRecord // keyed by QRData
	reports       map[string]*domain.ComplianceReport
	checkpoints   map[string]*domain.QualityCheckpoint
}

func newMockTraceabilityRepo() *mockTraceabilityRepo {
	return &mockTraceabilityRepo{
		records:        make(map[string]*domain.TraceabilityRecord),
		events:         make(map[string][]domain.SupplyChainEvent),
		certifications: make(map[string]*domain.Certification),
		certsByRecord:  make(map[string][]domain.Certification),
		batches:        make(map[string]*domain.BatchRecord),
		qrCodes:        make(map[string]*domain.QRCodeRecord),
		qrByData:       make(map[string]*domain.QRCodeRecord),
		reports:        make(map[string]*domain.ComplianceReport),
		checkpoints:    make(map[string]*domain.QualityCheckpoint),
	}
}

// --- Records ---

func (m *mockTraceabilityRepo) CreateRecord(_ context.Context, r *domain.TraceabilityRecord) (*domain.TraceabilityRecord, error) {
	m.records[r.ID] = r
	return r, nil
}

func (m *mockTraceabilityRepo) GetRecord(_ context.Context, id, tenantID string) (*domain.TraceabilityRecord, error) {
	r, ok := m.records[id]
	if !ok || r.TenantID != tenantID {
		return nil, errors.NotFound("RECORD_NOT_FOUND", fmt.Sprintf("record not found: %s", id))
	}
	return r, nil
}

func (m *mockTraceabilityRepo) ListRecords(_ context.Context, tenantID string, _ domain.ListRecordsFilter) ([]domain.TraceabilityRecord, int64, error) {
	var result []domain.TraceabilityRecord
	for _, r := range m.records {
		if r.TenantID == tenantID {
			result = append(result, *r)
		}
	}
	return result, int64(len(result)), nil
}

func (m *mockTraceabilityRepo) UpdateRecordCompliance(_ context.Context, id, tenantID string, status domain.ComplianceStatusType, _ string) (*domain.TraceabilityRecord, error) {
	r, ok := m.records[id]
	if !ok || r.TenantID != tenantID {
		return nil, errors.NotFound("RECORD_NOT_FOUND", "not found")
	}
	r.ComplianceStatus = status
	return r, nil
}

func (m *mockTraceabilityRepo) UpdateRecordQR(_ context.Context, id, tenantID, qrData, _ string) (*domain.TraceabilityRecord, error) {
	r, ok := m.records[id]
	if !ok || r.TenantID != tenantID {
		return nil, errors.NotFound("RECORD_NOT_FOUND", "not found")
	}
	r.QRCodeData = qrData
	return r, nil
}

func (m *mockTraceabilityRepo) AppendChainOfCustody(_ context.Context, id, tenantID, entry, _ string) (*domain.TraceabilityRecord, error) {
	r, ok := m.records[id]
	if !ok || r.TenantID != tenantID {
		return nil, errors.NotFound("RECORD_NOT_FOUND", "not found")
	}
	r.ChainOfCustody = append(r.ChainOfCustody, entry)
	return r, nil
}

// --- Supply Chain Events ---

func (m *mockTraceabilityRepo) CreateSupplyChainEvent(_ context.Context, e *domain.SupplyChainEvent) (*domain.SupplyChainEvent, error) {
	m.events[e.RecordID] = append(m.events[e.RecordID], *e)
	return e, nil
}

func (m *mockTraceabilityRepo) GetSupplyChainEventsByRecord(_ context.Context, recordID string) ([]domain.SupplyChainEvent, error) {
	return m.events[recordID], nil
}

// --- Certifications ---

func (m *mockTraceabilityRepo) CreateCertification(_ context.Context, cert *domain.Certification) (*domain.Certification, error) {
	m.certifications[cert.ID] = cert
	m.certsByRecord[cert.RecordID] = append(m.certsByRecord[cert.RecordID], *cert)
	return cert, nil
}

func (m *mockTraceabilityRepo) GetCertification(_ context.Context, id, tenantID string) (*domain.Certification, error) {
	cert, ok := m.certifications[id]
	if !ok || cert.TenantID != tenantID {
		return nil, errors.NotFound("CERTIFICATION_NOT_FOUND", fmt.Sprintf("certification not found: %s", id))
	}
	return cert, nil
}

func (m *mockTraceabilityRepo) ListCertifications(_ context.Context, tenantID string, _ domain.ListCertificationsFilter) ([]domain.Certification, int64, error) {
	var result []domain.Certification
	for _, c := range m.certifications {
		if c.TenantID == tenantID {
			result = append(result, *c)
		}
	}
	return result, int64(len(result)), nil
}

func (m *mockTraceabilityRepo) VerifyCertification(_ context.Context, id, tenantID, verifiedBy string) (*domain.Certification, error) {
	cert, ok := m.certifications[id]
	if !ok || cert.TenantID != tenantID {
		return nil, errors.NotFound("CERTIFICATION_NOT_FOUND", "not found")
	}
	now := time.Now()
	cert.Status = domain.CertificationStatusActive
	cert.VerifiedBy = verifiedBy
	cert.VerifiedAt = &now
	return cert, nil
}

func (m *mockTraceabilityRepo) GetCertificationsByRecord(_ context.Context, recordID, _ string) ([]domain.Certification, error) {
	return m.certsByRecord[recordID], nil
}

func (m *mockTraceabilityRepo) GetActiveCertificationsByRecord(_ context.Context, recordID, _ string) ([]domain.Certification, error) {
	var result []domain.Certification
	for _, c := range m.certsByRecord[recordID] {
		if c.Status == domain.CertificationStatusActive {
			result = append(result, c)
		}
	}
	return result, nil
}

func (m *mockTraceabilityRepo) RevokeCertification(_ context.Context, id, tenantID, _ string) (*domain.Certification, error) {
	cert, ok := m.certifications[id]
	if !ok || cert.TenantID != tenantID {
		return nil, errors.NotFound("CERTIFICATION_NOT_FOUND", "not found")
	}
	cert.Status = domain.CertificationStatusRevoked
	return cert, nil
}

// --- Batch Records ---

func (m *mockTraceabilityRepo) CreateBatchRecord(_ context.Context, b *domain.BatchRecord) (*domain.BatchRecord, error) {
	m.batches[b.ID] = b
	return b, nil
}

func (m *mockTraceabilityRepo) GetBatchRecord(_ context.Context, id, tenantID string) (*domain.BatchRecord, error) {
	b, ok := m.batches[id]
	if !ok || b.TenantID != tenantID {
		return nil, errors.NotFound("BATCH_NOT_FOUND", fmt.Sprintf("batch not found: %s", id))
	}
	return b, nil
}

func (m *mockTraceabilityRepo) ListBatchRecords(_ context.Context, tenantID string, _ domain.ListBatchesFilter) ([]domain.BatchRecord, int64, error) {
	var result []domain.BatchRecord
	for _, b := range m.batches {
		if b.TenantID == tenantID {
			result = append(result, *b)
		}
	}
	return result, int64(len(result)), nil
}

// --- QR Codes ---

func (m *mockTraceabilityRepo) CreateQRCode(_ context.Context, qr *domain.QRCodeRecord) (*domain.QRCodeRecord, error) {
	m.qrCodes[qr.ID] = qr
	m.qrByData[qr.QRData] = qr
	return qr, nil
}

func (m *mockTraceabilityRepo) GetQRCodeByData(_ context.Context, qrData string) (*domain.QRCodeRecord, error) {
	qr, ok := m.qrByData[qrData]
	if !ok {
		return nil, errors.NotFound("QR_NOT_FOUND", "QR code not found")
	}
	return qr, nil
}

func (m *mockTraceabilityRepo) GetQRCodesByRecord(_ context.Context, _ string) ([]domain.QRCodeRecord, error) {
	return nil, nil
}

// --- Compliance Reports ---

func (m *mockTraceabilityRepo) CreateComplianceReport(_ context.Context, report *domain.ComplianceReport) (*domain.ComplianceReport, error) {
	m.reports[report.ID] = report
	return report, nil
}

func (m *mockTraceabilityRepo) GetComplianceReport(_ context.Context, id, tenantID string) (*domain.ComplianceReport, error) {
	r, ok := m.reports[id]
	if !ok || r.TenantID != tenantID {
		return nil, errors.NotFound("REPORT_NOT_FOUND", fmt.Sprintf("report not found: %s", id))
	}
	return r, nil
}

func (m *mockTraceabilityRepo) GetComplianceReportsByRecord(_ context.Context, _, _ string) ([]domain.ComplianceReport, error) {
	return nil, nil
}

func (m *mockTraceabilityRepo) GetLatestComplianceReport(_ context.Context, _, _ string) (*domain.ComplianceReport, error) {
	return nil, errors.NotFound("REPORT_NOT_FOUND", "no reports")
}

func (m *mockTraceabilityRepo) ListComplianceReports(_ context.Context, _ domain.ListComplianceReportsFilter, _ string) ([]domain.ComplianceReport, int32, error) {
	return nil, 0, nil
}

// --- Quality Checkpoints ---

func (m *mockTraceabilityRepo) CreateQualityCheckpoint(_ context.Context, cp *domain.QualityCheckpoint) (*domain.QualityCheckpoint, error) {
	m.checkpoints[cp.ID] = cp
	return cp, nil
}

func (m *mockTraceabilityRepo) GetQualityCheckpoint(_ context.Context, id, tenantID string) (*domain.QualityCheckpoint, error) {
	cp, ok := m.checkpoints[id]
	if !ok || cp.TenantID != tenantID {
		return nil, errors.NotFound("CHECKPOINT_NOT_FOUND", fmt.Sprintf("checkpoint not found: %s", id))
	}
	return cp, nil
}

func (m *mockTraceabilityRepo) ListQualityCheckpoints(_ context.Context, _ domain.ListQualityCheckpointsFilter, _ string) ([]domain.QualityCheckpoint, int32, error) {
	return nil, 0, nil
}

// --- Record Update ---

func (m *mockTraceabilityRepo) UpdateRecord(_ context.Context, id, tenantID string, _ domain.UpdateRecordInput, _ string) (*domain.TraceabilityRecord, error) {
	r, ok := m.records[id]
	if !ok || r.TenantID != tenantID {
		return nil, errors.NotFound("RECORD_NOT_FOUND", "record not found")
	}
	return r, nil
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

func testContext(tenantID, userID string) context.Context {
	ctx := context.Background()
	ctx = p9context.NewConnectionInfo(ctx, &saas.ConnectionInfo{TenantID: tenantID})
	if userID != "" {
		ctx = p9context.NewUserContext(ctx, p9context.UserContext{UserID: userID})
	}
	return ctx
}

func newService() (*mockTraceabilityRepo, *mockEventPublisher, *traceabilityService) {
	repo := newMockTraceabilityRepo()
	pub := &mockEventPublisher{}
	farmClient := &mockFarmClient{existing: map[string]bool{"farm-001": true}}
	fieldClient := &mockFieldClient{existing: map[string]bool{"field-001": true}}
	yieldClient := &mockYieldClient{}
	cropClient := &mockCropClient{existing: map[string]bool{"crop-001": true}}
	svc := NewTraceabilityService(repo, pub, farmClient, fieldClient, yieldClient, cropClient, nil, nopLogger{}).(*traceabilityService)
	return repo, pub, svc
}

func seedRecord(repo *mockTraceabilityRepo, id, tenantID string) *domain.TraceabilityRecord {
	r := &domain.TraceabilityRecord{
		ID:               id,
		TenantID:         tenantID,
		FarmID:           "farm-001",
		ProductType:      "Rice",
		OriginCountry:    "India",
		OriginRegion:     "Punjab",
		SeedSource:       "National Seed Corp",
		ComplianceStatus: domain.ComplianceStatusPending,
		ChainOfCustody:   []string{},
		Metadata:         json.RawMessage("{}"),
		Version:          1,
		CreatedAt:        time.Now(),
		UpdatedAt:        time.Now(),
	}
	repo.records[id] = r
	return r
}

// ---------------------------------------------------------------------------
// Tests: CreateRecord
// ---------------------------------------------------------------------------

func TestCreateRecord_HappyPath(t *testing.T) {
	_, pub, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	input := domain.CreateRecordInput{
		FarmID:      "farm-001",
		ProductType: "Rice",
	}
	created, err := svc.CreateRecord(ctx, input)
	require.NoError(t, err)
	assert.Equal(t, "tenant-1", created.TenantID)
	assert.Equal(t, "farm-001", created.FarmID)
	assert.Equal(t, domain.ComplianceStatusPending, created.ComplianceStatus)
	assert.Equal(t, "user-1", created.CreatedBy)
	assert.NotEmpty(t, created.ID)
	assert.Equal(t, int64(1), created.Version)

	assert.Len(t, pub.published, 1)
	assert.Equal(t, eventTopic, pub.published[0].topic)
}

func TestCreateRecord_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.CreateRecord(ctx, domain.CreateRecordInput{FarmID: "farm-001"})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_TENANT", errors.Reason(err))
}

func TestCreateRecord_MissingFarmID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CreateRecord(ctx, domain.CreateRecordInput{})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_FARM_ID", errors.Reason(err))
}

// ---------------------------------------------------------------------------
// Tests: GetRecord
// ---------------------------------------------------------------------------

func TestGetRecord_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	seedRecord(repo, "rec-001", "tenant-1")

	record, err := svc.GetRecord(ctx, "rec-001")
	require.NoError(t, err)
	assert.Equal(t, "rec-001", record.ID)
	assert.Equal(t, "Rice", record.ProductType)
}

func TestGetRecord_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.GetRecord(ctx, "rec-001")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_TENANT", errors.Reason(err))
}

func TestGetRecord_MissingID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetRecord(ctx, "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_ID", errors.Reason(err))
}

func TestGetRecord_NotFound(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetRecord(ctx, "nonexistent")
	require.Error(t, err)
	assert.True(t, errors.IsNotFound(err))
}

// ---------------------------------------------------------------------------
// Tests: ListRecords
// ---------------------------------------------------------------------------

func TestListRecords_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	seedRecord(repo, "rec-001", "tenant-1")
	seedRecord(repo, "rec-002", "tenant-1")

	records, total, err := svc.ListRecords(ctx, domain.ListRecordsFilter{})
	require.NoError(t, err)
	assert.Equal(t, int64(2), total)
	assert.Len(t, records, 2)
}

func TestListRecords_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, _, err := svc.ListRecords(ctx, domain.ListRecordsFilter{})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestListRecords_DefaultAndMaxPageSize(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	// PageSize 0 defaults to 20, PageSize 500 caps to 100 -- no error either way.
	_, _, err := svc.ListRecords(ctx, domain.ListRecordsFilter{PageSize: 0})
	require.NoError(t, err)
	_, _, err = svc.ListRecords(ctx, domain.ListRecordsFilter{PageSize: 500})
	require.NoError(t, err)
}

// ---------------------------------------------------------------------------
// Tests: AddSupplyChainEvent
// ---------------------------------------------------------------------------

func TestAddSupplyChainEvent_HappyPath(t *testing.T) {
	repo, pub, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	seedRecord(repo, "rec-001", "tenant-1")

	input := domain.AddSupplyChainEventInput{
		RecordID:  "rec-001",
		EventType: domain.SupplyChainEventTypePlanted,
		Timestamp: time.Now(),
		Location:  "Field A",
		Actor:     "Farmer",
		Details:   "Planted rice seedlings",
	}

	event, err := svc.AddSupplyChainEvent(ctx, input)
	require.NoError(t, err)
	assert.NotEmpty(t, event.ID)
	assert.Equal(t, domain.SupplyChainEventTypePlanted, event.EventType)
	assert.NotEmpty(t, event.VerificationHash)
	assert.Len(t, pub.published, 1)
}

func TestAddSupplyChainEvent_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.AddSupplyChainEvent(ctx, domain.AddSupplyChainEventInput{
		RecordID:  "rec-001",
		EventType: domain.SupplyChainEventTypePlanted,
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_TENANT", errors.Reason(err))
}

func TestAddSupplyChainEvent_MissingRecordID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.AddSupplyChainEvent(ctx, domain.AddSupplyChainEventInput{
		EventType: domain.SupplyChainEventTypePlanted,
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_RECORD_ID", errors.Reason(err))
}

func TestAddSupplyChainEvent_InvalidEventType(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.AddSupplyChainEvent(ctx, domain.AddSupplyChainEventInput{
		RecordID:  "rec-001",
		EventType: "INVALID_TYPE",
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_EVENT_TYPE", errors.Reason(err))
}

func TestAddSupplyChainEvent_RecordNotFound(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.AddSupplyChainEvent(ctx, domain.AddSupplyChainEventInput{
		RecordID:  "nonexistent",
		EventType: domain.SupplyChainEventTypePlanted,
	})
	require.Error(t, err)
	assert.True(t, errors.IsNotFound(err))
}

// ---------------------------------------------------------------------------
// Tests: GetSupplyChain
// ---------------------------------------------------------------------------

func TestGetSupplyChain_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	seedRecord(repo, "rec-001", "tenant-1")
	repo.events["rec-001"] = []domain.SupplyChainEvent{
		{ID: "e1", RecordID: "rec-001", EventType: domain.SupplyChainEventTypePlanted},
		{ID: "e2", RecordID: "rec-001", EventType: domain.SupplyChainEventTypeHarvested},
	}

	events, err := svc.GetSupplyChain(ctx, "rec-001")
	require.NoError(t, err)
	assert.Len(t, events, 2)
}

func TestGetSupplyChain_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.GetSupplyChain(ctx, "rec-001")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestGetSupplyChain_MissingRecordID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetSupplyChain(ctx, "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_RECORD_ID", errors.Reason(err))
}

// ---------------------------------------------------------------------------
// Tests: CreateCertification
// ---------------------------------------------------------------------------

func TestCreateCertification_HappyPath(t *testing.T) {
	repo, pub, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	seedRecord(repo, "rec-001", "tenant-1")

	input := domain.CreateCertificationInput{
		RecordID:   "rec-001",
		CertType:   domain.CertificationTypeOrganic,
		CertNumber: "ORG-2026-001",
		IssuedBy:   "Certification Authority",
	}

	cert, err := svc.CreateCertification(ctx, input)
	require.NoError(t, err)
	assert.NotEmpty(t, cert.ID)
	assert.Equal(t, domain.CertificationStatusPending, cert.Status)
	assert.Equal(t, "tenant-1", cert.TenantID)
	assert.Len(t, pub.published, 1)
}

func TestCreateCertification_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.CreateCertification(ctx, domain.CreateCertificationInput{
		RecordID: "rec-001",
		CertType: domain.CertificationTypeOrganic,
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestCreateCertification_MissingRecordID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CreateCertification(ctx, domain.CreateCertificationInput{
		CertType: domain.CertificationTypeOrganic,
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_RECORD_ID", errors.Reason(err))
}

func TestCreateCertification_InvalidCertType(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CreateCertification(ctx, domain.CreateCertificationInput{
		RecordID: "rec-001",
		CertType: "INVALID_CERT",
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_CERT_TYPE", errors.Reason(err))
}

// ---------------------------------------------------------------------------
// Tests: GetCertification
// ---------------------------------------------------------------------------

func TestGetCertification_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.certifications["cert-001"] = &domain.Certification{
		ID:       "cert-001",
		TenantID: "tenant-1",
		RecordID: "rec-001",
		CertType: domain.CertificationTypeOrganic,
		Status:   domain.CertificationStatusPending,
	}

	cert, err := svc.GetCertification(ctx, "cert-001")
	require.NoError(t, err)
	assert.Equal(t, "cert-001", cert.ID)
}

func TestGetCertification_MissingID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetCertification(ctx, "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_ID", errors.Reason(err))
}

func TestGetCertification_NotFound(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetCertification(ctx, "nonexistent")
	require.Error(t, err)
	assert.True(t, errors.IsNotFound(err))
}

// ---------------------------------------------------------------------------
// Tests: VerifyCertification
// ---------------------------------------------------------------------------

func TestVerifyCertification_HappyPath(t *testing.T) {
	repo, pub, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	futureExpiry := time.Now().Add(365 * 24 * time.Hour)
	repo.certifications["cert-001"] = &domain.Certification{
		ID:         "cert-001",
		TenantID:   "tenant-1",
		RecordID:   "rec-001",
		CertType:   domain.CertificationTypeOrganic,
		Status:     domain.CertificationStatusPending,
		ExpiryDate: &futureExpiry,
	}

	verified, err := svc.VerifyCertification(ctx, "cert-001", "auditor-1")
	require.NoError(t, err)
	assert.Equal(t, domain.CertificationStatusActive, verified.Status)
	assert.Equal(t, "auditor-1", verified.VerifiedBy)
	assert.NotNil(t, verified.VerifiedAt)
	assert.Len(t, pub.published, 1)
}

func TestVerifyCertification_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.VerifyCertification(ctx, "cert-001", "auditor-1")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestVerifyCertification_MissingID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.VerifyCertification(ctx, "", "auditor-1")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_ID", errors.Reason(err))
}

func TestVerifyCertification_MissingVerifier(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.VerifyCertification(ctx, "cert-001", "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_VERIFIER", errors.Reason(err))
}

func TestVerifyCertification_AlreadyActive(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.certifications["cert-001"] = &domain.Certification{
		ID:       "cert-001",
		TenantID: "tenant-1",
		Status:   domain.CertificationStatusActive, // not PENDING
	}

	_, err := svc.VerifyCertification(ctx, "cert-001", "auditor-1")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_STATUS", errors.Reason(err))
}

func TestVerifyCertification_Expired(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	pastExpiry := time.Now().Add(-24 * time.Hour)
	repo.certifications["cert-001"] = &domain.Certification{
		ID:         "cert-001",
		TenantID:   "tenant-1",
		Status:     domain.CertificationStatusPending,
		ExpiryDate: &pastExpiry,
	}

	_, err := svc.VerifyCertification(ctx, "cert-001", "auditor-1")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "CERTIFICATION_EXPIRED", errors.Reason(err))
}

// ---------------------------------------------------------------------------
// Tests: RevokeCertification
// ---------------------------------------------------------------------------

func TestRevokeCertification_HappyPath(t *testing.T) {
	repo, pub, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.certifications["cert-001"] = &domain.Certification{
		ID:       "cert-001",
		TenantID: "tenant-1",
		RecordID: "rec-001",
		CertType: domain.CertificationTypeOrganic,
		Status:   domain.CertificationStatusActive,
	}

	revoked, err := svc.RevokeCertification(ctx, "cert-001", "fraud detected")
	require.NoError(t, err)
	assert.Equal(t, domain.CertificationStatusRevoked, revoked.Status)
	assert.Len(t, pub.published, 1)
}

func TestRevokeCertification_NotActive(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.certifications["cert-001"] = &domain.Certification{
		ID:       "cert-001",
		TenantID: "tenant-1",
		Status:   domain.CertificationStatusPending, // not ACTIVE
	}

	_, err := svc.RevokeCertification(ctx, "cert-001", "reason")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_STATUS", errors.Reason(err))
}

func TestRevokeCertification_MissingID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.RevokeCertification(ctx, "", "reason")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_ID", errors.Reason(err))
}

// ---------------------------------------------------------------------------
// Tests: CreateBatch
// ---------------------------------------------------------------------------

func TestCreateBatch_HappyPath(t *testing.T) {
	repo, pub, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	seedRecord(repo, "rec-001", "tenant-1")

	input := domain.CreateBatchInput{
		RecordID:    "rec-001",
		BatchNumber: "BATCH-2026-001",
		Quantity:    100,
		Unit:        "kg",
	}
	batch, err := svc.CreateBatch(ctx, input)
	require.NoError(t, err)
	assert.NotEmpty(t, batch.ID)
	assert.Equal(t, "tenant-1", batch.TenantID)
	assert.Equal(t, "BATCH-2026-001", batch.BatchNumber)
	assert.Len(t, pub.published, 1)
}

func TestCreateBatch_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.CreateBatch(ctx, domain.CreateBatchInput{RecordID: "rec-001", BatchNumber: "B1"})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestCreateBatch_MissingRecordID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CreateBatch(ctx, domain.CreateBatchInput{BatchNumber: "B1"})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_RECORD_ID", errors.Reason(err))
}

func TestCreateBatch_MissingBatchNumber(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CreateBatch(ctx, domain.CreateBatchInput{RecordID: "rec-001"})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_BATCH_NUMBER", errors.Reason(err))
}

// ---------------------------------------------------------------------------
// Tests: GetBatch
// ---------------------------------------------------------------------------

func TestGetBatch_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.batches["batch-001"] = &domain.BatchRecord{
		ID:          "batch-001",
		TenantID:    "tenant-1",
		BatchNumber: "BATCH-001",
	}

	batch, err := svc.GetBatch(ctx, "batch-001")
	require.NoError(t, err)
	assert.Equal(t, "batch-001", batch.ID)
}

func TestGetBatch_MissingID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetBatch(ctx, "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_ID", errors.Reason(err))
}

func TestGetBatch_NotFound(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetBatch(ctx, "nonexistent")
	require.Error(t, err)
	assert.True(t, errors.IsNotFound(err))
}

// ---------------------------------------------------------------------------
// Tests: GenerateQRCode
// ---------------------------------------------------------------------------

func TestGenerateQRCode_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	seedRecord(repo, "rec-001", "tenant-1")

	input := domain.GenerateQRCodeInput{
		RecordID: "rec-001",
	}
	qr, err := svc.GenerateQRCode(ctx, input)
	require.NoError(t, err)
	assert.NotEmpty(t, qr.ID)
	assert.NotEmpty(t, qr.QRData)
	assert.NotEmpty(t, qr.ScanURL)
	assert.True(t, qr.IsActive)
	assert.Contains(t, qr.ScanURL, "rec-001")
}

func TestGenerateQRCode_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.GenerateQRCode(ctx, domain.GenerateQRCodeInput{RecordID: "rec-001"})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestGenerateQRCode_MissingRecordID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GenerateQRCode(ctx, domain.GenerateQRCodeInput{})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_RECORD_ID", errors.Reason(err))
}

func TestGenerateQRCode_CustomBaseURL(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	seedRecord(repo, "rec-001", "tenant-1")

	input := domain.GenerateQRCodeInput{
		RecordID: "rec-001",
		BaseURL:  "https://custom.example.com",
	}
	qr, err := svc.GenerateQRCode(ctx, input)
	require.NoError(t, err)
	assert.Contains(t, qr.ScanURL, "https://custom.example.com/verify/rec-001")
}

// ---------------------------------------------------------------------------
// Tests: VerifyQRCode
// ---------------------------------------------------------------------------

func TestVerifyQRCode_MissingQRData(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, _, err := svc.VerifyQRCode(ctx, "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_QR_DATA", errors.Reason(err))
}

func TestVerifyQRCode_NotFound(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, _, err := svc.VerifyQRCode(ctx, "nonexistent-qr-data")
	require.Error(t, err)
	assert.True(t, errors.IsNotFound(err))
}

func TestVerifyQRCode_Expired(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	pastExpiry := time.Now().Add(-24 * time.Hour)
	repo.qrByData["expired-qr"] = &domain.QRCodeRecord{
		ID:        "qr-001",
		RecordID:  "rec-001",
		QRData:    "expired-qr",
		ExpiresAt: &pastExpiry,
		IsActive:  true,
	}

	_, _, err := svc.VerifyQRCode(ctx, "expired-qr")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "QR_CODE_EXPIRED", errors.Reason(err))
}

// ---------------------------------------------------------------------------
// Tests: GenerateComplianceReport
// ---------------------------------------------------------------------------

func TestGenerateComplianceReport_HappyPath(t *testing.T) {
	repo, pub, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	seedRecord(repo, "rec-001", "tenant-1")

	input := domain.GenerateComplianceReportInput{
		RecordID:   "rec-001",
		ReportType: "annual",
		Auditor:    "Auditor Inc",
	}

	report, err := svc.GenerateComplianceReport(ctx, input)
	require.NoError(t, err)
	assert.NotEmpty(t, report.ID)
	assert.Equal(t, "tenant-1", report.TenantID)
	assert.Equal(t, "rec-001", report.RecordID)
	assert.Greater(t, report.ComplianceScore, float64(0))
	assert.Len(t, pub.published, 1)
}

func TestGenerateComplianceReport_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.GenerateComplianceReport(ctx, domain.GenerateComplianceReportInput{RecordID: "rec-001"})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestGenerateComplianceReport_MissingRecordID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GenerateComplianceReport(ctx, domain.GenerateComplianceReportInput{})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_RECORD_ID", errors.Reason(err))
}

// ---------------------------------------------------------------------------
// Tests: evaluateCompliance
// ---------------------------------------------------------------------------

func TestEvaluateCompliance_FullyCompliant(t *testing.T) {
	now := time.Now()
	futureExpiry := now.Add(365 * 24 * time.Hour)
	plantDate := now.Add(-90 * 24 * time.Hour)
	harvestDate := now.Add(-30 * 24 * time.Hour)

	record := &domain.TraceabilityRecord{
		OriginCountry: "India",
		OriginRegion:  "Punjab",
		FarmID:        "farm-001",
		SeedSource:    "National Seed Corp",
		PlantingDate:  &plantDate,
		HarvestDate:   &harvestDate,
	}

	events := []domain.SupplyChainEvent{
		{EventType: domain.SupplyChainEventTypePlanted, VerificationHash: "hash1"},
		{EventType: domain.SupplyChainEventTypeHarvested, VerificationHash: "hash2"},
	}

	certs := []domain.Certification{
		{Status: domain.CertificationStatusActive, ExpiryDate: &futureExpiry, CertNumber: "C1", CertType: domain.CertificationTypeOrganic},
	}

	findings, _, score, status := evaluateCompliance(record, events, certs)
	assert.Equal(t, domain.ComplianceStatusCompliant, status)
	assert.GreaterOrEqual(t, score, 80.0)
	assert.Empty(t, findings)
}

func TestEvaluateCompliance_NonCompliant(t *testing.T) {
	// Missing everything.
	record := &domain.TraceabilityRecord{}
	events := []domain.SupplyChainEvent{}
	certs := []domain.Certification{}

	findings, recommendations, score, status := evaluateCompliance(record, events, certs)
	assert.Equal(t, domain.ComplianceStatusNonCompliant, status)
	assert.Less(t, score, 50.0)
	assert.NotEmpty(t, findings)
	assert.NotEmpty(t, recommendations)
}

func TestEvaluateCompliance_DateChainInconsistency(t *testing.T) {
	harvestDate := time.Now().Add(-90 * 24 * time.Hour)
	plantDate := time.Now().Add(-30 * 24 * time.Hour) // After harvest -- inconsistent

	record := &domain.TraceabilityRecord{
		OriginCountry: "India",
		OriginRegion:  "Punjab",
		FarmID:        "farm-001",
		SeedSource:    "Seed Corp",
		PlantingDate:  &plantDate,
		HarvestDate:   &harvestDate,
	}

	findings, _, _, _ := evaluateCompliance(record, nil, nil)
	found := false
	for _, f := range findings {
		if f == "Date chain inconsistency detected: dates must follow planting -> harvest -> processing -> packaging order" {
			found = true
			break
		}
	}
	assert.True(t, found, "expected date chain inconsistency finding")
}

// ---------------------------------------------------------------------------
// Tests: CreateQualityCheckpoint
// ---------------------------------------------------------------------------

func TestCreateQualityCheckpoint_HappyPath(t *testing.T) {
	repo, pub, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	seedRecord(repo, "rec-001", "tenant-1")

	input := domain.CreateQualityCheckpointInput{
		RecordID:      "rec-001",
		CheckType:     domain.QualityCheckTypeVisual,
		Result:        domain.QualityCheckResultPass,
		InspectorName: "Inspector A",
		InspectedAt:   time.Now(),
	}

	cp, err := svc.CreateQualityCheckpoint(ctx, input)
	require.NoError(t, err)
	assert.NotEmpty(t, cp.ID)
	assert.Equal(t, "tenant-1", cp.TenantID)
	assert.Equal(t, domain.QualityCheckTypeVisual, cp.CheckType)
	assert.Equal(t, domain.QualityCheckResultPass, cp.Result)
	assert.Len(t, pub.published, 1)
}

func TestCreateQualityCheckpoint_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.CreateQualityCheckpoint(ctx, domain.CreateQualityCheckpointInput{
		RecordID: "rec-001",
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestCreateQualityCheckpoint_MissingRecordID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CreateQualityCheckpoint(ctx, domain.CreateQualityCheckpointInput{
		CheckType:     domain.QualityCheckTypeVisual,
		Result:        domain.QualityCheckResultPass,
		InspectorName: "A",
		InspectedAt:   time.Now(),
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_RECORD_ID", errors.Reason(err))
}

func TestCreateQualityCheckpoint_InvalidCheckType(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CreateQualityCheckpoint(ctx, domain.CreateQualityCheckpointInput{
		RecordID:      "rec-001",
		CheckType:     "INVALID",
		Result:        domain.QualityCheckResultPass,
		InspectorName: "A",
		InspectedAt:   time.Now(),
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_CHECK_TYPE", errors.Reason(err))
}

func TestCreateQualityCheckpoint_InvalidResult(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CreateQualityCheckpoint(ctx, domain.CreateQualityCheckpointInput{
		RecordID:      "rec-001",
		CheckType:     domain.QualityCheckTypeVisual,
		Result:        "INVALID",
		InspectorName: "A",
		InspectedAt:   time.Now(),
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_RESULT", errors.Reason(err))
}

func TestCreateQualityCheckpoint_MissingInspectorName(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CreateQualityCheckpoint(ctx, domain.CreateQualityCheckpointInput{
		RecordID:    "rec-001",
		CheckType:   domain.QualityCheckTypeVisual,
		Result:      domain.QualityCheckResultPass,
		InspectedAt: time.Now(),
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_INSPECTOR_NAME", errors.Reason(err))
}

func TestCreateQualityCheckpoint_MissingInspectedAt(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CreateQualityCheckpoint(ctx, domain.CreateQualityCheckpointInput{
		RecordID:      "rec-001",
		CheckType:     domain.QualityCheckTypeVisual,
		Result:        domain.QualityCheckResultPass,
		InspectorName: "A",
		// InspectedAt is zero
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_INSPECTED_AT", errors.Reason(err))
}

// ---------------------------------------------------------------------------
// Tests: GetQualityCheckpoint
// ---------------------------------------------------------------------------

func TestGetQualityCheckpoint_MissingID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetQualityCheckpoint(ctx, "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_ID", errors.Reason(err))
}

// ---------------------------------------------------------------------------
// Tests: ListQualityCheckpoints
// ---------------------------------------------------------------------------

func TestListQualityCheckpoints_MissingRecordID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, _, err := svc.ListQualityCheckpoints(ctx, domain.ListQualityCheckpointsFilter{})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_RECORD_ID", errors.Reason(err))
}

// ---------------------------------------------------------------------------
// Tests: UpdateRecord
// ---------------------------------------------------------------------------

func TestUpdateRecord_HappyPath(t *testing.T) {
	repo, pub, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	seedRecord(repo, "rec-001", "tenant-1")

	country := "India"
	updated, err := svc.UpdateRecord(ctx, "rec-001", domain.UpdateRecordInput{
		OriginCountry: &country,
	})
	require.NoError(t, err)
	assert.Equal(t, "rec-001", updated.ID)
	assert.Len(t, pub.published, 1)
}

func TestUpdateRecord_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.UpdateRecord(ctx, "rec-001", domain.UpdateRecordInput{})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestUpdateRecord_MissingID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.UpdateRecord(ctx, "", domain.UpdateRecordInput{})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_ID", errors.Reason(err))
}

// ---------------------------------------------------------------------------
// Tests: GetComplianceReport
// ---------------------------------------------------------------------------

func TestGetComplianceReport_MissingID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetComplianceReport(ctx, "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_ID", errors.Reason(err))
}

func TestGetComplianceReport_NotFound(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetComplianceReport(ctx, "nonexistent")
	require.Error(t, err)
	assert.True(t, errors.IsNotFound(err))
}

// ---------------------------------------------------------------------------
// Tests: ListComplianceReports
// ---------------------------------------------------------------------------

func TestListComplianceReports_MissingRecordID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, _, err := svc.ListComplianceReports(ctx, domain.ListComplianceReportsFilter{})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_RECORD_ID", errors.Reason(err))
}

// ---------------------------------------------------------------------------
// Tests: ListCertifications
// ---------------------------------------------------------------------------

func TestListCertifications_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, _, err := svc.ListCertifications(ctx, domain.ListCertificationsFilter{})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

// ---------------------------------------------------------------------------
// Tests: ListBatches
// ---------------------------------------------------------------------------

func TestListBatches_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, _, err := svc.ListBatches(ctx, domain.ListBatchesFilter{})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}
