// Package ai provides a gRPC client for the AI Gateway service.
// It exposes pest detection and image-based pest identification operations
// needed by the pest-prediction-service.
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
	methodDetectPests   = "/agriculture.ai.v1.AIGatewayService/DetectPests"
	methodPredictYield  = "/agriculture.ai.v1.AIGatewayService/PredictYield"
)

// AIClient wraps the gRPC connection to the AI Gateway for pest operations.
type AIClient struct {
	conn   *grpc.ClientConn
	logger *p9log.Helper
}

// NewAIClient creates a new AI Gateway client for pest prediction.
func NewAIClient(addr string, logger *p9log.Helper) (*AIClient, error) {
	conn, err := grpc.NewClient(addr,
		grpc.WithTransportCredentials(insecure.NewCredentials()),
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
type ImageInput struct {
	ImageURL  string
	ImageType string
}

// DetectPestsFromImage sends observation images to the AI Gateway for AI-powered pest identification.
// This enhances the rule-based risk prediction with visual pest detection.
func (c *AIClient) DetectPestsFromImage(ctx context.Context, requestID string, images []ImageInput, plantSpeciesID string) (*PestDetectionResult, error) {
	reqFields := map[string]*structpb.Value{
		"request_id":       structpb.NewStringValue(requestID),
		"plant_species_id": structpb.NewStringValue(plantSpeciesID),
	}

	imageList := make([]*structpb.Value, 0, len(images))
	for _, img := range images {
		imgStruct, _ := structpb.NewStruct(map[string]interface{}{
			"image_url":  img.ImageURL,
			"image_type": img.ImageType,
		})
		imageList = append(imageList, structpb.NewStructValue(imgStruct))
	}
	reqFields["images"] = structpb.NewListValue(&structpb.ListValue{Values: imageList})

	reqMsg := &structpb.Struct{Fields: reqFields}
	respMsg := &structpb.Struct{}

	err := c.conn.Invoke(ctx, methodDetectPests, reqMsg, respMsg)
	if err != nil {
		c.logger.Errorw("msg", "AI DetectPests failed", "request_id", requestID, "error", err)
		return nil, fmt.Errorf("DetectPests invoke failed: %w", err)
	}

	result := parsePestResult(respMsg)
	c.logger.Infow("msg", "AI pest detection completed",
		"request_id", requestID,
		"pests_found", len(result.Pests),
		"processing_ms", result.ProcessingTimeMs,
	)

	return result, nil
}

func parsePestResult(resp *structpb.Struct) *PestDetectionResult {
	result := &PestDetectionResult{}
	if resp == nil || resp.Fields == nil {
		return result
	}

	result.RequestID = getStringField(resp, "request_id")
	result.ModelVersion = getStringField(resp, "model_version")
	result.ProcessingTimeMs = int64(getNumberField(resp, "processing_time_ms"))

	if pestList, ok := resp.Fields["pests"]; ok {
		if lv := pestList.GetListValue(); lv != nil {
			for _, pv := range lv.Values {
				if ps := pv.GetStructValue(); ps != nil {
					result.Pests = append(result.Pests, DetectedPest{
						PestID:          getStringField(ps, "pest_id"),
						PestName:        getStringField(ps, "pest_name"),
						ScientificName:  getStringField(ps, "scientific_name"),
						ConfidenceScore: getNumberField(ps, "confidence_score"),
						DamageLevel:     getStringField(ps, "damage_level"),
						Description:     getStringField(ps, "description"),
						DamagePattern:   getStringField(ps, "damage_pattern"),
						ControlMethods:  getStringListField(ps, "control_methods"),
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

func getStringListField(s *structpb.Struct, key string) []string {
	if v, ok := s.Fields[key]; ok {
		if lv := v.GetListValue(); lv != nil {
			result := make([]string, 0, len(lv.Values))
			for _, item := range lv.Values {
				result = append(result, item.GetStringValue())
			}
			return result
		}
	}
	return nil
}
