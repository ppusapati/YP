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
	Update(ctx context.Context, inspection *pb.Inspection, baseVersion int64) (*pb.Inspection, int64, error)
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
		return nil, errors.InternalServer("INSPECTION_GET_FAILED", "an internal error occurred")
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
		return nil, "", 0, errors.InternalServer("INSPECTION_COUNT_FAILED", "an internal error occurred")
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
		return nil, "", 0, errors.InternalServer("INSPECTION_LIST_FAILED", "an internal error occurred")
	}
	defer rows.Close()

	inspections := make([]*pb.Inspection, 0)
	for rows.Next() {
		inspection, err := scanInspectionFromRows(rows)
		if err != nil {
			r.log.Errorw("msg", "failed to scan inspection row", "error", err)
			return nil, "", 0, errors.InternalServer("INSPECTION_SCAN_FAILED", "an internal error occurred")
		}
		inspections = append(inspections, inspection)
	}
	if err := rows.Err(); err != nil {
		r.log.Errorw("msg", "row iteration error", "error", err)
		return nil, "", 0, errors.InternalServer("INSPECTION_ROWS_ERROR", "an internal error occurred")
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
		r.log.Errorw("msg", "failed to marshal issues", "error", err)
		return nil, errors.InternalServer("ISSUES_MARSHAL_FAILED", "an internal error occurred")
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
		return nil, errors.InternalServer("INSPECTION_CREATE_FAILED", "an internal error occurred")
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
		return nil, errors.InternalServer("INSPECTION_STATUS_UPDATE_FAILED", "an internal error occurred")
	}

	r.log.Infow("msg", "inspection status updated", "id", inspection.Id, "status", status)
	return inspection, nil
}

// ErrInspectionVersionConflict means the update lost a race with a newer one.
//
// Distinct from "not found": the caller's edit is fine, it is just based on a
// version that has been superseded, and the right response is to show them
// what replaced it rather than to report a failure.
var ErrInspectionVersionConflict = errors.Conflict(
	"INSPECTION_VERSION_CONFLICT",
	"this inspection was changed by someone else while you were editing",
)

// Update writes an edited draft.
//
// `base_version` of 0 means the caller did not check, which is accepted: a
// single agronomist correcting a typo should not have to participate in the
// versioning. A non-zero base that has been overtaken is refused, so a
// collaborative editor cannot silently replace the edit that beat it — which
// is the same rule the in-memory session applies, held here as well because
// the session does not survive a process restart and the database does.
func (r *inspectionRepository) Update(ctx context.Context, in *pb.Inspection, baseVersion int64) (*pb.Inspection, int64, error) {
	tenantID := p9context.TenantID(ctx)

	issuesJSON, err := json.Marshal(in.Issues)
	if err != nil {
		r.log.Errorw("msg", "failed to marshal issues", "error", err)
		return nil, 0, errors.InternalServer("ISSUES_MARSHAL_FAILED", "an internal error occurred")
	}

	// `($9 = 0 OR version = $9)` is the whole conflict check, done in the
	// UPDATE rather than as a read-then-write: two editors saving at the same
	// instant would both pass a separate SELECT and the second would still
	// overwrite the first.
	row := r.d.Pool.QueryRow(ctx, `
		UPDATE inspections SET
			findings        = $3,
			photos          = $4,
			recommendations = $5,
			issues          = $6,
			health_score    = $7,
			notes           = $8,
			version         = version + 1,
			updated_at      = NOW()
		WHERE id = $1 AND tenant_id = $2
		  AND is_active = TRUE AND deleted_at IS NULL
		  AND ($9 = 0 OR version = $9)
		RETURNING id, tenant_id, field_id, farm_id, inspector_id, status,
		          findings, photos, recommendations, issues, health_score,
		          notes, inspection_date, created_at, updated_at, version`,
		in.Id, tenantID,
		in.Findings, in.Photos, in.Recommendations,
		issuesJSON, in.HealthScore, in.Notes,
		baseVersion,
	)

	updated, version, err := scanInspectionWithVersion(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			// Either the inspection is gone or the version moved. Told apart
			// with a second read, because "somebody edited this" and "this no
			// longer exists" need different things from the person editing.
			if _, getErr := r.GetByID(ctx, in.Id); getErr == nil {
				return nil, 0, ErrInspectionVersionConflict
			}
			return nil, 0, errors.NotFound("INSPECTION_NOT_FOUND", fmt.Sprintf("inspection not found: %s", in.Id))
		}
		r.log.Errorw("msg", "failed to update inspection", "id", in.Id, "error", err)
		return nil, 0, errors.InternalServer("INSPECTION_UPDATE_FAILED", "an internal error occurred")
	}

	r.log.Infow("msg", "inspection updated", "id", updated.Id, "version", version)
	return updated, version, nil
}

// scanInspectionWithVersion scans a row that carries the version column.
func scanInspectionWithVersion(row pgx.Row) (*pb.Inspection, int64, error) {
	var (
		id, tenantID, fieldID, farmID, inspectorID, status string
		findings, notes                                    string
		photos, recommendations                            []string
		issuesJSON                                         []byte
		healthScore                                        float64
		inspectionDate                                     *time.Time
		createdAt, updatedAt                               time.Time
		version                                            int64
	)

	if err := row.Scan(
		&id, &tenantID, &fieldID, &farmID, &inspectorID, &status,
		&findings, &photos, &recommendations, &issuesJSON, &healthScore,
		&notes, &inspectionDate, &createdAt, &updatedAt, &version,
	); err != nil {
		return nil, 0, err
	}

	var issues []*pb.InspectionIssue
	if len(issuesJSON) > 0 {
		_ = json.Unmarshal(issuesJSON, &issues)
	}

	out := &pb.Inspection{
		Id:              id,
		FieldId:         fieldID,
		FarmId:          farmID,
		InspectorId:     inspectorID,
		Status:          pb.InspectionStatus(pb.InspectionStatus_value[status]),
		Findings:        findings,
		Photos:          photos,
		Recommendations: recommendations,
		Issues:          issues,
		HealthScore:     healthScore,
		Notes:           notes,
		CreatedAt:       timestamppb.New(createdAt),
		UpdatedAt:       timestamppb.New(updatedAt),
	}
	if inspectionDate != nil {
		out.InspectionDate = timestamppb.New(*inspectionDate)
	}
	return out, version, nil
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
