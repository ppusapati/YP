package services

import (
	"context"
	"strings"
	"time"

	pb "p9e.in/samavaya/agriculture/alert-service/api/v1"
	"p9e.in/samavaya/agriculture/alert-service/internal/ai"
	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"
	"google.golang.org/protobuf/types/known/timestamppb"
)

// ListAlertsInput holds the filter parameters for listing alerts.
type ListAlertsInput struct {
	FarmID    string
	FieldID   string
	Severity  pb.AlertSeverity
	Status    pb.AlertStatus
	PageSize  int32
	PageToken string
}

// ListAlertHistoryInput holds the filter parameters for listing alert history.
type ListAlertHistoryInput struct {
	StartDate string
	EndDate   string
	FarmID    string
	FieldID   string
	PageSize  int32
	PageToken string
}

// AlertService defines the business logic interface for alert operations.
type AlertService interface {
	// Alert CRUD
	ListAlerts(ctx context.Context, input ListAlertsInput) ([]*pb.Alert, string, int32, error)
	GetAlert(ctx context.Context, id string) (*pb.Alert, error)
	AcknowledgeAlert(ctx context.Context, alertID, userID string) (*pb.Alert, error)
	ResolveAlert(ctx context.Context, alertID, userID string) (*pb.Alert, error)

	// Read status
	MarkAlertRead(ctx context.Context, alertID string) (*pb.Alert, error)
	MarkAllAlertsRead(ctx context.Context, farmID string) (int32, error)
	GetUnreadCount(ctx context.Context, farmID string) (int32, error)

	// Alert rules
	ListAlertRules(ctx context.Context, fieldID string) ([]*pb.AlertRule, error)
	CreateAlertRule(ctx context.Context, rule *pb.AlertRule) (*pb.AlertRule, error)
	UpdateAlertRule(ctx context.Context, rule *pb.AlertRule) (*pb.AlertRule, error)

	// Field risk
	GetFieldRisk(ctx context.Context, fieldID string) (*pb.FieldRiskScore, error)
	ListFieldRisks(ctx context.Context) ([]*pb.FieldRiskScore, error)

	// History
	ListAlertHistory(ctx context.Context, input ListAlertHistoryInput) ([]*pb.Alert, string, int32, error)
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

func (s *alertService) ListAlerts(ctx context.Context, input ListAlertsInput) ([]*pb.Alert, string, int32, error) {
	if strings.TrimSpace(input.FarmID) == "" && strings.TrimSpace(input.FieldID) == "" {
		return nil, "", 0, errors.BadRequest("INVALID_FILTER", "at least one of farm_id or field_id is required")
	}

	pageSize := input.PageSize
	if pageSize <= 0 {
		pageSize = 50
	}
	if pageSize > 200 {
		pageSize = 200
	}

	// Repository call would go here.
	s.logger.Infof("ListAlerts: farm=%s field=%s page_size=%d", input.FarmID, input.FieldID, pageSize)

	return nil, "", 0, nil
}

func (s *alertService) GetAlert(ctx context.Context, id string) (*pb.Alert, error) {
	if strings.TrimSpace(id) == "" {
		return nil, errors.BadRequest("INVALID_ID", "id is required")
	}

	// Repository call would go here.
	s.logger.Infof("GetAlert: id=%s", id)

	return nil, errors.NotFound("ALERT_NOT_FOUND", "alert not found")
}

func (s *alertService) AcknowledgeAlert(ctx context.Context, alertID, userID string) (*pb.Alert, error) {
	if strings.TrimSpace(alertID) == "" {
		return nil, errors.BadRequest("INVALID_ALERT_ID", "alert_id is required")
	}
	if strings.TrimSpace(userID) == "" {
		userID = p9context.UserID(ctx)
	}
	if strings.TrimSpace(userID) == "" {
		return nil, errors.BadRequest("INVALID_USER_ID", "user_id is required to acknowledge an alert")
	}

	// Repository call: update status to ACKNOWLEDGED, set acknowledged_at.
	s.logger.Infof("Alert acknowledged: id=%s by=%s", alertID, userID)

	return &pb.Alert{
		Id:             alertID,
		Status:         pb.AlertStatus_ALERT_STATUS_ACKNOWLEDGED,
		AcknowledgedAt: timestamppb.Now(),
		AcknowledgedBy: userID,
	}, nil
}

func (s *alertService) ResolveAlert(ctx context.Context, alertID, userID string) (*pb.Alert, error) {
	if strings.TrimSpace(alertID) == "" {
		return nil, errors.BadRequest("INVALID_ALERT_ID", "alert_id is required")
	}
	if strings.TrimSpace(userID) == "" {
		userID = p9context.UserID(ctx)
	}
	if strings.TrimSpace(userID) == "" {
		return nil, errors.BadRequest("INVALID_USER_ID", "user_id is required to resolve an alert")
	}

	// Repository call: update status to RESOLVED, set resolved_at.
	s.logger.Infof("Alert resolved: id=%s by=%s", alertID, userID)

	return &pb.Alert{
		Id:     alertID,
		Status: pb.AlertStatus_ALERT_STATUS_RESOLVED,
	}, nil
}

// ---------- Read Status ----------

func (s *alertService) MarkAlertRead(ctx context.Context, alertID string) (*pb.Alert, error) {
	if strings.TrimSpace(alertID) == "" {
		return nil, errors.BadRequest("INVALID_ALERT_ID", "alert_id is required")
	}

	// Repository call: set read = true.
	s.logger.Infof("Alert marked read: id=%s", alertID)

	return &pb.Alert{
		Id:   alertID,
		Read: true,
	}, nil
}

func (s *alertService) MarkAllAlertsRead(ctx context.Context, farmID string) (int32, error) {
	// Repository call: set read = true for all matching alerts.
	s.logger.Infof("All alerts marked read: farm=%s", farmID)

	return 0, nil
}

func (s *alertService) GetUnreadCount(ctx context.Context, farmID string) (int32, error) {
	// Repository call: count where read = false.
	s.logger.Infof("GetUnreadCount: farm=%s", farmID)

	return 0, nil
}

// ---------- Alert Rules ----------

func (s *alertService) ListAlertRules(ctx context.Context, fieldID string) ([]*pb.AlertRule, error) {
	// Repository call would go here.
	s.logger.Infof("ListAlertRules: field=%s", fieldID)

	return nil, nil
}

func (s *alertService) CreateAlertRule(ctx context.Context, rule *pb.AlertRule) (*pb.AlertRule, error) {
	if strings.TrimSpace(rule.GetFieldId()) == "" {
		return nil, errors.BadRequest("INVALID_FIELD_ID", "field_id is required")
	}
	if strings.TrimSpace(rule.GetMetric()) == "" {
		return nil, errors.BadRequest("INVALID_METRIC", "metric is required")
	}

	if rule.Id == "" {
		rule.Id = ulid.NewString()
	}

	// Repository call would persist the rule here.
	s.logger.Infof("AlertRule created: id=%s metric=%s field=%s", rule.Id, rule.Metric, rule.FieldId)

	return rule, nil
}

func (s *alertService) UpdateAlertRule(ctx context.Context, rule *pb.AlertRule) (*pb.AlertRule, error) {
	if strings.TrimSpace(rule.GetId()) == "" {
		return nil, errors.BadRequest("INVALID_RULE_ID", "rule id is required")
	}

	// Repository call would update the rule here.
	s.logger.Infof("AlertRule updated: id=%s", rule.Id)

	return rule, nil
}

// ---------- Field Risk ----------

func (s *alertService) GetFieldRisk(ctx context.Context, fieldID string) (*pb.FieldRiskScore, error) {
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
		s.logger.Errorf("GetFieldRisk failed: field=%s err=%v", fieldID, err)
		return nil, errors.InternalServer("FIELD_EVALUATION_FAILED", "failed to evaluate field risk")
	}

	riskFactors := map[string]float64{
		"temperature": result.TemperatureRisk,
		"water":       result.WaterRisk,
		"pest":        result.PestRisk,
		"disease":     result.DiseaseRisk,
		"nutrient":    result.NutrientRisk,
		"growth":      result.GrowthRisk,
	}

	s.logger.Infof("Field risk evaluated: field=%s overall=%.2f", result.FieldID, result.OverallRisk)

	return &pb.FieldRiskScore{
		FieldId:      result.FieldID,
		OverallScore: result.OverallRisk,
		RiskFactors:  riskFactors,
		CalculatedAt: result.EvaluatedAt.Format(time.RFC3339),
	}, nil
}

func (s *alertService) ListFieldRisks(ctx context.Context) ([]*pb.FieldRiskScore, error) {
	// Repository call would go here to list all field risk scores.
	s.logger.Infof("ListFieldRisks")

	return nil, nil
}

// ---------- Alert History ----------

func (s *alertService) ListAlertHistory(ctx context.Context, input ListAlertHistoryInput) ([]*pb.Alert, string, int32, error) {
	pageSize := input.PageSize
	if pageSize <= 0 {
		pageSize = 50
	}
	if pageSize > 200 {
		pageSize = 200
	}

	// Repository call would go here with date range filtering.
	s.logger.Infof("ListAlertHistory: start=%s end=%s farm=%s field=%s page_size=%d",
		input.StartDate, input.EndDate, input.FarmID, input.FieldID, pageSize)

	return nil, "", 0, nil
}
