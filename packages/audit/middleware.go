package audit

import (
	"bytes"
	"context"
	"io"
	"net/http"
	"strings"
	"time"

	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/ulid"
)

// sensitiveFields are field names that must be redacted from audit metadata.
var sensitiveFields = map[string]bool{
	"password":      true,
	"secret":        true,
	"token":         true,
	"access_token":  true,
	"refresh_token": true,
	"api_key":       true,
	"apikey":        true,
	"authorization": true,
	"cookie":        true,
	"set-cookie":    true,
	"x-api-key":     true,
	"credit_card":   true,
	"ssn":           true,
}

// isSensitiveField returns true if the field name should be redacted.
func isSensitiveField(name string) bool {
	return sensitiveFields[strings.ToLower(name)]
}

// filterHeaders returns a map of header key-value pairs with sensitive values redacted.
func filterHeaders(headers http.Header) map[string]string {
	result := make(map[string]string, len(headers))
	for key, values := range headers {
		if isSensitiveField(key) {
			result[key] = "[REDACTED]"
		} else {
			result[key] = strings.Join(values, ", ")
		}
	}
	return result
}

// responseCapture wraps http.ResponseWriter to capture the status code.
type responseCapture struct {
	http.ResponseWriter
	statusCode int
	written    bool
}

func newResponseCapture(w http.ResponseWriter) *responseCapture {
	return &responseCapture{ResponseWriter: w, statusCode: http.StatusOK}
}

func (rc *responseCapture) WriteHeader(code int) {
	if !rc.written {
		rc.statusCode = code
		rc.written = true
	}
	rc.ResponseWriter.WriteHeader(code)
}

func (rc *responseCapture) Write(b []byte) (int, error) {
	if !rc.written {
		rc.written = true
	}
	return rc.ResponseWriter.Write(b)
}

// MiddlewareOption configures the HTTP audit middleware.
type MiddlewareOption func(*middlewareConfig)

type middlewareConfig struct {
	skipPaths      map[string]bool
	captureHeaders bool
	maxBodyLog     int
}

// WithSkipPaths excludes specific paths from audit logging.
func WithSkipPaths(paths ...string) MiddlewareOption {
	return func(c *middlewareConfig) {
		for _, p := range paths {
			c.skipPaths[p] = true
		}
	}
}

// WithCaptureHeaders enables logging of request headers (sensitive values redacted).
func WithCaptureHeaders(capture bool) MiddlewareOption {
	return func(c *middlewareConfig) {
		c.captureHeaders = capture
	}
}

// HTTPMiddleware returns an HTTP middleware that captures audit events for mutations.
// It extracts user information from JWT claims stored in the request context
// (set by upstream auth middleware) and records request/response metadata.
//
// Only mutating HTTP methods (POST, PUT, PATCH, DELETE) are logged.
// Read-only methods (GET, HEAD, OPTIONS) are skipped.
func HTTPMiddleware(logger AuditLogger, opts ...MiddlewareOption) func(http.Handler) http.Handler {
	cfg := &middlewareConfig{
		skipPaths:      make(map[string]bool),
		captureHeaders: false,
		maxBodyLog:     0, // do not log body by default
	}
	for _, opt := range opts {
		opt(cfg)
	}

	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			// Skip non-mutating methods
			if r.Method == http.MethodGet || r.Method == http.MethodHead || r.Method == http.MethodOptions {
				next.ServeHTTP(w, r)
				return
			}

			// Skip excluded paths
			if cfg.skipPaths[r.URL.Path] {
				next.ServeHTTP(w, r)
				return
			}

			start := time.Now().UTC()
			capture := newResponseCapture(w)

			// Serve the request
			next.ServeHTTP(capture, r)

			// Build audit entry
			entry := AuditEntry{
				ID:        ulid.NewString(),
				Action:    httpMethodToAction(r.Method),
				Resource:  extractResourceFromPath(r.URL.Path),
				Procedure: r.Method + " " + r.URL.Path,
				Timestamp: start,
				Metadata:  make(map[string]string),
			}

			// Extract user info from context (set by auth middleware)
			if user, ok := p9context.FromUserContext(r.Context()); ok {
				entry.UserID = user.UserID
				entry.TenantID = user.TenantID
				entry.Role = user.Role
			}

			// Extract request context info
			if reqCtx, ok := p9context.FromRequestContext(r.Context()); ok {
				entry.RequestID = reqCtx.RequestID
				entry.ClientIP = reqCtx.ClientIP
				entry.UserAgent = reqCtx.UserAgent
			} else {
				entry.ClientIP = extractClientIPFromRequest(r)
				entry.UserAgent = r.UserAgent()
			}

			// Record response info
			entry.Metadata["status_code"] = http.StatusText(capture.statusCode)
			entry.Metadata["duration_ms"] = time.Since(start).String()

			if capture.statusCode >= 400 {
				entry.Result = "failure"
				entry.ErrorCode = http.StatusText(capture.statusCode)
			} else {
				entry.Result = "success"
			}

			// Capture filtered headers if enabled
			if cfg.captureHeaders {
				for k, v := range filterHeaders(r.Header) {
					entry.Metadata["req_header_"+strings.ToLower(k)] = v
				}
			}

			// Log asynchronously
			go func() {
				logCtx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
				defer cancel()
				_ = logger.Log(logCtx, entry)
			}()
		})
	}
}

// SanitizeBody reads the body, redacts sensitive fields, and returns
// the original body for re-reading and the sanitized version.
// This is intentionally not used by default to avoid performance overhead
// -- enable with WithCaptureHeaders or extend for body capture.
func SanitizeBody(body io.ReadCloser, maxBytes int) (io.ReadCloser, string) {
	if body == nil || maxBytes <= 0 {
		return body, ""
	}

	data, err := io.ReadAll(io.LimitReader(body, int64(maxBytes)))
	if err != nil {
		return body, ""
	}
	// Restore the body for downstream handlers
	restored := io.NopCloser(io.MultiReader(bytes.NewReader(data), body))

	sanitized := string(data)
	// Redact any field values that look like sensitive content
	for field := range sensitiveFields {
		// Simple redaction: replace "field":"value" patterns
		sanitized = redactJSONField(sanitized, field)
	}

	return restored, sanitized
}

// redactJSONField replaces the value of a JSON field with [REDACTED].
func redactJSONField(s, field string) string {
	// Match "field":"..." or "field": "..."
	patterns := []string{
		`"` + field + `":"`,
		`"` + field + `": "`,
	}
	for _, pattern := range patterns {
		idx := strings.Index(strings.ToLower(s), strings.ToLower(pattern))
		if idx == -1 {
			continue
		}
		valueStart := idx + len(pattern)
		valueEnd := strings.Index(s[valueStart:], `"`)
		if valueEnd == -1 {
			continue
		}
		s = s[:valueStart] + "[REDACTED]" + s[valueStart+valueEnd:]
	}
	return s
}

// httpMethodToAction maps HTTP methods to audit action names.
func httpMethodToAction(method string) string {
	switch method {
	case http.MethodPost:
		return "Create"
	case http.MethodPut:
		return "Update"
	case http.MethodPatch:
		return "Patch"
	case http.MethodDelete:
		return "Delete"
	default:
		return method
	}
}

// extractResourceFromPath extracts a resource name from a URL path.
// e.g. "/api/v1/farms/123" -> "farms"
func extractResourceFromPath(path string) string {
	parts := strings.Split(strings.Trim(path, "/"), "/")
	// Skip common prefixes like "api", "v1", "v2"
	for i, part := range parts {
		if part == "api" || strings.HasPrefix(part, "v") && len(part) <= 3 {
			continue
		}
		if i < len(parts) {
			return parts[i]
		}
	}
	if len(parts) > 0 {
		return parts[len(parts)-1]
	}
	return "unknown"
}

// extractClientIPFromRequest gets the client IP from the request directly.
func extractClientIPFromRequest(r *http.Request) string {
	if xff := r.Header.Get("X-Forwarded-For"); xff != "" {
		if idx := strings.Index(xff, ","); idx != -1 {
			return strings.TrimSpace(xff[:idx])
		}
		return xff
	}
	if realIP := r.Header.Get("X-Real-IP"); realIP != "" {
		return realIP
	}
	// Strip port from RemoteAddr
	addr := r.RemoteAddr
	if idx := strings.LastIndex(addr, ":"); idx != -1 {
		return addr[:idx]
	}
	return addr
}
