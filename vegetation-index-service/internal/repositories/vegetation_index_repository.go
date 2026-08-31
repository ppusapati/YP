package repositories

import (
	"context"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	vimodels "p9e.in/samavaya/agriculture/vegetation-index-service/internal/models"
)

// VegetationIndexRepository defines the interface for vegetation index persistence operations.
type VegetationIndexRepository interface {
	// Compute tasks
	InsertComputeTask(ctx context.Context, task *vimodels.ComputeTask) (*vimodels.ComputeTask, error)
	GetComputeTaskByUUID(ctx context.Context, uuid, tenantID string) (*vimodels.ComputeTask, error)
	ListComputeTasks(ctx context.Context, params vimodels.ListComputeTasksParams) ([]vimodels.ComputeTask, error)
	UpdateComputeStatus(ctx context.Context, uuid, tenantID string, status vimodels.ComputeStatus, errorMessage *string, computeTime *float64, updatedBy string) (*vimodels.ComputeTask, error)

	// Vegetation indices
	InsertVegetationIndex(ctx context.Context, vi *vimodels.VegetationIndex) (*vimodels.VegetationIndex, error)
	GetVegetationIndexByUUID(ctx context.Context, uuid, tenantID string) (*vimodels.VegetationIndex, error)
	ListVegetationIndices(ctx context.Context, params vimodels.ListVegetationIndicesParams) ([]vimodels.VegetationIndex, int32, error)

	// Time series and health
	GetNDVITimeSeries(ctx context.Context, tenantID, farmUUID string, fieldUUID *string, dateFrom, dateTo *time.Time) ([]vimodels.TimeSeriesPoint, error)
	GetFieldHealthSummary(ctx context.Context, tenantID, farmUUID string, fieldUUID *string) (*vimodels.FieldHealthSummary, error)

	// Transaction support
	WithTx(tx pgx.Tx) VegetationIndexRepository
}

// vegetationIndexRepository is the concrete implementation of VegetationIndexRepository.
type vegetationIndexRepository struct {
	d   deps.ServiceDeps
	log *p9log.Helper
	tx  pgx.Tx
}

// NewVegetationIndexRepository creates a new VegetationIndexRepository.
func NewVegetationIndexRepository(d deps.ServiceDeps) VegetationIndexRepository {
	return &vegetationIndexRepository{
		d:   d,
		log: p9log.NewHelper(p9log.With(d.Log, "component", "VegetationIndexRepository")),
	}
}

// WithTx returns a copy of the repository that uses the provided transaction.
func (r *vegetationIndexRepository) WithTx(tx pgx.Tx) VegetationIndexRepository {
	return &vegetationIndexRepository{
		d:   r.d,
		log: r.log,
		tx:  tx,
	}
}

// queryRow is a helper to use the tx or pool for single-row queries.
func (r *vegetationIndexRepository) queryRow(ctx context.Context, sql string, args ...any) pgx.Row {
	if r.tx != nil {
		return r.tx.QueryRow(ctx, sql, args...)
	}
	return r.d.Pool.QueryRow(ctx, sql, args...)
}

// query is a helper to use the tx or pool for multi-row queries.
func (r *vegetationIndexRepository) query(ctx context.Context, sql string, args ...any) (pgx.Rows, error) {
	if r.tx != nil {
		return r.tx.Query(ctx, sql, args...)
	}
	return r.d.Pool.Query(ctx, sql, args...)
}

// exec is a helper to use the tx or pool for exec statements.
func (r *vegetationIndexRepository) exec(ctx context.Context, sql string, args ...any) error {
	var err error
	if r.tx != nil {
		_, err = r.tx.Exec(ctx, sql, args...)
	} else {
		_, err = r.d.Pool.Exec(ctx, sql, args...)
	}
	return err
}

// ---------- Compute Task Operations ----------

func (r *vegetationIndexRepository) InsertComputeTask(ctx context.Context, task *vimodels.ComputeTask) (*vimodels.ComputeTask, error) {
	task.UUID = ulid.NewString()
	task.CreatedAt = time.Now()
	task.IsActive = true
	task.Version = 1
	task.Status = vimodels.ComputeStatusQueued

	// Convert index types to string array for PostgreSQL
	indexTypeStrs := make([]string, len(task.IndexTypes))
	for i, it := range task.IndexTypes {
		indexTypeStrs[i] = string(it)
	}

	row := r.queryRow(ctx, `
		INSERT INTO compute_tasks (
			uuid, tenant_id, processing_job_uuid, farm_uuid, index_types,
			status, version, is_active, created_by, created_at
		) VALUES (
			$1, $2, $3, $4, $5::vegetation_index_type[],
			'QUEUED', 1, TRUE, $6, NOW()
		)
		RETURNING id, uuid, tenant_id, processing_job_uuid, farm_uuid,
			index_types, status, error_message, compute_time_seconds,
			version, is_active, created_by, created_at,
			updated_by, updated_at, completed_at, deleted_at, deleted_by`,
		task.UUID, task.TenantID, task.ProcessingJobUUID, task.FarmUUID,
		indexTypeStrs, task.CreatedBy,
	)

	result := &vimodels.ComputeTask{}
	if err := scanComputeTask(row, result); err != nil {
		r.log.Errorw("msg", "failed to insert compute task", "error", err)
		return nil, errors.InternalServer("COMPUTE_TASK_CREATE_FAILED", fmt.Sprintf("failed to create compute task: %v", err))
	}

	r.log.Infow("msg", "compute task created", "uuid", result.UUID, "tenant_id", result.TenantID)
	return result, nil
}

func (r *vegetationIndexRepository) GetComputeTaskByUUID(ctx context.Context, uuid, tenantID string) (*vimodels.ComputeTask, error) {
	row := r.queryRow(ctx, `
		SELECT id, uuid, tenant_id, processing_job_uuid, farm_uuid,
			index_types, status, error_message, compute_time_seconds,
			version, is_active, created_by, created_at,
			updated_by, updated_at, completed_at, deleted_at, deleted_by
		FROM compute_tasks
		WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL`,
		uuid, tenantID,
	)

	task := &vimodels.ComputeTask{}
	if err := scanComputeTask(row, task); err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("COMPUTE_TASK_NOT_FOUND", fmt.Sprintf("compute task not found: %s", uuid))
		}
		r.log.Errorw("msg", "failed to get compute task", "uuid", uuid, "error", err)
		return nil, errors.InternalServer("COMPUTE_TASK_GET_FAILED", fmt.Sprintf("failed to get compute task: %v", err))
	}

	return task, nil
}

func (r *vegetationIndexRepository) ListComputeTasks(ctx context.Context, params vimodels.ListComputeTasksParams) ([]vimodels.ComputeTask, error) {
	rows, err := r.query(ctx, `
		SELECT id, uuid, tenant_id, processing_job_uuid, farm_uuid,
			index_types, status, error_message, compute_time_seconds,
			version, is_active, created_by, created_at,
			updated_by, updated_at, completed_at, deleted_at, deleted_by
		FROM compute_tasks
		WHERE tenant_id = $1
			AND is_active = TRUE
			AND deleted_at IS NULL
			AND ($2::VARCHAR IS NULL OR farm_uuid = $2)
			AND ($3::VARCHAR IS NULL OR status = $3::compute_status)
		ORDER BY created_at DESC
		LIMIT $4 OFFSET $5`,
		params.TenantID,
		nullableString(params.FarmUUID),
		nullableComputeStatus(params.Status),
		params.PageSize,
		params.Offset,
	)
	if err != nil {
		r.log.Errorw("msg", "failed to list compute tasks", "error", err)
		return nil, errors.InternalServer("COMPUTE_TASK_LIST_FAILED", fmt.Sprintf("failed to list compute tasks: %v", err))
	}
	defer rows.Close()

	tasks := make([]vimodels.ComputeTask, 0)
	for rows.Next() {
		var task vimodels.ComputeTask
		if err := scanComputeTaskFromRows(rows, &task); err != nil {
			r.log.Errorw("msg", "failed to scan compute task row", "error", err)
			return nil, errors.InternalServer("COMPUTE_TASK_SCAN_FAILED", fmt.Sprintf("failed to scan compute task: %v", err))
		}
		tasks = append(tasks, task)
	}
	if err := rows.Err(); err != nil {
		return nil, errors.InternalServer("COMPUTE_TASK_ROWS_ERROR", fmt.Sprintf("row iteration error: %v", err))
	}

	return tasks, nil
}

func (r *vegetationIndexRepository) UpdateComputeStatus(ctx context.Context, uuid, tenantID string, status vimodels.ComputeStatus, errorMessage *string, computeTime *float64, updatedBy string) (*vimodels.ComputeTask, error) {
	row := r.queryRow(ctx, `
		UPDATE compute_tasks SET
			status = $3::compute_status,
			error_message = $4,
			compute_time_seconds = COALESCE($5, compute_time_seconds),
			completed_at = CASE WHEN $3 IN ('COMPLETED', 'FAILED') THEN NOW() ELSE completed_at END,
			version = version + 1,
			updated_by = $6,
			updated_at = NOW()
		WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
		RETURNING id, uuid, tenant_id, processing_job_uuid, farm_uuid,
			index_types, status, error_message, compute_time_seconds,
			version, is_active, created_by, created_at,
			updated_by, updated_at, completed_at, deleted_at, deleted_by`,
		uuid, tenantID, string(status), errorMessage, computeTime, updatedBy,
	)

	result := &vimodels.ComputeTask{}
	if err := scanComputeTask(row, result); err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("COMPUTE_TASK_NOT_FOUND", fmt.Sprintf("compute task not found: %s", uuid))
		}
		r.log.Errorw("msg", "failed to update compute task status", "uuid", uuid, "error", err)
		return nil, errors.InternalServer("COMPUTE_STATUS_UPDATE_FAILED", fmt.Sprintf("failed to update compute status: %v", err))
	}

	r.log.Infow("msg", "compute task status updated", "uuid", result.UUID, "status", string(result.Status))
	return result, nil
}

// ---------- Vegetation Index Operations ----------

func (r *vegetationIndexRepository) InsertVegetationIndex(ctx context.Context, vi *vimodels.VegetationIndex) (*vimodels.VegetationIndex, error) {
	vi.UUID = ulid.NewString()
	vi.CreatedAt = time.Now()
	vi.ComputedAt = time.Now()
	vi.IsActive = true

	row := r.queryRow(ctx, `
		INSERT INTO vegetation_indices (
			uuid, tenant_id, farm_uuid, field_uuid, processing_job_uuid,
			compute_task_uuid, index_type, mean_value, min_value, max_value,
			std_deviation, median_value, pixel_count, coverage_percent,
			raster_s3_key, acquisition_date, computed_at,
			is_active, created_by, created_at
		) VALUES (
			$1, $2, $3, $4, $5,
			$6, $7::vegetation_index_type, $8, $9, $10,
			$11, $12, $13, $14,
			$15, $16, NOW(),
			TRUE, $17, NOW()
		)
		RETURNING id, uuid, tenant_id, farm_uuid, field_uuid,
			processing_job_uuid, compute_task_uuid, index_type,
			mean_value, min_value, max_value, std_deviation, median_value,
			pixel_count, coverage_percent, raster_s3_key,
			acquisition_date, computed_at, is_active, created_by, created_at,
			deleted_at, deleted_by`,
		vi.UUID, vi.TenantID, vi.FarmUUID, vi.FieldUUID, vi.ProcessingJobUUID,
		vi.ComputeTaskUUID, string(vi.IndexType), vi.MeanValue, vi.MinValue, vi.MaxValue,
		vi.StdDeviation, vi.MedianValue, vi.PixelCount, vi.CoveragePercent,
		vi.RasterS3Key, vi.AcquisitionDate, vi.CreatedBy,
	)

	result := &vimodels.VegetationIndex{}
	if err := scanVegetationIndex(row, result); err != nil {
		r.log.Errorw("msg", "failed to insert vegetation index", "error", err)
		return nil, errors.InternalServer("VI_CREATE_FAILED", fmt.Sprintf("failed to create vegetation index: %v", err))
	}

	r.log.Infow("msg", "vegetation index created", "uuid", result.UUID, "index_type", string(result.IndexType))
	return result, nil
}

func (r *vegetationIndexRepository) GetVegetationIndexByUUID(ctx context.Context, uuid, tenantID string) (*vimodels.VegetationIndex, error) {
	row := r.queryRow(ctx, `
		SELECT id, uuid, tenant_id, farm_uuid, field_uuid,
			processing_job_uuid, compute_task_uuid, index_type,
			mean_value, min_value, max_value, std_deviation, median_value,
			pixel_count, coverage_percent, raster_s3_key,
			acquisition_date, computed_at, is_active, created_by, created_at,
			deleted_at, deleted_by
		FROM vegetation_indices
		WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL`,
		uuid, tenantID,
	)

	vi := &vimodels.VegetationIndex{}
	if err := scanVegetationIndex(row, vi); err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("VI_NOT_FOUND", fmt.Sprintf("vegetation index not found: %s", uuid))
		}
		r.log.Errorw("msg", "failed to get vegetation index", "uuid", uuid, "error", err)
		return nil, errors.InternalServer("VI_GET_FAILED", fmt.Sprintf("failed to get vegetation index: %v", err))
	}

	return vi, nil
}

func (r *vegetationIndexRepository) ListVegetationIndices(ctx context.Context, params vimodels.ListVegetationIndicesParams) ([]vimodels.VegetationIndex, int32, error) {
	// Count total matching records
	var totalCount int32
	countRow := r.queryRow(ctx, `
		SELECT COUNT(*) FROM vegetation_indices
		WHERE tenant_id = $1
			AND is_active = TRUE
			AND deleted_at IS NULL
			AND ($2::VARCHAR IS NULL OR farm_uuid = $2)
			AND ($3::VARCHAR IS NULL OR field_uuid = $3)
			AND ($4::VARCHAR IS NULL OR index_type = $4::vegetation_index_type)
			AND ($5::TIMESTAMPTZ IS NULL OR acquisition_date >= $5)
			AND ($6::TIMESTAMPTZ IS NULL OR acquisition_date <= $6)`,
		params.TenantID,
		nullableString(params.FarmUUID),
		nullableString(params.FieldUUID),
		nullableIndexType(params.IndexType),
		params.DateFrom,
		params.DateTo,
	)
	if err := countRow.Scan(&totalCount); err != nil {
		r.log.Errorw("msg", "failed to count vegetation indices", "error", err)
		return nil, 0, errors.InternalServer("VI_COUNT_FAILED", fmt.Sprintf("failed to count vegetation indices: %v", err))
	}

	// Fetch the page
	rows, err := r.query(ctx, `
		SELECT id, uuid, tenant_id, farm_uuid, field_uuid,
			processing_job_uuid, compute_task_uuid, index_type,
			mean_value, min_value, max_value, std_deviation, median_value,
			pixel_count, coverage_percent, raster_s3_key,
			acquisition_date, computed_at, is_active, created_by, created_at,
			deleted_at, deleted_by
		FROM vegetation_indices
		WHERE tenant_id = $1
			AND is_active = TRUE
			AND deleted_at IS NULL
			AND ($2::VARCHAR IS NULL OR farm_uuid = $2)
			AND ($3::VARCHAR IS NULL OR field_uuid = $3)
			AND ($4::VARCHAR IS NULL OR index_type = $4::vegetation_index_type)
			AND ($5::TIMESTAMPTZ IS NULL OR acquisition_date >= $5)
			AND ($6::TIMESTAMPTZ IS NULL OR acquisition_date <= $6)
		ORDER BY acquisition_date DESC
		LIMIT $7 OFFSET $8`,
		params.TenantID,
		nullableString(params.FarmUUID),
		nullableString(params.FieldUUID),
		nullableIndexType(params.IndexType),
		params.DateFrom,
		params.DateTo,
		params.PageSize,
		params.Offset,
	)
	if err != nil {
		r.log.Errorw("msg", "failed to list vegetation indices", "error", err)
		return nil, 0, errors.InternalServer("VI_LIST_FAILED", fmt.Sprintf("failed to list vegetation indices: %v", err))
	}
	defer rows.Close()

	indices := make([]vimodels.VegetationIndex, 0)
	for rows.Next() {
		var vi vimodels.VegetationIndex
		if err := scanVegetationIndexFromRows(rows, &vi); err != nil {
			r.log.Errorw("msg", "failed to scan vegetation index row", "error", err)
			return nil, 0, errors.InternalServer("VI_SCAN_FAILED", fmt.Sprintf("failed to scan vegetation index: %v", err))
		}
		indices = append(indices, vi)
	}
	if err := rows.Err(); err != nil {
		return nil, 0, errors.InternalServer("VI_ROWS_ERROR", fmt.Sprintf("row iteration error: %v", err))
	}

	return indices, totalCount, nil
}

// ---------- Time Series and Health ----------

func (r *vegetationIndexRepository) GetNDVITimeSeries(ctx context.Context, tenantID, farmUUID string, fieldUUID *string, dateFrom, dateTo *time.Time) ([]vimodels.TimeSeriesPoint, error) {
	rows, err := r.query(ctx, `
		SELECT acquisition_date, mean_value, std_deviation
		FROM vegetation_indices
		WHERE tenant_id = $1
			AND farm_uuid = $2
			AND ($3::VARCHAR IS NULL OR field_uuid = $3)
			AND index_type = 'NDVI'
			AND is_active = TRUE
			AND deleted_at IS NULL
			AND ($4::TIMESTAMPTZ IS NULL OR acquisition_date >= $4)
			AND ($5::TIMESTAMPTZ IS NULL OR acquisition_date <= $5)
		ORDER BY acquisition_date ASC`,
		tenantID, farmUUID, fieldUUID, dateFrom, dateTo,
	)
	if err != nil {
		r.log.Errorw("msg", "failed to get NDVI time series", "farm_uuid", farmUUID, "error", err)
		return nil, errors.InternalServer("NDVI_TIMESERIES_FAILED", fmt.Sprintf("failed to get NDVI time series: %v", err))
	}
	defer rows.Close()

	points := make([]vimodels.TimeSeriesPoint, 0)
	for rows.Next() {
		var p vimodels.TimeSeriesPoint
		if err := rows.Scan(&p.Date, &p.Value, &p.StdDeviation); err != nil {
			r.log.Errorw("msg", "failed to scan time series point", "error", err)
			return nil, errors.InternalServer("NDVI_SCAN_FAILED", fmt.Sprintf("failed to scan time series point: %v", err))
		}
		points = append(points, p)
	}
	if err := rows.Err(); err != nil {
		return nil, errors.InternalServer("NDVI_ROWS_ERROR", fmt.Sprintf("row iteration error: %v", err))
	}

	return points, nil
}

func (r *vegetationIndexRepository) GetFieldHealthSummary(ctx context.Context, tenantID, farmUUID string, fieldUUID *string) (*vimodels.FieldHealthSummary, error) {
	// Get the two most recent NDVI values to compute trend
	rows, err := r.query(ctx, `
		SELECT mean_value, acquisition_date
		FROM vegetation_indices
		WHERE tenant_id = $1
			AND farm_uuid = $2
			AND ($3::VARCHAR IS NULL OR field_uuid = $3)
			AND index_type = 'NDVI'
			AND is_active = TRUE
			AND deleted_at IS NULL
		ORDER BY acquisition_date DESC
		LIMIT 2`,
		tenantID, farmUUID, fieldUUID,
	)
	if err != nil {
		r.log.Errorw("msg", "failed to get field health summary", "farm_uuid", farmUUID, "error", err)
		return nil, errors.InternalServer("HEALTH_SUMMARY_FAILED", fmt.Sprintf("failed to get field health summary: %v", err))
	}
	defer rows.Close()

	type ndviRecord struct {
		MeanValue       float64
		AcquisitionDate time.Time
	}
	records := make([]ndviRecord, 0, 2)
	for rows.Next() {
		var rec ndviRecord
		if err := rows.Scan(&rec.MeanValue, &rec.AcquisitionDate); err != nil {
			return nil, errors.InternalServer("HEALTH_SCAN_FAILED", fmt.Sprintf("failed to scan health record: %v", err))
		}
		records = append(records, rec)
	}
	if err := rows.Err(); err != nil {
		return nil, errors.InternalServer("HEALTH_ROWS_ERROR", fmt.Sprintf("row iteration error: %v", err))
	}

	if len(records) == 0 {
		return nil, errors.NotFound("HEALTH_NOT_FOUND", fmt.Sprintf("no NDVI data found for farm: %s", farmUUID))
	}

	summary := &vimodels.FieldHealthSummary{
		CurrentNDVI:  records[0].MeanValue,
		LastComputed: records[0].AcquisitionDate,
	}

	// Compute trend if we have at least two data points
	if len(records) >= 2 {
		summary.NDVITrend = records[0].MeanValue - records[1].MeanValue
	}

	// Compute health score and category based on NDVI value
	summary.HealthScore, summary.HealthCategory = computeHealthFromNDVI(summary.CurrentNDVI)

	return summary, nil
}

// computeHealthFromNDVI derives a health score (0-100) and category from an NDVI value.
func computeHealthFromNDVI(ndvi float64) (float64, string) {
	switch {
	case ndvi >= 0.7:
		return 95.0, "EXCELLENT"
	case ndvi >= 0.5:
		return 80.0, "GOOD"
	case ndvi >= 0.3:
		return 60.0, "MODERATE"
	case ndvi >= 0.15:
		return 40.0, "POOR"
	default:
		return 20.0, "CRITICAL"
	}
}

// ---------- Scan helpers ----------

func scanComputeTask(row pgx.Row, ct *vimodels.ComputeTask) error {
	return row.Scan(
		&ct.ID, &ct.UUID, &ct.TenantID, &ct.ProcessingJobUUID, &ct.FarmUUID,
		&ct.IndexTypes, &ct.Status, &ct.ErrorMessage, &ct.ComputeTimeSeconds,
		&ct.Version, &ct.IsActive, &ct.CreatedBy, &ct.CreatedAt,
		&ct.UpdatedBy, &ct.UpdatedAt, &ct.CompletedAt, &ct.DeletedAt, &ct.DeletedBy,
	)
}

func scanComputeTaskFromRows(rows pgx.Rows, ct *vimodels.ComputeTask) error {
	return rows.Scan(
		&ct.ID, &ct.UUID, &ct.TenantID, &ct.ProcessingJobUUID, &ct.FarmUUID,
		&ct.IndexTypes, &ct.Status, &ct.ErrorMessage, &ct.ComputeTimeSeconds,
		&ct.Version, &ct.IsActive, &ct.CreatedBy, &ct.CreatedAt,
		&ct.UpdatedBy, &ct.UpdatedAt, &ct.CompletedAt, &ct.DeletedAt, &ct.DeletedBy,
	)
}

func scanVegetationIndex(row pgx.Row, vi *vimodels.VegetationIndex) error {
	return row.Scan(
		&vi.ID, &vi.UUID, &vi.TenantID, &vi.FarmUUID, &vi.FieldUUID,
		&vi.ProcessingJobUUID, &vi.ComputeTaskUUID, &vi.IndexType,
		&vi.MeanValue, &vi.MinValue, &vi.MaxValue, &vi.StdDeviation, &vi.MedianValue,
		&vi.PixelCount, &vi.CoveragePercent, &vi.RasterS3Key,
		&vi.AcquisitionDate, &vi.ComputedAt, &vi.IsActive, &vi.CreatedBy, &vi.CreatedAt,
		&vi.DeletedAt, &vi.DeletedBy,
	)
}

func scanVegetationIndexFromRows(rows pgx.Rows, vi *vimodels.VegetationIndex) error {
	return rows.Scan(
		&vi.ID, &vi.UUID, &vi.TenantID, &vi.FarmUUID, &vi.FieldUUID,
		&vi.ProcessingJobUUID, &vi.ComputeTaskUUID, &vi.IndexType,
		&vi.MeanValue, &vi.MinValue, &vi.MaxValue, &vi.StdDeviation, &vi.MedianValue,
		&vi.PixelCount, &vi.CoveragePercent, &vi.RasterS3Key,
		&vi.AcquisitionDate, &vi.ComputedAt, &vi.IsActive, &vi.CreatedBy, &vi.CreatedAt,
		&vi.DeletedAt, &vi.DeletedBy,
	)
}

// ---------- Nil helpers ----------

func nullableString(v *string) *string {
	if v == nil || *v == "" {
		return nil
	}
	return v
}

func nullableComputeStatus(v *vimodels.ComputeStatus) *string {
	if v == nil || *v == vimodels.ComputeStatusUnspecified {
		return nil
	}
	s := string(*v)
	return &s
}

func nullableIndexType(v *vimodels.VegetationIndexType) *string {
	if v == nil || *v == vimodels.VegetationIndexTypeUnspecified {
		return nil
	}
	s := string(*v)
	return &s
}
