// Package clients holds alert-service's outbound clients for the services that
// hold a field's current conditions.
//
// They exist because the risk score did not previously describe the field it
// named. alert-service sent the gateway a field id and nothing else, and the
// gateway substitutes defaults for whatever is absent — 22°C, 30% soil
// moisture, no detections — so every field came back scored against the same
// imaginary temperate day. Nothing errored, and the number looked like a
// measurement.
//
// That mattered more once the rule scanner began calling it on a timer: a
// farmer who sets a threshold on water risk was being told about a default,
// not their field.
//
// The detections are here for the same reason and one more. Absent, the pest,
// disease and nutrient dimensions score a flat zero on every field, which is
// not a default a reader would notice — it is indistinguishable from a farm
// where nothing has ever gone wrong.
package clients

import (
	"context"
	"fmt"
	"net/http"
	"time"

	"connectrpc.com/connect"

	diagnosisv1 "p9e.in/samavaya/agriculture/plant-diagnosis-service/api/v1"
	"p9e.in/samavaya/agriculture/plant-diagnosis-service/api/v1/plantdiagnosisv1connect"
	soilv1 "p9e.in/samavaya/agriculture/soil-service/api/v1"
	"p9e.in/samavaya/agriculture/soil-service/api/v1/soilv1connect"
	weatherv1 "p9e.in/samavaya/agriculture/weather-service/api/v1"
	"p9e.in/samavaya/agriculture/weather-service/api/v1/weatherv1connect"
)

// FieldWeather is a field's current and near-term weather, in the units the
// AI gateway's FieldWeather message expects.
type FieldWeather struct {
	TemperatureCurrent      float64
	TemperatureMinForecast  float64
	TemperatureMaxForecast  float64
	PrecipitationMm         float64
	PrecipitationForecastMm float64
	EtReferenceMm           float64

	// SoilMoisture is volumetric, m³/m³, which is already the unit and scale
	// the gateway wants — its own default is 0.30. Present only when the
	// observation carried one, which is why it is reported separately.
	SoilMoisture    float64
	HasSoilMoisture bool
}

// WeatherClient reads a field's weather from weather-service.
type WeatherClient interface {
	FieldWeather(ctx context.Context, fieldID string) (*FieldWeather, error)
}

// SoilClient reads a field's soil state from soil-service.
type SoilClient interface {
	// LatestMoistureFraction returns the most recent sampled soil moisture as
	// a 0..1 fraction, and whether one was found.
	LatestMoistureFraction(ctx context.Context, fieldID string) (float64, bool, error)
}

// FieldDetections is what was actually found in a field's plants, in the units
// the AI gateway's DetectionResults message expects.
//
// Everything here is a finding from a photographed plant, not a forecast. The
// alerts these feed are worded as observations — "Pest detected: X (78%
// confidence)" — so a predicted risk must never be routed into them, however
// convenient its number looks.
type FieldDetections struct {
	// Confidences are probabilities on 0..1, the same scale the gateway's
	// pest_confidence (threshold 0.6) and disease_confidence (0.5) are read
	// on. plant-diagnosis already stores them that way, so there is nothing to
	// convert — and nothing should be added.
	PestConfidence    float64
	PestSpecies       string
	DiseaseConfidence float64
	DiseaseName       string

	// NutrientSeverity is derived from the diagnosis's severity grade, not
	// from its confidence. The gateway asks how bad the deficiency is; a
	// confidence says only how sure the model is that it is there at all.
	NutrientSeverity float64
	NutrientType     string
}

// DiagnosisClient reads a field's most recent plant diagnosis from
// plant-diagnosis-service.
type DiagnosisClient interface {
	// LatestDetections returns the newest completed diagnosis for the field,
	// or nil when there is none recent enough to describe it today.
	LatestDetections(ctx context.Context, fieldID string) (*FieldDetections, error)
}

// ---------------------------------------------------------------------------

type weatherClient struct {
	client weatherv1connect.WeatherServiceClient
}

// NewWeatherClient creates a Connect-backed WeatherClient.
func NewWeatherClient(baseURL string, httpClient *http.Client, opts ...connect.ClientOption) WeatherClient {
	return &weatherClient{client: weatherv1connect.NewWeatherServiceClient(httpClient, baseURL, opts...)}
}

// FieldWeather returns the field's latest observation plus tomorrow's forecast.
//
// Two calls because the gateway wants both: the current temperature and
// rainfall come from the observation, while the min/max it scores frost and
// heat risk against, and the reference ET it scores water risk against, only
// exist in the forecast.
//
// A missing forecast is not fatal. The observation alone is still far better
// than the gateway's defaults, and refusing to score a field because tomorrow
// is unknown would take the whole evaluation down with it.
func (c *weatherClient) FieldWeather(ctx context.Context, fieldID string) (*FieldWeather, error) {
	if fieldID == "" {
		return nil, fmt.Errorf("field_id is required to look up weather")
	}

	resp, err := c.client.GetCurrentWeather(ctx, connect.NewRequest(&weatherv1.GetCurrentWeatherRequest{
		FieldId: fieldID,
	}))
	if err != nil {
		return nil, fmt.Errorf("weather GetCurrentWeather: %w", err)
	}
	obs := resp.Msg.GetObservation()
	if obs == nil {
		return nil, fmt.Errorf("no weather observation recorded for field %s", fieldID)
	}

	out := &FieldWeather{
		TemperatureCurrent: obs.GetTemperatureC(),
		PrecipitationMm:    obs.GetPrecipitationMm(),
		// Defaulted to the current temperature so that, without a forecast,
		// frost and heat risk are scored against today rather than against
		// zero — which would read as a hard freeze.
		TemperatureMinForecast: obs.GetTemperatureC(),
		TemperatureMaxForecast: obs.GetTemperatureC(),
	}
	if m := obs.GetSoilMoistureM3M3(); m > 0 {
		out.SoilMoisture, out.HasSoilMoisture = m, true
	}

	fc, err := c.client.GetForecast(ctx, connect.NewRequest(&weatherv1.GetForecastRequest{
		FieldId: fieldID,
		Days:    1,
	}))
	if err != nil {
		return out, nil
	}
	if days := fc.Msg.GetForecasts(); len(days) > 0 {
		d := days[0]
		out.TemperatureMinForecast = d.GetTemperatureMinC()
		out.TemperatureMaxForecast = d.GetTemperatureMaxC()
		out.PrecipitationForecastMm = d.GetPrecipitationMm()
		out.EtReferenceMm = d.GetEt0Mm()
	}
	return out, nil
}

// ---------------------------------------------------------------------------

type soilClient struct {
	client soilv1connect.SoilServiceClient
}

// NewSoilClient creates a Connect-backed SoilClient.
func NewSoilClient(baseURL string, httpClient *http.Client, opts ...connect.ClientOption) SoilClient {
	return &soilClient{client: soilv1connect.NewSoilServiceClient(httpClient, baseURL, opts...)}
}

// LatestMoistureFraction returns the field's most recent sampled soil moisture.
//
// Divided by 100 on the way out, and that is the whole reason this returns a
// named fraction rather than the number soil-service stores. A sample's
// moisture_pct is a percentage — 30 means 30% — while the gateway's
// soil_moisture is a fraction whose own default is 0.30. Passing the
// percentage straight through would hand it 30.0 where it expects 0.3, a
// hundredfold error that would read as saturated ground on every field.
func (c *soilClient) LatestMoistureFraction(ctx context.Context, fieldID string) (float64, bool, error) {
	if fieldID == "" {
		return 0, false, fmt.Errorf("field_id is required to look up soil moisture")
	}

	resp, err := c.client.ListSoilSamples(ctx, connect.NewRequest(&soilv1.ListSoilSamplesRequest{
		FieldId:  fieldID,
		PageSize: 1,
	}))
	if err != nil {
		return 0, false, fmt.Errorf("soil ListSoilSamples: %w", err)
	}

	samples := resp.Msg.GetSamples()
	if len(samples) == 0 {
		return 0, false, nil
	}
	fraction, ok := moistureFraction(samples[0].GetMoisturePct())
	return fraction, ok, nil
}

// moistureFraction converts a sample's moisture percentage to the fraction the
// gateway expects, and reports whether there was a reading at all.
//
// Extracted so it can be tested without a server, because nothing else catches
// this: dropping the division still compiles and still runs, and the wrong
// number is a plausible one. 30% arriving as 30.0 where 0.3 belongs reads as
// ground a hundred times wetter than saturated.
//
// A zero or negative percentage is "not recorded", not "bone dry". Sent as a
// real 0.0 it would be drier than any soil, and water risk would peg high on
// every field whose sample happened to omit it.
func moistureFraction(pct float64) (float64, bool) {
	if pct <= 0 {
		return 0, false
	}
	return pct / 100.0, true
}

// ---------------------------------------------------------------------------

// DefaultDiagnosisMaxAge is how old a diagnosis may be and still count as a
// description of the field today.
//
// There has to be a bound. The alerts these detections raise are phrased in the
// present tense, and plant-diagnosis keeps every diagnosis a field has ever
// had, so without a window the newest row for a quiet field is whatever was
// photographed last season — and a farmer would be told about a pest that was
// treated months ago, every scan, forever.
const DefaultDiagnosisMaxAge = 14 * 24 * time.Hour

type diagnosisClient struct {
	client plantdiagnosisv1connect.PlantDiagnosisServiceClient
	maxAge time.Duration
}

// NewDiagnosisClient creates a Connect-backed DiagnosisClient.
func NewDiagnosisClient(baseURL string, httpClient *http.Client, opts ...connect.ClientOption) DiagnosisClient {
	return &diagnosisClient{
		client: plantdiagnosisv1connect.NewPlantDiagnosisServiceClient(httpClient, baseURL, opts...),
		maxAge: DefaultDiagnosisMaxAge,
	}
}

// LatestDetections returns the field's most recent completed diagnosis.
//
// Two calls, and the second is not optional: ListDiagnoses selects only the
// request columns and leaves `result` nil on every row it returns, so reading
// detections straight off the listing would yield nothing at all — quietly,
// with no error, on a field that has been diagnosed a dozen times. GetDiagnosis
// is what joins the result in.
//
// Only COMPLETED diagnoses are asked for. A pending or failed one has no
// result to read, and a failed analysis is not evidence that a field is clean.
func (c *diagnosisClient) LatestDetections(ctx context.Context, fieldID string) (*FieldDetections, error) {
	if fieldID == "" {
		return nil, fmt.Errorf("field_id is required to look up diagnoses")
	}

	list, err := c.client.ListDiagnoses(ctx, connect.NewRequest(&diagnosisv1.ListDiagnosesRequest{
		FieldId:  fieldID,
		Status:   diagnosisv1.DiagnosisStatus_DIAGNOSIS_STATUS_COMPLETED,
		PageSize: 1,
		SortBy:   "created_at",
		SortDesc: true,
	}))
	if err != nil {
		return nil, fmt.Errorf("diagnosis ListDiagnoses: %w", err)
	}

	diagnoses := list.Msg.GetDiagnoses()
	if len(diagnoses) == 0 {
		return nil, nil
	}
	latest := diagnoses[0]
	if !withinMaxAge(latest.GetCreatedAt().AsTime(), latest.GetCreatedAt() != nil, c.maxAge, time.Now()) {
		return nil, nil
	}

	got, err := c.client.GetDiagnosis(ctx, connect.NewRequest(&diagnosisv1.GetDiagnosisRequest{
		Id: latest.GetId(),
	}))
	if err != nil {
		return nil, fmt.Errorf("diagnosis GetDiagnosis %s: %w", latest.GetId(), err)
	}
	return detectionsFromResult(got.Msg.GetDiagnosis().GetResult()), nil
}

// withinMaxAge reports whether a diagnosis stamped at createdAt is recent
// enough to describe the field now.
//
// A diagnosis with no timestamp at all is kept rather than discarded. The
// column is not nullable and the listing is ordered by it, so an absent one
// means something went wrong in transport, not that the diagnosis is old —
// and throwing away a real detection over a missing field would be the worse
// failure of the two.
func withinMaxAge(createdAt time.Time, stamped bool, maxAge time.Duration, now time.Time) bool {
	if !stamped || maxAge <= 0 {
		return true
	}
	return now.Sub(createdAt) <= maxAge
}

// detectionsFromResult picks the one disease, pest and deficiency the gateway
// has room for out of everything the diagnosis found.
//
// DetectionResults carries a single entry of each kind while a diagnosis can
// report several, so something has to be chosen, and the choice is the worst
// case rather than the first listed: the gateway compares what it is given
// against a threshold, and handing it the mildest of three findings would be a
// way of reporting a healthy field that has three problems.
//
// Returns nil when nothing was found, which is what keeps a clean field clean.
// A zero-valued FieldDetections would still be sent, and a zero confidence
// scores the same as no detection — but the "Unknown" species the gateway
// falls back to would then be one bad threshold change away from becoming an
// alert about a pest nobody ever saw.
func detectionsFromResult(res *diagnosisv1.DiagnosisResult) *FieldDetections {
	if res == nil {
		return nil
	}

	var out FieldDetections
	found := false

	for _, d := range res.GetDetectedDiseases() {
		if d.GetConfidenceScore() > out.DiseaseConfidence {
			out.DiseaseConfidence, out.DiseaseName = d.GetConfidenceScore(), d.GetDiseaseName()
			found = true
		}
	}
	for _, p := range res.GetPestDamage() {
		if p.GetConfidenceScore() > out.PestConfidence {
			out.PestConfidence, out.PestSpecies = p.GetConfidenceScore(), p.GetPestName()
			found = true
		}
	}
	for _, n := range res.GetNutrientDeficiencies() {
		score, ok := severityScore(n.GetSeverity())
		if ok && score > out.NutrientSeverity {
			out.NutrientSeverity, out.NutrientType = score, n.GetNutrient()
			found = true
		}
	}

	if !found {
		return nil
	}
	return &out
}

// severityScore maps a diagnosis severity grade onto the 0..1 number the
// gateway reads nutrient_severity as, and reports whether the grade said
// anything at all.
//
// The grades are spaced evenly so that MODERATE lands exactly on the gateway's
// 0.5 threshold, which it compares with >=. That is deliberate: a moderate
// deficiency is the mildest grade worth telling a farmer about, and MILD sits
// below the line where it belongs.
//
// SEVERITY_UNSPECIFIED is "not graded", not "not severe". Scored as a real 0.0
// it would be indistinguishable from a field with no deficiency, which is the
// right outcome here but for the wrong reason — so it is reported as absent
// and the caller decides.
func severityScore(s diagnosisv1.Severity) (float64, bool) {
	switch s {
	case diagnosisv1.Severity_SEVERITY_MILD:
		return 0.25, true
	case diagnosisv1.Severity_SEVERITY_MODERATE:
		return 0.5, true
	case diagnosisv1.Severity_SEVERITY_SEVERE:
		return 0.75, true
	case diagnosisv1.Severity_SEVERITY_CRITICAL:
		return 1.0, true
	default:
		return 0, false
	}
}
