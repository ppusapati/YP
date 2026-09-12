# YieldPoint SLO / SLI Definitions

This document defines the Service Level Objectives (SLOs) and corresponding
Service Level Indicators (SLIs) for the YieldPoint precision agriculture
platform.

---

## Overview

| Service Group | Availability SLO | Latency SLO (P99) | Error Budget (30-day) |
|---|---|---|---|
| Auth Service | 99.9% | < 200 ms | 43.2 minutes |
| Farm / Field CRUD | 99.5% | < 500 ms | 3.6 hours |
| Satellite Processing | 99.0% | < 30 s | 7.2 hours |
| AI Gateway Inference | 99.5% | < 2 s | 3.6 hours |

---

## 1. Auth Service

**Purpose:** Handles user authentication, token issuance, and authorization.
Downtime here blocks every other operation.

### SLIs

| Indicator | Measurement |
|---|---|
| Availability | `sum(rate(http_requests_total{service="auth-service",code!~"5.."}[5m])) / sum(rate(http_requests_total{service="auth-service"}[5m]))` |
| Latency P99 | `histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket{service="auth-service"}[5m])) by (le))` |

### SLOs

- **Availability:** 99.9% of requests return a non-5xx response over a rolling
  30-day window.
- **Latency:** 99th-percentile request duration < 200 ms over any 5-minute
  window.

### Error Budget

- 30-day budget: `(1 - 0.999) * 30 * 24 * 60 = 43.2 minutes` of allowed
  downtime equivalent.
- Burn-rate alert: if the error budget consumption rate exceeds 14.4x the
  steady-state burn over a 1-hour window, fire a critical alert (the budget
  would be exhausted in roughly 2 days at that rate).

---

## 2. Farm / Field CRUD

**Purpose:** Core CRUD operations on farm, field, crop, sensor, and task
resources. Used throughout the platform UI and APIs.

### SLIs

| Indicator | Measurement |
|---|---|
| Availability | `sum(rate(http_requests_total{service=~"farm-service|field-service|crop-service|sensor-service|task-service",code!~"5.."}[5m])) / sum(rate(http_requests_total{service=~"farm-service|field-service|crop-service|sensor-service|task-service"}[5m]))` |
| Latency P99 | `histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket{service=~"farm-service|field-service|crop-service|sensor-service|task-service"}[5m])) by (le))` |

### SLOs

- **Availability:** 99.5% of requests return a non-5xx response over a rolling
  30-day window.
- **Latency:** 99th-percentile request duration < 500 ms over any 5-minute
  window.

### Error Budget

- 30-day budget: `(1 - 0.995) * 30 * 24 * 60 = 216 minutes (3.6 hours)`.
- Burn-rate alert: fire at 14.4x over 1 hour (budget exhausted in ~2 days).

---

## 3. Satellite Processing

**Purpose:** Ingestion, NDVI computation, analytics, and tile serving for
satellite imagery. These are inherently long-running workloads.

### SLIs

| Indicator | Measurement |
|---|---|
| Availability | `sum(rate(http_requests_total{service=~"satellite-ingestion-service|satellite-processing-service|satellite-analytics-service|satellite-tile-service|vegetation-index-service",code!~"5.."}[5m])) / sum(rate(http_requests_total{service=~"satellite-ingestion-service|satellite-processing-service|satellite-analytics-service|satellite-tile-service|vegetation-index-service"}[5m]))` |
| Latency P99 | `histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket{service=~"satellite-ingestion-service|satellite-processing-service|satellite-analytics-service|satellite-tile-service|vegetation-index-service"}[5m])) by (le))` |

### SLOs

- **Availability:** 99.0% of requests return a non-5xx response over a rolling
  30-day window.
- **Latency:** 99th-percentile request duration < 30 s over any 5-minute
  window. (The generous target reflects large image processing jobs.)

### Error Budget

- 30-day budget: `(1 - 0.99) * 30 * 24 * 60 = 432 minutes (7.2 hours)`.
- Burn-rate alert: fire at 14.4x over 1 hour.

---

## 4. AI Gateway Inference

**Purpose:** Rust-based gRPC gateway wrapping ML/AI engines (disease detection,
yield prediction, crop recommendation, plant diagnosis, etc.) with A/B testing
support.

### SLIs

| Indicator | Measurement |
|---|---|
| Availability | `sum(rate(ai_inference_requests_total{job="ai-gateway"}) - rate(ai_inference_errors_total{job="ai-gateway"})) / sum(rate(ai_inference_requests_total{job="ai-gateway"}))` |
| Latency P99 | `histogram_quantile(0.99, sum(rate(ai_inference_duration_seconds_bucket{job="ai-gateway"}[5m])) by (le))` |

### SLOs

- **Availability:** 99.5% of inference requests succeed (non-error) over a
  rolling 30-day window.
- **Latency:** 99th-percentile inference duration < 2 s over any 5-minute
  window.

### Error Budget

- 30-day budget: `(1 - 0.995) * 30 * 24 * 60 = 216 minutes (3.6 hours)`.
- Burn-rate alert: fire at 14.4x over 1 hour.

---

## Error Budget Calculation Method

The error budget quantifies how much unreliability a service is allowed before
violating its SLO.

### Formula

```
error_budget = (1 - SLO_target) * window_duration
```

For a 30-day rolling window:

```
error_budget_minutes = (1 - SLO_target) * 30 * 24 * 60
```

### Burn Rate Alerts

We use multi-window burn-rate alerting (as described in the Google SRE
Workbook, chapter 5). The key parameters:

| Alert Severity | Burn Rate | Long Window | Short Window | Budget Consumed |
|---|---|---|---|---|
| Page (critical) | 14.4x | 1 hour | 5 minutes | 2% in 1 hour |
| Ticket (warning) | 6x | 6 hours | 30 minutes | 5% in 6 hours |
| Low (info) | 1x | 3 days | 6 hours | 10% in 3 days |

A **burn rate of 14.4x** means the service is consuming errors at 14.4 times
the steady-state rate; at that pace the entire 30-day budget would be exhausted
in roughly 50 hours (~2 days).

### Prometheus Recording Rules (Example)

```yaml
# 5-minute error ratio for auth-service
- record: service:error_ratio:rate5m
  expr: >-
    sum(rate(http_requests_total{service="auth-service",code=~"5.."}[5m]))
    / sum(rate(http_requests_total{service="auth-service"}[5m]))

# 1-hour burn rate for auth-service (target 99.9%)
- record: service:error_budget_burn_rate:1h
  expr: >-
    service:error_ratio:rate1h / (1 - 0.999)
```

### Budget Exhaustion Policy

When a service exhausts its error budget for the current 30-day window:

1. **Feature freeze:** No new feature deployments for the affected service
   until the budget recovers.
2. **Reliability sprint:** The owning team allocates the next sprint
   exclusively to reliability work (performance, resilience, observability).
3. **Post-mortem required:** Any single incident consuming more than 20% of a
   service's monthly budget triggers a blameless post-mortem.

---

## Dashboards

These SLOs are visualised on the following Grafana dashboards:

- **Service Health** (`yp-service-health`): Real-time up/down, request rate,
  error rate, and latency percentiles for all 23 Go microservices.
- **Database Health** (`yp-database-health`): Connection pool utilisation,
  transaction rates, slow queries, replication lag.
- **Kafka Health** (`yp-kafka-health`): Consumer group lag, message throughput,
  partition counts, broker status.
- **AI Gateway** (`yp-ai-gateway`): Inference latency, throughput, error rates,
  and A/B variant comparison.
