# API changelog

Changes to the wire contract — anything a client can observe. Newest first.

Internal refactors, performance work and dependency bumps do not belong here.
If a client cannot tell it happened, it is not an API change.

Entries are marked:

- **Breaking** — existing clients stop working, or start behaving differently.
- **Added** — new capability; existing clients unaffected.
- **Fixed** — behaviour now matches what the API always claimed to do. These
  can still break a client that had adapted to the bug, so they say so.

See [CONVENTIONS.md](CONVENTIONS.md) for how errors, pagination and rate limits
work now, and [VERSIONING.md](VERSIONING.md) for the compatibility rules.

---

## Unreleased

### Fixed — domain errors now carry their real status code

**Affects every service.** Previously every domain error reached clients as
Connect code `unknown` / HTTP 500, with the platform's internal debug
formatting as the message:

```
unknown: error: code = 404 reason = FARM_NOT_FOUND message = farm not found
metadata = map[] cause = <nil>
```

`*errors.Error` implements `GRPCStatus()`, and the conversion helper returned it
unchanged assuming ConnectRPC would read the code from there. It does not:
connect-go looks only for a `*connect.Error` and wraps anything else in
`CodeUnknown`. Errors now arrive as:

| Was | Is |
|---|---|
| `unknown` / 500 for everything | `not_found`, `invalid_argument`, `permission_denied`, `aborted`, … |
| debug string as the message | the handler's message alone |
| reason buried in the message text | `ErrorInfo` detail plus an `x-error-reason` header |

**Migrating.** A client that matched on `unknown`, or on HTTP 500, or that
parsed the reason out of the message, needs updating:

```diff
- if connect.CodeOf(err) == connect.CodeUnknown &&
-     strings.Contains(err.Error(), "FARM_NOT_FOUND") {
+ if connect.CodeOf(err) == connect.CodeNotFound {
```

Prefer the reason over the code where you need to distinguish two failures that
share a code — it is stable, and the message is not.

A retry policy keyed on 5xx will now stop retrying 4xx errors it used to retry
forever. That is the point, but check that nothing depended on the old
behaviour to eventually succeed.

### Fixed — pagination no longer loops forever when `page_size` is omitted

**Affects** farm-service (`ListFarms`), satellite-analytics,
satellite-ingestion, satellite-processing, satellite-tile, vegetation-index.

These handlers computed `next_page_token` as `offset + requested page size`,
while the default was applied to a separate copy inside the application service.
A client that omitted `page_size` left it at zero, so the token was the offset it
had just read — pagination never advanced, while each response still carried a
full page of rows. The token is now derived from the number of rows actually
returned.

A client that sent an explicit `page_size` was never affected. One that worked
around the loop by ignoring the token and incrementing its own offset still
works, and can now stop.

### Added — per-tenant feature flag overrides

Flags can be pinned on or off for a named tenant, ahead of targeting rules and
the rollout percentage. Not an RPC change; noted because it changes which
features a given tenant sees. See `packages/featureflags`.

---

## How to add an entry

Write it when you make the change, in the same commit. A changelog assembled
before a release from commit messages is a list of what was done; one written
as you go is a list of what a client has to care about, which is a different
and shorter list.

Say what a client sees, not what you refactored. "ListFarms now returns
`total_count`" is useful; "refactored the farm repository" is not.

For anything marked **Breaking** or **Fixed**, include a migration snippet.
Someone will read it under time pressure with a broken integration, and a diff
answers faster than prose.
