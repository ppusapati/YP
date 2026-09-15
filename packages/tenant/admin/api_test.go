package admin

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"p9e.in/samavaya/packages/connect/interceptors"
	"p9e.in/samavaya/packages/saas"
)

// The HTTP surface is the part an attacker can reach, so these tests are about
// what it refuses rather than what it renders.

var errBadToken = errors.New("invalid token")

func ptr[T any](v T) *T { return &v }

// stubValidator accepts one token and rejects everything else.
type stubValidator struct {
	token  string
	claims *interceptors.JWTClaims
	err    error
}

func (v *stubValidator) ValidateToken(_ context.Context, token string) (*interceptors.JWTClaims, error) {
	if v.err != nil {
		return nil, v.err
	}
	if token != v.token {
		return nil, errBadToken
	}
	return v.claims, nil
}

func platformClaims() *interceptors.JWTClaims {
	return &interceptors.JWTClaims{
		UserID: "u-1", TenantID: "t-1", Role: string(interceptors.RolePlatform),
		ExpiresAt: now.Add(time.Hour),
	}
}

// newHandler builds a handler over a platform with two tenants.
func newHandler(t *testing.T, claims *interceptors.JWTClaims) (*Handler, *recordingAudit) {
	t.Helper()
	auditLog := &recordingAudit{}
	svc := &Service{
		registry: &stubRegistry{tenants: []saas.TenantConfig{
			{ID: "t-1", Name: "Alpha Farms", IsActive: true},
			{ID: "t-2", Name: "Beta Estates", IsActive: false},
		}},
		usage: &stubUsage{snapshots: map[string]UsageSnapshot{
			"t-1": {TenantID: "t-1", Farms: 3, Fields: 12, Sensors: 40, Users: 7,
				LastActivityAt: ptr(now.Add(-2 * time.Hour)), GatheredAt: now},
		}},
		audit: auditLog,
		now:   func() time.Time { return now },
	}
	validator := &stubValidator{token: "good", claims: claims}
	auth, err := NewBearerAuthenticator(validator)
	if err != nil {
		t.Fatalf("building the authenticator: %v", err)
	}
	auth.now = func() time.Time { return now }

	h, err := NewHandler(svc, auth)
	if err != nil {
		t.Fatalf("building the handler: %v", err)
	}
	return h, auditLog
}

func get(h *Handler, path, token string) *httptest.ResponseRecorder {
	req := httptest.NewRequest(http.MethodGet, path, nil)
	if token != "" {
		req.Header.Set("Authorization", "Bearer "+token)
	}
	rec := httptest.NewRecorder()
	h.ServeHTTP(rec, req)
	return rec
}

// ── What it refuses ─────────────────────────────────────────────────────────

func TestAHandlerCannotBeBuiltWithoutAnAuthenticator(t *testing.T) {
	// The single most important test in this file. An admin endpoint with a
	// "no auth configured" path is an admin endpoint someone will deploy that
	// way, and this one reads every tenant.
	built, _ := newHandler(t, platformClaims())
	if _, err := NewHandler(built.svc, nil); err == nil {
		t.Fatal("a handler was built with no authenticator")
	}
	if _, err := NewHandler(nil, built.auth); err == nil {
		t.Fatal("a handler was built with no service")
	}
}

func TestAnUnauthenticatedRequestIsRefused(t *testing.T) {
	h, auditLog := newHandler(t, platformClaims())

	rec := get(h, "/admin/tenants", "")
	if rec.Code != http.StatusUnauthorized {
		t.Errorf("status %d, want 401", rec.Code)
	}
	if len(auditLog.entries) != 0 {
		t.Error("an unauthenticated request reached the audited path")
	}
}

func TestABadTokenIsIndistinguishableFromNoToken(t *testing.T) {
	// Distinguishing them tells somebody probing the endpoint which of their
	// guesses was closer.
	h, _ := newHandler(t, platformClaims())

	missing := get(h, "/admin/tenants", "")
	bad := get(h, "/admin/tenants", "wrong")
	if missing.Code != bad.Code {
		t.Errorf("missing token gave %d, bad token gave %d", missing.Code, bad.Code)
	}
	if missing.Body.String() != bad.Body.String() {
		t.Errorf("responses differ:\n missing: %s\n bad:     %s", missing.Body, bad.Body)
	}
}

func TestATenantAdminIsRefusedTheCrossTenantView(t *testing.T) {
	// The whole point of the package. A tenant admin is the highest authority
	// inside their tenant and has no business seeing another's.
	claims := platformClaims()
	claims.Role = string(interceptors.RoleAdmin)
	h, auditLog := newHandler(t, claims)

	rec := get(h, "/admin/tenants", "good")
	if rec.Code != http.StatusForbidden {
		t.Errorf("status %d, want 403", rec.Code)
	}
	// And the attempt is on the record. Someone trying to reach this is more
	// interesting than someone succeeding.
	if len(auditLog.entries) != 1 || auditLog.entries[0].Result != "failure" {
		t.Errorf("the refused attempt was not audited: %+v", auditLog.entries)
	}
}

func TestAnExpiredTokenIsRefused(t *testing.T) {
	claims := platformClaims()
	claims.ExpiresAt = now.Add(-time.Minute)
	h, _ := newHandler(t, claims)

	if rec := get(h, "/admin/tenants", "good"); rec.Code != http.StatusUnauthorized {
		t.Errorf("status %d, want 401 for an expired token", rec.Code)
	}
}

func TestATokenWithNoExpiryIsRefused(t *testing.T) {
	// A missing exp is not "never expires". A token that opens the cross-tenant
	// view forever is the one expiry bug worth double-checking.
	claims := platformClaims()
	claims.ExpiresAt = time.Time{}
	h, _ := newHandler(t, claims)

	if rec := get(h, "/admin/tenants", "good"); rec.Code != http.StatusUnauthorized {
		t.Errorf("status %d, want 401 for a token with no expiry", rec.Code)
	}
}

func TestWritesAreNotServedAsReads(t *testing.T) {
	h, _ := newHandler(t, platformClaims())

	req := httptest.NewRequest(http.MethodPost, "/admin/tenants", nil)
	req.Header.Set("Authorization", "Bearer good")
	rec := httptest.NewRecorder()
	h.ServeHTTP(rec, req)

	if rec.Code == http.StatusOK {
		t.Error("a POST was served as a read")
	}
}

// ── What it serves ──────────────────────────────────────────────────────────

func TestAPlatformOperatorGetsTheTenantList(t *testing.T) {
	h, auditLog := newHandler(t, platformClaims())

	rec := get(h, "/admin/tenants", "good")
	if rec.Code != http.StatusOK {
		t.Fatalf("status %d (%s), want 200", rec.Code, rec.Body)
	}

	var got []TenantSummary
	if err := json.Unmarshal(rec.Body.Bytes(), &got); err != nil {
		t.Fatalf("the body is not a tenant array: %v (%s)", err, rec.Body)
	}
	if len(got) != 2 {
		t.Fatalf("got %d tenants, want 2", len(got))
	}
	if len(auditLog.entries) != 1 || auditLog.entries[0].Result != "success" {
		t.Errorf("the access was not audited as a success: %+v", auditLog.entries)
	}
}

func TestTheAuditRecordSaysWhereTheCallCameFrom(t *testing.T) {
	h, auditLog := newHandler(t, platformClaims())

	req := httptest.NewRequest(http.MethodGet, "/admin/tenants", nil)
	req.Header.Set("Authorization", "Bearer good")
	req.Header.Set("X-Request-ID", "req-42")
	req.Header.Set("User-Agent", "platform-console/1.0")
	req.RemoteAddr = "203.0.113.9:51544"
	h.ServeHTTP(httptest.NewRecorder(), req)

	if len(auditLog.entries) != 1 {
		t.Fatalf("got %d audit entries, want 1", len(auditLog.entries))
	}
	e := auditLog.entries[0]
	if e.ClientIP != "203.0.113.9" {
		t.Errorf("client ip %q, want 203.0.113.9", e.ClientIP)
	}
	if e.UserAgent != "platform-console/1.0" {
		t.Errorf("user agent %q", e.UserAgent)
	}
	if e.RequestID != "req-42" {
		t.Errorf("request id %q, want req-42", e.RequestID)
	}
}

func TestAForgedForwardedForDoesNotOverrideTheSocketAddress(t *testing.T) {
	// The audit log may be wrong about the real client behind a proxy, but it
	// must never be wrong because the client said so.
	h, auditLog := newHandler(t, platformClaims())

	req := httptest.NewRequest(http.MethodGet, "/admin/tenants", nil)
	req.Header.Set("Authorization", "Bearer good")
	req.Header.Set("X-Forwarded-For", "10.0.0.1")
	req.RemoteAddr = "203.0.113.9:51544"
	h.ServeHTTP(httptest.NewRecorder(), req)

	if got := auditLog.entries[0].ClientIP; got != "203.0.113.9" {
		t.Errorf("client ip %q; a header overrode the socket address", got)
	}
}

func TestAnEmptyPlatformIsAnArrayNotNull(t *testing.T) {
	// A client that distinguishes [] from null would otherwise read "no
	// tenants" as a broken response.
	h, _ := newHandler(t, platformClaims())
	h.svc.registry = &stubRegistry{}

	rec := get(h, "/admin/tenants", "good")
	if body := rec.Body.String(); body != "[]\n" {
		t.Errorf("body %q, want an empty array", body)
	}
}

func TestTheStatsRouteRollsTheTenantsUp(t *testing.T) {
	h, _ := newHandler(t, platformClaims())

	rec := get(h, "/admin/stats", "good")
	if rec.Code != http.StatusOK {
		t.Fatalf("status %d (%s), want 200", rec.Code, rec.Body)
	}

	var stats PlatformStats
	if err := json.Unmarshal(rec.Body.Bytes(), &stats); err != nil {
		t.Fatalf("the body is not a stats object: %v (%s)", err, rec.Body)
	}
	if stats.Tenants != 2 || stats.Active != 1 || stats.Suspended != 1 {
		t.Errorf("tenants=%d active=%d suspended=%d, want 2/1/1",
			stats.Tenants, stats.Active, stats.Suspended)
	}
	if stats.TotalFarms != 3 {
		t.Errorf("total farms %d, want 3", stats.TotalFarms)
	}
}

func TestTheResponseIsNotCacheable(t *testing.T) {
	// Live per-operator state on a shared proxy is both stale and readable by
	// the wrong person.
	h, _ := newHandler(t, platformClaims())

	rec := get(h, "/admin/tenants", "good")
	if got := rec.Header().Get("Cache-Control"); got != "no-store" {
		t.Errorf("Cache-Control %q, want no-store", got)
	}
}
