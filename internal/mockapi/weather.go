package mockapi

import (
	"math"
	"net/http"
	"strconv"
	"strings"
	"time"
)

// Open-Meteo and OpenWeather stand-ins.
//
// Both emit only the variables the request asked for, exactly as the real APIs
// do. That matters: if a service asks for a variable it never reads, or reads
// one it forgot to ask for, a mock that returned everything regardless would
// hide it, and the bug would surface the first time the code met the real API.

const maxDays = 400 // a guard against a request for a century of hourly data

type weatherHandlers struct {
	faults  *faultStore
	now     func() time.Time
	omitET0 bool
}

// ── Open-Meteo ──────────────────────────────────────────────────────────────

// handleOpenMeteoForecast serves /v1/forecast.
func (h *weatherHandlers) handleOpenMeteoForecast(w http.ResponseWriter, r *http.Request) {
	h.openMeteo(w, r, false)
}

// handleOpenMeteoArchive serves /v1/archive. The archive API has no
// forecast_days and requires an explicit range, which is the one behavioural
// difference worth preserving.
func (h *weatherHandlers) handleOpenMeteoArchive(w http.ResponseWriter, r *http.Request) {
	h.openMeteo(w, r, true)
}

func (h *weatherHandlers) openMeteo(w http.ResponseWriter, r *http.Request, archive bool) {
	if h.faults.apply(w, "openmeteo") {
		return
	}

	q := r.URL.Query()
	lat, latOK := parseFloat(q.Get("latitude"))
	lon, lonOK := parseFloat(q.Get("longitude"))
	if !latOK || !lonOK {
		// The real API answers a missing coordinate with 400 and this body
		// shape, and the client checks the `error` flag, not just the status.
		writeJSON(w, http.StatusBadRequest, map[string]any{
			"error":  true,
			"reason": "Value for parameter 'latitude' and 'longitude' is required.",
		})
		return
	}
	elev, _ := parseFloat(q.Get("elevation"))

	start, end, err := h.window(q, archive)
	if err != "" {
		writeJSON(w, http.StatusBadRequest, map[string]any{"error": true, "reason": err})
		return
	}

	out := map[string]any{
		"latitude":              lat,
		"longitude":             lon,
		"timezone":              orDefault(q.Get("timezone"), "GMT"),
		"timezone_abbreviation": "GMT",
		"elevation":             elev,
		"utc_offset_seconds":    0,
	}

	if vars := splitVars(q.Get("hourly")); len(vars) > 0 {
		out["hourly"] = h.openMeteoHourly(lat, lon, start, end, vars)
		out["hourly_units"] = unitsFor(vars, openMeteoHourlyUnits)
	}
	if vars := splitVars(q.Get("daily")); len(vars) > 0 {
		out["daily"] = h.openMeteoDaily(lat, lon, elev, start, end, vars, !h.omitET0)
		out["daily_units"] = unitsFor(vars, openMeteoDailyUnits)
	}

	writeJSON(w, http.StatusOK, out)
}

// window resolves the requested period. forecast_days is relative to today and
// is what FetchDailyForecast uses; start_date/end_date is what the hourly and
// archive calls use.
func (h *weatherHandlers) window(q urlValues, archive bool) (time.Time, time.Time, string) {
	today := h.now().UTC().Truncate(24 * time.Hour)

	sd, ed := q.Get("start_date"), q.Get("end_date")
	if sd != "" || ed != "" {
		start, err1 := time.Parse("2006-01-02", sd)
		end, err2 := time.Parse("2006-01-02", ed)
		if err1 != nil || err2 != nil {
			return time.Time{}, time.Time{}, "Invalid date format, expected yyyy-mm-dd."
		}
		if end.Before(start) {
			return time.Time{}, time.Time{}, "Parameter 'end_date' is before 'start_date'."
		}
		if end.Sub(start) > maxDays*24*time.Hour {
			return time.Time{}, time.Time{}, "Requested range is too long."
		}
		return start.UTC(), end.UTC(), ""
	}

	if archive {
		return time.Time{}, time.Time{}, "Parameter 'start_date' and 'end_date' are required."
	}

	days := 7
	if n, err := strconv.Atoi(q.Get("forecast_days")); err == nil && n > 0 {
		days = n
	}
	if days > 16 {
		days = 16 // the real forecast API's ceiling
	}
	return today, today.AddDate(0, 0, days-1), ""
}

func (h *weatherHandlers) openMeteoHourly(lat, lon float64, start, end time.Time, vars []string) map[string]any {
	cols := newColumns(vars)
	var times []string

	for day := start; !day.After(end); day = day.AddDate(0, 0, 1) {
		c := dayClimate(lat, lon, day)
		for hour := 0; hour < 24; hour++ {
			at := day.Add(time.Duration(hour) * time.Hour)
			// Open-Meteo's hourly timestamps have no seconds and no zone
			// suffix. The client parses with exactly this layout, so a
			// friendlier format here would simply be dropped on the floor.
			times = append(times, at.Format("2006-01-02T15:04"))

			temp := c.tempAt(hour)
			rh := c.humidityAt(hour)
			// A day's rain falls over a few hours, not evenly across 24 — an
			// even spread would make every hour marginally wet and never
			// produce the intense hour a drainage or spray-window rule is
			// meant to react to.
			var precip float64
			if c.rainMM > 0 {
				peak := int(unit(spot(lat, lon)+day.Format("|2006-01-02|peak")) * 24)
				switch d := abs(hour - peak); d {
				case 0:
					precip = round1(c.rainMM * 0.5)
				case 1:
					precip = round1(c.rainMM * 0.2)
				case 2:
					precip = round1(c.rainMM * 0.05)
				}
			}

			cols.put("temperature_2m", temp)
			cols.put("relative_humidity_2m", rh)
			cols.put("precipitation", precip)
			cols.put("rain", precip)
			cols.put("wind_speed_10m", round1(c.windMS*(0.7+0.6*math.Abs(math.Sin(float64(hour)/24*math.Pi)))))
			cols.put("wind_direction_10m", c.windDeg)
			cols.put("surface_pressure", c.pressHPa)
			cols.put("shortwave_radiation", c.solarAt(hour))
			cols.put("cloud_cover", c.cloudPct)
			cols.put("dew_point_2m", dewPointC(temp, rh))
			// Soil lags the air: warmest in the late afternoon, and damped.
			cols.put("soil_temperature_0cm", round1(c.meanC+(c.rangeC/3)*math.Cos(2*math.Pi*(float64(hour)-16)/24)))
			cols.put("soil_moisture_0_to_1cm", round2(clamp(0.18+c.rainMM*0.01-float64(24-hour)*0.001, 0.02, 0.48)))
			cols.put("et0_fao_evapotranspiration", round2(c.solarAt(hour)/1e6*3600*0.35))
		}
	}

	out := cols.result()
	out["time"] = times
	return out
}

func (h *weatherHandlers) openMeteoDaily(lat, lon, elev float64, start, end time.Time, vars []string, withET0 bool) map[string]any {
	cols := newColumns(vars)
	var times []string

	for day := start; !day.After(end); day = day.AddDate(0, 0, 1) {
		c := dayClimate(lat, lon, day)
		times = append(times, day.Format("2006-01-02"))

		cols.put("temperature_2m_max", c.maxC())
		cols.put("temperature_2m_min", c.minC())
		cols.put("temperature_2m_mean", c.meanC)
		cols.put("precipitation_sum", c.rainMM)
		cols.put("rain_sum", c.rainMM)
		cols.put("precipitation_hours", math.Round(boolTo(c.rainMM > 0)*3))
		// Probability and amount have to agree. A forecast showing 40 mm at a
		// 5% chance is the kind of thing a mock can emit and a real API cannot.
		cols.put("precipitation_probability_max", math.Round(clamp(c.rainMM*8+boolTo(c.isMonsoon)*25, 0, 100)))
		cols.put("wind_speed_10m_max", round1(c.windMS*1.6))
		cols.put("wind_speed_10m_mean", c.windMS)
		cols.put("wind_direction_10m_dominant", c.windDeg)
		cols.put("shortwave_radiation_sum", c.solarMJ)
		cols.put("relative_humidity_2m_mean", c.humidPct)
		cols.put("cloud_cover_mean", c.cloudPct)
		cols.putInt("weather_code", wmoCode(c))

		// Returning zero for ET0 is not a broken response — it is what the real
		// API does outside its supported range, and the service is supposed to
		// notice and recompute. Options.OmitET0 is how that branch gets tested.
		if withET0 {
			cols.put("et0_fao_evapotranspiration", et0MM(c, elev))
		} else {
			cols.put("et0_fao_evapotranspiration", 0)
		}
	}

	out := cols.result()
	out["time"] = times
	return out
}

// ── OpenWeather One Call 3.0 ────────────────────────────────────────────────

// handleOpenWeather serves /data/3.0/onecall.
func (h *weatherHandlers) handleOpenWeather(w http.ResponseWriter, r *http.Request) {
	if h.faults.apply(w, "openweather") {
		return
	}

	q := r.URL.Query()
	if q.Get("appid") == "" {
		// The real API's shape for this, which the client surfaces verbatim.
		writeJSON(w, http.StatusUnauthorized, map[string]any{
			"cod":     401,
			"message": "Invalid API key. Please see https://openweathermap.org/faq#error401 for more info.",
		})
		return
	}
	lat, latOK := parseFloat(q.Get("lat"))
	lon, lonOK := parseFloat(q.Get("lon"))
	if !latOK || !lonOK {
		writeJSON(w, http.StatusBadRequest, map[string]any{
			"cod":     "400",
			"message": "wrong latitude",
		})
		return
	}

	excluded := map[string]bool{}
	for _, part := range splitVars(q.Get("exclude")) {
		excluded[part] = true
	}

	now := h.now().UTC()
	out := map[string]any{
		"lat":             lat,
		"lon":             lon,
		"timezone":        "Etc/GMT",
		"timezone_offset": 0,
	}

	if !excluded["hourly"] {
		// One Call returns 48 hours from the current hour.
		hourly := make([]map[string]any, 0, 48)
		base := now.Truncate(time.Hour)
		for i := 0; i < 48; i++ {
			at := base.Add(time.Duration(i) * time.Hour)
			day := at.Truncate(24 * time.Hour)
			c := dayClimate(lat, lon, day)
			hour := at.Hour()
			temp := c.tempAt(hour)
			rh := c.humidityAt(hour)

			entry := map[string]any{
				"dt":         at.Unix(),
				"temp":       temp,
				"feels_like": round1(temp + (rh-60)/100*1.5),
				"pressure":   math.Round(c.pressHPa),
				"humidity":   rh,
				"dew_point":  dewPointC(temp, rh),
				"clouds":     c.cloudPct,
				"visibility": 10000,
				"wind_speed": round1(c.windMS),
				"wind_deg":   c.windDeg,
				"uvi":        round1(c.solarAt(hour) / 100),
				"pop":        round2(clamp(c.rainMM*0.08, 0, 1)),
			}
			main, desc := owCondition(c)
			entry["weather"] = []map[string]any{{
				"id": 500, "main": main, "description": desc, "icon": "10d",
			}}
			// Hourly rain is a nested object keyed "1h"; daily rain is a bare
			// number. That inconsistency is OpenWeather's, and reproducing it
			// is the point — a client that assumes one shape for both breaks
			// on exactly this.
			if c.rainMM > 0 {
				entry["rain"] = map[string]float64{"1h": round1(c.rainMM / 6)}
			}
			hourly = append(hourly, entry)
		}
		out["hourly"] = hourly
	}

	if !excluded["daily"] {
		daily := make([]map[string]any, 0, 8)
		today := now.Truncate(24 * time.Hour)
		for i := 0; i < 8; i++ {
			day := today.AddDate(0, 0, i)
			c := dayClimate(lat, lon, day)
			main, desc := owCondition(c)

			entry := map[string]any{
				"dt":         day.Add(12 * time.Hour).Unix(),
				"sunrise":    day.Add(time.Duration((12-daylightHours(lat, c.dayOfYear)/2)*3600) * time.Second).Unix(),
				"sunset":     day.Add(time.Duration((12+daylightHours(lat, c.dayOfYear)/2)*3600) * time.Second).Unix(),
				"pressure":   math.Round(c.pressHPa),
				"humidity":   c.humidPct,
				"dew_point":  dewPointC(c.meanC, c.humidPct),
				"clouds":     c.cloudPct,
				"wind_speed": round1(c.windMS * 1.6),
				"wind_deg":   c.windDeg,
				"pop":        round2(clamp(c.rainMM*0.08, 0, 1)),
				"uvi":        round1(c.solarMJ / 2),
				"temp": map[string]float64{
					"min": c.minC(), "max": c.maxC(), "day": c.meanC,
					"night": round1(c.minC() + 1), "eve": round1(c.meanC + 1), "morn": round1(c.minC() + 2),
				},
				"weather": []map[string]any{{
					"id": 500, "main": main, "description": desc, "icon": "10d",
				}},
			}
			if c.rainMM > 0 {
				entry["rain"] = c.rainMM
			}
			daily = append(daily, entry)
		}
		out["daily"] = daily
	}

	writeJSON(w, http.StatusOK, out)
}

// ── column helpers ──────────────────────────────────────────────────────────

// columns accumulates Open-Meteo's column-oriented arrays, keeping only the
// variables the request named.
type columns struct {
	want   map[string]bool
	floats map[string][]float64
	ints   map[string][]int
	order  []string
}

func newColumns(vars []string) *columns {
	want := make(map[string]bool, len(vars))
	for _, v := range vars {
		want[v] = true
	}
	return &columns{
		want:   want,
		floats: map[string][]float64{},
		ints:   map[string][]int{},
		order:  vars,
	}
}

func (c *columns) put(name string, v float64) {
	if c.want[name] {
		c.floats[name] = append(c.floats[name], v)
	}
}

func (c *columns) putInt(name string, v int) {
	if c.want[name] {
		c.ints[name] = append(c.ints[name], v)
	}
}

func (c *columns) result() map[string]any {
	out := map[string]any{}
	for _, name := range c.order {
		if vs, ok := c.floats[name]; ok {
			out[name] = vs
		} else if vs, ok := c.ints[name]; ok {
			out[name] = vs
		}
	}
	return out
}

var openMeteoHourlyUnits = map[string]string{
	"temperature_2m": "°C", "relative_humidity_2m": "%", "precipitation": "mm",
	"rain": "mm", "wind_speed_10m": "m/s", "wind_direction_10m": "°",
	"surface_pressure": "hPa", "shortwave_radiation": "W/m²", "cloud_cover": "%",
	"dew_point_2m": "°C", "soil_temperature_0cm": "°C",
	"soil_moisture_0_to_1cm": "m³/m³", "et0_fao_evapotranspiration": "mm",
}

var openMeteoDailyUnits = map[string]string{
	"temperature_2m_max": "°C", "temperature_2m_min": "°C", "temperature_2m_mean": "°C",
	"precipitation_sum": "mm", "rain_sum": "mm", "precipitation_hours": "h",
	"precipitation_probability_max": "%", "wind_speed_10m_max": "m/s",
	"wind_speed_10m_mean": "m/s", "wind_direction_10m_dominant": "°",
	"shortwave_radiation_sum": "MJ/m²", "et0_fao_evapotranspiration": "mm",
	"weather_code": "wmo code", "relative_humidity_2m_mean": "%", "cloud_cover_mean": "%",
}

func unitsFor(vars []string, table map[string]string) map[string]string {
	out := map[string]string{"time": "iso8601"}
	for _, v := range vars {
		if u, ok := table[v]; ok {
			out[v] = u
		}
	}
	return out
}

// urlValues is the subset of url.Values used here, kept as an interface so the
// window logic can be tested without building a whole request.
type urlValues interface{ Get(string) string }

func splitVars(s string) []string {
	if s == "" {
		return nil
	}
	parts := strings.Split(s, ",")
	out := make([]string, 0, len(parts))
	for _, p := range parts {
		if p = strings.TrimSpace(p); p != "" {
			out = append(out, p)
		}
	}
	return out
}

func parseFloat(s string) (float64, bool) {
	if s == "" {
		return 0, false
	}
	v, err := strconv.ParseFloat(s, 64)
	if err != nil {
		return 0, false
	}
	return v, true
}

func orDefault(v, fallback string) string {
	if v == "" {
		return fallback
	}
	return v
}

func abs(i int) int {
	if i < 0 {
		return -i
	}
	return i
}
