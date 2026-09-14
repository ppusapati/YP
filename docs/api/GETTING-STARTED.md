# Getting started

From nothing to a list of farms, in four steps.

Everything enters through the API gateway on port 8080. Individual service
ports (8081–8108) are exposed for debugging and should not be called directly:
the gateway is where authentication, rate limiting and CORS are applied.

```bash
docker compose up -d          # add --profile offline to skip external APIs
```

See [offline-development.md](../offline-development.md) for running with no
network access or API keys.

---

## 1. Get a token

```bash
curl -s http://localhost:8080/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"agronomist@example.com","password":"…"}'
```

```json
{
  "token": {
    "access_token": "eyJhbGciOi…",
    "refresh_token": "…",
    "expires_at": 1773504000
  },
  "user": { "id": "…", "tenant_id": "…", "name": "…", "email": "…", "role": "…" }
}
```

Login is rate limited far more tightly than the rest of the API — 10 requests
per second per IP against 100 — so a client that logs in on every request will
be throttled long before anything else is. Log in once, keep the token, and
refresh it.

## 2. Refresh before it expires

```bash
curl -s http://localhost:8080/auth/refresh \
  -H 'Content-Type: application/json' \
  -d '{"refresh_token":"…"}'
```

Refresh a minute or so ahead of `expires_at`. A token that expires while a
request is in flight fails *after* the server has done the work, and the retry
is indistinguishable from a real authentication failure.

A rejected refresh means the token is spent or revoked; log in again rather
than retrying.

## 3. Call an RPC

Every RPC is `POST /<proto package>.<Service>/<Method>` with a JSON body:

```bash
curl -s http://localhost:8080/agriculture.farm.v1.FarmService/ListFarms \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{"page_size": 20}'
```

| Header | Required | Purpose |
|---|---|---|
| `Authorization: Bearer <jwt>` | yes | Identity and tenant |
| `Content-Type: application/json` | yes | Protobuf is also accepted |
| `X-Tenant-ID` | no | Only when not taken from the token; must match the token's tenant if both are sent |
| `X-Request-ID` | no | Echoed into logs; generated if absent — worth sending, it is what support will ask for |

The tenant normally comes from the token. Sending `X-Tenant-ID` for a different
tenant is refused with `permission_denied`, not silently ignored.

## 4. Handle the answer

An error looks like this:

```json
{ "code": "not_found", "message": "farm not found" }
```

with the machine-readable reason in the `x-error-reason` header and as a
`google.rpc.ErrorInfo` detail.

**Branch on the reason, not the message.** `not_found` tells you something was
missing; `FARM_NOT_FOUND` tells you what. Messages are written for people and
change without notice.

Retry `unavailable`, `deadline_exceeded` and `resource_exhausted`. Do not retry
`invalid_argument`, `not_found`, `permission_denied` or `unimplemented` —
repeating those produces the same answer more slowly. `unimplemented` in
particular means "not built yet", not "temporarily broken"; a number of RPCs
are declared in protos with no handler behind them.

Full detail in [CONVENTIONS.md](CONVENTIONS.md).

---

## Clients

### Go

Generated from the protos and checked in, so a regeneration is reviewable as a
diff. Regenerate with `make proto`.

```go
import (
    "connectrpc.com/connect"
    farmv1 "p9e.in/samavaya/agriculture/farm-service/api/v1"
    "p9e.in/samavaya/agriculture/farm-service/api/v1/farmv1connect"
)

client := farmv1connect.NewFarmServiceClient(http.DefaultClient, "http://localhost:8080")

req := connect.NewRequest(&farmv1.ListFarmsRequest{PageSize: 20})
req.Header().Set("Authorization", "Bearer "+token)

resp, err := client.ListFarms(ctx, req)
if err != nil {
    if connect.CodeOf(err) == connect.CodeNotFound {
        // …
    }
    return err
}
for _, farm := range resp.Msg.GetFarms() {
    fmt.Println(farm.GetName())
}
```

`packages/connect/client` supplies a configured HTTP client and a
context-propagating interceptor; prefer those over `http.DefaultClient` for
service-to-service calls, since they carry the request id and tenant through.

### TypeScript

Generated with protobuf-es. Regenerate with `make proto-web`.

```ts
import { createClient } from "@connectrpc/connect";
import { createConnectTransport } from "@connectrpc/connect-web";
import { FarmService } from "@samavāya/proto/farm-service";

const transport = createConnectTransport({
  baseUrl: import.meta.env.VITE_API_URL ?? "http://localhost:8080",
  interceptors: [
    (next) => async (req) => {
      req.header.set("Authorization", `Bearer ${token}`);
      return next(req);
    },
  ],
});

const client = createClient(FarmService, transport);
const { farms } = await client.listFarms({ pageSize: 20 });
```

### Python

`clients/python/` — hand-written rather than generated, and deliberately so.

ConnectRPC over JSON is an ordinary HTTP API, so generated Python message
classes would add a build step, a freshness gate and a few thousand
checked-in files while buying nothing a dict does not already give a Python
caller. Go and TypeScript generate because their compilers can check the
result; Python's cannot, so the cost is all cost.

What the client does provide is the part that is easy to get wrong: the auth
handshake and refresh, retry on the failures that are actually transient,
pagination that terminates, and errors carrying the platform's `reason`.

```python
from samavaya import ApiError, Client

with Client("http://localhost:8080") as api:
    api.login("agronomist@example.com", "…")

    for farm in api.paginate(
        "agriculture.farm.v1.FarmService", "ListFarms",
        {"page_size": 50}, "farms",
    ):
        print(farm["name"])

    try:
        api.call("agriculture.farm.v1.FarmService", "GetFarm", {"id": "nope"})
    except ApiError as err:
        if err.reason == "FARM_NOT_FOUND":
            ...
```

```bash
pip install -e clients/python
python -m unittest discover -s clients/python/tests
```

### Dart / Flutter

Generated into `mobile/packages/flutter_proto`. Regenerate with
`make proto-mobile` (needs the Dart SDK and `protoc-gen-dart`).

---

## Pagination

Send `page_size`; read `total_count`; follow `next_page_token` if the response
has one, otherwise advance `page_offset`.

Services use both styles — see [CONVENTIONS.md](CONVENTIONS.md#pagination) for
which does what — so a general client should handle either. The Python client's
`paginate()` does, and is worth reading for the termination guards if you are
writing your own: a server that hands back the token it was given will
otherwise page forever.

Do not parse a `next_page_token`. It happens to be an offset today; that is not
a promise.

## Rate limits

100 requests per second per client IP, burst 200, per service instance. Login
is 10/s. Exceeding it gives `429` with `Retry-After` over plain HTTP, or
`resource_exhausted` over Connect.

There are no `X-RateLimit-*` headers, so a client cannot see its remaining
budget, and `Retry-After` is a constant `1` rather than the real wait. Back off
on rejection rather than trying to stay under a limit you cannot observe.

## Browsing the API

```bash
docker compose -f docs/api/docker-compose.docs.yaml up
```

Swagger UI on [localhost:9090](http://localhost:9090), with a dropdown for each
service. The OpenAPI specs are generated from the protos — `make api-docs`.
