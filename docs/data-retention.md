# Data retention and storage tiering

Two things on this platform grow without bound and nothing used to remove
either: sensor readings and satellite scenes. A field with fifty sensors
reporting every five minutes produces around five million rows a year, and a
single Sentinel-2 tile is a few hundred megabytes arriving every few days per
field.

This is what now happens to each, and why those numbers.

---

## Sensor readings

`sensor_readings` is a TimescaleDB hypertable, partitioned by `recorded_at`.

| Age | What happens |
|---|---|
| 0–30 days | Raw rows, uncompressed. This is the window in which readings are read individually |
| 30–365 days | Compressed in place, roughly a tenth of the size. Still queryable |
| Beyond 365 days | The chunk is dropped. The hourly rollup survives |

**Chunks are a week.** The guidance is that a chunk's indexes should fit
comfortably in memory; a week is a few hundred thousand rows at these volumes,
and makes a year fifty-two chunks rather than three hundred and sixty-five.

**Compression segments by `sensor_id`** because every query filters on it, so
a compressed chunk can be read for one sensor without decompressing the rest.

**Dropping a chunk is a `DROP TABLE`, not a `DELETE`.** It is instant and
leaves no dead tuples for autovacuum to chase. That is the main reason
time-series data belongs in a hypertable rather than in an ordinary table with
a nightly delete job.

### The rollup

`sensor_readings_hourly` is a continuous aggregate: hourly mean, min, max and
sample count per sensor. It is what charts read, through
`GetHourlyReadings`. A season of five-minute readings is a hundred thousand
points per sensor; an hour-bucketed series is around eight thousand, which a
browser can actually draw.

`sample_count` is carried deliberately. An hour with two readings and an hour
with twelve both produce an average, and only the count tells you which to
trust — a gap in reporting is otherwise invisible once the data is rolled up.

**`tenant_id` is in the `GROUP BY`, and the view carries its own RLS.** A
continuous aggregate is a materialised view, and row-level security on the
base table does not follow into it. Without the tenant in the grouping, one
tenant's rollup would silently include another's readings.

### Two behaviour changes worth knowing

- **Rows in a compressed chunk cannot be updated.** The table has a
  `deleted_at` column and an `updated_at` trigger, so soft-deleting a reading
  older than thirty days will fail. Readings are telemetry and amending a
  month-old measurement is not something anyone should be doing — but it is a
  change, not an implementation detail.
- **The primary key is now `(id, recorded_at)`.** A hypertable's partitioning
  column has to appear in every unique constraint, because uniqueness can only
  be enforced within a chunk. Ids are ULIDs generated per row, so the weaker
  guarantee is not reachable in practice, and a separate index keeps lookups by
  id alone fast.

### Running it

`docker-compose.yml` uses `timescale/timescaledb:2.17.2-pg16` — stock
PostgreSQL 16 with the extension available, and a drop-in for the twenty-odd
service databases that do not use hypertables. `timescaledb` must come first in
`shared_preload_libraries` or it refuses to load.

Migration `000006` **fails** if the extension is unavailable rather than
skipping. A deployment that believes it has time-series storage and does not is
worse than one that will not start.

---

## Satellite imagery

Object storage, via `scripts/storage-lifecycle.sh` (`make storage-lifecycle`,
or `DRY_RUN=1` to preview).

| Prefix | Rule | Why |
|---|---|---|
| `satellite/raw/` | Cold tier at 30 days | Past the window in which a scene is actively processed, and past any retry of a failed ingestion |
| `satellite/raw/` | Expire at 1095 days | Three seasons. Two covers year-on-year comparison; three leaves margin for a two-year rotation |
| `satellite/tiles/` | Expire at 180 days | Derived data. Re-renderable from the scene, so paying to keep it is worse than re-rendering on the rare occasion someone asks |
| everything | Abort incomplete uploads at 7 days | An interrupted multipart upload leaves parts that are billed and do not appear in a listing |

The access pattern is what drives this: a scene is read constantly for the
first month while NDVI is computed and the field is being watched, then
essentially never — except for a season-over-season comparison that reaches
back a year or two and tolerates a restore delay.

### Before relying on the cold tier

**MinIO accepts a `COLD` transition rule without a remote tier configured and
then silently never moves anything.** The rule appears in `mc ilm ls`, the
objects stay where they are, and nothing reports a problem. Configure the tier
first:

```bash
mc ilm tier add s3 yp COLD \
  --endpoint https://s3.amazonaws.com \
  --access-key ... --secret-key ... \
  --bucket <archive-bucket> --storage-class GLACIER
```

The expiry rules work regardless; only the transition depends on it.

**Expiry is irreversible and applies to objects already in the bucket.** On a
deployment with existing data, dry-run first and look at what is actually
there:

```bash
make storage-lifecycle DRY_RUN=1
mc ls --recursive --summarize yp/yieldpoint/satellite/raw/
```

---

## Everything else

| Data | Retention | Where it is set |
|---|---|---|
| Logs | 31 days | `monitoring/loki/loki-config.yml` — and note that `retention_period` does nothing unless the compactor is told to apply it |
| Metrics | Prometheus default (15 days) | `docker-compose.yml` |
| Tenant archives | Until deleted by hand | `packages/tenant/offboarding` — an archive is written at offboarding and the grace period is 30 days before purge |
| Alerts | No policy yet | `alert-service` has an `expires_at` and an `ExpireDue` sweep, but nothing deletes closed alerts. Worth adding when the table gets large |
