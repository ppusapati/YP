package repositories

import (
	"context"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/lib/pq"
	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	ingestionmodels "p9e.in/samavaya/agriculture/satellite-ingestion-service/internal/models"
)

// IngestionRepository defines the interface for ingestion task persistence operations.
type IngestionRepository interface {
	CreateIngestionTask(ctx context.Context, task *ingestionmodels.IngestionTask) (*ingestionmodels.IngestionTask, error)
	GetIngestionTaskByUUID(ctx context.Context, uuid, tenantID string) (*ingestionmodels.IngestionTask, error)
	ListIngestionTasks(ctx context.Context, params ingestionmodels.ListIngestionTasksParams) ([]ingestionmodels.IngestionTask, int32, error)
	UpdateIngestionStatus(ctx context.Context, task *ingestionmodels.IngestionTask) (*ingestionmodels.IngestionTask, error)
	CancelIngestionTask(ctx context.Context, uuid, tenantID, cancelledBy string) (*ingestionmodels.IngestionTask, error)
	GetIngestionStats(ctx context.Context, tenantID string, farmUUID *string, provider *ingestionmodels.SatelliteProvider) (*ingestionmodels.IngestionStats, error)

	// Transaction support: accept a pgx.Tx for use within a UoW
	WithTx(tx pgx.Tx) IngestionRepository
}

// ingestionRepository is the concrete implementation of IngestionRepository.
type ingestionRepository struct {
	d   deps.ServiceDeps
	log *p9log.Helper
	tx  pgx.Tx
}

// NewIngestionRepository creates a new IngestionRepository.
func NewIngestionRepository(d deps.ServiceDeps) IngestionRepository {
	return &ingestionRepository{
		d:   d,
		log: p9log.NewHelper(p9log.With(d.Log, "component", "IngestionRepository")),
	}
}

// WithTx returns a copy of the repository that uses the provided transaction.
func (r *ingestionRepository) WithTx(tx pgx.Tx) IngestionRepository {
	return &ingestionRepository{
		d:   r.d,
		log: r.log,
		tx:  tx,
	}
}

// queryRow is a helper to use the tx or pool for single-row queries.
func (r *ingestionRepository) queryRow(ctx context.Context, sql string, args ...any) pgx.Row {
	if r.tx != nil {
		return r.tx.QueryRow(ctx, sql, args...)
	}
	return r.d.Pool.QueryRow(ctx, sql, args...)
}

// query is a helper to use the tx or pool for multi-row queries.
func (r *ingestionRepository) query(ctx context.Context, sql string, args ...any) (pgx.Rows, error) {
	if r.tx != nil {
		return r.tx.Query(ctx, sql, args...)
	}
	return r.d.Pool.Query(ctx, sql, args...)
}

// exec is a helper to use the tx or pool for exec statements.
func (r *ingestionRepository) exec(ctx context.Context, sql string, args ...any) error {
	var err error
	if r.tx != nil {
		_, err = r.tx.Exec(ctx, sql, args...)
	} else {
		_, err = r.d.Pool.Exec(ctx, sql, args...)
	}
	return err
}

// ---------- IngestionTask CRUD ----------

func (r *ingestionRepository) CreateIngestionTask(ctx context.Context, task *ingestionmodels.IngestionTask) (*ingestionmodels.IngestionTask, error) {
	task.UUID = ulid.NewString()
	task.CreatedAt = time.Now()
	task.IsActive = true
	task.Version = 1
	task.Status = ingestionmodels.IngestionStatusQueued

	row := r.queryRow(ctx, `
		INSERT INTO ingestion_tasks (
			uuid, tenant_id, farm_id, farm_uuid, provider,
			scene_id, status, s3_bucket, s3_key,
			cloud_cover_percent, resolution_meters, bands,
			bbox, file_size_bytes, checksum_sha256, error_message,
			retry_count, acquisition_date, is_active, version,
			created_by, created_at
		) VALUES (
			$1, $2, $3, $4, $5,
			$6, 'QUEUED', $7, $8,
			$9, $10, $11,
			ST_GeomFromGeoJSON($12), $13, $14, $15,
			0, $16, TRUE, 1,
			$17, NOW()
		)
		RETURNING id, uuid, tenant_id, farm_id, farm_uuid, provider,
			scene_id, status, s3_bucket, s3_key,
			cloud_cover_percent, resolution_meters, bands,
			file_size_bytes, checksum_sha256, error_message,
			retry_count, acquisition_date, completed_at,
			is_active, version, created_by, created_at,
			updated_by, updated_at, deleted_by, deleted_at`,
		task.UUID, task.TenantID, task.FarmID, task.FarmUUID, task.Provider,
		task.SceneID, task.S3Bucket, task.S3Key,
		task.CloudCoverPercent, task.ResolutionMeters, pq.Array(task.Bands),
		task.BboxGeoJSON, task.FileSizeBytes, task.ChecksumSHA256, task.ErrorMessage,
		task.AcquisitionDate,
		task.CreatedBy,
	)

	result := &ingestionmodels.IngestionTask{}
	if err := scanIngestionTask(row, result); err != nil {
		r.log.Errorw("msg", "failed to create ingestion task", "error", err)
		return nil, errors.InternalServer("INGESTION_CREATE_FAILED", fmt.Sprintf("failed to create ingestion task: %v", err))
	}

	r.log.Infow("msg", "ingestion task created", "uuid", result.UUID, "tenant_id", result.TenantID)
	return result, nil
}

func (r *ingestionRepository) GetIngestionTaskByUUID(ctx context.Context, uuid, tenantID string) (*ingestionmodels.IngestionTask, error) {
	row := r.queryRow(ctx, `
		SELECT id, uuid, tenant_id, farm_id, farm_uuid, provider,
			scene_id, status, s3_bucket, s3_key,
			cloud_cover_percent, resolution_meters, bands,
			file_size_bytes, checksum_sha256, error_message,
			retry_count, acquisition_date, completed_at,
			is_active, version, created_by, created_at,
			updated_by, updated_at, deleted_by, deleted_at
		FROM ingestion_tasks
		WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL`,
		uuid, tenantID,
	)

	task := &ingestionmodels.IngestionTask{}
	if err := scanIngestionTask(row, task); err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("INGESTION_TASK_NOT_FOUND", fmt.Sprintf("ingestion task not found: %s", uuid))
		}
		r.log.Errorw("msg", "failed to get ingestion task", "uuid", uuid, "error", err)
		return nil, errors.InternalServer("INGESTION_GET_FAILED", fmt.Sprintf("failed to get ingestion task: %v", err))
	}

	return task, nil
}

func (r *ingestionRepository) ListIngestionTasks(ctx context.Context, params ingestionmodels.ListIngestionTasksParams) ([]ingestionmodels.IngestionTask, int32, error) {
	// Count total matching records
	var totalCount int32
	countRow := r.queryRow(ctx, `
		SELECT COUNT(*) FROM ingestion_tasks
		WHERE tenant_id = $1
			AND is_active = TRUE
			AND deleted_at IS NULL
			AND ($2::VARCHAR IS NULL OR farm_uuid = $2)
			AND ($3::VARCHAR IS NULL OR provider = $3::satellite_provider)
			AND ($4::VARCHAR IS NULL OR status = $4::ingestion_status)`,
		params.TenantID,
		nullableString(params.FarmUUID),
		nullableProviderString(params.Provider),
		nullableStatusString(params.Status),
	)
	if err := countRow.Scan(&totalCount); err != nil {
		r.log.Errorw("msg", "failed to count ingestion tasks", "error", err)
		return nil, 0, errors.InternalServer("INGESTION_COUNT_FAILED", fmt.Sprintf("failed to count ingestion tasks: %v", err))
	}

	// Fetch the page
	rows, err := r.query(ctx, `
		SELECT id, uuid, tenant_id, farm_id, farm_uuid, provider,
			scene_id, status, s3_bucket, s3_key,
			cloud_cover_percent, resolution_meters, bands,
			file_size_bytes, checksum_sha256, error_message,
			retry_count, acquisition_date, completed_at,
			is_active, version, created_by, created_at,
			updated_by, updated_at, deleted_by, deleted_at
		FROM ingestion_tasks
		WHERE tenant_id = $1
			AND is_active = TRUE
			AND deleted_at IS NULL
			AND ($2::VARCHAR IS NULL OR farm_uuid = $2)
			AND ($3::VARCHAR IS NULL OR provider = $3::satellite_provider)
			AND ($4::VARCHAR IS NULL OR status = $4::ingestion_status)
		ORDER BY created_at DESC
		LIMIT $5 OFFSET $6`,
		params.TenantID,
		nullableString(params.FarmUUID),
		nullableProviderString(params.Provider),
		nullableStatusString(params.Status),
		params.PageSize,
		params.Offset,
	)
	if err != nil {
		r.log.Errorw("msg", "failed to list ingestion tasks", "error", err)
		return nil, 0, errors.InternalServer("INGESTION_LIST_FAILED", fmt.Sprintf("failed to list ingestion tasks: %v", err))
	}
	defer rows.Close()

	tasks := make([]ingestionmodels.IngestionTask, 0)
	for rows.Next() {
		var task ingestionmodels.IngestionTask
		if err := scanIngestionTaskFromRows(rows, &task); err != nil {
			r.log.Errorw("msg", "failed to scan ingestion task row", "error", err)
			return nil, 0, errors.InternalServer("INGESTION_SCAN_FAILED", fmt.Sprintf("failed to scan ingestion task: %v", err))
		}
		tasks = append(tasks, task)
	}
	if err := rows.Err(); err != nil {
		return nil, 0, errors.InternalServer("INGESTION_ROWS_ERROR", fmt.Sprintf("row iteration error: %v", err))
	}

	return tasks, totalCount, nil
}

func (r *ingestionRepository) UpdateIngestionStatus(ctx context.Context, task *ingestionmodels.IngestionTask) (*ingestionmodels.IngestionTask, error) {
	row := r.queryRow(ctx, `
		UPDATE ingestion_tasks SET
			status = $3::ingestion_status,
			s3_bucket = COALESCE($4, s3_bucket),
			s3_key = COALESCE($5, s3_key),
			file_size_bytes = COALESCE($6, file_size_bytes),
			checksum_sha256 = COALESCE($7, checksum_sha256),
			error_message = COALESCE($8, error_message),
			retry_count = COALESCE($9, retry_count),
			completed_at = COALESCE($10, completed_at),
			version = version + 1,
			updated_by = $11,
			updated_at = NOW()
		WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
		RETURNING id, uuid, tenant_id, farm_id, farm_uuid, provider,
			scene_id, status, s3_bucket, s3_key,
			cloud_cover_percent, resolution_meters, bands,
			file_size_bytes, checksum_sha256, error_message,
			retry_count, acquisition_date, completed_at,
			is_active, version, created_by, created_at,
			updated_by, updated_at, deleted_by, deleted_at`,
		task.UUID, task.TenantID, task.Status,
		task.S3Bucket, task.S3Key,
		nilIfZeroInt64(task.FileSizeBytes), task.ChecksumSHA256,
		task.ErrorMessage, nilIfZeroInt32(task.RetryCount),
		task.CompletedAt,
		task.UpdatedBy,
	)

	result := &ingestionmodels.IngestionTask{}
	if err := scanIngestionTask(row, result); err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("INGESTION_TASK_NOT_FOUND", fmt.Sprintf("ingestion task not found: %s", task.UUID))
		}
		r.log.Errorw("msg", "failed to update ingestion status", "uuid", task.UUID, "error", err)
		return nil, errors.InternalServer("INGESTION_UPDATE_FAILED", fmt.Sprintf("failed to update ingestion task: %v", err))
	}

	r.log.Infow("msg", "ingestion task status updated", "uuid", result.UUID, "status", result.Status, "version", result.Version)
	return result, nil
}

func (r *ingestionRepository) CancelIngestionTask(ctx context.Context, uuid, tenantID, cancelledBy string) (*ingestionmodels.IngestionTask, error) {
	row := r.queryRow(ctx, `
		UPDATE ingestion_tasks SET
			status = 'FAILED',
			error_message = 'Cancelled by user',
			version = version + 1,
			updated_by = $3,
			updated_at = NOW()
		WHERE uuid = $1 AND tenant_id = $2
			AND status IN ('QUEUED', 'DOWNLOADING')
			AND is_active = TRUE AND deleted_at IS NULL
		RETURNING id, uuid, tenant_id, farm_id, farm_uuid, provider,
			scene_id, status, s3_bucket, s3_key,
			cloud_cover_percent, resolution_meters, bands,
			file_size_bytes, checksum_sha256, error_message,
			retry_count, acquisition_date, completed_at,
			is_active, version, created_by, created_at,
			updated_by, updated_at, deleted_by, deleted_at`,
		uuid, tenantID, cancelledBy,
	)

	result := &ingestionmodels.IngestionTask{}
	if err := scanIngestionTask(row, result); err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("INGESTION_TASK_NOT_CANCELLABLE", fmt.Sprintf("ingestion task not found or not in cancellable state: %s", uuid))
		}
		r.log.Errorw("msg", "failed to cancel ingestion task", "uuid", uuid, "error", err)
		return nil, errors.InternalServer("INGESTION_CANCEL_FAILED", fmt.Sprintf("failed to cancel ingestion task: %v", err))
	}

	r.log.Infow("msg", "ingestion task cancelled", "uuid", result.UUID)
	return result, nil
}

func (r *ingestionRepository) GetIngestionStats(ctx context.Context, tenantID string, farmUUID *string, provider *ingestionmodels.SatelliteProvider) (*ingestionmodels.IngestionStats, error) {
	row := r.queryRow(ctx, `
		SELECT
			COUNT(*) AS total_tasks,
			COUNT(*) FILTER (WHERE status = 'STORED') AS completed_tasks,
			COUNT(*) FILTER (WHERE status = 'FAILED') AS failed_tasks,
			COUNT(*) FILTER (WHERE status IN ('QUEUED', 'DOWNLOADING', 'VALIDATING')) AS pending_tasks,
			COALESCE(SUM(file_size_bytes) FILTER (WHERE status = 'STORED'), 0) AS total_bytes_stored
		FROM ingestion_tasks
		WHERE tenant_id = $1
			AND is_active = TRUE
			AND deleted_at IS NULL
			AND ($2::VARCHAR IS NULL OR farm_uuid = $2)
			AND ($3::VARCHAR IS NULL OR provider = $3::satellite_provider)`,
		tenantID,
		nullableString(farmUUID),
		nullableProviderString(provider),
	)

	stats := &ingestionmodels.IngestionStats{}
	if err := row.Scan(
		&stats.TotalTasks,
		&stats.CompletedTasks,
		&stats.FailedTasks,
		&stats.PendingTasks,
		&stats.TotalBytesStored,
	); err != nil {
		r.log.Errorw("msg", "failed to get ingestion stats", "error", err)
		return nil, errors.InternalServer("INGESTION_STATS_FAILED", fmt.Sprintf("failed to get ingestion stats: %v", err))
	}

	return stats, nil
}

// ---------- Scan helpers ----------

func scanIngestionTask(row pgx.Row, t *ingestionmodels.IngestionTask) error {
	return row.Scan(
		&t.ID, &t.UUID, &t.TenantID, &t.FarmID, &t.FarmUUID, &t.Provider,
		&t.SceneID, &t.Status, &t.S3Bucket, &t.S3Key,
		&t.CloudCoverPercent, &t.ResolutionMeters, pq.Array(&t.Bands),
		&t.FileSizeBytes, &t.ChecksumSHA256, &t.ErrorMessage,
		&t.RetryCount, &t.AcquisitionDate, &t.CompletedAt,
		&t.IsActive, &t.Version, &t.CreatedBy, &t.CreatedAt,
		&t.UpdatedBy, &t.UpdatedAt, &t.DeletedBy, &t.DeletedAt,
	)
}

func scanIngestionTaskFromRows(rows pgx.Rows, t *ingestionmodels.IngestionTask) error {
	return rows.Scan(
		&t.ID, &t.UUID, &t.TenantID, &t.FarmID, &t.FarmUUID, &t.Provider,
		&t.SceneID, &t.Status, &t.S3Bucket, &t.S3Key,
		&t.CloudCoverPercent, &t.ResolutionMeters, pq.Array(&t.Bands),
		&t.FileSizeBytes, &t.ChecksumSHA256, &t.ErrorMessage,
		&t.RetryCount, &t.AcquisitionDate, &t.CompletedAt,
		&t.IsActive, &t.Version, &t.CreatedBy, &t.CreatedAt,
		&t.UpdatedBy, &t.UpdatedAt, &t.DeletedBy, &t.DeletedAt,
	)
}

// ---------- Nil helpers ----------

func nullableString(v *string) *string {
	if v == nil || *v == "" {
		return nil
	}
	return v
}

func nullableProviderString(v *ingestionmodels.SatelliteProvider) *string {
	if v == nil || *v == "" {
		return nil
	}
	s := string(*v)
	return &s
}

func nullableStatusString(v *ingestionmodels.IngestionStatus) *string {
	if v == nil || *v == "" {
		return nil
	}
	s := string(*v)
	return &s
}

func nilIfZeroInt64(v int64) *int64 {
	if v == 0 {
		return nil
	}
	return &v
}

func nilIfZeroInt32(v int32) *int32 {
	if v == 0 {
		return nil
	}
	return &v
}
