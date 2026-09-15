"""A Python client for the YieldPoint agriculture platform.

There is deliberately no code generation here, and the reason is worth stating
because it is the opposite of what the Go and TypeScript clients do.

ConnectRPC over JSON is an ordinary HTTP API: every call is
``POST /<proto package>.<Service>/<Method>`` with a JSON body. Generated
Python message classes would add a build step, a freshness gate, and a few
thousand checked-in files, and would buy nothing that a dict does not already
give a Python caller. Go and TypeScript generate because their compilers can
check the result; Python's cannot, so the cost is all cost.

What is worth having in a client, and is here, is the part that is easy to get
wrong: the auth handshake and refresh, tenant headers, retry with backoff on
the failures that are actually transient, paging that terminates, and errors
that carry the platform's ``reason`` rather than a status code alone.

    from samavaya import Client

    api = Client("http://localhost:8080")
    api.login("agronomist@example.com", "…")

    for farm in api.paginate("agriculture.farm.v1.FarmService", "ListFarms",
                             {"page_size": 50}, "farms"):
        print(farm["name"])

Requires ``httpx``.
"""

from __future__ import annotations

import time
from typing import Any, Callable, Dict, Iterator, Optional

import httpx

__all__ = ["Client", "ApiError", "AuthError", "RateLimited"]

# Connect codes that are worth trying again. Everything else means the request
# was wrong, and repeating it will produce the same answer more slowly.
RETRYABLE_CODES = frozenset({"unavailable", "deadline_exceeded", "resource_exhausted", "aborted"})

DEFAULT_TIMEOUT = 30.0
DEFAULT_RETRIES = 3


class ApiError(RuntimeError):
    """An error returned by the platform.

    ``reason`` is the machine-readable one — FARM_NOT_FOUND, MISSING_TENANT —
    and is what you should branch on. ``code`` says what kind of failure it was;
    ``message`` is written for a person and changes without notice.
    """

    def __init__(self, code: str, message: str, reason: str = "",
                 status: int = 0, details: Any = None):
        super().__init__(f"{code}: {message}" + (f" [{reason}]" if reason else ""))
        self.code = code
        self.message = message
        self.reason = reason
        self.status = status
        self.details = details

    @property
    def retryable(self) -> bool:
        return self.code in RETRYABLE_CODES


class AuthError(ApiError):
    """Authentication failed, or the session is no longer valid."""


class RateLimited(ApiError):
    """The rate limit or a tenant quota was exceeded.

    ``retry_after`` is the server's advice in seconds. Note that the platform
    sends no ``X-RateLimit-*`` headers, so there is no way to see remaining
    budget — back off on this rather than trying to stay under a limit you
    cannot observe.
    """

    def __init__(self, *args, retry_after: float = 1.0, **kwargs):
        super().__init__(*args, **kwargs)
        self.retry_after = retry_after


class Client:
    """A client for one deployment.

    Args:
        base_url: the API gateway, e.g. ``http://localhost:8080``.
        token: an access token, if you already have one.
        tenant_id: sent as ``X-Tenant-ID``. Usually unnecessary — the token
            carries the tenant — and it must match the token's tenant when
            both are present, or the request is refused.
        timeout: per-request timeout in seconds.
        retries: attempts for a retryable failure, the first included.
    """

    def __init__(
        self,
        base_url: str,
        *,
        token: Optional[str] = None,
        tenant_id: Optional[str] = None,
        timeout: float = DEFAULT_TIMEOUT,
        retries: int = DEFAULT_RETRIES,
        session: Optional[httpx.Client] = None,
    ):
        self.base_url = base_url.rstrip("/")
        self.token = token
        self.tenant_id = tenant_id
        self.retries = max(1, retries)
        self._refresh_token: Optional[str] = None
        self._expires_at: float = 0.0
        self._http = session or httpx.Client(timeout=timeout)

    # -- auth ---------------------------------------------------------------

    def login(self, email: str, password: str) -> Dict[str, Any]:
        """Exchange credentials for tokens and keep them.

        Login is rate limited far more tightly than the rest of the API — 10
        requests per second per IP against 100 — so a client that logs in per
        request will be throttled long before anything else is.
        """
        resp = self._http.post(
            f"{self.base_url}/auth/login",
            json={"email": email, "password": password},
        )
        if resp.status_code != 200:
            raise AuthError("unauthenticated", _text(resp), status=resp.status_code)

        body = resp.json()
        self._store_token(body.get("token", {}))
        user = body.get("user", {})
        if not self.tenant_id:
            self.tenant_id = user.get("tenant_id")
        return user

    def refresh(self) -> None:
        """Exchange the refresh token for a new access token."""
        if not self._refresh_token:
            raise AuthError("unauthenticated", "no refresh token; call login() first")
        resp = self._http.post(
            f"{self.base_url}/auth/refresh",
            json={"refresh_token": self._refresh_token},
        )
        if resp.status_code != 200:
            # The refresh token is spent or revoked; nothing to do but log in
            # again, and saying so is more useful than another 401.
            self._refresh_token = None
            raise AuthError("unauthenticated", "refresh failed; log in again",
                            status=resp.status_code)
        self._store_token(resp.json().get("token", {}))

    def _store_token(self, token: Dict[str, Any]) -> None:
        self.token = token.get("access_token")
        self._refresh_token = token.get("refresh_token") or self._refresh_token
        self._expires_at = float(token.get("expires_at") or 0)

    def _ensure_token(self) -> None:
        """Refresh slightly before expiry.

        The 60-second margin is not politeness — a token that expires while the
        request is in flight fails after the server has already done the work,
        and the retry is indistinguishable from a real auth failure.
        """
        if self._refresh_token and self._expires_at and time.time() > self._expires_at - 60:
            self.refresh()

    # -- calls --------------------------------------------------------------

    def call(self, service: str, method: str, body: Optional[Dict[str, Any]] = None,
             *, headers: Optional[Dict[str, str]] = None) -> Dict[str, Any]:
        """Invoke one RPC.

        Args:
            service: the fully-qualified service, e.g.
                ``agriculture.farm.v1.FarmService``.
            method: the RPC name, e.g. ``ListFarms``.
            body: the request message as a dict. Field names are the proto's
                JSON names (lowerCamelCase is accepted; snake_case is what the
                specs show).
        """
        self._ensure_token()
        url = f"{self.base_url}/{service}/{method}"

        hdrs = {"Content-Type": "application/json"}
        if self.token:
            hdrs["Authorization"] = f"Bearer {self.token}"
        if self.tenant_id:
            hdrs["X-Tenant-ID"] = self.tenant_id
        if headers:
            hdrs.update(headers)

        last: Optional[Exception] = None
        for attempt in range(self.retries):
            if attempt:
                # Exponential, capped. Uncapped backoff on a long outage means
                # a client that has stopped trying without saying so.
                time.sleep(min(2 ** (attempt - 1), 8))
            try:
                resp = self._http.post(url, json=body or {}, headers=hdrs)
            except httpx.TransportError as exc:
                # The request may or may not have been applied. Retried anyway,
                # because every RPC here is either a read or keyed on an id the
                # caller supplied.
                last = ApiError("unavailable", str(exc))
                continue

            if resp.status_code == 200:
                return resp.json()

            err = _to_error(resp)
            if isinstance(err, AuthError) and self._refresh_token and attempt == 0:
                # One shot at a refresh: a token can expire between the check
                # above and the server reading it.
                try:
                    self.refresh()
                    hdrs["Authorization"] = f"Bearer {self.token}"
                    continue
                except AuthError:
                    raise err from None
            if not err.retryable:
                raise err
            last = err

        raise last  # type: ignore[misc]

    def paginate(self, service: str, method: str, body: Dict[str, Any],
                 items_field: str, *, max_pages: int = 10_000) -> Iterator[Dict[str, Any]]:
        """Yield every item across pages, whichever pagination style applies.

        The platform uses both offset (``page_offset``) and token
        (``page_token``/``next_page_token``) styles depending on the service;
        this handles either, so callers need not know which.

        Termination is guarded four ways, because a server that does not
        advance is a real failure mode here rather than a theoretical one —
        several services used to compute the next token from the *requested*
        page size, so a client that omitted ``page_size`` was handed back the
        offset it had just read and paged forever:

        * a token identical to the one just sent ends the loop *before*
          yielding, since that page is by construction the one already
          returned;
        * a token seen earlier ends it;
        * a page shorter than the requested ``page_size`` is the last one;
        * ``max_pages`` bounds it regardless.

        Always send an explicit ``page_size``. Over a service's maximum it is
        clamped silently, and over 500 it is rejected outright.
        """
        request = dict(body)
        seen_tokens: set = set()
        sent_token: Optional[str] = None
        token_mode = False
        offset = int(request.get("page_offset") or 0)
        page_size = int(request.get("page_size") or 0)

        for _ in range(max_pages):
            resp = self.call(service, method, request)
            items = resp.get(items_field) or []
            token = resp.get("next_page_token") or resp.get("nextPageToken") or ""

            # The server handed back the token it was given: it has not
            # advanced, and these are the rows already yielded. Returning
            # before yielding is what stops the caller seeing them twice.
            if sent_token and token == sent_token:
                return

            for item in items:
                yield item

            if token:
                if token in seen_tokens:
                    return
                seen_tokens.add(token)
                request["page_token"] = token
                sent_token = token
                token_mode = True
                continue

            # No token. Once in token mode, that is the end of the results —
            # falling through to offsets here would re-request the last page
            # from a service that ignores page_offset.
            if token_mode or not items:
                return
            if page_size and len(items) < page_size:
                return

            # Offset style: advance by what arrived, and stop at the total.
            offset += len(items)
            total = resp.get("total_count") or resp.get("totalCount")
            if total is not None and offset >= int(total):
                return
            request["page_offset"] = offset

    def close(self) -> None:
        self._http.close()

    def __enter__(self) -> "Client":
        return self

    def __exit__(self, *exc: Any) -> None:
        self.close()


def _to_error(resp: httpx.Response) -> ApiError:
    """Build an ApiError from a Connect error response."""
    code, message, details = "unknown", _text(resp), None
    try:
        body = resp.json()
        code = body.get("code") or code
        message = body.get("message") or message
        details = body.get("details")
    except ValueError:
        pass

    # Mirrored into a header by the platform's error interceptor, for clients
    # that cannot decode the structured detail.
    reason = resp.headers.get("x-error-reason", "")
    if not reason and isinstance(details, list):
        for detail in details:
            if isinstance(detail, dict) and "reason" in detail:
                reason = detail["reason"]
                break

    if code == "unauthenticated" or resp.status_code == 401:
        return AuthError(code, message, reason, resp.status_code, details)
    if code == "resource_exhausted" or resp.status_code == 429:
        return RateLimited(code or "resource_exhausted", message, reason,
                           resp.status_code, details,
                           retry_after=float(resp.headers.get("retry-after", 1)))
    return ApiError(code, message, reason, resp.status_code, details)


def _text(resp: httpx.Response) -> str:
    body = (resp.text or "").strip()
    return body[:500] if body else f"HTTP {resp.status_code}"
