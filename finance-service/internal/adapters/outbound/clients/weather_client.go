package clients

import (
	"context"
	"net/http"
	"time"

	"connectrpc.com/connect"
	"google.golang.org/protobuf/types/known/timestamppb"

	weatherv1 "p9e.in/samavaya/agriculture/weather-service/api/v1"
	weatherv1connect "p9e.in/samavaya/agriculture/weather-service/api/v1/weatherv1connect"

	"p9e.in/samavaya/agriculture/finance-service/internal/domain"
	"p9e.in/samavaya/agriculture/finance-service/internal/ports/outbound"
)

const observationPageSize = 1000

// maxObservationPages bounds a window read.
const maxObservationPages = 50

// normalYears is how many past years the long-run rainfall normal is drawn from.
//
// Five. A drought claim turns on rainfall being below what is normal *here*,
// and without a local normal the assessment says so rather than comparing the
// Konkan to the Deccan.
const normalYears = 5

// minNormalYears is the shortest history that can stand in for a normal.
const minNormalYears = 3

// wetDayMM is the rainfall that stops a day counting as dry.
const wetDayMM = 2.5

type weatherClient struct {
	client weatherv1connect.WeatherServiceClient
}

// NewWeatherClient creates a Connect-backed WeatherClient.
func NewWeatherClient(baseURL string, httpClient *http.Client, opts ...connect.ClientOption) outbound.WeatherClient {
	return &weatherClient{client: weatherv1connect.NewWeatherServiceClient(httpClient, baseURL, opts...)}
}

// Window reads what the weather did over a loss period.
//
// The same calendar window in each of the previous five years gives the
// long-run normal. Comparing a monsoon fortnight against an annual average
// would make every August look wet and every February look dry, which would
// support a flood claim filed in the monsoon regardless of what happened.
func (c *weatherClient) Window(ctx context.Context, fieldID string, from, to time.Time) (domain.WeatherWindow, error) {
	daily, err := c.dailyRain(ctx, fieldID, from, to)
	if err != nil {
		return domain.WeatherWindow{}, err
	}

	window := domain.WeatherWindow{
		Days: int(to.Sub(from).Hours()/24) + 1,
	}
	if window.Days < 1 {
		window.Days = 1
	}

	for _, day := range daily {
		window.RainfallMM += day.rain
		if day.maxTemp > window.MaxTemperatureC {
			window.MaxTemperatureC = day.maxTemp
		}
		if window.MinTemperatureC == 0 || (day.minTemp != 0 && day.minTemp < window.MinTemperatureC) {
			window.MinTemperatureC = day.minTemp
		}
	}
	window.DryDays = longestDryRun(daily, window.Days)

	// The normal is best-effort. A window with no comparison is reported
	// without one rather than against a made-up figure — the domain reads a
	// missing normal as "cannot say", which is the honest answer.
	totals := make([]float64, 0, normalYears)
	for back := 1; back <= normalYears; back++ {
		pastFrom := from.AddDate(-back, 0, 0)
		pastTo := to.AddDate(-back, 0, 0)

		past, err := c.dailyRain(ctx, fieldID, pastFrom, pastTo)
		if err != nil || len(past) == 0 {
			continue
		}
		total := 0.0
		for _, day := range past {
			total += day.rain
		}
		totals = append(totals, total)
	}

	if len(totals) >= minNormalYears {
		sum := 0.0
		for _, total := range totals {
			sum += total
		}
		window.NormalRainfallMM = sum / float64(len(totals))
		window.HasNormal = true
	}

	return window, nil
}

type dayWeather struct {
	date    time.Time
	rain    float64
	maxTemp float64
	minTemp float64
}

// dailyRain rolls weather-service's observations up into daily totals.
//
// weather-service records whatever cadence the provider gives, so a criterion
// written in millimetres per day applied to raw hourly readings would count a
// wet afternoon as four dry-day-breaking days.
func (c *weatherClient) dailyRain(ctx context.Context, fieldID string, from, to time.Time) ([]dayWeather, error) {
	byDay := map[string]*dayWeather{}

	for page := 0; page < maxObservationPages; page++ {
		resp, err := c.client.ListObservations(ctx, connect.NewRequest(&weatherv1.ListObservationsRequest{
			FieldId:    fieldID,
			Start:      timestamppb.New(from),
			End:        timestamppb.New(to),
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
			if byDay[key] == nil {
				byDay[key] = &dayWeather{date: day}
			}
			entry := byDay[key]
			entry.rain += obs.GetPrecipitationMm()
			if obs.GetTemperatureC() > entry.maxTemp {
				entry.maxTemp = obs.GetTemperatureC()
			}
			if entry.minTemp == 0 || obs.GetTemperatureC() < entry.minTemp {
				entry.minTemp = obs.GetTemperatureC()
			}
		}

		if len(observations) < observationPageSize {
			break
		}
	}

	out := make([]dayWeather, 0, len(byDay))
	for _, day := range byDay {
		out = append(out, *day)
	}
	return out, nil
}

// longestDryRun is the longest run of consecutive dry days in the window.
//
// The longest run, not the count: a drought is twenty days without rain, and
// twenty dry days scattered through six wet weeks is an ordinary monsoon.
func longestDryRun(daily []dayWeather, windowDays int) int {
	if len(daily) == 0 {
		// No observations at all. Reported as zero rather than as the whole
		// window being dry: an absent record is not a record of no rain, and
		// treating it as one would support a drought claim on missing data.
		return 0
	}

	wet := map[string]bool{}
	var earliest time.Time
	for _, day := range daily {
		if day.rain >= wetDayMM {
			wet[day.date.Format("2006-01-02")] = true
		}
		if earliest.IsZero() || day.date.Before(earliest) {
			earliest = day.date
		}
	}

	longest, current := 0, 0
	for offset := 0; offset < windowDays; offset++ {
		key := earliest.AddDate(0, 0, offset).Format("2006-01-02")
		if wet[key] {
			current = 0
			continue
		}
		current++
		if current > longest {
			longest = current
		}
	}
	return longest
}
