#!/usr/bin/env bash
#
# Apply object-storage lifecycle rules: tier old satellite imagery to cold
# storage, and expire what nobody will read again.
#
# Satellite scenes are by far the largest thing this platform stores — a single
# Sentinel-2 tile is a few hundred megabytes, and ingestion adds them every few
# days per field, forever. Nothing currently removes or demotes any of it.
#
# The access pattern is sharply front-loaded. A scene is read constantly for
# the first month while NDVI is computed and the field is being watched, then
# essentially never, except for a season-over-season comparison that reaches
# back a year or two and tolerates a restore delay. That shape is what tiering
# is for.
#
# Usage:
#   scripts/storage-lifecycle.sh                 # apply and show the result
#   scripts/storage-lifecycle.sh --dry-run       # print the rules, change nothing
#
# Runs against MinIO by default; the same JSON applies to S3 unchanged, since
# MinIO implements the S3 lifecycle API.

set -euo pipefail

DRY_RUN=0
[ "${1:-}" = "--dry-run" ] && DRY_RUN=1

S3_ENDPOINT="${S3_ENDPOINT:-http://localhost:9000}"
S3_BUCKET="${S3_BUCKET:-yieldpoint}"
ALIAS="${MC_ALIAS:-yp}"

# Tiering thresholds, in days.
#
# 30 for the warm-to-cold move: it is past the window in which a scene is being
# actively processed, and comfortably past the point where a re-run of a failed
# ingestion would still be attempted.
RAW_TO_COLD_DAYS="${RAW_TO_COLD_DAYS:-30}"

# Tiles are derived data. They can be re-rendered from the scene they came
# from, so they expire rather than tier — paying to keep something cheaply
# reproducible is worse than re-rendering it on the rare occasion someone asks.
TILE_EXPIRY_DAYS="${TILE_EXPIRY_DAYS:-180}"

# Raw scenes are kept for three seasons. Two would cover year-on-year
# comparison; three leaves a margin for a crop on a two-year rotation.
RAW_EXPIRY_DAYS="${RAW_EXPIRY_DAYS:-1095}"

# A multipart upload that was interrupted leaves parts behind that are billed
# and invisible — they do not appear in a bucket listing. A week is long enough
# for a legitimate retry and short enough that the leak stays small.
INCOMPLETE_UPLOAD_DAYS="${INCOMPLETE_UPLOAD_DAYS:-7}"

LIFECYCLE_JSON=$(cat <<JSON
{
  "Rules": [
    {
      "ID": "satellite-raw-to-cold",
      "Status": "Enabled",
      "Filter": { "Prefix": "satellite/raw/" },
      "Transition": {
        "Days": ${RAW_TO_COLD_DAYS},
        "StorageClass": "COLD"
      }
    },
    {
      "ID": "satellite-raw-expiry",
      "Status": "Enabled",
      "Filter": { "Prefix": "satellite/raw/" },
      "Expiration": { "Days": ${RAW_EXPIRY_DAYS} }
    },
    {
      "ID": "satellite-tiles-expiry",
      "Status": "Enabled",
      "Filter": { "Prefix": "satellite/tiles/" },
      "Expiration": { "Days": ${TILE_EXPIRY_DAYS} }
    },
    {
      "ID": "abort-incomplete-uploads",
      "Status": "Enabled",
      "Filter": { "Prefix": "" },
      "AbortIncompleteMultipartUpload": { "DaysAfterInitiation": ${INCOMPLETE_UPLOAD_DAYS} }
    }
  ]
}
JSON
)

if [ "$DRY_RUN" = "1" ]; then
  echo "Would apply to ${ALIAS}/${S3_BUCKET}:"
  echo "$LIFECYCLE_JSON"
  exit 0
fi

# Only needed to apply. A dry run prints the rules and touches nothing, so it
# should work on a machine that has never installed the client.
if ! command -v mc >/dev/null 2>&1; then
  cat >&2 <<'MSG'
The MinIO client (mc) is required.

  docker run --rm -it --network host minio/mc:latest sh
  # then run the mc commands below by hand, or

  brew install minio-mc          # macOS
  go install github.com/minio/mc@latest
MSG
  exit 1
fi

mc alias set "$ALIAS" "$S3_ENDPOINT" \
  "${S3_ACCESS_KEY_ID:?S3_ACCESS_KEY_ID is required}" \
  "${S3_SECRET_ACCESS_KEY:?S3_SECRET_ACCESS_KEY is required}" >/dev/null

TMP_RULES=$(mktemp)
trap 'rm -f "$TMP_RULES"' EXIT
printf '%s\n' "$LIFECYCLE_JSON" > "$TMP_RULES"

mc ilm import "${ALIAS}/${S3_BUCKET}" < "$TMP_RULES"

echo
echo "Lifecycle rules on ${ALIAS}/${S3_BUCKET}:"
mc ilm ls "${ALIAS}/${S3_BUCKET}"

cat <<'MSG'

Two things to know before relying on this:

  - The COLD transition needs a remote tier configured, or MinIO accepts the
    rule and silently never moves anything. Set one up first:

      mc ilm tier add s3 yp COLD \
        --endpoint https://s3.amazonaws.com \
        --access-key ... --secret-key ... \
        --bucket <archive-bucket> --storage-class GLACIER

    Without it, the expiry rules still work; the transition does not.

  - Expiry is irreversible and applies to objects already in the bucket. On a
    deployment with existing data, run with --dry-run first and check the ages
    of what is there:

      mc ls --recursive --summarize yp/yieldpoint/satellite/raw/
MSG
