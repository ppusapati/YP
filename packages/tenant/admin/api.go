package admin

import (
	"context"
	"encoding/json"
	"errors"
	"net"
	"net/http"
	"strings"
	"time"

	"p9e.in/samavaya/packages/connect/interceptors"
	p9errors "p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
)

// Handler exposes the platform view over plain HTTP as JSON.
//
// Plain HTTP rather than a Connect RPC, which is what every other surface on
// this platform uses. The reason is narrow and worth recording so nobody
// "fixes" it later without knowing: adding a proto here means regenerating the
// Dart client, and CI gates on generated Dart being fresh. Two endpoints
// returning aggregates to one internal page is not worth a schema change that
// cannot be verified from this side. If the platform view grows into something
// with writes, move it to a proto and pay that cost properly.
//
// Routes:
//
//	GET /admin/tenants — every tenant, ordered so the ones needing attention
//	                     come first
//	GET /admin/stats   — the roll-up across all of them
type Handler struct {
	svc     *Service
	auth    Authenticator
	mux     *http.ServeMux
	timeout time.Duration
}

// RequestTimeout bounds one platform request.
//
// Generous, because listing every tenant on a large platform is genuinely a
// slow query, but bounded: an unbounded admin query is how one wedged page
// holds a connection open until the pool is exhausted and the rest of the
// service stops.
const RequestTimeout = 20 * time.Second

// Authenticator turns an incoming request into a context carrying the caller's
// identity.
//
// An interface rather than a JWT validator baked in, because the service that
// eventually mounts this already has its own way of establishing identity and
// the two must agree. What is *not* offered is a nil authenticator meaning
// "skip authentication": see NewHandler.
type Authenticator interface {
	Authenticate(r *http.Request) (context.Context, error)
}

// NewHandler builds the HTTP surface.
//
// Both arguments are required. There is no development mode, no "auth
// disabled" flag and no default that lets an unauthenticated request through,
// because this is the one endpoint on the platform that reads across every
// tenant at once. A convenience switch here is a switch someone leaves on.
func NewHandler(svc *Service, auth Authenticator) (*Handler, error) {
	if svc == nil {
		return nil, errors.New("admin: a service is required")
	}
	if auth == nil {
		return nil, errors.New("admin: an authenticator is required; this endpoint reads across every tenant")
	}

	h := &Handler{svc: svc, auth: auth, mux: http.NewServeMux(), timeout: RequestTimeout}
	// Method-qualified patterns, so a POST to either route is a 405 rather than
	// being quietly served as a read.
	h.mux.HandleFunc("GET /admin/tenants", h.handleTenants)
	h.mux.HandleFunc("GET /admin/stats", h.handleStats)
	return h, nil
}

// ServeHTTP implements http.Handler.
func (h *Handler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	h.mux.ServeHTTP(w, r)
}

// Mount registers the routes on an existing mux, for a service that already
// has an HTTP server rather than one dedicated to this.
func (h *Handler) Mount(mux *http.ServeMux) {
	mux.Handle("/admin/", h)
}

func (h *Handler) handleTenants(w http.ResponseWriter, r *http.Request) {
	ctx, cancel, ok := h.begin(w, r)
	if !ok {
		return
	}
	defer cancel()

	tenants, err := h.svc.ListTenants(ctx)
	if err != nil {
		writeError(w, err)
		return
	}
	// Encoded as a bare array because that is what the page consumes. An empty
	// platform is `[]`, never `null`: a client that distinguishes the two would
	// otherwise see "no tenants" as a broken response.
	if tenants == nil {
		tenants = []TenantSummary{}
	}
	writeJSON(w, http.StatusOK, tenants)
}

func (h *Handler) handleStats(w http.ResponseWriter, r *http.Request) {
	ctx, cancel, ok := h.begin(w, r)
	if !ok {
		return
	}
	defer cancel()

	stats, err := h.svc.Stats(ctx)
	if err != nil {
		writeError(w, err)
		return
	}
	writeJSON(w, http.StatusOK, stats)
}

// begin authenticates the request and attaches the request metadata the audit
// record needs.
//
// The metadata is not decoration. An audit entry saying that some platform
// operator listed every tenant, without saying from where, is most of the way
// to useless during the incident where it matters.
func (h *Handler) begin(w http.ResponseWriter, r *http.Request) (context.Context, context.CancelFunc, bool) {
	ctx, err := h.auth.Authenticate(r)
	if err != nil {
		writeError(w, err)
		return nil, nil, false
	}
	if ctx == nil {
		// A misbehaving authenticator returning (nil, nil) must not read as
		// success with an empty context — the service would then see no user
		// and refuse, but through the wrong path and with a confusing status.
		writeError(w, p9errors.InternalServer("AUTH_BROKEN", "authentication produced no context"))
		return nil, nil, false
	}

	ctx = p9context.NewRequestContext(ctx, p9context.RequestContext{
		RequestID: requestID(r),
		ClientIP:  clientIP(r),
		UserAgent: r.UserAgent(),
		Method:    r.Method,
		Path:      r.URL.Path,
	})

	ctx, cancel := context.WithTimeout(ctx, h.timeout)
	return ctx, cancel, true
}

func requestID(r *http.Request) string {
	if id := r.Header.Get("X-Request-ID"); id != "" {
		return id
	}
	return r.Header.Get("X-Correlation-ID")
}

// clientIP prefers the socket address and only falls back to the forwarding
// headers.
//
// The order matters: X-Forwarded-For is set by the client on a direct request
// and is trivially forged, so behind a proxy that rewrites it the header is
// right and on a direct connection the socket is. Taking the socket first
// means the audit log can be wrong about the client's real address behind a
// proxy, but never wrong because the client said so.
func clientIP(r *http.Request) string {
	if host, _, err := net.SplitHostPort(r.RemoteAddr); err == nil && host != "" {
		return host
	}
	if r.RemoteAddr != "" {
		return r.RemoteAddr
	}
	if fwd := r.Header.Get("X-Forwarded-For"); fwd != "" {
		return strings.TrimSpace(strings.Split(fwd, ",")[0])
	}
	return ""
}

// errorBody is what a refused request returns.
type errorBody struct {
	Error   string `json:"error"`
	Message string `json:"message,omitempty"`
}

func writeJSON(w http.ResponseWriter, status int, body any) {
	w.Header().Set("Content-Type", "application/json")
	// This is a per-operator view of live state; a cached copy on a shared
	// proxy is both stale and readable by the wrong person.
	w.Header().Set("Cache-Control", "no-store")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(body)
}

// writeError maps a domain error to a status.
//
// The message returned is the one the error carries, which the admin package
// writes deliberately — "an internal error occurred" for anything from the
// database, the real reason for an authorization refusal. Echoing err.Error()
// instead would leak query text to whoever probes the endpoint.
func writeError(w http.ResponseWriter, err error) {
	var p9e *p9errors.Error
	if errors.As(err, &p9e) {
		status := int(p9e.Code)
		if status < 400 || status > 599 {
			status = http.StatusInternalServerError
		}
		writeJSON(w, status, errorBody{Error: p9e.Reason, Message: p9e.Message})
		return
	}
	switch {
	case errors.Is(err, ErrNotPlatformOperator):
		writeJSON(w, http.StatusForbidden, errorBody{
			Error: "NOT_PLATFORM_OPERATOR", Message: ErrNotPlatformOperator.Error()})
	case errors.Is(err, context.DeadlineExceeded):
		writeJSON(w, http.StatusGatewayTimeout, errorBody{
			Error: "TIMEOUT", Message: "the platform query took too long"})
	default:
		writeJSON(w, http.StatusInternalServerError, errorBody{
			Error: "INTERNAL", Message: "an internal error occurred"})
	}
}

// ── Bearer token authentication ─────────────────────────────────────────────

// BearerAuthenticator authenticates with the same JWT validator the Connect
// interceptors use, so a token is accepted here exactly when it is accepted
// everywhere else. A second token format for the admin endpoint would be a
// second thing to get wrong.
type BearerAuthenticator struct {
	validator interceptors.JWTValidator
	now       func() time.Time
}

// NewBearerAuthenticator wraps a JWT validator.
func NewBearerAuthenticator(v interceptors.JWTValidator) (*BearerAuthenticator, error) {
	if v == nil {
		return nil, errors.New("admin: a JWT validator is required")
	}
	return &BearerAuthenticator{validator: v, now: time.Now}, nil
}

// Authenticate validates the Authorization header and returns a context
// carrying the caller.
func (a *BearerAuthenticator) Authenticate(r *http.Request) (context.Context, error) {
	const unauthenticated = "NOT_AUTHENTICATED"

	header := r.Header.Get("Authorization")
	if header == "" {
		return nil, p9errors.Unauthorized(unauthenticated, "authentication is required")
	}
	// Case-insensitive scheme, because that is what RFC 7235 says and some
	// clients send "bearer".
	if len(header) < 7 || !strings.EqualFold(header[:7], "bearer ") {
		return nil, p9errors.Unauthorized(unauthenticated, "expected a bearer token")
	}
	token := strings.TrimSpace(header[7:])
	if token == "" {
		return nil, p9errors.Unauthorized(unauthenticated, "expected a bearer token")
	}

	claims, err := a.validator.ValidateToken(r.Context(), token)
	if err != nil || claims == nil {
		// Deliberately the same response as a missing header. Distinguishing
		// "no token" from "bad token" tells someone probing the endpoint which
		// of their guesses was closer.
		return nil, p9errors.Unauthorized(unauthenticated, "authentication is required")
	}

	// Expiry is checked here as well as in the validator. Validators vary —
	// some check exp, some leave it to a library setting — and a stale token
	// that still opens the cross-tenant view is the one expiry bug worth
	// double-checking. A zero ExpiresAt means the validator did not report one,
	// which is not treated as "never expires": it is refused.
	if claims.ExpiresAt.IsZero() {
		return nil, p9errors.Unauthorized(unauthenticated, "token carries no expiry")
	}
	if !a.now().Before(claims.ExpiresAt) {
		return nil, p9errors.Unauthorized("TOKEN_EXPIRED", "the token has expired")
	}

	ctx := p9context.NewUserContext(r.Context(), p9context.UserContext{
		UserID:      claims.UserID,
		TenantID:    claims.TenantID,
		CompanyID:   claims.CompanyID,
		BranchID:    claims.BranchID,
		Role:        claims.Role,
		Permissions: claims.Permissions,
	})
	return ctx, nil
}
