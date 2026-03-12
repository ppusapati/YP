package builder

import (
	"context"
	"sync"
	"time"

	"p9e.in/samavaya/packages/metrics"
)

// QueryMetrics provides per-table query performance tracking.
// It wraps the metrics.MetricsProvider to add table-specific dimensions.
type QueryMetrics struct {
	provider metrics.MetricsProvider
	enabled  bool
}

// QueryMetricsConfig configures query metrics behavior.
type QueryMetricsConfig struct {
	Enabled bool // Enable per-table query metrics
}

var (
	// Global query metrics instance
	globalQueryMetrics *QueryMetrics
)

// NewQueryMetrics creates a new QueryMetrics instance.
func NewQueryMetrics(provider metrics.MetricsProvider, config QueryMetricsConfig) *QueryMetrics {
	return &QueryMetrics{
		provider: provider,
		enabled:  config.Enabled,
	}
}

// SetGlobalQueryMetrics sets the global query metrics used by all query functions.
func SetGlobalQueryMetrics(qm *QueryMetrics) {
	globalQueryMetrics = qm
}

// GetGlobalQueryMetrics returns the global query metrics (may be nil).
func GetGlobalQueryMetrics() *QueryMetrics {
	return globalQueryMetrics
}

// RecordQuery records a query execution with table and operation dimensions.
//
// Example:
//
//	qm.RecordQuery(ctx, "users", "SELECT", time.Millisecond*50, true)
func (qm *QueryMetrics) RecordQuery(ctx context.Context, table string, operation string, duration time.Duration, success bool) {
	if !qm.enabled || qm.provider == nil {
		return
	}

	// Create operation label with table and query type
	operationLabel := table + "." + operation
	qm.provider.RecordDBOperation(operationLabel, duration, success)

	// Track local in-memory stats for GetStats() aggregation
	recordStats(table, operation, duration, success)
}

// RecordRetry records a query retry with table and operation dimensions.
//
// Example:
//
//	qm.RecordRetry(ctx, "users", "SELECT")
func (qm *QueryMetrics) RecordRetry(ctx context.Context, table string, operation string) {
	if !qm.enabled || qm.provider == nil {
		return
	}

	operationLabel := table + "." + operation
	qm.provider.RecordDBRetry(operationLabel)
}

// WithQueryMetrics is a helper that wraps query execution with per-table metrics.
//
// Example:
//
//	result, err := WithQueryMetrics(ctx, "users", "SELECT", func() (interface{}, error) {
//	    return db.Query(ctx, query, args...)
//	})
func WithQueryMetrics(ctx context.Context, table string, operation string, fn func() (interface{}, error)) (interface{}, error) {
	if globalQueryMetrics == nil || !globalQueryMetrics.enabled {
		return fn()
	}

	start := time.Now()
	result, err := fn()
	duration := time.Since(start)

	globalQueryMetrics.RecordQuery(ctx, table, operation, duration, err == nil)

	return result, err
}

// WithQueryMetricsAndLogging combines query logging and metrics.
// This is the recommended wrapper for all query executions.
//
// Example:
//
//	result, err := WithQueryMetricsAndLogging(ctx, "users", "SELECT", query, args, func() (interface{}, error) {
//	    return db.Query(ctx, query, args...)
//	})
func WithQueryMetricsAndLogging(
	ctx context.Context,
	table string,
	operation string,
	query string,
	args []interface{},
	fn func() (interface{}, error),
) (interface{}, error) {
	// Enable both logging and metrics if available
	logEnabled := globalQueryLogger != nil && globalQueryLogger.enabled
	metricsEnabled := globalQueryMetrics != nil && globalQueryMetrics.enabled

	if !logEnabled && !metricsEnabled {
		return fn()
	}

	start := time.Now()
	result, err := fn()
	duration := time.Since(start)

	// Record metrics
	if metricsEnabled {
		globalQueryMetrics.RecordQuery(ctx, table, operation, duration, err == nil)
	}

	// Log query
	if logEnabled {
		if err != nil {
			globalQueryLogger.LogQueryError(ctx, operation, query, args, err, duration)
		} else {
			globalQueryLogger.LogQuery(ctx, operation, query, args, duration)
		}
	}

	return result, err
}

// QueryStats provides aggregated statistics for a specific table/operation.
// This is a helper for external monitoring and dashboards.
type QueryStats struct {
	Table         string
	Operation     string
	TotalDuration time.Duration
	TotalCount    int64
	SuccessCount  int64
	FailureCount  int64
	AvgDuration   time.Duration
}

// inMemoryStats tracks per-table/operation counts for local aggregation.
type inMemoryStats struct {
	mu    sync.RWMutex
	stats map[string]*QueryStats
}

var localStats = &inMemoryStats{
	stats: make(map[string]*QueryStats),
}

func statsKey(table, operation string) string {
	return table + "." + operation
}

// recordStats updates local in-memory stats for a query execution.
func recordStats(table, operation string, duration time.Duration, success bool) {
	key := statsKey(table, operation)
	localStats.mu.Lock()
	defer localStats.mu.Unlock()

	s, exists := localStats.stats[key]
	if !exists {
		s = &QueryStats{Table: table, Operation: operation}
		localStats.stats[key] = s
	}
	s.TotalCount++
	s.TotalDuration += duration
	if success {
		s.SuccessCount++
	} else {
		s.FailureCount++
	}
	if s.TotalCount > 0 {
		s.AvgDuration = s.TotalDuration / time.Duration(s.TotalCount)
	}
}

// GetStats returns aggregated statistics for the given table and operation.
// Statistics are tracked in-memory alongside being pushed to metrics backends.
func (qm *QueryMetrics) GetStats(table string, operation string) *QueryStats {
	key := statsKey(table, operation)
	localStats.mu.RLock()
	defer localStats.mu.RUnlock()

	if s, exists := localStats.stats[key]; exists {
		// Return a copy to avoid data races
		result := *s
		return &result
	}
	return &QueryStats{
		Table:     table,
		Operation: operation,
	}
}
