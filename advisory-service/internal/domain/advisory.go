// Package domain holds advisory-service's entities and the agronomy-independent
// logic the service is built on: retrieval scoring, groundedness evaluation and
// budget arithmetic.
package domain

import (
	"strings"
	"time"

	p9errors "p9e.in/samavaya/packages/errors"
)

// CitationKind says what a citation points at.
type CitationKind string

const (
	CitationDocument      CitationKind = "DOCUMENT"
	CitationField         CitationKind = "FIELD"
	CitationPrescription  CitationKind = "PRESCRIPTION"
	CitationAlert         CitationKind = "ALERT"
	CitationWeather       CitationKind = "WEATHER"
	CitationDiagnosis     CitationKind = "DIAGNOSIS"
	CitationYieldForecast CitationKind = "YIELD_FORECAST"
	CitationIrrigation    CitationKind = "IRRIGATION"
	CitationPestRisk      CitationKind = "PEST_RISK"
	CitationSoil          CitationKind = "SOIL"
)

// AnswerKind is how an answer was produced.
type AnswerKind string

const (
	AnswerGenerated  AnswerKind = "GENERATED"
	AnswerExtractive AnswerKind = "EXTRACTIVE"
	AnswerRefused    AnswerKind = "REFUSED"
)

// GroundednessVerdict is the evaluator's read on an answer.
type GroundednessVerdict string

const (
	VerdictGrounded   GroundednessVerdict = "GROUNDED"
	VerdictPartial    GroundednessVerdict = "PARTIAL"
	VerdictUngrounded GroundednessVerdict = "UNGROUNDED"
)

// DocumentKind is what a piece of reference material is.
type DocumentKind string

const (
	DocAgronomyReference DocumentKind = "AGRONOMY_REFERENCE"
	DocCropGuide         DocumentKind = "CROP_GUIDE"
	DocRegionalAdvisory  DocumentKind = "REGIONAL_ADVISORY"
	DocPackageOfPractice DocumentKind = "PACKAGE_OF_PRACTICES"
)

// Citation is one thing the answer is allowed to lean on.
type Citation struct {
	ID       string       `json:"id"`
	TenantID string       `json:"tenant_id"`
	Kind     CitationKind `json:"kind"`
	Title    string       `json:"title"`
	Snippet  string       `json:"snippet"`
	URI      string       `json:"uri"`
	SourceID string       `json:"source_id"`
	Score    float64      `json:"score"`
	Marker   int          `json:"marker"`
	Locale   Locale       `json:"locale"`
}

// ToolCall records one call the assistant made into another service.
type ToolCall struct {
	Name          string        `json:"name"`
	ArgumentsJSON string        `json:"arguments_json"`
	ResultJSON    string        `json:"result_json"`
	OK            bool          `json:"ok"`
	Error         string        `json:"error,omitempty"`
	Latency       time.Duration `json:"latency"`
}

// UnsupportedClaim is a sentence the evaluator could not tie to the context.
type UnsupportedClaim struct {
	Text   string `json:"text"`
	Reason string `json:"reason"`
}

// Evaluation is the automated check that runs on every answer.
type Evaluation struct {
	Verdict            GroundednessVerdict `json:"verdict"`
	Groundedness       float64             `json:"groundedness"`
	Unsupported        []UnsupportedClaim  `json:"unsupported,omitempty"`
	UnsupportedNumbers []string            `json:"unsupported_numbers,omitempty"`
	NeedsReview        bool                `json:"needs_review"`
	Notes              string              `json:"notes,omitempty"`
}

// Usage is what one exchange cost.
type Usage struct {
	PromptTokens     int           `json:"prompt_tokens"`
	CompletionTokens int           `json:"completion_tokens"`
	Latency          time.Duration `json:"latency"`
	CostMicros       int64         `json:"cost_micros"`
	Model            string        `json:"model"`
}

// Exchange is one question and its answer, with everything needed to audit it.
type Exchange struct {
	ID             string     `json:"id"`
	TenantID       string     `json:"tenant_id"`
	ConversationID string     `json:"conversation_id"`
	Question       string     `json:"question"`
	Answer         string     `json:"answer"`
	Locale         Locale     `json:"locale"`
	AnswerKind     AnswerKind `json:"answer_kind"`
	Citations      []Citation `json:"citations,omitempty"`
	ToolCalls      []ToolCall `json:"tool_calls,omitempty"`
	Evaluation     Evaluation `json:"evaluation"`
	Usage          Usage      `json:"usage"`
	AskedBy        string     `json:"asked_by"`
	CreatedAt      time.Time  `json:"created_at"`

	Reviewed     bool       `json:"reviewed"`
	ReviewerNote string     `json:"reviewer_note,omitempty"`
	Rating       int        `json:"rating,omitempty"`
	ReviewedBy   string     `json:"reviewed_by,omitempty"`
	ReviewedAt   *time.Time `json:"reviewed_at,omitempty"`
}

// Conversation groups exchanges so a follow-up question has context.
type Conversation struct {
	ID            string    `json:"id"`
	TenantID      string    `json:"tenant_id"`
	Title         string    `json:"title"`
	FieldID       string    `json:"field_id"`
	FarmID        string    `json:"farm_id"`
	Locale        Locale    `json:"locale"`
	CreatedBy     string    `json:"created_by"`
	CreatedAt     time.Time `json:"created_at"`
	UpdatedAt     time.Time `json:"updated_at"`
	ExchangeCount int       `json:"exchange_count"`
}

// ReferenceDocument is one piece of indexed agronomy material.
type ReferenceDocument struct {
	ID         string       `json:"id"`
	TenantID   string       `json:"tenant_id"`
	Title      string       `json:"title"`
	Kind       DocumentKind `json:"kind"`
	Locale     Locale       `json:"locale"`
	Source     string       `json:"source"`
	URI        string       `json:"uri"`
	Crops      []string     `json:"crops,omitempty"`
	Region     string       `json:"region"`
	ChunkCount int          `json:"chunk_count"`
	// Embedder names what indexed this document. A corpus half-indexed by the
	// lexical fallback and half by a hosted model retrieves badly in a way
	// that looks like a content problem; without this it is unidentifiable
	// after the fact.
	Embedder  string    `json:"embedder"`
	CreatedBy string    `json:"created_by"`
	CreatedAt time.Time `json:"created_at"`
}

// Chunk is one indexed passage of a document.
type Chunk struct {
	ID         string    `json:"id"`
	TenantID   string    `json:"tenant_id"`
	DocumentID string    `json:"document_id"`
	Ordinal    int       `json:"ordinal"`
	Text       string    `json:"text"`
	Embedding  []float32 `json:"-"`
}

// ── Validation ───────────────────────────────────────────────────────────────

// maxQuestionRunes bounds a question.
//
// Generous — a farmer describing a problem writes more than a search box — but
// not unbounded: the question goes into the prompt, and an unbounded one is a
// way to spend a tenant's whole daily budget in a single call.
const maxQuestionRunes = 4000

// Validate checks a question before any work is done on it.
func ValidateQuestion(q string) error {
	q = strings.TrimSpace(q)
	if q == "" {
		return p9errors.BadRequest("QUESTION_REQUIRED", "a question is required")
	}
	if len([]rune(q)) > maxQuestionRunes {
		return p9errors.BadRequest("QUESTION_TOO_LONG", "the question is too long")
	}
	return nil
}

// Validate checks a document before it is chunked and indexed.
func (d *ReferenceDocument) Validate() error {
	if strings.TrimSpace(d.Title) == "" {
		return p9errors.BadRequest("TITLE_REQUIRED", "a document title is required")
	}
	if strings.TrimSpace(d.Source) == "" {
		return p9errors.BadRequest("SOURCE_REQUIRED",
			"a document source is required — an uncited advisory is not usable as a citation")
	}
	switch d.Kind {
	case DocAgronomyReference, DocCropGuide, DocRegionalAdvisory, DocPackageOfPractice:
	default:
		return p9errors.BadRequest("KIND_INVALID", "unknown document kind")
	}
	return nil
}

// Title derives a conversation title from its first question.
//
// The first sentence, capped. A conversation list where every row reads
// "Conversation" is a list nobody can navigate.
func ConversationTitle(question string) string {
	q := strings.TrimSpace(question)
	if q == "" {
		return "Advisory"
	}
	if sentences := SplitSentences(q); len(sentences) > 0 {
		q = sentences[0]
	}
	runes := []rune(q)
	if len(runes) > 80 {
		return strings.TrimSpace(string(runes[:80])) + "…"
	}
	return q
}

// ListConversationsParams filters a conversation listing.
type ListConversationsParams struct {
	TenantID string
	FieldID  string
	FarmID   string
	Limit    int
	Offset   int
}

// ListExchangesParams filters the review queue.
type ListExchangesParams struct {
	TenantID       string
	ConversationID string
	NeedsReview    bool
	Unreviewed     bool
	Limit          int
	Offset         int
}

// ListDocumentsParams filters a document listing.
type ListDocumentsParams struct {
	TenantID string
	Locale   Locale
	Crop     string
	Region   string
	Limit    int
	Offset   int
}

// ClampPage applies the default and maximum page size.
func ClampPage(size, offset int) (int, int) {
	if size <= 0 {
		size = 20
	}
	if size > 100 {
		size = 100
	}
	if offset < 0 {
		offset = 0
	}
	return size, offset
}
