// Package clients contains Connect client adapters for peer services.
package clients

import (
	"context"
	"net/http"
	"time"

	"connectrpc.com/connect"
	"google.golang.org/protobuf/types/known/timestamppb"

	weatherv1 "p9e.in/samavaya/agriculture/weather-service/api/v1"
	weatherv1connect "p9e.in/samavaya/agriculture/weather-service/api/v1/weatherv1connect"

	"p9e.in/samavaya/agriculture/planning-service/internal/domain"
	"p9e.in/samavaya/agriculture/planning-service/internal/ports/outbound"
)

// onsetHistoryYears is how far back the onset average is drawn from.
//
// Seven years: long enough that one freak season does not move the answer,
// short enough that a shifting rainfall pattern is not averaged away with a
// decade that no longer describes the place.
const onsetHistoryYears = 7

// observationPageSize is how many observations are asked for at a time.
//
// weather-service stores sub-daily observations, so seven monsoon seasons is
// tens of thousands of rows. They are paged rather than requested at once,
// because a single unbounded query is the kind of thing that works in testing
// and times out on a field with a dense sensor.
const observationPageSize = 1000

// maxObservationPages bounds the walk.
//
// A field with a minute-resolution sensor would page forever otherwise, and
// the onset estimate does not get better after the first few years of daily
// totals are in.
const maxObservationPages = 200

type weatherClient struct {
	client weatherv1connect.WeatherServiceClient
	now    func() time.Time
}

// NewWeatherClient creates a Connect-backed WeatherClient.
func NewWeatherClient(baseURL string, httpClient *http.Client, opts ...connect.ClientOption) outbound.WeatherClient {
	return &weatherClient{
		client: weatherv1connect.NewWeatherServiceClient(httpClient, baseURL, opts...),
		now:    time.Now,
	}
}

// MonsoonOnset derives a field's typical monsoon onset from its rainfall record.
//
// The observations are rolled up into daily totals before the spell test runs.
// weather-service records whatever cadence the provider gives, and a criterion
// written in millimetres per day applied to hourly readings would never
// register an onset at all.
func (c *weatherClient) MonsoonOnset(ctx context.Context, fieldID string) (*domain.MonsoonOnset, error) {
	now := c.now().UTC()
	start := time.Date(now.Year()-onsetHistoryYears, time.January, 1, 0, 0, 0, 0, time.UTC)

	totals := map[string]*domain.DailyRain{}

	for page := 0; page < maxObservationPages; page++ {
		resp, err := c.client.ListObservations(ctx, connect.NewRequest(&weatherv1.ListObservationsRequest{
			FieldId:    fieldID,
			Start:      timestamppb.New(start),
			End:        timestamppb.New(now),
			PageSize:   observationPageSize,
			PageOffset: int32(page * observationPageSize),
		}))
		if err != nil {
			return nil, err
		}

		observations := resp.Msg.GetObservations()
		for _, obs := range observations {
			at := obs.GetObservedAt()
			if at == nil {
				continue
			}
			day := at.AsTime().UTC().Truncate(24 * time.Hour)
			key := day.Format("2006-01-02")
			if totals[key] == nil {
				totals[key] = &domain.DailyRain{Date: day}
			}
			totals[key].MM += obs.GetPrecipitationMm()
		}

		if len(observations) < observationPageSize {
			break
		}
	}

	daily := make([]domain.DailyRain, 0, len(totals))
	for _, d := range totals {
		daily = append(daily, *d)
	}

	// nil, nil when no onset is detectable. Not an error — a field registered
	// last month has no monsoon history, and that is a normal state, not a
	// failure. The caller falls back to the crop calendar and says so in the
	// window's basis.
	return domain.DetectMonsoonOnset(daily), nil
}
