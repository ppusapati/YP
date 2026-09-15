// Package domain contains the pure domain model for the weather-service.
package domain

import "time"

// Provider identifies the upstream weather data source.
type Provider string

const (
	ProviderUnspecified Provider = ""
	ProviderOpenMeteo   Provider = "OPEN_METEO"
	ProviderOpenWeather Provider = "OPENWEATHER"
	ProviderIMD         Provider = "IMD"
)

// AlertType classifies a weather-triggered alert.
type AlertType string

const (
	AlertTypeFrost         AlertType = "FROST"
	AlertTypeHeatStress    AlertType = "HEAT_STRESS"
	AlertTypeHeavyRainfall AlertType = "HEAVY_RAINFALL"
	AlertTypeHighWind      AlertType = "HIGH_WIND"
	AlertTypeDrought       AlertType = "DROUGHT"
)

// Severity is the alert severity level.
type Severity string

const (
	SeverityInfo     Severity = "INFO"
	SeverityWarning  Severity = "WARNING"
	SeverityCritical Severity = "CRITICAL"
)

// FieldLocation is the point at which weather is sampled for a field.
type FieldLocation struct {
	ID           string     `json:"id"`
	TenantID     string     `json:"tenant_id"`
	FieldID      string     `json:"field_id"`
	FarmID       string     `json:"farm_id"`
	Latitude     float64    `json:"latitude"`
	Longitude    float64    `json:"longitude"`
	ElevationM   float64    `json:"elevation_m"`
	Timezone     string     `json:"timezone"`
	Provider     Provider   `json:"provider"`
	LastPolledAt *time.Time `json:"last_polled_at,omitempty"`
	CreatedBy    string     `json:"created_by"`
	CreatedAt    time.Time  `json:"created_at"`
	UpdatedAt    time.Time  `json:"updated_at"`
}

// Observation is one hourly weather reading at a field location.
type Observation struct {
	ID                string    `json:"id"`
	TenantID          string    `json:"tenant_id"`
	FieldID           string    `json:"field_id"`
	ObservedAt        time.Time `json:"observed_at"`
	TemperatureC      float64   `json:"temperature_c"`
	HumidityPct       float64   `json:"humidity_pct"`
	PrecipitationMM   float64   `json:"precipitation_mm"`
	WindSpeedMS       float64   `json:"wind_speed_ms"`
	WindDirectionDeg  float64   `json:"wind_direction_deg"`
	PressureHPa       float64   `json:"pressure_hpa"`
	SolarRadiationWM2 float64   `json:"solar_radiation_wm2"`
	CloudCoverPct     float64   `json:"cloud_cover_pct"`
	DewPointC         float64   `json:"dew_point_c"`
	SoilTemperatureC  float64   `json:"soil_temperature_c"`
	SoilMoistureM3M3  float64   `json:"soil_moisture_m3m3"`
	Provider          Provider  `json:"provider"`
}

// DailyForecast is one forecast day for a field location.
type DailyForecast struct {
	ID                string    `json:"id"`
	TenantID          string    `json:"tenant_id"`
	FieldID           string    `json:"field_id"`
	ForecastDate      time.Time `json:"forecast_date"`
	IssuedAt          time.Time `json:"issued_at"`
	TemperatureMinC   float64   `json:"temperature_min_c"`
	TemperatureMaxC   float64   `json:"temperature_max_c"`
	TemperatureMeanC  float64   `json:"temperature_mean_c"`
	PrecipitationMM   float64   `json:"precipitation_mm"`
	PrecipitationProb float64   `json:"precipitation_prob"`
	HumidityMeanPct   float64   `json:"humidity_mean_pct"`
	WindSpeedMaxMS    float64   `json:"wind_speed_max_ms"`
	SolarRadiationMJ  float64   `json:"solar_radiation_mj"`
	ET0MM             float64   `json:"et0_mm"`
	Condition         string    `json:"condition"`
	Provider          Provider  `json:"provider"`
}

// DailyAgroMetrics is the derived per-day agronomic record.
type DailyAgroMetrics struct {
	TenantID          string    `json:"tenant_id"`
	FieldID           string    `json:"field_id"`
	Date              time.Time `json:"date"`
	TemperatureMinC   float64   `json:"temperature_min_c"`
	TemperatureMaxC   float64   `json:"temperature_max_c"`
	TemperatureMeanC  float64   `json:"temperature_mean_c"`
	PrecipitationMM   float64   `json:"precipitation_mm"`
	HumidityMeanPct   float64   `json:"humidity_mean_pct"`
	WindSpeedMeanMS   float64   `json:"wind_speed_mean_ms"`
	SolarRadiationMJ  float64   `json:"solar_radiation_mj"`
	GDD               float64   `json:"gdd"`
	ET0MM             float64   `json:"et0_mm"`
	ChillHours        float64   `json:"chill_hours"`
	RainfallDeficitMM float64   `json:"rainfall_deficit_mm"`
	ObservationCount  int       `json:"observation_count"`
}

// AgroMetricsSummary aggregates DailyAgroMetrics across a date range.
type AgroMetricsSummary struct {
	CumulativeGDD             float64 `json:"cumulative_gdd"`
	CumulativeET0MM           float64 `json:"cumulative_et0_mm"`
	CumulativePrecipitationMM float64 `json:"cumulative_precipitation_mm"`
	CumulativeChillHours      float64 `json:"cumulative_chill_hours"`
	CumulativeDeficitMM       float64 `json:"cumulative_deficit_mm"`
	Days                      int     `json:"days"`
	FrostDays                 int     `json:"frost_days"`
	HeatStressDays            int     `json:"heat_stress_days"`
}

// WeatherAlert is a weather-condition alert raised for a field.
type WeatherAlert struct {
	ID        string    `json:"id"`
	TenantID  string    `json:"tenant_id"`
	FieldID   string    `json:"field_id"`
	Type      AlertType `json:"type"`
	Severity  Severity  `json:"severity"`
	Message   string    `json:"message"`
	Value     float64   `json:"value"`
	Threshold float64   `json:"threshold"`
	ValidFrom time.Time `json:"valid_from"`
	ValidTo   time.Time `json:"valid_to"`
	CreatedAt time.Time `json:"created_at"`
}

// ListObservationsParams filters observation listings.
type ListObservationsParams struct {
	TenantID   string
	FieldID    string
	Start      time.Time
	End        time.Time
	PageSize   int32
	PageOffset int32
}

// ListAlertsParams filters alert listings.
type ListAlertsParams struct {
	TenantID   string
	FieldID    string
	ActiveOnly bool
	Now        time.Time
	PageSize   int32
	PageOffset int32
}

// ListLocationsParams filters field location listings.
type ListLocationsParams struct {
	TenantID   string
	FarmID     string
	PageSize   int32
	PageOffset int32
}
