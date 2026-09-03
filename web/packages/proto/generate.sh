#!/usr/bin/env bash
# =============================================================================
# Proto Codegen — TypeScript types & ConnectRPC service descriptors
# =============================================================================
# Uses buf to generate TypeScript proto types from the monorepo's .proto files.
#
# Prerequisites:
#   npm install -g @bufbuild/protoc-gen-es@2.2.3
#   buf installed (https://buf.build/docs/installation)
#
# Usage:
#   ./generate.sh          # Generate all proto types
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
FINAL_OUT="$SCRIPT_DIR/src/gen"

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
rm -rf "$FINAL_OUT"
mkdir -p "$FINAL_OUT"

buf generate --template "$SCRIPT_DIR/buf.gen.yaml"

TOTAL=$(find "$FINAL_OUT" -name "*.ts" 2>/dev/null | wc -l)

echo ""
echo "============================================"
echo "DONE"
echo "  Generated: $TOTAL TypeScript files"
echo "  Location:  $FINAL_OUT"
echo "============================================"
