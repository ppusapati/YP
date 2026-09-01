// Package inbound defines the primary ports for the plant-diagnosis-service.
package inbound

import (
	"context"

	"p9e.in/samavaya/agriculture/plant-diagnosis-service/internal/domain"
)

// DiagnosisService is the primary port for all diagnosis business operations.
type DiagnosisService interface {
	SubmitDiagnosis(ctx context.Context, req *domain.DiagnosisRequest) (*domain.DiagnosisRequest, error)
	GetDiagnosis(ctx context.Context, id string) (*domain.DiagnosisRequest, error)
	ListDiagnoses(ctx context.Context, params domain.ListDiagnosesParams) ([]domain.DiagnosisRequest, int32, error)
	GetDiseaseInfo(ctx context.Context, id string) (*domain.DiseaseInfo, error)
	ListDiseases(ctx context.Context, params domain.ListDiseasesParams) ([]domain.DiseaseInfo, int32, error)
	GetTreatmentPlan(ctx context.Context, diagnosisID string) (*domain.TreatmentPlan, error)
	IdentifySpecies(ctx context.Context, images []domain.DiagnosisImage) ([]domain.PlantSpecies, error)
	DetectNutrientDeficiency(ctx context.Context, speciesID string, images []domain.DiagnosisImage) ([]domain.NutrientDeficiency, error)
	DetectPestDamage(ctx context.Context, speciesID string, images []domain.DiagnosisImage) ([]domain.PestDamage, error)
}
