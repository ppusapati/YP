#!/usr/bin/env bash
#
# generate-api-docs.sh — Generate OpenAPI v3 specs from protobuf service definitions.
#
# This script parses each service's .proto file and produces an OpenAPI v3 YAML
# spec under docs/api/. It extracts service names, RPC methods, and request/response
# message types to build the spec skeleton.
#
# Usage:
#   ./scripts/generate-api-docs.sh
#
# Requirements: bash, grep, sed, awk (standard Unix tools)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUTPUT_DIR="${REPO_ROOT}/docs/api"

mkdir -p "${OUTPUT_DIR}"

# Service definitions: name:port:proto_path:package
SERVICES=(
  "farm-service:8080:farm-service/proto/farm.proto:agriculture.farm.v1"
  "field-service:8081:field-service/proto/field.proto:agriculture.field.v1"
  "crop-service:8082:crop-service/proto/crop.proto:agriculture.crop.v1"
  "sensor-service:8083:sensor-service/proto/sensor.proto:agriculture.sensor.v1"
  "irrigation-service:8084:irrigation-service/proto/irrigation.proto:agriculture.irrigation.v1"
  "soil-service:8085:soil-service/proto/soil.proto:agriculture.soil.v1"
  "yield-service:8086:yield-service/proto/yield.proto:agriculture.yield.v1"
  "pest-prediction-service:8087:pest-prediction-service/proto/pest.proto:agriculture.pest.v1"
  "plant-diagnosis-service:8088:plant-diagnosis-service/proto/diagnosis.proto:agriculture.diagnosis.v1"
  "satellite-analytics-service:8089:satellite-analytics-service/proto/analytics.proto:agriculture.satellite.analytics.v1"
  "traceability-service:8090:traceability-service/proto/traceability.proto:agriculture.traceability.v1"
  "commerce-service:8092:commerce-service/proto/commerce.proto:agriculture.commerce.v1"
)

generate_spec() {
  local svc_name="$1"
  local port="$2"
  local proto_path="$3"
  local package="$4"
  local proto_file="${REPO_ROOT}/${proto_path}"
  local output_file="${OUTPUT_DIR}/${svc_name}.yaml"

  if [[ ! -f "${proto_file}" ]]; then
    echo "WARN: Proto file not found: ${proto_file}, skipping ${svc_name}"
    return
  fi

  # Extract the service name (e.g., FarmService)
  local service_name
  service_name=$(grep -oP '^\s*service\s+\K\w+' "${proto_file}" | head -1)

  if [[ -z "${service_name}" ]]; then
    echo "WARN: No service definition found in ${proto_file}, skipping"
    return
  fi

  # Extract RPCs: "rpc MethodName(RequestType) returns (ResponseType)"
  local rpcs
  rpcs=$(grep -oP '^\s*rpc\s+\K\w+\s*\(\s*\w+\s*\)\s*returns\s*\(\s*\w+\s*\)' "${proto_file}" || true)

  # Build a human-readable title
  local title
  title=$(echo "${svc_name}" | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g')

  # Start writing the OpenAPI spec
  cat > "${output_file}" <<HEADER
openapi: 3.0.3
info:
  title: ${title} API
  description: |
    Auto-generated OpenAPI spec for ${service_name} (${package}).
    Uses ConnectRPC protocol - all RPCs are POST with JSON bodies.
  version: 1.0.0
servers:
  - url: http://localhost:${port}
    description: Local development

paths:
HEADER

  # Generate a path entry for each RPC
  while IFS= read -r rpc_line; do
    [[ -z "${rpc_line}" ]] && continue

    local method request_type response_type
    method=$(echo "${rpc_line}" | grep -oP '^\w+')
    request_type=$(echo "${rpc_line}" | grep -oP '\(\s*\K\w+' | head -1)
    response_type=$(echo "${rpc_line}" | grep -oP 'returns\s*\(\s*\K\w+')

    cat >> "${output_file}" <<RPC
  /${package}.${service_name}/${method}:
    post:
      summary: "${method}"
      operationId: ${method}
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              description: "${request_type}"
      responses:
        '200':
          description: Success
          content:
            application/json:
              schema:
                type: object
                description: "${response_type}"

RPC
  done <<< "${rpcs}"

  echo "Generated: ${output_file}"
}

echo "Generating API documentation from proto definitions..."
echo ""

for entry in "${SERVICES[@]}"; do
  IFS=':' read -r svc_name port proto_path package <<< "${entry}"
  generate_spec "${svc_name}" "${port}" "${proto_path}" "${package}"
done

echo ""
echo "API docs generated in ${OUTPUT_DIR}/"
echo "Run 'make api-docs' to regenerate."
