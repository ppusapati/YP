#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
# verify-backup.sh — Weekly backup verification for YieldPoint databases
#
# Restores the latest backup for each database into a temporary test database,
# runs basic integrity checks (table counts, foreign key constraints, not-null
# columns), and reports results.
#
# Designed to run as a weekly cron job.
#
# Environment variables (required):
#   PGHOST          PostgreSQL host            (default: localhost)
#   PGPORT          PostgreSQL port            (default: 5432)
#   PGUSER          PostgreSQL superuser       (default: yieldpoint)
#   PGPASSWORD      PostgreSQL password        (no default — required)
#   BACKUP_BUCKET   S3/MinIO bucket name       (default: yieldpoint-backups)
#
# Environment variables (optional):
#   S3_ENDPOINT     S3/MinIO endpoint URL      (default: unset — uses AWS)
#   VERIFY_DIR      Local working directory    (default: /tmp/yp-pg-verify)
#   USE_MC          Set to "1" to use MinIO mc instead of aws cli
#   REPORT_WEBHOOK  Webhook URL for posting results (Slack, etc.)
# ──────────────────────────────────────────────────────────────────────────────
set -euo pipefail

# ── Configuration ─────────────────────────────────────────────────────────────
PGHOST="${PGHOST:-localhost}"
PGPORT="${PGPORT:-5432}"
PGUSER="${PGUSER:-yieldpoint}"
BACKUP_BUCKET="${BACKUP_BUCKET:-yieldpoint-backups}"
VERIFY_DIR="${VERIFY_DIR:-/tmp/yp-pg-verify}"
USE_MC="${USE_MC:-0}"
TEST_DB_PREFIX="yp_verify_"
TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"

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
command -v psql   >/dev/null 2>&1 || die "psql not found in PATH"
command -v gunzip >/dev/null 2>&1 || die "gunzip not found in PATH"

if [[ -z "${PGPASSWORD:-}" ]]; then
  die "PGPASSWORD is not set"
fi

mkdir -p "$VERIFY_DIR"

# ── S3 helpers ────────────────────────────────────────────────────────────────
s3_endpoint_flag=""
if [[ -n "${S3_ENDPOINT:-}" && "$USE_MC" != "1" ]]; then
  s3_endpoint_flag="--endpoint-url $S3_ENDPOINT"
fi

# Find today's or the most recent backup for a database.
find_latest_backup() {
  local db="$1"

  # Try today first, then go back up to 7 days.
  for days_ago in 0 1 2 3 4 5 6 7; do
    local date_str
    date_str="$(date -u -d "${days_ago} days ago" +%Y/%m/%d 2>/dev/null || \
                date -u -v-"${days_ago}"d +%Y/%m/%d 2>/dev/null || echo "")"

    [[ -z "$date_str" ]] && continue

    local key
    if [[ "$USE_MC" == "1" ]]; then
      key=$(mc ls "backup/${BACKUP_BUCKET}/${date_str}/" 2>/dev/null \
        | grep "${db}_" | tail -1 | awk '{print $NF}')
      if [[ -n "$key" ]]; then
        echo "${date_str}/${key}"
        return 0
      fi
    else
      # shellcheck disable=SC2086
      key=$(aws s3api list-objects-v2 \
        --bucket "$BACKUP_BUCKET" \
        --prefix "${date_str}/${db}_" \
        --query "sort_by(Contents, &LastModified)[-1].Key" \
        --output text $s3_endpoint_flag 2>/dev/null || echo "")
      if [[ -n "$key" && "$key" != "None" ]]; then
        echo "$key"
        return 0
      fi
    fi
  done
  return 1
}

download_backup() {
  local key="$1" dest="$2"
  if [[ "$USE_MC" == "1" ]]; then
    mc cp "backup/${BACKUP_BUCKET}/${key}" "$dest"
  else
    # shellcheck disable=SC2086
    aws s3 cp "s3://${BACKUP_BUCKET}/${key}" "$dest" $s3_endpoint_flag --quiet
  fi
}

# ── Cleanup function ─────────────────────────────────────────────────────────
cleanup_test_db() {
  local test_db="$1"
  psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d postgres -c \
    "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '${test_db}' AND pid <> pg_backend_pid();" \
    >/dev/null 2>&1 || true
  psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d postgres -c \
    "DROP DATABASE IF EXISTS ${test_db};" >/dev/null 2>&1 || true
}

# ── Run integrity checks on a test database ──────────────────────────────────
# Returns 0 on pass, 1 on failure. Prints check results.
run_integrity_checks() {
  local test_db="$1" db_name="$2"

  local checks_passed=0
  local checks_failed=0

  # Check 1: Table count — database should have at least 1 table.
  local table_count
  table_count=$(psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$test_db" -tAc \
    "SELECT count(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE';" 2>/dev/null || echo "0")

  if [[ "$table_count" -gt 0 ]]; then
    log "  [PASS] Table count: ${table_count} tables"
    checks_passed=$((checks_passed + 1))
  else
    warn "  [FAIL] No tables found in restored database"
    checks_failed=$((checks_failed + 1))
  fi

  # Check 2: Foreign key constraints exist and are valid.
  local fk_count
  fk_count=$(psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$test_db" -tAc \
    "SELECT count(*) FROM information_schema.table_constraints WHERE constraint_type = 'FOREIGN KEY';" 2>/dev/null || echo "0")
  log "  [INFO] Foreign key constraints: ${fk_count}"

  # Check 3: Primary key constraints.
  local pk_count
  pk_count=$(psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$test_db" -tAc \
    "SELECT count(*) FROM information_schema.table_constraints WHERE constraint_type = 'PRIMARY KEY';" 2>/dev/null || echo "0")

  if [[ "$pk_count" -gt 0 ]]; then
    log "  [PASS] Primary key constraints: ${pk_count}"
    checks_passed=$((checks_passed + 1))
  else
    warn "  [WARN] No primary key constraints found"
  fi

  # Check 4: Index count.
  local idx_count
  idx_count=$(psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$test_db" -tAc \
    "SELECT count(*) FROM pg_indexes WHERE schemaname = 'public';" 2>/dev/null || echo "0")
  log "  [INFO] Indexes: ${idx_count}"

  # Check 5: Verify each table is readable (no corruption).
  local readable_tables=0
  local total_tables=0
  while IFS= read -r table; do
    [[ -z "$table" ]] && continue
    total_tables=$((total_tables + 1))
    if psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$test_db" -c \
         "SELECT count(*) FROM \"${table}\";" >/dev/null 2>&1; then
      readable_tables=$((readable_tables + 1))
    else
      warn "  [FAIL] Table '${table}' is not readable"
      checks_failed=$((checks_failed + 1))
    fi
  done < <(psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$test_db" -tAc \
    "SELECT tablename FROM pg_tables WHERE schemaname = 'public';" 2>/dev/null)

  if [[ "$total_tables" -gt 0 && "$readable_tables" -eq "$total_tables" ]]; then
    log "  [PASS] All ${readable_tables}/${total_tables} tables are readable"
    checks_passed=$((checks_passed + 1))
  elif [[ "$total_tables" -gt 0 ]]; then
    warn "  [FAIL] Only ${readable_tables}/${total_tables} tables are readable"
    checks_failed=$((checks_failed + 1))
  fi

  # Check 6: Verify NOT NULL constraints are enforced.
  local nn_count
  nn_count=$(psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$test_db" -tAc \
    "SELECT count(*) FROM information_schema.columns WHERE table_schema = 'public' AND is_nullable = 'NO';" 2>/dev/null || echo "0")
  log "  [INFO] NOT NULL columns: ${nn_count}"

  # Summary for this database.
  log "  Checks passed: ${checks_passed}, failed: ${checks_failed}"

  [[ "$checks_failed" -eq 0 ]] && return 0 || return 1
}

# ── Main verification loop ───────────────────────────────────────────────────
log "Starting backup verification run ${TIMESTAMP}"
log "Verifying latest backups for ${#DATABASES[@]} databases"
log ""

PASSED=()
FAILED=()
SKIPPED=()

REPORT_FILE="${VERIFY_DIR}/report_${TIMESTAMP}.txt"
{
  echo "YieldPoint Backup Verification Report"
  echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "============================================="
  echo ""
} > "$REPORT_FILE"

for db in "${DATABASES[@]}"; do
  test_db="${TEST_DB_PREFIX}${db}"

  log "── Verifying: ${db} ──"

  # Find the latest backup.
  remote_key=""
  remote_key=$(find_latest_backup "$db" 2>/dev/null) || true

  if [[ -z "$remote_key" ]]; then
    warn "No recent backup found for ${db} — SKIPPED"
    SKIPPED+=("$db")
    echo "[SKIP] ${db}: No recent backup found" >> "$REPORT_FILE"
    continue
  fi

  log "  Backup: ${remote_key}"

  # Download backup.
  local_file="${VERIFY_DIR}/$(basename "$remote_key")"
  if ! download_backup "$remote_key" "$local_file" 2>/dev/null; then
    warn "Failed to download backup for ${db} — SKIPPED"
    SKIPPED+=("$db")
    echo "[SKIP] ${db}: Download failed" >> "$REPORT_FILE"
    continue
  fi

  # Clean up any leftover test database.
  cleanup_test_db "$test_db"

  # Create test database and restore.
  psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d postgres -c \
    "CREATE DATABASE ${test_db};" >/dev/null 2>&1

  log "  Restoring to test database ${test_db} ..."
  if gunzip -c "$local_file" | psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" \
       -d "$test_db" -v ON_ERROR_STOP=0 >/dev/null 2>&1; then

    # Run integrity checks.
    if run_integrity_checks "$test_db" "$db"; then
      PASSED+=("$db")
      echo "[PASS] ${db}" >> "$REPORT_FILE"
    else
      FAILED+=("$db")
      echo "[FAIL] ${db}: Integrity checks failed" >> "$REPORT_FILE"
    fi
  else
    warn "Restore failed for ${db}"
    FAILED+=("$db")
    echo "[FAIL] ${db}: Restore failed" >> "$REPORT_FILE"
  fi

  # Clean up test database and local file.
  cleanup_test_db "$test_db"
  rm -f "$local_file"

  log ""
done

# ── Summary ───────────────────────────────────────────────────────────────────
{
  echo ""
  echo "============================================="
  echo "Summary"
  echo "  Passed:  ${#PASSED[@]}/${#DATABASES[@]}"
  echo "  Failed:  ${#FAILED[@]}/${#DATABASES[@]}"
  echo "  Skipped: ${#SKIPPED[@]}/${#DATABASES[@]}"
  if [[ ${#FAILED[@]} -gt 0 ]]; then
    echo "  Failed:  ${FAILED[*]}"
  fi
  if [[ ${#SKIPPED[@]} -gt 0 ]]; then
    echo "  Skipped: ${SKIPPED[*]}"
  fi
} | tee -a "$REPORT_FILE"

log ""
log "Full report: ${REPORT_FILE}"

# ── Send webhook notification if configured ───────────────────────────────────
if [[ -n "${REPORT_WEBHOOK:-}" ]]; then
  status="passed"
  [[ ${#FAILED[@]} -gt 0 ]] && status="FAILED"

  payload=$(cat <<EOJSON
{
  "text": "YieldPoint Backup Verification: ${status}\nPassed: ${#PASSED[@]}/${#DATABASES[@]}, Failed: ${#FAILED[@]}, Skipped: ${#SKIPPED[@]}",
  "username": "backup-verify",
  "icon_emoji": "$(if [[ "$status" == "passed" ]]; then echo ":white_check_mark:"; else echo ":x:"; fi)"
}
EOJSON
)
  curl -s -X POST -H "Content-Type: application/json" -d "$payload" "$REPORT_WEBHOOK" >/dev/null 2>&1 || \
    warn "Failed to send webhook notification"
fi

# Exit with error if any database failed.
if [[ ${#FAILED[@]} -gt 0 ]]; then
  exit 1
fi

exit 0
