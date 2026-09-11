package repositories

import (
	"context"
	"encoding/json"
	"fmt"
	"strconv"
	"time"

	"github.com/jackc/pgx/v5"
	"google.golang.org/protobuf/types/known/timestamppb"

	pb "p9e.in/samavaya/agriculture/agronomy-service/api/v1"
	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
)

// InspectionListParams holds query parameters for listing inspections.
type InspectionListParams struct {
	FarmID      string
	FieldID     string
	InspectorID string
	Status      string
	PageSize    int32
	PageToken   string
}

// InspectionRepository defines the interface for inspection persistence operations.
type InspectionRepository interface {
	GetByID(ctx context.Context, id string) (*pb.Inspection, error)
	List(ctx context.Context, params InspectionListParams) ([]*pb.Inspection, string, int32, error)
	Create(ctx context.Context, inspection *pb.Inspection) (*pb.Inspection, error)
	UpdateStatus(ctx context.Context, id string, status string) (*pb.Inspection, error)
}

// inspectionRepository is the concrete implementation of InspectionRepository.
type inspectionRepository struct {
	d   deps.ServiceDeps
	log *p9log.Helper
}

// NewInspectionRepository creates a new InspectionRepository.
func NewInspectionRepository(d deps.ServiceDeps) InspectionRepository {
	return &inspectionRepository{
		d:   d,
		log: p9log.NewHelper(p9log.With(d.Log, "component", "InspectionRepository")),
	}
}

// GetByID retrieves an inspection by its ID.
func (r *inspectionRepository) GetByID(ctx context.Context, id string) (*pb.Inspection, error) {
	tenantID := p9context.TenantID(ctx)

	row := r.d.Pool.QueryRow(ctx, `
		SELECT id, tenant_id, field_id, farm_id, inspector_id, status,
		       findings, photos, recommendations, issues, health_score,
		       notes, inspection_date, created_at, updated_at
		FROM inspections
		WHERE id = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL`,
		id, tenantID,
	)

	inspection, err := scanInspection(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("INSPECTION_NOT_FOUND", fmt.Sprintf("inspection not found: %s", id))
		}
		r.log.Errorw("msg", "failed to get inspection", "id", id, "error", err)
		return nil, errors.InternalServer("INSPECTION_GET_FAILED", fmt.Sprintf("failed to get inspection: %v", err))
	}

	return inspection, nil
}

// List retrieves inspections with filtering and pagination.
func (r *inspectionRepository) List(ctx context.Context, params InspectionListParams) ([]*pb.Inspection, string, int32, error) {
	tenantID := p9context.TenantID(ctx)

	offset := int32(0)
	if params.PageToken != "" {
		parsed, err := strconv.ParseInt(params.PageToken, 10, 32)
		if err == nil {
			offset = int32(parsed)
		}
	}

	// Count total matching records
	var totalCount int32
	countRow := r.d.Pool.QueryRow(ctx, `
		SELECT COUNT(*) FROM inspections
		WHERE tenant_id = $1
			AND is_active = TRUE
			AND deleted_at IS NULL
			AND ($2::TEXT = '' OR farm_id = $2)
			AND ($3::TEXT = '' OR field_id = $3)
			AND ($4::TEXT = '' OR inspector_id = $4)
			AND ($5::TEXT = '' OR $5 = 'INSPECTION_STATUS_UNSPECIFIED' OR status = $5)`,
		tenantID,
		params.FarmID,
		params.FieldID,
		params.InspectorID,
		params.Status,
	)
	if err := countRow.Scan(&totalCount); err != nil {
		r.log.Errorw("msg", "failed to count inspections", "error", err)
		return nil, "", 0, errors.InternalServer("INSPECTION_COUNT_FAILED", fmt.Sprintf("failed to count inspections: %v", err))
	}

	// Fetch the page
	rows, err := r.d.Pool.Query(ctx, `
		SELECT id, tenant_id, field_id, farm_id, inspector_id, status,
		       findings, photos, recommendations, issues, health_score,
		       notes, inspection_date, created_at, updated_at
		FROM inspections
		WHERE tenant_id = $1
			AND is_active = TRUE
			AND deleted_at IS NULL
			AND ($2::TEXT = '' OR farm_id = $2)
			AND ($3::TEXT = '' OR field_id = $3)
			AND ($4::TEXT = '' OR inspector_id = $4)
			AND ($5::TEXT = '' OR $5 = 'INSPECTION_STATUS_UNSPECIFIED' OR status = $5)
		ORDER BY created_at DESC
		LIMIT $6 OFFSET $7`,
		tenantID,
		params.FarmID,
		params.FieldID,
		params.InspectorID,
		params.Status,
		params.PageSize,
		offset,
	)
	if err != nil {
		r.log.Errorw("msg", "failed to list inspections", "error", err)
		return nil, "", 0, errors.InternalServer("INSPECTION_LIST_FAILED", fmt.Sprintf("failed to list inspections: %v", err))
	}
	defer rows.Close()

	inspections := make([]*pb.Inspection, 0)
	for rows.Next() {
		inspection, err := scanInspectionFromRows(rows)
		if err != nil {
			r.log.Errorw("msg", "failed to scan inspection row", "error", err)
			return nil, "", 0, errors.InternalServer("INSPECTION_SCAN_FAILED", fmt.Sprintf("failed to scan inspection: %v", err))
		}
		inspections = append(inspections, inspection)
	}
	if err := rows.Err(); err != nil {
		return nil, "", 0, errors.InternalServer("INSPECTION_ROWS_ERROR", fmt.Sprintf("row iteration error: %v", err))
	}

	// Compute next page token
	nextPageToken := ""
	nextOffset := offset + params.PageSize
	if nextOffset < totalCount {
		nextPageToken = fmt.Sprintf("%d", nextOffset)
	}

	return inspections, nextPageToken, totalCount, nil
}

// Create inserts a new inspection into the database.
func (r *inspectionRepository) Create(ctx context.Context, inspection *pb.Inspection) (*pb.Inspection, error) {
	tenantID := p9context.TenantID(ctx)

	statusStr := inspection.Status.String()
	if inspection.Status == pb.InspectionStatus_INSPECTION_STATUS_UNSPECIFIED {
		statusStr = "DRAFT"
	}

	// Serialize issues to JSONB
	issuesJSON, err := json.Marshal(inspection.Issues)
	if err != nil {
		return nil, errors.InternalServer("ISSUES_MARSHAL_FAILED", fmt.Sprintf("failed to marshal issues: %v", err))
	}

	var inspectionDate *time.Time
	if inspection.InspectionDate != nil {
		t := inspection.InspectionDate.AsTime()
		inspectionDate = &t
	}

	row := r.d.Pool.QueryRow(ctx, `
		INSERT INTO inspections (
			id, tenant_id, field_id, farm_id, inspector_id, status,
			findings, photos, recommendations, issues, health_score,
			notes, inspection_date, is_active, created_at, updated_at
		) VALUES (
			$1, $2, $3, $4, $5, $6,
			$7, $8, $9, $10, $11,
			$12, $13, TRUE, NOW(), NOW()
		)
		RETURNING id, tenant_id, field_id, farm_id, inspector_id, status,
		          findings, photos, recommendations, issues, health_score,
		          notes, inspection_date, created_at, updated_at`,
		inspection.Id, tenantID, inspection.FieldId, inspection.FarmId,
		inspection.InspectorId, statusStr,
		inspection.Findings, inspection.Photos, inspection.Recommendations,
		issuesJSON, inspection.HealthScore,
		inspection.Notes, inspectionDate,
	)

	created, err := scanInspection(row)
	if err != nil {
		r.log.Errorw("msg", "failed to insert inspection", "error", err)
		return nil, errors.InternalServer("INSPECTION_CREATE_FAILED", fmt.Sprintf("failed to create inspection: %v", err))
	}

	r.log.Infow("msg", "inspection created", "id", created.Id, "tenant_id", tenantID)
	return created, nil
}

// UpdateStatus updates the status of an inspection.
func (r *inspectionRepository) UpdateStatus(ctx context.Context, id string, status string) (*pb.Inspection, error) {
	tenantID := p9context.TenantID(ctx)

	row := r.d.Pool.QueryRow(ctx, `
		UPDATE inspections SET
			status = $3,
			updated_at = NOW()
		WHERE id = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
		RETURNING id, tenant_id, field_id, farm_id, inspector_id, status,
		          findings, photos, recommendations, issues, health_score,
		          notes, inspection_date, created_at, updated_at`,
		id, tenantID, status,
	)

	inspection, err := scanInspection(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("INSPECTION_NOT_FOUND", fmt.Sprintf("inspection not found: %s", id))
		}
		r.log.Errorw("msg", "failed to update inspection status", "id", id, "error", err)
		return nil, errors.InternalServer("INSPECTION_STATUS_UPDATE_FAILED", fmt.Sprintf("failed to update inspection status: %v", err))
	}

	r.log.Infow("msg", "inspection status updated", "id", inspection.Id, "status", status)
	return inspection, nil
}

// ---------- Scan helpers ----------

func scanInspection(row pgx.Row) (*pb.Inspection, error) {
	var (
		id, tenantID, fieldID, farmID, inspectorID, status string
		findings, notes                                    string
		photos, recommendations                            []string
		issuesJSON                                         []byte
		healthScore                                        float64
		inspectionDate                                     *time.Time
		createdAt, updatedAt                               time.Time
	)

	err := row.Scan(
		&id, &tenantID, &fieldID, &farmID, &inspectorID, &status,
		&findings, &photos, &recommendations, &issuesJSON, &healthScore,
		&notes, &inspectionDate, &createdAt, &updatedAt,
	)
	if err != nil {
		return nil, err
	}

	return buildInspectionProto(
		id, fieldID, farmID, inspectorID, status,
		findings, photos, recommendations, issuesJSON, healthScore,
		notes, inspectionDate, createdAt, updatedAt,
	), nil
}

func scanInspectionFromRows(rows pgx.Rows) (*pb.Inspection, error) {
	var (
		id, tenantID, fieldID, farmID, inspectorID, status string
		findings, notes                                    string
		photos, recommendations                            []string
		issuesJSON                                         []byte
		healthScore                                        float64
		inspectionDate                                     *time.Time
		createdAt, updatedAt                               time.Time
	)

	err := rows.Scan(
		&id, &tenantID, &fieldID, &farmID, &inspectorID, &status,
		&findings, &photos, &recommendations, &issuesJSON, &healthScore,
		&notes, &inspectionDate, &createdAt, &updatedAt,
	)
	if err != nil {
		return nil, err
	}

	return buildInspectionProto(
		id, fieldID, farmID, inspectorID, status,
		findings, photos, recommendations, issuesJSON, healthScore,
		notes, inspectionDate, createdAt, updatedAt,
	), nil
}

// buildInspectionProto constructs a proto Inspection from scanned fields.
func buildInspectionProto(
	id, fieldID, farmID, inspectorID, status string,
	findings string, photos, recommendations []string, issuesJSON []byte, healthScore float64,
	notes string, inspectionDate *time.Time, createdAt, updatedAt time.Time,
) *pb.Inspection {
	inspection := &pb.Inspection{
		Id:              id,
		FieldId:         fieldID,
		FarmId:          farmID,
		InspectorId:     inspectorID,
		Status:          parseInspectionStatus(status),
		Findings:        findings,
		Photos:          photos,
		Recommendations: recommendations,
		HealthScore:     healthScore,
		Notes:           notes,
		CreatedAt:       timestamppb.New(createdAt),
		UpdatedAt:       timestamppb.New(updatedAt),
	}

	if inspectionDate != nil {
		inspection.InspectionDate = timestamppb.New(*inspectionDate)
	}

	// Unmarshal JSONB issues
	if len(issuesJSON) > 0 {
		var issues []*pb.InspectionIssue
		if err := json.Unmarshal(issuesJSON, &issues); err == nil {
			inspection.Issues = issues
		}
	}

	return inspection
}

// parseInspectionStatus converts a string status back to the proto enum.
func parseInspectionStatus(s string) pb.InspectionStatus {
	switch s {
	case "INSPECTION_STATUS_DRAFT", "DRAFT":
		return pb.InspectionStatus_INSPECTION_STATUS_DRAFT
	case "INSPECTION_STATUS_SUBMITTED", "SUBMITTED":
		return pb.InspectionStatus_INSPECTION_STATUS_SUBMITTED
	case "INSPECTION_STATUS_REVIEWED", "REVIEWED":
		return pb.InspectionStatus_INSPECTION_STATUS_REVIEWED
	default:
		return pb.InspectionStatus_INSPECTION_STATUS_UNSPECIFIED
	}
}
