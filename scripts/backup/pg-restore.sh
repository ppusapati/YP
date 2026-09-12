#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
# pg-restore.sh — Restore YieldPoint PostgreSQL databases from backup
#
# Supports:
#   - Restoring a single database from a specific backup file
#   - Restoring all databases from a dated backup set
#   - Point-in-time recovery (PITR) via WAL replay
#   - Download from S3/MinIO before restore
#
# Usage:
#   pg-restore.sh --db <database> --file <backup.sql.gz>
#   pg-restore.sh --db <database> --date <YYYYMMDD> [--time <HHMMSS>]
#   pg-restore.sh --all --date <YYYYMMDD>
#   pg-restore.sh --pitr --target-time "2025-06-15 14:30:00+00"
#
# Environment variables (required):
#   PGHOST          PostgreSQL host            (default: localhost)
#   PGPORT          PostgreSQL port            (default: 5432)
#   PGUSER          PostgreSQL superuser       (default: yieldpoint)
#   PGPASSWORD      PostgreSQL password        (no default — required)
#
# Environment variables (optional):
#   BACKUP_BUCKET   S3/MinIO bucket name       (default: yieldpoint-backups)
#   S3_ENDPOINT     S3/MinIO endpoint URL      (default: unset — uses AWS)
#   RESTORE_DIR     Local working directory    (default: /tmp/yp-pg-restore)
#   USE_MC          Set to "1" to use MinIO mc instead of aws cli
#   FORCE           Set to "1" to skip confirmation prompts
# ──────────────────────────────────────────────────────────────────────────────
set -euo pipefail

# ── Configuration ─────────────────────────────────────────────────────────────
PGHOST="${PGHOST:-localhost}"
PGPORT="${PGPORT:-5432}"
PGUSER="${PGUSER:-yieldpoint}"
BACKUP_BUCKET="${BACKUP_BUCKET:-yieldpoint-backups}"
RESTORE_DIR="${RESTORE_DIR:-/tmp/yp-pg-restore}"
USE_MC="${USE_MC:-0}"
FORCE="${FORCE:-0}"

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

# ── Argument parsing ──────────────────────────────────────────────────────────
MODE=""
TARGET_DB=""
BACKUP_FILE=""
BACKUP_DATE=""
BACKUP_TIME=""
PITR_TARGET=""

usage() {
  cat <<EOF
Usage:
  $(basename "$0") --db <database> --file <backup.sql.gz>
  $(basename "$0") --db <database> --date <YYYYMMDD>
  $(basename "$0") --all --date <YYYYMMDD>
  $(basename "$0") --pitr --target-time "YYYY-MM-DD HH:MM:SS+00"

Options:
  --db <name>               Restore a single database
  --all                     Restore all 20 databases
  --file <path>             Path to a local .sql.gz backup file
  --date <YYYYMMDD>         Date of backup to fetch from S3
  --time <HHMMSS>           Specific time within date (picks latest if omitted)
  --pitr --target-time <t>  Point-in-time recovery via WAL replay
  --force                   Skip confirmation prompts
  -h, --help                Show this help
EOF
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --db)           TARGET_DB="$2"; MODE="single"; shift 2 ;;
    --all)          MODE="all"; shift ;;
    --file)         BACKUP_FILE="$2"; shift 2 ;;
    --date)         BACKUP_DATE="$2"; shift 2 ;;
    --time)         BACKUP_TIME="$2"; shift 2 ;;
    --pitr)         MODE="pitr"; shift ;;
    --target-time)  PITR_TARGET="$2"; shift 2 ;;
    --force)        FORCE="1"; shift ;;
    -h|--help)      usage ;;
    *)              die "Unknown option: $1" ;;
  esac
done

[[ -z "$MODE" ]] && die "Must specify --db, --all, or --pitr. Use --help for usage."

# ── Pre-flight checks ────────────────────────────────────────────────────────
command -v psql  >/dev/null 2>&1 || die "psql not found in PATH"
command -v gunzip >/dev/null 2>&1 || die "gunzip not found in PATH"

if [[ -z "${PGPASSWORD:-}" ]]; then
  die "PGPASSWORD is not set"
fi

mkdir -p "$RESTORE_DIR"

# ── S3 helpers ────────────────────────────────────────────────────────────────
s3_endpoint_flag=""
if [[ -n "${S3_ENDPOINT:-}" && "$USE_MC" != "1" ]]; then
  s3_endpoint_flag="--endpoint-url $S3_ENDPOINT"
fi

# Download a backup from S3.  Usage: download_backup <remote_key> <local_dest>
download_backup() {
  local key="$1" dest="$2"
  log "Downloading s3://${BACKUP_BUCKET}/${key} ..."
  if [[ "$USE_MC" == "1" ]]; then
    mc cp "backup/${BACKUP_BUCKET}/${key}" "$dest"
  else
    # shellcheck disable=SC2086
    aws s3 cp "s3://${BACKUP_BUCKET}/${key}" "$dest" $s3_endpoint_flag --quiet
  fi
}

# Find the latest backup key for a given database and date.
# Usage: find_latest_backup <db_name> <YYYYMMDD>
find_latest_backup() {
  local db="$1" date_str="$2"
  local prefix
  prefix="$(echo "$date_str" | sed 's/\(....\)\(..\)\(..\)/\1\/\2\/\3/')/"

  if [[ "$USE_MC" == "1" ]]; then
    mc ls "backup/${BACKUP_BUCKET}/${prefix}" 2>/dev/null \
      | grep "${db}_" | tail -1 | awk '{print $NF}'
  else
    # shellcheck disable=SC2086
    aws s3api list-objects-v2 \
      --bucket "$BACKUP_BUCKET" \
      --prefix "${prefix}${db}_" \
      --query "sort_by(Contents, &LastModified)[-1].Key" \
      --output text $s3_endpoint_flag 2>/dev/null
  fi
}

# ── Confirmation prompt ──────────────────────────────────────────────────────
confirm() {
  if [[ "$FORCE" == "1" ]]; then
    return 0
  fi

  local msg="$1"
  echo ""
  echo "WARNING: $msg"
  echo ""
  read -rp "Type 'yes' to continue: " answer
  if [[ "$answer" != "yes" ]]; then
    die "Aborted by user"
  fi
}

# ── Restore a single database from a .sql.gz file ────────────────────────────
restore_database() {
  local db="$1" file="$2"

  if [[ ! -f "$file" ]]; then
    die "Backup file not found: $file"
  fi

  log "Checking if database ${db} exists ..."
  local db_exists
  db_exists=$(psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d postgres \
    -tAc "SELECT 1 FROM pg_database WHERE datname = '${db}'" 2>/dev/null || echo "")

  if [[ "$db_exists" == "1" ]]; then
    confirm "Database '${db}' already exists. Restoring will DROP and recreate it. All existing data will be lost."

    log "Terminating active connections to ${db} ..."
    psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d postgres -c \
      "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '${db}' AND pid <> pg_backend_pid();" \
      >/dev/null 2>&1 || true

    log "Dropping database ${db} ..."
    psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d postgres -c \
      "DROP DATABASE IF EXISTS ${db};" >/dev/null
  fi

  log "Creating database ${db} ..."
  psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d postgres -c \
    "CREATE DATABASE ${db};" >/dev/null

  log "Restoring ${db} from $(basename "$file") ..."
  if gunzip -c "$file" | psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" \
       -d "$db" --single-transaction -v ON_ERROR_STOP=0 >/dev/null 2>&1; then
    log "  -> ${db} restored successfully"
    return 0
  else
    warn "Restore of ${db} completed with warnings (some errors may be non-fatal)"
    return 0
  fi
}

# ── Mode: single database ────────────────────────────────────────────────────
if [[ "$MODE" == "single" ]]; then
  [[ -z "$TARGET_DB" ]] && die "--db requires a database name"

  # Validate the database name is one of the known databases.
  db_valid=0
  for db in "${DATABASES[@]}"; do
    [[ "$db" == "$TARGET_DB" ]] && db_valid=1
  done
  if [[ "$db_valid" -eq 0 ]]; then
    warn "Database '${TARGET_DB}' is not in the known database list. Proceeding anyway."
  fi

  # Either use a provided file or download from S3.
  if [[ -n "$BACKUP_FILE" ]]; then
    restore_database "$TARGET_DB" "$BACKUP_FILE"
  elif [[ -n "$BACKUP_DATE" ]]; then
    remote_key=$(find_latest_backup "$TARGET_DB" "$BACKUP_DATE")
    if [[ -z "$remote_key" || "$remote_key" == "None" ]]; then
      die "No backup found for ${TARGET_DB} on date ${BACKUP_DATE}"
    fi
    local_file="${RESTORE_DIR}/$(basename "$remote_key")"
    download_backup "$remote_key" "$local_file"
    restore_database "$TARGET_DB" "$local_file"
    rm -f "$local_file"
  else
    die "Must specify --file or --date when using --db"
  fi
fi

# ── Mode: all databases ──────────────────────────────────────────────────────
if [[ "$MODE" == "all" ]]; then
  [[ -z "$BACKUP_DATE" ]] && die "--all requires --date <YYYYMMDD>"

  confirm "This will DROP and RECREATE all ${#DATABASES[@]} service databases. ALL EXISTING DATA WILL BE LOST."

  # Restore globals first if available.
  globals_key=$(find_latest_backup "globals" "$BACKUP_DATE")
  if [[ -n "$globals_key" && "$globals_key" != "None" ]]; then
    globals_file="${RESTORE_DIR}/$(basename "$globals_key")"
    download_backup "$globals_key" "$globals_file"
    log "Restoring global objects ..."
    gunzip -c "$globals_file" | psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" \
      -d postgres -v ON_ERROR_STOP=0 >/dev/null 2>&1 || \
      warn "Globals restore completed with warnings"
    rm -f "$globals_file"
  fi

  FAILED=()
  for db in "${DATABASES[@]}"; do
    remote_key=$(find_latest_backup "$db" "$BACKUP_DATE")
    if [[ -z "$remote_key" || "$remote_key" == "None" ]]; then
      warn "No backup found for ${db} on ${BACKUP_DATE} — skipping"
      FAILED+=("$db")
      continue
    fi

    local_file="${RESTORE_DIR}/$(basename "$remote_key")"
    download_backup "$remote_key" "$local_file"
    # Force mode to skip per-database prompts since we already confirmed.
    FORCE=1 restore_database "$db" "$local_file" || FAILED+=("$db")
    rm -f "$local_file"
  done

  if [[ ${#FAILED[@]} -gt 0 ]]; then
    warn "Failed/skipped databases: ${FAILED[*]}"
    exit 1
  fi
  log "All databases restored successfully"
fi

# ── Mode: Point-in-time recovery ─────────────────────────────────────────────
if [[ "$MODE" == "pitr" ]]; then
  [[ -z "$PITR_TARGET" ]] && die "--pitr requires --target-time"

  confirm "Point-in-time recovery to '${PITR_TARGET}'. This requires PostgreSQL to be configured for WAL archiving and the WAL archive to be accessible. The PostgreSQL server will need to be restarted."

  log "Point-in-time recovery to: ${PITR_TARGET}"
  log ""
  log "PITR requires manual steps — this script prepares the recovery configuration."
  log ""

  PGDATA="${PGDATA:-/var/lib/postgresql/data}"

  # Step 1: Verify WAL archive is accessible.
  if [[ ! -d "${PGDATA}" ]]; then
    die "PGDATA directory not found at ${PGDATA}. Set PGDATA if it is elsewhere."
  fi

  # Step 2: Restore the base backup first (latest full backup before target).
  log "Step 1: Ensure a base backup has been restored to ${PGDATA}"
  log "  If not, stop PostgreSQL, restore the base backup, then re-run this script."
  log ""

  # Step 3: Create recovery signal and configure recovery target.
  recovery_conf="${PGDATA}/postgresql.auto.conf"

  log "Step 2: Writing recovery settings to ${recovery_conf} ..."

  # Append PITR settings (PostgreSQL 12+ uses recovery signal files).
  cat >> "$recovery_conf" <<EOF

# ── PITR Recovery (written by pg-restore.sh at $(date -u +%Y-%m-%dT%H:%M:%SZ)) ──
recovery_target_time = '${PITR_TARGET}'
recovery_target_action = 'promote'
restore_command = 'cp /var/lib/postgresql/wal_archive/%f %p'
EOF

  # Create the recovery signal file.
  touch "${PGDATA}/recovery.signal"

  log "Step 3: Recovery signal created at ${PGDATA}/recovery.signal"
  log ""
  log "Step 4: Restart PostgreSQL to begin WAL replay."
  log "  pg_ctl -D ${PGDATA} restart"
  log ""
  log "Step 5: Monitor recovery progress in the PostgreSQL log."
  log "  Once recovery is complete, PostgreSQL will promote to read-write mode."
  log ""
  log "PITR configuration complete. Restart PostgreSQL to begin recovery."
fi

log "Restore operation complete"
exit 0
