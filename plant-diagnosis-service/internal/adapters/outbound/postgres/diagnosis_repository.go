// Package postgres implements the outbound.DiagnosisRepository port using pgx.
package postgres

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"

	"github.com/jackc/pgx/v5"
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

// ─────────────────────────────────────────────────────────────────────────────
// diagnosis_requests
// ─────────────────────────────────────────────────────────────────────────────

func (r *diagnosisRepository) CreateDiagnosisRequest(ctx context.Context, req *domain.DiagnosisRequest) (*domain.DiagnosisRequest, error) {
	req.ID = ulid.NewString()

	imagesJSON, err := json.Marshal(req.Images)
	if err != nil {
		return nil, errors.InternalServer("JSON_MARSHAL_ERROR", fmt.Sprintf("failed to marshal images: %v", err))
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
		return nil, errors.InternalServer("DB_ERROR", err.Error())
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
		return nil, 0, errors.InternalServer("DB_ERROR", err.Error())
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
		return nil, 0, errors.InternalServer("DB_ERROR", err.Error())
	}
	defer rows.Close()

	var results []domain.DiagnosisRequest
	for rows.Next() {
		e, err := scanDiagnosisRequestFromRows(rows)
		if err != nil {
			return nil, 0, errors.InternalServer("DB_SCAN_ERROR", err.Error())
		}
		results = append(results, *e)
	}
	if err := rows.Err(); err != nil {
		return nil, 0, errors.InternalServer("DB_ERROR", err.Error())
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
			overall_health_score, summary, created_at, updated_at
		FROM diagnosis_results
		WHERE diagnosis_request_id=$1 AND tenant_id=$2 AND deleted_at IS NULL`,
		requestID, tenantID,
	)

	e := &domain.DiagnosisResult{}
	var identifiedSpeciesRaw, diseasesRaw, nutrientsRaw, pestsRaw []byte
	err := row.Scan(
		&e.ID, &e.TenantID, &e.DiagnosisRequestID,
		&identifiedSpeciesRaw, &diseasesRaw, &nutrientsRaw, &pestsRaw,
		&e.TreatmentRecommendations, &e.AIModelVersion, &e.ProcessingTimeMs,
		&e.OverallHealthScore, &e.Summary, &e.CreatedAt, &e.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil // no result yet is not an error
		}
		return nil, errors.InternalServer("DB_ERROR", err.Error())
	}
	e.IdentifiedSpecies = identifiedSpeciesRaw
	e.DetectedDiseases = diseasesRaw
	e.NutrientDeficiencies = nutrientsRaw
	e.PestDamage = pestsRaw
	return e, nil
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
		return nil, errors.InternalServer("DB_ERROR", err.Error())
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
		return nil, 0, errors.InternalServer("DB_ERROR", err.Error())
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
		return nil, 0, errors.InternalServer("DB_ERROR", err.Error())
	}
	defer rows.Close()

	var results []domain.DiseaseInfo
	for rows.Next() {
		d := domain.DiseaseInfo{}
		if err := rows.Scan(
			&d.ID, &d.TenantID, &d.DiseaseName, &d.ScientificName, &d.ConfidenceScore, &d.Severity,
			&d.Description, &d.Symptoms, &d.TreatmentOptions, &d.Prevention, &d.CreatedAt, &d.UpdatedAt,
		); err != nil {
			return nil, 0, errors.InternalServer("DB_SCAN_ERROR", err.Error())
		}
		results = append(results, d)
	}
	if err := rows.Err(); err != nil {
		return nil, 0, errors.InternalServer("DB_ERROR", err.Error())
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
		return nil, errors.InternalServer("DB_ERROR", err.Error())
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
		return nil, errors.InternalServer("DB_ERROR", err.Error())
	}
	tp.Steps = stepsRaw
	return tp, nil
}
