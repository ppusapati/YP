#!/usr/bin/env bash
#
# Wait for every YieldPoint deployment in a namespace, and fail if there are none.
#
# Why the count check exists
# --------------------------
#   kubectl rollout status deployment -l app.kubernetes.io/part-of=yieldpoint
#
# exits zero when the selector matches nothing. The pipeline that ran that line
# reported a successful deploy of thirty services while applying three, and
# would have reported a successful deploy of zero just as cheerfully. A deploy
# step that cannot fail is not a check, it is a decoration.
#
# So: count first, assert the count is what the manifests say it should be, then
# wait on each one by name. Waiting per deployment rather than on the selector
# also means the failure message names the service that did not come up.
#
# Usage:  verify-rollout.sh <namespace> [expected-count] [timeout-seconds]

set -euo pipefail

NAMESPACE="${1:?usage: verify-rollout.sh <namespace> [expected] [timeout]}"
EXPECTED="${2:-}"
TIMEOUT="${3:-600}"

SELECTOR="app.kubernetes.io/part-of=yieldpoint"

log() { printf '%s  %s\n' "$(date -u +%H:%M:%S)" "$*" >&2; }

mapfile -t deployments < <(
  kubectl -n "$NAMESPACE" get deployments -l "$SELECTOR" \
    -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | sort
)

count=${#deployments[@]}

if [ "$count" -eq 0 ]; then
  log "ERROR: no deployments in namespace $NAMESPACE match $SELECTOR."
  log "Nothing was deployed. This is the failure that looked like success for as"
  log "long as the pipeline waited on a label selector instead of a name."
  exit 1
fi

# When no expectation is passed, derive one from the manifests the repo holds.
# A deploy that silently drops a service — a bad kustomize patch, a resource
# that failed to apply — otherwise passes, because everything still running is
# still healthy.
if [ -z "$EXPECTED" ] && command -v python3 >/dev/null 2>&1; then
  repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  if [ -f "$repo_root/k8s/base/services.yaml" ]; then
    EXPECTED=$(grep -c '^kind: Deployment$' "$repo_root/k8s/base/services.yaml" || true)
  fi
fi

if [ -n "${EXPECTED:-}" ] && [ "$EXPECTED" -gt 0 ] && [ "$count" -lt "$EXPECTED" ]; then
  log "ERROR: $count deployment(s) in $NAMESPACE, expected at least $EXPECTED."
  log "Something in the manifests did not apply. Present:"
  printf '  %s\n' "${deployments[@]}" >&2
  exit 1
fi

log "waiting for $count deployment(s) in $NAMESPACE"

failed=()
for deployment in "${deployments[@]}"; do
  if kubectl -n "$NAMESPACE" rollout status "deployment/$deployment" \
      --timeout="${TIMEOUT}s" >/dev/null 2>&1; then
    log "  ok   $deployment"
  else
    log "  FAIL $deployment"
    failed+=("$deployment")
  fi
done

if [ ${#failed[@]} -gt 0 ]; then
  log ""
  log "ERROR: ${#failed[@]} of $count deployment(s) did not roll out:"
  for deployment in "${failed[@]}"; do
    log "  --- $deployment ---"
    kubectl -n "$NAMESPACE" describe "deployment/$deployment" 2>&1 | tail -20 >&2 || true
    kubectl -n "$NAMESPACE" logs "deployment/$deployment" --tail=40 2>&1 >&2 || true
  done
  exit 1
fi

log "all $count deployment(s) rolled out"
