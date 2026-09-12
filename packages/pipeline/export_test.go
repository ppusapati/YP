package pipeline

import (
	"bytes"
	"context"
	"encoding/csv"
	"encoding/json"
	"strings"
	"testing"
	"time"
)

type mockDataSource struct {
	dataType string
	columns  []string
	rows     [][]string
}

func (m *mockDataSource) DataType() string   { return m.dataType }
func (m *mockDataSource) Columns() []string  { return m.columns }
func (m *mockDataSource) Scan(ctx context.Context, filter ExportFilter, fn func(row []string) error) error {
	for _, row := range m.rows {
		if err := fn(row); err != nil {
			return err
		}
	}
	return nil
}

func TestDataExporter_ExportCSV(t *testing.T) {
	src := &mockDataSource{
		dataType: "sensor_readings",
		columns:  []string{"id", "field_id", "value", "timestamp"},
		rows: [][]string{
			{"1", "field-1", "25.3", "2024-01-01T00:00:00Z"},
			{"2", "field-1", "26.1", "2024-01-01T01:00:00Z"},
			{"3", "field-2", "22.8", "2024-01-01T00:00:00Z"},
		},
	}

	exporter := NewDataExporter(src)
	var buf bytes.Buffer
	manifest, err := exporter.Export(context.Background(), &buf, ExportFormatCSV, ExportFilter{
		TenantID: "tenant-1",
	})
	if err != nil {
		t.Fatal(err)
	}

	if manifest.TotalRows != 3 {
		t.Errorf("expected 3 rows, got %d", manifest.TotalRows)
	}
	if manifest.TenantID != "tenant-1" {
		t.Errorf("expected tenant-1, got %s", manifest.TenantID)
	}
	if manifest.Format != ExportFormatCSV {
		t.Errorf("expected csv format, got %s", manifest.Format)
	}
	if len(manifest.Files) != 1 {
		t.Fatalf("expected 1 file entry, got %d", len(manifest.Files))
	}
	if manifest.Files[0].DataType != "sensor_readings" {
		t.Errorf("expected sensor_readings data type, got %s", manifest.Files[0].DataType)
	}
	if manifest.Files[0].FileName != "sensor_readings.csv" {
		t.Errorf("expected sensor_readings.csv, got %s", manifest.Files[0].FileName)
	}
	if !strings.HasPrefix(manifest.Files[0].Checksum, "sha256:") {
		t.Error("checksum should start with sha256:")
	}
	if manifest.TotalBytes == 0 {
		t.Error("total bytes should be > 0")
	}

	reader := csv.NewReader(strings.NewReader(buf.String()))
	records, err := reader.ReadAll()
	if err != nil {
		t.Fatal(err)
	}
	if len(records) != 4 {
		t.Errorf("expected 4 CSV records (1 header + 3 data), got %d", len(records))
	}
	if records[0][0] != "id" {
		t.Errorf("expected header 'id', got %s", records[0][0])
	}
}

func TestDataExporter_ExportJSON(t *testing.T) {
	src := &mockDataSource{
		dataType: "yields",
		columns:  []string{"field_id", "crop", "yield_kg"},
		rows: [][]string{
			{"field-1", "wheat", "5200"},
			{"field-2", "corn", "8100"},
		},
	}

	exporter := NewDataExporter(src)
	var buf bytes.Buffer
	manifest, err := exporter.Export(context.Background(), &buf, ExportFormatJSON, ExportFilter{
		TenantID: "tenant-2",
	})
	if err != nil {
		t.Fatal(err)
	}

	if manifest.TotalRows != 2 {
		t.Errorf("expected 2 rows, got %d", manifest.TotalRows)
	}
	if manifest.Files[0].FileName != "yields.json" {
		t.Errorf("expected yields.json, got %s", manifest.Files[0].FileName)
	}

	output := buf.String()
	if !strings.HasPrefix(output, "[") {
		t.Error("JSON output should start with [")
	}
	if !strings.HasSuffix(strings.TrimSpace(output), "]") {
		t.Error("JSON output should end with ]")
	}

	trimmed := strings.TrimSpace(output)
	trimmed = strings.TrimPrefix(trimmed, "[\n")
	trimmed = strings.TrimSuffix(trimmed, "\n]")
	parts := strings.Split(trimmed, ",\n")

	if len(parts) != 2 {
		t.Fatalf("expected 2 JSON records, got %d", len(parts))
	}

	var record map[string]string
	if err := json.Unmarshal([]byte(parts[0]), &record); err != nil {
		t.Fatalf("failed to parse JSON record: %v", err)
	}
	if record["crop"] != "wheat" {
		t.Errorf("expected crop wheat, got %s", record["crop"])
	}
}

func TestDataExporter_MultipleSources(t *testing.T) {
	src1 := &mockDataSource{
		dataType: "sensors",
		columns:  []string{"id", "value"},
		rows:     [][]string{{"1", "10"}, {"2", "20"}},
	}
	src2 := &mockDataSource{
		dataType: "yields",
		columns:  []string{"id", "amount"},
		rows:     [][]string{{"1", "5000"}},
	}

	exporter := NewDataExporter(src1, src2)
	var buf bytes.Buffer
	manifest, err := exporter.Export(context.Background(), &buf, ExportFormatCSV, ExportFilter{
		TenantID: "tenant-1",
	})
	if err != nil {
		t.Fatal(err)
	}

	if len(manifest.Files) != 2 {
		t.Errorf("expected 2 file entries, got %d", len(manifest.Files))
	}
	if manifest.TotalRows != 3 {
		t.Errorf("expected 3 total rows, got %d", manifest.TotalRows)
	}
	if manifest.Files[0].Rows != 2 {
		t.Errorf("expected 2 rows for sensors, got %d", manifest.Files[0].Rows)
	}
	if manifest.Files[1].Rows != 1 {
		t.Errorf("expected 1 row for yields, got %d", manifest.Files[1].Rows)
	}
}

func TestDataExporter_DataTypeFilter(t *testing.T) {
	src1 := &mockDataSource{
		dataType: "sensors",
		columns:  []string{"id"},
		rows:     [][]string{{"1"}},
	}
	src2 := &mockDataSource{
		dataType: "yields",
		columns:  []string{"id"},
		rows:     [][]string{{"1"}},
	}

	exporter := NewDataExporter(src1, src2)
	var buf bytes.Buffer
	manifest, err := exporter.Export(context.Background(), &buf, ExportFormatCSV, ExportFilter{
		TenantID:  "tenant-1",
		DataTypes: []string{"sensors"},
	})
	if err != nil {
		t.Fatal(err)
	}

	if len(manifest.Files) != 1 {
		t.Errorf("expected 1 file entry (filtered), got %d", len(manifest.Files))
	}
	if manifest.Files[0].DataType != "sensors" {
		t.Errorf("expected sensors, got %s", manifest.Files[0].DataType)
	}
}

func TestDataExporter_UnsupportedFormat(t *testing.T) {
	src := &mockDataSource{
		dataType: "test",
		columns:  []string{"id"},
		rows:     [][]string{{"1"}},
	}

	exporter := NewDataExporter(src)
	var buf bytes.Buffer
	_, err := exporter.Export(context.Background(), &buf, ExportFormat("xml"), ExportFilter{})
	if err == nil {
		t.Error("expected error for unsupported format")
	}
}

func TestDataExporter_EmptySource(t *testing.T) {
	src := &mockDataSource{
		dataType: "empty",
		columns:  []string{"id", "value"},
		rows:     nil,
	}

	exporter := NewDataExporter(src)
	var buf bytes.Buffer
	manifest, err := exporter.Export(context.Background(), &buf, ExportFormatCSV, ExportFilter{})
	if err != nil {
		t.Fatal(err)
	}

	if manifest.TotalRows != 0 {
		t.Errorf("expected 0 rows, got %d", manifest.TotalRows)
	}
}

func TestDataExporter_ContextCancellation(t *testing.T) {
	src := &mockDataSource{
		dataType: "test",
		columns:  []string{"id"},
		rows:     [][]string{{"1"}, {"2"}, {"3"}},
	}

	ctx, cancel := context.WithCancel(context.Background())
	cancel()

	exporter := NewDataExporter(src)
	var buf bytes.Buffer
	_, err := exporter.Export(ctx, &buf, ExportFormatCSV, ExportFilter{})
	if err == nil {
		t.Error("expected error from cancelled context")
	}
}

func TestDataExporter_ManifestFields(t *testing.T) {
	src := &mockDataSource{
		dataType: "test",
		columns:  []string{"id"},
		rows:     [][]string{{"1"}},
	}

	exporter := NewDataExporter(src)
	var buf bytes.Buffer
	now := time.Now()
	manifest, err := exporter.Export(context.Background(), &buf, ExportFormatCSV, ExportFilter{
		TenantID:  "tenant-abc",
		StartDate: now.Add(-24 * time.Hour),
		EndDate:   now,
	})
	if err != nil {
		t.Fatal(err)
	}

	if !strings.HasPrefix(manifest.ExportID, "export-") {
		t.Errorf("export ID should start with export-, got %s", manifest.ExportID)
	}
	if manifest.TenantID != "tenant-abc" {
		t.Errorf("expected tenant-abc, got %s", manifest.TenantID)
	}
	if manifest.ExportedAt.IsZero() {
		t.Error("ExportedAt should not be zero")
	}
}

func TestCountingWriter(t *testing.T) {
	var buf bytes.Buffer
	cw := &countingWriter{w: &buf}

	n, err := cw.Write([]byte("hello"))
	if err != nil {
		t.Fatal(err)
	}
	if n != 5 {
		t.Errorf("expected 5 bytes written, got %d", n)
	}
	if cw.n != 5 {
		t.Errorf("expected count 5, got %d", cw.n)
	}

	n, err = cw.Write([]byte(" world"))
	if err != nil {
		t.Fatal(err)
	}
	if cw.n != 11 {
		t.Errorf("expected count 11, got %d", cw.n)
	}
}

func TestContains(t *testing.T) {
	tests := []struct {
		slice []string
		item  string
		want  bool
	}{
		{[]string{"a", "b", "c"}, "b", true},
		{[]string{"a", "b", "c"}, "d", false},
		{nil, "a", false},
		{[]string{}, "a", false},
		{[]string{"sensors"}, "sensors", true},
	}

	for _, tt := range tests {
		got := contains(tt.slice, tt.item)
		if got != tt.want {
			t.Errorf("contains(%v, %q) = %v, want %v", tt.slice, tt.item, got, tt.want)
		}
	}
}
