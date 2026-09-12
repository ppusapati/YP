package gateway

import (
	"encoding/json"
	"fmt"
	"net"
	"net/http"
	"regexp"
	"strings"
	"sync"
)

type WAFConfig struct {
	MaxBodySize       int64    `json:"max_body_size"`
	EnableSQLi        bool     `json:"enable_sqli"`
	EnableXSS         bool     `json:"enable_xss"`
	EnablePathTraversal bool   `json:"enable_path_traversal"`
	IPAllowlist       []string `json:"ip_allowlist"`
	IPDenylist        []string `json:"ip_denylist"`
}

func DefaultWAFConfig() WAFConfig {
	return WAFConfig{
		MaxBodySize:       10 * 1024 * 1024, // 10MB
		EnableSQLi:        true,
		EnableXSS:         true,
		EnablePathTraversal: true,
	}
}

type WAF struct {
	config      WAFConfig
	allowNets   []*net.IPNet
	denyNets    []*net.IPNet
	mu          sync.RWMutex
	sqliPatterns []*regexp.Regexp
	xssPatterns  []*regexp.Regexp
	pathPatterns []*regexp.Regexp
}

func NewWAF(cfg WAFConfig) (*WAF, error) {
	w := &WAF{config: cfg}

	var err error
	w.allowNets, err = parseCIDRs(cfg.IPAllowlist)
	if err != nil {
		return nil, fmt.Errorf("parse allowlist: %w", err)
	}
	w.denyNets, err = parseCIDRs(cfg.IPDenylist)
	if err != nil {
		return nil, fmt.Errorf("parse denylist: %w", err)
	}

	w.sqliPatterns = compilePatterns([]string{
		`(?i)(\b(union|select|insert|update|delete|drop|alter|create|exec|execute)\b.*\b(from|into|table|database|where|set)\b)`,
		`(?i)(\b(or|and)\b\s+[\d'"].*=)`,
		`(?i)(;\s*(drop|delete|update|insert)\b)`,
		`(?i)('(\s|%20)*\b(or|and)\b(\s|%20)*'?\d)`,
		`(?i)('[\s+]*OR[\s+]*')`,
		`(?i)(--[\s+]|--$|#|/\*.*\*/)`,
	})

	w.xssPatterns = compilePatterns([]string{
		`(?i)(<\s*script[^>]*>)`,
		`(?i)(javascript\s*:)`,
		`(?i)(on(load|error|click|mouseover|submit|focus|blur)\s*=)`,
		`(?i)(<\s*iframe[^>]*>)`,
		`(?i)(<\s*object[^>]*>)`,
		`(?i)(<\s*embed[^>]*>)`,
		`(?i)(expression\s*\()`,
	})

	w.pathPatterns = compilePatterns([]string{
		`(\.\.[\\/])`,
		`(%2e%2e[\\/])`,
		`(%252e%252e[\\/])`,
		`(\.\.%2f)`,
		`(%2e%2e%2f)`,
	})

	return w, nil
}

func (w *WAF) Middleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(rw http.ResponseWriter, r *http.Request) {
		if reason := w.Check(r); reason != "" {
			http.Error(rw, fmt.Sprintf(`{"error":"blocked","reason":"%s"}`, reason), http.StatusForbidden)
			return
		}
		next.ServeHTTP(rw, r)
	})
}

func (w *WAF) Check(r *http.Request) string {
	clientIP := extractIP(r)

	if len(w.denyNets) > 0 && w.matchIP(clientIP, w.denyNets) {
		return "ip_denied"
	}

	if len(w.allowNets) > 0 && !w.matchIP(clientIP, w.allowNets) {
		return "ip_not_allowed"
	}

	if r.ContentLength > w.config.MaxBodySize {
		return "body_too_large"
	}

	if w.config.EnablePathTraversal {
		if w.matchPatterns(r.URL.Path, w.pathPatterns) {
			return "path_traversal"
		}
		if w.matchPatterns(r.URL.RawQuery, w.pathPatterns) {
			return "path_traversal"
		}
	}

	queryStr := r.URL.RawQuery
	if w.config.EnableSQLi && w.matchPatterns(queryStr, w.sqliPatterns) {
		return "sql_injection"
	}
	if w.config.EnableXSS && w.matchPatterns(queryStr, w.xssPatterns) {
		return "xss"
	}

	if r.Header.Get("Content-Type") == "application/json" && r.Body != nil {
		body := make([]byte, min(r.ContentLength, 65536))
		n, _ := r.Body.Read(body)
		bodyStr := string(body[:n])

		if w.config.EnableSQLi && w.matchPatterns(bodyStr, w.sqliPatterns) {
			return "sql_injection"
		}
		if w.config.EnableXSS && w.matchPatterns(bodyStr, w.xssPatterns) {
			return "xss"
		}
	}

	return ""
}

func (w *WAF) matchIP(ip string, nets []*net.IPNet) bool {
	parsed := net.ParseIP(ip)
	if parsed == nil {
		return false
	}
	for _, n := range nets {
		if n.Contains(parsed) {
			return true
		}
	}
	return false
}

func (w *WAF) matchPatterns(input string, patterns []*regexp.Regexp) bool {
	if input == "" {
		return false
	}
	for _, p := range patterns {
		if p.MatchString(input) {
			return true
		}
	}
	return false
}

func (w *WAF) UpdateDenylist(ips []string) error {
	nets, err := parseCIDRs(ips)
	if err != nil {
		return err
	}
	w.mu.Lock()
	w.denyNets = nets
	w.mu.Unlock()
	return nil
}

func extractIP(r *http.Request) string {
	if xff := r.Header.Get("X-Forwarded-For"); xff != "" {
		parts := strings.SplitN(xff, ",", 2)
		return strings.TrimSpace(parts[0])
	}
	if xri := r.Header.Get("X-Real-IP"); xri != "" {
		return xri
	}
	host, _, _ := net.SplitHostPort(r.RemoteAddr)
	return host
}

func parseCIDRs(entries []string) ([]*net.IPNet, error) {
	var nets []*net.IPNet
	for _, entry := range entries {
		if !strings.Contains(entry, "/") {
			entry += "/32"
		}
		_, ipNet, err := net.ParseCIDR(entry)
		if err != nil {
			return nil, fmt.Errorf("invalid CIDR %q: %w", entry, err)
		}
		nets = append(nets, ipNet)
	}
	return nets, nil
}

func compilePatterns(patterns []string) []*regexp.Regexp {
	compiled := make([]*regexp.Regexp, 0, len(patterns))
	for _, p := range patterns {
		compiled = append(compiled, regexp.MustCompile(p))
	}
	return compiled
}

// InspectJSONBody extracts string values from a JSON body for pattern matching.
func InspectJSONBody(body []byte) []string {
	var data map[string]interface{}
	if err := json.Unmarshal(body, &data); err != nil {
		return nil
	}
	return extractStrings(data)
}

func extractStrings(data map[string]interface{}) []string {
	var result []string
	for _, v := range data {
		switch val := v.(type) {
		case string:
			result = append(result, val)
		case map[string]interface{}:
			result = append(result, extractStrings(val)...)
		case []interface{}:
			for _, item := range val {
				if s, ok := item.(string); ok {
					result = append(result, s)
				}
				if m, ok := item.(map[string]interface{}); ok {
					result = append(result, extractStrings(m)...)
				}
			}
		}
	}
	return result
}
