// Package mockapi stands in for the external APIs this platform depends on, so
// that development and tests can run without network access, API keys, or
// somebody else's rate limit.
//
// It serves Open-Meteo (forecast and archive), OpenWeather One Call 3.0,
// PlantNet, Google Cloud Vision, and the ai-gateway's own "custom" vision
// provider, at the paths those services really use.
//
// Responses are deterministic functions of their inputs — the same coordinates
// and date always produce the same weather, the same image bytes always produce
// the same diagnosis — which is what makes them worth asserting against.
//
// It is a package rather than only a binary so that a Go test can stand an
// upstream up in-process:
//
//	srv := httptest.NewServer(mockapi.New(mockapi.Options{}).Handler())
//	defer srv.Close()
//	provider := providers.NewOpenMeteo(srv.Client(), srv.URL+"/v1/forecast", srv.URL+"/v1/archive")
//
// Command cmd/mockserver wraps the same handler in a standalone process for
// use from docker-compose or a developer's shell.
package mockapi

import (
	"net/http"
	"time"
)

// Options configures a mock server.
type Options struct {
	// Now supplies the current time. Overriding it freezes forecast windows,
	// which is what makes "the same request gives the same answer" true across
	// runs rather than only within one. Defaults to time.Now.
	Now func() time.Time

	// OmitET0 makes Open-Meteo return zero for reference evapotranspiration,
	// as the real API does outside its supported range.
	//
	// This is a server option rather than a query parameter because the
	// adapter builds its own query string onto the configured base URL, so
	// anything smuggled in there would be appended after a second "?" and
	// ignored. Withholding ET0 is what makes weather-service take its local
	// recomputation path instead of reading the value from the response;
	// without the switch, half of that logic cannot be reached offline.
	OmitET0 bool
}

// Server holds the mock's state: the handlers and whatever faults are
// currently configured.
type Server struct {
	faults  *faultStore
	weather *weatherHandlers
	vision  *visionHandlers
	now     func() time.Time
}

// New creates a mock server.
func New(opts Options) *Server {
	now := opts.Now
	if now == nil {
		now = time.Now
	}
	faults := newFaultStore()
	return &Server{
		faults:  faults,
		weather: &weatherHandlers{faults: faults, now: now, omitET0: opts.OmitET0},
		vision:  &visionHandlers{faults: faults},
		now:     now,
	}
}

// Handler returns the mux serving every mocked provider, plus the control
// endpoints under /__mock/.
func (s *Server) Handler() http.Handler {
	mux := http.NewServeMux()

	// Open-Meteo.
	mux.HandleFunc("GET /v1/forecast", s.weather.handleOpenMeteoForecast)
	mux.HandleFunc("GET /v1/archive", s.weather.handleOpenMeteoArchive)

	// OpenWeather One Call 3.0.
	mux.HandleFunc("GET /data/3.0/onecall", s.weather.handleOpenWeather)

	// PlantNet. The v2 prefix belongs to the configured base URL rather than to
	// the path the client appends, so both spellings are accepted — getting
	// that boundary wrong is otherwise a confusing 404.
	mux.HandleFunc("POST /v2/identify/all", s.vision.handlePlantNet)
	mux.HandleFunc("POST /identify/all", s.vision.handlePlantNet)

	// Google Cloud Vision.
	mux.HandleFunc("POST /v1/images:annotate", s.vision.handleGoogleVision)

	// The ai-gateway's own provider shape.
	mux.HandleFunc("POST /analyze", s.vision.handleCustomAnalyze)

	// Control and introspection.
	mux.HandleFunc("/__mock/faults", s.faults.handleFaults)
	mux.HandleFunc("GET /__mock/health", func(w http.ResponseWriter, r *http.Request) {
		writeJSON(w, http.StatusOK, map[string]any{"status": "ok", "now": s.now().UTC()})
	})
	mux.HandleFunc("GET /__mock/routes", func(w http.ResponseWriter, r *http.Request) {
		writeJSON(w, http.StatusOK, Routes)
	})
	mux.HandleFunc("/", notFound)

	return mux
}

// SetFault installs a fault for a provider, as the /__mock/faults endpoint
// does, for tests that would rather not make an HTTP call to arrange one.
//
// Provider names are "openmeteo", "openweather", "plantnet", "vision",
// "custom", and "all" for anything without a more specific entry.
func (s *Server) SetFault(provider string, f *Fault) { s.faults.set(provider, f) }

// ClearFaults removes every configured fault.
func (s *Server) ClearFaults() { s.faults.clear() }

// Route describes one mocked endpoint.
type Route struct {
	Method   string `json:"method"`
	Path     string `json:"path"`
	Provider string `json:"provider"`
}

// Routes is what the mock serves, in the order it is worth reading.
var Routes = []Route{
	{"GET", "/v1/forecast", "open-meteo (forecast)"},
	{"GET", "/v1/archive", "open-meteo (archive)"},
	{"GET", "/data/3.0/onecall", "openweather one call 3.0"},
	{"POST", "/v2/identify/all", "plantnet"},
	{"POST", "/v1/images:annotate", "google cloud vision"},
	{"POST", "/analyze", "custom vision provider"},
	{"GET", "/__mock/health", "mockserver"},
	{"GET", "/__mock/routes", "mockserver"},
	{"*", "/__mock/faults", "mockserver (fault injection)"},
}

func notFound(w http.ResponseWriter, r *http.Request) {
	// A 404 here almost always means a base URL was configured with the wrong
	// path rather than that the mock lacks a provider, so say what is served.
	writeJSON(w, http.StatusNotFound, map[string]any{
		"error":  "no mock for this path",
		"path":   r.URL.Path,
		"method": r.Method,
		"served": Routes,
	})
}
