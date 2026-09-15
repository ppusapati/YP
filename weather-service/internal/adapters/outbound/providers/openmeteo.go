// Package providers contains upstream weather API adapters.
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

const (
	openMeteoForecastURL = "https://api.open-meteo.com/v1/forecast"
	openMeteoArchiveURL  = "https://archive-api.open-meteo.com/v1/archive"
)

// OpenMeteo implements outbound.WeatherProvider against the free Open-Meteo API.
type OpenMeteo struct {
	forecastURL string
	archiveURL  string
	http        *http.Client
}

// NewOpenMeteo creates an Open-Meteo provider. Empty URLs use the public endpoints.
func NewOpenMeteo(httpClient *http.Client, forecastURL, archiveURL string) outbound.WeatherProvider {
	if httpClient == nil {
		httpClient = &http.Client{Timeout: 20 * time.Second}
	}
	if forecastURL == "" {
		forecastURL = openMeteoForecastURL
	}
	if archiveURL == "" {
		archiveURL = openMeteoArchiveURL
	}
	return &OpenMeteo{forecastURL: forecastURL, archiveURL: archiveURL, http: httpClient}
}

func (p *OpenMeteo) Name() domain.Provider { return domain.ProviderOpenMeteo }

type openMeteoHourly struct {
	Time             []string  `json:"time"`
	Temperature2m    []float64 `json:"temperature_2m"`
	RelativeHumidity []float64 `json:"relative_humidity_2m"`
	Precipitation    []float64 `json:"precipitation"`
	WindSpeed10m     []float64 `json:"wind_speed_10m"`
	WindDirection10m []float64 `json:"wind_direction_10m"`
	SurfacePressure  []float64 `json:"surface_pressure"`
	ShortwaveRad     []float64 `json:"shortwave_radiation"`
	CloudCover       []float64 `json:"cloud_cover"`
	DewPoint2m       []float64 `json:"dew_point_2m"`
	SoilTemp0cm      []float64 `json:"soil_temperature_0cm"`
	SoilMoisture     []float64 `json:"soil_moisture_0_to_1cm"`
}

type openMeteoDaily struct {
	Time             []string  `json:"time"`
	TempMax          []float64 `json:"temperature_2m_max"`
	TempMin          []float64 `json:"temperature_2m_min"`
	TempMean         []float64 `json:"temperature_2m_mean"`
	PrecipSum        []float64 `json:"precipitation_sum"`
	PrecipProbMax    []float64 `json:"precipitation_probability_max"`
	WindMax          []float64 `json:"wind_speed_10m_max"`
	ShortwaveRadSum  []float64 `json:"shortwave_radiation_sum"`
	ET0              []float64 `json:"et0_fao_evapotranspiration"`
	WeatherCode      []int     `json:"weather_code"`
	RelHumidityMean  []float64 `json:"relative_humidity_2m_mean"`
	WindSpeed10mMean []float64 `json:"wind_speed_10m_mean"`
}

type openMeteoResponse struct {
	Timezone string          `json:"timezone"`
	Hourly   openMeteoHourly `json:"hourly"`
	Daily    openMeteoDaily  `json:"daily"`
	Error    bool            `json:"error"`
	Reason   string          `json:"reason"`
}

func (p *OpenMeteo) FetchHourly(ctx context.Context, loc domain.FieldLocation, start, end time.Time) ([]domain.Observation, error) {
	q := p.baseQuery(loc)
	q.Set("hourly", "temperature_2m,relative_humidity_2m,precipitation,wind_speed_10m,wind_direction_10m,surface_pressure,shortwave_radiation,cloud_cover,dew_point_2m,soil_temperature_0cm,soil_moisture_0_to_1cm")
	q.Set("start_date", start.UTC().Format("2006-01-02"))
	q.Set("end_date", end.UTC().Format("2006-01-02"))
	q.Set("wind_speed_unit", "ms")
	q.Set("timezone", "UTC")

	var resp openMeteoResponse
	if err := p.get(ctx, p.forecastURL, q, &resp); err != nil {
		return nil, err
	}

	h := resp.Hourly
	out := make([]domain.Observation, 0, len(h.Time))
	for i, ts := range h.Time {
		at, err := time.Parse("2006-01-02T15:04", ts)
		if err != nil {
			continue
		}
		at = at.UTC()
		if at.Before(start) || at.After(end) {
			continue
		}
		out = append(out, domain.Observation{
			TenantID:          loc.TenantID,
			FieldID:           loc.FieldID,
			ObservedAt:        at,
			TemperatureC:      at_(h.Temperature2m, i),
			HumidityPct:       at_(h.RelativeHumidity, i),
			PrecipitationMM:   at_(h.Precipitation, i),
			WindSpeedMS:       at_(h.WindSpeed10m, i),
			WindDirectionDeg:  at_(h.WindDirection10m, i),
			PressureHPa:       at_(h.SurfacePressure, i),
			SolarRadiationWM2: at_(h.ShortwaveRad, i),
			CloudCoverPct:     at_(h.CloudCover, i),
			DewPointC:         at_(h.DewPoint2m, i),
			SoilTemperatureC:  at_(h.SoilTemp0cm, i),
			SoilMoistureM3M3:  at_(h.SoilMoisture, i),
			Provider:          domain.ProviderOpenMeteo,
		})
	}
	return out, nil
}

func (p *OpenMeteo) FetchDailyForecast(ctx context.Context, loc domain.FieldLocation, days int) ([]domain.DailyForecast, error) {
	if days <= 0 {
		days = 7
	}
	if days > 16 {
		days = 16
	}
	q := p.baseQuery(loc)
	q.Set("daily", "temperature_2m_max,temperature_2m_min,temperature_2m_mean,precipitation_sum,precipitation_probability_max,wind_speed_10m_max,shortwave_radiation_sum,et0_fao_evapotranspiration,weather_code,relative_humidity_2m_mean")
	q.Set("forecast_days", strconv.Itoa(days))
	q.Set("wind_speed_unit", "ms")
	q.Set("timezone", "UTC")

	var resp openMeteoResponse
	if err := p.get(ctx, p.forecastURL, q, &resp); err != nil {
		return nil, err
	}

	issued := time.Now().UTC()
	d := resp.Daily
	out := make([]domain.DailyForecast, 0, len(d.Time))
	for i, ts := range d.Time {
		day, err := time.Parse("2006-01-02", ts)
		if err != nil {
			continue
		}
		out = append(out, domain.DailyForecast{
			TenantID:          loc.TenantID,
			FieldID:           loc.FieldID,
			ForecastDate:      day.UTC(),
			IssuedAt:          issued,
			TemperatureMinC:   at_(d.TempMin, i),
			TemperatureMaxC:   at_(d.TempMax, i),
			TemperatureMeanC:  at_(d.TempMean, i),
			PrecipitationMM:   at_(d.PrecipSum, i),
			PrecipitationProb: at_(d.PrecipProbMax, i),
			HumidityMeanPct:   at_(d.RelHumidityMean, i),
			WindSpeedMaxMS:    at_(d.WindMax, i),
			SolarRadiationMJ:  at_(d.ShortwaveRadSum, i),
			ET0MM:             at_(d.ET0, i),
			Condition:         wmoCondition(atInt(d.WeatherCode, i)),
			Provider:          domain.ProviderOpenMeteo,
		})
	}
	return out, nil
}

func (p *OpenMeteo) FetchHistoricalDaily(ctx context.Context, loc domain.FieldLocation, start, end time.Time) ([]domain.DailyAgroMetrics, error) {
	q := p.baseQuery(loc)
	q.Set("daily", "temperature_2m_max,temperature_2m_min,temperature_2m_mean,precipitation_sum,wind_speed_10m_max,shortwave_radiation_sum,et0_fao_evapotranspiration,relative_humidity_2m_mean,wind_speed_10m_mean")
	q.Set("start_date", start.UTC().Format("2006-01-02"))
	q.Set("end_date", end.UTC().Format("2006-01-02"))
	q.Set("wind_speed_unit", "ms")
	q.Set("timezone", "UTC")

	var resp openMeteoResponse
	if err := p.get(ctx, p.archiveURL, q, &resp); err != nil {
		return nil, err
	}

	d := resp.Daily
	out := make([]domain.DailyAgroMetrics, 0, len(d.Time))
	for i, ts := range d.Time {
		day, err := time.Parse("2006-01-02", ts)
		if err != nil {
			continue
		}
		tmin, tmax := at_(d.TempMin, i), at_(d.TempMax, i)
		precip := at_(d.PrecipSum, i)
		et0 := at_(d.ET0, i)
		if et0 == 0 {
			et0 = domain.ReferenceET0(domain.ET0Inputs{
				TminC: tmin, TmaxC: tmax, RHMeanPct: at_(d.RelHumidityMean, i),
				WindSpeed2mMS:    domain.Wind10mTo2m(at_(d.WindSpeed10mMean, i)),
				SolarRadiationMJ: at_(d.ShortwaveRadSum, i), ElevationM: loc.ElevationM,
				LatitudeDeg: loc.Latitude, DayOfYear: day.YearDay(),
			})
		}
		out = append(out, domain.DailyAgroMetrics{
			TenantID:          loc.TenantID,
			FieldID:           loc.FieldID,
			Date:              day.UTC(),
			TemperatureMinC:   tmin,
			TemperatureMaxC:   tmax,
			TemperatureMeanC:  at_(d.TempMean, i),
			PrecipitationMM:   precip,
			HumidityMeanPct:   at_(d.RelHumidityMean, i),
			WindSpeedMeanMS:   at_(d.WindSpeed10mMean, i),
			SolarRadiationMJ:  at_(d.ShortwaveRadSum, i),
			GDD:               domain.GrowingDegreeDays(tmin, tmax, domain.DefaultGDDBaseC, domain.DefaultGDDCapC),
			ET0MM:             et0,
			RainfallDeficitMM: domain.RainfallDeficit(et0, precip),
		})
	}
	return out, nil
}

func (p *OpenMeteo) baseQuery(loc domain.FieldLocation) url.Values {
	q := url.Values{}
	q.Set("latitude", strconv.FormatFloat(loc.Latitude, 'f', 5, 64))
	q.Set("longitude", strconv.FormatFloat(loc.Longitude, 'f', 5, 64))
	if loc.ElevationM != 0 {
		q.Set("elevation", strconv.FormatFloat(loc.ElevationM, 'f', 1, 64))
	}
	return q
}

func (p *OpenMeteo) get(ctx context.Context, base string, q url.Values, out *openMeteoResponse) error {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, base+"?"+q.Encode(), nil)
	if err != nil {
		return err
	}
	resp, err := p.http.Do(req)
	if err != nil {
		return fmt.Errorf("open-meteo request: %w", err)
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("open-meteo: unexpected status %d", resp.StatusCode)
	}
	if err := json.NewDecoder(resp.Body).Decode(out); err != nil {
		return fmt.Errorf("open-meteo decode: %w", err)
	}
	if out.Error {
		return fmt.Errorf("open-meteo: %s", out.Reason)
	}
	return nil
}

func at_(xs []float64, i int) float64 {
	if i < len(xs) {
		return xs[i]
	}
	return 0
}

func atInt(xs []int, i int) int {
	if i < len(xs) {
		return xs[i]
	}
	return 0
}

// wmoCondition maps WMO 4677 weather interpretation codes to short labels.
func wmoCondition(code int) string {
	switch {
	case code == 0:
		return "clear"
	case code <= 3:
		return "partly_cloudy"
	case code <= 48:
		return "fog"
	case code <= 57:
		return "drizzle"
	case code <= 67:
		return "rain"
	case code <= 77:
		return "snow"
	case code <= 82:
		return "rain_showers"
	case code <= 86:
		return "snow_showers"
	case code <= 99:
		return "thunderstorm"
	default:
		return "unknown"
	}
}
