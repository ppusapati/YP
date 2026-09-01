// Package outbound defines the secondary ports for the plant-diagnosis-service.
package outbound

import (
	"context"

	"github.com/jackc/pgx/v5"

	"p9e.in/samavaya/agriculture/plant-diagnosis-service/internal/domain"
)

// DiagnosisRepository is the secondary port for diagnosis persistence.
type DiagnosisRepository interface {
	// diagnosis_requests
	CreateDiagnosisRequest(ctx context.Context, req *domain.DiagnosisRequest) (*domain.DiagnosisRequest, error)
	GetDiagnosisRequestByID(ctx context.Context, id, tenantID string) (*domain.DiagnosisRequest, error)
	ListDiagnosisRequests(ctx context.Context, params domain.ListDiagnosesParams) ([]domain.DiagnosisRequest, int32, error)

	// diagnosis_results
	GetDiagnosisResultByRequestID(ctx context.Context, requestID, tenantID string) (*domain.DiagnosisResult, error)

	// diseases (reference data)
	GetDiseaseByID(ctx context.Context, id, tenantID string) (*domain.DiseaseInfo, error)
	ListDiseases(ctx context.Context, params domain.ListDiseasesParams) ([]domain.DiseaseInfo, int32, error)

	// treatment_plans
	GetTreatmentPlanByDiagnosisID(ctx context.Context, diagnosisID, tenantID string) (*domain.TreatmentPlan, error)
	CreateTreatmentPlan(ctx context.Context, plan *domain.TreatmentPlan) (*domain.TreatmentPlan, error)

	WithTx(tx pgx.Tx) DiagnosisRepository
}
