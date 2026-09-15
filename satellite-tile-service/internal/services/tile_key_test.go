package services

import (
	"testing"

	tilemodels "p9e.in/samavaya/agriculture/satellite-tile-service/internal/models"
)

// The key layout is not ours to choose: {prefix}/{z}/{x}/{y}.{ext} is the XYZ
// convention every renderer writes and every map client reads. Getting it
// wrong means every tile request misses, which — before this change — would
// have looked like a blank map rather than an error.

func TestTileKeyFollowsTheXYZConvention(t *testing.T) {
	got := tileKey("tenants/t-1/tilesets/ts-9", 12, 2048, 1365, tilemodels.TileFormatPNG)
	want := "tenants/t-1/tilesets/ts-9/12/2048/1365.png"
	if got != want {
		t.Errorf("tileKey = %q, want %q", got, want)
	}
}

func TestATrailingSlashOnThePrefixDoesNotDoubleUp(t *testing.T) {
	// A prefix stored with a trailing slash is easy to produce and would
	// otherwise yield ".../ts-9//12/...", which is a different key in S3 and
	// misses every time.
	got := tileKey("tenants/t-1/tilesets/ts-9/", 3, 4, 5, tilemodels.TileFormatPNG)
	want := "tenants/t-1/tilesets/ts-9/3/4/5.png"
	if got != want {
		t.Errorf("tileKey = %q, want %q", got, want)
	}
}

func TestEachFormatGetsItsConventionalExtension(t *testing.T) {
	cases := map[tilemodels.TileFormat]string{
		tilemodels.TileFormatPNG:  "png",
		tilemodels.TileFormatJPEG: "jpg", // not "jpeg": renderers write .jpg
		tilemodels.TileFormatWEBP: "webp",
		tilemodels.TileFormatMVT:  "pbf", // vector tiles are .pbf by convention
	}
	for format, ext := range cases {
		if got := tileExtension(format); got != ext {
			t.Errorf("tileExtension(%q) = %q, want %q", format, got, ext)
		}
	}
	// An unset format defaults to PNG rather than producing a key ending in a
	// bare dot, which would miss silently.
	if got := tileExtension(tilemodels.TileFormatUnspecified); got != "png" {
		t.Errorf("unspecified format gave extension %q, want png", got)
	}
}
