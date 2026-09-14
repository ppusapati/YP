package mockapi

import (
	"hash/fnv"
	"math"
	"strconv"
	"time"
)

// Deterministic synthesis of plausible weather.
//
// Two properties matter more than realism here.
//
// The first is determinism. A mock that returns random numbers makes every
// test that depends on it flaky, and a mock that returns one fixed blob never
// exercises the date arithmetic that surrounds a weather call. Everything
// below is derived from (latitude, longitude, timestamp) by hashing, so the
// same request always produces the same answer and a different day produces a
// different one.
//
// The second is plausibility. A mock that returns 500 °C, or humidity of 300%,
// lets through exactly the bugs real data would have caught — a unit mix-up, a
// missing bounds check, a chart that silently rescales. So the numbers follow
// an annual cycle by latitude, a diurnal cycle by hour, humidity that moves
// against temperature, and rainfall concentrated in the monsoon window. It is
// not a forecast. It is a shape that looks enough like weather to be wrong in
// the ways weather is wrong.
//
// The physics here is deliberately re-derived rather than imported from
// weather-service's domain package. If the mock computed ET0 with the same
// code the service does, a bug in that code would produce self-consistent
// output and the test would pass through it.

// unit returns a deterministic value in [0, 1) for a key.
func unit(key string) float64 {
	h := fnv.New64a()
	_, _ = h.Write([]byte(key))
	// The top 53 bits are the ones a float64 can hold exactly.
	return float64(h.Sum64()>>11) / float64(uint64(1)<<53)
}

// spot rounds coordinates to a ~1 km grid so that two requests for the same
// field agree even when the caller's precision wobbles.
func spot(lat, lon float64) string {
	return strconv.FormatFloat(math.Round(lat*100)/100, 'f', 2, 64) + "," +
		strconv.FormatFloat(math.Round(lon*100)/100, 'f', 2, 64)
}

// jitter returns a deterministic value in [-scale, +scale].
func jitter(key string, scale float64) float64 {
	return (unit(key)*2 - 1) * scale
}

// climate describes a day at a location: the shape everything hourly and daily
// is then derived from.
type climate struct {
	meanC     float64 // daily mean temperature
	rangeC    float64 // diurnal swing, max minus min
	rainMM    float64 // total precipitation
	cloudPct  float64 // mean cloud cover
	humidPct  float64 // mean relative humidity
	windMS    float64 // mean wind speed at 10 m
	windDeg   float64 // prevailing direction
	pressHPa  float64 // mean surface pressure
	raMJ      float64 // extraterrestrial radiation, for the radiation budget
	solarMJ   float64 // shortwave radiation reaching the surface
	dayOfYear int
	latitude  float64
	isMonsoon bool
}

// dayClimate synthesises one day at one place.
func dayClimate(lat, lon float64, day time.Time) climate {
	doy := day.YearDay()
	key := spot(lat, lon) + "|" + day.Format("2006-01-02")

	// Annual temperature cycle. The peak sits near the solstice and flips
	// hemisphere with the sign of the latitude; the amplitude grows away from
	// the equator, where there is barely a cycle at all.
	absLat := math.Abs(lat)
	phase := 2 * math.Pi * (float64(doy) - 172) / 365.25
	if lat < 0 {
		phase += math.Pi
	}
	// The fall-off with latitude is quadratic rather than linear because a
	// straight line fitted to temperate stations runs several degrees cool
	// across the tropics, which is where this platform's fields are. This
	// curve lands within about a degree of the real annual means for the
	// Indian latitudes — 26 °C at 17°N, 23 °C at 30°N — and stays roughly
	// sane further north. The amplitude is capped because the seasonal swing
	// stops growing once you leave the mid-latitudes.
	annualAmp := math.Min(1.0+absLat*0.35, 13.0)
	baseMean := 28.0 - 0.0055*absLat*absLat
	meanC := baseMean + annualAmp*math.Cos(phase) + jitter(key+"|t", 2.5)

	// Continentality: inland sites swing harder between day and night than
	// coastal ones. Longitude is a crude stand-in, but it is stable.
	rangeC := 8.0 + 6.0*unit(spot(lat, lon)+"|range")

	// Monsoon. Roughly June through September in the northern tropics, which
	// is where this platform's fields are; elsewhere rain is spread thinner.
	isMonsoon := lat > 5 && lat < 35 && doy >= 152 && doy <= 273
	wetChance := 0.18
	if isMonsoon {
		wetChance = 0.62
	}
	var rainMM float64
	if unit(key+"|wet") < wetChance {
		// Rainfall is heavy-tailed: most wet days are drizzle, a few are not.
		u := unit(key + "|amt")
		rainMM = math.Round(-math.Log(1-u*0.995)*(6.0+14.0*boolTo(isMonsoon))*10) / 10
	}

	// Cloud cover has to follow the season too, not just wobble around a
	// constant. The Indian dry season is mostly clear sky, and a mock that
	// averaged 50% cloud year-round would hold solar radiation — and so ET0,
	// and so every irrigation figure derived from it — at roughly half its
	// real value while still looking superficially reasonable.
	cloudBase, cloudSpread := 5.0, 35.0
	if isMonsoon {
		cloudBase, cloudSpread = 35.0, 40.0
	}
	// Capped below total overcast: pinning a whole monsoon month at 100% drives
	// radiation, and with it ET0, well under what is actually measured, and an
	// irrigation schedule built on that would under-water the crop.
	cloudPct := clamp(cloudBase+cloudSpread*unit(key+"|cloud")+20*boolTo(rainMM > 0), 0, 92)

	// Humidity moves against temperature and with rain. The 3 °C-per-point
	// slope is not from anywhere in particular; it just keeps hot dry days dry
	// and warm wet days near saturation.
	humidPct := clamp(72-(meanC-25)*1.6+cloudPct*0.18+20*boolTo(rainMM > 0)+jitter(key+"|rh", 6), 12, 99)

	windMS := clamp(1.2+4.5*unit(key+"|wind")+1.5*boolTo(rainMM > 0), 0.2, 18)
	windDeg := math.Round(360 * unit(key+"|dir"))
	pressHPa := 1013.0 + jitter(key+"|p", 7) - 2*boolTo(rainMM > 0)

	raMJ := extraterrestrialMJ(lat, doy)
	// Angstrom–Prescott with cloud cover standing in for sunshine fraction.
	solarMJ := raMJ * (0.25 + 0.50*(1-cloudPct/100))

	return climate{
		meanC:     round1(meanC),
		rangeC:    round1(rangeC),
		rainMM:    rainMM,
		cloudPct:  math.Round(cloudPct),
		humidPct:  math.Round(humidPct),
		windMS:    round1(windMS),
		windDeg:   windDeg,
		pressHPa:  round1(pressHPa),
		raMJ:      raMJ,
		solarMJ:   round1(solarMJ),
		dayOfYear: doy,
		latitude:  lat,
		isMonsoon: isMonsoon,
	}
}

func (c climate) minC() float64 { return round1(c.meanC - c.rangeC/2) }
func (c climate) maxC() float64 { return round1(c.meanC + c.rangeC/2) }

// tempAt gives the temperature at an hour of the day. The minimum lands just
// before sunrise and the maximum in mid-afternoon, which is why this is a
// shifted cosine rather than something centred on noon.
func (c climate) tempAt(hour int) float64 {
	h := float64(hour)
	return round1(c.meanC + (c.rangeC/2)*math.Cos(2*math.Pi*(h-15)/24))
}

// humidityAt tracks temperature inversely: the same air is nearer saturation
// when it is cold.
func (c climate) humidityAt(hour int) float64 {
	spread := c.tempAt(hour) - c.meanC
	return math.Round(clamp(c.humidPct-spread*2.2, 8, 100))
}

// solarAt distributes the day's radiation over daylight as a sine bell, in
// W/m² rather than the daily total's MJ/m².
func (c climate) solarAt(hour int) float64 {
	daylight := daylightHours(c.latitude, c.dayOfYear)
	if daylight <= 0 {
		return 0
	}
	sunrise := 12 - daylight/2
	x := (float64(hour) + 0.5 - sunrise) / daylight
	if x <= 0 || x >= 1 {
		return 0
	}
	// A half-sine over the daylight window integrates to 2/π of its peak, so
	// scaling by π/2 makes the hourly values sum back to the daily total.
	meanW := c.solarMJ * 1e6 / (daylight * 3600)
	return math.Round(meanW * (math.Pi / 2) * math.Sin(math.Pi*x))
}

// dewPointC inverts the Magnus formula. Meaningful because several downstream
// calculations use the gap between temperature and dew point, and computing it
// from an unrelated random number would break that relationship.
func dewPointC(tempC, rhPct float64) float64 {
	rh := clamp(rhPct, 1, 100)
	gamma := math.Log(rh/100) + (17.625*tempC)/(243.04+tempC)
	return round1(243.04 * gamma / (17.625 - gamma))
}

// extraterrestrialMJ is FAO-56 equation 21: radiation at the top of the
// atmosphere, MJ m⁻² day⁻¹. It is the ceiling the surface figure sits under.
func extraterrestrialMJ(lat float64, doy int) float64 {
	phi := lat * math.Pi / 180
	dr := 1 + 0.033*math.Cos(2*math.Pi*float64(doy)/365)
	decl := 0.409 * math.Sin(2*math.Pi*float64(doy)/365-1.39)

	// Inside the polar circles the sun may not set, or not rise; the argument
	// to arccos leaves [-1, 1] and has to be clamped rather than producing NaN.
	ws := math.Acos(clamp(-math.Tan(phi)*math.Tan(decl), -1, 1))

	ra := (24 * 60 / math.Pi) * 0.0820 * dr *
		(ws*math.Sin(phi)*math.Sin(decl) + math.Cos(phi)*math.Cos(decl)*math.Sin(ws))
	return math.Max(0, round1(ra))
}

// daylightHours is FAO-56 equation 34.
func daylightHours(lat float64, doy int) float64 {
	phi := lat * math.Pi / 180
	decl := 0.409 * math.Sin(2*math.Pi*float64(doy)/365-1.39)
	ws := math.Acos(clamp(-math.Tan(phi)*math.Tan(decl), -1, 1))
	return 24 / math.Pi * ws
}

// et0MM is the FAO-56 Penman-Monteith reference evapotranspiration.
//
// The weather service recomputes this itself when the upstream omits it, so
// the mock returning a plausible value rather than zero is what decides which
// of those two paths a test exercises. `?et0=omit` forces the other one.
func et0MM(c climate, elevM float64) float64 {
	tmin, tmax := c.minC(), c.maxC()
	tmean := (tmin + tmax) / 2

	// Wind is measured at 10 m; Penman-Monteith wants it at 2 m (eq. 47).
	u2 := c.windMS * 4.87 / math.Log(67.8*10-5.42)

	svp := func(t float64) float64 { return 0.6108 * math.Exp(17.27*t/(t+237.3)) }
	es := (svp(tmax) + svp(tmin)) / 2
	ea := es * c.humidPct / 100

	delta := 4098 * svp(tmean) / math.Pow(tmean+237.3, 2)
	p := 101.3 * math.Pow((293-0.0065*elevM)/293, 5.26)
	gamma := 0.000665 * p

	rs := c.solarMJ
	rns := 0.77 * rs
	rso := (0.75 + 2e-5*elevM) * c.raMJ
	ratio := 1.0
	if rso > 0 {
		ratio = clamp(rs/rso, 0.25, 1.0)
	}
	k := func(t float64) float64 { return math.Pow(t+273.16, 4) }
	rnl := 4.903e-9 * (k(tmax) + k(tmin)) / 2 *
		(0.34 - 0.14*math.Sqrt(ea)) * (1.35*ratio - 0.35)
	rn := rns - rnl

	num := 0.408*delta*rn + gamma*(900/(tmean+273))*u2*(es-ea)
	den := delta + gamma*(1+0.34*u2)
	if den == 0 {
		return 0
	}
	return math.Max(0, round2(num/den))
}

// wmoCode maps a day back to a WMO 4677 code, the vocabulary Open-Meteo speaks.
// The service translates these into condition strings, so returning a code that
// contradicts the precipitation figure would be a fine way to hide a bug.
func wmoCode(c climate) int {
	switch {
	case c.rainMM >= 25:
		return 65 // heavy rain
	case c.rainMM >= 8:
		return 63 // moderate rain
	case c.rainMM > 0:
		return 61 // slight rain
	case c.cloudPct >= 85:
		return 3 // overcast
	case c.cloudPct >= 50:
		return 2 // partly cloudy
	case c.cloudPct >= 20:
		return 1 // mainly clear
	default:
		return 0 // clear
	}
}

// owCondition is OpenWeather's vocabulary for the same thing.
func owCondition(c climate) (string, string) {
	switch {
	case c.rainMM >= 8:
		return "Rain", "moderate rain"
	case c.rainMM > 0:
		return "Rain", "light rain"
	case c.cloudPct >= 85:
		return "Clouds", "overcast clouds"
	case c.cloudPct >= 50:
		return "Clouds", "scattered clouds"
	default:
		return "Clear", "clear sky"
	}
}

func clamp(v, lo, hi float64) float64 { return math.Min(hi, math.Max(lo, v)) }
func round1(v float64) float64        { return math.Round(v*10) / 10 }
func round2(v float64) float64        { return math.Round(v*100) / 100 }

func boolTo(b bool) float64 {
	if b {
		return 1
	}
	return 0
}
