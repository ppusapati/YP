-- Commerce service initial schema: marketplace listings and orders.

-- ============================================================================
-- Table: marketplace_listings
-- ============================================================================

CREATE TABLE IF NOT EXISTS marketplace_listings (
    id                      CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id               CHAR(26)        NOT NULL,
    farm_id                 CHAR(26)        NOT NULL,
    crop_id                 CHAR(26)        NOT NULL,

    -- product details
    product_name            TEXT            NOT NULL,
    product_type            TEXT            NOT NULL,
    description             TEXT,
    quantity_available       DOUBLE PRECISION NOT NULL DEFAULT 0,
    quantity_unit            TEXT            NOT NULL DEFAULT 'kg',
    price_per_unit_paise    BIGINT          NOT NULL DEFAULT 0,
    currency                TEXT            NOT NULL DEFAULT 'INR',
    min_order_quantity       DOUBLE PRECISION,
    quality_grade            TEXT,
    traceability_record_id   CHAR(26),

    -- status
    status                  TEXT            NOT NULL DEFAULT 'LISTING_STATUS_DRAFT',

    -- location
    location                TEXT,
    region                  TEXT,

    -- media
    image_urls              TEXT[]          DEFAULT '{}',

    -- availability window
    available_from          TIMESTAMPTZ,
    available_to            TIMESTAMPTZ,

    -- audit
    version                 BIGINT          NOT NULL DEFAULT 1,
    is_active               BOOLEAN         NOT NULL DEFAULT TRUE,
    created_by              CHAR(26)        NOT NULL,
    updated_by              CHAR(26),
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_by              CHAR(26),
    deleted_at              TIMESTAMPTZ
);

-- RLS
ALTER TABLE marketplace_listings ENABLE ROW LEVEL SECURITY;
ALTER TABLE marketplace_listings FORCE ROW LEVEL SECURITY;

CREATE POLICY marketplace_listings_select_policy ON marketplace_listings
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY marketplace_listings_insert_policy ON marketplace_listings
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY marketplace_listings_update_policy ON marketplace_listings
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY marketplace_listings_delete_policy ON marketplace_listings
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_marketplace_listings_tenant ON marketplace_listings (tenant_id);
CREATE INDEX idx_marketplace_listings_farm ON marketplace_listings (tenant_id, farm_id);
CREATE INDEX idx_marketplace_listings_status ON marketplace_listings (tenant_id, status) WHERE deleted_at IS NULL;
CREATE INDEX idx_marketplace_listings_product_type ON marketplace_listings (tenant_id, product_type) WHERE deleted_at IS NULL;
CREATE INDEX idx_marketplace_listings_region ON marketplace_listings (tenant_id, region) WHERE deleted_at IS NULL AND region IS NOT NULL;
CREATE INDEX idx_marketplace_listings_created ON marketplace_listings (tenant_id, created_at DESC);

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION trg_marketplace_listings_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_marketplace_listings_updated_at
    BEFORE UPDATE ON marketplace_listings
    FOR EACH ROW
    EXECUTE FUNCTION trg_marketplace_listings_updated_at();

-- ============================================================================
-- Table: orders
-- ============================================================================

CREATE TABLE IF NOT EXISTS orders (
    id                      CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id               CHAR(26)        NOT NULL,
    listing_id              CHAR(26)        NOT NULL REFERENCES marketplace_listings(id),
    buyer_id                CHAR(26)        NOT NULL,
    seller_id               CHAR(26)        NOT NULL,

    -- line item
    quantity                DOUBLE PRECISION NOT NULL,
    quantity_unit            TEXT            NOT NULL,
    unit_price_paise        BIGINT          NOT NULL,
    total_amount_paise      BIGINT          NOT NULL,
    currency                TEXT            NOT NULL DEFAULT 'INR',

    -- status
    status                  TEXT            NOT NULL DEFAULT 'ORDER_STATUS_PENDING',
    payment_status          TEXT            NOT NULL DEFAULT 'PAYMENT_STATUS_PENDING',
    payment_reference       TEXT,

    -- delivery
    delivery_method         TEXT,
    delivery_address        TEXT,
    delivery_notes          TEXT,
    estimated_delivery_date TIMESTAMPTZ,
    actual_delivery_date    TIMESTAMPTZ,

    -- notes & metadata
    notes                   TEXT,
    metadata                JSONB           DEFAULT '{}',

    -- audit
    version                 BIGINT          NOT NULL DEFAULT 1,
    is_active               BOOLEAN         NOT NULL DEFAULT TRUE,
    created_by              CHAR(26)        NOT NULL,
    updated_by              CHAR(26),
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_by              CHAR(26),
    deleted_at              TIMESTAMPTZ
);

-- RLS
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders FORCE ROW LEVEL SECURITY;

CREATE POLICY orders_select_policy ON orders
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY orders_insert_policy ON orders
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY orders_update_policy ON orders
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

-- Indexes
CREATE INDEX idx_orders_tenant ON orders (tenant_id);
CREATE INDEX idx_orders_listing ON orders (tenant_id, listing_id);
CREATE INDEX idx_orders_buyer ON orders (tenant_id, buyer_id);
CREATE INDEX idx_orders_seller ON orders (tenant_id, seller_id);
CREATE INDEX idx_orders_status ON orders (tenant_id, status) WHERE deleted_at IS NULL;
CREATE INDEX idx_orders_created ON orders (tenant_id, created_at DESC);

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION trg_orders_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_orders_updated_at
    BEFORE UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION trg_orders_updated_at();
