package services

import (
	"context"
	"errors"
	"testing"

	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/testutil"

	"p9e.in/samavaya/agriculture/alert-service/internal/ai"
	"p9e.in/samavaya/agriculture/alert-service/internal/clients"
)

// These cover what alert-service sends the gateway, which is the part that was
// wrong: it used to send a field id and nothing else, and the gateway fills in
// 22°C and 30% soil moisture for whatever it is not given. Every field came
// back scored against the same imaginary temperate day, with no error and a
// number that looked like a measurement.

type stubWeather struct {
	weather *clients.FieldWeather
	err     error
	calls   []string
}

func (s *stubWeather) FieldWeather(_ context.Context, fieldID string) (*clients.FieldWeather, error) {
	s.calls = append(s.calls, fieldID)
	return s.weather, s.err
}

type stubSoil struct {
	moisture float64
	found    bool
	err      error
	calls    []string
}

func (s *stubSoil) LatestMoistureFraction(_ context.Context, fieldID string) (float64, bool, error) {
	s.calls = append(s.calls, fieldID)
	return s.moisture, s.found, s.err
}

type stubDiagnosis struct {
	detections *clients.FieldDetections
	err        error
	calls      []string
}

func (s *stubDiagnosis) LatestDetections(_ context.Context, fieldID string) (*clients.FieldDetections, error) {
	s.calls = append(s.calls, fieldID)
	return s.detections, s.err
}

func newService(w clients.WeatherClient, so clients.SoilClient) *alertService {
	return newServiceWithDiagnosis(w, so, nil)
}

func newServiceWithDiagnosis(w clients.WeatherClient, so clients.SoilClient, dg clients.DiagnosisClient) *alertService {
	return NewAlertService(
		deps.ServiceDeps{Log: testutil.NopLogger{}},
		nil, nil, w, so, dg,
	).(*alertService)
}

// ---------------------------------------------------------------------------

// The field's own weather reaches the gateway.
func TestObservedWeatherIsSent(t *testing.T) {
	w := &stubWeather{weather: &clients.FieldWeather{
		TemperatureCurrent:      31.5,
		TemperatureMinForecast:  18.0,
		TemperatureMaxForecast:  36.0,
		PrecipitationMm:         2.5,
		PrecipitationForecastMm: 11.0,
		EtReferenceMm:           5.2,
	}}
	got := newService(w, nil).fieldConditions(context.Background(), "fld-1")

	want := ai.FieldConditions{
		TemperatureCurrent:      31.5,
		TemperatureMinForecast:  18.0,
		TemperatureMaxForecast:  36.0,
		PrecipitationMm:         2.5,
		PrecipitationForecastMm: 11.0,
		EtReferenceMm:           5.2,
	}
	if got != want {
		t.Errorf("conditions = %+v, want %+v", got, want)
	}
	if len(w.calls) != 1 || w.calls[0] != "fld-1" {
		t.Errorf("weather looked up for %v", w.calls)
	}
}

// Soil moisture from a weather observation is already volumetric (m³/m³), the
// same scale the gateway's own default of 0.30 is on, so it passes through.
func TestObservationSoilMoisturePassesThroughUnscaled(t *testing.T) {
	w := &stubWeather{weather: &clients.FieldWeather{
		TemperatureCurrent: 20,
		SoilMoisture:       0.22,
		HasSoilMoisture:    true,
	}}
	got := newService(w, nil).fieldConditions(context.Background(), "fld-1")

	if got.SoilMoisture != 0.22 {
		t.Errorf("SoilMoisture = %v, want 0.22 — the observation is already a fraction", got.SoilMoisture)
	}
}

// The weather observation wins over a soil sample. It is continuous and
// current; a sample is an occasional lab result.
func TestTheObservationIsPreferredOverASample(t *testing.T) {
	w := &stubWeather{weather: &clients.FieldWeather{SoilMoisture: 0.18, HasSoilMoisture: true}}
	so := &stubSoil{moisture: 0.40, found: true}

	got := newService(w, so).fieldConditions(context.Background(), "fld-1")

	if got.SoilMoisture != 0.18 {
		t.Errorf("SoilMoisture = %v, want the observation's 0.18", got.SoilMoisture)
	}
	if len(so.calls) != 0 {
		t.Error("soil-service was queried although the observation carried moisture")
	}
}

// With no moisture in the observation, the soil sample is used.
func TestTheSoilSampleIsTheFallback(t *testing.T) {
	w := &stubWeather{weather: &clients.FieldWeather{TemperatureCurrent: 20}}
	so := &stubSoil{moisture: 0.31, found: true}

	got := newService(w, so).fieldConditions(context.Background(), "fld-1")

	if got.SoilMoisture != 0.31 {
		t.Errorf("SoilMoisture = %v, want the sample's 0.31", got.SoilMoisture)
	}
	if len(so.calls) != 1 {
		t.Errorf("soil-service called %d times", len(so.calls))
	}
}

// A weather failure does not take the evaluation down with it.
//
// Returning the error instead would mean the scanner raises nothing at all for
// that field while weather-service is unreachable, and a farmer waiting on a
// threshold hears silence.
func TestAWeatherFailureDegradesRatherThanFails(t *testing.T) {
	w := &stubWeather{err: errors.New("weather-service unreachable")}
	so := &stubSoil{moisture: 0.25, found: true}

	got := newService(w, so).fieldConditions(context.Background(), "fld-1")

	if got.TemperatureCurrent != 0 {
		t.Errorf("TemperatureCurrent = %v after a failed lookup", got.TemperatureCurrent)
	}
	// Soil is still gathered: one source failing must not suppress the other.
	if got.SoilMoisture != 0.25 {
		t.Errorf("SoilMoisture = %v; a weather failure suppressed the soil lookup", got.SoilMoisture)
	}
}

// A soil failure likewise leaves the weather in place.
func TestASoilFailureLeavesWeatherIntact(t *testing.T) {
	w := &stubWeather{weather: &clients.FieldWeather{TemperatureCurrent: 28}}
	so := &stubSoil{err: errors.New("soil-service unreachable")}

	got := newService(w, so).fieldConditions(context.Background(), "fld-1")

	if got.TemperatureCurrent != 28 {
		t.Errorf("TemperatureCurrent = %v; a soil failure discarded the weather", got.TemperatureCurrent)
	}
	if got.SoilMoisture != 0 {
		t.Errorf("SoilMoisture = %v after a failed lookup", got.SoilMoisture)
	}
}

// With neither client configured the conditions are zero, which the gateway
// reads as "use the defaults" — the old behaviour, now reached explicitly
// rather than by omission.
func TestNoClientsMeansEmptyConditions(t *testing.T) {
	if got := newService(nil, nil).fieldConditions(context.Background(), "fld-1"); got != (ai.FieldConditions{}) {
		t.Errorf("conditions = %+v, want zero", got)
	}
}

// A sample with no moisture recorded is not treated as bone-dry ground.
//
// Zero would be sent as a real reading of 0.0 — drier than any soil — and
// water risk would peg high on every field whose sample happened to omit it.
func TestASampleWithoutMoistureIsNotTreatedAsZero(t *testing.T) {
	w := &stubWeather{weather: &clients.FieldWeather{TemperatureCurrent: 20}}
	so := &stubSoil{moisture: 0, found: false}

	got := newService(w, so).fieldConditions(context.Background(), "fld-1")

	if got.SoilMoisture != 0 {
		t.Errorf("SoilMoisture = %v", got.SoilMoisture)
	}
}

// ---------------------------------------------------------------------------

// What was actually found in the field's plants reaches the gateway.
//
// Without this the pest, disease and nutrient dimensions score 0 on every
// field, which is indistinguishable from a farm where nothing is ever wrong.
func TestDetectionsFromTheLatestDiagnosisAreSent(t *testing.T) {
	dg := &stubDiagnosis{detections: &clients.FieldDetections{
		PestConfidence:    0.71,
		PestSpecies:       "Fall armyworm",
		DiseaseConfidence: 0.82,
		DiseaseName:       "Late blight",
		NutrientSeverity:  0.75,
		NutrientType:      "Nitrogen",
	}}
	got := newServiceWithDiagnosis(&stubWeather{weather: &clients.FieldWeather{TemperatureCurrent: 20}}, nil, dg).
		fieldConditions(context.Background(), "fld-1")

	if got.PestConfidence != 0.71 || got.PestSpecies != "Fall armyworm" {
		t.Errorf("pest = %v %q", got.PestConfidence, got.PestSpecies)
	}
	if got.DiseaseConfidence != 0.82 || got.DiseaseName != "Late blight" {
		t.Errorf("disease = %v %q", got.DiseaseConfidence, got.DiseaseName)
	}
	if got.NutrientSeverity != 0.75 || got.NutrientType != "Nitrogen" {
		t.Errorf("nutrient = %v %q", got.NutrientSeverity, got.NutrientType)
	}
	if !got.HasDetections {
		t.Error("HasDetections = false although the field was diagnosed")
	}
	if len(dg.calls) != 1 || dg.calls[0] != "fld-1" {
		t.Errorf("diagnoses looked up for %v", dg.calls)
	}
}

// A field with no recent diagnosis is not a field that was looked at and found
// clean, and the difference is carried rather than flattened.
func TestAFieldWithNoDiagnosisCarriesNoDetections(t *testing.T) {
	dg := &stubDiagnosis{detections: nil}
	got := newServiceWithDiagnosis(&stubWeather{weather: &clients.FieldWeather{TemperatureCurrent: 20}}, nil, dg).
		fieldConditions(context.Background(), "fld-1")

	if got.HasDetections {
		t.Error("HasDetections = true although there was no diagnosis")
	}
	if got.PestSpecies != "" || got.DiseaseName != "" || got.NutrientType != "" {
		t.Errorf("named findings on an undiagnosed field: %+v", got)
	}
}

// A diagnosis failure degrades the score rather than failing the evaluation,
// and leaves the weather that was already gathered in place.
func TestADiagnosisFailureDegradesRatherThanFails(t *testing.T) {
	dg := &stubDiagnosis{err: errors.New("plant-diagnosis unreachable")}
	got := newServiceWithDiagnosis(&stubWeather{weather: &clients.FieldWeather{TemperatureCurrent: 28}}, nil, dg).
		fieldConditions(context.Background(), "fld-1")

	if got.TemperatureCurrent != 28 {
		t.Errorf("TemperatureCurrent = %v; a diagnosis failure discarded the weather", got.TemperatureCurrent)
	}
	if got.HasDetections {
		t.Error("HasDetections = true after a failed lookup")
	}
}
