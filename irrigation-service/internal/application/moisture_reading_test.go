package application

import (
	"context"
	"errors"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.uber.org/zap"

	"p9e.in/samavaya/packages/p9log"

	"p9e.in/samavaya/agriculture/irrigation-service/internal/domain"
	"p9e.in/samavaya/agriculture/irrigation-service/internal/ports/outbound"
)

// The sensor leg end to end: a measurement arrives and a valve does or does
// not open. Most of these assert that it does not.

func reading(pct float64) domain.MoistureReading {
	return domain.MoistureReading{
		SensorID:   "sen-1",
		TenantID:   "tenant-1",
		FieldID:    "field-001",
		Percent:    pct,
		Unit:       "%",
		Quality:    domain.GoodReadingQuality,
		SensorType: domain.SoilMoistureSensorType,
		RecordedAt: time.Now().Add(-5 * time.Minute),
	}
}

// sensorFarm registers a zone on field-001 with an adaptive schedule that
// waters below 25% for 30 minutes.
func sensorFarm(repo *mockIrrigationRepo) {
	zone := &domain.IrrigationZone{TenantID: "tenant-1", FieldID: "field-001", FarmID: "farm-001"}
	zone.ID = "zone-001"
	repo.zones["zone-001"] = zone

	sched := &domain.IrrigationSchedule{
		TenantID:                 "tenant-1",
		ZoneID:                   "zone-001",
		ScheduleType:             domain.ScheduleTypeAdaptive,
		SoilMoistureThresholdPct: 25,
		DurationMinutes:          30,
		Status:                   domain.IrrigationStatusScheduled,
	}
	sched.ID = "sched-001"
	repo.schedules["sched-001"] = sched
}

// ---------------------------------------------------------------------------

// Dry soil on an opted-in zone opens a valve.
func TestDrySoilStartsIrrigation(t *testing.T) {
	repo, _, svc, hw := actuated()
	sensorFarm(repo)

	require.NoError(t, svc.ApplyMoistureReading(testContext("", ""), reading(18)))

	require.Len(t, hw.sent, 1, "no command reached a controller")
	assert.Equal(t, domain.CommandStart, hw.sent[0].Kind)
	assert.Equal(t, "zone-001", hw.sent[0].ZoneID)
	assert.Equal(t, int32(30), hw.sent[0].DurationMinutes)
	// "system", so the automation interlock applies to it — an automatic
	// command must be refused on a zone nobody opted in.
	assert.Equal(t, "system", hw.sent[0].IssuedBy)
	// The reading is in the reason, because an automatic command nobody can
	// explain afterwards is indistinguishable from a malfunction.
	assert.Contains(t, hw.sent[0].Reason, "18")
}

// Wet enough is the common case and is not an error.
func TestWetSoilDoesNothing(t *testing.T) {
	repo, _, svc, hw := actuated()
	sensorFarm(repo)

	require.NoError(t, svc.ApplyMoistureReading(testContext("", ""), reading(40)))
	assert.Empty(t, hw.sent, "a valve was opened on soil above the threshold")
	assert.Empty(t, repo.events, "a run was recorded for soil that needed none")
}

// The run is written, and that is what keeps the interlocks honest.
//
// ZoneState derives the rest interval and the daily cap from irrigation_events.
// An automatic run that actuated without recording one would be invisible to
// the limits meant to bound it: a flapping sensor could water a field all day
// inside a cap that was counting nothing.
func TestAnAutomaticRunIsRecorded(t *testing.T) {
	repo, pub, svc, _ := actuated()
	sensorFarm(repo)

	require.NoError(t, svc.ApplyMoistureReading(testContext("", ""), reading(18)))

	require.Len(t, repo.events, 1, "the run was not recorded; the daily cap would never see it")
	for _, evt := range repo.events {
		assert.Equal(t, "zone-001", evt.ZoneID)
		assert.Equal(t, "sched-001", evt.ScheduleID)
		assert.Equal(t, domain.IrrigationStatusActive, evt.Status)
		assert.NotNil(t, evt.StartedAt)
	}

	// And traceability hears about it, so water applied without anybody
	// present still reaches the compliance record.
	data := publishedPayload(t, pub, "agriculture.irrigation.triggered")
	assert.Equal(t, "field-001", data["field_id"])
	assert.Equal(t, "system", data["issued_by"])
}

// An adaptive schedule is a standing rule. Flipping it to ACTIVE the way
// TriggerIrrigation does would take the rule out of service after one firing.
func TestAnAutomaticRunLeavesTheStandingRuleInPlace(t *testing.T) {
	repo, _, svc, _ := actuated()
	sensorFarm(repo)

	require.NoError(t, svc.ApplyMoistureReading(testContext("", ""), reading(18)))
	assert.Equal(t, domain.IrrigationStatusScheduled, repo.schedules["sched-001"].Status,
		"the standing rule was consumed by its own first firing")
}

// A zone that has not opted in is not watered, however dry it reads.
func TestAZoneWithoutAnAdaptiveScheduleIsNotWatered(t *testing.T) {
	repo, _, svc, hw := actuated()
	sensorFarm(repo)
	repo.schedules["sched-001"].ScheduleType = domain.ScheduleTypeFixed

	require.NoError(t, svc.ApplyMoistureReading(testContext("", ""), reading(5)))
	assert.Empty(t, hw.sent, "a zone that never opted in was irrigated")
}

// The automation interlock is the per-zone kill switch, and it is off by
// default. A farmer opts in for a zone they have watched behave.
func TestAutomationOffMeansNoUnattendedIrrigation(t *testing.T) {
	repo, pub, svc := newService()
	sensorFarm(repo)

	zones := readyZone()
	zones.state.Limits.Automatic = false
	hw := &fakeController{}
	svc.WithActuator(NewActuator(zones, hw, &fakeCommands{}, pub, p9log.NewLogger(zap.NewNop())))

	require.NoError(t, svc.ApplyMoistureReading(testContext("", ""), reading(5)))
	assert.Empty(t, hw.sent, "an automatic command reached a zone with automation disabled")
	assert.Empty(t, repo.events)
}

// A reading too old to act on waters nothing.
//
// The failure this guards against is a sensor that has stopped reporting while
// reading dry: without it, its last value justifies irrigation for ever and
// the field is watered on a measurement from last week.
func TestAStaleReadingWatersNothing(t *testing.T) {
	repo, _, svc, hw := actuated()
	sensorFarm(repo)

	old := reading(5)
	old.RecordedAt = time.Now().Add(-domain.MaxReadingAge - time.Minute)

	require.NoError(t, svc.ApplyMoistureReading(testContext("", ""), old))
	assert.Empty(t, hw.sent, "a field was watered on a stale measurement")
}

// A reading that cannot be acted on is dropped, not retried. Kafka would
// redeliver it for ever and no amount of retrying makes a missing tenant
// appear — while a blocked partition stops every other reading on the farm.
func TestAnUnusableReadingIsDroppedRatherThanRetried(t *testing.T) {
	repo, _, svc, hw := actuated()
	sensorFarm(repo)

	for _, bad := range []domain.MoistureReading{
		func() domain.MoistureReading { r := reading(5); r.TenantID = ""; return r }(),
		func() domain.MoistureReading { r := reading(5); r.Quality = "BAD"; return r }(),
		func() domain.MoistureReading { r := reading(5); r.SensorType = "TEMPERATURE"; return r }(),
		func() domain.MoistureReading { r := reading(5); r.RecordedAt = time.Time{}; return r }(),
	} {
		assert.NoError(t, svc.ApplyMoistureReading(testContext("", ""), bad),
			"an unusable reading was returned as an error and would block the partition")
	}
	assert.Empty(t, hw.sent)
}

// Redelivery is safe. Kafka is at-least-once, and the rest interlock is what
// stops the second copy of a reading starting a second run.
func TestARedeliveredReadingDoesNotWaterTwice(t *testing.T) {
	repo, pub, svc := newService()
	sensorFarm(repo)

	zones := readyZone()
	hw := &fakeController{}
	svc.WithActuator(NewActuator(zones, hw, &fakeCommands{}, pub, p9log.NewLogger(zap.NewNop())))

	ctx := testContext("", "")
	require.NoError(t, svc.ApplyMoistureReading(ctx, reading(18)))
	require.Len(t, hw.sent, 1)

	// The zone is now running and irrigated a moment ago, which is what the
	// real ZoneState would report on the redelivery.
	zones.state.Running = true
	zones.state.LastRunEndedAt = time.Now()

	require.NoError(t, svc.ApplyMoistureReading(ctx, reading(18)))
	assert.Len(t, hw.sent, 1, "a redelivered reading opened the valve a second time")
}

// With no controller client the reading is noted and dropped, not returned as
// an error: blocking the partition over a deployment with no hardware would
// stop every other consumer on the topic too.
func TestNoHardwareDoesNotBlockThePartition(t *testing.T) {
	repo, _, svc := newService()
	sensorFarm(repo)

	assert.NoError(t, svc.ApplyMoistureReading(testContext("", ""), reading(5)))
	assert.Empty(t, repo.events)
}

// A field with several zones waters each on its own rule, and one zone's
// controller being unreachable does not strand the others.
func TestOneFailingZoneDoesNotStrandTheRest(t *testing.T) {
	repo, pub, svc := newService()
	sensorFarm(repo)

	second := &domain.IrrigationZone{TenantID: "tenant-1", FieldID: "field-001", FarmID: "farm-001"}
	second.ID = "zone-002"
	repo.zones["zone-002"] = second
	sched2 := &domain.IrrigationSchedule{
		TenantID: "tenant-1", ZoneID: "zone-002",
		ScheduleType: domain.ScheduleTypeAdaptive, SoilMoistureThresholdPct: 25,
		DurationMinutes: 30, Status: domain.IrrigationStatusScheduled,
	}
	sched2.ID = "sched-002"
	repo.schedules["sched-002"] = sched2

	// A controller that fails only for the first zone it is asked about.
	hw := &failFirstController{}
	svc.WithActuator(NewActuator(readyZone(), hw, &fakeCommands{}, pub, p9log.NewLogger(zap.NewNop())))

	require.NoError(t, svc.ApplyMoistureReading(testContext("", ""), reading(18)))
	assert.Len(t, hw.sent, 2, "the second zone was skipped after the first failed")
}

// Every zone failing is a fault on this side, not a run of coincidences.
// Reporting success would have Kafka commit the offset over a reading that
// watered nothing.
func TestEveryZoneFailingIsReportedUpward(t *testing.T) {
	repo, pub, svc := newService()
	sensorFarm(repo)

	hw := &fakeController{err: errors.New("panel unreachable")}
	svc.WithActuator(NewActuator(readyZone(), hw, &fakeCommands{}, pub, p9log.NewLogger(zap.NewNop())))

	err := svc.ApplyMoistureReading(testContext("", ""), reading(18))
	assert.Error(t, err, "a reading that watered nothing was reported as handled")
}

// A zone with two adaptive schedules is skipped, not resolved arbitrarily —
// and skipped without an error, because a retry produces the same ambiguity
// for ever and the fix is a farmer editing a schedule.
func TestAmbiguousSchedulesSkipTheZoneWithoutBlocking(t *testing.T) {
	repo, _, svc, hw := actuated()
	sensorFarm(repo)

	other := &domain.IrrigationSchedule{
		TenantID: "tenant-1", ZoneID: "zone-001",
		ScheduleType: domain.ScheduleTypeAdaptive, SoilMoistureThresholdPct: 40,
		DurationMinutes: 60, Status: domain.IrrigationStatusScheduled,
	}
	other.ID = "sched-002"
	repo.schedules["sched-002"] = other

	assert.NoError(t, svc.ApplyMoistureReading(testContext("", ""), reading(18)))
	assert.Empty(t, hw.sent, "an ambiguous configuration was resolved by picking one")
}

// failFirstController refuses the first command and accepts the rest.
type failFirstController struct {
	sent []*domain.IrrigationCommand
}

func (f *failFirstController) Send(_ context.Context, _ *domain.WaterController, cmd *domain.IrrigationCommand) (*outbound.ControllerAck, error) {
	f.sent = append(f.sent, cmd)
	if len(f.sent) == 1 {
		return nil, errors.New("panel unreachable")
	}
	return &outbound.ControllerAck{Accepted: true}, nil
}

func (f *failFirstController) Status(context.Context, *domain.WaterController) (*outbound.ControllerStatus, error) {
	return &outbound.ControllerStatus{Online: true}, nil
}
