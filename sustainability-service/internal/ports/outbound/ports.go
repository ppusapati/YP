// Package outbound defines the secondary ports for sustainability-service.
package outbound

import (
	"context"

	"p9e.in/samavaya/agriculture/sustainability-service/internal/domain"
)

// InputRepository is the secondary port for input-use records.
type InputRepository interface {
	CreateInput(ctx context.Context, in *domain.InputUse) (*domain.InputUse, error)
	ListInputs(ctx context.Context, params domain.ListInputUseParams) ([]domain.InputUse, int64, error)

	// AllInputs is the unpaged read the footprint and the certification check
	// need. Paging them would mean a footprint computed from the first fifty
	// applications and a certification check that missed the urea in row 51 —
	// both would look like answers.
	AllInputs(ctx context.Context, params domain.ListInputUseParams) ([]domain.InputUse, error)
}

// FootprintRepository is the secondary port for stored footprints.
type FootprintRepository interface {
	SaveFootprint(ctx context.Context, f *domain.Footprint) (*domain.Footprint, error)
	GetFootprint(ctx context.Context, id, tenantID string) (*domain.Footprint, error)
	ListFootprints(ctx context.Context, params domain.ListFootprintsParams) ([]domain.Footprint, int64, error)
}

// EventPublisher is the secondary port for emitting domain events.
type EventPublisher interface {
	Publish(ctx context.Context, topic, key string, payload []byte) error
}
