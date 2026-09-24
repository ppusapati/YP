package application

import (
	"context"
	"encoding/json"
	"fmt"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.uber.org/zap"

	eventsdomain "p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9log"

	"p9e.in/samavaya/agriculture/irrigation-service/internal/domain"
	"p9e.in/samavaya/agriculture/irrigation-service/internal/ports/outbound"
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

// ---------------------------------------------------------------------------
// An actuator with fake hardware behind it.
//
// TriggerIrrigation now refuses when nothing can reach a valve, so a test that
// wants a run has to supply something that can. These fakes are the smallest
// thing that answers: a zone that passes every interlock, a controller that
// accepts, and a recorder that remembers.

type fakeZones struct {
	state      domain.ZoneState
	controller *domain.WaterController
}

func (f *fakeZones) ZoneState(context.Context, string, string) (domain.ZoneState, error) {
	return f.state, nil
}

func (f *fakeZones) ControllerForZone(context.Context, string, string) (*domain.WaterController, error) {
	return f.controller, nil
}

type fakeCommands struct {
	recorded []*domain.IrrigationCommand
	outcomes []string
}

func (f *fakeCommands) RecordCommand(_ context.Context, cmd *domain.IrrigationCommand) error {
	f.recorded = append(f.recorded, cmd)
	return nil
}

func (f *fakeCommands) RecordOutcome(_ context.Context, id string, accepted bool, detail string) error {
	f.outcomes = append(f.outcomes, fmt.Sprintf("%s accepted=%v %s", id, accepted, detail))
	return nil
}

type fakeController struct {
	ack  *outbound.ControllerAck
	err  error
	sent []*domain.IrrigationCommand
}

func (f *fakeController) Send(_ context.Context, _ *domain.WaterController, cmd *domain.IrrigationCommand) (*outbound.ControllerAck, error) {
	f.sent = append(f.sent, cmd)
	if f.err != nil {
		return nil, f.err
	}
	if f.ack != nil {
		return f.ack, nil
	}
	return &outbound.ControllerAck{Accepted: true}, nil
}

func (f *fakeController) Status(context.Context, *domain.WaterController) (*outbound.ControllerStatus, error) {
	return &outbound.ControllerStatus{Online: true}, nil
}

// readyZone is a zone that passes every interlock: online controller, nothing
// running, no recent run, no minutes used.
func readyZone() *fakeZones {
	ctrl := &domain.WaterController{TenantID: "tenant-1", Status: domain.ControllerStatusOnline}
	ctrl.ID = "ctrl-001"
	return &fakeZones{
		state: domain.ZoneState{
			ZoneID:           "zone-001",
			Limits:           domain.ZoneLimits{MaxRunMinutes: 240, MinRestMinutes: 90, MaxDailyMinutes: 480, Automatic: true},
			ControllerOnline: true,
		},
		controller: ctrl,
	}
}

// actuated wires a service to an actuator whose hardware accepts everything.
func actuated() (*mockIrrigationRepo, *mockEventPublisher, *irrigationService, *fakeController) {
	repo, pub, svc := newService()
	hw := &fakeController{}
	svc.WithActuator(NewActuator(readyZone(), hw, &fakeCommands{}, pub, p9log.NewLogger(zap.NewNop())))
	return repo, pub, svc, hw
}

// publishedPayload finds the event of a given type and decodes its data.
//
// By type rather than by position, because a run now publishes twice: the
// actuator emits agriculture.irrigation.command.sent when a controller takes
// the command, and the service emits agriculture.irrigation.triggered when the
// run is recorded. Indexing into the slice would pin the order of two
// independent things.
func publishedPayload(t *testing.T, pub *mockEventPublisher, want eventsdomain.EventType) map[string]interface{} {
	t.Helper()

	var seen []string
	for _, ev := range pub.published {
		var envelope struct {
			Type string                 `json:"type"`
			Data map[string]interface{} `json:"data"`
		}
		if err := json.Unmarshal(ev.payload, &envelope); err != nil {
			continue
		}
		seen = append(seen, envelope.Type)
		if envelope.Type == string(want) {
			return envelope.Data
		}
	}
	t.Fatalf("no %s event was published; got %v", want, seen)
	return nil
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
	repo, pub, svc, _ := actuated()
	scheduledRun(repo, "")

	_, err := svc.TriggerIrrigation(testContext("tenant-1", "user-1"), "sched-001")
	require.NoError(t, err)

	data := publishedPayload(t, pub, eventsdomain.EventTypeIrrigationTriggered)

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
	repo, pub, svc, _ := actuated()
	scheduledRun(repo, "field-override")

	_, err := svc.TriggerIrrigation(testContext("tenant-1", "user-1"), "sched-001")
	require.NoError(t, err)

	data := publishedPayload(t, pub, eventsdomain.EventTypeIrrigationTriggered)
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
	repo, pub, svc, _ := actuated()
	scheduledRun(repo, "")

	_, err := svc.TriggerIrrigation(testContext("tenant-1", "user-1"), "sched-001")
	require.NoError(t, err)

	data := publishedPayload(t, pub, eventsdomain.EventTypeIrrigationTriggered)
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
	repo, pub, svc, _ := actuated()
	scheduledRun(repo, "")

	_, err := svc.TriggerIrrigation(testContext("tenant-1", "user-1"), "sched-001")
	require.NoError(t, err)

	data := publishedPayload(t, pub, eventsdomain.EventTypeIrrigationTriggered)
	assert.IsType(t, float64(0), data["planned_water_liters"])
	assert.IsType(t, float64(0), data["planned_duration_minutes"])
}

// An unresolvable zone does not suppress the event.
//
// The run has started and the row is written; refusing to publish would lose
// the record of something that happened. It goes out without a field, which
// the consumer declines to record and says so.
func TestAnUnresolvableZoneStillPublishesTheRun(t *testing.T) {
	repo, pub, svc, _ := actuated()
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

	data := publishedPayload(t, pub, eventsdomain.EventTypeIrrigationTriggered)
	assert.Equal(t, "", data["field_id"])
	assert.Equal(t, "event-uuid-001", data["event_id"])
}
