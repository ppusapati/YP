// farm-crud.js — k6 load test for YieldPoint farm and field CRUD operations.
//
// Tests: create farm, list farms, update farm, create field, list fields.
// All endpoints use ConnectRPC (HTTP POST with JSON body).
//
// Run:  k6 run tests/load/farm-crud.js

import http from "k6/http";
import { check, sleep, group } from "k6";
import { Rate, Trend } from "k6/metrics";
import {
  BASE_URL,
  authenticate,
  authedHeaders,
  TEST_USER,
  uniqueName,
  parseConnectResponse,
} from "./k6-config.js";

// ---------------------------------------------------------------------------
// Custom metrics
// ---------------------------------------------------------------------------

const createFarmDuration = new Trend("yp_create_farm_duration", true);
const listFarmsDuration = new Trend("yp_list_farms_duration", true);
const getFarmDuration = new Trend("yp_get_farm_duration", true);
const updateFarmDuration = new Trend("yp_update_farm_duration", true);
const createFieldDuration = new Trend("yp_create_field_duration", true);
const listFieldsDuration = new Trend("yp_list_fields_duration", true);
const crudErrors = new Rate("yp_crud_errors");

// ---------------------------------------------------------------------------
// Service paths (ConnectRPC)
// ---------------------------------------------------------------------------

const FARM_SVC = "agriculture.farm.v1.FarmService";
const FIELD_SVC = "agriculture.field.v1.FieldService";

// ---------------------------------------------------------------------------
// Options
// ---------------------------------------------------------------------------

export const options = {
  scenarios: {
    farm_crud: {
      executor: "constant-vus",
      vus: 50,
      duration: "5m",
    },
  },
  thresholds: {
    http_req_duration: ["p(95)<1000"],
    http_req_failed: ["rate<0.01"],
    yp_create_farm_duration: ["p(95)<1000", "p(99)<2000"],
    yp_list_farms_duration: ["p(95)<500", "p(99)<1000"],
    yp_get_farm_duration: ["p(95)<500", "p(99)<1000"],
    yp_update_farm_duration: ["p(95)<1000", "p(99)<2000"],
    yp_create_field_duration: ["p(95)<1000", "p(99)<2000"],
    yp_list_fields_duration: ["p(95)<500", "p(99)<1000"],
    yp_crud_errors: ["rate<0.01"],
  },
};

// ---------------------------------------------------------------------------
// Setup — authenticate once and share the token across VUs
// ---------------------------------------------------------------------------

export function setup() {
  const auth = authenticate(TEST_USER.email, TEST_USER.password);
  if (!auth) {
    throw new Error("Setup authentication failed — cannot proceed with test");
  }
  return { token: auth.accessToken };
}

// ---------------------------------------------------------------------------
// Default function — runs per VU iteration
// ---------------------------------------------------------------------------

export default function (data) {
  const headers = authedHeaders(data.token);

  // ---- Create Farm -------------------------------------------------------
  let farmId = null;

  group("Create Farm", () => {
    const farmName = uniqueName("loadtest-farm");
    const res = http.post(
      `${BASE_URL}/${FARM_SVC}/CreateFarm`,
      JSON.stringify({
        name: farmName,
        description: "Load test farm",
        total_area_hectares: 150.5,
        location: {
          latitude: 17.385,
          longitude: 78.4867,
          elevation_meters: 542,
        },
        farm_type: 1, // FARM_TYPE_CROP
        soil_type: 3,  // SOIL_TYPE_LOAMY
        climate_zone: 1, // CLIMATE_ZONE_TROPICAL
        elevation_meters: 542,
        address: "Load Test Road, Hyderabad",
        region: "Telangana",
        country: "IN",
      }),
      { headers, tags: { name: "ConnectRPC CreateFarm" } }
    );

    createFarmDuration.add(res.timings.duration);

    const ok = check(res, {
      "CreateFarm status 200": (r) => r.status === 200,
      "CreateFarm returns farm.id": (r) => {
        const body = parseConnectResponse(r);
        return body && body.farm && body.farm.id;
      },
    });

    if (ok) {
      crudErrors.add(0);
      const body = parseConnectResponse(res);
      farmId = body.farm.id;
    } else {
      crudErrors.add(1);
    }
  });

  if (!farmId) {
    sleep(1);
    return;
  }

  sleep(0.3);

  // ---- List Farms --------------------------------------------------------
  group("List Farms", () => {
    const res = http.post(
      `${BASE_URL}/${FARM_SVC}/ListFarms`,
      JSON.stringify({ page_size: 20 }),
      { headers, tags: { name: "ConnectRPC ListFarms" } }
    );

    listFarmsDuration.add(res.timings.duration);

    check(res, {
      "ListFarms status 200": (r) => r.status === 200,
      "ListFarms returns farms array": (r) => {
        const body = parseConnectResponse(r);
        return body && Array.isArray(body.farms);
      },
    });
  });

  sleep(0.3);

  // ---- Get Farm ----------------------------------------------------------
  group("Get Farm", () => {
    const res = http.post(
      `${BASE_URL}/${FARM_SVC}/GetFarm`,
      JSON.stringify({ id: farmId }),
      { headers, tags: { name: "ConnectRPC GetFarm" } }
    );

    getFarmDuration.add(res.timings.duration);

    check(res, {
      "GetFarm status 200": (r) => r.status === 200,
      "GetFarm returns correct farm": (r) => {
        const body = parseConnectResponse(r);
        return body && body.farm && body.farm.id === farmId;
      },
    });
  });

  sleep(0.3);

  // ---- Update Farm -------------------------------------------------------
  group("Update Farm", () => {
    const res = http.post(
      `${BASE_URL}/${FARM_SVC}/UpdateFarm`,
      JSON.stringify({
        id: farmId,
        description: `Updated by load test at ${new Date().toISOString()}`,
        total_area_hectares: 155.0,
      }),
      { headers, tags: { name: "ConnectRPC UpdateFarm" } }
    );

    updateFarmDuration.add(res.timings.duration);

    check(res, {
      "UpdateFarm status 200": (r) => r.status === 200,
    });
  });

  sleep(0.3);

  // ---- Create Field ------------------------------------------------------
  let fieldId = null;

  group("Create Field", () => {
    const fieldName = uniqueName("loadtest-field");
    const res = http.post(
      `${BASE_URL}/${FIELD_SVC}/CreateField`,
      JSON.stringify({
        farm_id: farmId,
        name: fieldName,
        area_hectares: 25.0,
        boundary: {
          points: [
            { longitude: 78.48, latitude: 17.38 },
            { longitude: 78.49, latitude: 17.38 },
            { longitude: 78.49, latitude: 17.39 },
            { longitude: 78.48, latitude: 17.39 },
            { longitude: 78.48, latitude: 17.38 },
          ],
        },
        field_type: 1, // FIELD_TYPE_CROPLAND
        soil_type: 3,  // SOIL_TYPE_LOAMY
        irrigation_type: 2, // IRRIGATION_TYPE_DRIP
        elevation_meters: 540,
        slope_degrees: 2.5,
        aspect_direction: 5, // ASPECT_DIRECTION_SOUTH
      }),
      { headers, tags: { name: "ConnectRPC CreateField" } }
    );

    createFieldDuration.add(res.timings.duration);

    const ok = check(res, {
      "CreateField status 200": (r) => r.status === 200,
      "CreateField returns field.id": (r) => {
        const body = parseConnectResponse(r);
        return body && body.field && body.field.id;
      },
    });

    if (ok) {
      const body = parseConnectResponse(res);
      fieldId = body.field.id;
    }
  });

  sleep(0.3);

  // ---- List Fields -------------------------------------------------------
  group("List Fields", () => {
    const res = http.post(
      `${BASE_URL}/${FIELD_SVC}/ListFields`,
      JSON.stringify({
        farm_id: farmId,
        page_size: 20,
      }),
      { headers, tags: { name: "ConnectRPC ListFields" } }
    );

    listFieldsDuration.add(res.timings.duration);

    check(res, {
      "ListFields status 200": (r) => r.status === 200,
      "ListFields returns fields array": (r) => {
        const body = parseConnectResponse(r);
        return body && Array.isArray(body.fields);
      },
    });
  });

  sleep(0.3);

  // ---- Cleanup: Delete Farm (cascades fields) ----------------------------
  group("Delete Farm", () => {
    const res = http.post(
      `${BASE_URL}/${FARM_SVC}/DeleteFarm`,
      JSON.stringify({ id: farmId }),
      { headers, tags: { name: "ConnectRPC DeleteFarm" } }
    );

    check(res, {
      "DeleteFarm status 200": (r) => r.status === 200,
    });
  });

  sleep(1);
}
