// Package outbound defines the secondary ports for soil-lab-service.
package outbound

import (
	"context"

	"p9e.in/samavaya/agriculture/soil-lab-service/internal/domain"
)

// LabRepository is the secondary port for lab and report persistence.
type LabRepository interface {
	CreateLab(ctx context.Context, lab *domain.Lab) (*domain.Lab, error)
	GetLab(ctx context.Context, id, tenantID string) (*domain.Lab, error)
	ListLabs(ctx context.Context, params domain.ListLabsParams) ([]domain.Lab, int64, error)

	CreateReport(ctx context.Context, r *domain.LabReport) (*domain.LabReport, error)
	GetReport(ctx context.Context, id, tenantID string) (*domain.LabReport, error)
	// FindByContentHash is what makes a re-upload return the existing report
	// rather than creating a second set of soil samples for one set of results.
	FindByContentHash(ctx context.Context, hash, tenantID string) (*domain.LabReport, error)
	ListReports(ctx context.Context, params domain.ListReportsParams) ([]domain.LabReport, int64, error)
	SaveReport(ctx context.Context, r *domain.LabReport) error
}

// SoilClient is the secondary port for creating samples in soil-service.
//
// An interface rather than a direct dependency on soil-service's generated
// code, so this service's domain does not have to know another service's
// proto — and so the application layer is testable without one running.
type SoilClient interface {
	// CreateSamples returns the ids it created. A partial failure returns what
	// it managed along with the error, because the report has to record which
	// rows made it: re-applying all of them would duplicate the ones that did.
	CreateSamples(ctx context.Context, samples []domain.SoilSample) ([]string, error)
}

// BlobStore is the secondary port for keeping the original file.
//
// The file is kept whatever happens to the parse. A lab report is the evidence
// behind a fertiliser decision, and a PDF is not parsed at all — it exists to
// be read by a person.
type BlobStore interface {
	Put(ctx context.Context, key string, content []byte, contentType string) (url string, err error)
}

// EventPublisher is the secondary port for emitting domain events.
type EventPublisher interface {
	Publish(ctx context.Context, topic, key string, payload []byte) error
}
