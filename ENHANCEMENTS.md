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
- [x] Add Postgres exporter and Kafka exporter — both are deployed and the scrape jobs point at them. They previously targeted `postgres:5432` and `kafka:9092` directly, which serve the Postgres and Kafka wire protocols rather than metrics, so those two jobs had never produced a single sample
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
- [x] Configure PgBouncer for database connection pooling — transaction pooling in front of Postgres, since every service keeps its own pool and the sum of two dozen of them is what exhausts `max_connections`. Not in the default path: transaction pooling forbids session state, so a service has to be checked before its `DATABASE_URL` moves
- [x] Add response compression at the Caddy gateway — zstd and gzip on the API gateway and the web proxy. JSON and Connect envelopes compress to a fraction of their size, and the farmers using this are often on a rural mobile connection where bytes cost time. Caddy skips already-compressed types on its own
- [ ] Set up CDN for satellite tile imagery and static assets
- [ ] Configure database read replicas for read-heavy services (satellite, analytics)
- [x] Add slow query logging and periodic EXPLAIN analysis — Postgres now preloads `pg_stat_statements` and logs statements over a second, lock waits, temp files and checkpoints. `scripts/slow-queries.sh` ranks by total time rather than mean, because a 2ms query running a million times costs more than a two-second one running twice and is the one worth an index

**Effort:** Medium | **Impact:** High

---

### E-006: Web Frontend Test Coverage

**Current state:** SvelteKit app has 50+ routes but only 2 test files. No E2E browser tests.

**Enhancements:**
- [x] Add Playwright E2E tests for critical user journeys: login, create farm, add field, view satellite imagery, create irrigation schedule
- [x] Add Vitest unit tests for Svelte stores and utility functions
- [ ] Add component tests for reusable UI components (charts, maps, data grids)
- [ ] Set up visual regression testing (Playwright screenshots or Chromatic)
- [x] Add web test coverage to CI pipeline — the web suite had no CI job at all, so a broken test only surfaced when someone happened to run it locally. Lint, typecheck and test now run on every push
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
- [x] Add Docker BuildKit layer caching in CI for faster builds — every image build recompiled every layer from scratch. Caches are scoped per service so one image cannot evict another's
- [ ] Evaluate Istio/Linkerd service mesh for mTLS and traffic management

**Effort:** Large | **Impact:** Medium

---

### E-009: API Documentation & Developer Portal

**Current state:** 13 OpenAPI specs exist in docs/api/ with a README. No hosted docs, no interactive explorer, newer services lack specs.

**Enhancements:**
- [x] Generate OpenAPI specs for missing services: alert, analytics, prescription, satellite-ingestion, satellite-processing, satellite-tile, vegetation-index, task, agronomy
- [x] Deploy Swagger UI or Redoc as a service for interactive API exploration
- [x] Add API changelog and versioning migration guides
- [x] Create developer portal with getting-started guides, authentication docs, and code samples
- [x] Add API usage examples and SDK generation (Go, Python, TypeScript clients) — Go/TS/Dart are generated from the protos; Python is a hand-written Connect client in `clients/python/`, since generated Python messages would add a build step and a freshness gate while buying nothing a dict does not
- [x] Document rate limits, pagination, and error codes

**Effort:** Medium | **Impact:** Medium

---

### E-010: Internationalization Completion

**Current state:** i18n middleware exists (backend + web + Rust WASM). English complete (152 keys), Hindi partial (50 keys). No mobile localization.

**Enhancements:**
- [x] Complete Hindi translations (102 missing keys)
- [x] Add locales for major agricultural regions: Marathi, Telugu, Tamil, Kannada, Punjabi, Bengali
- [x] Set up Flutter localization (arb files) for the mobile app
- [x] Add date/number/currency formatting per locale
- [x] Add RTL language support for future Arabic/Urdu expansion
- [ ] Set up translation management (Crowdin or Lokalise) for community contributions
- [x] Add locale detection from user profile and browser settings

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
- [x] Expand training pipeline to cover pest detection, nutrient deficiency, crop classification — all four tasks are configured and trainable, and `train-heads` fits them together on one backbone (E-020)
- [x] Add transfer learning from pre-trained agricultural vision models — `train-heads` takes any pretrained ONNX checkpoint (E-020)
- [x] Build labeled dataset management UI for agronomists to review/correct predictions — the label review queue, now also ordered by the labels a trained model disputes (E-019, E-024)
- [x] Add GPU support in training Dockerfile (CUDA backend for burn) — `backend.rs` selects ndarray/wgpu/cuda-jit at compile time, with `Dockerfile.cuda` (E-020)

**Effort:** Large | **Impact:** Medium

---

### E-013: Multi-Tenancy Enhancements

**Current state:** Mature tenant isolation with RLS, per-tenant DB pools, JWT claims. No provisioning workflow or billing isolation.

**Enhancements:**
- [x] Build tenant provisioning API (create tenant → create databases → run migrations → seed defaults)
- [x] Add tenant-level resource quotas (storage limits, API rate limits per tenant)
- [ ] Build admin dashboard for cross-tenant analytics and health monitoring
- [x] Add tenant data export API (GDPR/data portability compliance)
- [x] Implement tenant offboarding with data archival
- [x] Add tenant-specific feature flags

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
- [x] Build local mock server for external APIs (PlantNet, Google Vision) for offline development

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
- [x] Replace caller-supplied weather fields with a server-side lookup by field ID — pest-prediction reads the field's own observations from weather-service and uses the request's numbers only when that lookup fails. Weather is a property of the field, not of whoever is calling: taking it from the request let a caller move the risk score by sending stale or wrong numbers. The lookup belongs in the calling Go service rather than the gateway, which is a pure compute service with no outbound network
- [x] Raise weather alerts (frost, heat stress, heavy rainfall, high wind, drought) and publish `agriculture.weather.alert.triggered` events
- [x] Consume weather alert events in alert-service so they appear alongside pest and sensor alerts — alert-service now has a schema, a repository and a Kafka consumer covering weather, sensor and pest. The `Alert` proto is narrower than what is stored: `metric_value`/`threshold_value` are folded into the `metrics` map, and `resolved_at`, `expires_at` and an `EXPIRED` status have no field yet. Adding them is a safe, non-breaking proto change, but the generated Dart cannot be regenerated in this environment

**Effort:** Medium | **Impact:** Critical (prerequisite for E-018, E-019, E-021)

---

### E-017: Satellite Pipeline Hardening

**Current state:** Indices NDVI/NDWI/EVI/SAVI/MSAVI/GNDVI are computed. NDRE and LAI are declared in `vegetation-index-service/internal/models/vegetation_index.go` but never computed. Cloud handling is a scene-level `cloud_cover_percent` filter only. Change detection and trend analysis in `satellite-analytics-service/internal/services/analytics_service.go` return hardcoded slope/R².

**Enhancements:**
- [x] Implement NDRE and LAI computation in `rust-engines/satellite-ndvi-engine` (NDRE wired into `compute_all_indices`; LAI via SAVI-based Clevers model in `lai.rs`)
- [x] Add per-pixel cloud and shadow masking using Sentinel-2 SCL band and Landsat QA_PIXEL (`cloudmask.rs`, applied in the AI gateway `ComputeNDVI` when QA bands are supplied)
- [x] Add atmospheric correction handling (prefer L2A/Collection 2 Level-2 products; flag L1C scenes) — `ProcessingLevel` in engine + gateway advisory, `processing_level` on ingestion tasks
- [x] Implement temporal gap-filling and cross-sensor harmonization (Sentinel-2 to Landsat) — Roy et al. OLI→MSI coefficients in engine and `satellite-analytics-service/internal/timeseries`
- [x] Replace stubbed change detection with real before/after differencing and z-score anomaly flags
- [x] Replace stubbed trend analysis with the `packages/pipeline` linear regression over the index time series (fetched live from vegetation-index-service)
- [x] Add field-level phenology extraction (green-up, peak, senescence dates) from NDVI curves (`ANALYSIS_TYPE_PHENOLOGY`)
- [x] Ingest drone/UAV orthomosaics through the same pipeline with a `source=uav` discriminator (`SATELLITE_PROVIDER_UAV`)
- [x] Attach SCL / QA_PIXEL bands during ingestion so masking is automatic rather than caller-supplied — ingestion now adds the quality layer its provider publishes at the requested processing level. Sentinel-2 only carries SCL in its L2A product, so asking for one on L1C would fail the download rather than improve the mask; the mapping is pinned by tests
- [x] Persist per-scene `cloud_fraction` / `valid_pixel_fraction` on vegetation-index results and drop scenes below a usable threshold — both are stored with the index and returned with it, and `RecordIndex` drops a scene with too little clear sky. A gap in the time series is honest; an index computed over cloud lands in it looking exactly like a clear-day reading. Providers report one fraction or the other, so the missing one is derived rather than treated as zero. Note the write path this hangs off had no callers, the same orphaned-insert pattern as `diagnosis_results`

**Effort:** Large | **Impact:** High

---

### E-018: Tabular Yield & Growth Models

**Current state:** `rust-engines/yield-prediction-engine/src/model.rs` uses hardcoded per-crop constants for wheat, corn, and soybean only. Crop-growth (WOFOST/ODE) and climate-response engines are deterministic parametric models. No tabular or time-series model training exists in `ml-training/`.

**Enhancements:**
- [x] Add a tabular training task in `ml-training/` (gradient boosting or small temporal net) using warehouse features: weather aggregates, index time series, soil, prior yields — `yp-ml-training train-tabular --task yield` trains a pure-Rust GBM (`yield-prediction-engine/src/gbm.rs`) on a CSV of `FEATURE_NAMES` columns and registers it
- [x] Extend crop coverage to rice, cotton, sugarcane, pulses, and regional horticulture — `YieldModelParams::for_crop` covers 13 crops incl. cotton, sugarcane, chickpea, pigeon pea, groundnut, mustard, tomato, potato, onion; FAO-56 Kc tables added for the same set
- [x] Serve the trained model through the AI gateway — as a JSON artifact (`yield_tabular_model` config); the gateway now has a tract ONNX runtime, but tract does not implement the `ai.onnx.ml` TreeEnsemble op, so the GBM keeps its JSON form
- [x] Keep the parametric engines as a fallback when a field lacks training history; blend by confidence — blend weight is the tabular model's held-out R²; response reports `model_source`, `tabular_weight`, `crop_supported`
- [x] Add per-field prediction intervals and expose uncertainty in the yield RPC response — split-conformal intervals with reported `interval_coverage`
- [x] In-season features: yield-service now sends season-to-date GDD, rainfall, frost/heat-stress days from weather-service instead of placeholders
- [x] Add a weekly scheduler that re-runs in-season predictions for active fields as new weather and imagery arrive — a forecast made at sowing is a guess from soil and intent; by flowering the weather that actually happened is known, but only if something re-runs it. Weekly because neither weather aggregates nor NDVI move enough day to day to redraw a seasonal line. Tenants are listed explicitly, since background work has no request to inherit a tenant from and would otherwise see nothing under row-level security
- [x] Assemble the training CSV automatically from yield records, weather aggregates and NDVI peaks — `build-yield-dataset` joins harvests to their season's weather and imagery. The join is where a training set quietly goes wrong, so the edge cases are explicit: out-of-season observations are not folded in, another field's weather is not borrowed, a season with too few days of weather is excluded rather than recorded as dry, and a crop outside the model's table is excluded rather than coded as something else. Input is exported JSON Lines rather than a live connection, which keeps the join testable and re-runnable
- [x] Wire `water-flow-simulation-engine` into irrigation-service for ET0-driven water-balance scheduling — `RequestDecision` runs the FAO-56 balance via the AI gateway with weather-service ET0/forecast, falling back to the moisture heuristic; decisions record method, depth, Kc, ET0

**Effort:** Large | **Impact:** High

---

### E-019: Training Data Quality & Human-in-the-Loop Labeling

**Current state:** Labels come from PlantNet/Google Vision responses via `ai-gateway/src/data_collector.rs` directly into the training manifest. No human review, no dataset versioning, no label-noise handling beyond `min_confidence` and `min_samples_per_class`.

**Enhancements:**
- [x] Build a labeling review queue API and web UI for agronomists to confirm, correct, or reject auto-labels — gateway `ListTrainingSamples` / `SubmitLabelReview` / `GetTrainingSampleImage` over the sample store (`{task}/labels/{id}.json` + `reviews.jsonl` audit log); `plant-diagnosis-service` proxies them tenant-scoped (`ListLabelReviewQueue`, `SubmitLabelReview`, `GetLabelReviewImage`, reviewer from the JWT); `label-review` page in crop-intelligence and the ERP shell
- [x] Add dataset versioning with content hashing and immutable snapshots per training run — sample ids are the SHA-256 of the image bytes (deduped on collect); every `train` run writes `dataset_snapshot.json` (snapshot id = hash of the sorted id/label set, train/val/test id lists) and records it in `training_meta.json` and the model registry
- [x] Add class-balance reporting and stratified sampling in `ml-training/src/dataset.rs` — `dataset_report.json` (per-class counts, imbalance ratio, provenance/crop breakdown, warnings), deterministic per-class hash-bucket split, inverse-frequency class weights fed to the cross-entropy loss
- [x] Add label-noise detection (confident-learning style disagreement between model and label) — after training, samples the best model contradicts with p≥0.9 while p(label)≤0.1 are written to `label_noise_report.json` for review
- [x] Track label provenance (external API, human, model-assisted) and weight samples accordingly — `provenance` on every sample; `[data.provenance_weights]` (human 1.0 / external_api 0.6 / local_model 0.3) scales class weights; human decisions bypass `min_confidence`, corrections override the label, rejections drop the sample
- [x] Add active-learning sampling: surface low-confidence and high-disagreement images for review first — queue defaults to `confidence_asc`; local-model predictions are also collected so the trained model's uncertain cases enter the queue
- [x] Add geographic and crop-type metadata to every sample for slicing in evaluation — `SampleContext` (tenant, farm, field, crop, lat/lon, submitter) on every vision RPC and stored with the sample; the Go client now uses the generated gateway stubs (the previous `structpb` encoding never matched the gateway's wire format)
- [x] Add an "ask a second reviewer" flow and inter-annotator agreement reporting — a sample keeps every verdict rather than the latest, two reviewers who disagree flag it automatically, and anyone can send one for another pair of eyes. Agreement is reported as Cohen's kappa, not raw agreement: two reviewers who both answer "healthy" on a set that is ninety percent healthy agree ninety percent of the time having demonstrated nothing. A reviewer who revisits their own verdict replaces it rather than counting twice, since agreement is between people
- [x] Feed `label_noise_report.json` suspects back into the review queue automatically — `train` marks contradicted labels in the collected data, the gateway queue can filter and order by them, and the web review page has a **Model-disputed only** filter that shows what the model predicted instead. Flags a later run no longer holds are cleared, so a vindicated label leaves the queue

**Effort:** Medium | **Impact:** High

---

### E-020: Vision Model Upgrade

**Current state:** `ml-training/src/model.rs` trains a single small `PlantCnn` from scratch for all four vision tasks (disease, pest, nutrient deficiency, classification). No pretrained backbone, no transfer learning.

**Enhancements:**
- [x] Serve exported ONNX models locally in the AI gateway (pure-Rust `tract` runtime in `plant-ai-inference-engine`); vision RPCs try the trained model before the external-API/demo fallback, and each model is reported on the gRPC health service. A burn-vs-tract round-trip test guards the export, which fixed three wrong protobuf field tags and a transposed `Gemm` in the exporter
- [x] Import a pretrained backbone (ImageNet or agriculture-specific) via ONNX and train per task — `yp-ml-training train-heads` runs any ONNX checkpoint with `tract` to embed each image once (cached on disk, keyed by backbone hash), then fits a head per task on those embeddings. The backbone stays **frozen**: burn 0.16 imports ONNX only as build-time codegen, so backpropagating into it is not available; frozen-feature transfer is what this pipeline does
- [x] Add multi-task heads sharing one backbone to cut inference cost on mobile — the trained heads are spliced back onto the backbone graph as one model with a `logits_<task>` output per task, and everything the new outputs do not need is pruned (including the pretrained classifier tail). `MultiTaskClassifier` in `plant-ai-inference-engine` runs all tasks in a single pass; the gateway's `multitask_model` serves any task lacking a model of its own and reports it as shared on the health service
- [x] Add augmentation pipeline tuned for field photos: lighting, occlusion, motion blur, background variation — `ml-training/src/augment.rs` adds contrast/gamma/colour-cast, occluding patches, directional blur, off-subject re-lighting, and sensor noise on top of the existing flips/rotation/crop. Draws are seeded by sample id and epoch, so runs reproduce; only training batches are augmented
- [x] Add mobile-optimized export (quantized ONNX) for on-device inference in the Flutter app — `--quantize` writes an int8 weight-quantized copy (per-tensor symmetric scale + `DequantizeLinear`), roughly a quarter the weight bytes. Biases and small tensors stay float, where low precision costs the most and saves the least. A round-trip test asserts the int8 model's logits and its argmax still match the float model. TFLite conversion needs the TensorFlow converter, outside this pure-Rust pipeline; the int8 ONNX is the portable input to it
- [x] Add GPU support in the training Dockerfile (CUDA backend for burn) — `ml-training/src/backend.rs` selects ndarray / wgpu / cuda-jit at compile time; `Dockerfile` takes a `FEATURES` build arg and `Dockerfile.cuda` builds the CUDA variant on the NVIDIA toolkit image
- [x] Full ONNX message definitions so third-party models can be read, modified, and re-emitted losslessly (`ml-training/src/onnx_proto.rs`) — the previous write-only structs would have dropped any field they did not model
- [x] Fixed the training config's `classification` task key, which never matched the `plant_classification` directory the gateway collects into, so that task could never have found its data
- [ ] Fine-tune the backbone itself (needs an ONNX importer that yields trainable burn weights, or a second training backend)
- [ ] Benchmark against the external APIs on the held-out set and gate the kill switches on parity

**Effort:** Large | **Impact:** High

---

### E-021: Model Evaluation & Explainability

**Current state:** `ml-training/src/validate.rs` reports per-class metrics only. Explainability is limited to threshold/bbox post-processing in `rust-engines/disease-detection-engine/src/heatmap.rs`. No feature attribution for yield or prescription outputs.

**Enhancements:**
- [x] Add confusion matrix, calibration curves, and expected calibration error to validation output — `ml-training/src/eval.rs` reports the matrix with the worst confusions called out, reliability bins, ECE, MCE, Brier and NLL, and fits the temperature that would fix overconfidence (one scalar that changes no prediction but brings confidence back in line with correctness). The maths works on plain prediction values, so it is tested without a model or a backend
- [x] Add a fixed held-out benchmark suite per task that every candidate model must pass before promotion — `benchmark create` freezes sample ids **and the labels they had at the time**, so a later relabel is reported drift rather than a moved target. Candidates trained on a different class ordering are folded into the benchmark's label space by name, since comparing two index spaces gives metrics that look plausible and mean nothing
- [x] Add evaluation slicing by crop, region, season, and image source — samples now carry capture location and time; region is a one-degree grid cell and season is derived from the timestamp, flipped below the equator. Slices too small to trust are reported and flagged, never gated on
- [x] Add Grad-CAM heatmaps for vision predictions and return them in the diagnosis response — with a global average pool between the feature map and the head, the gradient of a class logit has a closed form, so the composed model emits exact per-class maps as an extra output for one small matrix product. Only average pooling is accepted; the same arithmetic on a max-pooled backbone would produce a confident-looking map that means nothing. Returned on all four vision RPCs
- [x] Add SHAP-style feature attribution for yield and prescription outputs — permutation-sampling Shapley for the 22-feature yield model, exact enumeration for the seven-input prescription rules. Absent features are drawn from real stored rows rather than means, since an "average" field with one district's rainfall and another's soil is not a field any model was fitted on
- [x] Add regression gates in CI: fail promotion if benchmark accuracy drops or calibration worsens — `scripts/model-gate.sh` plus a `model-gate` job; the gate blocks on absolutes (samples, coverage, accuracy, macro F1, ECE, worst slice) and on regressions against the baseline already live
- [x] Surface "why this recommendation" explanations in the web diagnosis views — a new Image Analysis page runs the vision models over a field photo and paints the Grad-CAM map over it, with the focus region, the share of the image used, and a sentence describing where the model looked. A model that cannot explain itself says so rather than showing a fabricated heatmap
- [ ] Surface the same explanations in the Flutter app — the Dart toolchain and `protoc-gen-dart` are not available in this environment, so the generated Dart protos cannot be regenerated to carry the new `Explanation` message. The service side is done; only the mobile client remains
- [x] Persist diagnosis results, and their explanations, from Go — `SubmitDiagnosis` now runs the vision models and stores what they found, so a submitted diagnosis completes instead of staying pending forever. Explanations are stored alongside and returned with the result

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
- [x] Replace mock data in plant-diagnosis with real service calls — the service fetches the image bytes for the URLs it validated and hands them to the gateway, which previously received a URL and no pixels and silently fell through to demo weights. The gateway now declines an image it cannot see rather than analysing a black frame
- [x] Replace mock data in pest-prediction with real service calls — the service now asks the gateway to score a field and falls back to its weather rules only when that fails. Its AI client previously sent `structpb.Struct` values over hand-written method names, which cannot decode as the typed request the server expects; nothing called it, so the mismatch never surfaced. Its test suite had also stopped compiling against a widened logger interface, so 37 tests had not run in some time
- [x] Add a CI check that fails when TODO count increases in a service — `scripts/todo-budget.sh` holds a per-area budget in `.todo-budget` and fails the build when an area exceeds it. Budgets only go down; the script names the ones that can now be lowered. A raw count would either be zero and get disabled within a week, or be meaningless
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
