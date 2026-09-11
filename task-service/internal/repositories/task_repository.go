package repositories

import (
	"context"
	"fmt"
	"strconv"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	pb "p9e.in/samavaya/agriculture/task-service/api/v1"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"
	"google.golang.org/protobuf/types/known/timestamppb"
)

// ListTasksParams holds the query parameters for listing tasks.
type ListTasksParams struct {
	FarmID     string
	FieldID    string
	AssignedTo string
	Status     string
	Priority   string
	PageSize   int32
	PageToken  string
}

// TaskRepository defines the interface for task persistence operations.
type TaskRepository interface {
	GetByID(ctx context.Context, id string) (*pb.Task, error)
	List(ctx context.Context, params ListTasksParams) ([]*pb.Task, string, int32, error)
	Create(ctx context.Context, task *pb.Task, createdBy string) (*pb.Task, error)
	Update(ctx context.Context, task *pb.Task) (*pb.Task, error)
	Delete(ctx context.Context, id string) error
}

// taskRepository is the concrete implementation of TaskRepository.
type taskRepository struct {
	pool *pgxpool.Pool
	log  *p9log.Helper
}

// NewTaskRepository creates a new TaskRepository.
func NewTaskRepository(pool *pgxpool.Pool, logger p9log.Logger) TaskRepository {
	return &taskRepository{
		pool: pool,
		log:  p9log.NewHelper(p9log.With(logger, "component", "TaskRepository")),
	}
}

// GetByID retrieves a task by its ID.
func (r *taskRepository) GetByID(ctx context.Context, id string) (*pb.Task, error) {
	row := r.pool.QueryRow(ctx, `
		SELECT id, title, description, status, priority,
			assigned_to, farm_id, field_id, due_date,
			created_at, updated_at
		FROM tasks
		WHERE id = $1 AND is_active = TRUE AND deleted_at IS NULL`,
		id,
	)

	task, err := scanTask(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("TASK_NOT_FOUND", fmt.Sprintf("task not found: %s", id))
		}
		r.log.Errorw("msg", "failed to get task", "id", id, "error", err)
		return nil, errors.InternalServer("TASK_GET_FAILED", fmt.Sprintf("failed to get task: %v", err))
	}

	return task, nil
}

// List retrieves a filtered, paginated list of tasks.
func (r *taskRepository) List(ctx context.Context, params ListTasksParams) ([]*pb.Task, string, int32, error) {
	// Parse offset from page token.
	var offset int32
	if params.PageToken != "" {
		parsed, err := strconv.ParseInt(params.PageToken, 10, 32)
		if err == nil {
			offset = int32(parsed)
		}
	}

	// Normalize filter values: treat UNSPECIFIED enum strings as empty.
	status := params.Status
	if status == "TASK_STATUS_UNSPECIFIED" {
		status = ""
	}
	priority := params.Priority
	if priority == "TASK_PRIORITY_UNSPECIFIED" {
		priority = ""
	}

	// Count total matching records.
	var totalCount int32
	countRow := r.pool.QueryRow(ctx, `
		SELECT COUNT(*) FROM tasks
		WHERE is_active = TRUE AND deleted_at IS NULL
			AND ($1::TEXT = '' OR farm_id = $1)
			AND ($2::TEXT = '' OR field_id = $2)
			AND ($3::TEXT = '' OR assigned_to = $3)
			AND ($4::TEXT = '' OR status = $4)
			AND ($5::TEXT = '' OR priority = $5)`,
		params.FarmID,
		params.FieldID,
		params.AssignedTo,
		status,
		priority,
	)
	if err := countRow.Scan(&totalCount); err != nil {
		r.log.Errorw("msg", "failed to count tasks", "error", err)
		return nil, "", 0, errors.InternalServer("TASK_COUNT_FAILED", fmt.Sprintf("failed to count tasks: %v", err))
	}

	// Fetch the page.
	rows, err := r.pool.Query(ctx, `
		SELECT id, title, description, status, priority,
			assigned_to, farm_id, field_id, due_date,
			created_at, updated_at
		FROM tasks
		WHERE is_active = TRUE AND deleted_at IS NULL
			AND ($1::TEXT = '' OR farm_id = $1)
			AND ($2::TEXT = '' OR field_id = $2)
			AND ($3::TEXT = '' OR assigned_to = $3)
			AND ($4::TEXT = '' OR status = $4)
			AND ($5::TEXT = '' OR priority = $5)
		ORDER BY created_at DESC
		LIMIT $6 OFFSET $7`,
		params.FarmID,
		params.FieldID,
		params.AssignedTo,
		status,
		priority,
		params.PageSize,
		offset,
	)
	if err != nil {
		r.log.Errorw("msg", "failed to list tasks", "error", err)
		return nil, "", 0, errors.InternalServer("TASK_LIST_FAILED", fmt.Sprintf("failed to list tasks: %v", err))
	}
	defer rows.Close()

	tasks := make([]*pb.Task, 0)
	for rows.Next() {
		task, err := scanTaskFromRows(rows)
		if err != nil {
			r.log.Errorw("msg", "failed to scan task row", "error", err)
			return nil, "", 0, errors.InternalServer("TASK_SCAN_FAILED", fmt.Sprintf("failed to scan task: %v", err))
		}
		tasks = append(tasks, task)
	}
	if err := rows.Err(); err != nil {
		return nil, "", 0, errors.InternalServer("TASK_ROWS_ERROR", fmt.Sprintf("row iteration error: %v", err))
	}

	// Compute next page token.
	var nextPageToken string
	nextOffset := offset + params.PageSize
	if nextOffset < totalCount {
		nextPageToken = fmt.Sprintf("%d", nextOffset)
	}

	return tasks, nextPageToken, totalCount, nil
}

// Create inserts a new task into the database.
func (r *taskRepository) Create(ctx context.Context, task *pb.Task, createdBy string) (*pb.Task, error) {
	var dueDate *time.Time
	if task.DueDate != nil {
		t := task.DueDate.AsTime()
		dueDate = &t
	}

	row := r.pool.QueryRow(ctx, `
		INSERT INTO tasks (
			id, tenant_id, title, description, status, priority,
			assigned_to, farm_id, field_id, due_date,
			created_by, created_at, updated_at
		) VALUES (
			$1, current_setting('app.tenant_id', true), $2, $3, $4, $5,
			$6, $7, $8, $9,
			$10, NOW(), NOW()
		)
		RETURNING id, title, description, status, priority,
			assigned_to, farm_id, field_id, due_date,
			created_at, updated_at`,
		task.Id,
		task.Title,
		task.Description,
		task.Status.String(),
		task.Priority.String(),
		nullableString(task.AssignedTo),
		task.FarmId,
		nullableString(task.FieldId),
		dueDate,
		createdBy,
	)

	created, err := scanTask(row)
	if err != nil {
		r.log.Errorw("msg", "failed to create task", "error", err)
		return nil, errors.InternalServer("TASK_CREATE_FAILED", fmt.Sprintf("failed to create task: %v", err))
	}

	return created, nil
}

// Update updates an existing task in the database.
func (r *taskRepository) Update(ctx context.Context, task *pb.Task) (*pb.Task, error) {
	var dueDate *time.Time
	if task.DueDate != nil {
		t := task.DueDate.AsTime()
		dueDate = &t
	}

	row := r.pool.QueryRow(ctx, `
		UPDATE tasks SET
			title = $2,
			description = $3,
			status = $4,
			priority = $5,
			assigned_to = $6,
			field_id = $7,
			due_date = $8,
			updated_at = NOW()
		WHERE id = $1 AND is_active = TRUE AND deleted_at IS NULL
		RETURNING id, title, description, status, priority,
			assigned_to, farm_id, field_id, due_date,
			created_at, updated_at`,
		task.Id,
		task.Title,
		task.Description,
		task.Status.String(),
		task.Priority.String(),
		nullableString(task.AssignedTo),
		nullableString(task.FieldId),
		dueDate,
	)

	updated, err := scanTask(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("TASK_NOT_FOUND", fmt.Sprintf("task not found: %s", task.Id))
		}
		r.log.Errorw("msg", "failed to update task", "id", task.Id, "error", err)
		return nil, errors.InternalServer("TASK_UPDATE_FAILED", fmt.Sprintf("failed to update task: %v", err))
	}

	return updated, nil
}

// Delete soft-deletes a task by setting deleted_at and is_active = false.
func (r *taskRepository) Delete(ctx context.Context, id string) error {
	tag, err := r.pool.Exec(ctx, `
		UPDATE tasks SET
			deleted_at = NOW(),
			is_active = FALSE,
			updated_at = NOW()
		WHERE id = $1 AND is_active = TRUE AND deleted_at IS NULL`,
		id,
	)
	if err != nil {
		r.log.Errorw("msg", "failed to delete task", "id", id, "error", err)
		return errors.InternalServer("TASK_DELETE_FAILED", fmt.Sprintf("failed to delete task: %v", err))
	}

	if tag.RowsAffected() == 0 {
		return errors.NotFound("TASK_NOT_FOUND", fmt.Sprintf("task not found: %s", id))
	}

	return nil
}

// ---------- Scan helpers ----------

func scanTask(row pgx.Row) (*pb.Task, error) {
	var (
		id          string
		title       string
		description *string
		status      string
		priority    string
		assignedTo  *string
		farmID      string
		fieldID     *string
		dueDate     *time.Time
		createdAt   time.Time
		updatedAt   *time.Time
	)

	err := row.Scan(
		&id, &title, &description, &status, &priority,
		&assignedTo, &farmID, &fieldID, &dueDate,
		&createdAt, &updatedAt,
	)
	if err != nil {
		return nil, err
	}

	return buildTask(id, title, description, status, priority,
		assignedTo, farmID, fieldID, dueDate, createdAt, updatedAt), nil
}

func scanTaskFromRows(rows pgx.Rows) (*pb.Task, error) {
	var (
		id          string
		title       string
		description *string
		status      string
		priority    string
		assignedTo  *string
		farmID      string
		fieldID     *string
		dueDate     *time.Time
		createdAt   time.Time
		updatedAt   *time.Time
	)

	err := rows.Scan(
		&id, &title, &description, &status, &priority,
		&assignedTo, &farmID, &fieldID, &dueDate,
		&createdAt, &updatedAt,
	)
	if err != nil {
		return nil, err
	}

	return buildTask(id, title, description, status, priority,
		assignedTo, farmID, fieldID, dueDate, createdAt, updatedAt), nil
}

func buildTask(
	id, title string,
	description *string,
	status, priority string,
	assignedTo *string,
	farmID string,
	fieldID *string,
	dueDate *time.Time,
	createdAt time.Time,
	updatedAt *time.Time,
) *pb.Task {
	task := &pb.Task{
		Id:        id,
		Title:     title,
		Status:    parseTaskStatus(status),
		Priority:  parseTaskPriority(priority),
		FarmId:    farmID,
		CreatedAt: timestamppb.New(createdAt),
	}

	if description != nil {
		task.Description = *description
	}
	if assignedTo != nil {
		task.AssignedTo = *assignedTo
	}
	if fieldID != nil {
		task.FieldId = *fieldID
	}
	if dueDate != nil {
		task.DueDate = timestamppb.New(*dueDate)
	}
	if updatedAt != nil {
		task.UpdatedAt = timestamppb.New(*updatedAt)
	}

	return task
}

// ---------- Enum helpers ----------

func parseTaskStatus(s string) pb.TaskStatus {
	if v, ok := pb.TaskStatus_value[s]; ok {
		return pb.TaskStatus(v)
	}
	return pb.TaskStatus_TASK_STATUS_UNSPECIFIED
}

func parseTaskPriority(s string) pb.TaskPriority {
	if v, ok := pb.TaskPriority_value[s]; ok {
		return pb.TaskPriority(v)
	}
	return pb.TaskPriority_TASK_PRIORITY_UNSPECIFIED
}

// ---------- Nil helpers ----------

func nullableString(v string) *string {
	if v == "" {
		return nil
	}
	return &v
}
