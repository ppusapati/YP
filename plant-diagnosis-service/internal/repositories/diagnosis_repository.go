package repositories

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"p9e.in/samavaya/agriculture/plant-diagnosis-service/internal/models"
	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// DiagnosisRepository defines the interface for diagnosis persistence operations.
type DiagnosisRepository interface {
	// Diagnosis requests
	CreateDiagnosisRequest(ctx context.Context, req *models.DiagnosisRequest) (*models.DiagnosisRequest, error)
	GetDiagnosisRequestByUUID(ctx context.Context, uuid string) (*models.DiagnosisRequest, error)
	ListDiagnosisRequests(ctx context.Context, params ListDiagnosisParams) ([]*models.DiagnosisRequest, int64, error)
	UpdateDiagnosisRequestStatus(ctx context.Context, uuid string, status models.DiagnosisStatus, updatedBy string) (*models.DiagnosisRequest, error)
	SoftDeleteDiagnosisRequest(ctx context.Context, uuid string, deletedBy string) error

	// Diagnosis images
	CreateDiagnosisImage(ctx context.Context, img *models.DiagnosisImage) (*models.DiagnosisImage, error)
	ListDiagnosisImages(ctx context.Context, diagnosisRequestID int64) ([]models.DiagnosisImage, error)

	// Diagnosis results
	CreateDiagnosisResult(ctx context.Context, result *models.DiagnosisResult) (*models.DiagnosisResult, error)
	GetDiagnosisResultByRequestID(ctx context.Context, requestID int64) (*models.DiagnosisResult, error)

	// Disease catalog
	GetDiseaseByUUID(ctx context.Context, uuid string) (*models.DiseaseCatalog, error)
	ListDiseases(ctx context.Context, searchTerm string, pageSize, pageOffset int32) ([]*models.DiseaseCatalog, int64, error)

	// Treatment plans
	CreateTreatmentPlan(ctx context.Context, plan *models.TreatmentPlan) (*models.TreatmentPlan, error)
	GetTreatmentPlanByDiagnosisRequestID(ctx context.Context, diagnosisRequestID int64) (*models.TreatmentPlan, error)
}

// ListDiagnosisParams holds filtering/pagination for listing diagnosis requests.
type ListDiagnosisParams struct {
	FarmID     string
	FieldID    string
	Status     string
	PageSize   int32
	PageOffset int32
	SortDesc   bool
}

// ─────────────────────────────────────────────────────────────────────────────
// Implementation
// ─────────────────────────────────────────────────────────────────────────────

type diagnosisRepository struct {
	pool   *pgxpool.Pool
	logger *p9log.Helper
}

// NewDiagnosisRepository creates a new DiagnosisRepository.
func NewDiagnosisRepository(serviceDeps deps.ServiceDeps) DiagnosisRepository {
	return &diagnosisRepository{
		pool:   serviceDeps.Pool,
		logger: p9log.NewHelper(p9log.With(serviceDeps.Log, "component", "DiagnosisRepository")),
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Diagnosis Requests
// ─────────────────────────────────────────────────────────────────────────────

func (r *diagnosisRepository) CreateDiagnosisRequest(ctx context.Context, req *models.DiagnosisRequest) (*models.DiagnosisRequest, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}

	req.UUID = ulid.NewString()
	req.TenantID = tenantID
	req.Status = models.DiagnosisStatusPending
	req.Version = 1
	req.IsActive = true
	req.CreatedAt = time.Now()

	query := `
		INSERT INTO diagnosis_requests (
			uuid, tenant_id, farm_id, field_id, plant_species_id,
			status, notes, version, is_active, created_by, created_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
		RETURNING id`

	err := r.pool.QueryRow(ctx, query,
		req.UUID, req.TenantID, req.FarmID, req.FieldID, req.PlantSpeciesID,
		string(req.Status), req.Notes, req.Version, req.IsActive,
		req.CreatedBy, req.CreatedAt,
	).Scan(&req.ID)
	if err != nil {
		r.logger.Errorf("failed to create diagnosis request: %v", err)
		return nil, errors.InternalServer("CREATE_FAILED", fmt.Sprintf("failed to create diagnosis request: %v", err))
	}

	return req, nil
}

func (r *diagnosisRepository) GetDiagnosisRequestByUUID(ctx context.Context, uuid string) (*models.DiagnosisRequest, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}

	query := `
		SELECT id, uuid, tenant_id, farm_id, field_id, plant_species_id,
			   status, notes, version, is_active, created_by, created_at,
			   updated_by, updated_at, deleted_by, deleted_at
		FROM diagnosis_requests
		WHERE uuid = $1 AND tenant_id = $2 AND deleted_at IS NULL`

	row := r.pool.QueryRow(ctx, query, uuid, tenantID)
	req, err := scanDiagnosisRequest(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("DIAGNOSIS_NOT_FOUND", fmt.Sprintf("diagnosis request %s not found", uuid))
		}
		r.logger.Errorf("failed to get diagnosis request: %v", err)
		return nil, errors.InternalServer("GET_FAILED", fmt.Sprintf("failed to get diagnosis request: %v", err))
	}

	return req, nil
}

func (r *diagnosisRepository) ListDiagnosisRequests(ctx context.Context, params ListDiagnosisParams) ([]*models.DiagnosisRequest, int64, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}

	if params.PageSize <= 0 {
		params.PageSize = 20
	}
	if params.PageSize > 100 {
		params.PageSize = 100
	}

	// Build dynamic WHERE clause
	baseWhere := "tenant_id = $1 AND deleted_at IS NULL"
	args := []interface{}{tenantID}
	argIdx := 2

	if params.FarmID != "" {
		baseWhere += fmt.Sprintf(" AND farm_id = $%d", argIdx)
		args = append(args, params.FarmID)
		argIdx++
	}
	if params.FieldID != "" {
		baseWhere += fmt.Sprintf(" AND field_id = $%d", argIdx)
		args = append(args, params.FieldID)
		argIdx++
	}
	if params.Status != "" {
		baseWhere += fmt.Sprintf(" AND status = $%d", argIdx)
		args = append(args, params.Status)
		argIdx++
	}

	// Count query
	countQuery := fmt.Sprintf("SELECT COUNT(*) FROM diagnosis_requests WHERE %s", baseWhere)
	var totalCount int64
	if err := r.pool.QueryRow(ctx, countQuery, args...).Scan(&totalCount); err != nil {
		r.logger.Errorf("failed to count diagnosis requests: %v", err)
		return nil, 0, errors.InternalServer("COUNT_FAILED", fmt.Sprintf("failed to count diagnosis requests: %v", err))
	}

	// List query
	orderDir := "ASC"
	if params.SortDesc {
		orderDir = "DESC"
	}

	listQuery := fmt.Sprintf(`
		SELECT id, uuid, tenant_id, farm_id, field_id, plant_species_id,
			   status, notes, version, is_active, created_by, created_at,
			   updated_by, updated_at, deleted_by, deleted_at
		FROM diagnosis_requests
		WHERE %s
		ORDER BY created_at %s
		LIMIT $%d OFFSET $%d`,
		baseWhere, orderDir, argIdx, argIdx+1)

	args = append(args, params.PageSize, params.PageOffset)

	rows, err := r.pool.Query(ctx, listQuery, args...)
	if err != nil {
		r.logger.Errorf("failed to list diagnosis requests: %v", err)
		return nil, 0, errors.InternalServer("LIST_FAILED", fmt.Sprintf("failed to list diagnosis requests: %v", err))
	}
	defer rows.Close()

	results := make([]*models.DiagnosisRequest, 0)
	for rows.Next() {
		req, err := scanDiagnosisRequestFromRows(rows)
		if err != nil {
			r.logger.Errorf("failed to scan diagnosis request: %v", err)
			return nil, 0, errors.InternalServer("SCAN_FAILED", fmt.Sprintf("failed to scan diagnosis request: %v", err))
		}
		results = append(results, req)
	}
	if err := rows.Err(); err != nil {
		return nil, 0, errors.InternalServer("ROWS_ERROR", fmt.Sprintf("rows iteration error: %v", err))
	}

	return results, totalCount, nil
}

func (r *diagnosisRepository) UpdateDiagnosisRequestStatus(ctx context.Context, uuid string, status models.DiagnosisStatus, updatedBy string) (*models.DiagnosisRequest, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}

	query := `
		UPDATE diagnosis_requests
		SET status     = $3,
			updated_by = $4,
			updated_at = NOW(),
			version    = version + 1
		WHERE uuid = $1 AND tenant_id = $2 AND deleted_at IS NULL
		RETURNING id, uuid, tenant_id, farm_id, field_id, plant_species_id,
				  status, notes, version, is_active, created_by, created_at,
				  updated_by, updated_at, deleted_by, deleted_at`

	row := r.pool.QueryRow(ctx, query, uuid, tenantID, string(status), updatedBy)
	req, err := scanDiagnosisRequest(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("DIAGNOSIS_NOT_FOUND", fmt.Sprintf("diagnosis request %s not found", uuid))
		}
		r.logger.Errorf("failed to update diagnosis request status: %v", err)
		return nil, errors.InternalServer("UPDATE_FAILED", fmt.Sprintf("failed to update status: %v", err))
	}

	return req, nil
}

func (r *diagnosisRepository) SoftDeleteDiagnosisRequest(ctx context.Context, uuid string, deletedBy string) error {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}

	query := `
		UPDATE diagnosis_requests
		SET deleted_by = $3,
			deleted_at = NOW(),
			is_active  = FALSE
		WHERE uuid = $1 AND tenant_id = $2 AND deleted_at IS NULL`

	tag, err := r.pool.Exec(ctx, query, uuid, tenantID, deletedBy)
	if err != nil {
		r.logger.Errorf("failed to soft delete diagnosis request: %v", err)
		return errors.InternalServer("DELETE_FAILED", fmt.Sprintf("failed to delete diagnosis request: %v", err))
	}
	if tag.RowsAffected() == 0 {
		return errors.NotFound("DIAGNOSIS_NOT_FOUND", fmt.Sprintf("diagnosis request %s not found", uuid))
	}
	return nil
}

// ─────────────────────────────────────────────────────────────────────────────
// Diagnosis Images
// ─────────────────────────────────────────────────────────────────────────────

func (r *diagnosisRepository) CreateDiagnosisImage(ctx context.Context, img *models.DiagnosisImage) (*models.DiagnosisImage, error) {
	img.UUID = ulid.NewString()
	img.UploadedAt = time.Now()

	query := `
		INSERT INTO diagnosis_images (
			uuid, diagnosis_request_id, image_url, image_type,
			size_bytes, mime_type, checksum, uploaded_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
		RETURNING id`

	err := r.pool.QueryRow(ctx, query,
		img.UUID, img.DiagnosisRequestID, img.ImageURL, img.ImageType,
		img.SizeBytes, img.MimeType, img.Checksum, img.UploadedAt,
	).Scan(&img.ID)
	if err != nil {
		r.logger.Errorf("failed to create diagnosis image: %v", err)
		return nil, errors.InternalServer("CREATE_IMAGE_FAILED", fmt.Sprintf("failed to create image: %v", err))
	}

	return img, nil
}

func (r *diagnosisRepository) ListDiagnosisImages(ctx context.Context, diagnosisRequestID int64) ([]models.DiagnosisImage, error) {
	query := `
		SELECT id, uuid, diagnosis_request_id, image_url, image_type,
			   size_bytes, mime_type, checksum, uploaded_at
		FROM diagnosis_images
		WHERE diagnosis_request_id = $1
		ORDER BY uploaded_at ASC`

	rows, err := r.pool.Query(ctx, query, diagnosisRequestID)
	if err != nil {
		r.logger.Errorf("failed to list diagnosis images: %v", err)
		return nil, errors.InternalServer("LIST_IMAGES_FAILED", fmt.Sprintf("failed to list images: %v", err))
	}
	defer rows.Close()

	images := make([]models.DiagnosisImage, 0)
	for rows.Next() {
		var img models.DiagnosisImage
		if err := rows.Scan(
			&img.ID, &img.UUID, &img.DiagnosisRequestID, &img.ImageURL, &img.ImageType,
			&img.SizeBytes, &img.MimeType, &img.Checksum, &img.UploadedAt,
		); err != nil {
			r.logger.Errorf("failed to scan diagnosis image: %v", err)
			return nil, errors.InternalServer("SCAN_IMAGE_FAILED", fmt.Sprintf("failed to scan image: %v", err))
		}
		images = append(images, img)
	}
	if err := rows.Err(); err != nil {
		return nil, errors.InternalServer("ROWS_ERROR", fmt.Sprintf("rows iteration error: %v", err))
	}

	return images, nil
}

// ─────────────────────────────────────────────────────────────────────────────
// Diagnosis Results
// ─────────────────────────────────────────────────────────────────────────────

func (r *diagnosisRepository) CreateDiagnosisResult(ctx context.Context, result *models.DiagnosisResult) (*models.DiagnosisResult, error) {
	result.UUID = ulid.NewString()
	result.CreatedAt = time.Now()

	// Ensure JSONB fields are never nil (use empty arrays)
	if result.DetectedDiseases == nil {
		result.DetectedDiseases = json.RawMessage("[]")
	}
	if result.NutrientDeficiencies == nil {
		result.NutrientDeficiencies = json.RawMessage("[]")
	}
	if result.PestDamage == nil {
		result.PestDamage = json.RawMessage("[]")
	}
	if result.TreatmentRecommendations == nil {
		result.TreatmentRecommendations = json.RawMessage("[]")
	}

	query := `
		INSERT INTO diagnosis_results (
			uuid, diagnosis_request_id, identified_species_id,
			identified_species_name, identified_species_conf,
			detected_diseases, nutrient_deficiencies, pest_damage,
			treatment_recommendations, ai_model_version, processing_time_ms,
			overall_health_score, summary, created_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
		RETURNING id`

	err := r.pool.QueryRow(ctx, query,
		result.UUID, result.DiagnosisRequestID, result.IdentifiedSpeciesID,
		result.IdentifiedSpeciesName, result.IdentifiedSpeciesConf,
		result.DetectedDiseases, result.NutrientDeficiencies, result.PestDamage,
		result.TreatmentRecommendations, result.AIModelVersion, result.ProcessingTimeMs,
		result.OverallHealthScore, result.Summary, result.CreatedAt,
	).Scan(&result.ID)
	if err != nil {
		r.logger.Errorf("failed to create diagnosis result: %v", err)
		return nil, errors.InternalServer("CREATE_RESULT_FAILED", fmt.Sprintf("failed to create result: %v", err))
	}

	return result, nil
}

func (r *diagnosisRepository) GetDiagnosisResultByRequestID(ctx context.Context, requestID int64) (*models.DiagnosisResult, error) {
	query := `
		SELECT id, uuid, diagnosis_request_id, identified_species_id,
			   identified_species_name, identified_species_conf,
			   detected_diseases, nutrient_deficiencies, pest_damage,
			   treatment_recommendations, ai_model_version, processing_time_ms,
			   overall_health_score, summary, created_at
		FROM diagnosis_results
		WHERE diagnosis_request_id = $1`

	var result models.DiagnosisResult
	err := r.pool.QueryRow(ctx, query, requestID).Scan(
		&result.ID, &result.UUID, &result.DiagnosisRequestID,
		&result.IdentifiedSpeciesID, &result.IdentifiedSpeciesName, &result.IdentifiedSpeciesConf,
		&result.DetectedDiseases, &result.NutrientDeficiencies, &result.PestDamage,
		&result.TreatmentRecommendations, &result.AIModelVersion, &result.ProcessingTimeMs,
		&result.OverallHealthScore, &result.Summary, &result.CreatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("RESULT_NOT_FOUND", "diagnosis result not found")
		}
		r.logger.Errorf("failed to get diagnosis result: %v", err)
		return nil, errors.InternalServer("GET_RESULT_FAILED", fmt.Sprintf("failed to get result: %v", err))
	}

	return &result, nil
}

// ─────────────────────────────────────────────────────────────────────────────
// Disease Catalog
// ─────────────────────────────────────────────────────────────────────────────

func (r *diagnosisRepository) GetDiseaseByUUID(ctx context.Context, uuid string) (*models.DiseaseCatalog, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}

	query := `
		SELECT id, uuid, tenant_id, disease_name, scientific_name, description,
			   symptoms, treatment_options, prevention, affected_species,
			   is_active, created_by, created_at, updated_by, updated_at, deleted_by, deleted_at
		FROM disease_catalog
		WHERE uuid = $1 AND tenant_id = $2 AND deleted_at IS NULL`

	var d models.DiseaseCatalog
	err := r.pool.QueryRow(ctx, query, uuid, tenantID).Scan(
		&d.ID, &d.UUID, &d.TenantID, &d.DiseaseName, &d.ScientificName, &d.Description,
		&d.Symptoms, &d.TreatmentOptions, &d.Prevention, &d.AffectedSpecies,
		&d.IsActive, &d.CreatedBy, &d.CreatedAt, &d.UpdatedBy, &d.UpdatedAt, &d.DeletedBy, &d.DeletedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("DISEASE_NOT_FOUND", fmt.Sprintf("disease %s not found", uuid))
		}
		r.logger.Errorf("failed to get disease: %v", err)
		return nil, errors.InternalServer("GET_DISEASE_FAILED", fmt.Sprintf("failed to get disease: %v", err))
	}

	return &d, nil
}

func (r *diagnosisRepository) ListDiseases(ctx context.Context, searchTerm string, pageSize, pageOffset int32) ([]*models.DiseaseCatalog, int64, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}

	if pageSize <= 0 {
		pageSize = 20
	}
	if pageSize > 100 {
		pageSize = 100
	}

	baseWhere := "tenant_id = $1 AND deleted_at IS NULL"
	args := []interface{}{tenantID}
	argIdx := 2

	if searchTerm != "" {
		baseWhere += fmt.Sprintf(" AND (disease_name ILIKE '%%' || $%d || '%%' OR scientific_name ILIKE '%%' || $%d || '%%')", argIdx, argIdx)
		args = append(args, searchTerm)
		argIdx++
	}

	// Count
	var totalCount int64
	countQuery := fmt.Sprintf("SELECT COUNT(*) FROM disease_catalog WHERE %s", baseWhere)
	if err := r.pool.QueryRow(ctx, countQuery, args...).Scan(&totalCount); err != nil {
		return nil, 0, errors.InternalServer("COUNT_DISEASES_FAILED", fmt.Sprintf("failed to count diseases: %v", err))
	}

	// List
	listQuery := fmt.Sprintf(`
		SELECT id, uuid, tenant_id, disease_name, scientific_name, description,
			   symptoms, treatment_options, prevention, affected_species,
			   is_active, created_by, created_at, updated_by, updated_at, deleted_by, deleted_at
		FROM disease_catalog
		WHERE %s
		ORDER BY disease_name ASC
		LIMIT $%d OFFSET $%d`, baseWhere, argIdx, argIdx+1)

	args = append(args, pageSize, pageOffset)

	rows, err := r.pool.Query(ctx, listQuery, args...)
	if err != nil {
		return nil, 0, errors.InternalServer("LIST_DISEASES_FAILED", fmt.Sprintf("failed to list diseases: %v", err))
	}
	defer rows.Close()

	diseases := make([]*models.DiseaseCatalog, 0)
	for rows.Next() {
		var d models.DiseaseCatalog
		if err := rows.Scan(
			&d.ID, &d.UUID, &d.TenantID, &d.DiseaseName, &d.ScientificName, &d.Description,
			&d.Symptoms, &d.TreatmentOptions, &d.Prevention, &d.AffectedSpecies,
			&d.IsActive, &d.CreatedBy, &d.CreatedAt, &d.UpdatedBy, &d.UpdatedAt, &d.DeletedBy, &d.DeletedAt,
		); err != nil {
			return nil, 0, errors.InternalServer("SCAN_DISEASE_FAILED", fmt.Sprintf("failed to scan disease: %v", err))
		}
		diseases = append(diseases, &d)
	}
	if err := rows.Err(); err != nil {
		return nil, 0, errors.InternalServer("ROWS_ERROR", fmt.Sprintf("rows iteration error: %v", err))
	}

	return diseases, totalCount, nil
}

// ─────────────────────────────────────────────────────────────────────────────
// Treatment Plans
// ─────────────────────────────────────────────────────────────────────────────

func (r *diagnosisRepository) CreateTreatmentPlan(ctx context.Context, plan *models.TreatmentPlan) (*models.TreatmentPlan, error) {
	plan.UUID = ulid.NewString()
	plan.IsActive = true
	plan.CreatedAt = time.Now()

	if plan.Steps == nil {
		plan.Steps = json.RawMessage("[]")
	}

	query := `
		INSERT INTO treatment_plans (
			uuid, diagnosis_request_id, title, description,
			priority, steps, estimated_cost, estimated_days,
			is_active, created_by, created_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
		RETURNING id`

	err := r.pool.QueryRow(ctx, query,
		plan.UUID, plan.DiagnosisRequestID, plan.Title, plan.Description,
		plan.Priority, plan.Steps, plan.EstimatedCost, plan.EstimatedDays,
		plan.IsActive, plan.CreatedBy, plan.CreatedAt,
	).Scan(&plan.ID)
	if err != nil {
		r.logger.Errorf("failed to create treatment plan: %v", err)
		return nil, errors.InternalServer("CREATE_PLAN_FAILED", fmt.Sprintf("failed to create treatment plan: %v", err))
	}

	return plan, nil
}

func (r *diagnosisRepository) GetTreatmentPlanByDiagnosisRequestID(ctx context.Context, diagnosisRequestID int64) (*models.TreatmentPlan, error) {
	query := `
		SELECT id, uuid, diagnosis_request_id, title, description,
			   priority, steps, estimated_cost, estimated_days,
			   is_active, created_by, created_at, updated_by, updated_at, deleted_by, deleted_at
		FROM treatment_plans
		WHERE diagnosis_request_id = $1 AND deleted_at IS NULL
		ORDER BY created_at DESC
		LIMIT 1`

	var tp models.TreatmentPlan
	err := r.pool.QueryRow(ctx, query, diagnosisRequestID).Scan(
		&tp.ID, &tp.UUID, &tp.DiagnosisRequestID, &tp.Title, &tp.Description,
		&tp.Priority, &tp.Steps, &tp.EstimatedCost, &tp.EstimatedDays,
		&tp.IsActive, &tp.CreatedBy, &tp.CreatedAt, &tp.UpdatedBy, &tp.UpdatedAt, &tp.DeletedBy, &tp.DeletedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("PLAN_NOT_FOUND", "treatment plan not found")
		}
		r.logger.Errorf("failed to get treatment plan: %v", err)
		return nil, errors.InternalServer("GET_PLAN_FAILED", fmt.Sprintf("failed to get treatment plan: %v", err))
	}

	return &tp, nil
}

// ─────────────────────────────────────────────────────────────────────────────
// Row scanners
// ─────────────────────────────────────────────────────────────────────────────

func scanDiagnosisRequest(row pgx.Row) (*models.DiagnosisRequest, error) {
	var req models.DiagnosisRequest
	var status string
	err := row.Scan(
		&req.ID, &req.UUID, &req.TenantID, &req.FarmID, &req.FieldID, &req.PlantSpeciesID,
		&status, &req.Notes, &req.Version, &req.IsActive,
		&req.CreatedBy, &req.CreatedAt, &req.UpdatedBy, &req.UpdatedAt,
		&req.DeletedBy, &req.DeletedAt,
	)
	if err != nil {
		return nil, err
	}
	req.Status = models.DiagnosisStatus(status)
	return &req, nil
}

func scanDiagnosisRequestFromRows(rows pgx.Rows) (*models.DiagnosisRequest, error) {
	var req models.DiagnosisRequest
	var status string
	err := rows.Scan(
		&req.ID, &req.UUID, &req.TenantID, &req.FarmID, &req.FieldID, &req.PlantSpeciesID,
		&status, &req.Notes, &req.Version, &req.IsActive,
		&req.CreatedBy, &req.CreatedAt, &req.UpdatedBy, &req.UpdatedAt,
		&req.DeletedBy, &req.DeletedAt,
	)
	if err != nil {
		return nil, err
	}
	req.Status = models.DiagnosisStatus(status)
	return &req, nil
}
