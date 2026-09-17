// Package inbound defines the primary ports for advisory-service.
package inbound

import (
	"context"

	"p9e.in/samavaya/agriculture/advisory-service/internal/domain"
)

// AskParams is one question put to the assistant.
type AskParams struct {
	ConversationID string
	Question       string
	Locale         domain.Locale
	FieldID        string
	FarmID         string
	DisableTools   bool
}

// AskResult is the answer and what it cost.
type AskResult struct {
	Conversation domain.Conversation
	Exchange     domain.Exchange
	Budget       domain.Budget
}

// AdvisoryService is the primary port for the agronomy assistant.
type AdvisoryService interface {
	Ask(ctx context.Context, p AskParams) (*AskResult, error)

	GetConversation(ctx context.Context, id string) (*domain.Conversation, []domain.Exchange, error)
	ListConversations(ctx context.Context, params domain.ListConversationsParams) ([]domain.Conversation, int64, error)

	ListExchanges(ctx context.Context, params domain.ListExchangesParams) ([]domain.Exchange, int64, error)
	ReviewExchange(ctx context.Context, id, note string, rating int) (*domain.Exchange, error)

	GetBudget(ctx context.Context) (domain.Budget, error)
	SetBudget(ctx context.Context, b domain.Budget) (domain.Budget, error)

	IngestDocument(ctx context.Context, d *domain.ReferenceDocument, text string) (*domain.ReferenceDocument, error)
	ListDocuments(ctx context.Context, params domain.ListDocumentsParams) ([]domain.ReferenceDocument, int64, error)
	DeleteDocument(ctx context.Context, id string) (bool, error)

	SearchReference(ctx context.Context, query string, locale domain.Locale, crop string, limit int) ([]domain.Citation, error)
}
