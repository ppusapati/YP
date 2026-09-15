// Package application contains the plant-diagnosis-service application service.
package application

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"

	"github.com/jackc/pgx/v5/pgxpool"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"
	"p9e.in/samavaya/packages/urlsafe"

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
	fetcher     *ai.ImageFetcher
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
		fetcher:     ai.NewImageFetcher(),
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

	// Analyse before returning, so the response carries the answer the caller
	// asked for. The alternative — leaving the request PENDING for a worker —
	// needs a worker, and until now there was none: every diagnosis ever
	// submitted stayed pending forever.
	if result := s.analyse(ctx, created); result != nil {
		created.Result = result
		created.Status = domain.DiagnosisStatusCompleted
	}

	s.log.Infow("msg", "diagnosis submitted", "id", created.ID, "status", string(created.Status))
	return created, nil
}

// analyse runs the vision models over a request's images and stores what they
// found. Returns nil when no result could be produced, leaving the request
// pending rather than recording an empty diagnosis as if it were an answer.
func (s *diagnosisService) analyse(ctx context.Context, req *domain.DiagnosisRequest) *domain.DiagnosisResult {
	if s.aiClient == nil || len(req.Images) == 0 {
		return nil
	}

	if err := s.repo.UpdateDiagnosisRequestStatus(ctx, req.ID, req.TenantID, domain.DiagnosisStatusAnalyzing); err != nil {
		s.log.Warnw("msg", "could not mark diagnosis analysing", "id", req.ID, "error", err)
	}

	images := make([]ai.ImageInput, 0, len(req.Images))
	for _, img := range req.Images {
		if err := urlsafe.ValidateImageURL(img.ImageURL); err != nil {
			s.log.Warnw("msg", "skipping image with a rejected URL", "error", err)
			continue
		}
		images = append(images, ai.ImageInput{
			ImageURL:  img.ImageURL,
			ImageType: img.ImageType,
			MimeType:  img.MimeType,
		})
	}

	// The gateway classifies bytes, not URLs: handing it a URL alone makes
	// every local model skip the image and fall through to demo weights.
	images, fetchErrs := s.fetcher.FetchAll(ctx, images)
	for _, err := range fetchErrs {
		s.log.Warnw("msg", "could not fetch a diagnosis image", "error", err)
	}
	if len(images) == 0 {
		s.log.Warnw("msg", "no usable images; leaving diagnosis pending", "id", req.ID)
		s.markFailed(ctx, req)
		return nil
	}

	requestID := p9context.RequestID(ctx)
	if requestID == "" {
		requestID = ulid.NewString()
	}
	speciesID := ""
	if req.PlantSpeciesID != nil {
		speciesID = *req.PlantSpeciesID
	}
	sctx := s.sampleContext(ctx, speciesID)
	result := &domain.DiagnosisResult{
		TenantID:           req.TenantID,
		DiagnosisRequestID: req.ID,
	}

	// Each model answers a different question, and one failing says nothing
	// about the others: a disease reading is still worth storing when the pest
	// model is down.
	var versions []string
	var explanations []ai.Explanation
	answered := false

	if diag, err := s.aiClient.DiagnoseImage(ctx, requestID, images, speciesID, sctx); err != nil {
		s.log.Warnw("msg", "AI DiagnoseImage failed", "error", err)
	} else {
		answered = true
		result.DetectedDiseases = marshalOrNil(diag.Diseases)
		health := diag.OverallHealthScore
		result.OverallHealthScore = &health
		summary := diag.Summary
		result.Summary = &summary
		result.ProcessingTimeMs = diag.ProcessingTimeMs
		versions = append(versions, diag.ModelVersion)
		explanations = append(explanations, diag.Explanations...)
	}

	if pest, err := s.aiClient.DetectPests(ctx, requestID, images, speciesID, sctx); err != nil {
		s.log.Warnw("msg", "AI DetectPests failed", "error", err)
	} else {
		answered = true
		result.PestDamage = marshalOrNil(pest.Pests)
		versions = append(versions, pest.ModelVersion)
		explanations = append(explanations, pest.Explanations...)
	}

	if nutrient, err := s.aiClient.DetectNutrientDeficiency(ctx, requestID, images, speciesID, sctx); err != nil {
		s.log.Warnw("msg", "AI DetectNutrientDeficiency failed", "error", err)
	} else {
		answered = true
		result.NutrientDeficiencies = marshalOrNil(nutrient.Deficiencies)
		versions = append(versions, nutrient.ModelVersion)
		explanations = append(explanations, nutrient.Explanations...)
	}

	if species, err := s.aiClient.ClassifyPlant(ctx, requestID, images, sctx); err != nil {
		s.log.Warnw("msg", "AI ClassifyPlant failed", "error", err)
	} else {
		answered = true
		result.IdentifiedSpecies = marshalOrNil(domain.PlantSpecies{
			ID:             species.SpeciesID,
			CommonName:     species.CommonName,
			ScientificName: species.ScientificName,
			Family:         species.Family,
			Confidence:     species.Confidence,
		})
		versions = append(versions, species.ModelVersion)
	}

	if !answered {
		s.markFailed(ctx, req)
		return nil
	}

	result.AIModelVersion = strings.Join(compact(versions), "+")
	result.Explanations = marshalOrNil(toDomainExplanations(explanations))

	stored, err := s.repo.CreateDiagnosisResult(ctx, result)
	if err != nil {
		s.log.Errorw("msg", "could not store diagnosis result", "id", req.ID, "error", err)
		s.markFailed(ctx, req)
		return nil
	}
	if err := s.repo.UpdateDiagnosisRequestStatus(ctx, req.ID, req.TenantID, domain.DiagnosisStatusCompleted); err != nil {
		s.log.Warnw("msg", "result stored but status not updated", "id", req.ID, "error", err)
	}

	s.emitEvent(ctx, "agriculture.plant-diagnosis.analysed", req.ID, map[string]interface{}{
		"plant_diagnosis_id": req.ID,
		"tenant_id":          req.TenantID,
		"model_version":      result.AIModelVersion,
	})
	return stored
}

func (s *diagnosisService) markFailed(ctx context.Context, req *domain.DiagnosisRequest) {
	if err := s.repo.UpdateDiagnosisRequestStatus(ctx, req.ID, req.TenantID, domain.DiagnosisStatusFailed); err != nil {
		s.log.Warnw("msg", "could not mark diagnosis failed", "id", req.ID, "error", err)
	}
	req.Status = domain.DiagnosisStatusFailed
}

// marshalOrNil serialises a value for a JSONB column, dropping it rather than
// storing a broken document if it cannot be encoded.
func marshalOrNil(v any) json.RawMessage {
	raw, err := json.Marshal(v)
	if err != nil {
		return nil
	}
	return raw
}

// compact drops empty strings, so a missing model version does not leave a
// stray separator in the combined one.
func compact(in []string) []string {
	out := make([]string, 0, len(in))
	for _, v := range in {
		if v != "" {
			out = append(out, v)
		}
	}
	return out
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

	// No fallback plan.
	//
	// This used to build a canned three-step plan — "Apply recommended
	// treatment", product "Pending analysis", cost "TBD" — persist it, and
	// return it as a created treatment plan. A farmer opening it saw a plan
	// with their diagnosis attached and no indication that nothing had been
	// derived from it, and it sat in the database looking like every real one.
	//
	// A treatment plan is advice about what to put on a crop. Inventing one is
	// worse than having none, so when the advisory engine cannot produce a
	// plan this says so.
	return nil, errors.ServiceUnavailable("TREATMENT_PLAN_UNAVAILABLE",
		"a treatment plan could not be generated for this diagnosis")
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

	for _, img := range images {
		if err := urlsafe.ValidateImageURL(img.ImageURL); err != nil {
			return nil, errors.BadRequest("INVALID_IMAGE_URL", fmt.Sprintf("image URL rejected: %v", err))
		}
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

	result, err := s.aiClient.ClassifyPlant(ctx, requestID, aiImages, s.sampleContext(ctx, ""))
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

// DetectNutrientDeficiency identifies nutrient deficiencies from leaf images.
//
// It returns an error rather than a guess when the model is unavailable. The
// code this replaced returned a fabricated "Nitrogen, 0.5 confidence, moderate
// severity, possible nitrogen deficiency detected" with a nil error whenever
// the AI client was missing or the call failed — and a named nutrient at a
// stated confidence reads as a finding. A farmer acting on it would apply
// nitrogen to a field that might be short of something else entirely, or of
// nothing at all.
func (s *diagnosisService) DetectNutrientDeficiency(ctx context.Context, speciesID string, images []domain.DiagnosisImage) ([]domain.NutrientDeficiency, []domain.Explanation, error) {
	for _, img := range images {
		if err := urlsafe.ValidateImageURL(img.ImageURL); err != nil {
			return nil, nil, errors.BadRequest("INVALID_IMAGE_URL", fmt.Sprintf("image URL rejected: %v", err))
		}
	}

	if s.aiClient == nil {
		return nil, nil, errors.ServiceUnavailable("NUTRIENT_ANALYSIS_UNAVAILABLE",
			"nutrient deficiency analysis is not available")
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

	result, err := s.aiClient.DetectNutrientDeficiency(ctx, requestID, aiImages, speciesID, s.sampleContext(ctx, speciesID))
	if err != nil {
		s.log.Errorw("msg", "nutrient deficiency analysis failed", "error", err)
		return nil, nil, errors.ServiceUnavailable("NUTRIENT_ANALYSIS_UNAVAILABLE",
			"nutrient deficiency analysis is not available")
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

	return deficiencies, toDomainExplanations(result.Explanations), nil
}

// ─────────────────────────────────────────────────────────────────────────────
// DetectPestDamage (synthetic placeholder)
// ─────────────────────────────────────────────────────────────────────────────

func (s *diagnosisService) DetectPestDamage(ctx context.Context, speciesID string, images []domain.DiagnosisImage) ([]domain.PestDamage, []domain.Explanation, error) {
	syntheticResult := []domain.PestDamage{
		{
			PestID:          ulid.NewString(),
			PestName:        "Analysis pending",
			ConfidenceScore: 0.0,
			DamageLevel:     domain.SeverityUnspecified,
		},
	}

	for _, img := range images {
		if err := urlsafe.ValidateImageURL(img.ImageURL); err != nil {
			return nil, nil, errors.BadRequest("INVALID_IMAGE_URL", fmt.Sprintf("image URL rejected: %v", err))
		}
	}

	if s.aiClient == nil {
		return syntheticResult, nil, nil
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

	result, err := s.aiClient.DetectPests(ctx, requestID, aiImages, speciesID, s.sampleContext(ctx, speciesID))
	if err != nil {
		s.log.Warnw("msg", "AI DetectPests failed, returning synthetic fallback", "error", err)
		return syntheticResult, nil, nil
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

	return pests, toDomainExplanations(result.Explanations), nil
}

// toDomainExplanations converts the AI client's explanations for the caller.
func toDomainExplanations(in []ai.Explanation) []domain.Explanation {
	if len(in) == 0 {
		return nil
	}
	out := make([]domain.Explanation, len(in))
	for i, e := range in {
		out[i] = domain.Explanation{
			Task:          e.Task,
			ClassName:     e.ClassName,
			HeatmapPNG:    e.HeatmapPNG,
			HeatmapWidth:  e.HeatmapWidth,
			HeatmapHeight: e.HeatmapHeight,
			FocusX:        e.FocusX,
			FocusY:        e.FocusY,
			FocusWidth:    e.FocusWidth,
			FocusHeight:   e.FocusHeight,
			FocusCoverage: e.FocusCoverage,
			Summary:       e.Summary,
			Method:        e.Method,
			Localised:     e.Localised,
		}
	}
	return out
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
