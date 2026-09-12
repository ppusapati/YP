package pipeline

import (
	"context"
	"crypto/sha256"
	"encoding/csv"
	"encoding/json"
	"fmt"
	"io"
	"time"
)

type ExportFormat string

const (
	ExportFormatCSV  ExportFormat = "csv"
	ExportFormatJSON ExportFormat = "json"
)

type ExportFilter struct {
	TenantID  string
	StartDate time.Time
	EndDate   time.Time
	DataTypes []string
}

type ExportManifest struct {
	ExportID   string            `json:"export_id"`
	TenantID   string            `json:"tenant_id"`
	ExportedAt time.Time         `json:"exported_at"`
	Format     ExportFormat      `json:"format"`
	Filter     ExportFilter      `json:"filter"`
	Files      []ExportFileEntry `json:"files"`
	TotalRows  int64             `json:"total_rows"`
	TotalBytes int64             `json:"total_bytes"`
}

type ExportFileEntry struct {
	DataType string `json:"data_type"`
	FileName string `json:"file_name"`
	Rows     int64  `json:"rows"`
	Bytes    int64  `json:"bytes"`
	Checksum string `json:"checksum"`
}

type ExportableDataSource interface {
	DataType() string
	Columns() []string
	Scan(ctx context.Context, filter ExportFilter, fn func(row []string) error) error
}

type DataExporter struct {
	sources []ExportableDataSource
}

func NewDataExporter(sources ...ExportableDataSource) *DataExporter {
	return &DataExporter{sources: sources}
}

func (e *DataExporter) Export(ctx context.Context, w io.Writer, format ExportFormat, filter ExportFilter) (*ExportManifest, error) {
	manifest := &ExportManifest{
		ExportID:   fmt.Sprintf("export-%d", time.Now().UnixNano()),
		TenantID:   filter.TenantID,
		ExportedAt: time.Now(),
		Format:     format,
		Filter:     filter,
	}

	for _, src := range e.sources {
		if len(filter.DataTypes) > 0 && !contains(filter.DataTypes, src.DataType()) {
			continue
		}

		var entry ExportFileEntry
		entry.DataType = src.DataType()
		entry.FileName = fmt.Sprintf("%s.%s", src.DataType(), format)

		hasher := sha256.New()
		counted := &countingWriter{w: io.MultiWriter(w, hasher)}

		var rowCount int64
		switch format {
		case ExportFormatCSV:
			err := e.exportCSV(ctx, counted, src, filter, &rowCount)
			if err != nil {
				return nil, fmt.Errorf("export %s as CSV: %w", src.DataType(), err)
			}
		case ExportFormatJSON:
			err := e.exportJSON(ctx, counted, src, filter, &rowCount)
			if err != nil {
				return nil, fmt.Errorf("export %s as JSON: %w", src.DataType(), err)
			}
		default:
			return nil, fmt.Errorf("unsupported format: %s", format)
		}

		entry.Rows = rowCount
		entry.Bytes = counted.n
		entry.Checksum = fmt.Sprintf("sha256:%x", hasher.Sum(nil))
		manifest.Files = append(manifest.Files, entry)
		manifest.TotalRows += rowCount
		manifest.TotalBytes += counted.n
	}

	return manifest, nil
}

func (e *DataExporter) exportCSV(ctx context.Context, w io.Writer, src ExportableDataSource, filter ExportFilter, rowCount *int64) error {
	cw := csv.NewWriter(w)
	defer cw.Flush()

	if err := cw.Write(src.Columns()); err != nil {
		return err
	}

	return src.Scan(ctx, filter, func(row []string) error {
		if ctx.Err() != nil {
			return ctx.Err()
		}
		*rowCount++
		return cw.Write(row)
	})
}

func (e *DataExporter) exportJSON(ctx context.Context, w io.Writer, src ExportableDataSource, filter ExportFilter, rowCount *int64) error {
	columns := src.Columns()
	enc := json.NewEncoder(w)

	if _, err := w.Write([]byte("[\n")); err != nil {
		return err
	}

	first := true
	err := src.Scan(ctx, filter, func(row []string) error {
		if ctx.Err() != nil {
			return ctx.Err()
		}

		if !first {
			if _, err := w.Write([]byte(",\n")); err != nil {
				return err
			}
		}
		first = false
		*rowCount++

		record := make(map[string]string, len(columns))
		for i, col := range columns {
			if i < len(row) {
				record[col] = row[i]
			}
		}
		return enc.Encode(record)
	})
	if err != nil {
		return err
	}

	_, err = w.Write([]byte("\n]"))
	return err
}

type countingWriter struct {
	w io.Writer
	n int64
}

func (cw *countingWriter) Write(p []byte) (int, error) {
	n, err := cw.w.Write(p)
	cw.n += int64(n)
	return n, err
}

func contains(slice []string, item string) bool {
	for _, s := range slice {
		if s == item {
			return true
		}
	}
	return false
}
