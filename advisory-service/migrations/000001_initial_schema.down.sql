-- ============================================================================
-- Advisory Service: Initial Schema Migration (DOWN)
-- ============================================================================

DROP POLICY IF EXISTS advisory_budgets_tenant_policy      ON advisory_budgets;
DROP POLICY IF EXISTS advisory_exchanges_tenant_policy     ON advisory_exchanges;
DROP POLICY IF EXISTS advisory_conversations_tenant_policy ON advisory_conversations;
DROP POLICY IF EXISTS advisory_chunks_tenant_policy        ON advisory_chunks;
DROP POLICY IF EXISTS advisory_documents_tenant_policy     ON advisory_documents;

DROP TABLE IF EXISTS advisory_budgets;
DROP TABLE IF EXISTS advisory_exchanges;
DROP TABLE IF EXISTS advisory_conversations;
DROP TABLE IF EXISTS advisory_chunks;
DROP TABLE IF EXISTS advisory_documents;

-- The extensions are left in place. Dropping vector would take with it any
-- other schema in the database that uses it, which is not this migration's to
-- decide.
