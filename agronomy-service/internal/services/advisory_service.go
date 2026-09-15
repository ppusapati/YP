package services

import (
	"context"
	"strings"

	"google.golang.org/protobuf/types/known/timestamppb"

	pb "p9e.in/samavaya/agriculture/agronomy-service/api/v1"
	"p9e.in/samavaya/agriculture/agronomy-service/internal/repositories"
	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/outbox"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"
)

// ListAdvisoriesInput holds the filter parameters for listing advisories.
type ListAdvisoriesInput struct {
	FarmID    string
	FieldID   string
	CropType  string
	Severity  pb.AdvisorySeverity
	Region    string
	PageSize  int32
	PageToken string
}

// AdvisoryService defines the business logic interface for advisory operations.
type AdvisoryService interface {
	GetAdvisory(ctx context.Context, id string) (*pb.Advisory, error)
	ListAdvisories(ctx context.Context, input ListAdvisoriesInput) ([]*pb.Advisory, string, int32, error)
	CreateAdvisory(ctx context.Context, req *pb.CreateAdvisoryRequest) (*pb.Advisory, error)
}

// advisoryService is the concrete implementation of AdvisoryService.
type advisoryService struct {
	deps      deps.ServiceDeps
	repo      repositories.AdvisoryRepository
	outboxPub *outbox.Publisher
	logger    *p9log.Helper
}

// NewAdvisoryService creates a new AdvisoryService instance.
func NewAdvisoryService(d deps.ServiceDeps, repo repositories.AdvisoryRepository, outboxPub *outbox.Publisher) AdvisoryService {
	return &advisoryService{
		deps:      d,
		repo:      repo,
		outboxPub: outboxPub,
		logger:    p9log.NewHelper(p9log.With(d.Log, "component", "AdvisoryService")),
	}
}

// GetAdvisory retrieves a single advisory by ID.
func (s *advisoryService) GetAdvisory(ctx context.Context, id string) (*pb.Advisory, error) {
	if strings.TrimSpace(id) == "" {
		return nil, errors.BadRequest("INVALID_ID", "id is required")
	}

	advisory, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}

	return advisory, nil
}

// ListAdvisories retrieves advisories with filtering and pagination.
func (s *advisoryService) ListAdvisories(ctx context.Context, input ListAdvisoriesInput) ([]*pb.Advisory, string, int32, error) {
	pageSize := input.PageSize
	if pageSize <= 0 {
		pageSize = 50
	}
	if pageSize > 200 {
		pageSize = 200
	}
	input.PageSize = pageSize

	advisories, nextPageToken, totalCount, err := s.repo.List(ctx, repositories.AdvisoryListParams{
		FarmID:    input.FarmID,
		FieldID:   input.FieldID,
		CropType:  input.CropType,
		Severity:  input.Severity.String(),
		Region:    input.Region,
		PageSize:  pageSize,
		PageToken: input.PageToken,
	})
	if err != nil {
		return nil, "", 0, err
	}

	return advisories, nextPageToken, totalCount, nil
}

// CreateAdvisory creates a new advisory record.
func (s *advisoryService) CreateAdvisory(ctx context.Context, req *pb.CreateAdvisoryRequest) (*pb.Advisory, error) {
	if strings.TrimSpace(req.GetTitle()) == "" {
		return nil, errors.BadRequest("INVALID_TITLE", "title is required")
	}
	if strings.TrimSpace(req.GetContent()) == "" {
		return nil, errors.BadRequest("INVALID_CONTENT", "content is required")
	}

	createdBy := p9context.UserID(ctx)
	if createdBy == "" {
		return nil, errors.BadRequest("MISSING_USER", "authenticated user is required to create an advisory")
	}

	now := timestamppb.Now()

	advisory := &pb.Advisory{
		Id:        ulid.NewString(),
		Title:     req.GetTitle(),
		Content:   req.GetContent(),
		CropType:  req.GetCropType(),
		Severity:  req.GetSeverity(),
		Region:    req.GetRegion(),
		FarmId:    req.GetFarmId(),
		FieldId:   req.GetFieldId(),
		CreatedBy: createdBy,
		CreatedAt: now,
		UpdatedAt: now,
	}

	created, err := s.repo.Create(ctx, advisory)
	if err != nil {
		s.logger.Errorf("failed to create advisory: %v", err)
		return nil, err
	}

	s.logger.Infof("Advisory created: id=%s title=%s created_by=%s", created.Id, created.Title, created.CreatedBy)

	return created, nil
}
