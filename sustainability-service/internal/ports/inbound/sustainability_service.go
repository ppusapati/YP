// Package inbound defines the primary ports for sustainability-service.
package inbound

import (
	"context"
	"time"

	"p9e.in/samavaya/agriculture/sustainability-service/internal/domain"
)

// ExportPack is a rendered certification evidence pack.
type ExportPack struct {
	Filename    string
	Content     []byte
	ContentType string
	Check       domain.CertificationCheck
}

// SustainabilityService is the primary port for emissions and certification.
type SustainabilityService interface {
	RecordInputUse(ctx context.Context, in *domain.InputUse) (*domain.InputUse, error)
	ListInputUse(ctx context.Context, params domain.ListInputUseParams) ([]domain.InputUse, int64, error)

	ComputeFootprint(ctx context.Context, params domain.FootprintParams) (*domain.Footprint, error)
	GetFootprint(ctx context.Context, id string) (*domain.Footprint, error)
	ListFootprints(ctx context.Context, params domain.ListFootprintsParams) ([]domain.Footprint, int64, error)

	CheckCertification(ctx context.Context, fieldID string, standard domain.CertificationStandard, conversionStartedOn time.Time) (domain.CertificationCheck, error)
	ExportCertificationPack(ctx context.Context, fieldID string, standard domain.CertificationStandard, conversionStartedOn time.Time, allowIncomplete bool) (ExportPack, error)
}
