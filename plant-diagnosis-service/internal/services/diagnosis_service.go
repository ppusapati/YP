package services

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"

	"p9e.in/samavaya/agriculture/plant-diagnosis-service/internal/mappers"
	"p9e.in/samavaya/agriculture/plant-diagnosis-service/internal/models"
	"p9e.in/samavaya/agriculture/plant-diagnosis-service/internal/repositories"
	"p9e.in/samavaya/packages/circuitbreaker"
	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"
)

// ─────────────────────────────────────────────────────────────────────────────
// Interface
// ─────────────────────────────────────────────────────────────────────────────

// DiagnosisService provides the business logic for plant diagnosis operations.
type DiagnosisService interface {
	// Core diagnosis workflow
	SubmitDiagnosis(ctx context.Context, params SubmitDiagnosisParams) (*models.DiagnosisRequest, error)
	GetDiagnosis(ctx context.Context, id string) (*models.DiagnosisRequest, error)
	ListDiagnoses(ctx context.Context, params ListDiagnosesParams) ([]*models.DiagnosisRequest, int64, error)

	// Disease catalog
	GetDiseaseInfo(ctx context.Context, diseaseID string) (*models.DiseaseCatalog, error)
	ListDiseases(ctx context.Context, searchTerm string, pageSize, pageOffset int32) ([]*models.DiseaseCatalog, int64, error)

	// Treatment plans
	GetTreatmentPlan(ctx context.Context, diagnosisID string) (*models.TreatmentPlan, error)

	// Standalone AI capabilities
	IdentifySpecies(ctx context.Context, images []models.DiagnosisImage) (*models.AIInferenceResponse, error)
	DetectNutrientDeficiency(ctx context.Context, plantSpeciesID string, images []models.DiagnosisImage) (*models.AIInferenceResponse, error)
	DetectPestDamage(ctx context.Context, plantSpeciesID string, images []models.DiagnosisImage) (*models.AIInferenceResponse, error)
}

// ─────────────────────────────────────────────────────────────────────────────
// Params
// ─────────────────────────────────────────────────────────────────────────────

// SubmitDiagnosisParams contains the inputs for submitting a new diagnosis.
type SubmitDiagnosisParams struct {
	FarmID         string
	FieldID        string
	PlantSpeciesID string
	Images         []models.DiagnosisImage
	Notes          string
}

// ListDiagnosesParams contains the inputs for listing diagnoses.
type ListDiagnosesParams struct {
	FarmID     string
	FieldID    string
	Status     string
	PageSize   int32
	PageOffset int32
	SortDesc   bool
}

// ─────────────────────────────────────────────────────────────────────────────
// Configuration
// ─────────────────────────────────────────────────────────────────────────────

// AIServiceConfig holds endpoints and settings for the AI pipeline.
type AIServiceConfig struct {
	RustPreprocessURL    string
	PythonInferenceURL   string
	RequestTimeout       time.Duration
	ModelVersion         string
}

// DefaultAIServiceConfig returns sensible defaults for the AI pipeline.
func DefaultAIServiceConfig() AIServiceConfig {
	return AIServiceConfig{
		RustPreprocessURL:  "http://rust-engines:8090/api/v1/preprocess",
		PythonInferenceURL: "http://python-ai:8091/api/v1/inference",
		RequestTimeout:     30 * time.Second,
		ModelVersion:       "plant-diag-v2.1",
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Implementation
// ─────────────────────────────────────────────────────────────────────────────

type diagnosisService struct {
	repo         repositories.DiagnosisRepository
	logger       *p9log.Helper
	httpClient   *http.Client
	aiConfig     AIServiceConfig
	preprocessCB *circuitbreaker.SimpleCircuitBreaker
	inferenceCB  *circuitbreaker.SimpleCircuitBreaker
	deps         deps.ServiceDeps
}

// NewDiagnosisService creates a new DiagnosisService.
func NewDiagnosisService(
	serviceDeps deps.ServiceDeps,
	repo repositories.DiagnosisRepository,
	aiConfig AIServiceConfig,
) DiagnosisService {
	return &diagnosisService{
		repo:   repo,
		logger: p9log.NewHelper(p9log.With(serviceDeps.Log, "component", "DiagnosisService")),
		httpClient: &http.Client{
			Timeout: aiConfig.RequestTimeout,
		},
		aiConfig: aiConfig,
		preprocessCB: circuitbreaker.NewSimpleCircuitBreaker(circuitbreaker.SimpleConfig{
			MaxFailures:      5,
			SuccessThreshold: 2,
			Timeout:          60 * time.Second,
		}),
		inferenceCB: circuitbreaker.NewSimpleCircuitBreaker(circuitbreaker.SimpleConfig{
			MaxFailures:      3,
			SuccessThreshold: 2,
			Timeout:          90 * time.Second,
		}),
		deps: serviceDeps,
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// SubmitDiagnosis orchestrates the full AI pipeline
// ─────────────────────────────────────────────────────────────────────────────

func (s *diagnosisService) SubmitDiagnosis(ctx context.Context, params SubmitDiagnosisParams) (*models.DiagnosisRequest, error) {
	userID := p9context.UserID(ctx)
	if userID == "" {
		return nil, errors.Unauthorized("UNAUTHORIZED", "user must be authenticated")
	}

	if params.FarmID == "" {
		return nil, errors.BadRequest("MISSING_FARM_ID", "farm_id is required")
	}
	if len(params.Images) == 0 {
		return nil, errors.BadRequest("MISSING_IMAGES", "at least one image is required")
	}

	// 1. Create the diagnosis request in PENDING state
	req := &models.DiagnosisRequest{
		FarmID:    params.FarmID,
		CreatedBy: userID,
	}
	if params.FieldID != "" {
		req.FieldID = &params.FieldID
	}
	if params.PlantSpeciesID != "" {
		req.PlantSpeciesID = &params.PlantSpeciesID
	}
	if params.Notes != "" {
		req.Notes = &params.Notes
	}

	created, err := s.repo.CreateDiagnosisRequest(ctx, req)
	if err != nil {
		return nil, err
	}

	// 2. Persist the uploaded images
	savedImages := make([]models.DiagnosisImage, 0, len(params.Images))
	for _, img := range params.Images {
		img.DiagnosisRequestID = created.ID
		saved, err := s.repo.CreateDiagnosisImage(ctx, &img)
		if err != nil {
			s.logger.Errorf("failed to save image for diagnosis %s: %v", created.UUID, err)
			_, _ = s.repo.UpdateDiagnosisRequestStatus(ctx, created.UUID, models.DiagnosisStatusFailed, userID)
			return nil, err
		}
		savedImages = append(savedImages, *saved)
	}
	created.Images = savedImages

	// 3. Publish DiagnosisSubmitted event
	s.publishDiagnosisSubmittedEvent(ctx, created)

	// 4. Transition to ANALYZING and kick off the AI pipeline asynchronously
	updated, err := s.repo.UpdateDiagnosisRequestStatus(ctx, created.UUID, models.DiagnosisStatusAnalyzing, userID)
	if err != nil {
		s.logger.Errorf("failed to transition diagnosis %s to ANALYZING: %v", created.UUID, err)
		return created, nil // Return created even if status update fails
	}
	updated.Images = savedImages

	// Run the AI pipeline in the background
	go s.runAIPipeline(context.Background(), updated, userID)

	return updated, nil
}

// ─────────────────────────────────────────────────────────────────────────────
// AI pipeline orchestration
// ─────────────────────────────────────────────────────────────────────────────

// runAIPipeline executes: image upload → Rust preprocessing → Python inference → persist result.
func (s *diagnosisService) runAIPipeline(ctx context.Context, req *models.DiagnosisRequest, userID string) {
	startTime := time.Now()

	// Collect image URLs and types
	imageURLs := make([]string, 0, len(req.Images))
	imageTypes := make([]string, 0, len(req.Images))
	for _, img := range req.Images {
		imageURLs = append(imageURLs, img.ImageURL)
		imageTypes = append(imageTypes, img.ImageType)
	}

	// Step 1: Rust preprocessing (resize, normalise, augment)
	preprocessResult, err := s.callRustPreprocessing(ctx, req.UUID, imageURLs)
	if err != nil {
		s.logger.Errorf("Rust preprocessing failed for diagnosis %s: %v", req.UUID, err)
		s.failDiagnosis(ctx, req.UUID, userID)
		return
	}

	// Use preprocessed URLs if available, otherwise fall back to originals
	processedURLs := imageURLs
	if preprocessResult != nil && len(preprocessResult.ProcessedURLs) > 0 {
		processedURLs = preprocessResult.ProcessedURLs
	}

	// Step 2: Python AI inference (disease detection, species ID, nutrient, pest)
	speciesID := ""
	if req.PlantSpeciesID != nil {
		speciesID = *req.PlantSpeciesID
	}
	inferenceResp, err := s.callPythonInference(ctx, req.UUID, processedURLs, imageTypes, speciesID)
	if err != nil {
		s.logger.Errorf("Python inference failed for diagnosis %s: %v", req.UUID, err)
		s.failDiagnosis(ctx, req.UUID, userID)
		return
	}

	// Step 3: Persist the result
	result, err := mappers.AIResponseToResult(inferenceResp, req.ID)
	if err != nil {
		s.logger.Errorf("failed to map AI response for diagnosis %s: %v", req.UUID, err)
		s.failDiagnosis(ctx, req.UUID, userID)
		return
	}

	savedResult, err := s.repo.CreateDiagnosisResult(ctx, result)
	if err != nil {
		s.logger.Errorf("failed to persist result for diagnosis %s: %v", req.UUID, err)
		s.failDiagnosis(ctx, req.UUID, userID)
		return
	}

	// Step 4: Generate treatment plan from results
	s.generateTreatmentPlan(ctx, req, savedResult, userID)

	// Step 5: Transition to COMPLETED
	_, err = s.repo.UpdateDiagnosisRequestStatus(ctx, req.UUID, models.DiagnosisStatusCompleted, userID)
	if err != nil {
		s.logger.Errorf("failed to complete diagnosis %s: %v", req.UUID, err)
		return
	}

	processingTime := time.Since(startTime)
	s.logger.Infof("diagnosis %s completed in %dms", req.UUID, processingTime.Milliseconds())

	// Step 6: Publish completion and detection events
	s.publishDiagnosisCompletedEvent(ctx, req, savedResult)
	s.publishDetectionEvents(ctx, req, savedResult)
}

// callRustPreprocessing sends images to the Rust preprocessing engine.
func (s *diagnosisService) callRustPreprocessing(ctx context.Context, requestID string, imageURLs []string) (*models.ImagePreprocessResult, error) {
	var result *models.ImagePreprocessResult

	err := s.preprocessCB.Execute(ctx, func(cbCtx context.Context) error {
		payload := map[string]interface{}{
			"request_id": requestID,
			"image_urls": imageURLs,
			"operations": []string{"resize", "normalize", "enhance"},
			"target_size": map[string]int{
				"width":  640,
				"height": 640,
			},
		}

		body, err := json.Marshal(payload)
		if err != nil {
			return fmt.Errorf("failed to marshal preprocess request: %w", err)
		}

		httpReq, err := http.NewRequestWithContext(cbCtx, http.MethodPost, s.aiConfig.RustPreprocessURL, bytes.NewReader(body))
		if err != nil {
			return fmt.Errorf("failed to create preprocess request: %w", err)
		}
		httpReq.Header.Set("Content-Type", "application/json")

		resp, err := s.httpClient.Do(httpReq)
		if err != nil {
			return fmt.Errorf("preprocess request failed: %w", err)
		}
		defer resp.Body.Close()

		if resp.StatusCode != http.StatusOK {
			respBody, _ := io.ReadAll(resp.Body)
			return fmt.Errorf("preprocess returned status %d: %s", resp.StatusCode, string(respBody))
		}

		var preprocessResult models.ImagePreprocessResult
		if err := json.NewDecoder(resp.Body).Decode(&preprocessResult); err != nil {
			return fmt.Errorf("failed to decode preprocess response: %w", err)
		}

		result = &preprocessResult
		return nil
	})

	if err != nil {
		return nil, err
	}
	return result, nil
}

// callPythonInference sends preprocessed images to the Python AI inference service.
func (s *diagnosisService) callPythonInference(
	ctx context.Context,
	requestID string,
	imageURLs []string,
	imageTypes []string,
	plantSpeciesID string,
) (*models.AIInferenceResponse, error) {
	var result *models.AIInferenceResponse

	err := s.inferenceCB.Execute(ctx, func(cbCtx context.Context) error {
		inferenceReq := models.AIInferenceRequest{
			RequestID:      requestID,
			ImageURLs:      imageURLs,
			ImageTypes:     imageTypes,
			PlantSpeciesID: plantSpeciesID,
			ModelVersion:   s.aiConfig.ModelVersion,
		}

		body, err := json.Marshal(inferenceReq)
		if err != nil {
			return fmt.Errorf("failed to marshal inference request: %w", err)
		}

		httpReq, err := http.NewRequestWithContext(cbCtx, http.MethodPost, s.aiConfig.PythonInferenceURL, bytes.NewReader(body))
		if err != nil {
			return fmt.Errorf("failed to create inference request: %w", err)
		}
		httpReq.Header.Set("Content-Type", "application/json")

		resp, err := s.httpClient.Do(httpReq)
		if err != nil {
			return fmt.Errorf("inference request failed: %w", err)
		}
		defer resp.Body.Close()

		if resp.StatusCode != http.StatusOK {
			respBody, _ := io.ReadAll(resp.Body)
			return fmt.Errorf("inference returned status %d: %s", resp.StatusCode, string(respBody))
		}

		var inferenceResp models.AIInferenceResponse
		if err := json.NewDecoder(resp.Body).Decode(&inferenceResp); err != nil {
			return fmt.Errorf("failed to decode inference response: %w", err)
		}

		result = &inferenceResp
		return nil
	})

	if err != nil {
		return nil, err
	}
	return result, nil
}

// generateTreatmentPlan creates a treatment plan from diagnosis results.
func (s *diagnosisService) generateTreatmentPlan(ctx context.Context, req *models.DiagnosisRequest, result *models.DiagnosisResult, userID string) {
	// Parse detected diseases to build treatment steps
	var diseases []models.DetectedDisease
	if len(result.DetectedDiseases) > 0 {
		_ = json.Unmarshal(result.DetectedDiseases, &diseases)
	}
	var nutrients []models.DetectedNutrientDeficiency
	if len(result.NutrientDeficiencies) > 0 {
		_ = json.Unmarshal(result.NutrientDeficiencies, &nutrients)
	}
	var pests []models.DetectedPestDamage
	if len(result.PestDamage) > 0 {
		_ = json.Unmarshal(result.PestDamage, &pests)
	}

	steps := make([]models.TreatmentStep, 0)
	stepNum := int32(1)

	// Build disease treatment steps
	for _, d := range diseases {
		for _, treatment := range d.TreatmentOptions {
			steps = append(steps, models.TreatmentStep{
				StepNumber: stepNum,
				Action:     fmt.Sprintf("Treat %s (%s severity)", d.DiseaseName, d.Severity),
				Product:    treatment,
				Notes:      d.Description,
			})
			stepNum++
		}
	}

	// Build nutrient deficiency treatment steps
	for _, n := range nutrients {
		for _, fert := range n.RecommendedFertilizers {
			steps = append(steps, models.TreatmentStep{
				StepNumber: stepNum,
				Action:     fmt.Sprintf("Address %s deficiency", n.Nutrient),
				Product:    fert,
				Dosage:     n.ApplicationMethod,
				Notes:      n.Description,
			})
			stepNum++
		}
	}

	// Build pest control steps
	for _, p := range pests {
		for _, method := range p.ControlMethods {
			steps = append(steps, models.TreatmentStep{
				StepNumber: stepNum,
				Action:     fmt.Sprintf("Control %s pest damage", p.PestName),
				Product:    method,
				Notes:      p.Description,
			})
			stepNum++
		}
	}

	if len(steps) == 0 {
		s.logger.Infof("no treatment steps needed for diagnosis %s", req.UUID)
		return
	}

	stepsJSON, err := json.Marshal(steps)
	if err != nil {
		s.logger.Errorf("failed to marshal treatment steps for diagnosis %s: %v", req.UUID, err)
		return
	}

	// Determine priority from the highest severity found
	priority := determinePriority(diseases, nutrients, pests)

	plan := &models.TreatmentPlan{
		DiagnosisRequestID: req.ID,
		Title:              fmt.Sprintf("Treatment Plan for Diagnosis %s", req.UUID),
		Priority:           string(priority),
		Steps:              stepsJSON,
		CreatedBy:          userID,
	}

	summary := fmt.Sprintf(
		"Plan addresses %d disease(s), %d nutrient deficiency(ies), and %d pest(s) with %d treatment steps.",
		len(diseases), len(nutrients), len(pests), len(steps),
	)
	plan.Description = &summary
	estimatedDays := int32(len(steps) * 3)
	plan.EstimatedDays = &estimatedDays

	_, err = s.repo.CreateTreatmentPlan(ctx, plan)
	if err != nil {
		s.logger.Errorf("failed to create treatment plan for diagnosis %s: %v", req.UUID, err)
	}
}

// failDiagnosis transitions a diagnosis to FAILED status.
func (s *diagnosisService) failDiagnosis(ctx context.Context, uuid, userID string) {
	_, err := s.repo.UpdateDiagnosisRequestStatus(ctx, uuid, models.DiagnosisStatusFailed, userID)
	if err != nil {
		s.logger.Errorf("failed to mark diagnosis %s as FAILED: %v", uuid, err)
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Query operations
// ─────────────────────────────────────────────────────────────────────────────

func (s *diagnosisService) GetDiagnosis(ctx context.Context, id string) (*models.DiagnosisRequest, error) {
	if id == "" {
		return nil, errors.BadRequest("MISSING_ID", "diagnosis ID is required")
	}

	req, err := s.repo.GetDiagnosisRequestByUUID(ctx, id)
	if err != nil {
		return nil, err
	}

	// Eagerly load images
	images, err := s.repo.ListDiagnosisImages(ctx, req.ID)
	if err != nil {
		s.logger.Errorf("failed to load images for diagnosis %s: %v", id, err)
	} else {
		req.Images = images
	}

	// Eagerly load result if completed
	if req.Status == models.DiagnosisStatusCompleted {
		result, err := s.repo.GetDiagnosisResultByRequestID(ctx, req.ID)
		if err != nil && !errors.IsNotFound(err) {
			s.logger.Errorf("failed to load result for diagnosis %s: %v", id, err)
		} else {
			req.Result = result
		}
	}

	return req, nil
}

func (s *diagnosisService) ListDiagnoses(ctx context.Context, params ListDiagnosesParams) ([]*models.DiagnosisRequest, int64, error) {
	repoParams := repositories.ListDiagnosisParams{
		FarmID:     params.FarmID,
		FieldID:    params.FieldID,
		Status:     params.Status,
		PageSize:   params.PageSize,
		PageOffset: params.PageOffset,
		SortDesc:   params.SortDesc,
	}

	return s.repo.ListDiagnosisRequests(ctx, repoParams)
}

func (s *diagnosisService) GetDiseaseInfo(ctx context.Context, diseaseID string) (*models.DiseaseCatalog, error) {
	if diseaseID == "" {
		return nil, errors.BadRequest("MISSING_DISEASE_ID", "disease ID is required")
	}
	return s.repo.GetDiseaseByUUID(ctx, diseaseID)
}

func (s *diagnosisService) ListDiseases(ctx context.Context, searchTerm string, pageSize, pageOffset int32) ([]*models.DiseaseCatalog, int64, error) {
	return s.repo.ListDiseases(ctx, searchTerm, pageSize, pageOffset)
}

func (s *diagnosisService) GetTreatmentPlan(ctx context.Context, diagnosisID string) (*models.TreatmentPlan, error) {
	if diagnosisID == "" {
		return nil, errors.BadRequest("MISSING_DIAGNOSIS_ID", "diagnosis ID is required")
	}

	// First get the diagnosis to obtain the DB ID
	req, err := s.repo.GetDiagnosisRequestByUUID(ctx, diagnosisID)
	if err != nil {
		return nil, err
	}

	return s.repo.GetTreatmentPlanByDiagnosisRequestID(ctx, req.ID)
}

// ─────────────────────────────────────────────────────────────────────────────
// Standalone AI capabilities (direct inference without persistence)
// ─────────────────────────────────────────────────────────────────────────────

func (s *diagnosisService) IdentifySpecies(ctx context.Context, images []models.DiagnosisImage) (*models.AIInferenceResponse, error) {
	if len(images) == 0 {
		return nil, errors.BadRequest("MISSING_IMAGES", "at least one image is required")
	}

	imageURLs := make([]string, 0, len(images))
	imageTypes := make([]string, 0, len(images))
	for _, img := range images {
		imageURLs = append(imageURLs, img.ImageURL)
		imageTypes = append(imageTypes, img.ImageType)
	}

	requestID := ulid.NewString()
	return s.callPythonInference(ctx, requestID, imageURLs, imageTypes, "")
}

func (s *diagnosisService) DetectNutrientDeficiency(ctx context.Context, plantSpeciesID string, images []models.DiagnosisImage) (*models.AIInferenceResponse, error) {
	if len(images) == 0 {
		return nil, errors.BadRequest("MISSING_IMAGES", "at least one image is required")
	}

	imageURLs := make([]string, 0, len(images))
	imageTypes := make([]string, 0, len(images))
	for _, img := range images {
		imageURLs = append(imageURLs, img.ImageURL)
		imageTypes = append(imageTypes, img.ImageType)
	}

	requestID := ulid.NewString()
	return s.callPythonInference(ctx, requestID, imageURLs, imageTypes, plantSpeciesID)
}

func (s *diagnosisService) DetectPestDamage(ctx context.Context, plantSpeciesID string, images []models.DiagnosisImage) (*models.AIInferenceResponse, error) {
	if len(images) == 0 {
		return nil, errors.BadRequest("MISSING_IMAGES", "at least one image is required")
	}

	imageURLs := make([]string, 0, len(images))
	imageTypes := make([]string, 0, len(images))
	for _, img := range images {
		imageURLs = append(imageURLs, img.ImageURL)
		imageTypes = append(imageTypes, img.ImageType)
	}

	requestID := ulid.NewString()
	return s.callPythonInference(ctx, requestID, imageURLs, imageTypes, plantSpeciesID)
}

// ─────────────────────────────────────────────────────────────────────────────
// Domain event publishing
// ─────────────────────────────────────────────────────────────────────────────

func (s *diagnosisService) publishDiagnosisSubmittedEvent(ctx context.Context, req *models.DiagnosisRequest) {
	event := domain.NewDomainEvent(
		EventTypeDiagnosisSubmitted,
		req.UUID,
		"diagnosis_request",
		map[string]interface{}{
			"tenant_id":  req.TenantID,
			"farm_id":    req.FarmID,
			"field_id":   req.FieldID,
			"image_count": len(req.Images),
			"created_by": req.CreatedBy,
		},
	).WithSource("plant-diagnosis-service").WithPriority(domain.PriorityMedium)

	if s.deps.KafkaProducer != nil {
		s.logger.Infof("publishing DiagnosisSubmitted event for %s", req.UUID)
		// Fire and forget for non-critical event
		go func() {
			if err := publishEventToKafka(ctx, s.deps, event); err != nil {
				s.logger.Errorf("failed to publish DiagnosisSubmitted event: %v", err)
			}
		}()
	}
}

func (s *diagnosisService) publishDiagnosisCompletedEvent(ctx context.Context, req *models.DiagnosisRequest, result *models.DiagnosisResult) {
	event := domain.NewDomainEvent(
		EventTypeDiagnosisCompleted,
		req.UUID,
		"diagnosis_request",
		map[string]interface{}{
			"tenant_id":          req.TenantID,
			"farm_id":            req.FarmID,
			"ai_model_version":   result.AIModelVersion,
			"processing_time_ms": result.ProcessingTimeMs,
			"health_score":       result.OverallHealthScore,
		},
	).WithSource("plant-diagnosis-service").WithPriority(domain.PriorityMedium)

	if s.deps.KafkaProducer != nil {
		go func() {
			if err := publishEventToKafka(ctx, s.deps, event); err != nil {
				s.logger.Errorf("failed to publish DiagnosisCompleted event: %v", err)
			}
		}()
	}
}

func (s *diagnosisService) publishDetectionEvents(ctx context.Context, req *models.DiagnosisRequest, result *models.DiagnosisResult) {
	// Disease detection events
	var diseases []models.DetectedDisease
	if len(result.DetectedDiseases) > 0 {
		_ = json.Unmarshal(result.DetectedDiseases, &diseases)
	}
	for _, d := range diseases {
		event := domain.NewDomainEvent(
			EventTypeDiseaseDetected,
			req.UUID,
			"diagnosis_request",
			map[string]interface{}{
				"tenant_id":    req.TenantID,
				"farm_id":      req.FarmID,
				"disease_name": d.DiseaseName,
				"confidence":   d.ConfidenceScore,
				"severity":     string(d.Severity),
			},
		).WithSource("plant-diagnosis-service").WithPriority(severityToPriority(d.Severity))

		if s.deps.KafkaProducer != nil {
			go func(evt *domain.DomainEvent) {
				if err := publishEventToKafka(ctx, s.deps, evt); err != nil {
					s.logger.Errorf("failed to publish DiseaseDetected event: %v", err)
				}
			}(event)
		}
	}

	// Nutrient deficiency events
	var nutrients []models.DetectedNutrientDeficiency
	if len(result.NutrientDeficiencies) > 0 {
		_ = json.Unmarshal(result.NutrientDeficiencies, &nutrients)
	}
	for _, n := range nutrients {
		event := domain.NewDomainEvent(
			EventTypeNutrientDeficiencyDetected,
			req.UUID,
			"diagnosis_request",
			map[string]interface{}{
				"tenant_id": req.TenantID,
				"farm_id":   req.FarmID,
				"nutrient":  n.Nutrient,
				"confidence": n.ConfidenceScore,
				"severity":  string(n.Severity),
			},
		).WithSource("plant-diagnosis-service").WithPriority(severityToPriority(n.Severity))

		if s.deps.KafkaProducer != nil {
			go func(evt *domain.DomainEvent) {
				if err := publishEventToKafka(ctx, s.deps, evt); err != nil {
					s.logger.Errorf("failed to publish NutrientDeficiencyDetected event: %v", err)
				}
			}(event)
		}
	}

	// Pest damage events
	var pests []models.DetectedPestDamage
	if len(result.PestDamage) > 0 {
		_ = json.Unmarshal(result.PestDamage, &pests)
	}
	for _, p := range pests {
		event := domain.NewDomainEvent(
			EventTypePestDamageDetected,
			req.UUID,
			"diagnosis_request",
			map[string]interface{}{
				"tenant_id":    req.TenantID,
				"farm_id":      req.FarmID,
				"pest_name":    p.PestName,
				"confidence":   p.ConfidenceScore,
				"damage_level": string(p.DamageLevel),
			},
		).WithSource("plant-diagnosis-service").WithPriority(severityToPriority(p.DamageLevel))

		if s.deps.KafkaProducer != nil {
			go func(evt *domain.DomainEvent) {
				if err := publishEventToKafka(ctx, s.deps, evt); err != nil {
					s.logger.Errorf("failed to publish PestDamageDetected event: %v", err)
				}
			}(event)
		}
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Event type constants (agriculture domain)
// ─────────────────────────────────────────────────────────────────────────────

const (
	EventTypeDiagnosisSubmitted          domain.EventType = "agriculture.diagnosis.submitted"
	EventTypeDiagnosisCompleted          domain.EventType = "agriculture.diagnosis.completed"
	EventTypeDiseaseDetected             domain.EventType = "agriculture.disease.detected"
	EventTypeNutrientDeficiencyDetected  domain.EventType = "agriculture.nutrient_deficiency.detected"
	EventTypePestDamageDetected          domain.EventType = "agriculture.pest_damage.detected"
)

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

// publishEventToKafka is a utility to publish domain events through the KafkaProducer.
func publishEventToKafka(ctx context.Context, d deps.ServiceDeps, event *domain.DomainEvent) error {
	if d.KafkaProducer == nil {
		return nil
	}

	eventData, err := json.Marshal(event)
	if err != nil {
		return fmt.Errorf("failed to marshal event: %w", err)
	}

	// Use the generic agriculture events topic
	_ = eventData // In production this would be sent to Kafka
	return nil
}

// determinePriority finds the highest severity across all detections.
func determinePriority(
	diseases []models.DetectedDisease,
	nutrients []models.DetectedNutrientDeficiency,
	pests []models.DetectedPestDamage,
) models.SeverityLevel {
	highest := models.SeverityMild

	for _, d := range diseases {
		if severityRank(d.Severity) > severityRank(highest) {
			highest = d.Severity
		}
	}
	for _, n := range nutrients {
		if severityRank(n.Severity) > severityRank(highest) {
			highest = n.Severity
		}
	}
	for _, p := range pests {
		if severityRank(p.DamageLevel) > severityRank(highest) {
			highest = p.DamageLevel
		}
	}

	return highest
}

func severityRank(s models.SeverityLevel) int {
	switch s {
	case models.SeverityMild:
		return 1
	case models.SeverityModerate:
		return 2
	case models.SeveritySevere:
		return 3
	case models.SeverityCritical:
		return 4
	default:
		return 0
	}
}

func severityToPriority(s models.SeverityLevel) domain.Priority {
	switch s {
	case models.SeverityCritical:
		return domain.PriorityCritical
	case models.SeveritySevere:
		return domain.PriorityHigh
	case models.SeverityModerate:
		return domain.PriorityMedium
	default:
		return domain.PriorityLow
	}
}
