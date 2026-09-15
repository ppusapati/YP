// Package clients contains Connect client adapters for peer services.
package clients

import (
	"context"
	"net/http"

	"connectrpc.com/connect"

	yieldv1 "p9e.in/samavaya/agriculture/yield-service/api/v1"
	yieldv1connect "p9e.in/samavaya/agriculture/yield-service/api/v1/yieldv1connect"

	"p9e.in/samavaya/agriculture/finance-service/internal/domain"
	"p9e.in/samavaya/agriculture/finance-service/internal/ports/outbound"
)

// historyPageSize is how many yield records are asked for at a time.
const historyPageSize = 200

// maxHistoryPages bounds the walk.
//
// Twenty pages is four thousand harvest records for one farm, which is more
// than a lifetime. The bound exists so a paging bug cannot turn a credit
// assessment into an unbounded loop, not because a real farm approaches it.
const maxHistoryPages = 20

type yieldClient struct {
	client yieldv1connect.YieldServiceClient
}

// NewYieldClient creates a Connect-backed YieldClient.
func NewYieldClient(baseURL string, httpClient *http.Client, opts ...connect.ClientOption) outbound.YieldClient {
	return &yieldClient{client: yieldv1connect.NewYieldServiceClient(httpClient, baseURL, opts...)}
}

func (c *yieldClient) FieldHistory(ctx context.Context, fieldID string, fromYear, toYear int) ([]domain.YieldSeason, error) {
	return c.history(ctx, &yieldv1.GetYieldHistoryRequest{
		FieldId:  fieldID,
		FromYear: int32(fromYear),
		ToYear:   int32(toYear),
	})
}

func (c *yieldClient) FarmHistory(ctx context.Context, farmID string, fromYear, toYear int) ([]domain.YieldSeason, error) {
	return c.history(ctx, &yieldv1.GetYieldHistoryRequest{
		FarmId:   farmID,
		FromYear: int32(fromYear),
		ToYear:   int32(toYear),
	})
}

// history walks every page of the record.
//
// Every page, not the first: a credit score built from the most recent fifty
// harvests of a farm that has a hundred would be a different number with no
// sign that it was partial, and an insurance rate priced off half a history is
// simply wrong rather than approximate.
func (c *yieldClient) history(ctx context.Context, req *yieldv1.GetYieldHistoryRequest) ([]domain.YieldSeason, error) {
	var out []domain.YieldSeason
	token := ""

	for page := 0; page < maxHistoryPages; page++ {
		req.PageSize = historyPageSize
		req.PageToken = token

		resp, err := c.client.GetYieldHistory(ctx, connect.NewRequest(req))
		if err != nil {
			return nil, err
		}

		for _, record := range resp.Msg.GetRecords() {
			out = append(out, toYieldSeason(record))
		}

		token = resp.Msg.GetNextPageToken()
		if token == "" {
			break
		}
	}
	return out, nil
}

func toYieldSeason(r *yieldv1.YieldRecord) domain.YieldSeason {
	return domain.YieldSeason{
		Year:   int(r.GetYear()),
		Season: domain.Season(r.GetSeason()),
		// The crop id is what yield-service records. It is matched
		// case-insensitively against the crop on a quote, so a deployment that
		// stores readable crop names lines up and one that stores opaque ids
		// falls through to the benchmark rate — which the quote says out loud
		// rather than pricing from a history it could not match.
		Crop:        r.GetCropId(),
		YieldKgHa:   r.GetActualYieldKgPerHectare(),
		AreaHa:      r.GetTotalAreaHarvestedHectares(),
		ProfitPerHa: r.GetProfitPerHectare(),
	}
}
