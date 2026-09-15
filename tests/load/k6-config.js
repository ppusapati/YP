// k6-config.js — Shared k6 configuration for YieldPoint load tests.
//
// Provides base URL configuration, authentication helpers, ConnectRPC headers,
// custom metrics definitions, and reusable threshold presets.

import http from "k6/http";
import { Rate, Trend } from "k6/metrics";

// ---------------------------------------------------------------------------
// Environment / Base URLs
// ---------------------------------------------------------------------------

// API gateway (Caddy) fronts all ConnectRPC and REST endpoints.
export const BASE_URL = __ENV.BASE_URL || "http://localhost:8080";

// AI gateway listens on gRPC (used by ai-inference tests).
export const AI_GATEWAY_URL = __ENV.AI_GATEWAY_URL || "http://localhost:50051";

// Auth service is exposed through the gateway at /auth/*.
export const AUTH_URL = `${BASE_URL}/auth`;

// ---------------------------------------------------------------------------
// Test user credentials (seeded in the target environment)
// ---------------------------------------------------------------------------

export const TEST_USER = {
  email: __ENV.TEST_USER_EMAIL || "loadtest@yieldpoint.dev",
  password: __ENV.TEST_USER_PASSWORD || "LoadTest2026!",
};

// ---------------------------------------------------------------------------
// ConnectRPC helpers
// ---------------------------------------------------------------------------

// Standard headers for ConnectRPC unary calls (HTTP POST with JSON).
export const CONNECT_HEADERS = {
  "Content-Type": "application/json",
  "Connect-Protocol-Version": "1",
};

// Build headers with an Authorization bearer token.
export function authedHeaders(token) {
  return Object.assign({}, CONNECT_HEADERS, {
    Authorization: `Bearer ${token}`,
  });
}

// Make a ConnectRPC unary call.
// service: full protobuf service name, e.g. "agriculture.farm.v1.FarmService"
// method:  RPC method name, e.g. "CreateFarm"
// payload: request message as a JS object
// params:  optional k6 http params (headers, tags, etc.)
export function connectRPC(service, method, payload, params = {}) {
  const url = `${BASE_URL}/${service}/${method}`;
  const body = JSON.stringify(payload);
  const headers = params.headers || CONNECT_HEADERS;
  return http.post(url, body, Object.assign({}, params, { headers }));
}

// ---------------------------------------------------------------------------
// Auth helpers
// ---------------------------------------------------------------------------

// Authenticate with the auth service and return { accessToken, refreshToken }.
export function authenticate(email, password) {
  const res = http.post(
    `${AUTH_URL}/login`,
    JSON.stringify({ email, password }),
    { headers: { "Content-Type": "application/json" } }
  );

  if (res.status !== 200) {
    console.error(
      `Authentication failed: ${res.status} — ${res.body}`
    );
    return null;
  }

  const body = JSON.parse(res.body);
  return {
    accessToken: body.token.access_token,
    refreshToken: body.token.refresh_token,
    expiresAt: body.token.expires_at,
    user: body.user,
  };
}

// Refresh an access token using the refresh token.
export function refreshAccessToken(refreshToken) {
  const res = http.post(
    `${AUTH_URL}/refresh`,
    JSON.stringify({ refresh_token: refreshToken }),
    { headers: { "Content-Type": "application/json" } }
  );

  if (res.status !== 200) {
    console.error(`Token refresh failed: ${res.status} — ${res.body}`);
    return null;
  }

  const body = JSON.parse(res.body);
  return {
    accessToken: body.token.access_token,
    refreshToken: body.token.refresh_token,
    expiresAt: body.token.expires_at,
  };
}

// ---------------------------------------------------------------------------
// Custom metrics
// ---------------------------------------------------------------------------

// Shared custom metrics available to all test scripts.
export const customMetrics = {
  // Auth
  loginDuration: new Trend("yp_login_duration", true),
  refreshDuration: new Trend("yp_refresh_duration", true),
  authErrors: new Rate("yp_auth_errors"),

  // Farm CRUD
  createFarmDuration: new Trend("yp_create_farm_duration", true),
  listFarmsDuration: new Trend("yp_list_farms_duration", true),
  updateFarmDuration: new Trend("yp_update_farm_duration", true),

  // Field CRUD
  createFieldDuration: new Trend("yp_create_field_duration", true),
  listFieldsDuration: new Trend("yp_list_fields_duration", true),

  // Sensor ingestion
  ingestReadingDuration: new Trend("yp_ingest_reading_duration", true),
  batchIngestDuration: new Trend("yp_batch_ingest_duration", true),
  sensorErrors: new Rate("yp_sensor_errors"),

  // Satellite
  uploadDuration: new Trend("yp_satellite_upload_duration", true),
  processingDuration: new Trend("yp_satellite_processing_duration", true),
  tileRetrievalDuration: new Trend("yp_tile_retrieval_duration", true),

  // AI inference
  diagnoseDuration: new Trend("yp_diagnose_duration", true),
  recommendDuration: new Trend("yp_recommend_duration", true),
  inferenceErrors: new Rate("yp_inference_errors"),
};

// ---------------------------------------------------------------------------
// Threshold presets
// ---------------------------------------------------------------------------

// Reusable threshold definitions per endpoint category.
export const thresholdPresets = {
  auth: {
    http_req_duration: ["p(95)<500"],
    http_req_failed: ["rate<0.01"],
  },
  crud: {
    http_req_duration: ["p(95)<1000"],
    http_req_failed: ["rate<0.01"],
  },
  sensor: {
    http_req_duration: ["p(95)<2000"],
    http_req_failed: ["rate<0.005"],
  },
  satellite: {
    http_req_duration: ["p(95)<10000"],
    http_req_failed: ["rate<0.01"],
  },
  inference: {
    http_req_duration: ["p(95)<3000"],
    http_req_failed: ["rate<0.02"],
  },
};

// ---------------------------------------------------------------------------
// Utility helpers
// ---------------------------------------------------------------------------

// Generate a unique name with a timestamp suffix to avoid collisions.
export function uniqueName(prefix) {
  const ts = Date.now();
  const rand = Math.floor(Math.random() * 10000);
  return `${prefix}-${ts}-${rand}`;
}

// Parse a ConnectRPC JSON response, returning the decoded body or null on error.
export function parseConnectResponse(res) {
  if (res.status !== 200) {
    return null;
  }
  try {
    return JSON.parse(res.body);
  } catch (_e) {
    return null;
  }
}
