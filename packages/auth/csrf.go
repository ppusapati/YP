// Package auth provides security middleware for the YieldPoint platform,
// including CSRF protection and OAuth2/OIDC support.
package auth

import (
	"crypto/hmac"
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"errors"
	"fmt"
	"net/http"
	"strings"
	"time"
)

// CSRF errors.
var (
	ErrCSRFTokenMissing  = errors.New("csrf: token missing from request")
	ErrCSRFTokenInvalid  = errors.New("csrf: token validation failed")
	ErrCSRFTokenExpired  = errors.New("csrf: token has expired")
	ErrCSRFCookieMissing = errors.New("csrf: cookie not found")
)

const (
	// DefaultCSRFCookieName is the default name for the CSRF cookie.
	DefaultCSRFCookieName = "_csrf_token"

	// DefaultCSRFHeaderName is the default header for submitting the CSRF token.
	DefaultCSRFHeaderName = "X-CSRF-Token"

	// DefaultCSRFFieldName is the default form field name for the CSRF token.
	DefaultCSRFFieldName = "csrf_token"

	// csrfTokenLength is the byte length of the random token component.
	csrfTokenLength = 32
)

// CSRFConfig configures CSRF protection.
type CSRFConfig struct {
	// Secret used for HMAC signing. Must be at least 32 bytes.
	Secret []byte

	// CookieName for the CSRF cookie. Default: "_csrf_token".
	CookieName string

	// HeaderName for the CSRF header. Default: "X-CSRF-Token".
	HeaderName string

	// FieldName for form submissions. Default: "csrf_token".
	FieldName string

	// MaxAge of the CSRF cookie in seconds. Default: 12 hours.
	MaxAge int

	// Secure sets the Secure flag on the cookie. Should be true in production.
	Secure bool

	// SameSite attribute for the cookie. Default: SameSiteStrictMode.
	SameSite http.SameSite

	// Domain for the cookie. Empty uses the request domain.
	Domain string

	// Path for the cookie. Default: "/".
	Path string

	// SkipCheck is called for each request. If it returns true, CSRF
	// verification is skipped. Use this to bypass ConnectRPC endpoints.
	SkipCheck func(r *http.Request) bool
}

// DefaultCSRFConfig returns a CSRFConfig with sensible defaults.
func DefaultCSRFConfig(secret []byte) CSRFConfig {
	return CSRFConfig{
		Secret:     secret,
		CookieName: DefaultCSRFCookieName,
		HeaderName: DefaultCSRFHeaderName,
		FieldName:  DefaultCSRFFieldName,
		MaxAge:     43200, // 12 hours
		Secure:     true,
		SameSite:   http.SameSiteStrictMode,
		Path:       "/",
	}
}

// CSRFProtection provides double-submit cookie CSRF protection.
type CSRFProtection struct {
	cfg CSRFConfig
}

// NewCSRFProtection creates a new CSRF protection instance.
func NewCSRFProtection(cfg CSRFConfig) (*CSRFProtection, error) {
	if len(cfg.Secret) < 32 {
		return nil, fmt.Errorf("csrf: secret must be at least 32 bytes (got %d)", len(cfg.Secret))
	}
	if cfg.CookieName == "" {
		cfg.CookieName = DefaultCSRFCookieName
	}
	if cfg.HeaderName == "" {
		cfg.HeaderName = DefaultCSRFHeaderName
	}
	if cfg.FieldName == "" {
		cfg.FieldName = DefaultCSRFFieldName
	}
	if cfg.MaxAge == 0 {
		cfg.MaxAge = 43200
	}
	if cfg.Path == "" {
		cfg.Path = "/"
	}
	if cfg.SameSite == 0 {
		cfg.SameSite = http.SameSiteStrictMode
	}
	return &CSRFProtection{cfg: cfg}, nil
}

// GenerateToken creates a new CSRF token: base64(random || timestamp || hmac).
func (c *CSRFProtection) GenerateToken() (string, error) {
	randomBytes := make([]byte, csrfTokenLength)
	if _, err := rand.Read(randomBytes); err != nil {
		return "", fmt.Errorf("csrf: failed to generate random bytes: %w", err)
	}

	timestamp := time.Now().Unix()
	tsBytes := []byte(fmt.Sprintf("%d", timestamp))

	// HMAC(random || timestamp)
	mac := hmac.New(sha256.New, c.cfg.Secret)
	mac.Write(randomBytes)
	mac.Write(tsBytes)
	signature := mac.Sum(nil)

	// Encode: random.timestamp.signature
	token := fmt.Sprintf("%s.%d.%s",
		base64.RawURLEncoding.EncodeToString(randomBytes),
		timestamp,
		base64.RawURLEncoding.EncodeToString(signature),
	)

	return token, nil
}

// ValidateToken verifies a CSRF token's HMAC and expiration.
func (c *CSRFProtection) ValidateToken(token string) error {
	parts := strings.SplitN(token, ".", 3)
	if len(parts) != 3 {
		return ErrCSRFTokenInvalid
	}

	randomBytes, err := base64.RawURLEncoding.DecodeString(parts[0])
	if err != nil {
		return ErrCSRFTokenInvalid
	}

	var timestamp int64
	if _, err := fmt.Sscanf(parts[1], "%d", &timestamp); err != nil {
		return ErrCSRFTokenInvalid
	}

	signature, err := base64.RawURLEncoding.DecodeString(parts[2])
	if err != nil {
		return ErrCSRFTokenInvalid
	}

	// Check expiration
	age := time.Since(time.Unix(timestamp, 0))
	if age > time.Duration(c.cfg.MaxAge)*time.Second || age < 0 {
		return ErrCSRFTokenExpired
	}

	// Verify HMAC
	tsBytes := []byte(fmt.Sprintf("%d", timestamp))
	mac := hmac.New(sha256.New, c.cfg.Secret)
	mac.Write(randomBytes)
	mac.Write(tsBytes)
	expectedSig := mac.Sum(nil)

	if !hmac.Equal(signature, expectedSig) {
		return ErrCSRFTokenInvalid
	}

	return nil
}

// SetCookie writes a CSRF cookie to the response with a fresh token.
func (c *CSRFProtection) SetCookie(w http.ResponseWriter, token string) {
	http.SetCookie(w, &http.Cookie{
		Name:     c.cfg.CookieName,
		Value:    token,
		Path:     c.cfg.Path,
		Domain:   c.cfg.Domain,
		MaxAge:   c.cfg.MaxAge,
		Secure:   c.cfg.Secure,
		HttpOnly: false, // must be readable by JavaScript for double-submit
		SameSite: c.cfg.SameSite,
	})
}

// TokenFromRequest extracts the CSRF token from the request header or form field.
func (c *CSRFProtection) TokenFromRequest(r *http.Request) string {
	// Check header first
	if token := r.Header.Get(c.cfg.HeaderName); token != "" {
		return token
	}
	// Fall back to form field
	return r.FormValue(c.cfg.FieldName)
}

// TokenFromCookie extracts the CSRF token from the request cookie.
func (c *CSRFProtection) TokenFromCookie(r *http.Request) (string, error) {
	cookie, err := r.Cookie(c.cfg.CookieName)
	if err != nil {
		return "", ErrCSRFCookieMissing
	}
	return cookie.Value, nil
}

// isConnectRPC checks whether the request is a ConnectRPC call.
// ConnectRPC uses POST with application/proto, application/json, or
// application/connect+proto content types, and paths starting with a
// package-qualified service name (e.g. "/farm.v1.FarmService/CreateFarm").
func isConnectRPC(r *http.Request) bool {
	ct := r.Header.Get("Content-Type")
	if strings.HasPrefix(ct, "application/connect+") ||
		strings.HasPrefix(ct, "application/grpc") {
		return true
	}
	// ConnectRPC JSON requests use Connect-Protocol-Version header
	if r.Header.Get("Connect-Protocol-Version") != "" {
		return true
	}
	return false
}

// safeMethods are HTTP methods that do not require CSRF validation.
var safeMethods = map[string]bool{
	http.MethodGet:     true,
	http.MethodHead:    true,
	http.MethodOptions: true,
	http.MethodTrace:   true,
}

// Middleware returns an HTTP middleware that enforces CSRF protection
// using the double-submit cookie pattern.
//
// For safe HTTP methods (GET, HEAD, OPTIONS, TRACE), a CSRF cookie is
// set if missing and the request proceeds.
//
// For unsafe methods (POST, PUT, PATCH, DELETE), the token from the
// cookie must match the token from the header or form field. Both are
// validated individually and then compared.
//
// ConnectRPC endpoints are skipped by default because they are already
// protected by Bearer token authentication.
func (c *CSRFProtection) Middleware() func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			// Skip ConnectRPC requests (protected by Bearer tokens)
			if isConnectRPC(r) {
				next.ServeHTTP(w, r)
				return
			}

			// Skip if custom check says so
			if c.cfg.SkipCheck != nil && c.cfg.SkipCheck(r) {
				next.ServeHTTP(w, r)
				return
			}

			// Safe methods: ensure cookie is set, then proceed
			if safeMethods[r.Method] {
				if _, err := r.Cookie(c.cfg.CookieName); err != nil {
					token, genErr := c.GenerateToken()
					if genErr != nil {
						http.Error(w, "Internal Server Error", http.StatusInternalServerError)
						return
					}
					c.SetCookie(w, token)
				}
				next.ServeHTTP(w, r)
				return
			}

			// Unsafe methods: validate CSRF
			cookieToken, err := c.TokenFromCookie(r)
			if err != nil {
				http.Error(w, ErrCSRFCookieMissing.Error(), http.StatusForbidden)
				return
			}

			requestToken := c.TokenFromRequest(r)
			if requestToken == "" {
				http.Error(w, ErrCSRFTokenMissing.Error(), http.StatusForbidden)
				return
			}

			// Validate the token from the cookie
			if err := c.ValidateToken(cookieToken); err != nil {
				http.Error(w, err.Error(), http.StatusForbidden)
				return
			}

			// Double-submit: cookie token must match header/form token
			if cookieToken != requestToken {
				http.Error(w, ErrCSRFTokenInvalid.Error(), http.StatusForbidden)
				return
			}

			// Rotate token on successful mutation
			newToken, genErr := c.GenerateToken()
			if genErr == nil {
				c.SetCookie(w, newToken)
			}

			next.ServeHTTP(w, r)
		})
	}
}
