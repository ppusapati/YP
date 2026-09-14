# Stub and TODO debt: triage

An inventory of every TODO, FIXME, stub and placeholder in the repository,
sorted into **implement**, **delete**, or **leave with a reason**.

The headline finding is that the marker count was anti-correlated with risk.
The directories with the most TODOs — traceability, farm, yield, satellite,
pest, irrigation, field, at 12 to 14 each — were almost entirely event handlers
that log and drop, which is bad but visible. The services with *zero* markers
included four that returned confident answers derived from nothing, three of
which persisted those answers and one of which published domain events about
them. Counting comments does not find that class of defect; reading what a
function returns does.

`scripts/todo-budget.sh` enforces a per-area ceiling that only goes down.
`bash scripts/todo-budget.sh` reports; `--update` re-baselines after clearing
markers.

---

## The categories that matter

### 1. Silent success — fixed

A caller receives a plausible response and nothing real happened. This is the
worst class because there is no error to catch, no marker to grep, and — where
the result is persisted — the fabrication outlives the request and becomes
indistinguishable from real data.

| Where | What the caller believed | Status |
|---|---|---|
| plant-diagnosis `SubmitDiagnosis` | Their photo was analysed | **Fixed** — the AI path now runs and results are persisted |
| ai-gateway image handling | The stored photo was the input | **Fixed** — an all-zero frame is no longer substituted for a URL |
| pest-prediction AI client | Predictions used the model | **Fixed** — was sending `structpb.Struct` over hand-written method strings; rewritten on generated stubs |
| alert-service (all of it) | Alerts were stored and acknowledged | **Fixed** — schema, repository and Kafka consumer added |
| satellite-analytics `DetectStress` | Imagery was analysed and stress found | **Fixed** — asked the gateway to analyse an empty raster, then wrote a hardcoded alert and emitted an event; now measures NDVI against the field's own baseline |
| satellite-analytics `RunTemporalAnalysis` (monolith copy) | A trend was fitted over their period | **Fixed** — returned a literal slope of 0.02 and R² of 0.87; fork collapsed onto the real implementation |
| satellite-tile `GetTile` | They received a map tile | **Fixed** — returned HTTP 200 with zero bytes, which renders as transparent; now fetches from object storage |
| plant-diagnosis `GetTreatmentPlan` | A plan was derived from their diagnosis | **Fixed** — persisted a canned plan; now returns an error |
| plant-diagnosis `DetectNutrientDeficiency` | Nitrogen deficiency was detected | **Fixed** — returned a fabricated finding at 0.5 confidence; now returns an error |
| disease-detection engine `load()` | A trained model was loaded | **Fixed** — fell back to demo weights and reported success; now fails |
| plant-ai-inference `load_model()` | A trained model was loaded | **Fixed** — discarded the path entirely; now fails |

The pattern worth naming: **every one of these had a fallback that returned
success.** A fallback is right when it degrades a feature; it is wrong when it
substitutes for the answer the caller asked for. The test is whether the caller
can tell. If not, fail.

`satellite-service/internal/application/satellite_service.go:183` has the
inverse, and is the reference to copy: *"Return an error rather than
plausible-looking synthetic values."*

### 2. Silent success — outstanding

| Where | What the caller believes | Why it is still open |
|---|---|---|
| `packages/observability/graph/tracker.go:236` | It received p50/p95/p99 latency | Indexes an unsorted slice. A one-line sort fixes it; nothing reads it yet, so it is not urgent, but it will be wrong the moment something does |
| `packages/loadbalancer/algorithms/latency_aware.go:115` | Percentiles | `P95 = 0.95 × Max` is an affine transform of the maximum, not a percentile. Any routing keyed on P95 is keyed on max |
| `packages/config` `Watch()` | A config-change callback was registered | The observer is stored and never invoked; the file watcher underneath returns "not implemented". No non-test callers today |
| `alert-service/internal/scheduler` | Threshold alerts are scanned periodically | The package is imported by nothing and its `FieldProvider` has no implementation. Alerts now arrive via the event consumer, so the scanner is redundant rather than broken — **delete it or wire it**, but do not leave it looking live |
| `web/apps/shell/.../dashboard/+page.svelte` | These are their tenant's numbers | Hardcoded $125,430 revenue and 1,234 orders under a live user greeting |
| `web/apps/shell/src/routes/+page.svelte` | — | `// Temporarily bypass auth`; `/` goes straight to the dashboard |
| `mobile/.../irrigation_remote_datasource.dart:117` | The field has no irrigation alerts | `getAlerts()` returns an empty list with no network call |
| `mobile/.../soil_remote_datasource.dart:69` | Results are date-filtered | `from`/`to` are accepted and ignored |
| `mobile/.../create_listing_screen.dart:291` | Their listing is attached to a farm | Submits `farmId: ''` |

### 3. Events consumed, acked, and dropped

About 25 distinct handlers (≈40 across the duplicated trees) log as if they did
work, then `return nil`. Kafka commits the offset and the event is gone.

Ordered by consequence rather than by count:

| Handler | Consequence |
|---|---|
| `traceability_consumer.go:191` harvest recorded | **The chain of custody has a hole at the harvest** — the one link a traceability service exists to provide |
| `field_consumer.go:107` farm deleted | Orphaned fields stay active under a deleted farm |
| `farm_consumer.go:88,104,120` field created/updated/deleted | Farm field counts and total area diverge from reality, then `GetFarm` serves them as authoritative |
| `irrigation_consumer.go:137` field deleted | Active irrigation schedules keep running against a deleted field |
| `satellite_consumer.go:115,146` farm/field deleted | Pending imagery tasks are never cancelled and keep billing |
| `sensor_consumer.go:99,114` field/farm deleted | Sensors are never decommissioned |
| `traceability_consumer.go:99,113,129,145,175` | Provenance links never written |
| `yield_consumer.go:119` crop assigned | No prediction generated; the UI shows "no data" rather than an error |
| `crop_consumer.go:104`, `soil_consumer.go:129` | Assignments stay active; samples never archived |

**Triage: implement.** These are not hard — each is a call to a service method
that already exists — but they are numerous, and the cascade deletes have
correctness implications (orphaned rows, phantom billing) that make them worth
doing before the cosmetic ones.

**Do not** convert these to "log and return an error" as a stopgap: that turns a
silent drop into a poison-pill message that blocks the partition.

### 4. The duplicated package trees

Most services keep two copies of each package: `<svc>/internal/...` for the
standalone binary and `<svc>/...` for `cmd/monolith`. Both compile. **They have
already drifted**, and the drift is what produced the fabricated temporal
analysis above.

`alert-service`, `satellite-analytics-service` and `satellite-tile-service` are
now collapsed onto alias shims — `type X = internal.X`, which is the same type,
so one implementation serves both. The remaining services should follow.

This is the highest-leverage item on the list, because until it is done every
fix elsewhere has to be made twice and there is measured evidence that the
second one gets missed.

### 5. Informational markers — leave

`NOTE: proto types are generated by buf generate`, repeated across handler
files, is accurate and useful. `farm_service_test.go:256`'s note that the
CreateFarm happy path needs a real pgxpool documents a genuine coverage gap.
`scripts/new-service.sh`'s TODOs are scaffolding template text, emitted into
generated services deliberately.

These are counted by the ratchet and that is fine: the budget only has to not
go up.

---

## What the audit changed about the ratchet

`scripts/todo-budget.sh` was measuring noise.

Its `AREAS` list covered 13 directories and left **52 markers — about a third —
entirely outside enforcement**, including every satellite service and all of
yield, crop, soil and sensor. It now lists every top-level area.

And `web` carried a budget of 13 against **one** real marker. Ten were a single
wasm-bindgen comment repeated across build output under `pkg/`; three were
phone-number masks, `XXX-XXX-XXXX`, matching on word boundaries. Twelve free
TODOs before the ratchet would have noticed anything.

A budget that permits more debt than exists is worse than no budget, because it
reads as enforcement. Both filters are fixed and `.todo-budget` re-baselined.

---

## Suggested order

1. **Collapse the duplicated trees** onto alias shims. Everything else is
   cheaper afterwards, and safer.
2. **The remaining silent-success cases** in §2 — particularly the web
   dashboard, which shows a logged-in user fabricated revenue for their own
   tenant, and the two percentile functions, which will be wrong the moment
   anything routes on them.
3. **The dropped event handlers** in §3, cascade deletes first.
4. **Delete `alert-service/internal/scheduler`** or wire it. An unreferenced
   package that describes a periodic job nobody runs is worse than no package.
