package models

import "testing"

func TestSatelliteProvider_IsValid(t *testing.T) {
	valid := []SatelliteProvider{SatelliteProviderSentinel2, SatelliteProviderLandsat, SatelliteProviderPlanetScope, SatelliteProviderUAV}
	for _, p := range valid {
		if !p.IsValid() {
			t.Errorf("%s should be valid", p)
		}
	}
	if SatelliteProviderUnspecified.IsValid() || SatelliteProvider("MODIS").IsValid() {
		t.Error("unknown providers must be invalid")
	}
}

func TestProcessingLevel(t *testing.T) {
	cases := map[ProcessingLevel]struct{ valid, sr bool }{
		ProcessingLevelL2A:     {true, true},
		ProcessingLevelL2SP:    {true, true},
		ProcessingLevelSR:      {true, true},
		ProcessingLevelL1C:     {true, false},
		ProcessingLevelL1TP:    {true, false},
		ProcessingLevelTOA:     {true, false},
		ProcessingLevelUnknown: {true, false},
		ProcessingLevel("L3"):  {false, false},
		ProcessingLevel(""):    {false, false},
	}
	for lvl, want := range cases {
		if got := lvl.IsValid(); got != want.valid {
			t.Errorf("%q IsValid = %v, want %v", lvl, got, want.valid)
		}
		if got := lvl.IsSurfaceReflectance(); got != want.sr {
			t.Errorf("%q IsSurfaceReflectance = %v, want %v", lvl, got, want.sr)
		}
	}
}
