#!/usr/bin/env bash
# run-all.sh — Run all YieldPoint k6 load tests sequentially.
#
# Usage:
#   ./tests/load/run-all.sh                     # run all tests against localhost
#   BASE_URL=https://staging.yieldpoint.dev ./tests/load/run-all.sh
#   ./tests/load/run-all.sh --only auth-flow    # run a single test
#
# Outputs:
#   - JSON results to tests/load/results/<test>-<timestamp>.json
#   - Summary report to tests/load/results/summary-<timestamp>.txt
#   - Exit code 0 if all thresholds pass, 1 otherwise

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="${SCRIPT_DIR}/results"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
SUMMARY_FILE="${RESULTS_DIR}/summary-${TIMESTAMP}.txt"

# Ensure results directory exists
mkdir -p "${RESULTS_DIR}"

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

export BASE_URL="${BASE_URL:-http://localhost:8080}"
export AI_GATEWAY_URL="${AI_GATEWAY_URL:-http://localhost:50051}"
export TEST_USER_EMAIL="${TEST_USER_EMAIL:-loadtest@yieldpoint.dev}"
export TEST_USER_PASSWORD="${TEST_USER_PASSWORD:-LoadTest2026!}"

# All test files in execution order
ALL_TESTS=(
  "auth-flow"
  "farm-crud"
  "sensor-ingestion"
  "satellite-upload"
  "ai-inference"
)

# ---------------------------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------------------------

ONLY_TEST=""
if [[ "${1:-}" == "--only" ]] && [[ -n "${2:-}" ]]; then
  ONLY_TEST="$2"
fi

# ---------------------------------------------------------------------------
# Run tests
# ---------------------------------------------------------------------------

TOTAL=0
PASSED=0
FAILED=0
FAILED_TESTS=()

echo "============================================================"
echo "  YieldPoint Load Test Suite"
echo "  Target: ${BASE_URL}"
echo "  Started: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
echo "============================================================"
echo ""

{
  echo "YieldPoint Load Test Report"
  echo "=========================="
  echo "Target:  ${BASE_URL}"
  echo "Started: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
  echo ""
} > "${SUMMARY_FILE}"

for TEST_NAME in "${ALL_TESTS[@]}"; do
  # Skip if --only was specified and this is not the requested test
  if [[ -n "${ONLY_TEST}" ]] && [[ "${TEST_NAME}" != "${ONLY_TEST}" ]]; then
    continue
  fi

  TEST_FILE="${SCRIPT_DIR}/${TEST_NAME}.js"

  if [[ ! -f "${TEST_FILE}" ]]; then
    echo "WARNING: Test file not found: ${TEST_FILE} — skipping"
    continue
  fi

  TOTAL=$((TOTAL + 1))
  RESULT_FILE="${RESULTS_DIR}/${TEST_NAME}-${TIMESTAMP}.json"

  echo "------------------------------------------------------------"
  echo "  Running: ${TEST_NAME}"
  echo "  Output:  ${RESULT_FILE}"
  echo "------------------------------------------------------------"

  # Run k6 and capture exit code
  set +e
  k6 run \
    --out "json=${RESULT_FILE}" \
    --summary-trend-stats="avg,min,med,max,p(90),p(95),p(99)" \
    --env "BASE_URL=${BASE_URL}" \
    --env "AI_GATEWAY_URL=${AI_GATEWAY_URL}" \
    --env "TEST_USER_EMAIL=${TEST_USER_EMAIL}" \
    --env "TEST_USER_PASSWORD=${TEST_USER_PASSWORD}" \
    "${TEST_FILE}" 2>&1 | tee "${RESULTS_DIR}/${TEST_NAME}-${TIMESTAMP}.log"
  EXIT_CODE=${PIPESTATUS[0]}
  set -e

  if [[ ${EXIT_CODE} -eq 0 ]]; then
    PASSED=$((PASSED + 1))
    STATUS="PASS"
  else
    FAILED=$((FAILED + 1))
    FAILED_TESTS+=("${TEST_NAME}")
    STATUS="FAIL (exit ${EXIT_CODE})"
  fi

  echo ""
  echo "  Result: ${STATUS}"
  echo ""

  {
    echo "Test: ${TEST_NAME}"
    echo "  Status:  ${STATUS}"
    echo "  Results: ${RESULT_FILE}"
    echo ""
  } >> "${SUMMARY_FILE}"

  # Small pause between tests to let services recover
  if [[ "${TEST_NAME}" != "${ALL_TESTS[-1]}" ]]; then
    echo "  Waiting 10s before next test..."
    sleep 10
  fi
done

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

echo ""
echo "============================================================"
echo "  Load Test Summary"
echo "============================================================"
echo "  Total:   ${TOTAL}"
echo "  Passed:  ${PASSED}"
echo "  Failed:  ${FAILED}"

if [[ ${FAILED} -gt 0 ]]; then
  echo ""
  echo "  Failed tests:"
  for T in "${FAILED_TESTS[@]}"; do
    echo "    - ${T}"
  done
fi

echo ""
echo "  Results directory: ${RESULTS_DIR}"
echo "  Summary report:    ${SUMMARY_FILE}"
echo "  Finished: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
echo "============================================================"

{
  echo "============================================================"
  echo "Summary"
  echo "  Total:   ${TOTAL}"
  echo "  Passed:  ${PASSED}"
  echo "  Failed:  ${FAILED}"
  if [[ ${FAILED} -gt 0 ]]; then
    echo ""
    echo "  Failed tests:"
    for T in "${FAILED_TESTS[@]}"; do
      echo "    - ${T}"
    done
  fi
  echo ""
  echo "Finished: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
} >> "${SUMMARY_FILE}"

# Exit with failure if any test failed
if [[ ${FAILED} -gt 0 ]]; then
  exit 1
fi

exit 0
