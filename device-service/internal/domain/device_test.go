package domain

import (
	"strings"
	"testing"
	"time"
)

var now = time.Date(2026, 3, 14, 9, 0, 0, 0, time.UTC)

func ptr(t time.Time) *time.Time { return &t }

// ─────────────────────────────────────────────────────────────────────────────
// Status is derived, not stored
// ─────────────────────────────────────────────────────────────────────────────

func TestStatusAt_ProvisionedButNeverHeardFrom(t *testing.T) {
	// Distinct from offline: one is an installation that was never finished,
	// the other is a device that worked and stopped. They need different
	// people to do different things.
	d := Device{Serial: "s-1", Kind: KindSoilProbe}

	if got := d.StatusAt(now); got != StatusProvisioned {
		t.Fatalf("status = %s, want PROVISIONED", got)
	}
}

func TestStatusAt_OnlineWhileReporting(t *testing.T) {
	d := Device{LastSeenAt: ptr(now.Add(-30 * time.Minute))}

	if got := d.StatusAt(now); got != StatusOnline {
		t.Fatalf("status = %s, want ONLINE", got)
	}
}

func TestStatusAt_OfflineAfterTheWindow(t *testing.T) {
	// Field hardware on solar and a cellular uplink misses hours in ordinary
	// weather. A tighter window fills the fleet view with devices that are
	// working, and an operator who sees fifty false alarms stops reading it.
	justInside := Device{LastSeenAt: ptr(now.Add(-OfflineAfter + time.Minute))}
	if got := justInside.StatusAt(now); got != StatusOnline {
		t.Errorf("a device inside the window reported %s", got)
	}

	justOutside := Device{LastSeenAt: ptr(now.Add(-OfflineAfter - time.Minute))}
	if got := justOutside.StatusAt(now); got != StatusOffline {
		t.Errorf("a device past the window reported %s", got)
	}
}

func TestStatusAt_DegradedWhenTheDeviceDeclaresAFault(t *testing.T) {
	d := Device{LastSeenAt: ptr(now.Add(-time.Minute)), Fault: "moisture sensor open circuit"}

	if got := d.StatusAt(now); got != StatusDegraded {
		t.Fatalf("status = %s, want DEGRADED", got)
	}
}

func TestStatusAt_OfflineBeatsDegraded(t *testing.T) {
	// A device that raised a fault and then went silent needs a visit for the
	// silence; reporting DEGRADED would suggest it is still talking.
	d := Device{LastSeenAt: ptr(now.Add(-2 * OfflineAfter)), Fault: "low battery"}

	if got := d.StatusAt(now); got != StatusOffline {
		t.Fatalf("status = %s, want OFFLINE", got)
	}
}

func TestStatusAt_RetiredBeatsEverything(t *testing.T) {
	d := Device{
		LastSeenAt: ptr(now.Add(-time.Minute)),
		Fault:      "whatever",
		RetiredAt:  ptr(now.Add(-24 * time.Hour)),
	}

	if got := d.StatusAt(now); got != StatusRetired {
		t.Fatalf("status = %s, want RETIRED", got)
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Heartbeats
// ─────────────────────────────────────────────────────────────────────────────

func heartbeat() Heartbeat {
	return Heartbeat{
		DeviceID:       "dev-1",
		BatteryPercent: 78,
		SignalDBM:      -91,
		RecordedAt:     now.Add(-5 * time.Minute),
	}
}

func TestHeartbeat_Valid(t *testing.T) {
	h := heartbeat()
	if err := h.Validate(now); err != nil {
		t.Fatalf("a good heartbeat was refused: %v", err)
	}
}

func TestHeartbeat_AllowsALittleClockDrift(t *testing.T) {
	// Clock drift on field hardware is routine; refusing it would drop
	// perfectly good readings from devices whose RTC is a minute fast.
	h := heartbeat()
	h.RecordedAt = now.Add(2 * time.Minute)

	if err := h.Validate(now); err != nil {
		t.Fatalf("a slightly-fast clock was refused: %v", err)
	}
}

func TestHeartbeat_RefusesAFutureReading(t *testing.T) {
	// An hour ahead is a broken clock, not a future reading, and accepting it
	// would keep a dead device "online" for that hour.
	h := heartbeat()
	h.RecordedAt = now.Add(time.Hour)

	if err := h.Validate(now); err != ErrHeartbeatFuture {
		t.Fatalf("expected ErrHeartbeatFuture, got %v", err)
	}
}

func TestHeartbeat_AcceptsAGatewayBacklog(t *testing.T) {
	// A gateway buffers while its uplink is down and floods when it returns.
	// The backlog is normal and has to be accepted.
	h := heartbeat()
	h.RecordedAt = now.Add(-8 * time.Hour)

	if err := h.Validate(now); err != nil {
		t.Fatalf("a buffered heartbeat was refused: %v", err)
	}
}

func TestHeartbeat_RefusesOneOlderThanADay(t *testing.T) {
	// Beyond a day it says where the device was yesterday, and letting it set
	// "online" would mark a dead device healthy.
	h := heartbeat()
	h.RecordedAt = now.Add(-MaxHeartbeatAge - time.Minute)

	if err := h.Validate(now); err != ErrHeartbeatTooOld {
		t.Fatalf("expected ErrHeartbeatTooOld, got %v", err)
	}
}

func TestHeartbeat_RefusesAnImpossibleBattery(t *testing.T) {
	for _, pct := range []float64{-1, 101} {
		h := heartbeat()
		h.BatteryPercent = pct
		if err := h.Validate(now); err != ErrBatteryOutOfRange {
			t.Errorf("battery %v: expected ErrBatteryOutOfRange, got %v", pct, err)
		}
	}
}

func TestApply_UpdatesTheDevice(t *testing.T) {
	d := Device{}
	h := heartbeat()
	h.FirmwareVersion = "2.4.1"
	h.Fault = "sensor drift"

	if !d.Apply(h) {
		t.Fatal("the heartbeat was not applied")
	}
	if d.BatteryPercent != 78 || d.SignalDBM != -91 {
		t.Errorf("telemetry was not applied: %+v", d)
	}
	if d.FirmwareVersion != "2.4.1" {
		t.Errorf("firmware = %q", d.FirmwareVersion)
	}
	if d.Fault != "sensor drift" {
		t.Errorf("fault = %q", d.Fault)
	}
}

func TestApply_IgnoresAnOlderHeartbeat(t *testing.T) {
	// A gateway's backlog arrives in whatever order it was queued. A replayed
	// old reading must not roll the battery level back up or clear a fault
	// that was raised afterwards.
	d := Device{
		LastSeenAt:     ptr(now.Add(-time.Minute)),
		BatteryPercent: 12,
		Fault:          "low battery",
	}

	stale := heartbeat()
	stale.RecordedAt = now.Add(-3 * time.Hour)
	stale.BatteryPercent = 95
	stale.Fault = ""

	if d.Apply(stale) {
		t.Fatal("a stale heartbeat was applied")
	}
	if d.BatteryPercent != 12 {
		t.Errorf("battery was rolled back to %v", d.BatteryPercent)
	}
	if d.Fault == "" {
		t.Error("a fault raised later was cleared by an older heartbeat")
	}
}

func TestApply_KeepsFirmwareWhenAHeartbeatOmitsIt(t *testing.T) {
	// Not every heartbeat carries a version; blanking it would make the fleet
	// view show unknown firmware for working devices.
	d := Device{FirmwareVersion: "2.4.1"}
	h := heartbeat()
	h.FirmwareVersion = ""

	d.Apply(h)

	if d.FirmwareVersion != "2.4.1" {
		t.Errorf("firmware was cleared: %q", d.FirmwareVersion)
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Visits
// ─────────────────────────────────────────────────────────────────────────────

func TestNeedsVisit(t *testing.T) {
	cases := []struct {
		name   string
		device Device
		want   bool
	}{
		{"offline", Device{LastSeenAt: ptr(now.Add(-2 * OfflineAfter))}, true},
		{"degraded", Device{LastSeenAt: ptr(now), Fault: "open circuit"}, true},
		{"low battery", Device{LastSeenAt: ptr(now), BatteryPercent: 12}, true},
		{"healthy", Device{LastSeenAt: ptr(now), BatteryPercent: 80}, false},
		// Never installed: an installation task, not a maintenance visit.
		{"provisioned", Device{}, false},
		{"retired", Device{RetiredAt: ptr(now)}, false},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			if got := tc.device.NeedsVisit(now); got != tc.want {
				t.Errorf("NeedsVisit = %v, want %v", got, tc.want)
			}
		})
	}
}

func TestNeedsVisit_IgnoresAnUnreportedBattery(t *testing.T) {
	// A mains-powered device reports 0; treating that as flat would put every
	// gateway on the visit list forever.
	d := Device{LastSeenAt: ptr(now), BatteryPercent: 0}

	if d.NeedsVisit(now) {
		t.Error("a device with no battery reading was flagged for a visit")
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Fleet health
// ─────────────────────────────────────────────────────────────────────────────

func TestSummariseFleet_CountsByDerivedStatus(t *testing.T) {
	devices := []Device{
		{LastSeenAt: ptr(now.Add(-time.Minute)), BatteryPercent: 80},
		{LastSeenAt: ptr(now.Add(-time.Minute)), BatteryPercent: 15},
		{LastSeenAt: ptr(now.Add(-2 * OfflineAfter))},
		{LastSeenAt: ptr(now), Fault: "sensor drift", BatteryPercent: 60},
		{},
	}

	health := SummariseFleet("north", devices, now)

	if health.Total != 5 {
		t.Errorf("total = %d, want 5", health.Total)
	}
	if health.Online != 2 {
		t.Errorf("online = %d, want 2", health.Online)
	}
	if health.Offline != 1 {
		t.Errorf("offline = %d, want 1", health.Offline)
	}
	if health.Degraded != 1 {
		t.Errorf("degraded = %d, want 1", health.Degraded)
	}
	if health.Provisioned != 1 {
		t.Errorf("provisioned = %d, want 1", health.Provisioned)
	}
	if health.LowBattery != 1 {
		t.Errorf("low battery = %d, want 1", health.LowBattery)
	}
}

func TestSummariseFleet_ExcludesRetiredFromTheTotal(t *testing.T) {
	// A fleet of 500 with 200 retired is a fleet of 300. Reporting 60% online
	// when every live device is reporting sends somebody looking for a fault
	// that is not there.
	devices := []Device{
		{LastSeenAt: ptr(now)},
		{RetiredAt: ptr(now.Add(-24 * time.Hour))},
		{RetiredAt: ptr(now.Add(-24 * time.Hour))},
	}

	health := SummariseFleet("north", devices, now)

	if health.Total != 1 {
		t.Errorf("total = %d, want 1 — retired devices are not part of the fleet", health.Total)
	}
	if health.Online != 1 {
		t.Errorf("online = %d, want 1", health.Online)
	}
}

func TestSummariseFleet_CountsALowBatteryOnADegradedDevice(t *testing.T) {
	// A flat battery is often *why* it is degraded, so excluding it would hide
	// the reason for the visit.
	devices := []Device{{LastSeenAt: ptr(now), Fault: "brownout", BatteryPercent: 8}}

	health := SummariseFleet("north", devices, now)

	if health.LowBattery != 1 {
		t.Errorf("low battery = %d, want 1", health.LowBattery)
	}
}

func TestSummariseFleet_EmptyFleet(t *testing.T) {
	health := SummariseFleet("north", nil, now)

	if health.Total != 0 || health.Fleet != "north" {
		t.Errorf("unexpected summary: %+v", health)
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Rollouts
// ─────────────────────────────────────────────────────────────────────────────

func rollout() FirmwareRollout {
	return FirmwareRollout{
		Fleet:            "north",
		Kind:             KindSoilProbe,
		Version:          "2.5.0",
		ArtifactURL:      "https://firmware.example/soil-probe-2.5.0.bin",
		ArtifactSHA256:   "abc123",
		StagePercent:     10,
		FailureThreshold: DefaultFailureThreshold,
		State:            RolloutPending,
	}
}

func TestRollout_RequiresBothURLAndChecksum(t *testing.T) {
	// A URL with no checksum means a device installs whatever is served at
	// that address — the difference between an update channel and a way to
	// brick a fleet.
	r := rollout()
	r.ArtifactSHA256 = ""
	if err := r.Validate(); err != ErrMissingArtifact {
		t.Fatalf("expected ErrMissingArtifact, got %v", err)
	}

	r = rollout()
	r.ArtifactURL = ""
	if err := r.Validate(); err != ErrMissingArtifact {
		t.Fatalf("expected ErrMissingArtifact, got %v", err)
	}
}

func TestRollout_DefaultsAnUnusableFailureThreshold(t *testing.T) {
	r := rollout()
	r.FailureThreshold = 0

	if err := r.Validate(); err != nil {
		t.Fatalf("validate: %v", err)
	}
	if r.FailureThreshold != DefaultFailureThreshold {
		t.Errorf("threshold = %v, want the default", r.FailureThreshold)
	}
}

func TestRollout_StageMustBeAPercentage(t *testing.T) {
	for _, pct := range []int{0, -5, 101} {
		r := rollout()
		r.StagePercent = pct
		if err := r.Validate(); err != ErrStageOutOfRange {
			t.Errorf("stage %d: expected ErrStageOutOfRange, got %v", pct, err)
		}
	}
}

func TestAdvance_WidensTheRollout(t *testing.T) {
	r := rollout()

	if err := r.Advance(50); err != nil {
		t.Fatalf("advance: %v", err)
	}
	if r.StagePercent != 50 {
		t.Errorf("stage = %d, want 50", r.StagePercent)
	}
	if r.State != RolloutInProgress {
		t.Errorf("state = %s, want IN_PROGRESS", r.State)
	}
}

func TestAdvance_IsForwardOnly(t *testing.T) {
	// Reducing the stage would not recall firmware already installed, so a
	// lower number would be a record that disagrees with the hardware.
	r := rollout()
	_ = r.Advance(50)

	if err := r.Advance(20); err != ErrStageWentBackward {
		t.Fatalf("expected ErrStageWentBackward, got %v", err)
	}
	if r.StagePercent != 50 {
		t.Errorf("the stage moved anyway: %d", r.StagePercent)
	}
}

func TestAdvance_RefusedOnAHaltedRollout(t *testing.T) {
	r := rollout()
	r.State = RolloutHalted

	if err := r.Advance(100); err != ErrRolloutNotRunning {
		t.Fatalf("expected ErrRolloutNotRunning, got %v", err)
	}
}

func TestRecordUpdate_CountsOutcomes(t *testing.T) {
	r := rollout()

	r.RecordUpdate(UpdateOffered, now)
	r.RecordUpdate(UpdateSucceeded, now)
	r.RecordUpdate(UpdateFailed, now)

	if r.Offered != 1 || r.Succeeded != 1 || r.Failed != 1 {
		t.Errorf("counts = %d/%d/%d", r.Offered, r.Succeeded, r.Failed)
	}
}

func TestRecordUpdate_ProgressIsNotAnOutcome(t *testing.T) {
	r := rollout()

	r.RecordUpdate(UpdateDownloading, now)
	r.RecordUpdate(UpdateInstalling, now)

	if r.Succeeded != 0 || r.Failed != 0 {
		t.Errorf("progress was counted as an outcome: %d/%d", r.Succeeded, r.Failed)
	}
}

func TestRecordUpdate_ARollbackCountsAsAFailure(t *testing.T) {
	// A device that came back on its old firmware did not take the update,
	// whatever the reason.
	r := rollout()
	r.RecordUpdate(UpdateRolledBack, now)

	if r.Failed != 1 {
		t.Errorf("failed = %d, want 1", r.Failed)
	}
}

func TestRecordUpdate_HaltsWhenTooManyFail(t *testing.T) {
	// Bad firmware on field hardware is not a bad deploy you roll back from a
	// console — every affected device needs somebody to drive to it.
	r := rollout()
	r.FailureThreshold = 0.10

	for i := 0; i < 9; i++ {
		r.RecordUpdate(UpdateSucceeded, now)
	}
	halted := r.RecordUpdate(UpdateFailed, now)

	if !halted {
		t.Fatalf("the rollout did not halt at %d/%d failures", r.Failed, r.Succeeded+r.Failed)
	}
	if r.State != RolloutHalted {
		t.Errorf("state = %s, want HALTED", r.State)
	}
	if !strings.Contains(r.HaltedReason, "threshold") {
		t.Errorf("the halt does not say why: %q", r.HaltedReason)
	}
}

func TestRecordUpdate_DoesNotHaltOnTooFewAttempts(t *testing.T) {
	// One failure out of one is a 100% failure rate and means nothing. A
	// rollout that halts on the first device with a flat battery never reaches
	// the fleet.
	r := rollout()
	halted := r.RecordUpdate(UpdateFailed, now)

	if halted || r.State == RolloutHalted {
		t.Fatalf("the rollout halted after a single failure: %s", r.HaltedReason)
	}
}

func TestRecordUpdate_HaltsOnceTheMinimumIsReached(t *testing.T) {
	r := rollout()
	r.FailureThreshold = 0.5

	for i := 0; i < MinAttemptsBeforeHalt-1; i++ {
		if r.RecordUpdate(UpdateFailed, now) {
			t.Fatalf("halted early at %d attempts", i+1)
		}
	}
	if !r.RecordUpdate(UpdateFailed, now) {
		t.Fatal("the rollout did not halt once the minimum was reached")
	}
}

func TestRecordUpdate_AHaltedRolloutStaysHalted(t *testing.T) {
	r := rollout()
	r.State = RolloutHalted
	r.HaltedReason = "original reason"

	r.RecordUpdate(UpdateSucceeded, now)

	if r.State != RolloutHalted {
		t.Errorf("a halted rollout resumed: %s", r.State)
	}
	if r.HaltedReason != "original reason" {
		t.Errorf("the halt reason was overwritten: %q", r.HaltedReason)
	}
}

func TestAcceptsUpdates(t *testing.T) {
	cases := map[RolloutState]bool{
		RolloutPending:    true,
		RolloutInProgress: true,
		RolloutPaused:     false,
		RolloutHalted:     false,
		RolloutCompleted:  false,
	}

	for state, want := range cases {
		r := rollout()
		r.State = state
		if got := r.AcceptsUpdates(); got != want {
			t.Errorf("%s: AcceptsUpdates = %v, want %v", state, got, want)
		}
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Provisioning
// ─────────────────────────────────────────────────────────────────────────────

func TestDevice_Validate(t *testing.T) {
	d := Device{Serial: "SP-0001", Kind: KindSoilProbe, Latitude: 20.1, Longitude: 77.3}
	if err := d.Validate(); err != nil {
		t.Fatalf("a good device was refused: %v", err)
	}

	noSerial := d
	noSerial.Serial = "  "
	if err := noSerial.Validate(); err != ErrMissingSerial {
		t.Errorf("expected ErrMissingSerial, got %v", err)
	}

	noKind := d
	noKind.Kind = ""
	if err := noKind.Validate(); err != ErrUnknownKind {
		t.Errorf("expected ErrUnknownKind, got %v", err)
	}

	offEarth := d
	offEarth.Latitude = 95
	if err := offEarth.Validate(); err == nil {
		t.Error("a device off the planet was accepted")
	}
}

func TestDevice_AllowsAnUnlocatedDevice(t *testing.T) {
	// A device provisioned in a warehouse has no position yet; 0,0 here means
	// "not placed", and refusing it would block the normal order of work.
	d := Device{Serial: "SP-0001", Kind: KindSoilProbe}

	if err := d.Validate(); err != nil {
		t.Fatalf("an unplaced device was refused: %v", err)
	}
}
