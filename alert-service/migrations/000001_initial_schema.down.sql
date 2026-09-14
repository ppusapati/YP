-- ============================================================================
-- Alert Service: Initial Schema (DOWN)
--
-- Dropped in reverse dependency order. The policies and indexes go with their
-- tables; naming them separately would only add ways for this to half-apply.
-- ============================================================================

DROP TABLE IF EXISTS field_risk_scores;
DROP TABLE IF EXISTS alert_rules;
DROP TABLE IF EXISTS alerts;
