# Real-time topics

Both real-time transports — the WebSocket hub in `packages/websocket` and the
SSE broker in `packages/sse` — route on a topic string. This is how that string
is scoped, and why.

## The rule

**A topic is qualified by tenant, and the qualification is structural.**

```
t/<tenant-id>/<name>
```

Build one with `realtime.TenantTopic(tenantID, name)`. Never concatenate it by
hand: `SplitTopic` is what the delivery path uses to decide who may receive a
message, and a topic it cannot parse reaches nobody.

## What this replaced

Neither transport had any tenant scoping at all.

The WebSocket hub took whatever topic string a client sent, stored it verbatim,
and delivered every broadcast on that string to everyone subscribed to it. A
`Client` carried a `TenantID` and nothing read it. So an authenticated user in
one tenant who named another tenant's field — `sensor.<field-id>` — received
that field's live sensor readings, irrigation events and alerts.

The SSE broker was the same shape and one step worse. It read its topics from a
`?topics=` query parameter, and an event published with **no topic at all** was
delivered to every subscriber on the process, across every tenant. Forgetting
the topic was a cross-tenant broadcast rather than a no-op.

Identifiers being ULIDs was not what protected this. Ids leak through URLs,
exports and shared reports, and "hard to guess" is not an access control — the
rest of this platform does not rely on it, it uses row-level security, and a
live stream of the same rows should not be the one place that does.

## How it is enforced

Three checks, and the third exists because the first two are the ones somebody
will eventually route around:

1. **At subscribe.** `realtime.ScopeTopic(clientTenant, requested)` resolves
   what a subscriber actually gets. A bare name is qualified with the
   subscriber's own tenant, so a client asking for `sensor.field-1` receives its
   own tenant's stream and has no way to express another's. A name qualified
   with a different tenant is refused. A connection with no tenant is refused
   outright rather than treated as belonging to all of them.
2. **At delivery.** The hub and the broker re-check that each subscriber's
   tenant owns the topic before writing to it. This is what holds if a future
   caller ever inserts a subscriber by another route.
3. **On the publish side.** An unqualified topic reaches nobody, and the
   transport logs an error naming it. A publisher that forgets `TenantTopic`
   gets silence, which is a bug that gets found — rather than the quiet
   cross-tenant delivery it used to get.

The subscriber is acked with the *resolved* topic, not the one it asked for, so
a client that sent a bare name can see what it is actually subscribed to.

A client asking for another tenant's topic is told the topic is unavailable,
not that it belongs to someone else. The second confirms the tenant exists,
which is the one thing the refusal should not reveal.

## Publishing

### From Kafka

`websocket.KafkaBridge` reads the tenant from each message's payload —
`tenant_id` by default, configurable per mapping with `TenantField` — and
builds the qualified topic itself. A message without one is **dropped with an
error**, not broadcast: every event on this platform is written from a
tenant-scoped row, so a missing `tenant_id` means the producer lost it, and
that is worth finding.

A message that does not parse as JSON is dropped too. It used to be broadcast
to the bare prefix topic, which every subscriber in every tenant was on.

### Directly

```go
hub.Broadcast(realtime.TenantTopic(tenantID, "sensor."+fieldID), reading)
broker.PublishData("alert", realtime.TenantTopic(tenantID, "alert."+farmID), alert)
```

## Where the tenant comes from

The authenticated request, never the client.

- WebSocket: the upgrade handler validates the JWT and passes `claims.TenantID`
  into `NewClient`.
- SSE: the handler reads `p9context.UserTenantID(r.Context())`, put there by the
  auth middleware. A request with no tenant gets a 401.

Nothing reads a tenant from a query parameter, a header the client controls, or
the topic string itself.

## Where the transports are served

`/ws` and `/events`, by the `realtime` binary — `cmd/realtime`, mounted by
`registerRealtimeModule` and routed by the api-gateway.

That wiring did not exist before. The hub, the SSE broker, the Kafka bridge and
the routing middleware were all written, and **nothing constructed or mounted
any of them** — no service called `NewHub`, no mux served `/ws`, and the
Caddyfile had no route, so a client that connected reached the catch-all 404.
Both transports were complete as code and unreachable as product.

It ran in the monolith first, which was the wrong home: the monolith also
carried a stale second copy of twenty-two services, and it had no Kubernetes
manifest, so the real-time features ran under compose and nowhere else. The
transport now has its own image, its own Deployment and its own Service, and the
ingress points at the api-gateway that knows how to reach it.

The gateway routes them without the timeouts that suit a unary RPC, and
`/events` disables response buffering: without `flush_interval -1` an SSE event
waits in Caddy's buffer until enough accumulate, which for an alert stream is
indefinitely. The nginx ingress in front of it needs the same two things —
`proxy-read-timeout` well past the 60s default and `proxy-buffering: "off"` —
because either hop alone still holds the event.

### One replica, deliberately

The hub, the presence registry and the inspection sessions are process memory,
and nothing joins two copies of them. A second replica splits every room: half a
field's watchers see an event and half do not, and two people editing one
inspection get two sessions that diverge silently. So the Deployment is one
replica with no autoscaler and a `Recreate` strategy — a rolling update would
briefly run two pods, which is the same split. Clients reconnect, which they
must handle regardless; a tractor leaves signal several times a day.

A Redis or Kafka fan-out behind the hub is what would lift that limit.

## Topics in use

| Topic | Carries | Intended publisher | Publishing today |
| --- | --- | --- | --- |
| `sensor.<field_id>` | Live sensor readings | Kafka bridge | **no** |
| `alert.<farm_id>` | Alert notifications | Kafka bridge | **no** |
| `irrigation.<field_id>` | Irrigation decisions and actuator state | irrigation-service | **no** |
| `fieldmap.<field_id>` | Machine positions, imagery overlays, presence | `PublishPosition`, `PublishOverlay` | **no** |
| `inspection.<inspection_id>` | Presence, edits, snapshots | `ApplyInspectionEdit` | **no** |

All five are qualified with `TenantTopic` before they reach a transport.

### Nothing publishes yet

The fourth column is not a typo. A client can connect to `/ws`, authenticate,
subscribe to a field and be acked — and then receive nothing, for ever, because
no code path in the platform broadcasts on any of these topics.

Two separate gaps produce that:

**The Kafka bridge is written and not connected.**
`packages/websocket/kafka_bridge.go` maps a Kafka topic onto a WebSocket topic
prefix. No binary constructs it — not the monolith before, not `cmd/realtime`
now. Mounting it is not a one-line change, which is why it has not been done
quietly: the bridge reads the tenant from `tenant_id` at the top level of the
message, and the envelope every service publishes
(`packages/events/domain.DomainEvent`) has no such field — it carries
`aggregate_id`, `data` and `metadata`. Every message would be dropped,
correctly, for being unqualified. Connecting the bridge means first putting the
tenant in the envelope, across the twelve services that publish one. Until then
`cmd/realtime` is given no `KAFKA_BROKER`, so the deployment does not advertise
a connection it never opens.

**The field-map and inspection publishers have no caller.**
`PublishPosition`, `PublishOverlay`, `JoinInspection` and `ApplyInspectionEdit`
are written, tested and exported on the realtime module, and nothing invokes
them: there is no RPC, no HTTP route and no inbound WebSocket message type that
reaches them. The client's own socket is the natural source for both — a tractor
reports its position and an editor sends an edit — but `handleMessage` in
`packages/websocket/client.go` accepts only `subscribe`, `unsubscribe` and
`pong`. A publish message type, authorised against the connection's tenant, is
what closes this.

The browser end is in the same state: `web/packages/stores` has a WebSocket
store that no page mounts, and it sends `{"type":"subscribe","channel":…}` where
the server reads `topic`.

## Field map

One topic per field carries three kinds of event, tagged in an envelope so a
client does not have to guess from the payload's shape: `machine_moved`,
`overlay_ready` and `presence`.

A position is refused rather than broadcast when it cannot be drawn honestly:

* **Null Island.** Exactly `(0, 0)` is what a telematics unit reports before it
  has a fix. Drawing it puts every unfixed machine in the Gulf of Guinea, which
  reads as a bug in the map rather than in the device.
* **Older than fifteen minutes.** A live map showing where a tractor was two
  hours ago is not a live map; it is a map that is wrong in a way nobody can
  see. Older positions belong in the track history.
* **No tenant.** The topic would be unqualified, which both transports refuse
  anyway — caught at the publisher so the reason is named.

The fix accuracy travels with the position rather than being dropped, because a
40 m fix drawn as a precise dot on a field boundary is a lie the map tells
convincingly.

An overlay carries a tile URL template and bounds, not imagery: a drone
orthomosaic is hundreds of megabytes and has no business on a WebSocket. The
event exists so a map that is already open picks up a new layer without polling.

Presence expires after 90 seconds without a heartbeat. A phone that drives out
of signal never sends a leave, so a registry that removed members only on an
explicit departure would show a tractor sitting in a field for the rest of the
season.

## Collaborative inspection

Two agronomists open the same draft — one in the field, one at a desk with the
satellite history — and both type. The question is what happens when they type
into the same box:

* **Last write wins, silently.** One agronomist's findings vanish while they are
  looking at them, and they do not notice until the report is filed.
* **Whole-document locking.** One edits, the other watches. That is a queue.
* **A CRDT.** Correct, and the wrong tool. An inspection is a form — a health
  score, a findings paragraph, a list of issues — not shared prose, and the cost
  of getting a CRDT subtly wrong is silent corruption of an agronomic record.

What this does: **per-field last-write-wins with an explicit version, and a
loser who is told.** An edit names the version it was based on; if that is
current it applies, and if not it is refused and the editor is handed the value
that beat them. Two people editing different fields never conflict, which is the
common case.

The same rule is enforced in the database, because the in-memory session does
not survive a restart and the row does: `UPDATE ... WHERE ($9 = 0 OR version =
$9)`, checked inside the statement rather than as a read-then-write, which two
simultaneous saves would both pass.

`base_version` of 0 means "I did not check" and is accepted — a single
agronomist correcting a typo should not have to participate in the versioning.

### The RPC this needed

There was no way to edit an inspection at all. `InspectionService` had
`CreateInspection` and `SubmitInspection` and nothing between them, so a draft
was written once and after that only its status could change. Brokering edits
that could never be saved would have made the feature a demonstration.
`UpdateInspection` and a `version` column are the other half of it.

Only a draft can be edited. A submitted inspection is a record of what an
agronomist found on a date; editing it afterwards rewrites the history a
prescription or an insurance claim was built on, so a wrong one is corrected by
filing another — the same rule the traceability records follow.
