package offboarding

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"

	"fmt"
	"os"
	"path/filepath"
	"sort"
	"time"

	"p9e.in/samavaya/packages/tenant/export"
)

// ExportArchiver is the Archiver backed by packages/tenant/export.
//
// It exists so the Archiver interface has an implementation rather than only a
// shape. The export package already knows how to pull a tenant's rows out of
// every registered table; what archiving adds is a manifest and a checksum,
// because the question a purge has to answer is not "did an export run" but
// "is that data still on disk, intact, right now".
type ExportArchiver struct {
	exporter *export.TenantDataExporter
	format   export.ExportFormat
}

// NewExportArchiver wraps an exporter.
//
// JSON by default rather than CSV: an archive is read by whoever has to restore
// or answer a data-subject request, often years later and with no schema to
// hand, and CSV loses the distinction between an empty string, a null and a
// nested value.
func NewExportArchiver(exporter *export.TenantDataExporter) *ExportArchiver {
	return &ExportArchiver{exporter: exporter, format: export.FormatJSON}
}

// Manifest describes an archive's contents, written beside the data.
type Manifest struct {
	TenantID   string         `json:"tenant_id"`
	CreatedAt  time.Time      `json:"created_at"`
	Format     string         `json:"format"`
	TotalRows  int64          `json:"total_rows"`
	TotalBytes int64          `json:"total_bytes"`
	Files      []ManifestFile `json:"files"`
}

// ManifestFile records one exported table.
type ManifestFile struct {
	Table string `json:"table"`
	Path  string `json:"path"`
	Rows  int64  `json:"rows"`
	Bytes int64  `json:"bytes"`
}

// ManifestName is the manifest's filename inside an archive directory.
const ManifestName = "manifest.json"

// Archive exports every table for a tenant and writes a manifest.
func (a *ExportArchiver) Archive(ctx context.Context, tenantID, destination string) (*ArchiveInfo, error) {
	if err := os.MkdirAll(destination, 0o750); err != nil {
		return nil, fmt.Errorf("create archive directory: %w", err)
	}

	result, err := a.exporter.Export(ctx, export.ExportRequest{
		TenantID:  tenantID,
		Format:    a.format,
		OutputDir: destination,
	})
	if err != nil {
		return nil, fmt.Errorf("export tenant data: %w", err)
	}

	manifest := Manifest{
		TenantID:  tenantID,
		CreatedAt: time.Now().UTC(),
		Format:    string(a.format),
		TotalRows: result.TotalRows,
	}
	for _, f := range result.Files {
		manifest.TotalBytes += f.SizeBytes
		manifest.Files = append(manifest.Files, ManifestFile{
			Table: f.TableName,
			// Relative, so an archive stays valid after it is moved to cold
			// storage — an absolute path here would make the manifest a
			// description of one machine rather than of the archive.
			Path:  filepath.Base(f.Path),
			Rows:  f.RowCount,
			Bytes: f.SizeBytes,
		})
	}
	// Sorted so the checksum depends on the contents and not on the order the
	// exporter happened to walk the tables in.
	sort.Slice(manifest.Files, func(i, j int) bool {
		return manifest.Files[i].Table < manifest.Files[j].Table
	})

	checksum, err := a.writeManifest(destination, manifest)
	if err != nil {
		return nil, err
	}

	return &ArchiveInfo{
		Location:  destination,
		Tables:    len(manifest.Files),
		Rows:      manifest.TotalRows,
		Bytes:     manifest.TotalBytes,
		Checksum:  checksum,
		CreatedAt: manifest.CreatedAt,
	}, nil
}

// VerifyArchive re-reads an archive and confirms it matches what was recorded.
//
// Checked against the manifest rather than trusting it: the manifest is part of
// the archive, so a corrupted or truncated one is exactly the case this is
// meant to catch. Every file is stat'd, because a manifest listing twelve
// tables and a directory holding eleven is the failure that only shows up at
// restore time.
func (a *ExportArchiver) VerifyArchive(_ context.Context, info *ArchiveInfo) error {
	if info == nil || info.Location == "" {
		return ErrNoVerifiedArchive
	}

	raw, err := os.ReadFile(filepath.Join(info.Location, ManifestName))
	if err != nil {
		return fmt.Errorf("read manifest: %w", err)
	}
	if got := checksumOf(raw); got != info.Checksum {
		return fmt.Errorf("manifest checksum is %s, recorded as %s: the archive has changed since it was written",
			got, info.Checksum)
	}

	var manifest Manifest
	if err := json.Unmarshal(raw, &manifest); err != nil {
		return fmt.Errorf("parse manifest: %w", err)
	}
	if manifest.TotalRows == 0 || len(manifest.Files) == 0 {
		return ErrArchiveEmpty
	}
	if manifest.TotalRows != info.Rows {
		return fmt.Errorf("manifest reports %d rows, record says %d", manifest.TotalRows, info.Rows)
	}

	var seen int64
	for _, f := range manifest.Files {
		st, err := os.Stat(filepath.Join(info.Location, f.Path))
		if err != nil {
			return fmt.Errorf("archive file %s: %w", f.Path, err)
		}
		if st.Size() != f.Bytes {
			return fmt.Errorf("archive file %s is %d bytes, manifest says %d",
				f.Path, st.Size(), f.Bytes)
		}
		seen += f.Rows
	}
	if seen != manifest.TotalRows {
		return fmt.Errorf("per-file rows sum to %d, manifest total is %d", seen, manifest.TotalRows)
	}
	return nil
}

func (a *ExportArchiver) writeManifest(destination string, m Manifest) (string, error) {
	raw, err := json.MarshalIndent(m, "", "  ")
	if err != nil {
		return "", fmt.Errorf("encode manifest: %w", err)
	}
	path := filepath.Join(destination, ManifestName)
	if err := os.WriteFile(path, raw, 0o640); err != nil {
		return "", fmt.Errorf("write manifest: %w", err)
	}
	return checksumOf(raw), nil
}

func checksumOf(b []byte) string {
	sum := sha256.Sum256(b)
	return hex.EncodeToString(sum[:])
}

// Compile-time check that the concrete archiver satisfies the port.
var _ Archiver = (*ExportArchiver)(nil)
