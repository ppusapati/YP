package domain

import (
	"errors"
	"testing"
	"time"
)

// Each test is named after the failure the interlock exists to prevent, not
// after the function it calls. These are the guards standing between a
// probabilistic decision and a valve on somebody's farm, and the reason each
// one is there matters more than its implementation.

var now = time.Date(2026, 6, 15, 14, 0, 0, 0, time.UTC)

func startCmd(minutes int32) *IrrigationCommand {
	return &IrrigationCommand{
		ID: "cmd-1", TenantID: "t-1", ZoneID: "z-1",
		Kind: CommandStart, DurationMinutes: minutes,
		Reason: "soil moisture below threshold", IssuedBy: "system",
	}
}

func readyZone() ZoneState {
	limits := DefaultZoneLimits()
	limits.Automatic = true
	return ZoneState{
		ZoneID:           "z-1",
		Limits:           limits,
		ControllerOnline: true,
		// Well clear of the rest window.
		LastRunEndedAt: now.Add(-6 * time.Hour),
	}
}

func interlockName(t *testing.T, err error) string {
	t.Helper()
	var ie *InterlockError
	if !errors.As(err, &ie) {
		t.Fatalf("expected an InterlockError, got %v", err)
	}
	return ie.Interlock
}

// ── The command gets through when it should ─────────────────────────────────

func TestAReasonableCommandOnAReadyZoneIsAllowed(t *testing.T) {
	if err := CheckInterlocks(startCmd(45), readyZone(), now); err != nil {
		t.Errorf("a valid command was refused: %v", err)
	}
}

// ── Stopping is never blocked ───────────────────────────────────────────────

func TestStoppingIsNeverRefused(t *testing.T) {
	// The one thing worse than a valve that will not open is a valve that will
	// not close. Every state that blocks a start must still allow a stop.
	stop := &IrrigationCommand{
		ID: "cmd-2", TenantID: "t-1", ZoneID: "z-1",
		Kind: CommandStop, Reason: "operator", IssuedBy: "user-1",
	}

	states := map[string]ZoneState{
		"controller offline":    {ControllerOnline: false},
		"automation disabled":   {ControllerOnline: true, Limits: DefaultZoneLimits()},
		"already running":       {ControllerOnline: true, Running: true},
		"daily cap exhausted":   {ControllerOnline: true, MinutesRunToday: 100000},
		"just ran a moment ago": {ControllerOnline: true, LastRunEndedAt: now.Add(-1 * time.Minute)},
	}
	for name, state := range states {
		if err := CheckInterlocks(stop, state, now); err != nil {
			t.Errorf("stop refused while %s: %v", name, err)
		}
	}
}

// ── Each guard, named after its failure ─────────────────────────────────────

func TestAutomationIsOffUntilSomebodyTurnsItOn(t *testing.T) {
	// Automatic irrigation is something a farmer opts into for a zone they have
	// watched behave, not something that starts happening because a sensor was
	// installed.
	state := readyZone()
	state.Limits.Automatic = false

	err := CheckInterlocks(startCmd(45), state, now)
	if got := interlockName(t, err); got != "automation_disabled" {
		t.Errorf("interlock %q, want automation_disabled", got)
	}

	// And an operator can still act on the same zone.
	manual := startCmd(45)
	manual.IssuedBy = "user-1"
	if err := CheckInterlocks(manual, state, now); err != nil {
		t.Errorf("a manual command was refused on a zone with automation off: %v", err)
	}
}

func TestAnOfflineControllerBlocksTheStart(t *testing.T) {
	// Sending a start to a controller that is not answering means not knowing
	// whether the valve opened — and the stop that should follow would be
	// equally unheard.
	state := readyZone()
	state.ControllerOnline = false

	if got := interlockName(t, CheckInterlocks(startCmd(45), state, now)); got != "controller_offline" {
		t.Errorf("interlock %q, want controller_offline", got)
	}
}

func TestASecondStartWhileRunningIsRefused(t *testing.T) {
	state := readyZone()
	state.Running = true

	if got := interlockName(t, CheckInterlocks(startCmd(45), state, now)); got != "already_running" {
		t.Errorf("interlock %q, want already_running", got)
	}
}

func TestTheRestWindowStopsWateringAlreadyWetSoil(t *testing.T) {
	// The specific loop this prevents: soil takes time to absorb, so a sensor
	// twenty minutes after a run is still reading dry. Without a rest window
	// that reading triggers another run, and another, and the water runs off.
	state := readyZone()
	state.LastRunEndedAt = now.Add(-20 * time.Minute)

	err := CheckInterlocks(startCmd(45), state, now)
	if got := interlockName(t, err); got != "min_rest" {
		t.Errorf("interlock %q, want min_rest", got)
	}
	// The message should say how long is left, not just that it was refused.
	if ie := new(InterlockError); errors.As(err, &ie) && ie.Detail == "" {
		t.Error("the refusal carries no detail")
	}

	// Past the window, the same command is fine.
	state.LastRunEndedAt = now.Add(-2 * time.Hour)
	if err := CheckInterlocks(startCmd(45), state, now); err != nil {
		t.Errorf("refused after the rest window had passed: %v", err)
	}
}

func TestASingleRunIsBounded(t *testing.T) {
	// A command for a day and a half is a mistake or a stuck valve, and there
	// is no legitimate automatic decision that asks for it.
	if got := interlockName(t, CheckInterlocks(startCmd(2000), readyZone(), now)); got != "max_run" {
		t.Errorf("interlock %q, want max_run", got)
	}
}

func TestTheDailyCapIsTheBackstop(t *testing.T) {
	// The guard for every failure the per-command checks miss: a flapping
	// sensor, a decision loop, a rule firing on every reading. Each individual
	// command is reasonable; the total is not.
	state := readyZone()
	state.MinutesRunToday = 460 // cap is 480

	err := CheckInterlocks(startCmd(45), state, now)
	if got := interlockName(t, err); got != "max_daily" {
		t.Errorf("interlock %q, want max_daily", got)
	}

	// A command that fits inside what is left is allowed.
	if err := CheckInterlocks(startCmd(15), state, now); err != nil {
		t.Errorf("a command within the remaining budget was refused: %v", err)
	}
}

func TestPerZoneLimitsOverrideTheDefaults(t *testing.T) {
	// A greenhouse bed and a field of cotton do not want the same numbers.
	state := readyZone()
	state.Limits.MaxRunMinutes = 20

	if got := interlockName(t, CheckInterlocks(startCmd(45), state, now)); got != "max_run" {
		t.Errorf("interlock %q, want the zone's own max_run", got)
	}
	if err := CheckInterlocks(startCmd(15), state, now); err != nil {
		t.Errorf("a command inside the zone's limit was refused: %v", err)
	}
}

func TestZeroedLimitsFallBackToTheDefaults(t *testing.T) {
	// A zone row with unset limits must not mean "no limits". That is the
	// difference between a missing configuration and an unbounded valve.
	state := readyZone()
	state.Limits = ZoneLimits{Automatic: true} // every bound zero

	if got := interlockName(t, CheckInterlocks(startCmd(2000), state, now)); got != "max_run" {
		t.Errorf("interlock %q; zeroed limits were treated as no limit", got)
	}
}

// ── Malformed commands ──────────────────────────────────────────────────────

func TestACommandMustSayWhyItExists(t *testing.T) {
	// An automatic command nobody can explain afterwards is indistinguishable
	// from a malfunction.
	cmd := startCmd(45)
	cmd.Reason = ""

	if got := interlockName(t, CheckInterlocks(cmd, readyZone(), now)); got != "malformed" {
		t.Errorf("interlock %q, want malformed", got)
	}
}

func TestAStartWithoutADurationIsRefused(t *testing.T) {
	// There is no unbounded open. A command that says "on" and relies on a
	// later command to say "off" fails open: if the stop is lost, the valve
	// stays open until somebody notices.
	for _, minutes := range []int32{0, -30} {
		if got := interlockName(t, CheckInterlocks(startCmd(minutes), readyZone(), now)); got != "malformed" {
			t.Errorf("duration %d gave interlock %q, want malformed", minutes, got)
		}
	}
}

func TestACommandWithoutATenantOrZoneIsRefused(t *testing.T) {
	for _, mutate := range []func(*IrrigationCommand){
		func(c *IrrigationCommand) { c.TenantID = "" },
		func(c *IrrigationCommand) { c.ZoneID = "" },
	} {
		cmd := startCmd(45)
		mutate(cmd)
		if err := CheckInterlocks(cmd, readyZone(), now); err == nil {
			t.Errorf("accepted a command missing an identifier: %+v", cmd)
		}
	}
}

func TestAnUnknownCommandKindIsRefused(t *testing.T) {
	cmd := startCmd(45)
	cmd.Kind = "FLUSH"
	if err := CheckInterlocks(cmd, readyZone(), now); err == nil {
		t.Error("an unrecognised command kind was accepted")
	}
}

// ── Reading freshness ───────────────────────────────────────────────────────

func TestAStaleReadingCannotJustifyIrrigation(t *testing.T) {
	// The dangerous case: a sensor that stopped reporting while reading dry.
	// Without this, its last value justifies irrigation forever and the field
	// is watered on a measurement from last week.
	if !ReadingTooOld(now.Add(-6*time.Hour), now, MaxReadingAge) {
		t.Error("a six-hour-old reading was treated as current")
	}
	if ReadingTooOld(now.Add(-30*time.Minute), now, MaxReadingAge) {
		t.Error("a half-hour-old reading was treated as stale")
	}
}

func TestAMissingTimestampIsTreatedAsStale(t *testing.T) {
	// A zero time means the reading carried no timestamp, which is not a
	// reason to trust it.
	if !ReadingTooOld(time.Time{}, now, MaxReadingAge) {
		t.Error("a reading with no timestamp was treated as current")
	}
}

func TestAReadingFromTheFutureIsRejected(t *testing.T) {
	// A device with a badly-set clock would otherwise keep a stale value
	// permanently fresh — the freshness check would never expire it.
	if !ReadingTooOld(now.Add(2*time.Hour), now, MaxReadingAge) {
		t.Error("a reading dated two hours in the future was accepted")
	}
	// A little clock skew is normal and should not reject the reading.
	if ReadingTooOld(now.Add(1*time.Minute), now, MaxReadingAge) {
		t.Error("a minute of clock skew was treated as stale")
	}
}

func TestDefaultsAreAppliedWhenNoMaxAgeIsGiven(t *testing.T) {
	if ReadingTooOld(now.Add(-30*time.Minute), now, 0) {
		t.Error("a fresh reading was rejected when maxAge defaulted")
	}
	if !ReadingTooOld(now.Add(-6*time.Hour), now, 0) {
		t.Error("a stale reading was accepted when maxAge defaulted")
	}
}

// ── Defaults ────────────────────────────────────────────────────────────────

func TestAutomationIsOffByDefault(t *testing.T) {
	if DefaultZoneLimits().Automatic {
		t.Error("a zone with no configuration would accept automatic commands")
	}
}
