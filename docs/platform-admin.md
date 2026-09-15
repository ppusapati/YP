# Platform administration

The cross-tenant operations view: which tenants exist, which are healthy, and
what they consume. It lives at `/platform` in the shell app and is served by
`packages/tenant/admin`.

This is the one deliberate hole in the isolation model. Everything else on this
platform is scoped to a single tenant and enforced by row-level security; this
reads across that boundary on purpose, which makes it the one place where
getting authorization wrong exposes every tenant at once rather than one.

## The three rules

Enforced in `packages/tenant/admin`, not left to callers:

1. **Platform role only.** The check is `role == "platform"` specifically, not
   `RoleAtLeast(RoleAdmin)`. A tenant admin is the highest authority inside
   their tenant and has no business seeing another's.
2. **Aggregates only.** Counts, health, usage, timestamps. Never a tenant's own
   records — no farm names, no field boundaries, no readings. That line is what
   keeps this a monitoring tool rather than a backdoor.
3. **Every access is audited.** The audit write happens *before* the data is
   returned, and a failure to audit fails the request. Refused attempts are
   audited too: someone trying to reach this is more interesting than someone
   succeeding.

## The `platform` role

`RolePlatform` sits above `RoleAdmin` in `packages/connect/interceptors`:

| Role | Rank |
| --- | --- |
| `viewer` | 0 |
| `worker` | 1 |
| `manager` | 2 |
| `admin` | 3 |
| `platform` | 4 |

Because the hierarchy is ordered, `platform` now satisfies every existing
`RoleAtLeast(role, RoleAdmin)` check. That is intended — a platform operator can
do anything a tenant admin can — but it means the role should be issued to
service operators only, and never as a tenant's own admin role.

## HTTP surface

Plain HTTP JSON rather than a Connect RPC, which is what every other surface
here uses. The reason is narrow and worth knowing before anyone "fixes" it:
adding a proto means regenerating the Dart client, and CI gates on generated
Dart being fresh. Two read-only endpoints feeding one internal page did not
justify a schema change. If the platform view grows writes, move it to a proto
and pay that cost properly.

| Route | Returns |
| --- | --- |
| `GET /admin/tenants` | Every tenant, ordered so the ones needing attention come first |
| `GET /admin/stats` | The roll-up across all of them |

Both require `Authorization: Bearer <jwt>` and both are `Cache-Control:
no-store`. A `POST` to either is a 405, not a read.

`NewHandler` refuses to build without an authenticator. There is no development
mode and no "auth disabled" flag, because a convenience switch on the endpoint
that reads every tenant is a switch somebody leaves on.

## Health states

Derived from the counts, not stored:

| State | Meaning |
| --- | --- |
| `ok` | Active, has farms and users, written to within the last fortnight |
| `quiet` | Provisioned and set up, but nothing written for over 14 days |
| `degraded` | Provisioned but never set up, no recorded activity at all, or sensors registered against no fields |
| `suspended` | Deliberately deactivated, usually mid-offboarding |
| `unknown` | Usage has never been gathered for this tenant |

`quiet` is separate from `degraded` because agriculture is seasonal: a farm
between planting and harvest can legitimately go a week without anyone touching
the system, and a dashboard that turns amber every August stops being read. The
threshold is a fortnight for the same reason.

`unknown` is its own state rather than folded into either. Claiming health for a
tenant nothing has measured is a guess; claiming a fault would page somebody for
a missing measurement.

## Gathering usage — and the RLS trap

Counting farms, fields, sensors and users per tenant looks like one query with
three joins. It is neither.

**Each service owns its own database.** `farm_service`, `field_service`,
`sensor_service` and `auth_service` are separate databases. There is no join
across them, so usage is four queries stitched together in Go by tenant id.
That is why `UsageStore` is a port supplying periodically-gathered snapshots
rather than something computed in the request, and why the snapshot's age is
shown on the dashboard — a stale number presented as current is how an operator
concludes nothing is wrong.

**Every one of those tables has `FORCE ROW LEVEL SECURITY`** with a policy keyed
on `current_setting('app.tenant_id')`. With that setting unset the comparison is
`NULL`, the policy matches nothing, and `SELECT COUNT(*) FROM farms` returns
`0` — successfully, with no error anywhere. A gatherer connecting as an ordinary
application role would therefore report that every tenant on the platform is
empty, confidently.

`SQLUsage` refuses to run before checking that its connection actually bypasses
RLS:

```sql
SELECT current_setting('is_superuser') = 'on'
    OR COALESCE((SELECT rolbypassrls FROM pg_roles
                 WHERE rolname = current_user), false)
```

So the gatherer needs its own role:

```sql
CREATE ROLE usage_gatherer LOGIN PASSWORD '…' BYPASSRLS;
GRANT CONNECT ON DATABASE farm_service  TO usage_gatherer;
GRANT SELECT  ON farms                  TO usage_gatherer;
-- and the same for field_service.fields, sensor_service.sensors,
-- auth_service.users
```

`SELECT` on the four tables and nothing else. `BYPASSRLS` is a large privilege
and this role should reach exactly the columns it counts.

### All or nothing

If any source fails, `Usage` returns nothing rather than a partial snapshot.
This is the opposite of what feels helpful, and it is deliberate: farms counted
with fields missing does not read as "incomplete" downstream, it reads as a
tenant with forty sensors and no fields, which `DeriveHealth` correctly calls
degraded. A missing measurement shows as `unknown` and prompts somebody to look;
a partial one invents a fault and wastes their time.

## Wiring it up

```go
registry, err := admin.RegistryFromMemoryStore(tenantStore)

usage, err := admin.NewSQLUsage(
    admin.UsageSource{Metric: admin.MetricFarms,   DB: farmPool,   Query: admin.QueryFarms},
    admin.UsageSource{Metric: admin.MetricFields,  DB: fieldPool,  Query: admin.QueryFields},
    admin.UsageSource{Metric: admin.MetricSensors, DB: sensorPool, Query: admin.QuerySensors},
    admin.UsageSource{Metric: admin.MetricUsers,   DB: authPool,   Query: admin.QueryUsers},
)

svc, err := admin.New(registry, usage, auditLogger)

auth, err := admin.NewBearerAuthenticator(jwtValidator)
handler, err := admin.NewHandler(svc, auth)
handler.Mount(mux)
```

`usage` may be nil: a platform that has not set up gathering still gets the
tenant list and each tenant's active state, with every tenant showing as
`unknown` rather than as zero.

The tenant list itself comes from `saas.TenantStore`, whose only implementation
today is `MemoryTenantStore`, loaded from configuration at startup. There is no
`tenants` table in this repository, so `TenantRegistry` is a port; when a real
registry arrives it implements that interface and nothing else changes.

## Web

`web/apps/shell/src/routes/(app)/platform/` holds the page. It checks the
platform role server-side *as well as* the backend doing so. The backend check
is the one that protects the data; the page's exists so a tenant admin who
navigates here gets a 403 page rather than an empty dashboard with a failed
fetch behind it. A UI-only check would be security theatre; a UI check in
addition to the server's is just a better error message.

`ADMIN_API_URL` points the page at the service hosting the handler. A failed
fetch is surfaced as an error, never swallowed into an empty list — an
operations page showing no tenants because the call failed looks identical to
one showing a platform with no tenants, and the second is the reassuring
reading.
