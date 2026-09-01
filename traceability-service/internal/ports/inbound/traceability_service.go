// Package inbound defines the primary ports for the traceability-service.
package inbound

import (
	"context"

	"p9e.in/samavaya/agriculture/traceability-service/internal/models"
)

// TraceabilityService is the primary port for all traceability business operations.
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
