package services

import (
	"context"
	"strconv"
	"strings"
	"time"

	"google.golang.org/protobuf/types/known/timestamppb"

	pb "p9e.in/samavaya/agriculture/alert-service/api/v1"
	"p9e.in/samavaya/agriculture/alert-service/internal/ai"
	"p9e.in/samavaya/agriculture/alert-service/internal/clients"
	"p9e.in/samavaya/agriculture/alert-service/internal/models"
	"p9e.in/samavaya/agriculture/alert-service/internal/repositories"
	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"
)

const (
	defaultPageSize int32 = 50
	maxPageSize     int32 = 200
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

	// RecordExternalAlert stores an alert raised by another service. It is the
	// entry point for the Kafka consumer, and is idempotent on
	// (source, source alert id); the bool reports whether a row was created.
	RecordExternalAlert(ctx context.Context, tenantID string, a *models.Alert) (*models.Alert, bool, error)
}

// alertService is the concrete implementation of AlertService.
type alertService struct {
	deps deps.ServiceDeps
	repo repositories.AlertRepository
	// weatherClient and soilClient are optional. Without them a risk score is
	// computed from the gateway's defaults rather than the field, which is
	// what this service used to do unconditionally.
	weatherClient clients.WeatherClient
	soilClient    clients.SoilClient
	aiClient      *ai.AIClient
	logger        *p9log.Helper
}

// NewAlertService creates a new AlertService instance.
func NewAlertService(
	d deps.ServiceDeps,
	repo repositories.AlertRepository,
	aiClient *ai.AIClient,
	weatherClient clients.WeatherClient,
	soilClient clients.SoilClient,
) AlertService {
	return &alertService{
		deps:          d,
		repo:          repo,
		weatherClient: weatherClient,
		soilClient:    soilClient,
		aiClient:      aiClient,
		logger:        p9log.NewHelper(p9log.With(d.Log, "component", "AlertService")),
	}
}

// tenant resolves the caller's tenant, which every query is scoped by.
func (s *alertService) tenant(ctx context.Context) (string, error) {
	t := p9context.TenantID(ctx)
	if strings.TrimSpace(t) == "" {
		return "", errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	return t, nil
}

// ---------- Alert CRUD ----------

func (s *alertService) ListAlerts(ctx context.Context, input ListAlertsInput) ([]*pb.Alert, string, int32, error) {
	if strings.TrimSpace(input.FarmID) == "" && strings.TrimSpace(input.FieldID) == "" {
		return nil, "", 0, errors.BadRequest("INVALID_FILTER", "at least one of farm_id or field_id is required")
	}
	tenantID, err := s.tenant(ctx)
	if err != nil {
		return nil, "", 0, err
	}

	pageSize := clampPageSize(input.PageSize)
	offset, err := parsePageToken(input.PageToken)
	if err != nil {
		return nil, "", 0, err
	}

	alerts, total, err := s.repo.ListAlerts(ctx, tenantID, repositories.AlertFilter{
		FarmID:   input.FarmID,
		FieldID:  input.FieldID,
		Severity: severityFromProto(input.Severity),
		Statuses: statusesFromProto(input.Status),
		Offset:   offset,
		Limit:    pageSize,
	})
	if err != nil {
		return nil, "", 0, err
	}
	return alertsToProto(alerts), nextToken(offset, len(alerts), total), total, nil
}

func (s *alertService) GetAlert(ctx context.Context, id string) (*pb.Alert, error) {
	if strings.TrimSpace(id) == "" {
		return nil, errors.BadRequest("INVALID_ID", "id is required")
	}
	tenantID, err := s.tenant(ctx)
	if err != nil {
		return nil, err
	}
	a, err := s.repo.GetAlert(ctx, tenantID, id)
	if err != nil {
		return nil, err
	}
	return alertToProto(a), nil
}

func (s *alertService) AcknowledgeAlert(ctx context.Context, alertID, userID string) (*pb.Alert, error) {
	return s.transition(ctx, alertID, userID, models.AlertStatusAcknowledged, "acknowledge")
}

func (s *alertService) ResolveAlert(ctx context.Context, alertID, userID string) (*pb.Alert, error) {
	return s.transition(ctx, alertID, userID, models.AlertStatusResolved, "resolve")
}

func (s *alertService) transition(ctx context.Context, alertID, userID string, to models.AlertStatus, verb string) (*pb.Alert, error) {
	if strings.TrimSpace(alertID) == "" {
		return nil, errors.BadRequest("INVALID_ALERT_ID", "alert_id is required")
	}
	if strings.TrimSpace(userID) == "" {
		userID = p9context.UserID(ctx)
	}
	// Who acted on an alert is the whole value of the record afterwards, so an
	// anonymous transition is refused rather than attributed to nobody.
	if strings.TrimSpace(userID) == "" {
		return nil, errors.BadRequest("INVALID_USER_ID", "user_id is required to "+verb+" an alert")
	}
	tenantID, err := s.tenant(ctx)
	if err != nil {
		return nil, err
	}

	updated, err := s.repo.SetStatus(ctx, tenantID, alertID, to, userID, time.Now().UTC())
	if err != nil {
		return nil, err
	}
	s.logger.Infow("msg", "alert "+verb+"d", "alert_id", alertID, "by", userID)
	return alertToProto(updated), nil
}

// ---------- Read Status ----------

func (s *alertService) MarkAlertRead(ctx context.Context, alertID string) (*pb.Alert, error) {
	if strings.TrimSpace(alertID) == "" {
		return nil, errors.BadRequest("INVALID_ALERT_ID", "alert_id is required")
	}
	tenantID, err := s.tenant(ctx)
	if err != nil {
		return nil, err
	}
	a, err := s.repo.MarkRead(ctx, tenantID, alertID)
	if err != nil {
		return nil, err
	}
	return alertToProto(a), nil
}

func (s *alertService) MarkAllAlertsRead(ctx context.Context, farmID string) (int32, error) {
	tenantID, err := s.tenant(ctx)
	if err != nil {
		return 0, err
	}
	n, err := s.repo.MarkAllRead(ctx, tenantID, farmID)
	if err != nil {
		return 0, err
	}
	s.logger.Infow("msg", "alerts marked read", "farm_id", farmID, "count", n)
	return n, nil
}

func (s *alertService) GetUnreadCount(ctx context.Context, farmID string) (int32, error) {
	tenantID, err := s.tenant(ctx)
	if err != nil {
		return 0, err
	}
	return s.repo.UnreadCount(ctx, tenantID, farmID)
}

// ---------- Alert Rules ----------

func (s *alertService) ListAlertRules(ctx context.Context, fieldID string) ([]*pb.AlertRule, error) {
	tenantID, err := s.tenant(ctx)
	if err != nil {
		return nil, err
	}
	rules, err := s.repo.ListRules(ctx, tenantID, fieldID)
	if err != nil {
		return nil, err
	}
	out := make([]*pb.AlertRule, 0, len(rules))
	for _, r := range rules {
		out = append(out, ruleToProto(r))
	}
	return out, nil
}

func (s *alertService) CreateAlertRule(ctx context.Context, rule *pb.AlertRule) (*pb.AlertRule, error) {
	if strings.TrimSpace(rule.GetFieldId()) == "" {
		return nil, errors.BadRequest("INVALID_FIELD_ID", "field_id is required")
	}
	if strings.TrimSpace(rule.GetMetric()) == "" {
		return nil, errors.BadRequest("INVALID_METRIC", "metric is required")
	}
	tenantID, err := s.tenant(ctx)
	if err != nil {
		return nil, err
	}
	if rule.Id == "" {
		rule.Id = ulid.NewString()
	}

	created, err := s.repo.CreateRule(ctx, tenantID, ruleFromProto(rule))
	if err != nil {
		return nil, err
	}
	s.logger.Infow("msg", "alert rule created", "rule_id", created.ID, "metric", created.Metric, "field_id", created.FieldID)
	return ruleToProto(created), nil
}

func (s *alertService) UpdateAlertRule(ctx context.Context, rule *pb.AlertRule) (*pb.AlertRule, error) {
	if strings.TrimSpace(rule.GetId()) == "" {
		return nil, errors.BadRequest("INVALID_RULE_ID", "rule id is required")
	}
	tenantID, err := s.tenant(ctx)
	if err != nil {
		return nil, err
	}
	updated, err := s.repo.UpdateRule(ctx, tenantID, ruleFromProto(rule))
	if err != nil {
		return nil, err
	}
	s.logger.Infow("msg", "alert rule updated", "rule_id", updated.ID)
	return ruleToProto(updated), nil
}

// ---------- Field Risk ----------

// fieldConditions gathers what this service can learn about a field's current
// state before asking the gateway to score it.
//
// Failures are logged and skipped rather than returned. A risk evaluation that
// refuses to run because weather-service is briefly unreachable is worse than
// one computed from fewer inputs: the scanner would then raise nothing at all
// for that field, and a farmer waiting on a threshold hears silence. What each
// call did or did not contribute is logged, so a score that looks wrong can be
// traced to the inputs it was built from rather than guessed at.
func (s *alertService) fieldConditions(ctx context.Context, fieldID string) ai.FieldConditions {
	var cond ai.FieldConditions
	haveSoil := false

	if s.weatherClient != nil {
		w, err := s.weatherClient.FieldWeather(ctx, fieldID)
		switch {
		case err != nil:
			s.logger.Warnw("msg", "no weather for field; risk will be scored against gateway defaults",
				"field_id", fieldID, "error", err)
		case w != nil:
			cond.TemperatureCurrent = w.TemperatureCurrent
			cond.TemperatureMinForecast = w.TemperatureMinForecast
			cond.TemperatureMaxForecast = w.TemperatureMaxForecast
			cond.PrecipitationMm = w.PrecipitationMm
			cond.PrecipitationForecastMm = w.PrecipitationForecastMm
			cond.EtReferenceMm = w.EtReferenceMm
			if w.HasSoilMoisture {
				cond.SoilMoisture, haveSoil = w.SoilMoisture, true
			}
		}
	}

	// soil-service is the fallback, not the first choice. A weather
	// observation's soil moisture is continuous and current; a soil sample is
	// an occasional lab result, so it is the better answer only when there is
	// no observation to prefer.
	if !haveSoil && s.soilClient != nil {
		moisture, found, err := s.soilClient.LatestMoistureFraction(ctx, fieldID)
		switch {
		case err != nil:
			s.logger.Warnw("msg", "no soil moisture for field; water risk will be scored against the gateway default",
				"field_id", fieldID, "error", err)
		case found:
			cond.SoilMoisture, haveSoil = moisture, true
		}
	}

	s.logger.Infow("msg", "field conditions gathered",
		"field_id", fieldID,
		"has_weather", cond.TemperatureCurrent != 0 || cond.PrecipitationMm != 0,
		"has_soil_moisture", haveSoil)
	return cond
}

func (s *alertService) GetFieldRisk(ctx context.Context, fieldID string) (*pb.FieldRiskScore, error) {
	if strings.TrimSpace(fieldID) == "" {
		return nil, errors.BadRequest("INVALID_FIELD_ID", "field_id is required")
	}
	if s.aiClient == nil {
		return nil, errors.InternalServer("AI_CLIENT_UNAVAILABLE", "AI Gateway client is not configured")
	}
	tenantID, err := s.tenant(ctx)
	if err != nil {
		return nil, err
	}

	requestID := p9context.RequestID(ctx)
	if requestID == "" {
		requestID = ulid.NewString()
	}

	result, err := s.aiClient.EvaluateFieldRisk(ctx, requestID, fieldID, s.fieldConditions(ctx, fieldID))
	if err != nil {
		s.logger.Errorw("msg", "field risk evaluation failed", "field_id", fieldID, "error", err)
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

	// Cached so that ListFieldRisks can render a farm overview from one query
	// instead of fanning out a gateway call per field. A cache write failing
	// must not fail the call the user actually made — they asked for this
	// field's risk, and they have it.
	if err := s.repo.UpsertFieldRisk(ctx, tenantID, &models.FieldRiskScore{
		FieldID:     result.FieldID,
		OverallRisk: result.OverallRisk,
		RiskFactors: riskFactors,
		EvaluatedAt: result.EvaluatedAt,
	}); err != nil {
		s.logger.Warnw("msg", "field risk cached failed", "field_id", fieldID, "error", err)
	}

	s.logger.Infow("msg", "field risk evaluated", "field_id", result.FieldID, "overall", result.OverallRisk)

	return &pb.FieldRiskScore{
		FieldId:      result.FieldID,
		OverallScore: result.OverallRisk,
		RiskFactors:  riskFactors,
		CalculatedAt: result.EvaluatedAt.Format(time.RFC3339),
	}, nil
}

func (s *alertService) ListFieldRisks(ctx context.Context) ([]*pb.FieldRiskScore, error) {
	tenantID, err := s.tenant(ctx)
	if err != nil {
		return nil, err
	}
	scores, err := s.repo.ListFieldRisks(ctx, tenantID, "")
	if err != nil {
		return nil, err
	}
	out := make([]*pb.FieldRiskScore, 0, len(scores))
	for _, sc := range scores {
		out = append(out, &pb.FieldRiskScore{
			FieldId:      sc.FieldID,
			OverallScore: sc.OverallRisk,
			RiskFactors:  sc.RiskFactors,
			CalculatedAt: sc.CalculatedAt,
		})
	}
	return out, nil
}

// ---------- Alert History ----------

func (s *alertService) ListAlertHistory(ctx context.Context, input ListAlertHistoryInput) ([]*pb.Alert, string, int32, error) {
	tenantID, err := s.tenant(ctx)
	if err != nil {
		return nil, "", 0, err
	}
	pageSize := clampPageSize(input.PageSize)
	offset, err := parsePageToken(input.PageToken)
	if err != nil {
		return nil, "", 0, err
	}

	since, err := parseDate(input.StartDate, "start_date")
	if err != nil {
		return nil, "", 0, err
	}
	until, err := parseDate(input.EndDate, "end_date")
	if err != nil {
		return nil, "", 0, err
	}
	if since != nil && until != nil && until.Before(*since) {
		return nil, "", 0, errors.BadRequest("INVALID_DATE_RANGE", "end_date is before start_date")
	}
	if until != nil {
		// A bare date means the whole of that day, not its first instant —
		// otherwise "to the 5th" silently excludes everything on the 5th.
		end := until.Add(24*time.Hour - time.Nanosecond)
		until = &end
	}

	alerts, total, err := s.repo.ListAlerts(ctx, tenantID, repositories.AlertFilter{
		FarmID:  input.FarmID,
		FieldID: input.FieldID,
		Since:   since,
		Until:   until,
		Offset:  offset,
		Limit:   pageSize,
	})
	if err != nil {
		return nil, "", 0, err
	}
	return alertsToProto(alerts), nextToken(offset, len(alerts), total), total, nil
}

// ---------- Ingest ----------

func (s *alertService) RecordExternalAlert(ctx context.Context, tenantID string, a *models.Alert) (*models.Alert, bool, error) {
	if a == nil {
		return nil, false, errors.BadRequest("INVALID_ALERT", "alert is required")
	}
	if a.ID == "" {
		a.ID = ulid.NewString()
	}
	stored, created, err := s.repo.UpsertSourcedAlert(ctx, tenantID, a)
	if err != nil {
		return nil, false, err
	}
	if created {
		s.logger.Infow("msg", "alert ingested",
			"source", a.Source, "source_alert_id", a.SourceAlertID,
			"field_id", a.FieldID, "type", a.AlertType, "severity", a.Severity)
	}
	return stored, created, nil
}

// ---------- helpers ----------

func clampPageSize(n int32) int32 {
	if n <= 0 {
		return defaultPageSize
	}
	if n > maxPageSize {
		return maxPageSize
	}
	return n
}

// parsePageToken reads the offset out of a page token.
//
// Rejecting a malformed token rather than silently restarting at zero: a client
// that has corrupted its token is better told so than handed page one again
// under the impression it is paging forward.
func parsePageToken(token string) (int32, error) {
	if strings.TrimSpace(token) == "" {
		return 0, nil
	}
	n, err := strconv.Atoi(token)
	if err != nil || n < 0 {
		return 0, errors.BadRequest("INVALID_PAGE_TOKEN", "page_token is not valid")
	}
	return int32(n), nil
}

// nextToken advances by the rows actually returned, so a short page cannot
// produce a token that points at where the caller already is.
func nextToken(offset int32, returned int, total int32) string {
	next := offset + int32(returned)
	if returned == 0 || next >= total {
		return ""
	}
	return strconv.Itoa(int(next))
}

func parseDate(s, field string) (*time.Time, error) {
	if strings.TrimSpace(s) == "" {
		return nil, nil
	}
	// RFC 3339 first, since that is what the rest of the platform emits;
	// a bare date is accepted because it is what a human types.
	if t, err := time.Parse(time.RFC3339, s); err == nil {
		u := t.UTC()
		return &u, nil
	}
	if t, err := time.Parse("2006-01-02", s); err == nil {
		u := t.UTC()
		return &u, nil
	}
	return nil, errors.BadRequest("INVALID_DATE",
		field+" must be RFC 3339 or YYYY-MM-DD")
}

func severityFromProto(s pb.AlertSeverity) models.AlertSeverity {
	switch s {
	case pb.AlertSeverity_ALERT_SEVERITY_INFO:
		return models.AlertSeverityInfo
	case pb.AlertSeverity_ALERT_SEVERITY_WARNING:
		return models.AlertSeverityWarning
	case pb.AlertSeverity_ALERT_SEVERITY_CRITICAL:
		return models.AlertSeverityCritical
	case pb.AlertSeverity_ALERT_SEVERITY_EMERGENCY:
		return models.AlertSeverityEmergency
	default:
		return ""
	}
}

func severityToProto(s models.AlertSeverity) pb.AlertSeverity {
	switch s {
	case models.AlertSeverityInfo:
		return pb.AlertSeverity_ALERT_SEVERITY_INFO
	case models.AlertSeverityWarning:
		return pb.AlertSeverity_ALERT_SEVERITY_WARNING
	case models.AlertSeverityCritical:
		return pb.AlertSeverity_ALERT_SEVERITY_CRITICAL
	case models.AlertSeverityEmergency:
		return pb.AlertSeverity_ALERT_SEVERITY_EMERGENCY
	default:
		return pb.AlertSeverity_ALERT_SEVERITY_UNSPECIFIED
	}
}

// statusesFromProto expands a requested status into the stored statuses that
// satisfy it. RESOLVED covers EXPIRED too, because the proto has no separate
// value for it and a caller asking for closed alerts means both.
func statusesFromProto(s pb.AlertStatus) []models.AlertStatus {
	switch s {
	case pb.AlertStatus_ALERT_STATUS_ACTIVE:
		return []models.AlertStatus{models.AlertStatusActive}
	case pb.AlertStatus_ALERT_STATUS_ACKNOWLEDGED:
		return []models.AlertStatus{models.AlertStatusAcknowledged}
	case pb.AlertStatus_ALERT_STATUS_RESOLVED:
		return []models.AlertStatus{models.AlertStatusResolved, models.AlertStatusExpired}
	default:
		return nil
	}
}

func statusToProto(s models.AlertStatus) pb.AlertStatus {
	switch s {
	case models.AlertStatusActive:
		return pb.AlertStatus_ALERT_STATUS_ACTIVE
	case models.AlertStatusAcknowledged:
		return pb.AlertStatus_ALERT_STATUS_ACKNOWLEDGED
	case models.AlertStatusResolved, models.AlertStatusExpired:
		// The proto has no EXPIRED. Reported as RESOLVED because both mean the
		// alert is closed and needs no action, which is the distinction a
		// client acts on; `resolved_at` being absent is what separates them
		// internally. Adding the enum value is a safe, non-breaking proto
		// change, but the generated Dart cannot be regenerated in this
		// environment, so it waits for a batch that can.
		return pb.AlertStatus_ALERT_STATUS_RESOLVED
	default:
		return pb.AlertStatus_ALERT_STATUS_UNSPECIFIED
	}
}

// alertToProto maps the stored alert onto the wire message.
//
// The model is wider than the proto: metric_value, threshold_value,
// resolved_at, expires_at and the source pair are persisted but have no field
// to go in. Rather than drop the two numeric ones — they are what makes an
// alert actionable, "soil moisture 0.11 against a threshold of 0.15" rather
// than "soil is dry" — they are folded into the existing metrics map.
func alertToProto(a *models.Alert) *pb.Alert {
	if a == nil {
		return nil
	}
	metrics := make(map[string]float64, len(a.Metrics)+2)
	for k, v := range a.Metrics {
		metrics[k] = v
	}
	if a.MetricValue != 0 {
		metrics["value"] = a.MetricValue
	}
	if a.ThresholdValue != 0 {
		metrics["threshold"] = a.ThresholdValue
	}

	out := &pb.Alert{
		Id:              a.ID,
		FieldId:         a.FieldID,
		FarmId:          a.FarmID,
		FieldName:       a.FieldName,
		Type:            string(a.AlertType),
		Severity:        severityToProto(a.Severity),
		Status:          statusToProto(a.Status),
		Title:           a.Title,
		Message:         a.Message,
		Read:            a.Read,
		ActionUrl:       a.ActionURL,
		Recommendations: a.Recommendations,
		Metrics:         metrics,
		AcknowledgedBy:  a.AcknowledgedBy,
	}
	if !a.CreatedAt.IsZero() {
		out.Timestamp = timestamppb.New(a.CreatedAt)
	}
	if a.AcknowledgedAt != nil {
		out.AcknowledgedAt = timestamppb.New(*a.AcknowledgedAt)
	}
	return out
}

func alertsToProto(in []*models.Alert) []*pb.Alert {
	out := make([]*pb.Alert, 0, len(in))
	for _, a := range in {
		out = append(out, alertToProto(a))
	}
	return out
}

func ruleToProto(r *models.AlertRule) *pb.AlertRule {
	if r == nil {
		return nil
	}
	// alert_type and cooldown_minutes are stored but have no proto field yet.
	// The cooldown in particular matters — it is what stops a sensor parked
	// just over its threshold from raising an alert on every reading — so it
	// is honoured server-side using the column default until the proto can
	// carry it.
	return &pb.AlertRule{
		Id:             r.ID,
		FieldId:        r.FieldID,
		Metric:         r.Metric,
		Condition:      r.Condition,
		Threshold:      r.Threshold,
		Severity:       severityToProto(r.Severity),
		Enabled:        r.Enabled,
		NotifyChannels: r.NotifyChannels,
	}
}

func ruleFromProto(r *pb.AlertRule) *models.AlertRule {
	if r == nil {
		return nil
	}
	return &models.AlertRule{
		ID:             r.GetId(),
		FieldID:        r.GetFieldId(),
		Metric:         r.GetMetric(),
		Condition:      r.GetCondition(),
		Threshold:      r.GetThreshold(),
		Severity:       severityFromProto(r.GetSeverity()),
		Enabled:        r.GetEnabled(),
		NotifyChannels: r.GetNotifyChannels(),
	}
}
