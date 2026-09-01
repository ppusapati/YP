#!/usr/bin/env bash
# Run migrations for a specific service or all services.
# Usage:
#   ./scripts/migrate.sh farm-service up        # run up migrations for farm-service
#   ./scripts/migrate.sh all up                  # run up migrations for all services
#   ./scripts/migrate.sh field-service down      # rollback field-service
#
# Requires: psql
# Reads DATABASE_URL from environment or defaults to local compose setup.
set -euo pipefail

SERVICES=(
  farm-service
  field-service
  crop-service
  sensor-service
  irrigation-service
  soil-service
  yield-service
  pest-prediction-service
  plant-diagnosis-service
  satellite-service
  traceability-service
)

DB_USER="${POSTGRES_USER:-yieldpoint}"
DB_PASS="${POSTGRES_PASSWORD:-yieldpoint}"
DB_HOST="${POSTGRES_HOST:-localhost}"
DB_PORT="${POSTGRES_PORT:-5432}"

SERVICE="${1:-}"
DIRECTION="${2:-up}"

if [[ -z "$SERVICE" ]]; then
  echo "Usage: $0 <service|all> <up|down>"
  echo "Services: ${SERVICES[*]}"
  exit 1
fi

run_migrations() {
  local svc="$1"
  local dir="$2"
  local db_name
  db_name=$(echo "$svc" | tr '-' '_')

  local migration_dir
  migration_dir="$(dirname "$0")/../${svc}/migrations"

  if [[ ! -d "$migration_dir" ]]; then
    echo "  ⏭  No migrations directory for $svc"
    return
  fi

  local dsn="postgres://${DB_USER}:${DB_PASS}@${DB_HOST}:${DB_PORT}/${db_name}?sslmode=disable"

  if [[ "$dir" == "up" ]]; then
    for f in "$migration_dir"/*.up.sql; do
      [[ -f "$f" ]] || continue
      echo "  → $(basename "$f")"
      psql "$dsn" -f "$f" 2>&1 | head -5
    done
  elif [[ "$dir" == "down" ]]; then
    for f in $(ls -r "$migration_dir"/*.down.sql 2>/dev/null); do
      [[ -f "$f" ]] || continue
      echo "  → $(basename "$f")"
      psql "$dsn" -f "$f" 2>&1 | head -5
    done
  else
    echo "Unknown direction: $dir (use 'up' or 'down')"
    exit 1
  fi
}

if [[ "$SERVICE" == "all" ]]; then
  for svc in "${SERVICES[@]}"; do
    echo "=== $svc ($DIRECTION) ==="
    run_migrations "$svc" "$DIRECTION"
  done
else
  echo "=== $SERVICE ($DIRECTION) ==="
  run_migrations "$SERVICE" "$DIRECTION"
fi

echo "Done."
