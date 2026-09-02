#!/usr/bin/env bash
# Creates one database per service inside the shared PostgreSQL instance.
# Mounted as a docker-entrypoint-initdb.d script by docker-compose.
set -euo pipefail

DATABASES=(
  farm_service
  field_service
  crop_service
  sensor_service
  irrigation_service
  soil_service
  yield_service
  pest_prediction_service
  plant_diagnosis_service
  satellite_service
  traceability_service
  commerce_service
)

for db in "${DATABASES[@]}"; do
  echo "Creating database: $db"
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-SQL
    SELECT 'CREATE DATABASE $db'
    WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$db')\gexec
SQL
done

echo "All databases created."
