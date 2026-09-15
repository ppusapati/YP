// Package postgres implements the outbound.LabRepository port using pgx.
package postgres

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"strings"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	p9errors "p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"

	"p9e.in/samavaya/agriculture/soil-lab-service/internal/domain"
	"p9e.in/samavaya/agriculture/soil-lab-service/internal/ports/outbound"
)

const labColumns = `id, tenant_id, name, accreditation, contact_email, column_aliases, created_at`

const reportColumns = `
	id, tenant_id, lab_id, lab_name, format, filename, storage_url,
	content_sha256, status, row_count, applied_count, blocked_count,
	rows, uploaded_at, applied_at, uploaded_by, rejection_reason`

type labRepository struct {
	pool *pgxpool.Pool
	log  *p9log.Helper
}

// NewLabRepository creates a postgres-backed LabRepository.
func NewLabRepository(pool *pgxpool.Pool, log p9log.Logger) outbound.LabRepository {
	return &labRepository{
		pool: pool,
		log:  p9log.NewHelper(p9log.With(log, "component", "SoilLabPostgresRepository")),
	}
}

func scanLab(row pgx.Row) (*domain.Lab, error) {
	var lab domain.Lab
	var aliases []byte
	if err := row.Scan(
		&lab.ID, &lab.TenantID, &lab.Name, &lab.Accreditation,
		&lab.ContactEmail, &aliases, &lab.CreatedAt,
	); err != nil {
		return nil, err
	}
	if len(aliases) > 0 {
		_ = json.Unmarshal(aliases, &lab.ColumnAliases)
	}
	return &lab, nil
}

func (r *labRepository) CreateLab(ctx context.Context, lab *domain.Lab) (*domain.Lab, error) {
	aliases, err := json.Marshal(lab.ColumnAliases)
	if err != nil {
		return nil, p9errors.InternalServer("LAB_ALIASES_FAILED", "an internal error occurred")
	}

	row := r.pool.QueryRow(ctx, `
		INSERT INTO labs (id, tenant_id, name, accreditation, contact_email, column_aliases)
		VALUES ($1,$2,$3,$4,$5,$6)
		RETURNING `+labColumns,
		lab.ID, lab.TenantID, lab.Name, lab.Accreditation, lab.ContactEmail, aliases)

	created, err := scanLab(row)
	if err != nil {
		r.log.Errorw("msg", "failed to create lab", "name", lab.Name, "error", err)
		return nil, p9errors.InternalServer("LAB_CREATE_FAILED", "an internal error occurred")
	}
	return created, nil
}

func (r *labRepository) GetLab(ctx context.Context, id, tenantID string) (*domain.Lab, error) {
	row := r.pool.QueryRow(ctx,
		`SELECT `+labColumns+` FROM labs WHERE id = $1 AND tenant_id = $2`, id, tenantID)

	lab, err := scanLab(row)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, p9errors.NotFound("LAB_NOT_FOUND", fmt.Sprintf("lab not found: %s", id))
		}
		return nil, p9errors.InternalServer("LAB_GET_FAILED", "an internal error occurred")
	}
	return lab, nil
}

func (r *labRepository) ListLabs(ctx context.Context, params domain.ListLabsParams) ([]domain.Lab, int64, error) {
	var total int64
	if err := r.pool.QueryRow(ctx,
		"SELECT COUNT(*) FROM labs WHERE tenant_id = $1", params.TenantID).Scan(&total); err != nil {
		return nil, 0, p9errors.InternalServer("LAB_LIST_FAILED", "an internal error occurred")
	}

	rows, err := r.pool.Query(ctx,
		`SELECT `+labColumns+` FROM labs WHERE tenant_id = $1 ORDER BY name LIMIT $2 OFFSET $3`,
		params.TenantID, params.Limit, params.Offset)
	if err != nil {
		return nil, 0, p9errors.InternalServer("LAB_LIST_FAILED", "an internal error occurred")
	}
	defer rows.Close()

	var out []domain.Lab
	for rows.Next() {
		lab, err := scanLab(rows)
		if err != nil {
			return nil, 0, p9errors.InternalServer("LAB_SCAN_FAILED", "an internal error occurred")
		}
		out = append(out, *lab)
	}
	return out, total, rows.Err()
}

func scanReport(row pgx.Row) (*domain.LabReport, error) {
	var r domain.LabReport
	var rowsJSON []byte
	if err := row.Scan(
		&r.ID, &r.TenantID, &r.LabID, &r.LabName, &r.Format, &r.Filename, &r.StorageURL,
		&r.ContentSHA256, &r.Status, &r.RowCount, &r.AppliedCount, &r.BlockedCount,
		&rowsJSON, &r.UploadedAt, &r.AppliedAt, &r.UploadedBy, &r.RejectionReason,
	); err != nil {
		return nil, err
	}
	if len(rowsJSON) > 0 {
		_ = json.Unmarshal(rowsJSON, &r.Rows)
	}
	return &r, nil
}

func (r *labRepository) CreateReport(ctx context.Context, report *domain.LabReport) (*domain.LabReport, error) {
	rowsJSON, err := json.Marshal(report.Rows)
	if err != nil {
		return nil, p9errors.InternalServer("REPORT_ROWS_FAILED", "an internal error occurred")
	}

	row := r.pool.QueryRow(ctx, `
		INSERT INTO lab_reports (
			id, tenant_id, lab_id, lab_name, format, filename, storage_url,
			content_sha256, status, row_count, applied_count, blocked_count,
			rows, uploaded_at, uploaded_by, rejection_reason
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16)
		RETURNING `+reportColumns,
		report.ID, report.TenantID, report.LabID, report.LabName,
		string(report.Format), report.Filename, report.StorageURL,
		report.ContentSHA256, string(report.Status),
		report.RowCount, report.AppliedCount, report.BlockedCount,
		rowsJSON, report.UploadedAt, report.UploadedBy, report.RejectionReason)

	created, err := scanReport(row)
	if err != nil {
		r.log.Errorw("msg", "failed to create report", "filename", report.Filename, "error", err)
		return nil, p9errors.InternalServer("REPORT_CREATE_FAILED", "an internal error occurred")
	}
	return created, nil
}

func (r *labRepository) GetReport(ctx context.Context, id, tenantID string) (*domain.LabReport, error) {
	row := r.pool.QueryRow(ctx,
		`SELECT `+reportColumns+` FROM lab_reports WHERE id = $1 AND tenant_id = $2`, id, tenantID)

	report, err := scanReport(row)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, p9errors.NotFound("REPORT_NOT_FOUND", fmt.Sprintf("report not found: %s", id))
		}
		return nil, p9errors.InternalServer("REPORT_GET_FAILED", "an internal error occurred")
	}
	return report, nil
}

// FindByContentHash returns nil without an error when nothing matches.
//
// A miss is the ordinary case for a new upload, so it is not a failure — and
// the caller has to be able to tell "never seen" from "lookup broke", because
// the second must not silently create a duplicate report.
func (r *labRepository) FindByContentHash(ctx context.Context, hash, tenantID string) (*domain.LabReport, error) {
	row := r.pool.QueryRow(ctx,
		`SELECT `+reportColumns+` FROM lab_reports WHERE content_sha256 = $1 AND tenant_id = $2`,
		hash, tenantID)

	report, err := scanReport(row)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, p9errors.InternalServer("REPORT_LOOKUP_FAILED", "an internal error occurred")
	}
	return report, nil
}

func (r *labRepository) ListReports(ctx context.Context, params domain.ListReportsParams) ([]domain.LabReport, int64, error) {
	where := []string{"tenant_id = $1"}
	args := []any{params.TenantID}

	if params.LabID != "" {
		args = append(args, params.LabID)
		where = append(where, fmt.Sprintf("lab_id = $%d", len(args)))
	}
	if params.Status != "" {
		args = append(args, string(params.Status))
		where = append(where, fmt.Sprintf("status = $%d", len(args)))
	}
	clause := strings.Join(where, " AND ")

	var total int64
	if err := r.pool.QueryRow(ctx,
		"SELECT COUNT(*) FROM lab_reports WHERE "+clause, args...).Scan(&total); err != nil {
		return nil, 0, p9errors.InternalServer("REPORT_LIST_FAILED", "an internal error occurred")
	}

	args = append(args, params.Limit, params.Offset)
	rows, err := r.pool.Query(ctx, fmt.Sprintf(
		`SELECT %s FROM lab_reports WHERE %s ORDER BY uploaded_at DESC LIMIT $%d OFFSET $%d`,
		reportColumns, clause, len(args)-1, len(args)), args...)
	if err != nil {
		return nil, 0, p9errors.InternalServer("REPORT_LIST_FAILED", "an internal error occurred")
	}
	defer rows.Close()

	var out []domain.LabReport
	for rows.Next() {
		report, err := scanReport(rows)
		if err != nil {
			return nil, 0, p9errors.InternalServer("REPORT_SCAN_FAILED", "an internal error occurred")
		}
		out = append(out, *report)
	}
	return out, total, rows.Err()
}

func (r *labRepository) SaveReport(ctx context.Context, report *domain.LabReport) error {
	rowsJSON, err := json.Marshal(report.Rows)
	if err != nil {
		return p9errors.InternalServer("REPORT_ROWS_FAILED", "an internal error occurred")
	}

	_, err = r.pool.Exec(ctx, `
		UPDATE lab_reports SET
			status = $3, row_count = $4, applied_count = $5, blocked_count = $6,
			rows = $7, applied_at = $8, rejection_reason = $9
		WHERE id = $1 AND tenant_id = $2`,
		report.ID, report.TenantID, string(report.Status),
		report.RowCount, report.AppliedCount, report.BlockedCount,
		rowsJSON, report.AppliedAt, report.RejectionReason)
	if err != nil {
		r.log.Errorw("msg", "failed to save report", "report", report.ID, "error", err)
		return p9errors.InternalServer("REPORT_SAVE_FAILED", "an internal error occurred")
	}
	return nil
}
