package services

import (
	"context"

	"p9e.in/samavaya/agriculture/prescription-service/internal/models"
	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/p9log"
)

// PrescriptionService defines the business-logic contract for prescriptions.
type PrescriptionService interface {
	ListPrescriptions(ctx context.Context, prescriptionType string, pageSize int32, pageToken string) ([]models.PrescriptionBundle, string, error)
	GetPrescription(ctx context.Context, id string) (*models.PrescriptionBundle, error)
	GeneratePrescription(ctx context.Context, input models.GeneratePrescriptionInput) (*models.PrescriptionBundle, error)
	ExportPrescription(ctx context.Context, id, format string) (downloadURL, fileName string, err error)
}

type prescriptionService struct {
	deps   deps.ServiceDeps
	logger *p9log.Helper
}

// NewPrescriptionService creates a new PrescriptionService with the given
// dependencies.
func NewPrescriptionService(d deps.ServiceDeps) PrescriptionService {
	return &prescriptionService{
		deps:   d,
		logger: p9log.NewHelper(p9log.With(d.Log, "component", "prescription_service")),
	}
}

func (s *prescriptionService) ListPrescriptions(ctx context.Context, prescriptionType string, pageSize int32, pageToken string) ([]models.PrescriptionBundle, string, error) {
	s.logger.Infow("msg", "ListPrescriptions called", "type", prescriptionType, "page_size", pageSize)
	return nil, "", nil
}

func (s *prescriptionService) GetPrescription(ctx context.Context, id string) (*models.PrescriptionBundle, error) {
	s.logger.Infow("msg", "GetPrescription called", "id", id)
	return &models.PrescriptionBundle{}, nil
}

func (s *prescriptionService) GeneratePrescription(ctx context.Context, input models.GeneratePrescriptionInput) (*models.PrescriptionBundle, error) {
	s.logger.Infow("msg", "GeneratePrescription called", "field_id", input.FieldID, "crop_type", input.CropType)
	return &models.PrescriptionBundle{}, nil
}

func (s *prescriptionService) ExportPrescription(ctx context.Context, id, format string) (string, string, error) {
	s.logger.Infow("msg", "ExportPrescription called", "id", id, "format", format)
	return "", "", nil
}
