"""Tests for the Python client, driven against a real HTTP server.

A stdlib server rather than mocked transport, because the things worth testing
here — that a 401 triggers exactly one refresh, that pagination terminates, that
the reason arrives from a header — are about what goes over the wire.
"""

import json
import threading
import time
import unittest
from http.server import BaseHTTPRequestHandler, HTTPServer

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from samavaya import ApiError, AuthError, Client, RateLimited  # noqa: E402


class Handler(BaseHTTPRequestHandler):
    """Serves whatever the current test told it to."""

    routes = {}
    calls = []

    def log_message(self, *args):  # keep the test output readable
        pass

    def do_POST(self):
        length = int(self.headers.get("Content-Length") or 0)
        raw = self.rfile.read(length) if length else b"{}"
        body = json.loads(raw or b"{}")
        Handler.calls.append({
            "path": self.path,
            "body": body,
            "auth": self.headers.get("Authorization"),
            "tenant": self.headers.get("X-Tenant-ID"),
        })

        route = Handler.routes.get(self.path)
        if route is None:
            self._send(404, {"code": "not_found", "message": "no route"})
            return

        status, payload, headers = route(body) if callable(route) else route
        self._send(status, payload, headers)

    def _send(self, status, payload, headers=None):
        raw = json.dumps(payload).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(raw)))
        for k, v in (headers or {}).items():
            self.send_header(k, v)
        self.end_headers()
        self.wfile.write(raw)


class ClientTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.server = HTTPServer(("127.0.0.1", 0), Handler)
        cls.base = f"http://127.0.0.1:{cls.server.server_port}"
        cls.thread = threading.Thread(target=cls.server.serve_forever, daemon=True)
        cls.thread.start()

    @classmethod
    def tearDownClass(cls):
        cls.server.shutdown()

    def setUp(self):
        Handler.routes = {}
        Handler.calls = []

    def route(self, path, status=200, payload=None, headers=None):
        Handler.routes[path] = (status, payload or {}, headers or {})

    # -- auth ---------------------------------------------------------------

    def test_login_stores_token_and_tenant(self):
        self.route("/auth/login", 200, {
            "token": {"access_token": "tok-1", "refresh_token": "ref-1",
                      "expires_at": int(time.time()) + 3600},
            "user": {"id": "u-1", "tenant_id": "t-1", "email": "a@b.c"},
        })
        self.route("/x.Svc/M", 200, {"ok": True})

        api = Client(self.base)
        user = api.login("a@b.c", "pw")
        self.assertEqual(user["tenant_id"], "t-1")

        api.call("x.Svc", "M")
        call = Handler.calls[-1]
        self.assertEqual(call["auth"], "Bearer tok-1")
        # The tenant is picked up from the login response so the caller does
        # not have to thread it through separately.
        self.assertEqual(call["tenant"], "t-1")

    def test_expiring_token_is_refreshed_before_use(self):
        # A token that expires while the request is in flight fails after the
        # server has already done the work, so the client refreshes early.
        self.route("/auth/login", 200, {
            "token": {"access_token": "tok-old", "refresh_token": "ref-1",
                      "expires_at": int(time.time()) + 10},  # inside the margin
            "user": {"id": "u-1", "tenant_id": "t-1"},
        })
        self.route("/auth/refresh", 200, {
            "token": {"access_token": "tok-new", "refresh_token": "ref-2",
                      "expires_at": int(time.time()) + 3600},
        })
        self.route("/x.Svc/M", 200, {"ok": True})

        api = Client(self.base)
        api.login("a@b.c", "pw")
        api.call("x.Svc", "M")
        self.assertEqual(Handler.calls[-1]["auth"], "Bearer tok-new")

    def test_a_401_triggers_exactly_one_refresh(self):
        state = {"calls": 0}

        def rpc(_body):
            state["calls"] += 1
            if state["calls"] == 1:
                return 401, {"code": "unauthenticated", "message": "expired"}, {}
            return 200, {"ok": True}, {}

        self.route("/auth/login", 200, {
            "token": {"access_token": "tok-1", "refresh_token": "ref-1",
                      "expires_at": int(time.time()) + 3600},
            "user": {"tenant_id": "t-1"},
        })
        self.route("/auth/refresh", 200, {
            "token": {"access_token": "tok-2", "expires_at": int(time.time()) + 3600},
        })
        Handler.routes["/x.Svc/M"] = rpc

        api = Client(self.base)
        api.login("a@b.c", "pw")
        self.assertEqual(api.call("x.Svc", "M"), {"ok": True})
        self.assertEqual(state["calls"], 2, "should retry once after refreshing")

    def test_failed_refresh_reports_the_auth_error(self):
        # Retrying a refresh that the server has rejected only produces the
        # same answer; the caller has to log in again and should be told.
        self.route("/auth/login", 200, {
            "token": {"access_token": "tok-1", "refresh_token": "ref-1",
                      "expires_at": int(time.time()) + 3600},
            "user": {"tenant_id": "t-1"},
        })
        self.route("/auth/refresh", 401, {"code": "unauthenticated", "message": "revoked"})
        self.route("/x.Svc/M", 401, {"code": "unauthenticated", "message": "expired"})

        api = Client(self.base)
        api.login("a@b.c", "pw")
        with self.assertRaises(AuthError):
            api.call("x.Svc", "M")

    # -- errors -------------------------------------------------------------

    def test_reason_is_read_from_the_header(self):
        # The platform mirrors the reason into x-error-reason for clients that
        # cannot decode the structured detail. Branching on it is the point:
        # the code says a thing was missing, the reason says what.
        self.route("/x.Svc/M", 404,
                   {"code": "not_found", "message": "farm not found"},
                   {"x-error-reason": "FARM_NOT_FOUND"})

        api = Client(self.base, token="t")
        with self.assertRaises(ApiError) as caught:
            api.call("x.Svc", "M")
        self.assertEqual(caught.exception.reason, "FARM_NOT_FOUND")
        self.assertEqual(caught.exception.code, "not_found")
        self.assertFalse(caught.exception.retryable)

    def test_reason_falls_back_to_the_structured_detail(self):
        self.route("/x.Svc/M", 409, {
            "code": "aborted", "message": "taken",
            "details": [{"type": "google.rpc.ErrorInfo", "reason": "FARM_NAME_EXISTS"}],
        })
        api = Client(self.base, token="t")
        with self.assertRaises(ApiError) as caught:
            api.call("x.Svc", "M")
        self.assertEqual(caught.exception.reason, "FARM_NAME_EXISTS")

    def test_a_client_error_is_not_retried(self):
        state = {"calls": 0}

        def rpc(_body):
            state["calls"] += 1
            return 400, {"code": "invalid_argument", "message": "field_id required"}, {}

        Handler.routes["/x.Svc/M"] = rpc
        api = Client(self.base, token="t", retries=3)
        with self.assertRaises(ApiError):
            api.call("x.Svc", "M")
        # Repeating a bad request only produces the same answer more slowly.
        self.assertEqual(state["calls"], 1)

    def test_a_transient_failure_is_retried(self):
        state = {"calls": 0}

        def rpc(_body):
            state["calls"] += 1
            if state["calls"] < 3:
                return 503, {"code": "unavailable", "message": "restarting"}, {}
            return 200, {"ok": True}, {}

        Handler.routes["/x.Svc/M"] = rpc
        api = Client(self.base, token="t", retries=4)
        self.assertEqual(api.call("x.Svc", "M"), {"ok": True})
        self.assertEqual(state["calls"], 3)

    def test_rate_limit_carries_retry_after(self):
        self.route("/x.Svc/M", 429,
                   {"code": "resource_exhausted", "message": "too many requests"},
                   {"retry-after": "7"})
        api = Client(self.base, token="t", retries=1)
        with self.assertRaises(RateLimited) as caught:
            api.call("x.Svc", "M")
        self.assertEqual(caught.exception.retry_after, 7.0)

    # -- pagination ---------------------------------------------------------

    def test_token_pagination(self):
        pages = {
            None: (["a", "b"], "2"),
            "2": (["c", "d"], "4"),
            "4": (["e"], ""),
        }

        def rpc(body):
            items, token = pages[body.get("page_token")]
            return 200, {"farms": [{"name": n} for n in items],
                         "next_page_token": token, "total_count": 5}, {}

        Handler.routes["/x.Svc/ListFarms"] = rpc
        api = Client(self.base, token="t")
        names = [f["name"] for f in api.paginate("x.Svc", "ListFarms", {"page_size": 2}, "farms")]
        self.assertEqual(names, ["a", "b", "c", "d", "e"])

    def test_offset_pagination_stops_at_the_total(self):
        def rpc(body):
            offset = body.get("page_offset", 0)
            rows = [{"name": f"f{offset + i}"} for i in range(2)][: max(0, 5 - offset)]
            return 200, {"farms": rows, "total_count": 5}, {}

        Handler.routes["/x.Svc/ListFarms"] = rpc
        api = Client(self.base, token="t")
        names = [f["name"] for f in api.paginate("x.Svc", "ListFarms", {"page_size": 2}, "farms")]
        self.assertEqual(names, ["f0", "f1", "f2", "f3", "f4"])

    def test_a_repeating_token_does_not_loop_forever(self):
        # This was a real bug in several services: the next token was computed
        # from the requested page size, which a client omitting page_size left
        # at zero, so the token was the offset just read. A client that trusts
        # the server here spins until it is killed.
        def rpc(_body):
            return 200, {"farms": [{"name": "a"}], "next_page_token": "0",
                         "total_count": 100}, {}

        Handler.routes["/x.Svc/ListFarms"] = rpc
        api = Client(self.base, token="t")
        names = [f["name"] for f in api.paginate("x.Svc", "ListFarms", {}, "farms")]
        self.assertEqual(names, ["a"], "the loop should stop when a token repeats")

    def test_an_empty_page_ends_pagination(self):
        def rpc(_body):
            return 200, {"farms": [], "total_count": 100}, {}

        Handler.routes["/x.Svc/ListFarms"] = rpc
        api = Client(self.base, token="t")
        self.assertEqual(list(api.paginate("x.Svc", "ListFarms", {}, "farms")), [])


if __name__ == "__main__":
    unittest.main()
