package providers

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"strconv"
	"time"

	"p9e.in/samavaya/agriculture/weather-service/internal/domain"
	"p9e.in/samavaya/agriculture/weather-service/internal/ports/outbound"
)

const openWeatherOneCallURL = "https://api.openweathermap.org/data/3.0/onecall"

// OpenWeather implements outbound.WeatherProvider against the OpenWeather One Call 3.0 API.
// Historical backfill is not supported on this provider; use Open-Meteo for archive data.
type OpenWeather struct {
	baseURL string
	apiKey  string
	http    *http.Client
}

// NewOpenWeather creates an OpenWeather provider.
func NewOpenWeather(httpClient *http.Client, baseURL, apiKey string) outbound.WeatherProvider {
	if httpClient == nil {
		httpClient = &http.Client{Timeout: 20 * time.Second}
	}
	if baseURL == "" {
		baseURL = openWeatherOneCallURL
	}
	return &OpenWeather{baseURL: baseURL, apiKey: apiKey, http: httpClient}
}

func (p *OpenWeather) Name() domain.Provider { return domain.ProviderOpenWeather }

type owWeather struct {
	Main string `json:"main"`
}

type owHourly struct {
	Dt        int64   `json:"dt"`
	Temp      float64 `json:"temp"`
	Humidity  float64 `json:"humidity"`
	Pressure  float64 `json:"pressure"`
	DewPoint  float64 `json:"dew_point"`
	Clouds    float64 `json:"clouds"`
	WindSpeed float64 `json:"wind_speed"`
	WindDeg   float64 `json:"wind_deg"`
	Rain      *struct {
		H1 float64 `json:"1h"`
	} `json:"rain"`
}

type owDaily struct {
	Dt        int64   `json:"dt"`
	Humidity  float64 `json:"humidity"`
	WindSpeed float64 `json:"wind_speed"`
	Pop       float64 `json:"pop"`
	Rain      float64 `json:"rain"`
	Temp      struct {
		Min float64 `json:"min"`
		Max float64 `json:"max"`
		Day float64 `json:"day"`
	} `json:"temp"`
	Weather []owWeather `json:"weather"`
}

type owResponse struct {
	Hourly []owHourly `json:"hourly"`
	Daily  []owDaily  `json:"daily"`
	Cod    int        `json:"cod"`
	Msg    string     `json:"message"`
}

func (p *OpenWeather) FetchHourly(ctx context.Context, loc domain.FieldLocation, start, end time.Time) ([]domain.Observation, error) {
	resp, err := p.get(ctx, loc, "minutely,daily,alerts")
	if err != nil {
		return nil, err
	}
	out := make([]domain.Observation, 0, len(resp.Hourly))
	for _, h := range resp.Hourly {
		at := time.Unix(h.Dt, 0).UTC()
		if at.Before(start) || at.After(end) {
			continue
		}
		var rain float64
		if h.Rain != nil {
			rain = h.Rain.H1
		}
		out = append(out, domain.Observation{
			TenantID:         loc.TenantID,
			FieldID:          loc.FieldID,
			ObservedAt:       at,
			TemperatureC:     h.Temp,
			HumidityPct:      h.Humidity,
			PrecipitationMM:  rain,
			WindSpeedMS:      h.WindSpeed,
			WindDirectionDeg: h.WindDeg,
			PressureHPa:      h.Pressure,
			CloudCoverPct:    h.Clouds,
			DewPointC:        h.DewPoint,
			Provider:         domain.ProviderOpenWeather,
		})
	}
	return out, nil
}

func (p *OpenWeather) FetchDailyForecast(ctx context.Context, loc domain.FieldLocation, days int) ([]domain.DailyForecast, error) {
	if days <= 0 {
		days = 7
	}
	if days > 8 {
		days = 8
	}
	resp, err := p.get(ctx, loc, "minutely,hourly,alerts")
	if err != nil {
		return nil, err
	}
	issued := time.Now().UTC()
	out := make([]domain.DailyForecast, 0, days)
	for i, d := range resp.Daily {
		if i >= days {
			break
		}
		cond := "unknown"
		if len(d.Weather) > 0 {
			cond = d.Weather[0].Main
		}
		day := time.Unix(d.Dt, 0).UTC()
		day = time.Date(day.Year(), day.Month(), day.Day(), 0, 0, 0, 0, time.UTC)
		out = append(out, domain.DailyForecast{
			TenantID:          loc.TenantID,
			FieldID:           loc.FieldID,
			ForecastDate:      day,
			IssuedAt:          issued,
			TemperatureMinC:   d.Temp.Min,
			TemperatureMaxC:   d.Temp.Max,
			TemperatureMeanC:  d.Temp.Day,
			PrecipitationMM:   d.Rain,
			PrecipitationProb: d.Pop * 100,
			HumidityMeanPct:   d.Humidity,
			WindSpeedMaxMS:    d.WindSpeed,
			Condition:         cond,
			Provider:          domain.ProviderOpenWeather,
		})
	}
	return out, nil
}

func (p *OpenWeather) FetchHistoricalDaily(_ context.Context, _ domain.FieldLocation, _, _ time.Time) ([]domain.DailyAgroMetrics, error) {
	return nil, fmt.Errorf("openweather: historical backfill not supported; configure OPEN_METEO for archive data")
}

func (p *OpenWeather) get(ctx context.Context, loc domain.FieldLocation, exclude string) (*owResponse, error) {
	if p.apiKey == "" {
		return nil, fmt.Errorf("openweather: OPENWEATHER_API_KEY not configured")
	}
	q := url.Values{}
	q.Set("lat", strconv.FormatFloat(loc.Latitude, 'f', 5, 64))
	q.Set("lon", strconv.FormatFloat(loc.Longitude, 'f', 5, 64))
	q.Set("units", "metric")
	q.Set("exclude", exclude)
	q.Set("appid", p.apiKey)

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, p.baseURL+"?"+q.Encode(), nil)
	if err != nil {
		return nil, err
	}
	resp, err := p.http.Do(req)
	if err != nil {
		return nil, fmt.Errorf("openweather request: %w", err)
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("openweather: unexpected status %d", resp.StatusCode)
	}
	var out owResponse
	if err := json.NewDecoder(resp.Body).Decode(&out); err != nil {
		return nil, fmt.Errorf("openweather decode: %w", err)
	}
	return &out, nil
}
