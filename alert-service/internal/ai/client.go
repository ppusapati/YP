// Package ai provides a gRPC client for the AI Gateway service.
// It exposes field risk evaluation operations needed by the alert-service.
//
// Calls go through the gateway's generated stubs. An earlier version sent
// `structpb.Struct` values over `conn.Invoke` with the method name written out
// by hand, which cannot work: a Struct serialises as a map entry list and
// bears no resemblance on the wire to the typed request the server decodes.
//
// Two of the fields it read back do not exist on the response at all.
// EvaluateFieldRiskResponse has no `farm_id` and no `evaluated_at`, and
// FieldAlert has neither `field_id` nor `farm_id` — so FarmID was always empty
// and the evaluation timestamp always fell through to "now". Those reads are
// gone rather than reinstated, because the server has nothing to put in them.
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

	aipb "p9e.in/samavaya/agriculture/ai-gateway/api/v1"
	alertmodels "p9e.in/samavaya/agriculture/alert-service/internal/models"
	"p9e.in/samavaya/packages/p9log"
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

func (c *AIClient) gateway() aipb.AIGatewayServiceClient {
	return aipb.NewAIGatewayServiceClient(c.conn)
}

// EvaluateFieldRisk asks the gateway to score a field's risk.
//
// Only the field id is sent, because that is all alert-service holds. The
// gateway fills the rest in with defaults — 22°C, 30% soil moisture, no
// detections — so the score that comes back describes a temperate day on an
// average field rather than this one. That is a real limitation and it is
// worse now than it was, because the rule scanner calls this on a timer:
// closing it means alert-service acquiring weather, soil and detection inputs
// for the field and passing them here, which is a larger change than moving
// onto the generated stubs.
func (c *AIClient) EvaluateFieldRisk(ctx context.Context, requestID, fieldID string) (*alertmodels.FieldRiskScore, error) {
	resp, err := c.gateway().EvaluateFieldRisk(ctx, &aipb.EvaluateFieldRiskRequest{
		RequestId: requestID,
		FieldId:   fieldID,
	})
	if err != nil {
		c.logger.Errorw("msg", "AI EvaluateFieldRisk failed", "request_id", requestID, "error", err)
		return nil, fmt.Errorf("EvaluateFieldRisk: %w", err)
	}

	result := &alertmodels.FieldRiskScore{
		FieldID:         resp.GetFieldId(),
		OverallRisk:     resp.GetOverallRisk(),
		TemperatureRisk: resp.GetTemperatureRisk(),
		WaterRisk:       resp.GetWaterRisk(),
		PestRisk:        resp.GetPestRisk(),
		DiseaseRisk:     resp.GetDiseaseRisk(),
		NutrientRisk:    resp.GetNutrientRisk(),
		GrowthRisk:      resp.GetGrowthRisk(),
		// The response carries no timestamp, so this is when the answer
		// arrived here. Stamped locally rather than left zero, because
		// UpsertFieldRisk guards on it to reject an out-of-order write.
		EvaluatedAt: time.Now().UTC(),
	}

	for _, a := range resp.GetAlerts() {
		result.Alerts = append(result.Alerts, alertmodels.Alert{
			AlertType: alertmodels.AlertType(a.GetAlertType()),
			Severity:  alertmodels.AlertSeverity(a.GetSeverity()),
			// FieldID comes from the request, not the alert: FieldAlert has no
			// field of its own, and an alert with no field cannot be stored.
			FieldID:         fieldID,
			Title:           a.GetTitle(),
			Message:         a.GetMessage(),
			Recommendations: a.GetRecommendations(),
			MetricValue:     a.GetMetricValue(),
			ThresholdValue:  a.GetThresholdValue(),
			Status:          alertmodels.AlertStatusActive,
		})
	}

	c.logger.Infow("msg", "AI field risk evaluation completed",
		"request_id", requestID,
		"field_id", result.FieldID,
		"overall_risk", result.OverallRisk,
		"alert_count", len(result.Alerts),
	)
	return result, nil
}
