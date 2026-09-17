// Package embedding implements the Embedder port.
//
// Two implementations, and the service logs which one it is using at startup.
// That log line matters: the two are not equivalent, and a corpus indexed by
// one and queried by the other retrieves nothing useful while looking entirely
// healthy — no error, no empty result, just consistently poor answers.
package embedding

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"sort"
	"strings"
	"time"

	"p9e.in/samavaya/agriculture/advisory-service/internal/domain"
	"p9e.in/samavaya/agriculture/advisory-service/internal/ports/outbound"
)

// ── Lexical ──────────────────────────────────────────────────────────────────

type lexicalEmbedder struct{ dim int }

// NewLexicalEmbedder builds vectors locally by feature hashing.
//
// Not a semantic embedder, and the name says so wherever it appears. It will
// match "urea top dressing" to "top dressing with urea" and will not match it
// to "nitrogen application". It exists so a deployment with no embedding
// endpoint still retrieves — badly, but visibly, with the same code path as
// the real thing — instead of having an empty context and an assistant that
// refuses every question.
func NewLexicalEmbedder(dim int) outbound.Embedder {
	if dim <= 0 {
		dim = domain.DefaultEmbeddingDim
	}
	return &lexicalEmbedder{dim: dim}
}

func (e *lexicalEmbedder) Dim() int     { return e.dim }
func (e *lexicalEmbedder) Name() string { return fmt.Sprintf("lexical-hash-%d", e.dim) }

func (e *lexicalEmbedder) Embed(_ context.Context, texts []string) ([][]float32, error) {
	out := make([][]float32, len(texts))
	for i, text := range texts {
		out[i] = domain.LexicalVector(text, e.dim)
	}
	return out, nil
}

// ── HTTP ─────────────────────────────────────────────────────────────────────

// HTTPConfig points at an OpenAI-compatible embeddings endpoint.
type HTTPConfig struct {
	URL     string
	APIKey  string
	Model   string
	Dim     int
	Timeout time.Duration
	// BatchSize bounds one request. Embedding a 500-chunk document in a single
	// call is a request body large enough to be rejected by some proxies and
	// slow enough to time out behind others, and the failure arrives after the
	// whole document has been chunked.
	BatchSize int
}

type httpEmbedder struct {
	cfg  HTTPConfig
	http *http.Client
}

// NewHTTPEmbedder calls a hosted embedding model.
func NewHTTPEmbedder(cfg HTTPConfig) (outbound.Embedder, error) {
	if strings.TrimSpace(cfg.URL) == "" {
		return nil, fmt.Errorf("embedding: a URL is required")
	}
	if cfg.Dim <= 0 {
		cfg.Dim = domain.DefaultEmbeddingDim
	}
	if cfg.Timeout <= 0 {
		cfg.Timeout = 30 * time.Second
	}
	if cfg.BatchSize <= 0 {
		cfg.BatchSize = 32
	}
	return &httpEmbedder{cfg: cfg, http: &http.Client{Timeout: cfg.Timeout}}, nil
}

func (e *httpEmbedder) Dim() int { return e.cfg.Dim }

func (e *httpEmbedder) Name() string {
	if e.cfg.Model != "" {
		return e.cfg.Model
	}
	return "http-embedder"
}

type embedRequest struct {
	Model string   `json:"model,omitempty"`
	Input []string `json:"input"`
}

type embedResponse struct {
	Data []struct {
		Index     int       `json:"index"`
		Embedding []float32 `json:"embedding"`
	} `json:"data"`
	Error *struct {
		Message string `json:"message"`
	} `json:"error"`
}

func (e *httpEmbedder) Embed(ctx context.Context, texts []string) ([][]float32, error) {
	out := make([][]float32, 0, len(texts))
	for start := 0; start < len(texts); start += e.cfg.BatchSize {
		end := start + e.cfg.BatchSize
		if end > len(texts) {
			end = len(texts)
		}
		batch, err := e.embedBatch(ctx, texts[start:end])
		if err != nil {
			return nil, err
		}
		out = append(out, batch...)
	}
	return out, nil
}

func (e *httpEmbedder) embedBatch(ctx context.Context, texts []string) ([][]float32, error) {
	payload, err := json.Marshal(embedRequest{Model: e.cfg.Model, Input: texts})
	if err != nil {
		return nil, err
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, e.cfg.URL, bytes.NewReader(payload))
	if err != nil {
		return nil, err
	}
	req.Header.Set("content-type", "application/json")
	if e.cfg.APIKey != "" {
		req.Header.Set("authorization", "Bearer "+e.cfg.APIKey)
	}

	resp, err := e.http.Do(req)
	if err != nil {
		return nil, fmt.Errorf("embedding: %w", err)
	}
	defer resp.Body.Close() //nolint:errcheck

	raw, err := io.ReadAll(io.LimitReader(resp.Body, 32<<20))
	if err != nil {
		return nil, fmt.Errorf("embedding: reading response: %w", err)
	}

	var parsed embedResponse
	if err := json.Unmarshal(raw, &parsed); err != nil {
		return nil, fmt.Errorf("embedding: unreadable response (status %d)", resp.StatusCode)
	}
	if resp.StatusCode >= 400 {
		if parsed.Error != nil {
			return nil, fmt.Errorf("embedding: %s", parsed.Error.Message)
		}
		return nil, fmt.Errorf("embedding: status %d", resp.StatusCode)
	}
	if len(parsed.Data) != len(texts) {
		return nil, fmt.Errorf("embedding: asked for %d vectors, got %d", len(texts), len(parsed.Data))
	}

	// Ordered by the index the endpoint reports, not by arrival. The
	// specification allows any order, and a provider that returns them
	// out of order would silently attach every chunk's vector to a
	// different chunk — retrieval would still work, and would cite the
	// wrong passage every time.
	sort.Slice(parsed.Data, func(i, j int) bool { return parsed.Data[i].Index < parsed.Data[j].Index })

	out := make([][]float32, len(parsed.Data))
	for i, item := range parsed.Data {
		if len(item.Embedding) != e.cfg.Dim {
			// Rejected rather than padded or truncated. A vector of the wrong
			// width still has a cosine similarity, and the ranking it produces
			// is indistinguishable from a corpus of weak matches.
			return nil, fmt.Errorf(
				"embedding: model returned %d dimensions but the schema stores %d — "+
					"reindex the corpus or set EMBEDDING_DIM to match",
				len(item.Embedding), e.cfg.Dim)
		}
		out[i] = item.Embedding
	}
	return out, nil
}
