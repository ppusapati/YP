// Package grpc adapts the ConnectRPC surface onto market-service's use cases.
package grpc

import (
	"context"

	"connectrpc.com/connect"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"

	pb "p9e.in/samavaya/agriculture/market-service/api/v1"
	"p9e.in/samavaya/agriculture/market-service/internal/domain"
	"p9e.in/samavaya/agriculture/market-service/internal/ports/inbound"
)

// MarketHandler serves the MarketService RPCs.
type MarketHandler struct {
	svc inbound.MarketService
	log *p9log.Helper
}

// NewMarketHandler creates a MarketHandler.
func NewMarketHandler(svc inbound.MarketService, log p9log.Logger) *MarketHandler {
	return &MarketHandler{
		svc: svc,
		log: p9log.NewHelper(p9log.With(log, "component", "MarketHandler")),
	}
}

func (h *MarketHandler) ListMarkets(ctx context.Context, req *connect.Request[pb.ListMarketsRequest]) (*connect.Response[pb.ListMarketsResponse], error) {
	limit, offset := page(req.Msg.GetPageSize(), req.Msg.GetPageToken())

	markets, total, err := h.svc.ListMarkets(ctx, domain.ListMarketsParams{
		State:    req.Msg.GetState(),
		District: req.Msg.GetDistrict(),
		Kind:     marketKindFromProto(req.Msg.GetKind()),
		Limit:    limit,
		Offset:   offset,
	})
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	out := make([]*pb.Market, 0, len(markets))
	for i := range markets {
		out = append(out, marketToProto(&markets[i]))
	}

	return connect.NewResponse(&pb.ListMarketsResponse{
		Markets:       out,
		NextPageToken: nextToken(offset, limit, total),
		TotalCount:    int32(total),
	}), nil
}

func (h *MarketHandler) RecordQuotes(ctx context.Context, req *connect.Request[pb.RecordQuotesRequest]) (*connect.Response[pb.RecordQuotesResponse], error) {
	quotes := make([]domain.PriceQuote, 0, len(req.Msg.GetQuotes()))
	for _, q := range req.Msg.GetQuotes() {
		quotes = append(quotes, quoteFromProto(q))
	}

	result, err := h.svc.RecordQuotes(ctx, quotes)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return connect.NewResponse(&pb.RecordQuotesResponse{
		Recorded: int32(result.Recorded),
		Rejected: result.Rejected,
	}), nil
}

func (h *MarketHandler) ListQuotes(ctx context.Context, req *connect.Request[pb.ListQuotesRequest]) (*connect.Response[pb.ListQuotesResponse], error) {
	limit, offset := page(req.Msg.GetPageSize(), req.Msg.GetPageToken())

	params := domain.ListQuotesParams{
		Commodity: req.Msg.GetCommodity(),
		MarketID:  req.Msg.GetMarketId(),
		Limit:     limit,
		Offset:    offset,
	}
	if ts := req.Msg.GetFrom(); ts != nil {
		params.From = ts.AsTime()
	}
	if ts := req.Msg.GetTo(); ts != nil {
		params.To = ts.AsTime()
	}

	quotes, total, err := h.svc.ListQuotes(ctx, params)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	out := make([]*pb.PriceQuote, 0, len(quotes))
	for i := range quotes {
		out = append(out, quoteToProto(&quotes[i]))
	}

	return connect.NewResponse(&pb.ListQuotesResponse{
		Quotes:        out,
		NextPageToken: nextToken(offset, limit, total),
		TotalCount:    int32(total),
	}), nil
}

func (h *MarketHandler) GetPriceStatistics(ctx context.Context, req *connect.Request[pb.GetPriceStatisticsRequest]) (*connect.Response[pb.GetPriceStatisticsResponse], error) {
	stats, ok, err := h.svc.GetPriceStatistics(ctx, req.Msg.GetCommodity(), req.Msg.GetMarketId(), int(req.Msg.GetDays()))
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	if !ok {
		// Nil rather than a zeroed message: a struct of zeros renders as "the
		// price is ₹0" and reads as data rather than as an absence of it.
		return connect.NewResponse(&pb.GetPriceStatisticsResponse{}), nil
	}
	return connect.NewResponse(&pb.GetPriceStatisticsResponse{
		Statistics: statsToProto(stats),
	}), nil
}

func (h *MarketHandler) GetSellSignal(ctx context.Context, req *connect.Request[pb.GetSellSignalRequest]) (*connect.Response[pb.GetSellSignalResponse], error) {
	signal, err := h.svc.GetSellSignal(ctx, req.Msg.GetCommodity(), req.Msg.GetMarketId(), int(req.Msg.GetDays()))
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.GetSellSignalResponse{
		Signal: signalToProto(signal),
	}), nil
}

func (h *MarketHandler) CreatePriceAlert(ctx context.Context, req *connect.Request[pb.CreatePriceAlertRequest]) (*connect.Response[pb.CreatePriceAlertResponse], error) {
	alert := &domain.PriceAlert{
		Commodity:           req.Msg.GetCommodity(),
		MarketID:            req.Msg.GetMarketId(),
		Direction:           alertDirectionFromProto(req.Msg.GetDirection()),
		ThresholdPerQuintal: req.Msg.GetThresholdPerQuintal(),
	}

	created, err := h.svc.CreatePriceAlert(ctx, alert)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.CreatePriceAlertResponse{
		Alert: alertToProto(created),
	}), nil
}

func (h *MarketHandler) ListPriceAlerts(ctx context.Context, req *connect.Request[pb.ListPriceAlertsRequest]) (*connect.Response[pb.ListPriceAlertsResponse], error) {
	limit, offset := page(req.Msg.GetPageSize(), req.Msg.GetPageToken())

	alerts, total, err := h.svc.ListPriceAlerts(ctx, domain.ListAlertsParams{
		Commodity: req.Msg.GetCommodity(),
		Limit:     limit,
		Offset:    offset,
	})
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	out := make([]*pb.PriceAlert, 0, len(alerts))
	for i := range alerts {
		out = append(out, alertToProto(&alerts[i]))
	}

	return connect.NewResponse(&pb.ListPriceAlertsResponse{
		Alerts:        out,
		NextPageToken: nextToken(offset, limit, total),
		TotalCount:    int32(total),
	}), nil
}

func (h *MarketHandler) DeletePriceAlert(ctx context.Context, req *connect.Request[pb.DeletePriceAlertRequest]) (*connect.Response[pb.DeletePriceAlertResponse], error) {
	deleted, err := h.svc.DeletePriceAlert(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.DeletePriceAlertResponse{Deleted: deleted}), nil
}
