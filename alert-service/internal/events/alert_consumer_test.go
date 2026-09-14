package events

import (
	"context"
	"errors"
	"strings"
	"sync"
	"testing"
	"time"

	"p9e.in/samavaya/agriculture/alert-service/internal/models"
	"p9e.in/samavaya/agriculture/alert-service/internal/services"
	eventsdomain "p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/testutil"
)

// recordingService captures what the consumer would store, so the tests can
// assert on the alert rather than on the database.
type recordingService struct {
	services.AlertService // nil: the consumer only calls RecordExternalAlert

	mu       sync.Mutex
	recorded []*models.Alert
	tenants  []string
	seen     map[string]bool
	err      error
}

func newRecordingService() *recordingService {
	return &recordingService{seen: map[string]bool{}}
}

func (s *recordingService) RecordExternalAlert(_ context.Context, tenantID string, a *models.Alert) (*models.Alert, bool, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if s.err != nil {
		return nil, false, s.err
	}
	key := tenantID + "|" + a.Source + "|" + a.SourceAlertID
	created := !s.seen[key]
	s.seen[key] = true
	if created {
		s.recorded = append(s.recorded, a)
		s.tenants = append(s.tenants, tenantID)
	}
	return a, created, nil
}

func (s *recordingService) only(t *testing.T) *models.Alert {
	t.Helper()
	s.mu.Lock()
	defer s.mu.Unlock()
	if len(s.recorded) != 1 {
		t.Fatalf("recorded %d alerts, want exactly 1", len(s.recorded))
	}
	return s.recorded[0]
}

func (s *recordingService) count() int {
	s.mu.Lock()
	defer s.mu.Unlock()
	return len(s.recorded)
}

func newConsumer() (*AlertConsumer, *recordingService) {
	svc := newRecordingService()
	return NewAlertConsumer(svc, testutil.NopLogger{}), svc
}

func event(eventType string, data map[string]interface{}) *eventsdomain.DomainEvent {
	return &eventsdomain.DomainEvent{
		ID:          "evt-1",
		Type:        eventsdomain.EventType(eventType),
		AggregateID: "agg-1",
		Timestamp:   time.Date(2026, 3, 15, 6, 0, 0, 0, time.UTC),
		Data:        data,
	}
}

func handle(t *testing.T, c *AlertConsumer, e *eventsdomain.DomainEvent) {
	t.Helper()
	if err := c.HandleEvent(context.Background(), e); err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}
}

// ── Weather ─────────────────────────────────────────────────────────────────

func TestWeatherAlertBecomesAnAlert(t *testing.T) {
	c, svc := newConsumer()
	handle(t, c, event(weatherAlertTriggered, map[string]interface{}{
		"alert_id": "wa-1", "tenant_id": "t-1", "field_id": "f-1", "farm_id": "fm-1",
		"alert_type": "FROST_RISK", "severity": "CRITICAL",
		"message": "Frost expected before dawn.",
		"value":   1.2, "threshold": 2.0,
		"valid_to": "2026-03-16T06:00:00Z",
	}))

	a := svc.only(t)
	if a.AlertType != models.AlertTypeFrostRisk {
		t.Errorf("alert type %q", a.AlertType)
	}
	if a.Severity != models.AlertSeverityCritical {
		t.Errorf("severity %q", a.Severity)
	}
	if a.Source != sourceWeather || a.SourceAlertID != "wa-1" {
		t.Errorf("source %q/%q; the idempotency key is wrong", a.Source, a.SourceAlertID)
	}
	if a.MetricValue != 1.2 || a.ThresholdValue != 2.0 {
		t.Errorf("value/threshold %v/%v; the numbers are what make it actionable",
			a.MetricValue, a.ThresholdValue)
	}
	// A frost warning for last night should not still be in the list tomorrow.
	if a.ExpiresAt == nil {
		t.Error("valid_to did not become an expiry; the list would accumulate stale warnings")
	} else if got := a.ExpiresAt.UTC(); !got.Equal(time.Date(2026, 3, 16, 6, 0, 0, 0, time.UTC)) {
		t.Errorf("expires at %s", got)
	}
	if svc.tenants[0] != "t-1" {
		t.Errorf("stored against tenant %q", svc.tenants[0])
	}
}

func TestReplayedAlertIsNotDuplicated(t *testing.T) {
	// Kafka delivery is at-least-once and a rebalance replays whatever was in
	// flight. Without a stable source id the same frost warning lands in the
	// farmer's list several times and the list stops being believed.
	c, svc := newConsumer()
	e := event(weatherAlertTriggered, map[string]interface{}{
		"alert_id": "wa-1", "tenant_id": "t-1", "field_id": "f-1",
		"alert_type": "FROST_RISK", "severity": "CRITICAL",
	})
	handle(t, c, e)
	handle(t, c, e)
	handle(t, c, e)

	if n := svc.count(); n != 1 {
		t.Errorf("recorded %d alerts for three deliveries of one event, want 1", n)
	}
}

func TestAlertWithoutAnUpstreamIDStillGetsAStableKey(t *testing.T) {
	// An alert stored with an empty source id bypasses the uniqueness index
	// and duplicates on every replay, so the id falls back to the aggregate.
	c, svc := newConsumer()
	e := event(weatherAlertTriggered, map[string]interface{}{
		"tenant_id": "t-1", "field_id": "f-1", "alert_type": "HEAT_STRESS",
	})
	handle(t, c, e)
	handle(t, c, e)

	if n := svc.count(); n != 1 {
		t.Errorf("recorded %d alerts, want 1", n)
	}
	if id := svc.only(t).SourceAlertID; id == "" {
		t.Error("source alert id is empty; this alert would duplicate on replay")
	}
}

func TestUnknownSeverityBecomesWarningNotInfo(t *testing.T) {
	// An alert whose severity did not survive the wire should be visible, not
	// filed quietly at the bottom of the list.
	c, svc := newConsumer()
	handle(t, c, event(weatherAlertTriggered, map[string]interface{}{
		"alert_id": "wa-9", "tenant_id": "t-1", "field_id": "f-1",
		"alert_type": "FROST_RISK", "severity": "CATASTROPHIC",
	}))
	if got := svc.only(t).Severity; got != models.AlertSeverityWarning {
		t.Errorf("severity %q, want WARNING", got)
	}
}

func TestAnUnrecognisedAlertTypeIsStillStored(t *testing.T) {
	// The two services' vocabularies are meant to match. When they do not, the
	// farmer should still learn about the condition.
	c, svc := newConsumer()
	handle(t, c, event(weatherAlertTriggered, map[string]interface{}{
		"alert_id": "wa-2", "tenant_id": "t-1", "field_id": "f-1",
		"alert_type": "HAIL_RISK", "severity": "WARNING",
	}))
	if got := svc.only(t).AlertType; string(got) != "HAIL_RISK" {
		t.Errorf("alert type %q, want the upstream value preserved", got)
	}
}

// ── Sensor ──────────────────────────────────────────────────────────────────

func TestSensorAlertIsFiledUnderAnAgronomicType(t *testing.T) {
	// A soil-moisture breach should sit alongside a weather drought warning,
	// not in a category of its own — that is the whole point of one list.
	c, svc := newConsumer()
	handle(t, c, event(sensorAlertTriggered, map[string]interface{}{
		"alert_id": "sa-1", "tenant_id": "t-1", "field_id": "f-1",
		"sensor_type": "SOIL_MOISTURE", "condition": "LT",
		"actual_value": 0.11, "threshold": 0.15, "severity": "WARNING",
	}))

	a := svc.only(t)
	if a.AlertType != models.AlertTypeWaterStress {
		t.Errorf("alert type %q, want WATER_STRESS", a.AlertType)
	}
	if a.Source != sourceSensor {
		t.Errorf("source %q", a.Source)
	}
	// The sensor service sends no message, so one has to be built or the
	// farmer sees a title and nothing else.
	if a.Message == "" {
		t.Fatal("no message was composed")
	}
	for _, want := range []string{"0.11", "0.15", "below"} {
		if !strings.Contains(a.Message, want) {
			t.Errorf("message %q does not mention %q", a.Message, want)
		}
	}
}

func TestSensorMessageSaysAboveWhenTheReadingIsHigh(t *testing.T) {
	c, svc := newConsumer()
	handle(t, c, event(sensorAlertTriggered, map[string]interface{}{
		"alert_id": "sa-2", "tenant_id": "t-1", "field_id": "f-1",
		"sensor_type": "TEMPERATURE", "condition": "GT",
		"actual_value": 41.0, "threshold": 38.0,
	}))
	if msg := svc.only(t).Message; !strings.Contains(msg, "above") {
		t.Errorf("message %q should say the reading is above the threshold", msg)
	}
}

// ── Pest ────────────────────────────────────────────────────────────────────

func TestLowRiskPredictionsDoNotBecomeAlerts(t *testing.T) {
	// Most predictions are low risk. Surfacing every one of them as something
	// needing attention is how an alert list gets ignored.
	c, svc := newConsumer()
	handle(t, c, event(pestPredicted, map[string]interface{}{
		"prediction_id": "p-1", "tenant_id": "t-1", "field_id": "f-1",
		"pest_name": "Fall Armyworm", "risk_score": 20,
	}))
	if n := svc.count(); n != 0 {
		t.Errorf("recorded %d alerts for a 20%% risk prediction, want 0", n)
	}
}

func TestHighRiskPredictionBecomesAnAlert(t *testing.T) {
	c, svc := newConsumer()
	handle(t, c, event(pestPredicted, map[string]interface{}{
		"prediction_id": "p-2", "tenant_id": "t-1", "field_id": "f-1",
		"pest_name": "Fall Armyworm", "risk_score": 90,
	}))

	a := svc.only(t)
	if a.AlertType != models.AlertTypePestOutbreak {
		t.Errorf("alert type %q", a.AlertType)
	}
	if a.Severity != models.AlertSeverityCritical {
		t.Errorf("severity %q, want CRITICAL at 90%% risk", a.Severity)
	}
	if !strings.Contains(a.Title, "Fall Armyworm") {
		t.Errorf("title %q does not name the pest", a.Title)
	}
	// The advice matters: an alert that says only "high risk" invites a spray
	// that scouting might have shown to be unnecessary.
	if !strings.Contains(a.Message, "Scout") {
		t.Errorf("message %q does not tell the farmer what to do first", a.Message)
	}
	if a.SourceAlertID != "p-2" {
		t.Errorf("source id %q; a re-scored prediction should replace, not duplicate", a.SourceAlertID)
	}
}

func TestPestSeverityBandsOnRisk(t *testing.T) {
	cases := []struct {
		risk float64
		want models.AlertSeverity
	}{
		{0.62, models.AlertSeverityInfo},
		{0.75, models.AlertSeverityWarning},
		{0.95, models.AlertSeverityCritical},
	}
	for _, tc := range cases {
		if got := pestSeverity(tc.risk); got != tc.want {
			t.Errorf("risk %.2f gave %q, want %q", tc.risk, got, tc.want)
		}
	}
}

func TestRiskScoreIsNormalisedFromTheDomainScale(t *testing.T) {
	// The pest service sends its 0-100 integer. Read as a fraction it would be
	// a risk of 9000%, which passes every threshold and would turn every
	// prediction into a critical alert.
	c, svc := newConsumer()
	handle(t, c, event(pestPredicted, map[string]interface{}{
		"prediction_id": "p-3", "tenant_id": "t-1", "field_id": "f-1",
		"pest_name": "Pink Bollworm", "risk_score": 65,
	}))
	a := svc.only(t)
	if a.MetricValue < 0.6 || a.MetricValue > 0.7 {
		t.Errorf("risk stored as %v, want about 0.65", a.MetricValue)
	}
	if !strings.Contains(a.Message, "65%") {
		t.Errorf("message %q does not state the risk as a percentage", a.Message)
	}
}

func TestAFractionalRiskScoreIsLeftAlone(t *testing.T) {
	// A producer that sends a fraction must not be read as 0.7% and dropped.
	c, svc := newConsumer()
	handle(t, c, event(pestPredicted, map[string]interface{}{
		"prediction_id": "p-4", "tenant_id": "t-1", "field_id": "f-1",
		"pest_name": "Brown Planthopper", "risk_score": 0.7,
	}))
	if svc.count() != 1 {
		t.Fatalf("a 0.7 risk produced %d alerts, want 1", svc.count())
	}
}

func TestAnUnnamedPestGetsAGenericTitle(t *testing.T) {
	// Never the crop type: "Cotton risk" would read as a pest and be wrong.
	c, svc := newConsumer()
	handle(t, c, event(pestPredicted, map[string]interface{}{
		"prediction_id": "p-5", "tenant_id": "t-1", "field_id": "f-1",
		"crop_type": "Cotton", "risk_score": 80,
	}))
	if title := svc.only(t).Title; strings.Contains(title, "Cotton") {
		t.Errorf("title %q used the crop as the pest name", title)
	}
}

// ── Robustness ──────────────────────────────────────────────────────────────

func TestEventWithoutATenantIsDroppedNotRetried(t *testing.T) {
	// There is nobody to show it to, and guessing a tenant would put one
	// tenant's alert in another's list. Returning an error would retry a
	// message that can never succeed and block the partition behind it.
	c, svc := newConsumer()
	if err := c.HandleEvent(context.Background(), event(weatherAlertTriggered, map[string]interface{}{
		"alert_id": "wa-3", "field_id": "f-1", "alert_type": "FROST_RISK",
	})); err != nil {
		t.Fatalf("HandleEvent returned %v; a tenant-less event must not be retried forever", err)
	}
	if n := svc.count(); n != 0 {
		t.Errorf("recorded %d alerts without a tenant", n)
	}
}

func TestEventWithoutAFieldIsDropped(t *testing.T) {
	c, svc := newConsumer()
	if err := c.HandleEvent(context.Background(), event(weatherAlertTriggered, map[string]interface{}{
		"alert_id": "wa-4", "tenant_id": "t-1", "alert_type": "FROST_RISK",
	})); err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}
	if n := svc.count(); n != 0 {
		t.Errorf("recorded %d alerts without a field", n)
	}
}

func TestStorageFailureIsRetried(t *testing.T) {
	// The opposite case: a database that is briefly unavailable should not
	// lose the alert, so this one does come back as an error.
	c, svc := newConsumer()
	svc.err = errors.New("connection refused")

	err := c.HandleEvent(context.Background(), event(weatherAlertTriggered, map[string]interface{}{
		"alert_id": "wa-5", "tenant_id": "t-1", "field_id": "f-1", "alert_type": "FROST_RISK",
	}))
	if err == nil {
		t.Error("a storage failure was swallowed; the alert would be lost")
	}
}

func TestUnrelatedEventsAreIgnored(t *testing.T) {
	// These topics carry every event the services publish, not only alerts.
	c, svc := newConsumer()
	for _, typ := range []string{
		"agriculture.weather.observation.recorded",
		"agriculture.sensor.reading.recorded",
		"agriculture.pest-prediction.observation.reported",
	} {
		handle(t, c, event(typ, map[string]interface{}{"tenant_id": "t-1", "field_id": "f-1"}))
	}
	if n := svc.count(); n != 0 {
		t.Errorf("recorded %d alerts from non-alert events", n)
	}
}

func TestWronglyTypedFieldsDoNotPanic(t *testing.T) {
	// Every field here is JSON from another service. A type assertion that
	// panics takes the consumer down and stops the partition, which is far
	// worse than one badly-formed alert.
	c, _ := newConsumer()
	handle(t, c, event(weatherAlertTriggered, map[string]interface{}{
		"alert_id": 12345, "tenant_id": "t-1", "field_id": "f-1",
		"alert_type": []string{"FROST_RISK"}, "severity": 3,
		"value": "not a number", "valid_to": 99,
	}))
}

func TestNilEventIsAnError(t *testing.T) {
	c, _ := newConsumer()
	if err := c.HandleEvent(context.Background(), nil); err == nil {
		t.Error("a nil event should be reported, not silently accepted")
	}
}

func TestTopicsCoverEveryAlertSource(t *testing.T) {
	c, _ := newConsumer()
	got := map[string]bool{}
	for _, topic := range c.Topics() {
		got[topic] = true
	}
	for _, want := range []string{WeatherEventTopic, SensorEventTopic, PestEventTopic} {
		if !got[want] {
			t.Errorf("not subscribed to %s; those alerts would never arrive", want)
		}
	}
}
