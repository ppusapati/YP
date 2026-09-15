package realtime

import (
	"math"
	"testing"
	"time"
)

var mapNow = time.Date(2026, 3, 14, 9, 0, 0, 0, time.UTC)

func position() MachinePosition {
	return MachinePosition{
		MachineID:            "tractor-4",
		TenantID:             "tenant-1",
		FieldID:              "field-1",
		Kind:                 MachineTractor,
		Label:                "Tractor 4",
		Latitude:             20.1,
		Longitude:            77.3,
		HeadingDegrees:       142,
		SpeedMetersPerSecond: 2.4,
		AccuracyMeters:       3.5,
		RecordedAt:           mapNow.Add(-30 * time.Second),
	}
}

func TestMachinePosition_Valid(t *testing.T) {
	if err := position().Validate(mapNow); err != nil {
		t.Fatalf("a good position was refused: %v", err)
	}
}

func TestMachinePosition_RefusesNullIsland(t *testing.T) {
	// (0,0) is what a telematics unit reports before it has a fix. Drawing it
	// puts every unfixed machine in the Gulf of Guinea, which reads as a bug
	// in the map rather than in the device.
	p := position()
	p.Latitude, p.Longitude = 0, 0

	if err := p.Validate(mapNow); err != ErrInvalidPosition {
		t.Fatalf("expected ErrInvalidPosition, got %v", err)
	}
}

func TestMachinePosition_RefusesOffEarthCoordinates(t *testing.T) {
	for _, tc := range []struct {
		name     string
		lat, lng float64
	}{
		{"latitude past the pole", 91, 77},
		{"longitude past the date line", 20, 181},
		{"NaN latitude", math.NaN(), 77},
	} {
		t.Run(tc.name, func(t *testing.T) {
			p := position()
			p.Latitude, p.Longitude = tc.lat, tc.lng
			if err := p.Validate(mapNow); err != ErrInvalidPosition {
				t.Fatalf("expected ErrInvalidPosition, got %v", err)
			}
		})
	}
}

func TestMachinePosition_RefusesAStalePosition(t *testing.T) {
	// A live map showing where a tractor was two hours ago is not a live map;
	// it is a map that is wrong in a way nobody can see.
	p := position()
	p.RecordedAt = mapNow.Add(-MaxPositionAge - time.Second)

	if err := p.Validate(mapNow); err != ErrPositionTooOld {
		t.Fatalf("expected ErrPositionTooOld, got %v", err)
	}
}

func TestMachinePosition_AcceptsOneJustInsideTheWindow(t *testing.T) {
	// A telematics unit buffers while out of signal exactly as the phone does,
	// so a position that took a few minutes to arrive is normal.
	p := position()
	p.RecordedAt = mapNow.Add(-MaxPositionAge + time.Second)

	if err := p.Validate(mapNow); err != nil {
		t.Fatalf("a position inside the window was refused: %v", err)
	}
}

func TestMachinePosition_RefusesAMissingTimestamp(t *testing.T) {
	p := position()
	p.RecordedAt = time.Time{}

	if err := p.Validate(mapNow); err != ErrPositionTooOld {
		t.Fatalf("expected ErrPositionTooOld, got %v", err)
	}
}

func TestMachinePosition_RefusesAMissingTenant(t *testing.T) {
	// Without it the topic is unqualified, which both transports refuse —
	// caught here so the reason is named rather than appearing as silence.
	p := position()
	p.TenantID = ""

	if err := p.Validate(mapNow); err != ErrNoTenant {
		t.Fatalf("expected ErrNoTenant, got %v", err)
	}
}

func TestMachinePosition_RefusesAMissingMachine(t *testing.T) {
	p := position()
	p.MachineID = ""

	if err := p.Validate(mapNow); err != ErrUnknownMachine {
		t.Fatalf("expected ErrUnknownMachine, got %v", err)
	}
}

func TestMachinePosition_TopicIsTenantQualified(t *testing.T) {
	want := TenantTopic("tenant-1", FieldMapTopic("field-1"))
	if got := position().Topic(); got != want {
		t.Errorf("topic = %q, want %q", got, want)
	}
	if !TopicBelongsTo(position().Topic(), "tenant-1") {
		t.Error("the topic does not belong to the machine's own tenant")
	}
	if TopicBelongsTo(position().Topic(), "tenant-2") {
		t.Error("the topic is readable by another tenant")
	}
}

func TestMachinePosition_AsMemberCarriesTheFixTime(t *testing.T) {
	// The map's "who is in this field" list and its moving dots come from one
	// source, so they cannot disagree about whether a machine is still there.
	m := position().AsMember()

	if m.ID != "tractor-4" || m.Role != string(MachineTractor) {
		t.Errorf("member is wrong: %+v", m)
	}
	if !m.LastSeen.Equal(position().RecordedAt) {
		t.Error("presence would expire from arrival time rather than fix time")
	}
}

func overlay() ImageryOverlay {
	return ImageryOverlay{
		OverlayID:       "ov-1",
		TenantID:        "tenant-1",
		FieldID:         "field-1",
		Kind:            OverlayNDVI,
		TileURLTemplate: "https://tiles.example/ndvi/{z}/{x}/{y}.png",
		Bounds:          [4]float64{77.29, 20.09, 77.31, 20.11},
		CapturedAt:      mapNow.Add(-2 * time.Hour),
	}
}

func TestImageryOverlay_Valid(t *testing.T) {
	if err := overlay().Validate(); err != nil {
		t.Fatalf("a good overlay was refused: %v", err)
	}
}

func TestImageryOverlay_RefusesInvertedBounds(t *testing.T) {
	// West past east, or south past north, draws the layer inside out or not
	// at all — and a client cannot tell which from a blank map.
	for _, tc := range []struct {
		name   string
		bounds [4]float64
	}{
		{"west past east", [4]float64{77.31, 20.09, 77.29, 20.11}},
		{"south past north", [4]float64{77.29, 20.11, 77.31, 20.09}},
		{"zero width", [4]float64{77.3, 20.09, 77.3, 20.11}},
	} {
		t.Run(tc.name, func(t *testing.T) {
			o := overlay()
			o.Bounds = tc.bounds
			if err := o.Validate(); err != ErrInvalidOverlay {
				t.Fatalf("expected ErrInvalidOverlay, got %v", err)
			}
		})
	}
}

func TestImageryOverlay_RefusesOffEarthBounds(t *testing.T) {
	o := overlay()
	o.Bounds = [4]float64{77.29, 20.09, 77.31, 95}

	if err := o.Validate(); err != ErrInvalidOverlay {
		t.Fatalf("expected ErrInvalidOverlay, got %v", err)
	}
}

func TestImageryOverlay_RefusesAMissingTileTemplate(t *testing.T) {
	// The overlay carries where to fetch the tiles, not the tiles; without a
	// template the announcement tells a client nothing it can act on.
	o := overlay()
	o.TileURLTemplate = ""

	if err := o.Validate(); err != ErrInvalidOverlay {
		t.Fatalf("expected ErrInvalidOverlay, got %v", err)
	}
}

func TestImageryOverlay_RefusesAMissingTenant(t *testing.T) {
	o := overlay()
	o.TenantID = ""

	if err := o.Validate(); err != ErrNoTenant {
		t.Fatalf("expected ErrNoTenant, got %v", err)
	}
}

func TestImageryOverlay_TopicIsTenantQualified(t *testing.T) {
	want := TenantTopic("tenant-1", FieldMapTopic("field-1"))
	if got := overlay().Topic(); got != want {
		t.Errorf("topic = %q, want %q", got, want)
	}
}

func TestFieldMapAndInspectionTopicsDoNotCollide(t *testing.T) {
	// One id could name both a field and an inspection; the prefixes are what
	// stop a map subscriber receiving inspection edits.
	if FieldMapTopic("x") == InspectionTopic("x") {
		t.Fatal("field map and inspection topics collide")
	}
}
