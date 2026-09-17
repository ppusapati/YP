# Generated protobuf code

Four languages are generated from the same `.proto` files, and three of them
are checked by CI:

| Target | Output | CI job |
| --- | --- | --- |
| Go | `<service>/api/v1/` | `proto-check` |
| Dart (Flutter) | `mobile/packages/flutter_proto/lib/src/generated/` | `proto-check-dart` |
| TypeScript (web) | `web/packages/proto/src/gen/` | `proto-check-ts` |
| Rust | hand-written, not generated | — |

Each job regenerates and fails on drift, so a proto change that is not
regenerated and committed turns the build red. That is the intent, and all
three now hold it. For a long time two of them did not, in two separate ways
that are worth keeping written down because both are easy to reintroduce.

**The template paths were relative to the wrong thing.** buf resolves a
template's `out` and `inputs` against the *working directory*, not against the
template file. Both the Dart and TypeScript templates were written as if the
opposite were true. Run the way CI runs them — from the repository root — the
Dart template created a stray `lib/src/generated/` at the root and left the
real tree untouched, and the TypeScript template's `../../..` climbed out of
the checkout entirely. Each job then diffed a directory nothing had written to
and passed. Every path in both templates is now written relative to the
repository root, and every caller runs from there.

**`git diff --exit-code` cannot see a new file.** It compares the index against
the working tree, and an untracked file is in neither. That is not a corner
case for this check: a new service's bindings are *all* new files, so the
check passed while six services had no Dart client at all. The jobs now call
`scripts/check-generated-drift.sh`, which uses `git status --porcelain` and so
reports additions, modifications and deletions alike.

## Dart

Regenerating needs `protoc_plugin` **25.0.0** specifically:

```bash
dart pub global activate protoc_plugin 25.0.0
make proto-mobile      # buf generate --template mobile/packages/flutter_proto/buf.gen.yaml
```

From the repository root. `make proto-mobile` used to `cd` into the package
first, which made buf resolve the template's `out` against that directory and
write the whole tree to the wrong place.

Version matters more than it looks. 24.x resolves the well-known types to
locally generated files instead of `package:protobuf`, and 25.1.0 changes how
message factories construct. Under 25.0.0 the unchanged files regenerate
byte-identically, which is how you can tell a diff is real content rather than
a reformat. The runtime dependency is `protobuf: ^6.0.0`, which is what 25.0.0
targets.

The generated Dart was stale for a long time: eighteen files — the whole of
weather, commerce and ai-gateway, plus the json and server halves of advisory,
inspection and task — had never been committed, so the mobile app had no client
for those services at all, and `Explanation` existed in the proto and not in
the app.

## TypeScript

```bash
pnpm install          # in web/ — this is what pins the plugin version
make proto-web        # runs web/packages/proto/generate.sh from the repo root
```

The plugin comes from the workspace, not from a global `npm install -g`.
protoc-gen-es stamps its own version into the first line of every file it
generates, so generating with a different version rewrites all 47 files and the
freshness check reports drift that is nothing but a version bump. Four versions
were in play before this was settled: the committed tree said 2.14.0, the
lockfile pinned 2.11.0, CI installed 2.2.3, and `package.json` asked for
`^2.0.0`. The lockfile is the only one the repository actually builds against,
so both CI and `generate.sh` now put `web/node_modules/.bin` on PATH ahead of
anything else.

### The layout is flat, and why

Output paths follow each proto file's path *within its buf module*. The root
`buf.yaml` is a v2 workspace listing one module per service, so
`traceability-service/proto/traceability.proto` is `traceability.proto` inside
its module and generates `src/gen/traceability_pb.ts`. The committed tree used
to be nested (`src/gen/traceability-service/proto/traceability_pb.ts`), which
is what a single module rooted at the repository root produces — the shape this
repository had before the workspace was introduced, and never regenerated
since.

Going back to nested was considered and rejected. A module rooted at the
repository root also picks up `.claude/worktrees/` — leftover copies of the
whole repo — and `proto/agriculture/`, which duplicates three service protos;
both produce `symbol already defined` errors. It can be made to build with a
list of exclusions, but every exclusion is a place for the next service to be
silently dropped, which is the same class of failure as the one being fixed.

Flattening required one change outside the generated tree:
`web/packages/proto/src/index.ts` is the only file in the repository that
imports from `src/gen`, and its 64 import paths were rewritten mechanically.

### The shared protos

`packages/proto` — the `TenantContext`, `BaseResponse`, `Money` and
`Pagination` types the barrel re-exports — lives in its own buf workspace
(`packages/buf.yaml`), whose single module is rooted at `packages/proto`. Two
files in it imported each other by repository-root path
(`import "packages/proto/query.proto"`), which under that module root resolves
to `packages/proto/packages/proto/query.proto`. So `packages/buf.yaml` did not
build at all: `buf build` in `packages/` failed on a missing import. Those two
imports are now module-relative and it builds.

It is deliberately **not** added to the root `buf.yaml`. Its `go_package`
options put it under `p9e.in/samavaya/packages`, a different Go module from the
services, so generating it from the root template would emit Go into the wrong
place. Instead the web template takes two inputs — the repository root and
`packages` — which is the honest statement of what the barrel needs.

### What the stale client was costing

Regenerating brought back eight RPCs the platform serves and the web client did
not have: `UpdateFarm`, `DeleteFarm`, `UpdateSensor`, `UpdateSchedule`,
`DeleteSchedule`, `UpdateRecord`, `RevokeCertification` and
`CreateQualityCheckpoint`. Editing a farm — the most ordinary operation in the
product — had no client method behind it for this reason alone.

Two pages had been written to say so rather than call methods that were not
there — the certification detail page disabled Revoke, and the traceability
record page refused to save. Both are wired up now.

Re-enabling them was not only deleting a guard, because two of the three call
sites were wrong in ways the missing methods had been hiding:

- The traceability edit page rendered the **create** schema. `UpdateRecord`
  accepts origin, seed source and four dates; batch id, product name, farm,
  field and crop are immutable by design, since a record is the chain of
  custody for one batch and repointing it rewrites provenance. Wiring the
  create form straight to the RPC would have let someone edit a batch id, press
  Save, get a success, and find nothing changed. There is now a separate
  `traceabilityRecordUpdateSchema` matching what the RPC takes.

- The farm edit page was broken in **both** directions and neither failed
  loudly. It loaded with `values = { ...res.farm }`, copying the client's
  camelCase fields into a form whose inputs carry the proto's snake_case names,
  so most of the form rendered blank on a fully-populated farm. It saved with
  `updateFarm({ id, ...formValues } as any)`, handing protobuf-es keys it does
  not recognise — it drops them, the request succeeds, and nothing changes. The
  `as any` is what kept the typechecker quiet.

### Form values are not protobuf values

Three mismatches sit between a form and a message, and every one of them fails
silently: field names (`total_area_hectares` vs `totalAreaHectares`), enums (a
select holds `'FARM_TYPE_CROP'`, the message holds a number) and timestamps (a
date input holds `yyyy-mm-dd`). `@samavāya/agriculture/convert` does all three
through the generated descriptors, so a value added to a proto cannot fall out
of step with the page that renders it.

No page spreads form values into a request any more. Working through the rest
of them turned up four that were not naming problems at all, which is why a
blanket camelCase rewrite would have been the wrong fix:

- **Sensors** rendered the *registration* form. `UpdateSensorRequest` accepts
  firmware version, location, status, protocol, reading interval and metadata;
  field, type, manufacturer, model and installation date are fixed at
  registration, because changing them describes a different physical device
  while keeping the readings the old one recorded. Eight of the form's fields
  had nowhere to go. There is now an `updateSensorSchema`.

- **Irrigation schedules** take a whole nested `IrrigationSchedule`, not flat
  fields, so `{ id, ...formValues }` did not merely use the wrong names — it
  had no `schedule` at all and the service received an empty request. The page
  now loads the schedule and lays the edited fields over it, because replacing
  it with a message built only from the form would blank the farm, the
  controller, the name, the description and the status: a replace with an unset
  field is a replace with the zero value, not a skip.

  Its frequency select also offered `FREQUENCY_BI_WEEKLY` and
  `FREQUENCY_MONTHLY`, which the enum has never had, and omitted
  `FREQUENCY_EVERY_OTHER_DAY`, which it does.

- **Farm owners → new** called `TransferOwnership` with a name, email, phone and
  percentage. That RPC needs the user the farm moves *from* and the user it
  moves *to*, neither of which the form asked for, and it has nowhere to put
  "is primary". Every submission was rejected for a missing `from_user_id`.
  farm-service has no AddOwner RPC — transfer is the whole surface — so the
  page now says that and links to `/ownership-transfer`, which already exists.
  (That page had the same `as any` bug and is fixed too.)

- **Processing jobs** "saved" by calling `SubmitProcessingJob` with an `id`.
  That request has no id field, so protobuf dropped it: pressing Save created a
  *second* job with the same settings and left the first untouched.
  satellite-processing-service has no update operation — Submit, Get, List,
  Cancel and Stats are all of it — and a job is a unit of work that has already
  run, so editing one in place cannot mean anything. The button now says "Run
  as a new job" and the subtitle says the original is left alone.

## Go

```bash
buf generate
```

from the repo root. This one works and `proto-check` passes.

## Adding a service

A new service's `proto/` directory has to be added to the root `buf.yaml`
`modules` list, or nothing generates for it in any language — and because each
freshness job only checks for drift in what already exists, the omission does
not fail CI. It shows up later as a service with no client.
