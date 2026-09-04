ALTER TABLE quality_checkpoints
  DROP COLUMN IF EXISTS lab_report_url,
  DROP COLUMN IF EXISTS grade;
