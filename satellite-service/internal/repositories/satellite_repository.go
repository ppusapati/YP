package repositories

import (
	"context"
	"encoding/json"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"p9e.in/samavaya/agriculture/satellite-service/internal/models"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"
)

// ---------------------------------------------------------------------------
// Interface
// ---------------------------------------------------------------------------

// SatelliteRepository defines persistence operations for the satellite domain.
type SatelliteRepository interface {
	// Images
	CreateImage(ctx context.Context, img *models.SatelliteImage) (*models.SatelliteImage, error)
	GetImageByUUID(ctx context.Context, uuid, tenantID string) (*models.SatelliteImage, error)
	ListImagesByField(ctx context.Context, tenantID, fieldID string, limit, offset int32) ([]*models.SatelliteImage, error)
	ListImagesByFarm(ctx context.Context, tenantID, farmID string, limit, offset int32) ([]*models.SatelliteImage, error)
	ListImagesByTenant(ctx context.Context, tenantID string, limit, offset int32) ([]*models.SatelliteImage, error)
	CountImagesByTenant(ctx context.Context, tenantID string) (int64, error)
	CountImagesByField(ctx context.Context, tenantID, fieldID string) (int64, error)
	CountImagesByFarm(ctx context.Context, tenantID, farmID string) (int64, error)
	UpdateImageStatus(ctx context.Context, uuid, tenantID string, status models.ProcessingStatus, updatedBy string) (*models.SatelliteImage, error)
	UpdateImageURL(ctx context.Context, uuid, tenantID, imageURL, updatedBy string) (*models.SatelliteImage, error)

	// Vegetation indices
	CreateVegetationIndex(ctx context.Context, vi *models.VegetationIndex) (*models.VegetationIndex, error)
	GetVegetationIndexByUUID(ctx context.Context, uuid, tenantID string) (*models.VegetationIndex, error)
	ListVegetationIndicesByImage(ctx context.Context, tenantID, imageID string) ([]*models.VegetationIndex, error)
	ListVegetationIndicesByField(ctx context.Context, tenantID, fieldID string) ([]*models.VegetationIndex, error)
	ListVegetationIndicesByFieldAndType(ctx context.Context, tenantID, fieldID string, indexType models.IndexType) ([]*models.VegetationIndex, error)
	GetVegetationIndexByImageAndType(ctx context.Context, imageID string, indexType models.IndexType, tenantID string) (*models.VegetationIndex, error)

	// Crop stress alerts
	CreateCropStressAlert(ctx context.Context, alert *models.CropStressAlert) (*models.CropStressAlert, error)
	GetCropStressAlertByUUID(ctx context.Context, uuid, tenantID string) (*models.CropStressAlert, error)
	ListCropStressAlertsByField(ctx context.Context, tenantID, fieldID string, limit, offset int32) ([]*models.CropStressAlert, error)
	ListCropStressAlertsByTenant(ctx context.Context, tenantID string, limit, offset int32) ([]*models.CropStressAlert, error)
	CountCropStressAlertsByField(ctx context.Context, tenantID, fieldID string) (int64, error)
	CountCropStressAlertsByTenant(ctx context.Context, tenantID string) (int64, error)
	ListCropStressAlertsByImage(ctx context.Context, tenantID, imageID string) ([]*models.CropStressAlert, error)

	// Temporal analyses
	CreateTemporalAnalysis(ctx context.Context, ta *models.TemporalAnalysis) (*models.TemporalAnalysis, error)
	GetTemporalAnalysisByUUID(ctx context.Context, uuid, tenantID string) (*models.TemporalAnalysis, error)
	GetTemporalAnalysisByFieldAndType(ctx context.Context, tenantID, fieldID string, indexType models.IndexType, start, end time.Time) (*models.TemporalAnalysis, error)
	ListTemporalAnalysesByField(ctx context.Context, tenantID, fieldID string) ([]*models.TemporalAnalysis, error)

	// Tasks
	CreateTask(ctx context.Context, task *models.SatelliteTask) (*models.SatelliteTask, error)
	GetTaskByUUID(ctx context.Context, uuid, tenantID string) (*models.SatelliteTask, error)
	UpdateTaskStatus(ctx context.Context, uuid, tenantID string, status models.ProcessingStatus, resultID, errMsg, updatedBy string) (*models.SatelliteTask, error)
	IncrementTaskRetry(ctx context.Context, uuid, tenantID, updatedBy string) (*models.SatelliteTask, error)
	ListPendingTasks(ctx context.Context, limit int32) ([]*models.SatelliteTask, error)
}

// ---------------------------------------------------------------------------
// Implementation
// ---------------------------------------------------------------------------

type satelliteRepository struct {
	pool   *pgxpool.Pool
	logger p9log.Helper
}

// NewSatelliteRepository creates a new repository backed by pgx.
func NewSatelliteRepository(pool *pgxpool.Pool, logger p9log.Logger) SatelliteRepository {
	return &satelliteRepository{
		pool:   pool,
		logger: *p9log.NewHelper(p9log.With(logger, "component", "SatelliteRepository")),
	}
}

// ---------------------------------------------------------------------------
// Images
// ---------------------------------------------------------------------------

func (r *satelliteRepository) CreateImage(ctx context.Context, img *models.SatelliteImage) (*models.SatelliteImage, error) {
	img.UUID = ulid.NewString()
	if img.ProcessingStatus == "" {
		img.ProcessingStatus = models.ProcessingStatusPending
	}

	var minLon, minLat, maxLon, maxLat float64
	if img.Bbox != nil {
		minLon = img.Bbox.MinLon
		minLat = img.Bbox.MinLat
		maxLon = img.Bbox.MaxLon
		maxLat = img.Bbox.MaxLat
	}

	query := `INSERT INTO satellite_images (
		uuid, tenant_id, field_id, farm_id, satellite_provider,
		acquisition_date, cloud_cover_pct, resolution_meters, bands,
		bbox, image_url, processing_status, version, created_by, created_at
	) VALUES (
		$1, $2, $3, $4, $5,
		$6, $7, $8, $9,
		ST_MakeEnvelope($10, $11, $12, $13, 4326),
		$14, $15, 1, $16, NOW()
	) RETURNING id, uuid, tenant_id, field_id, farm_id, satellite_provider,
		acquisition_date, cloud_cover_pct, resolution_meters, bands,
		image_url, processing_status, version, is_active,
		created_by, created_at, updated_by, updated_at`

	row := r.pool.QueryRow(ctx, query,
		img.UUID, img.TenantID, img.FieldID, img.FarmID, string(img.SatelliteProvider),
		img.AcquisitionDate, img.CloudCoverPct, img.ResolutionMeters, img.Bands,
		minLon, minLat, maxLon, maxLat,
		img.ImageURL, string(img.ProcessingStatus), img.CreatedBy,
	)

	result := &models.SatelliteImage{Bbox: img.Bbox}
	var provider, status string
	err := row.Scan(
		&result.ID, &result.UUID, &result.TenantID, &result.FieldID, &result.FarmID,
		&provider, &result.AcquisitionDate, &result.CloudCoverPct, &result.ResolutionMeters,
		&result.Bands, &result.ImageURL, &status,
		&result.Version, &result.IsActive, &result.CreatedBy, &result.CreatedAt,
		&result.UpdatedBy, &result.UpdatedAt,
	)
	if err != nil {
		r.logger.Errorf("CreateImage failed: %v", err)
		return nil, errors.Internal("failed to create satellite image: %v", err)
	}
	result.SatelliteProvider = models.SatelliteProvider(provider)
	result.ProcessingStatus = models.ProcessingStatus(status)
	return result, nil
}

func (r *satelliteRepository) GetImageByUUID(ctx context.Context, uuid, tenantID string) (*models.SatelliteImage, error) {
	query := `SELECT id, uuid, tenant_id, field_id, farm_id, satellite_provider,
		acquisition_date, cloud_cover_pct, resolution_meters, bands,
		image_url, processing_status, version, is_active,
		created_by, created_at, updated_by, updated_at,
		ST_YMin(bbox) as min_lat, ST_XMin(bbox) as min_lon,
		ST_YMax(bbox) as max_lat, ST_XMax(bbox) as max_lon
	FROM satellite_images
	WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL`

	row := r.pool.QueryRow(ctx, query, uuid, tenantID)
	return r.scanImageWithBbox(row)
}

func (r *satelliteRepository) scanImageWithBbox(row pgx.Row) (*models.SatelliteImage, error) {
	var img models.SatelliteImage
	var provider, status string
	var minLat, minLon, maxLat, maxLon *float64

	err := row.Scan(
		&img.ID, &img.UUID, &img.TenantID, &img.FieldID, &img.FarmID,
		&provider, &img.AcquisitionDate, &img.CloudCoverPct, &img.ResolutionMeters,
		&img.Bands, &img.ImageURL, &status,
		&img.Version, &img.IsActive, &img.CreatedBy, &img.CreatedAt,
		&img.UpdatedBy, &img.UpdatedAt,
		&minLat, &minLon, &maxLat, &maxLon,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("IMAGE_NOT_FOUND", "satellite image not found")
		}
		return nil, errors.Internal("failed to scan satellite image: %v", err)
	}

	img.SatelliteProvider = models.SatelliteProvider(provider)
	img.ProcessingStatus = models.ProcessingStatus(status)
	if minLat != nil && minLon != nil && maxLat != nil && maxLon != nil {
		img.Bbox = &models.BoundingBox{
			MinLat: *minLat, MinLon: *minLon,
			MaxLat: *maxLat, MaxLon: *maxLon,
		}
	}
	return &img, nil
}

func (r *satelliteRepository) scanImages(rows pgx.Rows) ([]*models.SatelliteImage, error) {
	defer rows.Close()
	var result []*models.SatelliteImage
	for rows.Next() {
		var img models.SatelliteImage
		var provider, status string
		err := rows.Scan(
			&img.ID, &img.UUID, &img.TenantID, &img.FieldID, &img.FarmID,
			&provider, &img.AcquisitionDate, &img.CloudCoverPct, &img.ResolutionMeters,
			&img.Bands, &img.ImageURL, &status,
			&img.Version, &img.IsActive, &img.CreatedBy, &img.CreatedAt,
			&img.UpdatedBy, &img.UpdatedAt, &img.DeletedBy, &img.DeletedAt,
		)
		if err != nil {
			return nil, errors.Internal("failed to scan satellite image row: %v", err)
		}
		img.SatelliteProvider = models.SatelliteProvider(provider)
		img.ProcessingStatus = models.ProcessingStatus(status)
		result = append(result, &img)
	}
	return result, nil
}

func (r *satelliteRepository) ListImagesByField(ctx context.Context, tenantID, fieldID string, limit, offset int32) ([]*models.SatelliteImage, error) {
	query := `SELECT * FROM satellite_images
		WHERE tenant_id = $1 AND field_id = $2 AND is_active = TRUE AND deleted_at IS NULL
		ORDER BY acquisition_date DESC LIMIT $3 OFFSET $4`
	rows, err := r.pool.Query(ctx, query, tenantID, fieldID, limit, offset)
	if err != nil {
		return nil, errors.Internal("failed to list images by field: %v", err)
	}
	return r.scanImages(rows)
}

func (r *satelliteRepository) ListImagesByFarm(ctx context.Context, tenantID, farmID string, limit, offset int32) ([]*models.SatelliteImage, error) {
	query := `SELECT * FROM satellite_images
		WHERE tenant_id = $1 AND farm_id = $2 AND is_active = TRUE AND deleted_at IS NULL
		ORDER BY acquisition_date DESC LIMIT $3 OFFSET $4`
	rows, err := r.pool.Query(ctx, query, tenantID, farmID, limit, offset)
	if err != nil {
		return nil, errors.Internal("failed to list images by farm: %v", err)
	}
	return r.scanImages(rows)
}

func (r *satelliteRepository) ListImagesByTenant(ctx context.Context, tenantID string, limit, offset int32) ([]*models.SatelliteImage, error) {
	query := `SELECT * FROM satellite_images
		WHERE tenant_id = $1 AND is_active = TRUE AND deleted_at IS NULL
		ORDER BY acquisition_date DESC LIMIT $2 OFFSET $3`
	rows, err := r.pool.Query(ctx, query, tenantID, limit, offset)
	if err != nil {
		return nil, errors.Internal("failed to list images by tenant: %v", err)
	}
	return r.scanImages(rows)
}

func (r *satelliteRepository) CountImagesByTenant(ctx context.Context, tenantID string) (int64, error) {
	var count int64
	err := r.pool.QueryRow(ctx,
		`SELECT COUNT(*) FROM satellite_images WHERE tenant_id = $1 AND is_active = TRUE AND deleted_at IS NULL`,
		tenantID).Scan(&count)
	if err != nil {
		return 0, errors.Internal("failed to count images: %v", err)
	}
	return count, nil
}

func (r *satelliteRepository) CountImagesByField(ctx context.Context, tenantID, fieldID string) (int64, error) {
	var count int64
	err := r.pool.QueryRow(ctx,
		`SELECT COUNT(*) FROM satellite_images WHERE tenant_id = $1 AND field_id = $2 AND is_active = TRUE AND deleted_at IS NULL`,
		tenantID, fieldID).Scan(&count)
	if err != nil {
		return 0, errors.Internal("failed to count images by field: %v", err)
	}
	return count, nil
}

func (r *satelliteRepository) CountImagesByFarm(ctx context.Context, tenantID, farmID string) (int64, error) {
	var count int64
	err := r.pool.QueryRow(ctx,
		`SELECT COUNT(*) FROM satellite_images WHERE tenant_id = $1 AND farm_id = $2 AND is_active = TRUE AND deleted_at IS NULL`,
		tenantID, farmID).Scan(&count)
	if err != nil {
		return 0, errors.Internal("failed to count images by farm: %v", err)
	}
	return count, nil
}

func (r *satelliteRepository) UpdateImageStatus(ctx context.Context, uuid, tenantID string, status models.ProcessingStatus, updatedBy string) (*models.SatelliteImage, error) {
	query := `UPDATE satellite_images
		SET processing_status = $3, updated_by = $4, updated_at = NOW(), version = version + 1
		WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
		RETURNING id, uuid, tenant_id, field_id, farm_id, satellite_provider,
			acquisition_date, cloud_cover_pct, resolution_meters, bands,
			image_url, processing_status, version, is_active,
			created_by, created_at, updated_by, updated_at,
			NULL::float8, NULL::float8, NULL::float8, NULL::float8`

	row := r.pool.QueryRow(ctx, query, uuid, tenantID, string(status), updatedBy)
	return r.scanImageWithBbox(row)
}

func (r *satelliteRepository) UpdateImageURL(ctx context.Context, uuid, tenantID, imageURL, updatedBy string) (*models.SatelliteImage, error) {
	query := `UPDATE satellite_images
		SET image_url = $3, updated_by = $4, updated_at = NOW(), version = version + 1
		WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
		RETURNING id, uuid, tenant_id, field_id, farm_id, satellite_provider,
			acquisition_date, cloud_cover_pct, resolution_meters, bands,
			image_url, processing_status, version, is_active,
			created_by, created_at, updated_by, updated_at,
			NULL::float8, NULL::float8, NULL::float8, NULL::float8`

	row := r.pool.QueryRow(ctx, query, uuid, tenantID, imageURL, updatedBy)
	return r.scanImageWithBbox(row)
}

// ---------------------------------------------------------------------------
// Vegetation Indices
// ---------------------------------------------------------------------------

func (r *satelliteRepository) CreateVegetationIndex(ctx context.Context, vi *models.VegetationIndex) (*models.VegetationIndex, error) {
	vi.UUID = ulid.NewString()
	query := `INSERT INTO vegetation_indices (
		uuid, tenant_id, image_id, field_id, index_type,
		min_value, max_value, mean_value, std_dev,
		raster_url, computed_at, version, created_by, created_at
	) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,NOW(),1,$11,NOW())
	RETURNING id, uuid, tenant_id, image_id, field_id, index_type,
		min_value, max_value, mean_value, std_dev,
		raster_url, computed_at, version, is_active,
		created_by, created_at, updated_by, updated_at`

	row := r.pool.QueryRow(ctx, query,
		vi.UUID, vi.TenantID, vi.ImageID, vi.FieldID, string(vi.IndexType),
		vi.MinValue, vi.MaxValue, vi.MeanValue, vi.StdDev,
		vi.RasterURL, vi.CreatedBy,
	)
	return r.scanVegetationIndex(row)
}

func (r *satelliteRepository) scanVegetationIndex(row pgx.Row) (*models.VegetationIndex, error) {
	var vi models.VegetationIndex
	var indexType string
	err := row.Scan(
		&vi.ID, &vi.UUID, &vi.TenantID, &vi.ImageID, &vi.FieldID, &indexType,
		&vi.MinValue, &vi.MaxValue, &vi.MeanValue, &vi.StdDev,
		&vi.RasterURL, &vi.ComputedAt, &vi.Version, &vi.IsActive,
		&vi.CreatedBy, &vi.CreatedAt, &vi.UpdatedBy, &vi.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("VEGETATION_INDEX_NOT_FOUND", "vegetation index not found")
		}
		return nil, errors.Internal("failed to scan vegetation index: %v", err)
	}
	vi.IndexType = models.IndexType(indexType)
	return &vi, nil
}

func (r *satelliteRepository) scanVegetationIndices(rows pgx.Rows) ([]*models.VegetationIndex, error) {
	defer rows.Close()
	var result []*models.VegetationIndex
	for rows.Next() {
		var vi models.VegetationIndex
		var indexType string
		err := rows.Scan(
			&vi.ID, &vi.UUID, &vi.TenantID, &vi.ImageID, &vi.FieldID, &indexType,
			&vi.MinValue, &vi.MaxValue, &vi.MeanValue, &vi.StdDev,
			&vi.RasterURL, &vi.ComputedAt, &vi.Version, &vi.IsActive,
			&vi.CreatedBy, &vi.CreatedAt, &vi.UpdatedBy, &vi.UpdatedAt,
			&vi.DeletedBy, &vi.DeletedAt,
		)
		if err != nil {
			return nil, errors.Internal("failed to scan vegetation index row: %v", err)
		}
		vi.IndexType = models.IndexType(indexType)
		result = append(result, &vi)
	}
	return result, nil
}

func (r *satelliteRepository) GetVegetationIndexByUUID(ctx context.Context, uuid, tenantID string) (*models.VegetationIndex, error) {
	query := `SELECT id, uuid, tenant_id, image_id, field_id, index_type,
		min_value, max_value, mean_value, std_dev,
		raster_url, computed_at, version, is_active,
		created_by, created_at, updated_by, updated_at
	FROM vegetation_indices
	WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL`
	return r.scanVegetationIndex(r.pool.QueryRow(ctx, query, uuid, tenantID))
}

func (r *satelliteRepository) ListVegetationIndicesByImage(ctx context.Context, tenantID, imageID string) ([]*models.VegetationIndex, error) {
	query := `SELECT * FROM vegetation_indices
		WHERE tenant_id = $1 AND image_id = $2 AND is_active = TRUE AND deleted_at IS NULL
		ORDER BY created_at DESC`
	rows, err := r.pool.Query(ctx, query, tenantID, imageID)
	if err != nil {
		return nil, errors.Internal("failed to list vegetation indices by image: %v", err)
	}
	return r.scanVegetationIndices(rows)
}

func (r *satelliteRepository) ListVegetationIndicesByField(ctx context.Context, tenantID, fieldID string) ([]*models.VegetationIndex, error) {
	query := `SELECT * FROM vegetation_indices
		WHERE tenant_id = $1 AND field_id = $2 AND is_active = TRUE AND deleted_at IS NULL
		ORDER BY computed_at DESC`
	rows, err := r.pool.Query(ctx, query, tenantID, fieldID)
	if err != nil {
		return nil, errors.Internal("failed to list vegetation indices by field: %v", err)
	}
	return r.scanVegetationIndices(rows)
}

func (r *satelliteRepository) ListVegetationIndicesByFieldAndType(ctx context.Context, tenantID, fieldID string, indexType models.IndexType) ([]*models.VegetationIndex, error) {
	query := `SELECT * FROM vegetation_indices
		WHERE tenant_id = $1 AND field_id = $2 AND index_type = $3 AND is_active = TRUE AND deleted_at IS NULL
		ORDER BY computed_at DESC`
	rows, err := r.pool.Query(ctx, query, tenantID, fieldID, string(indexType))
	if err != nil {
		return nil, errors.Internal("failed to list vegetation indices by field and type: %v", err)
	}
	return r.scanVegetationIndices(rows)
}

func (r *satelliteRepository) GetVegetationIndexByImageAndType(ctx context.Context, imageID string, indexType models.IndexType, tenantID string) (*models.VegetationIndex, error) {
	query := `SELECT id, uuid, tenant_id, image_id, field_id, index_type,
		min_value, max_value, mean_value, std_dev,
		raster_url, computed_at, version, is_active,
		created_by, created_at, updated_by, updated_at
	FROM vegetation_indices
	WHERE image_id = $1 AND index_type = $2 AND tenant_id = $3 AND is_active = TRUE AND deleted_at IS NULL`
	return r.scanVegetationIndex(r.pool.QueryRow(ctx, query, imageID, string(indexType), tenantID))
}

// ---------------------------------------------------------------------------
// Crop Stress Alerts
// ---------------------------------------------------------------------------

func (r *satelliteRepository) CreateCropStressAlert(ctx context.Context, alert *models.CropStressAlert) (*models.CropStressAlert, error) {
	alert.UUID = ulid.NewString()

	var minLon, minLat, maxLon, maxLat float64
	if alert.AffectedBbox != nil {
		minLon = alert.AffectedBbox.MinLon
		minLat = alert.AffectedBbox.MinLat
		maxLon = alert.AffectedBbox.MaxLon
		maxLat = alert.AffectedBbox.MaxLat
	}

	query := `INSERT INTO crop_stress_alerts (
		uuid, tenant_id, field_id, image_id, stress_detected,
		stress_type, stress_severity, affected_area_pct,
		description, recommendation,
		affected_bbox,
		version, detected_at, created_by, created_at
	) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,
		ST_MakeEnvelope($11,$12,$13,$14,4326),
		1, NOW(), $15, NOW())
	RETURNING id, uuid, tenant_id, field_id, image_id, stress_detected,
		stress_type, stress_severity, affected_area_pct,
		description, recommendation,
		version, detected_at, is_active,
		created_by, created_at, updated_by, updated_at`

	row := r.pool.QueryRow(ctx, query,
		alert.UUID, alert.TenantID, alert.FieldID, alert.ImageID, alert.StressDetected,
		string(alert.StressType), alert.StressSeverity, alert.AffectedAreaPct,
		alert.Description, alert.Recommendation,
		minLon, minLat, maxLon, maxLat,
		alert.CreatedBy,
	)

	result := &models.CropStressAlert{AffectedBbox: alert.AffectedBbox}
	var stressType string
	err := row.Scan(
		&result.ID, &result.UUID, &result.TenantID, &result.FieldID, &result.ImageID,
		&result.StressDetected, &stressType, &result.StressSeverity, &result.AffectedAreaPct,
		&result.Description, &result.Recommendation,
		&result.Version, &result.DetectedAt, &result.IsActive,
		&result.CreatedBy, &result.CreatedAt, &result.UpdatedBy, &result.UpdatedAt,
	)
	if err != nil {
		r.logger.Errorf("CreateCropStressAlert failed: %v", err)
		return nil, errors.Internal("failed to create crop stress alert: %v", err)
	}
	result.StressType = models.StressType(stressType)
	return result, nil
}

func (r *satelliteRepository) GetCropStressAlertByUUID(ctx context.Context, uuid, tenantID string) (*models.CropStressAlert, error) {
	query := `SELECT id, uuid, tenant_id, field_id, image_id, stress_detected,
		stress_type, stress_severity, affected_area_pct,
		description, recommendation,
		version, detected_at, is_active,
		created_by, created_at, updated_by, updated_at
	FROM crop_stress_alerts
	WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL`
	return r.scanCropStressAlert(r.pool.QueryRow(ctx, query, uuid, tenantID))
}

func (r *satelliteRepository) scanCropStressAlert(row pgx.Row) (*models.CropStressAlert, error) {
	var alert models.CropStressAlert
	var stressType string
	err := row.Scan(
		&alert.ID, &alert.UUID, &alert.TenantID, &alert.FieldID, &alert.ImageID,
		&alert.StressDetected, &stressType, &alert.StressSeverity, &alert.AffectedAreaPct,
		&alert.Description, &alert.Recommendation,
		&alert.Version, &alert.DetectedAt, &alert.IsActive,
		&alert.CreatedBy, &alert.CreatedAt, &alert.UpdatedBy, &alert.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("ALERT_NOT_FOUND", "crop stress alert not found")
		}
		return nil, errors.Internal("failed to scan crop stress alert: %v", err)
	}
	alert.StressType = models.StressType(stressType)
	return &alert, nil
}

func (r *satelliteRepository) scanCropStressAlerts(rows pgx.Rows) ([]*models.CropStressAlert, error) {
	defer rows.Close()
	var result []*models.CropStressAlert
	for rows.Next() {
		var alert models.CropStressAlert
		var stressType string
		err := rows.Scan(
			&alert.ID, &alert.UUID, &alert.TenantID, &alert.FieldID, &alert.ImageID,
			&alert.StressDetected, &stressType, &alert.StressSeverity, &alert.AffectedAreaPct,
			&alert.Description, &alert.Recommendation,
			&alert.Version, &alert.DetectedAt, &alert.IsActive,
			&alert.CreatedBy, &alert.CreatedAt, &alert.UpdatedBy, &alert.UpdatedAt,
			&alert.DeletedBy, &alert.DeletedAt,
		)
		if err != nil {
			return nil, errors.Internal("failed to scan crop stress alert row: %v", err)
		}
		alert.StressType = models.StressType(stressType)
		result = append(result, &alert)
	}
	return result, nil
}

func (r *satelliteRepository) ListCropStressAlertsByField(ctx context.Context, tenantID, fieldID string, limit, offset int32) ([]*models.CropStressAlert, error) {
	query := `SELECT * FROM crop_stress_alerts
		WHERE tenant_id = $1 AND field_id = $2 AND is_active = TRUE AND deleted_at IS NULL
		ORDER BY detected_at DESC LIMIT $3 OFFSET $4`
	rows, err := r.pool.Query(ctx, query, tenantID, fieldID, limit, offset)
	if err != nil {
		return nil, errors.Internal("failed to list alerts by field: %v", err)
	}
	return r.scanCropStressAlerts(rows)
}

func (r *satelliteRepository) ListCropStressAlertsByTenant(ctx context.Context, tenantID string, limit, offset int32) ([]*models.CropStressAlert, error) {
	query := `SELECT * FROM crop_stress_alerts
		WHERE tenant_id = $1 AND is_active = TRUE AND deleted_at IS NULL
		ORDER BY detected_at DESC LIMIT $2 OFFSET $3`
	rows, err := r.pool.Query(ctx, query, tenantID, limit, offset)
	if err != nil {
		return nil, errors.Internal("failed to list alerts by tenant: %v", err)
	}
	return r.scanCropStressAlerts(rows)
}

func (r *satelliteRepository) CountCropStressAlertsByField(ctx context.Context, tenantID, fieldID string) (int64, error) {
	var count int64
	err := r.pool.QueryRow(ctx,
		`SELECT COUNT(*) FROM crop_stress_alerts WHERE tenant_id = $1 AND field_id = $2 AND is_active = TRUE AND deleted_at IS NULL`,
		tenantID, fieldID).Scan(&count)
	if err != nil {
		return 0, errors.Internal("failed to count alerts by field: %v", err)
	}
	return count, nil
}

func (r *satelliteRepository) CountCropStressAlertsByTenant(ctx context.Context, tenantID string) (int64, error) {
	var count int64
	err := r.pool.QueryRow(ctx,
		`SELECT COUNT(*) FROM crop_stress_alerts WHERE tenant_id = $1 AND is_active = TRUE AND deleted_at IS NULL`,
		tenantID).Scan(&count)
	if err != nil {
		return 0, errors.Internal("failed to count alerts by tenant: %v", err)
	}
	return count, nil
}

func (r *satelliteRepository) ListCropStressAlertsByImage(ctx context.Context, tenantID, imageID string) ([]*models.CropStressAlert, error) {
	query := `SELECT * FROM crop_stress_alerts
		WHERE tenant_id = $1 AND image_id = $2 AND is_active = TRUE AND deleted_at IS NULL
		ORDER BY detected_at DESC`
	rows, err := r.pool.Query(ctx, query, tenantID, imageID)
	if err != nil {
		return nil, errors.Internal("failed to list alerts by image: %v", err)
	}
	return r.scanCropStressAlerts(rows)
}

// ---------------------------------------------------------------------------
// Temporal Analyses
// ---------------------------------------------------------------------------

func (r *satelliteRepository) CreateTemporalAnalysis(ctx context.Context, ta *models.TemporalAnalysis) (*models.TemporalAnalysis, error) {
	ta.UUID = ulid.NewString()

	dpJSON, err := json.Marshal(ta.DataPoints)
	if err != nil {
		return nil, errors.Internal("failed to marshal data points: %v", err)
	}

	query := `INSERT INTO temporal_analyses (
		uuid, tenant_id, field_id, index_type,
		start_date, end_date, data_points,
		trend_slope, trend_direction, change_pct,
		version, created_by, created_at
	) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,1,$11,NOW())
	RETURNING id, uuid, tenant_id, field_id, index_type,
		start_date, end_date, data_points,
		trend_slope, trend_direction, change_pct,
		version, is_active, created_by, created_at, updated_by, updated_at`

	row := r.pool.QueryRow(ctx, query,
		ta.UUID, ta.TenantID, ta.FieldID, string(ta.IndexType),
		ta.StartDate, ta.EndDate, dpJSON,
		ta.TrendSlope, string(ta.TrendDirection), ta.ChangePct,
		ta.CreatedBy,
	)
	return r.scanTemporalAnalysis(row)
}

func (r *satelliteRepository) scanTemporalAnalysis(row pgx.Row) (*models.TemporalAnalysis, error) {
	var ta models.TemporalAnalysis
	var indexType, direction string
	var dpJSON []byte

	err := row.Scan(
		&ta.ID, &ta.UUID, &ta.TenantID, &ta.FieldID, &indexType,
		&ta.StartDate, &ta.EndDate, &dpJSON,
		&ta.TrendSlope, &direction, &ta.ChangePct,
		&ta.Version, &ta.IsActive, &ta.CreatedBy, &ta.CreatedAt, &ta.UpdatedBy, &ta.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("TEMPORAL_ANALYSIS_NOT_FOUND", "temporal analysis not found")
		}
		return nil, errors.Internal("failed to scan temporal analysis: %v", err)
	}
	ta.IndexType = models.IndexType(indexType)
	ta.TrendDirection = models.TrendDirection(direction)

	if len(dpJSON) > 0 {
		if jsonErr := json.Unmarshal(dpJSON, &ta.DataPoints); jsonErr != nil {
			return nil, errors.Internal("failed to unmarshal data points: %v", jsonErr)
		}
	}
	return &ta, nil
}

func (r *satelliteRepository) GetTemporalAnalysisByUUID(ctx context.Context, uuid, tenantID string) (*models.TemporalAnalysis, error) {
	query := `SELECT id, uuid, tenant_id, field_id, index_type,
		start_date, end_date, data_points,
		trend_slope, trend_direction, change_pct,
		version, is_active, created_by, created_at, updated_by, updated_at
	FROM temporal_analyses
	WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL`
	return r.scanTemporalAnalysis(r.pool.QueryRow(ctx, query, uuid, tenantID))
}

func (r *satelliteRepository) GetTemporalAnalysisByFieldAndType(ctx context.Context, tenantID, fieldID string, indexType models.IndexType, start, end time.Time) (*models.TemporalAnalysis, error) {
	query := `SELECT id, uuid, tenant_id, field_id, index_type,
		start_date, end_date, data_points,
		trend_slope, trend_direction, change_pct,
		version, is_active, created_by, created_at, updated_by, updated_at
	FROM temporal_analyses
	WHERE tenant_id = $1 AND field_id = $2 AND index_type = $3
	  AND start_date <= $4 AND end_date >= $5
	  AND is_active = TRUE AND deleted_at IS NULL
	ORDER BY created_at DESC LIMIT 1`
	return r.scanTemporalAnalysis(r.pool.QueryRow(ctx, query, tenantID, fieldID, string(indexType), start, end))
}

func (r *satelliteRepository) ListTemporalAnalysesByField(ctx context.Context, tenantID, fieldID string) ([]*models.TemporalAnalysis, error) {
	query := `SELECT id, uuid, tenant_id, field_id, index_type,
		start_date, end_date, data_points,
		trend_slope, trend_direction, change_pct,
		version, is_active, created_by, created_at, updated_by, updated_at
	FROM temporal_analyses
	WHERE tenant_id = $1 AND field_id = $2 AND is_active = TRUE AND deleted_at IS NULL
	ORDER BY created_at DESC`

	rows, err := r.pool.Query(ctx, query, tenantID, fieldID)
	if err != nil {
		return nil, errors.Internal("failed to list temporal analyses: %v", err)
	}
	defer rows.Close()

	var result []*models.TemporalAnalysis
	for rows.Next() {
		var ta models.TemporalAnalysis
		var indexType, direction string
		var dpJSON []byte
		err := rows.Scan(
			&ta.ID, &ta.UUID, &ta.TenantID, &ta.FieldID, &indexType,
			&ta.StartDate, &ta.EndDate, &dpJSON,
			&ta.TrendSlope, &direction, &ta.ChangePct,
			&ta.Version, &ta.IsActive, &ta.CreatedBy, &ta.CreatedAt, &ta.UpdatedBy, &ta.UpdatedAt,
		)
		if err != nil {
			return nil, errors.Internal("failed to scan temporal analysis row: %v", err)
		}
		ta.IndexType = models.IndexType(indexType)
		ta.TrendDirection = models.TrendDirection(direction)
		if len(dpJSON) > 0 {
			_ = json.Unmarshal(dpJSON, &ta.DataPoints)
		}
		result = append(result, &ta)
	}
	return result, nil
}

// ---------------------------------------------------------------------------
// Tasks
// ---------------------------------------------------------------------------

func (r *satelliteRepository) CreateTask(ctx context.Context, task *models.SatelliteTask) (*models.SatelliteTask, error) {
	task.UUID = ulid.NewString()
	if task.Status == "" {
		task.Status = models.ProcessingStatusPending
	}

	query := `INSERT INTO satellite_tasks (
		uuid, tenant_id, field_id, task_type, status,
		input_image_id, result_id, error_message, retry_count,
		version, created_by, created_at
	) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,1,$10,NOW())
	RETURNING id, uuid, tenant_id, field_id, task_type, status,
		input_image_id, result_id, error_message, retry_count,
		version, is_active, created_by, created_at, updated_by, updated_at`

	row := r.pool.QueryRow(ctx, query,
		task.UUID, task.TenantID, task.FieldID, task.TaskType, string(task.Status),
		task.InputImageID, task.ResultID, task.ErrorMessage, task.RetryCount,
		task.CreatedBy,
	)
	return r.scanTask(row)
}

func (r *satelliteRepository) scanTask(row pgx.Row) (*models.SatelliteTask, error) {
	var task models.SatelliteTask
	var status string
	err := row.Scan(
		&task.ID, &task.UUID, &task.TenantID, &task.FieldID, &task.TaskType,
		&status, &task.InputImageID, &task.ResultID, &task.ErrorMessage, &task.RetryCount,
		&task.Version, &task.IsActive, &task.CreatedBy, &task.CreatedAt,
		&task.UpdatedBy, &task.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("TASK_NOT_FOUND", "satellite task not found")
		}
		return nil, errors.Internal("failed to scan satellite task: %v", err)
	}
	task.Status = models.ProcessingStatus(status)
	return &task, nil
}

func (r *satelliteRepository) GetTaskByUUID(ctx context.Context, uuid, tenantID string) (*models.SatelliteTask, error) {
	query := `SELECT id, uuid, tenant_id, field_id, task_type, status,
		input_image_id, result_id, error_message, retry_count,
		version, is_active, created_by, created_at, updated_by, updated_at
	FROM satellite_tasks
	WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL`
	return r.scanTask(r.pool.QueryRow(ctx, query, uuid, tenantID))
}

func (r *satelliteRepository) UpdateTaskStatus(ctx context.Context, uuid, tenantID string, status models.ProcessingStatus, resultID, errMsg, updatedBy string) (*models.SatelliteTask, error) {
	query := `UPDATE satellite_tasks
		SET status = $3, result_id = $4, error_message = $5,
			updated_by = $6, updated_at = NOW(), version = version + 1
		WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
		RETURNING id, uuid, tenant_id, field_id, task_type, status,
			input_image_id, result_id, error_message, retry_count,
			version, is_active, created_by, created_at, updated_by, updated_at`
	return r.scanTask(r.pool.QueryRow(ctx, query, uuid, tenantID, string(status), resultID, errMsg, updatedBy))
}

func (r *satelliteRepository) IncrementTaskRetry(ctx context.Context, uuid, tenantID, updatedBy string) (*models.SatelliteTask, error) {
	query := `UPDATE satellite_tasks
		SET retry_count = retry_count + 1, updated_by = $3, updated_at = NOW(), version = version + 1
		WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
		RETURNING id, uuid, tenant_id, field_id, task_type, status,
			input_image_id, result_id, error_message, retry_count,
			version, is_active, created_by, created_at, updated_by, updated_at`
	return r.scanTask(r.pool.QueryRow(ctx, query, uuid, tenantID, updatedBy))
}

func (r *satelliteRepository) ListPendingTasks(ctx context.Context, limit int32) ([]*models.SatelliteTask, error) {
	query := `SELECT id, uuid, tenant_id, field_id, task_type, status,
		input_image_id, result_id, error_message, retry_count,
		version, is_active, created_by, created_at, updated_by, updated_at
	FROM satellite_tasks
	WHERE status = 'PENDING' AND is_active = TRUE AND deleted_at IS NULL
	ORDER BY created_at ASC LIMIT $1`

	rows, err := r.pool.Query(ctx, query, limit)
	if err != nil {
		return nil, errors.Internal("failed to list pending tasks: %v", err)
	}
	defer rows.Close()

	var result []*models.SatelliteTask
	for rows.Next() {
		var task models.SatelliteTask
		var status string
		err := rows.Scan(
			&task.ID, &task.UUID, &task.TenantID, &task.FieldID, &task.TaskType,
			&status, &task.InputImageID, &task.ResultID, &task.ErrorMessage, &task.RetryCount,
			&task.Version, &task.IsActive, &task.CreatedBy, &task.CreatedAt,
			&task.UpdatedBy, &task.UpdatedAt,
		)
		if err != nil {
			return nil, errors.Internal("failed to scan task row: %v", err)
		}
		task.Status = models.ProcessingStatus(status)
		result = append(result, &task)
	}
	return result, nil
}

// ensure interface compliance
var _ SatelliteRepository = (*satelliteRepository)(nil)
