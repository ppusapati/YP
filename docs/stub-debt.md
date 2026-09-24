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
| **All nine AI clients** | The gateway received what they sent | **Fixed** — every one sent `structpb.Struct` over `conn.Invoke` with the method name written out by hand. That cannot work: a Struct serialises as a map entry list and bears no resemblance on the wire to the typed request the server decodes. pest-prediction was converted first; the remaining seven followed, and moving to the generated stubs is what made the compiler surface the rest. field-service's `GeneratePrescription` took seven arrays of per-cell agronomy data, built a list out of the NDVI one, and sent none of them — so every "variable rate" map was uniform by construction. Its `EvaluateFieldRisk` sent weather, soil and detections flat where the proto nests them, and the gateway substitutes defaults for whatever is absent, so the score described a nominal field. crop-service read `suitability_pct`, `season` and `reasons`, none of which exist on `CropRecommendation`. alert-service read `farm_id` and `evaluated_at`, neither of which exists on the response — and sent only a field id, so the gateway scored every field against its own defaults (22°C, 30% soil moisture). **Now closed**: alert-service has weather, soil and plant-diagnosis clients, and passes observed temperature, rainfall, forecast min/max, reference ET, volumetric soil moisture, and the pest, disease and nutrient findings of the field's most recent completed diagnosis. Growth stays unset, and the code says why: the gateway's growth risk compares an actual against an expected value, and nothing in this platform holds an expected one — satellite-analytics' baseline is the fitted start of the requested window, which a healthy crop exceeds by far more than the 20% deviation threshold, so wiring it would raise a growth anomaly on every field that is growing normally. NDVI is unset with it, because the alert engine only prints NDVI inside that same growth-anomaly message and it enters no score. satellite-analytics never read `ndvi_values` — the NDVI grid, the RPC's entire output. irrigation-service assigned ETc straight into a crop coefficient under a comment reading `ETc/ET0`, so Kc carried mm/day where a ratio belongs |
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
| `packages/config` `Watch()` | A config-change callback was registered | **Fixed** — the observer was stored and never invoked, the file source's `Watch` returned "not implemented", and `Load` never called it: a caller registering a callback got no error and no callback. The watcher underneath is now real, and watches the containing *directory* rather than the file, because fsnotify follows the inode — a watch on the path itself survives an in-place write but dies silently on the atomic write-and-rename that every editor and every ConfigMap update performs. `Close` stops the watchers it starts; a source that cannot be watched degrades to static config with a warning rather than failing `Load` |
| `alert-service/internal/scheduler` | Threshold alerts are scanned periodically | **Fixed** — and it was not redundant, as recorded here. The event consumer ingests what *other services* noticed; a rule is the one place the farmer states a condition in advance, and three web routes and a mobile screen write them. Nothing read them. Even wired, the old scanner logged `"Risk threshold exceeded"` and returned without creating an alert, compared every rule with `score >= threshold` whatever condition the farmer chose — so an `LT` rule fired on exactly the fields that were fine — hardcoded a 60-minute cooldown over `rule.GetCooldownMinutes()`, kept that cooldown in a per-replica map lost on restart, and hung off a `FieldProvider` interface with no implementation. Now enumerates due rules instead of fields (no cross-tenant field listing exists to enumerate), honours the condition, and takes the cooldown from `last_fired_at`, which every replica and every restart agrees on |
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
The duplicated trees no longer exist — see §4 — so the second number is
meaningless.

It then claimed the first number was "the whole population". **It was not**, and
that is worth recording because it is the same mistake this document was written
to catch. The table below was assembled by reading handlers that looked
consequential, not by sweeping the markers; when the listed rows were cleared and
the markers swept properly, `yield_consumer.go`'s field-deleted handler turned up
as a silent drop of exactly the class already in the table, and it had never been
listed. A register of debt that is itself hand-maintained goes stale the same way
a hand-maintained service list does — and §4 of this document is about exactly
that failure. The rows below now come from a marker sweep, which turned up two
more — `yield_consumer`'s field-deleted handler and `pest_consumer`'s
crop-assigned one.

The sweep is also how the **growth-stage vocabularies were found to diverge** —
**now reconciled**, and the divergence was worse than it first looked.
field-service had BUDDING = 4, FLOWERING = 5, FRUIT_SET = 6, RIPENING = 7,
MATURITY = 8, SENESCENCE = 9; pest-prediction had FLOWERING = 4, FRUITING = 5,
MATURATION = 6, HARVEST = 7. Two failures, neither of which raised an error:

- **By name.** A stage in one list and not the other was scored as unstaged,
  and growth stage is a quarter of the pest risk score.
- **By number.** field's `FLOWERING(5)` was pest's `FRUITING(5)`, so any path
  carrying the enum rather than its name decoded one stage as another and
  produced a plausible score for the wrong thing. Nothing would have shown
  this: at planting the overlapping stages happen to agree.

pest-prediction adopted field's list, names and numbers, because field is the
phenological sequence and the place a farmer actually records the stage. Three
stored values were renamed by migration (`FRUITING`→`FRUIT_SET`,
`MATURATION`→`MATURITY`, `HARVEST`→`SENESCENCE`, each keeping its scoring
band), and BUDDING and RIPENING are scored for the first time.

The guard is a conformance test, not a comment: `pest-prediction-service/
internal/domain/growth_stage_conformance_test.go` compares the two generated
enums through their name/number maps, so drift fails the build instead of
warning at runtime. It is written against the generated maps rather than a
hand-written list, so it cannot go stale the way the vocabularies did.

Ordered by consequence rather than by count:

| Handler | Consequence | Status |
|---|---|---|
| traceability, harvest recorded | **The chain of custody has a hole at the harvest** — the one link a traceability service exists to provide | **Fixed** |
| traceability, crop assigned to field | The chain did not start until harvest, so nothing that happened while the crop grew had a batch to attach to | **Fixed** — the record now opens at planting and the harvest closes it |
| traceability, irrigation | "Recording for compliance" while recording nothing, for one of the inputs an organic or GAP audit asks about | **Fixed twice.** The handler was written first and still recorded nothing: it keyed the batch off `field_id` and listened for `agriculture.irrigation.created`, whose producer sent `{irrigation_id, tenant_id}` and whose domain type — a named plan with a status — has no field, no zone and no water to send. So every message took the "missing tenant or field" guard, logged that it was not recording it, and returned nil. The test passed because it hand-built a payload with a `field_id` in it, and quoted its litres as a string so that a `str` read found them; a producer sending a number would have read as absent. Now: irrigation-service publishes `agriculture.irrigation.triggered` — the run, not the plan — carrying the field (resolved from the zone, since a schedule's own `field_id` is nullable and a zone's is not), the farm, the zone, the start time and the quantity; the consumer listens for that; and the payload contract is pinned from both ends, against the literal keys, because a test that builds its own payload proves only that the consumer can parse itself. The quantity is published and rendered as **planned**, not applied — see below |
| traceability, farm/field/crop created | Provenance links never written | **Closed as not applicable** — see below |
| `field_consumer.go` farm deleted | Orphaned fields stay active under a deleted farm | **Fixed** |
| `farm_consumer.go:88,104,120` field created/updated/deleted | Farm field counts and total area diverge from reality, then `GetFarm` serves them as authoritative | **Part fixed, part closed as not applicable.** The consequence recorded here was wrong on both counts. There is no field count — not on `Farm`, not in the `farms` table, not in the proto — so nothing could drift; whoever needs one asks field-service. `total_area_hectares` is the farmer's own declared area for the parcel, typed into CreateFarm and editable, so summing the fields into it would have overwritten what they entered with a strictly smaller number, silently, on every field created. What farm-service *does* hold about a field is its `management_unit_fields` membership, keyed on an id from another service with no foreign key to cascade from — a deleted field stayed in its unit for ever. `onFieldDeleted` now drops it |
| `irrigation_consumer.go:137` field deleted | Active irrigation schedules keep running against a deleted field | **Fixed** — the worst of the three, because a schedule is not a stale row but a valve: the next window would have run water onto ground nobody farms and billed for it. Zones are deliberately left alone; a zone describes hardware in the ground, which outlives the field record |
| `satellite_consumer.go:115,146` farm/field deleted | Pending imagery tasks are never cancelled and keep billing | **Fixed for the field, closed as not applicable for the farm.** The billing consequence recorded here was wrong: nothing reads `satellite_tasks` — the repository could only insert — so no acquisition was ever ordered from one. The real defect was a table accumulating PENDING rows for fields nobody can open, and the first thing to drain that queue would have picked them up. The farm handler was the wrong thing to ask for: a task carries `field_id` and no `farm_id`, and field-service already cascades a farm deletion into one delete event per field |
| `sensor_consumer.go:99,114` field/farm deleted | Sensors are never decommissioned | **Fixed** — sensors stayed ACTIVE against a deleted field, still ingesting and still raising threshold alerts naming a field nobody could open. Both handlers are kept, not just the farm one: a sensor can sit at the farm with no field — a weather station by the gate — and no field-deleted event would ever reach it |
| `yield_consumer.go:119` crop assigned | No prediction generated; the UI shows "no data" rather than an error | **Fixed** — the field's yield page showed "no data" from planting until somebody asked for a prediction by hand, which is the one moment a farmer is least likely to, having just told the system what they planted. The opening prediction is a baseline: no soil, weather or pest scores exist on planting day, so it stores the crop's base yield at **zero confidence** rather than dressing it up. `field.crop.assigned` now carries `farm_id`, `season` and `planting_date`, which a prediction needs and the consumer could not otherwise get |
| `crop_consumer.go:104` field deleted | Crop assignments stay active | **Closed as not applicable, and the real bug was elsewhere.** crop-service has no assignment table — its schema is the catalogue of what a crop *is*. Assignments are facts about a field and live in field-service's `crop_assignments`, which `DeleteField` was not touching: it soft-deleted the `fields` row alone and left the assignments, segments and crop cycles live and unreachable, so `GetCropHistory` on a re-created field would have served the previous occupant's plantings. Fixed there, in one statement with the field |
| `pest_consumer.go` crop assigned | No pest risk assessment until somebody asks for one by hand | **Fixed** — also never listed above. Three things about it had to be got right, and the obvious implementation gets each of them wrong. It reads `crop_name`, not `crop_id`: `PredictPestRisk` stores whatever it is given as the prediction's crop type and forwards it to the AI gateway, and the rules scorer ignores crop type entirely — so passing the opaque id would file a farmer-facing prediction against an unreadable crop while the risk number looked perfectly normal. It carries the growth stage, worth a quarter of the score. And it suppresses the alert: risk ≥ HIGH normally raises one and weather alone clears that on a warm wet day, so without it, planting three fields on one damp morning pages the farmer three times about pests on bare ground. No pest species is named, because a crop assignment does not imply one |
| `yield_consumer.go` field deleted | Forecasts and harvest plans stand against a field nobody farms | **Fixed** — never listed above until a marker sweep found it. A harvest plan is not a stale row: it is a date somebody is meant to turn up with a combine. Predictions and plans are archived; **yield records are deliberately untouched**, because a record is what was actually cut off that ground and is what a traceability or subsidy audit asks for. `is_active = FALSE` rather than `deleted_at`, and that is not cosmetic: `GetCropPerformance` joins a record to its prediction on `yp.deleted_at IS NULL` inside `COALESCE(..., 0)`, so soft-deleting would have rendered a real forecast as a predicted yield of zero — a harvest that beat its forecast showing as "predicted 0, actual 4200" |
| `soil_consumer.go:129` field deleted | Samples never archived | **Fixed** — a farm-level soil listing kept returning samples and health scores for a field nobody could open. Archived (`is_active = FALSE`) rather than soft-deleted: these are laboratory measurements of ground that still exists — the field record was an administrative boundary, not the dirt — and they are what an organic or GAP audit asks for years later, so `deleted_at` stays NULL |

**The irrigation quantity is published as `planned_water_liters`, not as an
actual**, and that is not pedantry. `TriggerIrrigation` copies the schedule's
figure into the event's `ActualWaterLiters` at start time — before water could
have flowed — and nothing revises it afterwards, because `UpdateEvent` has no
caller. Nothing dialled a valve either, when that was written: `NewActuator` had no
caller, so the actuator, its interlocks and the whole `ControllerClient` port
were unreachable, and no implementation of that port existed. **That is now
wired** — clients for MQTT, LoRaWAN and Modbus, a commands table written before
each send, and `TriggerIrrigation` refusing rather than recording a run nothing
performed. **The quantity is now measured too**: the controller's cumulative water meter
is read when the valve opens and again when it closes, and the difference is
recorded with the source that produced it — METER, ESTIMATED from a measured
flow rate, or UNMETERED, because a number in a column called water_liters says
nothing about whether anybody measured it. `CreateWaterUsageLog` has its first
caller, so `GetWaterUsage` no longer returns an empty list for every zone on
every farm. What is still deliberately absent is the nameplate flow rate times
the duration: every panel has one, so it would always produce a figure, and the
figure would be wrong in the one case anybody cares about — a blocked line
delivers nothing at exactly that rate.
An auditor reading "12000 L planned" knows to ask for the meter; one reading
"12000 L" does not. The consumer prefers a measured `water_amount_liters` when
a producer ever sends one, so metering this path later needs no change there.

**The migrations now run against a real PostgreSQL**, and that found two things
review had not. **auth-service's `000004_add_rls` could not apply to an empty
database at all**: it copied `AND deleted_at IS NULL` from the other services'
policy template into a `CREATE POLICY` on `users`, a table that has never had
that column, so the statement failed and migrate rolled the whole file back.
The authentication service could not be deployed from scratch, and nothing
caught it because the only thing that creates an empty database is a new
deployment. (The column is not missing by oversight: this service disables an
account with `is_active`, and a disabled user has to stay readable or an
administrator cannot re-enable it.) And `CreateWaterUsageLog` returned a 500
for a duplicate, because `ON CONFLICT DO NOTHING ... RETURNING` yields no rows
— so the idempotency guard working correctly was logged as "the run's water
usage could not be recorded". `tools/migrationcheck` now applies every
service's migrations to its own empty database, and CI runs it.

**Row-level security had never been exercised anywhere — now fixed.** The
repositories issued their queries straight on the pool, and nothing on that
path ran `set_config('app.tenant_id', ...)`; only `uow.RLSFactory` did, inside
a transaction they do not open. Under the non-superuser role
`scripts/setup-db-roles.sql` defines for production, every INSERT violated its
policy's WITH CHECK and every SELECT matched nothing — verified against a real
database. docker-compose connects as the superuser `yieldpoint`, which bypasses
RLS entirely, which is why it went unnoticed: the policies had never run in
development, in tests, or in CI.

`packages/database/rlspool` fixes it in one place. A pool built there sets
`app.tenant_id`, `app.company_id` and `app.branch_id` on every connection as it
is acquired, from the context of the query acquiring it — pgx's `PrepareConn`
receives that context, which is what makes this possible without touching a
single repository. All 29 services now build their pool through it.

The settings are written on **every** acquire, empty included, and that costs a
round trip. Connections are shared between tenants, so skipping the write when
a caller has no tenant would leave the previous caller's in place and hand the
next query somebody else's rows. A cache keyed on the connection would avoid
most of those round trips and is not worth the class of bug a stale entry would
be.

Two things read across tenants on purpose — alert-service's rule scanner and
irrigation-service's run-closing sweep — and a scoped pool would leave them
reading nothing, silently, for ever. They now take a separate unscoped pool
from `DATABASE_URL_SYSTEM`, and `rlspool.Probe` checks at startup whether that
role can actually bypass RLS, logging an error naming the consequence when it
cannot. A sweep that finds nothing is otherwise indistinguishable from a
platform with nothing to do.

CI runs both halves against a real database under the application role: that a
pool isolates tenants, and that a service's repository works through it. The
irrigation repository suite, which skipped under `yp_app` before, passes.

**Triage: done.** The original note said "these are not hard — each is a call to
a service method that already exists". That was true of about half of them.

**Do not** convert a dropped handler to "log and return an error" as a stopgap:
that turns a silent drop into a poison-pill message that blocks the partition.
The error contract that came out of doing these, and which the tests pin:

- A listing or write failure is **returned**, so the consumer retries. A
  database blip must not orphan the rows.
- One item in a batch failing is **logged and skipped**, because a replay finds
  whatever is left and abandoning the page strands the rest.
- A page where *every* item failed is **returned** — the next page would fail
  identically, and reporting success is a lie Kafka then commits.
- An event with no tenant is **dropped, not retried**: it can never succeed,
  retrying blocks the partition, and guessing a tenant touches another
  tenant's rows.

And the loop shape is not one shape. A cascading *delete* re-reads the first
page, because deleting shifts the window and an advancing offset skips as many
rows as it deletes. A cascading *status change* must advance the offset instead,
because the row stays in the listing. Confusing the two silently skips half the
rows or never terminates.

**Six of them were the wrong thing to ask for**, which is the more useful
finding: a TODO is a note somebody wrote before they understood the model, and
implementing one as written can be worse than leaving it.

- **traceability** farm-created, farm-updated, field-created, crop-created said
  to call `AddSupplyChainEvent`, which the model cannot express: an event hangs
  off a record, and a record is one batch from one field's season. A farm being
  renamed belongs to no batch. Implementing them would have produced a table
  full of supply chain events attached to nothing.
- **`farm_consumer`** field-created and field-updated said to recalculate the
  farm's field count and total area. There is no field count anywhere in the
  service, and total area is the farmer's own declared figure — summing the
  fields into it would have overwritten what they typed with a smaller number
  on every field created.
- **`crop_consumer`** field-deleted said to deactivate crop assignments.
  crop-service has no assignment table; the rows are field-service's, and
  field-service was the thing not deleting them.
- **`satellite_consumer`** farm-deleted said to cancel the farm's tasks. A task
  carries `field_id` and no `farm_id`, and field-service already cascades a
  farm deletion into one delete event per field.

Each now does nothing on purpose, with the reasoning in the code and a test
asserting it, so that a future attempt to "finish" them has to argue first.

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
3. ~~**The dropped event handlers** in §3, cascade deletes first.~~ Done. Six of
   them turned out to be asking for something the model could not express; see
   §3 for which, and why implementing a TODO as written is not always progress.
4. ~~**Delete `alert-service/internal/scheduler`** or wire it.~~ Wired, and the
   suggestion to consider deleting it was wrong: it was the only reader of the
   alert rules the product lets farmers configure. See §2.
