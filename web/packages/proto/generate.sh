#!/usr/bin/env bash
# =============================================================================
# Proto Codegen — TypeScript types & ConnectRPC service descriptors
# =============================================================================
# Uses buf to generate TypeScript proto types from the monorepo's .proto files.
#
# Prerequisites:
#   pnpm install   (in web/ — the protoc-gen-es version is pinned by the lockfile)
#   buf installed (https://buf.build/docs/installation)
#
# Usage:
#   ./generate.sh          # Generate all proto types
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
FINAL_OUT="$SCRIPT_DIR/src/gen"

# buf resolves the template's `out` and `inputs` against the working directory,
# and both are written relative to the repository root, so this has to run from
# there regardless of where it was invoked from.
cd "$REPO_ROOT"

# Prefer the workspace's own plugin over whatever happens to be on PATH.
# protoc-gen-es writes its version into every file it generates, so a globally
# installed copy at a different version rewrites all 47 of them and the CI
# freshness check reports drift that is only a version bump.
export PATH="$REPO_ROOT/web/node_modules/.bin:$PATH"

echo "============================================"
echo "Proto Codegen for @samavaya/proto"
echo "============================================"
echo "Repo root: $REPO_ROOT"
echo "Output:    $FINAL_OUT"
echo ""

# Ensure required tools exist
for tool in buf protoc-gen-es; do
  if ! command -v "$tool" &>/dev/null; then
    echo "ERROR: $tool is not installed or not in PATH."
    exit 1
  fi
done

# ── Generate using buf ──────────────────────────────────────────────
echo "Generating TypeScript proto types..."
# The template declares `clean: true`, so buf removes the output directory
# itself; this only guarantees it exists on a first run.
mkdir -p "$FINAL_OUT"

buf generate --template web/packages/proto/buf.gen.yaml

TOTAL=$(find "$FINAL_OUT" -name "*.ts" 2>/dev/null | wc -l)

echo ""
echo "============================================"
echo "DONE"
echo "  Generated: $TOTAL TypeScript files"
echo "  Location:  $FINAL_OUT"
echo "============================================"
