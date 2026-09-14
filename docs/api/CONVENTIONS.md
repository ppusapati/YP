# API conventions: rate limits, pagination, and errors

What a client actually receives, verified against the code rather than against
intent. Where services disagree with each other, this says so — an inconsistency
you know about is workable, one you discover in production is not.

For the per-service RPC catalogue see [README.md](README.md) and the OpenAPI
specs beside it.

---

## Rate limits

Two limiters, both token buckets, both per client IP.

| Scope | Sustained | Burst | Where |
|---|---|---|---|
| Every service, all HTTP traffic | 100 req/s | 200 | `packages/connect/server` `WrapAll` |
| auth-service login endpoints | 10 req/s | 20 | `auth-service/cmd/server/main.go` |

The client IP comes from the first entry in `X-Forwarded-For`, falling back to
the socket's remote address. Configure per service through `ServerConfig`:
`RateLimitEnabled`, `RateLimitPerSecond`, `RateLimitBurst`.

**When you exceed it:**

| Transport | Response |
|---|---|
| Plain HTTP | `429 Too Many Requests`, `Retry-After: 1`, body `{"error":"rate_limit_exceeded","message":"too many requests"}` |
| ConnectRPC | code `resource_exhausted` |

Rejections are counted in the `http_rate_limit_rejected_total` Prometheus
counter.

### Two things to know before you tune this

**The limit is per instance, not per fleet.** Each replica keeps its own bucket
in memory, so N replicas behind a load balancer admit roughly N × 100 req/s in
total, and a client's effective limit depends on which pod it lands on. A
PostgreSQL-backed shared limiter exists at `packages/ratelimit/backend` but is
not wired in. Treat the configured number as a per-instance safety valve, not a
quota.

**There are no `X-RateLimit-*` headers.** A client cannot see how much budget
it has left, or when the window resets, and `Retry-After` is the constant `1`
rather than the real wait. Back off on 429 rather than trying to stay under a
limit you cannot observe.

Tenant-level quotas are separate and also surface as `resource_exhausted`; see
`packages/tenant/quotas`.

---

## Pagination

### The short version

Send `page_size`. Read `total_count`. If the response carries a
`next_page_token`, send it back as `page_token`; otherwise use `page_offset`.
Stop when the token is empty or you have read `total_count` rows.

### The long version

There is no shared pagination type in use. `packages/proto/pagination.proto`
defines one, and compiles to `packages/api/v1/pagination`, but **no service
proto imports it** — every service re-declares its own fields. Three
conventions resulted.

**Offset-based** (`page_size` + `page_offset`, response carries `total_count`):
commerce, crop, field, irrigation, plant-diagnosis, satellite, sensor, soil,
weather, and farm's `ListManagementUnits`.

**Token-based** (`page_size` + `page_token`, response carries `next_page_token`
and usually `total_count`): agronomy, alert, pest-prediction, prescription,
task, traceability, vegetation-index, the four satellite-\* services, yield, and
farm's `ListFarms`.

**Unpaginated:** analytics-service `ListFieldAnalytics`, and alert-service's
`ListAlertRules` and `ListFieldRisks`. These return everything.

farm-service uses both conventions in one service. There is no reason for that
beyond history.

#### The tokens are not cursors

Every `next_page_token` in this platform is an offset wearing a disguise — most
services emit the decimal offset as a string, pest-prediction and yield
base64-encode it. Nothing implements a real cursor, so the usual cursor
guarantee does not hold: **rows inserted or deleted between pages will shift
the window**, and you can see a row twice or miss one entirely. If that matters,
sort by a stable key and filter client-side.

Do not parse the token. Send back what you were given.

#### Defaults and limits

Four different sets of numbers are in play:

| Default / max | Services |
|---|---|
| 20 / 100 | commerce, crop (`ListCrops`), farm, field, irrigation, pest-prediction, plant-diagnosis, satellite, satellite-analytics, satellite-ingestion, satellite-processing, satellite-tile, sensor, soil, traceability, vegetation-index, yield |
| 50 / 200 | agronomy, alert, task, crop (`ListVarieties`) |
| 50 / 500 | weather, plant-diagnosis `ListLabelReviewQueue` |
| none | prescription (`ListPrescriptions` is a stub that returns nothing) |

Requests over a service's maximum are **clamped silently** — ask for 200 from
field-service and you get 100, with nothing in the response saying so. But a
`page_size` above **500** is rejected outright by a shared validation
interceptor with `invalid_argument`, regardless of the service's own, lower
limit. So `page_size=200` is quietly reduced and `page_size=600` is an error.

commerce-service and traceability-service go further: their repositories
*reset* an over-maximum request to the default of 20 rather than clamping it to
100. Asking for more than the maximum gets you fewer rows than asking for
nothing.

Send a `page_size` you actually want, within the service's documented maximum.

#### Response fields you should not rely on

- **`has_next`** is declared in exactly one proto — soil-service's — and is
  never populated, so it always reads `false`. Compare `page_offset + len(rows)`
  against `total_count` instead.
- **`total_count`** is absent from prescription-service's list response, which
  is the only token-based service without one.
- **prescription-service's `ListPrescriptions` is not implemented.** It returns
  an empty list and an empty token.

#### Fixed here

Seven services computed the next token as `offset + requested_page_size` in the
handler, while the clamp happened on a by-value copy inside the application
service. A client that omitted `page_size` left it at zero, so the token was the
offset it had just read and pagination looped forever, each response carrying a
full page of rows. Those handlers now advance by the number of rows actually
returned.

---

## Errors

Every RPC error carries a Connect code, a human-readable message, and a
machine-readable `reason`.

### Codes

| Connect code | HTTP | Means |
|---|---|---|
| `invalid_argument` | 400 | The request is malformed or a required field is missing |
| `unauthenticated` | 401 | No token, a malformed header, or an expired or revoked session |
| `permission_denied` | 403 | Authenticated, but not permitted — including a tenant mismatch between the request and the token |
| `not_found` | 404 | No such entity, or none visible to this tenant |
| `aborted` | 409 | Conflict — the name is taken, the state has moved on |
| `resource_exhausted` | 429 | Rate limit or tenant quota |
| `internal` | 500 | A server fault, including a recovered panic |
| `unimplemented` | 501 | Declared in the proto, no handler behind it |
| `unavailable` | 503 | A dependency is down; retry |
| `deadline_exceeded` | 504 | The call outran its timeout |

`unimplemented` is worth taking seriously: a large number of RPCs are declared
in protos with no implementation behind them, and they return this rather than
failing to route. Treat it as "not built yet", not "temporarily broken", and do
not retry it.

### Reading the reason

The code says what kind of thing went wrong; the reason says which thing.
`not_found` tells you something was missing, `FARM_NOT_FOUND` tells you what.

The reason arrives two ways, whichever your client can read:

- as a `google.rpc.ErrorInfo` detail, with any extra context in its `metadata`
  map (`field_id`, and so on);
- as an `x-error-reason` response header.

Branch on the reason, never on the message text — messages are written for
people and change without notice.

Reasons are conventional, not enumerated: they are inline string literals with
no central registry, and there are over 500 distinct ones. The shapes are
`MISSING_*` and `INVALID_*` for 400, `<ENTITY>_NOT_FOUND` for 404, and
`DB_ERROR` or `<OPERATION>_FAILED` for 500. Match on the ones you care about
and treat the rest as the code alone. A handful are filed under the wrong code
— irrigation-service returns `ZONE_NOT_FOUND` as a 400 — so prefer the reason
when the two disagree.

### Validation

Two paths, and they look different:

- **Shared interceptor**, before the handler: any string field over 10,000
  runes, or `page_size` over 500. Returns `invalid_argument` with a plain
  message and *no* reason.
- **Handler**: everything else. Returns `invalid_argument` with a reason such
  as `MISSING_FIELD_ID` or `INVALID_LATITUDE`.

### Panics

A recovered panic returns `internal` with the literal message
`"internal server error"` — no stack, no reason. The stack and the request ID
go to the server log; quote the request ID when reporting one.

### Fixed here

Until recently, none of the above was true of domain errors. `*errors.Error`
implements `GRPCStatus()`, and the conversion helper returned it unchanged on
the assumption that ConnectRPC would read the code from there. It does not —
connect-go looks only for a `*connect.Error` and wraps anything else in
`CodeUnknown`. Every domain error from every handler reached clients as
`unknown` / HTTP 500, with the internal debug formatting as the message:

```
unknown: error: code = 404 reason = FARM_NOT_FOUND message = farm not found
metadata = map[] cause = <nil>
```

An interceptor now converts on the way out, so codes, messages, reasons and
metadata arrive as described above. If you built a client against the old
behaviour — matching on `unknown`, or parsing the reason out of the message —
it needs updating. See [CHANGELOG.md](CHANGELOG.md).

---

## Requests

Every RPC is `POST /<proto package>.<Service>/<Method>` with a JSON body.

| Header | Required | Purpose |
|---|---|---|
| `Authorization: Bearer <jwt>` | yes, except on public procedures | Identity and tenant |
| `X-Tenant-ID` | no | Tenant when not taken from the token; must match the token's tenant if both are present |
| `Content-Type: application/json` | yes | Also accepts protobuf |
| `X-Request-ID` | no | Echoed into logs; generated if absent |

Request bodies are capped at 10 MB.

## Timeouts

Read header 30s, read 60s, write 60s, idle 120s. Requests slower than 5s are
logged as slow. Long-running work — satellite processing, model training — is
submitted as a job and polled, not held open.
