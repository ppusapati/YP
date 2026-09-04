package application

import (
	"context"
	"encoding/json"
	"fmt"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/saas"

	"p9e.in/samavaya/agriculture/commerce-service/internal/domain"
)

// ---------------------------------------------------------------------------
// No-op logger satisfying p9log.Logger
// ---------------------------------------------------------------------------

type nopLogger struct{}

func (nopLogger) Log(_ p9log.Level, _ ...interface{}) error { return nil }

// ---------------------------------------------------------------------------
// Mock: EventPublisher
// ---------------------------------------------------------------------------

type mockEventPublisher struct {
	published []publishedEvent
}

type publishedEvent struct {
	topic, key string
	payload    []byte
}

func (m *mockEventPublisher) Publish(_ context.Context, topic, key string, payload []byte) error {
	m.published = append(m.published, publishedEvent{topic, key, payload})
	return nil
}

// ---------------------------------------------------------------------------
// Mock: CommerceRepository
// ---------------------------------------------------------------------------

type mockCommerceRepo struct {
	listings map[string]*domain.MarketplaceListing
	orders   map[string]*domain.Order
}

func newMockCommerceRepo() *mockCommerceRepo {
	return &mockCommerceRepo{
		listings: make(map[string]*domain.MarketplaceListing),
		orders:   make(map[string]*domain.Order),
	}
}

// --- Listings ---

func (m *mockCommerceRepo) CreateListing(_ context.Context, l *domain.MarketplaceListing) (*domain.MarketplaceListing, error) {
	m.listings[l.ID] = l
	return l, nil
}

func (m *mockCommerceRepo) GetListingByID(_ context.Context, id, tenantID string) (*domain.MarketplaceListing, error) {
	l, ok := m.listings[id]
	if !ok || l.TenantID != tenantID {
		return nil, errors.NotFound("LISTING_NOT_FOUND", fmt.Sprintf("listing not found: %s", id))
	}
	return l, nil
}

func (m *mockCommerceRepo) ListListings(_ context.Context, tenantID string, _ domain.ListListingsFilter) ([]domain.MarketplaceListing, int32, error) {
	var result []domain.MarketplaceListing
	for _, l := range m.listings {
		if l.TenantID == tenantID {
			result = append(result, *l)
		}
	}
	return result, int32(len(result)), nil
}

func (m *mockCommerceRepo) UpdateListing(_ context.Context, id, tenantID string, input domain.UpdateListingInput, updatedBy string) (*domain.MarketplaceListing, error) {
	l, ok := m.listings[id]
	if !ok || l.TenantID != tenantID {
		return nil, errors.NotFound("LISTING_NOT_FOUND", "listing not found")
	}
	if input.ProductName != nil {
		l.ProductName = *input.ProductName
	}
	l.UpdatedBy = &updatedBy
	return l, nil
}

func (m *mockCommerceRepo) ActivateListing(_ context.Context, id, tenantID, updatedBy string) (*domain.MarketplaceListing, error) {
	l, ok := m.listings[id]
	if !ok || l.TenantID != tenantID {
		return nil, errors.NotFound("LISTING_NOT_FOUND", "listing not found")
	}
	l.Status = domain.ListingStatusActive
	l.UpdatedBy = &updatedBy
	return l, nil
}

func (m *mockCommerceRepo) DecrementListingQuantity(_ context.Context, id, tenantID string, quantity float64) error {
	l, ok := m.listings[id]
	if !ok || l.TenantID != tenantID {
		return errors.NotFound("LISTING_NOT_FOUND", "listing not found")
	}
	if l.QuantityAvailable < quantity {
		return errors.BadRequest("INSUFFICIENT_QUANTITY", "insufficient quantity available")
	}
	l.QuantityAvailable -= quantity
	if l.QuantityAvailable <= 0 {
		l.Status = domain.ListingStatusSoldOut
	}
	return nil
}

func (m *mockCommerceRepo) CancelListing(_ context.Context, id, tenantID, updatedBy string) (*domain.MarketplaceListing, error) {
	l, ok := m.listings[id]
	if !ok || l.TenantID != tenantID {
		return nil, errors.NotFound("LISTING_NOT_FOUND", "listing not found")
	}
	l.Status = domain.ListingStatusCancelled
	l.UpdatedBy = &updatedBy
	return l, nil
}

// --- Orders ---

func (m *mockCommerceRepo) CreateOrder(_ context.Context, o *domain.Order) (*domain.Order, error) {
	m.orders[o.ID] = o
	return o, nil
}

func (m *mockCommerceRepo) GetOrderByID(_ context.Context, id, tenantID string) (*domain.Order, error) {
	o, ok := m.orders[id]
	if !ok || o.TenantID != tenantID {
		return nil, errors.NotFound("ORDER_NOT_FOUND", fmt.Sprintf("order not found: %s", id))
	}
	return o, nil
}

func (m *mockCommerceRepo) ListOrders(_ context.Context, tenantID string, _ domain.ListOrdersFilter) ([]domain.Order, int32, error) {
	var result []domain.Order
	for _, o := range m.orders {
		if o.TenantID == tenantID {
			result = append(result, *o)
		}
	}
	return result, int32(len(result)), nil
}

func (m *mockCommerceRepo) UpdateOrderStatus(_ context.Context, id, tenantID string, status domain.OrderStatus, _ string, updatedBy string) (*domain.Order, error) {
	o, ok := m.orders[id]
	if !ok || o.TenantID != tenantID {
		return nil, errors.NotFound("ORDER_NOT_FOUND", "order not found")
	}
	o.Status = status
	o.UpdatedBy = &updatedBy
	return o, nil
}

func (m *mockCommerceRepo) UpdatePaymentStatus(_ context.Context, id, tenantID string, status domain.PaymentStatus, reference string, updatedBy string) (*domain.Order, error) {
	o, ok := m.orders[id]
	if !ok || o.TenantID != tenantID {
		return nil, errors.NotFound("ORDER_NOT_FOUND", "order not found")
	}
	o.PaymentStatus = status
	o.PaymentReference = &reference
	o.UpdatedBy = &updatedBy
	return o, nil
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

func testContext(tenantID, userID string) context.Context {
	ctx := context.Background()
	ctx = p9context.NewConnectionInfo(ctx, &saas.ConnectionInfo{TenantID: tenantID})
	if userID != "" {
		ctx = p9context.NewUserContext(ctx, p9context.UserContext{UserID: userID})
	}
	return ctx
}

func newService() (*mockCommerceRepo, *mockEventPublisher, *commerceService) {
	repo := newMockCommerceRepo()
	pub := &mockEventPublisher{}
	svc := NewCommerceService(repo, pub, nopLogger{}).(*commerceService)
	return repo, pub, svc
}

func seedActiveListing(repo *mockCommerceRepo, id, tenantID string) *domain.MarketplaceListing {
	l := &domain.MarketplaceListing{
		ID:                id,
		TenantID:          tenantID,
		FarmID:            "farm-001",
		ProductName:       "Basmati Rice",
		QuantityAvailable: 1000,
		QuantityUnit:      "kg",
		PricePerUnitPaise: 5000, // 50.00 INR
		Currency:          "INR",
		Status:            domain.ListingStatusActive,
		ImageURLs:         []string{},
		Version:           1,
		CreatedBy:         "seller-1",
		CreatedAt:         time.Now(),
		UpdatedAt:         time.Now(),
	}
	repo.listings[id] = l
	return l
}

func seedOrder(repo *mockCommerceRepo, id, tenantID string, status domain.OrderStatus) *domain.Order {
	o := &domain.Order{
		ID:               id,
		TenantID:         tenantID,
		ListingID:        "listing-001",
		BuyerID:          "buyer-1",
		SellerID:         "seller-1",
		Quantity:         100,
		QuantityUnit:     "kg",
		UnitPricePaise:   5000,
		TotalAmountPaise: 500000,
		Currency:         "INR",
		Status:           status,
		PaymentStatus:    domain.PaymentStatusPending,
		Metadata:         json.RawMessage("{}"),
		Version:          1,
		CreatedBy:        "buyer-1",
		CreatedAt:        time.Now(),
		UpdatedAt:        time.Now(),
	}
	repo.orders[id] = o
	return o
}

// ===========================================================================
// Tests: CreateListing
// ===========================================================================

func TestCreateListing_HappyPath(t *testing.T) {
	_, pub, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	input := domain.CreateListingInput{
		FarmID:            "farm-001",
		ProductName:       "Basmati Rice",
		QuantityAvailable: 500,
		PricePerUnitPaise: 5000,
	}

	listing, err := svc.CreateListing(ctx, input)
	require.NoError(t, err)
	assert.NotEmpty(t, listing.ID)
	assert.Equal(t, "tenant-1", listing.TenantID)
	assert.Equal(t, "Basmati Rice", listing.ProductName)
	assert.Equal(t, domain.ListingStatusDraft, listing.Status)
	assert.Equal(t, "user-1", listing.CreatedBy)
	assert.Equal(t, "INR", listing.Currency)
	assert.Equal(t, "kg", listing.QuantityUnit)
	assert.Equal(t, int64(1), listing.Version)
	assert.Len(t, pub.published, 1)
	assert.Equal(t, eventTopic, pub.published[0].topic)
}

func TestCreateListing_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.CreateListing(ctx, domain.CreateListingInput{
		FarmID:            "farm-001",
		ProductName:       "X",
		QuantityAvailable: 10,
		PricePerUnitPaise: 100,
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_TENANT", errors.Reason(err))
}

func TestCreateListing_MissingFarmID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CreateListing(ctx, domain.CreateListingInput{
		ProductName:       "X",
		QuantityAvailable: 10,
		PricePerUnitPaise: 100,
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_FARM_ID", errors.Reason(err))
}

func TestCreateListing_MissingProductName(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CreateListing(ctx, domain.CreateListingInput{
		FarmID:            "farm-001",
		QuantityAvailable: 10,
		PricePerUnitPaise: 100,
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_PRODUCT_NAME", errors.Reason(err))
}

func TestCreateListing_InvalidQuantity(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CreateListing(ctx, domain.CreateListingInput{
		FarmID:            "farm-001",
		ProductName:       "X",
		QuantityAvailable: 0,
		PricePerUnitPaise: 100,
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_QUANTITY", errors.Reason(err))
}

func TestCreateListing_InvalidPrice(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CreateListing(ctx, domain.CreateListingInput{
		FarmID:            "farm-001",
		ProductName:       "X",
		QuantityAvailable: 10,
		PricePerUnitPaise: 0,
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_PRICE", errors.Reason(err))
}

func TestCreateListing_DefaultCurrencyAndUnit(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	listing, err := svc.CreateListing(ctx, domain.CreateListingInput{
		FarmID:            "farm-001",
		ProductName:       "Wheat",
		QuantityAvailable: 10,
		PricePerUnitPaise: 100,
		// Currency and QuantityUnit not set -- should default.
	})
	require.NoError(t, err)
	assert.Equal(t, "INR", listing.Currency)
	assert.Equal(t, "kg", listing.QuantityUnit)
}

// ===========================================================================
// Tests: GetListing
// ===========================================================================

func TestGetListing_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	seedActiveListing(repo, "listing-001", "tenant-1")

	listing, err := svc.GetListing(ctx, "listing-001")
	require.NoError(t, err)
	assert.Equal(t, "Basmati Rice", listing.ProductName)
}

func TestGetListing_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.GetListing(ctx, "listing-001")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestGetListing_MissingID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetListing(ctx, "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_ID", errors.Reason(err))
}

func TestGetListing_NotFound(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetListing(ctx, "nonexistent")
	require.Error(t, err)
	assert.True(t, errors.IsNotFound(err))
}

// ===========================================================================
// Tests: ListListings
// ===========================================================================

func TestListListings_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	seedActiveListing(repo, "listing-001", "tenant-1")
	seedActiveListing(repo, "listing-002", "tenant-1")

	listings, total, err := svc.ListListings(ctx, domain.ListListingsFilter{})
	require.NoError(t, err)
	assert.Equal(t, int32(2), total)
	assert.Len(t, listings, 2)
}

func TestListListings_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, _, err := svc.ListListings(ctx, domain.ListListingsFilter{})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestListListings_DefaultAndMaxPageSize(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	// PageSize 0 defaults, PageSize 500 caps.
	_, _, err := svc.ListListings(ctx, domain.ListListingsFilter{PageSize: 0})
	require.NoError(t, err)
	_, _, err = svc.ListListings(ctx, domain.ListListingsFilter{PageSize: 500})
	require.NoError(t, err)
}

// ===========================================================================
// Tests: UpdateListing
// ===========================================================================

func TestUpdateListing_HappyPath(t *testing.T) {
	repo, pub, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	// Draft listing can be updated.
	repo.listings["listing-001"] = &domain.MarketplaceListing{
		ID:       "listing-001",
		TenantID: "tenant-1",
		Status:   domain.ListingStatusDraft,
	}

	newName := "Updated Rice"
	updated, err := svc.UpdateListing(ctx, "listing-001", domain.UpdateListingInput{
		ProductName: &newName,
	})
	require.NoError(t, err)
	assert.Equal(t, "Updated Rice", updated.ProductName)
	assert.Len(t, pub.published, 1)
}

func TestUpdateListing_ActiveListingCanBeUpdated(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	seedActiveListing(repo, "listing-001", "tenant-1")

	newName := "Fresh Rice"
	_, err := svc.UpdateListing(ctx, "listing-001", domain.UpdateListingInput{
		ProductName: &newName,
	})
	require.NoError(t, err)
}

func TestUpdateListing_CancelledCannotBeUpdated(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.listings["listing-001"] = &domain.MarketplaceListing{
		ID:       "listing-001",
		TenantID: "tenant-1",
		Status:   domain.ListingStatusCancelled,
	}

	newName := "X"
	_, err := svc.UpdateListing(ctx, "listing-001", domain.UpdateListingInput{
		ProductName: &newName,
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_STATUS", errors.Reason(err))
}

func TestUpdateListing_SoldOutCannotBeUpdated(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.listings["listing-001"] = &domain.MarketplaceListing{
		ID:       "listing-001",
		TenantID: "tenant-1",
		Status:   domain.ListingStatusSoldOut,
	}

	newName := "X"
	_, err := svc.UpdateListing(ctx, "listing-001", domain.UpdateListingInput{
		ProductName: &newName,
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_STATUS", errors.Reason(err))
}

func TestUpdateListing_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.UpdateListing(ctx, "listing-001", domain.UpdateListingInput{})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestUpdateListing_MissingID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.UpdateListing(ctx, "", domain.UpdateListingInput{})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_ID", errors.Reason(err))
}

// ===========================================================================
// Tests: CancelListing
// ===========================================================================

func TestCancelListing_DraftCanBeCancelled(t *testing.T) {
	repo, pub, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.listings["listing-001"] = &domain.MarketplaceListing{
		ID:       "listing-001",
		TenantID: "tenant-1",
		Status:   domain.ListingStatusDraft,
	}

	cancelled, err := svc.CancelListing(ctx, "listing-001")
	require.NoError(t, err)
	assert.Equal(t, domain.ListingStatusCancelled, cancelled.Status)
	assert.Len(t, pub.published, 1)
}

func TestCancelListing_ActiveCanBeCancelled(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	seedActiveListing(repo, "listing-001", "tenant-1")

	cancelled, err := svc.CancelListing(ctx, "listing-001")
	require.NoError(t, err)
	assert.Equal(t, domain.ListingStatusCancelled, cancelled.Status)
}

func TestCancelListing_SoldOutCannotBeCancelled(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.listings["listing-001"] = &domain.MarketplaceListing{
		ID:       "listing-001",
		TenantID: "tenant-1",
		Status:   domain.ListingStatusSoldOut,
	}

	_, err := svc.CancelListing(ctx, "listing-001")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_STATUS", errors.Reason(err))
}

func TestCancelListing_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.CancelListing(ctx, "listing-001")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestCancelListing_MissingID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CancelListing(ctx, "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_ID", errors.Reason(err))
}

// ===========================================================================
// Tests: PlaceOrder
// ===========================================================================

func TestPlaceOrder_HappyPath(t *testing.T) {
	repo, pub, svc := newService()
	ctx := testContext("tenant-1", "buyer-1")

	seedActiveListing(repo, "listing-001", "tenant-1")

	input := domain.PlaceOrderInput{
		ListingID: "listing-001",
		Quantity:  100,
	}

	order, err := svc.PlaceOrder(ctx, input)
	require.NoError(t, err)
	assert.NotEmpty(t, order.ID)
	assert.Equal(t, "tenant-1", order.TenantID)
	assert.Equal(t, "listing-001", order.ListingID)
	assert.Equal(t, "buyer-1", order.BuyerID)
	assert.Equal(t, "seller-1", order.SellerID)
	assert.Equal(t, float64(100), order.Quantity)
	assert.Equal(t, int64(5000), order.UnitPricePaise)
	assert.Equal(t, int64(500000), order.TotalAmountPaise)
	assert.Equal(t, "INR", order.Currency)
	assert.Equal(t, domain.OrderStatusPending, order.Status)
	assert.Equal(t, domain.PaymentStatusPending, order.PaymentStatus)
	assert.Len(t, pub.published, 1)
}

func TestPlaceOrder_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "buyer-1")

	_, err := svc.PlaceOrder(ctx, domain.PlaceOrderInput{ListingID: "l1", Quantity: 10})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_TENANT", errors.Reason(err))
}

func TestPlaceOrder_MissingListingID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "buyer-1")

	_, err := svc.PlaceOrder(ctx, domain.PlaceOrderInput{Quantity: 10})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_LISTING_ID", errors.Reason(err))
}

func TestPlaceOrder_InvalidQuantity(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "buyer-1")

	_, err := svc.PlaceOrder(ctx, domain.PlaceOrderInput{ListingID: "l1", Quantity: 0})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_QUANTITY", errors.Reason(err))
}

func TestPlaceOrder_ListingNotActive(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "buyer-1")

	repo.listings["listing-001"] = &domain.MarketplaceListing{
		ID:       "listing-001",
		TenantID: "tenant-1",
		Status:   domain.ListingStatusDraft, // not active
	}

	_, err := svc.PlaceOrder(ctx, domain.PlaceOrderInput{ListingID: "listing-001", Quantity: 10})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "LISTING_NOT_ACTIVE", errors.Reason(err))
}

func TestPlaceOrder_InsufficientQuantity(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "buyer-1")

	seedActiveListing(repo, "listing-001", "tenant-1") // has 1000 kg available

	_, err := svc.PlaceOrder(ctx, domain.PlaceOrderInput{
		ListingID: "listing-001",
		Quantity:  2000, // exceeds 1000
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INSUFFICIENT_QUANTITY", errors.Reason(err))
}

func TestPlaceOrder_ListingNotFound(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "buyer-1")

	_, err := svc.PlaceOrder(ctx, domain.PlaceOrderInput{
		ListingID: "nonexistent",
		Quantity:  10,
	})
	require.Error(t, err)
	assert.True(t, errors.IsNotFound(err))
}

// ===========================================================================
// Tests: GetOrder
// ===========================================================================

func TestGetOrder_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	seedOrder(repo, "order-001", "tenant-1", domain.OrderStatusPending)

	order, err := svc.GetOrder(ctx, "order-001")
	require.NoError(t, err)
	assert.Equal(t, "order-001", order.ID)
}

func TestGetOrder_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.GetOrder(ctx, "order-001")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestGetOrder_MissingID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetOrder(ctx, "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_ID", errors.Reason(err))
}

func TestGetOrder_NotFound(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetOrder(ctx, "nonexistent")
	require.Error(t, err)
	assert.True(t, errors.IsNotFound(err))
}

// ===========================================================================
// Tests: ListOrders
// ===========================================================================

func TestListOrders_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	seedOrder(repo, "order-001", "tenant-1", domain.OrderStatusPending)
	seedOrder(repo, "order-002", "tenant-1", domain.OrderStatusConfirmed)

	orders, total, err := svc.ListOrders(ctx, domain.ListOrdersFilter{})
	require.NoError(t, err)
	assert.Equal(t, int32(2), total)
	assert.Len(t, orders, 2)
}

func TestListOrders_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, _, err := svc.ListOrders(ctx, domain.ListOrdersFilter{})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

// ===========================================================================
// Tests: UpdateOrderStatus -- order state machine transitions
// ===========================================================================

func TestUpdateOrderStatus_PendingToConfirmed(t *testing.T) {
	repo, pub, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	seedOrder(repo, "order-001", "tenant-1", domain.OrderStatusPending)

	updated, err := svc.UpdateOrderStatus(ctx, "order-001", domain.OrderStatusConfirmed, "confirming")
	require.NoError(t, err)
	assert.Equal(t, domain.OrderStatusConfirmed, updated.Status)
	assert.Len(t, pub.published, 1)
}

func TestUpdateOrderStatus_PendingToCancelled(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	seedOrder(repo, "order-001", "tenant-1", domain.OrderStatusPending)

	updated, err := svc.UpdateOrderStatus(ctx, "order-001", domain.OrderStatusCancelled, "buyer cancelled")
	require.NoError(t, err)
	assert.Equal(t, domain.OrderStatusCancelled, updated.Status)
}

func TestUpdateOrderStatus_ConfirmedToProcessing(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	seedOrder(repo, "order-001", "tenant-1", domain.OrderStatusConfirmed)

	updated, err := svc.UpdateOrderStatus(ctx, "order-001", domain.OrderStatusProcessing, "")
	require.NoError(t, err)
	assert.Equal(t, domain.OrderStatusProcessing, updated.Status)
}

func TestUpdateOrderStatus_ConfirmedToCancelled(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	seedOrder(repo, "order-001", "tenant-1", domain.OrderStatusConfirmed)

	updated, err := svc.UpdateOrderStatus(ctx, "order-001", domain.OrderStatusCancelled, "")
	require.NoError(t, err)
	assert.Equal(t, domain.OrderStatusCancelled, updated.Status)
}

func TestUpdateOrderStatus_ProcessingToShipped(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	seedOrder(repo, "order-001", "tenant-1", domain.OrderStatusProcessing)

	updated, err := svc.UpdateOrderStatus(ctx, "order-001", domain.OrderStatusShipped, "")
	require.NoError(t, err)
	assert.Equal(t, domain.OrderStatusShipped, updated.Status)
}

func TestUpdateOrderStatus_ShippedToDelivered(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	seedOrder(repo, "order-001", "tenant-1", domain.OrderStatusShipped)

	updated, err := svc.UpdateOrderStatus(ctx, "order-001", domain.OrderStatusDelivered, "")
	require.NoError(t, err)
	assert.Equal(t, domain.OrderStatusDelivered, updated.Status)
}

func TestUpdateOrderStatus_ShippedToDisputed(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	seedOrder(repo, "order-001", "tenant-1", domain.OrderStatusShipped)

	updated, err := svc.UpdateOrderStatus(ctx, "order-001", domain.OrderStatusDisputed, "damaged goods")
	require.NoError(t, err)
	assert.Equal(t, domain.OrderStatusDisputed, updated.Status)
}

func TestUpdateOrderStatus_DeliveredToCompleted(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	seedOrder(repo, "order-001", "tenant-1", domain.OrderStatusDelivered)

	updated, err := svc.UpdateOrderStatus(ctx, "order-001", domain.OrderStatusCompleted, "")
	require.NoError(t, err)
	assert.Equal(t, domain.OrderStatusCompleted, updated.Status)
}

func TestUpdateOrderStatus_DeliveredToDisputed(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	seedOrder(repo, "order-001", "tenant-1", domain.OrderStatusDelivered)

	updated, err := svc.UpdateOrderStatus(ctx, "order-001", domain.OrderStatusDisputed, "quality issue")
	require.NoError(t, err)
	assert.Equal(t, domain.OrderStatusDisputed, updated.Status)
}

func TestUpdateOrderStatus_DisputedToCompleted(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	seedOrder(repo, "order-001", "tenant-1", domain.OrderStatusDisputed)

	updated, err := svc.UpdateOrderStatus(ctx, "order-001", domain.OrderStatusCompleted, "resolved")
	require.NoError(t, err)
	assert.Equal(t, domain.OrderStatusCompleted, updated.Status)
}

func TestUpdateOrderStatus_DisputedToCancelled(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	seedOrder(repo, "order-001", "tenant-1", domain.OrderStatusDisputed)

	updated, err := svc.UpdateOrderStatus(ctx, "order-001", domain.OrderStatusCancelled, "refunded")
	require.NoError(t, err)
	assert.Equal(t, domain.OrderStatusCancelled, updated.Status)
}

// --- Invalid transitions ---

func TestUpdateOrderStatus_PendingToShipped_Invalid(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	seedOrder(repo, "order-001", "tenant-1", domain.OrderStatusPending)

	_, err := svc.UpdateOrderStatus(ctx, "order-001", domain.OrderStatusShipped, "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_TRANSITION", errors.Reason(err))
}

func TestUpdateOrderStatus_CompletedCannotTransition(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	seedOrder(repo, "order-001", "tenant-1", domain.OrderStatusCompleted)

	_, err := svc.UpdateOrderStatus(ctx, "order-001", domain.OrderStatusCancelled, "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_TRANSITION", errors.Reason(err))
}

func TestUpdateOrderStatus_CancelledCannotTransition(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	seedOrder(repo, "order-001", "tenant-1", domain.OrderStatusCancelled)

	_, err := svc.UpdateOrderStatus(ctx, "order-001", domain.OrderStatusPending, "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_TRANSITION", errors.Reason(err))
}

func TestUpdateOrderStatus_ConfirmedToDelivered_Invalid(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	seedOrder(repo, "order-001", "tenant-1", domain.OrderStatusConfirmed)

	_, err := svc.UpdateOrderStatus(ctx, "order-001", domain.OrderStatusDelivered, "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_TRANSITION", errors.Reason(err))
}

func TestUpdateOrderStatus_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.UpdateOrderStatus(ctx, "order-001", domain.OrderStatusConfirmed, "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestUpdateOrderStatus_MissingID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.UpdateOrderStatus(ctx, "", domain.OrderStatusConfirmed, "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_ID", errors.Reason(err))
}

func TestUpdateOrderStatus_OrderNotFound(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.UpdateOrderStatus(ctx, "nonexistent", domain.OrderStatusConfirmed, "")
	require.Error(t, err)
	assert.True(t, errors.IsNotFound(err))
}

// ===========================================================================
// Tests: UpdatePaymentStatus
// ===========================================================================

func TestUpdatePaymentStatus_HappyPath(t *testing.T) {
	repo, pub, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	seedOrder(repo, "order-001", "tenant-1", domain.OrderStatusConfirmed)

	updated, err := svc.UpdatePaymentStatus(ctx, "order-001", domain.PaymentStatusPaid, "PAY-REF-123")
	require.NoError(t, err)
	assert.Equal(t, domain.PaymentStatusPaid, updated.PaymentStatus)
	require.NotNil(t, updated.PaymentReference)
	assert.Equal(t, "PAY-REF-123", *updated.PaymentReference)
	assert.Len(t, pub.published, 1)
}

func TestUpdatePaymentStatus_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.UpdatePaymentStatus(ctx, "order-001", domain.PaymentStatusPaid, "ref")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestUpdatePaymentStatus_MissingID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.UpdatePaymentStatus(ctx, "", domain.PaymentStatusPaid, "ref")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_ID", errors.Reason(err))
}

func TestUpdatePaymentStatus_OrderNotFound(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.UpdatePaymentStatus(ctx, "nonexistent", domain.PaymentStatusPaid, "ref")
	require.Error(t, err)
	assert.True(t, errors.IsNotFound(err))
}

// ===========================================================================
// Tests: Full order lifecycle (happy path through the state machine)
// ===========================================================================

func TestOrderLifecycle_FullHappyPath(t *testing.T) {
	repo, pub, svc := newService()
	ctx := testContext("tenant-1", "buyer-1")

	// 1. Create an active listing.
	seedActiveListing(repo, "listing-001", "tenant-1")

	// 2. Place an order.
	order, err := svc.PlaceOrder(ctx, domain.PlaceOrderInput{
		ListingID: "listing-001",
		Quantity:  50,
	})
	require.NoError(t, err)
	assert.Equal(t, domain.OrderStatusPending, order.Status)
	orderID := order.ID

	// 3. Confirm.
	order, err = svc.UpdateOrderStatus(ctx, orderID, domain.OrderStatusConfirmed, "")
	require.NoError(t, err)
	assert.Equal(t, domain.OrderStatusConfirmed, order.Status)

	// 4. Process.
	order, err = svc.UpdateOrderStatus(ctx, orderID, domain.OrderStatusProcessing, "")
	require.NoError(t, err)
	assert.Equal(t, domain.OrderStatusProcessing, order.Status)

	// 5. Ship.
	order, err = svc.UpdateOrderStatus(ctx, orderID, domain.OrderStatusShipped, "")
	require.NoError(t, err)
	assert.Equal(t, domain.OrderStatusShipped, order.Status)

	// 6. Deliver.
	order, err = svc.UpdateOrderStatus(ctx, orderID, domain.OrderStatusDelivered, "")
	require.NoError(t, err)
	assert.Equal(t, domain.OrderStatusDelivered, order.Status)

	// 7. Complete.
	order, err = svc.UpdateOrderStatus(ctx, orderID, domain.OrderStatusCompleted, "buyer satisfied")
	require.NoError(t, err)
	assert.Equal(t, domain.OrderStatusCompleted, order.Status)

	// Should have 6 events: PlaceOrder + 5 status updates.
	assert.Len(t, pub.published, 6)
}
