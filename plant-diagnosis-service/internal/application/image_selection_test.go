package application

import (
	"bytes"
	"encoding/json"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"p9e.in/samavaya/agriculture/plant-diagnosis-service/internal/ai"
	"p9e.in/samavaya/agriculture/plant-diagnosis-service/internal/domain"
)

// A phone capture is the case this whole path exists for: the photo has no
// address a server can resolve, so the app sends the file. Before
// `image_bytes` existed the app sent the device path as the URL, it failed
// scheme validation, and the image was dropped — so a photo taken in the
// farmer app was submitted, accepted, and never analysed.
func TestSelectImages_InlineBytesNeedNoURL(t *testing.T) {
	in := []domain.DiagnosisImage{{
		ImageType: "LEAF",
		MimeType:  "image/jpeg",
		Bytes:     []byte{0xFF, 0xD8, 0xFF, 0xE0},
	}}

	out, skipped := selectImages(in)

	require.Len(t, out, 1, "an image with bytes and no URL must be analysed")
	assert.Empty(t, skipped)
	assert.Equal(t, []byte{0xFF, 0xD8, 0xFF, 0xE0}, out[0].Bytes)
	assert.Equal(t, "image/jpeg", out[0].MimeType)
	assert.Equal(t, "LEAF", out[0].ImageType)
}

// The exact failure the field was added to fix, kept as a test so it cannot
// come back by someone tightening validation.
func TestSelectImages_DevicePathWithBytesIsNotRejected(t *testing.T) {
	in := []domain.DiagnosisImage{{
		ImageURL: "/data/user/0/in.p9e.farmer/cache/CAP1234.jpg",
		Bytes:    []byte{1, 2, 3},
	}}

	out, skipped := selectImages(in)

	assert.Len(t, out, 1)
	assert.Empty(t, skipped)
}

func TestSelectImages_URLWithoutBytesMustValidate(t *testing.T) {
	in := []domain.DiagnosisImage{
		{ImageURL: "https://images.example.com/leaf.jpg"},
		{ImageURL: "/data/user/0/in.p9e.farmer/cache/CAP1234.jpg"},
		{ImageURL: "http://169.254.169.254/latest/meta-data/"},
		{ImageURL: ""},
	}

	out, skipped := selectImages(in)

	require.Len(t, out, 1, "only the https URL is usable")
	assert.Equal(t, "https://images.example.com/leaf.jpg", out[0].ImageURL)
	assert.Len(t, skipped, 3)

	// Each skip names the image it refers to, so a three-photo diagnosis that
	// drops one says which.
	for i, want := range []string{"images[1]", "images[2]", "images[3]"} {
		assert.Contains(t, skipped[i], want)
	}
}

func TestSelectImages_OversizedInlineImageIsRejected(t *testing.T) {
	// A hostile request must not get past a ceiling a hostile URL could not.
	in := []domain.DiagnosisImage{{
		Bytes: bytes.Repeat([]byte{7}, ai.MaxImageBytes+1),
	}}

	out, skipped := selectImages(in)

	assert.Empty(t, out)
	require.Len(t, skipped, 1)
	assert.Contains(t, skipped[0], "exceeds")
	assert.Contains(t, skipped[0], "images[0]")
}

func TestSelectImages_AtTheLimitIsAccepted(t *testing.T) {
	// Off-by-one in the other direction: exactly the ceiling is fine, and a
	// phone photo can genuinely sit near it.
	in := []domain.DiagnosisImage{{
		Bytes: bytes.Repeat([]byte{7}, ai.MaxImageBytes),
	}}

	out, skipped := selectImages(in)

	assert.Len(t, out, 1)
	assert.Empty(t, skipped)
}

// One bad photo should not sink a three-photo diagnosis: two usable images
// still answer the question better than a refusal does.
func TestSelectImages_MixedBatchKeepsTheUsableOnes(t *testing.T) {
	in := []domain.DiagnosisImage{
		{Bytes: []byte{1}},
		{ImageURL: "not-a-url"},
		{ImageURL: "https://images.example.com/stem.jpg"},
	}

	out, skipped := selectImages(in)

	assert.Len(t, out, 2)
	assert.Len(t, skipped, 1)
	assert.True(t, strings.HasPrefix(skipped[0], "images[1]"))
}

func TestSelectImages_NoImages(t *testing.T) {
	out, skipped := selectImages(nil)

	assert.Empty(t, out)
	assert.Empty(t, skipped)
}

// The bytes exist to reach the gateway and must not land in the request row:
// a few megabytes of JPEG per diagnosis in a JSONB column is a table nobody
// can query.
func TestDiagnosisImage_BytesAreNotPersisted(t *testing.T) {
	img := domain.DiagnosisImage{
		ImageURL: "https://images.example.com/leaf.jpg",
		MimeType: "image/jpeg",
		Bytes:    []byte{0xFF, 0xD8, 0xFF},
	}

	encoded, err := json.Marshal(img)
	require.NoError(t, err)

	assert.Contains(t, string(encoded), "image_url")
	assert.NotContains(t, string(encoded), "Bytes")
	assert.NotContains(t, string(encoded), "image_bytes")
}
