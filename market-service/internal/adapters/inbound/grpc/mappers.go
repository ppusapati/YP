package grpc

import (
	"strconv"

	"google.golang.org/protobuf/types/known/timestamppb"

	pb "p9e.in/samavaya/agriculture/market-service/api/v1"
	"p9e.in/samavaya/agriculture/market-service/internal/domain"
)

// page turns a page size and an offset token into repository bounds.
//
// The token is the offset as a decimal string. An unparseable one starts from
// the beginning rather than erroring: a client that lost its place should see
// the first page, not a failure.
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

// nextToken is the token for the page after this one, or "" at the end.
func nextToken(offset, limit int, total int64) string {
	next := offset + limit
	if int64(next) >= total {
		return ""
	}
	return strconv.Itoa(next)
}

// ─────────────────────────────────────────────────────────────────────────────
// Enums
// ─────────────────────────────────────────────────────────────────────────────

func marketKindFromProto(k pb.MarketKind) domain.MarketKind {
	switch k {
	case pb.MarketKind_MARKET_KIND_MANDI:
		return domain.MarketMandi
	case pb.MarketKind_MARKET_KIND_EXCHANGE:
		return domain.MarketExchange
	case pb.MarketKind_MARKET_KIND_FARM_GATE:
		return domain.MarketFarmGate
	default:
		// Unspecified means "do not filter", so an empty kind is right here
		// rather than a default of MANDI that would silently hide the others.
		return ""
	}
}

func marketKindToProto(k domain.MarketKind) pb.MarketKind {
	switch k {
	case domain.MarketMandi:
		return pb.MarketKind_MARKET_KIND_MANDI
	case domain.MarketExchange:
		return pb.MarketKind_MARKET_KIND_EXCHANGE
	case domain.MarketFarmGate:
		return pb.MarketKind_MARKET_KIND_FARM_GATE
	default:
		return pb.MarketKind_MARKET_KIND_UNSPECIFIED
	}
}

func unitFromProto(u pb.PriceUnit) domain.PriceUnit {
	switch u {
	case pb.PriceUnit_PRICE_UNIT_PER_KG:
		return domain.UnitPerKg
	case pb.PriceUnit_PRICE_UNIT_PER_QUINTAL:
		return domain.UnitPerQuintal
	case pb.PriceUnit_PRICE_UNIT_PER_TONNE:
		return domain.UnitPerTonne
	default:
		// Left empty deliberately. Defaulting an unspecified unit to
		// per-quintal would silently divide an exchange price by ten; the
		// domain refuses it and the rejection names the quote.
		return ""
	}
}

func unitToProto(u domain.PriceUnit) pb.PriceUnit {
	switch u {
	case domain.UnitPerKg:
		return pb.PriceUnit_PRICE_UNIT_PER_KG
	case domain.UnitPerQuintal:
		return pb.PriceUnit_PRICE_UNIT_PER_QUINTAL
	case domain.UnitPerTonne:
		return pb.PriceUnit_PRICE_UNIT_PER_TONNE
	default:
		return pb.PriceUnit_PRICE_UNIT_UNSPECIFIED
	}
}

func trendToProto(t domain.PriceTrend) pb.PriceTrend {
	switch t {
	case domain.TrendRising:
		return pb.PriceTrend_PRICE_TREND_RISING
	case domain.TrendFalling:
		return pb.PriceTrend_PRICE_TREND_FALLING
	case domain.TrendFlat:
		return pb.PriceTrend_PRICE_TREND_FLAT
	default:
		return pb.PriceTrend_PRICE_TREND_UNSPECIFIED
	}
}

func recommendationToProto(r domain.SellRecommendation) pb.SellRecommendation {
	switch r {
	case domain.SellNow:
		return pb.SellRecommendation_SELL_RECOMMENDATION_SELL_NOW
	case domain.Hold:
		return pb.SellRecommendation_SELL_RECOMMENDATION_HOLD
	case domain.InsufficientData:
		return pb.SellRecommendation_SELL_RECOMMENDATION_INSUFFICIENT_DATA
	default:
		return pb.SellRecommendation_SELL_RECOMMENDATION_UNSPECIFIED
	}
}

func alertDirectionFromProto(d pb.AlertDirection) domain.AlertDirection {
	switch d {
	case pb.AlertDirection_ALERT_DIRECTION_ABOVE:
		return domain.AlertAbove
	case pb.AlertDirection_ALERT_DIRECTION_BELOW:
		return domain.AlertBelow
	default:
		// Left empty so Validate refuses it by name rather than the alert
		// being created with a direction it will never fire on.
		return ""
	}
}

func alertDirectionToProto(d domain.AlertDirection) pb.AlertDirection {
	switch d {
	case domain.AlertAbove:
		return pb.AlertDirection_ALERT_DIRECTION_ABOVE
	case domain.AlertBelow:
		return pb.AlertDirection_ALERT_DIRECTION_BELOW
	default:
		return pb.AlertDirection_ALERT_DIRECTION_UNSPECIFIED
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Messages
// ─────────────────────────────────────────────────────────────────────────────

func marketToProto(m *domain.Market) *pb.Market {
	return &pb.Market{
		Id:          m.ID,
		Name:        m.Name,
		Kind:        marketKindToProto(m.Kind),
		State:       m.State,
		District:    m.District,
		Latitude:    m.Latitude,
		Longitude:   m.Longitude,
		ExternalRef: m.ExternalRef,
	}
}

func quoteFromProto(q *pb.PriceQuote) domain.PriceQuote {
	out := domain.PriceQuote{
		Commodity:      q.GetCommodity(),
		Variety:        q.GetVariety(),
		MarketID:       q.GetMarketId(),
		MarketName:     q.GetMarketName(),
		MinPrice:       q.GetMinPrice(),
		MaxPrice:       q.GetMaxPrice(),
		ModalPrice:     q.GetModalPrice(),
		Unit:           unitFromProto(q.GetUnit()),
		Currency:       q.GetCurrency(),
		ArrivalsTonnes: q.GetArrivalsTonnes(),
		Source:         q.GetSource(),
	}
	if ts := q.GetQuotedOn(); ts != nil {
		out.QuotedOn = ts.AsTime()
	}
	// price_per_quintal is deliberately not read from the request. It is
	// derived, and trusting a caller's copy would let a feed send a modal price
	// in one unit and a normalised price that does not match it.
	return out
}

func quoteToProto(q *domain.PriceQuote) *pb.PriceQuote {
	out := &pb.PriceQuote{
		Id:              q.ID,
		Commodity:       q.Commodity,
		Variety:         q.Variety,
		MarketId:        q.MarketID,
		MarketName:      q.MarketName,
		MinPrice:        q.MinPrice,
		MaxPrice:        q.MaxPrice,
		ModalPrice:      q.ModalPrice,
		Unit:            unitToProto(q.Unit),
		Currency:        q.Currency,
		PricePerQuintal: q.PricePerQuintal,
		ArrivalsTonnes:  q.ArrivalsTonnes,
		Source:          q.Source,
	}
	if !q.QuotedOn.IsZero() {
		out.QuotedOn = timestamppb.New(q.QuotedOn)
	}
	return out
}

func statsToProto(s domain.PriceStatistics) *pb.PriceStatistics {
	return &pb.PriceStatistics{
		Commodity:        s.Commodity,
		MarketId:         s.MarketID,
		MeanPerQuintal:   s.MeanPerQuintal,
		MedianPerQuintal: s.MedianPerQuintal,
		MinPerQuintal:    s.MinPerQuintal,
		MaxPerQuintal:    s.MaxPerQuintal,
		LatestPerQuintal: s.LatestPerQuintal,
		LatestZScore:     s.LatestZScore,
		Trend:            trendToProto(s.Trend),
		TrendPerDay:      s.TrendPerDay,
		ObservationDays:  int32(s.ObservationDays),
	}
}

func signalToProto(s domain.SellSignal) *pb.SellSignal {
	out := &pb.SellSignal{
		Commodity:      s.Commodity,
		MarketId:       s.MarketID,
		Recommendation: recommendationToProto(s.Recommendation),
		Confidence:     s.Confidence,
		Rationale:      s.Rationale,
	}
	// The statistics go out only when there were any. An empty window would
	// otherwise be described by a block of zeros beneath a rationale that says
	// there is no data, which is a contradiction on one screen.
	if s.Statistics.ObservationDays > 0 {
		out.Statistics = statsToProto(s.Statistics)
	}
	if !s.GeneratedAt.IsZero() {
		out.GeneratedAt = timestamppb.New(s.GeneratedAt)
	}
	return out
}

func alertToProto(a *domain.PriceAlert) *pb.PriceAlert {
	out := &pb.PriceAlert{
		Id:                  a.ID,
		Commodity:           a.Commodity,
		MarketId:            a.MarketID,
		Direction:           alertDirectionToProto(a.Direction),
		ThresholdPerQuintal: a.ThresholdPerQuintal,
		Enabled:             a.Enabled,
		LastFiredPrice:      a.LastFiredPrice,
	}
	if !a.CreatedAt.IsZero() {
		out.CreatedAt = timestamppb.New(a.CreatedAt)
	}
	if a.LastFiredAt != nil {
		out.LastFiredAt = timestamppb.New(*a.LastFiredAt)
	}
	return out
}
