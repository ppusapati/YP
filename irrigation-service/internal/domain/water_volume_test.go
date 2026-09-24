package domain

import (
	"testing"
	"time"
)

// How much water a run applied is the one number on an irrigation record that
// a farmer pays for, an auditor asks about, and a season is planned from. It
// used to be the schedule's plan, copied into a column called "actual" before
// water could have flowed.

// A cumulative meter wraps, and the naive subtraction across a wrap produces a
// run that applied minus four billion litres — which sums into a season's
// total and takes it negative.
func TestAMeterThatWrapsDoesNotRecordNegativeWater(t *testing.T) {
	// 1,200 litres delivered across the wrap: the counter had 800 left in it
	// and has since counted 400.
	start := MeterRollover - 800
	end := 400.0

	got, ok := MeteredVolume(start, end)
	if !ok {
		t.Fatal("a wrapped meter was rejected")
	}
	if got != 1200 {
		t.Errorf("MeteredVolume = %v, want 1200", got)
	}
	if naive := end - start; naive >= 0 {
		t.Fatal("the fixture no longer exercises the wrap")
	}
}

func TestAnOrdinaryRunIsTheDifference(t *testing.T) {
	got, ok := MeteredVolume(1_000_000, 1_008_400)
	if !ok {
		t.Fatal("an ordinary pair of readings was rejected")
	}
	if got != 8400 {
		t.Errorf("MeteredVolume = %v, want 8400", got)
	}
}

// A run that delivered nothing is a real and important reading: it is what a
// blocked line looks like.
func TestAMeterThatDidNotMoveIsZeroAndNotAnError(t *testing.T) {
	got, ok := MeteredVolume(1_000_000, 1_000_000)
	if !ok || got != 0 {
		t.Errorf("MeteredVolume = %v, %v; want 0 and usable — this is a blocked line", got, ok)
	}
}

// A drop too large to be a wrap is a reset or a replaced unit. Guessing at how
// much water crossed that is worse than admitting the run is unmetered.
func TestAResetMeterIsRefusedRatherThanGuessedAt(t *testing.T) {
	// A meter replaced mid-run: it read 3.5 billion, the new unit reads 12.
	if _, ok := MeteredVolume(3_500_000_000, 12); ok {
		t.Error("a replaced meter produced a volume")
	}
	// A reading outside the counter's range is not from this meter.
	if _, ok := MeteredVolume(MeterRollover+5000, 100); ok {
		t.Error("an out-of-range start reading produced a volume")
	}
	// A jump larger than a run can physically deliver is not water. Four
	// hours is the run limit and a very large pump moves 200 m³ an hour, so
	// anything past a million litres came from somewhere other than a valve.
	if _, ok := MeteredVolume(1_000_000, 1_000_000+MaxPlausibleRunLiters+1); ok {
		t.Error("an implausibly large jump produced a volume")
	}
	// And the same across a wrap, which is where the arithmetic is happiest
	// to produce a plausible-looking several hundred million litres.
	if _, ok := MeteredVolume(3_000_000_000, 500_000_000); ok {
		t.Error("a meter swapped mid-season produced a volume across the wrap")
	}
	// A reading at the counter's own maximum is out of range: a 32-bit
	// counter holds 0..2^32-1.
	if _, ok := MeteredVolume(0, MeterRollover); ok {
		t.Error("a reading at the rollover point was accepted")
	}
	for _, bad := range [][2]float64{{-1, 100}, {100, -1}} {
		if _, ok := MeteredVolume(bad[0], bad[1]); ok {
			t.Errorf("negative readings %v produced a volume", bad)
		}
	}
}

// ---------------------------------------------------------------------------

// The estimate is the measured rate times the measured duration.
func TestAnEstimateUsesTheMeasuredRate(t *testing.T) {
	// 1,200 L/h for half an hour.
	got, ok := EstimatedVolume(1200, 1200, true, true, 30*time.Minute)
	if !ok {
		t.Fatal("an estimate was refused although a rate was measured")
	}
	if got != 600 {
		t.Errorf("EstimatedVolume = %v, want 600", got)
	}
}

// The two ends are averaged, so a run that was slowing down is not reported at
// its opening rate.
func TestAnEstimateAveragesTheEnds(t *testing.T) {
	got, ok := EstimatedVolume(1200, 800, true, true, time.Hour)
	if !ok || got != 1000 {
		t.Errorf("EstimatedVolume = %v, %v; want the mean of 1200 and 800", got, ok)
	}
}

// No flow sensor means no estimate, not an estimate of zero. "The panel has no
// flow sensor" and "no water flowed" are not the same statement, and a zero
// recorded as an estimate would be the second.
func TestNoFlowSensorMeansNoEstimate(t *testing.T) {
	if _, ok := EstimatedVolume(0, 0, false, false, time.Hour); ok {
		t.Error("a panel with no flow sensor produced an estimate")
	}
	// A measured zero, on the other hand, is a reading — a blocked line.
	got, ok := EstimatedVolume(0, 0, true, true, time.Hour)
	if !ok || got != 0 {
		t.Errorf("EstimatedVolume = %v, %v; a measured zero is a reading", got, ok)
	}
}

// A run with no duration has no volume to estimate.
func TestAnEstimateNeedsADuration(t *testing.T) {
	if _, ok := EstimatedVolume(1200, 1200, true, true, 0); ok {
		t.Error("a zero-length run produced an estimate")
	}
}

// One end reporting is enough, since a rate sampled once is still a
// measurement.
func TestOneEndIsEnoughForAnEstimate(t *testing.T) {
	got, ok := EstimatedVolume(0, 900, false, true, time.Hour)
	if !ok || got != 900 {
		t.Errorf("EstimatedVolume = %v, %v; want 900 from the one end that reported", got, ok)
	}
}

// The three sources are distinct, because a number in a column called
// water_liters says nothing about whether anybody measured it.
func TestTheSourcesAreDistinguishable(t *testing.T) {
	seen := map[WaterSource]bool{}
	for _, src := range []WaterSource{WaterSourceMeter, WaterSourceEstimated, WaterSourceUnmetered} {
		if src == "" {
			t.Error("a source is empty, which a NOT NULL column would store as a blank")
		}
		if seen[src] {
			t.Errorf("source %q is duplicated; two provenances would be indistinguishable", src)
		}
		seen[src] = true
	}
}
