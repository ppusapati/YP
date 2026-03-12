package repositories

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"p9e.in/samavaya/agriculture/traceability-service/internal/models"
	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// TraceabilityRepository defines the interface for traceability data access.
type TraceabilityRepository interface {
	// Traceability Records
	CreateRecord(ctx context.Context, record *models.TraceabilityRecord) (*models.TraceabilityRecord, error)
	GetRecord(ctx context.Context, id, tenantID string) (*models.TraceabilityRecord, error)
	ListRecords(ctx context.Context, tenantID string, filter models.ListRecordsFilter) ([]models.TraceabilityRecord, int64, error)
	UpdateRecordCompliance(ctx context.Context, id, tenantID string, status models.ComplianceStatusType, updatedBy string) (*models.TraceabilityRecord, error)
	UpdateRecordQR(ctx context.Context, id, tenantID, qrData, updatedBy string) (*models.TraceabilityRecord, error)
	AppendChainOfCustody(ctx context.Context, id, tenantID, custodyEntry, updatedBy string) (*models.TraceabilityRecord, error)

	// Supply Chain Events
	CreateSupplyChainEvent(ctx context.Context, event *models.SupplyChainEvent) (*models.SupplyChainEvent, error)
	GetSupplyChainEventsByRecord(ctx context.Context, recordID string) ([]models.SupplyChainEvent, error)

	// Certifications
	CreateCertification(ctx context.Context, cert *models.Certification) (*models.Certification, error)
	GetCertification(ctx context.Context, id, tenantID string) (*models.Certification, error)
	ListCertifications(ctx context.Context, tenantID string, filter models.ListCertificationsFilter) ([]models.Certification, int64, error)
	VerifyCertification(ctx context.Context, id, tenantID, verifiedBy string) (*models.Certification, error)
	GetCertificationsByRecord(ctx context.Context, recordID, tenantID string) ([]models.Certification, error)
	GetActiveCertificationsByRecord(ctx context.Context, recordID, tenantID string) ([]models.Certification, error)

	// Batch Records
	CreateBatchRecord(ctx context.Context, batch *models.BatchRecord) (*models.BatchRecord, error)
	GetBatchRecord(ctx context.Context, id, tenantID string) (*models.BatchRecord, error)
	ListBatchRecords(ctx context.Context, tenantID string, filter models.ListBatchesFilter) ([]models.BatchRecord, int64, error)

	// QR Codes
	CreateQRCode(ctx context.Context, qr *models.QRCodeRecord) (*models.QRCodeRecord, error)
	GetQRCodeByData(ctx context.Context, qrData string) (*models.QRCodeRecord, error)
	GetQRCodesByRecord(ctx context.Context, recordID string) ([]models.QRCodeRecord, error)

	// Compliance Reports
	CreateComplianceReport(ctx context.Context, report *models.ComplianceReport) (*models.ComplianceReport, error)
	GetComplianceReport(ctx context.Context, id, tenantID string) (*models.ComplianceReport, error)
	GetComplianceReportsByRecord(ctx context.Context, recordID, tenantID string) ([]models.ComplianceReport, error)
	GetLatestComplianceReport(ctx context.Context, recordID, tenantID string) (*models.ComplianceReport, error)
}

type traceabilityRepository struct {
	pool   *pgxpool.Pool
	logger *p9log.Helper
}

// NewTraceabilityRepository creates a new TraceabilityRepository.
func NewTraceabilityRepository(d deps.ServiceDeps) TraceabilityRepository {
	return &traceabilityRepository{
		pool:   d.Pool,
		logger: p9log.NewHelper(p9log.With(d.Log, "component", "TraceabilityRepository")),
	}
}

// --- Traceability Records ---

func (r *traceabilityRepository) CreateRecord(ctx context.Context, record *models.TraceabilityRecord) (*models.TraceabilityRecord, error) {
	query := `INSERT INTO traceability_records (
		id, tenant_id, farm_id, field_id, crop_id, batch_number,
		product_type, origin_country, origin_region, seed_source,
		planting_date, harvest_date, processing_date, packaging_date,
		qr_code_data, blockchain_hash, chain_of_custody, compliance_status,
		metadata, version, created_by, updated_by, created_at, updated_at
	) VALUES (
		$1, $2, $3, $4, $5, $6,
		$7, $8, $9, $10,
		$11, $12, $13, $14,
		$15, $16, $17, $18,
		$19, $20, $21, $22, $23, $24
	) RETURNING id, tenant_id, farm_id, field_id, crop_id, batch_number,
		product_type, origin_country, origin_region, seed_source,
		planting_date, harvest_date, processing_date, packaging_date,
		qr_code_data, blockchain_hash, chain_of_custody, compliance_status,
		metadata, version, created_by, updated_by, created_at, updated_at`

	var result models.TraceabilityRecord
	err := r.pool.QueryRow(ctx, query,
		record.ID, record.TenantID, record.FarmID, record.FieldID, record.CropID, record.BatchNumber,
		record.ProductType, record.OriginCountry, record.OriginRegion, record.SeedSource,
		record.PlantingDate, record.HarvestDate, record.ProcessingDate, record.PackagingDate,
		record.QRCodeData, record.BlockchainHash, record.ChainOfCustody, string(record.ComplianceStatus),
		record.Metadata, record.Version, record.CreatedBy, record.UpdatedBy, record.CreatedAt, record.UpdatedAt,
	).Scan(
		&result.ID, &result.TenantID, &result.FarmID, &result.FieldID, &result.CropID, &result.BatchNumber,
		&result.ProductType, &result.OriginCountry, &result.OriginRegion, &result.SeedSource,
		&result.PlantingDate, &result.HarvestDate, &result.ProcessingDate, &result.PackagingDate,
		&result.QRCodeData, &result.BlockchainHash, &result.ChainOfCustody, &result.ComplianceStatus,
		&result.Metadata, &result.Version, &result.CreatedBy, &result.UpdatedBy, &result.CreatedAt, &result.UpdatedAt,
	)
	if err != nil {
		r.logger.Errorf("failed to create traceability record: %v", err)
		return nil, errors.Internal("failed to create traceability record: %v", err)
	}
	return &result, nil
}

func (r *traceabilityRepository) GetRecord(ctx context.Context, id, tenantID string) (*models.TraceabilityRecord, error) {
	query := `SELECT id, tenant_id, farm_id, field_id, crop_id, batch_number,
		product_type, origin_country, origin_region, seed_source,
		planting_date, harvest_date, processing_date, packaging_date,
		qr_code_data, blockchain_hash, chain_of_custody, compliance_status,
		metadata, version, created_by, updated_by, created_at, updated_at
	FROM traceability_records WHERE id = $1 AND tenant_id = $2`

	var result models.TraceabilityRecord
	err := r.pool.QueryRow(ctx, query, id, tenantID).Scan(
		&result.ID, &result.TenantID, &result.FarmID, &result.FieldID, &result.CropID, &result.BatchNumber,
		&result.ProductType, &result.OriginCountry, &result.OriginRegion, &result.SeedSource,
		&result.PlantingDate, &result.HarvestDate, &result.ProcessingDate, &result.PackagingDate,
		&result.QRCodeData, &result.BlockchainHash, &result.ChainOfCustody, &result.ComplianceStatus,
		&result.Metadata, &result.Version, &result.CreatedBy, &result.UpdatedBy, &result.CreatedAt, &result.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("RECORD_NOT_FOUND", fmt.Sprintf("traceability record %s not found", id))
		}
		r.logger.Errorf("failed to get traceability record: %v", err)
		return nil, errors.Internal("failed to get traceability record: %v", err)
	}
	return &result, nil
}

func (r *traceabilityRepository) ListRecords(ctx context.Context, tenantID string, filter models.ListRecordsFilter) ([]models.TraceabilityRecord, int64, error) {
	baseWhere := `WHERE tenant_id = $1`
	args := []interface{}{tenantID}
	argIdx := 2

	if filter.FarmID != "" {
		baseWhere += fmt.Sprintf(" AND farm_id = $%d", argIdx)
		args = append(args, filter.FarmID)
		argIdx++
	}
	if filter.CropID != "" {
		baseWhere += fmt.Sprintf(" AND crop_id = $%d", argIdx)
		args = append(args, filter.CropID)
		argIdx++
	}
	if filter.ProductType != "" {
		baseWhere += fmt.Sprintf(" AND product_type = $%d", argIdx)
		args = append(args, filter.ProductType)
		argIdx++
	}
	if filter.OriginCountry != "" {
		baseWhere += fmt.Sprintf(" AND origin_country = $%d", argIdx)
		args = append(args, filter.OriginCountry)
		argIdx++
	}
	if filter.ComplianceStatus != "" {
		baseWhere += fmt.Sprintf(" AND compliance_status = $%d", argIdx)
		args = append(args, filter.ComplianceStatus)
		argIdx++
	}
	if filter.Search != "" {
		baseWhere += fmt.Sprintf(` AND (
			batch_number ILIKE '%%' || $%d || '%%'
			OR product_type ILIKE '%%' || $%d || '%%'
			OR origin_region ILIKE '%%' || $%d || '%%'
		)`, argIdx, argIdx, argIdx)
		args = append(args, filter.Search)
		argIdx++
	}

	// Count query
	countQuery := fmt.Sprintf("SELECT COUNT(*) FROM traceability_records %s", baseWhere)
	var totalCount int64
	err := r.pool.QueryRow(ctx, countQuery, args...).Scan(&totalCount)
	if err != nil {
		r.logger.Errorf("failed to count traceability records: %v", err)
		return nil, 0, errors.Internal("failed to count traceability records: %v", err)
	}

	// List query
	pageSize := filter.PageSize
	if pageSize <= 0 || pageSize > 100 {
		pageSize = 20
	}
	listQuery := fmt.Sprintf(`SELECT id, tenant_id, farm_id, field_id, crop_id, batch_number,
		product_type, origin_country, origin_region, seed_source,
		planting_date, harvest_date, processing_date, packaging_date,
		qr_code_data, blockchain_hash, chain_of_custody, compliance_status,
		metadata, version, created_by, updated_by, created_at, updated_at
	FROM traceability_records %s ORDER BY created_at DESC LIMIT $%d OFFSET $%d`, baseWhere, argIdx, argIdx+1)

	args = append(args, pageSize, filter.PageOffset)

	rows, err := r.pool.Query(ctx, listQuery, args...)
	if err != nil {
		r.logger.Errorf("failed to list traceability records: %v", err)
		return nil, 0, errors.Internal("failed to list traceability records: %v", err)
	}
	defer rows.Close()

	var records []models.TraceabilityRecord
	for rows.Next() {
		var rec models.TraceabilityRecord
		if err := rows.Scan(
			&rec.ID, &rec.TenantID, &rec.FarmID, &rec.FieldID, &rec.CropID, &rec.BatchNumber,
			&rec.ProductType, &rec.OriginCountry, &rec.OriginRegion, &rec.SeedSource,
			&rec.PlantingDate, &rec.HarvestDate, &rec.ProcessingDate, &rec.PackagingDate,
			&rec.QRCodeData, &rec.BlockchainHash, &rec.ChainOfCustody, &rec.ComplianceStatus,
			&rec.Metadata, &rec.Version, &rec.CreatedBy, &rec.UpdatedBy, &rec.CreatedAt, &rec.UpdatedAt,
		); err != nil {
			r.logger.Errorf("failed to scan traceability record: %v", err)
			return nil, 0, errors.Internal("failed to scan traceability record: %v", err)
		}
		records = append(records, rec)
	}

	if err := rows.Err(); err != nil {
		return nil, 0, errors.Internal("row iteration error: %v", err)
	}

	return records, totalCount, nil
}

func (r *traceabilityRepository) UpdateRecordCompliance(ctx context.Context, id, tenantID string, status models.ComplianceStatusType, updatedBy string) (*models.TraceabilityRecord, error) {
	query := `UPDATE traceability_records
		SET compliance_status = $3, updated_by = $4, updated_at = NOW(), version = version + 1
		WHERE id = $1 AND tenant_id = $2
		RETURNING id, tenant_id, farm_id, field_id, crop_id, batch_number,
			product_type, origin_country, origin_region, seed_source,
			planting_date, harvest_date, processing_date, packaging_date,
			qr_code_data, blockchain_hash, chain_of_custody, compliance_status,
			metadata, version, created_by, updated_by, created_at, updated_at`

	var result models.TraceabilityRecord
	err := r.pool.QueryRow(ctx, query, id, tenantID, string(status), updatedBy).Scan(
		&result.ID, &result.TenantID, &result.FarmID, &result.FieldID, &result.CropID, &result.BatchNumber,
		&result.ProductType, &result.OriginCountry, &result.OriginRegion, &result.SeedSource,
		&result.PlantingDate, &result.HarvestDate, &result.ProcessingDate, &result.PackagingDate,
		&result.QRCodeData, &result.BlockchainHash, &result.ChainOfCustody, &result.ComplianceStatus,
		&result.Metadata, &result.Version, &result.CreatedBy, &result.UpdatedBy, &result.CreatedAt, &result.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("RECORD_NOT_FOUND", fmt.Sprintf("traceability record %s not found", id))
		}
		return nil, errors.Internal("failed to update compliance status: %v", err)
	}
	return &result, nil
}

func (r *traceabilityRepository) UpdateRecordQR(ctx context.Context, id, tenantID, qrData, updatedBy string) (*models.TraceabilityRecord, error) {
	query := `UPDATE traceability_records
		SET qr_code_data = $3, updated_by = $4, updated_at = NOW(), version = version + 1
		WHERE id = $1 AND tenant_id = $2
		RETURNING id, tenant_id, farm_id, field_id, crop_id, batch_number,
			product_type, origin_country, origin_region, seed_source,
			planting_date, harvest_date, processing_date, packaging_date,
			qr_code_data, blockchain_hash, chain_of_custody, compliance_status,
			metadata, version, created_by, updated_by, created_at, updated_at`

	var result models.TraceabilityRecord
	err := r.pool.QueryRow(ctx, query, id, tenantID, qrData, updatedBy).Scan(
		&result.ID, &result.TenantID, &result.FarmID, &result.FieldID, &result.CropID, &result.BatchNumber,
		&result.ProductType, &result.OriginCountry, &result.OriginRegion, &result.SeedSource,
		&result.PlantingDate, &result.HarvestDate, &result.ProcessingDate, &result.PackagingDate,
		&result.QRCodeData, &result.BlockchainHash, &result.ChainOfCustody, &result.ComplianceStatus,
		&result.Metadata, &result.Version, &result.CreatedBy, &result.UpdatedBy, &result.CreatedAt, &result.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("RECORD_NOT_FOUND", fmt.Sprintf("traceability record %s not found", id))
		}
		return nil, errors.Internal("failed to update QR code data: %v", err)
	}
	return &result, nil
}

func (r *traceabilityRepository) AppendChainOfCustody(ctx context.Context, id, tenantID, custodyEntry, updatedBy string) (*models.TraceabilityRecord, error) {
	query := `UPDATE traceability_records
		SET chain_of_custody = array_append(chain_of_custody, $3),
			updated_by = $4, updated_at = NOW(), version = version + 1
		WHERE id = $1 AND tenant_id = $2
		RETURNING id, tenant_id, farm_id, field_id, crop_id, batch_number,
			product_type, origin_country, origin_region, seed_source,
			planting_date, harvest_date, processing_date, packaging_date,
			qr_code_data, blockchain_hash, chain_of_custody, compliance_status,
			metadata, version, created_by, updated_by, created_at, updated_at`

	var result models.TraceabilityRecord
	err := r.pool.QueryRow(ctx, query, id, tenantID, custodyEntry, updatedBy).Scan(
		&result.ID, &result.TenantID, &result.FarmID, &result.FieldID, &result.CropID, &result.BatchNumber,
		&result.ProductType, &result.OriginCountry, &result.OriginRegion, &result.SeedSource,
		&result.PlantingDate, &result.HarvestDate, &result.ProcessingDate, &result.PackagingDate,
		&result.QRCodeData, &result.BlockchainHash, &result.ChainOfCustody, &result.ComplianceStatus,
		&result.Metadata, &result.Version, &result.CreatedBy, &result.UpdatedBy, &result.CreatedAt, &result.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("RECORD_NOT_FOUND", fmt.Sprintf("traceability record %s not found", id))
		}
		return nil, errors.Internal("failed to append chain of custody: %v", err)
	}
	return &result, nil
}

// --- Supply Chain Events ---

func (r *traceabilityRepository) CreateSupplyChainEvent(ctx context.Context, event *models.SupplyChainEvent) (*models.SupplyChainEvent, error) {
	query := `INSERT INTO supply_chain_events (
		id, record_id, event_type, event_timestamp, location, actor, details, verification_hash, created_at
	) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
	RETURNING id, record_id, event_type, event_timestamp, location, actor, details, verification_hash, created_at`

	var result models.SupplyChainEvent
	err := r.pool.QueryRow(ctx, query,
		event.ID, event.RecordID, string(event.EventType), event.EventTimestamp,
		event.Location, event.Actor, event.Details, event.VerificationHash, event.CreatedAt,
	).Scan(
		&result.ID, &result.RecordID, &result.EventType, &result.EventTimestamp,
		&result.Location, &result.Actor, &result.Details, &result.VerificationHash, &result.CreatedAt,
	)
	if err != nil {
		r.logger.Errorf("failed to create supply chain event: %v", err)
		return nil, errors.Internal("failed to create supply chain event: %v", err)
	}
	return &result, nil
}

func (r *traceabilityRepository) GetSupplyChainEventsByRecord(ctx context.Context, recordID string) ([]models.SupplyChainEvent, error) {
	query := `SELECT id, record_id, event_type, event_timestamp, location, actor, details, verification_hash, created_at
	FROM supply_chain_events WHERE record_id = $1 ORDER BY event_timestamp ASC`

	rows, err := r.pool.Query(ctx, query, recordID)
	if err != nil {
		return nil, errors.Internal("failed to get supply chain events: %v", err)
	}
	defer rows.Close()

	var events []models.SupplyChainEvent
	for rows.Next() {
		var e models.SupplyChainEvent
		if err := rows.Scan(
			&e.ID, &e.RecordID, &e.EventType, &e.EventTimestamp,
			&e.Location, &e.Actor, &e.Details, &e.VerificationHash, &e.CreatedAt,
		); err != nil {
			return nil, errors.Internal("failed to scan supply chain event: %v", err)
		}
		events = append(events, e)
	}
	if err := rows.Err(); err != nil {
		return nil, errors.Internal("row iteration error: %v", err)
	}
	return events, nil
}

// --- Certifications ---

func (r *traceabilityRepository) CreateCertification(ctx context.Context, cert *models.Certification) (*models.Certification, error) {
	query := `INSERT INTO certifications (
		id, tenant_id, record_id, cert_type, cert_number, issued_by,
		issued_date, expiry_date, status, verified_by, verified_at,
		metadata, version, created_at, updated_at
	) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)
	RETURNING id, tenant_id, record_id, cert_type, cert_number, issued_by,
		issued_date, expiry_date, status, verified_by, verified_at,
		metadata, version, created_at, updated_at`

	var result models.Certification
	err := r.pool.QueryRow(ctx, query,
		cert.ID, cert.TenantID, cert.RecordID, string(cert.CertType), cert.CertNumber, cert.IssuedBy,
		cert.IssuedDate, cert.ExpiryDate, string(cert.Status), cert.VerifiedBy, cert.VerifiedAt,
		cert.Metadata, cert.Version, cert.CreatedAt, cert.UpdatedAt,
	).Scan(
		&result.ID, &result.TenantID, &result.RecordID, &result.CertType, &result.CertNumber, &result.IssuedBy,
		&result.IssuedDate, &result.ExpiryDate, &result.Status, &result.VerifiedBy, &result.VerifiedAt,
		&result.Metadata, &result.Version, &result.CreatedAt, &result.UpdatedAt,
	)
	if err != nil {
		r.logger.Errorf("failed to create certification: %v", err)
		return nil, errors.Internal("failed to create certification: %v", err)
	}
	return &result, nil
}

func (r *traceabilityRepository) GetCertification(ctx context.Context, id, tenantID string) (*models.Certification, error) {
	query := `SELECT id, tenant_id, record_id, cert_type, cert_number, issued_by,
		issued_date, expiry_date, status, verified_by, verified_at,
		metadata, version, created_at, updated_at
	FROM certifications WHERE id = $1 AND tenant_id = $2`

	var result models.Certification
	err := r.pool.QueryRow(ctx, query, id, tenantID).Scan(
		&result.ID, &result.TenantID, &result.RecordID, &result.CertType, &result.CertNumber, &result.IssuedBy,
		&result.IssuedDate, &result.ExpiryDate, &result.Status, &result.VerifiedBy, &result.VerifiedAt,
		&result.Metadata, &result.Version, &result.CreatedAt, &result.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("CERTIFICATION_NOT_FOUND", fmt.Sprintf("certification %s not found", id))
		}
		return nil, errors.Internal("failed to get certification: %v", err)
	}
	return &result, nil
}

func (r *traceabilityRepository) ListCertifications(ctx context.Context, tenantID string, filter models.ListCertificationsFilter) ([]models.Certification, int64, error) {
	baseWhere := `WHERE tenant_id = $1`
	args := []interface{}{tenantID}
	argIdx := 2

	if filter.RecordID != "" {
		baseWhere += fmt.Sprintf(" AND record_id = $%d", argIdx)
		args = append(args, filter.RecordID)
		argIdx++
	}
	if filter.CertType != "" {
		baseWhere += fmt.Sprintf(" AND cert_type = $%d", argIdx)
		args = append(args, filter.CertType)
		argIdx++
	}
	if filter.Status != "" {
		baseWhere += fmt.Sprintf(" AND status = $%d", argIdx)
		args = append(args, filter.Status)
		argIdx++
	}

	countQuery := fmt.Sprintf("SELECT COUNT(*) FROM certifications %s", baseWhere)
	var totalCount int64
	err := r.pool.QueryRow(ctx, countQuery, args...).Scan(&totalCount)
	if err != nil {
		return nil, 0, errors.Internal("failed to count certifications: %v", err)
	}

	pageSize := filter.PageSize
	if pageSize <= 0 || pageSize > 100 {
		pageSize = 20
	}

	listQuery := fmt.Sprintf(`SELECT id, tenant_id, record_id, cert_type, cert_number, issued_by,
		issued_date, expiry_date, status, verified_by, verified_at,
		metadata, version, created_at, updated_at
	FROM certifications %s ORDER BY created_at DESC LIMIT $%d OFFSET $%d`, baseWhere, argIdx, argIdx+1)
	args = append(args, pageSize, filter.PageOffset)

	rows, err := r.pool.Query(ctx, listQuery, args...)
	if err != nil {
		return nil, 0, errors.Internal("failed to list certifications: %v", err)
	}
	defer rows.Close()

	var certs []models.Certification
	for rows.Next() {
		var c models.Certification
		if err := rows.Scan(
			&c.ID, &c.TenantID, &c.RecordID, &c.CertType, &c.CertNumber, &c.IssuedBy,
			&c.IssuedDate, &c.ExpiryDate, &c.Status, &c.VerifiedBy, &c.VerifiedAt,
			&c.Metadata, &c.Version, &c.CreatedAt, &c.UpdatedAt,
		); err != nil {
			return nil, 0, errors.Internal("failed to scan certification: %v", err)
		}
		certs = append(certs, c)
	}
	if err := rows.Err(); err != nil {
		return nil, 0, errors.Internal("row iteration error: %v", err)
	}
	return certs, totalCount, nil
}

func (r *traceabilityRepository) VerifyCertification(ctx context.Context, id, tenantID, verifiedBy string) (*models.Certification, error) {
	query := `UPDATE certifications
		SET status = 'ACTIVE', verified_by = $3, verified_at = NOW(), updated_at = NOW(), version = version + 1
		WHERE id = $1 AND tenant_id = $2
		RETURNING id, tenant_id, record_id, cert_type, cert_number, issued_by,
			issued_date, expiry_date, status, verified_by, verified_at,
			metadata, version, created_at, updated_at`

	var result models.Certification
	err := r.pool.QueryRow(ctx, query, id, tenantID, verifiedBy).Scan(
		&result.ID, &result.TenantID, &result.RecordID, &result.CertType, &result.CertNumber, &result.IssuedBy,
		&result.IssuedDate, &result.ExpiryDate, &result.Status, &result.VerifiedBy, &result.VerifiedAt,
		&result.Metadata, &result.Version, &result.CreatedAt, &result.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("CERTIFICATION_NOT_FOUND", fmt.Sprintf("certification %s not found", id))
		}
		return nil, errors.Internal("failed to verify certification: %v", err)
	}
	return &result, nil
}

func (r *traceabilityRepository) GetCertificationsByRecord(ctx context.Context, recordID, tenantID string) ([]models.Certification, error) {
	query := `SELECT id, tenant_id, record_id, cert_type, cert_number, issued_by,
		issued_date, expiry_date, status, verified_by, verified_at,
		metadata, version, created_at, updated_at
	FROM certifications WHERE record_id = $1 AND tenant_id = $2 ORDER BY created_at DESC`

	rows, err := r.pool.Query(ctx, query, recordID, tenantID)
	if err != nil {
		return nil, errors.Internal("failed to get certifications: %v", err)
	}
	defer rows.Close()

	var certs []models.Certification
	for rows.Next() {
		var c models.Certification
		if err := rows.Scan(
			&c.ID, &c.TenantID, &c.RecordID, &c.CertType, &c.CertNumber, &c.IssuedBy,
			&c.IssuedDate, &c.ExpiryDate, &c.Status, &c.VerifiedBy, &c.VerifiedAt,
			&c.Metadata, &c.Version, &c.CreatedAt, &c.UpdatedAt,
		); err != nil {
			return nil, errors.Internal("failed to scan certification: %v", err)
		}
		certs = append(certs, c)
	}
	return certs, rows.Err()
}

func (r *traceabilityRepository) GetActiveCertificationsByRecord(ctx context.Context, recordID, tenantID string) ([]models.Certification, error) {
	query := `SELECT id, tenant_id, record_id, cert_type, cert_number, issued_by,
		issued_date, expiry_date, status, verified_by, verified_at,
		metadata, version, created_at, updated_at
	FROM certifications WHERE record_id = $1 AND tenant_id = $2 AND status = 'ACTIVE' ORDER BY created_at DESC`

	rows, err := r.pool.Query(ctx, query, recordID, tenantID)
	if err != nil {
		return nil, errors.Internal("failed to get active certifications: %v", err)
	}
	defer rows.Close()

	var certs []models.Certification
	for rows.Next() {
		var c models.Certification
		if err := rows.Scan(
			&c.ID, &c.TenantID, &c.RecordID, &c.CertType, &c.CertNumber, &c.IssuedBy,
			&c.IssuedDate, &c.ExpiryDate, &c.Status, &c.VerifiedBy, &c.VerifiedAt,
			&c.Metadata, &c.Version, &c.CreatedAt, &c.UpdatedAt,
		); err != nil {
			return nil, errors.Internal("failed to scan certification: %v", err)
		}
		certs = append(certs, c)
	}
	return certs, rows.Err()
}

// --- Batch Records ---

func (r *traceabilityRepository) CreateBatchRecord(ctx context.Context, batch *models.BatchRecord) (*models.BatchRecord, error) {
	query := `INSERT INTO batch_records (
		id, tenant_id, record_id, batch_number, quantity, unit,
		production_date, expiry_date, storage_conditions, quality_grade,
		metadata, version, created_at, updated_at
	) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
	RETURNING id, tenant_id, record_id, batch_number, quantity, unit,
		production_date, expiry_date, storage_conditions, quality_grade,
		metadata, version, created_at, updated_at`

	var result models.BatchRecord
	err := r.pool.QueryRow(ctx, query,
		batch.ID, batch.TenantID, batch.RecordID, batch.BatchNumber, batch.Quantity, batch.Unit,
		batch.ProductionDate, batch.ExpiryDate, batch.StorageConditions, batch.QualityGrade,
		batch.Metadata, batch.Version, batch.CreatedAt, batch.UpdatedAt,
	).Scan(
		&result.ID, &result.TenantID, &result.RecordID, &result.BatchNumber, &result.Quantity, &result.Unit,
		&result.ProductionDate, &result.ExpiryDate, &result.StorageConditions, &result.QualityGrade,
		&result.Metadata, &result.Version, &result.CreatedAt, &result.UpdatedAt,
	)
	if err != nil {
		r.logger.Errorf("failed to create batch record: %v", err)
		return nil, errors.Internal("failed to create batch record: %v", err)
	}
	return &result, nil
}

func (r *traceabilityRepository) GetBatchRecord(ctx context.Context, id, tenantID string) (*models.BatchRecord, error) {
	query := `SELECT id, tenant_id, record_id, batch_number, quantity, unit,
		production_date, expiry_date, storage_conditions, quality_grade,
		metadata, version, created_at, updated_at
	FROM batch_records WHERE id = $1 AND tenant_id = $2`

	var result models.BatchRecord
	err := r.pool.QueryRow(ctx, query, id, tenantID).Scan(
		&result.ID, &result.TenantID, &result.RecordID, &result.BatchNumber, &result.Quantity, &result.Unit,
		&result.ProductionDate, &result.ExpiryDate, &result.StorageConditions, &result.QualityGrade,
		&result.Metadata, &result.Version, &result.CreatedAt, &result.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("BATCH_NOT_FOUND", fmt.Sprintf("batch record %s not found", id))
		}
		return nil, errors.Internal("failed to get batch record: %v", err)
	}
	return &result, nil
}

func (r *traceabilityRepository) ListBatchRecords(ctx context.Context, tenantID string, filter models.ListBatchesFilter) ([]models.BatchRecord, int64, error) {
	baseWhere := `WHERE tenant_id = $1`
	args := []interface{}{tenantID}
	argIdx := 2

	if filter.RecordID != "" {
		baseWhere += fmt.Sprintf(" AND record_id = $%d", argIdx)
		args = append(args, filter.RecordID)
		argIdx++
	}

	countQuery := fmt.Sprintf("SELECT COUNT(*) FROM batch_records %s", baseWhere)
	var totalCount int64
	err := r.pool.QueryRow(ctx, countQuery, args...).Scan(&totalCount)
	if err != nil {
		return nil, 0, errors.Internal("failed to count batch records: %v", err)
	}

	pageSize := filter.PageSize
	if pageSize <= 0 || pageSize > 100 {
		pageSize = 20
	}

	listQuery := fmt.Sprintf(`SELECT id, tenant_id, record_id, batch_number, quantity, unit,
		production_date, expiry_date, storage_conditions, quality_grade,
		metadata, version, created_at, updated_at
	FROM batch_records %s ORDER BY created_at DESC LIMIT $%d OFFSET $%d`, baseWhere, argIdx, argIdx+1)
	args = append(args, pageSize, filter.PageOffset)

	rows, err := r.pool.Query(ctx, listQuery, args...)
	if err != nil {
		return nil, 0, errors.Internal("failed to list batch records: %v", err)
	}
	defer rows.Close()

	var batches []models.BatchRecord
	for rows.Next() {
		var b models.BatchRecord
		if err := rows.Scan(
			&b.ID, &b.TenantID, &b.RecordID, &b.BatchNumber, &b.Quantity, &b.Unit,
			&b.ProductionDate, &b.ExpiryDate, &b.StorageConditions, &b.QualityGrade,
			&b.Metadata, &b.Version, &b.CreatedAt, &b.UpdatedAt,
		); err != nil {
			return nil, 0, errors.Internal("failed to scan batch record: %v", err)
		}
		batches = append(batches, b)
	}
	if err := rows.Err(); err != nil {
		return nil, 0, errors.Internal("row iteration error: %v", err)
	}
	return batches, totalCount, nil
}

// --- QR Codes ---

func (r *traceabilityRepository) CreateQRCode(ctx context.Context, qr *models.QRCodeRecord) (*models.QRCodeRecord, error) {
	query := `INSERT INTO qr_codes (
		id, record_id, batch_id, qr_data, qr_image_url, scan_url,
		generated_at, expires_at, is_active
	) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
	RETURNING id, record_id, batch_id, qr_data, qr_image_url, scan_url,
		generated_at, expires_at, is_active`

	var result models.QRCodeRecord
	err := r.pool.QueryRow(ctx, query,
		qr.ID, qr.RecordID, qr.BatchID, qr.QRData, qr.QRImageURL, qr.ScanURL,
		qr.GeneratedAt, qr.ExpiresAt, qr.IsActive,
	).Scan(
		&result.ID, &result.RecordID, &result.BatchID, &result.QRData, &result.QRImageURL, &result.ScanURL,
		&result.GeneratedAt, &result.ExpiresAt, &result.IsActive,
	)
	if err != nil {
		r.logger.Errorf("failed to create QR code: %v", err)
		return nil, errors.Internal("failed to create QR code: %v", err)
	}
	return &result, nil
}

func (r *traceabilityRepository) GetQRCodeByData(ctx context.Context, qrData string) (*models.QRCodeRecord, error) {
	query := `SELECT id, record_id, batch_id, qr_data, qr_image_url, scan_url,
		generated_at, expires_at, is_active
	FROM qr_codes WHERE qr_data = $1 AND is_active = TRUE`

	var result models.QRCodeRecord
	err := r.pool.QueryRow(ctx, query, qrData).Scan(
		&result.ID, &result.RecordID, &result.BatchID, &result.QRData, &result.QRImageURL, &result.ScanURL,
		&result.GeneratedAt, &result.ExpiresAt, &result.IsActive,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("QR_CODE_NOT_FOUND", "QR code not found or inactive")
		}
		return nil, errors.Internal("failed to get QR code: %v", err)
	}
	return &result, nil
}

func (r *traceabilityRepository) GetQRCodesByRecord(ctx context.Context, recordID string) ([]models.QRCodeRecord, error) {
	query := `SELECT id, record_id, batch_id, qr_data, qr_image_url, scan_url,
		generated_at, expires_at, is_active
	FROM qr_codes WHERE record_id = $1 ORDER BY generated_at DESC`

	rows, err := r.pool.Query(ctx, query, recordID)
	if err != nil {
		return nil, errors.Internal("failed to get QR codes: %v", err)
	}
	defer rows.Close()

	var qrs []models.QRCodeRecord
	for rows.Next() {
		var q models.QRCodeRecord
		if err := rows.Scan(
			&q.ID, &q.RecordID, &q.BatchID, &q.QRData, &q.QRImageURL, &q.ScanURL,
			&q.GeneratedAt, &q.ExpiresAt, &q.IsActive,
		); err != nil {
			return nil, errors.Internal("failed to scan QR code: %v", err)
		}
		qrs = append(qrs, q)
	}
	return qrs, rows.Err()
}

// --- Compliance Reports ---

func (r *traceabilityRepository) CreateComplianceReport(ctx context.Context, report *models.ComplianceReport) (*models.ComplianceReport, error) {
	query := `INSERT INTO compliance_reports (
		id, tenant_id, record_id, status, report_type,
		findings, recommendations, auditor, audit_date,
		next_audit_date, compliance_score, metadata, created_at
	) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
	RETURNING id, tenant_id, record_id, status, report_type,
		findings, recommendations, auditor, audit_date,
		next_audit_date, compliance_score, metadata, created_at`

	var result models.ComplianceReport
	err := r.pool.QueryRow(ctx, query,
		report.ID, report.TenantID, report.RecordID, string(report.Status), report.ReportType,
		report.Findings, report.Recommendations, report.Auditor, report.AuditDate,
		report.NextAuditDate, report.ComplianceScore, report.Metadata, report.CreatedAt,
	).Scan(
		&result.ID, &result.TenantID, &result.RecordID, &result.Status, &result.ReportType,
		&result.Findings, &result.Recommendations, &result.Auditor, &result.AuditDate,
		&result.NextAuditDate, &result.ComplianceScore, &result.Metadata, &result.CreatedAt,
	)
	if err != nil {
		r.logger.Errorf("failed to create compliance report: %v", err)
		return nil, errors.Internal("failed to create compliance report: %v", err)
	}
	return &result, nil
}

func (r *traceabilityRepository) GetComplianceReport(ctx context.Context, id, tenantID string) (*models.ComplianceReport, error) {
	query := `SELECT id, tenant_id, record_id, status, report_type,
		findings, recommendations, auditor, audit_date,
		next_audit_date, compliance_score, metadata, created_at
	FROM compliance_reports WHERE id = $1 AND tenant_id = $2`

	var result models.ComplianceReport
	err := r.pool.QueryRow(ctx, query, id, tenantID).Scan(
		&result.ID, &result.TenantID, &result.RecordID, &result.Status, &result.ReportType,
		&result.Findings, &result.Recommendations, &result.Auditor, &result.AuditDate,
		&result.NextAuditDate, &result.ComplianceScore, &result.Metadata, &result.CreatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("REPORT_NOT_FOUND", fmt.Sprintf("compliance report %s not found", id))
		}
		return nil, errors.Internal("failed to get compliance report: %v", err)
	}
	return &result, nil
}

func (r *traceabilityRepository) GetComplianceReportsByRecord(ctx context.Context, recordID, tenantID string) ([]models.ComplianceReport, error) {
	query := `SELECT id, tenant_id, record_id, status, report_type,
		findings, recommendations, auditor, audit_date,
		next_audit_date, compliance_score, metadata, created_at
	FROM compliance_reports WHERE record_id = $1 AND tenant_id = $2 ORDER BY created_at DESC`

	rows, err := r.pool.Query(ctx, query, recordID, tenantID)
	if err != nil {
		return nil, errors.Internal("failed to get compliance reports: %v", err)
	}
	defer rows.Close()

	var reports []models.ComplianceReport
	for rows.Next() {
		var rp models.ComplianceReport
		if err := rows.Scan(
			&rp.ID, &rp.TenantID, &rp.RecordID, &rp.Status, &rp.ReportType,
			&rp.Findings, &rp.Recommendations, &rp.Auditor, &rp.AuditDate,
			&rp.NextAuditDate, &rp.ComplianceScore, &rp.Metadata, &rp.CreatedAt,
		); err != nil {
			return nil, errors.Internal("failed to scan compliance report: %v", err)
		}
		reports = append(reports, rp)
	}
	return reports, rows.Err()
}

func (r *traceabilityRepository) GetLatestComplianceReport(ctx context.Context, recordID, tenantID string) (*models.ComplianceReport, error) {
	query := `SELECT id, tenant_id, record_id, status, report_type,
		findings, recommendations, auditor, audit_date,
		next_audit_date, compliance_score, metadata, created_at
	FROM compliance_reports WHERE record_id = $1 AND tenant_id = $2
	ORDER BY created_at DESC LIMIT 1`

	var result models.ComplianceReport
	err := r.pool.QueryRow(ctx, query, recordID, tenantID).Scan(
		&result.ID, &result.TenantID, &result.RecordID, &result.Status, &result.ReportType,
		&result.Findings, &result.Recommendations, &result.Auditor, &result.AuditDate,
		&result.NextAuditDate, &result.ComplianceScore, &result.Metadata, &result.CreatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("REPORT_NOT_FOUND", "no compliance reports found for this record")
		}
		return nil, errors.Internal("failed to get latest compliance report: %v", err)
	}
	return &result, nil
}

// Ensure unused imports are referenced.
var _ json.RawMessage
var _ time.Time
