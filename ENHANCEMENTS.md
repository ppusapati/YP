# YieldPoint Platform Enhancements

Categorized by priority and effort. Each enhancement includes what exists today and what's needed.

---

## Critical Priority (Pre-Scale)

### E-001: Disaster Recovery & Database Resilience

**Current state:** Single Postgres instance, no backups, no replication, no failover. A single disk failure loses all data.

**Enhancements:**
- [x] Set up automated PostgreSQL backups (pg_dump cron + WAL archiving to S3/MinIO)
- [x] Configure Point-in-Time Recovery (PITR) with WAL-G or pgBackRest
- [x] Add streaming replication with at least one read replica
- [ ] Deploy Patroni or PgPool for automatic failover
- [x] Create backup verification script (restore to test DB weekly)
- [x] Document Recovery Point Objective (RPO) and Recovery Time Objective (RTO)
- [ ] Add cross-region backup replication for satellite imagery data
- [x] Define data retention policies per service

**Effort:** Large | **Impact:** Critical

---

### E-002: Observability Dashboards & Alerting

**Current state:** Prometheus scrapes metrics and Grafana is deployed, but zero dashboards and no alerting rules exist. Alerts engine exists in packages/ but is not connected to external notification channels.

**Enhancements:**
- [x] Create Grafana dashboard JSONs for: service health overview, request latency/error rates, database connection pool utilization, Kafka consumer lag, AI gateway inference latency
- [x] Define Prometheus alerting rules (`.rules.yml`) for: service down, high error rate (>1%), P99 latency breaches, database connection exhaustion, disk space warnings, Kafka consumer lag > threshold
- [x] Deploy AlertManager with routing to Slack/PagerDuty/email
- [ ] Add Postgres exporter (prometheusm community/postgres_exporter) and Kafka exporter (danielqsj/kafka_exporter)
- [x] Define SLOs/SLIs for critical paths (auth, farm CRUD, satellite processing)
- [ ] Add log aggregation (Grafana Loki or ELK stack)

**Effort:** Medium | **Impact:** Critical

---

### E-003: Security Hardening

**Current state:** JWT auth with RBAC, RLS, rate limiting, security headers exist. No security scanning, no secrets rotation, no WAF.

**Enhancements:**
- [x] Add dependency vulnerability scanning in CI (govulncheck for Go, cargo-audit for Rust, npm audit for web)
- [x] Add SAST scanning (semgrep or CodeQL GitHub Action)
- [ ] Implement secrets rotation mechanism (Vault or AWS Secrets Manager integration)
- [x] Add CSRF protection for web endpoints
- [x] Add WAF rules at ingress level (ModSecurity or cloud WAF)
- [x] Implement audit logging for admin operations and data mutations
- [x] Add OAuth2/OIDC provider support (Google, Microsoft SSO) alongside JWT
- [x] Move rate limiting to gateway level (Caddy rate_limit plugin) in addition to service-level
- [x] Add IP allowlisting/denylisting at the gateway

**Effort:** Large | **Impact:** Critical

---

## High Priority (Post-Launch)

### E-004: Feature Flags & Gradual Rollouts

**Current state:** No feature flag system exists. No canary deployment or A/B testing capability.

**Enhancements:**
- [x] Integrate a feature flag service (Unleash self-hosted or LaunchDarkly)
- [x] Add feature flag middleware to ConnectRPC interceptor chain
- [x] Implement percentage-based rollouts for new ML models
- [ ] Add canary deployment support in CD pipeline (deploy to subset of pods first)
- [ ] Create experiment tracking for A/B testing crop recommendations
- [x] Add kill switches for external API dependencies (PlantNet, Google Vision)

**Effort:** Medium | **Impact:** High

---

### E-005: Load Testing & Performance Baselines

**Current state:** Circuit breaker, connection pooling, caching, and load balancing packages exist. No load tests or benchmarks in CI.

**Enhancements:**
- [x] Create k6 load test scripts for critical paths: auth flow, farm/field CRUD, sensor data ingestion, satellite image upload, AI gateway inference
- [x] Establish performance baselines (P50/P95/P99 latency, max throughput)
- [x] Add benchmark tests to CI (fail on >10% regression)
- [ ] Configure PgBouncer for production database connection pooling
- [ ] Add response compression at Caddy gateway (gzip/brotli)
- [ ] Set up CDN for satellite tile imagery and static assets
- [ ] Configure database read replicas for read-heavy services (satellite, analytics)
- [ ] Add slow query logging and periodic EXPLAIN analysis

**Effort:** Medium | **Impact:** High

---

### E-006: Web Frontend Test Coverage

**Current state:** SvelteKit app has 50+ routes but only 2 test files. No E2E browser tests.

**Enhancements:**
- [x] Add Playwright E2E tests for critical user journeys: login, create farm, add field, view satellite imagery, create irrigation schedule
- [x] Add Vitest unit tests for Svelte stores and utility functions
- [ ] Add component tests for reusable UI components (charts, maps, data grids)
- [ ] Set up visual regression testing (Playwright screenshots or Chromatic)
- [ ] Add web test coverage to CI pipeline
- [ ] Create Storybook for the UI component library

**Effort:** Large | **Impact:** High

---

### E-007: Data Pipeline & Analytics Warehouse

**Current state:** Real-time event streaming via Kafka only. No batch processing, no data warehouse, no historical analytics.

**Enhancements:**
- [ ] Add TimescaleDB or InfluxDB for time-series sensor data (temperature, moisture, rainfall)
- [x] Set up a data warehouse (ClickHouse or PostgreSQL with Citus) for historical analytics
- [x] Create ETL jobs for nightly aggregation (daily yield summaries, weekly soil trends, seasonal crop performance)
- [x] Add data quality monitoring (Great Expectations or custom validators on Kafka consumers)
- [x] Build reporting/BI API for frontend dashboards (seasonal yield trends, farm-level KPIs)
- [ ] Archive satellite imagery to cold storage (S3 Glacier or MinIO tiering)
- [x] Add data export API for regulatory compliance and farmer data portability

**Effort:** Large | **Impact:** High

---

## Medium Priority (Growth Phase)

### E-008: Infrastructure as Code & GitOps

**Current state:** Raw K8s YAML with sed for tag substitution. No Helm, Kustomize, Terraform, or GitOps.

**Enhancements:**
- [x] Convert K8s manifests to Helm charts with values.yaml per environment
- [x] Add Kustomize overlays for staging vs production differences
- [x] Deploy ArgoCD or Flux for GitOps-based deployments
- [ ] Add Terraform/Pulumi for cloud infrastructure (VPC, RDS, EKS/GKE, S3)
- [x] Add K8s network policies for inter-service communication isolation
- [x] Configure Horizontal Pod Autoscaler (HPA) for all services
- [ ] Add Docker BuildKit layer caching in CI for faster builds
- [ ] Evaluate Istio/Linkerd service mesh for mTLS and traffic management

**Effort:** Large | **Impact:** Medium

---

### E-009: API Documentation & Developer Portal

**Current state:** 13 OpenAPI specs exist in docs/api/ with a README. No hosted docs, no interactive explorer, newer services lack specs.

**Enhancements:**
- [x] Generate OpenAPI specs for missing services: alert, analytics, prescription, satellite-ingestion, satellite-processing, satellite-tile, vegetation-index, task, agronomy
- [x] Deploy Swagger UI or Redoc as a service for interactive API exploration
- [ ] Add API changelog and versioning migration guides
- [ ] Create developer portal with getting-started guides, authentication docs, and code samples
- [ ] Add API usage examples and SDK generation (Go, Python, TypeScript clients)
- [ ] Document rate limits, pagination, and error codes

**Effort:** Medium | **Impact:** Medium

---

### E-010: Internationalization Completion

**Current state:** i18n middleware exists (backend + web + Rust WASM). English complete (152 keys), Hindi partial (50 keys). No mobile localization.

**Enhancements:**
- [x] Complete Hindi translations (102 missing keys)
- [x] Add locales for major agricultural regions: Marathi, Telugu, Tamil, Kannada, Punjabi, Bengali
- [x] Set up Flutter localization (arb files) for the mobile app
- [ ] Add date/number/currency formatting per locale
- [ ] Add RTL language support for future Arabic/Urdu expansion
- [ ] Set up translation management (Crowdin or Lokalise) for community contributions
- [ ] Add locale detection from user profile and browser settings

**Effort:** Medium | **Impact:** Medium

---

### E-011: Mobile App Enhancements

**Current state:** Flutter app with clean architecture, field inspection, irrigation, diagnosis, satellite, sensors. No offline mode, no push notifications.

**Enhancements:**
- [x] Implement offline-first with SQLite sync queue (critical for rural areas with poor connectivity)
- [x] Add push notifications via Firebase Cloud Messaging (pest alerts, irrigation reminders, weather warnings)
- [ ] Add camera integration for in-field plant diagnosis (capture → AI gateway)
- [ ] Add GPS-based field boundary drawing
- [ ] Add integration tests with Flutter integration_test package
- [ ] Add app-level analytics (Firebase Analytics or PostHog)
- [x] Build PWA configuration for the web app (service worker, manifest, offline fallback)

**Effort:** Large | **Impact:** Medium

---

## Lower Priority (Maturity Phase)

### E-012: Advanced ML Pipeline

**Current state:** Rust burn-based training pipeline for plant disease CNN. ONNX export. 15 inference engines. Data collection pipeline for external API responses.

**Enhancements:**
- [x] Add model versioning and registry (MLflow or custom metadata store)
- [x] Implement automated retraining triggers (when data collection reaches threshold)
- [x] Add model A/B testing in ai-gateway (serve multiple versions, compare accuracy)
- [x] Add model performance monitoring (accuracy drift detection in production)
- [ ] Expand training pipeline to cover pest detection, nutrient deficiency, crop classification
- [ ] Add transfer learning from pre-trained agricultural vision models
- [ ] Build labeled dataset management UI for agronomists to review/correct predictions
- [ ] Add GPU support in training Dockerfile (CUDA backend for burn)

**Effort:** Large | **Impact:** Medium

---

### E-013: Multi-Tenancy Enhancements

**Current state:** Mature tenant isolation with RLS, per-tenant DB pools, JWT claims. No provisioning workflow or billing isolation.

**Enhancements:**
- [x] Build tenant provisioning API (create tenant → create databases → run migrations → seed defaults)
- [x] Add tenant-level resource quotas (storage limits, API rate limits per tenant)
- [ ] Build admin dashboard for cross-tenant analytics and health monitoring
- [x] Add tenant data export API (GDPR/data portability compliance)
- [ ] Implement tenant offboarding with data archival
- [ ] Add tenant-specific feature flags

**Effort:** Medium | **Impact:** Medium

---

### E-014: Real-Time Features

**Current state:** Kafka event bus for async communication. No WebSocket or SSE support for live updates.

**Enhancements:**
- [x] Add WebSocket gateway for real-time sensor data streaming to web/mobile
- [x] Implement Server-Sent Events (SSE) for alert notifications
- [ ] Add real-time field map updates (live tractor GPS, drone imagery overlay)
- [ ] Build real-time irrigation control (sensor reading → decision → actuator command)
- [ ] Add collaborative field inspection (multiple users viewing/editing simultaneously)

**Effort:** Medium | **Impact:** Low

---

### E-015: Developer Experience

**Current state:** Makefile with standard targets, multi-stage Docker builds, Turborepo for web monorepo.

**Enhancements:**
- [x] Add dev container configuration (.devcontainer/) for consistent development environments
- [x] Create service scaffolding generator (`make new-service NAME=weather`)
- [x] Add pre-commit hooks (lint, format, proto freshness check)
- [ ] Set up PR preview environments (ephemeral namespaces per PR)
- [x] Add architecture decision records (ADRs) for major design choices
- [ ] Build local mock server for external APIs (PlantNet, Google Vision) for offline development

**Effort:** Small | **Impact:** Low

---

## Phase 2: AI/ML & Domain Expansion (Sequential)

These build on each other in order. Each step produces inputs the next one needs.

### E-016: Weather Service

**Current state:** No weather provider integration exists. Weather values (temperature, rainfall, humidity) are caller-supplied request fields on yield, growth, and risk RPCs. Nothing ingests forecasts or stores historical observations.

**Enhancements:**
- [x] Create `weather-service` with provider abstraction (Open-Meteo, OpenWeather; IMD enum reserved, no public API yet)
- [x] Ingest hourly observations and 7/14-day forecasts per field centroid (auto-registered from field events, hourly poller)
- [x] Compute derived agronomic metrics: growing degree days (GDD), reference evapotranspiration (ET0 via Penman-Monteith), chill hours, rainfall deficit
- [x] Publish `weather.observation` and `weather.forecast` Kafka events for downstream consumers
- [x] Backfill 5 years of historical weather per field for model training
- [ ] Replace caller-supplied weather fields in AI gateway RPCs with server-side lookup by field ID
- [x] Raise weather alerts (frost, heat stress, heavy rainfall, high wind, drought) and publish `agriculture.weather.alert.triggered` events
- [ ] Consume weather alert events in alert-service so they appear alongside pest and sensor alerts

**Effort:** Medium | **Impact:** Critical (prerequisite for E-018, E-019, E-021)

---

### E-017: Satellite Pipeline Hardening

**Current state:** Indices NDVI/NDWI/EVI/SAVI/MSAVI/GNDVI are computed. NDRE and LAI are declared in `vegetation-index-service/internal/models/vegetation_index.go` but never computed. Cloud handling is a scene-level `cloud_cover_percent` filter only. Change detection and trend analysis in `satellite-analytics-service/internal/services/analytics_service.go` return hardcoded slope/R².

**Enhancements:**
- [ ] Implement NDRE and LAI computation in `rust-engines/satellite-ndvi-engine`
- [ ] Add per-pixel cloud and shadow masking using Sentinel-2 SCL band and Landsat QA_PIXEL
- [ ] Add atmospheric correction handling (prefer L2A/Collection 2 Level-2 products; flag L1C scenes)
- [ ] Implement temporal gap-filling and cross-sensor harmonization (Sentinel-2 to Landsat)
- [ ] Replace stubbed change detection with real before/after differencing and z-score anomaly flags
- [ ] Replace stubbed trend analysis with the `packages/pipeline` linear regression over the index time series
- [ ] Add field-level phenology extraction (green-up, peak, senescence dates) from NDVI curves
- [ ] Ingest drone/UAV orthomosaics through the same pipeline with a `source=uav` discriminator

**Effort:** Large | **Impact:** High

---

### E-018: Tabular Yield & Growth Models

**Current state:** `rust-engines/yield-prediction-engine/src/model.rs` uses hardcoded per-crop constants for wheat, corn, and soybean only. Crop-growth (WOFOST/ODE) and climate-response engines are deterministic parametric models. No tabular or time-series model training exists in `ml-training/`.

**Enhancements:**
- [ ] Add a tabular training task in `ml-training/` (gradient boosting or small temporal net) using warehouse features: weather aggregates, index time series, soil, prior yields
- [ ] Extend crop coverage to rice, cotton, sugarcane, pulses, and regional horticulture
- [ ] Export tabular models to ONNX and serve through the existing AI gateway model registry
- [ ] Keep the parametric engines as a fallback when a field lacks training history; blend by confidence
- [ ] Add in-season yield forecasting that updates weekly as new imagery and weather arrive
- [ ] Add per-field prediction intervals and expose uncertainty in the yield RPC response
- [ ] Wire `water-flow-simulation-engine` into irrigation-service for ET0-driven water-balance scheduling

**Effort:** Large | **Impact:** High

---

### E-019: Training Data Quality & Human-in-the-Loop Labeling

**Current state:** Labels come from PlantNet/Google Vision responses via `ai-gateway/src/data_collector.rs` directly into the training manifest. No human review, no dataset versioning, no label-noise handling beyond `min_confidence` and `min_samples_per_class`.

**Enhancements:**
- [ ] Build a labeling review queue API and web UI for agronomists to confirm, correct, or reject auto-labels
- [ ] Add dataset versioning with content hashing and immutable snapshots per training run
- [ ] Add class-balance reporting and stratified sampling in `ml-training/src/dataset.rs`
- [ ] Add label-noise detection (confident-learning style disagreement between model and label)
- [ ] Track label provenance (external API, human, model-assisted) and weight samples accordingly
- [ ] Add active-learning sampling: surface low-confidence and high-disagreement images for review first
- [ ] Add geographic and crop-type metadata to every sample for slicing in evaluation

**Effort:** Medium | **Impact:** High

---

### E-020: Vision Model Upgrade

**Current state:** `ml-training/src/model.rs` trains a single small `PlantCnn` from scratch for all four vision tasks (disease, pest, nutrient deficiency, classification). No pretrained backbone, no transfer learning.

**Enhancements:**
- [ ] Import a pretrained backbone (ImageNet or agriculture-specific) via ONNX and fine-tune per task
- [ ] Add multi-task heads sharing one backbone to cut inference cost on mobile
- [ ] Add augmentation pipeline tuned for field photos: lighting, occlusion, motion blur, background variation
- [ ] Add mobile-optimized export (quantized ONNX / TFLite) for on-device inference in the Flutter app
- [ ] Add GPU support in the training Dockerfile (CUDA backend for burn)
- [ ] Benchmark against the external APIs on the held-out set and gate the kill switches on parity

**Effort:** Large | **Impact:** High

---

### E-021: Model Evaluation & Explainability

**Current state:** `ml-training/src/validate.rs` reports per-class metrics only. Explainability is limited to threshold/bbox post-processing in `rust-engines/disease-detection-engine/src/heatmap.rs`. No feature attribution for yield or prescription outputs.

**Enhancements:**
- [ ] Add confusion matrix, calibration curves, and expected calibration error to validation output
- [ ] Add a fixed held-out benchmark suite per task that every candidate model must pass before promotion
- [ ] Add evaluation slicing by crop, region, season, and image source
- [ ] Add Grad-CAM heatmaps for vision predictions and return them in the diagnosis response
- [ ] Add SHAP-style feature attribution for yield and prescription outputs
- [ ] Surface "why this recommendation" explanations in web and mobile diagnosis views
- [ ] Add regression gates in CI: fail promotion if benchmark accuracy drops or calibration worsens

**Effort:** Medium | **Impact:** High

---

### E-022: Agronomy Advisory Assistant (LLM + RAG)

**Current state:** No LLM, embeddings, vector search, RAG, or agentic components exist anywhere in the codebase. No advisory chat on web or mobile.

**Enhancements:**
- [ ] Add an `advisory-service` that grounds an LLM on tenant-scoped field data, prescriptions, alerts, weather, and diagnosis history
- [ ] Add tool-use bindings so the assistant can call existing services (yield forecast, irrigation decision, pest risk) rather than guess
- [ ] Add pgvector-backed retrieval over agronomy reference material, crop guides, and regional advisories
- [ ] Enforce tenant isolation and RLS in retrieval; never cross tenant boundaries in context
- [ ] Add a chat UI in web and mobile with citations back to the source data or document
- [ ] Support the locales already shipped (Hindi, Marathi, Telugu, Tamil, Kannada, Punjabi, Bengali)
- [ ] Add response evaluation (groundedness, hallucination checks) and log every exchange for review
- [ ] Add cost and latency budgets per tenant with the existing rate-limit and kill-switch infrastructure

**Effort:** Large | **Impact:** High

---

### E-023: New Domain Services

**Current state:** 23 services cover farm, field, crop, soil, sensor, irrigation, satellite, pest, diagnosis, prescription, yield, commerce, traceability, and tasks. No weather (see E-016), market prices, IoT device management, carbon accounting, soil-lab integration, crop planning, or financial products.

**Enhancements:**
- [ ] `market-service`: commodity price feeds (mandi/APMC, exchanges), price alerts, sell-timing signals
- [ ] `device-service`: IoT provisioning, firmware/OTA updates, heartbeat and health, fleet grouping
- [ ] `sustainability-service`: carbon and emissions accounting per field, input-use tracking, certification exports
- [ ] `soil-lab` integration: import lab reports (PDF/CSV), map to soil-service records, trigger prescriptions
- [ ] `planning-service`: season planner with crop rotation, sowing windows from weather, input budgeting
- [ ] `finance-service`: crop insurance quotes, credit scoring from yield history, claim support with satellite evidence

**Effort:** Large | **Impact:** Medium

---

### E-024: Stub & TODO Debt Reduction

**Current state:** Concentrated TODO/FIXME/not-implemented density: mobile (192), traceability (110), field (90), farm (79), pest-prediction (73), commerce (52), plant-diagnosis (44), irrigation (42), web (~238). Placeholder/mock-data markers: packages (57), plant-diagnosis (18), pest-prediction (12). Rust side is clean.

**Enhancements:**
- [ ] Triage every marker into: implement, delete, or convert to a tracked issue
- [ ] Clear mobile, traceability, and field first (top three by count and user-facing impact)
- [ ] Replace mock data in plant-diagnosis and pest-prediction with real service calls
- [ ] Add a CI check that fails when TODO count increases in a service
- [ ] Clear web app markers alongside the E-006 component test work

**Effort:** Medium | **Impact:** Medium

---

## Summary Matrix

| ID | Enhancement | Priority | Effort | Impact |
|----|-------------|----------|--------|--------|
| E-001 | Disaster Recovery | Critical | Large | Critical |
| E-002 | Dashboards & Alerting | Critical | Medium | Critical |
| E-003 | Security Hardening | Critical | Large | Critical |
| E-004 | Feature Flags | High | Medium | High |
| E-005 | Load Testing | High | Medium | High |
| E-006 | Web Frontend Tests | High | Large | High |
| E-007 | Data Pipeline | High | Large | High |
| E-008 | IaC & GitOps | Medium | Large | Medium |
| E-009 | API Docs Portal | Medium | Medium | Medium |
| E-010 | i18n Completion | Medium | Medium | Medium |
| E-011 | Mobile Enhancements | Medium | Large | Medium |
| E-012 | Advanced ML Pipeline | Lower | Large | Medium |
| E-013 | Multi-Tenancy | Lower | Medium | Medium |
| E-014 | Real-Time Features | Lower | Medium | Low |
| E-015 | Developer Experience | Lower | Small | Low |
| E-016 | Weather Service | Phase 2 - Step 1 | Medium | Critical |
| E-017 | Satellite Pipeline Hardening | Phase 2 - Step 2 | Large | High |
| E-018 | Tabular Yield & Growth Models | Phase 2 - Step 3 | Large | High |
| E-019 | Training Data Quality & Labeling | Phase 2 - Step 4 | Medium | High |
| E-020 | Vision Model Upgrade | Phase 2 - Step 5 | Large | High |
| E-021 | Model Evaluation & Explainability | Phase 2 - Step 6 | Medium | High |
| E-022 | Agronomy Advisory Assistant | Phase 2 - Step 7 | Large | High |
| E-023 | New Domain Services | Phase 2 - Step 8 | Large | Medium |
| E-024 | Stub & TODO Debt Reduction | Phase 2 - Step 9 | Medium | Medium |
