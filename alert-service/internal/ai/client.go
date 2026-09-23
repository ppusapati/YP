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

// FieldConditions is what alert-service knows about a field's current state.
//
// Every field here was previously left unset, and the gateway substitutes its
// own defaults for anything absent — 22°C, 30% soil moisture — so a score came
// back describing an imaginary temperate day rather than this field. Nothing
// errored and the number looked like a measurement.
//
// A zero-valued FieldConditions therefore still works and still means "score
// against the defaults"; it is the honest representation of knowing nothing,
// and the caller says so explicitly rather than by omission.
type FieldConditions struct {
	TemperatureCurrent      float64
	TemperatureMinForecast  float64
	TemperatureMaxForecast  float64
	PrecipitationMm         float64
	PrecipitationForecastMm float64
	EtReferenceMm           float64
	// SoilMoisture is volumetric, m³/m³, on the same 0..1 scale as the
	// gateway's own default of 0.30 — not a percentage.
	SoilMoisture float64

	// Detections are findings from the field's most recent plant diagnosis.
	// Confidences are probabilities on 0..1; NutrientSeverity is a graded
	// 0..1 severity, not a confidence.
	//
	// HasDetections separates "nothing was found" from "nobody looked". The
	// two score identically today — an absent DetectionResults and an
	// all-zero one both fall below every threshold — but only one of them is
	// true, and sending a DetectionResults full of zeros would put an
	// "Unknown" pest species one threshold change away from an alert.
	PestConfidence    float64
	PestSpecies       string
	DiseaseConfidence float64
	DiseaseName       string
	NutrientSeverity  float64
	NutrientType      string
	HasDetections     bool
}

// EvaluateFieldRisk asks the gateway to score a field's risk from its
// current conditions.
//
// Growth is still unset, and deliberately so. The gateway's growth risk is a
// comparison — growth_actual against growth_expected — and nothing in this
// platform holds an expected value to compare against. There is no crop growth
// curve, no per-stage NDVI reference, nothing; satellite-analytics' baseline is
// the fitted start of whatever window was asked for, which a healthy crop
// outgrows by far more than the 20% deviation threshold within weeks of
// emergence. Wiring that in would generate a "Growth anomaly" alert for every
// field that is growing normally. Growth risk therefore reads 0 here, which is
// worth knowing when reading a growth figure from this service.
//
// NDVI is unset for the same reason rather than a different one. The gateway
// accepts ndvi_current and ndvi_previous, but the alert engine only ever prints
// them inside the growth-anomaly message — they enter no score — so with no
// expected value to raise that alert, sending them would add a dependency on
// vegetation-index-service, and a field-to-farm lookup to satisfy it, in
// exchange for nothing observable.
func (c *AIClient) EvaluateFieldRisk(ctx context.Context, requestID, fieldID string, cond FieldConditions) (*alertmodels.FieldRiskScore, error) {
	req := &aipb.EvaluateFieldRiskRequest{
		RequestId: requestID,
		FieldId:   fieldID,
		Weather: &aipb.FieldWeather{
			TemperatureCurrent:      cond.TemperatureCurrent,
			TemperatureMinForecast:  cond.TemperatureMinForecast,
			TemperatureMaxForecast:  cond.TemperatureMaxForecast,
			PrecipitationMm:         cond.PrecipitationMm,
			PrecipitationForecastMm: cond.PrecipitationForecastMm,
			EtReferenceMm:           cond.EtReferenceMm,
		},
		SoilState: &aipb.FieldSoilState{SoilMoisture: cond.SoilMoisture},
	}
	// Left nil when the field has no recent diagnosis, so that "not looked at"
	// stays distinguishable from "looked at and clean".
	if cond.HasDetections {
		req.Detections = &aipb.DetectionResults{
			PestConfidence:    cond.PestConfidence,
			PestSpecies:       cond.PestSpecies,
			DiseaseConfidence: cond.DiseaseConfidence,
			DiseaseName:       cond.DiseaseName,
			NutrientSeverity:  cond.NutrientSeverity,
			NutrientType:      cond.NutrientType,
		}
	}

	resp, err := c.gateway().EvaluateFieldRisk(ctx, req)
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
