#!/usr/bin/env bash
#
# Run the frozen benchmark gate for every task that has a suite and a model.
#
# A model may only be promoted if it clears the absolute thresholds in its
# benchmark suite and has not regressed against the baseline recorded there.
# This script is the single place that decision is made, so CI and a developer
# on a laptop get the same answer.
#
# Usage:
#   scripts/model-gate.sh [MODELS_DIR] [BENCHMARKS_DIR]
#
# MODELS_DIR holds one directory per task (the run directory produced by
# `yp-ml-training train`), each containing best_model.mpk and labels.json.
# Tasks with a suite but no model are skipped, not failed: not every pipeline
# rebuilds every model.
#
# Exit codes: 0 all gates passed (or nothing to check), 1 at least one failed.

set -uo pipefail

MODELS_DIR="${1:-${MODELS_DIR:-models}}"
BENCHMARKS_DIR="${2:-${BENCHMARKS_DIR:-benchmarks}}"
CONFIG="${CONFIG:-configs/training_config.toml}"
CLI="${CLI:-cargo run --quiet --release --}"

if [ ! -d "$BENCHMARKS_DIR" ]; then
  echo "No benchmark directory at $BENCHMARKS_DIR; nothing to gate."
  exit 0
fi

shopt -s nullglob
suites=("$BENCHMARKS_DIR"/*.json)
if [ ${#suites[@]} -eq 0 ]; then
  echo "No benchmark suites in $BENCHMARKS_DIR; nothing to gate."
  exit 0
fi

failed=()
passed=()
skipped=()

for suite in "${suites[@]}"; do
  task="$(basename "$suite" .json)"
  model_dir="$MODELS_DIR/$task"

  if [ ! -f "$model_dir/best_model.mpk" ]; then
    echo "--- $task: no model at $model_dir, skipping"
    skipped+=("$task")
    continue
  fi

  echo "=== $task: gating $model_dir against $suite"
  if $CLI --config "$CONFIG" benchmark run \
      --task "$task" \
      --model-dir "$model_dir" \
      --suite "$suite"; then
    passed+=("$task")
  else
    failed+=("$task")
  fi
done

echo
echo "================================================================"
echo "passed:  ${passed[*]:-none}"
echo "skipped: ${skipped[*]:-none}"
echo "failed:  ${failed[*]:-none}"
echo "================================================================"

if [ ${#failed[@]} -gt 0 ]; then
  echo "Promotion blocked for: ${failed[*]}"
  exit 1
fi
exit 0
