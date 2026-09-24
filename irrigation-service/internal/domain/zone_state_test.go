package domain

import (
	"testing"
	"time"
)

// The arithmetic behind the interlocks, tested here because the interlocks are
// only as good as the state they are given and nothing else checks it. A query
// that returns the wrong rest interval refuses nothing and permits everything,
// with no error anywhere.

// `now` is the fixture in actuation_test.go, shared so that the interlocks
// and the state they read are reasoned about at the same instant.

func ago(d time.Duration) time.Time { return now.Add(-d) }

func ptr(t time.Time) *time.Time { return &t }

// A run with no recorded end is over once its duration has elapsed.
//
// This is the one that matters most. Nothing in this service closes a run, so
// every row has a start and a duration and no end — and read naively, an
// unclosed row makes the zone permanently "running". The already_running
// interlock would then refuse every subsequent start on that zone for ever:
// one safety check silently switching irrigation off altogether.
func TestAnUnclosedRunIsOverOnceItsDurationHasElapsed(t *testing.T) {
	got := SummariseRuns([]Run{
		{StartedAt: ago(90 * time.Minute), DurationMinutes: 30},
	}, now)

	if got.Running {
		t.Error("Running = true for a 30-minute run that began 90 minutes ago")
	}
	if want := ago(60 * time.Minute); !got.LastRunEndedAt.Equal(want) {
		t.Errorf("LastRunEndedAt = %v, want %v — start plus duration", got.LastRunEndedAt, want)
	}
}

// A run still inside its duration is running.
func TestARunInsideItsDurationIsRunning(t *testing.T) {
	got := SummariseRuns([]Run{
		{StartedAt: ago(10 * time.Minute), DurationMinutes: 30},
	}, now)

	if !got.Running {
		t.Error("Running = false for a 30-minute run that began 10 minutes ago")
	}
	// Counted for what has elapsed, not for what was asked for: the daily cap
	// is minutes of water, and the rest of this run has not happened yet.
	if got.MinutesRunToday != 10 {
		t.Errorf("MinutesRunToday = %d, want 10", got.MinutesRunToday)
	}
}

// An explicit end wins over the duration, for when something does close a run.
func TestARecordedEndWinsOverTheDuration(t *testing.T) {
	got := SummariseRuns([]Run{
		{StartedAt: ago(90 * time.Minute), DurationMinutes: 60, EndedAt: ptr(ago(75 * time.Minute))},
	}, now)

	if want := ago(75 * time.Minute); !got.LastRunEndedAt.Equal(want) {
		t.Errorf("LastRunEndedAt = %v, want the recorded end %v", got.LastRunEndedAt, want)
	}
	if got.MinutesRunToday != 15 {
		t.Errorf("MinutesRunToday = %d, want 15 — it was stopped early", got.MinutesRunToday)
	}
}

// Only the part of a run inside the window counts towards the daily cap.
func TestOnlyTheOverlapWithTheWindowCounts(t *testing.T) {
	// Began 25 hours ago and ran four hours, so it ended 21 hours ago: the
	// first hour is outside the rolling 24-hour window and the other three
	// are inside it.
	got := SummariseRuns([]Run{
		{StartedAt: ago(25 * time.Hour), DurationMinutes: 240},
	}, now)

	if got.MinutesRunToday != 180 {
		t.Errorf("MinutesRunToday = %d, want 180 — the first of the four hours is outside the window", got.MinutesRunToday)
	}
}

// A run that finished before the window contributes nothing to the total, but
// still counts as the last run for the rest interval.
func TestAnOldRunIsOutOfTheDailyTotal(t *testing.T) {
	got := SummariseRuns([]Run{
		{StartedAt: ago(30 * time.Hour), DurationMinutes: 60},
	}, now)

	if got.MinutesRunToday != 0 {
		t.Errorf("MinutesRunToday = %d, want 0", got.MinutesRunToday)
	}
	if got.LastRunEndedAt.IsZero() {
		t.Error("LastRunEndedAt is zero; an old run is still the last one")
	}
}

// The latest end wins, whatever order the rows arrive in.
func TestTheLatestEndIsTheLastRun(t *testing.T) {
	got := SummariseRuns([]Run{
		{StartedAt: ago(8 * time.Hour), DurationMinutes: 60},
		{StartedAt: ago(20 * time.Hour), DurationMinutes: 60},
		{StartedAt: ago(3 * time.Hour), DurationMinutes: 45},
	}, now)

	if want := ago(3*time.Hour - 45*time.Minute); !got.LastRunEndedAt.Equal(want) {
		t.Errorf("LastRunEndedAt = %v, want %v", got.LastRunEndedAt, want)
	}
	if got.MinutesRunToday != 165 {
		t.Errorf("MinutesRunToday = %d, want 165", got.MinutesRunToday)
	}
}

// A start timestamped in the future is a clock problem on a device, not water
// on a field.
func TestAFutureRunIsIgnored(t *testing.T) {
	got := SummariseRuns([]Run{
		{StartedAt: now.Add(2 * time.Hour), DurationMinutes: 60},
	}, now)

	if got.Running || got.MinutesRunToday != 0 || !got.LastRunEndedAt.IsZero() {
		t.Errorf("a future run was counted: %+v", got)
	}
}

// No runs is a zone that has never irrigated, and the rest interlock must not
// fire on it — a zero LastRunEndedAt is what CheckInterlocks reads as "never".
func TestAZoneThatHasNeverRunPassesTheRestInterlock(t *testing.T) {
	got := SummariseRuns(nil, now)
	if !got.LastRunEndedAt.IsZero() {
		t.Errorf("LastRunEndedAt = %v, want zero", got.LastRunEndedAt)
	}

	cmd := &IrrigationCommand{
		TenantID: "t-1", ZoneID: "z-1", Kind: CommandStart,
		DurationMinutes: 30, IssuedBy: "user-1", Reason: "operator",
	}
	state := ZoneState{
		Limits:           ZoneLimits{MaxRunMinutes: 240, MinRestMinutes: 90, MaxDailyMinutes: 480},
		ControllerOnline: true, LastRunEndedAt: got.LastRunEndedAt,
	}
	if err := CheckInterlocks(cmd, state, now); err != nil {
		t.Errorf("a zone that has never irrigated was refused: %v", err)
	}
}

// ---------------------------------------------------------------------------

// A controller that was answering and went quiet is offline, whatever its
// stored status says. The status column is a cached opinion; the absence of a
// heartbeat is the device not speaking.
func TestAStaleHeartbeatIsOffline(t *testing.T) {
	for _, tc := range []struct {
		name      string
		status    ControllerStatus
		heartbeat *time.Time
		want      bool
	}{
		{"fresh heartbeat", ControllerStatusOnline, ptr(ago(time.Minute)), true},
		{"just inside the TTL", ControllerStatusOnline, ptr(ago(ControllerHeartbeatTTL - time.Minute)), true},
		{"just outside the TTL", ControllerStatusOnline, ptr(ago(ControllerHeartbeatTTL + time.Minute)), false},
		{"quiet for a day, still marked online", ControllerStatusOnline, ptr(ago(24 * time.Hour)), false},
		{"heartbeat from the future", ControllerStatusOnline, ptr(now.Add(time.Hour)), false},
		// Never reported: falls back to the status, because nothing in this
		// platform sends heartbeats yet and reading that as offline would
		// refuse every command on every farm rather than protect anyone.
		{"never reported, marked online", ControllerStatusOnline, nil, true},
		{"never reported, marked offline", ControllerStatusOffline, nil, false},
		{"never reported, in error", ControllerStatusError, nil, false},
		// A fresh heartbeat from a controller reporting a fault is still a
		// fault: the status is what the device said about itself.
		{"fresh heartbeat but in error", ControllerStatusError, ptr(ago(time.Minute)), true},
	} {
		if got := ControllerReachable(tc.status, tc.heartbeat, now); got != tc.want {
			t.Errorf("%s: ControllerReachable = %v, want %v", tc.name, got, tc.want)
		}
	}
}
