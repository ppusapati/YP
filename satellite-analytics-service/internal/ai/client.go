// Package ai provides a gRPC client for the AI Gateway service.
// It exposes NDVI computation and vegetation stress detection operations
// needed by the satellite-analytics-service.
// Calls go through the gateway's generated stubs. An earlier version sent
// `structpb.Struct` values over `conn.Invoke` with the method name written out
// by hand, which cannot work: a Struct serialises as a map entry list and
// bears no resemblance on the wire to the typed request the server decodes.
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

// AIClient wraps the gRPC connection to the AI Gateway for satellite analytics.
type AIClient struct {
	conn   *grpc.ClientConn
	logger *p9log.Helper
}

// NewAIClient creates a new AI Gateway client for satellite analytics.
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
			Timeout: 120 * time.Second,
		}),
		grpc.WithKeepaliveParams(keepalive.ClientParameters{
			Time:                10 * time.Second,
			Timeout:             3 * time.Second,
			PermitWithoutStream: true,
		}),
		grpc.WithDefaultCallOptions(
			grpc.MaxCallRecvMsgSize(128*1024*1024), // 128MB for raster data
			grpc.MaxCallSendMsgSize(128*1024*1024),
		),
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

// NDVIResult contains the computed vegetation index output.
type NDVIResult struct {
	RequestID        string
	NDVIValues       []float64
	Width            int32
	Height           int32
	Statistics       *BandStatistics
	Zones            []NDVIZone
	ModelVersion     string
	ProcessingTimeMs int64

	// Quality metadata from cloud masking and product checks.
	CloudMasked        bool
	CloudFraction      float64
	ValidPixelFraction float64
	ProcessingLevel    string
	ProcessingAdvisory string
	Sensor             string
	Harmonized         bool
}

// BandStatistics contains statistical summary of a raster band.
type BandStatistics struct {
	Min             float64
	Max             float64
	Mean            float64
	StdDev          float64
	Median          float64
	ValidPixelCount int64
}

// NDVIZone represents a classified zone in the NDVI output.
type NDVIZone struct {
	Classification string
	MinValue       float64
	MaxValue       float64
	PixelCount     int64
	AreaPct        float64
}

// VegetationStressResult contains the stress detection output.
type VegetationStressResult struct {
	RequestID        string
	StressZones      []StressZone
	OverallStressPct float64
	HealthyPct       float64
	NDVIStatistics   *BandStatistics
	ModelVersion     string
	ProcessingTimeMs int64
}

// StressZone represents a detected stress area.
type StressZone struct {
	StressType      string
	Severity        string
	AffectedAreaPct float64
	Confidence      float64
}

// RasterBandsInput contains the satellite raster band data plus optional QA
// layers and product metadata used for cloud masking and harmonization.
type RasterBandsInput struct {
	NIRBand     []float64
	RedBand     []float64
	GreenBand   []float64
	BlueBand    []float64
	RedEdgeBand []float64
	Width       int32
	Height      int32
	// SCLBand is the Sentinel-2 L2A scene classification layer (codes 0..11).
	SCLBand []float64
	// QAPixelBand is the Landsat Collection 2 QA_PIXEL bit mask.
	QAPixelBand []float64
	// ProcessingLevel is the product level label, e.g. "L2A", "L1C", "L2SP".
	ProcessingLevel string
	// Sensor is the imaging platform, e.g. "SENTINEL2", "LANDSAT8", "UAV".
	Sensor string
	// CloudBufferPixels dilates masked regions; 0 keeps the mask as delivered.
	CloudBufferPixels int32
}

// bandsToProto converts the caller's raster bands to the gateway's message.
//
// A nil input becomes a nil message rather than an empty one, so the gateway
// can tell "no inline bands, use raster_url" from "inline bands, all empty".
func bandsToProto(bands *RasterBandsInput) *aipb.RasterBands {
	if bands == nil {
		return nil
	}
	return &aipb.RasterBands{
		NirBand:           bands.NIRBand,
		RedBand:           bands.RedBand,
		GreenBand:         bands.GreenBand,
		BlueBand:          bands.BlueBand,
		RedEdgeBand:       bands.RedEdgeBand,
		SclBand:           bands.SCLBand,
		QaPixelBand:       bands.QAPixelBand,
		Width:             bands.Width,
		Height:            bands.Height,
		ProcessingLevel:   bands.ProcessingLevel,
		Sensor:            bands.Sensor,
		CloudBufferPixels: bands.CloudBufferPixels,
	}
}

func boundsToProto(b *BoundingBoxInput) *aipb.BoundingBox {
	if b == nil {
		return nil
	}
	return &aipb.BoundingBox{
		MinLon: b.MinLon,
		MinLat: b.MinLat,
		MaxLon: b.MaxLon,
		MaxLat: b.MaxLat,
	}
}

func bandStatsFromProto(s *aipb.BandStatistics) *BandStatistics {
	if s == nil {
		return nil
	}
	return &BandStatistics{
		Min:             s.GetMin(),
		Max:             s.GetMax(),
		Mean:            s.GetMean(),
		StdDev:          s.GetStdDev(),
		Median:          s.GetMedian(),
		ValidPixelCount: s.GetValidPixelCount(),
	}
}

func (c *AIClient) gateway() aipb.AIGatewayServiceClient {
	return aipb.NewAIGatewayServiceClient(c.conn)
}

// BoundingBoxInput describes the spatial clip bounds.
type BoundingBoxInput struct {
	MinLon float64
	MinLat float64
	MaxLon float64
	MaxLat float64
}

// ComputeNDVI calls the AI Gateway to compute NDVI from satellite raster bands.
func (c *AIClient) ComputeNDVI(ctx context.Context, requestID string, bands *RasterBandsInput, clipBounds *BoundingBoxInput) (*NDVIResult, error) {
	resp, err := c.gateway().ComputeNDVI(ctx, &aipb.ComputeNDVIRequest{
		RequestId:  requestID,
		Bands:      bandsToProto(bands),
		ClipBounds: boundsToProto(clipBounds),
	})
	if err != nil {
		c.logger.Errorw("msg", "AI ComputeNDVI failed", "request_id", requestID, "error", err)
		return nil, fmt.Errorf("ComputeNDVI: %w", err)
	}

	result := &NDVIResult{
		RequestID: resp.GetRequestId(),
		// The NDVI grid itself, which the previous parser never read despite
		// NDVIResult having the field — the RPC's actual output was dropped on
		// the floor and every caller saw an empty slice.
		NDVIValues:         resp.GetNdviValues(),
		Width:              resp.GetWidth(),
		Height:             resp.GetHeight(),
		Statistics:         bandStatsFromProto(resp.GetStatistics()),
		ModelVersion:       resp.GetModelVersion(),
		ProcessingTimeMs:   resp.GetProcessingTimeMs(),
		CloudMasked:        resp.GetCloudMasked(),
		CloudFraction:      resp.GetCloudFraction(),
		ValidPixelFraction: resp.GetValidPixelFraction(),
		ProcessingLevel:    resp.GetProcessingLevel(),
		ProcessingAdvisory: resp.GetProcessingAdvisory(),
		Sensor:             resp.GetSensor(),
		Harmonized:         resp.GetHarmonized(),
	}
	for _, z := range resp.GetZones() {
		result.Zones = append(result.Zones, NDVIZone{
			Classification: z.GetClassification(),
			MinValue:       z.GetMinValue(),
			MaxValue:       z.GetMaxValue(),
			PixelCount:     z.GetPixelCount(),
			AreaPct:        z.GetAreaPct(),
		})
	}
	return result, nil
}

// DetectVegetationStress asks the gateway to classify stressed areas.
func (c *AIClient) DetectVegetationStress(ctx context.Context, requestID string, bands *RasterBandsInput, ndviThreshold, ndwiThreshold float64) (*VegetationStressResult, error) {
	resp, err := c.gateway().DetectVegetationStress(ctx, &aipb.DetectVegetationStressRequest{
		RequestId:           requestID,
		Bands:               bandsToProto(bands),
		NdviStressThreshold: ndviThreshold,
		NdwiStressThreshold: ndwiThreshold,
	})
	if err != nil {
		c.logger.Errorw("msg", "AI DetectVegetationStress failed", "request_id", requestID, "error", err)
		return nil, fmt.Errorf("DetectVegetationStress: %w", err)
	}

	result := &VegetationStressResult{
		RequestID:        resp.GetRequestId(),
		OverallStressPct: resp.GetOverallStressPct(),
		HealthyPct:       resp.GetHealthyPct(),
		NDVIStatistics:   bandStatsFromProto(resp.GetNdviStatistics()),
		ModelVersion:     resp.GetModelVersion(),
		ProcessingTimeMs: resp.GetProcessingTimeMs(),
	}
	for _, z := range resp.GetStressZones() {
		result.StressZones = append(result.StressZones, StressZone{
			StressType:      z.GetStressType(),
			Severity:        z.GetSeverity(),
			AffectedAreaPct: z.GetAffectedAreaPct(),
			Confidence:      z.GetConfidence(),
		})
	}
	return result, nil
}
