// Package ai provides a gRPC client for the AI Gateway water-flow simulation.
package ai

import (
	"context"
	"fmt"
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/keepalive"

	"p9e.in/samavaya/packages/grpcdial"
	"p9e.in/samavaya/packages/p9log"

	aipb "p9e.in/samavaya/agriculture/ai-gateway/api/v1"
	"p9e.in/samavaya/packages/ratelimit/algorithms"
	"p9e.in/samavaya/packages/ratelimit/grpclimit"

	"p9e.in/samavaya/agriculture/irrigation-service/internal/ports/outbound"
)

const methodSimulateWaterFlow = "/agriculture.ai.v1.AIGatewayService/SimulateWaterFlow"

// WaterBalanceClient calls SimulateWaterFlow on the AI gateway.
type WaterBalanceClient struct {
	conn   *grpc.ClientConn
	logger *p9log.Helper
}

// NewWaterBalanceClient dials the AI gateway.
func NewWaterBalanceClient(addr string, logger *p9log.Helper) (*WaterBalanceClient, error) {
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
	return &WaterBalanceClient{conn: conn, logger: logger}, nil
}

// Close closes the underlying connection.
func (c *WaterBalanceClient) Close() error {
	if c.conn != nil {
		return c.conn.Close()
	}
	return nil
}

var _ outbound.WaterBalanceClient = (*WaterBalanceClient)(nil)

// Simulate runs the FAO-56 water balance for the request.
func (c *WaterBalanceClient) Simulate(ctx context.Context, req outbound.WaterBalanceRequest) (*outbound.WaterBalanceResult, error) {
	days := req.SimulationDays
	if days <= 0 {
		days = len(req.DailyRainfallMM)
	}
	if days <= 0 {
		days = 7
	}

	// Padded to the simulation length so a short rainfall series means "no
	// rain after this point" rather than a series the gateway reads as
	// shorter than the run.
	rain := make([]float64, days)
	copy(rain, req.DailyRainfallMM)

	resp, err := c.gateway().SimulateWaterFlow(ctx, &aipb.SimulateWaterFlowRequest{
		RequestId: fmt.Sprintf("wb-%d", time.Now().UnixNano()),
		BalanceParams: &aipb.WaterFlowBalanceParams{
			FieldAreaHa:                req.FieldAreaHa,
			ReferenceEtMmDay:           req.ReferenceET0MMDay,
			RootZoneDepthM:             req.RootZoneDepthM,
			FieldCapacity:              req.FieldCapacity,
			WiltingPoint:               req.WiltingPoint,
			ManagementAllowedDepletion: req.AllowedDepletion,
			CropType:                   req.CropType,
			GrowthStage:                req.GrowthStage,
			DaysAfterPlanting:          int32(req.DaysAfterPlanting),
		},
		DailyRainfallMm:    rain,
		SimulationDays:     float64(days),
		EtMmDay:            req.ReferenceET0MMDay,
		InitialDepletionMm: req.InitialDepletionMM,
	})
	if err != nil {
		c.logger.Errorw("msg", "AI SimulateWaterFlow failed", "error", err)
		return nil, fmt.Errorf("SimulateWaterFlow: %w", err)
	}

	out := &outbound.WaterBalanceResult{}
	for _, d := range resp.GetWaterBalance() {
		out.Days = append(out.Days, outbound.WaterBalanceDay{
			Day:                 int(d.GetDay()),
			ETcMMDay:            d.GetEtcMmDay(),
			DepletionMM:         d.GetDepletionMm(),
			TotalAvailableMM:    d.GetTotalAvailableWaterMm(),
			ReadilyAvailableMM:  d.GetReadilyAvailableWaterMm(),
			IrrigationNeeded:    d.GetIrrigationNeeded(),
			IrrigationAmountMM:  d.GetIrrigationAmountMm(),
			EffectiveRainfallMM: d.GetEffectiveRainfallMm(),
		})
	}
	if s := resp.GetIrrigationSummary(); s != nil {
		out.TotalIrrigationMM = s.GetTotalIrrigationMm()
		out.IrrigationEvents = int(s.GetIrrigationEvents())
	}

	// Kc is ETc divided by ET0, and the division was missing: this used to
	// assign ETc straight across under a comment reading "ETc/ET0", so the
	// crop coefficient carried millimetres per day where a dimensionless
	// ratio belongs — roughly 4 to 6 where FAO-56 expects 0.3 to 1.2.
	if len(out.Days) > 0 && req.ReferenceET0MMDay > 0 {
		out.CropCoefficient = out.Days[0].ETcMMDay / req.ReferenceET0MMDay
	}
	return out, nil
}

func (c *WaterBalanceClient) gateway() aipb.AIGatewayServiceClient {
	return aipb.NewAIGatewayServiceClient(c.conn)
}
