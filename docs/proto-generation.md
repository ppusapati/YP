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
regenerated and committed turns the build red. That is the intent. Two of the
three have not been holding.

## Dart

Regenerating needs `protoc_plugin` **25.0.0** specifically:

```bash
dart pub global activate protoc_plugin 25.0.0
cd mobile/packages/flutter_proto
buf generate --template buf.gen.yaml <repo-root>
```

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

## TypeScript — currently broken

`web/packages/proto/buf.gen.yaml` declares:

```yaml
out: src/gen
inputs:
  - directory: ../../..
```

Neither half works any more:

- Run from `web/packages/proto`, buf finds the repo-root `buf.yaml`, treats the
  directory input as that **v2 workspace**, and emits paths relative to each
  module root — flat `traceability_pb.ts`. The committed tree is nested
  (`traceability-service/proto/traceability_pb.ts`), which is what a
  non-workspace directory input produces. The workspace was introduced after
  this code was generated.
- Run from the repo root the way CI does (`buf generate --template
  web/packages/proto/buf.gen.yaml`), `../../..` resolves above the repository
  and buf fails on `/proc`.
- `packages/proto` — the shared `context`, `response`, `geo` and `blob` types
  the barrel re-exports — is not in the root `buf.yaml` module list at all, and
  its files import each other as `packages/proto/query.proto`, so it can only
  be generated with the repo root as the module root.

So `proto-check-ts` cannot pass as configured, and the committed TypeScript is
behind the protos. traceability alone is seven RPCs short: the service declares
twenty-one and the client has fourteen, missing `RevokeCertification`,
`UpdateRecord`, `CreateQualityCheckpoint` among them.

**This needs a decision before it can be fixed**, because the two options are
not equivalent:

1. **Move to the flat layout.** Regenerate with the repo root as the module
   root, add `packages/proto` to the workspace, and rewrite the sixty-odd
   import paths in `web/packages/proto/src/index.ts`. Nothing outside that
   barrel imports from `src/gen`, so the blast radius is one file plus the
   generated tree. This is the smaller change and matches how buf v2 wants to
   work.
2. **Keep the nested layout.** Take the repo root out of the workspace for this
   template, or give the web package its own `buf.work.yaml`, so the directory
   input produces repo-root-relative paths again.

Until then, three pages say so rather than calling methods that are not there:
the certification detail page disables Revoke, the traceability record page
refuses to save, and both explain why in the UI. That is deliberate — a button
that calls a missing method fails at runtime with something unhelpful, and a
button that quietly does nothing is worse.

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
