package application

import (
	"encoding/json"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	eventsdomain "p9e.in/samavaya/packages/events/domain"

	"p9e.in/samavaya/agriculture/irrigation-service/internal/domain"
)

// These cover the payload rather than the return value, because the payload is
// what was wrong and nothing else was looking at it.
//
// The triggered event used to carry `{event_id, schedule_id, tenant_id}`.
// traceability-service's handler keys the batch off `field_id`, so every
// irrigation on every field hit its "missing tenant or field" branch, logged
// that it was not recording it, and returned nil — while that handler's own
// test passed, because the test hand-built a payload with a `field_id` in it
// that no producer ever sent.
//
// So these assert on the literal keys the consumer reads. A test that builds
// its own payload proves only that the consumer can parse itself.

// publishedPayload decodes the one event the service published.
func publishedPayload(t *testing.T, pub *mockEventPublisher) (eventType string, data map[string]interface{}) {
	t.Helper()
	require.Len(t, pub.published, 1, "expected exactly one published event")

	var envelope struct {
		Type string                 `json:"type"`
		Data map[string]interface{} `json:"data"`
	}
	require.NoError(t, json.Unmarshal(pub.published[0].payload, &envelope))
	return envelope.Type, envelope.Data
}

// scheduledRun registers a zone and a schedule that will fire on it.
func scheduledRun(repo *mockIrrigationRepo, scheduleFieldID string) {
	zone := &domain.IrrigationZone{
		TenantID: "tenant-1",
		FieldID:  "field-001",
		FarmID:   "farm-001",
		Name:     "North block",
	}
	zone.ID = "zone-001"
	repo.zones["zone-001"] = zone

	sched := &domain.IrrigationSchedule{
		TenantID:            "tenant-1",
		FieldID:             scheduleFieldID,
		ZoneID:              "zone-001",
		DurationMinutes:     30,
		WaterQuantityLiters: 12000,
		Status:              domain.IrrigationStatusScheduled,
	}
	sched.ID = "sched-001"
	repo.schedules["sched-001"] = sched
}

// ---------------------------------------------------------------------------

// The run names the field it ran on. Without this the compliance record for
// water application is never written, and the only trace is a warning log.
func TestATriggeredRunNamesItsField(t *testing.T) {
	repo, pub, svc := newService()
	scheduledRun(repo, "")

	_, err := svc.TriggerIrrigation(testContext("tenant-1", "user-1"), "sched-001")
	require.NoError(t, err)

	eventType, data := publishedPayload(t, pub)
	assert.Equal(t, string(eventsdomain.EventTypeIrrigationTriggered), eventType)

	// Exactly the keys traceability-service reads.
	assert.Equal(t, "tenant-1", data["tenant_id"], "the consumer scopes every query by this")
	assert.Equal(t, "field-001", data["field_id"], "the consumer finds the open batch by this")
	assert.Equal(t, "event-uuid-001", data["event_id"], "the consumer names the run by this")
	assert.NotEmpty(t, data["started_at"], "the consumer dates the supply chain event by this")

	assert.Equal(t, "farm-001", data["farm_id"])
	assert.Equal(t, "zone-001", data["zone_id"])
	assert.Equal(t, "sched-001", data["schedule_id"])
}

// A schedule may carry its own field; CreateSchedule does not require one, so
// the zone is the reliable source and the schedule is the override.
func TestTheScheduleOverridesTheZonesField(t *testing.T) {
	repo, pub, svc := newService()
	scheduledRun(repo, "field-override")

	_, err := svc.TriggerIrrigation(testContext("tenant-1", "user-1"), "sched-001")
	require.NoError(t, err)

	_, data := publishedPayload(t, pub)
	assert.Equal(t, "field-override", data["field_id"])
	// The farm still comes from the zone: only the field was overridden.
	assert.Equal(t, "farm-001", data["farm_id"])
}

// The water figure says it is a plan, because that is all it is.
//
// TriggerIrrigation writes the schedule's quantity into the event's
// ActualWaterLiters at start time — before water could have flowed — and
// UpdateEvent, the only thing that could revise it, has no caller. Publishing
// it as `water_amount_liters` would put that plan into an audit record as a
// measurement.
func TestThePlannedQuantityIsNotPublishedAsAMeasurement(t *testing.T) {
	repo, pub, svc := newService()
	scheduledRun(repo, "")

	_, err := svc.TriggerIrrigation(testContext("tenant-1", "user-1"), "sched-001")
	require.NoError(t, err)

	_, data := publishedPayload(t, pub)
	assert.Equal(t, 12000.0, data["planned_water_liters"])
	assert.Equal(t, 30.0, data["planned_duration_minutes"])

	for _, key := range []string{"water_amount_liters", "actual_water_liters", "actual_duration_minutes"} {
		_, present := data[key]
		assert.Falsef(t, present, "%s asserts a measurement nothing in this service takes", key)
	}
}

// A quantity is a number. Sent as a quoted string it reads as absent to any
// consumer that parses it as one, which is how a hand-written test payload
// diverges from a real one without anybody noticing.
func TestQuantitiesArePublishedAsNumbers(t *testing.T) {
	repo, pub, svc := newService()
	scheduledRun(repo, "")

	_, err := svc.TriggerIrrigation(testContext("tenant-1", "user-1"), "sched-001")
	require.NoError(t, err)

	_, data := publishedPayload(t, pub)
	assert.IsType(t, float64(0), data["planned_water_liters"])
	assert.IsType(t, float64(0), data["planned_duration_minutes"])
}

// An unresolvable zone does not suppress the event.
//
// The run has started and the row is written; refusing to publish would lose
// the record of something that happened. It goes out without a field, which
// the consumer declines to record and says so.
func TestAnUnresolvableZoneStillPublishesTheRun(t *testing.T) {
	repo, pub, svc := newService()
	sched := &domain.IrrigationSchedule{
		TenantID:            "tenant-1",
		ZoneID:              "zone-missing",
		DurationMinutes:     30,
		WaterQuantityLiters: 500,
		Status:              domain.IrrigationStatusScheduled,
	}
	sched.ID = "sched-001"
	repo.schedules["sched-001"] = sched

	_, err := svc.TriggerIrrigation(testContext("tenant-1", "user-1"), "sched-001")
	require.NoError(t, err)

	_, data := publishedPayload(t, pub)
	assert.Equal(t, "", data["field_id"])
	assert.Equal(t, "event-uuid-001", data["event_id"])
}
