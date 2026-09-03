// Package ai provides a gRPC client for the AI Gateway service.
// It exposes yield prediction and crop growth simulation operations
// needed by the yield-service.
package ai

import (
	"context"
	"fmt"
	"time"

	"google.golang.org/grpc"
	"p9e.in/samavaya/packages/grpcdial"
	"google.golang.org/grpc/keepalive"
	"google.golang.org/protobuf/types/known/structpb"

	"p9e.in/samavaya/packages/p9log"
)

const (
	methodPredictYield       = "/agriculture.ai.v1.AIGatewayService/PredictYield"
	methodSimulateCropGrowth = "/agriculture.ai.v1.AIGatewayService/SimulateCropGrowth"
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

// PredictYield calls the AI Gateway to get an ML-powered yield prediction.
// This augments the service's rule-based prediction with the Rust yield-prediction-engine.
func (c *AIClient) PredictYield(ctx context.Context, requestID, cropType string, factors YieldFactorsInput, fieldAreaHectares float64) (*YieldPredictionResult, error) {
	envStruct, _ := structpb.NewStruct(map[string]interface{}{
		"temperature_celsius":  20.0, // default; in production, fetched from weather service
		"humidity_pct":         factors.WeatherScore * 100.0,
		"rainfall_mm":         factors.IrrigationScore * 600.0,
		"solar_radiation":     20.0,
		"wind_speed_kmh":      10.0,
		"growing_degree_days": 2000.0,
	})

	soilStruct, _ := structpb.NewStruct(map[string]interface{}{
		"ph":                factors.SoilQualityScore * 7.0,
		"organic_matter_pct": factors.SoilQualityScore * 5.0,
		"nitrogen_ppm":      factors.NutrientScore * 80.0,
		"phosphorus_ppm":    factors.NutrientScore * 40.0,
		"potassium_ppm":     factors.NutrientScore * 60.0,
		"moisture_pct":      factors.IrrigationScore * 100.0,
		"texture":           "loam",
		"compaction_index":  0.1,
	})

	mgmtStruct, _ := structpb.NewStruct(map[string]interface{}{
		"irrigation_efficiency":     factors.IrrigationScore,
		"fertilizer_rate_kg_per_ha": factors.NutrientScore * 150.0,
		"tillage_type":              "conventional",
		"planting_density":          3500000.0,
		"pest_management_level":     fmt.Sprintf("%.0f", factors.PestPressureScore*100),
	})

	reqFields := map[string]*structpb.Value{
		"request_id":          structpb.NewStringValue(requestID),
		"crop_type":           structpb.NewStringValue(cropType),
		"environment":         structpb.NewStructValue(envStruct),
		"soil":                structpb.NewStructValue(soilStruct),
		"management":          structpb.NewStructValue(mgmtStruct),
		"field_area_hectares": structpb.NewNumberValue(fieldAreaHectares),
	}

	reqMsg := &structpb.Struct{Fields: reqFields}
	respMsg := &structpb.Struct{}

	err := c.conn.Invoke(ctx, methodPredictYield, reqMsg, respMsg)
	if err != nil {
		c.logger.Errorw("msg", "AI PredictYield failed", "request_id", requestID, "error", err)
		return nil, fmt.Errorf("PredictYield invoke failed: %w", err)
	}

	result := parseYieldResult(respMsg)
	c.logger.Infow("msg", "AI yield prediction completed",
		"request_id", requestID,
		"predicted_yield", result.PredictedYieldKgPerHectare,
		"confidence_pct", result.ConfidencePct,
		"processing_ms", result.ProcessingTimeMs,
	)

	return result, nil
}

// SimulateCropGrowth calls the AI Gateway to simulate crop growth over time.
func (c *AIClient) SimulateCropGrowth(ctx context.Context, requestID, cropType string, simulationDays int32) (*CropGrowthResult, error) {
	reqFields := map[string]*structpb.Value{
		"request_id":      structpb.NewStringValue(requestID),
		"crop_type":       structpb.NewStringValue(cropType),
		"simulation_days": structpb.NewNumberValue(float64(simulationDays)),
	}

	reqMsg := &structpb.Struct{Fields: reqFields}
	respMsg := &structpb.Struct{}

	err := c.conn.Invoke(ctx, methodSimulateCropGrowth, reqMsg, respMsg)
	if err != nil {
		c.logger.Errorw("msg", "AI SimulateCropGrowth failed", "request_id", requestID, "error", err)
		return nil, fmt.Errorf("SimulateCropGrowth invoke failed: %w", err)
	}

	result := parseGrowthResult(respMsg)
	return result, nil
}

// ─────────────────────────────────────────────────────────────────────────────
// Response parsers
// ─────────────────────────────────────────────────────────────────────────────

func parseYieldResult(resp *structpb.Struct) *YieldPredictionResult {
	result := &YieldPredictionResult{}
	if resp == nil || resp.Fields == nil {
		return result
	}

	result.RequestID = getStringField(resp, "request_id")
	result.PredictedYieldKgPerHectare = getNumberField(resp, "predicted_yield_kg_per_hectare")
	result.ConfidencePct = getNumberField(resp, "confidence_pct")
	result.YieldLowerBound = getNumberField(resp, "yield_lower_bound")
	result.YieldUpperBound = getNumberField(resp, "yield_upper_bound")
	result.ModelVersion = getStringField(resp, "model_version")
	result.ProcessingTimeMs = int64(getNumberField(resp, "processing_time_ms"))

	if sfList, ok := resp.Fields["stress_factors"]; ok {
		if lv := sfList.GetListValue(); lv != nil {
			for _, sfv := range lv.Values {
				if sfs := sfv.GetStructValue(); sfs != nil {
					result.StressFactors = append(result.StressFactors, StressFactor{
						FactorName:     getStringField(sfs, "factor_name"),
						Severity:       getNumberField(sfs, "severity"),
						YieldImpactPct: getNumberField(sfs, "yield_impact_pct"),
					})
				}
			}
		}
	}

	return result
}

func parseGrowthResult(resp *structpb.Struct) *CropGrowthResult {
	result := &CropGrowthResult{}
	if resp == nil || resp.Fields == nil {
		return result
	}

	result.RequestID = getStringField(resp, "request_id")
	result.FinalBiomassKgPerHa = getNumberField(resp, "final_biomass_kg_per_ha")
	result.EstimatedDaysToMaturity = int32(getNumberField(resp, "estimated_days_to_maturity"))
	result.ModelVersion = getStringField(resp, "model_version")
	result.ProcessingTimeMs = int64(getNumberField(resp, "processing_time_ms"))

	if stageList, ok := resp.Fields["stages"]; ok {
		if lv := stageList.GetListValue(); lv != nil {
			for _, sv := range lv.Values {
				if ss := sv.GetStructValue(); ss != nil {
					result.Stages = append(result.Stages, GrowthStageResult{
						Day:            int32(getNumberField(ss, "day")),
						StageName:      getStringField(ss, "stage_name"),
						BiomassKgPerHa: getNumberField(ss, "biomass_kg_per_ha"),
						LeafAreaIndex:  getNumberField(ss, "leaf_area_index"),
						CanopyHeightCm: getNumberField(ss, "canopy_height_cm"),
						WaterDemandMm:  getNumberField(ss, "water_demand_mm"),
					})
				}
			}
		}
	}

	return result
}

func getStringField(s *structpb.Struct, key string) string {
	if v, ok := s.Fields[key]; ok {
		return v.GetStringValue()
	}
	return ""
}

func getNumberField(s *structpb.Struct, key string) float64 {
	if v, ok := s.Fields[key]; ok {
		return v.GetNumberValue()
	}
	return 0
}
