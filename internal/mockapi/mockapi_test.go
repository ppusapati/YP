package mockapi_test

import (
	"bytes"
	"encoding/base64"
	"encoding/json"
	"io"
	"mime/multipart"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"p9e.in/samavaya/agriculture/internal/mockapi"
)

// These tests check the wire shapes the mock emits.
//
// The vision providers are consumed by ai-gateway's vision_client.rs, which is
// Rust and cannot be imported here, so the expectations below are transcribed
// from that parser: which fields it requires, which it treats as optional, and
// what it does when one is missing. That transcription is the weak link — it
// has to be revisited whenever the gateway's parser changes.
//
// The weather side has a stronger check available, because those consumers are
// Go: see weather-service/internal/adapters/outbound/providers, where the real
// adapters are driven against this mock.

// frozen is a fixed clock, so that forecast windows are the same on every run.
var frozen = time.Date(2026, 3, 15, 10, 0, 0, 0, time.UTC)

func newServer(t *testing.T) *httptest.Server {
	t.Helper()
	srv := httptest.NewServer(mockapi.New(mockapi.Options{
		Now: func() time.Time { return frozen },
	}).Handler())
	t.Cleanup(srv.Close)
	return srv
}

// ── Open-Meteo wire shape ───────────────────────────────────────────────────

func TestOpenMeteoRejectsMissingCoordinates(t *testing.T) {
	srv := newServer(t)
	resp, err := srv.Client().Get(srv.URL + "/v1/forecast?daily=temperature_2m_max")
	if err != nil {
		t.Fatalf("get: %v", err)
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusBadRequest {
		t.Errorf("status %d, want 400", resp.StatusCode)
	}

	var body struct {
		Error  bool   `json:"error"`
		Reason string `json:"reason"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&body); err != nil {
		t.Fatalf("decode: %v", err)
	}
	// The client checks this flag as well as the status code, so an error that
	// carried only the status would leave one of its two paths untested.
	if !body.Error || body.Reason == "" {
		t.Errorf("want the error/reason shape the client looks for, got %+v", body)
	}
}

func TestOpenMeteoArchiveRequiresADateRange(t *testing.T) {
	srv := newServer(t)
	resp, err := srv.Client().Get(srv.URL + "/v1/archive?latitude=17.38&longitude=78.49&daily=temperature_2m_max")
	if err != nil {
		t.Fatalf("get: %v", err)
	}
	defer resp.Body.Close()
	// The archive API has no forecast_days, and silently inventing a range
	// here would hide a caller that forgot to send one.
	if resp.StatusCode != http.StatusBadRequest {
		t.Errorf("status %d, want 400", resp.StatusCode)
	}
}

func TestOpenMeteoEmitsOnlyRequestedVariables(t *testing.T) {
	srv := newServer(t)
	resp, err := srv.Client().Get(srv.URL +
		"/v1/forecast?latitude=17.38&longitude=78.49&hourly=temperature_2m,precipitation")
	if err != nil {
		t.Fatalf("get: %v", err)
	}
	defer resp.Body.Close()

	var body struct {
		Hourly map[string]json.RawMessage `json:"hourly"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&body); err != nil {
		t.Fatalf("decode: %v", err)
	}
	// time plus the two that were asked for. Returning every variable
	// regardless would mask a service reading one it never requested — which
	// works against the mock and fails against the real API.
	if len(body.Hourly) != 3 {
		t.Errorf("got %d hourly columns %v, want time plus the two requested",
			len(body.Hourly), keysOf(body.Hourly))
	}
	if _, ok := body.Hourly["cloud_cover"]; ok {
		t.Error("cloud_cover was returned without being requested")
	}
}

func TestOpenMeteoColumnsAreIndexAligned(t *testing.T) {
	srv := newServer(t)
	resp, err := srv.Client().Get(srv.URL +
		"/v1/forecast?latitude=17.38&longitude=78.49&forecast_days=5" +
		"&daily=temperature_2m_max,temperature_2m_min,precipitation_sum,weather_code")
	if err != nil {
		t.Fatalf("get: %v", err)
	}
	defer resp.Body.Close()

	var body struct {
		Daily map[string][]json.RawMessage `json:"daily"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&body); err != nil {
		t.Fatalf("decode: %v", err)
	}
	// Open-Meteo's format is column-oriented and positional: every array is
	// read at the same index as `time`. A short column does not error, it
	// silently yields zeros, so the lengths have to match exactly.
	want := len(body.Daily["time"])
	if want != 5 {
		t.Fatalf("asked for 5 days, got %d", want)
	}
	for name, col := range body.Daily {
		if len(col) != want {
			t.Errorf("column %q has %d entries, time has %d", name, len(col), want)
		}
	}
}

func TestOpenWeatherRejectsMissingAPIKey(t *testing.T) {
	srv := newServer(t)
	resp, err := srv.Client().Get(srv.URL + "/data/3.0/onecall?lat=17.38&lon=78.49")
	if err != nil {
		t.Fatalf("get: %v", err)
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusUnauthorized {
		t.Errorf("status %d, want 401", resp.StatusCode)
	}
}

func TestOpenWeatherHourlyAndDailyRainDiffer(t *testing.T) {
	srv := newServer(t)
	resp, err := srv.Client().Get(srv.URL + "/data/3.0/onecall?lat=17.38&lon=78.49&appid=mock")
	if err != nil {
		t.Fatalf("get: %v", err)
	}
	defer resp.Body.Close()

	var body struct {
		Hourly []map[string]json.RawMessage `json:"hourly"`
		Daily  []map[string]json.RawMessage `json:"daily"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&body); err != nil {
		t.Fatalf("decode: %v", err)
	}

	// OpenWeather returns hourly rain as {"1h": n} and daily rain as a bare
	// number. That inconsistency is theirs, and reproducing it is the point: a
	// client that assumes one shape for both breaks on exactly this, and a
	// tidier mock would never reveal it.
	for _, h := range body.Hourly {
		if raw, ok := h["rain"]; ok {
			var obj map[string]float64
			if err := json.Unmarshal(raw, &obj); err != nil {
				t.Fatalf("hourly rain should be an object, got %s", raw)
			}
			if _, ok := obj["1h"]; !ok {
				t.Errorf(`hourly rain object has no "1h" key: %s`, raw)
			}
			break
		}
	}
	for _, d := range body.Daily {
		if raw, ok := d["rain"]; ok {
			var f float64
			if err := json.Unmarshal(raw, &f); err != nil {
				t.Fatalf("daily rain should be a bare number, got %s", raw)
			}
			break
		}
	}
}

// ── Fault injection ─────────────────────────────────────────────────────────

func TestInjectedFaultFailsExactlyTheConfiguredNumberOfCalls(t *testing.T) {
	srv := newServer(t)
	setFault(t, srv, "openmeteo", `{"status":503,"remaining":2}`)

	url := srv.URL + "/v1/forecast?latitude=17.38&longitude=78.49&daily=temperature_2m_max"
	for i, want := range []int{503, 503, 200} {
		resp, err := srv.Client().Get(url)
		if err != nil {
			t.Fatalf("call %d: %v", i, err)
		}
		resp.Body.Close()
		// This is the property that makes a retry loop testable at all: a
		// probabilistic fault cannot express "fail twice, then succeed".
		if resp.StatusCode != want {
			t.Errorf("call %d returned %d, want %d", i, resp.StatusCode, want)
		}
	}
}

func TestStickyFaultKeepsFailingUntilCleared(t *testing.T) {
	srv := newServer(t)
	setFault(t, srv, "openweather", `{"status":500}`)

	url := srv.URL + "/data/3.0/onecall?lat=17.38&lon=78.49&appid=mock"
	for i := 0; i < 3; i++ {
		resp, err := srv.Client().Get(url)
		if err != nil {
			t.Fatalf("call %d: %v", i, err)
		}
		resp.Body.Close()
		if resp.StatusCode != 500 {
			t.Fatalf("call %d returned %d, want a persistent 500", i, resp.StatusCode)
		}
	}

	req, _ := http.NewRequest(http.MethodDelete, srv.URL+"/__mock/faults", nil)
	resp, err := srv.Client().Do(req)
	if err != nil {
		t.Fatalf("clear: %v", err)
	}
	resp.Body.Close()

	after, err := srv.Client().Get(url)
	if err != nil {
		t.Fatalf("after clear: %v", err)
	}
	defer after.Body.Close()
	if after.StatusCode != 200 {
		t.Errorf("after clearing the fault, status %d", after.StatusCode)
	}
}

func TestFaultOnOneProviderLeavesOthersAlone(t *testing.T) {
	srv := newServer(t)
	setFault(t, srv, "openmeteo", `{"status":503}`)

	resp, err := srv.Client().Get(srv.URL + "/data/3.0/onecall?lat=17.38&lon=78.49&appid=mock")
	if err != nil {
		t.Fatalf("get: %v", err)
	}
	defer resp.Body.Close()
	// Simulating one upstream being down while the others are healthy is the
	// case a fallback path is written for.
	if resp.StatusCode != 200 {
		t.Errorf("openweather returned %d while only openmeteo was faulted", resp.StatusCode)
	}
}

func TestDelayOnlyFaultStillSucceeds(t *testing.T) {
	srv := newServer(t)
	setFault(t, srv, "openmeteo", `{"delay_ms":120}`)

	start := time.Now()
	resp, err := srv.Client().Get(srv.URL + "/v1/forecast?latitude=17.38&longitude=78.49&daily=temperature_2m_max")
	if err != nil {
		t.Fatalf("get: %v", err)
	}
	defer resp.Body.Close()

	// A slow-but-working upstream is a different failure mode from a broken
	// one: it is the one that trips client timeouts rather than error handling.
	if resp.StatusCode != 200 {
		t.Errorf("status %d, want the request to succeed after the delay", resp.StatusCode)
	}
	if elapsed := time.Since(start); elapsed < 100*time.Millisecond {
		t.Errorf("responded in %s, want at least the configured 120ms delay", elapsed)
	}
}

func TestFaultsCanBeSetInProcess(t *testing.T) {
	// Tests that would rather not make an HTTP call to arrange a fault.
	server := mockapi.New(mockapi.Options{Now: func() time.Time { return frozen }})
	server.SetFault("openmeteo", &mockapi.Fault{Status: 502})
	srv := httptest.NewServer(server.Handler())
	defer srv.Close()

	resp, err := srv.Client().Get(srv.URL + "/v1/forecast?latitude=17.38&longitude=78.49&daily=temperature_2m_max")
	if err != nil {
		t.Fatalf("get: %v", err)
	}
	resp.Body.Close()
	if resp.StatusCode != 502 {
		t.Errorf("status %d, want 502", resp.StatusCode)
	}

	server.ClearFaults()
	after, err := srv.Client().Get(srv.URL + "/v1/forecast?latitude=17.38&longitude=78.49&daily=temperature_2m_max")
	if err != nil {
		t.Fatalf("get: %v", err)
	}
	after.Body.Close()
	if after.StatusCode != 200 {
		t.Errorf("status %d after clearing faults", after.StatusCode)
	}
}

// ── PlantNet ────────────────────────────────────────────────────────────────

func TestPlantNetShapeMatchesTheGatewayParser(t *testing.T) {
	srv := newServer(t)

	body, ct := multipartImageBody(t, "images", []byte("a picture of a leaf"))
	resp, err := srv.Client().Post(srv.URL+"/v2/identify/all?api-key=mock", ct, body)
	if err != nil {
		t.Fatalf("post: %v", err)
	}
	defer resp.Body.Close()
	if resp.StatusCode != 200 {
		t.Fatalf("status %d", resp.StatusCode)
	}

	var out struct {
		Results []struct {
			Score   *float64 `json:"score"`
			Species struct {
				CommonNames                 []string `json:"commonNames"`
				ScientificNameWithoutAuthor string   `json:"scientificNameWithoutAuthor"`
				Family                      struct {
					ScientificNameWithoutAuthor string `json:"scientificNameWithoutAuthor"`
				} `json:"family"`
			} `json:"species"`
		} `json:"results"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&out); err != nil {
		t.Fatalf("decode: %v", err)
	}

	// The gateway treats a missing `results` as a parse error and silently
	// skips any entry without a `score`, so both have to be there.
	if len(out.Results) == 0 {
		t.Fatal("no results; the gateway would fail to parse this")
	}
	for i, r := range out.Results {
		if r.Score == nil {
			t.Errorf("result %d has no score; the gateway would drop it", i)
		}
		if len(r.Species.CommonNames) == 0 {
			t.Errorf("result %d has no commonNames; the label would default to Unknown", i)
		}
		if r.Species.ScientificNameWithoutAuthor == "" {
			t.Errorf("result %d has no scientific name", i)
		}
		if r.Species.Family.ScientificNameWithoutAuthor == "" {
			t.Errorf("result %d has no family; the gateway reads that as the category", i)
		}
	}
	// Ranked descending, as the gateway assumes when it takes the lead result.
	for i := 1; i < len(out.Results); i++ {
		if *out.Results[i].Score > *out.Results[i-1].Score {
			t.Errorf("results are not ranked: %f follows %f", *out.Results[i].Score, *out.Results[i-1].Score)
		}
	}
}

func TestPlantNetRequiresAPIKey(t *testing.T) {
	srv := newServer(t)
	body, ct := multipartImageBody(t, "images", []byte("leaf"))
	resp, err := srv.Client().Post(srv.URL+"/v2/identify/all", ct, body)
	if err != nil {
		t.Fatalf("post: %v", err)
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusUnauthorized {
		t.Errorf("status %d, want 401", resp.StatusCode)
	}
}

// ── Google Cloud Vision ─────────────────────────────────────────────────────

func TestGoogleVisionShapeMatchesTheGatewayParser(t *testing.T) {
	srv := newServer(t)

	req := `{"requests":[{"image":{"content":"aGVsbG8="},"features":[{"type":"LABEL_DETECTION","maxResults":15}]}]}`
	resp, err := srv.Client().Post(srv.URL+"/v1/images:annotate?key=mock",
		"application/json", bytes.NewBufferString(req))
	if err != nil {
		t.Fatalf("post: %v", err)
	}
	defer resp.Body.Close()

	var out struct {
		Responses []struct {
			LabelAnnotations []struct {
				Description string   `json:"description"`
				Score       *float64 `json:"score"`
			} `json:"labelAnnotations"`
		} `json:"responses"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&out); err != nil {
		t.Fatalf("decode: %v", err)
	}
	// The gateway reads responses[0].labelAnnotations and nothing else.
	if len(out.Responses) == 0 || len(out.Responses[0].LabelAnnotations) == 0 {
		t.Fatal("no labelAnnotations; the gateway would fail to parse this")
	}
	for i, a := range out.Responses[0].LabelAnnotations {
		if a.Description == "" || a.Score == nil {
			t.Errorf("annotation %d is missing description or score: %+v", i, a)
		}
	}
	if n := len(out.Responses[0].LabelAnnotations); n > 15 {
		t.Errorf("returned %d labels, more than the requested maxResults of 15", n)
	}
}

func TestGoogleVisionRequiresAKey(t *testing.T) {
	srv := newServer(t)
	resp, err := srv.Client().Post(srv.URL+"/v1/images:annotate", "application/json",
		bytes.NewBufferString(`{"requests":[{"image":{"content":"aGk="}}]}`))
	if err != nil {
		t.Fatalf("post: %v", err)
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusUnauthorized {
		t.Errorf("status %d, want 401", resp.StatusCode)
	}
}

// ── Custom provider ─────────────────────────────────────────────────────────

func TestCustomProviderShapeMatchesTheGatewayParser(t *testing.T) {
	srv := newServer(t)

	for _, task := range []string{"disease", "pest", "nutrient_deficiency", "classification"} {
		t.Run(task, func(t *testing.T) {
			results := analyze(t, srv, task, []byte("a picture of a sick leaf"))
			if len(results) == 0 {
				t.Fatal("no results; the gateway would fail to parse this")
			}
			for i, r := range results {
				// label and confidence are required by the gateway's
				// filter_map: an entry missing either is dropped without a
				// word, which looks identical to the model finding nothing.
				if r.Label == "" {
					t.Errorf("result %d has no label; the gateway would drop it", i)
				}
				if r.Confidence == nil {
					t.Errorf("result %d has no confidence; the gateway would drop it", i)
				} else if *r.Confidence <= 0 || *r.Confidence > 1 {
					t.Errorf("result %d: confidence %f outside (0,1]", i, *r.Confidence)
				}
			}
			// The lead should be clearly ahead, so a UI showing only the top
			// answer has something meaningful to show.
			if len(results) > 1 && *results[0].Confidence <= *results[1].Confidence {
				t.Errorf("leading result %f is not ahead of the runner-up %f",
					*results[0].Confidence, *results[1].Confidence)
			}
		})
	}
}

func TestCustomProviderCarriesSeverityAndTreatment(t *testing.T) {
	srv := newServer(t)
	// The disease catalogue is the one that has to carry severity and
	// recommendations through, because that is what the diagnosis screen shows.
	results := analyze(t, srv, "disease", []byte("blighted tomato leaf"))

	var withTreatment int
	for _, r := range results {
		if r.Severity == "" {
			t.Errorf("%q has no severity", r.Label)
		}
		if len(r.Recommendations) > 0 {
			withTreatment++
		}
	}
	if withTreatment == 0 {
		t.Error("no result carried recommendations; the treatment panel would always render empty")
	}
}

func TestSameImageGivesTheSameDiagnosis(t *testing.T) {
	srv := newServer(t)
	image := []byte("a specific photograph")

	first := analyze(t, srv, "disease", image)
	second := analyze(t, srv, "disease", image)
	if first[0].Label != second[0].Label || *first[0].Confidence != *second[0].Confidence {
		t.Errorf("the same image gave two answers: %q/%f then %q/%f",
			first[0].Label, *first[0].Confidence, second[0].Label, *second[0].Confidence)
	}

	// And different images must be able to give different answers, or the
	// image bytes are not reaching the selection at all.
	var differs bool
	for i := 0; i < 12; i++ {
		other := analyze(t, srv, "disease", []byte{byte(i), byte(i * 7), 'x'})
		if other[0].Label != first[0].Label {
			differs = true
			break
		}
	}
	if !differs {
		t.Error("twelve different images all produced the same diagnosis")
	}
}

func TestCustomProviderRequiresBearerToken(t *testing.T) {
	srv := newServer(t)
	resp, err := srv.Client().Post(srv.URL+"/analyze", "application/json",
		bytes.NewBufferString(`{"image":"aGk=","task":"disease","format":"base64"}`))
	if err != nil {
		t.Fatalf("post: %v", err)
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusUnauthorized {
		t.Errorf("status %d, want 401", resp.StatusCode)
	}
}

// ── Routing ─────────────────────────────────────────────────────────────────

func TestUnknownPathExplainsWhatIsServed(t *testing.T) {
	srv := newServer(t)
	resp, err := srv.Client().Get(srv.URL + "/v3/forecast")
	if err != nil {
		t.Fatalf("get: %v", err)
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusNotFound {
		t.Fatalf("status %d, want 404", resp.StatusCode)
	}

	var body struct {
		Served []mockapi.Route `json:"served"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&body); err != nil {
		t.Fatalf("decode: %v", err)
	}
	// A 404 here nearly always means a base URL was pointed at the wrong path,
	// so the response listing the real ones saves the guessing.
	if len(body.Served) == 0 {
		t.Error("the 404 body does not list the served routes")
	}
}

// ── helpers ─────────────────────────────────────────────────────────────────

type analyzeResult struct {
	Label           string   `json:"label"`
	Confidence      *float64 `json:"confidence"`
	Severity        string   `json:"severity"`
	Recommendations []string `json:"recommendations"`
}

func analyze(t *testing.T, srv *httptest.Server, task string, image []byte) []analyzeResult {
	t.Helper()
	payload, err := json.Marshal(map[string]string{
		"image":  base64.StdEncoding.EncodeToString(image),
		"task":   task,
		"format": "base64",
	})
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}
	req, err := http.NewRequest(http.MethodPost, srv.URL+"/analyze", bytes.NewReader(payload))
	if err != nil {
		t.Fatalf("request: %v", err)
	}
	req.Header.Set("Authorization", "Bearer mock")
	req.Header.Set("Content-Type", "application/json")

	resp, err := srv.Client().Do(req)
	if err != nil {
		t.Fatalf("post: %v", err)
	}
	defer resp.Body.Close()
	if resp.StatusCode != 200 {
		body, _ := io.ReadAll(resp.Body)
		t.Fatalf("status %d: %s", resp.StatusCode, body)
	}

	var out struct {
		Results []analyzeResult `json:"results"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&out); err != nil {
		t.Fatalf("decode: %v", err)
	}
	return out.Results
}

func setFault(t *testing.T, srv *httptest.Server, provider, body string) {
	t.Helper()
	resp, err := srv.Client().Post(srv.URL+"/__mock/faults?provider="+provider,
		"application/json", bytes.NewBufferString(body))
	if err != nil {
		t.Fatalf("set fault: %v", err)
	}
	defer resp.Body.Close()
	if resp.StatusCode != 200 {
		t.Fatalf("set fault: status %d", resp.StatusCode)
	}
}

func multipartImageBody(t *testing.T, field string, content []byte) (*bytes.Buffer, string) {
	t.Helper()
	var buf bytes.Buffer
	w := multipart.NewWriter(&buf)
	part, err := w.CreateFormFile(field, "image.jpg")
	if err != nil {
		t.Fatalf("form file: %v", err)
	}
	if _, err := part.Write(content); err != nil {
		t.Fatalf("write: %v", err)
	}
	if err := w.Close(); err != nil {
		t.Fatalf("close: %v", err)
	}
	return &buf, w.FormDataContentType()
}

func keysOf(m map[string]json.RawMessage) []string {
	out := make([]string, 0, len(m))
	for k := range m {
		out = append(out, k)
	}
	return out
}
