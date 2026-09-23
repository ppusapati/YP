// Package ai provides a gRPC client for the AI Gateway service.
//
// Calls go through the gateway's generated stubs. An earlier version sent
// `structpb.Struct` values over `conn.Invoke` with the method name written out
// by hand, which cannot work: a Struct serialises as a map entry list and
// bears no resemblance on the wire to the typed request the server decodes.
//
// Unlike the other clients converted alongside it, the field names here were
// right — so this one was broken purely by the encoding, with nothing in the
// source to hint at it.
package ai

import (
	"context"
	"fmt"
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/keepalive"
	"p9e.in/samavaya/packages/grpcdial"
	"p9e.in/samavaya/packages/ratelimit/algorithms"
	"p9e.in/samavaya/packages/ratelimit/grpclimit"

	"p9e.in/samavaya/packages/p9log"

	aipb "p9e.in/samavaya/agriculture/ai-gateway/api/v1"
)

type AIClient struct {
	conn   *grpc.ClientConn
	logger *p9log.Helper
}

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

func (c *AIClient) Close() error {
	if c.conn != nil {
		return c.conn.Close()
	}
	return nil
}

type FieldAnalytics struct {
	FieldID              string
	SeasonCount          int
	YieldTrend           string
	YieldTrendPctPerYear float64
	MeanYield            float64
	BestYield            float64
	WorstYield           float64
	YieldVariabilityCV   float64
	NDVITrend            string
	// NDVITrendPerYear was in the response all along and never read.
	NDVITrendPerYear        float64
	MeanStressDaysPerSeason float64
	RotationEffectiveness   float64
	RotationRecommendation  string
}

type SeasonRecord struct {
	CropType             string
	Season               string
	Year                 int
	YieldKgPerHa         float64
	StressDays           int
	FrostEvents          int
	HeatEvents           int
	DroughtDays          int
	TotalPrecipitationMM float64
	MeanTemperature      float64
	MeanNDVI             float64
	PeakNDVI             float64
	TotalThermalTime     float64
}

func (c *AIClient) gateway() aipb.AIGatewayServiceClient {
	return aipb.NewAIGatewayServiceClient(c.conn)
}

// ComputeFieldAnalytics asks the gateway for a field's multi-season trends.
func (c *AIClient) ComputeFieldAnalytics(ctx context.Context, requestID, fieldID, farmID string, seasons []SeasonRecord) (*FieldAnalytics, error) {
	pbSeasons := make([]*aipb.SeasonRecord, 0, len(seasons))
	for _, s := range seasons {
		pbSeasons = append(pbSeasons, &aipb.SeasonRecord{
			CropType:             s.CropType,
			Season:               s.Season,
			Year:                 int32(s.Year),
			YieldKgPerHa:         s.YieldKgPerHa,
			StressDays:           uint32(s.StressDays),
			FrostEvents:          uint32(s.FrostEvents),
			HeatEvents:           uint32(s.HeatEvents),
			DroughtDays:          uint32(s.DroughtDays),
			TotalPrecipitationMm: s.TotalPrecipitationMM,
			MeanTemperature:      s.MeanTemperature,
			MeanNdvi:             s.MeanNDVI,
			PeakNdvi:             s.PeakNDVI,
			TotalThermalTime:     s.TotalThermalTime,
		})
	}

	resp, err := c.gateway().ComputeFieldAnalytics(ctx, &aipb.ComputeFieldAnalyticsRequest{
		RequestId: requestID,
		FieldId:   fieldID,
		FarmId:    farmID,
		Seasons:   pbSeasons,
	})
	if err != nil {
		c.logger.Errorw("msg", "ComputeFieldAnalytics RPC failed", "error", err)
		return nil, fmt.Errorf("compute field analytics: %w", err)
	}

	result := &FieldAnalytics{
		// From the response rather than echoed back from the request: if the
		// gateway ever answers about a different field, that should be visible
		// here rather than papered over.
		FieldID:                 resp.GetFieldId(),
		SeasonCount:             int(resp.GetSeasonCount()),
		YieldTrend:              resp.GetYieldTrend(),
		YieldTrendPctPerYear:    resp.GetYieldTrendPctPerYear(),
		MeanYield:               resp.GetMeanYield(),
		BestYield:               resp.GetBestYield(),
		WorstYield:              resp.GetWorstYield(),
		YieldVariabilityCV:      resp.GetYieldVariabilityCv(),
		NDVITrend:               resp.GetNdviTrend(),
		NDVITrendPerYear:        resp.GetNdviTrendPerYear(),
		MeanStressDaysPerSeason: resp.GetMeanStressDaysPerSeason(),
	}
	if rot := resp.GetRotation(); rot != nil {
		result.RotationEffectiveness = rot.GetEffectivenessScore()
		result.RotationRecommendation = rot.GetRecommendation()
	}
	return result, nil
}
