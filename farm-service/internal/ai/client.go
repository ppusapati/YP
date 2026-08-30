package ai

import (
	"context"
	"fmt"
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/keepalive"
	"google.golang.org/protobuf/types/known/structpb"

	"p9e.in/samavaya/packages/p9log"
)

const (
	methodComputeFieldAnalytics = "/agriculture.ai.v1.AIGatewayService/ComputeFieldAnalytics"
)

type AIClient struct {
	conn   *grpc.ClientConn
	logger *p9log.Helper
}

func NewAIClient(addr string, logger *p9log.Helper) (*AIClient, error) {
	conn, err := grpc.NewClient(addr,
		grpc.WithTransportCredentials(insecure.NewCredentials()),
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
	FieldID                string
	SeasonCount            int
	YieldTrend             string
	YieldTrendPctPerYear   float64
	MeanYield              float64
	BestYield              float64
	WorstYield             float64
	YieldVariabilityCV     float64
	NDVITrend              string
	MeanStressDaysPerSeason float64
	RotationEffectiveness  float64
	RotationRecommendation string
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

func (c *AIClient) ComputeFieldAnalytics(ctx context.Context, fieldID, farmID string, seasons []SeasonRecord) (*FieldAnalytics, error) {
	seasonList := make([]interface{}, len(seasons))
	for i, s := range seasons {
		seasonList[i] = map[string]interface{}{
			"crop_type":              s.CropType,
			"season":                 s.Season,
			"year":                   float64(s.Year),
			"yield_kg_per_ha":        s.YieldKgPerHa,
			"stress_days":            float64(s.StressDays),
			"frost_events":           float64(s.FrostEvents),
			"heat_events":            float64(s.HeatEvents),
			"drought_days":           float64(s.DroughtDays),
			"total_precipitation_mm": s.TotalPrecipitationMM,
			"mean_temperature":       s.MeanTemperature,
			"mean_ndvi":              s.MeanNDVI,
			"peak_ndvi":              s.PeakNDVI,
			"total_thermal_time":     s.TotalThermalTime,
		}
	}

	in, err := structpb.NewStruct(map[string]interface{}{
		"field_id": fieldID,
		"farm_id":  farmID,
		"seasons":  seasonList,
	})
	if err != nil {
		return nil, fmt.Errorf("build request: %w", err)
	}

	out := &structpb.Struct{}
	if err := c.conn.Invoke(ctx, methodComputeFieldAnalytics, in, out); err != nil {
		c.logger.Errorf("ComputeFieldAnalytics RPC failed: %v", err)
		return nil, fmt.Errorf("compute field analytics: %w", err)
	}

	f := out.GetFields()
	result := &FieldAnalytics{
		FieldID:                 fieldID,
		SeasonCount:             int(f["season_count"].GetNumberValue()),
		YieldTrend:              f["yield_trend"].GetStringValue(),
		YieldTrendPctPerYear:    f["yield_trend_pct_per_year"].GetNumberValue(),
		MeanYield:               f["mean_yield"].GetNumberValue(),
		BestYield:               f["best_yield"].GetNumberValue(),
		WorstYield:              f["worst_yield"].GetNumberValue(),
		YieldVariabilityCV:      f["yield_variability_cv"].GetNumberValue(),
		NDVITrend:               f["ndvi_trend"].GetStringValue(),
		MeanStressDaysPerSeason: f["mean_stress_days_per_season"].GetNumberValue(),
	}

	if rot := f["rotation"]; rot != nil {
		rf := rot.GetStructValue().GetFields()
		result.RotationEffectiveness = rf["effectiveness_score"].GetNumberValue()
		result.RotationRecommendation = rf["recommendation"].GetStringValue()
	}

	return result, nil
}
