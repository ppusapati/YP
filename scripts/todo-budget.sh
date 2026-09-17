#!/usr/bin/env bash
#
# A ratchet on TODO/FIXME debt.
#
# Counting markers is easy; the hard part is that a raw count says nothing on
# its own — every codebase has some, and a build that fails on the first one
# gets disabled within a week. So this compares each area against a budget
# checked in beside it. Adding a marker to an area that is already at its limit
# fails the build; clearing markers lets the budget be lowered, and the script
# says exactly which lines to change.
#
# Budgets only ever go down. That is the point: the number is allowed to be
# large today, but not larger tomorrow.
#
# Usage:
#   scripts/todo-budget.sh            # check against .todo-budget
#   scripts/todo-budget.sh --update   # rewrite budgets to current counts
#
# Exit codes: 0 within budget, 1 over budget.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUDGET_FILE="${BUDGET_FILE:-$REPO_ROOT/.todo-budget}"
UPDATE=0
[ "${1:-}" = "--update" ] && UPDATE=1

# Generated code, vendored dependencies and agent worktrees are not ours to
# clean, and counting them would drown the signal.
#
# Two exclusions were added after an audit found the budget was mostly
# measuring noise:
#
#   /pkg/   — wasm-bindgen writes its output there, and ships with a TODO of
#             its own. Ten of the thirteen markers counted against `web` were
#             that one comment, repeated across build artefacts.
#   XXX{2,} — a phone-number mask is written XXX-XXX-XXXX, and the word-boundary
#             match counted each one as a marker. That accounted for the other
#             three.
#
# A third was added later, for the same reason:
#
#   /.svelte-kit/ — SvelteKit's build output, which carries 65 markers of its
#             own per app. It does not exist on a fresh checkout, so CI never
#             saw it; it appears the moment anyone runs `pnpm build`, and the
#             ratchet then reports `web: 261 markers, budget 1` locally. A
#             check that fails on your machine and passes in CI is one people
#             learn to run with `|| true`.
#
# `web` therefore had one real marker and a budget of thirteen: twelve free
# TODOs before the ratchet would notice anything. A budget that permits more
# debt than exists is worse than none, because it reads as enforcement.
count_markers() {
  local dir="$1"
  grep -rIn --binary-files=without-match \
      -E '\b(TODO|FIXME|HACK|XXX)\b' "$REPO_ROOT/$dir" 2>/dev/null \
    | grep -v '/node_modules/' \
    | grep -v '/\.claude/worktrees/' \
    | grep -v '/target/' \
    | grep -v '/build/' \
    | grep -v '/dist/' \
    | grep -v '/\.svelte-kit/' \
    | grep -v '\.pb\.go:' \
    | grep -v '_grpc\.pb\.go:' \
    | grep -v '\.pb.*\.dart:' \
    | grep -v '\.g\.dart:' \
    | grep -v '\.freezed\.dart:' \
    | grep -v '_pb\.ts:' \
    | grep -v '\.connect\.go:' \
    | grep -v '/src/gen/' \
    | grep -v '/src/generated/' \
    | grep -v '/pkg/' \
    | grep -v 'todo-budget' \
    | grep -vE 'XXX{2,}' \
    | wc -l | tr -d ' '
}

# Areas worth tracking separately: a spike in one should not be hidden by
# progress in another.
# Every top-level area is listed. The original set covered thirteen of them and
# left fifty-two markers — a third of the total — entirely outside the ratchet,
# including every satellite service and all of yield, crop, soil and sensor.
AREAS=(
  ai-gateway
  ml-training
  rust-engines
  mobile
  web
  packages
  scripts
  cmd
  internal
  tests
  agronomy-service
  alert-service
  analytics-service
  auth-service
  commerce-service
  crop-service
  farm-service
  field-service
  irrigation-service
  pest-prediction-service
  plant-diagnosis-service
  prescription-service
  satellite-analytics-service
  satellite-ingestion-service
  satellite-processing-service
  satellite-service
  satellite-tile-service
  sensor-service
  soil-service
  task-service
  traceability-service
  vegetation-index-service
  weather-service
  yield-service
  # Added with the services themselves. The comment above describes fifty-two
  # markers left outside the ratchet because this list was written once and not
  # revisited; these seven are every service added since, so the same gap does
  # not reopen. All are at zero today, which is the easiest time to start
  # counting.
  advisory-service
  market-service
  device-service
  soil-lab-service
  planning-service
  sustainability-service
  finance-service
)

if [ "$UPDATE" = "1" ]; then
  {
    echo "# TODO/FIXME budget per area, enforced by scripts/todo-budget.sh."
    echo "# These only ever go down. Lower one whenever you clear markers."
    for area in "${AREAS[@]}"; do
      [ -d "$REPO_ROOT/$area" ] || continue
      echo "$area $(count_markers "$area")"
    done
  } > "$BUDGET_FILE"
  echo "Wrote $BUDGET_FILE"
  exit 0
fi

if [ ! -f "$BUDGET_FILE" ]; then
  echo "No budget file at $BUDGET_FILE. Create one with: scripts/todo-budget.sh --update"
  exit 1
fi

over=()
under=()
status=0

while read -r area budget; do
  case "$area" in ''|\#*) continue ;; esac
  [ -d "$REPO_ROOT/$area" ] || continue

  actual="$(count_markers "$area")"
  if [ "$actual" -gt "$budget" ]; then
    over+=("$area: $actual markers, budget $budget (+$((actual - budget)))")
    status=1
  elif [ "$actual" -lt "$budget" ]; then
    under+=("$area: $actual markers, budget $budget — lower it to $actual")
  fi
done < "$BUDGET_FILE"

if [ ${#under[@]} -gt 0 ]; then
  echo "Markers cleared since the budget was set:"
  printf '  %s\n' "${under[@]}"
  echo
fi

if [ ${#over[@]} -gt 0 ]; then
  echo "TODO budget exceeded:"
  printf '  %s\n' "${over[@]}"
  echo
  echo "Either clear a marker elsewhere in the same area, or implement the one you added."
  echo "A marker that is genuinely future work belongs in the issue tracker, not the source."
else
  echo "All areas within their TODO budget."
fi

exit $status
