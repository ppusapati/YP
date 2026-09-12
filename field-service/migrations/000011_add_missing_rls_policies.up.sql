-- ============================================================================
-- Field Service: Add missing UPDATE policy on activity_evidence
-- ============================================================================

CREATE POLICY activity_evidence_update_policy ON activity_evidence
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );
