// Package grpc contains the inbound ConnectRPC adapter for the commerce-service.
package grpc

import (
	"context"
	"encoding/json"
	"time"

	"connectrpc.com/connect"
	"google.golang.org/protobuf/types/known/timestamppb"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"

	pb "p9e.in/samavaya/agriculture/commerce-service/api/v1"
	"p9e.in/samavaya/agriculture/commerce-service/api/v1/commercev1connect"
	"p9e.in/samavaya/agriculture/commerce-service/internal/domain"
	"p9e.in/samavaya/agriculture/commerce-service/internal/ports/inbound"
)

// CommerceHandler is the ConnectRPC inbound adapter.
type CommerceHandler struct {
	commercev1connect.UnimplementedCommerceServiceHandler
	svc inbound.CommerceService
	log *p9log.Helper
}

// NewCommerceHandler creates a new ConnectRPC commerce handler.
func NewCommerceHandler(svc inbound.CommerceService, log p9log.Logger) *CommerceHandler {
	return &CommerceHandler{
		svc: svc,
		log: p9log.NewHelper(p9log.With(log, "component", "CommerceHandler")),
	}
}

// ── Listings ─────────────────────────────────────────────────────────────────

func (h *CommerceHandler) CreateListing(ctx context.Context, req *connect.Request[pb.CreateListingRequest]) (*connect.Response[pb.CreateListingResponse], error) {
	input := domain.CreateListingInput{
		FarmID:            req.Msg.GetFarmId(),
		CropID:            req.Msg.GetCropId(),
		ProductName:       req.Msg.GetProductName(),
		ProductType:       req.Msg.GetProductType(),
		Description:       strPtr(req.Msg.GetDescription()),
		QuantityAvailable: req.Msg.GetQuantityAvailable(),
		QuantityUnit:      req.Msg.GetQuantityUnit(),
		PricePerUnitPaise: req.Msg.GetPricePerUnitPaise(),
		Currency:          req.Msg.GetCurrency(),
		MinOrderQuantity:  float64Ptr(req.Msg.GetMinOrderQuantity()),
		QualityGrade:      strPtr(req.Msg.GetQualityGrade()),
		TraceabilityRecordID: strPtr(req.Msg.GetTraceabilityRecordId()),
		BatchID:           strPtr(req.Msg.GetBatchId()),
		Location:          strPtr(req.Msg.GetLocation()),
		Region:            strPtr(req.Msg.GetRegion()),
		ImageURLs:         req.Msg.GetImageUrls(),
		AvailableFrom:     tsToTimePtr(req.Msg.GetAvailableFrom()),
		AvailableTo:       tsToTimePtr(req.Msg.GetAvailableTo()),
	}
	listing, err := h.svc.CreateListing(ctx, input)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.CreateListingResponse{Listing: listingToProto(listing)}), nil
}

func (h *CommerceHandler) GetListing(ctx context.Context, req *connect.Request[pb.GetListingRequest]) (*connect.Response[pb.GetListingResponse], error) {
	listing, err := h.svc.GetListing(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.GetListingResponse{Listing: listingToProto(listing)}), nil
}

func (h *CommerceHandler) ListListings(ctx context.Context, req *connect.Request[pb.ListListingsRequest]) (*connect.Response[pb.ListListingsResponse], error) {
	filter := domain.ListListingsFilter{
		FarmID:      req.Msg.GetFarmId(),
		CropID:      req.Msg.GetCropId(),
		ProductType: req.Msg.GetProductType(),
		Region:      req.Msg.GetRegion(),
		Search:      req.Msg.GetSearch(),
		PageSize:    req.Msg.GetPageSize(),
		PageOffset:  req.Msg.GetPageOffset(),
	}
	if req.Msg.GetStatus() != pb.ListingStatus_LISTING_STATUS_UNSPECIFIED {
		filter.Status = listingStatusProtoToDomainString(req.Msg.GetStatus())
	}

	listings, total, err := h.svc.ListListings(ctx, filter)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	protos := make([]*pb.MarketplaceListing, 0, len(listings))
	for i := range listings {
		protos = append(protos, listingToProto(&listings[i]))
	}
	return connect.NewResponse(&pb.ListListingsResponse{
		Listings:   protos,
		TotalCount: total,
	}), nil
}

func (h *CommerceHandler) UpdateListing(ctx context.Context, req *connect.Request[pb.UpdateListingRequest]) (*connect.Response[pb.UpdateListingResponse], error) {
	var input domain.UpdateListingInput
	if v := req.Msg.GetProductName(); v != "" {
		input.ProductName = &v
	}
	if v := req.Msg.GetDescription(); v != "" {
		input.Description = &v
	}
	if v := req.Msg.GetQuantityAvailable(); v != 0 {
		input.QuantityAvailable = &v
	}
	if v := req.Msg.GetPricePerUnitPaise(); v != 0 {
		input.PricePerUnitPaise = &v
	}
	if v := req.Msg.GetMinOrderQuantity(); v != 0 {
		input.MinOrderQuantity = &v
	}
	if v := req.Msg.GetQualityGrade(); v != "" {
		input.QualityGrade = &v
	}
	if v := req.Msg.GetImageUrls(); len(v) > 0 {
		input.ImageURLs = v
	}
	input.AvailableTo = tsToTimePtr(req.Msg.GetAvailableTo())

	listing, err := h.svc.UpdateListing(ctx, req.Msg.GetId(), input)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.UpdateListingResponse{Listing: listingToProto(listing)}), nil
}

func (h *CommerceHandler) ActivateListing(ctx context.Context, req *connect.Request[pb.ActivateListingRequest]) (*connect.Response[pb.ActivateListingResponse], error) {
	listing, err := h.svc.ActivateListing(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.ActivateListingResponse{Listing: listingToProto(listing)}), nil
}

func (h *CommerceHandler) CancelListing(ctx context.Context, req *connect.Request[pb.CancelListingRequest]) (*connect.Response[pb.CancelListingResponse], error) {
	listing, err := h.svc.CancelListing(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.CancelListingResponse{Listing: listingToProto(listing)}), nil
}

// ── Orders ───────────────────────────────────────────────────────────────────

func (h *CommerceHandler) PlaceOrder(ctx context.Context, req *connect.Request[pb.PlaceOrderRequest]) (*connect.Response[pb.PlaceOrderResponse], error) {
	input := domain.PlaceOrderInput{
		ListingID:       req.Msg.GetListingId(),
		Quantity:        req.Msg.GetQuantity(),
		DeliveryMethod:  strPtr(req.Msg.GetDeliveryMethod()),
		DeliveryAddress: strPtr(req.Msg.GetDeliveryAddress()),
		DeliveryNotes:   strPtr(req.Msg.GetDeliveryNotes()),
		Notes:           strPtr(req.Msg.GetNotes()),
	}
	order, err := h.svc.PlaceOrder(ctx, input)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.PlaceOrderResponse{Order: orderToProto(order)}), nil
}

func (h *CommerceHandler) GetOrder(ctx context.Context, req *connect.Request[pb.GetOrderRequest]) (*connect.Response[pb.GetOrderResponse], error) {
	order, err := h.svc.GetOrder(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.GetOrderResponse{Order: orderToProto(order)}), nil
}

func (h *CommerceHandler) ListOrders(ctx context.Context, req *connect.Request[pb.ListOrdersRequest]) (*connect.Response[pb.ListOrdersResponse], error) {
	filter := domain.ListOrdersFilter{
		ListingID:  req.Msg.GetListingId(),
		BuyerID:    req.Msg.GetBuyerId(),
		SellerID:   req.Msg.GetSellerId(),
		PageSize:   req.Msg.GetPageSize(),
		PageOffset: req.Msg.GetPageOffset(),
	}
	if req.Msg.GetStatus() != pb.OrderStatus_ORDER_STATUS_UNSPECIFIED {
		filter.Status = orderStatusProtoToDomainString(req.Msg.GetStatus())
	}

	orders, total, err := h.svc.ListOrders(ctx, filter)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	protos := make([]*pb.Order, 0, len(orders))
	for i := range orders {
		protos = append(protos, orderToProto(&orders[i]))
	}
	return connect.NewResponse(&pb.ListOrdersResponse{
		Orders:     protos,
		TotalCount: total,
	}), nil
}

func (h *CommerceHandler) UpdateOrderStatus(ctx context.Context, req *connect.Request[pb.UpdateOrderStatusRequest]) (*connect.Response[pb.UpdateOrderStatusResponse], error) {
	status := orderStatusProtoToDomain(req.Msg.GetStatus())
	order, err := h.svc.UpdateOrderStatus(ctx, req.Msg.GetId(), status, req.Msg.GetNotes())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.UpdateOrderStatusResponse{Order: orderToProto(order)}), nil
}

func (h *CommerceHandler) UpdatePaymentStatus(ctx context.Context, req *connect.Request[pb.UpdatePaymentStatusRequest]) (*connect.Response[pb.UpdatePaymentStatusResponse], error) {
	status := paymentStatusProtoToDomain(req.Msg.GetPaymentStatus())
	order, err := h.svc.UpdatePaymentStatus(ctx, req.Msg.GetId(), status, req.Msg.GetPaymentReference())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.UpdatePaymentStatusResponse{Order: orderToProto(order)}), nil
}

// ===================================================================
// Proto-to-Domain and Domain-to-Proto conversion helpers
// ===================================================================

// --- Timestamp helpers ---

func tsToTimePtr(ts *timestamppb.Timestamp) *time.Time {
	if ts == nil {
		return nil
	}
	t := ts.AsTime()
	return &t
}

func timePtrToTs(t *time.Time) *timestamppb.Timestamp {
	if t == nil {
		return nil
	}
	return timestamppb.New(*t)
}

func timeToTs(t time.Time) *timestamppb.Timestamp {
	return timestamppb.New(t)
}

// --- Optional-field helpers ---

func strPtr(s string) *string {
	if s == "" {
		return nil
	}
	return &s
}

func float64Ptr(v float64) *float64 {
	if v == 0 {
		return nil
	}
	return &v
}

func derefStr(s *string) string {
	if s == nil {
		return ""
	}
	return *s
}

// --- Listing conversion ---

func listingToProto(l *domain.MarketplaceListing) *pb.MarketplaceListing {
	if l == nil {
		return nil
	}
	proto := &pb.MarketplaceListing{
		Id:                   l.ID,
		TenantId:             l.TenantID,
		FarmId:               l.FarmID,
		CropId:               l.CropID,
		ProductName:          l.ProductName,
		ProductType:          l.ProductType,
		Description:          derefStr(l.Description),
		QuantityAvailable:    l.QuantityAvailable,
		QuantityUnit:         l.QuantityUnit,
		PricePerUnitPaise:    l.PricePerUnitPaise,
		Currency:             l.Currency,
		MinOrderQuantity:     derefFloat64(l.MinOrderQuantity),
		QualityGrade:         derefStr(l.QualityGrade),
		TraceabilityRecordId: derefStr(l.TraceabilityRecordID),
		BatchId:              derefStr(l.BatchID),
		Status:               listingStatusDomainToProto(l.Status),
		Location:             derefStr(l.Location),
		Region:               derefStr(l.Region),
		ImageUrls:            l.ImageURLs,
		AvailableFrom:        timePtrToTs(l.AvailableFrom),
		AvailableTo:          timePtrToTs(l.AvailableTo),
		CreatedBy:            l.CreatedBy,
		Version:              l.Version,
		CreatedAt:            timeToTs(l.CreatedAt),
		UpdatedAt:            timeToTs(l.UpdatedAt),
	}
	return proto
}

func derefFloat64(v *float64) float64 {
	if v == nil {
		return 0
	}
	return *v
}

// --- Order conversion ---

func orderToProto(o *domain.Order) *pb.Order {
	if o == nil {
		return nil
	}
	proto := &pb.Order{
		Id:                    o.ID,
		TenantId:              o.TenantID,
		ListingId:             o.ListingID,
		BuyerId:               o.BuyerID,
		SellerId:              o.SellerID,
		Quantity:              o.Quantity,
		QuantityUnit:          o.QuantityUnit,
		UnitPricePaise:        o.UnitPricePaise,
		TotalAmountPaise:      o.TotalAmountPaise,
		Currency:              o.Currency,
		Status:                orderStatusDomainToProto(o.Status),
		PaymentStatus:         paymentStatusDomainToProto(o.PaymentStatus),
		PaymentReference:      derefStr(o.PaymentReference),
		DeliveryMethod:        derefStr(o.DeliveryMethod),
		DeliveryAddress:       derefStr(o.DeliveryAddress),
		DeliveryNotes:         derefStr(o.DeliveryNotes),
		EstimatedDeliveryDate: timePtrToTs(o.EstimatedDeliveryDate),
		ActualDeliveryDate:    timePtrToTs(o.ActualDeliveryDate),
		Notes:                 derefStr(o.Notes),
		CreatedBy:             o.CreatedBy,
		Version:               o.Version,
		CreatedAt:             timeToTs(o.CreatedAt),
		UpdatedAt:             timeToTs(o.UpdatedAt),
	}
	return proto
}

// --- Enum conversion: Listing Status ---

var listingStatusToProto = map[domain.ListingStatus]pb.ListingStatus{
	domain.ListingStatusDraft:     pb.ListingStatus_LISTING_STATUS_DRAFT,
	domain.ListingStatusActive:    pb.ListingStatus_LISTING_STATUS_ACTIVE,
	domain.ListingStatusSoldOut:   pb.ListingStatus_LISTING_STATUS_SOLD_OUT,
	domain.ListingStatusExpired:   pb.ListingStatus_LISTING_STATUS_EXPIRED,
	domain.ListingStatusCancelled: pb.ListingStatus_LISTING_STATUS_CANCELLED,
}

func listingStatusDomainToProto(s domain.ListingStatus) pb.ListingStatus {
	if v, ok := listingStatusToProto[s]; ok {
		return v
	}
	return pb.ListingStatus_LISTING_STATUS_UNSPECIFIED
}

func listingStatusProtoToDomainString(s pb.ListingStatus) string {
	switch s {
	case pb.ListingStatus_LISTING_STATUS_DRAFT:
		return string(domain.ListingStatusDraft)
	case pb.ListingStatus_LISTING_STATUS_ACTIVE:
		return string(domain.ListingStatusActive)
	case pb.ListingStatus_LISTING_STATUS_SOLD_OUT:
		return string(domain.ListingStatusSoldOut)
	case pb.ListingStatus_LISTING_STATUS_EXPIRED:
		return string(domain.ListingStatusExpired)
	case pb.ListingStatus_LISTING_STATUS_CANCELLED:
		return string(domain.ListingStatusCancelled)
	default:
		return ""
	}
}

// --- Enum conversion: Order Status ---

var orderStatusToProto = map[domain.OrderStatus]pb.OrderStatus{
	domain.OrderStatusPending:    pb.OrderStatus_ORDER_STATUS_PENDING,
	domain.OrderStatusConfirmed:  pb.OrderStatus_ORDER_STATUS_CONFIRMED,
	domain.OrderStatusProcessing: pb.OrderStatus_ORDER_STATUS_PROCESSING,
	domain.OrderStatusShipped:    pb.OrderStatus_ORDER_STATUS_SHIPPED,
	domain.OrderStatusDelivered:  pb.OrderStatus_ORDER_STATUS_DELIVERED,
	domain.OrderStatusCompleted:  pb.OrderStatus_ORDER_STATUS_COMPLETED,
	domain.OrderStatusCancelled:  pb.OrderStatus_ORDER_STATUS_CANCELLED,
	domain.OrderStatusDisputed:   pb.OrderStatus_ORDER_STATUS_DISPUTED,
}

var orderStatusToDomain = map[pb.OrderStatus]domain.OrderStatus{
	pb.OrderStatus_ORDER_STATUS_PENDING:    domain.OrderStatusPending,
	pb.OrderStatus_ORDER_STATUS_CONFIRMED:  domain.OrderStatusConfirmed,
	pb.OrderStatus_ORDER_STATUS_PROCESSING: domain.OrderStatusProcessing,
	pb.OrderStatus_ORDER_STATUS_SHIPPED:    domain.OrderStatusShipped,
	pb.OrderStatus_ORDER_STATUS_DELIVERED:  domain.OrderStatusDelivered,
	pb.OrderStatus_ORDER_STATUS_COMPLETED:  domain.OrderStatusCompleted,
	pb.OrderStatus_ORDER_STATUS_CANCELLED:  domain.OrderStatusCancelled,
	pb.OrderStatus_ORDER_STATUS_DISPUTED:   domain.OrderStatusDisputed,
}

func orderStatusDomainToProto(s domain.OrderStatus) pb.OrderStatus {
	if v, ok := orderStatusToProto[s]; ok {
		return v
	}
	return pb.OrderStatus_ORDER_STATUS_UNSPECIFIED
}

func orderStatusProtoToDomain(s pb.OrderStatus) domain.OrderStatus {
	if v, ok := orderStatusToDomain[s]; ok {
		return v
	}
	return ""
}

func orderStatusProtoToDomainString(s pb.OrderStatus) string {
	return string(orderStatusProtoToDomain(s))
}

// --- Enum conversion: Payment Status ---

var paymentStatusToProto = map[domain.PaymentStatus]pb.PaymentStatus{
	domain.PaymentStatusPending:  pb.PaymentStatus_PAYMENT_STATUS_PENDING,
	domain.PaymentStatusPaid:     pb.PaymentStatus_PAYMENT_STATUS_PAID,
	domain.PaymentStatusRefunded: pb.PaymentStatus_PAYMENT_STATUS_REFUNDED,
}

var paymentStatusToDomain = map[pb.PaymentStatus]domain.PaymentStatus{
	pb.PaymentStatus_PAYMENT_STATUS_PENDING:  domain.PaymentStatusPending,
	pb.PaymentStatus_PAYMENT_STATUS_PAID:     domain.PaymentStatusPaid,
	pb.PaymentStatus_PAYMENT_STATUS_REFUNDED: domain.PaymentStatusRefunded,
}

func paymentStatusDomainToProto(s domain.PaymentStatus) pb.PaymentStatus {
	if v, ok := paymentStatusToProto[s]; ok {
		return v
	}
	return pb.PaymentStatus_PAYMENT_STATUS_UNSPECIFIED
}

func paymentStatusProtoToDomain(s pb.PaymentStatus) domain.PaymentStatus {
	if v, ok := paymentStatusToDomain[s]; ok {
		return v
	}
	return ""
}

// --- Metadata conversion ---

func metadataJSONToMap(raw json.RawMessage) map[string]string {
	if len(raw) == 0 || string(raw) == "{}" || string(raw) == "null" {
		return nil
	}
	m := make(map[string]string)
	if err := json.Unmarshal(raw, &m); err != nil {
		return nil
	}
	return m
}
