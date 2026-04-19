// Package inbound defines the primary ports for the plant-diagnosis-service.
package inbound

import (
	"context"

	"p9e.in/samavaya/agriculture/plant-diagnosis-service/internal/domain"
)

// DiagnosisService is the primary port for all diagnosis business operations.
type DiagnosisService interface {
	CreateDiagnosis(ctx context.Context, entity *domain.Diagnosis) (*domain.Diagnosis, error)
	GetDiagnosis(ctx context.Context, uuid string) (*domain.Diagnosis, error)
	ListPlantDiagnosiss(ctx context.Context, params domain.ListPlantDiagnosisParams) ([]domain.Diagnosis, int32, error)
	UpdateDiagnosis(ctx context.Context, entity *domain.Diagnosis) (*domain.Diagnosis, error)
	DeleteDiagnosis(ctx context.Context, uuid string) error
}
