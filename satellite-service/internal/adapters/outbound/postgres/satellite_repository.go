// Package postgres implements the outbound.SatelliteRepository port using pgx.
package postgres

import (
	"context"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	"p9e.in/samavaya/agriculture/satellite-service/internal/domain"
	"p9e.in/samavaya/agriculture/satellite-service/internal/ports/outbound"
)

type satelliteRepository struct {
	pool *pgxpool.Pool
	log  *p9log.Helper
	tx   pgx.Tx
}

// NewSatelliteRepository creates a new postgres-backed SatelliteRepository.
func NewSatelliteRepository(pool *pgxpool.Pool, log p9log.Logger) outbound.SatelliteRepository {
	return &satelliteRepository{
		pool: pool,
		log:  p9log.NewHelper(p9log.With(log, "component", "SatellitePostgresRepository")),
	}
}

func (r *satelliteRepository) WithTx(tx pgx.Tx) outbound.SatelliteRepository {
	return &satelliteRepository{pool: r.pool, log: r.log, tx: tx}
}

func (r *satelliteRepository) queryRow(ctx context.Context, sql string, args ...any) pgx.Row {
	if r.tx != nil {
		return r.tx.QueryRow(ctx, sql, args...)
	}
	return r.pool.QueryRow(ctx, sql, args...)
}

func (r *satelliteRepository) query(ctx context.Context, sql string, args ...any) (pgx.Rows, error) {
	if r.tx != nil {
		return r.tx.Query(ctx, sql, args...)
	}
	return r.pool.Query(ctx, sql, args...)
}

// ---------------------------------------------------------------------------
// Images
// ---------------------------------------------------------------------------

const imageColumns = `id, tenant_id, field_id, farm_id, satellite_provider,
	acquisition_date, cloud_cover_pct, resolution_meters, bands,
	bbox_min_lat, bbox_min_lon, bbox_max_lat, bbox_max_lon,
	image_url, processing_status, version, created_at, updated_at`

func (r *satelliteRepository) CreateImage(ctx context.Context, img *domain.SatelliteImage) (*domain.SatelliteImage, error) {
	img.ID = ulid.NewString()

	var bboxMinLat, bboxMinLon, bboxMaxLat, bboxMaxLon *float64
	if img.Bbox != nil {
		bboxMinLat = &img.Bbox.MinLat
		bboxMinLon = &img.Bbox.MinLon
		bboxMaxLat = &img.Bbox.MaxLat
		bboxMaxLon = &img.Bbox.MaxLon
	}

	row := r.queryRow(ctx,
		`INSERT INTO satellite_images (id, tenant_id, field_id, farm_id, satellite_provider,
			acquisition_date, cloud_cover_pct, resolution_meters, bands,
			bbox_min_lat, bbox_min_lon, bbox_max_lat, bbox_max_lon,
			image_url, processing_status)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15)
		RETURNING `+imageColumns,
		img.ID, img.TenantID, img.FieldID, img.FarmID, string(img.SatelliteProvider),
		img.AcquisitionDate, img.CloudCoverPct, img.ResolutionMeters, img.Bands,
		bboxMinLat, bboxMinLon, bboxMaxLat, bboxMaxLon,
		img.ImageURL, string(img.ProcessingStatus),
	)
	return scanImage(row)
}

func (r *satelliteRepository) GetImageByID(ctx context.Context, id, tenantID string) (*domain.SatelliteImage, error) {
	row := r.queryRow(ctx,
		`SELECT `+imageColumns+`
		FROM satellite_images WHERE id=$1 AND tenant_id=$2 AND deleted_at IS NULL`,
		id, tenantID,
	)
	img, err := scanImage(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("IMAGE_NOT_FOUND", fmt.Sprintf("satellite image not found: %s", id))
		}
		return nil, errors.InternalServer("DB_ERROR", err.Error())
	}
	return img, nil
}

func (r *satelliteRepository) ListImages(ctx context.Context, params domain.ListImagesParams) ([]domain.SatelliteImage, int32, error) {
	where := "tenant_id = $1 AND deleted_at IS NULL"
	args := []any{params.TenantID}
	argIdx := 2

	if params.FieldID != "" {
		where += fmt.Sprintf(" AND field_id = $%d", argIdx)
		args = append(args, params.FieldID)
		argIdx++
	}
	if params.FarmID != "" {
		where += fmt.Sprintf(" AND farm_id = $%d", argIdx)
		args = append(args, params.FarmID)
		argIdx++
	}

	var total int32
	countSQL := "SELECT COUNT(*) FROM satellite_images WHERE " + where
	if err := r.queryRow(ctx, countSQL, args...).Scan(&total); err != nil {
		return nil, 0, errors.InternalServer("DB_ERROR", err.Error())
	}

	selectSQL := `SELECT ` + imageColumns + ` FROM satellite_images WHERE ` + where +
		fmt.Sprintf(" ORDER BY created_at DESC LIMIT $%d OFFSET $%d", argIdx, argIdx+1)
	args = append(args, params.PageSize, params.Offset)

	rows, err := r.query(ctx, selectSQL, args...)
	if err != nil {
		return nil, 0, errors.InternalServer("DB_ERROR", err.Error())
	}
	defer rows.Close()

	var images []domain.SatelliteImage
	for rows.Next() {
		img, err := scanImage(rows)
		if err != nil {
			return nil, 0, errors.InternalServer("DB_ERROR", err.Error())
		}
		images = append(images, *img)
	}
	if err := rows.Err(); err != nil {
		return nil, 0, errors.InternalServer("DB_ERROR", err.Error())
	}

	return images, total, nil
}

func scanImage(row pgx.Row) (*domain.SatelliteImage, error) {
	img := &domain.SatelliteImage{}
	var (
		provider, status                               string
		fieldID, farmID                                *string
		acquisitionDate                                *time.Time
		cloudCoverPct, resolutionMeters                *float64
		bboxMinLat, bboxMinLon, bboxMaxLat, bboxMaxLon *float64
		imageURL                                       *string
	)
	err := row.Scan(
		&img.ID, &img.TenantID, &fieldID, &farmID,
		&provider, &acquisitionDate,
		&cloudCoverPct, &resolutionMeters, &img.Bands,
		&bboxMinLat, &bboxMinLon, &bboxMaxLat, &bboxMaxLon,
		&imageURL, &status, &img.Version,
		&img.CreatedAt, &img.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}

	img.SatelliteProvider = domain.SatelliteProvider(provider)
	img.ProcessingStatus = domain.ProcessingStatus(status)
	if fieldID != nil {
		img.FieldID = *fieldID
	}
	if farmID != nil {
		img.FarmID = *farmID
	}
	if acquisitionDate != nil {
		img.AcquisitionDate = *acquisitionDate
	}
	if cloudCoverPct != nil {
		img.CloudCoverPct = *cloudCoverPct
	}
	if resolutionMeters != nil {
		img.ResolutionMeters = *resolutionMeters
	}
	if imageURL != nil {
		img.ImageURL = *imageURL
	}
	if bboxMinLat != nil && bboxMinLon != nil && bboxMaxLat != nil && bboxMaxLon != nil {
		img.Bbox = &domain.BoundingBox{
			MinLat: *bboxMinLat, MinLon: *bboxMinLon,
			MaxLat: *bboxMaxLat, MaxLon: *bboxMaxLon,
		}
	}

	return img, nil
}

// ---------------------------------------------------------------------------
// Vegetation Indices
// ---------------------------------------------------------------------------

const indexColumns = `id, tenant_id, image_id, field_id, index_type,
	min_value, max_value, mean_value, std_dev,
	raster_url, computed_at, version, created_at, updated_at`

func (r *satelliteRepository) CreateVegetationIndex(ctx context.Context, idx *domain.VegetationIndex) (*domain.VegetationIndex, error) {
	idx.ID = ulid.NewString()

	row := r.queryRow(ctx,
		`INSERT INTO vegetation_indices (id, tenant_id, image_id, field_id, index_type,
			min_value, max_value, mean_value, std_dev, raster_url, computed_at)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)
		RETURNING `+indexColumns,
		idx.ID, idx.TenantID, idx.ImageID, idx.FieldID, string(idx.IndexType),
		idx.MinValue, idx.MaxValue, idx.MeanValue, idx.StdDev,
		idx.RasterURL, idx.ComputedAt,
	)
	return scanVegetationIndex(row)
}

func (r *satelliteRepository) GetVegetationIndices(ctx context.Context, params domain.GetVegetationIndicesParams) ([]domain.VegetationIndex, error) {
	where := "tenant_id = $1 AND deleted_at IS NULL"
	args := []any{params.TenantID}
	argIdx := 2

	if params.ImageID != "" {
		where += fmt.Sprintf(" AND image_id = $%d", argIdx)
		args = append(args, params.ImageID)
		argIdx++
	}
	if params.FieldID != "" {
		where += fmt.Sprintf(" AND field_id = $%d", argIdx)
		args = append(args, params.FieldID)
		argIdx++
	}
	if params.IndexType != "" {
		where += fmt.Sprintf(" AND index_type = $%d", argIdx)
		args = append(args, params.IndexType)
		argIdx++
	}

	selectSQL := `SELECT ` + indexColumns + ` FROM vegetation_indices WHERE ` + where + ` ORDER BY computed_at DESC`

	rows, err := r.query(ctx, selectSQL, args...)
	if err != nil {
		return nil, errors.InternalServer("DB_ERROR", err.Error())
	}
	defer rows.Close()

	var indices []domain.VegetationIndex
	for rows.Next() {
		idx, err := scanVegetationIndex(rows)
		if err != nil {
			return nil, errors.InternalServer("DB_ERROR", err.Error())
		}
		indices = append(indices, *idx)
	}
	if err := rows.Err(); err != nil {
		return nil, errors.InternalServer("DB_ERROR", err.Error())
	}

	return indices, nil
}

func (r *satelliteRepository) GetVegetationIndicesForTemporal(ctx context.Context, params domain.TemporalAnalysisParams) ([]domain.VegetationIndex, error) {
	selectSQL := `SELECT ` + indexColumns + ` FROM vegetation_indices
		WHERE tenant_id = $1 AND field_id = $2 AND index_type = $3
		AND computed_at >= $4 AND computed_at <= $5 AND deleted_at IS NULL
		ORDER BY computed_at ASC`

	rows, err := r.query(ctx, selectSQL,
		params.TenantID, params.FieldID, params.IndexType,
		params.StartDate, params.EndDate,
	)
	if err != nil {
		return nil, errors.InternalServer("DB_ERROR", err.Error())
	}
	defer rows.Close()

	var indices []domain.VegetationIndex
	for rows.Next() {
		idx, err := scanVegetationIndex(rows)
		if err != nil {
			return nil, errors.InternalServer("DB_ERROR", err.Error())
		}
		indices = append(indices, *idx)
	}
	if err := rows.Err(); err != nil {
		return nil, errors.InternalServer("DB_ERROR", err.Error())
	}

	return indices, nil
}

func scanVegetationIndex(row pgx.Row) (*domain.VegetationIndex, error) {
	idx := &domain.VegetationIndex{}
	var (
		indexType                       string
		imageID, fieldID               *string
		minVal, maxVal, meanVal, stdDev *float64
		rasterURL                      *string
		computedAt                     *time.Time
	)
	err := row.Scan(
		&idx.ID, &idx.TenantID, &imageID, &fieldID,
		&indexType, &minVal, &maxVal, &meanVal, &stdDev,
		&rasterURL, &computedAt, &idx.Version,
		&idx.CreatedAt, &idx.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}

	idx.IndexType = domain.IndexType(indexType)
	if imageID != nil {
		idx.ImageID = *imageID
	}
	if fieldID != nil {
		idx.FieldID = *fieldID
	}
	if minVal != nil {
		idx.MinValue = *minVal
	}
	if maxVal != nil {
		idx.MaxValue = *maxVal
	}
	if meanVal != nil {
		idx.MeanValue = *meanVal
	}
	if stdDev != nil {
		idx.StdDev = *stdDev
	}
	if rasterURL != nil {
		idx.RasterURL = *rasterURL
	}
	if computedAt != nil {
		idx.ComputedAt = *computedAt
	}

	return idx, nil
}

// ---------------------------------------------------------------------------
// Alerts
// ---------------------------------------------------------------------------

const alertColumns = `id, tenant_id, field_id, image_id,
	stress_detected, stress_type, stress_severity, affected_area_pct,
	description, recommendation,
	affected_bbox_min_lat, affected_bbox_min_lon, affected_bbox_max_lat, affected_bbox_max_lon,
	detected_at, version, created_at, updated_at`

func (r *satelliteRepository) CreateAlert(ctx context.Context, alert *domain.CropStressAlert) (*domain.CropStressAlert, error) {
	alert.ID = ulid.NewString()

	var abMinLat, abMinLon, abMaxLat, abMaxLon *float64
	if alert.AffectedBbox != nil {
		abMinLat = &alert.AffectedBbox.MinLat
		abMinLon = &alert.AffectedBbox.MinLon
		abMaxLat = &alert.AffectedBbox.MaxLat
		abMaxLon = &alert.AffectedBbox.MaxLon
	}

	row := r.queryRow(ctx,
		`INSERT INTO satellite_alerts (id, tenant_id, field_id, image_id,
			stress_detected, stress_type, stress_severity, affected_area_pct,
			description, recommendation,
			affected_bbox_min_lat, affected_bbox_min_lon, affected_bbox_max_lat, affected_bbox_max_lon,
			detected_at)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15)
		RETURNING `+alertColumns,
		alert.ID, alert.TenantID, alert.FieldID, alert.ImageID,
		alert.StressDetected, string(alert.StressType), alert.StressSeverity, alert.AffectedAreaPct,
		alert.Description, alert.Recommendation,
		abMinLat, abMinLon, abMaxLat, abMaxLon,
		alert.DetectedAt,
	)
	return scanAlert(row)
}

func (r *satelliteRepository) ListAlerts(ctx context.Context, params domain.ListAlertsParams) ([]domain.CropStressAlert, int32, error) {
	where := "tenant_id = $1 AND deleted_at IS NULL"
	args := []any{params.TenantID}
	argIdx := 2

	if params.FieldID != "" {
		where += fmt.Sprintf(" AND field_id = $%d", argIdx)
		args = append(args, params.FieldID)
		argIdx++
	}

	var total int32
	countSQL := "SELECT COUNT(*) FROM satellite_alerts WHERE " + where
	if err := r.queryRow(ctx, countSQL, args...).Scan(&total); err != nil {
		return nil, 0, errors.InternalServer("DB_ERROR", err.Error())
	}

	selectSQL := `SELECT ` + alertColumns + ` FROM satellite_alerts WHERE ` + where +
		fmt.Sprintf(" ORDER BY created_at DESC LIMIT $%d OFFSET $%d", argIdx, argIdx+1)
	args = append(args, params.PageSize, params.Offset)

	rows, err := r.query(ctx, selectSQL, args...)
	if err != nil {
		return nil, 0, errors.InternalServer("DB_ERROR", err.Error())
	}
	defer rows.Close()

	var alerts []domain.CropStressAlert
	for rows.Next() {
		a, err := scanAlert(rows)
		if err != nil {
			return nil, 0, errors.InternalServer("DB_ERROR", err.Error())
		}
		alerts = append(alerts, *a)
	}
	if err := rows.Err(); err != nil {
		return nil, 0, errors.InternalServer("DB_ERROR", err.Error())
	}

	return alerts, total, nil
}

func scanAlert(row pgx.Row) (*domain.CropStressAlert, error) {
	alert := &domain.CropStressAlert{}
	var (
		stressType                                     string
		fieldID, imageID                               *string
		stressSeverity, affectedAreaPct                 *float64
		description, recommendation                    *string
		abMinLat, abMinLon, abMaxLat, abMaxLon         *float64
		detectedAt                                     *time.Time
	)
	err := row.Scan(
		&alert.ID, &alert.TenantID, &fieldID, &imageID,
		&alert.StressDetected, &stressType, &stressSeverity, &affectedAreaPct,
		&description, &recommendation,
		&abMinLat, &abMinLon, &abMaxLat, &abMaxLon,
		&detectedAt, &alert.Version, &alert.CreatedAt, &alert.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}

	alert.StressType = domain.StressType(stressType)
	if fieldID != nil {
		alert.FieldID = *fieldID
	}
	if imageID != nil {
		alert.ImageID = *imageID
	}
	if stressSeverity != nil {
		alert.StressSeverity = *stressSeverity
	}
	if affectedAreaPct != nil {
		alert.AffectedAreaPct = *affectedAreaPct
	}
	if description != nil {
		alert.Description = *description
	}
	if recommendation != nil {
		alert.Recommendation = *recommendation
	}
	if detectedAt != nil {
		alert.DetectedAt = *detectedAt
	}
	if abMinLat != nil && abMinLon != nil && abMaxLat != nil && abMaxLon != nil {
		alert.AffectedBbox = &domain.BoundingBox{
			MinLat: *abMinLat, MinLon: *abMinLon,
			MaxLat: *abMaxLat, MaxLon: *abMaxLon,
		}
	}

	return alert, nil
}

// ---------------------------------------------------------------------------
// Tasks
// ---------------------------------------------------------------------------

const taskColumns = `id, tenant_id, field_id, task_type, status,
	input_image_id, result_id, error_message, retry_count,
	version, created_at, updated_at`

func (r *satelliteRepository) CreateTask(ctx context.Context, task *domain.SatelliteTask) (*domain.SatelliteTask, error) {
	task.ID = ulid.NewString()

	row := r.queryRow(ctx,
		`INSERT INTO satellite_tasks (id, tenant_id, field_id, task_type, status,
			input_image_id, result_id, error_message, retry_count)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)
		RETURNING `+taskColumns,
		task.ID, task.TenantID, task.FieldID, task.TaskType, string(task.Status),
		task.InputImageID, task.ResultID, task.ErrorMessage, task.RetryCount,
	)
	return scanTask(row)
}

func scanTask(row pgx.Row) (*domain.SatelliteTask, error) {
	task := &domain.SatelliteTask{}
	var (
		status                                        string
		fieldID, inputImageID, resultID, errorMessage *string
	)
	err := row.Scan(
		&task.ID, &task.TenantID, &fieldID, &task.TaskType, &status,
		&inputImageID, &resultID, &errorMessage, &task.RetryCount,
		&task.Version, &task.CreatedAt, &task.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}

	task.Status = domain.ProcessingStatus(status)
	if fieldID != nil {
		task.FieldID = *fieldID
	}
	if inputImageID != nil {
		task.InputImageID = *inputImageID
	}
	if resultID != nil {
		task.ResultID = *resultID
	}
	if errorMessage != nil {
		task.ErrorMessage = *errorMessage
	}

	return task, nil
}
