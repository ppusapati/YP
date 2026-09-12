package repositories

import (
	"context"
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

// AdvisoryListParams holds query parameters for listing advisories.
type AdvisoryListParams struct {
	FarmID    string
	FieldID   string
	CropType  string
	Severity  string
	Region    string
	PageSize  int32
	PageToken string
}

// AdvisoryRepository defines the interface for advisory persistence operations.
type AdvisoryRepository interface {
	GetByID(ctx context.Context, id string) (*pb.Advisory, error)
	List(ctx context.Context, params AdvisoryListParams) ([]*pb.Advisory, string, int32, error)
	Create(ctx context.Context, advisory *pb.Advisory) (*pb.Advisory, error)
}

// advisoryRepository is the concrete implementation of AdvisoryRepository.
type advisoryRepository struct {
	d   deps.ServiceDeps
	log *p9log.Helper
}

// NewAdvisoryRepository creates a new AdvisoryRepository.
func NewAdvisoryRepository(d deps.ServiceDeps) AdvisoryRepository {
	return &advisoryRepository{
		d:   d,
		log: p9log.NewHelper(p9log.With(d.Log, "component", "AdvisoryRepository")),
	}
}

// GetByID retrieves an advisory by its ID.
func (r *advisoryRepository) GetByID(ctx context.Context, id string) (*pb.Advisory, error) {
	tenantID := p9context.TenantID(ctx)

	row := r.d.Pool.QueryRow(ctx, `
		SELECT id, tenant_id, title, content, crop_type, severity, region,
		       farm_id, field_id, created_by, created_at, updated_at
		FROM advisories
		WHERE id = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL`,
		id, tenantID,
	)

	advisory, err := scanAdvisory(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("ADVISORY_NOT_FOUND", fmt.Sprintf("advisory not found: %s", id))
		}
		r.log.Errorw("msg", "failed to get advisory", "id", id, "error", err)
		return nil, errors.InternalServer("ADVISORY_GET_FAILED", "an internal error occurred")
	}

	return advisory, nil
}

// List retrieves advisories with filtering and pagination.
func (r *advisoryRepository) List(ctx context.Context, params AdvisoryListParams) ([]*pb.Advisory, string, int32, error) {
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
		SELECT COUNT(*) FROM advisories
		WHERE tenant_id = $1
			AND is_active = TRUE
			AND deleted_at IS NULL
			AND ($2::TEXT = '' OR farm_id = $2)
			AND ($3::TEXT = '' OR field_id = $3)
			AND ($4::TEXT = '' OR crop_type = $4)
			AND ($5::TEXT = '' OR $5 = 'ADVISORY_SEVERITY_UNSPECIFIED' OR severity = $5)
			AND ($6::TEXT = '' OR region = $6)`,
		tenantID,
		params.FarmID,
		params.FieldID,
		params.CropType,
		params.Severity,
		params.Region,
	)
	if err := countRow.Scan(&totalCount); err != nil {
		r.log.Errorw("msg", "failed to count advisories", "error", err)
		return nil, "", 0, errors.InternalServer("ADVISORY_COUNT_FAILED", "an internal error occurred")
	}

	// Fetch the page
	rows, err := r.d.Pool.Query(ctx, `
		SELECT id, tenant_id, title, content, crop_type, severity, region,
		       farm_id, field_id, created_by, created_at, updated_at
		FROM advisories
		WHERE tenant_id = $1
			AND is_active = TRUE
			AND deleted_at IS NULL
			AND ($2::TEXT = '' OR farm_id = $2)
			AND ($3::TEXT = '' OR field_id = $3)
			AND ($4::TEXT = '' OR crop_type = $4)
			AND ($5::TEXT = '' OR $5 = 'ADVISORY_SEVERITY_UNSPECIFIED' OR severity = $5)
			AND ($6::TEXT = '' OR region = $6)
		ORDER BY created_at DESC
		LIMIT $7 OFFSET $8`,
		tenantID,
		params.FarmID,
		params.FieldID,
		params.CropType,
		params.Severity,
		params.Region,
		params.PageSize,
		offset,
	)
	if err != nil {
		r.log.Errorw("msg", "failed to list advisories", "error", err)
		return nil, "", 0, errors.InternalServer("ADVISORY_LIST_FAILED", "an internal error occurred")
	}
	defer rows.Close()

	advisories := make([]*pb.Advisory, 0)
	for rows.Next() {
		advisory, err := scanAdvisoryFromRows(rows)
		if err != nil {
			r.log.Errorw("msg", "failed to scan advisory row", "error", err)
			return nil, "", 0, errors.InternalServer("ADVISORY_SCAN_FAILED", "an internal error occurred")
		}
		advisories = append(advisories, advisory)
	}
	if err := rows.Err(); err != nil {
		r.log.Errorw("msg", "row iteration error", "error", err)
		return nil, "", 0, errors.InternalServer("ADVISORY_ROWS_ERROR", "an internal error occurred")
	}

	// Compute next page token
	nextPageToken := ""
	nextOffset := offset + params.PageSize
	if nextOffset < totalCount {
		nextPageToken = fmt.Sprintf("%d", nextOffset)
	}

	return advisories, nextPageToken, totalCount, nil
}

// Create inserts a new advisory into the database.
func (r *advisoryRepository) Create(ctx context.Context, advisory *pb.Advisory) (*pb.Advisory, error) {
	tenantID := p9context.TenantID(ctx)

	severityStr := advisory.Severity.String()
	if advisory.Severity == pb.AdvisorySeverity_ADVISORY_SEVERITY_UNSPECIFIED {
		severityStr = "LOW"
	}

	row := r.d.Pool.QueryRow(ctx, `
		INSERT INTO advisories (
			id, tenant_id, title, content, crop_type, severity, region,
			farm_id, field_id, created_by, is_active, created_at, updated_at
		) VALUES (
			$1, $2, $3, $4, $5, $6, $7,
			$8, $9, $10, TRUE, NOW(), NOW()
		)
		RETURNING id, tenant_id, title, content, crop_type, severity, region,
		          farm_id, field_id, created_by, created_at, updated_at`,
		advisory.Id, tenantID, advisory.Title, advisory.Content, advisory.CropType,
		severityStr, advisory.Region, advisory.FarmId, advisory.FieldId, advisory.CreatedBy,
	)

	created, err := scanAdvisory(row)
	if err != nil {
		r.log.Errorw("msg", "failed to insert advisory", "error", err)
		return nil, errors.InternalServer("ADVISORY_CREATE_FAILED", "an internal error occurred")
	}

	r.log.Infow("msg", "advisory created", "id", created.Id, "tenant_id", tenantID)
	return created, nil
}

// ---------- Scan helpers ----------

func scanAdvisory(row pgx.Row) (*pb.Advisory, error) {
	var (
		id, tenantID, title, content, cropType, severity, region string
		farmID, fieldID, createdBy                               string
		createdAt, updatedAt                                     time.Time
	)

	err := row.Scan(
		&id, &tenantID, &title, &content, &cropType, &severity, &region,
		&farmID, &fieldID, &createdBy, &createdAt, &updatedAt,
	)
	if err != nil {
		return nil, err
	}

	return &pb.Advisory{
		Id:        id,
		Title:     title,
		Content:   content,
		CropType:  cropType,
		Severity:  parseAdvisorySeverity(severity),
		Region:    region,
		FarmId:    farmID,
		FieldId:   fieldID,
		CreatedBy: createdBy,
		CreatedAt: timestamppb.New(createdAt),
		UpdatedAt: timestamppb.New(updatedAt),
	}, nil
}

func scanAdvisoryFromRows(rows pgx.Rows) (*pb.Advisory, error) {
	var (
		id, tenantID, title, content, cropType, severity, region string
		farmID, fieldID, createdBy                               string
		createdAt, updatedAt                                     time.Time
	)

	err := rows.Scan(
		&id, &tenantID, &title, &content, &cropType, &severity, &region,
		&farmID, &fieldID, &createdBy, &createdAt, &updatedAt,
	)
	if err != nil {
		return nil, err
	}

	return &pb.Advisory{
		Id:        id,
		Title:     title,
		Content:   content,
		CropType:  cropType,
		Severity:  parseAdvisorySeverity(severity),
		Region:    region,
		FarmId:    farmID,
		FieldId:   fieldID,
		CreatedBy: createdBy,
		CreatedAt: timestamppb.New(createdAt),
		UpdatedAt: timestamppb.New(updatedAt),
	}, nil
}

// parseAdvisorySeverity converts a string severity back to the proto enum.
func parseAdvisorySeverity(s string) pb.AdvisorySeverity {
	switch s {
	case "ADVISORY_SEVERITY_LOW", "LOW":
		return pb.AdvisorySeverity_ADVISORY_SEVERITY_LOW
	case "ADVISORY_SEVERITY_MEDIUM", "MEDIUM":
		return pb.AdvisorySeverity_ADVISORY_SEVERITY_MEDIUM
	case "ADVISORY_SEVERITY_HIGH", "HIGH":
		return pb.AdvisorySeverity_ADVISORY_SEVERITY_HIGH
	case "ADVISORY_SEVERITY_CRITICAL", "CRITICAL":
		return pb.AdvisorySeverity_ADVISORY_SEVERITY_CRITICAL
	default:
		return pb.AdvisorySeverity_ADVISORY_SEVERITY_UNSPECIFIED
	}
}
