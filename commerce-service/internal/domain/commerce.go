package domain

import (
	"encoding/json"
	"time"
)

type ListingStatus string

const (
	ListingStatusDraft     ListingStatus = "LISTING_STATUS_DRAFT"
	ListingStatusActive    ListingStatus = "LISTING_STATUS_ACTIVE"
	ListingStatusSoldOut   ListingStatus = "LISTING_STATUS_SOLD_OUT"
	ListingStatusExpired   ListingStatus = "LISTING_STATUS_EXPIRED"
	ListingStatusCancelled ListingStatus = "LISTING_STATUS_CANCELLED"
)

type OrderStatus string

const (
	OrderStatusPending    OrderStatus = "ORDER_STATUS_PENDING"
	OrderStatusConfirmed  OrderStatus = "ORDER_STATUS_CONFIRMED"
	OrderStatusProcessing OrderStatus = "ORDER_STATUS_PROCESSING"
	OrderStatusShipped    OrderStatus = "ORDER_STATUS_SHIPPED"
	OrderStatusDelivered  OrderStatus = "ORDER_STATUS_DELIVERED"
	OrderStatusCompleted  OrderStatus = "ORDER_STATUS_COMPLETED"
	OrderStatusCancelled  OrderStatus = "ORDER_STATUS_CANCELLED"
	OrderStatusDisputed   OrderStatus = "ORDER_STATUS_DISPUTED"
)

type PaymentStatus string

const (
	PaymentStatusPending  PaymentStatus = "PAYMENT_STATUS_PENDING"
	PaymentStatusPaid     PaymentStatus = "PAYMENT_STATUS_PAID"
	PaymentStatusRefunded PaymentStatus = "PAYMENT_STATUS_REFUNDED"
)

// ValidOrderTransitions maps current status to allowed next statuses.
var ValidOrderTransitions = map[OrderStatus][]OrderStatus{
	OrderStatusPending:    {OrderStatusConfirmed, OrderStatusCancelled},
	OrderStatusConfirmed:  {OrderStatusProcessing, OrderStatusCancelled},
	OrderStatusProcessing: {OrderStatusShipped, OrderStatusCancelled},
	OrderStatusShipped:    {OrderStatusDelivered, OrderStatusDisputed},
	OrderStatusDelivered:  {OrderStatusCompleted, OrderStatusDisputed},
	OrderStatusDisputed:   {OrderStatusCompleted, OrderStatusCancelled},
}

// ValidPaymentTransitions maps current payment status to allowed next statuses.
var ValidPaymentTransitions = map[PaymentStatus][]PaymentStatus{
	PaymentStatusPending: {PaymentStatusPaid},
	PaymentStatusPaid:    {PaymentStatusRefunded},
}

// ValidListingTransitions maps current listing status to allowed next statuses.
var ValidListingTransitions = map[ListingStatus][]ListingStatus{
	ListingStatusDraft:   {ListingStatusActive, ListingStatusCancelled},
	ListingStatusActive:  {ListingStatusSoldOut, ListingStatusExpired, ListingStatusCancelled},
	ListingStatusSoldOut: {ListingStatusActive},
}

// MarketplaceListing is a produce listing posted by a farmer.
type MarketplaceListing struct {
	ID                    string        `json:"id"`
	TenantID              string        `json:"tenant_id"`
	FarmID                string        `json:"farm_id"`
	CropID                string        `json:"crop_id"`
	ProductName           string        `json:"product_name"`
	ProductType           string        `json:"product_type"`
	Description           *string       `json:"description,omitempty"`
	QuantityAvailable     float64       `json:"quantity_available"`
	QuantityUnit          string        `json:"quantity_unit"`
	PricePerUnitPaise     int64         `json:"price_per_unit_paise"`
	Currency              string        `json:"currency"`
	MinOrderQuantity      *float64      `json:"min_order_quantity,omitempty"`
	QualityGrade          *string       `json:"quality_grade,omitempty"`
	TraceabilityRecordID  *string       `json:"traceability_record_id,omitempty"`
	BatchID               *string       `json:"batch_id,omitempty"`
	Status                ListingStatus `json:"status"`
	Location              *string       `json:"location,omitempty"`
	Region                *string       `json:"region,omitempty"`
	ImageURLs             []string      `json:"image_urls"`
	AvailableFrom         *time.Time    `json:"available_from,omitempty"`
	AvailableTo           *time.Time    `json:"available_to,omitempty"`
	Version               int64         `json:"version"`
	CreatedBy             string        `json:"created_by"`
	UpdatedBy             *string       `json:"updated_by,omitempty"`
	CreatedAt             time.Time     `json:"created_at"`
	UpdatedAt             time.Time     `json:"updated_at"`
}

// Order represents a purchase order.
type Order struct {
	ID                    string        `json:"id"`
	TenantID              string        `json:"tenant_id"`
	ListingID             string        `json:"listing_id"`
	BuyerID               string        `json:"buyer_id"`
	SellerID              string        `json:"seller_id"`
	Quantity              float64       `json:"quantity"`
	QuantityUnit          string        `json:"quantity_unit"`
	UnitPricePaise        int64         `json:"unit_price_paise"`
	TotalAmountPaise      int64         `json:"total_amount_paise"`
	Currency              string        `json:"currency"`
	Status                OrderStatus   `json:"status"`
	PaymentStatus         PaymentStatus `json:"payment_status"`
	PaymentReference      *string       `json:"payment_reference,omitempty"`
	DeliveryMethod        *string       `json:"delivery_method,omitempty"`
	DeliveryAddress       *string       `json:"delivery_address,omitempty"`
	DeliveryNotes         *string       `json:"delivery_notes,omitempty"`
	EstimatedDeliveryDate *time.Time    `json:"estimated_delivery_date,omitempty"`
	ActualDeliveryDate    *time.Time    `json:"actual_delivery_date,omitempty"`
	Notes                 *string       `json:"notes,omitempty"`
	Metadata              json.RawMessage `json:"metadata"`
	Version               int64         `json:"version"`
	CreatedBy             string        `json:"created_by"`
	UpdatedBy             *string       `json:"updated_by,omitempty"`
	CreatedAt             time.Time     `json:"created_at"`
	UpdatedAt             time.Time     `json:"updated_at"`
}

type CreateListingInput struct {
	FarmID               string
	CropID               string
	ProductName          string
	ProductType          string
	Description          *string
	QuantityAvailable    float64
	QuantityUnit         string
	PricePerUnitPaise    int64
	Currency             string
	MinOrderQuantity     *float64
	QualityGrade         *string
	TraceabilityRecordID *string
	BatchID              *string
	Location             *string
	Region               *string
	ImageURLs            []string
	AvailableFrom        *time.Time
	AvailableTo          *time.Time
}

type UpdateListingInput struct {
	ProductName       *string
	Description       *string
	QuantityAvailable *float64
	PricePerUnitPaise *int64
	MinOrderQuantity  *float64
	QualityGrade      *string
	ImageURLs         []string
	AvailableTo       *time.Time
}

type ListListingsFilter struct {
	FarmID      string
	CropID      string
	ProductType string
	Region      string
	Status      string
	Search      string
	PageSize    int32
	PageOffset  int32
}

type PlaceOrderInput struct {
	ListingID       string
	Quantity        float64
	DeliveryMethod  *string
	DeliveryAddress *string
	DeliveryNotes   *string
	Notes           *string
}

type ListOrdersFilter struct {
	ListingID  string
	BuyerID    string
	SellerID   string
	Status     string
	PageSize   int32
	PageOffset int32
}
