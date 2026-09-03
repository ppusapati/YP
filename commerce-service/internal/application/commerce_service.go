// Package application contains the commerce-service application service -- the
// implementation of the CommerceService primary port. It orchestrates domain
// objects and drives outbound ports (repository, event publisher). It has NO
// knowledge of ConnectRPC, HTTP, SQL, or Kafka.
package application

import (
	"context"
	"encoding/json"
	"fmt"
	"math"
	"time"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"
	"p9e.in/samavaya/packages/urlsafe"

	"p9e.in/samavaya/agriculture/commerce-service/internal/domain"
	"p9e.in/samavaya/agriculture/commerce-service/internal/ports/inbound"
	"p9e.in/samavaya/agriculture/commerce-service/internal/ports/outbound"
)

const (
	serviceName           = "commerce-service"
	eventTopic            = "samavaya.agriculture.commerce.events"
	maxPageSize     int32 = 100
	defaultPageSize       = int32(20)
)

// commerceService implements inbound.CommerceService.
type commerceService struct {
	repo outbound.CommerceRepository
	pub  outbound.EventPublisher
	log  *p9log.Helper
}

// NewCommerceService creates a new application-layer CommerceService.
func NewCommerceService(
	repo outbound.CommerceRepository,
	pub outbound.EventPublisher,
	log p9log.Logger,
) inbound.CommerceService {
	return &commerceService{
		repo: repo,
		pub:  pub,
		log:  p9log.NewHelper(p9log.With(log, "component", "CommerceService")),
	}
}

// ── Listings ─────────────────────────────────────────────────────────────────

func (s *commerceService) CreateListing(ctx context.Context, input domain.CreateListingInput) (*domain.MarketplaceListing, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	userID := p9context.UserID(ctx)

	if input.FarmID == "" {
		return nil, errors.BadRequest("MISSING_FARM_ID", "farm_id is required")
	}
	if input.ProductName == "" {
		return nil, errors.BadRequest("MISSING_PRODUCT_NAME", "product_name is required")
	}
	if input.QuantityAvailable <= 0 {
		return nil, errors.BadRequest("INVALID_QUANTITY", "quantity_available must be greater than 0")
	}
	if input.PricePerUnitPaise <= 0 {
		return nil, errors.BadRequest("INVALID_PRICE", "price_per_unit_paise must be greater than 0")
	}
	if err := urlsafe.ValidateImageURLs(input.ImageURLs); err != nil {
		return nil, errors.BadRequest("INVALID_IMAGE_URL", fmt.Sprintf("image URL rejected: %v", err))
	}

	now := time.Now()
	listing := &domain.MarketplaceListing{
		ID:                   ulid.NewString(),
		TenantID:             tenantID,
		FarmID:               input.FarmID,
		CropID:               input.CropID,
		ProductName:          input.ProductName,
		ProductType:          input.ProductType,
		Description:          input.Description,
		QuantityAvailable:    input.QuantityAvailable,
		QuantityUnit:         input.QuantityUnit,
		PricePerUnitPaise:    input.PricePerUnitPaise,
		Currency:             input.Currency,
		MinOrderQuantity:     input.MinOrderQuantity,
		QualityGrade:         input.QualityGrade,
		TraceabilityRecordID: input.TraceabilityRecordID,
		BatchID:              input.BatchID,
		Status:               domain.ListingStatusDraft,
		Location:             input.Location,
		Region:               input.Region,
		ImageURLs:            input.ImageURLs,
		AvailableFrom:        input.AvailableFrom,
		AvailableTo:          input.AvailableTo,
		Version:              1,
		CreatedBy:            userID,
		CreatedAt:            now,
		UpdatedAt:            now,
	}
	if listing.Currency == "" {
		listing.Currency = "INR"
	}
	if listing.QuantityUnit == "" {
		listing.QuantityUnit = "kg"
	}
	if listing.ImageURLs == nil {
		listing.ImageURLs = []string{}
	}

	created, err := s.repo.CreateListing(ctx, listing)
	if err != nil {
		return nil, err
	}

	s.publishEvent(ctx, "commerce.listing.created", created.ID, map[string]interface{}{
		"listing_id":   created.ID,
		"tenant_id":    created.TenantID,
		"farm_id":      created.FarmID,
		"product_name": created.ProductName,
	})

	s.log.Infow("msg", "created listing", "listing_id", created.ID, "tenant_id", tenantID)
	return created, nil
}

func (s *commerceService) GetListing(ctx context.Context, id string) (*domain.MarketplaceListing, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if id == "" {
		return nil, errors.BadRequest("MISSING_ID", "listing id is required")
	}
	return s.repo.GetListingByID(ctx, id, tenantID)
}

func (s *commerceService) ListListings(ctx context.Context, filter domain.ListListingsFilter) ([]domain.MarketplaceListing, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if filter.PageSize <= 0 {
		filter.PageSize = defaultPageSize
	}
	if filter.PageSize > maxPageSize {
		filter.PageSize = maxPageSize
	}
	return s.repo.ListListings(ctx, tenantID, filter)
}

func (s *commerceService) UpdateListing(ctx context.Context, id string, input domain.UpdateListingInput) (*domain.MarketplaceListing, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if id == "" {
		return nil, errors.BadRequest("MISSING_ID", "listing id is required")
	}
	userID := p9context.UserID(ctx)

	existing, err := s.repo.GetListingByID(ctx, id, tenantID)
	if err != nil {
		return nil, err
	}

	if existing.Status != domain.ListingStatusDraft && existing.Status != domain.ListingStatusActive {
		return nil, errors.BadRequest("INVALID_STATUS", fmt.Sprintf("listing is in %s status, only DRAFT or ACTIVE listings can be updated", existing.Status))
	}
	if input.ImageURLs != nil {
		if err := urlsafe.ValidateImageURLs(input.ImageURLs); err != nil {
			return nil, errors.BadRequest("INVALID_IMAGE_URL", fmt.Sprintf("image URL rejected: %v", err))
		}
	}

	updated, err := s.repo.UpdateListing(ctx, id, tenantID, input, userID)
	if err != nil {
		return nil, err
	}

	s.publishEvent(ctx, "commerce.listing.updated", updated.ID, map[string]interface{}{
		"listing_id": updated.ID,
		"tenant_id":  updated.TenantID,
	})

	s.log.Infow("msg", "updated listing", "listing_id", updated.ID, "tenant_id", tenantID)
	return updated, nil
}

func (s *commerceService) CancelListing(ctx context.Context, id string) (*domain.MarketplaceListing, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if id == "" {
		return nil, errors.BadRequest("MISSING_ID", "listing id is required")
	}
	userID := p9context.UserID(ctx)

	existing, err := s.repo.GetListingByID(ctx, id, tenantID)
	if err != nil {
		return nil, err
	}

	if existing.Status != domain.ListingStatusDraft && existing.Status != domain.ListingStatusActive {
		return nil, errors.BadRequest("INVALID_STATUS", fmt.Sprintf("listing is in %s status, only DRAFT or ACTIVE listings can be cancelled", existing.Status))
	}

	cancelled, err := s.repo.CancelListing(ctx, id, tenantID, userID)
	if err != nil {
		return nil, err
	}

	s.publishEvent(ctx, "commerce.listing.cancelled", cancelled.ID, map[string]interface{}{
		"listing_id": cancelled.ID,
		"tenant_id":  cancelled.TenantID,
	})

	s.log.Infow("msg", "cancelled listing", "listing_id", cancelled.ID, "tenant_id", tenantID)
	return cancelled, nil
}

// ── Orders ───────────────────────────────────────────────────────────────────

func (s *commerceService) PlaceOrder(ctx context.Context, input domain.PlaceOrderInput) (*domain.Order, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	userID := p9context.UserID(ctx)

	if input.ListingID == "" {
		return nil, errors.BadRequest("MISSING_LISTING_ID", "listing_id is required")
	}
	if input.Quantity <= 0 {
		return nil, errors.BadRequest("INVALID_QUANTITY", "quantity must be greater than 0")
	}

	listing, err := s.repo.GetListingByID(ctx, input.ListingID, tenantID)
	if err != nil {
		return nil, err
	}

	if listing.Status != domain.ListingStatusActive {
		return nil, errors.BadRequest("LISTING_NOT_ACTIVE", fmt.Sprintf("listing is in %s status, only ACTIVE listings accept orders", listing.Status))
	}

	if input.Quantity > listing.QuantityAvailable {
		return nil, errors.BadRequest("INSUFFICIENT_QUANTITY", fmt.Sprintf("requested quantity %.2f exceeds available %.2f", input.Quantity, listing.QuantityAvailable))
	}

	totalAmount := int64(math.Round(float64(listing.PricePerUnitPaise) * input.Quantity))

	now := time.Now()
	order := &domain.Order{
		ID:               ulid.NewString(),
		TenantID:         tenantID,
		ListingID:        input.ListingID,
		BuyerID:          userID,
		SellerID:         listing.CreatedBy,
		Quantity:         input.Quantity,
		QuantityUnit:     listing.QuantityUnit,
		UnitPricePaise:   listing.PricePerUnitPaise,
		TotalAmountPaise: totalAmount,
		Currency:         listing.Currency,
		Status:           domain.OrderStatusPending,
		PaymentStatus:    domain.PaymentStatusPending,
		DeliveryMethod:   input.DeliveryMethod,
		DeliveryAddress:  input.DeliveryAddress,
		DeliveryNotes:    input.DeliveryNotes,
		Notes:            input.Notes,
		Metadata:         json.RawMessage("{}"),
		Version:          1,
		CreatedBy:        userID,
		CreatedAt:        now,
		UpdatedAt:        now,
	}

	created, err := s.repo.CreateOrder(ctx, order)
	if err != nil {
		return nil, err
	}

	s.publishEvent(ctx, "commerce.order.placed", created.ID, map[string]interface{}{
		"order_id":     created.ID,
		"listing_id":   created.ListingID,
		"buyer_id":     created.BuyerID,
		"seller_id":    created.SellerID,
		"quantity":     created.Quantity,
		"total_amount": created.TotalAmountPaise,
	})

	s.log.Infow("msg", "placed order", "order_id", created.ID, "listing_id", input.ListingID, "tenant_id", tenantID)
	return created, nil
}

func (s *commerceService) GetOrder(ctx context.Context, id string) (*domain.Order, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if id == "" {
		return nil, errors.BadRequest("MISSING_ID", "order id is required")
	}
	return s.repo.GetOrderByID(ctx, id, tenantID)
}

func (s *commerceService) ListOrders(ctx context.Context, filter domain.ListOrdersFilter) ([]domain.Order, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if filter.PageSize <= 0 {
		filter.PageSize = defaultPageSize
	}
	if filter.PageSize > maxPageSize {
		filter.PageSize = maxPageSize
	}
	return s.repo.ListOrders(ctx, tenantID, filter)
}

func (s *commerceService) UpdateOrderStatus(ctx context.Context, id string, status domain.OrderStatus, notes string) (*domain.Order, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if id == "" {
		return nil, errors.BadRequest("MISSING_ID", "order id is required")
	}
	userID := p9context.UserID(ctx)

	existing, err := s.repo.GetOrderByID(ctx, id, tenantID)
	if err != nil {
		return nil, err
	}

	allowed, ok := domain.ValidOrderTransitions[existing.Status]
	if !ok {
		return nil, errors.BadRequest("INVALID_TRANSITION", fmt.Sprintf("order in %s status cannot be transitioned", existing.Status))
	}
	valid := false
	for _, s := range allowed {
		if s == status {
			valid = true
			break
		}
	}
	if !valid {
		return nil, errors.BadRequest("INVALID_TRANSITION", fmt.Sprintf("cannot transition from %s to %s", existing.Status, status))
	}

	updated, err := s.repo.UpdateOrderStatus(ctx, id, tenantID, status, notes, userID)
	if err != nil {
		return nil, err
	}

	s.publishEvent(ctx, "commerce.order.status_updated", updated.ID, map[string]interface{}{
		"order_id":   updated.ID,
		"old_status": string(existing.Status),
		"new_status": string(updated.Status),
	})

	s.log.Infow("msg", "updated order status", "order_id", updated.ID, "new_status", status, "tenant_id", tenantID)
	return updated, nil
}

func (s *commerceService) UpdatePaymentStatus(ctx context.Context, id string, status domain.PaymentStatus, reference string) (*domain.Order, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if id == "" {
		return nil, errors.BadRequest("MISSING_ID", "order id is required")
	}
	userID := p9context.UserID(ctx)

	updated, err := s.repo.UpdatePaymentStatus(ctx, id, tenantID, status, reference, userID)
	if err != nil {
		return nil, err
	}

	s.publishEvent(ctx, "commerce.order.payment_updated", updated.ID, map[string]interface{}{
		"order_id":       updated.ID,
		"payment_status": string(updated.PaymentStatus),
		"reference":      reference,
	})

	s.log.Infow("msg", "updated payment status", "order_id", updated.ID, "payment_status", status, "tenant_id", tenantID)
	return updated, nil
}

// ── Helpers ──────────────────────────────────────────────────────────────────

func (s *commerceService) publishEvent(ctx context.Context, eventType, aggregateID string, data map[string]interface{}) {
	if s.pub == nil {
		return
	}
	payload := map[string]interface{}{
		"id":             ulid.NewString(),
		"type":           eventType,
		"aggregate_id":   aggregateID,
		"source":         serviceName,
		"correlation_id": p9context.RequestID(ctx),
		"tenant_id":      p9context.TenantID(ctx),
		"data":           data,
	}
	raw, err := json.Marshal(payload)
	if err != nil {
		s.log.Errorw("msg", "failed to marshal event", "error", err)
		return
	}
	if err := s.pub.Publish(ctx, eventTopic, aggregateID, raw); err != nil {
		s.log.Errorw("msg", "failed to publish event", "event_type", eventType, "error", err)
	}
}
