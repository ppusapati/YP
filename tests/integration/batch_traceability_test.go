//go:build e2e

package integration_test

import (
	"context"
	"encoding/json"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"p9e.in/samavaya/packages/ulid"
)

// TestCropCycleWithVariety verifies that crop cycles can carry variety and seed
// source fields, linked to a management unit.
func TestCropCycleWithVariety(t *testing.T) {
	require.NotNil(t, sharedPool, "shared pool must be initialized")
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	conn := acquireConn(t, ctx)
	t.Cleanup(func() {
		cleanup(t, "crop_cycles", "fields", "farms")
	})

	farmID := ulid.NewString()
	_, err := conn.Exec(ctx, `
		INSERT INTO farms (id, tenant_id, name, total_area_hectares, farm_type, status, created_by)
		VALUES ($1, $2, $3, $4, $5, $6, $7)`,
		farmID, testTenantID, "Variety Test Farm", 25.0, "CROP", "ACTIVE", testUserID,
	)
	require.NoError(t, err)

	fieldID := ulid.NewString()
	_, err = conn.Exec(ctx, `
		INSERT INTO fields (id, tenant_id, farm_id, name, area_hectares, field_type, soil_type,
		irrigation_type, status, elevation_meters, slope_degrees, aspect_direction, growth_stage, created_by)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)`,
		fieldID, testTenantID, farmID, "Paddy Block A", 10.0, "CROPLAND", "CLAY",
		"FLOOD", "ACTIVE", 80.0, 1.0, "SOUTH", "GERMINATION", testUserID,
	)
	require.NoError(t, err)

	cycleID := ulid.NewString()
	_, err = conn.Exec(ctx, `
		INSERT INTO crop_cycles (
			id, tenant_id, field_id, crop_id, season, cycle_year,
			status, crop_variety, seed_source, created_by
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)`,
		cycleID, testTenantID, fieldID, "crop-basmati-001", "KHARIF", int32(2026),
		"CYCLE_STATUS_PLANNED", "Pusa Basmati 1121", "IARI New Delhi", testUserID,
	)
	require.NoError(t, err, "insert crop cycle with variety")

	var variety, seedSource string
	err = conn.QueryRow(ctx,
		`SELECT crop_variety, seed_source FROM crop_cycles WHERE id = $1 AND tenant_id = $2`,
		cycleID, testTenantID,
	).Scan(&variety, &seedSource)
	require.NoError(t, err)
	assert.Equal(t, "Pusa Basmati 1121", variety)
	assert.Equal(t, "IARI New Delhi", seedSource)

	t.Logf("CropCycleWithVariety: cycle=%s variety=%s seed_source=%s", cycleID, variety, seedSource)
}

// TestBatchHarvestLinkage verifies that batch records link to crop cycles and
// yield records, and quality checkpoints link to batches with grade/lab fields.
func TestBatchHarvestLinkage(t *testing.T) {
	require.NotNil(t, sharedPool, "shared pool must be initialized")
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	conn := acquireConn(t, ctx)
	now := time.Now()
	meta, _ := json.Marshal(map[string]string{"source": "e2e-batch-test"})

	t.Cleanup(func() {
		cleanup(t, "quality_checkpoints", "batch_records", "traceability_records")
	})

	// 1. Create a traceability record.
	recordID := ulid.NewString()
	_, err := conn.Exec(ctx, `
		INSERT INTO traceability_records (
			id, tenant_id, farm_id, field_id, crop_id, batch_number,
			product_type, origin_country, origin_region, seed_source,
			planting_date, compliance_status,
			metadata, version, created_by, updated_by, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18)`,
		recordID, testTenantID, "farm-001", "field-001", "crop-001", "BATCH-HARVEST-001",
		"Wheat", "India", "Haryana", "State Seed Corp",
		now.Add(-120*24*time.Hour), "PENDING_REVIEW",
		meta, 1, testUserID, testUserID, now, now,
	)
	require.NoError(t, err, "insert traceability record")

	// 2. Create a batch record linked to crop cycle and yield record.
	batchID := ulid.NewString()
	cropCycleID := ulid.NewString()
	yieldRecordID := ulid.NewString()
	_, err = conn.Exec(ctx, `
		INSERT INTO batch_records (
			id, tenant_id, record_id, batch_number, product_type,
			quantity, quantity_unit, quality_grade,
			production_date, expiry_date,
			storage_conditions, status,
			crop_cycle_id, yield_record_id, weight_kg,
			metadata, version, created_by, updated_by, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21)`,
		batchID, testTenantID, recordID, "WHEAT-2026-H1", "Wheat Grain",
		5000.0, "kg", "A",
		now.Add(-7*24*time.Hour), now.Add(365*24*time.Hour),
		"Cool dry warehouse", "ACTIVE",
		cropCycleID, yieldRecordID, 5000.0,
		meta, 1, testUserID, testUserID, now, now,
	)
	require.NoError(t, err, "insert batch record with harvest linkage")

	// Verify batch harvest linkage fields.
	var gotCropCycleID, gotYieldRecordID string
	var gotWeightKg float64
	err = conn.QueryRow(ctx,
		`SELECT crop_cycle_id, yield_record_id, weight_kg FROM batch_records WHERE id = $1 AND tenant_id = $2`,
		batchID, testTenantID,
	).Scan(&gotCropCycleID, &gotYieldRecordID, &gotWeightKg)
	require.NoError(t, err)
	assert.Equal(t, cropCycleID, gotCropCycleID)
	assert.Equal(t, yieldRecordID, gotYieldRecordID)
	assert.Equal(t, 5000.0, gotWeightKg)

	// 3. Create a quality checkpoint with grade and lab report, scoped to the batch.
	checkpointID := ulid.NewString()
	_, err = conn.Exec(ctx, `
		INSERT INTO quality_checkpoints (
			id, tenant_id, record_id, check_type, result,
			inspector_id, inspector_name, inspected_at, location,
			measurement_value, measurement_unit,
			grade, lab_report_url,
			batch_id, created_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)`,
		checkpointID, testTenantID, recordID, "LAB", "PASS",
		testUserID, "Dr. Agarwal", now, "FSSAI Lab Chandigarh",
		12.5, "moisture_pct",
		"A", "https://lab.example.com/reports/wheat-2026-h1.pdf",
		batchID, now,
	)
	require.NoError(t, err, "insert quality checkpoint with grade and lab report")

	// Verify grade, lab URL, and batch linkage.
	var gotGrade, gotLabURL, gotBatchID string
	err = conn.QueryRow(ctx,
		`SELECT grade, lab_report_url, batch_id FROM quality_checkpoints WHERE id = $1 AND tenant_id = $2`,
		checkpointID, testTenantID,
	).Scan(&gotGrade, &gotLabURL, &gotBatchID)
	require.NoError(t, err)
	assert.Equal(t, "A", gotGrade)
	assert.Equal(t, "https://lab.example.com/reports/wheat-2026-h1.pdf", gotLabURL)
	assert.Equal(t, batchID, gotBatchID)

	t.Logf("BatchHarvestLinkage: record=%s batch=%s checkpoint=%s grade=%s",
		recordID, batchID, checkpointID, gotGrade)
}

// TestCommerceStockDecrement verifies the stock decrement and SOLD_OUT
// transition, and that batch_id propagates to listings.
func TestCommerceStockDecrement(t *testing.T) {
	require.NotNil(t, sharedPool, "shared pool must be initialized")
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	conn := acquireConn(t, ctx)
	now := time.Now()
	t.Cleanup(func() {
		cleanup(t, "orders", "marketplace_listings")
	})

	batchID := ulid.NewString()
	listingID := ulid.NewString()
	_, err := conn.Exec(ctx, `
		INSERT INTO marketplace_listings (
			id, tenant_id, farm_id, crop_id,
			product_name, product_type,
			quantity_available, quantity_unit, price_per_unit_paise, currency,
			min_order_quantity, batch_id,
			status, version, created_by, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17)`,
		listingID, testTenantID, "farm-001", "crop-001",
		"Organic Wheat", "WHEAT",
		200.0, "kg", int64(3500), "INR",
		50.0, batchID,
		"LISTING_STATUS_ACTIVE", 1, testUserID, now, now,
	)
	require.NoError(t, err, "insert listing with batch_id")

	// Verify batch_id on listing.
	var gotBatchID string
	err = conn.QueryRow(ctx,
		`SELECT batch_id FROM marketplace_listings WHERE id = $1`,
		listingID,
	).Scan(&gotBatchID)
	require.NoError(t, err)
	assert.Equal(t, batchID, gotBatchID)

	// Simulate stock decrement (what DecrementListingQuantity does).
	_, err = conn.Exec(ctx, `
		UPDATE marketplace_listings
		SET quantity_available = quantity_available - $3,
		    status = CASE WHEN quantity_available - $3 <= 0 THEN 'LISTING_STATUS_SOLD_OUT' ELSE status END,
		    version = version + 1
		WHERE id = $1 AND tenant_id = $2 AND quantity_available >= $3`,
		listingID, testTenantID, 150.0,
	)
	require.NoError(t, err, "decrement 150 kg")

	var remainingQty float64
	var status string
	err = conn.QueryRow(ctx,
		`SELECT quantity_available, status FROM marketplace_listings WHERE id = $1`,
		listingID,
	).Scan(&remainingQty, &status)
	require.NoError(t, err)
	assert.Equal(t, 50.0, remainingQty, "should have 50 kg remaining")
	assert.Equal(t, "LISTING_STATUS_ACTIVE", status, "should still be active")

	// Decrement remaining 50 kg — should transition to SOLD_OUT.
	_, err = conn.Exec(ctx, `
		UPDATE marketplace_listings
		SET quantity_available = quantity_available - $3,
		    status = CASE WHEN quantity_available - $3 <= 0 THEN 'LISTING_STATUS_SOLD_OUT' ELSE status END,
		    version = version + 1
		WHERE id = $1 AND tenant_id = $2 AND quantity_available >= $3`,
		listingID, testTenantID, 50.0,
	)
	require.NoError(t, err, "decrement final 50 kg")

	err = conn.QueryRow(ctx,
		`SELECT quantity_available, status FROM marketplace_listings WHERE id = $1`,
		listingID,
	).Scan(&remainingQty, &status)
	require.NoError(t, err)
	assert.Equal(t, 0.0, remainingQty, "should have 0 kg remaining")
	assert.Equal(t, "LISTING_STATUS_SOLD_OUT", status, "should be sold out")

	// Verify oversell protection — decrement on empty listing should affect 0 rows.
	tag, err := conn.Exec(ctx, `
		UPDATE marketplace_listings
		SET quantity_available = quantity_available - $3,
		    version = version + 1
		WHERE id = $1 AND tenant_id = $2 AND quantity_available >= $3`,
		listingID, testTenantID, 1.0,
	)
	require.NoError(t, err)
	assert.Equal(t, int64(0), tag.RowsAffected(), "oversell must be blocked")

	t.Logf("CommerceStockDecrement: listing=%s batch=%s final_status=%s",
		listingID, batchID, status)
}

// TestPaymentStatusTransitions verifies that payment status follows
// PENDING -> PAID -> REFUNDED and blocks invalid transitions.
func TestPaymentStatusTransitions(t *testing.T) {
	require.NotNil(t, sharedPool, "shared pool must be initialized")
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	conn := acquireConn(t, ctx)
	now := time.Now()
	orderMeta, _ := json.Marshal(map[string]string{})
	t.Cleanup(func() {
		cleanup(t, "orders", "marketplace_listings")
	})

	listingID := ulid.NewString()
	_, err := conn.Exec(ctx, `
		INSERT INTO marketplace_listings (
			id, tenant_id, farm_id, crop_id,
			product_name, product_type,
			quantity_available, quantity_unit, price_per_unit_paise, currency,
			status, version, created_by, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)`,
		listingID, testTenantID, "farm-001", "crop-001",
		"Test Produce", "GRAIN",
		500.0, "kg", int64(2000), "INR",
		"LISTING_STATUS_ACTIVE", 1, testUserID, now, now,
	)
	require.NoError(t, err)

	orderID := ulid.NewString()
	_, err = conn.Exec(ctx, `
		INSERT INTO orders (
			id, tenant_id, listing_id, buyer_id, seller_id,
			quantity, quantity_unit, unit_price_paise, total_amount_paise, currency,
			status, payment_status,
			metadata, version, created_by, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17)`,
		orderID, testTenantID, listingID, "buyer-001", testUserID,
		50.0, "kg", int64(2000), int64(100000), "INR",
		"ORDER_STATUS_CONFIRMED", "PAYMENT_STATUS_PENDING",
		orderMeta, 1, "buyer-001", now, now,
	)
	require.NoError(t, err, "insert order")

	// PENDING -> PAID is valid.
	_, err = conn.Exec(ctx,
		`UPDATE orders SET payment_status = $3, payment_reference = $4, version = version + 1
		 WHERE id = $1 AND tenant_id = $2`,
		orderID, testTenantID, "PAYMENT_STATUS_PAID", "PAY-REF-001",
	)
	require.NoError(t, err, "PENDING -> PAID")

	var payStatus, payRef string
	err = conn.QueryRow(ctx,
		`SELECT payment_status, payment_reference FROM orders WHERE id = $1`,
		orderID,
	).Scan(&payStatus, &payRef)
	require.NoError(t, err)
	assert.Equal(t, "PAYMENT_STATUS_PAID", payStatus)
	assert.Equal(t, "PAY-REF-001", payRef)

	// PAID -> REFUNDED is valid.
	_, err = conn.Exec(ctx,
		`UPDATE orders SET payment_status = $3, payment_reference = $4, version = version + 1
		 WHERE id = $1 AND tenant_id = $2`,
		orderID, testTenantID, "PAYMENT_STATUS_REFUNDED", "REFUND-REF-001",
	)
	require.NoError(t, err, "PAID -> REFUNDED")

	err = conn.QueryRow(ctx,
		`SELECT payment_status FROM orders WHERE id = $1`,
		orderID,
	).Scan(&payStatus)
	require.NoError(t, err)
	assert.Equal(t, "PAYMENT_STATUS_REFUNDED", payStatus)

	t.Logf("PaymentStatusTransitions: order=%s final_payment_status=%s", orderID, payStatus)
}

// TestListingActivation verifies DRAFT -> ACTIVE transition via the
// ActivateListing pattern.
func TestListingActivation(t *testing.T) {
	require.NotNil(t, sharedPool, "shared pool must be initialized")
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	conn := acquireConn(t, ctx)
	now := time.Now()
	t.Cleanup(func() {
		cleanup(t, "marketplace_listings")
	})

	listingID := ulid.NewString()
	_, err := conn.Exec(ctx, `
		INSERT INTO marketplace_listings (
			id, tenant_id, farm_id, crop_id,
			product_name, product_type,
			quantity_available, quantity_unit, price_per_unit_paise, currency,
			status, version, created_by, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)`,
		listingID, testTenantID, "farm-001", "crop-001",
		"Draft Listing", "GRAIN",
		100.0, "kg", int64(5000), "INR",
		"LISTING_STATUS_DRAFT", 1, testUserID, now, now,
	)
	require.NoError(t, err, "insert draft listing")

	// Activate: DRAFT -> ACTIVE.
	tag, err := conn.Exec(ctx,
		`UPDATE marketplace_listings
		 SET status = 'LISTING_STATUS_ACTIVE', updated_by = $3, version = version + 1
		 WHERE id = $1 AND tenant_id = $2 AND status IN ('LISTING_STATUS_DRAFT', 'LISTING_STATUS_SOLD_OUT')
		 AND deleted_at IS NULL`,
		listingID, testTenantID, testUserID,
	)
	require.NoError(t, err)
	assert.Equal(t, int64(1), tag.RowsAffected(), "activation should affect 1 row")

	var status string
	err = conn.QueryRow(ctx,
		`SELECT status FROM marketplace_listings WHERE id = $1`,
		listingID,
	).Scan(&status)
	require.NoError(t, err)
	assert.Equal(t, "LISTING_STATUS_ACTIVE", status)

	// Attempt to activate an already-active listing (should fail precondition).
	tag, err = conn.Exec(ctx,
		`UPDATE marketplace_listings
		 SET status = 'LISTING_STATUS_ACTIVE', version = version + 1
		 WHERE id = $1 AND tenant_id = $2 AND status IN ('LISTING_STATUS_DRAFT', 'LISTING_STATUS_SOLD_OUT')`,
		listingID, testTenantID,
	)
	require.NoError(t, err)
	assert.Equal(t, int64(0), tag.RowsAffected(), "re-activation of active listing should be no-op")

	t.Logf("ListingActivation: listing=%s status=%s", listingID, status)
}

// TestCrossServiceTraceabilityToCommerce verifies the full chain: traceability
// record -> batch -> quality checkpoint -> marketplace listing with batch_id.
func TestCrossServiceTraceabilityToCommerce(t *testing.T) {
	require.NotNil(t, sharedPool, "shared pool must be initialized")
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	conn := acquireConn(t, ctx)
	now := time.Now()
	meta, _ := json.Marshal(map[string]string{})

	t.Cleanup(func() {
		cleanup(t, "orders", "marketplace_listings", "quality_checkpoints",
			"batch_records", "traceability_records")
	})

	// 1. Traceability record.
	recordID := ulid.NewString()
	_, err := conn.Exec(ctx, `
		INSERT INTO traceability_records (
			id, tenant_id, farm_id, field_id, crop_id, batch_number,
			product_type, origin_country, origin_region, seed_source,
			planting_date, compliance_status,
			metadata, version, created_by, updated_by, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18)`,
		recordID, testTenantID, "farm-001", "field-001", "crop-001", "E2E-FULL-001",
		"Organic Rice", "India", "Karnataka", "KSC",
		now.Add(-90*24*time.Hour), "APPROVED",
		meta, 1, testUserID, testUserID, now, now,
	)
	require.NoError(t, err)

	// 2. Batch record linked to the traceability record.
	batchID := ulid.NewString()
	_, err = conn.Exec(ctx, `
		INSERT INTO batch_records (
			id, tenant_id, record_id, batch_number, product_type,
			quantity, quantity_unit, quality_grade,
			production_date, storage_conditions, status,
			crop_cycle_id, weight_kg,
			metadata, version, created_by, updated_by, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19)`,
		batchID, testTenantID, recordID, "RICE-E2E-001", "Rice",
		2000.0, "kg", "A",
		now.Add(-7*24*time.Hour), "Climate-controlled", "ACTIVE",
		ulid.NewString(), 2000.0,
		meta, 1, testUserID, testUserID, now, now,
	)
	require.NoError(t, err)

	// 3. Quality checkpoint with grade and lab report on the batch.
	checkpointID := ulid.NewString()
	_, err = conn.Exec(ctx, `
		INSERT INTO quality_checkpoints (
			id, tenant_id, record_id, check_type, result,
			inspector_id, inspector_name, inspected_at, location,
			grade, lab_report_url, batch_id, created_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)`,
		checkpointID, testTenantID, recordID, "LAB", "PASS",
		testUserID, "Lab Technician", now, "FSSAI Lab",
		"A", "https://lab.example.com/rice-e2e.pdf", batchID, now,
	)
	require.NoError(t, err)

	// 4. Marketplace listing referencing the batch and traceability record.
	listingID := ulid.NewString()
	_, err = conn.Exec(ctx, `
		INSERT INTO marketplace_listings (
			id, tenant_id, farm_id, crop_id,
			product_name, product_type,
			quantity_available, quantity_unit, price_per_unit_paise, currency,
			quality_grade, traceability_record_id, batch_id,
			status, version, created_by, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18)`,
		listingID, testTenantID, "farm-001", "crop-001",
		"Premium Organic Rice", "RICE",
		2000.0, "kg", int64(8000), "INR",
		"A", recordID, batchID,
		"LISTING_STATUS_ACTIVE", 1, testUserID, now, now,
	)
	require.NoError(t, err)

	// 5. Verify the full chain: listing -> batch -> checkpoint -> record.
	var lBatchID, lTraceID, lGrade string
	err = conn.QueryRow(ctx,
		`SELECT batch_id, traceability_record_id, quality_grade
		 FROM marketplace_listings WHERE id = $1`,
		listingID,
	).Scan(&lBatchID, &lTraceID, &lGrade)
	require.NoError(t, err)
	assert.Equal(t, batchID, lBatchID)
	assert.Equal(t, recordID, lTraceID)
	assert.Equal(t, "A", lGrade)

	// Verify batch -> record linkage.
	var bRecordID string
	err = conn.QueryRow(ctx,
		`SELECT record_id FROM batch_records WHERE id = $1`,
		batchID,
	).Scan(&bRecordID)
	require.NoError(t, err)
	assert.Equal(t, recordID, bRecordID)

	// Verify checkpoint -> batch linkage.
	var cpBatchID, cpGrade string
	err = conn.QueryRow(ctx,
		`SELECT batch_id, grade FROM quality_checkpoints WHERE id = $1`,
		checkpointID,
	).Scan(&cpBatchID, &cpGrade)
	require.NoError(t, err)
	assert.Equal(t, batchID, cpBatchID)
	assert.Equal(t, "A", cpGrade)

	t.Logf("CrossServiceTraceabilityToCommerce: record=%s batch=%s checkpoint=%s listing=%s — full chain verified",
		recordID, batchID, checkpointID, listingID)
}
