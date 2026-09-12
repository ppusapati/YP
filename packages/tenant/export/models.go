package export

import "time"

// ExportFormat specifies the output format for tenant data export.
type ExportFormat string

const (
	// FormatJSON exports data as JSON.
	FormatJSON ExportFormat = "json"
	// FormatCSV exports data as CSV.
	FormatCSV ExportFormat = "csv"
)

// ExportRequest describes what data to export for a tenant.
type ExportRequest struct {
	// TenantID is the tenant whose data is being exported.
	TenantID string `json:"tenant_id"`
	// Format is the desired output format (json or csv).
	Format ExportFormat `json:"format"`
	// Since, when set, limits the export to records created or updated after this time.
	// A zero value means export all data.
	Since *time.Time `json:"since,omitempty"`
	// Tables limits the export to specific table names. Empty means all registered tables.
	Tables []string `json:"tables,omitempty"`
	// OutputDir is the directory where export files are written.
	OutputDir string `json:"output_dir"`
}

// Validate checks that required fields are present.
func (r *ExportRequest) Validate() error {
	if r.TenantID == "" {
		return ErrTenantIDRequired
	}
	if r.Format != FormatJSON && r.Format != FormatCSV {
		return ErrInvalidFormat
	}
	if r.OutputDir == "" {
		return ErrOutputDirRequired
	}
	return nil
}

// IsIncremental returns true if this is a since-timestamp incremental export.
func (r *ExportRequest) IsIncremental() bool {
	return r.Since != nil && !r.Since.IsZero()
}

// ExportResult summarizes the outcome of a tenant data export.
type ExportResult struct {
	// TenantID is the tenant whose data was exported.
	TenantID string `json:"tenant_id"`
	// Format is the format used.
	Format ExportFormat `json:"format"`
	// Files lists all files produced by the export.
	Files []ExportedFile `json:"files"`
	// TotalRows is the total number of data rows exported across all tables.
	TotalRows int64 `json:"total_rows"`
	// Duration is how long the export took.
	Duration time.Duration `json:"duration"`
	// Since is the incremental boundary if provided.
	Since *time.Time `json:"since,omitempty"`
}

// ExportedFile describes a single file produced by the export.
type ExportedFile struct {
	// TableName is the source table that was exported.
	TableName string `json:"table_name"`
	// Path is the file path on disk.
	Path string `json:"path"`
	// RowCount is the number of rows in this file.
	RowCount int64 `json:"row_count"`
	// SizeBytes is the file size in bytes.
	SizeBytes int64 `json:"size_bytes"`
}

// TableConfig registers a table for export.
type TableConfig struct {
	// Name is the table name.
	Name string
	// TenantIDColumn is the column used to filter by tenant_id (defaults to "tenant_id").
	TenantIDColumn string
	// TimestampColumn is the column used for incremental export (defaults to "updated_at").
	TimestampColumn string
	// Columns lists the columns to export. Empty means all columns ("*").
	Columns []string
}

// effectiveTenantIDColumn returns the tenant ID column, defaulting to "tenant_id".
func (tc *TableConfig) effectiveTenantIDColumn() string {
	if tc.TenantIDColumn != "" {
		return tc.TenantIDColumn
	}
	return "tenant_id"
}

// effectiveTimestampColumn returns the timestamp column, defaulting to "updated_at".
func (tc *TableConfig) effectiveTimestampColumn() string {
	if tc.TimestampColumn != "" {
		return tc.TimestampColumn
	}
	return "updated_at"
}

// effectiveColumns returns the column selection, defaulting to "*".
func (tc *TableConfig) effectiveColumns() string {
	if len(tc.Columns) == 0 {
		return "*"
	}
	result := ""
	for i, col := range tc.Columns {
		if i > 0 {
			result += ", "
		}
		result += col
	}
	return result
}
