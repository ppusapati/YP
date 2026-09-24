//go:build integration

// Package postgres's SQL, exercised against a real PostgreSQL.
//
// This service had no repository test of any kind, so every query in it was
// reviewed and never executed. That is a gap the unit tests cannot close: they
// run against a map, and a map does not have a NOT NULL constraint, a partial
// unique index, a row-level security policy, or an opinion about whether
// `ON CONFLICT ... WHERE` parses.
//
// Run it with a database:
//
//	go test -tags=integration ./irrigation-service/internal/adapters/outbound/postgres/ \
//	    -irrigation-dsn "postgres://yp_app@127.0.0.1:5432/irrigation_service?sslmode=disable"
//
// The DSN should name the non-superuser role services connect with, because a
// superuser bypasses RLS and would make these pass whatever the policies say.
package postgres

import (
	"context"
	"flag"
	"testing"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"go.uber.org/zap"
	"p9e.in/samavaya/packages/database/rlspool"

	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/saas"
	"p9e.in/samavaya/packages/ulid"

	"p9e.in/samavaya/agriculture/irrigation-service/internal/domain"
)

var dsn = flag.String("irrigation-dsn", "",
	"PostgreSQL DSN for the irrigation_service database, migrated and reachable")

func newPool(t *testing.T) *pgxpool.Pool {
	t.Helper()
	if *dsn == "" {
		t.Skip("no -irrigation-dsn given")
	}
	// Built the way main builds it, so the RLS session settings are applied
	// per acquire. A plain pgxpool here would be testing a pool no service
	// uses, and under the application role it would fail every write.
	pool, err := rlspool.New(context.Background(), *dsn)
	if err != nil {
		t.Fatalf("connect: %v", err)
	}
	t.Cleanup(pool.Close)
	if err := pool.Ping(context.Background()); err != nil {
		t.Fatalf("ping: %v", err)
	}
	return pool
}

// setup gives each test its own tenant, so they neither see nor disturb each
// other's rows and can run against a database that is not empty.
func setup(t *testing.T) (context.Context, *pgxpool.Pool, *irrigationRepository, string) {
	t.Helper()
	pool := newPool(t)

	tenantID := ulid.NewString()
	ctx := context.Background()
	ctx = p9context.NewConnectionInfo(ctx, &saas.ConnectionInfo{TenantID: tenantID})
	ctx = p9context.NewUserContext(ctx, p9context.UserContext{UserID: "system", TenantID: tenantID})

	zl, _ := zap.NewDevelopment()
	repo := &irrigationRepository{pool: pool, log: p9log.NewHelper(p9log.NewLogger(zl))}

	requireWritableRole(t, ctx, pool, tenantID)
	return ctx, pool, repo, tenantID
}

// requireWritableRole checks the connected role can write, and says what it
// means when it cannot.
//
// This used to skip the whole suite. The repositories queried the pool
// directly and nothing on that path ran set_config('app.tenant_id', ...), so
// under a role subject to RLS every INSERT violated its policy's WITH CHECK
// and every SELECT matched nothing — and nobody had noticed, because
// docker-compose connects as a superuser, which bypasses RLS entirely.
//
// rlspool now sets the scope on every acquire, so this passes under the
// application role. It is kept as a check rather than deleted: a failure here
// again means the wiring has come undone, and the symptom of that is a service
// that silently reads nothing.
func requireWritableRole(t *testing.T, ctx context.Context, pool *pgxpool.Pool, tenantID string) {
	t.Helper()

	probe := ulid.NewString()
	if _, err := pool.Exec(ctx, `
		INSERT INTO irrigation_zones (id, tenant_id, field_id, farm_id, name)
		VALUES ($1, $2, 'probe', 'probe', 'rls probe')`, probe, tenantID); err != nil {
		t.Fatalf("this role cannot write its own tenant's rows, so the RLS session "+
			"settings are not reaching the connection: %v", err)
	}
	if _, err := pool.Exec(ctx, `DELETE FROM irrigation_zones WHERE id = $1`, probe); err != nil {
		t.Fatalf("probe cleanup: %v", err)
	}
}

// seedZone creates a zone, a controller on it, and an adaptive schedule.
func seedZone(t *testing.T, ctx context.Context, repo *irrigationRepository, tenantID string) (
	*domain.IrrigationZone, *domain.WaterController, *domain.IrrigationSchedule,
) {
	t.Helper()

	zone, err := repo.CreateZone(ctx, &domain.IrrigationZone{
		TenantID: tenantID, FieldID: ulid.NewString(), FarmID: ulid.NewString(),
		Name: "North block", AreaHectares: 2.5,
	})
	if err != nil {
		t.Fatalf("CreateZone: %v", err)
	}

	beat := time.Now()
	ctrl, err := repo.CreateController(ctx, &domain.WaterController{
		TenantID: tenantID, ZoneID: zone.ID, FieldID: zone.FieldID, FarmID: zone.FarmID,
		Name: "Panel 1", ControllerType: domain.ControllerTypeValve,
		Protocol: domain.ProtocolModbus, Status: domain.ControllerStatusOnline,
		Endpoint: "10.0.0.5:502?coil=3&meter_register=200", LastHeartbeat: &beat,
	})
	if err != nil {
		t.Fatalf("CreateController: %v", err)
	}

	sched, err := repo.CreateSchedule(ctx, &domain.IrrigationSchedule{
		TenantID: tenantID, FieldID: zone.FieldID, FarmID: zone.FarmID, ZoneID: zone.ID,
		Name: "Adaptive north", ScheduleType: domain.ScheduleTypeAdaptive,
		StartTime: time.Now(), DurationMinutes: 30, WaterQuantityLiters: 12000,
		SoilMoistureThresholdPct: 25, Status: domain.IrrigationStatusScheduled,
		ControllerID: ctrl.ID,
	})
	if err != nil {
		t.Fatalf("CreateSchedule: %v", err)
	}
	return zone, ctrl, sched
}

// ---------------------------------------------------------------------------
// The actuation store — migration 000007

// A zone with no overrides reports the package defaults, and automation off.
//
// The column is NOT NULL DEFAULT FALSE precisely so that shipping the feature
// did not turn every existing zone into one that accepts automatic commands.
func TestZoneLimitsDefaultToOffAndToThePackageValues(t *testing.T) {
	ctx, _, repo, tenantID := setup(t)
	zone, _, _ := seedZone(t, ctx, repo, tenantID)

	state, err := repo.ZoneState(ctx, tenantID, zone.ID)
	if err != nil {
		t.Fatalf("ZoneState: %v", err)
	}
	if state.Limits.Automatic {
		t.Error("a zone nobody opted in accepts automatic commands")
	}
	if state.Limits.MaxRunMinutes != domain.MaxRunMinutes ||
		state.Limits.MinRestMinutes != domain.MinRestMinutes ||
		state.Limits.MaxDailyMinutes != domain.MaxDailyMinutes {
		t.Errorf("limits = %+v, want the package defaults", state.Limits)
	}
	if !state.ControllerOnline {
		t.Error("a controller that heartbeat a moment ago reads as offline")
	}
}

// A NULL override takes the package default; a set one takes the column. The
// columns are nullable so those two stay distinguishable.
func TestAZoneOverrideIsRead(t *testing.T) {
	ctx, pool, repo, tenantID := setup(t)
	zone, _, _ := seedZone(t, ctx, repo, tenantID)

	if _, err := pool.Exec(ctx, `
		UPDATE irrigation_zones SET min_rest_minutes = 15, automatic = TRUE WHERE id = $1`,
		zone.ID); err != nil {
		t.Fatalf("set overrides: %v", err)
	}

	state, err := repo.ZoneState(ctx, tenantID, zone.ID)
	if err != nil {
		t.Fatalf("ZoneState: %v", err)
	}
	if state.Limits.MinRestMinutes != 15 {
		t.Errorf("MinRestMinutes = %d, want the zone's 15", state.Limits.MinRestMinutes)
	}
	if !state.Limits.Automatic {
		t.Error("a zone that opted in still refuses automatic commands")
	}
	// Untouched columns still fall back.
	if state.Limits.MaxRunMinutes != domain.MaxRunMinutes {
		t.Errorf("MaxRunMinutes = %d, want the default", state.Limits.MaxRunMinutes)
	}
}

// The command id is the idempotency key the controller sees, so a retry
// carrying the same id must not produce a second row any more than it produces
// a second run.
func TestRecordingACommandTwiceLeavesOneRow(t *testing.T) {
	ctx, pool, repo, tenantID := setup(t)
	zone, ctrl, _ := seedZone(t, ctx, repo, tenantID)

	cmd := &domain.IrrigationCommand{
		ID: ulid.NewString(), TenantID: tenantID, ZoneID: zone.ID, ControllerID: ctrl.ID,
		Kind: domain.CommandStart, DurationMinutes: 30, LitersRequested: 12000,
		Reason: "schedule triggered", IssuedBy: "user-1", IssuedAt: time.Now(),
	}
	if err := repo.RecordCommand(ctx, cmd); err != nil {
		t.Fatalf("RecordCommand: %v", err)
	}
	if err := repo.RecordCommand(ctx, cmd); err != nil {
		t.Fatalf("RecordCommand on retry: %v", err)
	}

	var rows int
	if err := pool.QueryRow(ctx, `SELECT count(*) FROM irrigation_commands WHERE id=$1`, cmd.ID).
		Scan(&rows); err != nil {
		t.Fatalf("count: %v", err)
	}
	if rows != 1 {
		t.Errorf("%d rows for one command; a retry was recorded as a second run", rows)
	}
}

// A controller that answers twice — a late ack after a timeout was already
// recorded — must not rewrite history into something tidier than what
// happened.
func TestALateAckDoesNotRewriteASettledOutcome(t *testing.T) {
	ctx, pool, repo, tenantID := setup(t)
	zone, ctrl, _ := seedZone(t, ctx, repo, tenantID)

	cmd := &domain.IrrigationCommand{
		ID: ulid.NewString(), TenantID: tenantID, ZoneID: zone.ID, ControllerID: ctrl.ID,
		Kind: domain.CommandStart, DurationMinutes: 30,
		Reason: "operator", IssuedBy: "user-1", IssuedAt: time.Now(),
	}
	if err := repo.RecordCommand(ctx, cmd); err != nil {
		t.Fatalf("RecordCommand: %v", err)
	}

	// Unsettled until something says otherwise, and NULL is "not known"
	// rather than "refused".
	var accepted *bool
	if err := pool.QueryRow(ctx, `SELECT accepted FROM irrigation_commands WHERE id=$1`, cmd.ID).
		Scan(&accepted); err != nil {
		t.Fatalf("read: %v", err)
	}
	if accepted != nil {
		t.Errorf("a command was settled before anything answered: %v", *accepted)
	}

	if err := repo.RecordOutcome(ctx, cmd.ID, true, ""); err != nil {
		t.Fatalf("RecordOutcome: %v", err)
	}
	if err := repo.RecordOutcome(ctx, cmd.ID, false, "late refusal"); err != nil {
		t.Fatalf("RecordOutcome again: %v", err)
	}

	var settled bool
	var detail *string
	if err := pool.QueryRow(ctx,
		`SELECT accepted, outcome_detail FROM irrigation_commands WHERE id=$1`, cmd.ID).
		Scan(&settled, &detail); err != nil {
		t.Fatalf("read: %v", err)
	}
	if !settled {
		t.Error("a late ack overwrote a settled outcome")
	}
	if detail != nil {
		t.Errorf("outcome_detail = %q; the late refusal was written over", *detail)
	}
}

// ---------------------------------------------------------------------------
// Runs and metering — migration 000008

// The meter readings and the source survive a round trip. Sixteen insert
// parameters and a scan in the same order is exactly the kind of thing that
// compiles and is wrong.
func TestMeterReadingsRoundTrip(t *testing.T) {
	ctx, _, repo, tenantID := setup(t)
	zone, ctrl, sched := seedZone(t, ctx, repo, tenantID)

	start := time.Now().Add(-45 * time.Minute)
	meterStart := 1_000_000.0
	evt, err := repo.CreateEvent(ctx, &domain.IrrigationEvent{
		TenantID: tenantID, ScheduleID: sched.ID, ZoneID: zone.ID, ControllerID: ctrl.ID,
		Status: domain.IrrigationStatusActive, StartedAt: &start,
		MeterStartLiters: &meterStart, WaterSource: domain.WaterSourceUnmetered,
	})
	if err != nil {
		t.Fatalf("CreateEvent: %v", err)
	}
	if evt.MeterStartLiters == nil || *evt.MeterStartLiters != meterStart {
		t.Fatalf("MeterStartLiters = %v, want %v", evt.MeterStartLiters, meterStart)
	}
	if evt.WaterSource != domain.WaterSourceUnmetered {
		t.Errorf("WaterSource = %q on a run in progress", evt.WaterSource)
	}

	end := time.Now()
	meterEnd := 1_008_400.0
	evt.EndedAt, evt.MeterEndLiters = &end, &meterEnd
	evt.Status = domain.IrrigationStatusCompleted
	evt.ActualDurationMinutes, evt.ActualWaterLiters = 45, 8400
	evt.WaterSource = domain.WaterSourceMeter

	updated, err := repo.UpdateEvent(ctx, evt)
	if err != nil {
		t.Fatalf("UpdateEvent: %v", err)
	}
	if updated.ActualWaterLiters != 8400 || updated.WaterSource != domain.WaterSourceMeter {
		t.Errorf("volume/source = %v/%q, want 8400/METER", updated.ActualWaterLiters, updated.WaterSource)
	}
	if updated.MeterEndLiters == nil || *updated.MeterEndLiters != meterEnd {
		t.Errorf("MeterEndLiters = %v", updated.MeterEndLiters)
	}
	// Re-read rather than trust the RETURNING clause.
	reread, err := repo.GetEventByUUID(ctx, evt.ID)
	if err != nil {
		t.Fatalf("GetEventByUUID: %v", err)
	}
	if reread.MeterStartLiters == nil || *reread.MeterStartLiters != meterStart {
		t.Errorf("the opening reading did not survive the update: %v", reread.MeterStartLiters)
	}
}

// A run past its duration is due to close; one still running is not, and one
// already closed is not again. The sweep depends on all three, and the
// arithmetic is in SQL where the unit tests cannot reach it.
func TestListRunsDueToClose(t *testing.T) {
	ctx, _, repo, tenantID := setup(t)
	zone, ctrl, sched := seedZone(t, ctx, repo, tenantID)

	newRun := func(startedAgo time.Duration) *domain.IrrigationEvent {
		started := time.Now().Add(-startedAgo)
		evt, err := repo.CreateEvent(ctx, &domain.IrrigationEvent{
			TenantID: tenantID, ScheduleID: sched.ID, ZoneID: zone.ID, ControllerID: ctrl.ID,
			Status: domain.IrrigationStatusActive, StartedAt: &started,
		})
		if err != nil {
			t.Fatalf("CreateEvent: %v", err)
		}
		return evt
	}

	finished := newRun(45 * time.Minute) // a 30-minute schedule
	running := newRun(5 * time.Minute)

	due, err := repo.ListRunsDueToClose(ctx, time.Now(), 10)
	if err != nil {
		t.Fatalf("ListRunsDueToClose: %v", err)
	}
	ids := map[string]bool{}
	for _, e := range due {
		ids[e.ID] = true
	}
	if !ids[finished.ID] {
		t.Error("a run past its duration was not due to close; it would stay ACTIVE for ever, unmetered")
	}
	if ids[running.ID] {
		t.Error("a run still irrigating was listed for closing; its volume would be recorded mid-flow")
	}

	// Close it, and it should not come back.
	end := time.Now()
	finished.EndedAt = &end
	finished.Status = domain.IrrigationStatusCompleted
	if _, err := repo.UpdateEvent(ctx, finished); err != nil {
		t.Fatalf("UpdateEvent: %v", err)
	}
	due, err = repo.ListRunsDueToClose(ctx, time.Now(), 10)
	if err != nil {
		t.Fatalf("ListRunsDueToClose: %v", err)
	}
	for _, e := range due {
		if e.ID == finished.ID {
			t.Fatal("a closed run was listed again; its water would be counted twice")
		}
	}
}

// One usage row per run. A second is a double count, and a seasonal total is
// exactly the query that would absorb it without complaint.
func TestOneWaterUsageRowPerRun(t *testing.T) {
	ctx, pool, repo, tenantID := setup(t)
	zone, ctrl, sched := seedZone(t, ctx, repo, tenantID)

	start := time.Now().Add(-45 * time.Minute)
	end := time.Now()
	evt, err := repo.CreateEvent(ctx, &domain.IrrigationEvent{
		TenantID: tenantID, ScheduleID: sched.ID, ZoneID: zone.ID, ControllerID: ctrl.ID,
		Status: domain.IrrigationStatusCompleted, StartedAt: &start, EndedAt: &end,
	})
	if err != nil {
		t.Fatalf("CreateEvent: %v", err)
	}

	usage := func() *domain.WaterUsageLog {
		return &domain.WaterUsageLog{
			TenantID: tenantID, ZoneID: zone.ID, ControllerID: ctrl.ID,
			WaterLiters: 8400, RecordedAt: end, PeriodStart: start, PeriodEnd: end,
			EventID: evt.ID, Source: domain.WaterSourceMeter,
		}
	}

	first, err := repo.CreateWaterUsageLog(ctx, usage())
	if err != nil {
		t.Fatalf("CreateWaterUsageLog: %v", err)
	}

	// A redelivered close, or a sweep racing an operator's stop. It must not
	// leave two rows, and it must not report a failure: DO NOTHING returns no
	// rows, so without care a perfectly correct idempotency guard comes back
	// as a 500 and gets logged as "the run's water usage could not be
	// recorded" — an alarm about a working system.
	second, err := repo.CreateWaterUsageLog(ctx, usage())
	if err != nil {
		t.Fatalf("a duplicate usage row was reported as a failure: %v", err)
	}
	if second == nil || second.ID != first.ID {
		t.Errorf("the duplicate returned %v, want the row already recorded (%s)", second, first.ID)
	}

	var rows int
	if err := pool.QueryRow(ctx, `SELECT count(*) FROM water_usage_logs WHERE event_id=$1`, evt.ID).
		Scan(&rows); err != nil {
		t.Fatalf("count: %v", err)
	}
	if rows != 1 {
		t.Errorf("%d usage rows for one run; a season's total would double count", rows)
	}
}

// GetWaterUsage returns the run, with the provenance of its figure. This query
// returned an empty list for every zone on every farm until the metering had a
// writer.
func TestWaterUsageComesBackWithItsSource(t *testing.T) {
	ctx, _, repo, tenantID := setup(t)
	zone, ctrl, sched := seedZone(t, ctx, repo, tenantID)

	start := time.Now().Add(-45 * time.Minute)
	end := time.Now()
	evt, err := repo.CreateEvent(ctx, &domain.IrrigationEvent{
		TenantID: tenantID, ScheduleID: sched.ID, ZoneID: zone.ID, ControllerID: ctrl.ID,
		Status: domain.IrrigationStatusCompleted, StartedAt: &start, EndedAt: &end,
	})
	if err != nil {
		t.Fatalf("CreateEvent: %v", err)
	}

	for _, tc := range []struct {
		source domain.WaterSource
		liters float64
	}{
		{domain.WaterSourceMeter, 8400},
	} {
		if _, err := repo.CreateWaterUsageLog(ctx, &domain.WaterUsageLog{
			TenantID: tenantID, ZoneID: zone.ID, ControllerID: ctrl.ID,
			WaterLiters: tc.liters, RecordedAt: end, PeriodStart: start, PeriodEnd: end,
			EventID: evt.ID, Source: tc.source,
		}); err != nil {
			t.Fatalf("CreateWaterUsageLog(%s): %v", tc.source, err)
		}
	}

	logs, err := repo.ListWaterUsageLogs(ctx, zone.ID, start.Add(-time.Hour), end.Add(time.Hour))
	if err != nil {
		t.Fatalf("ListWaterUsageLogs: %v", err)
	}
	if len(logs) != 1 {
		t.Fatalf("got %d usage rows, want 1", len(logs))
	}
	if logs[0].Source != domain.WaterSourceMeter {
		t.Errorf("Source = %q; the figure has no provenance", logs[0].Source)
	}
	if logs[0].EventID != evt.ID {
		t.Errorf("EventID = %q; the figure cannot be traced to its run", logs[0].EventID)
	}
	if logs[0].WaterLiters != 8400 {
		t.Errorf("WaterLiters = %v", logs[0].WaterLiters)
	}
}

// An unmetered run is recorded with zero litres and says so, rather than being
// omitted — otherwise a farm with no meters is indistinguishable from an idle
// one.
func TestAnUnmeteredRunIsStillRecorded(t *testing.T) {
	ctx, _, repo, tenantID := setup(t)
	zone, ctrl, sched := seedZone(t, ctx, repo, tenantID)

	start := time.Now().Add(-45 * time.Minute)
	end := time.Now()
	evt, err := repo.CreateEvent(ctx, &domain.IrrigationEvent{
		TenantID: tenantID, ScheduleID: sched.ID, ZoneID: zone.ID, ControllerID: ctrl.ID,
		Status: domain.IrrigationStatusCompleted, StartedAt: &start, EndedAt: &end,
	})
	if err != nil {
		t.Fatalf("CreateEvent: %v", err)
	}
	if _, err := repo.CreateWaterUsageLog(ctx, &domain.WaterUsageLog{
		TenantID: tenantID, ZoneID: zone.ID, ControllerID: ctrl.ID,
		WaterLiters: 0, RecordedAt: end, PeriodStart: start, PeriodEnd: end,
		EventID: evt.ID, Source: domain.WaterSourceUnmetered,
	}); err != nil {
		t.Fatalf("CreateWaterUsageLog: %v", err)
	}

	logs, err := repo.ListWaterUsageLogs(ctx, zone.ID, start.Add(-time.Hour), end.Add(time.Hour))
	if err != nil {
		t.Fatalf("ListWaterUsageLogs: %v", err)
	}
	if len(logs) != 1 || logs[0].Source != domain.WaterSourceUnmetered {
		t.Fatalf("got %d rows (%v); an unmetered run left no trace", len(logs), logs)
	}
}

// ---------------------------------------------------------------------------

// Row-level security keeps one tenant's rows out of another's.
//
// Only meaningful against a non-superuser role: a superuser bypasses RLS
// entirely, and this would pass whatever the policies said. That is what the
// check below is for.
func TestRowLevelSecurityIsInForce(t *testing.T) {
	ctx, pool, repo, tenantID := setup(t)

	var super, bypass bool
	if err := pool.QueryRow(ctx,
		`SELECT rolsuper, rolbypassrls FROM pg_roles WHERE rolname = current_user`).
		Scan(&super, &bypass); err != nil {
		t.Fatalf("read role: %v", err)
	}
	if super || bypass {
		t.Skip("connected as a role that bypasses RLS; point -irrigation-dsn at the " +
			"application role to exercise the policies")
	}

	zone, _, _ := seedZone(t, ctx, repo, tenantID)

	// A second tenant's context over the same pool. The connection may well be
	// the one that just served the first tenant, which is the case that
	// matters: the scope is rewritten on every acquire.
	otherID := ulid.NewString()
	other := context.Background()
	other = p9context.NewConnectionInfo(other, &saas.ConnectionInfo{TenantID: otherID})
	other = p9context.NewUserContext(other, p9context.UserContext{UserID: "system", TenantID: otherID})

	if _, err := repo.ZoneState(other, otherID, zone.ID); err == nil {
		t.Error("another tenant read a zone's state")
	}

	// And the policy, not just the repository's own WHERE clause, is what
	// stops it: asked for the row by id with no tenant predicate at all, the
	// other tenant still sees nothing.
	var seen int
	if err := pool.QueryRow(other,
		`SELECT count(*) FROM irrigation_zones WHERE id = $1`, zone.ID).Scan(&seen); err != nil {
		t.Fatalf("cross-tenant count: %v", err)
	}
	if seen != 0 {
		t.Error("a query with no tenant predicate read another tenant's row; " +
			"the policies are not doing anything")
	}
}
