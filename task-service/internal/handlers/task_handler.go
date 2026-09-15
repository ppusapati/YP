package handlers

import (
	"context"
	"strings"

	"connectrpc.com/connect"

	pb "p9e.in/samavaya/agriculture/task-service/api/v1"
	"p9e.in/samavaya/agriculture/task-service/api/v1/v1connect"
	"p9e.in/samavaya/agriculture/task-service/internal/services"
	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
)

// TaskHandler implements the ConnectRPC TaskServiceHandler interface.
type TaskHandler struct {
	v1connect.UnimplementedTaskServiceHandler

	svc    services.TaskService
	deps   deps.ServiceDeps
	logger *p9log.Helper
}

// NewTaskHandler creates a new TaskHandler.
func NewTaskHandler(d deps.ServiceDeps, svc services.TaskService) *TaskHandler {
	return &TaskHandler{
		svc:    svc,
		deps:   d,
		logger: p9log.NewHelper(p9log.With(d.Log, "component", "task_handler")),
	}
}

// GetTask handles the GetTask RPC.
func (h *TaskHandler) GetTask(ctx context.Context, req *connect.Request[pb.GetTaskRequest]) (*connect.Response[pb.GetTaskResponse], error) {
	if req.Msg.GetId() == "" {
		return nil, errors.BadRequest("MISSING_ID", "id is required")
	}

	task, err := h.svc.GetTask(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return connect.NewResponse(&pb.GetTaskResponse{Task: task}), nil
}

// ListTasks handles the ListTasks RPC.
func (h *TaskHandler) ListTasks(ctx context.Context, req *connect.Request[pb.ListTasksRequest]) (*connect.Response[pb.ListTasksResponse], error) {
	tasks, nextPageToken, totalCount, err := h.svc.ListTasks(ctx, services.ListTasksInput{
		FarmID:     req.Msg.GetFarmId(),
		FieldID:    req.Msg.GetFieldId(),
		AssignedTo: req.Msg.GetAssignedTo(),
		Status:     req.Msg.GetStatus(),
		Priority:   req.Msg.GetPriority(),
		PageSize:   req.Msg.GetPageSize(),
		PageToken:  req.Msg.GetPageToken(),
	})
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return connect.NewResponse(&pb.ListTasksResponse{
		Tasks:         tasks,
		NextPageToken: nextPageToken,
		TotalCount:    totalCount,
	}), nil
}

// CreateTask handles the CreateTask RPC.
func (h *TaskHandler) CreateTask(ctx context.Context, req *connect.Request[pb.CreateTaskRequest]) (*connect.Response[pb.CreateTaskResponse], error) {
	if strings.TrimSpace(req.Msg.GetTitle()) == "" {
		return nil, errors.BadRequest("MISSING_TITLE", "title is required")
	}
	if strings.TrimSpace(req.Msg.GetFarmId()) == "" {
		return nil, errors.BadRequest("MISSING_FARM_ID", "farm_id is required")
	}

	userID := p9context.UserID(ctx)

	task, err := h.svc.CreateTask(ctx, services.CreateTaskInput{
		Title:       req.Msg.GetTitle(),
		Description: req.Msg.GetDescription(),
		Priority:    req.Msg.GetPriority(),
		AssignedTo:  req.Msg.GetAssignedTo(),
		FarmID:      req.Msg.GetFarmId(),
		FieldID:     req.Msg.GetFieldId(),
		DueDate:     req.Msg.GetDueDate(),
		CreatedBy:   userID,
	})
	if err != nil {
		h.logger.Errorf("CreateTask failed: %v", err)
		return nil, errors.ToConnectError(err)
	}

	return connect.NewResponse(&pb.CreateTaskResponse{Task: task}), nil
}

// UpdateTask handles the UpdateTask RPC.
func (h *TaskHandler) UpdateTask(ctx context.Context, req *connect.Request[pb.UpdateTaskRequest]) (*connect.Response[pb.UpdateTaskResponse], error) {
	if req.Msg.GetId() == "" {
		return nil, errors.BadRequest("MISSING_ID", "id is required")
	}

	task, err := h.svc.UpdateTask(ctx, services.UpdateTaskInput{
		ID:          req.Msg.GetId(),
		Title:       req.Msg.GetTitle(),
		Description: req.Msg.GetDescription(),
		Status:      req.Msg.GetStatus(),
		Priority:    req.Msg.GetPriority(),
		AssignedTo:  req.Msg.GetAssignedTo(),
		FieldID:     req.Msg.GetFieldId(),
		DueDate:     req.Msg.GetDueDate(),
		UpdateMask:  req.Msg.GetUpdateMask(),
	})
	if err != nil {
		h.logger.Errorf("UpdateTask failed: %v", err)
		return nil, errors.ToConnectError(err)
	}

	return connect.NewResponse(&pb.UpdateTaskResponse{Task: task}), nil
}

// DeleteTask handles the DeleteTask RPC.
func (h *TaskHandler) DeleteTask(ctx context.Context, req *connect.Request[pb.DeleteTaskRequest]) (*connect.Response[pb.DeleteTaskResponse], error) {
	if req.Msg.GetId() == "" {
		return nil, errors.BadRequest("MISSING_ID", "id is required")
	}

	err := h.svc.DeleteTask(ctx, req.Msg.GetId())
	if err != nil {
		h.logger.Errorf("DeleteTask failed: %v", err)
		return nil, errors.ToConnectError(err)
	}

	return connect.NewResponse(&pb.DeleteTaskResponse{}), nil
}
