-- Deduplicate any existing duplicate boundaries, keeping the most recent.
DELETE FROM field_boundaries a
USING field_boundaries b
WHERE a.tenant_id = b.tenant_id
  AND a.field_id  = b.field_id
  AND a.created_at < b.created_at;

-- One active boundary per tenant+field.
CREATE UNIQUE INDEX IF NOT EXISTS uq_field_boundaries_tenant_field
    ON field_boundaries (tenant_id, field_id)
    WHERE deleted_at IS NULL;
