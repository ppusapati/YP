// auth-flow.js — k6 load test for YieldPoint authentication flows.
//
// Tests: login, token refresh, get current user, and logout.
// ConnectRPC is not used for auth (plain REST endpoints), but the test
// exercises the same gateway path.
//
// Run:  k6 run tests/load/auth-flow.js

import http from "k6/http";
import { check, sleep } from "k6";
import { Rate, Trend } from "k6/metrics";
import { AUTH_URL, TEST_USER } from "./k6-config.js";

// ---------------------------------------------------------------------------
// Custom metrics
// ---------------------------------------------------------------------------

const loginDuration = new Trend("yp_login_duration", true);
const refreshDuration = new Trend("yp_refresh_duration", true);
const meDuration = new Trend("yp_me_duration", true);
const logoutDuration = new Trend("yp_logout_duration", true);
const authErrors = new Rate("yp_auth_errors");

// ---------------------------------------------------------------------------
// Options
// ---------------------------------------------------------------------------

export const options = {
  scenarios: {
    auth_flow: {
      executor: "ramping-vus",
      startVUs: 0,
      stages: [
        { duration: "2m", target: 100 }, // ramp up
        { duration: "5m", target: 100 }, // sustained load
        { duration: "1m", target: 0 },   // ramp down
      ],
      gracefulRampDown: "30s",
    },
  },
  thresholds: {
    http_req_duration: ["p(95)<500"],
    http_req_failed: ["rate<0.01"],
    yp_login_duration: ["p(95)<500", "p(99)<800"],
    yp_refresh_duration: ["p(95)<300", "p(99)<500"],
    yp_me_duration: ["p(95)<200", "p(99)<400"],
    yp_auth_errors: ["rate<0.01"],
  },
};

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const jsonHeaders = { "Content-Type": "application/json" };

function authHeaders(token) {
  return {
    "Content-Type": "application/json",
    Authorization: `Bearer ${token}`,
  };
}

// ---------------------------------------------------------------------------
// Default function — runs per VU iteration
// ---------------------------------------------------------------------------

export default function () {
  // 1. Login
  const loginRes = http.post(
    `${AUTH_URL}/login`,
    JSON.stringify({
      email: TEST_USER.email,
      password: TEST_USER.password,
    }),
    { headers: jsonHeaders, tags: { name: "POST /auth/login" } }
  );

  loginDuration.add(loginRes.timings.duration);

  const loginOk = check(loginRes, {
    "login status 200": (r) => r.status === 200,
    "login returns access_token": (r) => {
      try {
        const body = JSON.parse(r.body);
        return body.token && body.token.access_token;
      } catch (_e) {
        return false;
      }
    },
    "login returns refresh_token": (r) => {
      try {
        const body = JSON.parse(r.body);
        return body.token && body.token.refresh_token;
      } catch (_e) {
        return false;
      }
    },
  });

  if (!loginOk) {
    authErrors.add(1);
    sleep(1);
    return;
  }
  authErrors.add(0);

  const loginBody = JSON.parse(loginRes.body);
  let accessToken = loginBody.token.access_token;
  const refreshToken = loginBody.token.refresh_token;

  sleep(0.5);

  // 2. Get current user (/auth/me)
  const meRes = http.get(`${AUTH_URL}/me`, {
    headers: authHeaders(accessToken),
    tags: { name: "GET /auth/me" },
  });

  meDuration.add(meRes.timings.duration);

  check(meRes, {
    "me status 200": (r) => r.status === 200,
    "me returns user id": (r) => {
      try {
        const body = JSON.parse(r.body);
        return !!body.id;
      } catch (_e) {
        return false;
      }
    },
  });

  sleep(0.5);

  // 3. Refresh token
  const refreshRes = http.post(
    `${AUTH_URL}/refresh`,
    JSON.stringify({ refresh_token: refreshToken }),
    { headers: jsonHeaders, tags: { name: "POST /auth/refresh" } }
  );

  refreshDuration.add(refreshRes.timings.duration);

  const refreshOk = check(refreshRes, {
    "refresh status 200": (r) => r.status === 200,
    "refresh returns new access_token": (r) => {
      try {
        const body = JSON.parse(r.body);
        return body.token && body.token.access_token;
      } catch (_e) {
        return false;
      }
    },
  });

  if (refreshOk) {
    const refreshBody = JSON.parse(refreshRes.body);
    accessToken = refreshBody.token.access_token;
  }

  sleep(0.5);

  // 4. Verify new token works
  const meRes2 = http.get(`${AUTH_URL}/me`, {
    headers: authHeaders(accessToken),
    tags: { name: "GET /auth/me (after refresh)" },
  });

  check(meRes2, {
    "me after refresh status 200": (r) => r.status === 200,
  });

  sleep(0.5);

  // 5. Logout
  const logoutRes = http.post(
    `${AUTH_URL}/logout`,
    null,
    {
      headers: authHeaders(accessToken),
      tags: { name: "POST /auth/logout" },
    }
  );

  logoutDuration.add(logoutRes.timings.duration);

  check(logoutRes, {
    "logout status 200": (r) => r.status === 200,
  });

  sleep(1);
}
