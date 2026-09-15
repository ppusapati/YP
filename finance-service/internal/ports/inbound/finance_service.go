// Package inbound defines the primary ports for finance-service.
package inbound

import (
	"context"

	"p9e.in/samavaya/agriculture/finance-service/internal/domain"
)

// FinanceService is the primary port for cover, credit and claims.
type FinanceService interface {
	QuoteInsurance(ctx context.Context, params domain.QuoteParams) (*domain.InsuranceQuote, error)
	GetQuote(ctx context.Context, id string) (*domain.InsuranceQuote, error)
	ListQuotes(ctx context.Context, params domain.ListQuotesParams) ([]domain.InsuranceQuote, int64, error)

	AssessCredit(ctx context.Context, farmID string, fromYear, toYear int) (*domain.CreditAssessment, error)
	GetCreditAssessment(ctx context.Context, id string) (*domain.CreditAssessment, error)

	FileClaim(ctx context.Context, c *domain.Claim) (*domain.Claim, error)
	GatherEvidence(ctx context.Context, claimID string) (*domain.Claim, error)
	GetClaim(ctx context.Context, id string) (*domain.Claim, error)
	ListClaims(ctx context.Context, params domain.ListClaimsParams) ([]domain.Claim, int64, error)
	UpdateClaimStatus(ctx context.Context, id string, status domain.ClaimStatus, note string) (*domain.Claim, error)
}
