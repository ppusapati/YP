// Package llm implements the LLMClient port against the Anthropic Messages API.
package llm

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"

	p9errors "p9e.in/samavaya/packages/errors"

	"p9e.in/samavaya/agriculture/advisory-service/internal/domain"
	"p9e.in/samavaya/agriculture/advisory-service/internal/ports/outbound"
)

// DefaultBaseURL is the Messages API.
//
// Overridable so a deployment can point this at a gateway, a regional endpoint
// or a compatible self-hosted server without a code change — the request shape
// is the same and the difference is entirely operational.
const DefaultBaseURL = "https://api.anthropic.com"

// apiVersion is the Messages API version header.
//
// Pinned rather than tracking latest. This header is what stops a change on
// the provider's side from silently altering the response shape underneath a
// running deployment.
const apiVersion = "2023-06-01"

// Config is what the client needs to run.
type Config struct {
	BaseURL     string
	APIKey      string
	Model       string
	MaxTokens   int
	Temperature float64
	Timeout     time.Duration
	Price       domain.ModelPrice
}

type anthropicClient struct {
	cfg  Config
	http *http.Client
}

// NewAnthropicClient creates a Messages API client.
func NewAnthropicClient(cfg Config) (outbound.LLMClient, error) {
	if strings.TrimSpace(cfg.APIKey) == "" {
		return nil, fmt.Errorf("llm: an API key is required")
	}
	if cfg.BaseURL == "" {
		cfg.BaseURL = DefaultBaseURL
	}
	if cfg.Model == "" {
		return nil, fmt.Errorf("llm: a model is required")
	}
	if cfg.MaxTokens <= 0 {
		cfg.MaxTokens = 1024
	}
	if cfg.Timeout <= 0 {
		cfg.Timeout = 30 * time.Second
	}
	return &anthropicClient{
		cfg:  cfg,
		http: &http.Client{Timeout: cfg.Timeout},
	}, nil
}

func (c *anthropicClient) Model() string            { return c.cfg.Model }
func (c *anthropicClient) Price() domain.ModelPrice { return c.cfg.Price }

// ── Wire types ───────────────────────────────────────────────────────────────

type wireRequest struct {
	Model       string        `json:"model"`
	MaxTokens   int           `json:"max_tokens"`
	System      string        `json:"system,omitempty"`
	Messages    []wireMessage `json:"messages"`
	Tools       []wireTool    `json:"tools,omitempty"`
	Temperature *float64      `json:"temperature,omitempty"`
}

type wireMessage struct {
	Role string `json:"role"`
	// Always a block list, never a bare string. A turn that carries a tool
	// result has to be a list anyway, and mixing the two forms across a
	// conversation is how a request that works for the first turn starts
	// failing on the third.
	Content []wireBlock `json:"content"`
}

type wireBlock struct {
	Type string `json:"type"`

	Text string `json:"text,omitempty"`

	// tool_use
	ID    string          `json:"id,omitempty"`
	Name  string          `json:"name,omitempty"`
	Input json.RawMessage `json:"input,omitempty"`

	// tool_result
	ToolUseID string `json:"tool_use_id,omitempty"`
	Content   string `json:"content,omitempty"`
	IsError   bool   `json:"is_error,omitempty"`
}

type wireTool struct {
	Name        string         `json:"name"`
	Description string         `json:"description"`
	InputSchema map[string]any `json:"input_schema"`
}

type wireResponse struct {
	ID         string      `json:"id"`
	Model      string      `json:"model"`
	StopReason string      `json:"stop_reason"`
	Content    []wireBlock `json:"content"`
	Usage      struct {
		InputTokens  int `json:"input_tokens"`
		OutputTokens int `json:"output_tokens"`
	} `json:"usage"`
	Error *struct {
		Type    string `json:"type"`
		Message string `json:"message"`
	} `json:"error"`
}

// Complete sends one request and returns what came back.
func (c *anthropicClient) Complete(ctx context.Context, req outbound.LLMRequest) (outbound.LLMResponse, error) {
	body := wireRequest{
		Model:     c.cfg.Model,
		MaxTokens: c.cfg.MaxTokens,
		System:    req.System,
		Messages:  make([]wireMessage, 0, len(req.Messages)),
	}
	if req.MaxTokens > 0 {
		body.MaxTokens = req.MaxTokens
	}
	if c.cfg.Temperature > 0 || req.Temperature > 0 {
		t := c.cfg.Temperature
		if req.Temperature > 0 {
			t = req.Temperature
		}
		body.Temperature = &t
	}

	for _, msg := range req.Messages {
		wire := wireMessage{Role: string(msg.Role)}

		// Tool results come first in the turn that carries them. The API
		// requires every tool_result to be at the start of the user message
		// that answers a tool_use, and putting text before them is rejected
		// for the whole request rather than ignored.
		for _, result := range msg.ToolResults {
			wire.Content = append(wire.Content, wireBlock{
				Type:      "tool_result",
				ToolUseID: result.ID,
				Content:   result.Content,
				IsError:   result.IsError,
			})
		}
		if strings.TrimSpace(msg.Text) != "" {
			wire.Content = append(wire.Content, wireBlock{Type: "text", Text: msg.Text})
		}
		for _, use := range msg.ToolUses {
			input := json.RawMessage(use.InputJSON)
			if len(input) == 0 {
				input = json.RawMessage(`{}`)
			}
			wire.Content = append(wire.Content, wireBlock{
				Type:  "tool_use",
				ID:    use.ID,
				Name:  use.Name,
				Input: input,
			})
		}
		if len(wire.Content) == 0 {
			// An empty turn is rejected by the API. Dropping it here keeps a
			// model turn that produced nothing but a stop reason from failing
			// the whole follow-up request.
			continue
		}
		body.Messages = append(body.Messages, wire)
	}

	for _, tool := range req.Tools {
		body.Tools = append(body.Tools, wireTool{
			Name:        tool.Name,
			Description: tool.Description,
			InputSchema: tool.InputSchema,
		})
	}

	payload, err := json.Marshal(body)
	if err != nil {
		return outbound.LLMResponse{}, p9errors.InternalServer("LLM_ENCODE_FAILED", "an internal error occurred")
	}

	httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost,
		strings.TrimSuffix(c.cfg.BaseURL, "/")+"/v1/messages", bytes.NewReader(payload))
	if err != nil {
		return outbound.LLMResponse{}, p9errors.InternalServer("LLM_REQUEST_FAILED", "an internal error occurred")
	}
	httpReq.Header.Set("content-type", "application/json")
	httpReq.Header.Set("x-api-key", c.cfg.APIKey)
	httpReq.Header.Set("anthropic-version", apiVersion)

	resp, err := c.http.Do(httpReq)
	if err != nil {
		return outbound.LLMResponse{}, p9errors.ServiceUnavailable("LLM_UNREACHABLE",
			"the advisory model could not be reached")
	}
	defer resp.Body.Close() //nolint:errcheck

	raw, err := io.ReadAll(io.LimitReader(resp.Body, 8<<20))
	if err != nil {
		return outbound.LLMResponse{}, p9errors.ServiceUnavailable("LLM_READ_FAILED",
			"the advisory model response could not be read")
	}

	var parsed wireResponse
	if err := json.Unmarshal(raw, &parsed); err != nil {
		return outbound.LLMResponse{}, p9errors.ServiceUnavailable("LLM_DECODE_FAILED",
			"the advisory model returned something unreadable")
	}

	if resp.StatusCode >= 400 {
		message := "the advisory model refused the request"
		if parsed.Error != nil && parsed.Error.Message != "" {
			message = parsed.Error.Message
		}
		switch {
		case resp.StatusCode == http.StatusTooManyRequests:
			return outbound.LLMResponse{}, p9errors.New(429, "LLM_RATE_LIMITED", message)
		case resp.StatusCode >= 500:
			return outbound.LLMResponse{}, p9errors.ServiceUnavailable("LLM_UPSTREAM_ERROR", message)
		default:
			return outbound.LLMResponse{}, p9errors.InternalServer("LLM_REQUEST_REJECTED", message)
		}
	}

	out := outbound.LLMResponse{
		StopReason:       parsed.StopReason,
		Model:            parsed.Model,
		PromptTokens:     parsed.Usage.InputTokens,
		CompletionTokens: parsed.Usage.OutputTokens,
	}
	if out.Model == "" {
		out.Model = c.cfg.Model
	}

	var text strings.Builder
	for _, block := range parsed.Content {
		switch block.Type {
		case "text":
			text.WriteString(block.Text)
		case "tool_use":
			out.ToolUses = append(out.ToolUses, outbound.LLMToolUse{
				ID:        block.ID,
				Name:      block.Name,
				InputJSON: string(block.Input),
			})
		}
	}
	out.Text = strings.TrimSpace(text.String())
	return out, nil
}
