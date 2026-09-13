// Package ai provides a gRPC client for the AI Gateway service.
// It exposes NDVI computation and vegetation stress detection operations
// needed by the satellite-analytics-service.
package ai

import (
	"context"
	"fmt"
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/keepalive"
	"google.golang.org/protobuf/types/known/structpb"
	"p9e.in/samavaya/packages/grpcdial"

	"p9e.in/samavaya/packages/p9log"
)

const (
	methodComputeNDVI            = "/agriculture.ai.v1.AIGatewayService/ComputeNDVI"
	methodDetectVegetationStress = "/agriculture.ai.v1.AIGatewayService/DetectVegetationStress"
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

// bandsToStruct serializes RasterBandsInput for the structpb transport,
// including the band arrays and QA metadata.
func bandsToStruct(bands *RasterBandsInput) *structpb.Struct {
	if bands == nil {
		s, _ := structpb.NewStruct(map[string]interface{}{})
		return s
	}
	fields := map[string]interface{}{
		"width":               float64(bands.Width),
		"height":              float64(bands.Height),
		"processing_level":    bands.ProcessingLevel,
		"sensor":              bands.Sensor,
		"cloud_buffer_pixels": float64(bands.CloudBufferPixels),
	}
	addBand := func(key string, values []float64) {
		if len(values) == 0 {
			return
		}
		list := make([]interface{}, len(values))
		for i, v := range values {
			list[i] = v
		}
		fields[key] = list
	}
	addBand("nir_band", bands.NIRBand)
	addBand("red_band", bands.RedBand)
	addBand("green_band", bands.GreenBand)
	addBand("blue_band", bands.BlueBand)
	addBand("red_edge_band", bands.RedEdgeBand)
	addBand("scl_band", bands.SCLBand)
	addBand("qa_pixel_band", bands.QAPixelBand)
	s, _ := structpb.NewStruct(fields)
	return s
}

// BoundingBoxInput describes the spatial clip bounds.
type BoundingBoxInput struct {
	MinLon float64
	MinLat float64
	MaxLon float64
	MaxLat float64
}

// ComputeNDVI calls the AI Gateway to compute NDVI from satellite raster bands.
// This replaces the placeholder computation with the Rust satellite-ndvi-engine.
func (c *AIClient) ComputeNDVI(ctx context.Context, requestID string, bands *RasterBandsInput, clipBounds *BoundingBoxInput) (*NDVIResult, error) {
	reqFields := map[string]*structpb.Value{
		"request_id": structpb.NewStringValue(requestID),
		"bands":      structpb.NewStructValue(bandsToStruct(bands)),
	}

	if clipBounds != nil {
		boundsStruct, _ := structpb.NewStruct(map[string]interface{}{
			"min_lon": clipBounds.MinLon,
			"min_lat": clipBounds.MinLat,
			"max_lon": clipBounds.MaxLon,
			"max_lat": clipBounds.MaxLat,
		})
		reqFields["clip_bounds"] = structpb.NewStructValue(boundsStruct)
	}

	reqMsg := &structpb.Struct{Fields: reqFields}
	respMsg := &structpb.Struct{}

	err := c.conn.Invoke(ctx, methodComputeNDVI, reqMsg, respMsg)
	if err != nil {
		c.logger.Errorw("msg", "AI ComputeNDVI failed", "request_id", requestID, "error", err)
		return nil, fmt.Errorf("ComputeNDVI invoke failed: %w", err)
	}

	result := parseNDVIResult(respMsg)
	c.logger.Infow("msg", "AI NDVI computation completed",
		"request_id", requestID,
		"width", result.Width,
		"height", result.Height,
		"processing_ms", result.ProcessingTimeMs,
	)

	return result, nil
}

// DetectVegetationStress calls the AI Gateway to detect crop stress from satellite data.
// This replaces the placeholder stress detection with the Rust engine.
func (c *AIClient) DetectVegetationStress(ctx context.Context, requestID string, bands *RasterBandsInput, ndviThreshold, ndwiThreshold float64) (*VegetationStressResult, error) {
	reqFields := map[string]*structpb.Value{
		"request_id":            structpb.NewStringValue(requestID),
		"bands":                 structpb.NewStructValue(bandsToStruct(bands)),
		"ndvi_stress_threshold": structpb.NewNumberValue(ndviThreshold),
		"ndwi_stress_threshold": structpb.NewNumberValue(ndwiThreshold),
	}

	reqMsg := &structpb.Struct{Fields: reqFields}
	respMsg := &structpb.Struct{}

	err := c.conn.Invoke(ctx, methodDetectVegetationStress, reqMsg, respMsg)
	if err != nil {
		c.logger.Errorw("msg", "AI DetectVegetationStress failed", "request_id", requestID, "error", err)
		return nil, fmt.Errorf("DetectVegetationStress invoke failed: %w", err)
	}

	result := parseStressResult(respMsg)
	c.logger.Infow("msg", "AI vegetation stress detection completed",
		"request_id", requestID,
		"stress_zones", len(result.StressZones),
		"overall_stress_pct", result.OverallStressPct,
		"processing_ms", result.ProcessingTimeMs,
	)

	return result, nil
}

// ─────────────────────────────────────────────────────────────────────────────
// Response parsers
// ─────────────────────────────────────────────────────────────────────────────

func parseNDVIResult(resp *structpb.Struct) *NDVIResult {
	result := &NDVIResult{}
	if resp == nil || resp.Fields == nil {
		return result
	}

	result.RequestID = getStringField(resp, "request_id")
	result.Width = int32(getNumberField(resp, "width"))
	result.Height = int32(getNumberField(resp, "height"))
	result.ModelVersion = getStringField(resp, "model_version")
	result.ProcessingTimeMs = int64(getNumberField(resp, "processing_time_ms"))
	result.CloudFraction = getNumberField(resp, "cloud_fraction")
	result.ValidPixelFraction = getNumberField(resp, "valid_pixel_fraction")
	result.ProcessingLevel = getStringField(resp, "processing_level")
	result.ProcessingAdvisory = getStringField(resp, "processing_advisory")
	result.Sensor = getStringField(resp, "sensor")
	if v, ok := resp.Fields["cloud_masked"]; ok {
		result.CloudMasked = v.GetBoolValue()
	}
	if v, ok := resp.Fields["harmonized"]; ok {
		result.Harmonized = v.GetBoolValue()
	}

	if statsVal, ok := resp.Fields["statistics"]; ok {
		if ss := statsVal.GetStructValue(); ss != nil {
			result.Statistics = parseBandStats(ss)
		}
	}

	if zoneList, ok := resp.Fields["zones"]; ok {
		if lv := zoneList.GetListValue(); lv != nil {
			for _, zv := range lv.Values {
				if zs := zv.GetStructValue(); zs != nil {
					result.Zones = append(result.Zones, NDVIZone{
						Classification: getStringField(zs, "classification"),
						MinValue:       getNumberField(zs, "min_value"),
						MaxValue:       getNumberField(zs, "max_value"),
						PixelCount:     int64(getNumberField(zs, "pixel_count")),
						AreaPct:        getNumberField(zs, "area_pct"),
					})
				}
			}
		}
	}

	return result
}

func parseStressResult(resp *structpb.Struct) *VegetationStressResult {
	result := &VegetationStressResult{}
	if resp == nil || resp.Fields == nil {
		return result
	}

	result.RequestID = getStringField(resp, "request_id")
	result.OverallStressPct = getNumberField(resp, "overall_stress_pct")
	result.HealthyPct = getNumberField(resp, "healthy_pct")
	result.ModelVersion = getStringField(resp, "model_version")
	result.ProcessingTimeMs = int64(getNumberField(resp, "processing_time_ms"))

	if statsVal, ok := resp.Fields["ndvi_statistics"]; ok {
		if ss := statsVal.GetStructValue(); ss != nil {
			result.NDVIStatistics = parseBandStats(ss)
		}
	}

	if szList, ok := resp.Fields["stress_zones"]; ok {
		if lv := szList.GetListValue(); lv != nil {
			for _, sv := range lv.Values {
				if ss := sv.GetStructValue(); ss != nil {
					result.StressZones = append(result.StressZones, StressZone{
						StressType:      getStringField(ss, "stress_type"),
						Severity:        getStringField(ss, "severity"),
						AffectedAreaPct: getNumberField(ss, "affected_area_pct"),
						Confidence:      getNumberField(ss, "confidence"),
					})
				}
			}
		}
	}

	return result
}

func parseBandStats(s *structpb.Struct) *BandStatistics {
	return &BandStatistics{
		Min:             getNumberField(s, "min"),
		Max:             getNumberField(s, "max"),
		Mean:            getNumberField(s, "mean"),
		StdDev:          getNumberField(s, "std_dev"),
		Median:          getNumberField(s, "median"),
		ValidPixelCount: int64(getNumberField(s, "valid_pixel_count")),
	}
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
