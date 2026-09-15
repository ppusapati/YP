package services

import (
	"context"
	"fmt"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"

	vimodels "p9e.in/samavaya/agriculture/vegetation-index-service/internal/models"
)

// MinValidPixelFraction is the share of a scene that must survive cloud
// masking for the index computed from it to be worth keeping.
//
// An index over a mostly-cloudy scene is not wrong so much as meaningless: the
// arithmetic succeeds on whatever reflectance the cloud tops returned, and the
// number lands in the time series looking exactly like a clear-day reading. A
// gap in the series is honest; a confident wrong value is not.
//
// A third is deliberately permissive. Partial cloud over one corner of a field
// still says something useful about the rest, and in a monsoon season a
// stricter bar would discard most of the record.
const MinValidPixelFraction = 0.35

// SceneQuality is what masking reported about a scene.
type SceneQuality struct {
	CloudFraction      float64
	ValidPixelFraction float64
}

// Usable reports whether enough of the scene survived masking.
func (q SceneQuality) Usable() bool {
	return q.ValidPixelFraction >= MinValidPixelFraction
}

// Normalise fills in whichever of the two fractions the caller left unset and
// clamps both to [0,1].
//
// Providers report one or the other depending on the product, and they are not
// quite complements — a pixel can be missing for reasons other than cloud, such
// as a scene edge or a sensor dropout. Deriving the missing one is still better
// than treating it as zero, which would silently mark every scene unusable.
func (q SceneQuality) Normalise() SceneQuality {
	clamp := func(v float64) float64 {
		if v < 0 {
			return 0
		}
		if v > 1 {
			return 1
		}
		return v
	}
	q.CloudFraction = clamp(q.CloudFraction)
	q.ValidPixelFraction = clamp(q.ValidPixelFraction)

	if q.ValidPixelFraction == 0 && q.CloudFraction > 0 {
		q.ValidPixelFraction = 1 - q.CloudFraction
	}
	if q.CloudFraction == 0 && q.ValidPixelFraction > 0 && q.ValidPixelFraction < 1 {
		q.CloudFraction = 1 - q.ValidPixelFraction
	}
	// Nothing reported at all: the scene predates masking, and the index was
	// already computed on the assumption that every pixel counted.
	if q.CloudFraction == 0 && q.ValidPixelFraction == 0 {
		q.ValidPixelFraction = 1
	}
	return q
}

// RecordIndex stores a computed index, dropping scenes too cloudy to mean
// anything.
//
// Returns (nil, nil) for a dropped scene: not finding enough clear sky is a
// normal outcome of looking at the weather, not an error to escalate.
func (s *vegetationIndexService) RecordIndex(ctx context.Context, vi *vimodels.VegetationIndex) (*vimodels.VegetationIndex, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if vi == nil {
		return nil, errors.BadRequest("MISSING_INDEX", "a vegetation index is required")
	}
	if vi.FarmUUID == "" {
		return nil, errors.BadRequest("MISSING_FARM_ID", "farm_uuid is required")
	}
	if !vi.IndexType.IsValid() {
		return nil, errors.BadRequest("INVALID_INDEX_TYPE", fmt.Sprintf("unknown index type %q", vi.IndexType))
	}

	quality := SceneQuality{
		CloudFraction:      vi.CloudFraction,
		ValidPixelFraction: vi.ValidPixelFraction,
	}.Normalise()
	vi.CloudFraction = quality.CloudFraction
	vi.ValidPixelFraction = quality.ValidPixelFraction

	if !quality.Usable() {
		s.log.Infow("msg", "scene dropped: too little clear sky to mean anything",
			"farm_uuid", vi.FarmUUID,
			"index_type", string(vi.IndexType),
			"cloud_fraction", quality.CloudFraction,
			"valid_pixel_fraction", quality.ValidPixelFraction,
			"threshold", MinValidPixelFraction,
		)
		return nil, nil
	}

	vi.TenantID = tenantID
	if vi.CreatedBy == "" {
		if userID := p9context.UserID(ctx); userID != "" {
			vi.CreatedBy = userID
		} else {
			vi.CreatedBy = "system"
		}
	}
	return s.repo.InsertVegetationIndex(ctx, vi)
}
