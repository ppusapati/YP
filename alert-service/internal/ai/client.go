// Package ai provides a gRPC client for the AI Gateway service.
// It exposes field risk evaluation operations needed by the alert-service.
package ai

import (
	"context"
	"fmt"
	"time"

	"google.golang.org/grpc"
	"p9e.in/samavaya/packages/grpcdial"
	"google.golang.org/grpc/keepalive"
	"google.golang.org/protobuf/types/known/structpb"

	alertmodels "p9e.in/samavaya/agriculture/alert-service/internal/models"
	"p9e.in/samavaya/packages/p9log"
)

const (
	methodEvaluateFieldRisk = "/agriculture.ai.v1.AIGatewayService/EvaluateFieldRisk"
)

// AIClient wraps the gRPC connection to the AI Gateway for alert operations.
type AIClient struct {
	conn   *grpc.ClientConn
	logger *p9log.Helper
}

// NewAIClient creates a new AI Gateway client for field risk evaluation.
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

// EvaluateFieldRisk sends a field risk evaluation request to the AI Gateway
// and returns the resulting FieldRiskScore.
func (c *AIClient) EvaluateFieldRisk(ctx context.Context, requestID, fieldID string) (*alertmodels.FieldRiskScore, error) {
	reqFields := map[string]*structpb.Value{
		"request_id": structpb.NewStringValue(requestID),
		"field_id":   structpb.NewStringValue(fieldID),
	}

	reqMsg := &structpb.Struct{Fields: reqFields}
	respMsg := &structpb.Struct{}

	err := c.conn.Invoke(ctx, methodEvaluateFieldRisk, reqMsg, respMsg)
	if err != nil {
		c.logger.Errorw("msg", "AI EvaluateFieldRisk failed", "request_id", requestID, "error", err)
		return nil, fmt.Errorf("EvaluateFieldRisk invoke failed: %w", err)
	}

	result := parseFieldRiskScore(respMsg)
	c.logger.Infow("msg", "AI field risk evaluation completed",
		"request_id", requestID,
		"field_id", result.FieldID,
		"overall_risk", result.OverallRisk,
		"alert_count", len(result.Alerts),
	)

	return result, nil
}

func parseFieldRiskScore(resp *structpb.Struct) *alertmodels.FieldRiskScore {
	result := &alertmodels.FieldRiskScore{}
	if resp == nil || resp.Fields == nil {
		return result
	}

	result.FieldID = getStringField(resp, "field_id")
	result.FarmID = getStringField(resp, "farm_id")
	result.OverallRisk = getNumberField(resp, "overall_risk")
	result.TemperatureRisk = getNumberField(resp, "temperature_risk")
	result.WaterRisk = getNumberField(resp, "water_risk")
	result.PestRisk = getNumberField(resp, "pest_risk")
	result.DiseaseRisk = getNumberField(resp, "disease_risk")
	result.NutrientRisk = getNumberField(resp, "nutrient_risk")
	result.GrowthRisk = getNumberField(resp, "growth_risk")

	if evalAt := getStringField(resp, "evaluated_at"); evalAt != "" {
		if t, err := time.Parse(time.RFC3339, evalAt); err == nil {
			result.EvaluatedAt = t
		}
	}
	if result.EvaluatedAt.IsZero() {
		result.EvaluatedAt = time.Now()
	}

	// Parse embedded alerts
	if alertList, ok := resp.Fields["alerts"]; ok {
		if lv := alertList.GetListValue(); lv != nil {
			for _, av := range lv.Values {
				if as := av.GetStructValue(); as != nil {
					alert := alertmodels.Alert{
						AlertType:       alertmodels.AlertType(getStringField(as, "alert_type")),
						Severity:        alertmodels.AlertSeverity(getStringField(as, "severity")),
						FieldID:         getStringField(as, "field_id"),
						FarmID:          getStringField(as, "farm_id"),
						Title:           getStringField(as, "title"),
						Message:         getStringField(as, "message"),
						Recommendations: getStringListField(as, "recommendations"),
						MetricValue:     getNumberField(as, "metric_value"),
						ThresholdValue:  getNumberField(as, "threshold_value"),
						Status:          alertmodels.AlertStatusActive,
					}
					result.Alerts = append(result.Alerts, alert)
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
