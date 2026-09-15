// Package grpc adapts the ConnectRPC surface onto planning-service's use cases.
package grpc

import (
	"context"
	"strconv"

	"connectrpc.com/connect"
	"google.golang.org/protobuf/types/known/timestamppb"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"

	pb "p9e.in/samavaya/agriculture/planning-service/api/v1"
	"p9e.in/samavaya/agriculture/planning-service/internal/domain"
	"p9e.in/samavaya/agriculture/planning-service/internal/ports/inbound"
)

// PlanningHandler serves the PlanningService RPCs.
type PlanningHandler struct {
	svc inbound.PlanningService
	log *p9log.Helper
}

// NewPlanningHandler creates a PlanningHandler.
func NewPlanningHandler(svc inbound.PlanningService, log p9log.Logger) *PlanningHandler {
	return &PlanningHandler{
		svc: svc,
		log: p9log.NewHelper(p9log.With(log, "component", "PlanningHandler")),
	}
}

func (h *PlanningHandler) CreatePlan(ctx context.Context, req *connect.Request[pb.CreatePlanRequest]) (*connect.Response[pb.CreatePlanResponse], error) {
	plan, err := h.svc.CreatePlan(ctx, &domain.SeasonPlan{
		FieldID:             req.Msg.GetFieldId(),
		FarmID:              req.Msg.GetFarmId(),
		Season:              seasonFromProto(req.Msg.GetSeason()),
		Year:                int(req.Msg.GetYear()),
		Crop:                req.Msg.GetCrop(),
		Variety:             req.Msg.GetVariety(),
		AreaHectares:        req.Msg.GetAreaHectares(),
		TargetYieldTonnesHa: req.Msg.GetTargetYieldTonnesHa(),
		Notes:               req.Msg.GetNotes(),
	})
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.CreatePlanResponse{Plan: planToProto(plan)}), nil
}

func (h *PlanningHandler) GetPlan(ctx context.Context, req *connect.Request[pb.GetPlanRequest]) (*connect.Response[pb.GetPlanResponse], error) {
	plan, err := h.svc.GetPlan(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.GetPlanResponse{Plan: planToProto(plan)}), nil
}

func (h *PlanningHandler) ListPlans(ctx context.Context, req *connect.Request[pb.ListPlansRequest]) (*connect.Response[pb.ListPlansResponse], error) {
	limit, offset := page(req.Msg.GetPageSize(), req.Msg.GetPageToken())

	plans, total, err := h.svc.ListPlans(ctx, domain.ListPlansParams{
		FieldID: req.Msg.GetFieldId(),
		FarmID:  req.Msg.GetFarmId(),
		Season:  seasonFromProto(req.Msg.GetSeason()),
		Year:    int(req.Msg.GetYear()),
		Status:  statusFromProto(req.Msg.GetStatus()),
		Limit:   limit,
		Offset:  offset,
	})
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	out := make([]*pb.SeasonPlan, 0, len(plans))
	for i := range plans {
		out = append(out, planToProto(&plans[i]))
	}
	return connect.NewResponse(&pb.ListPlansResponse{
		Plans:         out,
		NextPageToken: nextToken(offset, limit, total),
		TotalCount:    int32(total),
	}), nil
}

func (h *PlanningHandler) UpdatePlan(ctx context.Context, req *connect.Request[pb.UpdatePlanRequest]) (*connect.Response[pb.UpdatePlanResponse], error) {
	plan, err := h.svc.UpdatePlan(ctx, &domain.SeasonPlan{
		ID:                  req.Msg.GetId(),
		Crop:                req.Msg.GetCrop(),
		Variety:             req.Msg.GetVariety(),
		AreaHectares:        req.Msg.GetAreaHectares(),
		TargetYieldTonnesHa: req.Msg.GetTargetYieldTonnesHa(),
		Notes:               req.Msg.GetNotes(),
	}, req.Msg.GetBaseVersion())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.UpdatePlanResponse{Plan: planToProto(plan)}), nil
}

func (h *PlanningHandler) CommitPlan(ctx context.Context, req *connect.Request[pb.CommitPlanRequest]) (*connect.Response[pb.CommitPlanResponse], error) {
	plan, err := h.svc.CommitPlan(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.CommitPlanResponse{Plan: planToProto(plan)}), nil
}

func (h *PlanningHandler) CheckRotation(ctx context.Context, req *connect.Request[pb.CheckRotationRequest]) (*connect.Response[pb.CheckRotationResponse], error) {
	check, err := h.svc.CheckRotation(ctx, req.Msg.GetFieldId(), req.Msg.GetCrop())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.CheckRotationResponse{Check: rotationToProto(check)}), nil
}

func (h *PlanningHandler) GetSowingWindow(ctx context.Context, req *connect.Request[pb.GetSowingWindowRequest]) (*connect.Response[pb.GetSowingWindowResponse], error) {
	window, err := h.svc.GetSowingWindow(ctx,
		req.Msg.GetFieldId(),
		req.Msg.GetCrop(),
		seasonFromProto(req.Msg.GetSeason()),
		int(req.Msg.GetYear()),
	)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.GetSowingWindowResponse{Window: windowToProto(window)}), nil
}

// ─────────────────────────────────────────────────────────────────────────────
// Mapping
// ─────────────────────────────────────────────────────────────────────────────

func page(pageSize int32, pageToken string) (limit, offset int) {
	limit = int(pageSize)
	if limit <= 0 {
		limit = 50
	}
	if limit > 500 {
		limit = 500
	}
	if pageToken != "" {
		if parsed, err := strconv.Atoi(pageToken); err == nil && parsed > 0 {
			offset = parsed
		}
	}
	return limit, offset
}

func nextToken(offset, limit int, total int64) string {
	next := offset + limit
	if int64(next) >= total {
		return ""
	}
	return strconv.Itoa(next)
}

var seasonNames = map[pb.Season]domain.Season{
	pb.Season_SEASON_KHARIF: domain.Kharif,
	pb.Season_SEASON_RABI:   domain.Rabi,
	pb.Season_SEASON_ZAID:   domain.Zaid,
}

// seasonFromProto maps an unspecified season to "" rather than guessing.
//
// The service defaults an empty season to the current one where that is a fair
// reading of the request, and refuses it where it is not. Deciding that here
// would take the choice away from the layer that knows which is which.
func seasonFromProto(s pb.Season) domain.Season { return seasonNames[s] }

func seasonToProto(s domain.Season) pb.Season {
	for proto, name := range seasonNames {
		if name == s {
			return proto
		}
	}
	return pb.Season_SEASON_UNSPECIFIED
}

var planStatusNames = map[pb.PlanStatus]domain.PlanStatus{
	pb.PlanStatus_PLAN_STATUS_DRAFT:     domain.PlanDraft,
	pb.PlanStatus_PLAN_STATUS_COMMITTED: domain.PlanCommitted,
	pb.PlanStatus_PLAN_STATUS_COMPLETED: domain.PlanCompleted,
	pb.PlanStatus_PLAN_STATUS_ABANDONED: domain.PlanAbandoned,
}

func statusFromProto(s pb.PlanStatus) domain.PlanStatus { return planStatusNames[s] }

func statusToProto(s domain.PlanStatus) pb.PlanStatus {
	for proto, name := range planStatusNames {
		if name == s {
			return proto
		}
	}
	return pb.PlanStatus_PLAN_STATUS_UNSPECIFIED
}

var verdictNames = map[pb.RotationVerdict]domain.RotationVerdict{
	pb.RotationVerdict_ROTATION_VERDICT_GOOD:       domain.RotationGood,
	pb.RotationVerdict_ROTATION_VERDICT_ACCEPTABLE: domain.RotationAcceptable,
	pb.RotationVerdict_ROTATION_VERDICT_POOR:       domain.RotationPoor,
}

func verdictToProto(v domain.RotationVerdict) pb.RotationVerdict {
	for proto, name := range verdictNames {
		if name == v {
			return proto
		}
	}
	return pb.RotationVerdict_ROTATION_VERDICT_UNSPECIFIED
}

var inputKindNames = map[pb.InputKind]domain.InputKind{
	pb.InputKind_INPUT_KIND_SEED:       domain.InputSeed,
	pb.InputKind_INPUT_KIND_FERTILISER: domain.InputFertiliser,
	pb.InputKind_INPUT_KIND_PESTICIDE:  domain.InputPesticide,
	pb.InputKind_INPUT_KIND_LABOUR:     domain.InputLabour,
	pb.InputKind_INPUT_KIND_MACHINERY:  domain.InputMachinery,
	pb.InputKind_INPUT_KIND_IRRIGATION: domain.InputIrrigation,
}

func inputKindToProto(k domain.InputKind) pb.InputKind {
	for proto, name := range inputKindNames {
		if name == k {
			return proto
		}
	}
	return pb.InputKind_INPUT_KIND_UNSPECIFIED
}

func windowToProto(w domain.SowingWindow) *pb.SowingWindow {
	out := &pb.SowingWindow{
		Crop:            w.Crop,
		Season:          seasonToProto(w.Season),
		Basis:           w.Basis,
		WeatherInformed: w.WeatherInformed,
	}
	if !w.Opens.IsZero() {
		out.Opens = timestamppb.New(w.Opens)
	}
	if !w.Closes.IsZero() {
		out.Closes = timestamppb.New(w.Closes)
	}
	if !w.Optimal.IsZero() {
		out.Optimal = timestamppb.New(w.Optimal)
	}
	return out
}

func rotationToProto(c domain.RotationCheck) *pb.RotationCheck {
	return &pb.RotationCheck{
		Crop:               c.Crop,
		PreviousCrop:       c.PreviousCrop,
		Verdict:            verdictToProto(c.Verdict),
		Rationale:          c.Rationale,
		NitrogenCreditKgHa: c.NitrogenCreditKgHa,
	}
}

func budgetToProto(b domain.InputBudget) *pb.InputBudget {
	out := &pb.InputBudget{
		TotalCost:      b.TotalCost,
		CostPerHectare: b.CostPerHectare,
		Currency:       b.Currency,
		Lines:          make([]*pb.InputLine, 0, len(b.Lines)),
	}
	for _, line := range b.Lines {
		out.Lines = append(out.Lines, &pb.InputLine{
			Kind:      inputKindToProto(line.Kind),
			Item:      line.Item,
			Quantity:  line.Quantity,
			Unit:      line.Unit,
			UnitCost:  line.UnitCost,
			TotalCost: line.TotalCost,
			// Carried through: the note is where the budget says a figure is an
			// estimate, or that a legume credit already covers the nitrogen. A
			// number without it reads as a quote.
			Note: line.Note,
		})
	}
	return out
}

func planToProto(p *domain.SeasonPlan) *pb.SeasonPlan {
	if p == nil {
		return nil
	}
	out := &pb.SeasonPlan{
		Id:                  p.ID,
		FieldId:             p.FieldID,
		FarmId:              p.FarmID,
		Season:              seasonToProto(p.Season),
		Year:                int32(p.Year),
		Crop:                p.Crop,
		Variety:             p.Variety,
		AreaHectares:        p.AreaHectares,
		Status:              statusToProto(p.Status),
		SowingWindow:        windowToProto(p.SowingWindow),
		RotationCheck:       rotationToProto(p.RotationCheck),
		Budget:              budgetToProto(p.Budget),
		TargetYieldTonnesHa: p.TargetYieldTonnesHa,
		Notes:               p.Notes,
		Version:             p.Version,
	}
	if !p.CreatedAt.IsZero() {
		out.CreatedAt = timestamppb.New(p.CreatedAt)
	}
	if !p.UpdatedAt.IsZero() {
		out.UpdatedAt = timestamppb.New(p.UpdatedAt)
	}
	return out
}
