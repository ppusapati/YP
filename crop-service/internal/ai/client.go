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
	methodRecommendCrops = "/agriculture.ai.v1.AIGatewayService/RecommendCrops"
)

type AIClient struct {
	conn   *grpc.ClientConn
	logger *p9log.Helper
}

func NewAIClient(addr string, logger *p9log.Helper) (*AIClient, error) {
	conn, err := grpc.NewClient(addr,
		grpcdial.TransportCredentials(),
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

type CropRecommendation struct {
	CropName       string
	SuitabilityPct float64
	Season         string
	Reasons        []string
}

type RecommendCropsRequest struct {
	SoilType    string
	SoilPH      float64
	Rainfall    float64
	Temperature float64
	Humidity    float64
	Latitude    float64
	Longitude   float64
	Season      string
}

func (c *AIClient) RecommendCrops(ctx context.Context, req *RecommendCropsRequest) ([]CropRecommendation, error) {
	in, err := structpb.NewStruct(map[string]interface{}{
		"soil_type":   req.SoilType,
		"soil_ph":     req.SoilPH,
		"rainfall_mm": req.Rainfall,
		"temperature": req.Temperature,
		"humidity":    req.Humidity,
		"latitude":    req.Latitude,
		"longitude":   req.Longitude,
		"season":      req.Season,
	})
	if err != nil {
		return nil, fmt.Errorf("build request: %w", err)
	}

	out := &structpb.Struct{}
	if err := c.conn.Invoke(ctx, methodRecommendCrops, in, out); err != nil {
		c.logger.Errorf("RecommendCrops RPC failed: %v", err)
		return nil, fmt.Errorf("recommend crops: %w", err)
	}

	return parseRecommendations(out), nil
}

func parseRecommendations(s *structpb.Struct) []CropRecommendation {
	fields := s.GetFields()
	recsList := fields["recommendations"].GetListValue()
	if recsList == nil {
		return nil
	}

	var recs []CropRecommendation
	for _, v := range recsList.GetValues() {
		m := v.GetStructValue().GetFields()
		var reasons []string
		if r := m["reasons"].GetListValue(); r != nil {
			for _, rv := range r.GetValues() {
				reasons = append(reasons, rv.GetStringValue())
			}
		}
		recs = append(recs, CropRecommendation{
			CropName:       m["crop_name"].GetStringValue(),
			SuitabilityPct: m["suitability_pct"].GetNumberValue(),
			Season:         m["season"].GetStringValue(),
			Reasons:        reasons,
		})
	}
	return recs
}
