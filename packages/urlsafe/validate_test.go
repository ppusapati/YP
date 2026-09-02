package urlsafe

import (
	"strings"
	"testing"
)

func TestValidateImageURL_ValidURLs(t *testing.T) {
	valid := []string{
		"https://cdn.example.com/images/leaf.jpg",
		"https://storage.googleapis.com/bucket/photo.png",
		"https://my-bucket.s3.amazonaws.com/image.jpg",
		"s3://my-bucket/path/to/image.tiff",
		"https://203.0.113.50/image.jpg", // TEST-NET-3 (documentation range, not private)
	}

	for _, u := range valid {
		if err := ValidateImageURL(u); err != nil {
			t.Errorf("ValidateImageURL(%q) = %v; want nil", u, err)
		}
	}
}

func TestValidateImageURL_EmptyURL(t *testing.T) {
	err := ValidateImageURL("")
	if err == nil {
		t.Fatal("expected error for empty URL")
	}
}

func TestValidateImageURL_BlockedSchemes(t *testing.T) {
	blocked := []string{
		"http://example.com/image.jpg",
		"ftp://files.example.com/image.jpg",
		"file:///etc/passwd",
		"javascript:alert(1)",
		"data:image/png;base64,abc",
		"gopher://evil.com/",
	}

	for _, u := range blocked {
		err := ValidateImageURL(u)
		if err == nil {
			t.Errorf("ValidateImageURL(%q) = nil; want error", u)
		}
		if err != nil && !strings.Contains(err.Error(), "not allowed") {
			t.Errorf("ValidateImageURL(%q) = %v; want scheme error", u, err)
		}
	}
}

func TestValidateImageURL_BlockedPrivateIPs(t *testing.T) {
	blocked := []string{
		"https://127.0.0.1/image.jpg",
		"https://10.0.0.1/image.jpg",
		"https://172.16.0.1/image.jpg",
		"https://192.168.1.1/image.jpg",
		"https://169.254.169.254/latest/meta-data/",
		"https://[::1]/image.jpg",
		"https://[fd00:ec2::254]/latest/meta-data/",
		"https://0.0.0.0/image.jpg",
	}

	for _, u := range blocked {
		err := ValidateImageURL(u)
		if err == nil {
			t.Errorf("ValidateImageURL(%q) = nil; want error for private/internal IP", u)
		}
	}
}

func TestValidateImageURL_BlockedHosts(t *testing.T) {
	blocked := []string{
		"https://localhost/image.jpg",
		"https://sub.localhost/image.jpg",
		"https://metadata.google.internal/computeMetadata/v1/",
		"https://kubernetes.default.svc/api",
		"https://kubernetes.default.svc.cluster.local/api",
	}

	for _, u := range blocked {
		err := ValidateImageURL(u)
		if err == nil {
			t.Errorf("ValidateImageURL(%q) = nil; want error", u)
		}
	}
}

func TestValidateImageURL_BlocksCredentials(t *testing.T) {
	err := ValidateImageURL("https://user:pass@evil.com/image.jpg")
	if err == nil {
		t.Fatal("expected error for URL with credentials")
	}
	if !strings.Contains(err.Error(), "credentials") {
		t.Errorf("unexpected error: %v", err)
	}
}

func TestValidateImageURL_BlocksFragments(t *testing.T) {
	err := ValidateImageURL("https://example.com/image.jpg#fragment")
	if err == nil {
		t.Fatal("expected error for URL with fragment")
	}
}

func TestValidateImageURLs_Mixed(t *testing.T) {
	urls := []string{
		"https://cdn.example.com/a.jpg",
		"https://127.0.0.1/b.jpg",
	}
	err := ValidateImageURLs(urls)
	if err == nil {
		t.Fatal("expected error for batch with blocked URL")
	}
	if !strings.Contains(err.Error(), "image_urls[1]") {
		t.Errorf("error should reference index 1: %v", err)
	}
}

func TestValidateImageURLs_AllValid(t *testing.T) {
	urls := []string{
		"https://cdn.example.com/a.jpg",
		"s3://bucket/b.tiff",
	}
	if err := ValidateImageURLs(urls); err != nil {
		t.Errorf("ValidateImageURLs = %v; want nil", err)
	}
}
