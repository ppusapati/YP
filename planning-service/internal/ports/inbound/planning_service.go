// Package inbound defines the primary ports for planning-service.
package inbound

import (
	"context"

	"p9e.in/samavaya/agriculture/planning-service/internal/domain"
)

// PlanningService is the primary port for season planning.
type PlanningService interface {
	CreatePlan(ctx context.Context, p *domain.SeasonPlan) (*domain.SeasonPlan, error)
	GetPlan(ctx context.Context, id string) (*domain.SeasonPlan, error)
	ListPlans(ctx context.Context, params domain.ListPlansParams) ([]domain.SeasonPlan, int64, error)
	UpdatePlan(ctx context.Context, p *domain.SeasonPlan, baseVersion int64) (*domain.SeasonPlan, error)
	CommitPlan(ctx context.Context, id string) (*domain.SeasonPlan, error)

	CheckRotation(ctx context.Context, fieldID, crop string) (domain.RotationCheck, error)
	GetSowingWindow(ctx context.Context, fieldID, crop string, season domain.Season, year int) (domain.SowingWindow, error)
}
