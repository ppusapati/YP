package ai

import (
	"context"
	"fmt"
	"io"
	"net/http"
	"strings"
	"sync"
	"time"

	"p9e.in/samavaya/packages/urlsafe"
)

// The AI gateway is a pure compute service with no outbound network access: it
// classifies bytes it is handed and never fetches anything itself. That is a
// deliberate split — this service already owns the storage credentials and
// already validates every image URL it accepts, so putting the fetch here keeps
// SSRF defence in one place instead of reimplementing it in Rust.
//
// Without this step the gateway receives a URL and no bytes, and every local
// model is skipped: the vision pipeline silently falls through to the demo
// detectors no matter how good the trained models are.

// MaxImageBytes is the ceiling for a single image, whether it was fetched
// from a URL or sent inline. Generous for a phone photo, small enough that
// neither a hostile URL nor a hostile request can exhaust memory.
const MaxImageBytes = 16 << 20

const (
	maxImageBytes = MaxImageBytes

	fetchTimeout = 15 * time.Second

	// Whole-batch ceiling, so a request with many images cannot hold a
	// connection open indefinitely.
	batchTimeout = 45 * time.Second
)

// ImageFetcher loads image bytes for URLs that have already been validated.
type ImageFetcher struct {
	client *http.Client
}

// NewImageFetcher builds a fetcher with conservative transport settings.
//
// Redirects are refused rather than followed: a URL that passed validation can
// still redirect to somewhere that would not have, and re-validating every hop
// is easy to get subtly wrong.
func NewImageFetcher() *ImageFetcher {
	return &ImageFetcher{
		client: &http.Client{
			Timeout: fetchTimeout,
			CheckRedirect: func(req *http.Request, via []*http.Request) error {
				return fmt.Errorf("refusing redirect to %s", req.URL.Redacted())
			},
		},
	}
}

// Fetch returns the bytes behind one image URL.
func (f *ImageFetcher) Fetch(ctx context.Context, rawURL string) ([]byte, string, error) {
	if err := urlsafe.ValidateImageURL(rawURL); err != nil {
		return nil, "", fmt.Errorf("image URL rejected: %w", err)
	}
	// s3:// URLs need the storage client, not HTTP; callers that use them must
	// supply bytes themselves rather than have this guess at a mapping.
	if !strings.HasPrefix(rawURL, "https://") {
		return nil, "", fmt.Errorf("only https image URLs can be fetched directly")
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, rawURL, nil)
	if err != nil {
		return nil, "", fmt.Errorf("building image request: %w", err)
	}
	req.Header.Set("Accept", "image/*")

	resp, err := f.client.Do(req)
	if err != nil {
		return nil, "", fmt.Errorf("fetching image: %w", err)
	}
	defer resp.Body.Close()
	return readImageResponse(resp)
}

// readImageResponse turns a response into image bytes, or explains why it is
// not usable as one.
func readImageResponse(resp *http.Response) ([]byte, string, error) {
	if resp.StatusCode != http.StatusOK {
		return nil, "", fmt.Errorf("image fetch returned %d", resp.StatusCode)
	}

	// A missing content type is tolerated — some object stores omit it — but a
	// declared non-image one is a clear sign the URL points at something else.
	contentType := resp.Header.Get("Content-Type")
	if contentType != "" && !strings.HasPrefix(strings.ToLower(contentType), "image/") {
		return nil, "", fmt.Errorf("expected an image, got content type %q", contentType)
	}

	// One byte past the cap tells an oversized body apart from one that merely
	// fills it exactly.
	body, err := io.ReadAll(io.LimitReader(resp.Body, maxImageBytes+1))
	if err != nil {
		return nil, "", fmt.Errorf("reading image: %w", err)
	}
	if len(body) > maxImageBytes {
		return nil, "", fmt.Errorf("image exceeds the %d MB limit", maxImageBytes>>20)
	}
	if len(body) == 0 {
		return nil, "", fmt.Errorf("image is empty")
	}
	return body, contentType, nil
}

// FetchAll loads every image that carries a URL but no bytes.
//
// One failure does not sink the batch: a diagnosis over three photos where one
// URL has expired is better answered from the other two than refused outright.
// Images that could not be fetched are dropped and reported.
func (f *ImageFetcher) FetchAll(ctx context.Context, images []ImageInput) ([]ImageInput, []error) {
	ctx, cancel := context.WithTimeout(ctx, batchTimeout)
	defer cancel()

	out := make([]ImageInput, len(images))
	errs := make([]error, len(images))

	var wg sync.WaitGroup
	for i, img := range images {
		if len(img.Bytes) > 0 || img.ImageURL == "" {
			out[i] = img
			continue
		}
		wg.Add(1)
		go func(i int, img ImageInput) {
			defer wg.Done()
			body, contentType, err := f.Fetch(ctx, img.ImageURL)
			if err != nil {
				errs[i] = fmt.Errorf("%s: %w", img.ImageURL, err)
				return
			}
			img.Bytes = body
			if img.MimeType == "" {
				img.MimeType = contentType
			}
			out[i] = img
		}(i, img)
	}
	wg.Wait()

	fetched := make([]ImageInput, 0, len(images))
	failures := make([]error, 0)
	for i := range images {
		if errs[i] != nil {
			failures = append(failures, errs[i])
			continue
		}
		if len(out[i].Bytes) > 0 || out[i].ImageURL != "" {
			fetched = append(fetched, out[i])
		}
	}
	return fetched, failures
}
