package models

import "testing"

// The whole point of attaching a quality layer at ingestion is that masking
// stops depending on a caller remembering to ask for one. These pin which
// provider publishes what, because asking for a band a product does not carry
// fails the download rather than improving the mask.
func TestQualityBandFor(t *testing.T) {
	cases := []struct {
		name     string
		provider SatelliteProvider
		level    ProcessingLevel
		want     SpectralBand
	}{
		{"sentinel-2 surface reflectance carries SCL", SatelliteProviderSentinel2, ProcessingLevelL2A, SpectralBandSCL},
		{"sentinel-2 top-of-atmosphere has no scene classification", SatelliteProviderSentinel2, ProcessingLevelL1C, SpectralBandUnspecified},
		{"landsat level-1 carries QA_PIXEL", SatelliteProviderLandsat, ProcessingLevelL1TP, SpectralBandQAPixel},
		{"landsat level-2 carries QA_PIXEL", SatelliteProviderLandsat, ProcessingLevelL2SP, SpectralBandQAPixel},
		{"generic surface reflectance from landsat still carries it", SatelliteProviderLandsat, ProcessingLevelSR, SpectralBandQAPixel},
		{"an unknown level asks for nothing", SatelliteProviderSentinel2, ProcessingLevelUnknown, SpectralBandUnspecified},
		{"planetscope publishes no QA layer here", SatelliteProviderPlanetScope, ProcessingLevelSR, SpectralBandUnspecified},
		{"drone imagery has no satellite QA layer", SatelliteProviderUAV, ProcessingLevelSR, SpectralBandUnspecified},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			if got := QualityBandFor(tc.provider, tc.level); got != tc.want {
				t.Errorf("QualityBandFor(%s, %s) = %q, want %q", tc.provider, tc.level, got, tc.want)
			}
		})
	}
}

func TestQualityBandsAreValidBands(t *testing.T) {
	// They travel in the same list as the reflectance bands, so validation has
	// to accept them or an ingestion request carrying one would be rejected.
	for _, b := range []SpectralBand{SpectralBandSCL, SpectralBandQAPixel} {
		if !b.IsValid() {
			t.Errorf("%q should be a valid spectral band", b)
		}
	}
	if SpectralBandUnspecified.IsValid() {
		t.Error("the empty band should not be valid")
	}
}
