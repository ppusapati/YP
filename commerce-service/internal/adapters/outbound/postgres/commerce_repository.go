// Package postgres implements the outbound.CommerceRepository port using pgx.
package postgres

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"

	"p9e.in/samavaya/agriculture/commerce-service/internal/domain"
	"p9e.in/samavaya/agriculture/commerce-service/internal/ports/outbound"
)

type commerceRepository struct {
	pool *pgxpool.Pool
	log  *p9log.Helper
}

// NewCommerceRepository creates a new postgres-backed CommerceRepository.
func NewCommerceRepository(pool *pgxpool.Pool, log p9log.Logger) outbound.CommerceRepository {
	return &commerceRepository{
		pool: pool,
		log:  p9log.NewHelper(p9log.With(log, "component", "CommercePostgresRepository")),
	}
}

// ── Listing columns used by SELECT and RETURNING ────────────────────────────

const listingColumns = `id, tenant_id, farm_id, crop_id,
	product_name, product_type, description,
	quantity_available, quantity_unit, price_per_unit_paise, currency,
	min_order_quantity, quality_grade, traceability_record_id, batch_id,
	status, location, region, image_urls,
	available_from, available_to,
	version, created_by, updated_by, created_at, updated_at`

func scanListing(row pgx.Row) (*domain.MarketplaceListing, error) {
	var l domain.MarketplaceListing
	err := row.Scan(
		&l.ID, &l.TenantID, &l.FarmID, &l.CropID,
		&l.ProductName, &l.ProductType, &l.Description,
		&l.QuantityAvailable, &l.QuantityUnit, &l.PricePerUnitPaise, &l.Currency,
		&l.MinOrderQuantity, &l.QualityGrade, &l.TraceabilityRecordID, &l.BatchID,
		&l.Status, &l.Location, &l.Region, &l.ImageURLs,
		&l.AvailableFrom, &l.AvailableTo,
		&l.Version, &l.CreatedBy, &l.UpdatedBy, &l.CreatedAt, &l.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}
	return &l, nil
}

func scanListingRows(rows pgx.Rows) ([]domain.MarketplaceListing, error) {
	var listings []domain.MarketplaceListing
	for rows.Next() {
		var l domain.MarketplaceListing
		if err := rows.Scan(
			&l.ID, &l.TenantID, &l.FarmID, &l.CropID,
			&l.ProductName, &l.ProductType, &l.Description,
			&l.QuantityAvailable, &l.QuantityUnit, &l.PricePerUnitPaise, &l.Currency,
			&l.MinOrderQuantity, &l.QualityGrade, &l.TraceabilityRecordID, &l.BatchID,
			&l.Status, &l.Location, &l.Region, &l.ImageURLs,
			&l.AvailableFrom, &l.AvailableTo,
			&l.Version, &l.CreatedBy, &l.UpdatedBy, &l.CreatedAt, &l.UpdatedAt,
		); err != nil {
			return nil, err
		}
		listings = append(listings, l)
	}
	return listings, rows.Err()
}

// ── Listing CRUD ─────────────────────────────────────────────────────────────

func (r *commerceRepository) CreateListing(ctx context.Context, listing *domain.MarketplaceListing) (*domain.MarketplaceListing, error) {
	query := fmt.Sprintf(`INSERT INTO marketplace_listings (
		id, tenant_id, farm_id, crop_id,
		product_name, product_type, description,
		quantity_available, quantity_unit, price_per_unit_paise, currency,
		min_order_quantity, quality_grade, traceability_record_id, batch_id,
		status, location, region, image_urls,
		available_from, available_to,
		version, created_by, updated_by, created_at, updated_at
	) VALUES (
		$1, $2, $3, $4,
		$5, $6, $7,
		$8, $9, $10, $11,
		$12, $13, $14, $15,
		$16, $17, $18, $19,
		$20, $21,
		$22, $23, $24, $25, $26
	) RETURNING %s`, listingColumns)

	result, err := scanListing(r.pool.QueryRow(ctx, query,
		listing.ID, listing.TenantID, listing.FarmID, listing.CropID,
		listing.ProductName, listing.ProductType, listing.Description,
		listing.QuantityAvailable, listing.QuantityUnit, listing.PricePerUnitPaise, listing.Currency,
		listing.MinOrderQuantity, listing.QualityGrade, listing.TraceabilityRecordID, listing.BatchID,
		string(listing.Status), listing.Location, listing.Region, listing.ImageURLs,
		listing.AvailableFrom, listing.AvailableTo,
		listing.Version, listing.CreatedBy, listing.UpdatedBy, listing.CreatedAt, listing.UpdatedAt,
	))
	if err != nil {
		r.log.Errorw("msg", "failed to create listing", "error", err)
		return nil, errors.Internal("failed to create listing: %v", err)
	}
	return result, nil
}

func (r *commerceRepository) GetListingByID(ctx context.Context, id, tenantID string) (*domain.MarketplaceListing, error) {
	query := fmt.Sprintf(`SELECT %s FROM marketplace_listings WHERE id = $1 AND tenant_id = $2 AND deleted_at IS NULL`, listingColumns)

	result, err := scanListing(r.pool.QueryRow(ctx, query, id, tenantID))
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("LISTING_NOT_FOUND", fmt.Sprintf("listing %s not found", id))
		}
		r.log.Errorw("msg", "failed to get listing", "error", err)
		return nil, errors.Internal("failed to get listing: %v", err)
	}
	return result, nil
}

func (r *commerceRepository) ListListings(ctx context.Context, tenantID string, filter domain.ListListingsFilter) ([]domain.MarketplaceListing, int32, error) {
	baseWhere := `WHERE tenant_id = $1 AND deleted_at IS NULL`
	args := []interface{}{tenantID}
	argIdx := 2

	if filter.FarmID != "" {
		baseWhere += fmt.Sprintf(" AND farm_id = $%d", argIdx)
		args = append(args, filter.FarmID)
		argIdx++
	}
	if filter.CropID != "" {
		baseWhere += fmt.Sprintf(" AND crop_id = $%d", argIdx)
		args = append(args, filter.CropID)
		argIdx++
	}
	if filter.ProductType != "" {
		baseWhere += fmt.Sprintf(" AND product_type = $%d", argIdx)
		args = append(args, filter.ProductType)
		argIdx++
	}
	if filter.Region != "" {
		baseWhere += fmt.Sprintf(" AND region = $%d", argIdx)
		args = append(args, filter.Region)
		argIdx++
	}
	if filter.Status != "" {
		baseWhere += fmt.Sprintf(" AND status = $%d", argIdx)
		args = append(args, filter.Status)
		argIdx++
	}
	if filter.Search != "" {
		baseWhere += fmt.Sprintf(` AND (
			product_name ILIKE '%%' || $%d || '%%'
			OR product_type ILIKE '%%' || $%d || '%%'
			OR region ILIKE '%%' || $%d || '%%'
		)`, argIdx, argIdx, argIdx)
		args = append(args, filter.Search)
		argIdx++
	}

	countQuery := fmt.Sprintf("SELECT COUNT(*) FROM marketplace_listings %s", baseWhere)
	var totalCount int32
	err := r.pool.QueryRow(ctx, countQuery, args...).Scan(&totalCount)
	if err != nil {
		r.log.Errorw("msg", "failed to count listings", "error", err)
		return nil, 0, errors.Internal("failed to count listings: %v", err)
	}

	pageSize := filter.PageSize
	if pageSize <= 0 || pageSize > 100 {
		pageSize = 20
	}

	listQuery := fmt.Sprintf(`SELECT %s FROM marketplace_listings %s ORDER BY created_at DESC LIMIT $%d OFFSET $%d`,
		listingColumns, baseWhere, argIdx, argIdx+1)
	args = append(args, pageSize, filter.PageOffset)

	rows, err := r.pool.Query(ctx, listQuery, args...)
	if err != nil {
		r.log.Errorw("msg", "failed to list listings", "error", err)
		return nil, 0, errors.Internal("failed to list listings: %v", err)
	}
	defer rows.Close()

	listings, err := scanListingRows(rows)
	if err != nil {
		r.log.Errorw("msg", "failed to scan listing", "error", err)
		return nil, 0, errors.Internal("failed to scan listing: %v", err)
	}
	return listings, totalCount, nil
}

func (r *commerceRepository) UpdateListing(ctx context.Context, id, tenantID string, input domain.UpdateListingInput, updatedBy string) (*domain.MarketplaceListing, error) {
	setClauses := []string{"updated_by = $3", "version = version + 1"}
	args := []interface{}{id, tenantID, updatedBy}
	argIdx := 4

	if input.ProductName != nil {
		setClauses = append(setClauses, fmt.Sprintf("product_name = $%d", argIdx))
		args = append(args, *input.ProductName)
		argIdx++
	}
	if input.Description != nil {
		setClauses = append(setClauses, fmt.Sprintf("description = $%d", argIdx))
		args = append(args, *input.Description)
		argIdx++
	}
	if input.QuantityAvailable != nil {
		setClauses = append(setClauses, fmt.Sprintf("quantity_available = $%d", argIdx))
		args = append(args, *input.QuantityAvailable)
		argIdx++
	}
	if input.PricePerUnitPaise != nil {
		setClauses = append(setClauses, fmt.Sprintf("price_per_unit_paise = $%d", argIdx))
		args = append(args, *input.PricePerUnitPaise)
		argIdx++
	}
	if input.MinOrderQuantity != nil {
		setClauses = append(setClauses, fmt.Sprintf("min_order_quantity = $%d", argIdx))
		args = append(args, *input.MinOrderQuantity)
		argIdx++
	}
	if input.QualityGrade != nil {
		setClauses = append(setClauses, fmt.Sprintf("quality_grade = $%d", argIdx))
		args = append(args, *input.QualityGrade)
		argIdx++
	}
	if input.ImageURLs != nil {
		setClauses = append(setClauses, fmt.Sprintf("image_urls = $%d", argIdx))
		args = append(args, input.ImageURLs)
		argIdx++
	}
	if input.AvailableTo != nil {
		setClauses = append(setClauses, fmt.Sprintf("available_to = $%d", argIdx))
		args = append(args, input.AvailableTo)
		argIdx++
	}

	query := fmt.Sprintf(`UPDATE marketplace_listings SET %s
		WHERE id = $1 AND tenant_id = $2 AND deleted_at IS NULL
		RETURNING %s`, joinStrings(setClauses, ", "), listingColumns)

	result, err := scanListing(r.pool.QueryRow(ctx, query, args...))
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("LISTING_NOT_FOUND", fmt.Sprintf("listing %s not found", id))
		}
		r.log.Errorw("msg", "failed to update listing", "error", err)
		return nil, errors.Internal("failed to update listing: %v", err)
	}
	return result, nil
}

func (r *commerceRepository) CancelListing(ctx context.Context, id, tenantID, updatedBy string) (*domain.MarketplaceListing, error) {
	query := fmt.Sprintf(`UPDATE marketplace_listings
		SET status = $3, updated_by = $4, version = version + 1
		WHERE id = $1 AND tenant_id = $2 AND deleted_at IS NULL
		RETURNING %s`, listingColumns)

	result, err := scanListing(r.pool.QueryRow(ctx, query, id, tenantID, string(domain.ListingStatusCancelled), updatedBy))
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("LISTING_NOT_FOUND", fmt.Sprintf("listing %s not found", id))
		}
		r.log.Errorw("msg", "failed to cancel listing", "error", err)
		return nil, errors.Internal("failed to cancel listing: %v", err)
	}
	return result, nil
}

// ── Order columns used by SELECT and RETURNING ──────────────────────────────

const orderColumns = `id, tenant_id, listing_id, buyer_id, seller_id,
	quantity, quantity_unit, unit_price_paise, total_amount_paise, currency,
	status, payment_status, payment_reference,
	delivery_method, delivery_address, delivery_notes,
	estimated_delivery_date, actual_delivery_date,
	notes, metadata,
	version, created_by, updated_by, created_at, updated_at`

func scanOrder(row pgx.Row) (*domain.Order, error) {
	var o domain.Order
	var metadata json.RawMessage
	err := row.Scan(
		&o.ID, &o.TenantID, &o.ListingID, &o.BuyerID, &o.SellerID,
		&o.Quantity, &o.QuantityUnit, &o.UnitPricePaise, &o.TotalAmountPaise, &o.Currency,
		&o.Status, &o.PaymentStatus, &o.PaymentReference,
		&o.DeliveryMethod, &o.DeliveryAddress, &o.DeliveryNotes,
		&o.EstimatedDeliveryDate, &o.ActualDeliveryDate,
		&o.Notes, &metadata,
		&o.Version, &o.CreatedBy, &o.UpdatedBy, &o.CreatedAt, &o.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}
	o.Metadata = metadata
	return &o, nil
}

func scanOrderRows(rows pgx.Rows) ([]domain.Order, error) {
	var orders []domain.Order
	for rows.Next() {
		var o domain.Order
		var metadata json.RawMessage
		if err := rows.Scan(
			&o.ID, &o.TenantID, &o.ListingID, &o.BuyerID, &o.SellerID,
			&o.Quantity, &o.QuantityUnit, &o.UnitPricePaise, &o.TotalAmountPaise, &o.Currency,
			&o.Status, &o.PaymentStatus, &o.PaymentReference,
			&o.DeliveryMethod, &o.DeliveryAddress, &o.DeliveryNotes,
			&o.EstimatedDeliveryDate, &o.ActualDeliveryDate,
			&o.Notes, &metadata,
			&o.Version, &o.CreatedBy, &o.UpdatedBy, &o.CreatedAt, &o.UpdatedAt,
		); err != nil {
			return nil, err
		}
		o.Metadata = metadata
		orders = append(orders, o)
	}
	return orders, rows.Err()
}

// ── Order CRUD ───────────────────────────────────────────────────────────────

func (r *commerceRepository) CreateOrder(ctx context.Context, order *domain.Order) (*domain.Order, error) {
	query := fmt.Sprintf(`INSERT INTO orders (
		id, tenant_id, listing_id, buyer_id, seller_id,
		quantity, quantity_unit, unit_price_paise, total_amount_paise, currency,
		status, payment_status, payment_reference,
		delivery_method, delivery_address, delivery_notes,
		estimated_delivery_date, actual_delivery_date,
		notes, metadata,
		version, created_by, updated_by, created_at, updated_at
	) VALUES (
		$1, $2, $3, $4, $5,
		$6, $7, $8, $9, $10,
		$11, $12, $13,
		$14, $15, $16,
		$17, $18,
		$19, $20,
		$21, $22, $23, $24, $25
	) RETURNING %s`, orderColumns)

	result, err := scanOrder(r.pool.QueryRow(ctx, query,
		order.ID, order.TenantID, order.ListingID, order.BuyerID, order.SellerID,
		order.Quantity, order.QuantityUnit, order.UnitPricePaise, order.TotalAmountPaise, order.Currency,
		string(order.Status), string(order.PaymentStatus), order.PaymentReference,
		order.DeliveryMethod, order.DeliveryAddress, order.DeliveryNotes,
		order.EstimatedDeliveryDate, order.ActualDeliveryDate,
		order.Notes, order.Metadata,
		order.Version, order.CreatedBy, order.UpdatedBy, order.CreatedAt, order.UpdatedAt,
	))
	if err != nil {
		r.log.Errorw("msg", "failed to create order", "error", err)
		return nil, errors.Internal("failed to create order: %v", err)
	}
	return result, nil
}

func (r *commerceRepository) GetOrderByID(ctx context.Context, id, tenantID string) (*domain.Order, error) {
	query := fmt.Sprintf(`SELECT %s FROM orders WHERE id = $1 AND tenant_id = $2 AND deleted_at IS NULL`, orderColumns)

	result, err := scanOrder(r.pool.QueryRow(ctx, query, id, tenantID))
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("ORDER_NOT_FOUND", fmt.Sprintf("order %s not found", id))
		}
		r.log.Errorw("msg", "failed to get order", "error", err)
		return nil, errors.Internal("failed to get order: %v", err)
	}
	return result, nil
}

func (r *commerceRepository) ListOrders(ctx context.Context, tenantID string, filter domain.ListOrdersFilter) ([]domain.Order, int32, error) {
	baseWhere := `WHERE tenant_id = $1 AND deleted_at IS NULL`
	args := []interface{}{tenantID}
	argIdx := 2

	if filter.ListingID != "" {
		baseWhere += fmt.Sprintf(" AND listing_id = $%d", argIdx)
		args = append(args, filter.ListingID)
		argIdx++
	}
	if filter.BuyerID != "" {
		baseWhere += fmt.Sprintf(" AND buyer_id = $%d", argIdx)
		args = append(args, filter.BuyerID)
		argIdx++
	}
	if filter.SellerID != "" {
		baseWhere += fmt.Sprintf(" AND seller_id = $%d", argIdx)
		args = append(args, filter.SellerID)
		argIdx++
	}
	if filter.Status != "" {
		baseWhere += fmt.Sprintf(" AND status = $%d", argIdx)
		args = append(args, filter.Status)
		argIdx++
	}

	countQuery := fmt.Sprintf("SELECT COUNT(*) FROM orders %s", baseWhere)
	var totalCount int32
	err := r.pool.QueryRow(ctx, countQuery, args...).Scan(&totalCount)
	if err != nil {
		r.log.Errorw("msg", "failed to count orders", "error", err)
		return nil, 0, errors.Internal("failed to count orders: %v", err)
	}

	pageSize := filter.PageSize
	if pageSize <= 0 || pageSize > 100 {
		pageSize = 20
	}

	listQuery := fmt.Sprintf(`SELECT %s FROM orders %s ORDER BY created_at DESC LIMIT $%d OFFSET $%d`,
		orderColumns, baseWhere, argIdx, argIdx+1)
	args = append(args, pageSize, filter.PageOffset)

	rows, err := r.pool.Query(ctx, listQuery, args...)
	if err != nil {
		r.log.Errorw("msg", "failed to list orders", "error", err)
		return nil, 0, errors.Internal("failed to list orders: %v", err)
	}
	defer rows.Close()

	orders, err := scanOrderRows(rows)
	if err != nil {
		r.log.Errorw("msg", "failed to scan order", "error", err)
		return nil, 0, errors.Internal("failed to scan order: %v", err)
	}
	return orders, totalCount, nil
}

func (r *commerceRepository) UpdateOrderStatus(ctx context.Context, id, tenantID string, status domain.OrderStatus, notes string, updatedBy string) (*domain.Order, error) {
	query := fmt.Sprintf(`UPDATE orders
		SET status = $3, notes = $4, updated_by = $5, version = version + 1
		WHERE id = $1 AND tenant_id = $2 AND deleted_at IS NULL
		RETURNING %s`, orderColumns)

	result, err := scanOrder(r.pool.QueryRow(ctx, query, id, tenantID, string(status), notes, updatedBy))
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("ORDER_NOT_FOUND", fmt.Sprintf("order %s not found", id))
		}
		r.log.Errorw("msg", "failed to update order status", "error", err)
		return nil, errors.Internal("failed to update order status: %v", err)
	}
	return result, nil
}

func (r *commerceRepository) UpdatePaymentStatus(ctx context.Context, id, tenantID string, status domain.PaymentStatus, reference string, updatedBy string) (*domain.Order, error) {
	query := fmt.Sprintf(`UPDATE orders
		SET payment_status = $3, payment_reference = $4, updated_by = $5, version = version + 1
		WHERE id = $1 AND tenant_id = $2 AND deleted_at IS NULL
		RETURNING %s`, orderColumns)

	result, err := scanOrder(r.pool.QueryRow(ctx, query, id, tenantID, string(status), reference, updatedBy))
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("ORDER_NOT_FOUND", fmt.Sprintf("order %s not found", id))
		}
		r.log.Errorw("msg", "failed to update payment status", "error", err)
		return nil, errors.Internal("failed to update payment status: %v", err)
	}
	return result, nil
}

// joinStrings concatenates strings with a separator.
func joinStrings(parts []string, sep string) string {
	if len(parts) == 0 {
		return ""
	}
	result := parts[0]
	for _, p := range parts[1:] {
		result += sep + p
	}
	return result
}
