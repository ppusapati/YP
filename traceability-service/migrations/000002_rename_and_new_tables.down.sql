-- ============================================================================
-- Traceability Service: Rename Tables to Match Adapter + New Tables (DOWN)
-- ============================================================================

-- ============================================================================
-- Drop: compliance_reports
-- ============================================================================
DROP TRIGGER IF EXISTS trg_compliance_reports_set_updated_at ON compliance_reports;
DROP FUNCTION IF EXISTS trg_compliance_reports_updated_at();
DROP TABLE IF EXISTS compliance_reports;

-- ============================================================================
-- Drop: qr_codes
-- ============================================================================
DROP TRIGGER IF EXISTS trg_qr_codes_set_updated_at ON qr_codes;
DROP FUNCTION IF EXISTS trg_qr_codes_updated_at();
DROP TRIGGER IF EXISTS trg_qr_codes_set_tenant_before_insert ON qr_codes;
DROP FUNCTION IF EXISTS trg_qr_codes_set_tenant();
DROP TABLE IF EXISTS qr_codes;

-- ============================================================================
-- Drop: batch_records
-- ============================================================================
DROP TRIGGER IF EXISTS trg_batch_records_set_updated_at ON batch_records;
DROP FUNCTION IF EXISTS trg_batch_records_updated_at();
DROP TABLE IF EXISTS batch_records;

-- ============================================================================
-- Drop: certifications
-- ============================================================================
DROP TRIGGER IF EXISTS trg_certifications_set_updated_at ON certifications;
DROP FUNCTION IF EXISTS trg_certifications_updated_at();
DROP TABLE IF EXISTS certifications;

-- ============================================================================
-- Un-rename: supply_chain_events -> trace_events (+ event_timestamp -> timestamp)
-- ============================================================================
DROP TRIGGER IF EXISTS trg_supply_chain_events_set_tenant_before_insert ON supply_chain_events;
DROP FUNCTION IF EXISTS trg_supply_chain_events_set_tenant();

ALTER TABLE supply_chain_events RENAME CONSTRAINT fk_supply_chain_events_record_id TO fk_trace_events_record_id;

ALTER INDEX idx_supply_chain_events_tenant_id RENAME TO idx_trace_events_tenant_id;
ALTER INDEX idx_supply_chain_events_record_id RENAME TO idx_trace_events_record_id;
ALTER INDEX idx_supply_chain_events_event_type RENAME TO idx_trace_events_event_type;
ALTER INDEX idx_supply_chain_events_event_timestamp RENAME TO idx_trace_events_timestamp;

ALTER POLICY supply_chain_events_select_policy ON supply_chain_events RENAME TO trace_events_select_policy;
ALTER POLICY supply_chain_events_insert_policy ON supply_chain_events RENAME TO trace_events_insert_policy;
ALTER POLICY supply_chain_events_update_policy ON supply_chain_events RENAME TO trace_events_update_policy;
ALTER POLICY supply_chain_events_delete_policy ON supply_chain_events RENAME TO trace_events_delete_policy;

ALTER TABLE supply_chain_events RENAME COLUMN event_timestamp TO "timestamp";
ALTER TABLE supply_chain_events RENAME TO trace_events;

-- ============================================================================
-- Un-rename: traceability_records -> trace_chains
-- ============================================================================
ALTER FUNCTION trg_traceability_records_updated_at() RENAME TO trg_trace_chains_updated_at;
ALTER TRIGGER trg_traceability_records_set_updated_at ON traceability_records RENAME TO trg_trace_chains_set_updated_at;

ALTER INDEX idx_traceability_records_tenant_id RENAME TO idx_trace_chains_tenant_id;
ALTER INDEX idx_traceability_records_farm_id RENAME TO idx_trace_chains_farm_id;
ALTER INDEX idx_traceability_records_crop_id RENAME TO idx_trace_chains_crop_id;
ALTER INDEX idx_traceability_records_batch_number RENAME TO idx_trace_chains_batch_number;
ALTER INDEX idx_traceability_records_product_type RENAME TO idx_trace_chains_product_type;
ALTER INDEX idx_traceability_records_compliance_status RENAME TO idx_trace_chains_compliance_status;
ALTER INDEX idx_traceability_records_origin_country RENAME TO idx_trace_chains_origin_country;
ALTER INDEX idx_traceability_records_blockchain_hash RENAME TO idx_trace_chains_blockchain_hash;
ALTER INDEX idx_traceability_records_created_at RENAME TO idx_trace_chains_created_at;

ALTER POLICY traceability_records_select_policy ON traceability_records RENAME TO trace_chains_select_policy;
ALTER POLICY traceability_records_insert_policy ON traceability_records RENAME TO trace_chains_insert_policy;
ALTER POLICY traceability_records_update_policy ON traceability_records RENAME TO trace_chains_update_policy;
ALTER POLICY traceability_records_delete_policy ON traceability_records RENAME TO trace_chains_delete_policy;

ALTER TABLE traceability_records RENAME TO trace_chains;
