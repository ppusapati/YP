package main

// This file contains service module registration functions. Each function
// creates the service's repositories, application services, and handlers,
// then registers the ConnectRPC (or plain HTTP) handler on the shared mux.

import (
	"crypto/rand"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"net/http"
	"strings"
	"time"

	"connectrpc.com/connect"
	"github.com/golang-jwt/jwt/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"go.uber.org/zap"
	"golang.org/x/crypto/bcrypt"

	"p9e.in/samavaya/packages/authz"
	connectclient "p9e.in/samavaya/packages/connect/client"
	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/middleware"
	"p9e.in/samavaya/packages/outbox"
	_ "p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	// ── Generated ConnectRPC packages (named) ───────────────────────────────
	farmv1connect           "p9e.in/samavaya/agriculture/farm-service/api/v1/farmv1connect"
	fieldv1connect          "p9e.in/samavaya/agriculture/field-service/api/v1/fieldv1connect"
	cropv1connect           "p9e.in/samavaya/agriculture/crop-service/api/v1/cropv1connect"
	sensorv1connect         "p9e.in/samavaya/agriculture/sensor-service/api/v1/sensorv1connect"
	soilv1connect           "p9e.in/samavaya/agriculture/soil-service/api/v1/soilv1connect"
	irrigationv1connect     "p9e.in/samavaya/agriculture/irrigation-service/api/v1/irrigationv1connect"
	yieldv1connect          "p9e.in/samavaya/agriculture/yield-service/api/v1/yieldv1connect"
	satellitev1connect      "p9e.in/samavaya/agriculture/satellite-service/api/v1/satellitev1connect"
	pestpredictionv1connect "p9e.in/samavaya/agriculture/pest-prediction-service/api/v1/pestpredictionv1connect"
	plantdiagnosisv1connect "p9e.in/samavaya/agriculture/plant-diagnosis-service/api/v1/plantdiagnosisv1connect"
	traceabilityv1connect   "p9e.in/samavaya/agriculture/traceability-service/api/v1/traceabilityv1connect"
	commercev1connect       "p9e.in/samavaya/agriculture/commerce-service/api/v1/commercev1connect"

	// ── Generated ConnectRPC packages (aliased — all named v1connect) ───────
	alertv1connect         "p9e.in/samavaya/agriculture/alert-service/api/v1/v1connect"
	analyticsv1connect     "p9e.in/samavaya/agriculture/analytics-service/api/v1/v1connect"
	prescriptionv1connect  "p9e.in/samavaya/agriculture/prescription-service/api/v1/v1connect"
	agronomyv1connect      "p9e.in/samavaya/agriculture/agronomy-service/api/v1/v1connect"
	taskv1connect          "p9e.in/samavaya/agriculture/task-service/api/v1/v1connect"
	vegetationv1connect    "p9e.in/samavaya/agriculture/vegetation-index-service/api/v1/v1connect"
	satanalyticsv1connect  "p9e.in/samavaya/agriculture/satellite-analytics-service/api/v1/v1connect"
	sattilev1connect       "p9e.in/samavaya/agriculture/satellite-tile-service/api/v1/v1connect"
	satingestionv1connect  "p9e.in/samavaya/agriculture/satellite-ingestion-service/api/v1/v1connect"
	satprocessingv1connect "p9e.in/samavaya/agriculture/satellite-processing-service/api/v1/v1connect"

	// ── Hexagonal service adapters — farm ────────────────────────────────────
	farmgrpc     "p9e.in/samavaya/agriculture/farm-service/adapters/inbound/grpc"
	farmpostgres "p9e.in/samavaya/agriculture/farm-service/adapters/outbound/postgres"
	farmapp      "p9e.in/samavaya/agriculture/farm-service/application"

	// ── Hexagonal service adapters — field ───────────────────────────────────
	fieldgrpc     "p9e.in/samavaya/agriculture/field-service/adapters/inbound/grpc"
	fieldclients  "p9e.in/samavaya/agriculture/field-service/adapters/outbound/clients"
	fieldpostgres "p9e.in/samavaya/agriculture/field-service/adapters/outbound/postgres"
	fieldapp      "p9e.in/samavaya/agriculture/field-service/application"

	// ── Hexagonal service adapters — crop ────────────────────────────────────
	cropgrpc     "p9e.in/samavaya/agriculture/crop-service/adapters/inbound/grpc"
	croppostgres "p9e.in/samavaya/agriculture/crop-service/adapters/outbound/postgres"
	cropapp      "p9e.in/samavaya/agriculture/crop-service/application"

	// ── Hexagonal service adapters — sensor ──────────────────────────────────
	sensorgrpc     "p9e.in/samavaya/agriculture/sensor-service/adapters/inbound/grpc"
	sensorclients  "p9e.in/samavaya/agriculture/sensor-service/adapters/outbound/clients"
	sensorpostgres "p9e.in/samavaya/agriculture/sensor-service/adapters/outbound/postgres"
	sensorapp      "p9e.in/samavaya/agriculture/sensor-service/application"

	// ── Hexagonal service adapters — soil ────────────────────────────────────
	soilgrpc     "p9e.in/samavaya/agriculture/soil-service/adapters/inbound/grpc"
	soilclients  "p9e.in/samavaya/agriculture/soil-service/adapters/outbound/clients"
	soilpostgres "p9e.in/samavaya/agriculture/soil-service/adapters/outbound/postgres"
	soilapp      "p9e.in/samavaya/agriculture/soil-service/application"

	// ── Hexagonal service adapters — irrigation ─────────────────────────────
	irrigationgrpc     "p9e.in/samavaya/agriculture/irrigation-service/adapters/inbound/grpc"
	irrigationclients  "p9e.in/samavaya/agriculture/irrigation-service/adapters/outbound/clients"
	irrigationpostgres "p9e.in/samavaya/agriculture/irrigation-service/adapters/outbound/postgres"
	irrigationapp      "p9e.in/samavaya/agriculture/irrigation-service/application"

	// ── Hexagonal service adapters — yield ───────────────────────────────────
	yieldgrpc     "p9e.in/samavaya/agriculture/yield-service/adapters/inbound/grpc"
	yieldclients  "p9e.in/samavaya/agriculture/yield-service/adapters/outbound/clients"
	yieldpostgres "p9e.in/samavaya/agriculture/yield-service/adapters/outbound/postgres"
	yieldapp      "p9e.in/samavaya/agriculture/yield-service/application"

	// ── Hexagonal service adapters — satellite ──────────────────────────────
	satellitegrpc     "p9e.in/samavaya/agriculture/satellite-service/adapters/inbound/grpc"
	satelliteclients  "p9e.in/samavaya/agriculture/satellite-service/adapters/outbound/clients"
	satellitepostgres "p9e.in/samavaya/agriculture/satellite-service/adapters/outbound/postgres"
	satelliteapp      "p9e.in/samavaya/agriculture/satellite-service/application"

	// ── Hexagonal service adapters — pest-prediction ────────────────────────
	pestgrpc     "p9e.in/samavaya/agriculture/pest-prediction-service/adapters/inbound/grpc"
	pestclients  "p9e.in/samavaya/agriculture/pest-prediction-service/adapters/outbound/clients"
	pestpostgres "p9e.in/samavaya/agriculture/pest-prediction-service/adapters/outbound/postgres"
	pestapp      "p9e.in/samavaya/agriculture/pest-prediction-service/application"

	// ── Hexagonal service adapters — plant-diagnosis ────────────────────────
	diagnosisgrpc     "p9e.in/samavaya/agriculture/plant-diagnosis-service/adapters/inbound/grpc"
	diagnosisclients  "p9e.in/samavaya/agriculture/plant-diagnosis-service/adapters/outbound/clients"
	diagnosispostgres "p9e.in/samavaya/agriculture/plant-diagnosis-service/adapters/outbound/postgres"
	diagnosisapp      "p9e.in/samavaya/agriculture/plant-diagnosis-service/application"

	// ── Hexagonal service adapters — traceability ───────────────────────────
	traceabilitygrpc     "p9e.in/samavaya/agriculture/traceability-service/adapters/inbound/grpc"
	traceabilityclients  "p9e.in/samavaya/agriculture/traceability-service/adapters/outbound/clients"
	traceabilitypostgres "p9e.in/samavaya/agriculture/traceability-service/adapters/outbound/postgres"
	traceabilityapp      "p9e.in/samavaya/agriculture/traceability-service/application"

	// ── Hexagonal service adapters — commerce ───────────────────────────────
	commercegrpc     "p9e.in/samavaya/agriculture/commerce-service/adapters/inbound/grpc"
	commercepostgres "p9e.in/samavaya/agriculture/commerce-service/adapters/outbound/postgres"
	commerceapp      "p9e.in/samavaya/agriculture/commerce-service/application"

	// ── Deps-based services — task ──────────────────────────────────────────
	taskhandlers "p9e.in/samavaya/agriculture/task-service/handlers"
	taskrepos    "p9e.in/samavaya/agriculture/task-service/repositories"
	taskservices "p9e.in/samavaya/agriculture/task-service/services"

	// ── Deps-based services — agronomy ──────────────────────────────────────
	agronomyhandlers "p9e.in/samavaya/agriculture/agronomy-service/handlers"
	agronomyrepos    "p9e.in/samavaya/agriculture/agronomy-service/repositories"
	agronomyservices "p9e.in/samavaya/agriculture/agronomy-service/services"

	// ── Deps-based services — vegetation-index ──────────────────────────────
	vegetationhandlers "p9e.in/samavaya/agriculture/vegetation-index-service/handlers"
	vegetationrepos    "p9e.in/samavaya/agriculture/vegetation-index-service/repositories"
	vegetationservices "p9e.in/samavaya/agriculture/vegetation-index-service/services"

	// ── Deps-based services — satellite-analytics ───────────────────────────
	satanalyticshandlers "p9e.in/samavaya/agriculture/satellite-analytics-service/handlers"
	satanalyticsrepos    "p9e.in/samavaya/agriculture/satellite-analytics-service/repositories"
	satanalyticsservices "p9e.in/samavaya/agriculture/satellite-analytics-service/services"

	// ── Deps-based services — satellite-tile ────────────────────────────────
	sattilehandlers "p9e.in/samavaya/agriculture/satellite-tile-service/handlers"
	sattilerepos    "p9e.in/samavaya/agriculture/satellite-tile-service/repositories"
	sattileservices "p9e.in/samavaya/agriculture/satellite-tile-service/services"

	// ── Deps-based services — satellite-ingestion ───────────────────────────
	satingestionhandlers "p9e.in/samavaya/agriculture/satellite-ingestion-service/handlers"
	satingestionrepos    "p9e.in/samavaya/agriculture/satellite-ingestion-service/repositories"
	satingestionservices "p9e.in/samavaya/agriculture/satellite-ingestion-service/services"

	// ── Deps-based services — satellite-processing ──────────────────────────
	satprocessinghandlers "p9e.in/samavaya/agriculture/satellite-processing-service/handlers"
	satprocessingrepos    "p9e.in/samavaya/agriculture/satellite-processing-service/repositories"
	satprocessingservices "p9e.in/samavaya/agriculture/satellite-processing-service/services"

	// ── Stateless services — alert ──────────────────────────────────────────
	alerthandlers "p9e.in/samavaya/agriculture/alert-service/handlers"
	alertservices "p9e.in/samavaya/agriculture/alert-service/services"

	// ── Stateless services — analytics ──────────────────────────────────────
	analyticshandlers "p9e.in/samavaya/agriculture/analytics-service/handlers"
	analyticsservices "p9e.in/samavaya/agriculture/analytics-service/services"

	// ── Stateless services — prescription ───────────────────────────────────
	prescriptionhandlers "p9e.in/samavaya/agriculture/prescription-service/handlers"
	prescriptionservices "p9e.in/samavaya/agriculture/prescription-service/services"
)

// ═══════════════════════════════════════════════════════════════════════════════
// Hexagonal services — full adapter wiring with database
// ═══════════════════════════════════════════════════════════════════════════════

func registerFarmModule(mux *http.ServeMux, infra *sharedInfra) {
	repo := farmpostgres.NewFarmRepository(infra.pool, infra.logger)
	outboxPub := outbox.NewPublisher(infra.pool, infra.zapLogger)
	svc := farmapp.NewFarmService(repo, outboxPub, infra.pool, infra.logger, nil)
	handler := farmgrpc.NewFarmHandler(svc, infra.logger)

	path, h := farmv1connect.NewFarmServiceHandler(handler,
		connect.WithInterceptors(
			middleware.MetricsInterceptor("farm-service"),
			middleware.TracingInterceptor("farm-service"),
		),
		infra.connectOpt,
	)
	mux.Handle(path, h)
}

func registerFieldModule(mux *http.ServeMux, infra *sharedInfra) {
	repo := fieldpostgres.NewFieldRepository(infra.pool, infra.logger)
	outboxPub := outbox.NewPublisher(infra.pool, infra.zapLogger)

	clientOpt := connect.WithInterceptors(connectclient.ContextPropagator())
	farmClient := fieldclients.NewFarmClient(
		infra.baseURL,
		connectclient.NewHTTPClient(connectclient.DefaultConfig(infra.baseURL)),
		clientOpt,
	)
	cropClient := fieldclients.NewCropClient(
		infra.baseURL,
		connectclient.NewHTTPClient(connectclient.DefaultConfig(infra.baseURL)),
		clientOpt,
	)

	svc := fieldapp.NewFieldService(repo, outboxPub, farmClient, cropClient, infra.pool, infra.logger, nil)
	handler := fieldgrpc.NewFieldHandler(svc, infra.logger)

	path, h := fieldv1connect.NewFieldServiceHandler(handler,
		connect.WithInterceptors(
			middleware.MetricsInterceptor("field-service"),
			middleware.TracingInterceptor("field-service"),
		),
		infra.connectOpt,
	)
	mux.Handle(path, h)
}

func registerCropModule(mux *http.ServeMux, infra *sharedInfra) {
	repo := croppostgres.NewCropRepository(infra.pool, infra.logger)
	outboxPub := outbox.NewPublisher(infra.pool, infra.zapLogger)
	svc := cropapp.NewCropService(repo, outboxPub, infra.pool, infra.logger, nil)
	handler := cropgrpc.NewCropHandler(svc, infra.logger)

	path, h := cropv1connect.NewCropServiceHandler(handler,
		connect.WithInterceptors(
			middleware.MetricsInterceptor("crop-service"),
			middleware.TracingInterceptor("crop-service"),
		),
		infra.connectOpt,
	)
	mux.Handle(path, h)
}

func registerSensorModule(mux *http.ServeMux, infra *sharedInfra) {
	repo := sensorpostgres.NewSensorRepository(infra.pool, infra.logger)
	outboxPub := outbox.NewPublisher(infra.pool, infra.zapLogger)

	clientOpt := connect.WithInterceptors(connectclient.ContextPropagator())
	fieldClient := sensorclients.NewFieldClient(
		infra.baseURL,
		connectclient.NewHTTPClient(connectclient.DefaultConfig(infra.baseURL)),
		clientOpt,
	)
	farmClient := sensorclients.NewFarmClient(
		infra.baseURL,
		connectclient.NewHTTPClient(connectclient.DefaultConfig(infra.baseURL)),
		clientOpt,
	)

	svc := sensorapp.NewSensorService(repo, outboxPub, fieldClient, farmClient, infra.pool, infra.logger)
	handler := sensorgrpc.NewSensorHandler(svc, infra.logger)

	path, h := sensorv1connect.NewSensorServiceHandler(handler,
		connect.WithInterceptors(
			middleware.MetricsInterceptor("sensor-service"),
			middleware.TracingInterceptor("sensor-service"),
		),
		infra.connectOpt,
	)
	mux.Handle(path, h)
}

func registerSoilModule(mux *http.ServeMux, infra *sharedInfra) {
	repo := soilpostgres.NewSoilRepository(infra.pool, infra.logger)
	outboxPub := outbox.NewPublisher(infra.pool, infra.zapLogger)

	clientOpt := connect.WithInterceptors(connectclient.ContextPropagator())
	fieldClient := soilclients.NewFieldClient(
		infra.baseURL,
		connectclient.NewHTTPClient(connectclient.DefaultConfig(infra.baseURL)),
		clientOpt,
	)
	farmClient := soilclients.NewFarmClient(
		infra.baseURL,
		connectclient.NewHTTPClient(connectclient.DefaultConfig(infra.baseURL)),
		clientOpt,
	)

	svc := soilapp.NewSoilService(repo, outboxPub, fieldClient, farmClient, infra.pool, infra.logger)
	handler := soilgrpc.NewSoilHandler(svc, infra.logger)

	path, h := soilv1connect.NewSoilServiceHandler(handler,
		connect.WithInterceptors(
			middleware.MetricsInterceptor("soil-service"),
			middleware.TracingInterceptor("soil-service"),
		),
		infra.connectOpt,
	)
	mux.Handle(path, h)
}

func registerIrrigationModule(mux *http.ServeMux, infra *sharedInfra) {
	repo := irrigationpostgres.NewIrrigationRepository(infra.pool, infra.logger)
	outboxPub := outbox.NewPublisher(infra.pool, infra.zapLogger)

	clientOpt := connect.WithInterceptors(connectclient.ContextPropagator())
	fieldClient := irrigationclients.NewFieldClient(
		infra.baseURL,
		connectclient.NewHTTPClient(connectclient.DefaultConfig(infra.baseURL)),
		clientOpt,
	)
	farmClient := irrigationclients.NewFarmClient(
		infra.baseURL,
		connectclient.NewHTTPClient(connectclient.DefaultConfig(infra.baseURL)),
		clientOpt,
	)

	svc := irrigationapp.NewIrrigationService(repo, outboxPub, fieldClient, farmClient, infra.pool, infra.logger)
	handler := irrigationgrpc.NewIrrigationHandler(svc, infra.logger)

	path, h := irrigationv1connect.NewIrrigationServiceHandler(handler,
		connect.WithInterceptors(
			middleware.MetricsInterceptor("irrigation-service"),
			middleware.TracingInterceptor("irrigation-service"),
		),
		infra.connectOpt,
	)
	mux.Handle(path, h)
}

func registerYieldModule(mux *http.ServeMux, infra *sharedInfra) {
	repo := yieldpostgres.NewYieldRepository(infra.pool, infra.logger)
	outboxPub := outbox.NewPublisher(infra.pool, infra.zapLogger)

	clientOpt := connect.WithInterceptors(connectclient.ContextPropagator())
	newClient := func() *http.Client {
		return connectclient.NewHTTPClient(connectclient.DefaultConfig(infra.baseURL))
	}
	fieldClient := yieldclients.NewFieldClient(infra.baseURL, newClient(), clientOpt)
	soilClient := yieldclients.NewSoilClient(infra.baseURL, newClient(), clientOpt)
	irrigationClient := yieldclients.NewIrrigationClient(infra.baseURL, newClient(), clientOpt)
	pestClient := yieldclients.NewPestClient(infra.baseURL, newClient(), clientOpt)
	cropClient := yieldclients.NewCropClient(infra.baseURL, newClient(), clientOpt)
	farmClient := yieldclients.NewFarmClient(infra.baseURL, newClient(), clientOpt)

	svc := yieldapp.NewYieldService(repo, outboxPub,
		fieldClient,
		soilClient,
		irrigationClient,
		pestClient,
		cropClient,
		farmClient,
		infra.pool, infra.logger, nil,
	)
	handler := yieldgrpc.NewYieldHandler(svc, infra.logger)

	path, h := yieldv1connect.NewYieldServiceHandler(handler,
		connect.WithInterceptors(
			middleware.MetricsInterceptor("yield-service"),
			middleware.TracingInterceptor("yield-service"),
		),
		infra.connectOpt,
	)
	mux.Handle(path, h)
}

func registerSatelliteModule(mux *http.ServeMux, infra *sharedInfra) {
	repo := satellitepostgres.NewSatelliteRepository(infra.pool, infra.logger)
	outboxPub := outbox.NewPublisher(infra.pool, infra.zapLogger)

	clientOpt := connect.WithInterceptors(connectclient.ContextPropagator())
	fieldClient := satelliteclients.NewFieldClient(
		infra.baseURL,
		connectclient.NewHTTPClient(connectclient.DefaultConfig(infra.baseURL)),
		clientOpt,
	)
	farmClient := satelliteclients.NewFarmClient(
		infra.baseURL,
		connectclient.NewHTTPClient(connectclient.DefaultConfig(infra.baseURL)),
		clientOpt,
	)

	svc := satelliteapp.NewSatelliteService(repo, outboxPub, fieldClient, farmClient, infra.pool, infra.logger)
	handler := satellitegrpc.NewSatelliteHandler(svc, infra.logger)

	path, h := satellitev1connect.NewSatelliteServiceHandler(handler,
		connect.WithInterceptors(
			middleware.MetricsInterceptor("satellite-service"),
			middleware.TracingInterceptor("satellite-service"),
		),
		infra.connectOpt,
	)
	mux.Handle(path, h)
}

func registerPestPredictionModule(mux *http.ServeMux, infra *sharedInfra) {
	repo := pestpostgres.NewPestRepository(infra.pool, infra.logger)
	outboxPub := outbox.NewPublisher(infra.pool, infra.zapLogger)

	clientOpt := connect.WithInterceptors(connectclient.ContextPropagator())
	fieldClient := pestclients.NewFieldClient(
		infra.baseURL,
		connectclient.NewHTTPClient(connectclient.DefaultConfig(infra.baseURL)),
		clientOpt,
	)
	sensorClient := pestclients.NewSensorClient(
		infra.baseURL,
		connectclient.NewHTTPClient(connectclient.DefaultConfig(infra.baseURL)),
		clientOpt,
	)
	farmClient := pestclients.NewFarmClient(
		infra.baseURL,
		connectclient.NewHTTPClient(connectclient.DefaultConfig(infra.baseURL)),
		clientOpt,
	)

	svc := pestapp.NewPestService(repo, outboxPub, fieldClient, sensorClient, farmClient, infra.pool, infra.logger, nil)
	handler := pestgrpc.NewPestHandler(svc, infra.logger)

	path, h := pestpredictionv1connect.NewPestPredictionServiceHandler(handler,
		connect.WithInterceptors(
			middleware.MetricsInterceptor("pest-prediction-service"),
			middleware.TracingInterceptor("pest-prediction-service"),
		),
		infra.connectOpt,
	)
	mux.Handle(path, h)
}

func registerPlantDiagnosisModule(mux *http.ServeMux, infra *sharedInfra) {
	repo := diagnosispostgres.NewDiagnosisRepository(infra.pool, infra.logger)
	outboxPub := outbox.NewPublisher(infra.pool, infra.zapLogger)

	clientOpt := connect.WithInterceptors(connectclient.ContextPropagator())
	fieldClient := diagnosisclients.NewFieldClient(
		infra.baseURL,
		connectclient.NewHTTPClient(connectclient.DefaultConfig(infra.baseURL)),
		clientOpt,
	)
	farmClient := diagnosisclients.NewFarmClient(
		infra.baseURL,
		connectclient.NewHTTPClient(connectclient.DefaultConfig(infra.baseURL)),
		clientOpt,
	)

	svc := diagnosisapp.NewDiagnosisService(repo, outboxPub, fieldClient, farmClient, infra.pool, infra.logger, nil)
	handler := diagnosisgrpc.NewDiagnosisHandler(svc, infra.logger)

	path, h := plantdiagnosisv1connect.NewPlantDiagnosisServiceHandler(handler,
		connect.WithInterceptors(
			middleware.MetricsInterceptor("plant-diagnosis-service"),
			middleware.TracingInterceptor("plant-diagnosis-service"),
		),
		infra.connectOpt,
	)
	mux.Handle(path, h)
}

func registerTraceabilityModule(mux *http.ServeMux, infra *sharedInfra) {
	repo := traceabilitypostgres.NewTraceabilityRepository(infra.pool, infra.logger)
	outboxPub := outbox.NewPublisher(infra.pool, infra.zapLogger)

	clientOpt := connect.WithInterceptors(connectclient.ContextPropagator())
	newClient := func() *http.Client {
		return connectclient.NewHTTPClient(connectclient.DefaultConfig(infra.baseURL))
	}
	farmClient := traceabilityclients.NewFarmClient(infra.baseURL, newClient(), clientOpt)
	fieldClient := traceabilityclients.NewFieldClient(infra.baseURL, newClient(), clientOpt)
	yieldClient := traceabilityclients.NewYieldClient(infra.baseURL, newClient(), clientOpt)
	cropClient := traceabilityclients.NewCropClient(infra.baseURL, newClient(), clientOpt)

	svc := traceabilityapp.NewTraceabilityService(repo, outboxPub, farmClient, fieldClient, yieldClient, cropClient, infra.pool, infra.logger)
	handler := traceabilitygrpc.NewTraceabilityHandler(svc, infra.logger)

	path, h := traceabilityv1connect.NewTraceabilityServiceHandler(handler,
		connect.WithInterceptors(
			middleware.MetricsInterceptor("traceability-service"),
			middleware.TracingInterceptor("traceability-service"),
		),
		infra.connectOpt,
	)
	mux.Handle(path, h)
}

func registerCommerceModule(mux *http.ServeMux, infra *sharedInfra) {
	repo := commercepostgres.NewCommerceRepository(infra.pool, infra.logger)
	outboxPub := outbox.NewPublisher(infra.pool, infra.zapLogger)
	svc := commerceapp.NewCommerceService(repo, outboxPub, infra.logger)
	handler := commercegrpc.NewCommerceHandler(svc, infra.logger)

	path, h := commercev1connect.NewCommerceServiceHandler(handler,
		connect.WithInterceptors(
			middleware.MetricsInterceptor("commerce-service"),
			middleware.TracingInterceptor("commerce-service"),
		),
		infra.connectOpt,
	)
	mux.Handle(path, h)
}

// ═══════════════════════════════════════════════════════════════════════════════
// Deps-based services — ServiceDeps pattern with database
// ═══════════════════════════════════════════════════════════════════════════════

func registerTaskModule(mux *http.ServeMux, infra *sharedInfra) {
	d := deps.ServiceDeps{Pool: infra.pool, Log: infra.logger}
	outboxPub := outbox.NewPublisher(infra.pool, infra.zapLogger)

	repo := taskrepos.NewTaskRepository(infra.pool, infra.logger)
	svc := taskservices.NewTaskService(repo, outboxPub, infra.pool, infra.logger)
	handler := taskhandlers.NewTaskHandler(d, svc)

	path, h := taskv1connect.NewTaskServiceHandler(handler,
		connect.WithInterceptors(
			middleware.MetricsInterceptor("task-service"),
			middleware.TracingInterceptor("task-service"),
		),
		infra.connectOpt,
	)
	mux.Handle(path, h)
}

func registerAgronomyModule(mux *http.ServeMux, infra *sharedInfra) {
	d := deps.ServiceDeps{Pool: infra.pool, Log: infra.logger}
	outboxPub := outbox.NewPublisher(infra.pool, infra.zapLogger)

	advisoryRepo := agronomyrepos.NewAdvisoryRepository(d)
	inspectionRepo := agronomyrepos.NewInspectionRepository(d)

	advisorySvc := agronomyservices.NewAdvisoryService(d, advisoryRepo, outboxPub)
	inspectionSvc := agronomyservices.NewInspectionService(d, inspectionRepo, outboxPub)

	advisoryHandler := agronomyhandlers.NewAdvisoryHandler(d, advisorySvc)
	inspectionHandler := agronomyhandlers.NewInspectionHandler(d, inspectionSvc)

	// Register both ConnectRPC handlers on the mux.
	advisoryPath, advisoryH := agronomyv1connect.NewAdvisoryServiceHandler(advisoryHandler,
		connect.WithInterceptors(
			middleware.MetricsInterceptor("agronomy-service"),
			middleware.TracingInterceptor("agronomy-service"),
		),
		infra.connectOpt,
	)
	mux.Handle(advisoryPath, advisoryH)

	inspectionPath, inspectionH := agronomyv1connect.NewInspectionServiceHandler(inspectionHandler,
		connect.WithInterceptors(
			middleware.MetricsInterceptor("agronomy-service"),
			middleware.TracingInterceptor("agronomy-service"),
		),
		infra.connectOpt,
	)
	mux.Handle(inspectionPath, inspectionH)
}

func registerVegetationIndexModule(mux *http.ServeMux, infra *sharedInfra) {
	d := deps.ServiceDeps{Pool: infra.pool, Log: infra.logger}

	repo := vegetationrepos.NewVegetationIndexRepository(d)
	svc := vegetationservices.NewVegetationIndexService(d, repo)
	handler := vegetationhandlers.NewVegetationIndexHandler(d, svc)

	path, h := vegetationv1connect.NewVegetationIndexServiceHandler(handler,
		connect.WithInterceptors(
			middleware.MetricsInterceptor("vegetation-index-service"),
			middleware.TracingInterceptor("vegetation-index-service"),
		),
		infra.connectOpt,
	)
	mux.Handle(path, h)
}

func registerSatelliteAnalyticsModule(mux *http.ServeMux, infra *sharedInfra) {
	d := deps.ServiceDeps{Pool: infra.pool, Log: infra.logger}

	repo := satanalyticsrepos.NewAnalyticsRepository(d)
	svc := satanalyticsservices.NewAnalyticsService(d, repo, nil) // nil AI client
	handler := satanalyticshandlers.NewAnalyticsHandler(d, svc)

	path, h := satanalyticsv1connect.NewSatelliteAnalyticsServiceHandler(handler,
		connect.WithInterceptors(
			middleware.MetricsInterceptor("satellite-analytics-service"),
			middleware.TracingInterceptor("satellite-analytics-service"),
		),
		infra.connectOpt,
	)
	mux.Handle(path, h)
}

func registerSatelliteTileModule(mux *http.ServeMux, infra *sharedInfra) {
	d := deps.ServiceDeps{Pool: infra.pool, Log: infra.logger}

	repo := sattilerepos.NewTileRepository(d)
	svc := sattileservices.NewTileService(d, repo)
	handler := sattilehandlers.NewTileHandler(d, svc)

	path, h := sattilev1connect.NewSatelliteTileServiceHandler(handler,
		connect.WithInterceptors(
			middleware.MetricsInterceptor("satellite-tile-service"),
			middleware.TracingInterceptor("satellite-tile-service"),
		),
		infra.connectOpt,
	)
	mux.Handle(path, h)
}

func registerSatelliteIngestionModule(mux *http.ServeMux, infra *sharedInfra) {
	d := deps.ServiceDeps{Pool: infra.pool, Log: infra.logger}

	repo := satingestionrepos.NewIngestionRepository(d)
	svc := satingestionservices.NewIngestionService(d, repo)
	handler := satingestionhandlers.NewIngestionHandler(d, svc)

	path, h := satingestionv1connect.NewSatelliteIngestionServiceHandler(handler,
		connect.WithInterceptors(
			middleware.MetricsInterceptor("satellite-ingestion-service"),
			middleware.TracingInterceptor("satellite-ingestion-service"),
		),
		infra.connectOpt,
	)
	mux.Handle(path, h)
}

func registerSatelliteProcessingModule(mux *http.ServeMux, infra *sharedInfra) {
	d := deps.ServiceDeps{Pool: infra.pool, Log: infra.logger}

	repo := satprocessingrepos.NewProcessingRepository(d)
	svc := satprocessingservices.NewProcessingService(d, repo)
	handler := satprocessinghandlers.NewProcessingHandler(d, svc)

	path, h := satprocessingv1connect.NewSatelliteProcessingServiceHandler(handler,
		connect.WithInterceptors(
			middleware.MetricsInterceptor("satellite-processing-service"),
			middleware.TracingInterceptor("satellite-processing-service"),
		),
		infra.connectOpt,
	)
	mux.Handle(path, h)
}

// ═══════════════════════════════════════════════════════════════════════════════
// Stateless services — no database pool
// ═══════════════════════════════════════════════════════════════════════════════

func registerAlertModule(mux *http.ServeMux, infra *sharedInfra) {
	d := deps.ServiceDeps{Log: infra.logger}

	svc := alertservices.NewAlertService(d, nil) // nil AI client
	handler := alerthandlers.NewAlertHandler(d, svc)

	path, h := alertv1connect.NewAlertServiceHandler(handler,
		connect.WithInterceptors(
			middleware.MetricsInterceptor("alert-service"),
			middleware.TracingInterceptor("alert-service"),
		),
		infra.connectOpt,
	)
	mux.Handle(path, h)
}

func registerAnalyticsModule(mux *http.ServeMux, infra *sharedInfra) {
	d := deps.ServiceDeps{Log: infra.logger}

	svc := analyticsservices.NewAnalyticsService(d)
	handler := analyticshandlers.NewAnalyticsHandler(d, svc)

	path, h := analyticsv1connect.NewFieldAnalyticsServiceHandler(handler,
		connect.WithInterceptors(
			middleware.MetricsInterceptor("analytics-service"),
			middleware.TracingInterceptor("analytics-service"),
		),
		infra.connectOpt,
	)
	mux.Handle(path, h)
}

func registerPrescriptionModule(mux *http.ServeMux, infra *sharedInfra) {
	d := deps.ServiceDeps{Log: infra.logger}

	svc := prescriptionservices.NewPrescriptionService(d)
	handler := prescriptionhandlers.NewPrescriptionHandler(d, svc)

	path, h := prescriptionv1connect.NewPrescriptionServiceHandler(handler,
		connect.WithInterceptors(
			middleware.MetricsInterceptor("prescription-service"),
			middleware.TracingInterceptor("prescription-service"),
		),
		infra.connectOpt,
	)
	mux.Handle(path, h)
}

// ═══════════════════════════════════════════════════════════════════════════════
// Auth service — plain HTTP handlers (no ConnectRPC)
// ═══════════════════════════════════════════════════════════════════════════════

// registerAuthModule registers the auth-service routes as plain HTTP handlers.
// The auth-service does not use ConnectRPC; it serves /auth/* endpoints
// directly. The handler logic is replicated here because the original code
// lives in auth-service/cmd/server (package main, not importable).
func registerAuthModule(mux *http.ServeMux, infra *sharedInfra) {
	h := &monolithAuthHandler{pool: infra.pool, logger: infra.zapLogger}

	mux.HandleFunc("/auth/login", h.handleLogin)
	mux.HandleFunc("/auth/refresh", h.handleRefresh)
	mux.HandleFunc("/auth/me", h.handleMe)
	mux.HandleFunc("/auth/logout", h.handleLogout)
}

// monolithAuthHandler mirrors the auth-service handler. It manages user login,
// token refresh, current-user lookup, and logout via plain HTTP/JSON.
type monolithAuthHandler struct {
	pool   *pgxpool.Pool
	logger *zap.Logger
}

const (
	authAccessTokenTTL  = 15 * time.Minute
	authRefreshTokenTTL = 7 * 24 * time.Hour
)

// POST /auth/login  { "email": "...", "password": "..." }
func (h *monolithAuthHandler) handleLogin(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		authWriteJSON(w, http.StatusMethodNotAllowed, map[string]string{"error": "method not allowed"})
		return
	}

	r.Body = http.MaxBytesReader(w, r.Body, 1<<20)
	var req struct {
		Email    string `json:"email"`
		Password string `json:"password"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		authWriteJSON(w, http.StatusBadRequest, map[string]string{"error": "invalid request body"})
		return
	}
	if req.Email == "" || req.Password == "" {
		authWriteJSON(w, http.StatusBadRequest, map[string]string{"error": "email and password are required"})
		return
	}

	var userID, tenantID, name, role, passwordHash string
	err := h.pool.QueryRow(r.Context(),
		"SELECT id, tenant_id, name, role, password_hash FROM users WHERE email = $1 AND is_active = true",
		req.Email,
	).Scan(&userID, &tenantID, &name, &role, &passwordHash)
	if err != nil {
		authWriteJSON(w, http.StatusUnauthorized, map[string]string{"error": "invalid credentials"})
		return
	}

	if err := bcrypt.CompareHashAndPassword([]byte(passwordHash), []byte(req.Password)); err != nil {
		authWriteJSON(w, http.StatusUnauthorized, map[string]string{"error": "invalid credentials"})
		return
	}

	sessionID := ulid.NewString()
	refreshToken, tokenHash := authGenerateRefreshToken()

	expiresAt := time.Now().Add(authRefreshTokenTTL)
	_, err = h.pool.Exec(r.Context(),
		"INSERT INTO sessions (id, user_id, refresh_token_hash, ip_address, user_agent, expires_at) VALUES ($1, $2, $3, $4, $5, $6)",
		sessionID, userID, tokenHash, r.RemoteAddr, r.UserAgent(), expiresAt,
	)
	if err != nil {
		h.logger.Error("failed to create session", zap.Error(err))
		authWriteJSON(w, http.StatusInternalServerError, map[string]string{"error": "internal error"})
		return
	}

	accessToken, err := authIssueAccessToken(userID, tenantID, role, sessionID)
	if err != nil {
		h.logger.Error("failed to sign access token", zap.Error(err))
		authWriteJSON(w, http.StatusInternalServerError, map[string]string{"error": "internal error"})
		return
	}

	authWriteJSON(w, http.StatusOK, map[string]interface{}{
		"token": map[string]interface{}{
			"access_token":  accessToken,
			"refresh_token": refreshToken,
			"expires_at":    time.Now().Add(authAccessTokenTTL).Unix(),
		},
		"user": map[string]interface{}{
			"id":        strings.TrimSpace(userID),
			"tenant_id": strings.TrimSpace(tenantID),
			"name":      name,
			"email":     req.Email,
			"role":      role,
		},
	})
}

// POST /auth/refresh  { "refresh_token": "..." }
func (h *monolithAuthHandler) handleRefresh(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		authWriteJSON(w, http.StatusMethodNotAllowed, map[string]string{"error": "method not allowed"})
		return
	}

	r.Body = http.MaxBytesReader(w, r.Body, 1<<20)
	var req struct {
		RefreshToken string `json:"refresh_token"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil || req.RefreshToken == "" {
		authWriteJSON(w, http.StatusBadRequest, map[string]string{"error": "refresh_token is required"})
		return
	}

	tokenHash := authHashToken(req.RefreshToken)

	var sessionID, userID, tenantID, role string
	var expiresAt time.Time
	err := h.pool.QueryRow(r.Context(), `
		SELECT s.id, s.user_id, u.tenant_id, u.role, s.expires_at
		FROM sessions s JOIN users u ON u.id = s.user_id
		WHERE s.refresh_token_hash = $1 AND s.is_revoked = false AND u.is_active = true
	`, tokenHash).Scan(&sessionID, &userID, &tenantID, &role, &expiresAt)
	if err != nil {
		authWriteJSON(w, http.StatusUnauthorized, map[string]string{"error": "invalid refresh token"})
		return
	}

	if time.Now().After(expiresAt) {
		_, _ = h.pool.Exec(r.Context(), "UPDATE sessions SET is_revoked = true WHERE id = $1", sessionID)
		authWriteJSON(w, http.StatusUnauthorized, map[string]string{"error": "refresh token expired"})
		return
	}

	// Revoke old session, issue new one (rotation).
	_, _ = h.pool.Exec(r.Context(), "UPDATE sessions SET is_revoked = true WHERE id = $1", sessionID)

	newSessionID := ulid.NewString()
	newRefreshToken, newTokenHash := authGenerateRefreshToken()
	newExpiresAt := time.Now().Add(authRefreshTokenTTL)

	_, err = h.pool.Exec(r.Context(),
		"INSERT INTO sessions (id, user_id, refresh_token_hash, ip_address, user_agent, expires_at) VALUES ($1, $2, $3, $4, $5, $6)",
		newSessionID, userID, newTokenHash, r.RemoteAddr, r.UserAgent(), newExpiresAt,
	)
	if err != nil {
		h.logger.Error("failed to rotate session", zap.Error(err))
		authWriteJSON(w, http.StatusInternalServerError, map[string]string{"error": "internal error"})
		return
	}

	accessToken, err := authIssueAccessToken(
		strings.TrimSpace(userID),
		strings.TrimSpace(tenantID),
		strings.TrimSpace(role),
		newSessionID,
	)
	if err != nil {
		h.logger.Error("failed to sign access token", zap.Error(err))
		authWriteJSON(w, http.StatusInternalServerError, map[string]string{"error": "internal error"})
		return
	}

	authWriteJSON(w, http.StatusOK, map[string]interface{}{
		"token": map[string]interface{}{
			"access_token":  accessToken,
			"refresh_token": newRefreshToken,
			"expires_at":    time.Now().Add(authAccessTokenTTL).Unix(),
		},
	})
}

// GET /auth/me  (Authorization: Bearer <access_token>)
func (h *monolithAuthHandler) handleMe(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		authWriteJSON(w, http.StatusMethodNotAllowed, map[string]string{"error": "method not allowed"})
		return
	}

	claims, err := authExtractBearerClaims(r)
	if err != nil {
		authWriteJSON(w, http.StatusUnauthorized, map[string]string{"error": "unauthorized"})
		return
	}

	var email, name, role string
	err = h.pool.QueryRow(r.Context(),
		"SELECT email, name, role FROM users WHERE id = $1 AND is_active = true",
		claims.UserID,
	).Scan(&email, &name, &role)
	if err != nil {
		authWriteJSON(w, http.StatusNotFound, map[string]string{"error": "user not found"})
		return
	}

	authWriteJSON(w, http.StatusOK, map[string]interface{}{
		"id":        strings.TrimSpace(claims.UserID),
		"tenant_id": strings.TrimSpace(claims.TenantID),
		"name":      name,
		"email":     email,
		"role":      role,
	})
}

// POST /auth/logout  (Authorization: Bearer <access_token>)
func (h *monolithAuthHandler) handleLogout(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		authWriteJSON(w, http.StatusMethodNotAllowed, map[string]string{"error": "method not allowed"})
		return
	}

	claims, err := authExtractBearerClaims(r)
	if err != nil {
		authWriteJSON(w, http.StatusUnauthorized, map[string]string{"error": "unauthorized"})
		return
	}

	if claims.SessionID != "" {
		_, _ = h.pool.Exec(r.Context(),
			"UPDATE sessions SET is_revoked = true WHERE id = $1 AND user_id = $2 AND is_revoked = false",
			claims.SessionID, claims.UserID,
		)
	} else {
		_, _ = h.pool.Exec(r.Context(),
			"UPDATE sessions SET is_revoked = true WHERE user_id = $1 AND is_revoked = false",
			claims.UserID,
		)
	}

	authWriteJSON(w, http.StatusOK, map[string]string{"status": "logged_out"})
}

// ── Auth helpers ────────────────────────────────────────────────────────────

func authIssueAccessToken(userID, tenantID, role, sessionID string) (string, error) {
	now := time.Now()
	claims := &authz.CustomClaims{
		UserID:    userID,
		TenantID:  tenantID,
		Role:      role,
		SessionID: sessionID,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(now.Add(authAccessTokenTTL)),
			IssuedAt:  jwt.NewNumericDate(now),
			NotBefore: jwt.NewNumericDate(now),
		},
	}
	return authz.SignJWT(claims)
}

func authExtractBearerClaims(r *http.Request) (*authz.CustomClaims, error) {
	auth := r.Header.Get("Authorization")
	if !strings.HasPrefix(auth, "Bearer ") {
		return nil, authz.ErrJWTNotConfigured
	}
	return authz.ParseJWT(strings.TrimPrefix(auth, "Bearer "))
}

func authHashToken(token string) string {
	h := sha256.Sum256([]byte(token))
	return hex.EncodeToString(h[:])
}

func authGenerateRefreshToken() (raw string, hash string) {
	b := make([]byte, 32)
	if _, err := rand.Read(b); err != nil {
		panic("crypto/rand unavailable: " + err.Error())
	}
	raw = hex.EncodeToString(b)
	hash = authHashToken(raw)
	return raw, hash
}

func authWriteJSON(w http.ResponseWriter, status int, v interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}
