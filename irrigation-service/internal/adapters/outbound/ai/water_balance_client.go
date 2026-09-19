// Package ai provides a gRPC client for the AI Gateway water-flow simulation.
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
	rain := make([]interface{}, 0, days)
	for i := 0; i < days; i++ {
		if i < len(req.DailyRainfallMM) {
			rain = append(rain, req.DailyRainfallMM[i])
		} else {
			rain = append(rain, 0.0)
		}
	}

	balance, _ := structpb.NewStruct(map[string]interface{}{
		"field_area_ha":                req.FieldAreaHa,
		"crop_type":                    req.CropType,
		"growth_stage":                 req.GrowthStage,
		"days_after_planting":          float64(req.DaysAfterPlanting),
		"reference_et_mm_day":          req.ReferenceET0MMDay,
		"root_zone_depth_m":            req.RootZoneDepthM,
		"field_capacity":               req.FieldCapacity,
		"wilting_point":                req.WiltingPoint,
		"management_allowed_depletion": req.AllowedDepletion,
	})
	reqMsg := &structpb.Struct{Fields: map[string]*structpb.Value{
		"request_id":           structpb.NewStringValue(fmt.Sprintf("wb-%d", time.Now().UnixNano())),
		"balance_params":       structpb.NewStructValue(balance),
		"daily_rainfall_mm":    structpb.NewListValue(mustList(rain)),
		"simulation_days":      structpb.NewNumberValue(float64(days)),
		"et_mm_day":            structpb.NewNumberValue(req.ReferenceET0MMDay),
		"initial_depletion_mm": structpb.NewNumberValue(req.InitialDepletionMM),
	}}
	respMsg := &structpb.Struct{}
	if err := c.conn.Invoke(ctx, methodSimulateWaterFlow, reqMsg, respMsg); err != nil {
		c.logger.Errorw("msg", "AI SimulateWaterFlow failed", "error", err)
		return nil, fmt.Errorf("SimulateWaterFlow invoke failed: %w", err)
	}
	return parseWaterBalance(respMsg), nil
}

func mustList(values []interface{}) *structpb.ListValue {
	lv, _ := structpb.NewList(values)
	return lv
}

func parseWaterBalance(resp *structpb.Struct) *outbound.WaterBalanceResult {
	out := &outbound.WaterBalanceResult{}
	if resp == nil || resp.Fields == nil {
		return out
	}
	if lv := resp.Fields["water_balance"].GetListValue(); lv != nil {
		for _, v := range lv.Values {
			s := v.GetStructValue()
			if s == nil {
				continue
			}
			out.Days = append(out.Days, outbound.WaterBalanceDay{
				Day:                 int(num(s, "day")),
				ETcMMDay:            num(s, "etc_mm_day"),
				DepletionMM:         num(s, "depletion_mm"),
				TotalAvailableMM:    num(s, "total_available_water_mm"),
				ReadilyAvailableMM:  num(s, "readily_available_water_mm"),
				IrrigationNeeded:    s.Fields["irrigation_needed"].GetBoolValue(),
				IrrigationAmountMM:  num(s, "irrigation_amount_mm"),
				EffectiveRainfallMM: num(s, "effective_rainfall_mm"),
			})
		}
	}
	if s := resp.Fields["irrigation_summary"].GetStructValue(); s != nil {
		out.TotalIrrigationMM = num(s, "total_irrigation_mm")
		out.IrrigationEvents = int(num(s, "irrigation_events"))
	}
	// ETc/ET0 on day 1 recovers the crop coefficient the gateway resolved.
	if len(out.Days) > 0 && out.Days[0].ETcMMDay > 0 {
		out.CropCoefficient = out.Days[0].ETcMMDay
	}
	return out
}

func num(s *structpb.Struct, key string) float64 {
	if v, ok := s.Fields[key]; ok {
		return v.GetNumberValue()
	}
	return 0
}
