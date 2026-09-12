package pipeline

import (
	"context"
	"fmt"
	"math"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// TimeBucket represents a time aggregation interval.
type TimeBucket string

const (
	TimeBucket1Hour  TimeBucket = "1h"
	TimeBucket1Day   TimeBucket = "1d"
	TimeBucket1Week  TimeBucket = "1w"
	TimeBucket1Month TimeBucket = "1m"
)

// TimeSeriesQuery defines parameters for querying sensor data with time bucketing.
type TimeSeriesQuery struct {
	TenantID   string
	FieldID    string
	SensorType string
	Start      time.Time
	End        time.Time
	Bucket     TimeBucket
}

// TimeSeriesPoint is a single aggregated data point in a time series.
type TimeSeriesPoint struct {
	BucketStart time.Time
	MinValue    float64
	AvgValue    float64
	MaxValue    float64
	Count       int64
}

// TrendQuery defines parameters for computing linear regression trends.
type TrendQuery struct {
	TenantID   string
	FieldID    string
	Metric     string // column name in the source table
	Table      string // source table
	Start      time.Time
	End        time.Time
}

// TrendResult holds the linear regression output.
type TrendResult struct {
	Slope     float64 // rate of change per day
	Intercept float64
	RSquared  float64
	DataPoints int
	Direction string // "increasing", "decreasing", "stable"
}

// CrossFieldQuery defines parameters for comparing metrics across fields.
type CrossFieldQuery struct {
	TenantID   string
	FieldIDs   []string
	Metric     string
	Table      string
	Start      time.Time
	End        time.Time
}

// FieldMetricSummary holds aggregated metrics for one field.
type FieldMetricSummary struct {
	FieldID  string
	MinValue float64
	AvgValue float64
	MaxValue float64
	Count    int64
}

// WarehouseService defines the interface for analytics queries.
type WarehouseService interface {
	// QueryTimeSeries returns aggregated sensor data bucketed by time interval.
	QueryTimeSeries(ctx context.Context, q TimeSeriesQuery) ([]TimeSeriesPoint, error)
	// ComputeTrend calculates a linear regression trend for the given metric.
	ComputeTrend(ctx context.Context, q TrendQuery) (*TrendResult, error)
	// CompareFields compares a metric across multiple fields.
	CompareFields(ctx context.Context, q CrossFieldQuery) ([]FieldMetricSummary, error)
}

// PostgresWarehouse implements WarehouseService using PostgreSQL.
type PostgresWarehouse struct {
	Pool *pgxpool.Pool
}

// NewPostgresWarehouse creates a new PostgreSQL warehouse service.
func NewPostgresWarehouse(pool *pgxpool.Pool) *PostgresWarehouse {
	return &PostgresWarehouse{Pool: pool}
}

// QueryTimeSeries queries sensor data with time bucketing.
func (pw *PostgresWarehouse) QueryTimeSeries(ctx context.Context, q TimeSeriesQuery) ([]TimeSeriesPoint, error) {
	truncExpr, err := bucketToTrunc(q.Bucket)
	if err != nil {
		return nil, err
	}

	query := fmt.Sprintf(`
		SELECT
			date_trunc(%s, reading_time) AS bucket,
			MIN(value)                   AS min_value,
			AVG(value)                   AS avg_value,
			MAX(value)                   AS max_value,
			COUNT(*)                     AS cnt
		FROM sensor_readings
		WHERE tenant_id   = $1
		  AND field_id    = $2
		  AND sensor_type = $3
		  AND reading_time >= $4
		  AND reading_time <  $5
		GROUP BY bucket
		ORDER BY bucket`,
		truncExpr)

	rows, err := pw.Pool.Query(ctx, query, q.TenantID, q.FieldID, q.SensorType, q.Start, q.End)
	if err != nil {
		return nil, fmt.Errorf("warehouse: time series query: %w", err)
	}
	defer rows.Close()

	var points []TimeSeriesPoint
	for rows.Next() {
		var p TimeSeriesPoint
		if err := rows.Scan(&p.BucketStart, &p.MinValue, &p.AvgValue, &p.MaxValue, &p.Count); err != nil {
			return nil, fmt.Errorf("warehouse: time series scan: %w", err)
		}
		points = append(points, p)
	}
	return points, rows.Err()
}

func bucketToTrunc(b TimeBucket) (string, error) {
	switch b {
	case TimeBucket1Hour:
		return "'hour'", nil
	case TimeBucket1Day:
		return "'day'", nil
	case TimeBucket1Week:
		return "'week'", nil
	case TimeBucket1Month:
		return "'month'", nil
	default:
		return "", fmt.Errorf("warehouse: unsupported time bucket: %s", b)
	}
}

// ComputeTrend calculates linear regression for a metric over time.
// It uses PostgreSQL aggregate functions for regr_slope, regr_intercept,
// and regr_r2 when available, otherwise falls back to in-memory computation.
func (pw *PostgresWarehouse) ComputeTrend(ctx context.Context, q TrendQuery) (*TrendResult, error) {
	// Validate table/metric names to prevent SQL injection.
	if !isValidIdentifier(q.Table) || !isValidIdentifier(q.Metric) {
		return nil, fmt.Errorf("warehouse: invalid table or metric name")
	}

	query := fmt.Sprintf(`
		SELECT
			EXTRACT(EPOCH FROM reading_time) AS x,
			%s AS y
		FROM %s
		WHERE tenant_id = $1
		  AND field_id  = $2
		  AND reading_time >= $3
		  AND reading_time <  $4
		ORDER BY reading_time`,
		pgx.Identifier{q.Metric}.Sanitize(),
		pgx.Identifier{q.Table}.Sanitize())

	rows, err := pw.Pool.Query(ctx, query, q.TenantID, q.FieldID, q.Start, q.End)
	if err != nil {
		return nil, fmt.Errorf("warehouse: trend query: %w", err)
	}
	defer rows.Close()

	var xs, ys []float64
	for rows.Next() {
		var x, y float64
		if err := rows.Scan(&x, &y); err != nil {
			return nil, fmt.Errorf("warehouse: trend scan: %w", err)
		}
		xs = append(xs, x)
		ys = append(ys, y)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}

	if len(xs) < 2 {
		return &TrendResult{DataPoints: len(xs), Direction: "stable"}, nil
	}

	slope, intercept, rSquared := linearRegression(xs, ys)

	// Convert slope from per-second to per-day.
	slopePerDay := slope * 86400

	direction := "stable"
	if math.Abs(slopePerDay) > 0.001 {
		if slopePerDay > 0 {
			direction = "increasing"
		} else {
			direction = "decreasing"
		}
	}

	return &TrendResult{
		Slope:      slopePerDay,
		Intercept:  intercept,
		RSquared:   rSquared,
		DataPoints: len(xs),
		Direction:  direction,
	}, nil
}

// CompareFields compares a metric across multiple fields.
func (pw *PostgresWarehouse) CompareFields(ctx context.Context, q CrossFieldQuery) ([]FieldMetricSummary, error) {
	if !isValidIdentifier(q.Table) || !isValidIdentifier(q.Metric) {
		return nil, fmt.Errorf("warehouse: invalid table or metric name")
	}
	if len(q.FieldIDs) == 0 {
		return nil, fmt.Errorf("warehouse: no field IDs specified")
	}

	// Build parameterized IN clause.
	placeholders := make([]string, len(q.FieldIDs))
	args := make([]interface{}, 0, len(q.FieldIDs)+3)
	args = append(args, q.TenantID)

	for i, fid := range q.FieldIDs {
		placeholders[i] = fmt.Sprintf("$%d", i+2)
		args = append(args, fid)
	}
	args = append(args, q.Start, q.End)

	startIdx := len(q.FieldIDs) + 2
	endIdx := startIdx + 1

	query := fmt.Sprintf(`
		SELECT
			field_id,
			MIN(%s)   AS min_value,
			AVG(%s)   AS avg_value,
			MAX(%s)   AS max_value,
			COUNT(*)  AS cnt
		FROM %s
		WHERE tenant_id = $1
		  AND field_id IN (%s)
		  AND reading_time >= $%d
		  AND reading_time <  $%d
		GROUP BY field_id
		ORDER BY field_id`,
		pgx.Identifier{q.Metric}.Sanitize(),
		pgx.Identifier{q.Metric}.Sanitize(),
		pgx.Identifier{q.Metric}.Sanitize(),
		pgx.Identifier{q.Table}.Sanitize(),
		strings.Join(placeholders, ", "),
		startIdx, endIdx)

	rows, err := pw.Pool.Query(ctx, query, args...)
	if err != nil {
		return nil, fmt.Errorf("warehouse: cross-field query: %w", err)
	}
	defer rows.Close()

	var summaries []FieldMetricSummary
	for rows.Next() {
		var s FieldMetricSummary
		if err := rows.Scan(&s.FieldID, &s.MinValue, &s.AvgValue, &s.MaxValue, &s.Count); err != nil {
			return nil, fmt.Errorf("warehouse: cross-field scan: %w", err)
		}
		summaries = append(summaries, s)
	}
	return summaries, rows.Err()
}

// --------------------------------------------------------------------------
// Helpers
// --------------------------------------------------------------------------

// linearRegression computes slope, intercept, and R-squared for (x, y) pairs.
func linearRegression(xs, ys []float64) (slope, intercept, rSquared float64) {
	n := float64(len(xs))
	if n < 2 {
		return 0, 0, 0
	}

	var sumX, sumY, sumXY, sumX2, sumY2 float64
	for i := range xs {
		sumX += xs[i]
		sumY += ys[i]
		sumXY += xs[i] * ys[i]
		sumX2 += xs[i] * xs[i]
		sumY2 += ys[i] * ys[i]
	}

	denom := n*sumX2 - sumX*sumX
	if denom == 0 {
		return 0, sumY / n, 0
	}

	slope = (n*sumXY - sumX*sumY) / denom
	intercept = (sumY - slope*sumX) / n

	// R-squared
	ssRes := 0.0
	ssTot := 0.0
	meanY := sumY / n
	for i := range xs {
		predicted := slope*xs[i] + intercept
		ssRes += (ys[i] - predicted) * (ys[i] - predicted)
		ssTot += (ys[i] - meanY) * (ys[i] - meanY)
	}
	if ssTot > 0 {
		rSquared = 1 - ssRes/ssTot
	}

	return slope, intercept, rSquared
}

// isValidIdentifier checks that a SQL identifier contains only safe characters.
func isValidIdentifier(s string) bool {
	if s == "" {
		return false
	}
	for _, c := range s {
		if !((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_') {
			return false
		}
	}
	return true
}
