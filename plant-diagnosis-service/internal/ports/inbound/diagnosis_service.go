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
	DetectNutrientDeficiency(ctx context.Context, speciesID string, images []domain.DiagnosisImage) ([]domain.NutrientDeficiency, []domain.Explanation, error)
	DetectPestDamage(ctx context.Context, speciesID string, images []domain.DiagnosisImage) ([]domain.PestDamage, []domain.Explanation, error)

	// Human-in-the-loop label review of AI-gateway training samples.
	ListLabelReviewQueue(ctx context.Context, params domain.ListLabelReviewQueueParams) ([]domain.LabelReviewSample, int32, int32, error)
	SubmitLabelReview(ctx context.Context, input domain.SubmitLabelReviewInput) (*domain.LabelReviewSample, error)
	GetLabelReviewImage(ctx context.Context, task, sampleID string) (*domain.LabelReviewImage, error)
	// RequestSecondOpinion flags a sample as wanting another reviewer, or
	// clears the flag once the question is settled.
	RequestSecondOpinion(ctx context.Context, task, sampleID string, wanted bool) (*domain.LabelReviewSample, error)
	// ReviewAgreement reports how much reviewers agree on a task's labels.
	ReviewAgreement(ctx context.Context, task string) (*domain.ReviewAgreement, error)
}
