// Package outbound defines the secondary ports for the traceability-service.
package outbound

import (
	"context"

	"p9e.in/samavaya/agriculture/traceability-service/internal/domain"
)

// TraceabilityRepository is the secondary port for traceability persistence.
type TraceabilityRepository interface {
	// Traceability Records
	CreateRecord(ctx context.Context, record *domain.TraceabilityRecord) (*domain.TraceabilityRecord, error)
	GetRecord(ctx context.Context, id, tenantID string) (*domain.TraceabilityRecord, error)
	ListRecords(ctx context.Context, tenantID string, filter domain.ListRecordsFilter) ([]domain.TraceabilityRecord, int64, error)
	UpdateRecordCompliance(ctx context.Context, id, tenantID string, status domain.ComplianceStatusType, updatedBy string) (*domain.TraceabilityRecord, error)
	UpdateRecordQR(ctx context.Context, id, tenantID, qrData, updatedBy string) (*domain.TraceabilityRecord, error)
	AppendChainOfCustody(ctx context.Context, id, tenantID, custodyEntry, updatedBy string) (*domain.TraceabilityRecord, error)

	// Supply Chain Events
	CreateSupplyChainEvent(ctx context.Context, event *domain.SupplyChainEvent) (*domain.SupplyChainEvent, error)
	GetSupplyChainEventsByRecord(ctx context.Context, recordID string) ([]domain.SupplyChainEvent, error)

	// Certifications
	CreateCertification(ctx context.Context, cert *domain.Certification) (*domain.Certification, error)
	GetCertification(ctx context.Context, id, tenantID string) (*domain.Certification, error)
	ListCertifications(ctx context.Context, tenantID string, filter domain.ListCertificationsFilter) ([]domain.Certification, int64, error)
	VerifyCertification(ctx context.Context, id, tenantID, verifiedBy string) (*domain.Certification, error)
	GetCertificationsByRecord(ctx context.Context, recordID, tenantID string) ([]domain.Certification, error)
	GetActiveCertificationsByRecord(ctx context.Context, recordID, tenantID string) ([]domain.Certification, error)

	// Batch Records
	CreateBatchRecord(ctx context.Context, batch *domain.BatchRecord) (*domain.BatchRecord, error)
	GetBatchRecord(ctx context.Context, id, tenantID string) (*domain.BatchRecord, error)
	ListBatchRecords(ctx context.Context, tenantID string, filter domain.ListBatchesFilter) ([]domain.BatchRecord, int64, error)

	// QR Codes
	CreateQRCode(ctx context.Context, qr *domain.QRCodeRecord) (*domain.QRCodeRecord, error)
	GetQRCodeByData(ctx context.Context, qrData string) (*domain.QRCodeRecord, error)
	GetQRCodesByRecord(ctx context.Context, recordID string) ([]domain.QRCodeRecord, error)

	// Compliance Reports
	CreateComplianceReport(ctx context.Context, report *domain.ComplianceReport) (*domain.ComplianceReport, error)
	GetComplianceReport(ctx context.Context, id, tenantID string) (*domain.ComplianceReport, error)
	GetComplianceReportsByRecord(ctx context.Context, recordID, tenantID string) ([]domain.ComplianceReport, error)
	GetLatestComplianceReport(ctx context.Context, recordID, tenantID string) (*domain.ComplianceReport, error)
	ListComplianceReports(ctx context.Context, filter domain.ListComplianceReportsFilter, tenantID string) ([]domain.ComplianceReport, int32, error)

	// Quality Checkpoints
	CreateQualityCheckpoint(ctx context.Context, checkpoint *domain.QualityCheckpoint) (*domain.QualityCheckpoint, error)
	GetQualityCheckpoint(ctx context.Context, id, tenantID string) (*domain.QualityCheckpoint, error)
	ListQualityCheckpoints(ctx context.Context, filter domain.ListQualityCheckpointsFilter, tenantID string) ([]domain.QualityCheckpoint, int32, error)

	// Record Update
	UpdateRecord(ctx context.Context, id, tenantID string, input domain.UpdateRecordInput, updatedBy string) (*domain.TraceabilityRecord, error)

	// Certification Revocation
	RevokeCertification(ctx context.Context, id, tenantID, reason string) (*domain.Certification, error)
}
