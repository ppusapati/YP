// Package events holds alert-service's inbound Kafka adapter.
//
// This is what makes alert-service an alert service rather than a table.
// Weather raises frost warnings, sensors raise threshold breaches, pest
// prediction raises outbreak risks — and before this, each of those lived only
// in its own service's logs. A farmer had three places to look, none of which
// told them what still needed attention.
package events

import (
	"context"
	"fmt"
	"strings"
	"time"

	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9log"

	"p9e.in/samavaya/agriculture/alert-service/internal/models"
	"p9e.in/samavaya/agriculture/alert-service/internal/services"
)

// Topics this consumer subscribes to.
const (
	WeatherEventTopic = "samavaya.agriculture.weather.events"
	SensorEventTopic  = "samavaya.agriculture.sensor.events"
	PestEventTopic    = "samavaya.agriculture.pest-prediction.events"
)

// Event types that carry an alert. Everything else on these topics is ignored.
const (
	weatherAlertTriggered = "agriculture.weather.alert.triggered"
	sensorAlertTriggered  = "agriculture.sensor.alert.triggered"
	pestPredicted         = "agriculture.pest-prediction.predicted"
)

// Source names recorded against ingested alerts. They are half of the
// idempotency key, so they must stay stable: changing one makes every alert
// already stored under the old name look like a different alert.
const (
	sourceWeather = "weather-service"
	sourceSensor  = "sensor-service"
	sourcePest    = "pest-prediction-service"
)

// pestRiskThreshold is the probability above which a prediction becomes an
// alert. Below it a prediction is information, and surfacing every one of them
// as something needing attention is how an alert list gets ignored.
const pestRiskThreshold = 0.6

// AlertConsumer turns alert events from other services into stored alerts.
type AlertConsumer struct {
	svc services.AlertService
	log *p9log.Helper
}

// NewAlertConsumer creates the consumer.
func NewAlertConsumer(svc services.AlertService, log p9log.Logger) *AlertConsumer {
	return &AlertConsumer{
		svc: svc,
		log: p9log.NewHelper(p9log.With(log, "component", "AlertConsumer")),
	}
}

// Topics returns the Kafka topics this consumer listens on.
func (c *AlertConsumer) Topics() []string {
	return []string{WeatherEventTopic, SensorEventTopic, PestEventTopic}
}

// HandleEvent dispatches one event.
//
// The error contract matters more than it looks. Returning an error makes the
// consumer retry, and retrying forever on a message that can never succeed —
// one with no tenant, say — blocks the partition and stops every later alert.
// So a malformed or unusable message is logged and accepted; only a failure
// that a retry could plausibly fix is returned.
func (c *AlertConsumer) HandleEvent(ctx context.Context, event *domain.DomainEvent) error {
	if event == nil {
		return fmt.Errorf("received nil event")
	}
	switch event.Type {
	case weatherAlertTriggered:
		return c.onWeatherAlert(ctx, event)
	case sensorAlertTriggered:
		return c.onSensorAlert(ctx, event)
	case pestPredicted:
		return c.onPestPrediction(ctx, event)
	default:
		return nil
	}
}

func (c *AlertConsumer) onWeatherAlert(ctx context.Context, e *domain.DomainEvent) error {
	tenantID := str(e.Data, "tenant_id")
	fieldID := str(e.Data, "field_id")
	if !c.usable(e, tenantID, fieldID) {
		return nil
	}

	alertType := models.AlertType(strings.ToUpper(str(e.Data, "alert_type")))
	if !alertType.IsValid() {
		// The weather service's vocabulary and this one's are meant to match.
		// Storing an unrecognised type rather than dropping the alert keeps
		// the farmer informed; the log is how the mismatch gets noticed.
		c.log.Warnw("msg", "unrecognised weather alert type",
			"alert_type", str(e.Data, "alert_type"), "event_id", e.ID)
	}

	a := &models.Alert{
		FieldID:        fieldID,
		FarmID:         str(e.Data, "farm_id"),
		AlertType:      alertType,
		Severity:       severity(str(e.Data, "severity")),
		Status:         models.AlertStatusActive,
		Title:          weatherTitle(alertType),
		Message:        str(e.Data, "message"),
		Source:         sourceWeather,
		SourceAlertID:  sourceID(e, "alert_id"),
		MetricValue:    num(e.Data, "value"),
		ThresholdValue: num(e.Data, "threshold"),
		CreatedAt:      e.Timestamp,
		// Weather alerts describe a forecast window, so they stop being true
		// on their own. Carrying valid_to through means the list clears itself
		// instead of accumulating last week's frost warnings.
		ExpiresAt: tstamp(e.Data, "valid_to"),
	}
	return c.record(ctx, tenantID, a)
}

func (c *AlertConsumer) onSensorAlert(ctx context.Context, e *domain.DomainEvent) error {
	tenantID := str(e.Data, "tenant_id")
	fieldID := str(e.Data, "field_id")
	if !c.usable(e, tenantID, fieldID) {
		return nil
	}

	sensorType := str(e.Data, "sensor_type")
	value := num(e.Data, "actual_value")
	threshold := num(e.Data, "threshold")

	a := &models.Alert{
		FieldID:   fieldID,
		FarmID:    str(e.Data, "farm_id"),
		AlertType: sensorAlertType(sensorType),
		Severity:  severity(str(e.Data, "severity")),
		Status:    models.AlertStatusActive,
		Title:     sensorTitle(sensorType),
		// Built here rather than taken from the event because the sensor
		// service does not send one, and "sensor alert" on its own tells a
		// farmer nothing they can act on.
		Message:        sensorMessage(sensorType, str(e.Data, "condition"), value, threshold),
		Source:         sourceSensor,
		SourceAlertID:  sourceID(e, "alert_id"),
		MetricValue:    value,
		ThresholdValue: threshold,
		Metrics:        map[string]float64{"reading": value, "threshold": threshold},
		CreatedAt:      e.Timestamp,
	}
	return c.record(ctx, tenantID, a)
}

func (c *AlertConsumer) onPestPrediction(ctx context.Context, e *domain.DomainEvent) error {
	tenantID := str(e.Data, "tenant_id")
	fieldID := str(e.Data, "field_id")
	if !c.usable(e, tenantID, fieldID) {
		return nil
	}

	// The pest service sends its domain's 0-100 integer. Normalised here
	// rather than there so the event keeps agreeing with every other place the
	// score appears; a value already in [0,1] is taken as-is so that a future
	// producer sending a fraction is not read as a 40% risk being 0.4%.
	risk := num(e.Data, "risk_score")
	if risk > 1 {
		risk /= 100
	}
	if risk < pestRiskThreshold {
		// Not an error and not worth a warning: most predictions are low risk,
		// and that is the system working.
		return nil
	}

	// Falls back to a generic title when the species is not named, rather than
	// substituting something else in the payload — "Cotton risk" from the crop
	// type would read as a pest and be wrong.
	pest := str(e.Data, "pest_name")
	if pest == "" {
		pest = str(e.Data, "pest_species")
	}

	a := &models.Alert{
		FieldID:   fieldID,
		FarmID:    str(e.Data, "farm_id"),
		AlertType: models.AlertTypePestOutbreak,
		// Severity from the risk score rather than from a field the pest
		// service does not send, so the banding is at least consistent.
		Severity:       pestSeverity(risk),
		Status:         models.AlertStatusActive,
		Title:          pestTitle(pest),
		Message:        pestMessage(pest, risk),
		Source:         sourcePest,
		SourceAlertID:  sourceID(e, "prediction_id"),
		MetricValue:    risk,
		ThresholdValue: pestRiskThreshold,
		Metrics:        map[string]float64{"risk_score": risk},
		CreatedAt:      e.Timestamp,
	}
	return c.record(ctx, tenantID, a)
}

// usable reports whether an event carries enough to store an alert against.
func (c *AlertConsumer) usable(e *domain.DomainEvent, tenantID, fieldID string) bool {
	if tenantID == "" {
		// Without a tenant there is nobody to show the alert to, and guessing
		// one would put another tenant's alert in somebody's list.
		c.log.Warnw("msg", "alert event has no tenant; dropping",
			"event_id", e.ID, "type", e.Type)
		return false
	}
	if fieldID == "" {
		c.log.Warnw("msg", "alert event has no field; dropping",
			"event_id", e.ID, "type", e.Type)
		return false
	}
	return true
}

// record stores the alert, logging rather than failing when a duplicate
// arrives — a replay is the expected case, not an error.
func (c *AlertConsumer) record(ctx context.Context, tenantID string, a *models.Alert) error {
	if a.CreatedAt.IsZero() {
		a.CreatedAt = time.Now().UTC()
	}
	_, created, err := c.svc.RecordExternalAlert(ctx, tenantID, a)
	if err != nil {
		// Returned, so the consumer retries: a database that is briefly
		// unavailable should not lose the alert.
		c.log.Errorw("msg", "failed to record alert", "source", a.Source,
			"source_alert_id", a.SourceAlertID, "error", err)
		return err
	}
	if !created {
		c.log.Debugw("msg", "duplicate alert ignored",
			"source", a.Source, "source_alert_id", a.SourceAlertID)
	}
	return nil
}

// ---------------------------------------------------------------------------
// Field extraction
//
// Every event on these topics is JSON from another service, so nothing here
// may assume a type. A wrong assumption would panic the consumer and stop the
// partition, which is a far worse outcome than one badly-formed alert.
// ---------------------------------------------------------------------------

func str(m map[string]interface{}, key string) string {
	if m == nil {
		return ""
	}
	s, _ := m[key].(string)
	return strings.TrimSpace(s)
}

func num(m map[string]interface{}, key string) float64 {
	if m == nil {
		return 0
	}
	switch v := m[key].(type) {
	case float64:
		return v
	case float32:
		return float64(v)
	case int:
		return float64(v)
	case int64:
		return float64(v)
	default:
		return 0
	}
}

// tstamp reads a timestamp that JSON has rendered as an RFC 3339 string.
func tstamp(m map[string]interface{}, key string) *time.Time {
	raw := str(m, key)
	if raw == "" {
		return nil
	}
	t, err := time.Parse(time.RFC3339, raw)
	if err != nil {
		return nil
	}
	u := t.UTC()
	return &u
}

// sourceID picks the upstream's identifier for the alert, falling back to the
// event's aggregate id. It must never be empty: an alert stored without one
// bypasses the uniqueness constraint and will be duplicated on every replay.
func sourceID(e *domain.DomainEvent, key string) string {
	if id := str(e.Data, key); id != "" {
		return id
	}
	if e.AggregateID != "" {
		return e.AggregateID
	}
	return e.ID
}

func severity(raw string) models.AlertSeverity {
	s := models.AlertSeverity(strings.ToUpper(strings.TrimSpace(raw)))
	if s.IsValid() {
		return s
	}
	// WARNING rather than INFO: an alert whose severity did not survive the
	// wire should be visible, not filed quietly at the bottom of the list.
	return models.AlertSeverityWarning
}

func pestSeverity(risk float64) models.AlertSeverity {
	switch {
	case risk >= 0.85:
		return models.AlertSeverityCritical
	case risk >= 0.7:
		return models.AlertSeverityWarning
	default:
		return models.AlertSeverityInfo
	}
}

// sensorAlertType maps a sensor's kind onto the alert vocabulary, so that a
// soil-moisture breach files alongside a weather drought warning rather than
// in a category of its own.
func sensorAlertType(sensorType string) models.AlertType {
	switch strings.ToUpper(sensorType) {
	case "SOIL_MOISTURE", "MOISTURE":
		return models.AlertTypeWaterStress
	case "TEMPERATURE", "AIR_TEMPERATURE":
		return models.AlertTypeHeatStress
	case "RAINFALL", "RAIN_GAUGE":
		return models.AlertTypeExcessiveRain
	case "NUTRIENT", "EC", "NPK":
		return models.AlertTypeNutrientDeficiency
	default:
		return models.AlertTypeGrowthAnomaly
	}
}

func weatherTitle(t models.AlertType) string {
	switch t {
	case models.AlertTypeFrostRisk:
		return "Frost risk"
	case models.AlertTypeHeatStress:
		return "Heat stress"
	case models.AlertTypeDroughtWarning:
		return "Drought warning"
	case models.AlertTypeExcessiveRain:
		return "Heavy rain expected"
	default:
		return "Weather alert"
	}
}

func sensorTitle(sensorType string) string {
	if sensorType == "" {
		return "Sensor threshold exceeded"
	}
	return humanise(sensorType) + " threshold exceeded"
}

func sensorMessage(sensorType, condition string, value, threshold float64) string {
	name := humanise(sensorType)
	if name == "" {
		name = "Sensor reading"
	}
	direction := "above"
	if strings.Contains(strings.ToUpper(condition), "LT") ||
		strings.Contains(strings.ToUpper(condition), "BELOW") {
		direction = "below"
	}
	return fmt.Sprintf("%s is %.2f, %s the threshold of %.2f.", name, value, direction, threshold)
}

func pestTitle(pest string) string {
	if pest == "" {
		return "Pest risk"
	}
	return pest + " risk"
}

func pestMessage(pest string, risk float64) string {
	if pest == "" {
		pest = "Pest"
	}
	return fmt.Sprintf("%s risk is %.0f%% for this field. Scout before deciding to spray.",
		pest, risk*100)
}

// humanise turns SOIL_MOISTURE into "Soil moisture".
func humanise(s string) string {
	s = strings.TrimSpace(strings.ReplaceAll(s, "_", " "))
	if s == "" {
		return ""
	}
	lower := strings.ToLower(s)
	return strings.ToUpper(lower[:1]) + lower[1:]
}
