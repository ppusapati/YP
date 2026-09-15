-- ============================================================================
-- Farm Service: Add missing UPDATE policy on management_unit_fields
-- ============================================================================

CREATE POLICY management_unit_fields_update_policy ON management_unit_fields
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );
