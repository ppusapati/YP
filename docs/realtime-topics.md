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
