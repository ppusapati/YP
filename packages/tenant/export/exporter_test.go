package export

import (
	"context"
	"encoding/csv"
	"encoding/json"
	"os"
	"path/filepath"
	"testing"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// --- Mock implementations ---

type mockPoolResolver struct {
	pool *pgxpool.Pool
	err  error
}

func (m *mockPoolResolver) ResolvePool(_ context.Context, _ string) (*pgxpool.Pool, error) {
	if m.err != nil {
		return nil, m.err
	}
	return m.pool, nil
}

// mockRows simulates pgx query results for testing.
type mockRows struct {
	columns []pgxFieldDescription
	data    [][]any
	index   int
	closed  bool
}

func newMockRows(colNames []string, data [][]any) *mockRows {
	cols := make([]pgxFieldDescription, len(colNames))
	for i, name := range colNames {
		cols[i] = pgxFieldDescription{Name: []byte(name)}
	}
	return &mockRows{
		columns: cols,
		data:    data,
		index:   -1,
	}
}

func (r *mockRows) Next() bool {
	r.index++
	return r.index < len(r.data)
}

func (r *mockRows) Values() ([]any, error) {
	if r.index < 0 || r.index >= len(r.data) {
		return nil, nil
	}
	return r.data[r.index], nil
}

func (r *mockRows) FieldDescriptions() []pgxFieldDescription {
	return r.columns
}

func (r *mockRows) Err() error {
	return nil
}

func (r *mockRows) Close() {
	r.closed = true
}

// --- Tests ---

func TestExportRequest_Validate(t *testing.T) {
	tests := []struct {
		name    string
		req     ExportRequest
		wantErr error
	}{
		{
			name:    "valid JSON request",
			req:     ExportRequest{TenantID: "t1", Format: FormatJSON, OutputDir: "/tmp/export"},
			wantErr: nil,
		},
		{
			name:    "valid CSV request",
			req:     ExportRequest{TenantID: "t1", Format: FormatCSV, OutputDir: "/tmp/export"},
			wantErr: nil,
		},
		{
			name:    "missing tenant ID",
			req:     ExportRequest{Format: FormatJSON, OutputDir: "/tmp/export"},
			wantErr: ErrTenantIDRequired,
		},
		{
			name:    "invalid format",
			req:     ExportRequest{TenantID: "t1", Format: "xml", OutputDir: "/tmp/export"},
			wantErr: ErrInvalidFormat,
		},
		{
			name:    "missing output dir",
			req:     ExportRequest{TenantID: "t1", Format: FormatJSON},
			wantErr: ErrOutputDirRequired,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := tt.req.Validate()
			if tt.wantErr != nil {
				assert.ErrorIs(t, err, tt.wantErr)
			} else {
				assert.NoError(t, err)
			}
		})
	}
}

func TestExportRequest_IsIncremental(t *testing.T) {
	now := time.Now()
	assert.True(t, (&ExportRequest{Since: &now}).IsIncremental())
	assert.False(t, (&ExportRequest{}).IsIncremental())

	zero := time.Time{}
	assert.False(t, (&ExportRequest{Since: &zero}).IsIncremental())
}

func TestTableConfig_Defaults(t *testing.T) {
	tc := TableConfig{Name: "users"}

	assert.Equal(t, "tenant_id", tc.effectiveTenantIDColumn())
	assert.Equal(t, "updated_at", tc.effectiveTimestampColumn())
	assert.Equal(t, "*", tc.effectiveColumns())
}

func TestTableConfig_CustomValues(t *testing.T) {
	tc := TableConfig{
		Name:            "custom_table",
		TenantIDColumn:  "org_id",
		TimestampColumn: "modified_at",
		Columns:         []string{"id", "name", "value"},
	}

	assert.Equal(t, "org_id", tc.effectiveTenantIDColumn())
	assert.Equal(t, "modified_at", tc.effectiveTimestampColumn())
	assert.Equal(t, "id, name, value", tc.effectiveColumns())
}

func TestTenantDataExporter_BuildQuery_FullExport(t *testing.T) {
	e := NewTenantDataExporter(&mockPoolResolver{})

	table := TableConfig{Name: "users"}
	req := ExportRequest{TenantID: "t1", Format: FormatJSON, OutputDir: "/tmp"}

	query, args := e.buildQuery(req, table)

	assert.Contains(t, query, "SELECT * FROM users WHERE tenant_id = $1")
	assert.Equal(t, []any{"t1"}, args)
}

func TestTenantDataExporter_BuildQuery_IncrementalExport(t *testing.T) {
	e := NewTenantDataExporter(&mockPoolResolver{})

	since := time.Date(2025, 1, 15, 0, 0, 0, 0, time.UTC)
	table := TableConfig{Name: "orders", TimestampColumn: "modified_at"}
	req := ExportRequest{
		TenantID:  "t1",
		Format:    FormatJSON,
		OutputDir: "/tmp",
		Since:     &since,
	}

	query, args := e.buildQuery(req, table)

	assert.Contains(t, query, "SELECT * FROM orders WHERE tenant_id = $1")
	assert.Contains(t, query, "AND modified_at > $2")
	assert.Equal(t, "t1", args[0])
	assert.Equal(t, since, args[1])
}

func TestTenantDataExporter_BuildQuery_CustomColumns(t *testing.T) {
	e := NewTenantDataExporter(&mockPoolResolver{})

	table := TableConfig{
		Name:           "fields",
		TenantIDColumn: "org_id",
		Columns:        []string{"id", "name", "area_ha"},
	}
	req := ExportRequest{TenantID: "t1", Format: FormatCSV, OutputDir: "/tmp"}

	query, args := e.buildQuery(req, table)

	assert.Contains(t, query, "SELECT id, name, area_ha FROM fields WHERE org_id = $1")
	assert.Equal(t, []any{"t1"}, args)
}

func TestTenantDataExporter_WriteJSON(t *testing.T) {
	e := NewTenantDataExporter(&mockPoolResolver{})

	rows := newMockRows(
		[]string{"id", "name"},
		[][]any{
			{"1", "Alice"},
			{"2", "Bob"},
		},
	)

	tmpDir := t.TempDir()
	filePath := filepath.Join(tmpDir, "test.json")
	f, err := os.Create(filePath)
	require.NoError(t, err)

	count, err := e.writeJSON(f, rows)
	require.NoError(t, err)
	f.Close()

	assert.Equal(t, int64(2), count)

	// Verify the file contains valid JSON with the expected data.
	data, err := os.ReadFile(filePath)
	require.NoError(t, err)

	var records []map[string]any
	err = json.Unmarshal(data, &records)
	require.NoError(t, err)
	assert.Len(t, records, 2)
	assert.Equal(t, "Alice", records[0]["name"])
	assert.Equal(t, "Bob", records[1]["name"])
}

func TestTenantDataExporter_WriteCSV(t *testing.T) {
	e := NewTenantDataExporter(&mockPoolResolver{})

	rows := newMockRows(
		[]string{"id", "name", "value"},
		[][]any{
			{"1", "Field A", 42},
			{"2", "Field B", 99},
		},
	)

	tmpDir := t.TempDir()
	filePath := filepath.Join(tmpDir, "test.csv")
	f, err := os.Create(filePath)
	require.NoError(t, err)

	count, err := e.writeCSV(f, rows)
	require.NoError(t, err)
	f.Close()

	assert.Equal(t, int64(2), count)

	// Verify the CSV content.
	data, err := os.Open(filePath)
	require.NoError(t, err)
	defer data.Close()

	reader := csv.NewReader(data)
	records, err := reader.ReadAll()
	require.NoError(t, err)

	// Header + 2 data rows.
	assert.Len(t, records, 3)
	assert.Equal(t, []string{"id", "name", "value"}, records[0])
	assert.Equal(t, "Field A", records[1][1])
	assert.Equal(t, "99", records[2][2])
}

func TestTenantDataExporter_WriteJSON_EmptyRows(t *testing.T) {
	e := NewTenantDataExporter(&mockPoolResolver{})
	rows := newMockRows([]string{"id"}, nil)

	tmpDir := t.TempDir()
	filePath := filepath.Join(tmpDir, "empty.json")
	f, err := os.Create(filePath)
	require.NoError(t, err)

	count, err := e.writeJSON(f, rows)
	require.NoError(t, err)
	f.Close()

	assert.Equal(t, int64(0), count)

	data, err := os.ReadFile(filePath)
	require.NoError(t, err)

	var records []map[string]any
	err = json.Unmarshal(data, &records)
	require.NoError(t, err)
	assert.Empty(t, records)
}

func TestTenantDataExporter_WriteCSV_EmptyRows(t *testing.T) {
	e := NewTenantDataExporter(&mockPoolResolver{})
	rows := newMockRows([]string{"id", "name"}, nil)

	tmpDir := t.TempDir()
	filePath := filepath.Join(tmpDir, "empty.csv")
	f, err := os.Create(filePath)
	require.NoError(t, err)

	count, err := e.writeCSV(f, rows)
	require.NoError(t, err)
	f.Close()

	assert.Equal(t, int64(0), count)

	// Should still have the header row.
	data, err := os.Open(filePath)
	require.NoError(t, err)
	defer data.Close()

	reader := csv.NewReader(data)
	records, err := reader.ReadAll()
	require.NoError(t, err)
	assert.Len(t, records, 1) // Header only.
	assert.Equal(t, []string{"id", "name"}, records[0])
}

func TestTenantDataExporter_TableFiltering(t *testing.T) {
	tables := []TableConfig{
		{Name: "users"},
		{Name: "fields"},
		{Name: "orders"},
		{Name: "settings"},
	}

	e := NewTenantDataExporter(&mockPoolResolver{}, WithTables(tables...))

	// Export all tables.
	all := e.tablesToExport(nil)
	assert.Len(t, all, 4)

	// Export specific tables.
	filtered := e.tablesToExport([]string{"users", "orders"})
	assert.Len(t, filtered, 2)
	assert.Equal(t, "users", filtered[0].Name)
	assert.Equal(t, "orders", filtered[1].Name)

	// Export non-existent table.
	missing := e.tablesToExport([]string{"nonexistent"})
	assert.Empty(t, missing)
}

func TestExport_ValidationFailure(t *testing.T) {
	e := NewTenantDataExporter(&mockPoolResolver{}, WithTables(TableConfig{Name: "users"}))

	_, err := e.Export(context.Background(), ExportRequest{})
	assert.Error(t, err)
}

func TestExport_NoTables(t *testing.T) {
	e := NewTenantDataExporter(&mockPoolResolver{})

	_, err := e.Export(context.Background(), ExportRequest{
		TenantID:  "t1",
		Format:    FormatJSON,
		OutputDir: t.TempDir(),
	})
	assert.ErrorIs(t, err, ErrNoTables)
}

func TestExport_PoolResolverError(t *testing.T) {
	e := NewTenantDataExporter(
		&mockPoolResolver{err: assert.AnError},
		WithTables(TableConfig{Name: "users"}),
	)

	_, err := e.Export(context.Background(), ExportRequest{
		TenantID:  "t1",
		Format:    FormatJSON,
		OutputDir: t.TempDir(),
	})
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "resolve pool")
}
