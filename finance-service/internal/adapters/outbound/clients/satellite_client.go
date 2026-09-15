package clients

import (
	"context"
	"net/http"
	"time"

	"connectrpc.com/connect"

	satellitev1 "p9e.in/samavaya/agriculture/satellite-service/api/v1"
	satellitev1connect "p9e.in/samavaya/agriculture/satellite-service/api/v1/satellitev1connect"

	"p9e.in/samavaya/agriculture/finance-service/internal/domain"
	"p9e.in/samavaya/agriculture/finance-service/internal/ports/outbound"
)

// imagePageSize is how many scenes are asked for at a time.
const imagePageSize = 200

// maxImagePages bounds the walk over a field's imagery.
const maxImagePages = 10

type satelliteClient struct {
	client satellitev1connect.SatelliteServiceClient
}

// NewSatelliteClient creates a Connect-backed SatelliteClient.
func NewSatelliteClient(baseURL string, httpClient *http.Client, opts ...connect.ClientOption) outbound.SatelliteClient {
	return &satelliteClient{
		client: satellitev1connect.NewSatelliteServiceClient(httpClient, baseURL, opts...),
	}
}

// NDVISeries reads the field's vegetation index over a window.
//
// Two calls, joined on the image id: the scene list carries the acquisition
// date and the cloud cover, and the index list carries the NDVI. The cloud
// figure is the reason for the join — without it a claim assessment cannot
// tell a healthy canopy from a cloud top, and a monsoon flood claim gets
// contradicted by the weather that caused it.
func (c *satelliteClient) NDVISeries(ctx context.Context, fieldID string, from, to time.Time) ([]domain.NDVIObservation, error) {
	scenes, err := c.scenes(ctx, fieldID, from, to)
	if err != nil {
		return nil, err
	}
	if len(scenes) == 0 {
		return nil, nil
	}

	resp, err := c.client.GetVegetationIndices(ctx, connect.NewRequest(&satellitev1.GetVegetationIndicesRequest{
		FieldId:   fieldID,
		IndexType: "NDVI",
	}))
	if err != nil {
		return nil, err
	}

	out := make([]domain.NDVIObservation, 0, len(scenes))
	for _, index := range resp.Msg.GetIndices() {
		scene, ok := scenes[index.GetImageId()]
		if !ok {
			// An index whose scene is outside the window, or whose scene the
			// list did not return. Dropped rather than dated from computed_at:
			// an NDVI reading attached to the wrong date would move a claim's
			// baseline to a day the crop was in a different condition.
			continue
		}
		out = append(out, domain.NDVIObservation{
			At:    scene.at,
			Value: index.GetMeanValue(),
			// satellite-service reports cloud as a percentage; the domain works
			// in fractions. Passing 85 where 0.85 was meant would make every
			// scene look impossibly cloudy and every claim inconclusive.
			CloudCover: scene.cloudPct / 100,
			Reference:  index.GetRasterUrl(),
		})
	}
	return out, nil
}

type sceneMeta struct {
	at       time.Time
	cloudPct float64
}

// scenes lists the field's imagery inside the window, keyed by image id.
func (c *satelliteClient) scenes(ctx context.Context, fieldID string, from, to time.Time) (map[string]sceneMeta, error) {
	out := map[string]sceneMeta{}

	for page := 0; page < maxImagePages; page++ {
		resp, err := c.client.ListImages(ctx, connect.NewRequest(&satellitev1.ListImagesRequest{
			FieldId:    fieldID,
			PageSize:   imagePageSize,
			PageOffset: int32(page * imagePageSize),
		}))
		if err != nil {
			return nil, err
		}

		images := resp.Msg.GetImages()
		for _, image := range images {
			acquired := image.GetAcquisitionDate()
			if acquired == nil {
				continue
			}
			at := acquired.AsTime()
			if at.Before(from) || (!to.IsZero() && at.After(to)) {
				continue
			}
			out[image.GetId()] = sceneMeta{at: at, cloudPct: image.GetCloudCoverPct()}
		}

		if len(images) < imagePageSize {
			break
		}
	}
	return out, nil
}
