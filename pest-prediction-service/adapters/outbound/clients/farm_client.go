package clients

import (
	"context"
	"net/http"

	"connectrpc.com/connect"

	farmv1 "p9e.in/samavaya/agriculture/farm-service/api/v1"
	farmv1connect "p9e.in/samavaya/agriculture/farm-service/api/v1/farmv1connect"
	"p9e.in/samavaya/agriculture/pest-prediction-service/internal/ports/outbound"
)

type farmClient struct {
	client farmv1connect.FarmServiceClient
}

// NewFarmClient creates a Connect-backed FarmClient.
func NewFarmClient(baseURL string, httpClient *http.Client, opts ...connect.ClientOption) outbound.FarmClient {
	return &farmClient{
		client: farmv1connect.NewFarmServiceClient(httpClient, baseURL, opts...),
	}
}

func (c *farmClient) FarmExists(ctx context.Context, uuid, tenantID string) (bool, error) {
	resp, err := c.client.GetFarm(ctx, connect.NewRequest(&farmv1.GetFarmRequest{Id: uuid}))
	if err != nil {
		if connect.CodeOf(err) == connect.CodeNotFound {
			return false, nil
		}
		return false, err
	}
	return resp.Msg.GetFarm() != nil, nil
}
