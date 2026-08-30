package services

import (
	"context"
	"strings"
	"time"

	"p9e.in/samavaya/agriculture/alert-service/internal/ai"
	alertmodels "p9e.in/samavaya/agriculture/alert-service/internal/models"
	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"
)

// AlertService defines the business logic interface for alert operations.
type AlertService interface {
	CreateAlert(ctx context.Context, alert *alertmodels.Alert) (*alertmodels.Alert, error)
	ListAlerts(ctx context.Context, fieldID, farmID string, status *alertmodels.AlertStatus, limit, offset int32) ([]*alertmodels.Alert, int32, error)
	AcknowledgeAlert(ctx context.Context, alertID, userID string) error
	ResolveAlert(ctx context.Context, alertID, userID, resolution string) error
	EvaluateField(ctx context.Context, fieldID string) (*alertmodels.FieldRiskScore, error)

	CreateAlertRule(ctx context.Context, rule *alertmodels.AlertRule) (*alertmodels.AlertRule, error)
	ListAlertRules(ctx context.Context, fieldID string) ([]*alertmodels.AlertRule, error)
	UpdateAlertRule(ctx context.Context, rule *alertmodels.AlertRule) error
	DeleteAlertRule(ctx context.Context, ruleID string) error
}

// alertService is the concrete implementation of AlertService.
type alertService struct {
	deps     deps.ServiceDeps
	aiClient *ai.AIClient
	logger   *p9log.Helper
}

// NewAlertService creates a new AlertService instance.
func NewAlertService(d deps.ServiceDeps, aiClient *ai.AIClient) AlertService {
	return &alertService{
		deps:     d,
		aiClient: aiClient,
		logger:   p9log.NewHelper(p9log.With(d.Log, "component", "AlertService")),
	}
}

// ---------- Alert CRUD ----------

func (s *alertService) CreateAlert(ctx context.Context, alert *alertmodels.Alert) (*alertmodels.Alert, error) {
	if strings.TrimSpace(alert.FieldID) == "" {
		return nil, errors.BadRequest("INVALID_FIELD_ID", "field_id is required")
	}
	if strings.TrimSpace(alert.FarmID) == "" {
		return nil, errors.BadRequest("INVALID_FARM_ID", "farm_id is required")
	}
	if !alert.AlertType.IsValid() {
		return nil, errors.BadRequest("INVALID_ALERT_TYPE", "a valid alert_type is required")
	}
	if !alert.Severity.IsValid() {
		return nil, errors.BadRequest("INVALID_SEVERITY", "a valid severity is required")
	}
	if strings.TrimSpace(alert.Title) == "" {
		return nil, errors.BadRequest("INVALID_TITLE", "title is required")
	}

	if alert.ID == "" {
		alert.ID = ulid.NewString()
	}
	if alert.Status == "" {
		alert.Status = alertmodels.AlertStatusActive
	}
	if alert.CreatedAt.IsZero() {
		alert.CreatedAt = time.Now()
	}

	// In a full implementation this would persist to the database via a repository.
	// For now, the alert is returned as-is after validation and defaults.
	s.logger.Infof("Alert created: id=%s type=%s severity=%s field=%s",
		alert.ID, alert.AlertType, alert.Severity, alert.FieldID)

	return alert, nil
}

func (s *alertService) ListAlerts(ctx context.Context, fieldID, farmID string, status *alertmodels.AlertStatus, limit, offset int32) ([]*alertmodels.Alert, int32, error) {
	if strings.TrimSpace(fieldID) == "" && strings.TrimSpace(farmID) == "" {
		return nil, 0, errors.BadRequest("INVALID_FILTER", "at least one of field_id or farm_id is required")
	}

	if limit <= 0 {
		limit = 50
	}
	if limit > 200 {
		limit = 200
	}

	if status != nil && !status.IsValid() {
		return nil, 0, errors.BadRequest("INVALID_STATUS", "invalid alert status filter")
	}

	// Repository call would go here.
	s.logger.Infof("ListAlerts: field=%s farm=%s limit=%d offset=%d", fieldID, farmID, limit, offset)

	return nil, 0, nil
}

func (s *alertService) AcknowledgeAlert(ctx context.Context, alertID, userID string) error {
	if strings.TrimSpace(alertID) == "" {
		return errors.BadRequest("INVALID_ALERT_ID", "alert_id is required")
	}
	if strings.TrimSpace(userID) == "" {
		userID = p9context.UserID(ctx)
	}
	if strings.TrimSpace(userID) == "" {
		return errors.BadRequest("INVALID_USER_ID", "user_id is required to acknowledge an alert")
	}

	// Repository call: update status to ACKNOWLEDGED, set acknowledged_at.
	s.logger.Infof("Alert acknowledged: id=%s by=%s", alertID, userID)
	return nil
}

func (s *alertService) ResolveAlert(ctx context.Context, alertID, userID, resolution string) error {
	if strings.TrimSpace(alertID) == "" {
		return errors.BadRequest("INVALID_ALERT_ID", "alert_id is required")
	}
	if strings.TrimSpace(userID) == "" {
		userID = p9context.UserID(ctx)
	}
	if strings.TrimSpace(userID) == "" {
		return errors.BadRequest("INVALID_USER_ID", "user_id is required to resolve an alert")
	}

	// Repository call: update status to RESOLVED, set resolved_at and resolution note.
	s.logger.Infof("Alert resolved: id=%s by=%s resolution=%q", alertID, userID, resolution)
	return nil
}

// ---------- Field Evaluation ----------

func (s *alertService) EvaluateField(ctx context.Context, fieldID string) (*alertmodels.FieldRiskScore, error) {
	if strings.TrimSpace(fieldID) == "" {
		return nil, errors.BadRequest("INVALID_FIELD_ID", "field_id is required")
	}

	if s.aiClient == nil {
		return nil, errors.InternalServer("AI_CLIENT_UNAVAILABLE", "AI Gateway client is not configured")
	}

	requestID := p9context.RequestID(ctx)
	if requestID == "" {
		requestID = ulid.NewString()
	}

	result, err := s.aiClient.EvaluateFieldRisk(ctx, requestID, fieldID)
	if err != nil {
		s.logger.Errorf("EvaluateField failed: field=%s err=%v", fieldID, err)
		return nil, errors.InternalServer("FIELD_EVALUATION_FAILED", "failed to evaluate field risk")
	}

	s.logger.Infof("Field evaluated: field=%s overall_risk=%.2f alerts=%d",
		result.FieldID, result.OverallRisk, len(result.Alerts))
	return result, nil
}

// ---------- Alert Rules ----------

func (s *alertService) CreateAlertRule(ctx context.Context, rule *alertmodels.AlertRule) (*alertmodels.AlertRule, error) {
	if strings.TrimSpace(rule.FieldID) == "" {
		return nil, errors.BadRequest("INVALID_FIELD_ID", "field_id is required")
	}
	if strings.TrimSpace(rule.FarmID) == "" {
		return nil, errors.BadRequest("INVALID_FARM_ID", "farm_id is required")
	}
	if !rule.AlertType.IsValid() {
		return nil, errors.BadRequest("INVALID_ALERT_TYPE", "a valid alert_type is required")
	}

	if rule.ID == "" {
		rule.ID = ulid.NewString()
	}
	now := time.Now()
	if rule.CreatedAt.IsZero() {
		rule.CreatedAt = now
	}
	rule.UpdatedAt = now

	if rule.CooldownMinutes <= 0 {
		rule.CooldownMinutes = 60 // default cooldown: 1 hour
	}

	// Validate thresholds JSON
	if rule.ThresholdJSON != "" {
		if _, err := alertmodels.ParseThresholds(rule.ThresholdJSON); err != nil {
			return nil, errors.BadRequest("INVALID_THRESHOLDS", "threshold_json is not valid JSON")
		}
	} else {
		defaults := alertmodels.DefaultThresholds()
		marshaled, err := defaults.Marshal()
		if err != nil {
			return nil, errors.InternalServer("MARSHAL_THRESHOLDS_FAILED", "failed to serialize default thresholds")
		}
		rule.ThresholdJSON = marshaled
	}

	// Repository call would persist the rule here.
	s.logger.Infof("AlertRule created: id=%s type=%s field=%s", rule.ID, rule.AlertType, rule.FieldID)
	return rule, nil
}

func (s *alertService) ListAlertRules(ctx context.Context, fieldID string) ([]*alertmodels.AlertRule, error) {
	if strings.TrimSpace(fieldID) == "" {
		return nil, errors.BadRequest("INVALID_FIELD_ID", "field_id is required")
	}

	// Repository call would go here.
	s.logger.Infof("ListAlertRules: field=%s", fieldID)
	return nil, nil
}

func (s *alertService) UpdateAlertRule(ctx context.Context, rule *alertmodels.AlertRule) error {
	if strings.TrimSpace(rule.ID) == "" {
		return errors.BadRequest("INVALID_RULE_ID", "rule id is required")
	}
	if !rule.AlertType.IsValid() {
		return errors.BadRequest("INVALID_ALERT_TYPE", "a valid alert_type is required")
	}

	if rule.ThresholdJSON != "" {
		if _, err := alertmodels.ParseThresholds(rule.ThresholdJSON); err != nil {
			return errors.BadRequest("INVALID_THRESHOLDS", "threshold_json is not valid JSON")
		}
	}

	rule.UpdatedAt = time.Now()

	// Repository call would update the rule here.
	s.logger.Infof("AlertRule updated: id=%s", rule.ID)
	return nil
}

func (s *alertService) DeleteAlertRule(ctx context.Context, ruleID string) error {
	if strings.TrimSpace(ruleID) == "" {
		return errors.BadRequest("INVALID_RULE_ID", "rule id is required")
	}

	// Repository call would soft-delete the rule here.
	s.logger.Infof("AlertRule deleted: id=%s", ruleID)
	return nil
}
