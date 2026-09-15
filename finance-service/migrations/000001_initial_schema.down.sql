-- ============================================================================
-- Finance Service: Initial Schema Migration (DOWN)
-- ============================================================================

DROP POLICY IF EXISTS claims_tenant_policy ON claims;
DROP POLICY IF EXISTS credit_assessments_tenant_policy ON credit_assessments;
DROP POLICY IF EXISTS insurance_quotes_tenant_policy ON insurance_quotes;

DROP INDEX IF EXISTS idx_claims_quote;
DROP INDEX IF EXISTS idx_claims_farm;
DROP INDEX IF EXISTS idx_claims_field;
DROP TABLE IF EXISTS claims;

DROP INDEX IF EXISTS idx_credit_farm;
DROP TABLE IF EXISTS credit_assessments;

DROP INDEX IF EXISTS idx_quotes_farm;
DROP INDEX IF EXISTS idx_quotes_field;
DROP TABLE IF EXISTS insurance_quotes;
