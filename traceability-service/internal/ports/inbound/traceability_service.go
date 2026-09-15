// Package inbound defines the primary ports for the traceability-service.
package inbound

import (
	"context"

	"p9e.in/samavaya/agriculture/traceability-service/internal/domain"
)

// TraceabilityService is the primary port for all traceability business operations.
type TraceabilityService interface {
	// Records
	CreateRecord(ctx context.Context, input domain.CreateRecordInput) (*domain.TraceabilityRecord, error)
	GetRecord(ctx context.Context, id string) (*domain.TraceabilityRecord, error)
	ListRecords(ctx context.Context, filter domain.ListRecordsFilter) ([]domain.TraceabilityRecord, int64, error)

	// FindOpenRecordForField returns the field's current unharvested record, or
	// (nil, nil) if there is none.
	//
	// Exists for the event consumer: an irrigation or spraying event names a
	// field, and the chain of custody it belongs to is whatever is growing
	// there now. A field between seasons legitimately has none, so absence is
	// nil rather than an error.
	FindOpenRecordForField(ctx context.Context, fieldID string) (*domain.TraceabilityRecord, error)

	// FindRecordByBatch returns the record with this batch number, or
	// (nil, nil). Used to keep event handlers idempotent across Kafka replays.
	FindRecordByBatch(ctx context.Context, batchNumber string) (*domain.TraceabilityRecord, error)

	// Supply Chain Events
	AddSupplyChainEvent(ctx context.Context, input domain.AddSupplyChainEventInput) (*domain.SupplyChainEvent, error)
	GetSupplyChain(ctx context.Context, recordID string) ([]domain.SupplyChainEvent, error)

	// Certifications
	CreateCertification(ctx context.Context, input domain.CreateCertificationInput) (*domain.Certification, error)
	GetCertification(ctx context.Context, id string) (*domain.Certification, error)
	ListCertifications(ctx context.Context, filter domain.ListCertificationsFilter) ([]domain.Certification, int64, error)
	VerifyCertification(ctx context.Context, id, verifiedBy string) (*domain.Certification, error)

	// Batches
	CreateBatch(ctx context.Context, input domain.CreateBatchInput) (*domain.BatchRecord, error)
	GetBatch(ctx context.Context, id string) (*domain.BatchRecord, error)
	ListBatches(ctx context.Context, filter domain.ListBatchesFilter) ([]domain.BatchRecord, int64, error)

	// QR Codes
	GenerateQRCode(ctx context.Context, input domain.GenerateQRCodeInput) (*domain.QRCodeRecord, error)
	VerifyQRCode(ctx context.Context, qrData string) (*domain.TraceabilityRecord, *domain.BatchRecord, error)

	// Compliance
	GenerateComplianceReport(ctx context.Context, input domain.GenerateComplianceReportInput) (*domain.ComplianceReport, error)
	GetComplianceReport(ctx context.Context, id string) (*domain.ComplianceReport, error)
	ListComplianceReports(ctx context.Context, filter domain.ListComplianceReportsFilter) ([]domain.ComplianceReport, int32, error)

	// Quality Checkpoints
	CreateQualityCheckpoint(ctx context.Context, input domain.CreateQualityCheckpointInput) (*domain.QualityCheckpoint, error)
	GetQualityCheckpoint(ctx context.Context, id string) (*domain.QualityCheckpoint, error)
	ListQualityCheckpoints(ctx context.Context, filter domain.ListQualityCheckpointsFilter) ([]domain.QualityCheckpoint, int32, error)

	// Record Update
	UpdateRecord(ctx context.Context, id string, input domain.UpdateRecordInput) (*domain.TraceabilityRecord, error)

	// Certification Revocation
	RevokeCertification(ctx context.Context, id, reason string) (*domain.Certification, error)
}
