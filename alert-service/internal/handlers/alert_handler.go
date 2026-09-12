package handlers

import (
	"context"
	"strings"

	"connectrpc.com/connect"

	pb "p9e.in/samavaya/agriculture/alert-service/api/v1"
	"p9e.in/samavaya/agriculture/alert-service/api/v1/v1connect"
	"p9e.in/samavaya/agriculture/alert-service/internal/services"
	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
)

// AlertHandler implements the ConnectRPC AlertServiceHandler interface.
type AlertHandler struct {
	v1connect.UnimplementedAlertServiceHandler

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
func (h *AlertHandler) ListAlerts(ctx context.Context, req *connect.Request[pb.ListAlertsRequest]) (*connect.Response[pb.ListAlertsResponse], error) {
	alerts, nextPageToken, totalCount, err := h.svc.ListAlerts(ctx, services.ListAlertsInput{
		FarmID:    req.Msg.GetFarmId(),
		FieldID:   req.Msg.GetFieldId(),
		Severity:  req.Msg.GetSeverity(),
		Status:    req.Msg.GetStatus(),
		PageSize:  req.Msg.GetPageSize(),
		PageToken: req.Msg.GetPageToken(),
	})
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return connect.NewResponse(&pb.ListAlertsResponse{
		Alerts:        alerts,
		NextPageToken: nextPageToken,
		TotalCount:    totalCount,
	}), nil
}

// GetAlert handles the GetAlert RPC.
func (h *AlertHandler) GetAlert(ctx context.Context, req *connect.Request[pb.GetAlertRequest]) (*connect.Response[pb.GetAlertResponse], error) {
	if req.Msg.GetId() == "" {
		return nil, errors.BadRequest("MISSING_ID", "id is required")
	}

	alert, err := h.svc.GetAlert(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return connect.NewResponse(&pb.GetAlertResponse{Alert: alert}), nil
}

// AcknowledgeAlert handles the AcknowledgeAlert RPC.
func (h *AlertHandler) AcknowledgeAlert(ctx context.Context, req *connect.Request[pb.AcknowledgeAlertRequest]) (*connect.Response[pb.AcknowledgeAlertResponse], error) {
	if req.Msg.GetId() == "" {
		return nil, errors.BadRequest("MISSING_ID", "id is required")
	}

	userID := p9context.UserID(ctx)

	alert, err := h.svc.AcknowledgeAlert(ctx, req.Msg.GetId(), userID)
	if err != nil {
		h.logger.Errorf("AcknowledgeAlert failed: %v", err)
		return nil, errors.ToConnectError(err)
	}

	return connect.NewResponse(&pb.AcknowledgeAlertResponse{Alert: alert}), nil
}

// ResolveAlert handles the ResolveAlert RPC.
func (h *AlertHandler) ResolveAlert(ctx context.Context, req *connect.Request[pb.ResolveAlertRequest]) (*connect.Response[pb.ResolveAlertResponse], error) {
	if req.Msg.GetId() == "" {
		return nil, errors.BadRequest("MISSING_ID", "id is required")
	}

	userID := p9context.UserID(ctx)

	alert, err := h.svc.ResolveAlert(ctx, req.Msg.GetId(), userID)
	if err != nil {
		h.logger.Errorf("ResolveAlert failed: %v", err)
		return nil, errors.ToConnectError(err)
	}

	return connect.NewResponse(&pb.ResolveAlertResponse{Alert: alert}), nil
}

// MarkAlertRead handles the MarkAlertRead RPC.
func (h *AlertHandler) MarkAlertRead(ctx context.Context, req *connect.Request[pb.MarkAlertReadRequest]) (*connect.Response[pb.MarkAlertReadResponse], error) {
	if req.Msg.GetId() == "" {
		return nil, errors.BadRequest("MISSING_ID", "id is required")
	}

	alert, err := h.svc.MarkAlertRead(ctx, req.Msg.GetId())
	if err != nil {
		h.logger.Errorf("MarkAlertRead failed: %v", err)
		return nil, errors.ToConnectError(err)
	}

	return connect.NewResponse(&pb.MarkAlertReadResponse{Alert: alert}), nil
}

// MarkAllAlertsRead handles the MarkAllAlertsRead RPC.
func (h *AlertHandler) MarkAllAlertsRead(ctx context.Context, req *connect.Request[pb.MarkAllAlertsReadRequest]) (*connect.Response[pb.MarkAllAlertsReadResponse], error) {
	updatedCount, err := h.svc.MarkAllAlertsRead(ctx, req.Msg.GetFarmId())
	if err != nil {
		h.logger.Errorf("MarkAllAlertsRead failed: %v", err)
		return nil, errors.ToConnectError(err)
	}

	return connect.NewResponse(&pb.MarkAllAlertsReadResponse{UpdatedCount: updatedCount}), nil
}

// GetUnreadCount handles the GetUnreadCount RPC.
func (h *AlertHandler) GetUnreadCount(ctx context.Context, req *connect.Request[pb.GetUnreadCountRequest]) (*connect.Response[pb.GetUnreadCountResponse], error) {
	count, err := h.svc.GetUnreadCount(ctx, req.Msg.GetFarmId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return connect.NewResponse(&pb.GetUnreadCountResponse{Count: count}), nil
}

// ListAlertRules handles the ListAlertRules RPC.
func (h *AlertHandler) ListAlertRules(ctx context.Context, req *connect.Request[pb.ListAlertRulesRequest]) (*connect.Response[pb.ListAlertRulesResponse], error) {
	rules, err := h.svc.ListAlertRules(ctx, req.Msg.GetFieldId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return connect.NewResponse(&pb.ListAlertRulesResponse{Rules: rules}), nil
}

// CreateAlertRule handles the CreateAlertRule RPC.
func (h *AlertHandler) CreateAlertRule(ctx context.Context, req *connect.Request[pb.CreateAlertRuleRequest]) (*connect.Response[pb.CreateAlertRuleResponse], error) {
	if req.Msg.GetRule() == nil {
		return nil, errors.BadRequest("MISSING_RULE", "rule is required")
	}
	if strings.TrimSpace(req.Msg.GetRule().GetFieldId()) == "" {
		return nil, errors.BadRequest("MISSING_FIELD_ID", "rule.field_id is required")
	}
	if strings.TrimSpace(req.Msg.GetRule().GetMetric()) == "" {
		return nil, errors.BadRequest("MISSING_METRIC", "rule.metric is required")
	}

	rule, err := h.svc.CreateAlertRule(ctx, req.Msg.GetRule())
	if err != nil {
		h.logger.Errorf("CreateAlertRule failed: %v", err)
		return nil, errors.ToConnectError(err)
	}

	return connect.NewResponse(&pb.CreateAlertRuleResponse{Rule: rule}), nil
}

// UpdateAlertRule handles the UpdateAlertRule RPC.
func (h *AlertHandler) UpdateAlertRule(ctx context.Context, req *connect.Request[pb.UpdateAlertRuleRequest]) (*connect.Response[pb.UpdateAlertRuleResponse], error) {
	if req.Msg.GetRule() == nil {
		return nil, errors.BadRequest("MISSING_RULE", "rule is required")
	}
	if strings.TrimSpace(req.Msg.GetRule().GetId()) == "" {
		return nil, errors.BadRequest("MISSING_ID", "rule.id is required")
	}

	rule, err := h.svc.UpdateAlertRule(ctx, req.Msg.GetRule())
	if err != nil {
		h.logger.Errorf("UpdateAlertRule failed: %v", err)
		return nil, errors.ToConnectError(err)
	}

	return connect.NewResponse(&pb.UpdateAlertRuleResponse{Rule: rule}), nil
}

// GetFieldRisk handles the GetFieldRisk RPC.
func (h *AlertHandler) GetFieldRisk(ctx context.Context, req *connect.Request[pb.GetFieldRiskRequest]) (*connect.Response[pb.GetFieldRiskResponse], error) {
	if strings.TrimSpace(req.Msg.GetFieldId()) == "" {
		return nil, errors.BadRequest("MISSING_FIELD_ID", "field_id is required")
	}

	riskScore, err := h.svc.GetFieldRisk(ctx, req.Msg.GetFieldId())
	if err != nil {
		h.logger.Errorf("GetFieldRisk failed: %v", err)
		return nil, errors.ToConnectError(err)
	}

	return connect.NewResponse(&pb.GetFieldRiskResponse{RiskScore: riskScore}), nil
}

// ListFieldRisks handles the ListFieldRisks RPC.
func (h *AlertHandler) ListFieldRisks(ctx context.Context, req *connect.Request[pb.ListFieldRisksRequest]) (*connect.Response[pb.ListFieldRisksResponse], error) {
	riskScores, err := h.svc.ListFieldRisks(ctx)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return connect.NewResponse(&pb.ListFieldRisksResponse{RiskScores: riskScores}), nil
}

// ListAlertHistory handles the ListAlertHistory RPC.
func (h *AlertHandler) ListAlertHistory(ctx context.Context, req *connect.Request[pb.ListAlertHistoryRequest]) (*connect.Response[pb.ListAlertHistoryResponse], error) {
	alerts, nextPageToken, totalCount, err := h.svc.ListAlertHistory(ctx, services.ListAlertHistoryInput{
		StartDate: req.Msg.GetStartDate(),
		EndDate:   req.Msg.GetEndDate(),
		FarmID:    req.Msg.GetFarmId(),
		FieldID:   req.Msg.GetFieldId(),
		PageSize:  req.Msg.GetPageSize(),
		PageToken: req.Msg.GetPageToken(),
	})
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return connect.NewResponse(&pb.ListAlertHistoryResponse{
		Alerts:        alerts,
		NextPageToken: nextPageToken,
		TotalCount:    totalCount,
	}), nil
}
