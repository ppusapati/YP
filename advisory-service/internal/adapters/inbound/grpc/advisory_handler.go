// Package grpc adapts advisory-service's primary port to Connect.
package grpc

import (
	"context"
	"time"

	"connectrpc.com/connect"
	"google.golang.org/protobuf/types/known/timestamppb"

	"p9e.in/samavaya/packages/p9log"

	advisoryv1 "p9e.in/samavaya/agriculture/advisory-service/api/v1"
	"p9e.in/samavaya/agriculture/advisory-service/api/v1/advisoryv1connect"
	"p9e.in/samavaya/agriculture/advisory-service/internal/domain"
	"p9e.in/samavaya/agriculture/advisory-service/internal/ports/inbound"
)

// AdvisoryHandler serves the AdvisoryService RPCs.
type AdvisoryHandler struct {
	advisoryv1connect.UnimplementedAdvisoryServiceHandler
	svc inbound.AdvisoryService
	log *p9log.Helper
}

// NewAdvisoryHandler creates the Connect handler.
func NewAdvisoryHandler(svc inbound.AdvisoryService, log p9log.Logger) *AdvisoryHandler {
	return &AdvisoryHandler{
		svc: svc,
		log: p9log.NewHelper(p9log.With(log, "component", "AdvisoryHandler")),
	}
}

func (h *AdvisoryHandler) Ask(
	ctx context.Context,
	req *connect.Request[advisoryv1.AskRequest],
) (*connect.Response[advisoryv1.AskResponse], error) {
	msg := req.Msg
	result, err := h.svc.Ask(ctx, inbound.AskParams{
		ConversationID: msg.GetConversationId(),
		Question:       msg.GetQuestion(),
		Locale:         localeFromProto(msg.GetLocale()),
		FieldID:        msg.GetFieldId(),
		FarmID:         msg.GetFarmId(),
		DisableTools:   msg.GetDisableTools(),
	})
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&advisoryv1.AskResponse{
		ConversationId: result.Conversation.ID,
		Exchange:       exchangeToProto(result.Exchange),
		Budget:         budgetToProto(result.Budget),
	}), nil
}

func (h *AdvisoryHandler) GetConversation(
	ctx context.Context,
	req *connect.Request[advisoryv1.GetConversationRequest],
) (*connect.Response[advisoryv1.GetConversationResponse], error) {
	conversation, exchanges, err := h.svc.GetConversation(ctx, req.Msg.GetId())
	if err != nil {
		return nil, err
	}
	out := &advisoryv1.GetConversationResponse{
		Conversation: conversationToProto(*conversation),
		Exchanges:    make([]*advisoryv1.Exchange, 0, len(exchanges)),
	}
	for _, e := range exchanges {
		out.Exchanges = append(out.Exchanges, exchangeToProto(e))
	}
	return connect.NewResponse(out), nil
}

func (h *AdvisoryHandler) ListConversations(
	ctx context.Context,
	req *connect.Request[advisoryv1.ListConversationsRequest],
) (*connect.Response[advisoryv1.ListConversationsResponse], error) {
	conversations, total, err := h.svc.ListConversations(ctx, domain.ListConversationsParams{
		FieldID: req.Msg.GetFieldId(),
		FarmID:  req.Msg.GetFarmId(),
		Limit:   int(req.Msg.GetPageSize()),
		Offset:  int(req.Msg.GetPageOffset()),
	})
	if err != nil {
		return nil, err
	}
	out := &advisoryv1.ListConversationsResponse{
		Conversations: make([]*advisoryv1.Conversation, 0, len(conversations)),
		TotalCount:    int32(total),
	}
	for _, c := range conversations {
		out.Conversations = append(out.Conversations, conversationToProto(c))
	}
	return connect.NewResponse(out), nil
}

func (h *AdvisoryHandler) ListExchanges(
	ctx context.Context,
	req *connect.Request[advisoryv1.ListExchangesRequest],
) (*connect.Response[advisoryv1.ListExchangesResponse], error) {
	exchanges, total, err := h.svc.ListExchanges(ctx, domain.ListExchangesParams{
		ConversationID: req.Msg.GetConversationId(),
		NeedsReview:    req.Msg.GetNeedsReviewOnly(),
		Unreviewed:     req.Msg.GetUnreviewedOnly(),
		Limit:          int(req.Msg.GetPageSize()),
		Offset:         int(req.Msg.GetPageOffset()),
	})
	if err != nil {
		return nil, err
	}
	out := &advisoryv1.ListExchangesResponse{
		Exchanges:  make([]*advisoryv1.Exchange, 0, len(exchanges)),
		TotalCount: int32(total),
	}
	for _, e := range exchanges {
		out.Exchanges = append(out.Exchanges, exchangeToProto(e))
	}
	return connect.NewResponse(out), nil
}

func (h *AdvisoryHandler) ReviewExchange(
	ctx context.Context,
	req *connect.Request[advisoryv1.ReviewExchangeRequest],
) (*connect.Response[advisoryv1.ReviewExchangeResponse], error) {
	exchange, err := h.svc.ReviewExchange(ctx,
		req.Msg.GetExchangeId(), req.Msg.GetNote(), int(req.Msg.GetRating()))
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&advisoryv1.ReviewExchangeResponse{
		Exchange: exchangeToProto(*exchange),
	}), nil
}

func (h *AdvisoryHandler) GetTenantBudget(
	ctx context.Context,
	_ *connect.Request[advisoryv1.GetTenantBudgetRequest],
) (*connect.Response[advisoryv1.GetTenantBudgetResponse], error) {
	budget, err := h.svc.GetBudget(ctx)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&advisoryv1.GetTenantBudgetResponse{
		Budget: budgetToProto(budget),
	}), nil
}

func (h *AdvisoryHandler) SetTenantBudget(
	ctx context.Context,
	req *connect.Request[advisoryv1.SetTenantBudgetRequest],
) (*connect.Response[advisoryv1.SetTenantBudgetResponse], error) {
	budget, err := h.svc.SetBudget(ctx, domain.Budget{
		DailyCostMicros:      req.Msg.GetDailyCostMicros(),
		DailyQuestionLimit:   int(req.Msg.GetDailyQuestionLimit()),
		RequestLatencyBudget: time.Duration(req.Msg.GetRequestLatencyBudgetMs()) * time.Millisecond,
	})
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&advisoryv1.SetTenantBudgetResponse{
		Budget: budgetToProto(budget),
	}), nil
}

func (h *AdvisoryHandler) IngestDocument(
	ctx context.Context,
	req *connect.Request[advisoryv1.IngestDocumentRequest],
) (*connect.Response[advisoryv1.IngestDocumentResponse], error) {
	msg := req.Msg
	doc, err := h.svc.IngestDocument(ctx, &domain.ReferenceDocument{
		Title:  msg.GetTitle(),
		Kind:   documentKindFromProto(msg.GetKind()),
		Locale: localeFromProto(msg.GetLocale()),
		Source: msg.GetSource(),
		URI:    msg.GetUri(),
		Crops:  msg.GetCrops(),
		Region: msg.GetRegion(),
	}, msg.GetText())
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&advisoryv1.IngestDocumentResponse{
		Document: documentToProto(*doc),
	}), nil
}

func (h *AdvisoryHandler) ListDocuments(
	ctx context.Context,
	req *connect.Request[advisoryv1.ListDocumentsRequest],
) (*connect.Response[advisoryv1.ListDocumentsResponse], error) {
	docs, total, err := h.svc.ListDocuments(ctx, domain.ListDocumentsParams{
		Locale: localeFromProto(req.Msg.GetLocale()),
		Crop:   req.Msg.GetCrop(),
		Region: req.Msg.GetRegion(),
		Limit:  int(req.Msg.GetPageSize()),
		Offset: int(req.Msg.GetPageOffset()),
	})
	if err != nil {
		return nil, err
	}
	out := &advisoryv1.ListDocumentsResponse{
		Documents:  make([]*advisoryv1.ReferenceDocument, 0, len(docs)),
		TotalCount: int32(total),
	}
	for _, d := range docs {
		out.Documents = append(out.Documents, documentToProto(d))
	}
	return connect.NewResponse(out), nil
}

func (h *AdvisoryHandler) DeleteDocument(
	ctx context.Context,
	req *connect.Request[advisoryv1.DeleteDocumentRequest],
) (*connect.Response[advisoryv1.DeleteDocumentResponse], error) {
	deleted, err := h.svc.DeleteDocument(ctx, req.Msg.GetId())
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&advisoryv1.DeleteDocumentResponse{Deleted: deleted}), nil
}

func (h *AdvisoryHandler) SearchReference(
	ctx context.Context,
	req *connect.Request[advisoryv1.SearchReferenceRequest],
) (*connect.Response[advisoryv1.SearchReferenceResponse], error) {
	results, err := h.svc.SearchReference(ctx,
		req.Msg.GetQuery(), localeFromProto(req.Msg.GetLocale()),
		req.Msg.GetCrop(), int(req.Msg.GetLimit()))
	if err != nil {
		return nil, err
	}
	out := &advisoryv1.SearchReferenceResponse{
		Results: make([]*advisoryv1.Citation, 0, len(results)),
	}
	for _, c := range results {
		out.Results = append(out.Results, citationToProto(c))
	}
	return connect.NewResponse(out), nil
}

// ── Mapping ──────────────────────────────────────────────────────────────────

var localeToProtoMap = map[domain.Locale]advisoryv1.Locale{
	domain.LocaleEN: advisoryv1.Locale_LOCALE_EN,
	domain.LocaleHI: advisoryv1.Locale_LOCALE_HI,
	domain.LocaleMR: advisoryv1.Locale_LOCALE_MR,
	domain.LocaleTE: advisoryv1.Locale_LOCALE_TE,
	domain.LocaleTA: advisoryv1.Locale_LOCALE_TA,
	domain.LocaleKN: advisoryv1.Locale_LOCALE_KN,
	domain.LocalePA: advisoryv1.Locale_LOCALE_PA,
	domain.LocaleBN: advisoryv1.Locale_LOCALE_BN,
}

func localeFromProto(l advisoryv1.Locale) domain.Locale {
	for locale, proto := range localeToProtoMap {
		if proto == l {
			return locale
		}
	}
	return domain.LocaleUnspecified
}

func localeToProto(l domain.Locale) advisoryv1.Locale {
	if proto, ok := localeToProtoMap[l]; ok {
		return proto
	}
	return advisoryv1.Locale_LOCALE_UNSPECIFIED
}

var citationKindToProtoMap = map[domain.CitationKind]advisoryv1.CitationKind{
	domain.CitationDocument:      advisoryv1.CitationKind_CITATION_KIND_DOCUMENT,
	domain.CitationField:         advisoryv1.CitationKind_CITATION_KIND_FIELD,
	domain.CitationPrescription:  advisoryv1.CitationKind_CITATION_KIND_PRESCRIPTION,
	domain.CitationAlert:         advisoryv1.CitationKind_CITATION_KIND_ALERT,
	domain.CitationWeather:       advisoryv1.CitationKind_CITATION_KIND_WEATHER,
	domain.CitationDiagnosis:     advisoryv1.CitationKind_CITATION_KIND_DIAGNOSIS,
	domain.CitationYieldForecast: advisoryv1.CitationKind_CITATION_KIND_YIELD_FORECAST,
	domain.CitationIrrigation:    advisoryv1.CitationKind_CITATION_KIND_IRRIGATION,
	domain.CitationPestRisk:      advisoryv1.CitationKind_CITATION_KIND_PEST_RISK,
	domain.CitationSoil:          advisoryv1.CitationKind_CITATION_KIND_SOIL,
}

var answerKindToProtoMap = map[domain.AnswerKind]advisoryv1.AnswerKind{
	domain.AnswerGenerated:  advisoryv1.AnswerKind_ANSWER_KIND_GENERATED,
	domain.AnswerExtractive: advisoryv1.AnswerKind_ANSWER_KIND_EXTRACTIVE,
	domain.AnswerRefused:    advisoryv1.AnswerKind_ANSWER_KIND_REFUSED,
}

var verdictToProtoMap = map[domain.GroundednessVerdict]advisoryv1.GroundednessVerdict{
	domain.VerdictGrounded:   advisoryv1.GroundednessVerdict_GROUNDEDNESS_VERDICT_GROUNDED,
	domain.VerdictPartial:    advisoryv1.GroundednessVerdict_GROUNDEDNESS_VERDICT_PARTIAL,
	domain.VerdictUngrounded: advisoryv1.GroundednessVerdict_GROUNDEDNESS_VERDICT_UNGROUNDED,
}

var documentKindToProtoMap = map[domain.DocumentKind]advisoryv1.DocumentKind{
	domain.DocAgronomyReference: advisoryv1.DocumentKind_DOCUMENT_KIND_AGRONOMY_REFERENCE,
	domain.DocCropGuide:         advisoryv1.DocumentKind_DOCUMENT_KIND_CROP_GUIDE,
	domain.DocRegionalAdvisory:  advisoryv1.DocumentKind_DOCUMENT_KIND_REGIONAL_ADVISORY,
	domain.DocPackageOfPractice: advisoryv1.DocumentKind_DOCUMENT_KIND_PACKAGE_OF_PRACTICES,
}

func documentKindFromProto(k advisoryv1.DocumentKind) domain.DocumentKind {
	for kind, proto := range documentKindToProtoMap {
		if proto == k {
			return kind
		}
	}
	// Unspecified becomes a general agronomy reference rather than being
	// rejected. A crop guide filed under the wrong heading is still a usable
	// citation; a rejected upload is one the operator has to re-do to learn
	// which of four near-synonymous kinds this service wanted.
	return domain.DocAgronomyReference
}

func citationToProto(c domain.Citation) *advisoryv1.Citation {
	return &advisoryv1.Citation{
		Id:       c.ID,
		Kind:     citationKindToProtoMap[c.Kind],
		Title:    c.Title,
		Snippet:  c.Snippet,
		Uri:      c.URI,
		SourceId: c.SourceID,
		Score:    c.Score,
		Marker:   int32(c.Marker),
		Locale:   localeToProto(c.Locale),
	}
}

func exchangeToProto(e domain.Exchange) *advisoryv1.Exchange {
	out := &advisoryv1.Exchange{
		Id:             e.ID,
		ConversationId: e.ConversationID,
		Question:       e.Question,
		Answer:         e.Answer,
		Locale:         localeToProto(e.Locale),
		AnswerKind:     answerKindToProtoMap[e.AnswerKind],
		AskedBy:        e.AskedBy,
		CreatedAt:      timestamppb.New(e.CreatedAt),
		Reviewed:       e.Reviewed,
		ReviewerNote:   e.ReviewerNote,
		Rating:         int32(e.Rating),
		ReviewedBy:     e.ReviewedBy,
		Evaluation: &advisoryv1.Evaluation{
			Verdict:            verdictToProtoMap[e.Evaluation.Verdict],
			Groundedness:       e.Evaluation.Groundedness,
			UnsupportedNumbers: e.Evaluation.UnsupportedNumbers,
			NeedsReview:        e.Evaluation.NeedsReview,
			Notes:              e.Evaluation.Notes,
		},
		Usage: &advisoryv1.Usage{
			PromptTokens:     int32(e.Usage.PromptTokens),
			CompletionTokens: int32(e.Usage.CompletionTokens),
			LatencyMs:        e.Usage.Latency.Milliseconds(),
			CostMicros:       e.Usage.CostMicros,
			Model:            e.Usage.Model,
		},
	}
	for _, c := range e.Citations {
		out.Citations = append(out.Citations, citationToProto(c))
	}
	for _, t := range e.ToolCalls {
		out.ToolCalls = append(out.ToolCalls, &advisoryv1.ToolCall{
			Name:          t.Name,
			ArgumentsJson: t.ArgumentsJSON,
			ResultJson:    t.ResultJSON,
			Ok:            t.OK,
			Error:         t.Error,
			LatencyMs:     t.Latency.Milliseconds(),
		})
	}
	for _, u := range e.Evaluation.Unsupported {
		out.Evaluation.Unsupported = append(out.Evaluation.Unsupported, &advisoryv1.UnsupportedClaim{
			Text:   u.Text,
			Reason: u.Reason,
		})
	}
	if e.ReviewedAt != nil {
		out.ReviewedAt = timestamppb.New(*e.ReviewedAt)
	}
	return out
}

func conversationToProto(c domain.Conversation) *advisoryv1.Conversation {
	return &advisoryv1.Conversation{
		Id:            c.ID,
		Title:         c.Title,
		FieldId:       c.FieldID,
		FarmId:        c.FarmID,
		Locale:        localeToProto(c.Locale),
		CreatedAt:     timestamppb.New(c.CreatedAt),
		UpdatedAt:     timestamppb.New(c.UpdatedAt),
		ExchangeCount: int32(c.ExchangeCount),
	}
}

func documentToProto(d domain.ReferenceDocument) *advisoryv1.ReferenceDocument {
	return &advisoryv1.ReferenceDocument{
		Id:         d.ID,
		Title:      d.Title,
		Kind:       documentKindToProtoMap[d.Kind],
		Locale:     localeToProto(d.Locale),
		Source:     d.Source,
		Uri:        d.URI,
		Crops:      d.Crops,
		Region:     d.Region,
		ChunkCount: int32(d.ChunkCount),
		CreatedAt:  timestamppb.New(d.CreatedAt),
	}
}

func budgetToProto(b domain.Budget) *advisoryv1.TenantBudget {
	return &advisoryv1.TenantBudget{
		TenantId:               b.TenantID,
		DailyCostMicros:        b.DailyCostMicros,
		DailyQuestionLimit:     int32(b.DailyQuestionLimit),
		RequestLatencyBudgetMs: b.LatencyBudget().Milliseconds(),
		SpentCostMicros:        b.SpentCostMicros,
		SpentQuestions:         int32(b.SpentQuestions),
		Exhausted:              b.Exhausted(),
		WindowResetsAt:         timestamppb.New(b.WindowResetsAt()),
	}
}
