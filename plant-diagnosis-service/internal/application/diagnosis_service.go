// Package application contains the plant-diagnosis-service application service.
package application

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	"p9e.in/samavaya/agriculture/plant-diagnosis-service/internal/ai"
	"p9e.in/samavaya/agriculture/plant-diagnosis-service/internal/domain"
	"p9e.in/samavaya/agriculture/plant-diagnosis-service/internal/ports/inbound"
	"p9e.in/samavaya/agriculture/plant-diagnosis-service/internal/ports/outbound"
)

const (
	serviceName           = "plant-diagnosis-service"
	eventTopic            = "samavaya.agriculture.plant-diagnosis.events"
	maxPageSize     int32 = 100
	defaultPageSize       = int32(20)

	placeholderModelVersion = "v0.1.0-placeholder"
)

type diagnosisService struct {
	repo        outbound.DiagnosisRepository
	pub         outbound.EventPublisher
	fieldClient outbound.FieldClient
	farmClient  outbound.FarmClient
	pool        *pgxpool.Pool
	log         *p9log.Helper
	aiClient    *ai.AIClient
}

// NewDiagnosisService creates a new application-layer DiagnosisService.
func NewDiagnosisService(
	repo outbound.DiagnosisRepository,
	pub outbound.EventPublisher,
	fieldClient outbound.FieldClient,
	farmClient outbound.FarmClient,
	pool *pgxpool.Pool,
	log p9log.Logger,
	aiClient *ai.AIClient,
) inbound.DiagnosisService {
	return &diagnosisService{
		repo:        repo,
		pub:         pub,
		fieldClient: fieldClient,
		farmClient:  farmClient,
		pool:        pool,
		log:         p9log.NewHelper(p9log.With(log, "component", "DiagnosisService")),
		aiClient:    aiClient,
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// SubmitDiagnosis
// ─────────────────────────────────────────────────────────────────────────────

func (s *diagnosisService) SubmitDiagnosis(ctx context.Context, req *domain.DiagnosisRequest) (*domain.DiagnosisRequest, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if req.FarmID == "" {
		return nil, errors.BadRequest("INVALID_FARM_ID", "farm_id is required")
	}
	if userID == "" {
		userID = "system"
	}

	req.TenantID = tenantID
	req.CreatedBy = userID
	req.Status = domain.DiagnosisStatusPending
	req.Version = 1

	created, err := s.repo.CreateDiagnosisRequest(ctx, req)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.plant-diagnosis.created", created.ID, map[string]interface{}{
		"plant_diagnosis_id": created.ID, "tenant_id": tenantID,
	})
	s.log.Infow("msg", "diagnosis submitted", "id", created.ID)
	return created, nil
}

// ─────────────────────────────────────────────────────────────────────────────
// GetDiagnosis
// ─────────────────────────────────────────────────────────────────────────────

func (s *diagnosisService) GetDiagnosis(ctx context.Context, id string) (*domain.DiagnosisRequest, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if id == "" {
		return nil, errors.BadRequest("MISSING_ID", "diagnosis ID is required")
	}

	diag, err := s.repo.GetDiagnosisRequestByID(ctx, id, tenantID)
	if err != nil {
		return nil, err
	}

	// Attempt to join the result.
	result, err := s.repo.GetDiagnosisResultByRequestID(ctx, id, tenantID)
	if err != nil {
		s.log.Errorw("msg", "failed to fetch diagnosis result", "diagnosis_id", id, "error", err)
	}
	if result != nil {
		diag.Result = result
	}

	return diag, nil
}

// ─────────────────────────────────────────────────────────────────────────────
// ListDiagnoses
// ─────────────────────────────────────────────────────────────────────────────

func (s *diagnosisService) ListDiagnoses(ctx context.Context, params domain.ListDiagnosesParams) ([]domain.DiagnosisRequest, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	params.TenantID = tenantID

	if params.PageSize <= 0 {
		params.PageSize = defaultPageSize
	}
	if params.PageSize > maxPageSize {
		params.PageSize = maxPageSize
	}

	return s.repo.ListDiagnosisRequests(ctx, params)
}

// ─────────────────────────────────────────────────────────────────────────────
// GetDiseaseInfo
// ─────────────────────────────────────────────────────────────────────────────

func (s *diagnosisService) GetDiseaseInfo(ctx context.Context, id string) (*domain.DiseaseInfo, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if id == "" {
		return nil, errors.BadRequest("MISSING_ID", "disease ID is required")
	}
	return s.repo.GetDiseaseByID(ctx, id, tenantID)
}

// ─────────────────────────────────────────────────────────────────────────────
// ListDiseases
// ─────────────────────────────────────────────────────────────────────────────

func (s *diagnosisService) ListDiseases(ctx context.Context, params domain.ListDiseasesParams) ([]domain.DiseaseInfo, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	params.TenantID = tenantID

	if params.PageSize <= 0 {
		params.PageSize = defaultPageSize
	}
	if params.PageSize > maxPageSize {
		params.PageSize = maxPageSize
	}

	return s.repo.ListDiseases(ctx, params)
}

// ─────────────────────────────────────────────────────────────────────────────
// GetTreatmentPlan
// ─────────────────────────────────────────────────────────────────────────────

func (s *diagnosisService) GetTreatmentPlan(ctx context.Context, diagnosisID string) (*domain.TreatmentPlan, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if diagnosisID == "" {
		return nil, errors.BadRequest("MISSING_ID", "diagnosis_id is required")
	}

	// Verify the diagnosis exists.
	diag, err := s.repo.GetDiagnosisRequestByID(ctx, diagnosisID, tenantID)
	if err != nil {
		return nil, err
	}

	// Check for existing plan.
	plan, err := s.repo.GetTreatmentPlanByDiagnosisID(ctx, diagnosisID, tenantID)
	if err != nil {
		return nil, err
	}
	if plan != nil {
		return plan, nil
	}

	// Attempt AI-generated prescription when the AI client is available.
	if s.aiClient != nil {
		requestID := p9context.RequestID(ctx)
		if requestID == "" {
			requestID = ulid.NewString()
		}

		fieldID := ""
		if diag.FieldID != nil {
			fieldID = *diag.FieldID
		}
		cropType := ""
		if diag.PlantSpeciesID != nil {
			cropType = *diag.PlantSpeciesID
		}

		input := ai.PrescriptionInput{
			FieldID:           fieldID,
			CropType:          cropType,
			PrescriptionTypes: []string{"FERTILIZER", "IRRIGATION"},
		}

		result, aiErr := s.aiClient.GeneratePrescription(ctx, requestID, input)
		if aiErr != nil {
			s.log.Warnw("msg", "AI GeneratePrescription failed, falling back to synthetic plan", "diagnosis_id", diagnosisID, "error", aiErr)
		} else {
			aiPlan := s.mapPrescriptionToTreatmentPlan(tenantID, diagnosisID, result)
			created, createErr := s.repo.CreateTreatmentPlan(ctx, aiPlan)
			if createErr != nil {
				return nil, createErr
			}
			return created, nil
		}
	}

	// Fall back to synthetic placeholder plan.
	syntheticPlan := s.generateSyntheticTreatmentPlan(tenantID, diagnosisID)
	created, err := s.repo.CreateTreatmentPlan(ctx, syntheticPlan)
	if err != nil {
		return nil, err
	}
	return created, nil
}

func (s *diagnosisService) generateSyntheticTreatmentPlan(tenantID, diagnosisID string) *domain.TreatmentPlan {
	steps := []domain.TreatmentStep{
		{StepNumber: 1, Action: "Inspect affected plants closely", Notes: "Document visual symptoms", DurationDays: 1},
		{StepNumber: 2, Action: "Apply recommended treatment", Product: "Pending analysis", Frequency: "As directed", DurationDays: 7},
		{StepNumber: 3, Action: "Monitor progress and re-evaluate", Notes: "Reassess after treatment period", DurationDays: 14},
	}
	stepsJSON, _ := json.Marshal(steps)
	desc := "Auto-generated treatment plan pending full AI analysis"
	cost := "TBD"
	days := int32(22)

	return &domain.TreatmentPlan{
		TenantID:      tenantID,
		DiagnosisID:   diagnosisID,
		Title:         "Preliminary Treatment Plan",
		Description:   &desc,
		Priority:      string(domain.SeverityUnspecified),
		Steps:         stepsJSON,
		EstimatedCost: &cost,
		EstimatedDays: &days,
	}
}

// mapPrescriptionToTreatmentPlan converts an AI GeneratePrescription result
// into the domain TreatmentPlan model.
func (s *diagnosisService) mapPrescriptionToTreatmentPlan(tenantID, diagnosisID string, result *ai.PrescriptionResult) *domain.TreatmentPlan {
	steps := make([]domain.TreatmentStep, 0, len(result.Prescriptions))
	var totalAmount float64

	for i, rx := range result.Prescriptions {
		step := domain.TreatmentStep{
			StepNumber: int32(i + 1),
			Action:     fmt.Sprintf("Apply %s prescription", rx.PrescriptionType),
			Product:    rx.PrescriptionType,
			Dosage:     fmt.Sprintf("%.2f %s total", rx.TotalAmount, rx.Unit),
		}
		if len(rx.ZoneSummaries) > 0 {
			step.Notes = fmt.Sprintf("Variable-rate across %d zone(s); mean rate %.2f %s",
				len(rx.ZoneSummaries), rx.ZoneSummaries[0].MeanRate, rx.Unit)
		}
		steps = append(steps, step)
		totalAmount += rx.TotalAmount
	}

	stepsJSON, _ := json.Marshal(steps)

	desc := fmt.Sprintf("AI-generated prescription plan (est. cost savings %.1f%%, yield gain %.1f%%)",
		result.EstimatedCostSavingsPct, result.EstimatedYieldGainPct)
	cost := fmt.Sprintf("%.2f total units", totalAmount)
	days := int32(len(result.Prescriptions) * 7)

	return &domain.TreatmentPlan{
		TenantID:      tenantID,
		DiagnosisID:   diagnosisID,
		Title:         "AI-Generated Treatment Plan",
		Description:   &desc,
		Priority:      string(domain.SeverityModerate),
		Steps:         stepsJSON,
		EstimatedCost: &cost,
		EstimatedDays: &days,
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// IdentifySpecies (synthetic placeholder)
// ─────────────────────────────────────────────────────────────────────────────

func (s *diagnosisService) IdentifySpecies(ctx context.Context, images []domain.DiagnosisImage) ([]domain.PlantSpecies, error) {
	syntheticResult := []domain.PlantSpecies{
		{
			ID:             ulid.NewString(),
			CommonName:     "Unknown",
			ScientificName: "Analysis pending",
			Family:         "",
			Confidence:     0.0,
		},
	}

	if s.aiClient == nil {
		return syntheticResult, nil
	}

	requestID := p9context.RequestID(ctx)
	if requestID == "" {
		requestID = ulid.NewString()
	}

	aiImages := make([]ai.ImageInput, len(images))
	for i, img := range images {
		aiImages[i] = ai.ImageInput{
			ImageURL:  img.ImageURL,
			ImageType: img.ImageType,
			MimeType:  img.MimeType,
		}
	}

	result, err := s.aiClient.ClassifyPlant(ctx, requestID, aiImages)
	if err != nil {
		s.log.Warnw("msg", "AI ClassifyPlant failed, returning synthetic fallback", "error", err)
		return syntheticResult, nil
	}

	return []domain.PlantSpecies{
		{
			ID:             result.SpeciesID,
			CommonName:     result.CommonName,
			ScientificName: result.ScientificName,
			Family:         result.Family,
			Confidence:     result.Confidence,
		},
	}, nil
}

// ─────────────────────────────────────────────────────────────────────────────
// DetectNutrientDeficiency (synthetic placeholder)
// ─────────────────────────────────────────────────────────────────────────────

func (s *diagnosisService) DetectNutrientDeficiency(ctx context.Context, speciesID string, images []domain.DiagnosisImage) ([]domain.NutrientDeficiency, error) {
	syntheticResult := []domain.NutrientDeficiency{
		{
			Nutrient:        "Nitrogen",
			ConfidenceScore: 0.5,
			Severity:        domain.SeverityModerate,
			Description:     "Possible nitrogen deficiency detected",
		},
	}

	if s.aiClient == nil {
		return syntheticResult, nil
	}

	requestID := p9context.RequestID(ctx)
	if requestID == "" {
		requestID = ulid.NewString()
	}

	aiImages := make([]ai.ImageInput, len(images))
	for i, img := range images {
		aiImages[i] = ai.ImageInput{
			ImageURL:  img.ImageURL,
			ImageType: img.ImageType,
			MimeType:  img.MimeType,
		}
	}

	result, err := s.aiClient.DetectNutrientDeficiency(ctx, requestID, aiImages, speciesID)
	if err != nil {
		s.log.Warnw("msg", "AI DetectNutrientDeficiency failed, returning synthetic fallback", "error", err)
		return syntheticResult, nil
	}

	deficiencies := make([]domain.NutrientDeficiency, len(result.Deficiencies))
	for i, d := range result.Deficiencies {
		deficiencies[i] = domain.NutrientDeficiency{
			Nutrient:               d.Nutrient,
			ConfidenceScore:        d.ConfidenceScore,
			Severity:               domain.SeverityLevel(d.Severity),
			Description:            d.Description,
			VisualSymptoms:         d.VisualSymptoms,
			RecommendedFertilizers: d.RecommendedFertilizers,
			ApplicationMethod:      d.ApplicationMethod,
		}
	}

	return deficiencies, nil
}

// ─────────────────────────────────────────────────────────────────────────────
// DetectPestDamage (synthetic placeholder)
// ─────────────────────────────────────────────────────────────────────────────

func (s *diagnosisService) DetectPestDamage(ctx context.Context, speciesID string, images []domain.DiagnosisImage) ([]domain.PestDamage, error) {
	syntheticResult := []domain.PestDamage{
		{
			PestID:          ulid.NewString(),
			PestName:        "Analysis pending",
			ConfidenceScore: 0.0,
			DamageLevel:     domain.SeverityUnspecified,
		},
	}

	if s.aiClient == nil {
		return syntheticResult, nil
	}

	requestID := p9context.RequestID(ctx)
	if requestID == "" {
		requestID = ulid.NewString()
	}

	aiImages := make([]ai.ImageInput, len(images))
	for i, img := range images {
		aiImages[i] = ai.ImageInput{
			ImageURL:  img.ImageURL,
			ImageType: img.ImageType,
			MimeType:  img.MimeType,
		}
	}

	result, err := s.aiClient.DetectPests(ctx, requestID, aiImages, speciesID)
	if err != nil {
		s.log.Warnw("msg", "AI DetectPests failed, returning synthetic fallback", "error", err)
		return syntheticResult, nil
	}

	pests := make([]domain.PestDamage, len(result.Pests))
	for i, p := range result.Pests {
		pests[i] = domain.PestDamage{
			PestID:          p.PestID,
			PestName:        p.PestName,
			ScientificName:  p.ScientificName,
			ConfidenceScore: p.ConfidenceScore,
			DamageLevel:     domain.SeverityLevel(p.DamageLevel),
			Description:     p.Description,
			DamagePattern:   p.DamagePattern,
			ControlMethods:  p.ControlMethods,
		}
	}

	return pests, nil
}

// ─────────────────────────────────────────────────────────────────────────────
// Event publishing
// ─────────────────────────────────────────────────────────────────────────────

func (s *diagnosisService) emitEvent(ctx context.Context, eventType, aggregateID string, data map[string]interface{}) {
	if s.pub == nil {
		return
	}
	payload := map[string]interface{}{
		"id":             ulid.NewString(),
		"type":           eventType,
		"aggregate_id":   aggregateID,
		"source":         serviceName,
		"correlation_id": p9context.RequestID(ctx),
		"data":           data,
	}
	raw, err := json.Marshal(payload)
	if err != nil {
		s.log.Errorw("msg", "failed to marshal event", "error", err)
		return
	}
	if err := s.pub.Publish(ctx, eventTopic, aggregateID, raw); err != nil {
		s.log.Errorw("msg", "failed to publish event", "event_type", eventType, "error", err)
	}
}
