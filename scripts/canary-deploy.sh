#!/usr/bin/env bash
#
# Canary a new image on a subset of a Deployment's pods before rolling it out.
#
# How the split works
# -------------------
# A canary Deployment is created alongside the stable one carrying the *same*
# pod labels, so the existing Service selects both and kube-proxy spreads
# connections over the union. The share of traffic the canary takes is its share
# of the pods — one canary pod beside four stable ones is roughly a fifth, not
# exactly. That is the honest limit of doing this without a service mesh, and it
# is enough to answer the question a canary is for: does the new build fall over
# under real traffic.
#
# What it watches
# ---------------
# The canary's own pods, for the length of the bake. A canary that is judged on
# the *aggregate* error rate of the Service is nearly useless: four healthy
# stable pods dilute one failing canary to a rate that looks like noise, and by
# the time it crosses a threshold the rollout has already been promoted.
#
# On any failure — the canary never becoming ready, a container restarting, or
# a pod entering CrashLoopBackOff — the canary is deleted and the script exits
# non-zero without touching the stable Deployment. Nothing has been promoted, so
# there is nothing to roll back.
#
# Usage:
#   canary-deploy.sh <namespace> <deployment> <image> [bake-seconds] [canary-replicas]

set -euo pipefail

NAMESPACE="${1:?usage: canary-deploy.sh <namespace> <deployment> <image> [bake] [replicas]}"
DEPLOYMENT="${2:?deployment name is required}"
IMAGE="${3:?image is required}"
BAKE_SECONDS="${4:-120}"
CANARY_REPLICAS="${5:-1}"

CANARY="${DEPLOYMENT}-canary"

log() { printf '%s  %s\n' "$(date -u +%H:%M:%S)" "$*" >&2; }

cleanup_canary() {
  log "removing the canary deployment"
  kubectl -n "$NAMESPACE" delete deployment "$CANARY" --ignore-not-found --wait=true >/dev/null 2>&1 || true
}

# The canary is a temporary object. If this script is killed — a cancelled
# workflow, a runner timeout — leaving it behind would quietly serve the
# unpromoted build to a fifth of production for ever.
trap cleanup_canary EXIT

if ! kubectl -n "$NAMESPACE" get deployment "$DEPLOYMENT" >/dev/null 2>&1; then
  log "ERROR: deployment $DEPLOYMENT does not exist in $NAMESPACE"
  log "Nothing was deployed. A canary against a deployment that is not there"
  log "would otherwise succeed by doing nothing at all."
  exit 1
fi

log "building a canary of $DEPLOYMENT with $IMAGE"

# Derived from the live stable Deployment rather than from a manifest, so the
# canary differs from what is running in exactly one respect: the image.
kubectl -n "$NAMESPACE" get deployment "$DEPLOYMENT" -o json \
  | python3 -c '
import json, sys

canary = sys.argv[1]
image = sys.argv[2]
replicas = int(sys.argv[3])

spec = json.load(sys.stdin)

# Strip everything the cluster owns. Reposting resourceVersion or the old uid
# makes the create fail; reposting status makes it lie.
meta = spec["metadata"]
for field in ("resourceVersion", "uid", "selfLink", "creationTimestamp", "generation", "annotations"):
    meta.pop(field, None)
meta["name"] = canary
spec.pop("status", None)

# Marked so a human reading `kubectl get deploy` knows what it is, and so the
# cleanup below can find it even if the name convention changes.
meta.setdefault("labels", {})["yieldpoint.io/role"] = "canary"
meta.setdefault("annotations", {})["yieldpoint.io/canary-of"] = sys.argv[4]

body = spec["spec"]
body["replicas"] = replicas

# The pod template labels are left alone on purpose: they are what makes the
# Service route to the canary. A canary nothing routes to proves nothing.
# The *pod* gets an extra label for observability, which is not in the
# selector, so it does not change what the Service matches.
body["template"]["metadata"].setdefault("labels", {})["yieldpoint.io/role"] = "canary"

container = body["template"]["spec"]["containers"][0]
container["image"] = image

# A canary must not be scaled by the stable HPA, and must not outlive a failed
# bake because a pod took 20 minutes to terminate.
body["progressDeadlineSeconds"] = 300
body["template"]["spec"]["terminationGracePeriodSeconds"] = 30

json.dump(spec, sys.stdout)
' "$CANARY" "$IMAGE" "$CANARY_REPLICAS" "$DEPLOYMENT" \
  | kubectl -n "$NAMESPACE" apply -f - >/dev/null

log "waiting for the canary to become ready"
if ! kubectl -n "$NAMESPACE" rollout status "deployment/$CANARY" --timeout=300s; then
  log "ERROR: the canary never became ready. The stable deployment is untouched."
  kubectl -n "$NAMESPACE" describe "deployment/$CANARY" | tail -30 >&2 || true
  kubectl -n "$NAMESPACE" logs "deployment/$CANARY" --tail=50 >&2 || true
  exit 1
fi

log "canary is serving; baking for ${BAKE_SECONDS}s"

# Restarts are counted from the moment the canary went ready, not from zero.
# A container that restarted once while starting up is not the same as one
# restarting under traffic, and treating them alike fails good deploys.
baseline_restarts=$(kubectl -n "$NAMESPACE" get pods -l "yieldpoint.io/role=canary" \
  -o jsonpath='{range .items[*]}{.status.containerStatuses[0].restartCount}{"\n"}{end}' \
  2>/dev/null | awk '{s+=$1} END {print s+0}')

deadline=$(( $(date +%s) + BAKE_SECONDS ))
while [ "$(date +%s)" -lt "$deadline" ]; do
  sleep 10

  restarts=$(kubectl -n "$NAMESPACE" get pods -l "yieldpoint.io/role=canary" \
    -o jsonpath='{range .items[*]}{.status.containerStatuses[0].restartCount}{"\n"}{end}' \
    2>/dev/null | awk '{s+=$1} END {print s+0}')

  if [ "$restarts" -gt "$baseline_restarts" ]; then
    log "ERROR: the canary restarted $(( restarts - baseline_restarts )) time(s) under traffic."
    log "The stable deployment is untouched and nothing has been promoted."
    kubectl -n "$NAMESPACE" logs -l "yieldpoint.io/role=canary" --previous --tail=50 >&2 || true
    exit 1
  fi

  waiting=$(kubectl -n "$NAMESPACE" get pods -l "yieldpoint.io/role=canary" \
    -o jsonpath='{range .items[*]}{.status.containerStatuses[0].state.waiting.reason}{"\n"}{end}' \
    2>/dev/null | grep -c 'CrashLoopBackOff\|ImagePullBackOff\|ErrImagePull' || true)

  if [ "${waiting:-0}" -gt 0 ]; then
    log "ERROR: a canary pod is stuck (CrashLoopBackOff or an image it cannot pull)."
    exit 1
  fi

  ready=$(kubectl -n "$NAMESPACE" get deployment "$CANARY" \
    -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo 0)
  if [ "${ready:-0}" -lt "$CANARY_REPLICAS" ]; then
    log "ERROR: the canary dropped below ${CANARY_REPLICAS} ready replica(s) after serving."
    exit 1
  fi

  log "canary healthy ($(( deadline - $(date +%s) ))s of bake left)"
done

log "bake passed; promoting $IMAGE to $DEPLOYMENT"
kubectl -n "$NAMESPACE" set image "deployment/$DEPLOYMENT" \
  "$(kubectl -n "$NAMESPACE" get deployment "$DEPLOYMENT" -o jsonpath='{.spec.template.spec.containers[0].name}')=$IMAGE"

if ! kubectl -n "$NAMESPACE" rollout status "deployment/$DEPLOYMENT" --timeout=600s; then
  log "ERROR: the promoted rollout failed. Rolling $DEPLOYMENT back."
  kubectl -n "$NAMESPACE" rollout undo "deployment/$DEPLOYMENT"
  kubectl -n "$NAMESPACE" rollout status "deployment/$DEPLOYMENT" --timeout=300s || true
  exit 1
fi

log "promoted $DEPLOYMENT to $IMAGE"
