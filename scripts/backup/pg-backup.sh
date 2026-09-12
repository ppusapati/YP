#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
# pg-backup.sh — Automated PostgreSQL backup for all YieldPoint databases
#
# Dumps each of the 20 service databases, compresses with gzip, uploads to
# S3-compatible storage (AWS S3 or MinIO), and prunes backups older than the
# configured retention window.
#
# Designed to run as a daily cron job or Kubernetes CronJob.
#
# Environment variables (required):
#   PGHOST          PostgreSQL host            (default: localhost)
#   PGPORT          PostgreSQL port            (default: 5432)
#   PGUSER          PostgreSQL superuser       (default: yieldpoint)
#   PGPASSWORD      PostgreSQL password        (no default — required)
#   BACKUP_BUCKET   S3/MinIO bucket name       (default: yieldpoint-backups)
#   S3_ENDPOINT     S3/MinIO endpoint URL      (default: unset — uses AWS)
#
# Environment variables (optional):
#   RETENTION_DAYS  Days to keep backups       (default: 30)
#   BACKUP_DIR      Local scratch directory    (default: /tmp/yp-pg-backups)
#   AWS_PROFILE     AWS CLI profile            (default: unset)
#   USE_MC          Set to "1" to use MinIO mc instead of aws cli
# ──────────────────────────────────────────────────────────────────────────────
set -euo pipefail

# ── Configuration ─────────────────────────────────────────────────────────────
PGHOST="${PGHOST:-localhost}"
PGPORT="${PGPORT:-5432}"
PGUSER="${PGUSER:-yieldpoint}"
BACKUP_BUCKET="${BACKUP_BUCKET:-yieldpoint-backups}"
RETENTION_DAYS="${RETENTION_DAYS:-30}"
BACKUP_DIR="${BACKUP_DIR:-/tmp/yp-pg-backups}"
USE_MC="${USE_MC:-0}"
TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
DATE_PREFIX="$(date -u +%Y/%m/%d)"

DATABASES=(
  auth_service
  farm_service
  field_service
  crop_service
  soil_service
  sensor_service
  irrigation_service
  pest_prediction_service
  plant_diagnosis_service
  yield_service
  commerce_service
  traceability_service
  satellite_service
  satellite_ingestion_service
  satellite_processing_service
  satellite_analytics_service
  satellite_tile_service
  vegetation_index_service
  task_service
  agronomy_service
)

# ── Logging helpers ───────────────────────────────────────────────────────────
log()  { echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] [INFO]  $*"; }
warn() { echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] [WARN]  $*" >&2; }
die()  { echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] [ERROR] $*" >&2; exit 1; }

# ── Pre-flight checks ────────────────────────────────────────────────────────
command -v pg_dump  >/dev/null 2>&1 || die "pg_dump not found in PATH"
command -v gzip     >/dev/null 2>&1 || die "gzip not found in PATH"

if [[ "$USE_MC" == "1" ]]; then
  command -v mc >/dev/null 2>&1 || die "mc (MinIO client) not found in PATH"
else
  command -v aws >/dev/null 2>&1 || die "aws CLI not found in PATH"
fi

if [[ -z "${PGPASSWORD:-}" ]]; then
  die "PGPASSWORD is not set"
fi

mkdir -p "$BACKUP_DIR"

# ── Build S3 CLI flags ────────────────────────────────────────────────────────
s3_endpoint_flag=""
if [[ -n "${S3_ENDPOINT:-}" && "$USE_MC" != "1" ]]; then
  s3_endpoint_flag="--endpoint-url $S3_ENDPOINT"
fi

# Upload a file to the backup bucket.
# Usage: upload_file <local_path> <remote_key>
upload_file() {
  local src="$1" key="$2"
  if [[ "$USE_MC" == "1" ]]; then
    mc cp "$src" "backup/${BACKUP_BUCKET}/${key}"
  else
    # shellcheck disable=SC2086
    aws s3 cp "$src" "s3://${BACKUP_BUCKET}/${key}" $s3_endpoint_flag --quiet
  fi
}

# ── Dump each database ───────────────────────────────────────────────────────
FAILED=()
SUCCEEDED=0

log "Starting backup run ${TIMESTAMP} — ${#DATABASES[@]} databases"

for db in "${DATABASES[@]}"; do
  dump_file="${BACKUP_DIR}/${db}_${TIMESTAMP}.sql.gz"
  remote_key="${DATE_PREFIX}/${db}_${TIMESTAMP}.sql.gz"

  log "Dumping ${db} ..."
  if pg_dump -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" \
       --format=plain --no-owner --no-acl "$db" 2>/dev/null \
     | gzip -9 > "$dump_file"; then

    # Verify the gzip file is not empty (pg_dump can succeed with 0 rows but
    # should still produce DDL).
    if [[ ! -s "$dump_file" ]]; then
      warn "Dump for ${db} produced an empty file — skipping upload"
      FAILED+=("$db")
      rm -f "$dump_file"
      continue
    fi

    log "Uploading ${db} ($(du -h "$dump_file" | cut -f1)) ..."
    if upload_file "$dump_file" "$remote_key"; then
      SUCCEEDED=$((SUCCEEDED + 1))
      log "  -> s3://${BACKUP_BUCKET}/${remote_key}"
    else
      warn "Upload failed for ${db}"
      FAILED+=("$db")
    fi
  else
    warn "pg_dump failed for ${db}"
    FAILED+=("$db")
  fi

  # Clean up local dump regardless.
  rm -f "$dump_file"
done

# ── Also back up global objects (roles, tablespaces) ──────────────────────────
log "Dumping global objects (pg_dumpall --globals-only) ..."
globals_file="${BACKUP_DIR}/globals_${TIMESTAMP}.sql.gz"
globals_key="${DATE_PREFIX}/globals_${TIMESTAMP}.sql.gz"

if pg_dumpall -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" \
     --globals-only 2>/dev/null | gzip -9 > "$globals_file"; then
  upload_file "$globals_file" "$globals_key" && \
    log "  -> s3://${BACKUP_BUCKET}/${globals_key}" || \
    warn "Upload of globals dump failed"
else
  warn "pg_dumpall --globals-only failed"
fi
rm -f "$globals_file"

# ── Prune old backups ────────────────────────────────────────────────────────
log "Pruning backups older than ${RETENTION_DAYS} days ..."
cutoff_date="$(date -u -d "${RETENTION_DAYS} days ago" +%Y-%m-%d 2>/dev/null || \
               date -u -v-"${RETENTION_DAYS}"d +%Y-%m-%d 2>/dev/null || true)"

if [[ -n "$cutoff_date" ]]; then
  if [[ "$USE_MC" == "1" ]]; then
    mc rm --recursive --force --older-than "${RETENTION_DAYS}d" \
      "backup/${BACKUP_BUCKET}/" 2>/dev/null || \
      warn "Retention cleanup via mc failed (non-fatal)"
  else
    # List objects and delete those older than the cutoff.
    # shellcheck disable=SC2086
    aws s3api list-objects-v2 \
      --bucket "$BACKUP_BUCKET" \
      --query "Contents[?LastModified<='${cutoff_date}'].Key" \
      --output text $s3_endpoint_flag 2>/dev/null | tr '\t' '\n' | while read -r key; do
      if [[ -n "$key" && "$key" != "None" ]]; then
        # shellcheck disable=SC2086
        aws s3api delete-object --bucket "$BACKUP_BUCKET" --key "$key" $s3_endpoint_flag --quiet 2>/dev/null || true
      fi
    done
    log "Retention cleanup complete"
  fi
else
  warn "Could not compute cutoff date — skipping retention cleanup"
fi

# ── Summary ───────────────────────────────────────────────────────────────────
log "Backup run complete: ${SUCCEEDED}/${#DATABASES[@]} succeeded"

if [[ ${#FAILED[@]} -gt 0 ]]; then
  warn "Failed databases: ${FAILED[*]}"
  exit 1
fi

exit 0
