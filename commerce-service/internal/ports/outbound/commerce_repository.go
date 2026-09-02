// Package outbound defines the secondary ports for the commerce-service.
package outbound

import (
	"context"

	"p9e.in/samavaya/agriculture/commerce-service/internal/domain"
)

// CommerceRepository is the secondary port for commerce persistence.
type CommerceRepository interface {
	// Marketplace Listings
	CreateListing(ctx context.Context, listing *domain.MarketplaceListing) (*domain.MarketplaceListing, error)
	GetListingByID(ctx context.Context, id, tenantID string) (*domain.MarketplaceListing, error)
	ListListings(ctx context.Context, tenantID string, filter domain.ListListingsFilter) ([]domain.MarketplaceListing, int32, error)
	UpdateListing(ctx context.Context, id, tenantID string, input domain.UpdateListingInput, updatedBy string) (*domain.MarketplaceListing, error)
	CancelListing(ctx context.Context, id, tenantID, updatedBy string) (*domain.MarketplaceListing, error)

	// Orders
	CreateOrder(ctx context.Context, order *domain.Order) (*domain.Order, error)
	GetOrderByID(ctx context.Context, id, tenantID string) (*domain.Order, error)
	ListOrders(ctx context.Context, tenantID string, filter domain.ListOrdersFilter) ([]domain.Order, int32, error)
	UpdateOrderStatus(ctx context.Context, id, tenantID string, status domain.OrderStatus, notes string, updatedBy string) (*domain.Order, error)
	UpdatePaymentStatus(ctx context.Context, id, tenantID string, status domain.PaymentStatus, reference string, updatedBy string) (*domain.Order, error)
}
