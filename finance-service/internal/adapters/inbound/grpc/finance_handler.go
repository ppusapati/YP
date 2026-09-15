// Package grpc adapts the ConnectRPC surface onto finance-service's use cases.
package grpc

import (
	"context"
	"strconv"
	"time"

	"connectrpc.com/connect"
	"google.golang.org/protobuf/types/known/timestamppb"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"

	pb "p9e.in/samavaya/agriculture/finance-service/api/v1"
	"p9e.in/samavaya/agriculture/finance-service/internal/domain"
	"p9e.in/samavaya/agriculture/finance-service/internal/ports/inbound"
)

// FinanceHandler serves the FinanceService RPCs.
type FinanceHandler struct {
	svc inbound.FinanceService
	log *p9log.Helper
}

// NewFinanceHandler creates a FinanceHandler.
func NewFinanceHandler(svc inbound.FinanceService, log p9log.Logger) *FinanceHandler {
	return &FinanceHandler{
		svc: svc,
		log: p9log.NewHelper(p9log.With(log, "component", "FinanceHandler")),
	}
}

func (h *FinanceHandler) QuoteInsurance(ctx context.Context, req *connect.Request[pb.QuoteInsuranceRequest]) (*connect.Response[pb.QuoteInsuranceResponse], error) {
	quote, err := h.svc.QuoteInsurance(ctx, domain.QuoteParams{
		FieldID:              req.Msg.GetFieldId(),
		FarmID:               req.Msg.GetFarmId(),
		Crop:                 req.Msg.GetCrop(),
		Category:             categoryFromProto(req.Msg.GetCategory()),
		Season:               seasonFromProto(req.Msg.GetSeason()),
		Year:                 int(req.Msg.GetYear()),
		AreaHectares:         req.Msg.GetAreaHectares(),
		SumInsuredPerHectare: req.Msg.GetSumInsuredPerHectare(),
		IndemnityLevel:       req.Msg.GetIndemnityLevel(),
	})
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.QuoteInsuranceResponse{Quote: quoteToProto(quote)}), nil
}

func (h *FinanceHandler) GetQuote(ctx context.Context, req *connect.Request[pb.GetQuoteRequest]) (*connect.Response[pb.GetQuoteResponse], error) {
	quote, err := h.svc.GetQuote(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.GetQuoteResponse{Quote: quoteToProto(quote)}), nil
}

func (h *FinanceHandler) ListQuotes(ctx context.Context, req *connect.Request[pb.ListQuotesRequest]) (*connect.Response[pb.ListQuotesResponse], error) {
	limit, offset := page(req.Msg.GetPageSize(), req.Msg.GetPageToken())

	quotes, total, err := h.svc.ListQuotes(ctx, domain.ListQuotesParams{
		FieldID: req.Msg.GetFieldId(),
		FarmID:  req.Msg.GetFarmId(),
		Year:    int(req.Msg.GetYear()),
		Limit:   limit,
		Offset:  offset,
	})
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	out := make([]*pb.InsuranceQuote, 0, len(quotes))
	for i := range quotes {
		out = append(out, quoteToProto(&quotes[i]))
	}
	return connect.NewResponse(&pb.ListQuotesResponse{
		Quotes:        out,
		NextPageToken: nextToken(offset, limit, total),
		TotalCount:    int32(total),
	}), nil
}

func (h *FinanceHandler) AssessCredit(ctx context.Context, req *connect.Request[pb.AssessCreditRequest]) (*connect.Response[pb.AssessCreditResponse], error) {
	assessment, err := h.svc.AssessCredit(ctx,
		req.Msg.GetFarmId(), int(req.Msg.GetFromYear()), int(req.Msg.GetToYear()))
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.AssessCreditResponse{Assessment: assessmentToProto(assessment)}), nil
}

func (h *FinanceHandler) GetCreditAssessment(ctx context.Context, req *connect.Request[pb.GetCreditAssessmentRequest]) (*connect.Response[pb.GetCreditAssessmentResponse], error) {
	assessment, err := h.svc.GetCreditAssessment(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.GetCreditAssessmentResponse{Assessment: assessmentToProto(assessment)}), nil
}

func (h *FinanceHandler) FileClaim(ctx context.Context, req *connect.Request[pb.FileClaimRequest]) (*connect.Response[pb.FileClaimResponse], error) {
	claim, err := h.svc.FileClaim(ctx, &domain.Claim{
		QuoteID:             req.Msg.GetQuoteId(),
		FieldID:             req.Msg.GetFieldId(),
		Cause:               causeFromProto(req.Msg.GetCause()),
		LossStartedOn:       asTime(req.Msg.GetLossStartedOn()),
		LossEndedOn:         asTime(req.Msg.GetLossEndedOn()),
		Description:         req.Msg.GetDescription(),
		ClaimedAreaHectares: req.Msg.GetClaimedAreaHectares(),
		ReportedYieldKgHa:   req.Msg.GetReportedYieldKgHa(),
	})
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.FileClaimResponse{Claim: claimToProto(claim)}), nil
}

func (h *FinanceHandler) GatherEvidence(ctx context.Context, req *connect.Request[pb.GatherEvidenceRequest]) (*connect.Response[pb.GatherEvidenceResponse], error) {
	claim, err := h.svc.GatherEvidence(ctx, req.Msg.GetClaimId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.GatherEvidenceResponse{Claim: claimToProto(claim)}), nil
}

func (h *FinanceHandler) GetClaim(ctx context.Context, req *connect.Request[pb.GetClaimRequest]) (*connect.Response[pb.GetClaimResponse], error) {
	claim, err := h.svc.GetClaim(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.GetClaimResponse{Claim: claimToProto(claim)}), nil
}

func (h *FinanceHandler) ListClaims(ctx context.Context, req *connect.Request[pb.ListClaimsRequest]) (*connect.Response[pb.ListClaimsResponse], error) {
	limit, offset := page(req.Msg.GetPageSize(), req.Msg.GetPageToken())

	claims, total, err := h.svc.ListClaims(ctx, domain.ListClaimsParams{
		FieldID: req.Msg.GetFieldId(),
		FarmID:  req.Msg.GetFarmId(),
		Status:  claimStatusFromProto(req.Msg.GetStatus()),
		Limit:   limit,
		Offset:  offset,
	})
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	out := make([]*pb.Claim, 0, len(claims))
	for i := range claims {
		out = append(out, claimToProto(&claims[i]))
	}
	return connect.NewResponse(&pb.ListClaimsResponse{
		Claims:        out,
		NextPageToken: nextToken(offset, limit, total),
		TotalCount:    int32(total),
	}), nil
}

func (h *FinanceHandler) UpdateClaimStatus(ctx context.Context, req *connect.Request[pb.UpdateClaimStatusRequest]) (*connect.Response[pb.UpdateClaimStatusResponse], error) {
	claim, err := h.svc.UpdateClaimStatus(ctx,
		req.Msg.GetId(), claimStatusFromProto(req.Msg.GetStatus()), req.Msg.GetNote())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.UpdateClaimStatusResponse{Claim: claimToProto(claim)}), nil
}

// ─────────────────────────────────────────────────────────────────────────────
// Mapping
// ─────────────────────────────────────────────────────────────────────────────

func page(pageSize int32, pageToken string) (limit, offset int) {
	limit = int(pageSize)
	if limit <= 0 {
		limit = 50
	}
	if limit > 500 {
		limit = 500
	}
	if pageToken != "" {
		if parsed, err := strconv.Atoi(pageToken); err == nil && parsed > 0 {
			offset = parsed
		}
	}
	return limit, offset
}

func nextToken(offset, limit int, total int64) string {
	next := offset + limit
	if int64(next) >= total {
		return ""
	}
	return strconv.Itoa(next)
}

func asTime(ts *timestamppb.Timestamp) time.Time {
	if ts == nil {
		return time.Time{}
	}
	return ts.AsTime()
}

var seasonNames = map[pb.Season]domain.Season{
	pb.Season_SEASON_KHARIF: domain.Kharif,
	pb.Season_SEASON_RABI:   domain.Rabi,
	pb.Season_SEASON_ZAID:   domain.Zaid,
}

// seasonFromProto leaves an unspecified season empty.
//
// The domain then applies the kharif premium cap, which is the higher of the
// two food-crop caps — so an unstated season never quotes a farmer below what
// the scheme actually allows.
func seasonFromProto(s pb.Season) domain.Season { return seasonNames[s] }

func seasonToProto(s domain.Season) pb.Season {
	for proto, name := range seasonNames {
		if name == s {
			return proto
		}
	}
	return pb.Season_SEASON_UNSPECIFIED
}

var categoryNames = map[pb.CropCategory]domain.CropCategory{
	pb.CropCategory_CROP_CATEGORY_FOOD_GRAIN:   domain.CategoryFoodGrain,
	pb.CropCategory_CROP_CATEGORY_OILSEED:      domain.CategoryOilseed,
	pb.CropCategory_CROP_CATEGORY_COMMERCIAL:   domain.CategoryCommercial,
	pb.CropCategory_CROP_CATEGORY_HORTICULTURE: domain.CategoryHorticulture,
}

func categoryFromProto(c pb.CropCategory) domain.CropCategory { return categoryNames[c] }

func categoryToProto(c domain.CropCategory) pb.CropCategory {
	for proto, name := range categoryNames {
		if name == c {
			return proto
		}
	}
	return pb.CropCategory_CROP_CATEGORY_UNSPECIFIED
}

var confidenceNames = map[pb.QuoteConfidence]domain.QuoteConfidence{
	pb.QuoteConfidence_QUOTE_CONFIDENCE_FIELD_HISTORY:  domain.ConfidenceFieldHistory,
	pb.QuoteConfidence_QUOTE_CONFIDENCE_SHORT_HISTORY:  domain.ConfidenceShortHistory,
	pb.QuoteConfidence_QUOTE_CONFIDENCE_BENCHMARK_ONLY: domain.ConfidenceBenchmarkOnly,
}

func confidenceToProto(c domain.QuoteConfidence) pb.QuoteConfidence {
	for proto, name := range confidenceNames {
		if name == c {
			return proto
		}
	}
	return pb.QuoteConfidence_QUOTE_CONFIDENCE_UNSPECIFIED
}

var bandNames = map[pb.CreditBand]domain.CreditBand{
	pb.CreditBand_CREDIT_BAND_POOR:      domain.BandPoor,
	pb.CreditBand_CREDIT_BAND_FAIR:      domain.BandFair,
	pb.CreditBand_CREDIT_BAND_GOOD:      domain.BandGood,
	pb.CreditBand_CREDIT_BAND_EXCELLENT: domain.BandExcellent,
}

func bandToProto(b domain.CreditBand) pb.CreditBand {
	for proto, name := range bandNames {
		if name == b {
			return proto
		}
	}
	return pb.CreditBand_CREDIT_BAND_UNSPECIFIED
}

var scoreStatusNames = map[pb.ScoreStatus]domain.ScoreStatus{
	pb.ScoreStatus_SCORE_STATUS_SCORED:               domain.ScoreScored,
	pb.ScoreStatus_SCORE_STATUS_INSUFFICIENT_HISTORY: domain.ScoreInsufficientHistory,
}

func scoreStatusToProto(s domain.ScoreStatus) pb.ScoreStatus {
	for proto, name := range scoreStatusNames {
		if name == s {
			return proto
		}
	}
	return pb.ScoreStatus_SCORE_STATUS_UNSPECIFIED
}

var causeNames = map[pb.LossCause]domain.LossCause{
	pb.LossCause_LOSS_CAUSE_DROUGHT:         domain.CauseDrought,
	pb.LossCause_LOSS_CAUSE_FLOOD:           domain.CauseFlood,
	pb.LossCause_LOSS_CAUSE_UNSEASONAL_RAIN: domain.CauseUnseasonalRain,
	pb.LossCause_LOSS_CAUSE_HAIL:            domain.CauseHail,
	pb.LossCause_LOSS_CAUSE_CYCLONE:         domain.CauseCyclone,
	pb.LossCause_LOSS_CAUSE_PEST:            domain.CausePest,
	pb.LossCause_LOSS_CAUSE_DISEASE:         domain.CauseDisease,
	pb.LossCause_LOSS_CAUSE_FIRE:            domain.CauseFire,
}

// causeFromProto leaves an unspecified cause empty so the claim is refused.
//
// Every weather test here is written against a specific cause, and guessing
// one would assess a flood claim with a drought's criterion.
func causeFromProto(c pb.LossCause) domain.LossCause { return causeNames[c] }

func causeToProto(c domain.LossCause) pb.LossCause {
	for proto, name := range causeNames {
		if name == c {
			return proto
		}
	}
	return pb.LossCause_LOSS_CAUSE_UNSPECIFIED
}

var claimStatusNames = map[pb.ClaimStatus]domain.ClaimStatus{
	pb.ClaimStatus_CLAIM_STATUS_DRAFT:          domain.ClaimDraft,
	pb.ClaimStatus_CLAIM_STATUS_SUBMITTED:      domain.ClaimSubmitted,
	pb.ClaimStatus_CLAIM_STATUS_EVIDENCE_READY: domain.ClaimEvidenceReady,
	pb.ClaimStatus_CLAIM_STATUS_SETTLED:        domain.ClaimSettled,
	pb.ClaimStatus_CLAIM_STATUS_REJECTED:       domain.ClaimRejected,
	pb.ClaimStatus_CLAIM_STATUS_WITHDRAWN:      domain.ClaimWithdrawn,
}

func claimStatusFromProto(s pb.ClaimStatus) domain.ClaimStatus { return claimStatusNames[s] }

func claimStatusToProto(s domain.ClaimStatus) pb.ClaimStatus {
	for proto, name := range claimStatusNames {
		if name == s {
			return proto
		}
	}
	return pb.ClaimStatus_CLAIM_STATUS_UNSPECIFIED
}

var evidenceSourceNames = map[pb.EvidenceSource]domain.EvidenceSource{
	pb.EvidenceSource_EVIDENCE_SOURCE_SATELLITE_NDVI:   domain.EvidenceSatelliteNDVI,
	pb.EvidenceSource_EVIDENCE_SOURCE_WEATHER:          domain.EvidenceWeather,
	pb.EvidenceSource_EVIDENCE_SOURCE_FIELD_INSPECTION: domain.EvidenceFieldInspection,
	pb.EvidenceSource_EVIDENCE_SOURCE_YIELD_RECORD:     domain.EvidenceYieldRecord,
	pb.EvidenceSource_EVIDENCE_SOURCE_PHOTO:            domain.EvidencePhoto,
}

func evidenceSourceToProto(s domain.EvidenceSource) pb.EvidenceSource {
	for proto, name := range evidenceSourceNames {
		if name == s {
			return proto
		}
	}
	return pb.EvidenceSource_EVIDENCE_SOURCE_UNSPECIFIED
}

var verdictNames = map[pb.EvidenceVerdict]domain.EvidenceVerdict{
	pb.EvidenceVerdict_EVIDENCE_VERDICT_SUPPORTS:     domain.VerdictSupports,
	pb.EvidenceVerdict_EVIDENCE_VERDICT_CONTRADICTS:  domain.VerdictContradicts,
	pb.EvidenceVerdict_EVIDENCE_VERDICT_INCONCLUSIVE: domain.VerdictInconclusive,
}

func verdictToProto(v domain.EvidenceVerdict) pb.EvidenceVerdict {
	for proto, name := range verdictNames {
		if name == v {
			return proto
		}
	}
	return pb.EvidenceVerdict_EVIDENCE_VERDICT_UNSPECIFIED
}

func quoteToProto(q *domain.InsuranceQuote) *pb.InsuranceQuote {
	if q == nil {
		return nil
	}
	out := &pb.InsuranceQuote{
		Id:                   q.ID,
		FieldId:              q.FieldID,
		FarmId:               q.FarmID,
		Crop:                 q.Crop,
		Category:             categoryToProto(q.Category),
		Season:               seasonToProto(q.Season),
		Year:                 int32(q.Year),
		AreaHectares:         q.AreaHectares,
		SumInsuredPerHectare: q.SumInsuredPerHectare,
		TotalSumInsured:      q.TotalSumInsured,
		IndemnityLevel:       q.IndemnityLevel,
		ThresholdYieldKgHa:   q.ThresholdYieldKgHa,
		ActuarialPremium:     q.ActuarialPremium,
		ActuarialRate:        q.ActuarialRate,
		FarmerPremium:        q.FarmerPremium,
		Subsidy:              q.Subsidy,
		// Always sent. A benchmark rate and a priced one look identical without
		// it, and the farmer has no way to tell that nobody looked at their field.
		Confidence:     confidenceToProto(q.Confidence),
		HistorySeasons: int32(q.HistorySeasons),
		Basis:          q.Basis,
	}
	if !q.QuotedAt.IsZero() {
		out.QuotedAt = timestamppb.New(q.QuotedAt)
	}
	if !q.ExpiresAt.IsZero() {
		out.ExpiresAt = timestamppb.New(q.ExpiresAt)
	}

	out.Lines = make([]*pb.PremiumLine, 0, len(q.Lines))
	for _, line := range q.Lines {
		out.Lines = append(out.Lines, &pb.PremiumLine{
			Label:  line.Label,
			Rate:   line.Rate,
			Amount: line.Amount,
			Basis:  line.Basis,
		})
	}
	return out
}

func assessmentToProto(a *domain.CreditAssessment) *pb.CreditAssessment {
	if a == nil {
		return nil
	}
	out := &pb.CreditAssessment{
		Id:                   a.ID,
		FarmId:               a.FarmID,
		Status:               scoreStatusToProto(a.Status),
		Score:                int32(a.Score),
		Band:                 bandToProto(a.Band),
		SeasonsConsidered:    int32(a.SeasonsConsidered),
		MeanYieldKgHa:        a.MeanYieldKgHa,
		YieldVariability:     a.YieldVariability,
		MeanProfitPerHectare: a.MeanProfitPerHa,
		IndicativeLimit:      a.IndicativeLimit,
		// Never omitted. The caveat is what stops a score being read as a
		// lending decision by whoever renders it.
		Caveat: a.Caveat,
	}
	if !a.AssessedAt.IsZero() {
		out.AssessedAt = timestamppb.New(a.AssessedAt)
	}

	out.Factors = make([]*pb.ScoreFactor, 0, len(a.Factors))
	for _, f := range a.Factors {
		out.Factors = append(out.Factors, &pb.ScoreFactor{
			Code:        f.Code,
			Label:       f.Label,
			Points:      f.Points,
			Value:       f.Value,
			Explanation: f.Explanation,
		})
	}
	return out
}

func claimToProto(c *domain.Claim) *pb.Claim {
	if c == nil {
		return nil
	}
	out := &pb.Claim{
		Id:                  c.ID,
		QuoteId:             c.QuoteID,
		FieldId:             c.FieldID,
		FarmId:              c.FarmID,
		Crop:                c.Crop,
		Season:              seasonToProto(c.Season),
		Year:                int32(c.Year),
		Cause:               causeToProto(c.Cause),
		Description:         c.Description,
		Status:              claimStatusToProto(c.Status),
		ClaimedAreaHectares: c.ClaimedAreaHectares,
		ReportedYieldKgHa:   c.ReportedYieldKgHa,
		ThresholdYieldKgHa:  c.ThresholdYieldKgHa,
		IndicatedPayout:     c.IndicatedPayout,
		EvidenceSummary:     c.EvidenceSummary,
		SubmittedBy:         c.SubmittedBy,
		Version:             c.Version,
	}
	for _, pair := range []struct {
		from time.Time
		to   **timestamppb.Timestamp
	}{
		{c.LossStartedOn, &out.LossStartedOn},
		{c.LossEndedOn, &out.LossEndedOn},
		{c.SubmittedAt, &out.SubmittedAt},
		{c.CreatedAt, &out.CreatedAt},
		{c.UpdatedAt, &out.UpdatedAt},
	} {
		if !pair.from.IsZero() {
			*pair.to = timestamppb.New(pair.from)
		}
	}

	out.Evidence = make([]*pb.Evidence, 0, len(c.Evidence))
	for _, item := range c.Evidence {
		evidence := &pb.Evidence{
			Id:      item.ID,
			Source:  evidenceSourceToProto(item.Source),
			Verdict: verdictToProto(item.Verdict),
			Summary: item.Summary,
			// Sent with the verdict so a reader can see what the verdict was
			// drawn from rather than taking the word for it.
			Observed:  item.Observed,
			Baseline:  item.Baseline,
			Unit:      item.Unit,
			Reference: item.Reference,
		}
		if !item.ObservedAt.IsZero() {
			evidence.ObservedAt = timestamppb.New(item.ObservedAt)
		}
		out.Evidence = append(out.Evidence, evidence)
	}
	return out
}
