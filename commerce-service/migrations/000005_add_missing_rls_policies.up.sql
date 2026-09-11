-- ============================================================================
-- Commerce Service: Add missing DELETE policy on orders
-- ============================================================================

CREATE POLICY orders_delete_policy ON orders
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );
