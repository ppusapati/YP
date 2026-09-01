// Package application contains the satellite-service application service.
package application

import (
	"context"
	"encoding/json"
	"fmt"
	"math"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	"p9e.in/samavaya/agriculture/satellite-service/internal/domain"
	"p9e.in/samavaya/agriculture/satellite-service/internal/ports/inbound"
	"p9e.in/samavaya/agriculture/satellite-service/internal/ports/outbound"
)

const (
	serviceName           = "satellite-service"
	eventTopic            = "samavaya.agriculture.satellite.events"
	maxPageSize     int32 = 100
	defaultPageSize       = int32(20)
)

type satelliteService struct {
	repo        outbound.SatelliteRepository
	pub         outbound.EventPublisher
	fieldClient outbound.FieldClient
	farmClient  outbound.FarmClient
	pool        *pgxpool.Pool
	log         *p9log.Helper
}

// NewSatelliteService creates a new application-layer SatelliteService.
func NewSatelliteService(
	repo outbound.SatelliteRepository,
	pub outbound.EventPublisher,
	fieldClient outbound.FieldClient,
	farmClient outbound.FarmClient,
	pool *pgxpool.Pool,
	log p9log.Logger,
) inbound.SatelliteService {
	return &satelliteService{
		repo:        repo,
		pub:         pub,
		fieldClient: fieldClient,
		farmClient:  farmClient,
		pool:        pool,
		log:         p9log.NewHelper(p9log.With(log, "component", "SatelliteService")),
	}
}

// ---------------------------------------------------------------------------
// RequestImagery
// ---------------------------------------------------------------------------

func (s *satelliteService) RequestImagery(ctx context.Context, image *domain.SatelliteImage) (*domain.SatelliteTask, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if image.FieldID == "" {
		return nil, errors.BadRequest("MISSING_FIELD_ID", "field_id is required")
	}

	image.TenantID = tenantID
	image.ProcessingStatus = domain.ProcessingStatusPending
	image.AcquisitionDate = time.Now()

	// Use a transaction to create both image and task atomically.
	tx, err := s.pool.Begin(ctx)
	if err != nil {
		return nil, errors.InternalServer("TX_BEGIN_FAILED", err.Error())
	}
	defer tx.Rollback(ctx) //nolint:errcheck

	txRepo := s.repo.WithTx(tx)

	createdImage, err := txRepo.CreateImage(ctx, image)
	if err != nil {
		return nil, err
	}

	task := &domain.SatelliteTask{
		TenantID:     tenantID,
		FieldID:      image.FieldID,
		TaskType:     "acquisition",
		Status:       domain.ProcessingStatusPending,
		InputImageID: createdImage.UUID,
		ResultID:     createdImage.UUID,
	}

	createdTask, err := txRepo.CreateTask(ctx, task)
	if err != nil {
		return nil, err
	}

	if err := tx.Commit(ctx); err != nil {
		return nil, errors.InternalServer("TX_COMMIT_FAILED", err.Error())
	}

	s.emitEvent(ctx, "agriculture.satellite.imagery.requested", createdImage.UUID, map[string]interface{}{
		"image_id": createdImage.UUID, "task_id": createdTask.UUID, "tenant_id": tenantID,
	})
	s.log.Infow("msg", "imagery requested", "image_id", createdImage.UUID, "task_id", createdTask.UUID)

	return createdTask, nil
}

// ---------------------------------------------------------------------------
// GetImage
// ---------------------------------------------------------------------------

func (s *satelliteService) GetImage(ctx context.Context, id string) (*domain.SatelliteImage, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if id == "" {
		return nil, errors.BadRequest("MISSING_ID", "image ID is required")
	}
	return s.repo.GetImageByID(ctx, id, tenantID)
}

// ---------------------------------------------------------------------------
// ListImages
// ---------------------------------------------------------------------------

func (s *satelliteService) ListImages(ctx context.Context, params domain.ListImagesParams) ([]domain.SatelliteImage, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	params.TenantID = tenantID
	params.PageSize = normalizePageSize(params.PageSize)
	return s.repo.ListImages(ctx, params)
}

// ---------------------------------------------------------------------------
// ComputeVegetationIndex
// ---------------------------------------------------------------------------

func (s *satelliteService) ComputeVegetationIndex(ctx context.Context, imageID, fieldID, indexType string) (*domain.VegetationIndex, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if imageID == "" {
		return nil, errors.BadRequest("MISSING_IMAGE_ID", "image_id is required")
	}
	if fieldID == "" {
		return nil, errors.BadRequest("MISSING_FIELD_ID", "field_id is required")
	}

	idxType := domain.IndexType(indexType)
	if !idxType.IsValid() {
		return nil, errors.BadRequest("INVALID_INDEX_TYPE", fmt.Sprintf("unsupported index type: %s", indexType))
	}

	// Verify the image exists.
	_, err := s.repo.GetImageByID(ctx, imageID, tenantID)
	if err != nil {
		return nil, err
	}

	// Generate synthetic index values based on index type.
	var minVal, maxVal, meanVal, stdDev float64
	switch idxType {
	case domain.IndexTypeNDVI:
		minVal, maxVal, meanVal, stdDev = 0.15, 0.85, 0.62, 0.12
	case domain.IndexTypeNDWI:
		minVal, maxVal, meanVal, stdDev = -0.35, 0.25, -0.05, 0.10
	case domain.IndexTypeEVI:
		minVal, maxVal, meanVal, stdDev = 0.10, 0.75, 0.45, 0.11
	}

	now := time.Now()
	idx := &domain.VegetationIndex{
		TenantID:   tenantID,
		ImageID:    imageID,
		FieldID:    fieldID,
		IndexType:  idxType,
		MinValue:   minVal,
		MaxValue:   maxVal,
		MeanValue:  meanVal,
		StdDev:     stdDev,
		RasterURL:  fmt.Sprintf("s3://satellite-rasters/%s/%s/%s.tif", tenantID, imageID, indexType),
		ComputedAt: now,
		Version:    1,
	}

	created, err := s.repo.CreateVegetationIndex(ctx, idx)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.satellite.index.computed", created.UUID, map[string]interface{}{
		"index_id": created.UUID, "image_id": imageID, "index_type": indexType, "tenant_id": tenantID,
	})
	s.log.Infow("msg", "vegetation index computed", "index_id", created.UUID, "index_type", indexType)

	return created, nil
}

// ---------------------------------------------------------------------------
// GetVegetationIndices
// ---------------------------------------------------------------------------

func (s *satelliteService) GetVegetationIndices(ctx context.Context, params domain.GetVegetationIndicesParams) ([]domain.VegetationIndex, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	params.TenantID = tenantID
	return s.repo.GetVegetationIndices(ctx, params)
}

// ---------------------------------------------------------------------------
// DetectCropStress
// ---------------------------------------------------------------------------

func (s *satelliteService) DetectCropStress(ctx context.Context, imageID, fieldID string) (*domain.CropStressAlert, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if imageID == "" {
		return nil, errors.BadRequest("MISSING_IMAGE_ID", "image_id is required")
	}
	if fieldID == "" {
		return nil, errors.BadRequest("MISSING_FIELD_ID", "field_id is required")
	}

	// Verify the image exists.
	_, err := s.repo.GetImageByID(ctx, imageID, tenantID)
	if err != nil {
		return nil, err
	}

	// Generate synthetic stress detection (no stress for demo).
	now := time.Now()
	alert := &domain.CropStressAlert{
		TenantID:        tenantID,
		FieldID:         fieldID,
		ImageID:         imageID,
		StressDetected:  false,
		StressType:      domain.StressTypeWater,
		StressSeverity:  0.1,
		AffectedAreaPct: 2.5,
		Description:     "Automated crop stress analysis completed. No significant stress detected.",
		Recommendation:  "Continue regular monitoring. Current crop health indicators are within normal range.",
		DetectedAt:      now,
		Version:         1,
	}

	created, err := s.repo.CreateAlert(ctx, alert)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.satellite.stress.detected", created.UUID, map[string]interface{}{
		"alert_id": created.UUID, "image_id": imageID, "stress_detected": false, "tenant_id": tenantID,
	})
	s.log.Infow("msg", "crop stress detection completed", "alert_id", created.UUID, "stress_detected", false)

	return created, nil
}

// ---------------------------------------------------------------------------
// GetTemporalAnalysis
// ---------------------------------------------------------------------------

func (s *satelliteService) GetTemporalAnalysis(ctx context.Context, params domain.TemporalAnalysisParams) (*domain.TemporalAnalysis, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if params.FieldID == "" {
		return nil, errors.BadRequest("MISSING_FIELD_ID", "field_id is required")
	}

	idxType := domain.IndexType(params.IndexType)
	if !idxType.IsValid() {
		return nil, errors.BadRequest("INVALID_INDEX_TYPE", fmt.Sprintf("unsupported index type: %s", params.IndexType))
	}

	params.TenantID = tenantID

	// Query vegetation indices for the field+index_type in date range.
	indices, err := s.repo.GetVegetationIndicesForTemporal(ctx, params)
	if err != nil {
		return nil, err
	}

	if len(indices) == 0 {
		return nil, errors.NotFound("NO_DATA", "no vegetation index data found for the specified parameters")
	}

	// Build data points.
	dataPoints := make([]domain.TemporalDataPoint, len(indices))
	for i, idx := range indices {
		dataPoints[i] = domain.TemporalDataPoint{
			Date:      idx.ComputedAt,
			MeanValue: idx.MeanValue,
			MinValue:  idx.MinValue,
			MaxValue:  idx.MaxValue,
		}
	}

	// Compute trend using linear regression.
	trendSlope, trendDirection, changePct := computeTrend(dataPoints)

	now := time.Now()
	analysis := &domain.TemporalAnalysis{
		TenantID:       tenantID,
		FieldID:        params.FieldID,
		IndexType:      idxType,
		StartDate:      params.StartDate,
		EndDate:        params.EndDate,
		DataPoints:     dataPoints,
		TrendSlope:     trendSlope,
		TrendDirection: trendDirection,
		ChangePct:      changePct,
		Version:        1,
	}
	analysis.UUID = ulid.NewString()
	analysis.CreatedAt = now

	return analysis, nil
}

// ---------------------------------------------------------------------------
// ListAlerts
// ---------------------------------------------------------------------------

func (s *satelliteService) ListAlerts(ctx context.Context, params domain.ListAlertsParams) ([]domain.CropStressAlert, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	params.TenantID = tenantID
	params.PageSize = normalizePageSize(params.PageSize)
	return s.repo.ListAlerts(ctx, params)
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

func normalizePageSize(ps int32) int32 {
	if ps <= 0 {
		return defaultPageSize
	}
	if ps > maxPageSize {
		return maxPageSize
	}
	return ps
}

// computeTrend performs simple linear regression on temporal data points and
// determines the trend direction and percentage change.
func computeTrend(dataPoints []domain.TemporalDataPoint) (slope float64, direction domain.TrendDirection, changePct float64) {
	n := len(dataPoints)
	if n < 2 {
		return 0, domain.TrendDirectionStable, 0
	}

	// Simple linear regression: y = a + b*x where x is the index.
	var sumX, sumY, sumXY, sumX2 float64
	fn := float64(n)
	for i, dp := range dataPoints {
		x := float64(i)
		sumX += x
		sumY += dp.MeanValue
		sumXY += x * dp.MeanValue
		sumX2 += x * x
	}
	denom := fn*sumX2 - sumX*sumX
	if denom != 0 {
		slope = (fn*sumXY - sumX*sumY) / denom
	}

	first := dataPoints[0].MeanValue
	last := dataPoints[n-1].MeanValue
	if math.Abs(first) > 1e-9 {
		changePct = ((last - first) / math.Abs(first)) * 100
	}

	const threshold = 0.01
	if slope > threshold {
		direction = domain.TrendDirectionIncreasing
	} else if slope < -threshold {
		direction = domain.TrendDirectionDecreasing
	} else {
		direction = domain.TrendDirectionStable
	}

	return slope, direction, changePct
}

func (s *satelliteService) emitEvent(ctx context.Context, eventType, aggregateID string, data map[string]interface{}) {
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
