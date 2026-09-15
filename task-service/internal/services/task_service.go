package services

import (
	"context"
	"strings"

	"github.com/jackc/pgx/v5/pgxpool"
	"google.golang.org/protobuf/types/known/fieldmaskpb"
	"google.golang.org/protobuf/types/known/timestamppb"

	pb "p9e.in/samavaya/agriculture/task-service/api/v1"
	"p9e.in/samavaya/agriculture/task-service/internal/repositories"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/outbox"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"
)

// ListTasksInput holds the filter parameters for listing tasks.
type ListTasksInput struct {
	FarmID     string
	FieldID    string
	AssignedTo string
	Status     pb.TaskStatus
	Priority   pb.TaskPriority
	PageSize   int32
	PageToken  string
}

// CreateTaskInput holds the parameters for creating a task.
type CreateTaskInput struct {
	Title       string
	Description string
	Priority    pb.TaskPriority
	AssignedTo  string
	FarmID      string
	FieldID     string
	DueDate     *timestamppb.Timestamp
	CreatedBy   string
}

// UpdateTaskInput holds the parameters for updating a task.
type UpdateTaskInput struct {
	ID          string
	Title       string
	Description string
	Status      pb.TaskStatus
	Priority    pb.TaskPriority
	AssignedTo  string
	FieldID     string
	DueDate     *timestamppb.Timestamp
	UpdateMask  *fieldmaskpb.FieldMask
}

// TaskService defines the business logic interface for task operations.
type TaskService interface {
	GetTask(ctx context.Context, id string) (*pb.Task, error)
	ListTasks(ctx context.Context, input ListTasksInput) ([]*pb.Task, string, int32, error)
	CreateTask(ctx context.Context, input CreateTaskInput) (*pb.Task, error)
	UpdateTask(ctx context.Context, input UpdateTaskInput) (*pb.Task, error)
	DeleteTask(ctx context.Context, id string) error
}

// taskService is the concrete implementation of TaskService.
type taskService struct {
	repo      repositories.TaskRepository
	outboxPub *outbox.Publisher
	pool      *pgxpool.Pool
	logger    *p9log.Helper
}

// NewTaskService creates a new TaskService instance.
func NewTaskService(repo repositories.TaskRepository, pub *outbox.Publisher, pool *pgxpool.Pool, logger p9log.Logger) TaskService {
	return &taskService{
		repo:      repo,
		outboxPub: pub,
		pool:      pool,
		logger:    p9log.NewHelper(p9log.With(logger, "component", "TaskService")),
	}
}

// GetTask retrieves a task by ID.
func (s *taskService) GetTask(ctx context.Context, id string) (*pb.Task, error) {
	if strings.TrimSpace(id) == "" {
		return nil, errors.BadRequest("INVALID_ID", "id is required")
	}

	task, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}

	return task, nil
}

// ListTasks retrieves a filtered, paginated list of tasks.
func (s *taskService) ListTasks(ctx context.Context, input ListTasksInput) ([]*pb.Task, string, int32, error) {
	pageSize := input.PageSize
	if pageSize <= 0 {
		pageSize = 50
	}
	if pageSize > 200 {
		pageSize = 200
	}

	tasks, nextPageToken, totalCount, err := s.repo.List(ctx, repositories.ListTasksParams{
		FarmID:     input.FarmID,
		FieldID:    input.FieldID,
		AssignedTo: input.AssignedTo,
		Status:     input.Status.String(),
		Priority:   input.Priority.String(),
		PageSize:   pageSize,
		PageToken:  input.PageToken,
	})
	if err != nil {
		return nil, "", 0, err
	}

	return tasks, nextPageToken, totalCount, nil
}

// CreateTask creates a new task.
func (s *taskService) CreateTask(ctx context.Context, input CreateTaskInput) (*pb.Task, error) {
	if strings.TrimSpace(input.Title) == "" {
		return nil, errors.BadRequest("MISSING_TITLE", "title is required")
	}
	if strings.TrimSpace(input.FarmID) == "" {
		return nil, errors.BadRequest("MISSING_FARM_ID", "farm_id is required")
	}

	userID := input.CreatedBy
	if strings.TrimSpace(userID) == "" {
		userID = p9context.UserID(ctx)
	}
	if strings.TrimSpace(userID) == "" {
		return nil, errors.BadRequest("MISSING_USER_ID", "user_id is required to create a task")
	}

	now := timestamppb.Now()
	id := ulid.NewString()

	priority := input.Priority
	if priority == pb.TaskPriority_TASK_PRIORITY_UNSPECIFIED {
		priority = pb.TaskPriority_TASK_PRIORITY_MEDIUM
	}

	task := &pb.Task{
		Id:          id,
		Title:       input.Title,
		Description: input.Description,
		Status:      pb.TaskStatus_TASK_STATUS_PENDING,
		Priority:    priority,
		AssignedTo:  input.AssignedTo,
		FarmId:      input.FarmID,
		FieldId:     input.FieldID,
		DueDate:     input.DueDate,
		CreatedAt:   now,
		UpdatedAt:   now,
	}

	created, err := s.repo.Create(ctx, task, userID)
	if err != nil {
		s.logger.Errorf("CreateTask failed: %v", err)
		return nil, err
	}

	s.logger.Infof("Task created: id=%s title=%s farm=%s", created.Id, created.Title, created.FarmId)
	return created, nil
}

// UpdateTask updates an existing task.
func (s *taskService) UpdateTask(ctx context.Context, input UpdateTaskInput) (*pb.Task, error) {
	if strings.TrimSpace(input.ID) == "" {
		return nil, errors.BadRequest("INVALID_ID", "id is required")
	}

	// Fetch the existing task to apply partial updates.
	existing, err := s.repo.GetByID(ctx, input.ID)
	if err != nil {
		return nil, err
	}

	// Apply field mask or full update.
	if input.UpdateMask != nil && len(input.UpdateMask.GetPaths()) > 0 {
		for _, path := range input.UpdateMask.GetPaths() {
			switch path {
			case "title":
				existing.Title = input.Title
			case "description":
				existing.Description = input.Description
			case "status":
				existing.Status = input.Status
			case "priority":
				existing.Priority = input.Priority
			case "assigned_to":
				existing.AssignedTo = input.AssignedTo
			case "field_id":
				existing.FieldId = input.FieldID
			case "due_date":
				existing.DueDate = input.DueDate
			}
		}
	} else {
		// Full update: apply all non-zero fields.
		if input.Title != "" {
			existing.Title = input.Title
		}
		if input.Description != "" {
			existing.Description = input.Description
		}
		if input.Status != pb.TaskStatus_TASK_STATUS_UNSPECIFIED {
			existing.Status = input.Status
		}
		if input.Priority != pb.TaskPriority_TASK_PRIORITY_UNSPECIFIED {
			existing.Priority = input.Priority
		}
		if input.AssignedTo != "" {
			existing.AssignedTo = input.AssignedTo
		}
		if input.FieldID != "" {
			existing.FieldId = input.FieldID
		}
		if input.DueDate != nil {
			existing.DueDate = input.DueDate
		}
	}

	existing.UpdatedAt = timestamppb.Now()

	updated, err := s.repo.Update(ctx, existing)
	if err != nil {
		s.logger.Errorf("UpdateTask failed: %v", err)
		return nil, err
	}

	s.logger.Infof("Task updated: id=%s", updated.Id)
	return updated, nil
}

// DeleteTask soft-deletes a task by ID.
func (s *taskService) DeleteTask(ctx context.Context, id string) error {
	if strings.TrimSpace(id) == "" {
		return errors.BadRequest("INVALID_ID", "id is required")
	}

	if err := s.repo.Delete(ctx, id); err != nil {
		s.logger.Errorf("DeleteTask failed: %v", err)
		return err
	}

	s.logger.Infof("Task deleted: id=%s", id)
	return nil
}
