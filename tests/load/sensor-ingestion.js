// sensor-ingestion.js — k6 load test for YieldPoint sensor data ingestion.
//
// Simulates 500 IoT sensors sending readings every 30 seconds.
// Tests both single-reading ingestion and batch ingestion, plus burst handling
// (all sensors reporting simultaneously).
//
// Run:  k6 run tests/load/sensor-ingestion.js

import http from "k6/http";
import { check, sleep, group } from "k6";
import { Rate, Trend, Counter } from "k6/metrics";
import {
  BASE_URL,
  authenticate,
  authedHeaders,
  TEST_USER,
  parseConnectResponse,
} from "./k6-config.js";

// ---------------------------------------------------------------------------
// Custom metrics
// ---------------------------------------------------------------------------

const ingestReadingDuration = new Trend("yp_ingest_reading_duration", true);
const batchIngestDuration = new Trend("yp_batch_ingest_duration", true);
const sensorErrors = new Rate("yp_sensor_errors");
const readingsIngested = new Counter("yp_readings_ingested");

// ---------------------------------------------------------------------------
// Service path (ConnectRPC)
// ---------------------------------------------------------------------------

const SENSOR_SVC = "agriculture.sensor.v1.SensorService";

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------

const TOTAL_SENSORS = 500;
const BATCH_SIZE = 50; // readings per batch call
const SENSORS_PER_VU = 5; // each VU simulates 5 sensors

// Sensor type enum values
const SENSOR_TYPES = [1, 2, 3, 4, 5, 6, 7, 8, 9]; // SOIL_MOISTURE through LEAF_WETNESS

// Units per sensor type
const SENSOR_UNITS = {
  1: "%",     // soil moisture
  2: "pH",    // soil pH
  3: "C",     // temperature (Celsius)
  4: "%",     // humidity
  5: "mm",    // rainfall
  6: "m/s",   // wind speed
  7: "deg",   // wind direction
  8: "lux",   // light intensity
  9: "%",     // leaf wetness
};

// ---------------------------------------------------------------------------
// Options
// ---------------------------------------------------------------------------

// 100 VUs x 5 sensors each = 500 simulated sensors
export const options = {
  scenarios: {
    // Steady-state: sensors reporting at regular intervals
    steady_ingestion: {
      executor: "constant-vus",
      vus: 100,
      duration: "5m",
      exec: "steadyIngestion",
    },
    // Burst: all sensors report at once (tests queue/throughput limits)
    burst_ingestion: {
      executor: "per-vu-iterations",
      vus: 100,
      iterations: 3,
      startTime: "5m30s", // starts after steady-state
      exec: "burstIngestion",
    },
  },
  thresholds: {
    http_req_duration: ["p(95)<2000"],
    http_req_failed: ["rate<0.005"],
    yp_ingest_reading_duration: ["p(95)<2000", "p(99)<3000"],
    yp_batch_ingest_duration: ["p(95)<3000", "p(99)<5000"],
    yp_sensor_errors: ["rate<0.005"],
  },
};

// ---------------------------------------------------------------------------
// Setup — authenticate and prepare sensor IDs
// ---------------------------------------------------------------------------

export function setup() {
  const auth = authenticate(TEST_USER.email, TEST_USER.password);
  if (!auth) {
    throw new Error("Setup authentication failed — cannot proceed with test");
  }

  // Generate deterministic sensor IDs for the test.
  // In a real environment these would come from the sensor registry.
  const sensorIds = [];
  for (let i = 0; i < TOTAL_SENSORS; i++) {
    sensorIds.push(`loadtest-sensor-${String(i).padStart(4, "0")}`);
  }

  return {
    token: auth.accessToken,
    sensorIds,
  };
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

// Generate a realistic sensor reading value based on sensor type.
function generateReading(sensorType) {
  switch (sensorType) {
    case 1: return 20 + Math.random() * 60;           // soil moisture: 20-80%
    case 2: return 5.5 + Math.random() * 3;            // soil pH: 5.5-8.5
    case 3: return 15 + Math.random() * 25;            // temperature: 15-40 C
    case 4: return 30 + Math.random() * 60;            // humidity: 30-90%
    case 5: return Math.random() * 50;                 // rainfall: 0-50mm
    case 6: return Math.random() * 15;                 // wind speed: 0-15 m/s
    case 7: return Math.random() * 360;                // wind direction: 0-360 deg
    case 8: return 100 + Math.random() * 99900;        // light: 100-100000 lux
    case 9: return Math.random() * 100;                // leaf wetness: 0-100%
    default: return Math.random() * 100;
  }
}

function buildReadingPayload(sensorId, sensorType) {
  const unit = SENSOR_UNITS[sensorType] || "%";
  return {
    sensor_id: sensorId,
    value: generateReading(sensorType),
    unit: unit,
    timestamp: new Date().toISOString(),
    quality: 1, // READING_QUALITY_GOOD
    battery_level_pct: 70 + Math.random() * 30,
    signal_strength_dbm: -90 + Math.random() * 50,
  };
}

// ---------------------------------------------------------------------------
// Scenario: Steady-state ingestion
// ---------------------------------------------------------------------------

export function steadyIngestion(data) {
  const headers = authedHeaders(data.token);
  const vuId = __VU - 1;
  const startIdx = vuId * SENSORS_PER_VU;

  // Each VU sends readings for its assigned sensors
  for (let i = 0; i < SENSORS_PER_VU; i++) {
    const sensorIdx = startIdx + i;
    if (sensorIdx >= data.sensorIds.length) break;

    const sensorId = data.sensorIds[sensorIdx];
    const sensorType = SENSOR_TYPES[sensorIdx % SENSOR_TYPES.length];

    group("IngestReading", () => {
      const payload = buildReadingPayload(sensorId, sensorType);
      const res = http.post(
        `${BASE_URL}/${SENSOR_SVC}/IngestReading`,
        JSON.stringify(payload),
        { headers, tags: { name: "ConnectRPC IngestReading" } }
      );

      ingestReadingDuration.add(res.timings.duration);

      const ok = check(res, {
        "IngestReading status 200": (r) => r.status === 200,
      });

      if (ok) {
        sensorErrors.add(0);
        readingsIngested.add(1);
      } else {
        sensorErrors.add(1);
      }
    });
  }

  // Simulate the 30-second reporting interval (scaled down for test)
  // In real life sensors send every 30s; here we compress to ~3s per iteration
  sleep(3);
}

// ---------------------------------------------------------------------------
// Scenario: Burst ingestion (batch API)
// ---------------------------------------------------------------------------

export function burstIngestion(data) {
  const headers = authedHeaders(data.token);
  const vuId = __VU - 1;
  const startIdx = vuId * SENSORS_PER_VU;

  // Build a batch of readings from all sensors assigned to this VU
  const readings = [];
  for (let i = 0; i < SENSORS_PER_VU; i++) {
    const sensorIdx = startIdx + i;
    if (sensorIdx >= data.sensorIds.length) break;

    const sensorId = data.sensorIds[sensorIdx];
    const sensorType = SENSOR_TYPES[sensorIdx % SENSOR_TYPES.length];

    // Generate multiple readings per sensor to simulate burst backlog
    for (let j = 0; j < 10; j++) {
      readings.push(buildReadingPayload(sensorId, sensorType));
    }
  }

  // Send in batches of BATCH_SIZE
  for (let offset = 0; offset < readings.length; offset += BATCH_SIZE) {
    const batch = readings.slice(offset, offset + BATCH_SIZE);

    group("BatchIngestReadings", () => {
      const res = http.post(
        `${BASE_URL}/${SENSOR_SVC}/BatchIngestReadings`,
        JSON.stringify({ readings: batch }),
        { headers, tags: { name: "ConnectRPC BatchIngestReadings" } }
      );

      batchIngestDuration.add(res.timings.duration);

      const ok = check(res, {
        "BatchIngest status 200": (r) => r.status === 200,
        "BatchIngest ingested count > 0": (r) => {
          const body = parseConnectResponse(r);
          return body && body.ingested_count > 0;
        },
      });

      if (ok) {
        sensorErrors.add(0);
        const body = parseConnectResponse(res);
        readingsIngested.add(body.ingested_count || batch.length);
      } else {
        sensorErrors.add(1);
      }
    });
  }

  sleep(1);
}
