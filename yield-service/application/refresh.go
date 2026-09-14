package application

import (
	"context"
	"fmt"
	"time"

	"p9e.in/samavaya/packages/p9context"

	"p9e.in/samavaya/agriculture/yield-service/internal/domain"
)

// A yield forecast made at sowing is a guess from soil and intent. By flowering
// it can be a much better one, because the weather that actually happened and
// the imagery that actually arrived are now known — but only if something
// re-runs it. Left alone, a farmer plans against a number computed before the
// season had any weather in it.
//
// Weekly is the right cadence for the same reason the number is worth
// refreshing at all: neither weather aggregates nor NDVI move enough day to day
// to change a seasonal forecast, and re-running nightly would spend compute to
// redraw the same line.

// DefaultRefreshInterval is how often in-season forecasts are recomputed.
const DefaultRefreshInterval = 7 * 24 * time.Hour

// How many predictions one pass will refresh, so a large tenant cannot make a
// single run unbounded.
const maxRefreshBatch = 500

// RefreshReport is what one refresh pass did.
type RefreshReport struct {
	Considered int
	Refreshed  int
	Failed     int
	Errors     []string
}

// RefreshInSeasonPredictions recomputes forecasts for seasons still running.
//
// A completed prediction is not final: it is the best answer as of when it was
// made. Superseding it with a fresher one is the point, so the new prediction
// replaces the old rather than accumulating alongside it.
func (s *yieldService) RefreshInSeasonPredictions(ctx context.Context, tenantID string) (*RefreshReport, error) {
	if tenantID == "" {
		return nil, fmt.Errorf("tenant ID is required to refresh predictions")
	}
	// Background work has no caller to inherit a tenant from, so the row-level
	// security scope is set explicitly. Without it every repository query would
	// be blocked, which is the correct default for a request but wrong here.
	ctx = p9context.NewRLSScopeTenantOnly(ctx, tenantID)

	predictions, _, err := s.repo.ListPredictions(ctx, domain.ListPredictionsParams{
		TenantID: tenantID,
		Status:   domain.PredictionStatusCompleted,
		PageSize: maxRefreshBatch,
	})
	if err != nil {
		return nil, fmt.Errorf("list in-season predictions: %w", err)
	}

	report := &RefreshReport{Considered: len(predictions)}
	for i := range predictions {
		p := predictions[i]
		if !inSeason(&p, time.Now()) {
			continue
		}
		// Re-predict from the same field and crop; PredictYield reads the
		// weather and imagery that exist now rather than what existed then.
		fresh := &domain.YieldPrediction{
			TenantID: p.TenantID,
			FarmID:   p.FarmID,
			FieldID:  p.FieldID,
			CropID:   p.CropID,
			Season:   p.Season,
			Year:     p.Year,
		}
		if _, err := s.PredictYield(ctx, fresh); err != nil {
			report.Failed++
			// One field failing says nothing about the others; a whole tenant
			// should not lose its refresh because one lookup timed out.
			if len(report.Errors) < 10 {
				report.Errors = append(report.Errors, fmt.Sprintf("%s: %v", p.FieldID, err))
			}
			continue
		}
		report.Refreshed++
	}

	s.log.Infow("msg", "in-season yield forecasts refreshed",
		"tenant_id", tenantID,
		"considered", report.Considered,
		"refreshed", report.Refreshed,
		"failed", report.Failed,
	)
	return report, nil
}

// inSeason reports whether a prediction's season is still running and so still
// worth recomputing.
//
// The year a prediction was made for is the only season boundary the record
// carries. Last year's forecast is history: recomputing it against this year's
// weather would not improve it, it would corrupt it.
func inSeason(p *domain.YieldPrediction, now time.Time) bool {
	if p.Year == 0 {
		// No year recorded. Refresh it rather than strand it: a forecast with
		// no season attached is more likely current than archival.
		return true
	}
	return int(p.Year) >= now.UTC().Year()
}
