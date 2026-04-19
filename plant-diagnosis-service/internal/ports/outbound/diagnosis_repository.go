// Package outbound defines the secondary ports for the plant-diagnosis-service.
package outbound

import (
	"context"

	"github.com/jackc/pgx/v5"

	"p9e.in/samavaya/agriculture/plant-diagnosis-service/internal/domain"
)

// DiagnosisRepository is the secondary port for diagnosis persistence.
type DiagnosisRepository interface {
	CreateDiagnosis(ctx context.Context, entity *domain.Diagnosis) (*domain.Diagnosis, error)
	GetDiagnosisByUUID(ctx context.Context, uuid, tenantID string) (*domain.Diagnosis, error)
	ListPlantDiagnoses(ctx context.Context, params domain.ListPlantDiagnosisParams) ([]domain.Diagnosis, int32, error)
	UpdateDiagnosis(ctx context.Context, entity *domain.Diagnosis) (*domain.Diagnosis, error)
	DeleteDiagnosis(ctx context.Context, uuid, tenantID, deletedBy string) error
	CheckDiagnosisExists(ctx context.Context, uuid, tenantID string) (bool, error)
	CheckDiagnosisNameExists(ctx context.Context, name, tenantID string) (bool, error)

	WithTx(tx pgx.Tx) DiagnosisRepository
}
