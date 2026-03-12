package repositories

import (
	"context"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	analyticsmodels "p9e.in/samavaya/agriculture/satellite-analytics-service/internal/models"
)

// AnalyticsRepository defines the interface for analytics persistence operations.
type AnalyticsRepository interface {
	CreateStressAlert(ctx context.Context, alert *analyticsmodels.StressAlert) (*analyticsmodels.StressAlert, error)
	GetStressAlertByUUID(ctx context.Context, uuid, tenantID string) (*analyticsmodels.StressAlert, error)
	ListStressAlerts(ctx context.Context, params analyticsmodels.ListStressAlertsParams) ([]analyticsmodels.StressAlert, int32, error)
	AcknowledgeStressAlert(ctx context.Context, uuid, tenantID, acknowledgedBy string) error
	ListStressAlertsByProcessingJob(ctx context.Context, processingJobID, tenantID string) ([]analyticsmodels.StressAlert, error)
	CountActiveStressAlerts(ctx context.Context, tenantID, farmID, fieldID string) (int32, error)
	GetDominantStressType(ctx context.Context, tenantID, farmID, fieldID string) (*analyticsmodels.StressType, error)

	CreateTemporalAnalysis(ctx context.Context, analysis *analyticsmodels.TemporalAnalysis) (*analyticsmodels.TemporalAnalysis, error)
	GetTemporalAnalysisByUUID(ctx context.Context, uuid, tenantID string) (*analyticsmodels.TemporalAnalysis, error)
	GetLatestTemporalAnalysis(ctx context.Context, tenantID, farmID, fieldID string) (*analyticsmodels.TemporalAnalysis, error)

	WithTx(tx pgx.Tx) AnalyticsRepository
}

// analyticsRepository is the concrete implementation of AnalyticsRepository.
type analyticsRepository struct {
	d   deps.ServiceDeps
	log *p9log.Helper
	tx  pgx.Tx
}

// NewAnalyticsRepository creates a new AnalyticsRepository.
func NewAnalyticsRepository(d deps.ServiceDeps) AnalyticsRepository {
	return &analyticsRepository{
		d:   d,
		log: p9log.NewHelper(p9log.With(d.Log, "component", "AnalyticsRepository")),
	}
}

// WithTx returns a copy of the repository that uses the provided transaction.
func (r *analyticsRepository) WithTx(tx pgx.Tx) AnalyticsRepository {
	return &analyticsRepository{
		d:   r.d,
		log: r.log,
		tx:  tx,
	}
}

// queryRow is a helper to use the tx or pool for single-row queries.
func (r *analyticsRepository) queryRow(ctx context.Context, sql string, args ...any) pgx.Row {
	if r.tx != nil {
		return r.tx.QueryRow(ctx, sql, args...)
	}
	return r.d.Pool.QueryRow(ctx, sql, args...)
}

// query is a helper to use the tx or pool for multi-row queries.
func (r *analyticsRepository) query(ctx context.Context, sql string, args ...any) (pgx.Rows, error) {
	if r.tx != nil {
		return r.tx.Query(ctx, sql, args...)
	}
	return r.d.Pool.Query(ctx, sql, args...)
}

// exec is a helper to use the tx or pool for exec statements.
func (r *analyticsRepository) exec(ctx context.Context, sql string, args ...any) error {
	var err error
	if r.tx != nil {
		_, err = r.tx.Exec(ctx, sql, args...)
	} else {
		_, err = r.d.Pool.Exec(ctx, sql, args...)
	}
	return err
}

// ---------- Stress Alert CRUD ----------

func (r *analyticsRepository) CreateStressAlert(ctx context.Context, alert *analyticsmodels.StressAlert) (*analyticsmodels.StressAlert, error) {
	alert.UUID = ulid.NewString()
	alert.CreatedAt = time.Now()
	alert.IsActive = true
	alert.Acknowledged = false

	if alert.DetectedAt.IsZero() {
		alert.DetectedAt = time.Now()
	}

	row := r.queryRow(ctx, `
		INSERT INTO stress_alerts (
			uuid, tenant_id, farm_id, field_id, processing_job_id,
			stress_type, severity, confidence, affected_area_hectares,
			affected_percentage, bbox_geojson, description, recommendation,
			acknowledged, detected_at, is_active, created_by, created_at
		) VALUES (
			$1, $2, $3, $4, $5,
			$6, $7, $8, $9,
			$10, $11, $12, $13,
			FALSE, $14, TRUE, $15, NOW()
		)
		RETURNING id, uuid, tenant_id, farm_id, field_id, processing_job_id,
			stress_type, severity, confidence, affected_area_hectares,
			affected_percentage, bbox_geojson, description, recommendation,
			acknowledged, acknowledged_at, acknowledged_by, detected_at,
			is_active, created_by, created_at, updated_by, updated_at, deleted_by, deleted_at`,
		alert.UUID, alert.TenantID, alert.FarmID, alert.FieldID, alert.ProcessingJobID,
		alert.StressType, alert.Severity, alert.Confidence, alert.AffectedAreaHectares,
		alert.AffectedPercentage, alert.BboxGeoJSON, alert.Description, alert.Recommendation,
		alert.DetectedAt, alert.CreatedBy,
	)

	result := &analyticsmodels.StressAlert{}
	if err := scanStressAlert(row, result); err != nil {
		r.log.Errorw("msg", "failed to create stress alert", "error", err)
		return nil, errors.InternalServer("STRESS_ALERT_CREATE_FAILED", fmt.Sprintf("failed to create stress alert: %v", err))
	}

	r.log.Infow("msg", "stress alert created", "uuid", result.UUID, "tenant_id", result.TenantID)
	return result, nil
}

func (r *analyticsRepository) GetStressAlertByUUID(ctx context.Context, uuid, tenantID string) (*analyticsmodels.StressAlert, error) {
	row := r.queryRow(ctx, `
		SELECT id, uuid, tenant_id, farm_id, field_id, processing_job_id,
			stress_type, severity, confidence, affected_area_hectares,
			affected_percentage, bbox_geojson, description, recommendation,
			acknowledged, acknowledged_at, acknowledged_by, detected_at,
			is_active, created_by, created_at, updated_by, updated_at, deleted_by, deleted_at
		FROM stress_alerts
		WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL`,
		uuid, tenantID,
	)

	alert := &analyticsmodels.StressAlert{}
	if err := scanStressAlert(row, alert); err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("STRESS_ALERT_NOT_FOUND", fmt.Sprintf("stress alert not found: %s", uuid))
		}
		r.log.Errorw("msg", "failed to get stress alert", "uuid", uuid, "error", err)
		return nil, errors.InternalServer("STRESS_ALERT_GET_FAILED", fmt.Sprintf("failed to get stress alert: %v", err))
	}

	return alert, nil
}

func (r *analyticsRepository) ListStressAlerts(ctx context.Context, params analyticsmodels.ListStressAlertsParams) ([]analyticsmodels.StressAlert, int32, error) {
	// Count total matching records
	var totalCount int32
	countRow := r.queryRow(ctx, `
		SELECT COUNT(*) FROM stress_alerts
		WHERE tenant_id = $1
			AND is_active = TRUE
			AND deleted_at IS NULL
			AND ($2::VARCHAR IS NULL OR farm_id = $2)
			AND ($3::VARCHAR IS NULL OR stress_type = $3::stress_type)
			AND ($4::VARCHAR IS NULL OR severity >= $4::severity_level)
			AND ($5::BOOLEAN IS NULL OR $5::BOOLEAN = FALSE OR acknowledged = FALSE)`,
		params.TenantID,
		params.FarmID,
		nullableString(params.StressType),
		nullableString(params.MinSeverity),
		nilIfFalseBool(params.UnacknowledgedOnly),
	)
	if err := countRow.Scan(&totalCount); err != nil {
		r.log.Errorw("msg", "failed to count stress alerts", "error", err)
		return nil, 0, errors.InternalServer("STRESS_ALERT_COUNT_FAILED", fmt.Sprintf("failed to count stress alerts: %v", err))
	}

	// Fetch the page
	rows, err := r.query(ctx, `
		SELECT id, uuid, tenant_id, farm_id, field_id, processing_job_id,
			stress_type, severity, confidence, affected_area_hectares,
			affected_percentage, bbox_geojson, description, recommendation,
			acknowledged, acknowledged_at, acknowledged_by, detected_at,
			is_active, created_by, created_at, updated_by, updated_at, deleted_by, deleted_at
		FROM stress_alerts
		WHERE tenant_id = $1
			AND is_active = TRUE
			AND deleted_at IS NULL
			AND ($2::VARCHAR IS NULL OR farm_id = $2)
			AND ($3::VARCHAR IS NULL OR stress_type = $3::stress_type)
			AND ($4::VARCHAR IS NULL OR severity >= $4::severity_level)
			AND ($5::BOOLEAN IS NULL OR $5::BOOLEAN = FALSE OR acknowledged = FALSE)
		ORDER BY detected_at DESC
		LIMIT $6 OFFSET $7`,
		params.TenantID,
		params.FarmID,
		nullableString(params.StressType),
		nullableString(params.MinSeverity),
		nilIfFalseBool(params.UnacknowledgedOnly),
		params.PageSize,
		params.Offset,
	)
	if err != nil {
		r.log.Errorw("msg", "failed to list stress alerts", "error", err)
		return nil, 0, errors.InternalServer("STRESS_ALERT_LIST_FAILED", fmt.Sprintf("failed to list stress alerts: %v", err))
	}
	defer rows.Close()

	alerts := make([]analyticsmodels.StressAlert, 0)
	for rows.Next() {
		var alert analyticsmodels.StressAlert
		if err := scanStressAlertFromRows(rows, &alert); err != nil {
			r.log.Errorw("msg", "failed to scan stress alert row", "error", err)
			return nil, 0, errors.InternalServer("STRESS_ALERT_SCAN_FAILED", fmt.Sprintf("failed to scan stress alert: %v", err))
		}
		alerts = append(alerts, alert)
	}
	if err := rows.Err(); err != nil {
		return nil, 0, errors.InternalServer("STRESS_ALERT_ROWS_ERROR", fmt.Sprintf("row iteration error: %v", err))
	}

	return alerts, totalCount, nil
}

func (r *analyticsRepository) AcknowledgeStressAlert(ctx context.Context, uuid, tenantID, acknowledgedBy string) error {
	err := r.exec(ctx, `
		UPDATE stress_alerts SET
			acknowledged = TRUE,
			acknowledged_at = NOW(),
			acknowledged_by = $3,
			updated_by = $3,
			updated_at = NOW()
		WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL`,
		uuid, tenantID, acknowledgedBy,
	)
	if err != nil {
		r.log.Errorw("msg", "failed to acknowledge stress alert", "uuid", uuid, "error", err)
		return errors.InternalServer("STRESS_ALERT_ACK_FAILED", fmt.Sprintf("failed to acknowledge stress alert: %v", err))
	}

	r.log.Infow("msg", "stress alert acknowledged", "uuid", uuid)
	return nil
}

func (r *analyticsRepository) ListStressAlertsByProcessingJob(ctx context.Context, processingJobID, tenantID string) ([]analyticsmodels.StressAlert, error) {
	rows, err := r.query(ctx, `
		SELECT id, uuid, tenant_id, farm_id, field_id, processing_job_id,
			stress_type, severity, confidence, affected_area_hectares,
			affected_percentage, bbox_geojson, description, recommendation,
			acknowledged, acknowledged_at, acknowledged_by, detected_at,
			is_active, created_by, created_at, updated_by, updated_at, deleted_by, deleted_at
		FROM stress_alerts
		WHERE processing_job_id = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
		ORDER BY severity DESC, detected_at DESC`,
		processingJobID, tenantID,
	)
	if err != nil {
		r.log.Errorw("msg", "failed to list stress alerts by processing job", "processing_job_id", processingJobID, "error", err)
		return nil, errors.InternalServer("STRESS_ALERT_LIST_FAILED", fmt.Sprintf("failed to list stress alerts: %v", err))
	}
	defer rows.Close()

	alerts := make([]analyticsmodels.StressAlert, 0)
	for rows.Next() {
		var alert analyticsmodels.StressAlert
		if err := scanStressAlertFromRows(rows, &alert); err != nil {
			return nil, errors.InternalServer("STRESS_ALERT_SCAN_FAILED", fmt.Sprintf("failed to scan stress alert: %v", err))
		}
		alerts = append(alerts, alert)
	}
	if err := rows.Err(); err != nil {
		return nil, errors.InternalServer("STRESS_ALERT_ROWS_ERROR", fmt.Sprintf("row iteration error: %v", err))
	}

	return alerts, nil
}

func (r *analyticsRepository) CountActiveStressAlerts(ctx context.Context, tenantID, farmID, fieldID string) (int32, error) {
	var count int32
	row := r.queryRow(ctx, `
		SELECT COUNT(*) FROM stress_alerts
		WHERE tenant_id = $1 AND farm_id = $2 AND field_id = $3
			AND is_active = TRUE AND deleted_at IS NULL AND acknowledged = FALSE`,
		tenantID, farmID, fieldID,
	)
	if err := row.Scan(&count); err != nil {
		return 0, errors.InternalServer("STRESS_ALERT_COUNT_FAILED", fmt.Sprintf("failed to count active stress alerts: %v", err))
	}
	return count, nil
}

func (r *analyticsRepository) GetDominantStressType(ctx context.Context, tenantID, farmID, fieldID string) (*analyticsmodels.StressType, error) {
	var stressType analyticsmodels.StressType
	row := r.queryRow(ctx, `
		SELECT stress_type FROM stress_alerts
		WHERE tenant_id = $1 AND farm_id = $2 AND field_id = $3
			AND is_active = TRUE AND deleted_at IS NULL AND acknowledged = FALSE
		GROUP BY stress_type
		ORDER BY COUNT(*) DESC
		LIMIT 1`,
		tenantID, farmID, fieldID,
	)
	if err := row.Scan(&stressType); err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, errors.InternalServer("STRESS_TYPE_GET_FAILED", fmt.Sprintf("failed to get dominant stress type: %v", err))
	}
	return &stressType, nil
}

// ---------- Temporal Analysis CRUD ----------

func (r *analyticsRepository) CreateTemporalAnalysis(ctx context.Context, analysis *analyticsmodels.TemporalAnalysis) (*analyticsmodels.TemporalAnalysis, error) {
	analysis.UUID = ulid.NewString()
	analysis.CreatedAt = time.Now()
	analysis.IsActive = true

	row := r.queryRow(ctx, `
		INSERT INTO temporal_analyses (
			uuid, tenant_id, farm_id, field_id, analysis_type,
			metric_name, trend_slope, trend_r_squared, current_value,
			baseline_value, deviation_percent, period_start, period_end,
			is_active, created_by, created_at
		) VALUES (
			$1, $2, $3, $4, $5,
			$6, $7, $8, $9,
			$10, $11, $12, $13,
			TRUE, $14, NOW()
		)
		RETURNING id, uuid, tenant_id, farm_id, field_id, analysis_type,
			metric_name, trend_slope, trend_r_squared, current_value,
			baseline_value, deviation_percent, period_start, period_end,
			is_active, created_by, created_at, updated_by, updated_at, deleted_by, deleted_at`,
		analysis.UUID, analysis.TenantID, analysis.FarmID, analysis.FieldID, analysis.AnalysisType,
		analysis.MetricName, analysis.TrendSlope, analysis.TrendRSquared, analysis.CurrentValue,
		analysis.BaselineValue, analysis.DeviationPercent, analysis.PeriodStart, analysis.PeriodEnd,
		analysis.CreatedBy,
	)

	result := &analyticsmodels.TemporalAnalysis{}
	if err := scanTemporalAnalysis(row, result); err != nil {
		r.log.Errorw("msg", "failed to create temporal analysis", "error", err)
		return nil, errors.InternalServer("TEMPORAL_ANALYSIS_CREATE_FAILED", fmt.Sprintf("failed to create temporal analysis: %v", err))
	}

	r.log.Infow("msg", "temporal analysis created", "uuid", result.UUID, "tenant_id", result.TenantID)
	return result, nil
}

func (r *analyticsRepository) GetTemporalAnalysisByUUID(ctx context.Context, uuid, tenantID string) (*analyticsmodels.TemporalAnalysis, error) {
	row := r.queryRow(ctx, `
		SELECT id, uuid, tenant_id, farm_id, field_id, analysis_type,
			metric_name, trend_slope, trend_r_squared, current_value,
			baseline_value, deviation_percent, period_start, period_end,
			is_active, created_by, created_at, updated_by, updated_at, deleted_by, deleted_at
		FROM temporal_analyses
		WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL`,
		uuid, tenantID,
	)

	analysis := &analyticsmodels.TemporalAnalysis{}
	if err := scanTemporalAnalysis(row, analysis); err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("TEMPORAL_ANALYSIS_NOT_FOUND", fmt.Sprintf("temporal analysis not found: %s", uuid))
		}
		r.log.Errorw("msg", "failed to get temporal analysis", "uuid", uuid, "error", err)
		return nil, errors.InternalServer("TEMPORAL_ANALYSIS_GET_FAILED", fmt.Sprintf("failed to get temporal analysis: %v", err))
	}

	return analysis, nil
}

func (r *analyticsRepository) GetLatestTemporalAnalysis(ctx context.Context, tenantID, farmID, fieldID string) (*analyticsmodels.TemporalAnalysis, error) {
	row := r.queryRow(ctx, `
		SELECT id, uuid, tenant_id, farm_id, field_id, analysis_type,
			metric_name, trend_slope, trend_r_squared, current_value,
			baseline_value, deviation_percent, period_start, period_end,
			is_active, created_by, created_at, updated_by, updated_at, deleted_by, deleted_at
		FROM temporal_analyses
		WHERE tenant_id = $1 AND farm_id = $2 AND field_id = $3
			AND is_active = TRUE AND deleted_at IS NULL
		ORDER BY created_at DESC
		LIMIT 1`,
		tenantID, farmID, fieldID,
	)

	analysis := &analyticsmodels.TemporalAnalysis{}
	if err := scanTemporalAnalysis(row, analysis); err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		r.log.Errorw("msg", "failed to get latest temporal analysis", "error", err)
		return nil, errors.InternalServer("TEMPORAL_ANALYSIS_GET_FAILED", fmt.Sprintf("failed to get latest temporal analysis: %v", err))
	}

	return analysis, nil
}

// ---------- Scan helpers ----------

func scanStressAlert(row pgx.Row, a *analyticsmodels.StressAlert) error {
	return row.Scan(
		&a.ID, &a.UUID, &a.TenantID, &a.FarmID, &a.FieldID, &a.ProcessingJobID,
		&a.StressType, &a.Severity, &a.Confidence, &a.AffectedAreaHectares,
		&a.AffectedPercentage, &a.BboxGeoJSON, &a.Description, &a.Recommendation,
		&a.Acknowledged, &a.AcknowledgedAt, &a.AcknowledgedBy, &a.DetectedAt,
		&a.IsActive, &a.CreatedBy, &a.CreatedAt, &a.UpdatedBy, &a.UpdatedAt, &a.DeletedBy, &a.DeletedAt,
	)
}

func scanStressAlertFromRows(rows pgx.Rows, a *analyticsmodels.StressAlert) error {
	return rows.Scan(
		&a.ID, &a.UUID, &a.TenantID, &a.FarmID, &a.FieldID, &a.ProcessingJobID,
		&a.StressType, &a.Severity, &a.Confidence, &a.AffectedAreaHectares,
		&a.AffectedPercentage, &a.BboxGeoJSON, &a.Description, &a.Recommendation,
		&a.Acknowledged, &a.AcknowledgedAt, &a.AcknowledgedBy, &a.DetectedAt,
		&a.IsActive, &a.CreatedBy, &a.CreatedAt, &a.UpdatedBy, &a.UpdatedAt, &a.DeletedBy, &a.DeletedAt,
	)
}

func scanTemporalAnalysis(row pgx.Row, t *analyticsmodels.TemporalAnalysis) error {
	return row.Scan(
		&t.ID, &t.UUID, &t.TenantID, &t.FarmID, &t.FieldID, &t.AnalysisType,
		&t.MetricName, &t.TrendSlope, &t.TrendRSquared, &t.CurrentValue,
		&t.BaselineValue, &t.DeviationPercent, &t.PeriodStart, &t.PeriodEnd,
		&t.IsActive, &t.CreatedBy, &t.CreatedAt, &t.UpdatedBy, &t.UpdatedAt, &t.DeletedBy, &t.DeletedAt,
	)
}

func scanTemporalAnalysisFromRows(rows pgx.Rows, t *analyticsmodels.TemporalAnalysis) error {
	return rows.Scan(
		&t.ID, &t.UUID, &t.TenantID, &t.FarmID, &t.FieldID, &t.AnalysisType,
		&t.MetricName, &t.TrendSlope, &t.TrendRSquared, &t.CurrentValue,
		&t.BaselineValue, &t.DeviationPercent, &t.PeriodStart, &t.PeriodEnd,
		&t.IsActive, &t.CreatedBy, &t.CreatedAt, &t.UpdatedBy, &t.UpdatedAt, &t.DeletedBy, &t.DeletedAt,
	)
}

// ---------- Nil helpers ----------

func nullableString[T ~string](v *T) *string {
	if v == nil || *v == "" {
		return nil
	}
	s := string(*v)
	return &s
}

func nilIfFalseBool(b bool) *bool {
	if !b {
		return nil
	}
	return &b
}
