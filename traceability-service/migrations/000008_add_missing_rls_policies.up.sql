-- ============================================================================
-- Traceability Service: Add missing UPDATE policy on quality_checkpoints
-- ============================================================================

CREATE POLICY quality_checkpoints_update_policy ON quality_checkpoints
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );
