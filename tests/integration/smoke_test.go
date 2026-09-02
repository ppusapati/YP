//go:build e2e

package integration_test

import (
	"context"
	"encoding/json"
	"fmt"
	"testing"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"p9e.in/samavaya/packages/ulid"
)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

// acquireConn grabs a single connection from the shared pool and sets the RLS
// tenant. Tests that need multi-statement consistency use this.
func acquireConn(t *testing.T, ctx context.Context) *pgx.Conn {
	t.Helper()
	conn, err := sharedPool.Acquire(ctx)
	require.NoError(t, err, "acquire connection")
	raw := conn.Conn()
	_, err = raw.Exec(ctx, fmt.Sprintf("SET app.tenant_id = '%s'", testTenantID))
	require.NoError(t, err, "SET app.tenant_id")
	t.Cleanup(func() { conn.Release() })
	return raw
}

// cleanup deletes rows in the given table for the test tenant.
func cleanup(t *testing.T, tables ...string) {
	t.Helper()
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	for _, tbl := range tables {
		// Use the superuser connection (pool) which bypasses RLS.
		_, _ = sharedPool.Exec(ctx, fmt.Sprintf("DELETE FROM %s WHERE tenant_id = $1", tbl), testTenantID)
	}
}

// ---------------------------------------------------------------------------
// TestFarmToFieldFlow
// ---------------------------------------------------------------------------

func TestFarmToFieldFlow(t *testing.T) {
	require.NotNil(t, sharedPool, "shared pool must be initialized")
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	conn := acquireConn(t, ctx)
	t.Cleanup(func() {
		cleanup(t, "fields", "farms")
	})

	// 1. Create a farm.
	farmID := ulid.NewString()
	_, err := conn.Exec(ctx, `
		INSERT INTO farms (id, tenant_id, name, total_area_hectares, farm_type, status, created_by)
		VALUES ($1, $2, $3, $4, $5, $6, $7)`,
		farmID, testTenantID, "Smoke Test Farm", 50.0, "CROP", "ACTIVE", testUserID,
	)
	require.NoError(t, err, "insert farm")

	// Verify farm exists.
	var farmName string
	err = conn.QueryRow(ctx, `SELECT name FROM farms WHERE id = $1`, farmID).Scan(&farmName)
	require.NoError(t, err, "read farm")
	assert.Equal(t, "Smoke Test Farm", farmName)

	// 2. Create a field linked to the farm.
	fieldID := ulid.NewString()
	_, err = conn.Exec(ctx, `
		INSERT INTO fields (id, tenant_id, farm_id, name, area_hectares, field_type, soil_type,
		irrigation_type, status, elevation_meters, slope_degrees, aspect_direction, growth_stage, created_by)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)`,
		fieldID, testTenantID, farmID, "North Parcel", 12.5, "CROPLAND", "LOAMY",
		"DRIP", "ACTIVE", 100.0, 2.5, "NORTH", "GERMINATION", testUserID,
	)
	require.NoError(t, err, "insert field")

	// 3. Verify the field's farm_id matches.
	var gotFarmID string
	err = conn.QueryRow(ctx, `SELECT farm_id FROM fields WHERE id = $1`, fieldID).Scan(&gotFarmID)
	require.NoError(t, err, "read field")
	assert.Equal(t, farmID, gotFarmID, "field.farm_id must reference the created farm")

	t.Logf("FarmToFieldFlow: farm=%s field=%s linked correctly", farmID, fieldID)
}

// ---------------------------------------------------------------------------
// TestCropLifecycle
// ---------------------------------------------------------------------------

func TestCropLifecycle(t *testing.T) {
	require.NotNil(t, sharedPool, "shared pool must be initialized")
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	conn := acquireConn(t, ctx)
	t.Cleanup(func() {
		cleanup(t, "crop_varieties", "crops")
	})

	// 1. Create a crop.
	cropID := ulid.NewString()
	_, err := conn.Exec(ctx, `
		INSERT INTO crops (id, tenant_id, name, scientific_name, family, category, description, status, is_active, created_by)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, TRUE, $9)`,
		cropID, testTenantID, "Basmati Rice", "Oryza sativa", "Poaceae", "CEREAL",
		"Premium long-grain rice", "active", testUserID,
	)
	require.NoError(t, err, "insert crop")

	// 2. Add a variety.
	varietyID := ulid.NewString()
	_, err = conn.Exec(ctx, `
		INSERT INTO crop_varieties (id, tenant_id, crop_id, name, description, maturity_days,
		yield_potential_kg_per_hectare, is_hybrid, created_by)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
		varietyID, testTenantID, cropID, "Pusa Basmati 1121", "Extra-long grain, aromatic",
		140, 4500.0, false, testUserID,
	)
	require.NoError(t, err, "insert variety")

	// Add a second variety.
	variety2ID := ulid.NewString()
	_, err = conn.Exec(ctx, `
		INSERT INTO crop_varieties (id, tenant_id, crop_id, name, description, maturity_days,
		yield_potential_kg_per_hectare, is_hybrid, created_by)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
		variety2ID, testTenantID, cropID, "Pusa Basmati 6", "Short duration, high yield",
		120, 5000.0, true, testUserID,
	)
	require.NoError(t, err, "insert variety 2")

	// 3. List varieties for the crop.
	rows, err := conn.Query(ctx,
		`SELECT id, name, is_hybrid FROM crop_varieties WHERE crop_id = $1 AND tenant_id = $2 ORDER BY name`,
		cropID, testTenantID,
	)
	require.NoError(t, err, "list varieties")
	defer rows.Close()

	var varieties []struct {
		ID       string
		Name     string
		IsHybrid bool
	}
	for rows.Next() {
		var v struct {
			ID       string
			Name     string
			IsHybrid bool
		}
		require.NoError(t, rows.Scan(&v.ID, &v.Name, &v.IsHybrid))
		varieties = append(varieties, v)
	}
	require.NoError(t, rows.Err())
	assert.Len(t, varieties, 2, "should have 2 varieties")

	// Verify the varieties are the ones we created.
	names := []string{varieties[0].Name, varieties[1].Name}
	assert.Contains(t, names, "Pusa Basmati 1121")
	assert.Contains(t, names, "Pusa Basmati 6")

	t.Logf("CropLifecycle: crop=%s varieties=%d", cropID, len(varieties))
}

// ---------------------------------------------------------------------------
// TestTraceabilityFlow
// ---------------------------------------------------------------------------

func TestTraceabilityFlow(t *testing.T) {
	require.NotNil(t, sharedPool, "shared pool must be initialized")
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	conn := acquireConn(t, ctx)
	t.Cleanup(func() {
		cleanup(t, "qr_codes", "supply_chain_events", "traceability_records")
	})

	now := time.Now()
	meta, _ := json.Marshal(map[string]string{"source": "e2e-test"})

	// 1. Create a traceability record.
	recordID := ulid.NewString()
	_, err := conn.Exec(ctx, `
		INSERT INTO traceability_records (
			id, tenant_id, farm_id, field_id, crop_id, batch_number,
			product_type, origin_country, origin_region, seed_source,
			planting_date, compliance_status,
			metadata, version, created_by, updated_by, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18)`,
		recordID, testTenantID, "farm-001", "field-001", "crop-001", "BATCH-2026-001",
		"Basmati Rice", "India", "Punjab", "National Seed Corp",
		now.Add(-90*24*time.Hour), "PENDING_REVIEW",
		meta, 1, testUserID, testUserID, now, now,
	)
	require.NoError(t, err, "insert traceability record")

	// Verify record.
	var gotBatch string
	err = conn.QueryRow(ctx, `SELECT batch_number FROM traceability_records WHERE id = $1`, recordID).Scan(&gotBatch)
	require.NoError(t, err)
	assert.Equal(t, "BATCH-2026-001", gotBatch)

	// 2. Add a supply chain event (note: tenant_id is set by trigger from parent).
	eventID := ulid.NewString()
	_, err = conn.Exec(ctx, `
		INSERT INTO supply_chain_events (id, tenant_id, record_id, event_type, event_timestamp, location, actor, details, verification_hash, created_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)`,
		eventID, testTenantID, recordID, "PLANTED", now.Add(-90*24*time.Hour),
		"Punjab, India", "Farmer Singh", "Planted Basmati in 5ha", "hash-planted-001", now,
	)
	require.NoError(t, err, "insert supply chain event")

	// Verify event.
	var eventType string
	err = conn.QueryRow(ctx,
		`SELECT event_type FROM supply_chain_events WHERE id = $1 AND record_id = $2`,
		eventID, recordID,
	).Scan(&eventType)
	require.NoError(t, err)
	assert.Equal(t, "PLANTED", eventType)

	// 3. Generate a QR code.
	qrID := ulid.NewString()
	qrData := fmt.Sprintf("https://trace.yieldpoint.in/%s", recordID)
	_, err = conn.Exec(ctx, `
		INSERT INTO qr_codes (id, tenant_id, record_id, qr_data, qr_image_url, scan_url, generated_at, is_active)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
		qrID, testTenantID, recordID, qrData,
		"https://cdn.yieldpoint.in/qr/"+recordID+".png",
		qrData, now, true,
	)
	require.NoError(t, err, "insert QR code")

	// 4. Verify the QR code.
	var gotQRData string
	var gotIsActive bool
	err = conn.QueryRow(ctx,
		`SELECT qr_data, is_active FROM qr_codes WHERE id = $1 AND record_id = $2`,
		qrID, recordID,
	).Scan(&gotQRData, &gotIsActive)
	require.NoError(t, err, "read QR code")
	assert.Equal(t, qrData, gotQRData, "QR data must match")
	assert.True(t, gotIsActive, "QR code must be active")

	t.Logf("TraceabilityFlow: record=%s event=%s qr=%s all verified", recordID, eventID, qrID)
}

// ---------------------------------------------------------------------------
// TestCommerceOrderFlow
// ---------------------------------------------------------------------------

func TestCommerceOrderFlow(t *testing.T) {
	require.NotNil(t, sharedPool, "shared pool must be initialized")
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	conn := acquireConn(t, ctx)
	now := time.Now()
	t.Cleanup(func() {
		cleanup(t, "orders", "marketplace_listings")
	})

	// 1. Create a marketplace listing.
	listingID := ulid.NewString()
	_, err := conn.Exec(ctx, `
		INSERT INTO marketplace_listings (
			id, tenant_id, farm_id, crop_id,
			product_name, product_type, description,
			quantity_available, quantity_unit, price_per_unit_paise, currency,
			status, version, created_by, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16)`,
		listingID, testTenantID, "farm-001", "crop-001",
		"Organic Basmati Rice", "RICE", stringPtr("Premium quality basmati"),
		1000.0, "kg", int64(15000), "INR",
		"LISTING_STATUS_ACTIVE", 1, testUserID, now, now,
	)
	require.NoError(t, err, "insert listing")

	// Verify listing.
	var listingStatus string
	err = conn.QueryRow(ctx,
		`SELECT status FROM marketplace_listings WHERE id = $1 AND tenant_id = $2`,
		listingID, testTenantID,
	).Scan(&listingStatus)
	require.NoError(t, err)
	assert.Equal(t, "LISTING_STATUS_ACTIVE", listingStatus)

	// 2. Place an order.
	orderID := ulid.NewString()
	buyerID := "01J0000000TEST000BUYER001"
	sellerID := testUserID
	qty := 100.0
	unitPrice := int64(15000)
	totalAmount := int64(float64(unitPrice) * qty)
	orderMeta, _ := json.Marshal(map[string]string{})

	_, err = conn.Exec(ctx, `
		INSERT INTO orders (
			id, tenant_id, listing_id, buyer_id, seller_id,
			quantity, quantity_unit, unit_price_paise, total_amount_paise, currency,
			status, payment_status,
			metadata, version, created_by, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17)`,
		orderID, testTenantID, listingID, buyerID, sellerID,
		qty, "kg", unitPrice, totalAmount, "INR",
		"ORDER_STATUS_PENDING", "PAYMENT_STATUS_PENDING",
		orderMeta, 1, buyerID, now, now,
	)
	require.NoError(t, err, "insert order")

	// Verify initial status.
	var orderStatus string
	err = conn.QueryRow(ctx,
		`SELECT status FROM orders WHERE id = $1 AND tenant_id = $2`,
		orderID, testTenantID,
	).Scan(&orderStatus)
	require.NoError(t, err)
	assert.Equal(t, "ORDER_STATUS_PENDING", orderStatus)

	// 3. Confirm order (transition: PENDING -> CONFIRMED).
	_, err = conn.Exec(ctx,
		`UPDATE orders SET status = $3, updated_by = $4, version = version + 1
		 WHERE id = $1 AND tenant_id = $2 AND deleted_at IS NULL`,
		orderID, testTenantID, "ORDER_STATUS_CONFIRMED", sellerID,
	)
	require.NoError(t, err, "confirm order")

	// 4. Verify status transitions.
	err = conn.QueryRow(ctx,
		`SELECT status FROM orders WHERE id = $1 AND tenant_id = $2`,
		orderID, testTenantID,
	).Scan(&orderStatus)
	require.NoError(t, err)
	assert.Equal(t, "ORDER_STATUS_CONFIRMED", orderStatus, "order must be confirmed")

	// Transition: CONFIRMED -> PROCESSING.
	_, err = conn.Exec(ctx,
		`UPDATE orders SET status = $3, updated_by = $4, version = version + 1
		 WHERE id = $1 AND tenant_id = $2 AND deleted_at IS NULL`,
		orderID, testTenantID, "ORDER_STATUS_PROCESSING", sellerID,
	)
	require.NoError(t, err, "process order")

	// Transition: PROCESSING -> SHIPPED.
	_, err = conn.Exec(ctx,
		`UPDATE orders SET status = $3, updated_by = $4, version = version + 1
		 WHERE id = $1 AND tenant_id = $2 AND deleted_at IS NULL`,
		orderID, testTenantID, "ORDER_STATUS_SHIPPED", sellerID,
	)
	require.NoError(t, err, "ship order")

	// Transition: SHIPPED -> DELIVERED.
	_, err = conn.Exec(ctx,
		`UPDATE orders SET status = $3, actual_delivery_date = $4, updated_by = $5, version = version + 1
		 WHERE id = $1 AND tenant_id = $2 AND deleted_at IS NULL`,
		orderID, testTenantID, "ORDER_STATUS_DELIVERED", now, buyerID,
	)
	require.NoError(t, err, "deliver order")

	// Final verification: status = DELIVERED, version incremented.
	var finalStatus string
	var finalVersion int64
	err = conn.QueryRow(ctx,
		`SELECT status, version FROM orders WHERE id = $1 AND tenant_id = $2`,
		orderID, testTenantID,
	).Scan(&finalStatus, &finalVersion)
	require.NoError(t, err)
	assert.Equal(t, "ORDER_STATUS_DELIVERED", finalStatus)
	assert.Equal(t, int64(5), finalVersion, "version should be 5 (1 initial + 4 updates)")

	t.Logf("CommerceOrderFlow: listing=%s order=%s final_status=%s version=%d",
		listingID, orderID, finalStatus, finalVersion)
}

// stringPtr is a helper to create a *string.
func stringPtr(s string) *string { return &s }
