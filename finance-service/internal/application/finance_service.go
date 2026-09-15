// Package application holds finance-service's use cases.
package application

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"
	"time"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	"p9e.in/samavaya/agriculture/finance-service/internal/domain"
	"p9e.in/samavaya/agriculture/finance-service/internal/ports/inbound"
	"p9e.in/samavaya/agriculture/finance-service/internal/ports/outbound"
)

// Topics this service publishes on.
const (
	topicQuoteIssued    = "yp.finance.quote.issued"
	topicClaimFiled     = "yp.finance.claim.filed"
	topicEvidenceReady  = "yp.finance.claim.evidence_ready"
	topicCreditAssessed = "yp.finance.credit.assessed"
)

// creditWindowYears is how far back a credit assessment looks by default.
//
// Ten seasons. Long enough to see a farm through a drought cycle, short enough
// that a decade-old failure on ground that has since been levelled and drained
// does not follow a farmer forever.
const creditWindowYears = 10

// evidenceLeadDays is how far before the loss the satellite record is read.
//
// 45 days. The baseline has to be the canopy the crop had actually reached
// before the loss, and on a 10-day revisit with monsoon cloud, a fortnight's
// window can easily contain no usable scene at all.
const evidenceLeadDays = 45

type financeService struct {
	quotes    outbound.QuoteRepository
	credit    outbound.CreditRepository
	claims    outbound.ClaimRepository
	yields    outbound.YieldClient
	satellite outbound.SatelliteClient
	weather   outbound.WeatherClient
	pub       outbound.EventPublisher
	log       *p9log.Helper
	now       func() time.Time
}

// NewFinanceService creates the finance service.
func NewFinanceService(
	quotes outbound.QuoteRepository,
	credit outbound.CreditRepository,
	claims outbound.ClaimRepository,
	yields outbound.YieldClient,
	satellite outbound.SatelliteClient,
	weather outbound.WeatherClient,
	pub outbound.EventPublisher,
	log p9log.Logger,
) inbound.FinanceService {
	return &financeService{
		quotes:    quotes,
		credit:    credit,
		claims:    claims,
		yields:    yields,
		satellite: satellite,
		weather:   weather,
		pub:       pub,
		log:       p9log.NewHelper(p9log.With(log, "component", "FinanceService")),
		now:       time.Now,
	}
}

// QuoteInsurance prices a season's cover and stores the quote.
func (s *financeService) QuoteInsurance(ctx context.Context, params domain.QuoteParams) (*domain.InsuranceQuote, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	if params.Year == 0 {
		params.Year = s.now().Year()
	}

	history := s.fieldHistory(ctx, params.FieldID, params.Year)

	quote, err := domain.PriceQuote(params, history, s.now())
	if err != nil {
		return nil, errors.BadRequest("CANNOT_QUOTE", err.Error())
	}
	quote.ID = ulid.NewString()
	quote.TenantID = tenantID

	created, err := s.quotes.CreateQuote(ctx, &quote)
	if err != nil {
		return nil, err
	}

	s.publish(ctx, topicQuoteIssued, created.ID, map[string]any{
		"tenant_id":         tenantID,
		"quote_id":          created.ID,
		"field_id":          created.FieldID,
		"crop":              created.Crop,
		"year":              created.Year,
		"actuarial_premium": created.ActuarialPremium,
		"farmer_premium":    created.FarmerPremium,
		// Carried so nothing downstream can present a benchmark rate as though
		// somebody had looked at this field.
		"confidence":      created.Confidence,
		"history_seasons": created.HistorySeasons,
	})

	return created, nil
}

// fieldHistory reads a field's harvest record for pricing.
//
// A failure is logged and treated as no history rather than failing the quote.
// The quote then prices off a benchmark and says so in its confidence, which
// is a worse answer than a priced one but a much better one than no answer —
// and unlike a silent fallback, the farmer can see which they got.
func (s *financeService) fieldHistory(ctx context.Context, fieldID string, year int) []domain.YieldSeason {
	if s.yields == nil {
		return nil
	}
	history, err := s.yields.FieldHistory(ctx, fieldID, year-creditWindowYears, year)
	if err != nil {
		s.log.Warnw("msg", "could not read the field's yield history; the quote will "+
			"be priced from a benchmark", "field", fieldID, "error", err)
		return nil
	}
	return history
}

func (s *financeService) GetQuote(ctx context.Context, id string) (*domain.InsuranceQuote, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	if strings.TrimSpace(id) == "" {
		return nil, errors.BadRequest("MISSING_ID", "id is required")
	}
	return s.quotes.GetQuote(ctx, id, tenantID)
}

func (s *financeService) ListQuotes(ctx context.Context, params domain.ListQuotesParams) ([]domain.InsuranceQuote, int64, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	params.TenantID = tenantID
	params.Limit = clampLimit(params.Limit)
	return s.quotes.ListQuotes(ctx, params)
}

// AssessCredit reads a farm's harvest record into a score.
//
// A failed history read is an error here, not an empty history. An empty
// history produces INSUFFICIENT_HISTORY, which reads as "this farm has no
// track record" — and telling a farmer with eight good seasons that they have
// no track record, because a query timed out, is the kind of mistake that ends
// with them being turned down for a loan they had earned.
func (s *financeService) AssessCredit(ctx context.Context, farmID string, fromYear, toYear int) (*domain.CreditAssessment, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	if strings.TrimSpace(farmID) == "" {
		return nil, errors.BadRequest("MISSING_FARM", domain.ErrMissingFarm.Error())
	}
	if s.yields == nil {
		return nil, errors.InternalServer("YIELD_SERVICE_UNAVAILABLE",
			"yield-service is not configured, so there is no harvest record to assess")
	}

	now := s.now()
	if toYear == 0 {
		toYear = now.Year()
	}
	if fromYear == 0 {
		fromYear = toYear - creditWindowYears
	}

	history, err := s.yields.FarmHistory(ctx, farmID, fromYear, toYear)
	if err != nil {
		s.log.Errorw("msg", "could not read the farm's yield history", "farm", farmID, "error", err)
		return nil, errors.InternalServer("HISTORY_UNAVAILABLE",
			"the farm's harvest record could not be read, so no assessment has been "+
				"produced. An assessment made without it would say this farm has no "+
				"track record, which is not the same thing.")
	}

	assessment := domain.AssessCredit(farmID, history, now)
	assessment.ID = ulid.NewString()
	assessment.TenantID = tenantID

	saved, err := s.credit.SaveAssessment(ctx, &assessment)
	if err != nil {
		return nil, err
	}

	s.publish(ctx, topicCreditAssessed, saved.ID, map[string]any{
		"tenant_id":     tenantID,
		"assessment_id": saved.ID,
		"farm_id":       saved.FarmID,
		"status":        saved.Status,
		"score":         saved.Score,
		"band":          saved.Band,
		"seasons":       saved.SeasonsConsidered,
	})

	return saved, nil
}

func (s *financeService) GetCreditAssessment(ctx context.Context, id string) (*domain.CreditAssessment, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	return s.credit.GetAssessment(ctx, id, tenantID)
}

// FileClaim opens a loss claim against a quote.
func (s *financeService) FileClaim(ctx context.Context, c *domain.Claim) (*domain.Claim, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	if err := c.Validate(); err != nil {
		return nil, errors.BadRequest("INVALID_CLAIM", err.Error())
	}

	// The quote carries the threshold yield, the sum insured and the crop. A
	// claim assembled without it would be assessed against figures the
	// claimant supplied, which is not what the policy was written on.
	quote, err := s.quotes.GetQuote(ctx, c.QuoteID, tenantID)
	if err != nil {
		return nil, err
	}
	if quote.FieldID != c.FieldID {
		return nil, errors.BadRequest("FIELD_MISMATCH", fmt.Sprintf(
			"this claim is for field %s but the cover was written on field %s",
			c.FieldID, quote.FieldID))
	}
	if c.ClaimedAreaHectares > quote.AreaHectares {
		return nil, errors.BadRequest("AREA_EXCEEDS_COVER", fmt.Sprintf(
			"the claim covers %.2f ha but only %.2f ha is insured",
			c.ClaimedAreaHectares, quote.AreaHectares))
	}

	c.ID = ulid.NewString()
	c.TenantID = tenantID
	c.FarmID = quote.FarmID
	c.Crop = quote.Crop
	c.Season = quote.Season
	c.Year = quote.Year
	c.ThresholdYieldKgHa = quote.ThresholdYieldKgHa
	c.Status = domain.ClaimSubmitted
	c.SubmittedBy = actor(ctx)
	c.SubmittedAt = s.now()
	c.CreatedAt = c.SubmittedAt
	c.UpdatedAt = c.SubmittedAt
	c.Version = 1

	c.IndicatedPayout = domain.IndicatedPayout(
		quote.ThresholdYieldKgHa,
		c.ReportedYieldKgHa,
		quote.SumInsuredPerHectare,
		c.ClaimedAreaHectares,
	)

	created, err := s.claims.CreateClaim(ctx, c)
	if err != nil {
		return nil, err
	}

	s.publish(ctx, topicClaimFiled, created.ID, map[string]any{
		"tenant_id":        tenantID,
		"claim_id":         created.ID,
		"quote_id":         created.QuoteID,
		"field_id":         created.FieldID,
		"cause":            created.Cause,
		"indicated_payout": created.IndicatedPayout,
	})

	return created, nil
}

// GatherEvidence assembles the pack behind a claim.
//
// Each source is asked independently and a source that cannot answer produces
// an INCONCLUSIVE item rather than being left out. The difference matters: a
// pack with no satellite entry looks like a pack nobody bothered to build,
// while one that says "the fortnight was clouded over" is a fact about the
// claim — and it is the fact that keeps a genuine flood claim from being
// refused for lack of a picture.
func (s *financeService) GatherEvidence(ctx context.Context, claimID string) (*domain.Claim, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}

	claim, err := s.claims.GetClaim(ctx, claimID, tenantID)
	if err != nil {
		return nil, err
	}
	if !claim.Editable() {
		return nil, errors.BadRequest("CLAIM_CLOSED", fmt.Sprintf(
			"this claim is %s; its evidence pack is fixed as it was when the insurer "+
				"saw it", strings.ToLower(string(claim.Status))))
	}

	lossEnd := claim.LossEndedOn
	if lossEnd.IsZero() {
		lossEnd = claim.LossStartedOn.AddDate(0, 0, 14)
	}
	windowStart := claim.LossStartedOn.AddDate(0, 0, -evidenceLeadDays)

	evidence := []domain.Evidence{
		s.satelliteEvidence(ctx, claim.FieldID, windowStart, lossEnd, claim.LossStartedOn),
		s.weatherEvidence(ctx, claim),
		domain.AssessReportedYield(claim.ReportedYieldKgHa, claim.ThresholdYieldKgHa,
			s.fieldHistory(ctx, claim.FieldID, claim.Year)),
	}
	for i := range evidence {
		evidence[i].ID = ulid.NewString()
	}

	claim.Evidence = evidence
	claim.EvidenceSummary = domain.SummariseEvidence(evidence)
	claim.Status = domain.ClaimEvidenceReady
	claim.UpdatedAt = s.now()

	saved, err := s.claims.SaveClaim(ctx, claim)
	if err != nil {
		return nil, err
	}

	s.publish(ctx, topicEvidenceReady, saved.ID, map[string]any{
		"tenant_id": tenantID,
		"claim_id":  saved.ID,
		"field_id":  saved.FieldID,
		"cause":     saved.Cause,
		"summary":   saved.EvidenceSummary,
	})

	return saved, nil
}

func (s *financeService) satelliteEvidence(ctx context.Context, fieldID string, from, to, lossStart time.Time) domain.Evidence {
	if s.satellite == nil {
		return domain.Evidence{
			Source:  domain.EvidenceSatelliteNDVI,
			Verdict: domain.VerdictInconclusive,
			Summary: "no satellite service is configured for this deployment, so there " +
				"is no imagery behind this claim. That is a gap in the pack, not a " +
				"finding about the loss.",
		}
	}

	observations, err := s.satellite.NDVISeries(ctx, fieldID, from, to)
	if err != nil {
		s.log.Warnw("msg", "could not read the satellite record", "field", fieldID, "error", err)
		return domain.Evidence{
			Source:  domain.EvidenceSatelliteNDVI,
			Verdict: domain.VerdictInconclusive,
			Summary: "the satellite record could not be read for this field and window. " +
				"This is a gap in the pack, not evidence about the loss.",
		}
	}
	return domain.AssessNDVI(observations, lossStart, to)
}

func (s *financeService) weatherEvidence(ctx context.Context, claim *domain.Claim) domain.Evidence {
	lossEnd := claim.LossEndedOn
	if lossEnd.IsZero() {
		lossEnd = claim.LossStartedOn.AddDate(0, 0, 14)
	}

	if s.weather == nil {
		return domain.Evidence{
			Source:  domain.EvidenceWeather,
			Verdict: domain.VerdictInconclusive,
			Summary: "no weather service is configured for this deployment.",
		}
	}

	window, err := s.weather.Window(ctx, claim.FieldID, claim.LossStartedOn, lossEnd)
	if err != nil {
		s.log.Warnw("msg", "could not read the weather window", "field", claim.FieldID, "error", err)
		return domain.Evidence{
			Source:  domain.EvidenceWeather,
			Verdict: domain.VerdictInconclusive,
			Summary: "the weather record could not be read for this field and window.",
		}
	}
	return domain.AssessWeather(claim.Cause, window)
}

func (s *financeService) GetClaim(ctx context.Context, id string) (*domain.Claim, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	return s.claims.GetClaim(ctx, id, tenantID)
}

func (s *financeService) ListClaims(ctx context.Context, params domain.ListClaimsParams) ([]domain.Claim, int64, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	params.TenantID = tenantID
	params.Limit = clampLimit(params.Limit)
	return s.claims.ListClaims(ctx, params)
}

// UpdateClaimStatus records what the insurer decided.
//
// Recorded, not decided. SETTLED and REJECTED come from outside this service —
// it has never seen the policy wording — and the note that comes with them is
// required, because a claim marked rejected with no reason leaves a farmer with
// nothing to appeal against.
func (s *financeService) UpdateClaimStatus(ctx context.Context, id string, status domain.ClaimStatus, note string) (*domain.Claim, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	if status == "" {
		return nil, errors.BadRequest("MISSING_STATUS", "a status is required")
	}
	if status == domain.ClaimRejected && strings.TrimSpace(note) == "" {
		return nil, errors.BadRequest("MISSING_REASON",
			"a rejected claim needs a reason; without one the farmer has nothing to "+
				"appeal against")
	}

	claim, err := s.claims.GetClaim(ctx, id, tenantID)
	if err != nil {
		return nil, err
	}
	if claim.Status == domain.ClaimSettled || claim.Status == domain.ClaimRejected {
		return nil, errors.BadRequest("CLAIM_CLOSED", fmt.Sprintf(
			"this claim was already %s and cannot be reopened here",
			strings.ToLower(string(claim.Status))))
	}

	claim.Status = status
	claim.UpdatedAt = s.now()
	if strings.TrimSpace(note) != "" {
		claim.Description = appendNote(claim.Description, fmt.Sprintf(
			"[%s] %s: %s", claim.UpdatedAt.Format("2006-01-02"), status, note))
	}

	return s.claims.SaveClaim(ctx, claim)
}

func (s *financeService) publish(ctx context.Context, topic, key string, payload map[string]any) {
	if s.pub == nil {
		return
	}
	body, err := json.Marshal(payload)
	if err != nil {
		s.log.Errorw("msg", "could not encode event", "topic", topic, "error", err)
		return
	}
	if err := s.pub.Publish(ctx, topic, key, body); err != nil {
		s.log.Warnw("msg", "could not publish event", "topic", topic, "error", err)
	}
}

func appendNote(existing, note string) string {
	if strings.TrimSpace(existing) == "" {
		return note
	}
	return existing + "\n" + note
}

func actor(ctx context.Context) string {
	if user := p9context.UserID(ctx); user != "" {
		return user
	}
	return "system"
}

func clampLimit(limit int) int {
	switch {
	case limit <= 0:
		return 50
	case limit > 500:
		return 500
	default:
		return limit
	}
}
