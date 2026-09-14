// Command mockserver serves stand-ins for the external APIs this platform
// depends on, so that development and tests can run without network access,
// API keys, or somebody else's rate limit.
//
// It serves Open-Meteo (forecast and archive), OpenWeather One Call 3.0,
// PlantNet, Google Cloud Vision, and the ai-gateway's own "custom" vision
// provider, all on one port, at the paths the real services use.
//
// Point services at it by overriding their base URLs:
//
//	OPEN_METEO_FORECAST_URL=http://localhost:8199/v1/forecast
//	OPEN_METEO_ARCHIVE_URL=http://localhost:8199/v1/archive
//	OPENWEATHER_BASE_URL=http://localhost:8199/data/3.0/onecall
//	OPENWEATHER_API_KEY=mock
//
// The ai-gateway takes its vision provider from a TOML file rather than the
// environment, so point AI_GATEWAY_CONFIG at one containing:
//
//	[external_api]
//	enabled  = true
//	provider = "custom"          # or "plantnet" / "google_vision"
//	base_url = "http://localhost:8199"
//	api_key  = "mock"
//
// Responses are deterministic functions of their inputs — the same coordinates
// and date always produce the same weather, the same image always produces the
// same diagnosis — so they can be asserted against in tests.
//
// Faults can be injected at runtime to exercise retry and timeout paths:
//
//	# the next two Open-Meteo calls fail, the third succeeds
//	curl -X POST 'localhost:8199/__mock/faults?provider=openmeteo' \
//	     -d '{"status":503,"remaining":2}'
//
//	# PlantNet answers, but takes five seconds about it
//	curl -X POST 'localhost:8199/__mock/faults?provider=plantnet' \
//	     -d '{"delay_ms":5000}'
//
//	curl -X DELETE localhost:8199/__mock/faults
//
// Go tests can skip the binary entirely and use the package directly; see
// internal/mockapi.
package main

import (
	"context"
	"errors"
	"flag"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"p9e.in/samavaya/agriculture/internal/mockapi"
)

func main() {
	addr := flag.String("addr", envOr("MOCKSERVER_ADDR", ":8199"), "listen address")
	verbose := flag.Bool("v", false, "log every request")
	frozen := flag.String("now", os.Getenv("MOCKSERVER_NOW"),
		"freeze the clock at this RFC3339 time, so forecast windows stay reproducible across runs")
	omitET0 := flag.Bool("omit-et0", os.Getenv("MOCKSERVER_OMIT_ET0") != "",
		"return zero for Open-Meteo reference evapotranspiration, so the weather service takes its local recomputation path")
	flag.Parse()

	opts := mockapi.Options{OmitET0: *omitET0}
	if *frozen != "" {
		t, err := time.Parse(time.RFC3339, *frozen)
		if err != nil {
			log.Fatalf("-now: %v", err)
		}
		opts.Now = func() time.Time { return t }
		log.Printf("clock frozen at %s", t.Format(time.RFC3339))
	}

	var handler http.Handler = mockapi.New(opts).Handler()
	if *verbose {
		handler = logging(handler)
	}

	srv := &http.Server{
		Addr:              *addr,
		Handler:           handler,
		ReadHeaderTimeout: 10 * time.Second,
		// No write timeout on purpose: the delay fault is meant to hold a
		// response open for longer than any sane server would.
	}

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	go func() {
		log.Printf("mockserver listening on %s", *addr)
		for _, r := range mockapi.Routes {
			log.Printf("  %-7s %-24s %s", r.Method, r.Path, r.Provider)
		}
		if err := srv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			log.Fatalf("listen: %v", err)
		}
	}()

	<-ctx.Done()
	shutdown, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	_ = srv.Shutdown(shutdown)
	log.Print("mockserver stopped")
}

func logging(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		rec := &statusRecorder{ResponseWriter: w, status: http.StatusOK}
		start := time.Now()
		next.ServeHTTP(rec, r)
		log.Printf("%s %s%s -> %d (%s)",
			r.Method, r.URL.Path, query(r.URL.RawQuery), rec.status, time.Since(start).Round(time.Millisecond))
	})
}

func query(raw string) string {
	if raw == "" {
		return ""
	}
	if len(raw) > 120 {
		raw = raw[:120] + "…"
	}
	return "?" + raw
}

type statusRecorder struct {
	http.ResponseWriter
	status int
}

func (r *statusRecorder) WriteHeader(code int) {
	r.status = code
	r.ResponseWriter.WriteHeader(code)
}

func envOr(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
