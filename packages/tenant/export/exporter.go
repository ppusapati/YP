// Package export provides functionality for exporting all data belonging to a
// tenant, supporting both full and incremental (since-timestamp) exports in
// JSON or CSV format.
package export

import (
	"context"
	"encoding/csv"
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgxpool"

	"p9e.in/samavaya/packages/p9log"
)

// Sentinel errors returned by the exporter.
var (
	ErrTenantIDRequired  = errors.New("tenant_id is required")
	ErrInvalidFormat     = errors.New("format must be 'json' or 'csv'")
	ErrOutputDirRequired = errors.New("output_dir is required")
	ErrNoTables          = errors.New("no tables registered for export")
)

// PoolResolver returns a connection pool for the given tenant.
type PoolResolver interface {
	ResolvePool(ctx context.Context, tenantID string) (*pgxpool.Pool, error)
}

// RowIterator abstracts pgx.Rows so the write helpers can be tested without a
// real database connection.
type RowIterator interface {
	Next() bool
	Values() ([]any, error)
	FieldDescriptions() []pgconn.FieldDescription
	Err() error
	Close()
}

// Verify at compile time that pgx.Rows satisfies RowIterator.
var _ RowIterator = (pgx.Rows)(nil)

// TenantDataExporter exports all data for a specific tenant.
type TenantDataExporter struct {
	poolResolver PoolResolver
	tables       []TableConfig
}

// ExporterOption is a functional option for configuring TenantDataExporter.
type ExporterOption func(*TenantDataExporter)

// WithTables registers tables available for export.
func WithTables(tables ...TableConfig) ExporterOption {
	return func(e *TenantDataExporter) {
		e.tables = append(e.tables, tables...)
	}
}

// NewTenantDataExporter creates a new exporter with the given pool resolver and options.
func NewTenantDataExporter(poolResolver PoolResolver, opts ...ExporterOption) *TenantDataExporter {
	e := &TenantDataExporter{
		poolResolver: poolResolver,
	}
	for _, opt := range opts {
		opt(e)
	}
	return e
}

// Export runs the data export according to the request parameters.
func (e *TenantDataExporter) Export(ctx context.Context, req ExportRequest) (*ExportResult, error) {
	start := time.Now()

	if err := req.Validate(); err != nil {
		return nil, err
	}

	tables := e.tablesToExport(req.Tables)
	if len(tables) == 0 {
		return nil, ErrNoTables
	}

	// Ensure output directory exists.
	if err := os.MkdirAll(req.OutputDir, 0o755); err != nil {
		return nil, fmt.Errorf("create output directory: %w", err)
	}

	pool, err := e.poolResolver.ResolvePool(ctx, req.TenantID)
	if err != nil {
		return nil, fmt.Errorf("resolve pool: %w", err)
	}

	result := &ExportResult{
		TenantID: req.TenantID,
		Format:   req.Format,
		Since:    req.Since,
	}

	for _, table := range tables {
		exported, err := e.exportTable(ctx, pool, req, table)
		if err != nil {
			p9log.Errorf("export: table %s failed for tenant %s: %v", table.Name, req.TenantID, err)
			continue // Log and continue to export remaining tables.
		}
		result.Files = append(result.Files, *exported)
		result.TotalRows += exported.RowCount
	}

	result.Duration = time.Since(start)
	return result, nil
}

// tablesToExport filters registered tables by the request's table list.
func (e *TenantDataExporter) tablesToExport(requested []string) []TableConfig {
	if len(requested) == 0 {
		return e.tables
	}

	requestedSet := make(map[string]struct{}, len(requested))
	for _, t := range requested {
		requestedSet[t] = struct{}{}
	}

	var filtered []TableConfig
	for _, t := range e.tables {
		if _, ok := requestedSet[t.Name]; ok {
			filtered = append(filtered, t)
		}
	}
	return filtered
}

// exportTable queries a single table and writes the results to a file.
func (e *TenantDataExporter) exportTable(ctx context.Context, pool *pgxpool.Pool, req ExportRequest, table TableConfig) (*ExportedFile, error) {
	query, args := e.buildQuery(req, table)

	rows, err := pool.Query(ctx, query, args...)
	if err != nil {
		return nil, fmt.Errorf("query table %s: %w", table.Name, err)
	}
	defer rows.Close()

	ext := ".json"
	if req.Format == FormatCSV {
		ext = ".csv"
	}
	filePath := filepath.Join(req.OutputDir, table.Name+ext)

	f, err := os.Create(filePath)
	if err != nil {
		return nil, fmt.Errorf("create file %s: %w", filePath, err)
	}
	defer f.Close()

	var rowCount int64

	switch req.Format {
	case FormatJSON:
		rowCount, err = e.writeJSON(f, rows)
	case FormatCSV:
		rowCount, err = e.writeCSV(f, rows)
	}

	if err != nil {
		return nil, fmt.Errorf("write %s for table %s: %w", req.Format, table.Name, err)
	}

	info, err := f.Stat()
	if err != nil {
		return nil, fmt.Errorf("stat file %s: %w", filePath, err)
	}

	return &ExportedFile{
		TableName: table.Name,
		Path:      filePath,
		RowCount:  rowCount,
		SizeBytes: info.Size(),
	}, nil
}

// buildQuery constructs the SQL query for a table export.
func (e *TenantDataExporter) buildQuery(req ExportRequest, table TableConfig) (string, []any) {
	cols := table.effectiveColumns()
	tenantCol := table.effectiveTenantIDColumn()

	query := fmt.Sprintf("SELECT %s FROM %s WHERE %s = $1", cols, table.Name, tenantCol)
	args := []any{req.TenantID}

	if req.IsIncremental() {
		tsCol := table.effectiveTimestampColumn()
		query += fmt.Sprintf(" AND %s > $2", tsCol)
		args = append(args, *req.Since)
	}

	query += " ORDER BY " + table.effectiveTenantIDColumn()
	return query, args
}

// writeJSON writes query results as a JSON array to the given file.
func (e *TenantDataExporter) writeJSON(f *os.File, rows RowIterator) (int64, error) {
	fieldDescs := rows.FieldDescriptions()
	colNames := make([]string, len(fieldDescs))
	for i, fd := range fieldDescs {
		colNames[i] = fd.Name
	}

	encoder := json.NewEncoder(f)
	encoder.SetIndent("", "  ")

	if _, err := f.WriteString("[\n"); err != nil {
		return 0, err
	}

	var rowCount int64
	for rows.Next() {
		values, err := rows.Values()
		if err != nil {
			return rowCount, fmt.Errorf("scan values: %w", err)
		}

		record := make(map[string]any, len(colNames))
		for i, col := range colNames {
			record[col] = values[i]
		}

		if rowCount > 0 {
			if _, err := f.WriteString(",\n"); err != nil {
				return rowCount, err
			}
		}

		if err := encoder.Encode(record); err != nil {
			return rowCount, fmt.Errorf("encode row: %w", err)
		}
		rowCount++
	}

	if _, err := f.WriteString("]\n"); err != nil {
		return rowCount, err
	}

	return rowCount, rows.Err()
}

// writeCSV writes query results as CSV to the given file.
func (e *TenantDataExporter) writeCSV(f *os.File, rows RowIterator) (int64, error) {
	fieldDescs := rows.FieldDescriptions()
	colNames := make([]string, len(fieldDescs))
	for i, fd := range fieldDescs {
		colNames[i] = fd.Name
	}

	writer := csv.NewWriter(f)
	defer writer.Flush()

	// Write header row.
	if err := writer.Write(colNames); err != nil {
		return 0, fmt.Errorf("write header: %w", err)
	}

	var rowCount int64
	for rows.Next() {
		values, err := rows.Values()
		if err != nil {
			return rowCount, fmt.Errorf("scan values: %w", err)
		}

		record := make([]string, len(values))
		for i, v := range values {
			record[i] = fmt.Sprintf("%v", v)
		}

		if err := writer.Write(record); err != nil {
			return rowCount, fmt.Errorf("write row: %w", err)
		}
		rowCount++
	}

	return rowCount, rows.Err()
}
