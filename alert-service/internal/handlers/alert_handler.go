package handlers

import (
	"context"
	"strings"

	alertmodels "p9e.in/samavaya/agriculture/alert-service/internal/models"
	"p9e.in/samavaya/agriculture/alert-service/internal/services"
	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
)

// AlertHandler implements the gRPC AlertServiceServer interface.
type AlertHandler struct {
	svc    services.AlertService
	deps   deps.ServiceDeps
	logger *p9log.Helper
}

// NewAlertHandler creates a new AlertHandler.
func NewAlertHandler(d deps.ServiceDeps, svc services.AlertService) *AlertHandler {
	return &AlertHandler{
		svc:    svc,
		deps:   d,
		logger: p9log.NewHelper(p9log.With(d.Log, "component", "AlertHandler")),
	}
}

// ---------- Request / Response types (stand-in for generated proto types) ----------
// In production these would be replaced by the generated protobuf types from
// alert-service/api/v1. They are defined here so the handler compiles without
// requiring a proto generation step.

// CreateAlertRequest is the gRPC request for creating an alert.
type CreateAlertRequest struct {
	FieldID         string   `json:"field_id"`
	FarmID          string   `json:"farm_id"`
	AlertType       string   `json:"alert_type"`
	Severity        string   `json:"severity"`
	Title           string   `json:"title"`
	Message         string   `json:"message"`
	Recommendations []string `json:"recommendations"`
	MetricValue     float64  `json:"metric_value"`
	ThresholdValue  float64  `json:"threshold_value"`
}

// CreateAlertResponse is the gRPC response for creating an alert.
type CreateAlertResponse struct {
	Alert *alertmodels.Alert `json:"alert"`
}

// ListAlertsRequest is the gRPC request for listing alerts.
type ListAlertsRequest struct {
	FieldID    string `json:"field_id"`
	FarmID     string `json:"farm_id"`
	Status     string `json:"status"`
	PageSize   int32  `json:"page_size"`
	PageOffset int32  `json:"page_offset"`
}

// ListAlertsResponse is the gRPC response for listing alerts.
type ListAlertsResponse struct {
	Alerts     []*alertmodels.Alert `json:"alerts"`
	TotalCount int32                `json:"total_count"`
}

// AcknowledgeAlertRequest is the gRPC request for acknowledging an alert.
type AcknowledgeAlertRequest struct {
	AlertID string `json:"alert_id"`
}

// AcknowledgeAlertResponse is the gRPC response for acknowledging an alert.
type AcknowledgeAlertResponse struct {
	Success bool `json:"success"`
}

// ResolveAlertRequest is the gRPC request for resolving an alert.
type ResolveAlertRequest struct {
	AlertID    string `json:"alert_id"`
	Resolution string `json:"resolution"`
}

// ResolveAlertResponse is the gRPC response for resolving an alert.
type ResolveAlertResponse struct {
	Success bool `json:"success"`
}

// EvaluateFieldRequest is the gRPC request for evaluating field risk.
type EvaluateFieldRequest struct {
	FieldID string `json:"field_id"`
}

// EvaluateFieldResponse is the gRPC response for evaluating field risk.
type EvaluateFieldResponse struct {
	RiskScore *alertmodels.FieldRiskScore `json:"risk_score"`
}

// CreateAlertRuleRequest is the gRPC request for creating an alert rule.
type CreateAlertRuleRequest struct {
	FieldID         string   `json:"field_id"`
	FarmID          string   `json:"farm_id"`
	AlertType       string   `json:"alert_type"`
	Enabled         bool     `json:"enabled"`
	ThresholdJSON   string   `json:"threshold_json"`
	NotifyChannels  []string `json:"notify_channels"`
	CooldownMinutes int32    `json:"cooldown_minutes"`
}

// CreateAlertRuleResponse is the gRPC response for creating an alert rule.
type CreateAlertRuleResponse struct {
	Rule *alertmodels.AlertRule `json:"rule"`
}

// ListAlertRulesRequest is the gRPC request for listing alert rules.
type ListAlertRulesRequest struct {
	FieldID string `json:"field_id"`
}

// ListAlertRulesResponse is the gRPC response for listing alert rules.
type ListAlertRulesResponse struct {
	Rules []*alertmodels.AlertRule `json:"rules"`
}

// UpdateAlertRuleRequest is the gRPC request for updating an alert rule.
type UpdateAlertRuleRequest struct {
	RuleID          string   `json:"rule_id"`
	AlertType       string   `json:"alert_type"`
	Enabled         bool     `json:"enabled"`
	ThresholdJSON   string   `json:"threshold_json"`
	NotifyChannels  []string `json:"notify_channels"`
	CooldownMinutes int32    `json:"cooldown_minutes"`
}

// UpdateAlertRuleResponse is the gRPC response for updating an alert rule.
type UpdateAlertRuleResponse struct {
	Success bool `json:"success"`
}

// DeleteAlertRuleRequest is the gRPC request for deleting an alert rule.
type DeleteAlertRuleRequest struct {
	RuleID string `json:"rule_id"`
}

// DeleteAlertRuleResponse is the gRPC response for deleting an alert rule.
type DeleteAlertRuleResponse struct {
	Success bool `json:"success"`
}

// ---------- Handler methods ----------

// CreateAlert handles a CreateAlert RPC request.
func (h *AlertHandler) CreateAlert(ctx context.Context, req *CreateAlertRequest) (*CreateAlertResponse, error) {
	if strings.TrimSpace(req.FieldID) == "" {
		return nil, errors.BadRequest("INVALID_FIELD_ID", "field_id is required")
	}
	if strings.TrimSpace(req.FarmID) == "" {
		return nil, errors.BadRequest("INVALID_FARM_ID", "farm_id is required")
	}
	if strings.TrimSpace(req.Title) == "" {
		return nil, errors.BadRequest("INVALID_TITLE", "title is required")
	}

	alert := &alertmodels.Alert{
		FieldID:         req.FieldID,
		FarmID:          req.FarmID,
		AlertType:       alertmodels.AlertType(req.AlertType),
		Severity:        alertmodels.AlertSeverity(req.Severity),
		Title:           req.Title,
		Message:         req.Message,
		Recommendations: req.Recommendations,
		MetricValue:     req.MetricValue,
		ThresholdValue:  req.ThresholdValue,
	}

	created, err := h.svc.CreateAlert(ctx, alert)
	if err != nil {
		h.logger.Errorf("CreateAlert failed: %v", err)
		return nil, errors.ToConnectError(err)
	}

	return &CreateAlertResponse{Alert: created}, nil
}

// ListAlerts handles a ListAlerts RPC request.
func (h *AlertHandler) ListAlerts(ctx context.Context, req *ListAlertsRequest) (*ListAlertsResponse, error) {
	limit := req.PageSize
	if limit <= 0 {
		limit = 50
	}

	var statusFilter *alertmodels.AlertStatus
	if req.Status != "" {
		s := alertmodels.AlertStatus(req.Status)
		statusFilter = &s
	}

	alerts, totalCount, err := h.svc.ListAlerts(ctx, req.FieldID, req.FarmID, statusFilter, limit, req.PageOffset)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &ListAlertsResponse{
		Alerts:     alerts,
		TotalCount: totalCount,
	}, nil
}

// AcknowledgeAlert handles an AcknowledgeAlert RPC request.
func (h *AlertHandler) AcknowledgeAlert(ctx context.Context, req *AcknowledgeAlertRequest) (*AcknowledgeAlertResponse, error) {
	if strings.TrimSpace(req.AlertID) == "" {
		return nil, errors.BadRequest("INVALID_ALERT_ID", "alert_id is required")
	}

	userID := p9context.UserID(ctx)

	if err := h.svc.AcknowledgeAlert(ctx, req.AlertID, userID); err != nil {
		h.logger.Errorf("AcknowledgeAlert failed: %v", err)
		return nil, errors.ToConnectError(err)
	}

	return &AcknowledgeAlertResponse{Success: true}, nil
}

// ResolveAlert handles a ResolveAlert RPC request.
func (h *AlertHandler) ResolveAlert(ctx context.Context, req *ResolveAlertRequest) (*ResolveAlertResponse, error) {
	if strings.TrimSpace(req.AlertID) == "" {
		return nil, errors.BadRequest("INVALID_ALERT_ID", "alert_id is required")
	}

	userID := p9context.UserID(ctx)

	if err := h.svc.ResolveAlert(ctx, req.AlertID, userID, req.Resolution); err != nil {
		h.logger.Errorf("ResolveAlert failed: %v", err)
		return nil, errors.ToConnectError(err)
	}

	return &ResolveAlertResponse{Success: true}, nil
}

// EvaluateField handles an EvaluateField RPC request.
func (h *AlertHandler) EvaluateField(ctx context.Context, req *EvaluateFieldRequest) (*EvaluateFieldResponse, error) {
	if strings.TrimSpace(req.FieldID) == "" {
		return nil, errors.BadRequest("INVALID_FIELD_ID", "field_id is required")
	}

	riskScore, err := h.svc.EvaluateField(ctx, req.FieldID)
	if err != nil {
		h.logger.Errorf("EvaluateField failed: %v", err)
		return nil, errors.ToConnectError(err)
	}

	return &EvaluateFieldResponse{RiskScore: riskScore}, nil
}

// CreateAlertRule handles a CreateAlertRule RPC request.
func (h *AlertHandler) CreateAlertRule(ctx context.Context, req *CreateAlertRuleRequest) (*CreateAlertRuleResponse, error) {
	if strings.TrimSpace(req.FieldID) == "" {
		return nil, errors.BadRequest("INVALID_FIELD_ID", "field_id is required")
	}
	if strings.TrimSpace(req.FarmID) == "" {
		return nil, errors.BadRequest("INVALID_FARM_ID", "farm_id is required")
	}

	rule := &alertmodels.AlertRule{
		FieldID:         req.FieldID,
		FarmID:          req.FarmID,
		AlertType:       alertmodels.AlertType(req.AlertType),
		Enabled:         req.Enabled,
		ThresholdJSON:   req.ThresholdJSON,
		NotifyChannels:  req.NotifyChannels,
		CooldownMinutes: req.CooldownMinutes,
	}

	created, err := h.svc.CreateAlertRule(ctx, rule)
	if err != nil {
		h.logger.Errorf("CreateAlertRule failed: %v", err)
		return nil, errors.ToConnectError(err)
	}

	return &CreateAlertRuleResponse{Rule: created}, nil
}

// ListAlertRules handles a ListAlertRules RPC request.
func (h *AlertHandler) ListAlertRules(ctx context.Context, req *ListAlertRulesRequest) (*ListAlertRulesResponse, error) {
	if strings.TrimSpace(req.FieldID) == "" {
		return nil, errors.BadRequest("INVALID_FIELD_ID", "field_id is required")
	}

	rules, err := h.svc.ListAlertRules(ctx, req.FieldID)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &ListAlertRulesResponse{Rules: rules}, nil
}

// UpdateAlertRule handles an UpdateAlertRule RPC request.
func (h *AlertHandler) UpdateAlertRule(ctx context.Context, req *UpdateAlertRuleRequest) (*UpdateAlertRuleResponse, error) {
	if strings.TrimSpace(req.RuleID) == "" {
		return nil, errors.BadRequest("INVALID_RULE_ID", "rule_id is required")
	}

	rule := &alertmodels.AlertRule{
		ID:              req.RuleID,
		AlertType:       alertmodels.AlertType(req.AlertType),
		Enabled:         req.Enabled,
		ThresholdJSON:   req.ThresholdJSON,
		NotifyChannels:  req.NotifyChannels,
		CooldownMinutes: req.CooldownMinutes,
	}

	if err := h.svc.UpdateAlertRule(ctx, rule); err != nil {
		h.logger.Errorf("UpdateAlertRule failed: %v", err)
		return nil, errors.ToConnectError(err)
	}

	return &UpdateAlertRuleResponse{Success: true}, nil
}

// DeleteAlertRule handles a DeleteAlertRule RPC request.
func (h *AlertHandler) DeleteAlertRule(ctx context.Context, req *DeleteAlertRuleRequest) (*DeleteAlertRuleResponse, error) {
	if strings.TrimSpace(req.RuleID) == "" {
		return nil, errors.BadRequest("INVALID_RULE_ID", "rule_id is required")
	}

	if err := h.svc.DeleteAlertRule(ctx, req.RuleID); err != nil {
		h.logger.Errorf("DeleteAlertRule failed: %v", err)
		return nil, errors.ToConnectError(err)
	}

	return &DeleteAlertRuleResponse{Success: true}, nil
}
