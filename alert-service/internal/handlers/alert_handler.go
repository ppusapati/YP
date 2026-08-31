package handlers

import (
	"context"
	"strings"

	pb "p9e.in/samavaya/agriculture/alert-service/api/v1"
	"p9e.in/samavaya/agriculture/alert-service/internal/services"
	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
)

// AlertHandler implements the gRPC AlertServiceServer interface.
type AlertHandler struct {
	pb.UnimplementedAlertServiceServer

	svc    services.AlertService
	deps   deps.ServiceDeps
	logger *p9log.Helper
}

// NewAlertHandler creates a new AlertHandler.
func NewAlertHandler(d deps.ServiceDeps, svc services.AlertService) *AlertHandler {
	return &AlertHandler{
		svc:    svc,
		deps:   d,
		logger: p9log.NewHelper(p9log.With(d.Log, "component", "alert_handler")),
	}
}

// ListAlerts handles the ListAlerts RPC.
func (h *AlertHandler) ListAlerts(ctx context.Context, req *pb.ListAlertsRequest) (*pb.ListAlertsResponse, error) {
	if req == nil {
		return nil, errors.BadRequest("INVALID_REQUEST", "request must not be nil")
	}

	alerts, nextPageToken, totalCount, err := h.svc.ListAlerts(ctx, services.ListAlertsInput{
		FarmID:    req.GetFarmId(),
		FieldID:   req.GetFieldId(),
		Severity:  req.GetSeverity(),
		Status:    req.GetStatus(),
		PageSize:  req.GetPageSize(),
		PageToken: req.GetPageToken(),
	})
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.ListAlertsResponse{
		Alerts:        alerts,
		NextPageToken: nextPageToken,
		TotalCount:    totalCount,
	}, nil
}

// GetAlert handles the GetAlert RPC.
func (h *AlertHandler) GetAlert(ctx context.Context, req *pb.GetAlertRequest) (*pb.GetAlertResponse, error) {
	if req == nil {
		return nil, errors.BadRequest("INVALID_REQUEST", "request must not be nil")
	}
	if req.GetId() == "" {
		return nil, errors.BadRequest("MISSING_ID", "id is required")
	}

	alert, err := h.svc.GetAlert(ctx, req.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetAlertResponse{Alert: alert}, nil
}

// AcknowledgeAlert handles the AcknowledgeAlert RPC.
func (h *AlertHandler) AcknowledgeAlert(ctx context.Context, req *pb.AcknowledgeAlertRequest) (*pb.AcknowledgeAlertResponse, error) {
	if req == nil {
		return nil, errors.BadRequest("INVALID_REQUEST", "request must not be nil")
	}
	if req.GetId() == "" {
		return nil, errors.BadRequest("MISSING_ID", "id is required")
	}

	userID := p9context.UserID(ctx)

	alert, err := h.svc.AcknowledgeAlert(ctx, req.GetId(), userID)
	if err != nil {
		h.logger.Errorf("AcknowledgeAlert failed: %v", err)
		return nil, errors.ToConnectError(err)
	}

	return &pb.AcknowledgeAlertResponse{Alert: alert}, nil
}

// ResolveAlert handles the ResolveAlert RPC.
func (h *AlertHandler) ResolveAlert(ctx context.Context, req *pb.ResolveAlertRequest) (*pb.ResolveAlertResponse, error) {
	if req == nil {
		return nil, errors.BadRequest("INVALID_REQUEST", "request must not be nil")
	}
	if req.GetId() == "" {
		return nil, errors.BadRequest("MISSING_ID", "id is required")
	}

	userID := p9context.UserID(ctx)

	alert, err := h.svc.ResolveAlert(ctx, req.GetId(), userID)
	if err != nil {
		h.logger.Errorf("ResolveAlert failed: %v", err)
		return nil, errors.ToConnectError(err)
	}

	return &pb.ResolveAlertResponse{Alert: alert}, nil
}

// MarkAlertRead handles the MarkAlertRead RPC.
func (h *AlertHandler) MarkAlertRead(ctx context.Context, req *pb.MarkAlertReadRequest) (*pb.MarkAlertReadResponse, error) {
	if req == nil {
		return nil, errors.BadRequest("INVALID_REQUEST", "request must not be nil")
	}
	if req.GetId() == "" {
		return nil, errors.BadRequest("MISSING_ID", "id is required")
	}

	alert, err := h.svc.MarkAlertRead(ctx, req.GetId())
	if err != nil {
		h.logger.Errorf("MarkAlertRead failed: %v", err)
		return nil, errors.ToConnectError(err)
	}

	return &pb.MarkAlertReadResponse{Alert: alert}, nil
}

// MarkAllAlertsRead handles the MarkAllAlertsRead RPC.
func (h *AlertHandler) MarkAllAlertsRead(ctx context.Context, req *pb.MarkAllAlertsReadRequest) (*pb.MarkAllAlertsReadResponse, error) {
	if req == nil {
		return nil, errors.BadRequest("INVALID_REQUEST", "request must not be nil")
	}

	updatedCount, err := h.svc.MarkAllAlertsRead(ctx, req.GetFarmId())
	if err != nil {
		h.logger.Errorf("MarkAllAlertsRead failed: %v", err)
		return nil, errors.ToConnectError(err)
	}

	return &pb.MarkAllAlertsReadResponse{UpdatedCount: updatedCount}, nil
}

// GetUnreadCount handles the GetUnreadCount RPC.
func (h *AlertHandler) GetUnreadCount(ctx context.Context, req *pb.GetUnreadCountRequest) (*pb.GetUnreadCountResponse, error) {
	if req == nil {
		return nil, errors.BadRequest("INVALID_REQUEST", "request must not be nil")
	}

	count, err := h.svc.GetUnreadCount(ctx, req.GetFarmId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetUnreadCountResponse{Count: count}, nil
}

// ListAlertRules handles the ListAlertRules RPC.
func (h *AlertHandler) ListAlertRules(ctx context.Context, req *pb.ListAlertRulesRequest) (*pb.ListAlertRulesResponse, error) {
	if req == nil {
		return nil, errors.BadRequest("INVALID_REQUEST", "request must not be nil")
	}

	rules, err := h.svc.ListAlertRules(ctx, req.GetFieldId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.ListAlertRulesResponse{Rules: rules}, nil
}

// CreateAlertRule handles the CreateAlertRule RPC.
func (h *AlertHandler) CreateAlertRule(ctx context.Context, req *pb.CreateAlertRuleRequest) (*pb.CreateAlertRuleResponse, error) {
	if req == nil {
		return nil, errors.BadRequest("INVALID_REQUEST", "request must not be nil")
	}
	if req.GetRule() == nil {
		return nil, errors.BadRequest("MISSING_RULE", "rule is required")
	}
	if strings.TrimSpace(req.GetRule().GetFieldId()) == "" {
		return nil, errors.BadRequest("MISSING_FIELD_ID", "rule.field_id is required")
	}
	if strings.TrimSpace(req.GetRule().GetMetric()) == "" {
		return nil, errors.BadRequest("MISSING_METRIC", "rule.metric is required")
	}

	rule, err := h.svc.CreateAlertRule(ctx, req.GetRule())
	if err != nil {
		h.logger.Errorf("CreateAlertRule failed: %v", err)
		return nil, errors.ToConnectError(err)
	}

	return &pb.CreateAlertRuleResponse{Rule: rule}, nil
}

// UpdateAlertRule handles the UpdateAlertRule RPC.
func (h *AlertHandler) UpdateAlertRule(ctx context.Context, req *pb.UpdateAlertRuleRequest) (*pb.UpdateAlertRuleResponse, error) {
	if req == nil {
		return nil, errors.BadRequest("INVALID_REQUEST", "request must not be nil")
	}
	if req.GetRule() == nil {
		return nil, errors.BadRequest("MISSING_RULE", "rule is required")
	}
	if strings.TrimSpace(req.GetRule().GetId()) == "" {
		return nil, errors.BadRequest("MISSING_ID", "rule.id is required")
	}

	rule, err := h.svc.UpdateAlertRule(ctx, req.GetRule())
	if err != nil {
		h.logger.Errorf("UpdateAlertRule failed: %v", err)
		return nil, errors.ToConnectError(err)
	}

	return &pb.UpdateAlertRuleResponse{Rule: rule}, nil
}

// GetFieldRisk handles the GetFieldRisk RPC.
func (h *AlertHandler) GetFieldRisk(ctx context.Context, req *pb.GetFieldRiskRequest) (*pb.GetFieldRiskResponse, error) {
	if req == nil {
		return nil, errors.BadRequest("INVALID_REQUEST", "request must not be nil")
	}
	if strings.TrimSpace(req.GetFieldId()) == "" {
		return nil, errors.BadRequest("MISSING_FIELD_ID", "field_id is required")
	}

	riskScore, err := h.svc.GetFieldRisk(ctx, req.GetFieldId())
	if err != nil {
		h.logger.Errorf("GetFieldRisk failed: %v", err)
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetFieldRiskResponse{RiskScore: riskScore}, nil
}

// ListFieldRisks handles the ListFieldRisks RPC.
func (h *AlertHandler) ListFieldRisks(ctx context.Context, req *pb.ListFieldRisksRequest) (*pb.ListFieldRisksResponse, error) {
	if req == nil {
		return nil, errors.BadRequest("INVALID_REQUEST", "request must not be nil")
	}

	riskScores, err := h.svc.ListFieldRisks(ctx)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.ListFieldRisksResponse{RiskScores: riskScores}, nil
}

// ListAlertHistory handles the ListAlertHistory RPC.
func (h *AlertHandler) ListAlertHistory(ctx context.Context, req *pb.ListAlertHistoryRequest) (*pb.ListAlertHistoryResponse, error) {
	if req == nil {
		return nil, errors.BadRequest("INVALID_REQUEST", "request must not be nil")
	}

	alerts, nextPageToken, totalCount, err := h.svc.ListAlertHistory(ctx, services.ListAlertHistoryInput{
		StartDate: req.GetStartDate(),
		EndDate:   req.GetEndDate(),
		FarmID:    req.GetFarmId(),
		FieldID:   req.GetFieldId(),
		PageSize:  req.GetPageSize(),
		PageToken: req.GetPageToken(),
	})
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.ListAlertHistoryResponse{
		Alerts:        alerts,
		NextPageToken: nextPageToken,
		TotalCount:    totalCount,
	}, nil
}
