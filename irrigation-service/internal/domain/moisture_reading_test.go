package domain

import (
	"strings"
	"testing"
	"time"
)

// The guards between a sensor reading and a valve.
//
// Each of these exists because of a specific way a probe lies, and the
// dangerous direction is always the same: nearly every sensor failure — a
// disconnected cable, a probe pulled out of the ground, a value dropped in
// transit — presents as dry soil, which is the reading that opens a valve.

func goodReading() MoistureReading {
	return MoistureReading{
		SensorID:   "sen-1",
		TenantID:   "t-1",
		FieldID:    "f-1",
		Percent:    18,
		Unit:       "%",
		Quality:    GoodReadingQuality,
		SensorType: SoilMoistureSensorType,
		RecordedAt: now.Add(-10 * time.Minute),
	}
}

func TestAUsableReadingPasses(t *testing.T) {
	if err := goodReading().UsableForActuation(); err != nil {
		t.Errorf("a good reading was refused: %v", err)
	}
}

// Both sides of the comparison are percentages on 0..100, and this is the
// check that says so.
//
// sensor-service records soil moisture with unit "%" over a 0..100 range, and
// a schedule's threshold is SoilMoistureThresholdPct on the same scale. But
// weather observations elsewhere in this platform carry m³/m³ on 0..1, and the
// two are a hundredfold apart. A fraction arriving here reads as 0.3% — drier
// than any soil — and would water a saturated field on every reading.
func TestMoistureAndThresholdAreBothPercentages(t *testing.T) {
	dry := goodReading()
	dry.Percent = 18 // 18% moisture

	threshold := 25.0 // SoilMoistureThresholdPct, the same scale

	if dry.Percent >= threshold {
		t.Fatal("18% should be below a 25% threshold")
	}

	// The same soil reported as a fraction. If a producer ever sends m³/m³
	// and nothing checks, 0.18 is still "below threshold" — so the comparison
	// alone cannot catch it, and the unit check is what has to.
	asFraction := goodReading()
	asFraction.Percent = 0.18
	asFraction.Unit = "m3/m3"
	if err := asFraction.UsableForActuation(); err == nil {
		t.Error("a reading in m³/m³ was accepted and would be compared against a percentage")
	}

	// Saturated soil sent as a fraction would read as bone dry.
	saturated := goodReading()
	saturated.Percent = 0.45
	saturated.Unit = "m3/m3"
	if err := saturated.UsableForActuation(); err == nil {
		t.Error("45% moisture sent as 0.45 was accepted; it reads as 0.45% and waters a wet field")
	}
}

// An absent unit is taken as the percentage sensor-service records, because it
// does not always send one. A unit that is present and is not a percentage is
// refused rather than converted.
func TestUnitHandling(t *testing.T) {
	for _, tc := range []struct {
		unit string
		ok   bool
	}{
		{"", true},    // not sent; the producer's own scale is a percentage
		{"%", true},   // what sensor-service sends
		{"pct", true}, // the same thing spelled out
		{"m3/m3", false},
		{"fraction", false},
		{"mm", false},
	} {
		r := goodReading()
		r.Unit = tc.unit
		err := r.UsableForActuation()
		if (err == nil) != tc.ok {
			t.Errorf("unit %q: usable = %v, want %v (%v)", tc.unit, err == nil, tc.ok, err)
		}
	}
}

// A probe reading its own disconnection is out of physical range, and reads
// dry. Outside 0..100 the value is not a moisture percentage at all.
func TestAnOutOfRangeValueIsNotAPercentage(t *testing.T) {
	for _, pct := range []float64{-1, -9999, 101, 65535} {
		r := goodReading()
		r.Percent = pct
		if err := r.UsableForActuation(); err == nil {
			t.Errorf("%v was accepted as a moisture percentage", pct)
		}
	}
	// The ends of the range are real readings.
	for _, pct := range []float64{0, 100} {
		r := goodReading()
		r.Percent = pct
		if err := r.UsableForActuation(); err != nil {
			t.Errorf("%v%% was refused: %v", pct, err)
		}
	}
}

// sensor-service grades a reading outside its sensor's range SUSPECT or BAD.
// Neither may open a valve.
func TestOnlyAGoodReadingOpensAValve(t *testing.T) {
	for _, q := range []string{"SUSPECT", "BAD", "", "good"} {
		r := goodReading()
		r.Quality = q
		if err := r.UsableForActuation(); err == nil {
			t.Errorf("a reading graded %q was accepted", q)
		}
	}
}

// Nothing but a moisture probe implies irrigation. A temperature reading
// compared against a moisture threshold would water the field whenever it was
// cold.
func TestOnlyASoilMoistureSensorTriggersIrrigation(t *testing.T) {
	for _, st := range []string{"TEMPERATURE", "HUMIDITY", "RAINFALL", "LEAF_WETNESS", ""} {
		r := goodReading()
		r.SensorType = st
		if err := r.UsableForActuation(); err == nil {
			t.Errorf("sensor type %q was accepted as a moisture reading", st)
		}
	}
}

// A reading with no timestamp cannot have its age checked, so it is refused
// rather than treated as current. Substituting "now" would turn the staleness
// guard into a no-op that still looked like a guard.
func TestAReadingWithNoTimestampIsRefused(t *testing.T) {
	r := goodReading()
	r.RecordedAt = time.Time{}
	if err := r.UsableForActuation(); err == nil {
		t.Error("a reading with no timestamp was accepted")
	}
}

// Without a tenant every query runs unscoped, row-level security returns
// nothing, and that reads as a field with no zones rather than as a failure.
func TestAReadingWithNoTenantOrFieldIsRefused(t *testing.T) {
	r := goodReading()
	r.TenantID = ""
	if err := r.UsableForActuation(); err == nil {
		t.Error("a reading with no tenant was accepted")
	}

	r = goodReading()
	r.FieldID = ""
	if err := r.UsableForActuation(); err == nil {
		t.Error("a reading with no field was accepted")
	}
}

// ---------------------------------------------------------------------------

func adaptive(id string, threshold float64, minutes int32) IrrigationSchedule {
	s := IrrigationSchedule{
		ZoneID:                   "z-1",
		ScheduleType:             ScheduleTypeAdaptive,
		SoilMoistureThresholdPct: threshold,
		DurationMinutes:          minutes,
		Status:                   IrrigationStatusScheduled,
	}
	s.ID = id
	return s
}

// A zone opts into unattended irrigation by having an adaptive schedule.
func TestAnAdaptiveScheduleIsTheOptIn(t *testing.T) {
	got, err := AdaptiveSchedule([]IrrigationSchedule{adaptive("sch-1", 25, 30)})
	if err != nil {
		t.Fatalf("AdaptiveSchedule: %v", err)
	}
	if got == nil || got.ID != "sch-1" {
		t.Fatalf("got %+v, want sch-1", got)
	}
}

// A zone with only fixed schedules is not watered from a sensor. Unattended
// irrigation should start because somebody configured it, not because a sensor
// was installed.
func TestAZoneWithoutAnAdaptiveScheduleIsNotWatered(t *testing.T) {
	fixed := adaptive("sch-1", 25, 30)
	fixed.ScheduleType = ScheduleTypeFixed
	ai := adaptive("sch-2", 25, 30)
	ai.ScheduleType = ScheduleTypeAIDriven

	got, err := AdaptiveSchedule([]IrrigationSchedule{fixed, ai})
	if err != nil || got != nil {
		t.Errorf("got %+v, %v; want no schedule and no error", got, err)
	}

	if got, _ := AdaptiveSchedule(nil); got != nil {
		t.Errorf("got %+v for a zone with no schedules", got)
	}
}

// Cancelled and completed schedules are not standing rules.
func TestACancelledScheduleDoesNotWater(t *testing.T) {
	cancelled := adaptive("sch-1", 25, 30)
	cancelled.Status = IrrigationStatusCancelled
	done := adaptive("sch-2", 25, 30)
	done.Status = IrrigationStatusCompleted

	if got, _ := AdaptiveSchedule([]IrrigationSchedule{cancelled, done}); got != nil {
		t.Errorf("got %+v, want none", got)
	}
}

// A threshold or duration of zero is not a rule anybody meant to write: the
// first waters only bone-dry soil, the second is a start the interlocks reject
// as malformed.
func TestAScheduleWithNoThresholdOrDurationIsNotARule(t *testing.T) {
	if got, _ := AdaptiveSchedule([]IrrigationSchedule{adaptive("sch-1", 0, 30)}); got != nil {
		t.Errorf("a schedule with no threshold was used: %+v", got)
	}
	if got, _ := AdaptiveSchedule([]IrrigationSchedule{adaptive("sch-1", 25, 0)}); got != nil {
		t.Errorf("a schedule with no duration was used: %+v", got)
	}
}

// Two adaptive schedules is a refusal, not a choice. Their thresholds
// disagree, so acting on whichever sorted first would silently ignore the
// other and water the field on a rule nobody selected.
func TestTwoAdaptiveSchedulesAreAmbiguousRatherThanAChoice(t *testing.T) {
	got, err := AdaptiveSchedule([]IrrigationSchedule{
		adaptive("sch-1", 25, 30),
		adaptive("sch-2", 40, 60),
	})
	if err == nil {
		t.Fatal("two conflicting schedules were resolved silently")
	}
	if got != nil {
		t.Errorf("got %+v alongside the error", got)
	}
	// The error names them, so a farmer can be told which to remove.
	if !strings.Contains(err.Error(), "sch-1") || !strings.Contains(err.Error(), "sch-2") {
		t.Errorf("error %q does not name the schedules", err)
	}
}
