package domain

import (
	"fmt"
	"strings"
	"time"
)

// Closing the loop from a sensor reading to a valve.
//
// Everything else in this service produces advice: a schedule, a decision, a
// recommended depth. This is the part that opens a valve on a real farm, and
// the difference is not incremental. Advice that is wrong wastes somebody's
// afternoon; an actuation that is wrong floods a field, empties a tank, or
// runs a pump dry, and it does so at three in the morning with nobody watching.
//
// So the command path is built around refusing. Every check below exists
// because of a specific way automatic irrigation goes wrong, and each one is
// named after that failure rather than after what it validates.

// Command tells a controller what to do.
type CommandKind string

const (
	// CommandStart opens a zone for a bounded duration.
	CommandStart CommandKind = "START"
	// CommandStop closes it.
	//
	// A stop is never blocked by an interlock. Every guard below applies to
	// starting water; turning it off is always allowed, because the one thing
	// worse than a valve that will not open is a valve that will not close.
	CommandStop CommandKind = "STOP"
)

// IrrigationCommand is a single instruction to a controller.
type IrrigationCommand struct {
	// ID is the command's own identifier, and doubles as the idempotency key.
	//
	// Controllers are reached over lossy links — LoRaWAN in particular — so a
	// send that times out may or may not have arrived. Retrying with the same
	// id lets the controller recognise the repeat instead of opening the valve
	// a second time.
	ID       string      `json:"id"`
	TenantID string      `json:"tenant_id"`
	ZoneID   string      `json:"zone_id"`
	Kind     CommandKind `json:"kind"`

	// ControllerID is the box this was sent to, filled in by the actuator once
	// it has resolved the zone's controller.
	//
	// Recorded rather than left to be derived from the zone, because a zone's
	// controller can be replaced: asking later which device received a command
	// would otherwise give the answer for whatever box is there now.
	ControllerID string `json:"controller_id"`

	// DurationMinutes bounds a start. There is no unbounded open.
	//
	// A command that says "on" and relies on a later command to say "off"
	// fails open: if the network drops, the process restarts, or the stop is
	// lost, the valve stays open until somebody notices. A duration the
	// controller enforces locally fails closed instead.
	DurationMinutes int32 `json:"duration_minutes"`

	// LitersRequested is what the decision asked for, carried for accounting
	// rather than for the controller.
	LitersRequested float64 `json:"liters_requested"`

	// Reason records why this was issued — the decision id, the sensor reading,
	// or the operator. An automatic command nobody can explain afterwards is
	// indistinguishable from a malfunction.
	Reason string `json:"reason"`
	// IssuedBy is the user, or "system" for an automatic command.
	IssuedBy string    `json:"issued_by"`
	IssuedAt time.Time `json:"issued_at"`
}

// Validate checks a command is well-formed before any interlock is consulted.
func (c *IrrigationCommand) Validate() error {
	if c.TenantID == "" {
		return fmt.Errorf("command has no tenant")
	}
	if c.ZoneID == "" {
		return fmt.Errorf("command has no zone")
	}
	if c.Reason == "" {
		return fmt.Errorf("command has no reason")
	}
	switch c.Kind {
	case CommandStop:
		return nil
	case CommandStart:
		if c.DurationMinutes <= 0 {
			return fmt.Errorf("a start command must carry a duration")
		}
		return nil
	default:
		return fmt.Errorf("unknown command kind %q", c.Kind)
	}
}

// ── Interlocks ──────────────────────────────────────────────────────────────

// Default safety limits. Every one is overridable per zone; these are the
// values applied when nobody has said otherwise.
const (
	// MaxRunMinutes bounds a single start. Four hours is a long irrigation set
	// and well beyond any automatic decision; anything longer is a mistake or
	// a stuck valve.
	MaxRunMinutes int32 = 240

	// MinRestMinutes is the gap enforced between runs on one zone.
	//
	// Soil takes time to absorb. Two starts twenty minutes apart deliver water
	// the field cannot take, and the second one runs off — so a sensor that is
	// still reading dry because the first run has not soaked in yet would
	// otherwise trigger again, and again.
	MinRestMinutes = 90

	// MaxDailyMinutes caps total run time per zone per day. The backstop for
	// every failure the per-command checks miss: a flapping sensor, a decision
	// loop, a rule that fires on every reading.
	MaxDailyMinutes int32 = 480

	// MaxReadingAge is how stale a sensor reading may be and still justify
	// opening a valve.
	//
	// The dangerous case is a sensor that has stopped reporting while reading
	// dry. Without this, its last value justifies irrigation forever, and the
	// field is watered on the strength of a measurement from last week.
	MaxReadingAge = 2 * time.Hour

	// ControllerHeartbeatTTL is how long a heartbeat stays evidence that a
	// controller is reachable.
	//
	// The failure this catches is a controller that was answering and stopped.
	// Its stored status still says ONLINE, because a status column is a cached
	// opinion that something has to remember to revise, while the absence of a
	// heartbeat is the device itself not speaking.
	ControllerHeartbeatTTL = 15 * time.Minute

	// DailyWindow is the period MaxDailyMinutes is counted over.
	//
	// A rolling 24 hours rather than a calendar day, because no zone stores a
	// timezone and the alternative is counting from UTC midnight — which on an
	// Indian farm falls at 05:30 local, in the middle of the morning irrigation
	// set, and would reset the daily cap halfway through it. A rolling window
	// has no boundary to land badly and is never more permissive than a
	// calendar day.
	DailyWindow = 24 * time.Hour
)

// ZoneLimits are the per-zone overrides.
type ZoneLimits struct {
	MaxRunMinutes   int32
	MinRestMinutes  int32
	MaxDailyMinutes int32
	// Automatic gates unattended actuation for this zone. False means the zone
	// accepts operator commands but nothing automatic — the per-zone form of
	// the kill switch, and the setting a farmer reaches for after one bad
	// night.
	Automatic bool
}

// DefaultZoneLimits returns the limits applied to a zone with no overrides.
func DefaultZoneLimits() ZoneLimits {
	return ZoneLimits{
		MaxRunMinutes:   MaxRunMinutes,
		MinRestMinutes:  MinRestMinutes,
		MaxDailyMinutes: MaxDailyMinutes,
		// Off by default. Automatic irrigation is something a farmer opts into
		// for a zone they have watched behave, not something that starts
		// happening because a sensor was installed.
		Automatic: false,
	}
}

// ZoneState is what the interlocks need to know about a zone right now.
type ZoneState struct {
	ZoneID string
	Limits ZoneLimits
	// LastRunEndedAt is when water last stopped. Zero means never.
	LastRunEndedAt time.Time
	// MinutesRunToday counts run time since local midnight.
	MinutesRunToday int32
	// Running is whether water is on now.
	Running bool
	// ControllerOnline reflects the last heartbeat.
	ControllerOnline bool
}

// InterlockError says why a command was refused.
type InterlockError struct {
	Interlock string
	Detail    string
}

func (e *InterlockError) Error() string {
	return fmt.Sprintf("%s: %s", e.Interlock, e.Detail)
}

// CheckInterlocks decides whether a command may proceed.
//
// Returns nil to allow. A refusal is an *InterlockError naming which check
// stopped it, so the log says "min_rest" rather than "command rejected" and an
// operator can tell a safety limit from a bug.
//
// The order is deliberate: the cheapest and most absolute checks first, so a
// zone with automation disabled is refused before anything reads its history.
func CheckInterlocks(cmd *IrrigationCommand, state ZoneState, now time.Time) error {
	if err := cmd.Validate(); err != nil {
		return &InterlockError{Interlock: "malformed", Detail: err.Error()}
	}

	// A stop passes everything. See CommandStop.
	if cmd.Kind == CommandStop {
		return nil
	}

	if !state.ControllerOnline {
		// Sending a start to a controller that is not answering means not
		// knowing whether the valve opened. The stop that should follow would
		// be equally unheard.
		return &InterlockError{
			Interlock: "controller_offline",
			Detail:    "controller has not reported a heartbeat",
		}
	}

	if cmd.IssuedBy == "system" && !state.Limits.Automatic {
		return &InterlockError{
			Interlock: "automation_disabled",
			Detail:    "this zone does not accept automatic commands",
		}
	}

	if state.Running {
		// Not an error worth alarming about, but a second start while water is
		// already on is a sign the first one was not observed.
		return &InterlockError{
			Interlock: "already_running",
			Detail:    "the zone is already irrigating",
		}
	}

	maxRun := state.Limits.MaxRunMinutes
	if maxRun <= 0 {
		maxRun = MaxRunMinutes
	}
	if cmd.DurationMinutes > maxRun {
		return &InterlockError{
			Interlock: "max_run",
			Detail:    fmt.Sprintf("%d minutes exceeds the %d-minute limit for this zone", cmd.DurationMinutes, maxRun),
		}
	}

	rest := state.Limits.MinRestMinutes
	if rest <= 0 {
		rest = MinRestMinutes
	}
	if !state.LastRunEndedAt.IsZero() {
		elapsed := now.Sub(state.LastRunEndedAt)
		if elapsed < time.Duration(rest)*time.Minute {
			return &InterlockError{
				Interlock: "min_rest",
				Detail: fmt.Sprintf("last run ended %s ago; %d minutes of rest required",
					elapsed.Round(time.Minute), rest),
			}
		}
	}

	daily := state.Limits.MaxDailyMinutes
	if daily <= 0 {
		daily = MaxDailyMinutes
	}
	if state.MinutesRunToday+cmd.DurationMinutes > daily {
		return &InterlockError{
			Interlock: "max_daily",
			Detail: fmt.Sprintf("%d minutes already run today; %d more would exceed the %d-minute cap",
				state.MinutesRunToday, cmd.DurationMinutes, daily),
		}
	}

	return nil
}

// ReadingTooOld reports whether a sensor reading is too stale to act on.
//
// Separate from CheckInterlocks because only an automatic command has a
// reading behind it: an operator pressing "water this zone" is the
// justification, and does not need one.
func ReadingTooOld(readingAt, now time.Time, maxAge time.Duration) bool {
	if maxAge <= 0 {
		maxAge = MaxReadingAge
	}
	if readingAt.IsZero() {
		return true
	}
	// A reading from the future is a clock problem on the device, and trusting
	// it would let a badly-set clock keep a stale value permanently fresh.
	if readingAt.After(now.Add(5 * time.Minute)) {
		return true
	}
	return now.Sub(readingAt) > maxAge
}

// ── Deriving a zone's state from what was recorded ──────────────────────────

// Run is one irrigation run as the events table holds it.
type Run struct {
	StartedAt time.Time
	// EndedAt is when the run was recorded as finished. Nil is the common
	// case rather than the exception: nothing in this service closes a run, so
	// almost every row has a start and a duration and no end.
	EndedAt         *time.Time
	DurationMinutes int32
}

// End is when the run stopped, or is due to stop.
//
// An open-ended row does not mean water is still flowing. A start command
// carries a duration the controller enforces locally — there is no unbounded
// open — so a run that began 90 minutes ago for 30 minutes is over, whether or
// not anything wrote the end back.
//
// This matters more than it looks. Read naively, an unclosed row makes a zone
// permanently "running", and the already_running interlock then refuses every
// subsequent start on that zone for ever: one safety check silently disabling
// irrigation entirely.
func (r Run) End() time.Time {
	if r.EndedAt != nil {
		return *r.EndedAt
	}
	if r.DurationMinutes <= 0 {
		return r.StartedAt
	}
	return r.StartedAt.Add(time.Duration(r.DurationMinutes) * time.Minute)
}

// RunSummary is the part of ZoneState that comes from a zone's run history.
type RunSummary struct {
	LastRunEndedAt  time.Time
	MinutesRunToday int32
	Running         bool
}

// SummariseRuns derives a zone's run state from its recent runs.
//
// Kept here, out of SQL, because it is the arithmetic the interlocks depend on
// and it is the part worth testing: a query can be eyeballed, an off-by-one in
// a rest interval cannot.
func SummariseRuns(runs []Run, now time.Time) RunSummary {
	var out RunSummary
	windowStart := now.Add(-DailyWindow)

	for _, run := range runs {
		if run.StartedAt.IsZero() || run.StartedAt.After(now) {
			// A run that has not begun contributes nothing, and a start
			// timestamped in the future is a clock problem on the device
			// rather than water on a field.
			continue
		}
		end := run.End()

		if run.EndedAt == nil && end.After(now) {
			out.Running = true
			// Deliberately not counted towards the daily total yet, and not
			// treated as a last run: it is this run, still going.
			out.MinutesRunToday += minutesBetween(maxTime(run.StartedAt, windowStart), now)
			continue
		}

		if end.After(out.LastRunEndedAt) {
			out.LastRunEndedAt = end
		}
		// Only the part of the run inside the window counts. A four-hour set
		// that began five hours ago has an hour of it outside.
		if end.After(windowStart) {
			out.MinutesRunToday += minutesBetween(maxTime(run.StartedAt, windowStart), minTime(end, now))
		}
	}
	return out
}

// ControllerReachable reports whether a controller should be treated as online.
//
// A fresh heartbeat is the only positive evidence, and a stale one is a
// refusal whatever the status column says — a controller that went quiet is
// exactly the case the controller_offline interlock exists for.
//
// A controller that has *never* reported falls back to its status, which is
// what registration sets. That is a weaker guard and it is deliberate: nothing
// in this platform currently sends heartbeats, and reading "never reported" as
// "offline" would refuse every command on every farm rather than protect
// anyone. The fix is to make controllers heartbeat, not to loosen this.
func ControllerReachable(status ControllerStatus, lastHeartbeat *time.Time, now time.Time) bool {
	if lastHeartbeat == nil || lastHeartbeat.IsZero() {
		return status == ControllerStatusOnline
	}
	if lastHeartbeat.After(now.Add(5 * time.Minute)) {
		// A heartbeat from the future is a clock problem, and trusting it
		// would keep a dead controller permanently fresh.
		return false
	}
	return now.Sub(*lastHeartbeat) <= ControllerHeartbeatTTL
}

func minutesBetween(from, to time.Time) int32 {
	if !to.After(from) {
		return 0
	}
	return int32(to.Sub(from) / time.Minute)
}

func maxTime(a, b time.Time) time.Time {
	if a.After(b) {
		return a
	}
	return b
}

func minTime(a, b time.Time) time.Time {
	if a.Before(b) {
		return a
	}
	return b
}

// ── Acting on a sensor reading ──────────────────────────────────────────────

// SoilMoistureSensorType is the sensor_type a reading must carry to open a
// valve. Nothing else on a farm's sensor network implies irrigation, and a
// temperature reading that reached the moisture path would be compared against
// a moisture threshold and water the field whenever it was cold.
const SoilMoistureSensorType = "SOIL_MOISTURE"

// GoodReadingQuality is the only quality that may open a valve.
//
// sensor-service grades every reading, marking one outside its sensor's valid
// range SUSPECT or BAD. A probe that has been pulled out of the ground, or
// whose cable has failed, reads far outside range — and reads dry.
const GoodReadingQuality = "GOOD"

// MoistureReading is a soil-moisture measurement as it arrives from
// sensor-service.
type MoistureReading struct {
	SensorID string
	TenantID string
	FieldID  string
	// Percent is volumetric water content as a percentage, 0..100.
	//
	// The name carries the unit deliberately. sensor-service records soil
	// moisture on a 0..100 scale with unit "%", and a schedule's threshold is
	// SoilMoistureThresholdPct on the same scale — but weather observations
	// elsewhere in this platform carry m³/m³ on 0..1, and the two are a
	// hundredfold apart. A fraction arriving here would read as 0.3% and
	// water a field that is already saturated, every time a reading arrived.
	Percent    float64
	Unit       string
	Quality    string
	SensorType string
	RecordedAt time.Time
}

// UsableForActuation reports whether a reading may be acted on.
//
// Returns an error naming the reason rather than a bool, because every one of
// these is worth seeing in a log: a run of refusals means a sensor needs
// attention, and "reading not usable" would not say which.
func (r MoistureReading) UsableForActuation() error {
	if r.TenantID == "" {
		// Cannot be scoped, so every query would run unscoped and row-level
		// security would return nothing — which reads as a field with no
		// irrigation zones rather than as a failure.
		return fmt.Errorf("reading carries no tenant")
	}
	if r.FieldID == "" {
		return fmt.Errorf("reading carries no field, so there is no zone to water")
	}
	if r.SensorType != SoilMoistureSensorType {
		return fmt.Errorf("sensor type %q does not measure soil moisture", r.SensorType)
	}
	if r.Quality != GoodReadingQuality {
		return fmt.Errorf("reading is graded %s, not %s", r.Quality, GoodReadingQuality)
	}
	// Outside the physical range the value is not a moisture percentage at
	// all. Most often it is a probe reading its own disconnection, which
	// presents as dry — the exact reading that opens a valve.
	if r.Percent < 0 || r.Percent > 100 {
		return fmt.Errorf("moisture of %.1f%% is outside 0..100 and is not a percentage", r.Percent)
	}
	// A unit is not always sent, and an absent one is taken as the percentage
	// sensor-service records. A unit that is present and is not a percentage
	// is refused rather than converted: guessing at a scale is how a fraction
	// becomes a hundredfold error that still looks like a reading.
	//
	// The accepted spellings are only the ones that unambiguously mean a
	// percentage. sensor-service passes the unit through as free text from the
	// device or its configuration, so which of these a given probe sends is
	// not something this service gets to decide — and refusing "percent"
	// because the fixture happened to say "%" would strand a reading over
	// nothing. Anything outside this set is still refused, because "m3/m3"
	// differs from "%" by a factor of a hundred.
	if !isPercentUnit(r.Unit) {
		return fmt.Errorf("moisture is reported in %q, not a percentage", r.Unit)
	}
	if r.RecordedAt.IsZero() {
		return fmt.Errorf("reading carries no timestamp, so its age cannot be checked")
	}
	return nil
}

// AdaptiveSchedule picks the schedule that says when a sensor may water a zone.
//
// A zone opts into automatic irrigation by having exactly one ADAPTIVE
// schedule with a threshold and a duration. Zones without one are not watered
// from a sensor at all, which is the opt-in: this is unattended irrigation,
// and it should start happening because somebody configured it rather than
// because a sensor was installed.
//
// Two eligible schedules is a refusal, not a choice. They carry different
// thresholds, so acting on whichever sorted first would silently ignore the
// other and water the field on a rule nobody selected — and the farmer who
// set the second one would have no way to tell.
func AdaptiveSchedule(schedules []IrrigationSchedule) (*IrrigationSchedule, error) {
	var found []*IrrigationSchedule
	for i := range schedules {
		s := &schedules[i]
		if s.ScheduleType != ScheduleTypeAdaptive {
			continue
		}
		if s.Status == IrrigationStatusCancelled || s.Status == IrrigationStatusCompleted {
			continue
		}
		// Both are required. A threshold of zero would water a field only
		// when the soil reads bone dry, and a duration of zero is a start
		// command the interlocks reject as malformed — neither is a rule
		// anybody meant to write.
		if s.SoilMoistureThresholdPct <= 0 || s.DurationMinutes <= 0 {
			continue
		}
		found = append(found, s)
	}

	switch len(found) {
	case 0:
		return nil, nil
	case 1:
		return found[0], nil
	default:
		ids := make([]string, 0, len(found))
		for _, s := range found {
			ids = append(ids, s.ID)
		}
		return nil, fmt.Errorf(
			"zone has %d adaptive schedules (%s); their thresholds disagree and acting on one would ignore the rest",
			len(found), strings.Join(ids, ", "))
	}
}

// ── How much water a run applied ────────────────────────────────────────────

// WaterSource records where a volume figure came from.
//
// It exists because a number in a column called water_liters says nothing
// about whether anybody measured it, and the three cases below are not
// interchangeable: one is a meter reading, one is arithmetic on a measured
// rate, and one is an admission. An auditor, or a farmer comparing two
// seasons, needs to know which they are looking at.
type WaterSource string

const (
	// WaterSourceMeter is a difference between two readings of the
	// controller's cumulative water meter. The only measurement of volume
	// this platform can take.
	WaterSourceMeter WaterSource = "METER"

	// WaterSourceEstimated is the measured flow rate multiplied by the run's
	// measured duration, for a panel that reports a rate but keeps no
	// totaliser.
	//
	// Honest arithmetic on two measurements, and still an estimate: the rate
	// is sampled at the ends of the run, so a line that blocked in the middle
	// and delivered nothing for twenty minutes produces the same figure as
	// one that ran clean.
	WaterSourceEstimated WaterSource = "ESTIMATED"

	// WaterSourceUnmetered is a run whose volume nobody measured.
	//
	// Recorded as its own row with zero litres rather than omitted, so that a
	// zone's water usage can distinguish "no water was applied" from "water
	// was applied and not measured". Omitting it would make an unmetered farm
	// indistinguishable from an idle one.
	WaterSourceUnmetered WaterSource = "UNMETERED"
)

// MeterRollover is where a cumulative meter wraps back to zero.
//
// 2^32 litres, because that is what a 32-bit totaliser holds and what the
// irrigation panels that expose one use. Four billion litres is about eleven
// years of continuous flow at a hundred litres a minute, so a farm reaches it
// eventually rather than never — and the field it wraps on is one where the
// naive subtraction produces a run that applied minus four billion litres.
const MeterRollover = 4294967296.0

// MaxPlausibleRunLiters is the most water a single run could deliver.
//
// MaxRunMinutes bounds a run at four hours, and a very large agricultural pump
// moves on the order of 200 m³ an hour, so eight hundred thousand litres is
// already generous. A million is the round number above it.
//
// This is a sanity bound on a *measurement*, not a limit on irrigation: a
// difference larger than this did not come from water passing a meter, and
// the run is recorded as unmetered rather than credited with it.
const MaxPlausibleRunLiters = 1_000_000.0

// MeteredVolume is how much water passed between two meter readings.
//
// Handles the wrap, which is the whole reason this is a function rather than a
// subtraction at the call site. A cumulative counter that has rolled over
// reads lower at the end of a run than at the start, and `end - start` is then
// a large negative number that would be stored as the run's water usage, sum
// into a season's total, and take it negative.
//
// Reports false when the readings cannot describe a run: a drop too large to
// be a rollover means the meter was replaced or reset, and a guess at how much
// water flowed across that is worse than admitting the run is unmetered.
func MeteredVolume(start, end float64) (float64, bool) {
	// Both readings have to be from the same counter before any arithmetic on
	// them means anything. Without this check an out-of-range start makes the
	// wrap branch below produce a *negative* volume, which is the exact
	// failure the wrap handling exists to prevent.
	if start < 0 || end < 0 || start >= MeterRollover || end >= MeterRollover {
		return 0, false
	}

	delta := end - start
	if delta < 0 {
		// The counter wrapped. What passed is the remainder of the range plus
		// whatever has accumulated since zero.
		delta = (MeterRollover - start) + end
	}

	// A single run cannot deliver this much, so a jump this large is a reset,
	// a replaced unit, or a decoding error rather than water.
	//
	// The ceiling matters most on the wrap branch, where the arithmetic is
	// happy to turn a meter swapped mid-season into a plausible-looking
	// several hundred million litres. Comparing against the counter's whole
	// range would not catch that; comparing against what a run can physically
	// deliver does.
	if delta > MaxPlausibleRunLiters {
		return 0, false
	}
	return delta, true
}

// EstimatedVolume is the fallback for a panel that reports a flow rate and
// keeps no totaliser: the mean of the rates seen at the ends of the run,
// multiplied by how long it ran.
//
// Returns false rather than zero when there is no rate to work from, so that
// "the panel has no flow sensor" stays distinguishable from "no water flowed".
func EstimatedVolume(startRateLitersPerHour, endRateLitersPerHour float64, haveStart, haveEnd bool, ran time.Duration) (float64, bool) {
	if ran <= 0 {
		return 0, false
	}

	var sum float64
	var n int
	if haveStart && startRateLitersPerHour >= 0 {
		sum += startRateLitersPerHour
		n++
	}
	if haveEnd && endRateLitersPerHour >= 0 {
		sum += endRateLitersPerHour
		n++
	}
	if n == 0 {
		return 0, false
	}
	return (sum / float64(n)) * ran.Hours(), true
}

// isPercentUnit reports whether a unit string means "percent".
//
// An empty unit counts: sensor-service leaves it unset when neither the
// reading nor the sensor's configuration carries one, and what it records in
// that case is a percentage.
func isPercentUnit(unit string) bool {
	switch strings.ToLower(strings.TrimSpace(unit)) {
	case "", "%", "pct", "percent":
		return true
	default:
		return false
	}
}
