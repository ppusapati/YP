// Package ai provides a gRPC client for the AI Gateway service.
// It exposes yield prediction and crop growth simulation operations
// needed by the yield-service.
// Calls go through the gateway's generated stubs. An earlier version sent
// `structpb.Struct` values over `conn.Invoke` with the method name written out
// by hand, which cannot work: a Struct serialises as a map entry list and
// bears no resemblance on the wire to the typed request the server decodes.
//
// The field names here were right, so this was broken purely by the encoding.
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

// AIClient wraps the gRPC connection to the AI Gateway for yield operations.
type AIClient struct {
	conn   *grpc.ClientConn
	logger *p9log.Helper
}

// NewAIClient creates a new AI Gateway client for yield prediction.
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
			Time:                10 * time.Second,
			Timeout:             3 * time.Second,
			PermitWithoutStream: true,
		}),
	)
	if err != nil {
		return nil, fmt.Errorf("failed to connect to AI Gateway at %s: %w", addr, err)
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

// YieldPredictionResult contains the AI-powered yield prediction output.
type YieldPredictionResult struct {
	RequestID                  string
	PredictedYieldKgPerHectare float64
	ConfidencePct              float64
	YieldLowerBound            float64
	YieldUpperBound            float64
	StressFactors              []StressFactor
	ModelVersion               string
	ProcessingTimeMs           int64
	// Provenance from the gateway: "parametric", "tabular", or "blended".
	ModelSource      string
	TabularWeight    float64
	CropSupported    bool
	IntervalCoverage float64
	// ParametricYieldKgPerHectare is the stress-factor estimate the gateway
	// keeps alongside a blended one. It was in the response all along and
	// nothing read it.
	ParametricYieldKgPerHectare float64
}

// StressFactor represents a factor that impacts yield negatively.
type StressFactor struct {
	FactorName     string
	Severity       float64
	YieldImpactPct float64
}

// CropGrowthResult contains the crop growth simulation output.
type CropGrowthResult struct {
	RequestID               string
	Stages                  []GrowthStageResult
	FinalBiomassKgPerHa     float64
	EstimatedDaysToMaturity int32
	ModelVersion            string
	ProcessingTimeMs        int64
}

// GrowthStageResult represents one stage in the simulated crop growth.
type GrowthStageResult struct {
	Day            int32
	StageName      string
	BiomassKgPerHa float64
	LeafAreaIndex  float64
	CanopyHeightCm float64
	WaterDemandMm  float64
}

// YieldFactorsInput contains the factor scores for yield prediction.
type YieldFactorsInput struct {
	SoilQualityScore  float64
	WeatherScore      float64
	IrrigationScore   float64
	PestPressureScore float64
	NutrientScore     float64
	ManagementScore   float64
}

// EnvironmentInput carries observed season weather for a field. When nil the
// gateway request falls back to score-derived placeholders.
type EnvironmentInput struct {
	AvgTemperatureC   float64
	HumidityPct       float64
	RainfallMM        float64
	SolarRadiationMJ  float64
	GrowingDegreeDays float64
	FrostDays         int
	HeatStressDays    int
}

// PredictYield calls the AI Gateway with score-derived environment placeholders.
func (c *AIClient) PredictYield(ctx context.Context, requestID, cropType string, factors YieldFactorsInput, fieldAreaHectares float64) (*YieldPredictionResult, error) {
	return c.PredictYieldWithEnvironment(ctx, requestID, cropType, factors, nil, fieldAreaHectares)
}

// PredictYieldWithEnvironment calls the AI Gateway using observed season
// weather when available.
func (c *AIClient) PredictYieldWithEnvironment(ctx context.Context, requestID, cropType string, factors YieldFactorsInput, env *EnvironmentInput, fieldAreaHectares float64) (*YieldPredictionResult, error) {
	// Without observed weather the gateway is handed a nominal season. These
	// are placeholders derived from the factor scores, not measurements, which
	// is why the caller prefers observed weather wherever it can assemble it.
	environment := &aipb.EnvironmentFactors{
		TemperatureCelsius: 20.0,
		HumidityPct:        factors.WeatherScore * 100.0,
		RainfallMm:         factors.IrrigationScore * 600.0,
		SolarRadiation:     20.0,
		WindSpeedKmh:       10.0,
		GrowingDegreeDays:  2000.0,
	}
	if env != nil {
		environment = &aipb.EnvironmentFactors{
			TemperatureCelsius: env.AvgTemperatureC,
			HumidityPct:        env.HumidityPct,
			RainfallMm:         env.RainfallMM,
			SolarRadiation:     env.SolarRadiationMJ,
			WindSpeedKmh:       10.0,
			GrowingDegreeDays:  env.GrowingDegreeDays,
			FrostDays:          int32(env.FrostDays),
			HeatStressDays:     int32(env.HeatStressDays),
		}
	}

	resp, err := c.gateway().PredictYield(ctx, &aipb.PredictYieldRequest{
		RequestId:   requestID,
		CropType:    cropType,
		Environment: environment,
		Soil: &aipb.SoilFactors{
			Ph:               factors.SoilQualityScore * 7.0,
			OrganicMatterPct: factors.SoilQualityScore * 5.0,
			NitrogenPpm:      factors.NutrientScore * 80.0,
			PhosphorusPpm:    factors.NutrientScore * 40.0,
			PotassiumPpm:     factors.NutrientScore * 60.0,
			MoisturePct:      factors.IrrigationScore * 100.0,
			Texture:          "loam",
			CompactionIndex:  0.1,
		},
		Management: &aipb.ManagementFactors{
			IrrigationEfficiency:  factors.IrrigationScore,
			FertilizerRateKgPerHa: factors.NutrientScore * 150.0,
			TillageType:           "conventional",
			PlantingDensity:       3500000.0,
			PestManagementLevel:   fmt.Sprintf("%.0f", factors.PestPressureScore*100),
		},
		FieldAreaHectares: fieldAreaHectares,
	})
	if err != nil {
		c.logger.Errorw("msg", "AI PredictYield failed", "request_id", requestID, "error", err)
		return nil, fmt.Errorf("PredictYield: %w", err)
	}

	result := &YieldPredictionResult{
		RequestID:                   resp.GetRequestId(),
		PredictedYieldKgPerHectare:  resp.GetPredictedYieldKgPerHectare(),
		ConfidencePct:               resp.GetConfidencePct(),
		YieldLowerBound:             resp.GetYieldLowerBound(),
		YieldUpperBound:             resp.GetYieldUpperBound(),
		ModelVersion:                resp.GetModelVersion(),
		ProcessingTimeMs:            resp.GetProcessingTimeMs(),
		ModelSource:                 resp.GetModelSource(),
		TabularWeight:               resp.GetTabularWeight(),
		CropSupported:               resp.GetCropSupported(),
		IntervalCoverage:            resp.GetIntervalCoverage(),
		ParametricYieldKgPerHectare: resp.GetParametricYieldKgPerHectare(),
	}
	for _, sf := range resp.GetStressFactors() {
		result.StressFactors = append(result.StressFactors, StressFactor{
			FactorName:     sf.GetFactorName(),
			Severity:       sf.GetSeverity(),
			YieldImpactPct: sf.GetYieldImpactPct(),
		})
	}
	return result, nil
}

// SimulateCropGrowth runs the gateway's growth model for a crop.
func (c *AIClient) SimulateCropGrowth(ctx context.Context, requestID, cropType string, simulationDays int32) (*CropGrowthResult, error) {
	resp, err := c.gateway().SimulateCropGrowth(ctx, &aipb.SimulateCropGrowthRequest{
		RequestId:      requestID,
		CropType:       cropType,
		SimulationDays: simulationDays,
	})
	if err != nil {
		c.logger.Errorw("msg", "AI SimulateCropGrowth failed", "request_id", requestID, "error", err)
		return nil, fmt.Errorf("SimulateCropGrowth: %w", err)
	}

	result := &CropGrowthResult{
		RequestID:               resp.GetRequestId(),
		FinalBiomassKgPerHa:     resp.GetFinalBiomassKgPerHa(),
		EstimatedDaysToMaturity: resp.GetEstimatedDaysToMaturity(),
		ModelVersion:            resp.GetModelVersion(),
		ProcessingTimeMs:        resp.GetProcessingTimeMs(),
	}
	for _, st := range resp.GetStages() {
		result.Stages = append(result.Stages, GrowthStageResult{
			Day:            st.GetDay(),
			StageName:      st.GetStageName(),
			BiomassKgPerHa: st.GetBiomassKgPerHa(),
			LeafAreaIndex:  st.GetLeafAreaIndex(),
			CanopyHeightCm: st.GetCanopyHeightCm(),
			WaterDemandMm:  st.GetWaterDemandMm(),
		})
	}
	return result, nil
}

func (c *AIClient) gateway() aipb.AIGatewayServiceClient {
	return aipb.NewAIGatewayServiceClient(c.conn)
}
