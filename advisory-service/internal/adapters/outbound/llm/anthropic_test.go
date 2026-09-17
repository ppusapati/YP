package llm

import (
	"context"
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"p9e.in/samavaya/agriculture/advisory-service/internal/ports/outbound"
)

func TestCompleteSendsTheRequiredHeadersAndPath(t *testing.T) {
	var gotPath, gotKey, gotVersion string

	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		gotPath = r.URL.Path
		gotKey = r.Header.Get("x-api-key")
		gotVersion = r.Header.Get("anthropic-version")
		_, _ = w.Write([]byte(`{"content":[{"type":"text","text":"ok"}],"stop_reason":"end_turn"}`))
	}))
	defer server.Close()

	client, err := NewAnthropicClient(Config{BaseURL: server.URL, APIKey: "k", Model: "m"})
	if err != nil {
		t.Fatal(err)
	}
	if _, err := client.Complete(context.Background(), outbound.LLMRequest{
		Messages: []outbound.LLMMessage{{Role: outbound.RoleUser, Text: "hello"}},
	}); err != nil {
		t.Fatal(err)
	}

	if gotPath != "/v1/messages" {
		t.Errorf("path = %q", gotPath)
	}
	if gotKey != "k" {
		t.Errorf("x-api-key = %q", gotKey)
	}
	// Pinned, not "latest": this header is what stops a provider-side change
	// from altering the response shape under a running deployment.
	if gotVersion != apiVersion {
		t.Errorf("anthropic-version = %q, want %q", gotVersion, apiVersion)
	}
}

func TestCompleteParsesTextAndUsage(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		_, _ = w.Write([]byte(`{
			"model": "served-model",
			"stop_reason": "end_turn",
			"content": [{"type":"text","text":"Apply urea "},{"type":"text","text":"at 60 kg/ha [1]."}],
			"usage": {"input_tokens": 512, "output_tokens": 48}
		}`))
	}))
	defer server.Close()

	client, _ := NewAnthropicClient(Config{BaseURL: server.URL, APIKey: "k", Model: "configured-model"})
	resp, err := client.Complete(context.Background(), outbound.LLMRequest{
		Messages: []outbound.LLMMessage{{Role: outbound.RoleUser, Text: "q"}},
	})
	if err != nil {
		t.Fatal(err)
	}

	if resp.Text != "Apply urea at 60 kg/ha [1]." {
		t.Errorf("text = %q — multiple text blocks should be joined", resp.Text)
	}
	if resp.PromptTokens != 512 || resp.CompletionTokens != 48 {
		t.Errorf("usage = %d/%d", resp.PromptTokens, resp.CompletionTokens)
	}
	// The model that actually served, not the one asked for. They differ when
	// a provider aliases a version, and billing against the wrong one is a
	// budget enforced on a price that was never charged.
	if resp.Model != "served-model" {
		t.Errorf("model = %q", resp.Model)
	}
}

func TestCompleteParsesToolUse(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		_, _ = w.Write([]byte(`{
			"stop_reason": "tool_use",
			"content": [
				{"type":"text","text":"Let me check."},
				{"type":"tool_use","id":"tu_1","name":"yield_forecast","input":{"field_id":"F1"}}
			]
		}`))
	}))
	defer server.Close()

	client, _ := NewAnthropicClient(Config{BaseURL: server.URL, APIKey: "k", Model: "m"})
	resp, err := client.Complete(context.Background(), outbound.LLMRequest{
		Messages: []outbound.LLMMessage{{Role: outbound.RoleUser, Text: "q"}},
		Tools: []outbound.LLMToolSpec{{
			Name:        "yield_forecast",
			Description: "forecast",
			InputSchema: map[string]any{"type": "object"},
		}},
	})
	if err != nil {
		t.Fatal(err)
	}

	if len(resp.ToolUses) != 1 {
		t.Fatalf("tool uses = %d", len(resp.ToolUses))
	}
	if resp.ToolUses[0].ID != "tu_1" || resp.ToolUses[0].Name != "yield_forecast" {
		t.Errorf("tool use = %+v", resp.ToolUses[0])
	}
	if !strings.Contains(resp.ToolUses[0].InputJSON, `"field_id"`) {
		t.Errorf("input json = %q", resp.ToolUses[0].InputJSON)
	}
}

func TestToolResultsComeFirstInTheirTurn(t *testing.T) {
	// The API requires every tool_result to be at the start of the user
	// message that answers a tool_use. Text before them is not ignored — the
	// whole request is rejected, so this ordering is the difference between a
	// working tool loop and one that fails on its second iteration.
	var sent wireRequest

	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		raw, _ := io.ReadAll(r.Body)
		_ = json.Unmarshal(raw, &sent)
		_, _ = w.Write([]byte(`{"content":[{"type":"text","text":"done"}],"stop_reason":"end_turn"}`))
	}))
	defer server.Close()

	client, _ := NewAnthropicClient(Config{BaseURL: server.URL, APIKey: "k", Model: "m"})
	_, err := client.Complete(context.Background(), outbound.LLMRequest{
		Messages: []outbound.LLMMessage{
			{Role: outbound.RoleUser, Text: "question"},
			{Role: outbound.RoleAssistant, Text: "checking", ToolUses: []outbound.LLMToolUse{
				{ID: "tu_1", Name: "yield_forecast", InputJSON: `{"field_id":"F1"}`},
			}},
			{Role: outbound.RoleUser, Text: "trailing text", ToolResults: []outbound.LLMToolResult{
				{ID: "tu_1", Content: "[1] yield_forecast\n{}"},
			}},
		},
	})
	if err != nil {
		t.Fatal(err)
	}

	if len(sent.Messages) != 3 {
		t.Fatalf("messages = %d", len(sent.Messages))
	}
	last := sent.Messages[2]
	if len(last.Content) == 0 || last.Content[0].Type != "tool_result" {
		t.Fatalf("the tool result must be the first block, got %+v", last.Content)
	}
	if last.Content[0].ToolUseID != "tu_1" {
		t.Errorf("tool_use_id = %q", last.Content[0].ToolUseID)
	}
}

func TestToolUseWithNoInputSendsAnEmptyObject(t *testing.T) {
	// An absent `input` is rejected by the API. A tool with no required
	// arguments is the normal case for something like "list open alerts", so
	// this is not an edge case at all.
	var sent wireRequest

	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		raw, _ := io.ReadAll(r.Body)
		_ = json.Unmarshal(raw, &sent)
		_, _ = w.Write([]byte(`{"content":[{"type":"text","text":"done"}],"stop_reason":"end_turn"}`))
	}))
	defer server.Close()

	client, _ := NewAnthropicClient(Config{BaseURL: server.URL, APIKey: "k", Model: "m"})
	_, _ = client.Complete(context.Background(), outbound.LLMRequest{
		Messages: []outbound.LLMMessage{
			{Role: outbound.RoleAssistant, ToolUses: []outbound.LLMToolUse{{ID: "tu_1", Name: "open_alerts"}}},
		},
	})

	if len(sent.Messages) != 1 {
		t.Fatalf("messages = %d", len(sent.Messages))
	}
	if got := string(sent.Messages[0].Content[0].Input); got != "{}" {
		t.Errorf("input = %q, want {}", got)
	}
}

func TestEmptyTurnsAreDropped(t *testing.T) {
	var sent wireRequest

	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		raw, _ := io.ReadAll(r.Body)
		_ = json.Unmarshal(raw, &sent)
		_, _ = w.Write([]byte(`{"content":[{"type":"text","text":"done"}],"stop_reason":"end_turn"}`))
	}))
	defer server.Close()

	client, _ := NewAnthropicClient(Config{BaseURL: server.URL, APIKey: "k", Model: "m"})
	_, _ = client.Complete(context.Background(), outbound.LLMRequest{
		Messages: []outbound.LLMMessage{
			{Role: outbound.RoleUser, Text: "question"},
			{Role: outbound.RoleAssistant, Text: "   "},
		},
	})

	if len(sent.Messages) != 1 {
		t.Fatalf("an empty turn should be dropped, got %d messages", len(sent.Messages))
	}
}

func TestRateLimitIsDistinguishedFromOtherFailures(t *testing.T) {
	// A 429 is transient and a 400 is not, and an operator reading "the model
	// refused the request" for both cannot tell whether to wait or to fix
	// something.
	for status, wantCode := range map[int]string{
		http.StatusTooManyRequests:     "LLM_RATE_LIMITED",
		http.StatusBadRequest:          "LLM_REQUEST_REJECTED",
		http.StatusInternalServerError: "LLM_UPSTREAM_ERROR",
	} {
		server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
			w.WriteHeader(status)
			_, _ = w.Write([]byte(`{"error":{"type":"x","message":"upstream said no"}}`))
		}))

		client, _ := NewAnthropicClient(Config{BaseURL: server.URL, APIKey: "k", Model: "m"})
		_, err := client.Complete(context.Background(), outbound.LLMRequest{
			Messages: []outbound.LLMMessage{{Role: outbound.RoleUser, Text: "q"}},
		})
		server.Close()

		if err == nil {
			t.Fatalf("status %d should be an error", status)
		}
		if !strings.Contains(err.Error(), wantCode) {
			t.Errorf("status %d gave %q, expected reason %s", status, err.Error(), wantCode)
		}
	}
}

func TestAnAPIKeyIsRequired(t *testing.T) {
	// Refusing to build beats building a client that 401s on the first real
	// question a farmer asks.
	if _, err := NewAnthropicClient(Config{Model: "m"}); err == nil {
		t.Error("expected an error when no API key is set")
	}
	if _, err := NewAnthropicClient(Config{APIKey: "k"}); err == nil {
		t.Error("expected an error when no model is set")
	}
}
