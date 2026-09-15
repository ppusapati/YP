package application

import (
	"testing"
	"time"

	"p9e.in/samavaya/agriculture/yield-service/internal/domain"
)

func TestInSeason(t *testing.T) {
	now := time.Date(2026, 7, 1, 0, 0, 0, 0, time.UTC)

	cases := []struct {
		name string
		year int32
		want bool
	}{
		{"this season is still running", 2026, true},
		// Recomputing last year's forecast against this year's weather would
		// not improve it, it would corrupt it.
		{"last season is history", 2025, false},
		{"a much older season is history", 2019, false},
		// A season booked ahead has not started; refreshing it is harmless and
		// keeps it current as its weather arrives.
		{"next season is still ahead", 2027, true},
		// No season attached: more likely current than archival.
		{"an unrecorded year is refreshed", 0, true},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			p := &domain.YieldPrediction{Year: tc.year}
			if got := inSeason(p, now); got != tc.want {
				t.Errorf("inSeason(year=%d) = %v, want %v", tc.year, got, tc.want)
			}
		})
	}
}

func TestRefreshInSeasonPredictions_RequiresATenant(t *testing.T) {
	// Background work has no caller to inherit a tenant from, and running
	// unscoped would either see nothing or, worse, see everything.
	s := &yieldService{}
	if _, err := s.RefreshInSeasonPredictions(t.Context(), ""); err == nil {
		t.Fatal("expected an untenanted refresh to be refused")
	}
}

func TestDefaultRefreshInterval(t *testing.T) {
	// Weekly: neither weather aggregates nor NDVI move enough day to day to
	// change a seasonal forecast, so a nightly pass would redraw the same line.
	if DefaultRefreshInterval != 7*24*time.Hour {
		t.Errorf("DefaultRefreshInterval = %v, want a week", DefaultRefreshInterval)
	}
}
