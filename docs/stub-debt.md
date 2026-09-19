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
| `packages/observability/graph/tracker.go:236` | It received p50/p95/p99 latency | **Fixed** — three defects, not the one recorded here. It indexed an *unsorted* slice, so the answer depended on arrival order and one 30s call among 999 at 10ms became the p99. It kept the *first* thousand samples under a comment reading "keep recent latencies (last 1000)", so a dependency that degraded later reported the p99 of its healthiest hour for ever. And `depService := key` put "service:operation" into a field named Service, so every operation appeared as its own service. Now uses `packages/quantile` over a sliding window, and Dependency carries Operation separately |
| `packages/loadbalancer/algorithms/latency_aware.go:115` | Percentiles | **Fixed** — `P50 = mean` (a latency distribution is right-skewed, so its mean sits above its median, which is the reason anyone asks for a median) and `P95 = 0.95 × Max` against a maximum that never decayed, so one slow call at startup pinned p95 for the life of the process. Measured: an endpoint serving 999 calls at 10ms and one at 5s reported P95 = 4.75s, and P95 stayed at 950ms across a full window of 5ms calls. Now sampled, and `WithMaxLatencySamples` — config that nothing read, because there were no samples to size — sizes the window |
| `packages/config` `Watch()` | A config-change callback was registered | The observer is stored and never invoked; the file watcher underneath returns "not implemented". No non-test callers today |
| `alert-service/internal/scheduler` | Threshold alerts are scanned periodically | The package is imported by nothing and its `FieldProvider` has no implementation. Alerts now arrive via the event consumer, so the scanner is redundant rather than broken — **delete it or wire it**, but do not leave it looking live |
| `web/apps/shell/.../dashboard/+page.svelte` | These are their tenant's numbers | **Fixed** — hardcoded $125,430 revenue and 1,234 orders under a live user greeting; now fetched from farm, field and alert clients, and a figure that cannot be retrieved is shown as unavailable rather than as a number |
| `web/apps/shell/src/routes/+page.svelte` | — | **Fixed** — closed twice over: `(app)/+layout.server.ts` now requires a validated session for every route in the group, and `+page.server.ts` routes `/` on the server to the dashboard or to login. That made the client-side `$effect` unreachable, but it and its `// Temporarily bypass auth` comment stayed behind; both are gone now, because a comment announcing a bypass misleads whether or not the code under it can still run |
| `mobile/.../irrigation_remote_datasource.dart` | The field has no irrigation alerts | **Fixed** — returned an empty list with no network call; now asks alert-service, which owns alerts, and throws rather than swallowing a failure into an empty list |
| `mobile/.../soil_remote_datasource.dart` | Results are date-filtered | **Fixed** — `from`/`to` were accepted and ignored; now applied client-side, with a note on when the filter should move into the proto |
| `mobile/.../create_listing_screen.dart` | Their listing is attached to a farm | **Fixed** — submitted `farmId: ''`; the form now requires the seller to pick one |

The three mobile fixes are **not compile-checked**: there is no Flutter or Dart
toolchain in the environment they were written in. They follow the patterns of
neighbouring code in the same files and need `flutter analyze` before release.

### 3. Events consumed, acked, and dropped

Handlers that log as if they did work, then `return nil`. Kafka commits the offset
and the event is gone.

This used to read "about 25 distinct handlers (≈40 across the duplicated trees)".
The duplicated trees no longer exist — see §4 — so the second number is meaningless
and the first is now the whole population. Seven remain open below.

Ordered by consequence rather than by count:

| Handler | Consequence | Status |
|---|---|---|
| traceability, harvest recorded | **The chain of custody has a hole at the harvest** — the one link a traceability service exists to provide | **Fixed** |
| traceability, crop assigned to field | The chain did not start until harvest, so nothing that happened while the crop grew had a batch to attach to | **Fixed** — the record now opens at planting and the harvest closes it |
| traceability, irrigation | "Recording for compliance" while recording nothing, for one of the inputs an organic or GAP audit asks about | **Fixed** — attached to the batch growing in that field |
| traceability, farm/field/crop created | Provenance links never written | **Closed as not applicable** — see below |
| `field_consumer.go` farm deleted | Orphaned fields stay active under a deleted farm | **Fixed** |
| `farm_consumer.go:88,104,120` field created/updated/deleted | Farm field counts and total area diverge from reality, then `GetFarm` serves them as authoritative | Open |
| `irrigation_consumer.go:137` field deleted | Active irrigation schedules keep running against a deleted field | Open |
| `satellite_consumer.go:115,146` farm/field deleted | Pending imagery tasks are never cancelled and keep billing | Open |
| `sensor_consumer.go:99,114` field/farm deleted | Sensors are never decommissioned | Open |
| `yield_consumer.go:119` crop assigned | No prediction generated; the UI shows "no data" rather than an error | Open |
| `crop_consumer.go:104`, `soil_consumer.go:129` | Assignments stay active; samples never archived | Open |

**Triage: implement.** These are not hard — each is a call to a service method
that already exists — but they are numerous, and the cascade deletes have
correctness implications (orphaned rows, phantom billing) that make them worth
doing before the cosmetic ones.

**Do not** convert these to "log and return an error" as a stopgap: that turns a
silent drop into a poison-pill message that blocks the partition.

**One of them was the wrong thing to ask for.** The TODOs on traceability's
farm-created, farm-updated, field-created and crop-created handlers said to call
`AddSupplyChainEvent`, which the model cannot express: a supply chain event
hangs off a traceability record, and a record is one batch from one field's
season. A farm being renamed or a crop *type* being registered belongs to no
batch. Those four now do nothing on purpose, with the reasoning in the code, and
what the farm and field actually contribute to provenance is read through the
outbound clients when a chain is assembled — current at that moment rather than
duplicated into an event stream that then drifts.

Worth naming because implementing them as written would have produced a table
full of supply chain events attached to nothing, which counts as clearing the
debt and is worse than the TODO.

### 4. The duplicated package trees — resolved

Most services kept two copies of each package: `<svc>/internal/...` for the
standalone binary and `<svc>/...` for `cmd/monolith`. Both compiled. **They had
already drifted**, and the drift is what produced the fabricated temporal
analysis above.

The audit that followed measured it: twenty-two services carried a duplicate and
fifteen had diverged. The monolith's yield-service had no weather client, its
irrigation-service had no AI adapter and no actuator, and its field and
traceability services were an architecture generation behind — no Kafka
consumer, no repository. The image was built by CI and pushed by CD, so the
stale copy shipped.

Alias shims (`type X = internal.X`) collapsed five of them, and the rest were
never going to follow: the nine newest services are hexagonal with their own
`internal/` trees, which Go will not let a package outside their directory
import, so the monolith could not have served them however much of it was
collapsed.

So the monolith is gone, and with it ninety-seven duplicate packages and one
hundred and thirty-two files. What it uniquely served — `/ws` and `/events` —
moved to `cmd/realtime`, a binary with no services in it. The single-binary
deployment it offered is Option C in `DEPLOYMENT.md`: docker-compose, which runs
all thirty-one services on one host rather than twenty-two stale ones.

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

1. ~~**Collapse the duplicated trees** onto alias shims.~~ Done differently and
   more thoroughly: the monolith that needed them is deleted, so there is only
   one tree left to fix things in. See §4.
2. **The remaining silent-success cases** in §2 — particularly the web
   dashboard, which shows a logged-in user fabricated revenue for their own
   tenant, and the two percentile functions, which will be wrong the moment
   anything routes on them.
3. **The dropped event handlers** in §3, cascade deletes first.
4. **Delete `alert-service/internal/scheduler`** or wire it. An unreferenced
   package that describes a periodic job nobody runs is worse than no package.
