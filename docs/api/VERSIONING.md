# API versioning and migration

## Where the version lives

In the proto package, and therefore in the URL:

```
POST /agriculture.farm.v1.FarmService/ListFarms
```

Every service is at `v1`. There is no header-based or query-parameter
versioning, and no content negotiation between versions — the path is the
version, which means a client can be pinned to one by configuration alone.

## What can change inside a version

The rule is protobuf's own compatibility model, which is stricter than it first
appears because this platform serves JSON as well as binary.

**Safe:**

- Adding a message field with a new tag number.
- Adding an RPC to a service.
- Adding an enum value — *provided* clients treat unknown values as the
  `_UNSPECIFIED` default rather than failing. Every enum here reserves 0 for
  that purpose.
- Adding a response field. Clients ignore fields they do not know.
- Widening a validation rule, raising a page-size maximum, relaxing a required
  field.

**Breaking, and needs a new version:**

- Removing or renaming a field, an RPC, or an enum value. Renaming is breaking
  even though the tag number is unchanged, because the JSON encoding uses the
  field *name*.
- Changing a field's type, or reusing a tag number — including reusing one from
  a field you deleted. `reserved` the tag and the name instead.
- Changing an RPC's semantics while keeping its signature: making an optional
  field required, narrowing what a value may contain, changing a default,
  changing what an error code means for a given situation.
- Changing a unit. A field that held millimetres and now holds centimetres is
  the worst kind of breaking change, because nothing fails — the numbers are
  just wrong from then on. If a unit must change, rename the field so the old
  one breaks loudly.

Correcting behaviour that never matched the documented contract is not a new
version, but it is still a change a client can trip over — log it under
**Fixed** in the [changelog](CHANGELOG.md) with a migration snippet.

## Introducing v2

Only when a breaking change cannot be avoided. Adding a field is nearly always
cheaper than a version, and a second version is a second implementation to keep
correct for as long as both are live.

1. **New proto package, same repository.** `agriculture.farm.v2` beside
   `agriculture.farm.v1`, in `proto/v2/`. Not a copy of the v1 file with edits
   — start from what v2 should be, then check what v1 clients will need to
   translate.
2. **Both versions served by one process**, over the same application service.
   Two handler packages, two sets of mappers, one implementation. Two
   implementations of the same domain logic diverge; this is the single most
   important part of the plan.
3. **Write the migration guide before writing v2's handler.** If the guide is
   hard to write, the change is worse than it looks. It belongs in this
   directory as `MIGRATION-<service>-v1-to-v2.md`, with a field-by-field mapping
   table and a worked before/after request and response.
4. **Announce, then deprecate.** Mark v1 RPCs `deprecated = true` in the proto
   — that surfaces in generated clients and in the OpenAPI specs — and add a
   `Deprecation` response header giving the sunset date.
5. **Measure who is still on v1** before removing it. Per-version request
   counts are labelled in the Prometheus metrics by procedure, and the
   procedure carries the package name. Do not remove a version on a date; remove
   it when the traffic is gone, or when you have spoken to whoever is still
   sending it.

**Minimum overlap: two release cycles**, and longer where mobile is involved.
The Flutter app ships through app stores, so some fraction of installs stay on
an old build for months regardless of what the server does.

## Deprecating a field inside a version

Fields are cheaper to deprecate than services.

```protobuf
message Farm {
  string name = 1;
  // Deprecated: use `area_hectares`. Removed in v2.
  double area_acres = 7 [deprecated = true];
  double area_hectares = 12;
}
```

Populate both for the whole overlap. Accept both on input, preferring the new
one, and say in the comment which wins if a client sends both. Then `reserved 7;
reserved "area_acres";` when it finally goes — reserving the *name* as well as
the tag, because JSON clients bind by name.

## Client generation

Generated clients are checked in, not built on demand, so a regeneration is
reviewable as a diff:

```bash
make proto          # Go
make proto-web      # TypeScript
make proto-mobile   # Dart
make proto-all
```

CI fails if generated code is stale relative to the protos, which is what stops
a proto change from reaching a service without reaching its clients.

## Checklist for a breaking change

- [ ] Is it really breaking? Check the "safe" list above.
- [ ] Can it be an added field instead? It usually can.
- [ ] Migration guide written, with a field mapping table and a worked example.
- [ ] Both versions served by one implementation.
- [ ] v1 marked `deprecated` with a sunset date, and a `Deprecation` header.
- [ ] Changelog entry marked **Breaking**, with a migration snippet.
- [ ] Clients regenerated and committed.
- [ ] A way to see who is still on v1 before it is removed.
