// Package application holds advisory-service's use cases.
package application

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"
	"time"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/featureflags"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	"p9e.in/samavaya/agriculture/advisory-service/internal/domain"
	"p9e.in/samavaya/agriculture/advisory-service/internal/ports/inbound"
	"p9e.in/samavaya/agriculture/advisory-service/internal/ports/outbound"
)

// Topics this service publishes on.
const (
	topicExchangeRecorded = "yp.advisory.exchange.recorded"
	topicReviewRequired   = "yp.advisory.exchange.review_required"
)

// FlagAdvisoryLLM is the kill switch for the generative half of this service.
//
// Turning it off does not turn the assistant off. Retrieval, tenant scoping,
// evaluation and logging all keep running and the answer becomes extractive
// and says so — which is what an operator actually wants during a provider
// incident or a cost spike, rather than a feature that disappears.
const FlagAdvisoryLLM = "advisory_llm"

// Config tunes the ask pipeline.
type Config struct {
	// MaxToolIterations bounds the model/tool loop.
	//
	// Each iteration is a round trip to the provider and a round trip to a
	// peer service. Unbounded, a model that keeps asking for one more lookup
	// spends a tenant's whole daily budget on a single question — and the
	// farmer is still waiting.
	MaxToolIterations int
	// HistoryTurns is how many earlier exchanges go into a follow-up prompt.
	HistoryTurns int
	// RetrievalLimit is how many reference passages are pulled before ranking.
	RetrievalLimit int
	// MaxAnswerTokens caps one answer.
	MaxAnswerTokens int
}

// DefaultConfig is the shape this service runs in unless configured otherwise.
func DefaultConfig() Config {
	return Config{
		MaxToolIterations: 4,
		HistoryTurns:      4,
		RetrievalLimit:    24,
		MaxAnswerTokens:   1024,
	}
}

type advisoryService struct {
	conversations outbound.ConversationRepository
	documents     outbound.DocumentRepository
	budgets       outbound.BudgetRepository
	embedder      outbound.Embedder
	llm           outbound.LLMClient
	tools         []outbound.Tool
	farmContext   outbound.FarmContextSource
	killSwitch    *featureflags.KillSwitch
	pub           outbound.EventPublisher

	cfg Config
	log *p9log.Helper
	now func() time.Time
}

// Deps is what the service needs to run.
//
// LLM, tools, farm context and the publisher are all optional and the service
// says at startup which of them it has. The ones that are absent change what
// an answer can be built from; none of them changes whether an answer is
// grounded, evaluated, scoped to a tenant or logged.
type Deps struct {
	Conversations outbound.ConversationRepository
	Documents     outbound.DocumentRepository
	Budgets       outbound.BudgetRepository
	Embedder      outbound.Embedder
	LLM           outbound.LLMClient
	Tools         []outbound.Tool
	FarmContext   outbound.FarmContextSource
	KillSwitch    *featureflags.KillSwitch
	Publisher     outbound.EventPublisher
	Config        Config
}

// NewAdvisoryService creates the advisory service.
func NewAdvisoryService(deps Deps, log p9log.Logger) inbound.AdvisoryService {
	cfg := deps.Config
	if cfg.MaxToolIterations <= 0 {
		cfg = DefaultConfig()
	}
	return &advisoryService{
		conversations: deps.Conversations,
		documents:     deps.Documents,
		budgets:       deps.Budgets,
		embedder:      deps.Embedder,
		llm:           deps.LLM,
		tools:         deps.Tools,
		farmContext:   deps.FarmContext,
		killSwitch:    deps.KillSwitch,
		pub:           deps.Publisher,
		cfg:           cfg,
		log:           p9log.NewHelper(p9log.With(log, "component", "AdvisoryService")),
		now:           time.Now,
	}
}

// Ask answers one question and records everything that went into the answer.
//
// The order of the steps is the design:
//
//  1. Budget first, before any work. A ceiling checked after the model has run
//     is not a ceiling — the request that blew through it is the one that
//     already ran and already cost money.
//  2. Retrieval second, scoped to the tenant twice over.
//  3. Generation third, with tools, bounded.
//  4. Evaluation fourth, on what was actually put in front of the model.
//  5. The log last, and unconditionally. Refusals, budget rejections and
//     ungrounded answers are all written: a review queue that only holds the
//     answers the service was willing to give cannot show what it declined,
//     which is half of what a reviewer needs.
func (s *advisoryService) Ask(ctx context.Context, p inbound.AskParams) (*inbound.AskResult, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	if err := domain.ValidateQuestion(p.Question); err != nil {
		return nil, err
	}
	locale := p.Locale.OrDefault()
	started := s.now()

	budget, err := s.budgets.GetBudget(ctx, tenantID)
	if err != nil {
		return nil, err
	}
	budget = budget.Rolled(started)

	conversation, err := s.resolveConversation(ctx, tenantID, p)
	if err != nil {
		return nil, err
	}

	if reason := budget.ExhaustedReason(); reason != "" {
		s.log.Warnw("msg", "advisory budget exhausted", "tenant_id", tenantID, "reason", reason)
		return s.record(ctx, conversation, budget, domain.Exchange{
			TenantID:       tenantID,
			ConversationID: conversation.ID,
			Question:       p.Question,
			Answer:         domain.Phrase(domain.PhraseBudgetExhausted, locale),
			Locale:         locale,
			AnswerKind:     domain.AnswerRefused,
			Evaluation: domain.Evaluation{
				Verdict: domain.VerdictGrounded,
				Notes:   "not answered: " + reason,
			},
			Usage: domain.Usage{Latency: s.now().Sub(started)},
		}, false)
	}

	// The latency budget becomes the deadline for everything below. Without
	// it, a slow provider turns into a farmer holding a phone in a field
	// watching a spinner, and the request that eventually returns is one
	// nobody is waiting for any more.
	ctx, cancel := context.WithTimeout(ctx, budget.LatencyBudget())
	defer cancel()

	citations, err := s.retrieve(ctx, tenantID, p, locale)
	if err != nil {
		return nil, err
	}

	exchange := domain.Exchange{
		TenantID:       tenantID,
		ConversationID: conversation.ID,
		Question:       p.Question,
		Locale:         locale,
		AskedBy:        p9context.UserID(ctx),
	}

	switch {
	case len(citations) == 0 && s.llm == nil:
		exchange.Answer = domain.Phrase(domain.PhraseNoGrounding, locale)
		exchange.AnswerKind = domain.AnswerRefused

	case s.llmAvailable(ctx, tenantID):
		answer, toolCalls, toolCitations, usage, err := s.generate(ctx, conversation, p, locale, citations)
		if err != nil {
			return nil, err
		}
		citations = append(citations, toolCitations...)
		exchange.Answer = answer
		exchange.ToolCalls = toolCalls
		exchange.Usage = usage
		exchange.AnswerKind = domain.AnswerGenerated
		if strings.TrimSpace(answer) == "" {
			// A model that returned nothing is not an answer, and storing an
			// empty string would show a farmer a blank card.
			exchange.Answer = domain.Phrase(domain.PhraseNoGrounding, locale)
			exchange.AnswerKind = domain.AnswerRefused
		}

	default:
		exchange.Answer = domain.ExtractiveAnswer(citations, locale)
		exchange.AnswerKind = domain.AnswerExtractive
	}

	exchange.Citations = citations
	exchange.Usage.Latency = s.now().Sub(started)
	if exchange.Usage.Model == "" && s.llm != nil {
		exchange.Usage.Model = s.llm.Model()
	}

	// Evaluated only when the answer claims to be one. The service's own
	// refusals and its extractive quotations are not the model's assertions,
	// and scoring them would fill the review queue with the two cases where
	// there is nothing to review.
	if exchange.AnswerKind == domain.AnswerGenerated {
		exchange.Evaluation = domain.EvaluateGroundedness(
			exchange.Answer, domain.ContextPassages(citations))
		if exchange.Evaluation.Verdict != domain.VerdictGrounded {
			// Said to the farmer, not only recorded for a reviewer. An answer
			// the service itself could not tie to a source should not look
			// identical to one it could.
			exchange.Answer += "\n\n" + domain.Phrase(domain.PhraseCheckWithAgronomist, locale)
		}
	} else {
		exchange.Evaluation = domain.Evaluation{Verdict: domain.VerdictGrounded}
	}

	return s.record(ctx, conversation, budget, exchange, true)
}

// llmAvailable reports whether the generative path should be used.
func (s *advisoryService) llmAvailable(ctx context.Context, tenantID string) bool {
	if s.llm == nil {
		return false
	}
	if s.killSwitch == nil {
		return true
	}
	return s.killSwitch.IsAlive(ctx, featureflags.Attributes{"tenant_id": tenantID})
}

// resolveConversation finds the conversation this question belongs to, or
// starts one.
func (s *advisoryService) resolveConversation(
	ctx context.Context,
	tenantID string,
	p inbound.AskParams,
) (domain.Conversation, error) {
	if p.ConversationID != "" {
		// Read through the repository, which filters by tenant, rather than
		// trusting the id in the request. A conversation id is guessable
		// enough that accepting one unchecked would let a question be appended
		// to another tenant's thread.
		got, err := s.conversations.GetConversation(ctx, p.ConversationID, tenantID)
		if err != nil {
			return domain.Conversation{}, err
		}
		return *got, nil
	}

	created, err := s.conversations.CreateConversation(ctx, &domain.Conversation{
		ID:        ulid.NewString(),
		TenantID:  tenantID,
		Title:     domain.ConversationTitle(p.Question),
		FieldID:   p.FieldID,
		FarmID:    p.FarmID,
		Locale:    p.Locale.OrDefault(),
		CreatedBy: p9context.UserID(ctx),
	})
	if err != nil {
		return domain.Conversation{}, err
	}
	return *created, nil
}

// retrieve gathers the tenant's own records and the reference corpus.
func (s *advisoryService) retrieve(
	ctx context.Context,
	tenantID string,
	p inbound.AskParams,
	locale domain.Locale,
) ([]domain.Citation, error) {
	var candidates []domain.Citation

	if s.farmContext != nil {
		records, err := s.farmContext.Fetch(ctx, outbound.FarmContextQuery{
			TenantID: tenantID,
			FieldID:  p.FieldID,
			FarmID:   p.FarmID,
			Question: p.Question,
			Locale:   locale,
		})
		if err != nil {
			// Logged, not fatal. The reference corpus can still answer a
			// general question, and failing outright would take the whole
			// assistant down with one peer service.
			s.log.Warnw("msg", "farm context unavailable", "error", err)
		}
		candidates = append(candidates, records...)
	}

	chunks, err := s.searchCorpus(ctx, tenantID, p.Question, locale, "")
	if err != nil {
		return nil, err
	}
	candidates = append(candidates, chunks...)

	// The records the farm already holds are ranked against the corpus rather
	// than stapled on top of it, so a question the corpus answers better is
	// not crowded out by four rows of field metadata.
	ranked := domain.RankCitations(p.Question, candidates, locale)
	return domain.AssembleContext(tenantID, ranked)
}

func (s *advisoryService) searchCorpus(
	ctx context.Context,
	tenantID, question string,
	locale domain.Locale,
	crop string,
) ([]domain.Citation, error) {
	query := outbound.ChunkQuery{
		TenantID:  tenantID,
		QueryText: question,
		Locale:    locale,
		Crop:      crop,
		Limit:     s.cfg.RetrievalLimit,
	}

	if s.embedder != nil {
		vectors, err := s.embedder.Embed(ctx, []string{question})
		if err != nil {
			// The lexical half of the search still runs. An embedding endpoint
			// that is down should make retrieval worse, not absent, and the
			// log says which happened.
			s.log.Warnw("msg", "embedding the question failed; falling back to lexical search",
				"embedder", s.embedder.Name(), "error", err)
		} else if len(vectors) == 1 {
			query.Vector = vectors[0]
		}
	}

	return s.documents.SearchChunks(ctx, query)
}

// generate runs the model, executing any tools it asks for.
func (s *advisoryService) generate(
	ctx context.Context,
	conversation domain.Conversation,
	p inbound.AskParams,
	locale domain.Locale,
	citations []domain.Citation,
) (string, []domain.ToolCall, []domain.Citation, domain.Usage, error) {
	available := s.tools
	if p.DisableTools {
		available = nil
	}

	byName := make(map[string]outbound.Tool, len(available))
	specs := make([]outbound.LLMToolSpec, 0, len(available))
	names := make([]string, 0, len(available))
	for _, tool := range available {
		byName[tool.Name()] = tool
		names = append(names, tool.Name())
		specs = append(specs, outbound.LLMToolSpec{
			Name:        tool.Name(),
			Description: tool.Description(),
			InputSchema: tool.InputSchema(),
		})
	}

	var history string
	if conversation.ExchangeCount > 0 {
		previous, _, err := s.conversations.ListExchanges(ctx, domain.ListExchangesParams{
			TenantID:       conversation.TenantID,
			ConversationID: conversation.ID,
			Limit:          s.cfg.HistoryTurns,
		})
		if err != nil {
			s.log.Warnw("msg", "could not load conversation history", "error", err)
		} else {
			history = domain.ConversationHistory(previous, s.cfg.HistoryTurns)
		}
	}

	prompt := domain.BuildContextBlock(citations) + history +
		"QUESTION:\n" + strings.TrimSpace(p.Question)

	messages := []outbound.LLMMessage{{Role: outbound.RoleUser, Text: prompt}}

	var (
		toolCalls     []domain.ToolCall
		toolCitations []domain.Citation
		usage         domain.Usage
		answer        string
	)
	// Tool results continue the numbering the context block ended on, so a
	// figure the model got from a service is cited the same way a document is
	// and the reviewer can follow it.
	nextMarker := len(citations) + 1

	for iteration := 0; iteration < s.cfg.MaxToolIterations; iteration++ {
		resp, err := s.llm.Complete(ctx, outbound.LLMRequest{
			System:    domain.BuildSystemPrompt(locale, names),
			Messages:  messages,
			Tools:     specs,
			MaxTokens: s.cfg.MaxAnswerTokens,
		})
		if err != nil {
			return "", toolCalls, toolCitations, usage, err
		}

		usage.PromptTokens += resp.PromptTokens
		usage.CompletionTokens += resp.CompletionTokens
		usage.Model = resp.Model
		usage.CostMicros = domain.EstimateCostMicros(
			s.llm.Price(), usage.PromptTokens, usage.CompletionTokens)

		if len(resp.ToolUses) == 0 {
			answer = resp.Text
			break
		}

		messages = append(messages, outbound.LLMMessage{
			Role:     outbound.RoleAssistant,
			Text:     resp.Text,
			ToolUses: resp.ToolUses,
		})

		results := make([]outbound.LLMToolResult, 0, len(resp.ToolUses))
		for _, use := range resp.ToolUses {
			tool, ok := byName[use.Name]
			if !ok {
				results = append(results, outbound.LLMToolResult{
					ID:      use.ID,
					IsError: true,
					Content: fmt.Sprintf("there is no tool called %q", use.Name),
				})
				continue
			}

			callStarted := s.now()
			output, callErr := tool.Call(ctx, use.InputJSON)
			record := domain.ToolCall{
				Name:          use.Name,
				ArgumentsJSON: use.InputJSON,
				Latency:       s.now().Sub(callStarted),
			}

			if callErr != nil {
				record.OK = false
				record.Error = callErr.Error()
				toolCalls = append(toolCalls, record)
				// The error goes back to the model rather than failing the
				// request. A service being down is something the assistant can
				// work around — and must tell the farmer about — not a reason
				// for the question to return a 500.
				results = append(results, outbound.LLMToolResult{
					ID:      use.ID,
					IsError: true,
					Content: "this lookup failed: " + callErr.Error() +
						". Say so rather than estimating the figure yourself.",
				})
				continue
			}

			record.OK = true
			record.ResultJSON = output
			toolCalls = append(toolCalls, record)

			citation := tool.Citation(use.InputJSON, output)
			citation.ID = ulid.NewString()
			citation.TenantID = conversation.TenantID
			citation.Marker = nextMarker
			citation.Score = 1
			toolCitations = append(toolCitations, citation)

			results = append(results, outbound.LLMToolResult{
				ID:      use.ID,
				Content: fmt.Sprintf("[%d] %s\n%s", nextMarker, use.Name, output),
			})
			nextMarker++
		}

		messages = append(messages, outbound.LLMMessage{
			Role:        outbound.RoleUser,
			ToolResults: results,
		})
	}

	if answer == "" && len(toolCalls) > 0 {
		// The loop ran out of iterations with the model still asking for
		// lookups. Reported rather than presented as an answer: whatever the
		// model was mid-way through working out, it had not finished.
		s.log.Warnw("msg", "tool loop hit its iteration limit without an answer",
			"iterations", s.cfg.MaxToolIterations, "tool_calls", len(toolCalls))
	}

	return answer, toolCalls, toolCitations, usage, nil
}

// record writes the exchange, updates the conversation and bills the budget.
func (s *advisoryService) record(
	ctx context.Context,
	conversation domain.Conversation,
	budget domain.Budget,
	exchange domain.Exchange,
	charge bool,
) (*inbound.AskResult, error) {
	exchange.ID = ulid.NewString()
	exchange.CreatedAt = s.now().UTC()

	// Written with a background-derived context so the log survives the
	// request's own deadline. An exchange that timed out is precisely the one
	// worth having a record of, and writing it under the deadline that just
	// expired would lose exactly those.
	writeCtx, cancel := context.WithTimeout(context.WithoutCancel(ctx), 5*time.Second)
	defer cancel()

	stored, err := s.conversations.AppendExchange(writeCtx, &exchange)
	if err != nil {
		return nil, err
	}
	if err := s.conversations.TouchConversation(writeCtx, conversation.ID, conversation.TenantID, exchange.CreatedAt); err != nil {
		s.log.Warnw("msg", "could not update conversation timestamp", "error", err)
	}
	conversation.ExchangeCount++
	conversation.UpdatedAt = exchange.CreatedAt

	if charge {
		updated, err := s.budgets.RecordSpend(writeCtx, conversation.TenantID, exchange.CreatedAt, exchange.Usage)
		if err != nil {
			// The answer has already been given and already cost money. Losing
			// the accounting is bad; refusing to return an answer that was
			// paid for is worse, so this is loud rather than fatal.
			s.log.Errorw("msg", "could not record advisory spend — this tenant's budget is now under-counted",
				"tenant_id", conversation.TenantID, "cost_micros", exchange.Usage.CostMicros, "error", err)
		} else {
			budget = updated
		}
	}

	s.publish(writeCtx, topicExchangeRecorded, stored)
	if stored.Evaluation.NeedsReview {
		s.publish(writeCtx, topicReviewRequired, stored)
	}

	return &inbound.AskResult{
		Conversation: conversation,
		Exchange:     *stored,
		Budget:       budget,
	}, nil
}

func (s *advisoryService) publish(ctx context.Context, topic string, e *domain.Exchange) {
	if s.pub == nil {
		return
	}
	payload, err := json.Marshal(map[string]any{
		"exchange_id":     e.ID,
		"conversation_id": e.ConversationID,
		"tenant_id":       e.TenantID,
		"answer_kind":     e.AnswerKind,
		"verdict":         e.Evaluation.Verdict,
		"groundedness":    e.Evaluation.Groundedness,
		"needs_review":    e.Evaluation.NeedsReview,
		"cost_micros":     e.Usage.CostMicros,
		"latency_ms":      e.Usage.Latency.Milliseconds(),
		"created_at":      e.CreatedAt,
	})
	if err != nil {
		return
	}
	if err := s.pub.Publish(ctx, topic, e.TenantID, payload); err != nil {
		s.log.Warnw("msg", "failed to publish advisory event", "topic", topic, "error", err)
	}
}

// ── Reads ────────────────────────────────────────────────────────────────────

func (s *advisoryService) GetConversation(ctx context.Context, id string) (*domain.Conversation, []domain.Exchange, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, nil, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	conversation, err := s.conversations.GetConversation(ctx, id, tenantID)
	if err != nil {
		return nil, nil, err
	}
	exchanges, _, err := s.conversations.ListExchanges(ctx, domain.ListExchangesParams{
		TenantID:       tenantID,
		ConversationID: id,
		Limit:          100,
	})
	if err != nil {
		return nil, nil, err
	}
	return conversation, exchanges, nil
}

func (s *advisoryService) ListConversations(
	ctx context.Context,
	params domain.ListConversationsParams,
) ([]domain.Conversation, int64, error) {
	params.TenantID = p9context.TenantID(ctx)
	if params.TenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	return s.conversations.ListConversations(ctx, params)
}

func (s *advisoryService) ListExchanges(
	ctx context.Context,
	params domain.ListExchangesParams,
) ([]domain.Exchange, int64, error) {
	params.TenantID = p9context.TenantID(ctx)
	if params.TenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	return s.conversations.ListExchanges(ctx, params)
}

func (s *advisoryService) ReviewExchange(ctx context.Context, id, note string, rating int) (*domain.Exchange, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	if rating < 0 || rating > 5 {
		return nil, errors.BadRequest("RATING_OUT_OF_RANGE", "a rating must be between 0 and 5")
	}
	return s.conversations.ReviewExchange(ctx, id, tenantID,
		p9context.UserID(ctx), note, rating, s.now().UTC())
}

func (s *advisoryService) GetBudget(ctx context.Context) (domain.Budget, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return domain.Budget{}, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	budget, err := s.budgets.GetBudget(ctx, tenantID)
	if err != nil {
		return domain.Budget{}, err
	}
	return budget.Rolled(s.now()), nil
}

func (s *advisoryService) SetBudget(ctx context.Context, b domain.Budget) (domain.Budget, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return domain.Budget{}, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	if b.DailyCostMicros < 0 || b.DailyQuestionLimit < 0 || b.RequestLatencyBudget < 0 {
		return domain.Budget{}, errors.BadRequest("BUDGET_NEGATIVE", "a budget cannot be negative")
	}
	b.TenantID = tenantID
	return s.budgets.SetBudget(ctx, b)
}

// ── Corpus ───────────────────────────────────────────────────────────────────

func (s *advisoryService) IngestDocument(
	ctx context.Context,
	d *domain.ReferenceDocument,
	text string,
) (*domain.ReferenceDocument, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	if err := d.Validate(); err != nil {
		return nil, err
	}

	passages := domain.ChunkText(text)
	if len(passages) == 0 {
		return nil, errors.BadRequest("DOCUMENT_EMPTY",
			"the document has no text to index")
	}

	d.ID = ulid.NewString()
	d.TenantID = tenantID
	d.Locale = d.Locale.OrDefault()
	d.CreatedBy = p9context.UserID(ctx)

	var vectors [][]float32
	if s.embedder != nil {
		d.Embedder = s.embedder.Name()
		embedded, err := s.embedder.Embed(ctx, passages)
		if err != nil {
			// Refused rather than stored without vectors. A document indexed
			// with no embedding is retrievable only by exact words, which is
			// a silently worse corpus — and the operator who uploaded it would
			// have no reason to suspect anything went wrong.
			return nil, errors.ServiceUnavailable("EMBEDDING_FAILED",
				"the document could not be indexed because the embedding step failed")
		}
		vectors = embedded
	}

	chunks := make([]domain.Chunk, len(passages))
	for i, passage := range passages {
		chunks[i] = domain.Chunk{
			ID:         ulid.NewString(),
			TenantID:   tenantID,
			DocumentID: d.ID,
			Ordinal:    i,
			Text:       passage,
		}
		if i < len(vectors) {
			chunks[i].Embedding = vectors[i]
		}
	}

	return s.documents.CreateDocument(ctx, d, chunks)
}

func (s *advisoryService) ListDocuments(
	ctx context.Context,
	params domain.ListDocumentsParams,
) ([]domain.ReferenceDocument, int64, error) {
	params.TenantID = p9context.TenantID(ctx)
	if params.TenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	return s.documents.ListDocuments(ctx, params)
}

func (s *advisoryService) DeleteDocument(ctx context.Context, id string) (bool, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return false, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	return s.documents.DeleteDocument(ctx, id, tenantID)
}

func (s *advisoryService) SearchReference(
	ctx context.Context,
	query string,
	locale domain.Locale,
	crop string,
	limit int,
) ([]domain.Citation, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	if strings.TrimSpace(query) == "" {
		return nil, errors.BadRequest("QUERY_REQUIRED", "a search query is required")
	}
	if limit <= 0 || limit > domain.MaxCitations*4 {
		limit = domain.MaxCitations
	}

	candidates, err := s.searchCorpus(ctx, tenantID, query, locale, crop)
	if err != nil {
		return nil, err
	}
	ranked := domain.RankCitations(query, candidates, locale)
	if len(ranked) > limit {
		ranked = ranked[:limit]
	}
	// The same tenant guard the ask path uses. A retrieval-only endpoint that
	// skipped it would be the way around the check.
	return domain.AssembleContext(tenantID, ranked)
}
