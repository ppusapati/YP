package application

import (
	"context"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.uber.org/zap"

	"p9e.in/samavaya/packages/p9log"

	"p9e.in/samavaya/agriculture/irrigation-service/internal/domain"
	"p9e.in/samavaya/agriculture/irrigation-service/internal/ports/outbound"
)

// What a run says it used, and whether anybody measured it.
//
// actual_water_liters used to hold the schedule's planned quantity, copied in
// at start time before water could have flowed, and nothing ever revised it —
// so a column called "actual" held a forecast and a season's water usage was a
// sum of intentions. water_usage_logs had no writer at all, so GetWaterUsage
// returned an empty list for every zone on every farm.

// meteringController reports a meter that advances between readings.
type meteringController struct {
	readings []outbound.ControllerStatus
	calls    int
	sent     []*domain.IrrigationCommand
}

func (m *meteringController) Send(_ context.Context, _ *domain.WaterController, cmd *domain.IrrigationCommand) (*outbound.ControllerAck, error) {
	m.sent = append(m.sent, cmd)
	return &outbound.ControllerAck{Accepted: true}, nil
}

func (m *meteringController) Status(context.Context, *domain.WaterController) (*outbound.ControllerStatus, error) {
	if m.calls >= len(m.readings) {
		return &outbound.ControllerStatus{Online: true}, nil
	}
	s := m.readings[m.calls]
	m.calls++
	return &s, nil
}

// meteredService wires a service whose panel answers with the given readings,
// in order: the first is taken when the valve opens, the second when it closes.
func meteredService(readings ...outbound.ControllerStatus) (*mockIrrigationRepo, *irrigationService, *meteringController) {
	repo, pub, svc := newService()
	hw := &meteringController{readings: readings}
	svc.WithActuator(NewActuator(readyZone(), hw, &fakeCommands{}, pub, p9log.NewLogger(zap.NewNop())))

	sched := &domain.IrrigationSchedule{
		TenantID: "tenant-1", ZoneID: "zone-001",
		DurationMinutes: 30, WaterQuantityLiters: 12000,
		Status: domain.IrrigationStatusScheduled,
	}
	sched.ID = "sched-001"
	repo.schedules["sched-001"] = sched
	return repo, svc, hw
}

func meter(liters float64) outbound.ControllerStatus {
	return outbound.ControllerStatus{Online: true, VolumeTotalLiters: liters, HasVolumeTotal: true}
}

// ---------------------------------------------------------------------------

// The volume is the difference between two meter readings. A measurement.
func TestAMeteredRunRecordsWhatTheMeterSaid(t *testing.T) {
	_, svc, _ := meteredService(meter(1_000_000), meter(1_008_400))
	ctx := testContext("tenant-1", "user-1")

	evt, err := svc.TriggerIrrigation(ctx, "sched-001")
	require.NoError(t, err)

	// The opening reading is on the run, so the figure can be checked later.
	require.NotNil(t, evt.MeterStartLiters)
	assert.Equal(t, 1_000_000.0, *evt.MeterStartLiters)
	// Nothing is claimed while the run is in progress.
	assert.Zero(t, evt.ActualWaterLiters)
	assert.Equal(t, domain.WaterSourceUnmetered, evt.WaterSource)

	stopped, err := svc.StopIrrigation(ctx, evt.ID, "done")
	require.NoError(t, err)

	assert.Equal(t, 8400.0, stopped.ActualWaterLiters)
	assert.Equal(t, domain.WaterSourceMeter, stopped.WaterSource)
	require.NotNil(t, stopped.MeterEndLiters)
	assert.Equal(t, 1_008_400.0, *stopped.MeterEndLiters)

	// And the schedule's 12,000 L plan is nowhere in it.
	assert.NotEqual(t, 12000.0, stopped.ActualWaterLiters,
		"the schedule's planned quantity was recorded as the actual")
}

// GetWaterUsage returns the run. This is the first writer CreateWaterUsageLog
// has ever had: the query returned an empty list for every zone on every farm,
// which reads as a farm that has never used water.
func TestAMeteredRunReachesWaterUsage(t *testing.T) {
	_, svc, _ := meteredService(meter(1_000_000), meter(1_008_400))
	ctx := testContext("tenant-1", "user-1")

	evt, err := svc.TriggerIrrigation(ctx, "sched-001")
	require.NoError(t, err)
	_, err = svc.StopIrrigation(ctx, evt.ID, "done")
	require.NoError(t, err)

	logs, err := svc.GetWaterUsage(ctx, "zone-001", time.Time{}, time.Now().Add(time.Hour))
	require.NoError(t, err)
	require.Len(t, logs, 1, "a completed run produced no water usage row")

	assert.Equal(t, 8400.0, logs[0].WaterLiters)
	assert.Equal(t, domain.WaterSourceMeter, logs[0].Source)
	assert.Equal(t, evt.ID, logs[0].EventID, "the usage row cannot be traced back to its run")
}

// A panel with no totaliser but a flow sensor gets an estimate, labelled as
// one. Honest arithmetic on two measurements, and still not a meter reading.
func TestAFlowRateGivesAnEstimateThatSaysSo(t *testing.T) {
	rate := outbound.ControllerStatus{Online: true, FlowRateLitersPerHour: 1200, HasFlowRate: true}
	repo, svc, _ := meteredService(rate, rate)
	ctx := testContext("tenant-1", "user-1")

	evt, err := svc.TriggerIrrigation(ctx, "sched-001")
	require.NoError(t, err)
	require.Nil(t, evt.MeterStartLiters, "a panel with no totaliser reported one")

	// Backdate the start so the run has a measured duration to estimate over.
	started := time.Now().Add(-time.Hour)
	repo.events[evt.ID].StartedAt = &started

	stopped, err := svc.StopIrrigation(ctx, evt.ID, "done")
	require.NoError(t, err)

	assert.Equal(t, domain.WaterSourceEstimated, stopped.WaterSource)
	assert.InDelta(t, 1200.0, stopped.ActualWaterLiters, 25,
		"an hour at 1200 L/h should estimate about 1200 L")
}

// A panel with neither is unmetered, and the row says so rather than carrying
// a plausible number. The nameplate flow rate is deliberately never used: a
// blocked line delivers nothing at exactly that rate.
func TestAPanelWithNoInstrumentsIsRecordedAsUnmetered(t *testing.T) {
	bare := outbound.ControllerStatus{Online: true}
	_, svc, _ := meteredService(bare, bare)
	ctx := testContext("tenant-1", "user-1")

	evt, err := svc.TriggerIrrigation(ctx, "sched-001")
	require.NoError(t, err)
	stopped, err := svc.StopIrrigation(ctx, evt.ID, "done")
	require.NoError(t, err)

	assert.Equal(t, domain.WaterSourceUnmetered, stopped.WaterSource)
	assert.Zero(t, stopped.ActualWaterLiters)

	// The row is still written. A zone's usage has to distinguish "no water
	// was applied" from "water was applied and nobody measured it"; omitting
	// it makes an unmetered farm look like an idle one.
	logs, err := svc.GetWaterUsage(ctx, "zone-001", time.Time{}, time.Now().Add(time.Hour))
	require.NoError(t, err)
	require.Len(t, logs, 1, "an unmetered run left no trace in water usage")
	assert.Equal(t, domain.WaterSourceUnmetered, logs[0].Source)
	assert.Zero(t, logs[0].WaterLiters)
}

// A meter that did not move is a measured zero — the signature of a blocked
// line — and is recorded as METER, not as unmetered.
func TestABlockedLineIsAMeasuredZero(t *testing.T) {
	_, svc, _ := meteredService(meter(1_000_000), meter(1_000_000))
	ctx := testContext("tenant-1", "user-1")

	evt, err := svc.TriggerIrrigation(ctx, "sched-001")
	require.NoError(t, err)
	stopped, err := svc.StopIrrigation(ctx, evt.ID, "done")
	require.NoError(t, err)

	assert.Zero(t, stopped.ActualWaterLiters)
	assert.Equal(t, domain.WaterSourceMeter, stopped.WaterSource,
		"a measured zero was recorded as if nobody had measured it")
}

// Readings that cannot describe a run — a meter reset or replaced mid-season —
// leave the volume unclaimed, and both readings on the row for somebody to
// work out what happened.
func TestAResetMeterLeavesTheVolumeUnclaimed(t *testing.T) {
	_, svc, _ := meteredService(meter(3_500_000_000), meter(12))
	ctx := testContext("tenant-1", "user-1")

	evt, err := svc.TriggerIrrigation(ctx, "sched-001")
	require.NoError(t, err)
	stopped, err := svc.StopIrrigation(ctx, evt.ID, "done")
	require.NoError(t, err)

	assert.Equal(t, domain.WaterSourceUnmetered, stopped.WaterSource)
	assert.Zero(t, stopped.ActualWaterLiters)
	require.NotNil(t, stopped.MeterEndLiters, "the closing reading was discarded")
	assert.Equal(t, 12.0, *stopped.MeterEndLiters)
}

// A meter that fails to answer at the end does not fail the stop. The water is
// off, which is what the caller asked for.
func TestAMeterThatCannotBeReadDoesNotFailTheStop(t *testing.T) {
	_, svc, _ := meteredService(meter(1_000_000)) // no second reading
	ctx := testContext("tenant-1", "user-1")

	evt, err := svc.TriggerIrrigation(ctx, "sched-001")
	require.NoError(t, err)

	stopped, err := svc.StopIrrigation(ctx, evt.ID, "done")
	require.NoError(t, err, "a silent meter took the stop down with it")
	assert.Equal(t, domain.IrrigationStatusCompleted, stopped.Status)
	assert.Equal(t, domain.WaterSourceUnmetered, stopped.WaterSource)
}

// ---------------------------------------------------------------------------
// Closing runs nobody stops

// Every run an operator does not stop by hand ends when its duration elapses,
// and nothing tells this service. Without the sweep those runs stay ACTIVE for
// ever and are never metered — and every sensor-driven run ends that way,
// because nobody is present to stop one.
func TestAFinishedRunIsClosedAndMetered(t *testing.T) {
	repo, svc, _ := meteredService(meter(1_000_000), meter(1_008_400))
	ctx := testContext("tenant-1", "user-1")

	evt, err := svc.TriggerIrrigation(ctx, "sched-001")
	require.NoError(t, err)

	// The 30-minute run began 45 minutes ago, so the valve has shut.
	started := time.Now().Add(-45 * time.Minute)
	repo.events[evt.ID].StartedAt = &started

	closed, err := svc.CloseFinishedRuns(context.Background(), 10)
	require.NoError(t, err)
	assert.Equal(t, 1, closed)

	got := repo.events[evt.ID]
	assert.Equal(t, domain.IrrigationStatusCompleted, got.Status)
	require.NotNil(t, got.EndedAt)
	assert.Equal(t, 8400.0, got.ActualWaterLiters)
	assert.Equal(t, domain.WaterSourceMeter, got.WaterSource)

	logs, err := svc.GetWaterUsage(ctx, "zone-001", time.Time{}, time.Now().Add(time.Hour))
	require.NoError(t, err)
	require.Len(t, logs, 1, "a run closed by the sweep left no water usage row")
	assert.Equal(t, 8400.0, logs[0].WaterLiters)
}

// A run still inside its duration is left alone. Closing it would record a
// volume for water that is still flowing.
func TestARunStillInProgressIsLeftAlone(t *testing.T) {
	repo, svc, _ := meteredService(meter(1_000_000), meter(1_008_400))
	ctx := testContext("tenant-1", "user-1")

	evt, err := svc.TriggerIrrigation(ctx, "sched-001")
	require.NoError(t, err)

	closed, err := svc.CloseFinishedRuns(context.Background(), 10)
	require.NoError(t, err)
	assert.Zero(t, closed, "a run that is still irrigating was closed and metered")
	assert.Nil(t, repo.events[evt.ID].EndedAt)
}

// No stop command is sent: the controller already shut the valve when the
// duration elapsed. Sending one would go out on every sweep, because the
// interlocks never refuse a stop.
func TestClosingAFinishedRunSendsNoCommand(t *testing.T) {
	repo, svc, hw := meteredService(meter(1_000_000), meter(1_008_400))
	ctx := testContext("tenant-1", "user-1")

	evt, err := svc.TriggerIrrigation(ctx, "sched-001")
	require.NoError(t, err)
	sentAfterStart := len(hw.sent)

	started := time.Now().Add(-45 * time.Minute)
	repo.events[evt.ID].StartedAt = &started

	_, err = svc.CloseFinishedRuns(context.Background(), 10)
	require.NoError(t, err)

	assert.Equal(t, sentAfterStart, len(hw.sent),
		"the sweep sent a stop to a valve the controller had already shut")
}

// The sweep is idempotent: a closed run is not closed again, so its water is
// not counted twice into a season's total.
func TestTheSweepDoesNotCloseARunTwice(t *testing.T) {
	repo, svc, _ := meteredService(meter(1_000_000), meter(1_008_400))
	ctx := testContext("tenant-1", "user-1")

	evt, err := svc.TriggerIrrigation(ctx, "sched-001")
	require.NoError(t, err)
	started := time.Now().Add(-45 * time.Minute)
	repo.events[evt.ID].StartedAt = &started

	first, err := svc.CloseFinishedRuns(context.Background(), 10)
	require.NoError(t, err)
	require.Equal(t, 1, first)

	second, err := svc.CloseFinishedRuns(context.Background(), 10)
	require.NoError(t, err)
	assert.Zero(t, second, "a run was closed twice; its water would be counted twice")
}

// With no controller client there is nothing to read a meter with, and the
// sweep does nothing rather than closing runs with invented volumes.
func TestTheSweepDoesNothingWithoutHardware(t *testing.T) {
	_, _, svc := newService()
	closed, err := svc.CloseFinishedRuns(context.Background(), 10)
	require.NoError(t, err)
	assert.Zero(t, closed)
}
