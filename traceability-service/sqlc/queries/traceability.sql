-- name: CreateTraceabilityRecord :one
INSERT INTO traceability_records (
    id, tenant_id, farm_id, field_id, crop_id, batch_number,
    product_type, origin_country, origin_region, seed_source,
    planting_date, harvest_date, processing_date, packaging_date,
    qr_code_data, blockchain_hash, chain_of_custody, compliance_status,
    metadata, version, created_by, updated_by, created_at, updated_at
) VALUES (
    $1, $2, $3, $4, $5, $6,
    $7, $8, $9, $10,
    $11, $12, $13, $14,
    $15, $16, $17, $18,
    $19, $20, $21, $22, $23, $24
) RETURNING *;

-- name: GetTraceabilityRecord :one
SELECT * FROM traceability_records
WHERE id = $1 AND tenant_id = $2;

-- name: ListTraceabilityRecords :many
SELECT * FROM traceability_records
WHERE tenant_id = $1
  AND (sqlc.narg('farm_id')::TEXT IS NULL OR farm_id = sqlc.narg('farm_id'))
  AND (sqlc.narg('crop_id')::TEXT IS NULL OR crop_id = sqlc.narg('crop_id'))
  AND (sqlc.narg('product_type')::TEXT IS NULL OR product_type = sqlc.narg('product_type'))
  AND (sqlc.narg('origin_country')::TEXT IS NULL OR origin_country = sqlc.narg('origin_country'))
  AND (sqlc.narg('compliance_status')::TEXT IS NULL OR compliance_status = sqlc.narg('compliance_status'))
  AND (sqlc.narg('search')::TEXT IS NULL OR (
      batch_number ILIKE '%' || sqlc.narg('search') || '%'
      OR product_type ILIKE '%' || sqlc.narg('search') || '%'
      OR origin_region ILIKE '%' || sqlc.narg('search') || '%'
  ))
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;

-- name: CountTraceabilityRecords :one
SELECT COUNT(*) FROM traceability_records
WHERE tenant_id = $1
  AND (sqlc.narg('farm_id')::TEXT IS NULL OR farm_id = sqlc.narg('farm_id'))
  AND (sqlc.narg('crop_id')::TEXT IS NULL OR crop_id = sqlc.narg('crop_id'))
  AND (sqlc.narg('product_type')::TEXT IS NULL OR product_type = sqlc.narg('product_type'))
  AND (sqlc.narg('origin_country')::TEXT IS NULL OR origin_country = sqlc.narg('origin_country'))
  AND (sqlc.narg('compliance_status')::TEXT IS NULL OR compliance_status = sqlc.narg('compliance_status'))
  AND (sqlc.narg('search')::TEXT IS NULL OR (
      batch_number ILIKE '%' || sqlc.narg('search') || '%'
      OR product_type ILIKE '%' || sqlc.narg('search') || '%'
      OR origin_region ILIKE '%' || sqlc.narg('search') || '%'
  ));

-- name: UpdateTraceabilityRecordCompliance :one
UPDATE traceability_records
SET compliance_status = $3, updated_by = $4, updated_at = NOW(), version = version + 1
WHERE id = $1 AND tenant_id = $2
RETURNING *;

-- name: UpdateTraceabilityRecordQR :one
UPDATE traceability_records
SET qr_code_data = $3, updated_by = $4, updated_at = NOW(), version = version + 1
WHERE id = $1 AND tenant_id = $2
RETURNING *;

-- name: UpdateTraceabilityRecordBlockchain :one
UPDATE traceability_records
SET blockchain_hash = $3, updated_by = $4, updated_at = NOW(), version = version + 1
WHERE id = $1 AND tenant_id = $2
RETURNING *;

-- name: AppendChainOfCustody :one
UPDATE traceability_records
SET chain_of_custody = array_append(chain_of_custody, $3),
    updated_by = $4, updated_at = NOW(), version = version + 1
WHERE id = $1 AND tenant_id = $2
RETURNING *;

-- name: CreateSupplyChainEvent :one
INSERT INTO supply_chain_events (
    id, record_id, event_type, event_timestamp, location, actor, details, verification_hash, created_at
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9
) RETURNING *;

-- name: GetSupplyChainEventsByRecord :many
SELECT * FROM supply_chain_events
WHERE record_id = $1
ORDER BY event_timestamp ASC;

-- name: GetSupplyChainEvent :one
SELECT * FROM supply_chain_events
WHERE id = $1;

-- name: CreateCertification :one
INSERT INTO certifications (
    id, tenant_id, record_id, cert_type, cert_number, issued_by,
    issued_date, expiry_date, status, verified_by, verified_at,
    metadata, version, created_at, updated_at
) VALUES (
    $1, $2, $3, $4, $5, $6,
    $7, $8, $9, $10, $11,
    $12, $13, $14, $15
) RETURNING *;

-- name: GetCertification :one
SELECT * FROM certifications
WHERE id = $1 AND tenant_id = $2;

-- name: ListCertifications :many
SELECT * FROM certifications
WHERE tenant_id = $1
  AND (sqlc.narg('record_id')::TEXT IS NULL OR record_id = sqlc.narg('record_id'))
  AND (sqlc.narg('cert_type')::TEXT IS NULL OR cert_type = sqlc.narg('cert_type'))
  AND (sqlc.narg('status')::TEXT IS NULL OR status = sqlc.narg('status'))
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;

-- name: CountCertifications :one
SELECT COUNT(*) FROM certifications
WHERE tenant_id = $1
  AND (sqlc.narg('record_id')::TEXT IS NULL OR record_id = sqlc.narg('record_id'))
  AND (sqlc.narg('cert_type')::TEXT IS NULL OR cert_type = sqlc.narg('cert_type'))
  AND (sqlc.narg('status')::TEXT IS NULL OR status = sqlc.narg('status'));

-- name: UpdateCertificationStatus :one
UPDATE certifications
SET status = $3, updated_at = NOW(), version = version + 1
WHERE id = $1 AND tenant_id = $2
RETURNING *;

-- name: VerifyCertification :one
UPDATE certifications
SET status = 'ACTIVE', verified_by = $3, verified_at = NOW(), updated_at = NOW(), version = version + 1
WHERE id = $1 AND tenant_id = $2
RETURNING *;

-- name: GetCertificationsByRecord :many
SELECT * FROM certifications
WHERE record_id = $1 AND tenant_id = $2
ORDER BY created_at DESC;

-- name: GetActiveCertificationsByRecord :many
SELECT * FROM certifications
WHERE record_id = $1 AND tenant_id = $2 AND status = 'ACTIVE'
ORDER BY created_at DESC;

-- name: CreateBatchRecord :one
INSERT INTO batch_records (
    id, tenant_id, record_id, batch_number, quantity, unit,
    production_date, expiry_date, storage_conditions, quality_grade,
    metadata, version, created_at, updated_at
) VALUES (
    $1, $2, $3, $4, $5, $6,
    $7, $8, $9, $10,
    $11, $12, $13, $14
) RETURNING *;

-- name: GetBatchRecord :one
SELECT * FROM batch_records
WHERE id = $1 AND tenant_id = $2;

-- name: ListBatchRecords :many
SELECT * FROM batch_records
WHERE tenant_id = $1
  AND (sqlc.narg('record_id')::TEXT IS NULL OR record_id = sqlc.narg('record_id'))
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;

-- name: CountBatchRecords :one
SELECT COUNT(*) FROM batch_records
WHERE tenant_id = $1
  AND (sqlc.narg('record_id')::TEXT IS NULL OR record_id = sqlc.narg('record_id'));

-- name: GetBatchByNumber :one
SELECT * FROM batch_records
WHERE tenant_id = $1 AND batch_number = $2;

-- name: CreateQRCode :one
INSERT INTO qr_codes (
    id, record_id, batch_id, qr_data, qr_image_url, scan_url,
    generated_at, expires_at, is_active
) VALUES (
    $1, $2, $3, $4, $5, $6,
    $7, $8, $9
) RETURNING *;

-- name: GetQRCode :one
SELECT * FROM qr_codes
WHERE id = $1;

-- name: GetQRCodeByData :one
SELECT * FROM qr_codes
WHERE qr_data = $1 AND is_active = TRUE;

-- name: GetQRCodesByRecord :many
SELECT * FROM qr_codes
WHERE record_id = $1
ORDER BY generated_at DESC;

-- name: DeactivateQRCode :exec
UPDATE qr_codes SET is_active = FALSE WHERE id = $1;

-- name: CreateComplianceReport :one
INSERT INTO compliance_reports (
    id, tenant_id, record_id, status, report_type,
    findings, recommendations, auditor, audit_date,
    next_audit_date, compliance_score, metadata, created_at
) VALUES (
    $1, $2, $3, $4, $5,
    $6, $7, $8, $9,
    $10, $11, $12, $13
) RETURNING *;

-- name: GetComplianceReport :one
SELECT * FROM compliance_reports
WHERE id = $1 AND tenant_id = $2;

-- name: GetComplianceReportsByRecord :many
SELECT * FROM compliance_reports
WHERE record_id = $1 AND tenant_id = $2
ORDER BY created_at DESC;

-- name: GetLatestComplianceReport :one
SELECT * FROM compliance_reports
WHERE record_id = $1 AND tenant_id = $2
ORDER BY created_at DESC
LIMIT 1;
