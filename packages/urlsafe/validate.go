package urlsafe

import (
	"fmt"
	"net"
	"net/url"
	"strings"
)

var allowedSchemes = map[string]bool{
	"https": true,
	"s3":    true,
}

var blockedHosts = map[string]bool{
	"metadata.google.internal":        true,
	"metadata.google.internal.":       true,
	"kubernetes.default.svc":          true,
	"kubernetes.default.svc.":         true,
	"kubernetes.default.svc.cluster.local":  true,
	"kubernetes.default.svc.cluster.local.": true,
}

func ValidateImageURL(rawURL string) error {
	if rawURL == "" {
		return fmt.Errorf("image URL is empty")
	}

	parsed, err := url.Parse(rawURL)
	if err != nil {
		return fmt.Errorf("invalid URL: %w", err)
	}

	if !allowedSchemes[parsed.Scheme] {
		return fmt.Errorf("scheme %q is not allowed; use https or s3", parsed.Scheme)
	}

	if parsed.User != nil {
		return fmt.Errorf("URLs with credentials are not allowed")
	}

	hostname := parsed.Hostname()
	if hostname == "" {
		return fmt.Errorf("URL has no hostname")
	}

	lower := strings.ToLower(hostname)

	if lower == "localhost" || strings.HasSuffix(lower, ".localhost") {
		return fmt.Errorf("localhost URLs are not allowed")
	}

	if blockedHosts[lower] {
		return fmt.Errorf("hostname %q is blocked", hostname)
	}

	ip := net.ParseIP(hostname)
	if ip != nil {
		if isBlockedIP(ip) {
			return fmt.Errorf("IP address %s is not allowed", hostname)
		}
	}

	if parsed.Fragment != "" {
		return fmt.Errorf("URL fragments are not allowed")
	}

	return nil
}

func ValidateImageURLs(urls []string) error {
	for i, u := range urls {
		if err := ValidateImageURL(u); err != nil {
			return fmt.Errorf("image_urls[%d]: %w", i, err)
		}
	}
	return nil
}

func isBlockedIP(ip net.IP) bool {
	if ip.IsLoopback() || ip.IsPrivate() || ip.IsLinkLocalUnicast() || ip.IsLinkLocalMulticast() || ip.IsUnspecified() {
		return true
	}

	// Cloud metadata endpoint: 169.254.169.254
	if ip.Equal(net.ParseIP("169.254.169.254")) {
		return true
	}

	// AWS IMDSv2 alternative
	if ip.Equal(net.ParseIP("fd00:ec2::254")) {
		return true
	}

	return false
}
