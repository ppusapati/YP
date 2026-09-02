// Package ai provides a gRPC client for the AI Gateway service.
// It wraps the connection and provides typed methods for all AI operations
// needed by the plant-diagnosis-service.
package ai

import (
	"context"
	"fmt"
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/keepalive"

	"p9e.in/samavaya/packages/circuitbreaker"
	"p9e.in/samavaya/packages/p9log"
)

// AIClient wraps the gRPC connection to the AI Gateway for plant diagnosis operations.
type AIClient struct {
	conn   *grpc.ClientConn
	logger *p9log.Helper
	cb     *circuitbreaker.SimpleCircuitBreaker
}

// NewAIClient creates a new AI Gateway client.
func NewAIClient(addr string, logger *p9log.Helper) (*AIClient, error) {
	conn, err := grpc.NewClient(addr,
		grpc.WithTransportCredentials(insecure.NewCredentials()),
		grpc.WithKeepaliveParams(keepalive.ClientParameters{
			Time:                10 * time.Second,
			Timeout:             3 * time.Second,
			PermitWithoutStream: true,
		}),
		grpc.WithDefaultCallOptions(
			grpc.MaxCallRecvMsgSize(64*1024*1024), // 64MB for image data
		),
	)
	if err != nil {
		return nil, fmt.Errorf("failed to connect to AI Gateway at %s: %w", addr, err)
	}

	return &AIClient{
		conn:   conn,
		logger: logger,
		cb: circuitbreaker.NewSimpleCircuitBreaker(circuitbreaker.SimpleConfig{
			MaxFailures:      5,
			SuccessThreshold: 2,
			Timeout:          60 * time.Second,
		}),
	}, nil
}

// Close closes the underlying gRPC connection.
func (c *AIClient) Close() error {
	if c.conn != nil {
		return c.conn.Close()
	}
	return nil
}

// ─────────────────────────────────────────────────────────────────────────────
// Diagnosis Results
// ─────────────────────────────────────────────────────────────────────────────

// DiagnosisResult contains the full AI diagnosis output.
type DiagnosisResult struct {
	RequestID          string
	Diseases           []DetectedDisease
	OverallHealthScore float64
	Summary            string
	ModelVersion       string
	ProcessingTimeMs   int64
}

// DetectedDisease represents a single disease detection from the AI engine.
type DetectedDisease struct {
	DiseaseID        string
	DiseaseName      string
	ScientificName   string
	ConfidenceScore  float64
	Severity         string
	Description      string
	Symptoms         string
	TreatmentOptions []string
	Prevention       string
}

// PestDetectionResult contains pest detection output from the AI engine.
type PestDetectionResult struct {
	RequestID        string
	Pests            []DetectedPest
	ModelVersion     string
	ProcessingTimeMs int64
}

// DetectedPest represents a single pest detection.
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

// NutrientDeficiencyResult contains nutrient deficiency detection output.
type NutrientDeficiencyResult struct {
	RequestID        string
	Deficiencies     []DetectedNutrientDeficiency
	ModelVersion     string
	ProcessingTimeMs int64
}

// DetectedNutrientDeficiency represents a single nutrient deficiency detection.
type DetectedNutrientDeficiency struct {
	Nutrient              string
	ConfidenceScore       float64
	Severity              string
	Description           string
	VisualSymptoms        string
	RecommendedFertilizers []string
	ApplicationMethod     string
}

// SpeciesClassificationResult contains plant species classification output.
type SpeciesClassificationResult struct {
	RequestID        string
	SpeciesID        string
	CommonName       string
	ScientificName   string
	Family           string
	Confidence       float64
	ModelVersion     string
	ProcessingTimeMs int64
}

// PrescriptionResult contains the AI-generated prescription output.
type PrescriptionResult struct {
	RequestID              string
	FieldID                string
	Prescriptions          []PrescriptionMap
	EstimatedCostSavingsPct float64
	EstimatedYieldGainPct  float64
	ProcessingTimeMs       int64
}

// PrescriptionMap represents a single prescription type result.
type PrescriptionMap struct {
	PrescriptionType string
	Rates            []float64
	Unit             string
	TotalAmount      float64
	ZoneSummaries    []PrescriptionZone
}

// PrescriptionZone summarises a zone within a prescription map.
type PrescriptionZone struct {
	Zone        string
	CellCount   int32
	AreaHa      float64
	MeanRate    float64
	MinRate     float64
	MaxRate     float64
	TotalAmount float64
}

// PrescriptionInput holds the parameters needed for prescription generation.
type PrescriptionInput struct {
	FieldID           string
	CropType          string
	TargetYieldKgHa   float64
	PrescriptionTypes []string
	DiagnosisSummary  string
}

// ImageInput describes an image to send to the AI gateway.
type ImageInput struct {
	ImageURL  string
	ImageType string
	MimeType  string
}

// ─────────────────────────────────────────────────────────────────────────────
// RPC Methods
// ─────────────────────────────────────────────────────────────────────────────

// DiagnoseImage sends plant images to the AI Gateway for disease detection.
// This replaces the previous HTTP calls to the Rust preprocessing and Python inference services.
func (c *AIClient) DiagnoseImage(ctx context.Context, requestID string, images []ImageInput, plantSpeciesID string) (*DiagnosisResult, error) {
	var result *DiagnosisResult

	err := c.cb.Execute(ctx, func(cbCtx context.Context) error {
		// Build the gRPC request payload using raw proto bytes (via grpc.Invoke).
		// In a full implementation with generated pb stubs, this would be:
		//   resp, err := c.client.DiagnoseImage(cbCtx, &aipb.DiagnoseImageRequest{...})
		// Since we're building the integration layer, we use a codec-agnostic approach
		// that works with the proto definition.

		resp, err := callDiagnoseImage(cbCtx, c.conn, requestID, images, plantSpeciesID)
		if err != nil {
			return fmt.Errorf("DiagnoseImage RPC failed: %w", err)
		}

		result = resp
		return nil
	})

	if err != nil {
		c.logger.Errorw("msg", "AI DiagnoseImage failed", "request_id", requestID, "error", err)
		return nil, err
	}

	c.logger.Infow("msg", "AI DiagnoseImage completed",
		"request_id", requestID,
		"diseases_found", len(result.Diseases),
		"health_score", result.OverallHealthScore,
		"processing_ms", result.ProcessingTimeMs,
	)

	return result, nil
}

// DetectPests sends plant images to the AI Gateway for pest detection.
func (c *AIClient) DetectPests(ctx context.Context, requestID string, images []ImageInput, plantSpeciesID string) (*PestDetectionResult, error) {
	var result *PestDetectionResult

	err := c.cb.Execute(ctx, func(cbCtx context.Context) error {
		resp, err := callDetectPests(cbCtx, c.conn, requestID, images, plantSpeciesID)
		if err != nil {
			return fmt.Errorf("DetectPests RPC failed: %w", err)
		}
		result = resp
		return nil
	})

	if err != nil {
		c.logger.Errorw("msg", "AI DetectPests failed", "request_id", requestID, "error", err)
		return nil, err
	}

	return result, nil
}

// DetectNutrientDeficiency sends plant images for nutrient deficiency analysis.
func (c *AIClient) DetectNutrientDeficiency(ctx context.Context, requestID string, images []ImageInput, plantSpeciesID string) (*NutrientDeficiencyResult, error) {
	var result *NutrientDeficiencyResult

	err := c.cb.Execute(ctx, func(cbCtx context.Context) error {
		resp, err := callDetectNutrientDeficiency(cbCtx, c.conn, requestID, images, plantSpeciesID)
		if err != nil {
			return fmt.Errorf("DetectNutrientDeficiency RPC failed: %w", err)
		}
		result = resp
		return nil
	})

	if err != nil {
		c.logger.Errorw("msg", "AI DetectNutrientDeficiency failed", "request_id", requestID, "error", err)
		return nil, err
	}

	return result, nil
}

// ClassifyPlant sends plant images for species identification.
func (c *AIClient) ClassifyPlant(ctx context.Context, requestID string, images []ImageInput) (*SpeciesClassificationResult, error) {
	var result *SpeciesClassificationResult

	err := c.cb.Execute(ctx, func(cbCtx context.Context) error {
		resp, err := callClassifyPlant(cbCtx, c.conn, requestID, images)
		if err != nil {
			return fmt.Errorf("ClassifyPlant RPC failed: %w", err)
		}
		result = resp
		return nil
	})

	if err != nil {
		c.logger.Errorw("msg", "AI ClassifyPlant failed", "request_id", requestID, "error", err)
		return nil, err
	}

	return result, nil
}

// GeneratePrescription sends diagnosis context to the AI Gateway for treatment prescription generation.
func (c *AIClient) GeneratePrescription(ctx context.Context, requestID string, input PrescriptionInput) (*PrescriptionResult, error) {
	var result *PrescriptionResult

	err := c.cb.Execute(ctx, func(cbCtx context.Context) error {
		resp, err := callGeneratePrescription(cbCtx, c.conn, requestID, input)
		if err != nil {
			return fmt.Errorf("GeneratePrescription RPC failed: %w", err)
		}
		result = resp
		return nil
	})

	if err != nil {
		c.logger.Errorw("msg", "AI GeneratePrescription failed", "request_id", requestID, "error", err)
		return nil, err
	}

	c.logger.Infow("msg", "AI GeneratePrescription completed",
		"request_id", requestID,
		"prescriptions", len(result.Prescriptions),
		"cost_savings_pct", result.EstimatedCostSavingsPct,
		"yield_gain_pct", result.EstimatedYieldGainPct,
		"processing_ms", result.ProcessingTimeMs,
	)

	return result, nil
}
