// satellite-upload.js — k6 load test for YieldPoint satellite operations.
//
// Tests: satellite image ingestion request, processing job submission,
// processing status polling, and tile retrieval.
//
// Satellite operations are heavy, so we use only 10 VUs. The test covers the
// full pipeline: request ingestion -> submit processing -> poll status -> get tile.
//
// Run:  k6 run tests/load/satellite-upload.js

import http from "k6/http";
import { check, sleep, group } from "k6";
import { Rate, Trend } from "k6/metrics";
import {
  BASE_URL,
  authenticate,
  authedHeaders,
  TEST_USER,
  parseConnectResponse,
  uniqueName,
} from "./k6-config.js";

// ---------------------------------------------------------------------------
// Custom metrics
// ---------------------------------------------------------------------------

const ingestionRequestDuration = new Trend("yp_satellite_ingestion_request_duration", true);
const processingSubmitDuration = new Trend("yp_satellite_processing_submit_duration", true);
const processingPollDuration = new Trend("yp_satellite_processing_poll_duration", true);
const tileListDuration = new Trend("yp_tile_list_duration", true);
const tileRetrievalDuration = new Trend("yp_tile_retrieval_duration", true);
const satelliteErrors = new Rate("yp_satellite_errors");

// ---------------------------------------------------------------------------
// Service paths (ConnectRPC)
// ---------------------------------------------------------------------------

const INGESTION_SVC = "agriculture.satellite.ingestion.v1.SatelliteIngestionService";
const PROCESSING_SVC = "agriculture.satellite.processing.v1.SatelliteProcessingService";
const TILE_SVC = "agriculture.satellite.tile.v1.SatelliteTileService";

// ---------------------------------------------------------------------------
// Options
// ---------------------------------------------------------------------------

export const options = {
  scenarios: {
    satellite_pipeline: {
      executor: "constant-vus",
      vus: 10,
      duration: "5m",
    },
  },
  thresholds: {
    // Upload/ingestion request
    yp_satellite_ingestion_request_duration: ["p(95)<10000"],
    // Processing job submission
    yp_satellite_processing_submit_duration: ["p(95)<5000"],
    // Status polling
    yp_satellite_processing_poll_duration: ["p(95)<2000"],
    // Tile operations
    yp_tile_list_duration: ["p(95)<3000"],
    yp_tile_retrieval_duration: ["p(95)<5000"],
    // Overall
    http_req_failed: ["rate<0.01"],
    yp_satellite_errors: ["rate<0.01"],
  },
};

// ---------------------------------------------------------------------------
// Setup — authenticate
// ---------------------------------------------------------------------------

export function setup() {
  const auth = authenticate(TEST_USER.email, TEST_USER.password);
  if (!auth) {
    throw new Error("Setup authentication failed — cannot proceed with test");
  }

  // Use a well-known farm ID seeded in the test environment.
  const farmId = __ENV.TEST_FARM_ID || "loadtest-farm-satellite";

  return {
    token: auth.accessToken,
    farmId,
  };
}

// ---------------------------------------------------------------------------
// Default function — runs per VU iteration
// ---------------------------------------------------------------------------

export default function (data) {
  const headers = authedHeaders(data.token);

  // ---- Step 1: Request Satellite Ingestion --------------------------------
  let ingestionTaskId = null;

  group("Request Ingestion", () => {
    const now = new Date();
    const oneWeekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);

    const res = http.post(
      `${BASE_URL}/${INGESTION_SVC}/RequestIngestion`,
      JSON.stringify({
        farm_id: data.farmId,
        provider: 1, // SATELLITE_PROVIDER_SENTINEL2
        date_from: oneWeekAgo.toISOString(),
        date_to: now.toISOString(),
        max_cloud_cover: 20.0,
        bands: [1, 2, 3, 4], // BLUE, GREEN, RED, NIR
      }),
      { headers, tags: { name: "ConnectRPC RequestIngestion" } }
    );

    ingestionRequestDuration.add(res.timings.duration);

    const ok = check(res, {
      "RequestIngestion status 200": (r) => r.status === 200,
      "RequestIngestion returns task.id": (r) => {
        const body = parseConnectResponse(r);
        return body && body.task && body.task.id;
      },
    });

    if (ok) {
      satelliteErrors.add(0);
      const body = parseConnectResponse(res);
      ingestionTaskId = body.task.id;
    } else {
      satelliteErrors.add(1);
    }
  });

  if (!ingestionTaskId) {
    sleep(2);
    return;
  }

  sleep(1);

  // ---- Step 2: Poll Ingestion Status ------------------------------------
  group("Poll Ingestion Status", () => {
    const res = http.post(
      `${BASE_URL}/${INGESTION_SVC}/GetIngestionTask`,
      JSON.stringify({ id: ingestionTaskId }),
      { headers, tags: { name: "ConnectRPC GetIngestionTask" } }
    );

    processingPollDuration.add(res.timings.duration);

    check(res, {
      "GetIngestionTask status 200": (r) => r.status === 200,
      "GetIngestionTask returns task": (r) => {
        const body = parseConnectResponse(r);
        return body && body.task;
      },
    });
  });

  sleep(1);

  // ---- Step 3: Submit Processing Job ------------------------------------
  let processingJobId = null;

  group("Submit Processing Job", () => {
    const res = http.post(
      `${BASE_URL}/${PROCESSING_SVC}/SubmitProcessingJob`,
      JSON.stringify({
        ingestion_task_id: ingestionTaskId,
        farm_id: data.farmId,
        output_level: 2, // PROCESSING_LEVEL_L2A (surface reflectance)
        algorithm: 1,    // CORRECTION_ALGORITHM_SEN2COR
        cloud_mask_threshold: 0.3,
        apply_atmospheric_correction: true,
        apply_cloud_masking: true,
        apply_orthorectification: false,
        output_resolution_meters: 10,
        output_crs: "EPSG:4326",
      }),
      { headers, tags: { name: "ConnectRPC SubmitProcessingJob" } }
    );

    processingSubmitDuration.add(res.timings.duration);

    const ok = check(res, {
      "SubmitProcessingJob status 200": (r) => r.status === 200,
      "SubmitProcessingJob returns job.id": (r) => {
        const body = parseConnectResponse(r);
        return body && body.job && body.job.id;
      },
    });

    if (ok) {
      const body = parseConnectResponse(res);
      processingJobId = body.job.id;
    }
  });

  sleep(1);

  // ---- Step 4: Poll Processing Status -----------------------------------
  if (processingJobId) {
    group("Poll Processing Status", () => {
      // Poll up to 5 times with 2-second intervals
      for (let attempt = 0; attempt < 5; attempt++) {
        const res = http.post(
          `${BASE_URL}/${PROCESSING_SVC}/GetProcessingJob`,
          JSON.stringify({ id: processingJobId }),
          { headers, tags: { name: "ConnectRPC GetProcessingJob" } }
        );

        processingPollDuration.add(res.timings.duration);

        const body = parseConnectResponse(res);
        const ok = check(res, {
          "GetProcessingJob status 200": (r) => r.status === 200,
        });

        // If completed or failed, stop polling
        if (body && body.job) {
          const status = body.job.status;
          // 7 = COMPLETED, 8 = FAILED
          if (status === 7 || status === 8) {
            break;
          }
        }

        sleep(2);
      }
    });
  }

  sleep(1);

  // ---- Step 5: List Tilesets --------------------------------------------
  group("List Tilesets", () => {
    const res = http.post(
      `${BASE_URL}/${TILE_SVC}/ListTilesets`,
      JSON.stringify({
        farm_id: data.farmId,
        page_size: 10,
      }),
      { headers, tags: { name: "ConnectRPC ListTilesets" } }
    );

    tileListDuration.add(res.timings.duration);

    check(res, {
      "ListTilesets status 200": (r) => r.status === 200,
    });
  });

  sleep(1);

  // ---- Step 6: Retrieve a Tile (simulated with known tileset) -----------
  group("Get Tile", () => {
    // Try to get a tile from a well-known tileset (seeded in test env)
    const tilesetId = __ENV.TEST_TILESET_ID || "loadtest-tileset-001";

    const res = http.post(
      `${BASE_URL}/${TILE_SVC}/GetTile`,
      JSON.stringify({
        tileset_id: tilesetId,
        z: 14,
        x: 12345,
        y: 6789,
      }),
      { headers, tags: { name: "ConnectRPC GetTile" } }
    );

    tileRetrievalDuration.add(res.timings.duration);

    // Tile retrieval may return 404 if the test tileset does not exist —
    // that is expected in environments without pre-seeded data.
    check(res, {
      "GetTile status 200 or 404": (r) => r.status === 200 || r.status === 404,
    });
  });

  sleep(2);
}
