package domain

import (
	"testing"
	"time"
)

// rainOn builds a year's rainfall from a day-of-year → mm map.
func rainOn(year int, byDay map[int]float64) []DailyRain {
	out := make([]DailyRain, 0, len(byDay))
	for day, mm := range byDay {
		out = append(out, DailyRain{
			Date: time.Date(year, time.January, 1, 0, 0, 0, 0, time.UTC).AddDate(0, 0, day-1),
			MM:   mm,
		})
	}
	return out
}

func TestDetectMonsoonOnsetFindsFirstSustainedSpell(t *testing.T) {
	// A five-day spell starting on day 160, comfortably over the threshold.
	daily := rainOn(2023, map[int]float64{
		160: 12, 161: 8, 162: 10, 163: 3, 164: 1,
	})

	onset := DetectMonsoonOnset(daily)
	if onset == nil {
		t.Fatal("a 34 mm spell with four wet days should register as an onset")
	}
	if onset.DayOfYear != 160 {
		t.Errorf("onset day = %d, want 160", onset.DayOfYear)
	}
	if onset.Years != 1 {
		t.Errorf("years = %d, want 1", onset.Years)
	}
}

// A single heavy pre-monsoon storm is the failure this criterion exists to
// avoid: sowing on it germinates the seed into a fortnight of dry weather.
func TestDetectMonsoonOnsetIgnoresASingleStorm(t *testing.T) {
	daily := rainOn(2023, map[int]float64{
		150: 80, // one 80 mm cloudburst and nothing else
	})

	if onset := DetectMonsoonOnset(daily); onset != nil {
		t.Fatalf("a single 80 mm day is a pre-monsoon storm, not an onset; got day %d",
			onset.DayOfYear)
	}
}

// Rain that totals enough but never reaches the root zone on any one day.
func TestDetectMonsoonOnsetIgnoresDrizzle(t *testing.T) {
	daily := rainOn(2023, map[int]float64{
		160: 2, 161: 2, 162: 2, 163: 2, 164: 2,
	})

	if onset := DetectMonsoonOnset(daily); onset != nil {
		t.Fatalf("10 mm spread over five days is drizzle; got day %d", onset.DayOfYear)
	}
}

func TestDetectMonsoonOnsetAveragesAcrossYears(t *testing.T) {
	var daily []DailyRain
	for year, start := range map[int]int{2021: 158, 2022: 164, 2023: 161} {
		daily = append(daily, rainOn(year, map[int]float64{
			start: 12, start + 1: 8, start + 2: 10,
		})...)
	}

	onset := DetectMonsoonOnset(daily)
	if onset == nil {
		t.Fatal("three years each with a spell should produce an onset")
	}
	if onset.Years != 3 {
		t.Errorf("years = %d, want 3", onset.Years)
	}
	// (158 + 164 + 161) / 3 = 161.
	if onset.DayOfYear != 161 {
		t.Errorf("onset day = %d, want 161", onset.DayOfYear)
	}
}

// A year whose rain never qualifies is left out of the average rather than
// counted as an onset on day zero, which would drag the answer into February.
func TestDetectMonsoonOnsetSkipsYearsWithoutOne(t *testing.T) {
	daily := append(
		rainOn(2022, map[int]float64{160: 12, 161: 8, 162: 10}),
		rainOn(2023, map[int]float64{200: 1})...,
	)

	onset := DetectMonsoonOnset(daily)
	if onset == nil {
		t.Fatal("one qualifying year should still produce an onset")
	}
	if onset.Years != 1 {
		t.Errorf("years = %d, want 1 — the dry year has no onset to average in", onset.Years)
	}
	if onset.DayOfYear != 160 {
		t.Errorf("onset day = %d, want 160", onset.DayOfYear)
	}
}

// Heavy rain in March is not the monsoon however much of it there is.
func TestDetectMonsoonOnsetIgnoresRainOutsideTheWindow(t *testing.T) {
	daily := rainOn(2023, map[int]float64{
		80: 20, 81: 20, 82: 20, 83: 20, // late March, well before the window
	})

	if onset := DetectMonsoonOnset(daily); onset != nil {
		t.Fatalf("March rain is not a monsoon onset; got day %d", onset.DayOfYear)
	}
}

func TestDetectMonsoonOnsetWithNoDataReturnsNil(t *testing.T) {
	if onset := DetectMonsoonOnset(nil); onset != nil {
		t.Fatal("no rainfall history should mean no onset, not a guessed one")
	}
}

// Sub-daily readings are summed per day before the threshold is applied, which
// is what makes the mm-per-day criterion mean anything against hourly data.
func TestDetectMonsoonOnsetSumsRepeatedReadingsForADay(t *testing.T) {
	day := time.Date(2023, time.January, 1, 0, 0, 0, 0, time.UTC).AddDate(0, 0, 159)
	var daily []DailyRain
	for hour := 0; hour < 3; hour++ {
		for d := 0; d < 3; d++ {
			daily = append(daily, DailyRain{
				Date: day.AddDate(0, 0, d).Add(time.Duration(hour) * time.Hour),
				MM:   4,
			})
		}
	}

	onset := DetectMonsoonOnset(daily)
	if onset == nil {
		t.Fatal("3 days x 12 mm should qualify once the hourly readings are summed")
	}
	if onset.DayOfYear != 160 {
		t.Errorf("onset day = %d, want 160", onset.DayOfYear)
	}
}
