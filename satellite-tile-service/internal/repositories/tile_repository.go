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

	tilemodels "p9e.in/samavaya/agriculture/satellite-tile-service/internal/models"
)

// TileRepository defines the interface for tile persistence operations.
type TileRepository interface {
	CreateTileset(ctx context.Context, tileset *tilemodels.Tileset) (*tilemodels.Tileset, error)
	GetTilesetByUUID(ctx context.Context, uuid, tenantID string) (*tilemodels.Tileset, error)
	ListTilesets(ctx context.Context, params tilemodels.ListTilesetsParams) ([]tilemodels.Tileset, int32, error)
	UpdateTilesetStatus(ctx context.Context, uuid, tenantID string, status tilemodels.TilesetStatus, errorMessage *string, updatedBy string) (*tilemodels.Tileset, error)
	CompleteTileset(ctx context.Context, uuid, tenantID string, totalTiles int64, s3Prefix string, updatedBy string) (*tilemodels.Tileset, error)
	FailTileset(ctx context.Context, uuid, tenantID, errorMessage, updatedBy string) (*tilemodels.Tileset, error)
	DeleteTileset(ctx context.Context, uuid, tenantID, deletedBy string) error
	CheckTilesetExists(ctx context.Context, uuid, tenantID string) (bool, error)
	GetTilesetByProcessingJobAndLayer(ctx context.Context, processingJobID, tenantID string, layer tilemodels.TileLayer) (*tilemodels.Tileset, error)

	WithTx(tx pgx.Tx) TileRepository
}

// tileRepository is the concrete implementation of TileRepository.
type tileRepository struct {
	d   deps.ServiceDeps
	log *p9log.Helper
	tx  pgx.Tx
}

// NewTileRepository creates a new TileRepository.
func NewTileRepository(d deps.ServiceDeps) TileRepository {
	return &tileRepository{
		d:   d,
		log: p9log.NewHelper(p9log.With(d.Log, "component", "TileRepository")),
	}
}

// WithTx returns a copy of the repository that uses the provided transaction.
func (r *tileRepository) WithTx(tx pgx.Tx) TileRepository {
	return &tileRepository{
		d:   r.d,
		log: r.log,
		tx:  tx,
	}
}

// queryRow is a helper to use the tx or pool for single-row queries.
func (r *tileRepository) queryRow(ctx context.Context, sql string, args ...any) pgx.Row {
	if r.tx != nil {
		return r.tx.QueryRow(ctx, sql, args...)
	}
	return r.d.Pool.QueryRow(ctx, sql, args...)
}

// query is a helper to use the tx or pool for multi-row queries.
func (r *tileRepository) query(ctx context.Context, sql string, args ...any) (pgx.Rows, error) {
	if r.tx != nil {
		return r.tx.Query(ctx, sql, args...)
	}
	return r.d.Pool.Query(ctx, sql, args...)
}

// exec is a helper to use the tx or pool for exec statements.
func (r *tileRepository) exec(ctx context.Context, sql string, args ...any) error {
	var err error
	if r.tx != nil {
		_, err = r.tx.Exec(ctx, sql, args...)
	} else {
		_, err = r.d.Pool.Exec(ctx, sql, args...)
	}
	return err
}

// ---------- Tileset CRUD ----------

func (r *tileRepository) CreateTileset(ctx context.Context, tileset *tilemodels.Tileset) (*tilemodels.Tileset, error) {
	tileset.UUID = ulid.NewString()
	tileset.CreatedAt = time.Now()
	tileset.IsActive = true
	tileset.Status = tilemodels.TilesetStatusQueued

	row := r.queryRow(ctx, `
		INSERT INTO tilesets (
			uuid, tenant_id, farm_id, processing_job_id, layer,
			format, status, min_zoom, max_zoom, s3_prefix,
			total_tiles, bbox_geojson, acquisition_date,
			is_active, created_by, created_at
		) VALUES (
			$1, $2, $3, $4, $5,
			$6, 'QUEUED', $7, $8, $9,
			0, $10, $11,
			TRUE, $12, NOW()
		)
		RETURNING id, uuid, tenant_id, farm_id, processing_job_id, layer,
			format, status, min_zoom, max_zoom, s3_prefix,
			total_tiles, bbox_geojson, error_message, acquisition_date, completed_at,
			is_active, created_by, created_at, updated_by, updated_at, deleted_by, deleted_at`,
		tileset.UUID, tileset.TenantID, tileset.FarmID, tileset.ProcessingJobID, tileset.Layer,
		tileset.Format, tileset.MinZoom, tileset.MaxZoom, tileset.S3Prefix,
		tileset.BboxGeoJSON, tileset.AcquisitionDate,
		tileset.CreatedBy,
	)

	result := &tilemodels.Tileset{}
	if err := scanTileset(row, result); err != nil {
		r.log.Errorw("msg", "failed to create tileset", "error", err)
		return nil, errors.InternalServer("TILESET_CREATE_FAILED", fmt.Sprintf("failed to create tileset: %v", err))
	}

	r.log.Infow("msg", "tileset created", "uuid", result.UUID, "tenant_id", result.TenantID)
	return result, nil
}

func (r *tileRepository) GetTilesetByUUID(ctx context.Context, uuid, tenantID string) (*tilemodels.Tileset, error) {
	row := r.queryRow(ctx, `
		SELECT id, uuid, tenant_id, farm_id, processing_job_id, layer,
			format, status, min_zoom, max_zoom, s3_prefix,
			total_tiles, bbox_geojson, error_message, acquisition_date, completed_at,
			is_active, created_by, created_at, updated_by, updated_at, deleted_by, deleted_at
		FROM tilesets
		WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL`,
		uuid, tenantID,
	)

	tileset := &tilemodels.Tileset{}
	if err := scanTileset(row, tileset); err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("TILESET_NOT_FOUND", fmt.Sprintf("tileset not found: %s", uuid))
		}
		r.log.Errorw("msg", "failed to get tileset", "uuid", uuid, "error", err)
		return nil, errors.InternalServer("TILESET_GET_FAILED", fmt.Sprintf("failed to get tileset: %v", err))
	}

	return tileset, nil
}

func (r *tileRepository) ListTilesets(ctx context.Context, params tilemodels.ListTilesetsParams) ([]tilemodels.Tileset, int32, error) {
	// Count total matching records
	var totalCount int32
	countRow := r.queryRow(ctx, `
		SELECT COUNT(*) FROM tilesets
		WHERE tenant_id = $1
			AND is_active = TRUE
			AND deleted_at IS NULL
			AND ($2::VARCHAR IS NULL OR farm_id = $2)
			AND ($3::VARCHAR IS NULL OR layer = $3::tile_layer)
			AND ($4::VARCHAR IS NULL OR status = $4::tileset_status)`,
		params.TenantID,
		params.FarmID,
		nullableString(params.Layer),
		nullableString(params.Status),
	)
	if err := countRow.Scan(&totalCount); err != nil {
		r.log.Errorw("msg", "failed to count tilesets", "error", err)
		return nil, 0, errors.InternalServer("TILESET_COUNT_FAILED", fmt.Sprintf("failed to count tilesets: %v", err))
	}

	// Fetch the page
	rows, err := r.query(ctx, `
		SELECT id, uuid, tenant_id, farm_id, processing_job_id, layer,
			format, status, min_zoom, max_zoom, s3_prefix,
			total_tiles, bbox_geojson, error_message, acquisition_date, completed_at,
			is_active, created_by, created_at, updated_by, updated_at, deleted_by, deleted_at
		FROM tilesets
		WHERE tenant_id = $1
			AND is_active = TRUE
			AND deleted_at IS NULL
			AND ($2::VARCHAR IS NULL OR farm_id = $2)
			AND ($3::VARCHAR IS NULL OR layer = $3::tile_layer)
			AND ($4::VARCHAR IS NULL OR status = $4::tileset_status)
		ORDER BY created_at DESC
		LIMIT $5 OFFSET $6`,
		params.TenantID,
		params.FarmID,
		nullableString(params.Layer),
		nullableString(params.Status),
		params.PageSize,
		params.Offset,
	)
	if err != nil {
		r.log.Errorw("msg", "failed to list tilesets", "error", err)
		return nil, 0, errors.InternalServer("TILESET_LIST_FAILED", fmt.Sprintf("failed to list tilesets: %v", err))
	}
	defer rows.Close()

	tilesets := make([]tilemodels.Tileset, 0)
	for rows.Next() {
		var tileset tilemodels.Tileset
		if err := scanTilesetFromRows(rows, &tileset); err != nil {
			r.log.Errorw("msg", "failed to scan tileset row", "error", err)
			return nil, 0, errors.InternalServer("TILESET_SCAN_FAILED", fmt.Sprintf("failed to scan tileset: %v", err))
		}
		tilesets = append(tilesets, tileset)
	}
	if err := rows.Err(); err != nil {
		return nil, 0, errors.InternalServer("TILESET_ROWS_ERROR", fmt.Sprintf("row iteration error: %v", err))
	}

	return tilesets, totalCount, nil
}

func (r *tileRepository) UpdateTilesetStatus(ctx context.Context, uuid, tenantID string, status tilemodels.TilesetStatus, errorMessage *string, updatedBy string) (*tilemodels.Tileset, error) {
	row := r.queryRow(ctx, `
		UPDATE tilesets SET
			status = $3,
			error_message = $4,
			updated_by = $5,
			updated_at = NOW()
		WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
		RETURNING id, uuid, tenant_id, farm_id, processing_job_id, layer,
			format, status, min_zoom, max_zoom, s3_prefix,
			total_tiles, bbox_geojson, error_message, acquisition_date, completed_at,
			is_active, created_by, created_at, updated_by, updated_at, deleted_by, deleted_at`,
		uuid, tenantID, status, errorMessage, updatedBy,
	)

	result := &tilemodels.Tileset{}
	if err := scanTileset(row, result); err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("TILESET_NOT_FOUND", fmt.Sprintf("tileset not found: %s", uuid))
		}
		r.log.Errorw("msg", "failed to update tileset status", "uuid", uuid, "error", err)
		return nil, errors.InternalServer("TILESET_UPDATE_FAILED", fmt.Sprintf("failed to update tileset status: %v", err))
	}

	return result, nil
}

func (r *tileRepository) CompleteTileset(ctx context.Context, uuid, tenantID string, totalTiles int64, s3Prefix string, updatedBy string) (*tilemodels.Tileset, error) {
	row := r.queryRow(ctx, `
		UPDATE tilesets SET
			status = 'COMPLETED',
			total_tiles = $3,
			s3_prefix = $4,
			completed_at = NOW(),
			updated_by = $5,
			updated_at = NOW()
		WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
		RETURNING id, uuid, tenant_id, farm_id, processing_job_id, layer,
			format, status, min_zoom, max_zoom, s3_prefix,
			total_tiles, bbox_geojson, error_message, acquisition_date, completed_at,
			is_active, created_by, created_at, updated_by, updated_at, deleted_by, deleted_at`,
		uuid, tenantID, totalTiles, s3Prefix, updatedBy,
	)

	result := &tilemodels.Tileset{}
	if err := scanTileset(row, result); err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("TILESET_NOT_FOUND", fmt.Sprintf("tileset not found: %s", uuid))
		}
		r.log.Errorw("msg", "failed to complete tileset", "uuid", uuid, "error", err)
		return nil, errors.InternalServer("TILESET_COMPLETE_FAILED", fmt.Sprintf("failed to complete tileset: %v", err))
	}

	r.log.Infow("msg", "tileset completed", "uuid", result.UUID, "total_tiles", totalTiles)
	return result, nil
}

func (r *tileRepository) FailTileset(ctx context.Context, uuid, tenantID, errorMessage, updatedBy string) (*tilemodels.Tileset, error) {
	row := r.queryRow(ctx, `
		UPDATE tilesets SET
			status = 'FAILED',
			error_message = $3,
			updated_by = $4,
			updated_at = NOW()
		WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
		RETURNING id, uuid, tenant_id, farm_id, processing_job_id, layer,
			format, status, min_zoom, max_zoom, s3_prefix,
			total_tiles, bbox_geojson, error_message, acquisition_date, completed_at,
			is_active, created_by, created_at, updated_by, updated_at, deleted_by, deleted_at`,
		uuid, tenantID, errorMessage, updatedBy,
	)

	result := &tilemodels.Tileset{}
	if err := scanTileset(row, result); err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("TILESET_NOT_FOUND", fmt.Sprintf("tileset not found: %s", uuid))
		}
		r.log.Errorw("msg", "failed to fail tileset", "uuid", uuid, "error", err)
		return nil, errors.InternalServer("TILESET_FAIL_FAILED", fmt.Sprintf("failed to fail tileset: %v", err))
	}

	r.log.Infow("msg", "tileset marked as failed", "uuid", result.UUID, "error_message", errorMessage)
	return result, nil
}

func (r *tileRepository) DeleteTileset(ctx context.Context, uuid, tenantID, deletedBy string) error {
	err := r.exec(ctx, `
		UPDATE tilesets SET
			is_active = FALSE,
			deleted_by = $3,
			deleted_at = NOW()
		WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL`,
		uuid, tenantID, deletedBy,
	)
	if err != nil {
		r.log.Errorw("msg", "failed to delete tileset", "uuid", uuid, "error", err)
		return errors.InternalServer("TILESET_DELETE_FAILED", fmt.Sprintf("failed to delete tileset: %v", err))
	}

	r.log.Infow("msg", "tileset deleted", "uuid", uuid)
	return nil
}

func (r *tileRepository) CheckTilesetExists(ctx context.Context, uuid, tenantID string) (bool, error) {
	var exists bool
	row := r.queryRow(ctx, `
		SELECT EXISTS(
			SELECT 1 FROM tilesets
			WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
		)`,
		uuid, tenantID,
	)
	if err := row.Scan(&exists); err != nil {
		return false, errors.InternalServer("TILESET_CHECK_FAILED", fmt.Sprintf("failed to check tileset exists: %v", err))
	}
	return exists, nil
}

func (r *tileRepository) GetTilesetByProcessingJobAndLayer(ctx context.Context, processingJobID, tenantID string, layer tilemodels.TileLayer) (*tilemodels.Tileset, error) {
	row := r.queryRow(ctx, `
		SELECT id, uuid, tenant_id, farm_id, processing_job_id, layer,
			format, status, min_zoom, max_zoom, s3_prefix,
			total_tiles, bbox_geojson, error_message, acquisition_date, completed_at,
			is_active, created_by, created_at, updated_by, updated_at, deleted_by, deleted_at
		FROM tilesets
		WHERE processing_job_id = $1 AND tenant_id = $2 AND layer = $3
			AND is_active = TRUE AND deleted_at IS NULL`,
		processingJobID, tenantID, layer,
	)

	tileset := &tilemodels.Tileset{}
	if err := scanTileset(row, tileset); err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("TILESET_NOT_FOUND", fmt.Sprintf("tileset not found for job %s layer %s", processingJobID, layer))
		}
		r.log.Errorw("msg", "failed to get tileset by processing job and layer", "error", err)
		return nil, errors.InternalServer("TILESET_GET_FAILED", fmt.Sprintf("failed to get tileset: %v", err))
	}

	return tileset, nil
}

// ---------- Scan helpers ----------

func scanTileset(row pgx.Row, t *tilemodels.Tileset) error {
	return row.Scan(
		&t.ID, &t.UUID, &t.TenantID, &t.FarmID, &t.ProcessingJobID, &t.Layer,
		&t.Format, &t.Status, &t.MinZoom, &t.MaxZoom, &t.S3Prefix,
		&t.TotalTiles, &t.BboxGeoJSON, &t.ErrorMessage, &t.AcquisitionDate, &t.CompletedAt,
		&t.IsActive, &t.CreatedBy, &t.CreatedAt, &t.UpdatedBy, &t.UpdatedAt, &t.DeletedBy, &t.DeletedAt,
	)
}

func scanTilesetFromRows(rows pgx.Rows, t *tilemodels.Tileset) error {
	return rows.Scan(
		&t.ID, &t.UUID, &t.TenantID, &t.FarmID, &t.ProcessingJobID, &t.Layer,
		&t.Format, &t.Status, &t.MinZoom, &t.MaxZoom, &t.S3Prefix,
		&t.TotalTiles, &t.BboxGeoJSON, &t.ErrorMessage, &t.AcquisitionDate, &t.CompletedAt,
		&t.IsActive, &t.CreatedBy, &t.CreatedAt, &t.UpdatedBy, &t.UpdatedAt, &t.DeletedBy, &t.DeletedAt,
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
