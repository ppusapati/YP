package offboarding

import (
	"context"
	"encoding/json"
	"errors"
	"os"
	"path/filepath"
	"testing"
)

// These write and re-read real files, because what VerifyArchive is for is
// catching an archive that is not on disk the way it was recorded — and a
// fake filesystem would agree with whatever the code believed.

// stubArchive writes an archive directory by hand, so the tests can then
// damage it in specific ways.
func stubArchive(t *testing.T, rows int64, files []ManifestFile) (*ArchiveInfo, string) {
	t.Helper()
	dir := t.TempDir()

	for i := range files {
		body := make([]byte, files[i].Bytes)
		for j := range body {
			body[j] = 'x'
		}
		if err := os.WriteFile(filepath.Join(dir, files[i].Path), body, 0o640); err != nil {
			t.Fatalf("write %s: %v", files[i].Path, err)
		}
	}

	m := Manifest{TenantID: "t-1", Format: "json", TotalRows: rows, Files: files}
	for _, f := range files {
		m.TotalBytes += f.Bytes
	}
	raw, err := json.MarshalIndent(m, "", "  ")
	if err != nil {
		t.Fatalf("marshal manifest: %v", err)
	}
	if err := os.WriteFile(filepath.Join(dir, ManifestName), raw, 0o640); err != nil {
		t.Fatalf("write manifest: %v", err)
	}

	return &ArchiveInfo{
		Location: dir, Tables: len(files), Rows: rows,
		Bytes: m.TotalBytes, Checksum: checksumOf(raw),
	}, dir
}

func twoTables() []ManifestFile {
	return []ManifestFile{
		{Table: "farms", Path: "farms.json", Rows: 30, Bytes: 300},
		{Table: "fields", Path: "fields.json", Rows: 70, Bytes: 700},
	}
}

func TestAGoodArchiveVerifies(t *testing.T) {
	info, _ := stubArchive(t, 100, twoTables())
	if err := (&ExportArchiver{}).VerifyArchive(context.Background(), info); err != nil {
		t.Errorf("VerifyArchive: %v", err)
	}
}

func TestATamperedManifestFailsVerification(t *testing.T) {
	// The manifest is part of the archive, so trusting it would make the whole
	// check circular. This is what the checksum is for.
	info, dir := stubArchive(t, 100, twoTables())

	raw, _ := os.ReadFile(filepath.Join(dir, ManifestName))
	var m Manifest
	_ = json.Unmarshal(raw, &m)
	m.TotalRows = 999_999
	edited, _ := json.MarshalIndent(m, "", "  ")
	if err := os.WriteFile(filepath.Join(dir, ManifestName), edited, 0o640); err != nil {
		t.Fatalf("rewrite manifest: %v", err)
	}

	if err := (&ExportArchiver{}).VerifyArchive(context.Background(), info); err == nil {
		t.Error("a rewritten manifest verified successfully")
	}
}

func TestAMissingFileFailsVerification(t *testing.T) {
	// A manifest listing twelve tables and a directory holding eleven is the
	// failure that otherwise only shows up at restore time.
	info, dir := stubArchive(t, 100, twoTables())
	if err := os.Remove(filepath.Join(dir, "fields.json")); err != nil {
		t.Fatalf("remove: %v", err)
	}

	if err := (&ExportArchiver{}).VerifyArchive(context.Background(), info); err == nil {
		t.Error("an archive with a missing table verified successfully")
	}
}

func TestATruncatedFileFailsVerification(t *testing.T) {
	// The file is present, so a check that only stat'd for existence would
	// pass. Half a table is not a backup.
	info, dir := stubArchive(t, 100, twoTables())
	if err := os.WriteFile(filepath.Join(dir, "fields.json"), []byte("trunc"), 0o640); err != nil {
		t.Fatalf("truncate: %v", err)
	}

	if err := (&ExportArchiver{}).VerifyArchive(context.Background(), info); err == nil {
		t.Error("a truncated archive file verified successfully")
	}
}

func TestAnEmptyArchiveFailsVerification(t *testing.T) {
	info, _ := stubArchive(t, 0, nil)
	err := (&ExportArchiver{}).VerifyArchive(context.Background(), info)
	if !errors.Is(err, ErrArchiveEmpty) {
		t.Errorf("VerifyArchive on an empty archive returned %v, want ErrArchiveEmpty", err)
	}
}

func TestAVanishedArchiveFailsVerification(t *testing.T) {
	// The case the grace period makes likely: thirty days pass, and a cleanup
	// job has been over the directory in the meantime.
	info, dir := stubArchive(t, 100, twoTables())
	if err := os.RemoveAll(dir); err != nil {
		t.Fatalf("remove archive: %v", err)
	}

	if err := (&ExportArchiver{}).VerifyArchive(context.Background(), info); err == nil {
		t.Error("a missing archive directory verified successfully")
	}
}

func TestRowCountsMustAgreeWithTheRecord(t *testing.T) {
	// A manifest that is internally consistent but disagrees with what was
	// recorded means the archive is not the one the purge was approved against.
	info, _ := stubArchive(t, 100, twoTables())
	info.Rows = 250

	if err := (&ExportArchiver{}).VerifyArchive(context.Background(), info); err == nil {
		t.Error("an archive disagreeing with the record verified successfully")
	}
}

func TestPerFileRowsMustSumToTheTotal(t *testing.T) {
	// Catches a manifest assembled from a partial export: the header claims a
	// hundred rows and the files between them hold sixty.
	files := twoTables()
	files[1].Rows = 20 // 30 + 20 != 100
	info, _ := stubArchive(t, 100, files)

	if err := (&ExportArchiver{}).VerifyArchive(context.Background(), info); err == nil {
		t.Error("a manifest whose files do not sum to its total verified successfully")
	}
}

func TestVerifyRejectsAnArchiveWithNoLocation(t *testing.T) {
	a := &ExportArchiver{}
	if err := a.VerifyArchive(context.Background(), nil); !errors.Is(err, ErrNoVerifiedArchive) {
		t.Errorf("nil archive returned %v", err)
	}
	if err := a.VerifyArchive(context.Background(), &ArchiveInfo{}); !errors.Is(err, ErrNoVerifiedArchive) {
		t.Errorf("archive with no location returned %v", err)
	}
}

func TestManifestPathsAreRelative(t *testing.T) {
	// An absolute path would make the manifest a description of one machine
	// rather than of the archive, and break the moment it is moved to cold
	// storage.
	info, dir := stubArchive(t, 100, twoTables())
	raw, err := os.ReadFile(filepath.Join(info.Location, ManifestName))
	if err != nil {
		t.Fatalf("read manifest: %v", err)
	}
	var m Manifest
	if err := json.Unmarshal(raw, &m); err != nil {
		t.Fatalf("parse manifest: %v", err)
	}
	for _, f := range m.Files {
		if filepath.IsAbs(f.Path) {
			t.Errorf("manifest path %q is absolute", f.Path)
		}
	}
	_ = dir
}
