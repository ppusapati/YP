// Package inbound defines the primary ports for soil-lab-service.
package inbound

import (
	"context"

	"p9e.in/samavaya/agriculture/soil-lab-service/internal/domain"
)

// UploadResult carries the report and whether this file had been seen before.
type UploadResult struct {
	Report *domain.LabReport
	// Duplicate is true when the same bytes were uploaded before; the existing
	// report comes back rather than a second one being created.
	Duplicate bool
}

// ApplyResult carries the updated report and the samples it created.
type ApplyResult struct {
	Report           *domain.LabReport
	CreatedSampleIDs []string
}

// SoilLabService is the primary port for lab report import.
type SoilLabService interface {
	RegisterLab(ctx context.Context, lab *domain.Lab) (*domain.Lab, error)
	ListLabs(ctx context.Context, params domain.ListLabsParams) ([]domain.Lab, int64, error)

	UploadReport(ctx context.Context, labID string, format domain.ReportFormat, filename string, content []byte) (UploadResult, error)
	GetReport(ctx context.Context, id string) (*domain.LabReport, error)
	ListReports(ctx context.Context, params domain.ListReportsParams) ([]domain.LabReport, int64, error)

	ApplyReport(ctx context.Context, id string, skipBlocked bool) (ApplyResult, error)
	RejectReport(ctx context.Context, id, reason string) (*domain.LabReport, error)
}
