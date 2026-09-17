// Package tools binds the assistant to the services that already hold the
// answers.
//
// The point of this package is that the assistant does not have to know
// agronomy it was never taught. When a farmer asks whether to irrigate, the
// irrigation service has run a water balance on that field's own soil moisture
// and reference ET; a language model asked the same question from a paragraph
// of crop guide will produce a plausible sentence instead. Every tool here
// returns what a real service computed, and the figure is stored on the
// exchange so it can be checked against that service afterwards.
//
// Tenant isolation is not re-implemented here. Each client propagates the
// caller's request context, so the downstream service applies its own
// authentication and row-level security to the call — the assistant can only
// ever see what the person asking could have seen by opening the app.
package tools

import (
	"net/http"

	"connectrpc.com/connect"

	connectclient "p9e.in/samavaya/packages/connect/client"

	alertv1connect "p9e.in/samavaya/agriculture/alert-service/api/v1/v1connect"
	fieldv1connect "p9e.in/samavaya/agriculture/field-service/api/v1/fieldv1connect"
	irrigationv1connect "p9e.in/samavaya/agriculture/irrigation-service/api/v1/irrigationv1connect"
	pestv1connect "p9e.in/samavaya/agriculture/pest-prediction-service/api/v1/pestpredictionv1connect"
	diagnosisv1connect "p9e.in/samavaya/agriculture/plant-diagnosis-service/api/v1/plantdiagnosisv1connect"
	prescriptionv1connect "p9e.in/samavaya/agriculture/prescription-service/api/v1/v1connect"
	weatherv1connect "p9e.in/samavaya/agriculture/weather-service/api/v1/weatherv1connect"
	yieldv1connect "p9e.in/samavaya/agriculture/yield-service/api/v1/yieldv1connect"
)

// Endpoints is the set of peer services the assistant can reach.
//
// Every one is optional. A deployment that has not rolled out pest-prediction
// yet gets an assistant with one fewer tool, not an assistant that fails to
// start — and the tool list the model is shown contains only what is actually
// reachable, so it cannot call something that is not there and then have to
// explain the error to a farmer.
type Endpoints struct {
	FieldURL        string
	YieldURL        string
	IrrigationURL   string
	PestURL         string
	WeatherURL      string
	AlertURL        string
	PrescriptionURL string
	DiagnosisURL    string
}

// Clients holds the Connect clients for whichever endpoints were configured.
type Clients struct {
	Field        fieldv1connect.FieldServiceClient
	Yield        yieldv1connect.YieldServiceClient
	Irrigation   irrigationv1connect.IrrigationServiceClient
	Pest         pestv1connect.PestPredictionServiceClient
	Weather      weatherv1connect.WeatherServiceClient
	Alert        alertv1connect.AlertServiceClient
	Prescription prescriptionv1connect.PrescriptionServiceClient
	Diagnosis    diagnosisv1connect.PlantDiagnosisServiceClient
}

// NewClients builds clients for every endpoint that was configured.
func NewClients(e Endpoints) *Clients {
	c := &Clients{}

	with := func(url string, build func(*http.Client, string, ...connect.ClientOption)) {
		if url == "" {
			return
		}
		build(connectclient.NewHTTPClient(connectclient.DefaultConfig(url)), url,
			// The interceptor is what carries the caller's identity and tenant
			// downstream. Without it every tool call would arrive at the peer
			// service unauthenticated, and the peer would either reject it or,
			// worse, answer it without a tenant scope.
			connect.WithInterceptors(connectclient.ContextPropagator()))
	}

	with(e.FieldURL, func(h *http.Client, url string, opts ...connect.ClientOption) {
		c.Field = fieldv1connect.NewFieldServiceClient(h, url, opts...)
	})
	with(e.YieldURL, func(h *http.Client, url string, opts ...connect.ClientOption) {
		c.Yield = yieldv1connect.NewYieldServiceClient(h, url, opts...)
	})
	with(e.IrrigationURL, func(h *http.Client, url string, opts ...connect.ClientOption) {
		c.Irrigation = irrigationv1connect.NewIrrigationServiceClient(h, url, opts...)
	})
	with(e.PestURL, func(h *http.Client, url string, opts ...connect.ClientOption) {
		c.Pest = pestv1connect.NewPestPredictionServiceClient(h, url, opts...)
	})
	with(e.WeatherURL, func(h *http.Client, url string, opts ...connect.ClientOption) {
		c.Weather = weatherv1connect.NewWeatherServiceClient(h, url, opts...)
	})
	with(e.AlertURL, func(h *http.Client, url string, opts ...connect.ClientOption) {
		c.Alert = alertv1connect.NewAlertServiceClient(h, url, opts...)
	})
	with(e.PrescriptionURL, func(h *http.Client, url string, opts ...connect.ClientOption) {
		c.Prescription = prescriptionv1connect.NewPrescriptionServiceClient(h, url, opts...)
	})
	with(e.DiagnosisURL, func(h *http.Client, url string, opts ...connect.ClientOption) {
		c.Diagnosis = diagnosisv1connect.NewPlantDiagnosisServiceClient(h, url, opts...)
	})

	return c
}
