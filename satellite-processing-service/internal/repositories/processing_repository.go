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

	procmodels "p9e.in/samavaya/agriculture/satellite-processing-service/internal/models"
)

// ProcessingRepository defines the interface for processing job persistence operations.
type ProcessingRepository interface {
	CreateProcessingJob(ctx context.Context, job *procmodels.ProcessingJob) (*procmodels.ProcessingJob, error)
	GetProcessingJobByUUID(ctx context.Context, uuid, tenantID string) (*procmodels.ProcessingJob, error)
	ListProcessingJobs(ctx context.Context, params procmodels.ListProcessingJobsParams) ([]procmodels.ProcessingJob, int32, error)
	UpdateProcessingStatus(ctx context.Context, job *procmodels.ProcessingJob) (*procmodels.ProcessingJob, error)
	CancelProcessingJob(ctx context.Context, uuid, tenantID, cancelledBy string) error
	GetProcessingStats(ctx context.Context, tenantID string, farmUUID *string) (*procmodels.ProcessingStats, error)

	// Transaction support: accept a pgx.Tx for use within a UoW
	WithTx(tx pgx.Tx) ProcessingRepository
}

// processingRepository is the concrete implementation of ProcessingRepository.
type processingRepository struct {
	d   deps.ServiceDeps
	log *p9log.Helper
	tx  pgx.Tx
}

// NewProcessingRepository creates a new ProcessingRepository.
func NewProcessingRepository(d deps.ServiceDeps) ProcessingRepository {
	return &processingRepository{
		d:   d,
		log: p9log.NewHelper(p9log.With(d.Log, "component", "ProcessingRepository")),
	}
}

// WithTx returns a copy of the repository that uses the provided transaction.
func (r *processingRepository) WithTx(tx pgx.Tx) ProcessingRepository {
	return &processingRepository{
		d:   r.d,
		log: r.log,
		tx:  tx,
	}
}

// queryRow is a helper to use the tx or pool for single-row queries.
func (r *processingRepository) queryRow(ctx context.Context, sql string, args ...any) pgx.Row {
	if r.tx != nil {
		return r.tx.QueryRow(ctx, sql, args...)
	}
	return r.d.Pool.QueryRow(ctx, sql, args...)
}

// query is a helper to use the tx or pool for multi-row queries.
func (r *processingRepository) query(ctx context.Context, sql string, args ...any) (pgx.Rows, error) {
	if r.tx != nil {
		return r.tx.Query(ctx, sql, args...)
	}
	return r.d.Pool.Query(ctx, sql, args...)
}

// exec is a helper to use the tx or pool for exec statements.
func (r *processingRepository) exec(ctx context.Context, sql string, args ...any) error {
	var err error
	if r.tx != nil {
		_, err = r.tx.Exec(ctx, sql, args...)
	} else {
		_, err = r.d.Pool.Exec(ctx, sql, args...)
	}
	return err
}

// ---------- Processing Job CRUD ----------

func (r *processingRepository) CreateProcessingJob(ctx context.Context, job *procmodels.ProcessingJob) (*procmodels.ProcessingJob, error) {
	job.UUID = ulid.NewString()
	job.CreatedAt = time.Now()
	job.IsActive = true
	job.Status = procmodels.ProcessingStatusQueued

	row := r.queryRow(ctx, `
		INSERT INTO processing_jobs (
			uuid, tenant_id, ingestion_task_uuid, farm_uuid, status,
			input_level, output_level, algorithm, input_s3_key, output_s3_key,
			cloud_mask_threshold, apply_atmospheric_correction, apply_cloud_masking,
			apply_orthorectification, output_resolution_meters, output_crs,
			is_active, created_by, created_at
		) VALUES (
			$1, $2, $3, $4, $5,
			$6, $7, $8, $9, $10,
			$11, $12, $13,
			$14, $15, $16,
			TRUE, $17, NOW()
		)
		RETURNING id, uuid, tenant_id, ingestion_task_uuid, farm_uuid, status,
			input_level, output_level, algorithm, input_s3_key, output_s3_key,
			cloud_mask_threshold, apply_atmospheric_correction, apply_cloud_masking,
			apply_orthorectification, output_resolution_meters, output_crs,
			error_message, processing_time_seconds, is_active, created_by, created_at,
			updated_by, updated_at, completed_at, deleted_by, deleted_at`,
		job.UUID, job.TenantID, job.IngestionTaskUUID, job.FarmUUID, procmodels.ProcessingStatusQueued,
		job.InputLevel, job.OutputLevel, job.Algorithm, job.InputS3Key, job.OutputS3Key,
		job.CloudMaskThreshold, job.ApplyAtmosphericCorrection, job.ApplyCloudMasking,
		job.ApplyOrthorectification, job.OutputResolutionMeters, job.OutputCRS,
		job.CreatedBy,
	)

	result := &procmodels.ProcessingJob{}
	if err := scanProcessingJob(row, result); err != nil {
		r.log.Errorw("msg", "failed to create processing job", "error", err)
		return nil, errors.InternalServer("JOB_CREATE_FAILED", fmt.Sprintf("failed to create processing job: %v", err))
	}

	r.log.Infow("msg", "processing job created", "uuid", result.UUID, "tenant_id", result.TenantID)
	return result, nil
}

func (r *processingRepository) GetProcessingJobByUUID(ctx context.Context, uuid, tenantID string) (*procmodels.ProcessingJob, error) {
	row := r.queryRow(ctx, `
		SELECT id, uuid, tenant_id, ingestion_task_uuid, farm_uuid, status,
			input_level, output_level, algorithm, input_s3_key, output_s3_key,
			cloud_mask_threshold, apply_atmospheric_correction, apply_cloud_masking,
			apply_orthorectification, output_resolution_meters, output_crs,
			error_message, processing_time_seconds, is_active, created_by, created_at,
			updated_by, updated_at, completed_at, deleted_by, deleted_at
		FROM processing_jobs
		WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL`,
		uuid, tenantID,
	)

	job := &procmodels.ProcessingJob{}
	if err := scanProcessingJob(row, job); err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("JOB_NOT_FOUND", fmt.Sprintf("processing job not found: %s", uuid))
		}
		r.log.Errorw("msg", "failed to get processing job", "uuid", uuid, "error", err)
		return nil, errors.InternalServer("JOB_GET_FAILED", fmt.Sprintf("failed to get processing job: %v", err))
	}

	return job, nil
}

func (r *processingRepository) ListProcessingJobs(ctx context.Context, params procmodels.ListProcessingJobsParams) ([]procmodels.ProcessingJob, int32, error) {
	// Count total matching records
	var totalCount int32
	countRow := r.queryRow(ctx, `
		SELECT COUNT(*) FROM processing_jobs
		WHERE tenant_id = $1
			AND is_active = TRUE
			AND deleted_at IS NULL
			AND ($2::VARCHAR IS NULL OR farm_uuid = $2)
			AND ($3::VARCHAR IS NULL OR status = $3::processing_status)`,
		params.TenantID,
		params.FarmUUID,
		nullableString(params.Status),
	)
	if err := countRow.Scan(&totalCount); err != nil {
		r.log.Errorw("msg", "failed to count processing jobs", "error", err)
		return nil, 0, errors.InternalServer("JOB_COUNT_FAILED", fmt.Sprintf("failed to count processing jobs: %v", err))
	}

	// Fetch the page
	rows, err := r.query(ctx, `
		SELECT id, uuid, tenant_id, ingestion_task_uuid, farm_uuid, status,
			input_level, output_level, algorithm, input_s3_key, output_s3_key,
			cloud_mask_threshold, apply_atmospheric_correction, apply_cloud_masking,
			apply_orthorectification, output_resolution_meters, output_crs,
			error_message, processing_time_seconds, is_active, created_by, created_at,
			updated_by, updated_at, completed_at, deleted_by, deleted_at
		FROM processing_jobs
		WHERE tenant_id = $1
			AND is_active = TRUE
			AND deleted_at IS NULL
			AND ($2::VARCHAR IS NULL OR farm_uuid = $2)
			AND ($3::VARCHAR IS NULL OR status = $3::processing_status)
		ORDER BY created_at DESC
		LIMIT $4 OFFSET $5`,
		params.TenantID,
		params.FarmUUID,
		nullableString(params.Status),
		params.PageSize,
		params.Offset,
	)
	if err != nil {
		r.log.Errorw("msg", "failed to list processing jobs", "error", err)
		return nil, 0, errors.InternalServer("JOB_LIST_FAILED", fmt.Sprintf("failed to list processing jobs: %v", err))
	}
	defer rows.Close()

	jobs := make([]procmodels.ProcessingJob, 0)
	for rows.Next() {
		var job procmodels.ProcessingJob
		if err := scanProcessingJobFromRows(rows, &job); err != nil {
			r.log.Errorw("msg", "failed to scan processing job row", "error", err)
			return nil, 0, errors.InternalServer("JOB_SCAN_FAILED", fmt.Sprintf("failed to scan processing job: %v", err))
		}
		jobs = append(jobs, job)
	}
	if err := rows.Err(); err != nil {
		return nil, 0, errors.InternalServer("JOB_ROWS_ERROR", fmt.Sprintf("row iteration error: %v", err))
	}

	return jobs, totalCount, nil
}

func (r *processingRepository) UpdateProcessingStatus(ctx context.Context, job *procmodels.ProcessingJob) (*procmodels.ProcessingJob, error) {
	row := r.queryRow(ctx, `
		UPDATE processing_jobs SET
			status = $3,
			output_s3_key = COALESCE($4, output_s3_key),
			error_message = COALESCE($5, error_message),
			processing_time_seconds = COALESCE($6, processing_time_seconds),
			completed_at = COALESCE($7, completed_at),
			updated_by = $8,
			updated_at = NOW()
		WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
		RETURNING id, uuid, tenant_id, ingestion_task_uuid, farm_uuid, status,
			input_level, output_level, algorithm, input_s3_key, output_s3_key,
			cloud_mask_threshold, apply_atmospheric_correction, apply_cloud_masking,
			apply_orthorectification, output_resolution_meters, output_crs,
			error_message, processing_time_seconds, is_active, created_by, created_at,
			updated_by, updated_at, completed_at, deleted_by, deleted_at`,
		job.UUID, job.TenantID,
		job.Status, job.OutputS3Key, job.ErrorMessage,
		job.ProcessingTimeSeconds, job.CompletedAt,
		job.UpdatedBy,
	)

	result := &procmodels.ProcessingJob{}
	if err := scanProcessingJob(row, result); err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("JOB_NOT_FOUND", fmt.Sprintf("processing job not found: %s", job.UUID))
		}
		r.log.Errorw("msg", "failed to update processing job status", "uuid", job.UUID, "error", err)
		return nil, errors.InternalServer("JOB_UPDATE_FAILED", fmt.Sprintf("failed to update processing job: %v", err))
	}

	r.log.Infow("msg", "processing job status updated", "uuid", result.UUID, "status", string(result.Status))
	return result, nil
}

func (r *processingRepository) CancelProcessingJob(ctx context.Context, uuid, tenantID, cancelledBy string) error {
	err := r.exec(ctx, `
		UPDATE processing_jobs SET
			status = 'FAILED',
			error_message = 'Cancelled by user',
			updated_by = $3,
			updated_at = NOW()
		WHERE uuid = $1 AND tenant_id = $2
			AND status NOT IN ('COMPLETED', 'FAILED')
			AND is_active = TRUE AND deleted_at IS NULL`,
		uuid, tenantID, cancelledBy,
	)
	if err != nil {
		r.log.Errorw("msg", "failed to cancel processing job", "uuid", uuid, "error", err)
		return errors.InternalServer("JOB_CANCEL_FAILED", fmt.Sprintf("failed to cancel processing job: %v", err))
	}

	r.log.Infow("msg", "processing job cancelled", "uuid", uuid)
	return nil
}

func (r *processingRepository) GetProcessingStats(ctx context.Context, tenantID string, farmUUID *string) (*procmodels.ProcessingStats, error) {
	row := r.queryRow(ctx, `
		SELECT
			COUNT(*) AS total_jobs,
			COUNT(*) FILTER (WHERE status = 'COMPLETED') AS completed_jobs,
			COUNT(*) FILTER (WHERE status = 'FAILED') AS failed_jobs,
			COUNT(*) FILTER (WHERE status NOT IN ('COMPLETED', 'FAILED')) AS pending_jobs,
			COALESCE(AVG(processing_time_seconds) FILTER (WHERE status = 'COMPLETED'), 0) AS avg_processing_time_seconds
		FROM processing_jobs
		WHERE tenant_id = $1
			AND is_active = TRUE
			AND deleted_at IS NULL
			AND ($2::VARCHAR IS NULL OR farm_uuid = $2)`,
		tenantID, farmUUID,
	)

	stats := &procmodels.ProcessingStats{}
	if err := row.Scan(
		&stats.TotalJobs, &stats.CompletedJobs, &stats.FailedJobs,
		&stats.PendingJobs, &stats.AvgProcessingTimeSeconds,
	); err != nil {
		r.log.Errorw("msg", "failed to get processing stats", "error", err)
		return nil, errors.InternalServer("STATS_FAILED", fmt.Sprintf("failed to get processing stats: %v", err))
	}

	return stats, nil
}

// ---------- Scan helpers ----------

func scanProcessingJob(row pgx.Row, j *procmodels.ProcessingJob) error {
	return row.Scan(
		&j.ID, &j.UUID, &j.TenantID, &j.IngestionTaskUUID, &j.FarmUUID, &j.Status,
		&j.InputLevel, &j.OutputLevel, &j.Algorithm, &j.InputS3Key, &j.OutputS3Key,
		&j.CloudMaskThreshold, &j.ApplyAtmosphericCorrection, &j.ApplyCloudMasking,
		&j.ApplyOrthorectification, &j.OutputResolutionMeters, &j.OutputCRS,
		&j.ErrorMessage, &j.ProcessingTimeSeconds, &j.IsActive, &j.CreatedBy, &j.CreatedAt,
		&j.UpdatedBy, &j.UpdatedAt, &j.CompletedAt, &j.DeletedBy, &j.DeletedAt,
	)
}

func scanProcessingJobFromRows(rows pgx.Rows, j *procmodels.ProcessingJob) error {
	return rows.Scan(
		&j.ID, &j.UUID, &j.TenantID, &j.IngestionTaskUUID, &j.FarmUUID, &j.Status,
		&j.InputLevel, &j.OutputLevel, &j.Algorithm, &j.InputS3Key, &j.OutputS3Key,
		&j.CloudMaskThreshold, &j.ApplyAtmosphericCorrection, &j.ApplyCloudMasking,
		&j.ApplyOrthorectification, &j.OutputResolutionMeters, &j.OutputCRS,
		&j.ErrorMessage, &j.ProcessingTimeSeconds, &j.IsActive, &j.CreatedBy, &j.CreatedAt,
		&j.UpdatedBy, &j.UpdatedAt, &j.CompletedAt, &j.DeletedBy, &j.DeletedAt,
	)
}

// ---------- Nil helpers ----------

func nullableString[T ~string](v *T) *string {
	if v == nil || *v == "" {
		return nil
	}
	s := string(*v)
	return &s
}
