-- ============================================================================
-- Traceability Service: Drop UPDATE policy on quality_checkpoints
-- ============================================================================

DROP POLICY IF EXISTS quality_checkpoints_update_policy ON quality_checkpoints;
