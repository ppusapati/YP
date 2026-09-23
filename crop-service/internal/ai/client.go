// Package ai provides a gRPC client for the AI Gateway service.
//
// Calls go through the gateway's generated stubs. An earlier version sent
// `structpb.Struct` values over `conn.Invoke` with the method name written out
// by hand, which cannot work: a Struct serialises as a map entry list and
// bears no resemblance on the wire to the typed request the server decodes.
//
// The field names were wrong too, and that is the part a compiler would have
// caught. The request was sent flat — soil_type, soil_ph, rainfall_mm — where
// RecommendCropsRequest nests soil and climate in their own messages. The
// response was read for `suitability_pct`, `season` and `reasons`, none of
// which exist on CropRecommendation; the real fields are `suitability_score`,
// `rationale` and `risk_factors`. Every one of those reads would have returned
// a zero value, silently.
package ai

import (
	"context"
	"fmt"
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/keepalive"

	"p9e.in/samavaya/packages/grpcdial"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ratelimit/algorithms"
	"p9e.in/samavaya/packages/ratelimit/grpclimit"

	aipb "p9e.in/samavaya/agriculture/ai-gateway/api/v1"
)

// AIClient wraps the gRPC connection to the AI Gateway for crop operations.
type AIClient struct {
	conn   *grpc.ClientConn
	logger *p9log.Helper
}

// NewAIClient creates a new AI Gateway client for crop recommendations.
func NewAIClient(addr string, logger *p9log.Helper) (*AIClient, error) {
	conn, err := grpc.NewClient(addr,
		grpcdial.TransportCredentials(),
		// Bound what this service will ask of the shared gateway, and give
		// every call a deadline. Nine services dial ai-gateway; at their
		// autoscaler ceilings that is seventy pods against two gateway
		// replicas, and the gateway's own guard is per-connection, so it
		// rises with the caller count instead of capping the total.
		grpclimit.WithAdaptiveConcurrency(grpclimit.Options{
			Limiter: algorithms.NewAdaptiveLimiter(),
			Name:    "ai-gateway",
			Timeout: 30 * time.Second,
		}),
		grpc.WithKeepaliveParams(keepalive.ClientParameters{
			Time:                30 * time.Second,
			Timeout:             10 * time.Second,
			PermitWithoutStream: true,
		}),
	)
	if err != nil {
		return nil, fmt.Errorf("ai gateway dial: %w", err)
	}
	return &AIClient{conn: conn, logger: logger}, nil
}

// Close closes the underlying gRPC connection.
func (c *AIClient) Close() error {
	if c.conn != nil {
		return c.conn.Close()
	}
	return nil
}

func (c *AIClient) gateway() aipb.AIGatewayServiceClient {
	return aipb.NewAIGatewayServiceClient(c.conn)
}

// CropRecommendation is one recommended crop.
type CropRecommendation struct {
	CropName string
	// SuitabilityScore is 0..1, not a percentage. The field used to be called
	// SuitabilityPct against a gateway that returns a fraction, so anything
	// rendering it as a percentage was out by two orders of magnitude.
	SuitabilityScore     float64
	Confidence           float64
	ExpectedYieldKgPerHa float64
	ExpectedProfitPerHa  float64
	WaterRequirementMm   float64
	Rationale            string
	RiskFactors          []string
}

// RecommendCropsRequest is what the gateway can actually be asked.
//
// Latitude, longitude and season used to be on here and are gone:
// RecommendCropsRequest has no field for any of them, so they were built into
// a Struct the server never decoded. Economic factors are in the proto but the
// gateway's handler ignores them, so there is nothing to send yet either.
type RecommendCropsRequest struct {
	SoilPH      float64
	SoilTexture string
	Rainfall    float64
	Temperature float64
	Humidity    float64
	// MaxRecommendations caps the list. Zero means the gateway's default of 5.
	MaxRecommendations int32
}

// RecommendCrops asks the gateway which crops suit a set of conditions.
func (c *AIClient) RecommendCrops(ctx context.Context, requestID string, req *RecommendCropsRequest) ([]CropRecommendation, error) {
	resp, err := c.gateway().RecommendCrops(ctx, &aipb.RecommendCropsRequest{
		RequestId: requestID,
		Soil: &aipb.SoilConditions{
			Ph:      req.SoilPH,
			Texture: req.SoilTexture,
		},
		Climate: &aipb.ClimateConditions{
			AvgTemperatureCelsius: req.Temperature,
			AnnualRainfallMm:      req.Rainfall,
			AvgHumidityPct:        req.Humidity,
		},
		MaxRecommendations: req.MaxRecommendations,
	})
	if err != nil {
		c.logger.Errorw("msg", "RecommendCrops RPC failed", "error", err)
		return nil, fmt.Errorf("recommend crops: %w", err)
	}

	recs := make([]CropRecommendation, 0, len(resp.GetRecommendations()))
	for _, r := range resp.GetRecommendations() {
		recs = append(recs, CropRecommendation{
			CropName:             r.GetCropName(),
			SuitabilityScore:     r.GetSuitabilityScore(),
			Confidence:           r.GetConfidence(),
			ExpectedYieldKgPerHa: r.GetExpectedYieldKgPerHa(),
			ExpectedProfitPerHa:  r.GetExpectedProfitPerHa(),
			WaterRequirementMm:   r.GetWaterRequirementMm(),
			Rationale:            r.GetRationale(),
			RiskFactors:          r.GetRiskFactors(),
		})
	}
	return recs, nil
}
