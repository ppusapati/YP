# Performance Baselines

Target latency and throughput baselines for the YieldPoint platform. These baselines represent the performance levels that must be sustained under expected production load.

## Latency Targets

All latencies are measured end-to-end from the API gateway (Caddy) to the client.

### Auth Endpoints (`/auth/*`)

| Metric | Target |
|--------|--------|
| P50    | < 50ms |
| P95    | < 200ms |
| P99    | < 500ms |
| Error rate | < 1% |

Endpoints: `POST /auth/login`, `POST /auth/refresh`, `GET /auth/me`, `POST /auth/logout`

### CRUD Endpoints (ConnectRPC)

| Metric | Target |
|--------|--------|
| P50    | < 100ms |
| P95    | < 500ms |
| P99    | < 1s |
| Error rate | < 1% |

Services: FarmService, FieldService, CropService, SoilService, IrrigationService, TaskService, TraceabilityService, CommerceService

### Sensor Ingestion

| Metric | Target |
|--------|--------|
| P50    | < 200ms |
| P95    | < 1s |
| P99    | < 2s |
| Error rate | < 0.5% |

Endpoints: `SensorService/IngestReading`, `SensorService/BatchIngestReadings`

### Satellite Processing

| Metric | Target |
|--------|--------|
| P50 (ingestion request) | < 5s |
| P95 (ingestion request) | < 15s |
| P99 (ingestion request) | < 30s |
| P50 (tile retrieval) | < 500ms |
| P95 (tile retrieval) | < 3s |
| P99 (tile retrieval) | < 5s |
| Error rate | < 1% |

Services: SatelliteIngestionService, SatelliteProcessingService, SatelliteTileService

### AI Inference (gRPC via AI Gateway)

| Metric | Target |
|--------|--------|
| P50    | < 500ms |
| P95    | < 2s |
| P99    | < 5s |
| Error rate | < 2% |

Endpoints: `AIGatewayService/DiagnoseImage`, `AIGatewayService/RecommendCrops`, `AIGatewayService/PredictYield`, `AIGatewayService/ClassifyPlant`, `AIGatewayService/EvaluateFieldRisk`

## Throughput Targets

| Category | Target (requests/second) | VU Count | Notes |
|----------|--------------------------|----------|-------|
| Auth flows | 200 rps | 100 | Login, refresh, me, logout |
| Farm/field CRUD | 500 rps | 50 | Mixed create/read/update/delete |
| Sensor ingestion | 1000 rps | 100 | 500 sensors at 30s intervals |
| Batch sensor ingestion | 50 rps (50 readings each) | 100 | Burst scenario |
| Satellite operations | 10 rps | 10 | Heavy processing pipeline |
| AI inference | 40 rps | 20 | Mixed inference types |

## How to Run Load Tests

### Prerequisites

- [k6](https://k6.io/docs/get-started/installation/) installed (v0.54+)
- Target environment running and accessible
- Test user credentials seeded in the target database

### Run All Tests

```bash
# Against local environment (default)
./tests/load/run-all.sh

# Against staging
BASE_URL=https://staging-api.yieldpoint.dev ./tests/load/run-all.sh

# With custom credentials
TEST_USER_EMAIL=test@example.com TEST_USER_PASSWORD=secret ./tests/load/run-all.sh
```

### Run a Single Test

```bash
# Run only the auth flow test
./tests/load/run-all.sh --only auth-flow

# Or run directly with k6
k6 run tests/load/auth-flow.js

# With environment variables
k6 run --env BASE_URL=https://staging-api.yieldpoint.dev tests/load/farm-crud.js
```

### Available Tests

| Test | File | Description |
|------|------|-------------|
| auth-flow | `tests/load/auth-flow.js` | Login, token refresh, user info, logout |
| farm-crud | `tests/load/farm-crud.js` | Farm and field create/read/update/delete |
| sensor-ingestion | `tests/load/sensor-ingestion.js` | IoT sensor data ingestion and burst handling |
| satellite-upload | `tests/load/satellite-upload.js` | Satellite ingestion, processing, tile retrieval |
| ai-inference | `tests/load/ai-inference.js` | AI model inference (diagnosis, recommendations) |

### CI Integration

Load tests can be triggered in CI:

1. **Manual trigger**: Go to Actions > Load Tests > Run workflow, select the target environment.
2. **PR label**: Add the `load-test` label to a pull request. Results are posted as a PR comment.

## How to Interpret Results

### k6 Output

k6 prints a summary table after each test run. Key metrics to watch:

- **http_req_duration**: End-to-end request latency. Check p(95) and p(99) against the targets above.
- **http_req_failed**: Percentage of requests that returned a non-2xx status. Should be below the error rate target.
- **iterations**: Total completed VU iterations. Higher is better (indicates the system kept up).
- **vus**: Number of concurrent virtual users. Should match the test configuration.

### Custom Metrics

Each test defines custom YieldPoint metrics prefixed with `yp_`:

- `yp_login_duration`, `yp_refresh_duration`, etc.: Per-endpoint latency trends.
- `yp_auth_errors`, `yp_crud_errors`, etc.: Per-category error rates.
- `yp_readings_ingested`: Total sensor readings successfully ingested.

### Threshold Failures

k6 exits with code 99 when thresholds are breached. The summary output marks failed thresholds with a cross. When a threshold fails:

1. Check which specific metric breached the threshold.
2. Look at the p(95) and p(99) values to understand tail latency.
3. Compare against the baselines in this document.
4. Investigate whether the issue is in the service, database, or infrastructure.

### JSON Results

The `run-all.sh` script saves detailed JSON results to `tests/load/results/`. Each line in the JSON file is a metric data point that can be analyzed with tools like:

- k6 Cloud (upload with `k6 cloud`)
- Grafana + InfluxDB (use `--out influxdb=http://...`)
- Custom scripts parsing the JSON output

### Baseline Comparison

When establishing new baselines after infrastructure changes:

1. Run the full test suite three times against the target environment.
2. Take the median of the three runs for each metric.
3. Update the targets in this document if the new baselines are significantly different.
4. Document the infrastructure change that prompted the update.

### Common Issues

| Symptom | Likely Cause |
|---------|-------------|
| High p(99) but low p(50) | Garbage collection pauses or connection pool exhaustion |
| Increasing latency over time | Memory leak or connection leak in the service |
| Burst of errors at test start | Cold start, connection pool warming, rate limiter |
| Sensor batch errors > 0.5% | Database write contention under high concurrency |
| AI inference timeouts | Model loading cold start or GPU memory pressure |
