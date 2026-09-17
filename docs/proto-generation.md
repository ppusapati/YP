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
`scripts/check-proto-drift.sh`, which uses `git status --porcelain` and so
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

Three pages were written to say so rather than call methods that were not
there: the certification detail page disables Revoke, the traceability record
page refuses to save, and both explain why in the UI. **Those guards are now
unnecessary and have not been removed** — re-enabling a write path is a product
change and wants testing against a running service, not a side effect of a CI
fix.

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
