// ai-inference.js — k6 load test for YieldPoint AI gateway (gRPC).
//
// Tests: plant image diagnosis, crop recommendation, and yield prediction.
// The AI gateway is a Rust service on gRPC port 50051.
// k6 communicates with it through the API gateway's ConnectRPC proxy route
// (agriculture.ai.v1.AIGatewayService/*).
//
// Run:  k6 run tests/load/ai-inference.js

import http from "k6/http";
import { check, sleep, group } from "k6";
import { Rate, Trend } from "k6/metrics";
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

const diagnoseDuration = new Trend("yp_diagnose_duration", true);
const recommendDuration = new Trend("yp_recommend_duration", true);
const predictYieldDuration = new Trend("yp_predict_yield_duration", true);
const classifyPlantDuration = new Trend("yp_classify_plant_duration", true);
const evaluateRiskDuration = new Trend("yp_evaluate_risk_duration", true);
const inferenceErrors = new Rate("yp_inference_errors");

// ---------------------------------------------------------------------------
// Service path
// ---------------------------------------------------------------------------

const AI_SVC = "agriculture.ai.v1.AIGatewayService";

// ---------------------------------------------------------------------------
// Options
// ---------------------------------------------------------------------------

export const options = {
  scenarios: {
    ai_inference: {
      executor: "constant-vus",
      vus: 20,
      duration: "5m",
    },
  },
  thresholds: {
    http_req_duration: ["p(95)<3000"],
    http_req_failed: ["rate<0.02"],
    yp_diagnose_duration: ["p(95)<3000", "p(99)<5000"],
    yp_recommend_duration: ["p(95)<2000", "p(99)<4000"],
    yp_predict_yield_duration: ["p(95)<2000", "p(99)<4000"],
    yp_classify_plant_duration: ["p(95)<3000", "p(99)<5000"],
    yp_evaluate_risk_duration: ["p(95)<2000", "p(99)<4000"],
    yp_inference_errors: ["rate<0.02"],
  },
};

// ---------------------------------------------------------------------------
// Setup
// ---------------------------------------------------------------------------

export function setup() {
  const auth = authenticate(TEST_USER.email, TEST_USER.password);
  if (!auth) {
    throw new Error("Setup authentication failed — cannot proceed with test");
  }
  return { token: auth.accessToken };
}

// ---------------------------------------------------------------------------
// Default function — rotates through inference endpoints
// ---------------------------------------------------------------------------

export default function (data) {
  const headers = authedHeaders(data.token);

  // Each VU cycles through the different inference types
  const iteration = __ITER;
  const testType = iteration % 5;

  switch (testType) {
    case 0:
      testDiagnoseImage(headers);
      break;
    case 1:
      testRecommendCrops(headers);
      break;
    case 2:
      testPredictYield(headers);
      break;
    case 3:
      testClassifyPlant(headers);
      break;
    case 4:
      testEvaluateFieldRisk(headers);
      break;
  }

  sleep(2);
}

// ---------------------------------------------------------------------------
// Test functions
// ---------------------------------------------------------------------------

function testDiagnoseImage(headers) {
  group("DiagnoseImage", () => {
    const requestId = `diag-${__VU}-${__ITER}-${Date.now()}`;
    const res = http.post(
      `${BASE_URL}/${AI_SVC}/DiagnoseImage`,
      JSON.stringify({
        request_id: requestId,
        images: [
          {
            // Use a URL reference instead of raw bytes for load testing;
            // the AI gateway fetches the image from the URL.
            image_url: __ENV.TEST_IMAGE_URL || "https://storage.yieldpoint.dev/test/leaf-sample.jpg",
            image_type: "LEAF",
            mime_type: "image/jpeg",
          },
        ],
        plant_species_id: "tomato",
        operations: ["resize", "normalize"],
      }),
      { headers, tags: { name: "ConnectRPC DiagnoseImage" } }
    );

    diagnoseDuration.add(res.timings.duration);

    const ok = check(res, {
      "DiagnoseImage status 200": (r) => r.status === 200,
      "DiagnoseImage returns request_id": (r) => {
        const body = parseConnectResponse(r);
        return body && body.request_id === requestId;
      },
      "DiagnoseImage returns health_score": (r) => {
        const body = parseConnectResponse(r);
        return body && typeof body.overall_health_score === "number";
      },
    });

    inferenceErrors.add(ok ? 0 : 1);
  });
}

function testRecommendCrops(headers) {
  group("RecommendCrops", () => {
    const requestId = `rec-${__VU}-${__ITER}-${Date.now()}`;
    const res = http.post(
      `${BASE_URL}/${AI_SVC}/RecommendCrops`,
      JSON.stringify({
        request_id: requestId,
        soil: {
          ph: 6.5 + Math.random(),
          organic_matter_pct: 2.0 + Math.random() * 3,
          nitrogen_ppm: 20 + Math.random() * 40,
          phosphorus_ppm: 15 + Math.random() * 30,
          potassium_ppm: 100 + Math.random() * 200,
          texture: "loam",
          drainage_class: "well",
        },
        climate: {
          avg_temperature_celsius: 25 + Math.random() * 10,
          annual_rainfall_mm: 600 + Math.random() * 800,
          avg_humidity_pct: 50 + Math.random() * 30,
          frost_free_days: 250 + Math.random() * 80,
          solar_radiation_kwh: 1500 + Math.random() * 500,
          climate_zone: "tropical",
        },
        economics: {
          market_price_per_kg: 0.5 + Math.random() * 2,
          input_cost_per_hectare: 500 + Math.random() * 1500,
          labor_cost_per_hectare: 200 + Math.random() * 800,
          water_cost_per_cubic_meter: 0.01 + Math.random() * 0.1,
          organic_premium: Math.random() > 0.5,
        },
        max_recommendations: 5,
      }),
      { headers, tags: { name: "ConnectRPC RecommendCrops" } }
    );

    recommendDuration.add(res.timings.duration);

    const ok = check(res, {
      "RecommendCrops status 200": (r) => r.status === 200,
      "RecommendCrops returns recommendations": (r) => {
        const body = parseConnectResponse(r);
        return body && Array.isArray(body.recommendations) && body.recommendations.length > 0;
      },
    });

    inferenceErrors.add(ok ? 0 : 1);
  });
}

function testPredictYield(headers) {
  group("PredictYield", () => {
    const requestId = `yield-${__VU}-${__ITER}-${Date.now()}`;
    const res = http.post(
      `${BASE_URL}/${AI_SVC}/PredictYield`,
      JSON.stringify({
        request_id: requestId,
        crop_type: "wheat",
        environment: {
          temperature_celsius: 20 + Math.random() * 15,
          humidity_pct: 40 + Math.random() * 40,
          rainfall_mm: 50 + Math.random() * 200,
          solar_radiation: 15 + Math.random() * 10,
          wind_speed_kmh: 5 + Math.random() * 20,
          growing_degree_days: 1000 + Math.random() * 1500,
        },
        soil: {
          ph: 6.0 + Math.random() * 2,
          organic_matter_pct: 1.5 + Math.random() * 4,
          nitrogen_ppm: 30 + Math.random() * 50,
          phosphorus_ppm: 20 + Math.random() * 40,
          potassium_ppm: 150 + Math.random() * 200,
          moisture_pct: 25 + Math.random() * 30,
          texture: "loam",
          compaction_index: 0.2 + Math.random() * 0.5,
        },
        management: {
          irrigation_efficiency: 0.7 + Math.random() * 0.25,
          fertilizer_rate_kg_per_ha: 100 + Math.random() * 200,
          tillage_type: "conventional",
          planting_density: 200 + Math.random() * 100,
          pest_management_level: "moderate",
        },
        field_area_hectares: 10 + Math.random() * 50,
      }),
      { headers, tags: { name: "ConnectRPC PredictYield" } }
    );

    predictYieldDuration.add(res.timings.duration);

    const ok = check(res, {
      "PredictYield status 200": (r) => r.status === 200,
      "PredictYield returns prediction": (r) => {
        const body = parseConnectResponse(r);
        return body && typeof body.predicted_yield_kg_per_hectare === "number";
      },
    });

    inferenceErrors.add(ok ? 0 : 1);
  });
}

function testClassifyPlant(headers) {
  group("ClassifyPlant", () => {
    const requestId = `classify-${__VU}-${__ITER}-${Date.now()}`;
    const res = http.post(
      `${BASE_URL}/${AI_SVC}/ClassifyPlant`,
      JSON.stringify({
        request_id: requestId,
        images: [
          {
            image_url: __ENV.TEST_IMAGE_URL || "https://storage.yieldpoint.dev/test/plant-sample.jpg",
            image_type: "WHOLE_PLANT",
            mime_type: "image/jpeg",
          },
        ],
      }),
      { headers, tags: { name: "ConnectRPC ClassifyPlant" } }
    );

    classifyPlantDuration.add(res.timings.duration);

    const ok = check(res, {
      "ClassifyPlant status 200": (r) => r.status === 200,
      "ClassifyPlant returns species": (r) => {
        const body = parseConnectResponse(r);
        return body && body.species && body.species.common_name;
      },
    });

    inferenceErrors.add(ok ? 0 : 1);
  });
}

function testEvaluateFieldRisk(headers) {
  group("EvaluateFieldRisk", () => {
    const requestId = `risk-${__VU}-${__ITER}-${Date.now()}`;
    const res = http.post(
      `${BASE_URL}/${AI_SVC}/EvaluateFieldRisk`,
      JSON.stringify({
        request_id: requestId,
        field_id: "loadtest-field-001",
        farm_id: "loadtest-farm-001",
        crop_type: "rice",
        weather: {
          temperature_current: 30 + Math.random() * 10,
          temperature_min_forecast: 20 + Math.random() * 5,
          temperature_max_forecast: 35 + Math.random() * 10,
          precipitation_mm: Math.random() * 50,
          precipitation_forecast_mm: Math.random() * 100,
          et_reference_mm: 3 + Math.random() * 5,
          co2_ppm: 400 + Math.random() * 20,
        },
        soil_state: {
          soil_moisture: 0.2 + Math.random() * 0.6,
        },
        detections: {
          pest_confidence: Math.random() * 0.3,
          pest_species: "",
          disease_confidence: Math.random() * 0.2,
          disease_name: "",
          nutrient_severity: Math.random() * 0.4,
          nutrient_type: "",
        },
        growth: {
          ndvi_current: 0.4 + Math.random() * 0.4,
          ndvi_previous: 0.35 + Math.random() * 0.4,
          growth_expected: 0.5 + Math.random() * 0.3,
          growth_actual: 0.4 + Math.random() * 0.4,
        },
      }),
      { headers, tags: { name: "ConnectRPC EvaluateFieldRisk" } }
    );

    evaluateRiskDuration.add(res.timings.duration);

    const ok = check(res, {
      "EvaluateFieldRisk status 200": (r) => r.status === 200,
      "EvaluateFieldRisk returns overall_risk": (r) => {
        const body = parseConnectResponse(r);
        return body && typeof body.overall_risk === "number";
      },
    });

    inferenceErrors.add(ok ? 0 : 1);
  });
}
