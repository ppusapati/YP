package services

import (
	"context"
	"strings"

	"google.golang.org/protobuf/types/known/timestamppb"

	pb "p9e.in/samavaya/agriculture/agronomy-service/api/v1"
	"p9e.in/samavaya/agriculture/agronomy-service/repositories"
	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/outbox"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"
)

// ListInspectionsInput holds the filter parameters for listing inspections.
type ListInspectionsInput struct {
	FarmID      string
	FieldID     string
	InspectorID string
	Status      pb.InspectionStatus
	PageSize    int32
	PageToken   string
}

// InspectionService defines the business logic interface for inspection operations.
type InspectionService interface {
	GetInspection(ctx context.Context, id string) (*pb.Inspection, error)
	ListInspections(ctx context.Context, input ListInspectionsInput) ([]*pb.Inspection, string, int32, error)
	CreateInspection(ctx context.Context, req *pb.CreateInspectionRequest, inspectorID string) (*pb.Inspection, error)
	SubmitInspection(ctx context.Context, id string) (*pb.Inspection, error)
}

// inspectionService is the concrete implementation of InspectionService.
type inspectionService struct {
	deps      deps.ServiceDeps
	repo      repositories.InspectionRepository
	outboxPub *outbox.Publisher
	logger    *p9log.Helper
}

// NewInspectionService creates a new InspectionService instance.
func NewInspectionService(d deps.ServiceDeps, repo repositories.InspectionRepository, outboxPub *outbox.Publisher) InspectionService {
	return &inspectionService{
		deps:      d,
		repo:      repo,
		outboxPub: outboxPub,
		logger:    p9log.NewHelper(p9log.With(d.Log, "component", "InspectionService")),
	}
}

// GetInspection retrieves a single inspection by ID.
func (s *inspectionService) GetInspection(ctx context.Context, id string) (*pb.Inspection, error) {
	if strings.TrimSpace(id) == "" {
		return nil, errors.BadRequest("INVALID_ID", "id is required")
	}

	inspection, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}

	return inspection, nil
}

// ListInspections retrieves inspections with filtering and pagination.
func (s *inspectionService) ListInspections(ctx context.Context, input ListInspectionsInput) ([]*pb.Inspection, string, int32, error) {
	pageSize := input.PageSize
	if pageSize <= 0 {
		pageSize = 50
	}
	if pageSize > 200 {
		pageSize = 200
	}
	input.PageSize = pageSize

	inspections, nextPageToken, totalCount, err := s.repo.List(ctx, repositories.InspectionListParams{
		FarmID:      input.FarmID,
		FieldID:     input.FieldID,
		InspectorID: input.InspectorID,
		Status:      input.Status.String(),
		PageSize:    pageSize,
		PageToken:   input.PageToken,
	})
	if err != nil {
		return nil, "", 0, err
	}

	return inspections, nextPageToken, totalCount, nil
}

// CreateInspection creates a new inspection record.
func (s *inspectionService) CreateInspection(ctx context.Context, req *pb.CreateInspectionRequest, inspectorID string) (*pb.Inspection, error) {
	if strings.TrimSpace(req.GetFieldId()) == "" {
		return nil, errors.BadRequest("INVALID_FIELD_ID", "field_id is required")
	}
	if strings.TrimSpace(req.GetFarmId()) == "" {
		return nil, errors.BadRequest("INVALID_FARM_ID", "farm_id is required")
	}

	if strings.TrimSpace(inspectorID) == "" {
		inspectorID = p9context.UserID(ctx)
	}
	if strings.TrimSpace(inspectorID) == "" {
		return nil, errors.BadRequest("MISSING_INSPECTOR", "authenticated user is required to create an inspection")
	}

	now := timestamppb.Now()

	inspectionDate := req.GetInspectionDate()
	if inspectionDate == nil {
		inspectionDate = now
	}

	inspection := &pb.Inspection{
		Id:              ulid.NewString(),
		FieldId:         req.GetFieldId(),
		FarmId:          req.GetFarmId(),
		InspectorId:     inspectorID,
		Status:          pb.InspectionStatus_INSPECTION_STATUS_DRAFT,
		Findings:        req.GetFindings(),
		Photos:          req.GetPhotos(),
		Recommendations: req.GetRecommendations(),
		Issues:          req.GetIssues(),
		HealthScore:     req.GetHealthScore(),
		Notes:           req.GetNotes(),
		InspectionDate:  inspectionDate,
		CreatedAt:       now,
		UpdatedAt:       now,
	}

	created, err := s.repo.Create(ctx, inspection)
	if err != nil {
		s.logger.Errorf("failed to create inspection: %v", err)
		return nil, err
	}

	s.logger.Infof("Inspection created: id=%s field=%s inspector=%s", created.Id, created.FieldId, created.InspectorId)

	return created, nil
}

// SubmitInspection transitions an inspection from DRAFT to SUBMITTED status.
func (s *inspectionService) SubmitInspection(ctx context.Context, id string) (*pb.Inspection, error) {
	if strings.TrimSpace(id) == "" {
		return nil, errors.BadRequest("INVALID_ID", "id is required")
	}

	// Fetch the current inspection to validate status
	existing, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}

	if existing.Status != pb.InspectionStatus_INSPECTION_STATUS_DRAFT {
		return nil, errors.BadRequest("INVALID_STATUS", "only inspections in DRAFT status can be submitted")
	}

	inspection, err := s.repo.UpdateStatus(ctx, id, pb.InspectionStatus_INSPECTION_STATUS_SUBMITTED.String())
	if err != nil {
		s.logger.Errorf("failed to submit inspection: %v", err)
		return nil, err
	}

	s.logger.Infof("Inspection submitted: id=%s", inspection.Id)

	return inspection, nil
}
