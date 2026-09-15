// Package clients contains Connect client adapters for peer services.
package clients

import (
	"context"
	"fmt"
	"net/http"

	"connectrpc.com/connect"
	"google.golang.org/protobuf/types/known/timestamppb"

	soilv1 "p9e.in/samavaya/agriculture/soil-service/api/v1"
	soilv1connect "p9e.in/samavaya/agriculture/soil-service/api/v1/soilv1connect"

	"p9e.in/samavaya/agriculture/soil-lab-service/internal/domain"
	"p9e.in/samavaya/agriculture/soil-lab-service/internal/ports/outbound"
)

type soilClient struct {
	client soilv1connect.SoilServiceClient
}

// NewSoilClient creates a Connect-backed SoilClient.
func NewSoilClient(baseURL string, httpClient *http.Client, opts ...connect.ClientOption) outbound.SoilClient {
	return &soilClient{client: soilv1connect.NewSoilServiceClient(httpClient, baseURL, opts...)}
}

// CreateSamples sends each usable row to soil-service as a soil sample.
//
// One at a time, with ids collected as they succeed. soil-service has no batch
// create, and firing them concurrently to return the first error would lose
// track of which ones landed — so a retry would duplicate them, and a
// duplicated soil history is one nobody can reconcile.
//
// On a failure the ids created so far are returned *with* the error rather
// than instead of it, which is what lets the caller record a partial apply.
func (c *soilClient) CreateSamples(ctx context.Context, samples []domain.SoilSample) ([]string, error) {
	created := make([]string, 0, len(samples))

	for i := range samples {
		id, err := c.createOne(ctx, samples[i])
		if err != nil {
			return created, fmt.Errorf("sample %d of %d (field %s): %w",
				i+1, len(samples), samples[i].FieldID, err)
		}
		created = append(created, id)
	}
	return created, nil
}

func (c *soilClient) createOne(ctx context.Context, sample domain.SoilSample) (string, error) {
	req := &soilv1.CreateSoilSampleRequest{
		FieldId:       sample.FieldID,
		SampleDepthCm: sample.DepthCM,
		Notes:         sample.Notes,
	}
	if !sample.CollectedOn.IsZero() {
		req.CollectionDate = timestamppb.New(sample.CollectedOn)
	}

	// Only the analytes the lab actually measured are set. A zero for one it
	// did not run would say the soil contains none of that nutrient, which is
	// the opposite of "not tested" — and it is a prescription input.
	for analyte, value := range sample.Values {
		applyAnalyte(req, analyte, value)
	}

	resp, err := c.client.CreateSoilSample(ctx, connect.NewRequest(req))
	if err != nil {
		return "", err
	}
	if resp.Msg.GetSample() == nil {
		return "", fmt.Errorf("soil-service accepted the sample and returned nothing")
	}
	return resp.Msg.GetSample().GetId(), nil
}

// applyAnalyte sets one measurement on the request.
//
// A switch rather than reflection: the mapping between this service's analyte
// names and soil-service's fields is the thing that has to be right, and a
// compiler-checked switch fails to build when soil-service renames a field,
// where reflection would silently stop populating it.
func applyAnalyte(req *soilv1.CreateSoilSampleRequest, analyte domain.Analyte, value float64) {
	switch analyte {
	case domain.AnalytePH:
		req.PH = value
	case domain.AnalyteOrganicMatter:
		req.OrganicMatterPct = value
	case domain.AnalyteNitrogen:
		req.NitrogenPpm = value
	case domain.AnalytePhosphorus:
		req.PhosphorusPpm = value
	case domain.AnalytePotassium:
		req.PotassiumPpm = value
	case domain.AnalyteCalcium:
		req.CalciumPpm = value
	case domain.AnalyteMagnesium:
		req.MagnesiumPpm = value
	case domain.AnalyteSulfur:
		req.SulfurPpm = value
	case domain.AnalyteIron:
		req.IronPpm = value
	case domain.AnalyteManganese:
		req.ManganesePpm = value
	case domain.AnalyteZinc:
		req.ZincPpm = value
	case domain.AnalyteCopper:
		req.CopperPpm = value
	case domain.AnalyteBoron:
		req.BoronPpm = value
	case domain.AnalyteMoisture:
		req.MoisturePct = value
	case domain.AnalyteBulkDensity:
		req.BulkDensity = value
	case domain.AnalyteCEC:
		req.CationExchangeCapacity = value
	case domain.AnalyteEC:
		req.ElectricalConductivity = value
	}
}
