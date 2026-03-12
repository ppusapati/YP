package services

import (
	"context"
	"math"
	"sort"
	"time"

	"p9e.in/samavaya/agriculture/satellite-service/internal/models"
	"p9e.in/samavaya/agriculture/satellite-service/internal/repositories"
	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"
)

// ---------------------------------------------------------------------------
// Interface
// ---------------------------------------------------------------------------

// SatelliteService defines application-level satellite operations.
type SatelliteService interface {
	// Image acquisition
	RequestImagery(ctx context.Context, req *ImageryRequest) (*models.SatelliteTask, error)
	GetImage(ctx context.Context, id, tenantID string) (*models.SatelliteImage, error)
	ListImages(ctx context.Context, tenantID, fieldID, farmID string, pageSize, pageOffset int32) ([]*models.SatelliteImage, int64, error)

	// Vegetation index computation
	ComputeNDVI(ctx context.Context, tenantID, imageID, fieldID string) (*models.VegetationIndex, error)
	ComputeNDWI(ctx context.Context, tenantID, imageID, fieldID string) (*models.VegetationIndex, error)
	ComputeEVI(ctx context.Context, tenantID, imageID, fieldID string) (*models.VegetationIndex, error)
	GetVegetationIndices(ctx context.Context, tenantID, imageID, fieldID, indexType string) ([]*models.VegetationIndex, error)

	// Stress detection
	DetectCropStress(ctx context.Context, tenantID, imageID, fieldID string) (*models.CropStressAlert, error)
	ListAlerts(ctx context.Context, tenantID, fieldID string, pageSize, pageOffset int32) ([]*models.CropStressAlert, int64, error)

	// Temporal analysis
	GetTemporalAnalysis(ctx context.Context, tenantID, fieldID, indexType string, startDate, endDate time.Time) (*models.TemporalAnalysis, error)
}

// ImageryRequest contains parameters for requesting new satellite imagery.
type ImageryRequest struct {
	TenantID          string
	FieldID           string
	FarmID            string
	SatelliteProvider models.SatelliteProvider
	Bbox              *models.BoundingBox
	MaxCloudCoverPct  float64
	ResolutionMeters  float64
	Bands             []string
}

// ---------------------------------------------------------------------------
// Implementation
// ---------------------------------------------------------------------------

type satelliteService struct {
	repo   repositories.SatelliteRepository
	deps   deps.ServiceDeps
	logger p9log.Helper
}

// NewSatelliteService creates a service with full dependency injection.
func NewSatelliteService(repo repositories.SatelliteRepository, d deps.ServiceDeps) SatelliteService {
	return &satelliteService{
		repo:   repo,
		deps:   d,
		logger: *p9log.NewHelper(p9log.With(d.Log, "component", "SatelliteService")),
	}
}

// ---------------------------------------------------------------------------
// Image acquisition
// ---------------------------------------------------------------------------

func (s *satelliteService) RequestImagery(ctx context.Context, req *ImageryRequest) (*models.SatelliteTask, error) {
	if req.TenantID == "" {
		return nil, errors.BadRequest("INVALID_TENANT", "tenant_id is required")
	}
	if req.FieldID == "" {
		return nil, errors.BadRequest("INVALID_FIELD", "field_id is required")
	}
	if req.FarmID == "" {
		return nil, errors.BadRequest("INVALID_FARM", "farm_id is required")
	}
	if !req.SatelliteProvider.IsValid() {
		return nil, errors.BadRequest("INVALID_PROVIDER", "satellite provider is invalid")
	}
	if req.Bbox != nil && !req.Bbox.IsValid() {
		return nil, errors.BadRequest("INVALID_BBOX", "bounding box coordinates are invalid")
	}

	userID := p9context.UserID(ctx)

	// Create the image record in PENDING state
	img := &models.SatelliteImage{
		TenantID:          req.TenantID,
		FieldID:           req.FieldID,
		FarmID:            req.FarmID,
		SatelliteProvider: req.SatelliteProvider,
		AcquisitionDate:   time.Now(),
		CloudCoverPct:     req.MaxCloudCoverPct,
		ResolutionMeters:  req.ResolutionMeters,
		Bands:             req.Bands,
		Bbox:              req.Bbox,
		ProcessingStatus:  models.ProcessingStatusPending,
	}
	img.CreatedBy = userID

	createdImg, err := s.repo.CreateImage(ctx, img)
	if err != nil {
		s.logger.Errorf("RequestImagery: failed to create image: %v", err)
		return nil, err
	}

	// Create the acquisition task
	task := &models.SatelliteTask{
		TenantID:     req.TenantID,
		FieldID:      req.FieldID,
		TaskType:     "acquisition",
		Status:       models.ProcessingStatusPending,
		InputImageID: createdImg.UUID,
	}
	task.CreatedBy = userID

	createdTask, err := s.repo.CreateTask(ctx, task)
	if err != nil {
		s.logger.Errorf("RequestImagery: failed to create task: %v", err)
		return nil, err
	}

	s.logger.Infof("Imagery requested: image=%s task=%s tenant=%s", createdImg.UUID, createdTask.UUID, req.TenantID)
	return createdTask, nil
}

func (s *satelliteService) GetImage(ctx context.Context, id, tenantID string) (*models.SatelliteImage, error) {
	if id == "" {
		return nil, errors.BadRequest("INVALID_ID", "image id is required")
	}
	if tenantID == "" {
		return nil, errors.BadRequest("INVALID_TENANT", "tenant_id is required")
	}
	return s.repo.GetImageByUUID(ctx, id, tenantID)
}

func (s *satelliteService) ListImages(ctx context.Context, tenantID, fieldID, farmID string, pageSize, pageOffset int32) ([]*models.SatelliteImage, int64, error) {
	if tenantID == "" {
		return nil, 0, errors.BadRequest("INVALID_TENANT", "tenant_id is required")
	}
	if pageSize <= 0 {
		pageSize = 20
	}
	if pageSize > 100 {
		pageSize = 100
	}
	if pageOffset < 0 {
		pageOffset = 0
	}

	var images []*models.SatelliteImage
	var total int64
	var err error

	if fieldID != "" {
		images, err = s.repo.ListImagesByField(ctx, tenantID, fieldID, pageSize, pageOffset)
		if err != nil {
			return nil, 0, err
		}
		total, err = s.repo.CountImagesByField(ctx, tenantID, fieldID)
	} else if farmID != "" {
		images, err = s.repo.ListImagesByFarm(ctx, tenantID, farmID, pageSize, pageOffset)
		if err != nil {
			return nil, 0, err
		}
		total, err = s.repo.CountImagesByFarm(ctx, tenantID, farmID)
	} else {
		images, err = s.repo.ListImagesByTenant(ctx, tenantID, pageSize, pageOffset)
		if err != nil {
			return nil, 0, err
		}
		total, err = s.repo.CountImagesByTenant(ctx, tenantID)
	}
	if err != nil {
		return nil, 0, err
	}
	return images, total, nil
}

// ---------------------------------------------------------------------------
// Vegetation index computation
// ---------------------------------------------------------------------------

func (s *satelliteService) ComputeNDVI(ctx context.Context, tenantID, imageID, fieldID string) (*models.VegetationIndex, error) {
	return s.computeIndex(ctx, tenantID, imageID, fieldID, models.IndexTypeNDVI)
}

func (s *satelliteService) ComputeNDWI(ctx context.Context, tenantID, imageID, fieldID string) (*models.VegetationIndex, error) {
	return s.computeIndex(ctx, tenantID, imageID, fieldID, models.IndexTypeNDWI)
}

func (s *satelliteService) ComputeEVI(ctx context.Context, tenantID, imageID, fieldID string) (*models.VegetationIndex, error) {
	return s.computeIndex(ctx, tenantID, imageID, fieldID, models.IndexTypeEVI)
}

func (s *satelliteService) computeIndex(ctx context.Context, tenantID, imageID, fieldID string, indexType models.IndexType) (*models.VegetationIndex, error) {
	if tenantID == "" {
		return nil, errors.BadRequest("INVALID_TENANT", "tenant_id is required")
	}
	if imageID == "" {
		return nil, errors.BadRequest("INVALID_IMAGE", "image_id is required")
	}
	if fieldID == "" {
		return nil, errors.BadRequest("INVALID_FIELD", "field_id is required")
	}

	// Verify the image exists and belongs to this tenant
	img, err := s.repo.GetImageByUUID(ctx, imageID, tenantID)
	if err != nil {
		return nil, err
	}

	// Check for existing computation (idempotency)
	existing, err := s.repo.GetVegetationIndexByImageAndType(ctx, imageID, indexType, tenantID)
	if err == nil && existing != nil {
		s.logger.Infof("Index %s already computed for image %s, returning cached result", indexType, imageID)
		return existing, nil
	}

	// Simulate pixel-level band-value extraction from the satellite image.
	// In production this reads the raster file; here we synthesize representative
	// values based on the image metadata to demonstrate the algorithm.
	pixels := s.synthesizeBandValues(img)

	var values []float64
	for _, px := range pixels {
		switch indexType {
		case models.IndexTypeNDVI:
			values = append(values, px.ComputeNDVI())
		case models.IndexTypeNDWI:
			values = append(values, px.ComputeNDWI())
		case models.IndexTypeEVI:
			values = append(values, px.ComputeEVI())
		}
	}

	stats := computeStats(values)
	userID := p9context.UserID(ctx)

	vi := &models.VegetationIndex{
		TenantID:  tenantID,
		ImageID:   imageID,
		FieldID:   fieldID,
		IndexType: indexType,
		MinValue:  stats.Min,
		MaxValue:  stats.Max,
		MeanValue: stats.Mean,
		StdDev:    stats.StdDev,
		RasterURL: generateRasterURL(tenantID, imageID, string(indexType)),
	}
	vi.CreatedBy = userID

	created, err := s.repo.CreateVegetationIndex(ctx, vi)
	if err != nil {
		s.logger.Errorf("computeIndex: failed to persist %s: %v", indexType, err)
		return nil, err
	}

	// Update image status to COMPLETED if it was still PROCESSING
	if img.ProcessingStatus == models.ProcessingStatusPending || img.ProcessingStatus == models.ProcessingStatusProcessing {
		_, _ = s.repo.UpdateImageStatus(ctx, imageID, tenantID, models.ProcessingStatusCompleted, userID)
	}

	s.logger.Infof("Computed %s for image %s: mean=%.4f min=%.4f max=%.4f", indexType, imageID, stats.Mean, stats.Min, stats.Max)
	return created, nil
}

// synthesizeBandValues creates representative spectral samples based on the
// image's cloud cover and resolution. In a production system this would
// read the actual GeoTIFF raster bands; here we generate deterministic,
// physically plausible reflectance values for demonstration and testing.
func (s *satelliteService) synthesizeBandValues(img *models.SatelliteImage) []models.BandValues {
	// Generate a grid of sample pixels proportional to resolution.
	// Higher resolution -> more sample points (capped for performance).
	numPixels := 100
	if img.ResolutionMeters > 0 && img.ResolutionMeters <= 3 {
		numPixels = 500
	} else if img.ResolutionMeters <= 10 {
		numPixels = 200
	}

	pixels := make([]models.BandValues, numPixels)
	cloudFactor := 1.0 - (img.CloudCoverPct / 100.0) // clear-sky fraction

	for i := 0; i < numPixels; i++ {
		// Deterministic pseudo-random based on pixel index.
		// Produces spatially varying but reproducible reflectance.
		t := float64(i) / float64(numPixels)
		noise := math.Sin(float64(i)*0.1) * 0.05

		// Typical healthy vegetation reflectance patterns:
		//   Red ≈ 0.03-0.10, NIR ≈ 0.30-0.55, Green ≈ 0.05-0.15
		//   SWIR ≈ 0.15-0.30, Blue ≈ 0.02-0.06, RedEdge ≈ 0.10-0.30
		pixels[i] = models.BandValues{
			Red:     clampReflectance((0.03 + 0.07*t + noise) * cloudFactor),
			Green:   clampReflectance((0.05 + 0.10*t + noise*0.8) * cloudFactor),
			Blue:    clampReflectance((0.02 + 0.04*t + noise*0.5) * cloudFactor),
			NIR:     clampReflectance((0.30 + 0.25*math.Sin(math.Pi*t) + noise) * cloudFactor),
			SWIR:    clampReflectance((0.15 + 0.15*t + noise*0.7) * cloudFactor),
			RedEdge: clampReflectance((0.10 + 0.20*math.Sin(math.Pi*t*0.8) + noise) * cloudFactor),
		}
	}
	return pixels
}

func (s *satelliteService) GetVegetationIndices(ctx context.Context, tenantID, imageID, fieldID, indexType string) ([]*models.VegetationIndex, error) {
	if tenantID == "" {
		return nil, errors.BadRequest("INVALID_TENANT", "tenant_id is required")
	}

	// Priority: image > field+type > field
	if imageID != "" {
		return s.repo.ListVegetationIndicesByImage(ctx, tenantID, imageID)
	}
	if fieldID != "" && indexType != "" {
		it := models.IndexType(indexType)
		if !it.IsValid() {
			return nil, errors.BadRequest("INVALID_INDEX_TYPE", "index_type must be NDVI, NDWI, or EVI")
		}
		return s.repo.ListVegetationIndicesByFieldAndType(ctx, tenantID, fieldID, it)
	}
	if fieldID != "" {
		return s.repo.ListVegetationIndicesByField(ctx, tenantID, fieldID)
	}
	return nil, errors.BadRequest("MISSING_FILTER", "at least image_id or field_id must be provided")
}

// ---------------------------------------------------------------------------
// Stress detection
// ---------------------------------------------------------------------------

func (s *satelliteService) DetectCropStress(ctx context.Context, tenantID, imageID, fieldID string) (*models.CropStressAlert, error) {
	if tenantID == "" {
		return nil, errors.BadRequest("INVALID_TENANT", "tenant_id is required")
	}
	if imageID == "" {
		return nil, errors.BadRequest("INVALID_IMAGE", "image_id is required")
	}
	if fieldID == "" {
		return nil, errors.BadRequest("INVALID_FIELD", "field_id is required")
	}

	// Fetch the image to verify existence
	img, err := s.repo.GetImageByUUID(ctx, imageID, tenantID)
	if err != nil {
		return nil, err
	}

	// Retrieve or compute required indices for stress analysis.
	ndvi, err := s.ensureIndex(ctx, tenantID, imageID, fieldID, models.IndexTypeNDVI)
	if err != nil {
		return nil, errors.Internal("stress detection requires NDVI: %v", err)
	}
	ndwi, err := s.ensureIndex(ctx, tenantID, imageID, fieldID, models.IndexTypeNDWI)
	if err != nil {
		return nil, errors.Internal("stress detection requires NDWI: %v", err)
	}

	// Run stress classification algorithm
	result := s.classifyStress(ndvi, ndwi, img)

	userID := p9context.UserID(ctx)
	alert := &models.CropStressAlert{
		TenantID:        tenantID,
		FieldID:         fieldID,
		ImageID:         imageID,
		StressDetected:  result.Detected,
		StressType:      result.Type,
		StressSeverity:  result.Severity,
		AffectedAreaPct: result.AffectedPct,
		Description:     result.Description,
		Recommendation:  result.Recommendation,
		AffectedBbox:    img.Bbox,
	}
	alert.CreatedBy = userID

	created, err := s.repo.CreateCropStressAlert(ctx, alert)
	if err != nil {
		s.logger.Errorf("DetectCropStress: failed to persist alert: %v", err)
		return nil, err
	}

	s.logger.Infof("Crop stress detection for image %s: detected=%v type=%s severity=%.2f",
		imageID, result.Detected, result.Type, result.Severity)
	return created, nil
}

// ensureIndex retrieves or computes a vegetation index if it does not yet exist.
func (s *satelliteService) ensureIndex(ctx context.Context, tenantID, imageID, fieldID string, indexType models.IndexType) (*models.VegetationIndex, error) {
	vi, err := s.repo.GetVegetationIndexByImageAndType(ctx, imageID, indexType, tenantID)
	if err == nil && vi != nil {
		return vi, nil
	}
	// Compute on demand
	return s.computeIndex(ctx, tenantID, imageID, fieldID, indexType)
}

// stressResult holds the output of the stress classification algorithm.
type stressResult struct {
	Detected       bool
	Type           models.StressType
	Severity       float64
	AffectedPct    float64
	Description    string
	Recommendation string
}

// classifyStress implements a rule-based crop stress detection algorithm
// that combines NDVI and NDWI statistics to identify the dominant stressor.
//
// Decision rules (simplified from peer-reviewed remote-sensing literature):
//
//  1. Water stress:  NDWI mean < -0.10 AND NDVI mean < 0.40
//  2. Nutrient stress: NDVI mean in [0.25, 0.45) AND NDWI mean >= -0.10
//  3. Disease stress:  NDVI std_dev > 0.15 (high spatial heterogeneity)
//  4. Pest stress:     NDVI min < 0.10 AND mean > 0.35 (localized damage)
//
// Severity is mapped to [0, 1] where 1 is extreme stress.
func (s *satelliteService) classifyStress(ndvi, ndwi *models.VegetationIndex, img *models.SatelliteImage) stressResult {
	result := stressResult{
		Detected: false,
		Type:     models.StressTypeWater,
	}

	// Rule 1: Water stress
	if ndwi.MeanValue < -0.10 && ndvi.MeanValue < 0.40 {
		result.Detected = true
		result.Type = models.StressTypeWater
		result.Severity = clamp01(1.0 - (ndwi.MeanValue+0.10)/0.50) // maps [-0.60, -0.10] -> [1.0, 0.0]
		result.AffectedPct = estimateAffectedArea(ndvi.MeanValue, ndvi.MinValue, 0.40)
		result.Description = "Water deficit detected. Low NDWI combined with reduced NDVI indicates insufficient soil moisture or plant water uptake."
		result.Recommendation = "Increase irrigation frequency. Consider deficit irrigation scheduling aligned with crop growth stage. Verify soil moisture sensor readings."
		return result
	}

	// Rule 2: Nutrient stress
	if ndvi.MeanValue >= 0.25 && ndvi.MeanValue < 0.45 && ndwi.MeanValue >= -0.10 {
		result.Detected = true
		result.Type = models.StressTypeNutrient
		result.Severity = clamp01((0.45 - ndvi.MeanValue) / 0.20)
		result.AffectedPct = estimateAffectedArea(ndvi.MeanValue, ndvi.MinValue, 0.45)
		result.Description = "Nutrient deficiency suspected. Moderate NDVI with adequate water index suggests limited nutrient availability rather than water stress."
		result.Recommendation = "Conduct soil nutrient analysis (N-P-K). Apply targeted fertilisation based on deficiency. Consider foliar application for immediate uptake."
		return result
	}

	// Rule 3: Disease stress (high spatial variability)
	if ndvi.StdDev > 0.15 {
		result.Detected = true
		result.Type = models.StressTypeDisease
		result.Severity = clamp01((ndvi.StdDev - 0.15) / 0.20)
		result.AffectedPct = clamp01(ndvi.StdDev / ndvi.MeanValue * 50) // rough estimate
		result.Description = "Possible disease pressure detected. High spatial variability in NDVI suggests patchy canopy degradation consistent with fungal or bacterial infection."
		result.Recommendation = "Scout affected zones for visible disease symptoms. Collect leaf samples for laboratory diagnosis. Apply preventative fungicide if warranted."
		return result
	}

	// Rule 4: Pest stress (localized damage with otherwise healthy canopy)
	if ndvi.MinValue < 0.10 && ndvi.MeanValue > 0.35 {
		result.Detected = true
		result.Type = models.StressTypePest
		result.Severity = clamp01(0.10 - ndvi.MinValue + 0.3)
		result.AffectedPct = estimateAffectedArea(ndvi.MeanValue, ndvi.MinValue, 0.35)
		result.Description = "Possible pest damage detected. Localised patches of very low NDVI within an otherwise healthy canopy suggest concentrated insect or animal herbivory."
		result.Recommendation = "Deploy pest monitoring traps in affected zones. Identify pest species and apply targeted integrated pest management (IPM) strategies."
		return result
	}

	// No stress detected
	result.Description = "No significant crop stress detected. Vegetation indices are within healthy ranges."
	result.Recommendation = "Continue routine monitoring. Next analysis recommended in 7-10 days."
	return result
}

func (s *satelliteService) ListAlerts(ctx context.Context, tenantID, fieldID string, pageSize, pageOffset int32) ([]*models.CropStressAlert, int64, error) {
	if tenantID == "" {
		return nil, 0, errors.BadRequest("INVALID_TENANT", "tenant_id is required")
	}
	if pageSize <= 0 {
		pageSize = 20
	}
	if pageSize > 100 {
		pageSize = 100
	}
	if pageOffset < 0 {
		pageOffset = 0
	}

	var alerts []*models.CropStressAlert
	var total int64
	var err error

	if fieldID != "" {
		alerts, err = s.repo.ListCropStressAlertsByField(ctx, tenantID, fieldID, pageSize, pageOffset)
		if err != nil {
			return nil, 0, err
		}
		total, err = s.repo.CountCropStressAlertsByField(ctx, tenantID, fieldID)
	} else {
		alerts, err = s.repo.ListCropStressAlertsByTenant(ctx, tenantID, pageSize, pageOffset)
		if err != nil {
			return nil, 0, err
		}
		total, err = s.repo.CountCropStressAlertsByTenant(ctx, tenantID)
	}
	if err != nil {
		return nil, 0, err
	}
	return alerts, total, nil
}

// ---------------------------------------------------------------------------
// Temporal analysis
// ---------------------------------------------------------------------------

func (s *satelliteService) GetTemporalAnalysis(ctx context.Context, tenantID, fieldID, indexType string, startDate, endDate time.Time) (*models.TemporalAnalysis, error) {
	if tenantID == "" {
		return nil, errors.BadRequest("INVALID_TENANT", "tenant_id is required")
	}
	if fieldID == "" {
		return nil, errors.BadRequest("INVALID_FIELD", "field_id is required")
	}
	it := models.IndexType(indexType)
	if !it.IsValid() {
		return nil, errors.BadRequest("INVALID_INDEX_TYPE", "index_type must be NDVI, NDWI, or EVI")
	}
	if startDate.IsZero() || endDate.IsZero() {
		return nil, errors.BadRequest("INVALID_DATES", "start_date and end_date are required")
	}
	if endDate.Before(startDate) {
		return nil, errors.BadRequest("INVALID_DATE_RANGE", "end_date must be after start_date")
	}

	// Try to find a cached analysis that covers the requested range
	existing, err := s.repo.GetTemporalAnalysisByFieldAndType(ctx, tenantID, fieldID, it, startDate, endDate)
	if err == nil && existing != nil {
		return existing, nil
	}

	// Build temporal analysis from vegetation indices within the date range
	indices, err := s.repo.ListVegetationIndicesByFieldAndType(ctx, tenantID, fieldID, it)
	if err != nil {
		return nil, err
	}

	// Filter to the requested date range
	var filtered []*models.VegetationIndex
	for _, vi := range indices {
		if !vi.ComputedAt.Before(startDate) && !vi.ComputedAt.After(endDate) {
			filtered = append(filtered, vi)
		}
	}

	if len(filtered) == 0 {
		return nil, errors.NotFound("NO_DATA", "no vegetation index data available for the specified date range")
	}

	// Sort by computed date ascending
	sort.Slice(filtered, func(i, j int) bool {
		return filtered[i].ComputedAt.Before(filtered[j].ComputedAt)
	})

	// Build data points
	dataPoints := make([]models.TemporalDataPoint, len(filtered))
	meanValues := make([]float64, len(filtered))
	for i, vi := range filtered {
		dataPoints[i] = models.TemporalDataPoint{
			Date:      vi.ComputedAt,
			MeanValue: vi.MeanValue,
			MinValue:  vi.MinValue,
			MaxValue:  vi.MaxValue,
		}
		meanValues[i] = vi.MeanValue
	}

	// Compute trend using linear regression
	slope, direction := computeTrend(dataPoints)

	// Compute percentage change from first to last observation
	changePct := 0.0
	if len(meanValues) >= 2 && meanValues[0] != 0 {
		changePct = ((meanValues[len(meanValues)-1] - meanValues[0]) / math.Abs(meanValues[0])) * 100
	}

	userID := p9context.UserID(ctx)
	ta := &models.TemporalAnalysis{
		TenantID:       tenantID,
		FieldID:        fieldID,
		IndexType:      it,
		StartDate:      startDate,
		EndDate:        endDate,
		DataPoints:     dataPoints,
		TrendSlope:     slope,
		TrendDirection: direction,
		ChangePct:      changePct,
	}
	ta.CreatedBy = userID

	created, err := s.repo.CreateTemporalAnalysis(ctx, ta)
	if err != nil {
		s.logger.Errorf("GetTemporalAnalysis: failed to persist: %v", err)
		return nil, err
	}

	s.logger.Infof("Temporal analysis for field %s (%s): trend=%s slope=%.6f change=%.2f%%",
		fieldID, indexType, direction, slope, changePct)
	return created, nil
}

// ---------------------------------------------------------------------------
// Statistical helpers
// ---------------------------------------------------------------------------

type indexStats struct {
	Min    float64
	Max    float64
	Mean   float64
	StdDev float64
}

func computeStats(values []float64) indexStats {
	if len(values) == 0 {
		return indexStats{}
	}

	minVal := math.MaxFloat64
	maxVal := -math.MaxFloat64
	sum := 0.0

	for _, v := range values {
		sum += v
		if v < minVal {
			minVal = v
		}
		if v > maxVal {
			maxVal = v
		}
	}

	mean := sum / float64(len(values))

	// Compute standard deviation
	varianceSum := 0.0
	for _, v := range values {
		diff := v - mean
		varianceSum += diff * diff
	}
	stdDev := math.Sqrt(varianceSum / float64(len(values)))

	return indexStats{
		Min:    math.Round(minVal*10000) / 10000,
		Max:    math.Round(maxVal*10000) / 10000,
		Mean:   math.Round(mean*10000) / 10000,
		StdDev: math.Round(stdDev*10000) / 10000,
	}
}

// computeTrend performs ordinary least-squares regression on the temporal
// data points and returns the slope and a descriptive direction string.
func computeTrend(points []models.TemporalDataPoint) (float64, models.TrendDirection) {
	n := float64(len(points))
	if n < 2 {
		return 0, models.TrendDirectionStable
	}

	// Use day-offset as X for numerical stability
	baseTime := points[0].Date
	var sumX, sumY, sumXY, sumXX float64
	for _, p := range points {
		x := p.Date.Sub(baseTime).Hours() / 24.0 // days since first point
		y := p.MeanValue
		sumX += x
		sumY += y
		sumXY += x * y
		sumXX += x * x
	}

	denom := n*sumXX - sumX*sumX
	if denom == 0 {
		return 0, models.TrendDirectionStable
	}

	slope := (n*sumXY - sumX*sumY) / denom

	// Classify direction with a threshold to avoid noise-driven labels
	const threshold = 0.0005 // per day
	direction := models.TrendDirectionStable
	if slope > threshold {
		direction = models.TrendDirectionIncreasing
	} else if slope < -threshold {
		direction = models.TrendDirectionDecreasing
	}

	return math.Round(slope*1000000) / 1000000, direction
}

// estimateAffectedArea estimates the fraction of the field under stress
// based on the distance between mean and minimum NDVI relative to a threshold.
func estimateAffectedArea(mean, min, threshold float64) float64 {
	if mean >= threshold {
		return 0
	}
	ratio := (threshold - mean) / (threshold - min + 0.001)
	return clamp01(ratio * 100)
}

func clampReflectance(v float64) float64 {
	if v < 0 {
		return 0
	}
	if v > 1 {
		return 1
	}
	return v
}

func clamp01(v float64) float64 {
	if v < 0 {
		return 0
	}
	if v > 1 {
		return 1
	}
	return v
}

func generateRasterURL(tenantID, imageID, indexType string) string {
	return "s3://satellite-rasters/" + tenantID + "/" + imageID + "/" + indexType + "_" + ulid.NewString() + ".tif"
}

// ensure interface compliance
var _ SatelliteService = (*satelliteService)(nil)
