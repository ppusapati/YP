// Package ai provides a gRPC client for the AI Gateway service.
//
// Calls go through the gateway's generated stubs. An earlier version sent
// `structpb.Struct` values over `conn.Invoke` with the method name written out
// by hand; that cannot work, because a Struct serialises as a map entry list
// and bears no resemblance on the wire to the typed request the server decodes.
// Nothing called it, so the mismatch never surfaced.
package ai

import (
	"context"
	"fmt"
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/keepalive"
	"p9e.in/samavaya/packages/grpcdial"

	aipb "p9e.in/samavaya/agriculture/ai-gateway/api/v1"
	"p9e.in/samavaya/packages/p9log"
)

// AIClient wraps the gRPC connection to the AI Gateway for pest operations.
type AIClient struct {
	conn   *grpc.ClientConn
	logger *p9log.Helper
}

// NewAIClient creates a new AI Gateway client for pest prediction.
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

func (c *AIClient) gateway() aipb.AIGatewayServiceClient {
	return aipb.NewAIGatewayServiceClient(c.conn)
}

// PestDetectionResult contains pest detection output from the AI engine.
type PestDetectionResult struct {
	RequestID        string
	Pests            []DetectedPest
	ModelVersion     string
	ProcessingTimeMs int64
}

// DetectedPest represents a single pest detection from image analysis.
type DetectedPest struct {
	PestID          string
	PestName        string
	ScientificName  string
	ConfidenceScore float64
	DamageLevel     string
	Description     string
	DamagePattern   string
	ControlMethods  []string
}

// ImageInput describes an image to send to the AI gateway.
//
// Bytes are what the gateway classifies; a URL alone makes it skip the image,
// so callers that have only a URL must fetch it first.
type ImageInput struct {
	ImageURL  string
	ImageType string
	MimeType  string
	Bytes     []byte
}

// FieldRiskInput is everything the gateway needs to score a field.
type FieldRiskInput struct {
	FieldID   string
	FarmID    string
	CropType  string
	Weather   FieldWeather
	SoilState FieldSoilState
	Detection DetectionResults
	Growth    GrowthState
}

type FieldWeather struct {
	TemperatureCurrent      float64
	TemperatureMinForecast  float64
	TemperatureMaxForecast  float64
	PrecipitationMm         float64
	PrecipitationForecastMm float64
	ETReferenceMm           float64
	CO2Ppm                  float64
}

type FieldSoilState struct {
	SoilMoisture float64
}

type DetectionResults struct {
	PestConfidence    float64
	PestSpecies       string
	DiseaseConfidence float64
	DiseaseName       string
	NutrientSeverity  float64
	NutrientType      string
}

type GrowthState struct {
	NDVICurrent    float64
	NDVIPrevious   float64
	GrowthExpected float64
	GrowthActual   float64
}

// FieldRiskResult is the gateway's risk assessment for a field.
type FieldRiskResult struct {
	RequestID        string
	FieldID          string
	OverallRisk      float64
	TemperatureRisk  float64
	WaterRisk        float64
	PestRisk         float64
	DiseaseRisk      float64
	NutrientRisk     float64
	GrowthRisk       float64
	Alerts           []FieldAlert
	ProcessingTimeMs int64
}

// FieldAlert is one condition the gateway thought worth raising.
type FieldAlert struct {
	AlertType       string
	Severity        string
	Title           string
	Message         string
	Recommendations []string
	MetricValue     float64
}

// EvaluateFieldRisk asks the gateway to score a field's risk from its weather,
// soil, detections and growth state.
func (c *AIClient) EvaluateFieldRisk(ctx context.Context, requestID string, in FieldRiskInput) (*FieldRiskResult, error) {
	resp, err := c.gateway().EvaluateFieldRisk(ctx, &aipb.EvaluateFieldRiskRequest{
		RequestId: requestID,
		FieldId:   in.FieldID,
		FarmId:    in.FarmID,
		CropType:  in.CropType,
		Weather: &aipb.FieldWeather{
			TemperatureCurrent:      in.Weather.TemperatureCurrent,
			TemperatureMinForecast:  in.Weather.TemperatureMinForecast,
			TemperatureMaxForecast:  in.Weather.TemperatureMaxForecast,
			PrecipitationMm:         in.Weather.PrecipitationMm,
			PrecipitationForecastMm: in.Weather.PrecipitationForecastMm,
			EtReferenceMm:           in.Weather.ETReferenceMm,
			Co2Ppm:                  in.Weather.CO2Ppm,
		},
		SoilState: &aipb.FieldSoilState{SoilMoisture: in.SoilState.SoilMoisture},
		Detections: &aipb.DetectionResults{
			PestConfidence:    in.Detection.PestConfidence,
			PestSpecies:       in.Detection.PestSpecies,
			DiseaseConfidence: in.Detection.DiseaseConfidence,
			DiseaseName:       in.Detection.DiseaseName,
			NutrientSeverity:  in.Detection.NutrientSeverity,
			NutrientType:      in.Detection.NutrientType,
		},
		Growth: &aipb.GrowthState{
			NdviCurrent:    in.Growth.NDVICurrent,
			NdviPrevious:   in.Growth.NDVIPrevious,
			GrowthExpected: in.Growth.GrowthExpected,
			GrowthActual:   in.Growth.GrowthActual,
		},
	})
	if err != nil {
		return nil, fmt.Errorf("EvaluateFieldRisk invoke failed: %w", err)
	}

	out := &FieldRiskResult{
		RequestID:        resp.GetRequestId(),
		FieldID:          resp.GetFieldId(),
		OverallRisk:      resp.GetOverallRisk(),
		TemperatureRisk:  resp.GetTemperatureRisk(),
		WaterRisk:        resp.GetWaterRisk(),
		PestRisk:         resp.GetPestRisk(),
		DiseaseRisk:      resp.GetDiseaseRisk(),
		NutrientRisk:     resp.GetNutrientRisk(),
		GrowthRisk:       resp.GetGrowthRisk(),
		ProcessingTimeMs: resp.GetProcessingTimeMs(),
	}
	for _, a := range resp.GetAlerts() {
		out.Alerts = append(out.Alerts, FieldAlert{
			AlertType:       a.GetAlertType(),
			Severity:        a.GetSeverity(),
			Title:           a.GetTitle(),
			Message:         a.GetMessage(),
			Recommendations: a.GetRecommendations(),
			MetricValue:     a.GetMetricValue(),
		})
	}
	return out, nil
}

// DetectPestsFromImage sends observation images to the AI Gateway for pest
// identification, enriching the risk prediction with what is visible in the
// field rather than only what the weather suggests.
func (c *AIClient) DetectPestsFromImage(ctx context.Context, requestID string, images []ImageInput, plantSpeciesID string) (*PestDetectionResult, error) {
	protoImages := make([]*aipb.ImageData, 0, len(images))
	for _, img := range images {
		protoImages = append(protoImages, &aipb.ImageData{
			ImageUrl:   img.ImageURL,
			ImageType:  img.ImageType,
			MimeType:   img.MimeType,
			ImageBytes: img.Bytes,
		})
	}

	resp, err := c.gateway().DetectPests(ctx, &aipb.DetectPestsRequest{
		RequestId:      requestID,
		Images:         protoImages,
		PlantSpeciesId: plantSpeciesID,
	})
	if err != nil {
		c.logger.Errorw("msg", "AI DetectPests failed", "request_id", requestID, "error", err)
		return nil, fmt.Errorf("DetectPests invoke failed: %w", err)
	}

	result := &PestDetectionResult{
		RequestID:        resp.GetRequestId(),
		ModelVersion:     resp.GetModelVersion(),
		ProcessingTimeMs: resp.GetProcessingTimeMs(),
	}
	for _, p := range resp.GetPests() {
		result.Pests = append(result.Pests, DetectedPest{
			PestID:          p.GetPestId(),
			PestName:        p.GetPestName(),
			ScientificName:  p.GetScientificName(),
			ConfidenceScore: p.GetConfidenceScore(),
			DamageLevel:     p.GetDamageLevel(),
			Description:     p.GetDescription(),
			DamagePattern:   p.GetDamagePattern(),
			ControlMethods:  p.GetControlMethods(),
		})
	}

	c.logger.Infow("msg", "AI pest detection completed",
		"request_id", requestID,
		"pests_found", len(result.Pests),
		"processing_ms", result.ProcessingTimeMs,
	)
	return result, nil
}
