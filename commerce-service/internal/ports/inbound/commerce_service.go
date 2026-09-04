// Package inbound defines the primary ports for the commerce-service.
package inbound

import (
	"context"

	"p9e.in/samavaya/agriculture/commerce-service/internal/domain"
)

// CommerceService is the primary port for all commerce business operations.
type CommerceService interface {
	// Listings
	CreateListing(ctx context.Context, input domain.CreateListingInput) (*domain.MarketplaceListing, error)
	GetListing(ctx context.Context, id string) (*domain.MarketplaceListing, error)
	ListListings(ctx context.Context, filter domain.ListListingsFilter) ([]domain.MarketplaceListing, int32, error)
	UpdateListing(ctx context.Context, id string, input domain.UpdateListingInput) (*domain.MarketplaceListing, error)
	ActivateListing(ctx context.Context, id string) (*domain.MarketplaceListing, error)
	CancelListing(ctx context.Context, id string) (*domain.MarketplaceListing, error)

	// Orders
	PlaceOrder(ctx context.Context, input domain.PlaceOrderInput) (*domain.Order, error)
	GetOrder(ctx context.Context, id string) (*domain.Order, error)
	ListOrders(ctx context.Context, filter domain.ListOrdersFilter) ([]domain.Order, int32, error)
	UpdateOrderStatus(ctx context.Context, id string, status domain.OrderStatus, notes string) (*domain.Order, error)
	UpdatePaymentStatus(ctx context.Context, id string, status domain.PaymentStatus, reference string) (*domain.Order, error)
}
