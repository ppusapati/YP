// Package postgres implements the outbound.DiagnosisRepository port using pgx.
package postgres

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgxpool"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	"p9e.in/samavaya/agriculture/plant-diagnosis-service/internal/domain"
	"p9e.in/samavaya/agriculture/plant-diagnosis-service/internal/ports/outbound"
)

type diagnosisRepository struct {
	pool *pgxpool.Pool
	log  *p9log.Helper
	tx   pgx.Tx
}

// NewDiagnosisRepository creates a new postgres-backed DiagnosisRepository.
func NewDiagnosisRepository(pool *pgxpool.Pool, log p9log.Logger) outbound.DiagnosisRepository {
	return &diagnosisRepository{
		pool: pool,
		log:  p9log.NewHelper(p9log.With(log, "component", "DiagnosisPostgresRepository")),
	}
}

func (r *diagnosisRepository) WithTx(tx pgx.Tx) outbound.DiagnosisRepository {
	return &diagnosisRepository{pool: r.pool, log: r.log, tx: tx}
}

func (r *diagnosisRepository) queryRow(ctx context.Context, sql string, args ...any) pgx.Row {
	if r.tx != nil {
		return r.tx.QueryRow(ctx, sql, args...)
	}
	return r.pool.QueryRow(ctx, sql, args...)
}

func (r *diagnosisRepository) query(ctx context.Context, sql string, args ...any) (pgx.Rows, error) {
	if r.tx != nil {
		return r.tx.Query(ctx, sql, args...)
	}
	return r.pool.Query(ctx, sql, args...)
}

func (r *diagnosisRepository) exec(ctx context.Context, sql string, args ...any) (pgconn.CommandTag, error) {
	if r.tx != nil {
		return r.tx.Exec(ctx, sql, args...)
	}
	return r.pool.Exec(ctx, sql, args...)
}

// ─────────────────────────────────────────────────────────────────────────────
// diagnosis_requests
// ─────────────────────────────────────────────────────────────────────────────

func (r *diagnosisRepository) CreateDiagnosisRequest(ctx context.Context, req *domain.DiagnosisRequest) (*domain.DiagnosisRequest, error) {
	req.ID = ulid.NewString()

	imagesJSON, err := json.Marshal(req.Images)
	if err != nil {
		r.log.Errorw("msg", "failed to marshal images", "error", err)
		return nil, errors.InternalServer("JSON_MARSHAL_ERROR", "an internal error occurred")
	}

	row := r.queryRow(ctx,
		`INSERT INTO diagnosis_requests
			(id, tenant_id, farm_id, field_id, plant_species_id, status, notes, images, version, created_by)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
		RETURNING id, tenant_id, farm_id, field_id, plant_species_id, status, notes, images, version, created_by, created_at, updated_at`,
		req.ID, req.TenantID, req.FarmID, req.FieldID, req.PlantSpeciesID,
		string(req.Status), req.Notes, imagesJSON, req.Version, req.CreatedBy,
	)
	return scanDiagnosisRequest(row)
}

func (r *diagnosisRepository) GetDiagnosisRequestByID(ctx context.Context, id, tenantID string) (*domain.DiagnosisRequest, error) {
	row := r.queryRow(ctx,
		`SELECT id, tenant_id, farm_id, field_id, plant_species_id, status, notes, images, version, created_by, created_at, updated_at
		FROM diagnosis_requests
		WHERE id=$1 AND tenant_id=$2 AND deleted_at IS NULL`,
		id, tenantID,
	)
	e, err := scanDiagnosisRequest(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("DIAGNOSIS_NOT_FOUND", fmt.Sprintf("diagnosis not found: %s", id))
		}
		r.log.Errorw("msg", "db error", "error", err)
		return nil, errors.InternalServer("DB_ERROR", "an internal error occurred")
	}
	return e, nil
}

func (r *diagnosisRepository) ListDiagnosisRequests(ctx context.Context, params domain.ListDiagnosesParams) ([]domain.DiagnosisRequest, int32, error) {
	// Build dynamic WHERE clause.
	where := []string{"tenant_id=$1", "deleted_at IS NULL"}
	args := []any{params.TenantID}
	argIdx := 2

	if params.FarmID != "" {
		where = append(where, fmt.Sprintf("farm_id=$%d", argIdx))
		args = append(args, params.FarmID)
		argIdx++
	}
	if params.FieldID != "" {
		where = append(where, fmt.Sprintf("field_id=$%d", argIdx))
		args = append(args, params.FieldID)
		argIdx++
	}
	if params.Status != nil {
		where = append(where, fmt.Sprintf("status=$%d", argIdx))
		args = append(args, string(*params.Status))
		argIdx++
	}

	whereClause := strings.Join(where, " AND ")

	// Count total.
	var total int32
	countSQL := fmt.Sprintf("SELECT COUNT(*) FROM diagnosis_requests WHERE %s", whereClause)
	if err := r.queryRow(ctx, countSQL, args...).Scan(&total); err != nil {
		r.log.Errorw("msg", "db error", "error", err)
		return nil, 0, errors.InternalServer("DB_ERROR", "an internal error occurred")
	}

	// Order.
	orderCol := "created_at"
	allowedSortCols := map[string]bool{"created_at": true, "updated_at": true, "status": true, "farm_id": true}
	if params.SortBy != "" && allowedSortCols[params.SortBy] {
		orderCol = params.SortBy
	}
	orderDir := "ASC"
	if params.SortDesc {
		orderDir = "DESC"
	}

	listSQL := fmt.Sprintf(
		`SELECT id, tenant_id, farm_id, field_id, plant_species_id, status, notes, images, version, created_by, created_at, updated_at
		FROM diagnosis_requests WHERE %s ORDER BY %s %s LIMIT $%d OFFSET $%d`,
		whereClause, orderCol, orderDir, argIdx, argIdx+1,
	)
	args = append(args, params.PageSize, params.Offset)

	rows, err := r.query(ctx, listSQL, args...)
	if err != nil {
		r.log.Errorw("msg", "db error", "error", err)
		return nil, 0, errors.InternalServer("DB_ERROR", "an internal error occurred")
	}
	defer rows.Close()

	var results []domain.DiagnosisRequest
	for rows.Next() {
		e, err := scanDiagnosisRequestFromRows(rows)
		if err != nil {
			r.log.Errorw("msg", "db scan error", "error", err)
			return nil, 0, errors.InternalServer("DB_SCAN_ERROR", "an internal error occurred")
		}
		results = append(results, *e)
	}
	if err := rows.Err(); err != nil {
		r.log.Errorw("msg", "db error", "error", err)
		return nil, 0, errors.InternalServer("DB_ERROR", "an internal error occurred")
	}

	return results, total, nil
}

func scanDiagnosisRequest(row pgx.Row) (*domain.DiagnosisRequest, error) {
	e := &domain.DiagnosisRequest{}
	var imagesRaw []byte
	err := row.Scan(
		&e.ID, &e.TenantID, &e.FarmID, &e.FieldID, &e.PlantSpeciesID,
		&e.Status, &e.Notes, &imagesRaw, &e.Version,
		&e.CreatedBy, &e.CreatedAt, &e.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}
	if len(imagesRaw) > 0 {
		_ = json.Unmarshal(imagesRaw, &e.Images)
	}
	return e, nil
}

func scanDiagnosisRequestFromRows(rows pgx.Rows) (*domain.DiagnosisRequest, error) {
	e := &domain.DiagnosisRequest{}
	var imagesRaw []byte
	err := rows.Scan(
		&e.ID, &e.TenantID, &e.FarmID, &e.FieldID, &e.PlantSpeciesID,
		&e.Status, &e.Notes, &imagesRaw, &e.Version,
		&e.CreatedBy, &e.CreatedAt, &e.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}
	if len(imagesRaw) > 0 {
		_ = json.Unmarshal(imagesRaw, &e.Images)
	}
	return e, nil
}

// ─────────────────────────────────────────────────────────────────────────────
// diagnosis_results
// ─────────────────────────────────────────────────────────────────────────────

func (r *diagnosisRepository) GetDiagnosisResultByRequestID(ctx context.Context, requestID, tenantID string) (*domain.DiagnosisResult, error) {
	row := r.queryRow(ctx,
		`SELECT id, tenant_id, diagnosis_request_id,
			identified_species, detected_diseases, nutrient_deficiencies, pest_damage,
			treatment_recommendations, ai_model_version, processing_time_ms,
			overall_health_score, summary, explanations, created_at, updated_at
		FROM diagnosis_results
		WHERE diagnosis_request_id=$1 AND tenant_id=$2 AND deleted_at IS NULL`,
		requestID, tenantID,
	)

	e, err := scanDiagnosisResult(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil // no result yet is not an error
		}
		r.log.Errorw("msg", "db error", "error", err)
		return nil, errors.InternalServer("DB_ERROR", "an internal error occurred")
	}
	return e, nil
}

// scanDiagnosisResult reads one row in the column order both queries select.
func scanDiagnosisResult(row pgx.Row) (*domain.DiagnosisResult, error) {
	e := &domain.DiagnosisResult{}
	var identifiedSpeciesRaw, diseasesRaw, nutrientsRaw, pestsRaw, explanationsRaw []byte
	if err := row.Scan(
		&e.ID, &e.TenantID, &e.DiagnosisRequestID,
		&identifiedSpeciesRaw, &diseasesRaw, &nutrientsRaw, &pestsRaw,
		&e.TreatmentRecommendations, &e.AIModelVersion, &e.ProcessingTimeMs,
		&e.OverallHealthScore, &e.Summary, &explanationsRaw, &e.CreatedAt, &e.UpdatedAt,
	); err != nil {
		return nil, err
	}
	e.IdentifiedSpecies = identifiedSpeciesRaw
	e.DetectedDiseases = diseasesRaw
	e.NutrientDeficiencies = nutrientsRaw
	e.PestDamage = pestsRaw
	e.Explanations = explanationsRaw
	return e, nil
}

// CreateDiagnosisResult stores the AI findings for a request.
//
// One result per request: the unique index on diagnosis_request_id makes a
// re-analysis an update rather than a second row, so a retried analysis
// replaces the old answer instead of leaving two that disagree.
func (r *diagnosisRepository) CreateDiagnosisResult(ctx context.Context, res *domain.DiagnosisResult) (*domain.DiagnosisResult, error) {
	if res.ID == "" {
		res.ID = ulid.NewString()
	}
	jsonOrEmpty := func(raw json.RawMessage, empty string) []byte {
		if len(raw) == 0 {
			return []byte(empty)
		}
		return raw
	}

	row := r.queryRow(ctx,
		`INSERT INTO diagnosis_results
			(id, tenant_id, diagnosis_request_id, identified_species, detected_diseases,
			 nutrient_deficiencies, pest_damage, treatment_recommendations,
			 ai_model_version, processing_time_ms, overall_health_score, summary, explanations)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)
		ON CONFLICT (diagnosis_request_id) WHERE deleted_at IS NULL DO UPDATE SET
			identified_species        = EXCLUDED.identified_species,
			detected_diseases         = EXCLUDED.detected_diseases,
			nutrient_deficiencies     = EXCLUDED.nutrient_deficiencies,
			pest_damage               = EXCLUDED.pest_damage,
			treatment_recommendations = EXCLUDED.treatment_recommendations,
			ai_model_version          = EXCLUDED.ai_model_version,
			processing_time_ms        = EXCLUDED.processing_time_ms,
			overall_health_score      = EXCLUDED.overall_health_score,
			summary                   = EXCLUDED.summary,
			explanations              = EXCLUDED.explanations,
			updated_at                = NOW()
		RETURNING id, tenant_id, diagnosis_request_id,
			identified_species, detected_diseases, nutrient_deficiencies, pest_damage,
			treatment_recommendations, ai_model_version, processing_time_ms,
			overall_health_score, summary, explanations, created_at, updated_at`,
		res.ID, res.TenantID, res.DiagnosisRequestID,
		jsonOrEmpty(res.IdentifiedSpecies, "null"),
		jsonOrEmpty(res.DetectedDiseases, "[]"),
		jsonOrEmpty(res.NutrientDeficiencies, "[]"),
		jsonOrEmpty(res.PestDamage, "[]"),
		res.TreatmentRecommendations, res.AIModelVersion, res.ProcessingTimeMs,
		res.OverallHealthScore, res.Summary,
		jsonOrEmpty(res.Explanations, "[]"),
	)
	out, err := scanDiagnosisResult(row)
	if err != nil {
		r.log.Errorw("msg", "failed to store diagnosis result", "error", err)
		return nil, errors.InternalServer("DB_ERROR", "an internal error occurred")
	}
	return out, nil
}

// UpdateDiagnosisRequestStatus moves a request through its lifecycle.
func (r *diagnosisRepository) UpdateDiagnosisRequestStatus(ctx context.Context, id, tenantID string, status domain.DiagnosisStatus) error {
	tag, err := r.exec(ctx,
		`UPDATE diagnosis_requests
		SET status=$3, version=version+1, updated_at=NOW()
		WHERE id=$1 AND tenant_id=$2 AND deleted_at IS NULL`,
		id, tenantID, string(status),
	)
	if err != nil {
		r.log.Errorw("msg", "failed to update diagnosis status", "error", err)
		return errors.InternalServer("DB_ERROR", "an internal error occurred")
	}
	if tag.RowsAffected() == 0 {
		return errors.NotFound("DIAGNOSIS_NOT_FOUND", fmt.Sprintf("diagnosis not found: %s", id))
	}
	return nil
}

// ─────────────────────────────────────────────────────────────────────────────
// diseases (reference table)
// ─────────────────────────────────────────────────────────────────────────────

func (r *diagnosisRepository) GetDiseaseByID(ctx context.Context, id, tenantID string) (*domain.DiseaseInfo, error) {
	row := r.queryRow(ctx,
		`SELECT id, tenant_id, disease_name, scientific_name, confidence_score, severity,
			description, symptoms, treatment_options, prevention, created_at, updated_at
		FROM diseases
		WHERE id=$1 AND tenant_id=$2 AND deleted_at IS NULL`,
		id, tenantID,
	)

	d := &domain.DiseaseInfo{}
	err := row.Scan(
		&d.ID, &d.TenantID, &d.DiseaseName, &d.ScientificName, &d.ConfidenceScore, &d.Severity,
		&d.Description, &d.Symptoms, &d.TreatmentOptions, &d.Prevention, &d.CreatedAt, &d.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("DISEASE_NOT_FOUND", fmt.Sprintf("disease not found: %s", id))
		}
		r.log.Errorw("msg", "db error", "error", err)
		return nil, errors.InternalServer("DB_ERROR", "an internal error occurred")
	}
	return d, nil
}

func (r *diagnosisRepository) ListDiseases(ctx context.Context, params domain.ListDiseasesParams) ([]domain.DiseaseInfo, int32, error) {
	where := []string{"tenant_id=$1", "deleted_at IS NULL"}
	args := []any{params.TenantID}
	argIdx := 2

	if params.SearchTerm != "" {
		where = append(where, fmt.Sprintf("(disease_name ILIKE $%d OR scientific_name ILIKE $%d)", argIdx, argIdx))
		args = append(args, "%"+params.SearchTerm+"%")
		argIdx++
	}

	whereClause := strings.Join(where, " AND ")

	var total int32
	countSQL := fmt.Sprintf("SELECT COUNT(*) FROM diseases WHERE %s", whereClause)
	if err := r.queryRow(ctx, countSQL, args...).Scan(&total); err != nil {
		r.log.Errorw("msg", "db error", "error", err)
		return nil, 0, errors.InternalServer("DB_ERROR", "an internal error occurred")
	}

	listSQL := fmt.Sprintf(
		`SELECT id, tenant_id, disease_name, scientific_name, confidence_score, severity,
			description, symptoms, treatment_options, prevention, created_at, updated_at
		FROM diseases WHERE %s ORDER BY disease_name ASC LIMIT $%d OFFSET $%d`,
		whereClause, argIdx, argIdx+1,
	)
	args = append(args, params.PageSize, params.Offset)

	rows, err := r.query(ctx, listSQL, args...)
	if err != nil {
		r.log.Errorw("msg", "db error", "error", err)
		return nil, 0, errors.InternalServer("DB_ERROR", "an internal error occurred")
	}
	defer rows.Close()

	var results []domain.DiseaseInfo
	for rows.Next() {
		d := domain.DiseaseInfo{}
		if err := rows.Scan(
			&d.ID, &d.TenantID, &d.DiseaseName, &d.ScientificName, &d.ConfidenceScore, &d.Severity,
			&d.Description, &d.Symptoms, &d.TreatmentOptions, &d.Prevention, &d.CreatedAt, &d.UpdatedAt,
		); err != nil {
			r.log.Errorw("msg", "db scan error", "error", err)
			return nil, 0, errors.InternalServer("DB_SCAN_ERROR", "an internal error occurred")
		}
		results = append(results, d)
	}
	if err := rows.Err(); err != nil {
		r.log.Errorw("msg", "db error", "error", err)
		return nil, 0, errors.InternalServer("DB_ERROR", "an internal error occurred")
	}
	return results, total, nil
}

// ─────────────────────────────────────────────────────────────────────────────
// treatment_plans
// ─────────────────────────────────────────────────────────────────────────────

func (r *diagnosisRepository) GetTreatmentPlanByDiagnosisID(ctx context.Context, diagnosisID, tenantID string) (*domain.TreatmentPlan, error) {
	row := r.queryRow(ctx,
		`SELECT id, tenant_id, diagnosis_id, title, description, priority,
			steps, estimated_cost, estimated_days, created_at, updated_at
		FROM treatment_plans
		WHERE diagnosis_id=$1 AND tenant_id=$2 AND deleted_at IS NULL
		ORDER BY created_at DESC LIMIT 1`,
		diagnosisID, tenantID,
	)

	tp := &domain.TreatmentPlan{}
	var stepsRaw []byte
	err := row.Scan(
		&tp.ID, &tp.TenantID, &tp.DiagnosisID, &tp.Title, &tp.Description, &tp.Priority,
		&stepsRaw, &tp.EstimatedCost, &tp.EstimatedDays, &tp.CreatedAt, &tp.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil // no plan yet
		}
		r.log.Errorw("msg", "db error", "error", err)
		return nil, errors.InternalServer("DB_ERROR", "an internal error occurred")
	}
	tp.Steps = stepsRaw
	return tp, nil
}

func (r *diagnosisRepository) CreateTreatmentPlan(ctx context.Context, plan *domain.TreatmentPlan) (*domain.TreatmentPlan, error) {
	plan.ID = ulid.NewString()

	stepsJSON := plan.Steps
	if len(stepsJSON) == 0 {
		stepsJSON = []byte("[]")
	}

	row := r.queryRow(ctx,
		`INSERT INTO treatment_plans
			(id, tenant_id, diagnosis_id, title, description, priority, steps, estimated_cost, estimated_days)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)
		RETURNING id, tenant_id, diagnosis_id, title, description, priority, steps, estimated_cost, estimated_days, created_at, updated_at`,
		plan.ID, plan.TenantID, plan.DiagnosisID, plan.Title, plan.Description,
		plan.Priority, stepsJSON, plan.EstimatedCost, plan.EstimatedDays,
	)

	tp := &domain.TreatmentPlan{}
	var stepsRaw []byte
	err := row.Scan(
		&tp.ID, &tp.TenantID, &tp.DiagnosisID, &tp.Title, &tp.Description, &tp.Priority,
		&stepsRaw, &tp.EstimatedCost, &tp.EstimatedDays, &tp.CreatedAt, &tp.UpdatedAt,
	)
	if err != nil {
		r.log.Errorw("msg", "db error", "error", err)
		return nil, errors.InternalServer("DB_ERROR", "an internal error occurred")
	}
	tp.Steps = stepsRaw
	return tp, nil
}
