package application

import (
	"context"
	"fmt"
	"strings"
	"testing"
	"time"

	"go.uber.org/zap"

	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"

	"p9e.in/samavaya/agriculture/advisory-service/internal/domain"
	"p9e.in/samavaya/agriculture/advisory-service/internal/ports/inbound"
	"p9e.in/samavaya/agriculture/advisory-service/internal/ports/outbound"
)

const (
	tenantA = "01TENANTAAAAAAAAAAAAAAAAAA"
	tenantB = "01TENANTBBBBBBBBBBBBBBBBBB"
)

func testContext(tenantID string) context.Context {
	return p9context.NewUserContext(context.Background(), p9context.UserContext{
		UserID:   "01USERAAAAAAAAAAAAAAAAAAAA",
		TenantID: tenantID,
	})
}

func testLogger(t *testing.T) p9log.Logger {
	t.Helper()
	return p9log.NewLogger(zap.NewNop())
}

// ── Fakes ────────────────────────────────────────────────────────────────────

type fakeConversations struct {
	conversations map[string]*domain.Conversation
	exchanges     []domain.Exchange
	nextID        int
}

func newFakeConversations() *fakeConversations {
	return &fakeConversations{conversations: map[string]*domain.Conversation{}}
}

func (f *fakeConversations) CreateConversation(_ context.Context, c *domain.Conversation) (*domain.Conversation, error) {
	f.nextID++
	if c.ID == "" {
		c.ID = fmt.Sprintf("conv-%d", f.nextID)
	}
	copied := *c
	f.conversations[c.ID] = &copied
	return &copied, nil
}

func (f *fakeConversations) GetConversation(_ context.Context, id, tenantID string) (*domain.Conversation, error) {
	c, ok := f.conversations[id]
	if !ok || c.TenantID != tenantID {
		return nil, fmt.Errorf("conversation not found")
	}
	copied := *c
	return &copied, nil
}

func (f *fakeConversations) ListConversations(_ context.Context, _ domain.ListConversationsParams) ([]domain.Conversation, int64, error) {
	return nil, 0, nil
}

func (f *fakeConversations) TouchConversation(_ context.Context, id, _ string, at time.Time) error {
	if c, ok := f.conversations[id]; ok {
		c.ExchangeCount++
		c.UpdatedAt = at
	}
	return nil
}

func (f *fakeConversations) AppendExchange(_ context.Context, e *domain.Exchange) (*domain.Exchange, error) {
	copied := *e
	f.exchanges = append(f.exchanges, copied)
	return &copied, nil
}

func (f *fakeConversations) GetExchange(_ context.Context, _, _ string) (*domain.Exchange, error) {
	return nil, fmt.Errorf("not implemented")
}

func (f *fakeConversations) ListExchanges(_ context.Context, params domain.ListExchangesParams) ([]domain.Exchange, int64, error) {
	var out []domain.Exchange
	for _, e := range f.exchanges {
		if params.ConversationID != "" && e.ConversationID != params.ConversationID {
			continue
		}
		out = append(out, e)
	}
	return out, int64(len(out)), nil
}

func (f *fakeConversations) ReviewExchange(_ context.Context, _, _, _, _ string, _ int, _ time.Time) (*domain.Exchange, error) {
	return nil, fmt.Errorf("not implemented")
}

type fakeDocuments struct {
	hits    []domain.Citation
	created *domain.ReferenceDocument
	chunks  []domain.Chunk
}

func (f *fakeDocuments) CreateDocument(_ context.Context, d *domain.ReferenceDocument, chunks []domain.Chunk) (*domain.ReferenceDocument, error) {
	f.created = d
	f.chunks = chunks
	d.ChunkCount = len(chunks)
	return d, nil
}

func (f *fakeDocuments) ListDocuments(_ context.Context, _ domain.ListDocumentsParams) ([]domain.ReferenceDocument, int64, error) {
	return nil, 0, nil
}

func (f *fakeDocuments) DeleteDocument(_ context.Context, _, _ string) (bool, error) {
	return true, nil
}

func (f *fakeDocuments) SearchChunks(_ context.Context, _ outbound.ChunkQuery) ([]domain.Citation, error) {
	return f.hits, nil
}

type fakeBudgets struct {
	budget domain.Budget
	spends []domain.Usage
}

func (f *fakeBudgets) GetBudget(_ context.Context, tenantID string) (domain.Budget, error) {
	if f.budget.TenantID == "" {
		return domain.DefaultBudget(tenantID, time.Now()), nil
	}
	return f.budget, nil
}

func (f *fakeBudgets) SetBudget(_ context.Context, b domain.Budget) (domain.Budget, error) {
	f.budget = b
	return b, nil
}

func (f *fakeBudgets) RecordSpend(_ context.Context, tenantID string, window time.Time, u domain.Usage) (domain.Budget, error) {
	f.spends = append(f.spends, u)
	b := f.budget
	if b.TenantID == "" {
		b = domain.DefaultBudget(tenantID, window)
	}
	return b.WithSpend(u), nil
}

// scriptedLLM replays a fixed list of responses, one per call.
type scriptedLLM struct {
	responses []outbound.LLMResponse
	requests  []outbound.LLMRequest
	price     domain.ModelPrice
}

func (l *scriptedLLM) Complete(_ context.Context, req outbound.LLMRequest) (outbound.LLMResponse, error) {
	l.requests = append(l.requests, req)
	if len(l.responses) == 0 {
		return outbound.LLMResponse{}, fmt.Errorf("the scripted model ran out of responses")
	}
	resp := l.responses[0]
	l.responses = l.responses[1:]
	return resp, nil
}

func (l *scriptedLLM) Model() string            { return "scripted-model" }
func (l *scriptedLLM) Price() domain.ModelPrice { return l.price }

type fakeTool struct {
	name   string
	result string
	err    error
	calls  []string
}

func (t *fakeTool) Name() string        { return t.name }
func (t *fakeTool) Description() string { return "a test tool" }
func (t *fakeTool) InputSchema() map[string]any {
	return map[string]any{"type": "object"}
}

func (t *fakeTool) Call(_ context.Context, argumentsJSON string) (string, error) {
	t.calls = append(t.calls, argumentsJSON)
	return t.result, t.err
}

func (t *fakeTool) Citation(_, resultJSON string) domain.Citation {
	return domain.Citation{
		Kind:    domain.CitationYieldForecast,
		Title:   "Yield forecast for this field",
		Snippet: resultJSON,
	}
}

type fakeFarmContext struct {
	citations []domain.Citation
	err       error
}

func (f *fakeFarmContext) Name() string { return "fake-records" }

func (f *fakeFarmContext) Fetch(_ context.Context, q outbound.FarmContextQuery) ([]domain.Citation, error) {
	if f.err != nil {
		return nil, f.err
	}
	out := make([]domain.Citation, len(f.citations))
	copy(out, f.citations)
	for i := range out {
		if out[i].TenantID == "" {
			out[i].TenantID = q.TenantID
		}
	}
	return out, nil
}

// ── Harness ──────────────────────────────────────────────────────────────────

type harness struct {
	svc           inbound.AdvisoryService
	conversations *fakeConversations
	documents     *fakeDocuments
	budgets       *fakeBudgets
	llm           *scriptedLLM
}

func newHarness(t *testing.T, deps Deps) *harness {
	t.Helper()

	conversations := newFakeConversations()
	documents := &fakeDocuments{}
	budgets := &fakeBudgets{}

	if deps.Conversations == nil {
		deps.Conversations = conversations
	}
	if deps.Documents == nil {
		deps.Documents = documents
	}
	if deps.Budgets == nil {
		deps.Budgets = budgets
	}

	h := &harness{
		conversations: conversations,
		documents:     documents,
		budgets:       budgets,
	}
	if scripted, ok := deps.LLM.(*scriptedLLM); ok {
		h.llm = scripted
	}
	h.svc = NewAdvisoryService(deps, testLogger(t))
	return h
}

const wheatPassage = "Urea is applied to irrigated wheat as a split top dressing. " +
	"The first split of 60 kg per hectare goes in at first irrigation, around 21 days after sowing."

func wheatCitation() domain.Citation {
	return domain.Citation{
		ID:       "chunk-1",
		TenantID: tenantA,
		Kind:     domain.CitationDocument,
		Title:    "Wheat package of practices — ICAR",
		Snippet:  wheatPassage,
		Score:    0.9,
		Locale:   domain.LocaleEN,
	}
}

// ── Tests ────────────────────────────────────────────────────────────────────

func TestAskWithoutAModelAnswersExtractivelyAndSaysSo(t *testing.T) {
	documents := &fakeDocuments{hits: []domain.Citation{wheatCitation()}}
	h := newHarness(t, Deps{Documents: documents, Config: DefaultConfig()})

	result, err := h.svc.Ask(testContext(tenantA), inbound.AskParams{
		Question: "How much urea for wheat top dressing?",
		Locale:   domain.LocaleEN,
	})
	if err != nil {
		t.Fatal(err)
	}

	if result.Exchange.AnswerKind != domain.AnswerExtractive {
		t.Fatalf("answer kind = %q, want EXTRACTIVE", result.Exchange.AnswerKind)
	}
	// The preamble is the point: a quotation and a written answer are not the
	// same claim, and rendering them identically is the convenient lie.
	if !strings.Contains(result.Exchange.Answer, "No language model is configured") {
		t.Errorf("an extractive answer must say it is one, got %q", result.Exchange.Answer)
	}
	if result.Exchange.Usage.Model != "" {
		t.Errorf("no model was called, so none should be claimed; got %q", result.Exchange.Usage.Model)
	}
	if len(result.Exchange.Citations) == 0 {
		t.Error("the quoted passage should be cited")
	}
}

func TestAskWithNothingRetrievedAndNoModelRefusesInTheAskedLanguage(t *testing.T) {
	h := newHarness(t, Deps{Config: DefaultConfig()})

	result, err := h.svc.Ask(testContext(tenantA), inbound.AskParams{
		Question: "నా పొలంలో యూరియా ఎంత వేయాలి?",
		Locale:   domain.LocaleTE,
	})
	if err != nil {
		t.Fatal(err)
	}

	if result.Exchange.AnswerKind != domain.AnswerRefused {
		t.Fatalf("answer kind = %q, want REFUSED", result.Exchange.AnswerKind)
	}
	want := domain.Phrase(domain.PhraseNoGrounding, domain.LocaleTE)
	if result.Exchange.Answer != want {
		t.Errorf("a Telugu question must be refused in Telugu.\n got: %q\nwant: %q",
			result.Exchange.Answer, want)
	}
}

func TestAGroundedAnswerIsNotQueuedForReview(t *testing.T) {
	documents := &fakeDocuments{hits: []domain.Citation{wheatCitation()}}
	llm := &scriptedLLM{responses: []outbound.LLMResponse{{
		Text:             "Apply urea as a split top dressing [1]. Give 60 kg per hectare at the first irrigation, around 21 days after sowing [1].",
		PromptTokens:     900,
		CompletionTokens: 40,
		Model:            "scripted-model",
	}}}

	h := newHarness(t, Deps{
		Documents: documents,
		LLM:       llm,
		Config:    DefaultConfig(),
	})

	result, err := h.svc.Ask(testContext(tenantA), inbound.AskParams{
		Question: "How much urea for wheat top dressing?",
		Locale:   domain.LocaleEN,
	})
	if err != nil {
		t.Fatal(err)
	}

	if result.Exchange.Evaluation.Verdict != domain.VerdictGrounded {
		t.Fatalf("verdict = %q (%.2f) unsupported=%+v numbers=%v",
			result.Exchange.Evaluation.Verdict, result.Exchange.Evaluation.Groundedness,
			result.Exchange.Evaluation.Unsupported, result.Exchange.Evaluation.UnsupportedNumbers)
	}
	if result.Exchange.Evaluation.NeedsReview {
		t.Error("a grounded answer should not be queued for review")
	}
	if strings.Contains(result.Exchange.Answer, domain.Phrase(domain.PhraseCheckWithAgronomist, domain.LocaleEN)) {
		t.Error("a grounded answer should not carry the check-with-an-agronomist warning")
	}
}

func TestAFabricatedQuantityIsFlaggedAndTheFarmerIsTold(t *testing.T) {
	// The whole point of the evaluator. The prose matches the source almost
	// word for word; only the number is invented, and it is the number the
	// farmer would act on.
	documents := &fakeDocuments{hits: []domain.Citation{wheatCitation()}}
	llm := &scriptedLLM{responses: []outbound.LLMResponse{{
		Text:  "Apply urea as a split top dressing [1]. Give 250 kg per hectare at the first irrigation [1].",
		Model: "scripted-model",
	}}}

	h := newHarness(t, Deps{Documents: documents, LLM: llm, Config: DefaultConfig()})

	result, err := h.svc.Ask(testContext(tenantA), inbound.AskParams{
		Question: "How much urea for wheat top dressing?",
		Locale:   domain.LocaleEN,
	})
	if err != nil {
		t.Fatal(err)
	}

	eval := result.Exchange.Evaluation
	if len(eval.UnsupportedNumbers) == 0 {
		t.Fatalf("250 appears in no source but was not reported; eval = %+v", eval)
	}
	if !eval.NeedsReview {
		t.Error("an answer with an invented quantity must reach the review queue")
	}
	// Told to the person reading it, not only recorded for a reviewer who may
	// look at it tomorrow.
	if !strings.Contains(result.Exchange.Answer, domain.Phrase(domain.PhraseCheckWithAgronomist, domain.LocaleEN)) {
		t.Errorf("the farmer should be warned in the answer itself, got %q", result.Exchange.Answer)
	}
}

func TestTheToolLoopRunsTheToolAndCitesItsResult(t *testing.T) {
	documents := &fakeDocuments{hits: []domain.Citation{wheatCitation()}}
	tool := &fakeTool{name: "yield_forecast", result: `{"predicted_yield_kg_per_hectare":4100}`}

	llm := &scriptedLLM{responses: []outbound.LLMResponse{
		{ToolUses: []outbound.LLMToolUse{{ID: "tu_1", Name: "yield_forecast", InputJSON: `{"field_id":"F1"}`}}},
		{Text: "Your forecast for this field is 4100 kg per hectare [2].", Model: "scripted-model"},
	}}

	h := newHarness(t, Deps{Documents: documents, LLM: llm, Tools: []outbound.Tool{tool}, Config: DefaultConfig()})

	result, err := h.svc.Ask(testContext(tenantA), inbound.AskParams{
		Question: "What yield should I expect?",
		FieldID:  "F1",
		Locale:   domain.LocaleEN,
	})
	if err != nil {
		t.Fatal(err)
	}

	if len(tool.calls) != 1 {
		t.Fatalf("the tool should have been called once, got %d", len(tool.calls))
	}
	if len(result.Exchange.ToolCalls) != 1 || !result.Exchange.ToolCalls[0].OK {
		t.Fatalf("tool calls = %+v", result.Exchange.ToolCalls)
	}

	// The tool result has to be citable, and its marker has to continue the
	// numbering the context block ended on — otherwise the [2] in the answer
	// points at nothing.
	var toolCitation *domain.Citation
	for i := range result.Exchange.Citations {
		if result.Exchange.Citations[i].Kind == domain.CitationYieldForecast {
			toolCitation = &result.Exchange.Citations[i]
		}
	}
	if toolCitation == nil {
		t.Fatal("the tool result should appear as a citation")
	}
	if toolCitation.Marker != 2 {
		t.Errorf("tool citation marker = %d, want 2 (one retrieved passage came first)", toolCitation.Marker)
	}
	if toolCitation.TenantID != tenantA {
		t.Errorf("tool citation tenant = %q", toolCitation.TenantID)
	}

	// And the figure it returned must count as grounding, or every
	// tool-derived number would be reported and reviewers would learn to
	// ignore the flag.
	if len(result.Exchange.Evaluation.UnsupportedNumbers) != 0 {
		t.Errorf("4100 came from the tool; it should not be unsupported, got %v",
			result.Exchange.Evaluation.UnsupportedNumbers)
	}
}

func TestAFailedToolDoesNotFailTheQuestionAndGroundsNothing(t *testing.T) {
	documents := &fakeDocuments{hits: []domain.Citation{wheatCitation()}}
	tool := &fakeTool{name: "yield_forecast", err: fmt.Errorf("yield-service is unreachable")}

	llm := &scriptedLLM{responses: []outbound.LLMResponse{
		{ToolUses: []outbound.LLMToolUse{{ID: "tu_1", Name: "yield_forecast", InputJSON: `{"field_id":"F1"}`}}},
		{Text: "I could not reach the yield forecast for this field, so I cannot give you a number.", Model: "scripted-model"},
	}}

	h := newHarness(t, Deps{Documents: documents, LLM: llm, Tools: []outbound.Tool{tool}, Config: DefaultConfig()})

	result, err := h.svc.Ask(testContext(tenantA), inbound.AskParams{
		Question: "What yield should I expect?",
		FieldID:  "F1",
		Locale:   domain.LocaleEN,
	})
	if err != nil {
		t.Fatalf("a peer service being down must not fail the question: %v", err)
	}

	if len(result.Exchange.ToolCalls) != 1 || result.Exchange.ToolCalls[0].OK {
		t.Fatalf("the failed call should be recorded as failed, got %+v", result.Exchange.ToolCalls)
	}
	if result.Exchange.ToolCalls[0].Error == "" {
		t.Error("the failure reason should be stored for the reviewer")
	}
	for _, c := range result.Exchange.Citations {
		if c.Kind == domain.CitationYieldForecast {
			t.Fatal("a failed tool call must not become a citation")
		}
	}

	// The model is told about the failure rather than the request 500ing.
	last := h.llm.requests[len(h.llm.requests)-1]
	found := false
	for _, msg := range last.Messages {
		for _, r := range msg.ToolResults {
			if r.IsError && strings.Contains(r.Content, "unreachable") {
				found = true
			}
		}
	}
	if !found {
		t.Error("the tool failure should have been handed back to the model")
	}
}

func TestDisableToolsRemovesTheToolSpecs(t *testing.T) {
	documents := &fakeDocuments{hits: []domain.Citation{wheatCitation()}}
	tool := &fakeTool{name: "yield_forecast", result: `{}`}
	llm := &scriptedLLM{responses: []outbound.LLMResponse{{Text: "An answer [1].", Model: "scripted-model"}}}

	h := newHarness(t, Deps{Documents: documents, LLM: llm, Tools: []outbound.Tool{tool}, Config: DefaultConfig()})

	if _, err := h.svc.Ask(testContext(tenantA), inbound.AskParams{
		Question:     "How much urea?",
		DisableTools: true,
		Locale:       domain.LocaleEN,
	}); err != nil {
		t.Fatal(err)
	}

	if len(h.llm.requests[0].Tools) != 0 {
		t.Errorf("tools were disabled but %d specs were sent", len(h.llm.requests[0].Tools))
	}
	if len(tool.calls) != 0 {
		t.Error("the tool should not have been called")
	}
}

func TestAnExhaustedBudgetRefusesBeforeCallingTheModel(t *testing.T) {
	// The ceiling has to bite before the spend, not after. A budget checked
	// once the model has answered is not a budget.
	budgets := &fakeBudgets{budget: domain.Budget{
		TenantID:           tenantA,
		DailyQuestionLimit: 5,
		SpentQuestions:     5,
		WindowStart:        domain.DayStart(time.Now()),
	}}
	llm := &scriptedLLM{} // no responses: calling it is an error

	h := newHarness(t, Deps{Budgets: budgets, LLM: llm, Config: DefaultConfig()})

	result, err := h.svc.Ask(testContext(tenantA), inbound.AskParams{
		Question: "How much urea?",
		Locale:   domain.LocaleHI,
	})
	if err != nil {
		t.Fatal(err)
	}

	if result.Exchange.AnswerKind != domain.AnswerRefused {
		t.Fatalf("answer kind = %q", result.Exchange.AnswerKind)
	}
	if result.Exchange.Answer != domain.Phrase(domain.PhraseBudgetExhausted, domain.LocaleHI) {
		t.Errorf("the refusal should be in the asked language, got %q", result.Exchange.Answer)
	}
	if len(llm.requests) != 0 {
		t.Error("the model must not be called once the budget is spent")
	}
	if len(budgets.spends) != 0 {
		t.Error("a refused question must not be charged")
	}
	// Still logged. A queue that only holds answered questions cannot show
	// that a tenant was being refused all afternoon.
	if len(h.conversations.exchanges) != 1 {
		t.Errorf("the refusal should still be recorded, got %d exchanges", len(h.conversations.exchanges))
	}
}

func TestSpendIsRecordedWithTheConfiguredPrice(t *testing.T) {
	documents := &fakeDocuments{hits: []domain.Citation{wheatCitation()}}
	llm := &scriptedLLM{
		price: domain.ModelPrice{InputMicrosPerMillion: 3_000_000, OutputMicrosPerMillion: 15_000_000},
		responses: []outbound.LLMResponse{{
			Text:             "Apply urea as a split top dressing [1].",
			PromptTokens:     1_000_000,
			CompletionTokens: 100_000,
			Model:            "scripted-model",
		}},
	}

	h := newHarness(t, Deps{Documents: documents, LLM: llm, Config: DefaultConfig()})

	result, err := h.svc.Ask(testContext(tenantA), inbound.AskParams{
		Question: "How much urea for wheat top dressing?",
		Locale:   domain.LocaleEN,
	})
	if err != nil {
		t.Fatal(err)
	}

	want := int64(3_000_000 + 1_500_000)
	if result.Exchange.Usage.CostMicros != want {
		t.Errorf("cost = %d, want %d", result.Exchange.Usage.CostMicros, want)
	}
	if len(h.budgets.spends) != 1 || h.budgets.spends[0].CostMicros != want {
		t.Errorf("spend recorded = %+v", h.budgets.spends)
	}
}

func TestACrossTenantPassageFailsTheRequest(t *testing.T) {
	// Row-level security and the repository's own tenant filter both have to
	// fail for this to happen, which is exactly why it stops rather than
	// quietly dropping the row and answering as though nothing occurred.
	foreign := wheatCitation()
	foreign.TenantID = tenantB
	documents := &fakeDocuments{hits: []domain.Citation{foreign}}

	h := newHarness(t, Deps{Documents: documents, Config: DefaultConfig()})

	_, err := h.svc.Ask(testContext(tenantA), inbound.AskParams{
		Question: "How much urea?",
		Locale:   domain.LocaleEN,
	})
	if err == nil {
		t.Fatal("a passage belonging to another tenant must fail the request")
	}
	if strings.Contains(err.Error(), wheatPassage) || strings.Contains(err.Error(), tenantB) {
		t.Errorf("the error must not leak the other tenant's data or id: %q", err.Error())
	}
}

func TestSearchReferenceAppliesTheSameTenantGuard(t *testing.T) {
	// A retrieval-only endpoint that skipped the guard would be the way around
	// it.
	foreign := wheatCitation()
	foreign.TenantID = tenantB
	documents := &fakeDocuments{hits: []domain.Citation{foreign}}

	h := newHarness(t, Deps{Documents: documents, Config: DefaultConfig()})

	if _, err := h.svc.SearchReference(testContext(tenantA), "urea", domain.LocaleEN, "", 5); err == nil {
		t.Fatal("expected the cross-tenant guard to fire on SearchReference too")
	}
}

func TestAConversationFromAnotherTenantCannotBeContinued(t *testing.T) {
	h := newHarness(t, Deps{Config: DefaultConfig()})

	other, err := h.conversations.CreateConversation(context.Background(), &domain.Conversation{
		ID: "conv-other", TenantID: tenantB, Title: "Theirs",
	})
	if err != nil {
		t.Fatal(err)
	}

	if _, err := h.svc.Ask(testContext(tenantA), inbound.AskParams{
		ConversationID: other.ID,
		Question:       "What did we say earlier?",
		Locale:         domain.LocaleEN,
	}); err == nil {
		t.Fatal("a conversation id from another tenant must not be accepted")
	}
}

func TestFarmRecordsAreRetrievedAndCited(t *testing.T) {
	farm := &fakeFarmContext{citations: []domain.Citation{{
		ID:       "field-1",
		Kind:     domain.CitationField,
		Title:    "This field's record: North block",
		Snippet:  `{"field_id":"F1","area_hectares":2.4,"days_after_sowing":21}`,
		SourceID: "F1",
		Locale:   domain.LocaleEN,
	}}}
	documents := &fakeDocuments{hits: []domain.Citation{wheatCitation()}}

	h := newHarness(t, Deps{Documents: documents, FarmContext: farm, Config: DefaultConfig()})

	result, err := h.svc.Ask(testContext(tenantA), inbound.AskParams{
		Question: "urea top dressing for this field",
		FieldID:  "F1",
		Locale:   domain.LocaleEN,
	})
	if err != nil {
		t.Fatal(err)
	}

	var sawField bool
	for _, c := range result.Exchange.Citations {
		if c.Kind == domain.CitationField {
			sawField = true
			if c.TenantID != tenantA {
				t.Errorf("farm record citation tenant = %q", c.TenantID)
			}
		}
	}
	if !sawField {
		t.Fatalf("the field's own record should be in the context, got %d citations", len(result.Exchange.Citations))
	}
}

func TestFarmContextFailureDoesNotFailTheQuestion(t *testing.T) {
	farm := &fakeFarmContext{err: fmt.Errorf("field-service is unreachable")}
	documents := &fakeDocuments{hits: []domain.Citation{wheatCitation()}}

	h := newHarness(t, Deps{Documents: documents, FarmContext: farm, Config: DefaultConfig()})

	result, err := h.svc.Ask(testContext(tenantA), inbound.AskParams{
		Question: "How much urea for wheat top dressing?",
		FieldID:  "F1",
		Locale:   domain.LocaleEN,
	})
	if err != nil {
		t.Fatalf("one peer service being down should degrade the answer, not fail it: %v", err)
	}
	if len(result.Exchange.Citations) == 0 {
		t.Error("the reference corpus should still have answered")
	}
}

func TestAnEmptyModelReplyBecomesARefusalRatherThanABlankCard(t *testing.T) {
	documents := &fakeDocuments{hits: []domain.Citation{wheatCitation()}}
	llm := &scriptedLLM{responses: []outbound.LLMResponse{{Text: "   ", Model: "scripted-model"}}}

	h := newHarness(t, Deps{Documents: documents, LLM: llm, Config: DefaultConfig()})

	result, err := h.svc.Ask(testContext(tenantA), inbound.AskParams{
		Question: "How much urea?",
		Locale:   domain.LocaleEN,
	})
	if err != nil {
		t.Fatal(err)
	}
	if result.Exchange.AnswerKind != domain.AnswerRefused {
		t.Errorf("answer kind = %q, want REFUSED", result.Exchange.AnswerKind)
	}
	if strings.TrimSpace(result.Exchange.Answer) == "" {
		t.Error("a farmer should never be shown a blank answer")
	}
}

func TestIngestChunksAndEmbedsTheDocument(t *testing.T) {
	documents := &fakeDocuments{}
	h := newHarness(t, Deps{
		Documents: documents,
		Embedder:  &countingEmbedder{dim: 16},
		Config:    DefaultConfig(),
	})

	var body strings.Builder
	for i := 0; i < 80; i++ {
		body.WriteString("Apply the recommended dose at the correct growth stage. ")
	}

	doc, err := h.svc.IngestDocument(testContext(tenantA), &domain.ReferenceDocument{
		Title:  "Wheat package of practices",
		Kind:   domain.DocPackageOfPractice,
		Locale: domain.LocaleEN,
		Source: "ICAR",
	}, body.String())
	if err != nil {
		t.Fatal(err)
	}

	if doc.ChunkCount < 2 {
		t.Fatalf("chunk count = %d — the document should have been split", doc.ChunkCount)
	}
	for i, chunk := range documents.chunks {
		if chunk.TenantID != tenantA {
			t.Fatalf("chunk %d has tenant %q", i, chunk.TenantID)
		}
		if len(chunk.Embedding) != 16 {
			t.Fatalf("chunk %d has a %d-wide vector, embedder reports 16", i, len(chunk.Embedding))
		}
	}
	// Recorded so a corpus half-indexed by one embedder and half by another is
	// identifiable rather than merely bad.
	if doc.Embedder == "" {
		t.Error("the document should record which embedder indexed it")
	}
}

func TestIngestRefusesRatherThanStoringADocumentWithNoVectors(t *testing.T) {
	// A document indexed without embeddings is retrievable only by exact
	// words. Storing it would leave a silently worse corpus and an operator
	// with no reason to suspect anything went wrong.
	h := newHarness(t, Deps{
		Embedder: &failingEmbedder{},
		Config:   DefaultConfig(),
	})

	_, err := h.svc.IngestDocument(testContext(tenantA), &domain.ReferenceDocument{
		Title:  "Wheat guide",
		Kind:   domain.DocCropGuide,
		Source: "ICAR",
	}, "Some text that would otherwise be indexed.")
	if err == nil {
		t.Fatal("expected ingestion to fail when embedding fails")
	}
}

func TestIngestRequiresASource(t *testing.T) {
	h := newHarness(t, Deps{Config: DefaultConfig()})
	if _, err := h.svc.IngestDocument(testContext(tenantA), &domain.ReferenceDocument{
		Title: "Unattributed PDF",
		Kind:  domain.DocCropGuide,
	}, "text"); err == nil {
		t.Error("a document with no source cannot be used as a citation and should be refused")
	}
}

func TestAskRequiresATenant(t *testing.T) {
	h := newHarness(t, Deps{Config: DefaultConfig()})
	if _, err := h.svc.Ask(context.Background(), inbound.AskParams{Question: "anything"}); err == nil {
		t.Error("expected an unauthenticated ask to be refused")
	}
}

type countingEmbedder struct{ dim int }

func (e *countingEmbedder) Dim() int     { return e.dim }
func (e *countingEmbedder) Name() string { return "counting" }

func (e *countingEmbedder) Embed(_ context.Context, texts []string) ([][]float32, error) {
	out := make([][]float32, len(texts))
	for i := range texts {
		out[i] = make([]float32, e.dim)
		out[i][0] = 1
	}
	return out, nil
}

type failingEmbedder struct{}

func (e *failingEmbedder) Dim() int     { return 16 }
func (e *failingEmbedder) Name() string { return "failing" }

func (e *failingEmbedder) Embed(_ context.Context, _ []string) ([][]float32, error) {
	return nil, fmt.Errorf("the embedding endpoint is unreachable")
}
