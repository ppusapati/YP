package ai

import (
	"bytes"
	"context"
	"io"
	"net/http"
	"strings"
	"testing"
)

func response(status int, contentType string, body []byte) *http.Response {
	header := http.Header{}
	if contentType != "" {
		header.Set("Content-Type", contentType)
	}
	return &http.Response{
		StatusCode: status,
		Header:     header,
		Body:       io.NopCloser(bytes.NewReader(body)),
	}
}

func TestReadImageResponse_AcceptsAnImage(t *testing.T) {
	body := []byte{0x89, 'P', 'N', 'G', 0x0d}
	got, contentType, err := readImageResponse(response(200, "image/png", body))
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if !bytes.Equal(got, body) {
		t.Errorf("body = %v, want %v", got, body)
	}
	if contentType != "image/png" {
		t.Errorf("contentType = %q", contentType)
	}
}

func TestReadImageResponse_ToleratesMissingContentType(t *testing.T) {
	// Some object stores serve images with no declared type; that is not a
	// reason to refuse a body that is otherwise fine.
	got, _, err := readImageResponse(response(200, "", []byte{1, 2, 3}))
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if len(got) != 3 {
		t.Errorf("len(body) = %d, want 3", len(got))
	}
}

func TestReadImageResponse_RejectsNonImages(t *testing.T) {
	// An HTML error page served with 200 is the classic way a broken link
	// turns into a "diagnosis" of random pixels.
	_, _, err := readImageResponse(response(200, "text/html; charset=utf-8", []byte("<html>")))
	if err == nil || !strings.Contains(err.Error(), "content type") {
		t.Fatalf("expected a content-type rejection, got %v", err)
	}
}

func TestReadImageResponse_RejectsErrorsAndEmptyBodies(t *testing.T) {
	if _, _, err := readImageResponse(response(404, "image/png", []byte{1})); err == nil {
		t.Error("expected a 404 to be refused")
	}
	_, _, err := readImageResponse(response(200, "image/png", nil))
	if err == nil || !strings.Contains(err.Error(), "empty") {
		t.Fatalf("expected an empty-body rejection, got %v", err)
	}
}

func TestReadImageResponse_EnforcesTheSizeCap(t *testing.T) {
	// Exactly at the cap is fine; one byte over is not. A hostile URL must not
	// be able to hand us an unbounded body.
	atCap := bytes.Repeat([]byte{7}, maxImageBytes)
	if _, _, err := readImageResponse(response(200, "image/jpeg", atCap)); err != nil {
		t.Fatalf("a body exactly at the cap should be accepted: %v", err)
	}

	overCap := bytes.Repeat([]byte{7}, maxImageBytes+1)
	_, _, err := readImageResponse(response(200, "image/jpeg", overCap))
	if err == nil || !strings.Contains(err.Error(), "limit") {
		t.Fatalf("expected a size rejection, got %v", err)
	}
}

func TestFetch_RefusesUnsafeURLs(t *testing.T) {
	f := NewImageFetcher()
	ctx := context.Background()

	for _, tc := range []struct{ name, url string }{
		{"empty", ""},
		{"loopback", "https://127.0.0.1/leaf.jpg"},
		{"localhost", "https://localhost/leaf.jpg"},
		{"private", "https://10.0.0.5/leaf.jpg"},
		{"metadata endpoint", "https://169.254.169.254/latest/meta-data/"},
		{"credentials", "https://user:pass@example.com/leaf.jpg"},
		{"plain http", "http://example.com/leaf.jpg"},
	} {
		if _, _, err := f.Fetch(ctx, tc.url); err == nil {
			t.Errorf("%s: expected %q to be refused", tc.name, tc.url)
		}
	}
}

func TestFetch_RefusesSchemesItCannotRetrieve(t *testing.T) {
	// s3:// passes URL validation but needs the storage client, so guessing an
	// HTTPS mapping for it would be wrong rather than merely unsupported.
	_, _, err := NewImageFetcher().Fetch(context.Background(), "s3://bucket/leaf.jpg")
	if err == nil || !strings.Contains(err.Error(), "https") {
		t.Fatalf("expected an https-only rejection, got %v", err)
	}
}

func TestFetchAll_PassesThroughWhatItCannotOrNeedNotFetch(t *testing.T) {
	f := NewImageFetcher()

	// Bytes already present: no fetch is attempted, and they survive.
	already := ImageInput{ImageURL: "https://example.com/a.jpg", Bytes: []byte{1, 2, 3}}
	// No URL at all: nothing to fetch, nothing to fail.
	bytesOnly := ImageInput{Bytes: []byte{4, 5}}
	// A URL that cannot pass validation: dropped and reported.
	bad := ImageInput{ImageURL: "https://127.0.0.1/c.jpg"}

	out, errs := f.FetchAll(context.Background(), []ImageInput{already, bytesOnly, bad})

	if len(out) != 2 {
		t.Fatalf("kept %d images, want 2: %+v", len(out), out)
	}
	if !bytes.Equal(out[0].Bytes, []byte{1, 2, 3}) {
		t.Errorf("existing bytes were not preserved: %v", out[0].Bytes)
	}
	if len(errs) != 1 {
		t.Fatalf("reported %d failures, want 1", len(errs))
	}
	if !strings.Contains(errs[0].Error(), "127.0.0.1") {
		t.Errorf("failure should name the URL: %v", errs[0])
	}
}

func TestFetchAll_EmptyInputIsNotAnError(t *testing.T) {
	out, errs := NewImageFetcher().FetchAll(context.Background(), nil)
	if len(out) != 0 || len(errs) != 0 {
		t.Errorf("got %d images and %d errors, want none", len(out), len(errs))
	}
}
