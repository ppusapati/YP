#!/usr/bin/env bash
#
# Put every YieldPoint deployment in a namespace back on its previous ReplicaSet.
#
# A half-finished rollout is worse than either version on its own: the Service
# is selecting some old pods and some crash-looping new ones, so a share of
# requests fail and the share depends on how far the rollout got. Undoing gets
# back to one known state.
#
# Deployments that were already healthy are left alone. Rolling back a service
# that deployed fine would take a good build out of production because a
# different service failed, and on a thirty-service platform that turns one
# bad build into thirty.
#
# Usage:  rollback.sh <namespace>

set -uo pipefail

NAMESPACE="${1:?usage: rollback.sh <namespace>}"
SELECTOR="app.kubernetes.io/part-of=yieldpoint"

log() { printf '%s  %s\n' "$(date -u +%H:%M:%S)" "$*" >&2; }

# Any canary left behind by a failed bake goes first: it is by definition
# running the build that just failed.
canaries=$(kubectl -n "$NAMESPACE" get deployments -l "yieldpoint.io/role=canary" \
  -o jsonpath='{range .items[*]}{.metadata.name}{" "}{end}' 2>/dev/null || true)
if [ -n "${canaries// /}" ]; then
  log "removing leftover canary deployment(s): $canaries"
  # shellcheck disable=SC2086
  kubectl -n "$NAMESPACE" delete deployment $canaries --ignore-not-found >/dev/null 2>&1 || true
fi

mapfile -t deployments < <(
  kubectl -n "$NAMESPACE" get deployments -l "$SELECTOR" \
    -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' 2>/dev/null | sort
)

if [ ${#deployments[@]} -eq 0 ]; then
  log "no deployments in $NAMESPACE to roll back"
  exit 0
fi

rolled=0
for deployment in "${deployments[@]}"; do
  # Healthy is: every replica the spec asks for is ready and up to date.
  read -r desired ready updated < <(
    kubectl -n "$NAMESPACE" get "deployment/$deployment" \
      -o jsonpath='{.spec.replicas}{" "}{.status.readyReplicas}{" "}{.status.updatedReplicas}' \
      2>/dev/null
  )
  desired=${desired:-0}
  ready=${ready:-0}
  updated=${updated:-0}

  if [ "$ready" -ge "$desired" ] && [ "$updated" -ge "$desired" ]; then
    continue
  fi

  log "rolling back $deployment (${ready}/${desired} ready)"
  if kubectl -n "$NAMESPACE" rollout undo "deployment/$deployment" >/dev/null 2>&1; then
    rolled=$((rolled + 1))
  else
    # The most common reason is that there is no previous revision: a first
    # deploy that failed has nothing to go back to. Said out loud, because the
    # fix is to delete it rather than to wait.
    log "  could not undo $deployment — it may have no previous revision"
  fi
done

if [ "$rolled" -eq 0 ]; then
  log "nothing needed rolling back"
  exit 0
fi

log "waiting for $rolled rolled-back deployment(s) to settle"
for deployment in "${deployments[@]}"; do
  kubectl -n "$NAMESPACE" rollout status "deployment/$deployment" --timeout=300s >/dev/null 2>&1 || true
done

log "rolled back $rolled deployment(s) in $NAMESPACE"
