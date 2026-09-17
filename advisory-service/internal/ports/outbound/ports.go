// Package outbound defines the secondary ports for advisory-service.
package outbound

import (
	"context"
	"time"

	"p9e.in/samavaya/agriculture/advisory-service/internal/domain"
)

// ConversationRepository persists conversations and the exchanges in them.
type ConversationRepository interface {
	CreateConversation(ctx context.Context, c *domain.Conversation) (*domain.Conversation, error)
	GetConversation(ctx context.Context, id, tenantID string) (*domain.Conversation, error)
	ListConversations(ctx context.Context, params domain.ListConversationsParams) ([]domain.Conversation, int64, error)
	TouchConversation(ctx context.Context, id, tenantID string, at time.Time) error

	// AppendExchange stores one question, its answer and everything that went
	// into it. Every exchange is logged, including refusals and budget
	// rejections: a review queue that only contains the answers the service
	// was willing to give cannot show what it declined to answer, which is
	// half of what a reviewer needs to see.
	AppendExchange(ctx context.Context, e *domain.Exchange) (*domain.Exchange, error)
	GetExchange(ctx context.Context, id, tenantID string) (*domain.Exchange, error)
	ListExchanges(ctx context.Context, params domain.ListExchangesParams) ([]domain.Exchange, int64, error)
	ReviewExchange(ctx context.Context, id, tenantID, reviewer, note string, rating int, at time.Time) (*domain.Exchange, error)
}

// DocumentRepository stores reference material and searches it.
type DocumentRepository interface {
	CreateDocument(ctx context.Context, d *domain.ReferenceDocument, chunks []domain.Chunk) (*domain.ReferenceDocument, error)
	ListDocuments(ctx context.Context, params domain.ListDocumentsParams) ([]domain.ReferenceDocument, int64, error)
	DeleteDocument(ctx context.Context, id, tenantID string) (bool, error)

	// SearchChunks returns the passages nearest the query vector.
	//
	// tenantID is a parameter rather than something the query infers, and the
	// implementation must filter on it in SQL even though row-level security
	// already does. Two independent filters on a boundary that must not be
	// crossed is cheap; discovering that the session variable was not set on
	// one code path is not.
	SearchChunks(ctx context.Context, q ChunkQuery) ([]domain.Citation, error)
}

// ChunkQuery is one retrieval over the reference corpus.
type ChunkQuery struct {
	TenantID string
	// Vector is empty when no embedder produced one, in which case the
	// implementation falls back to a lexical search rather than returning
	// nothing.
	Vector    []float32
	QueryText string
	Locale    domain.Locale
	Crop      string
	Region    string
	Limit     int
}

// BudgetRepository stores each tenant's ceiling and what it has spent today.
type BudgetRepository interface {
	GetBudget(ctx context.Context, tenantID string) (domain.Budget, error)
	SetBudget(ctx context.Context, b domain.Budget) (domain.Budget, error)
	// RecordSpend adds one exchange's usage inside the database rather than
	// read-modify-writing it here. Two questions asked at the same moment from
	// two phones would otherwise each read the same starting figure and write
	// back the same total, and the tenant would be charged for one of them.
	RecordSpend(ctx context.Context, tenantID string, windowStart time.Time, u domain.Usage) (domain.Budget, error)
}

// Embedder turns text into a vector.
type Embedder interface {
	Embed(ctx context.Context, texts []string) ([][]float32, error)
	// Dim is the width every vector this embedder produces has, which has to
	// match the column the migration created.
	Dim() int
	// Name goes into the startup log and into the document row, so a corpus
	// indexed by one embedder and queried by another is identifiable rather
	// than merely bad.
	Name() string
}

// ── LLM ──────────────────────────────────────────────────────────────────────

// LLMRole is who said a message.
type LLMRole string

const (
	RoleUser      LLMRole = "user"
	RoleAssistant LLMRole = "assistant"
)

// LLMToolSpec describes a tool the model may call.
type LLMToolSpec struct {
	Name        string
	Description string
	// InputSchema is a JSON Schema object.
	InputSchema map[string]any
}

// LLMToolUse is the model asking for a tool to be run.
type LLMToolUse struct {
	ID        string
	Name      string
	InputJSON string
}

// LLMToolResult is what came back.
type LLMToolResult struct {
	ID      string
	Content string
	IsError bool
}

// LLMMessage is one turn.
type LLMMessage struct {
	Role        LLMRole
	Text        string
	ToolUses    []LLMToolUse
	ToolResults []LLMToolResult
}

// LLMRequest is one call to the model.
type LLMRequest struct {
	System      string
	Messages    []LLMMessage
	Tools       []LLMToolSpec
	MaxTokens   int
	Temperature float64
}

// LLMResponse is what came back.
type LLMResponse struct {
	Text             string
	ToolUses         []LLMToolUse
	StopReason       string
	Model            string
	PromptTokens     int
	CompletionTokens int
}

// LLMClient is the secondary port for a language model.
//
// Optional by design. With no model configured the service still retrieves,
// still enforces tenant isolation, still evaluates and still logs — it just
// answers extractively and says so. The alternative, refusing to start, would
// make the whole advisory surface unavailable in every deployment that has not
// bought a model subscription.
type LLMClient interface {
	Complete(ctx context.Context, req LLMRequest) (LLMResponse, error)
	Model() string
	Price() domain.ModelPrice
}

// ── Tools ────────────────────────────────────────────────────────────────────

// Tool is one capability the assistant can call into.
type Tool interface {
	Name() string
	Description() string
	InputSchema() map[string]any
	// Call runs the tool. The returned JSON is put in front of the model and
	// stored on the exchange, so it has to be something a person reviewing the
	// answer can read.
	Call(ctx context.Context, argumentsJSON string) (string, error)
	// Citation describes the result as a source, so a figure the model got
	// from a service is traceable in the same way a document is.
	Citation(argumentsJSON, resultJSON string) domain.Citation
}

// FarmContextSource pulls the tenant's own records for a question.
//
// Separate from Tool because this runs unconditionally before the model is
// called: the farmer's field, its crop, its open alerts and its latest
// diagnosis are what makes the answer about them rather than about farming in
// general, and waiting for the model to think to ask for them means most
// answers never get them.
type FarmContextSource interface {
	Name() string
	Fetch(ctx context.Context, q FarmContextQuery) ([]domain.Citation, error)
}

// FarmContextQuery is the anchor for a record lookup.
type FarmContextQuery struct {
	TenantID string
	FieldID  string
	FarmID   string
	Question string
	Locale   domain.Locale
}

// EventPublisher is the secondary port for emitting domain events.
type EventPublisher interface {
	Publish(ctx context.Context, topic, key string, payload []byte) error
}
