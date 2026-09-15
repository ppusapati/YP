package providers

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"p9e.in/samavaya/agriculture/weather-service/internal/domain"
)

func TestOpenMeteo_FetchHourly(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Query().Get("latitude") != "18.50000" {
			t.Errorf("unexpected latitude %s", r.URL.Query().Get("latitude"))
		}
		if r.URL.Query().Get("wind_speed_unit") != "ms" {
			t.Error("expected wind_speed_unit=ms")
		}
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{
			"timezone":"UTC",
			"hourly":{
				"time":["2025-03-10T00:00","2025-03-10T01:00","2025-03-11T05:00"],
				"temperature_2m":[20.1,19.5,22.0],
				"relative_humidity_2m":[60,62,55],
				"precipitation":[0,0.4,0],
				"wind_speed_10m":[2.1,2.3,3.0],
				"wind_direction_10m":[180,190,200],
				"surface_pressure":[1010,1011,1009],
				"shortwave_radiation":[0,0,120],
				"cloud_cover":[10,20,5],
				"dew_point_2m":[12,12.1,11],
				"soil_temperature_0cm":[18,17.9,19],
				"soil_moisture_0_to_1cm":[0.21,0.22,0.2]
			}}`))
	}))
	defer srv.Close()

	p := NewOpenMeteo(srv.Client(), srv.URL, srv.URL)
	loc := domain.FieldLocation{TenantID: "t1", FieldID: "f1", Latitude: 18.5, Longitude: 73.8}
	start := time.Date(2025, 3, 10, 0, 0, 0, 0, time.UTC)
	end := time.Date(2025, 3, 10, 23, 0, 0, 0, time.UTC)

	obs, err := p.FetchHourly(context.Background(), loc, start, end)
	if err != nil {
		t.Fatal(err)
	}
	if len(obs) != 2 {
		t.Fatalf("expected 2 observations within range, got %d", len(obs))
	}
	if obs[1].PrecipitationMM != 0.4 || obs[1].TemperatureC != 19.5 {
		t.Errorf("unexpected mapping: %+v", obs[1])
	}
	if obs[0].Provider != domain.ProviderOpenMeteo || obs[0].FieldID != "f1" || obs[0].TenantID != "t1" {
		t.Error("provider/field/tenant not stamped")
	}
}

func TestOpenMeteo_FetchDailyForecast(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Query().Get("forecast_days") != "3" {
			t.Errorf("expected forecast_days=3, got %s", r.URL.Query().Get("forecast_days"))
		}
		_, _ = w.Write([]byte(`{"daily":{
			"time":["2025-03-10","2025-03-11","2025-03-12"],
			"temperature_2m_max":[30,-1,36],
			"temperature_2m_min":[18,-4,24],
			"temperature_2m_mean":[24,-2,30],
			"precipitation_sum":[0,5,80],
			"precipitation_probability_max":[5,60,95],
			"wind_speed_10m_max":[4,6,16],
			"shortwave_radiation_sum":[22,10,18],
			"et0_fao_evapotranspiration":[5.1,0.8,6.2],
			"weather_code":[0,71,95],
			"relative_humidity_2m_mean":[50,80,70]
		}}`))
	}))
	defer srv.Close()

	p := NewOpenMeteo(srv.Client(), srv.URL, srv.URL)
	fc, err := p.FetchDailyForecast(context.Background(), domain.FieldLocation{FieldID: "f1"}, 3)
	if err != nil {
		t.Fatal(err)
	}
	if len(fc) != 3 {
		t.Fatalf("expected 3 days, got %d", len(fc))
	}
	if fc[0].Condition != "clear" || fc[1].Condition != "snow" || fc[2].Condition != "thunderstorm" {
		t.Errorf("condition mapping wrong: %s %s %s", fc[0].Condition, fc[1].Condition, fc[2].Condition)
	}
	if fc[2].ET0MM != 6.2 || fc[2].PrecipitationMM != 80 {
		t.Errorf("unexpected day 3: %+v", fc[2])
	}
}

func TestOpenMeteo_FetchHistoricalDaily_ComputesET0WhenMissing(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Query().Get("start_date") != "2020-01-01" {
			t.Errorf("unexpected start_date %s", r.URL.Query().Get("start_date"))
		}
		_, _ = w.Write([]byte(`{"daily":{
			"time":["2020-01-01","2020-01-02"],
			"temperature_2m_max":[28,30],
			"temperature_2m_min":[15,16],
			"temperature_2m_mean":[21,23],
			"precipitation_sum":[0,12],
			"shortwave_radiation_sum":[18,20],
			"et0_fao_evapotranspiration":[0,4.5],
			"relative_humidity_2m_mean":[55,60],
			"wind_speed_10m_mean":[2.5,3]
		}}`))
	}))
	defer srv.Close()

	p := NewOpenMeteo(srv.Client(), srv.URL, srv.URL)
	loc := domain.FieldLocation{FieldID: "f1", Latitude: 18.5, ElevationM: 500}
	rows, err := p.FetchHistoricalDaily(context.Background(),
		loc,
		time.Date(2020, 1, 1, 0, 0, 0, 0, time.UTC),
		time.Date(2020, 1, 2, 0, 0, 0, 0, time.UTC))
	if err != nil {
		t.Fatal(err)
	}
	if len(rows) != 2 {
		t.Fatalf("expected 2 rows, got %d", len(rows))
	}
	if rows[0].ET0MM <= 0 {
		t.Error("ET0 should be computed locally when provider returns 0")
	}
	if rows[1].ET0MM != 4.5 {
		t.Errorf("provider ET0 should be used when present, got %v", rows[1].ET0MM)
	}
	if rows[0].GDD != 11.5 {
		t.Errorf("GDD = %v, want 11.5", rows[0].GDD)
	}
	if rows[1].RainfallDeficitMM != 0 {
		t.Errorf("deficit should be 0 when rain exceeds ET0, got %v", rows[1].RainfallDeficitMM)
	}
}

func TestOpenMeteo_ErrorResponse(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusBadRequest)
		_, _ = w.Write([]byte(`{"error":true,"reason":"bad latitude"}`))
	}))
	defer srv.Close()

	p := NewOpenMeteo(srv.Client(), srv.URL, srv.URL)
	if _, err := p.FetchDailyForecast(context.Background(), domain.FieldLocation{}, 7); err == nil {
		t.Error("expected error on 400")
	}
}

func TestOpenWeather_FetchDailyForecast(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Query().Get("appid") != "key123" {
			t.Error("expected appid to be passed")
		}
		if r.URL.Query().Get("units") != "metric" {
			t.Error("expected metric units")
		}
		_, _ = w.Write([]byte(`{"daily":[
			{"dt":1741564800,"humidity":60,"wind_speed":5,"pop":0.2,"rain":1.5,"temp":{"min":18,"max":30,"day":25},"weather":[{"main":"Clouds"}]},
			{"dt":1741651200,"humidity":70,"wind_speed":8,"pop":0.9,"rain":40,"temp":{"min":20,"max":28,"day":24},"weather":[{"main":"Rain"}]}
		]}`))
	}))
	defer srv.Close()

	p := NewOpenWeather(srv.Client(), srv.URL, "key123")
	fc, err := p.FetchDailyForecast(context.Background(), domain.FieldLocation{FieldID: "f1"}, 7)
	if err != nil {
		t.Fatal(err)
	}
	if len(fc) != 2 {
		t.Fatalf("expected 2 days, got %d", len(fc))
	}
	if fc[1].PrecipitationProb != 90 || fc[1].Condition != "Rain" || fc[1].PrecipitationMM != 40 {
		t.Errorf("unexpected mapping: %+v", fc[1])
	}
}

func TestOpenWeather_RequiresAPIKey(t *testing.T) {
	p := NewOpenWeather(nil, "http://127.0.0.1:1", "")
	if _, err := p.FetchDailyForecast(context.Background(), domain.FieldLocation{}, 7); err == nil {
		t.Error("expected error without API key")
	}
}

func TestOpenWeather_HistoricalUnsupported(t *testing.T) {
	p := NewOpenWeather(nil, "", "k")
	if _, err := p.FetchHistoricalDaily(context.Background(), domain.FieldLocation{}, time.Now(), time.Now()); err == nil {
		t.Error("expected unsupported error")
	}
}

func TestRegistry(t *testing.T) {
	om := NewOpenMeteo(nil, "", "")
	ow := NewOpenWeather(nil, "", "k")
	r := NewRegistry(om, ow)

	if r.Default() != domain.ProviderOpenMeteo {
		t.Errorf("default should be first provider, got %s", r.Default())
	}
	p, err := r.For(domain.FieldLocation{Provider: domain.ProviderOpenWeather})
	if err != nil || p.Name() != domain.ProviderOpenWeather {
		t.Error("should resolve explicit provider")
	}
	p, err = r.For(domain.FieldLocation{Provider: domain.ProviderIMD})
	if err != nil || p.Name() != domain.ProviderOpenMeteo {
		t.Error("unknown provider should fall back to default")
	}
	if _, err := NewRegistry().For(domain.FieldLocation{}); err == nil {
		t.Error("empty registry should error")
	}
}

func TestWMOCondition(t *testing.T) {
	cases := map[int]string{0: "clear", 2: "partly_cloudy", 45: "fog", 51: "drizzle", 61: "rain", 75: "snow", 80: "rain_showers", 85: "snow_showers", 99: "thunderstorm", 150: "unknown"}
	for code, want := range cases {
		if got := wmoCondition(code); got != want {
			t.Errorf("wmoCondition(%d) = %s, want %s", code, got, want)
		}
	}
}
