// Package grpc adapts the ConnectRPC surface onto sustainability-service's use cases.
package grpc

import (
	"context"
	"strconv"
	"time"

	"connectrpc.com/connect"
	"google.golang.org/protobuf/types/known/timestamppb"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"

	pb "p9e.in/samavaya/agriculture/sustainability-service/api/v1"
	"p9e.in/samavaya/agriculture/sustainability-service/internal/domain"
	"p9e.in/samavaya/agriculture/sustainability-service/internal/ports/inbound"
)

// SustainabilityHandler serves the SustainabilityService RPCs.
type SustainabilityHandler struct {
	svc inbound.SustainabilityService
	log *p9log.Helper
}

// NewSustainabilityHandler creates a SustainabilityHandler.
func NewSustainabilityHandler(svc inbound.SustainabilityService, log p9log.Logger) *SustainabilityHandler {
	return &SustainabilityHandler{
		svc: svc,
		log: p9log.NewHelper(p9log.With(log, "component", "SustainabilityHandler")),
	}
}

func (h *SustainabilityHandler) RecordInputUse(ctx context.Context, req *connect.Request[pb.RecordInputUseRequest]) (*connect.Response[pb.RecordInputUseResponse], error) {
	input, err := h.svc.RecordInputUse(ctx, &domain.InputUse{
		FieldID:    req.Msg.GetFieldId(),
		Crop:       req.Msg.GetCrop(),
		Year:       int(req.Msg.GetYear()),
		Category:   categoryFromProto(req.Msg.GetCategory()),
		Product:    req.Msg.GetProduct(),
		Quantity:   req.Msg.GetQuantity(),
		Unit:       req.Msg.GetUnit(),
		NitrogenKg: req.Msg.GetNitrogenKg(),
		AppliedOn:  asTime(req.Msg.GetAppliedOn()),
		Notes:      req.Msg.GetNotes(),
	})
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.RecordInputUseResponse{Input: inputToProto(input)}), nil
}

func (h *SustainabilityHandler) ListInputUse(ctx context.Context, req *connect.Request[pb.ListInputUseRequest]) (*connect.Response[pb.ListInputUseResponse], error) {
	limit, offset := page(req.Msg.GetPageSize(), req.Msg.GetPageToken())

	inputs, total, err := h.svc.ListInputUse(ctx, domain.ListInputUseParams{
		FieldID:  req.Msg.GetFieldId(),
		Year:     int(req.Msg.GetYear()),
		Category: categoryFromProto(req.Msg.GetCategory()),
		Limit:    limit,
		Offset:   offset,
	})
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	out := make([]*pb.InputUse, 0, len(inputs))
	for i := range inputs {
		out = append(out, inputToProto(&inputs[i]))
	}
	return connect.NewResponse(&pb.ListInputUseResponse{
		Inputs:        out,
		NextPageToken: nextToken(offset, limit, total),
		TotalCount:    int32(total),
	}), nil
}

func (h *SustainabilityHandler) ComputeFootprint(ctx context.Context, req *connect.Request[pb.ComputeFootprintRequest]) (*connect.Response[pb.ComputeFootprintResponse], error) {
	footprint, err := h.svc.ComputeFootprint(ctx, domain.FootprintParams{
		FieldID:      req.Msg.GetFieldId(),
		Crop:         req.Msg.GetCrop(),
		Year:         int(req.Msg.GetYear()),
		AreaHectares: req.Msg.GetAreaHectares(),
		WaterRegime:  regimeFromProto(req.Msg.GetWaterRegime()),
		FloodedDays:  int(req.Msg.GetFloodedDays()),
		YieldTonnes:  req.Msg.GetYieldTonnes(),
	})
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.ComputeFootprintResponse{Footprint: footprintToProto(footprint)}), nil
}

func (h *SustainabilityHandler) GetFootprint(ctx context.Context, req *connect.Request[pb.GetFootprintRequest]) (*connect.Response[pb.GetFootprintResponse], error) {
	footprint, err := h.svc.GetFootprint(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.GetFootprintResponse{Footprint: footprintToProto(footprint)}), nil
}

func (h *SustainabilityHandler) ListFootprints(ctx context.Context, req *connect.Request[pb.ListFootprintsRequest]) (*connect.Response[pb.ListFootprintsResponse], error) {
	limit, offset := page(req.Msg.GetPageSize(), req.Msg.GetPageToken())

	footprints, total, err := h.svc.ListFootprints(ctx, domain.ListFootprintsParams{
		FieldID: req.Msg.GetFieldId(),
		FarmID:  req.Msg.GetFarmId(),
		Year:    int(req.Msg.GetYear()),
		Limit:   limit,
		Offset:  offset,
	})
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	out := make([]*pb.Footprint, 0, len(footprints))
	for i := range footprints {
		out = append(out, footprintToProto(&footprints[i]))
	}
	return connect.NewResponse(&pb.ListFootprintsResponse{
		Footprints:    out,
		NextPageToken: nextToken(offset, limit, total),
		TotalCount:    int32(total),
	}), nil
}

func (h *SustainabilityHandler) CheckCertification(ctx context.Context, req *connect.Request[pb.CheckCertificationRequest]) (*connect.Response[pb.CheckCertificationResponse], error) {
	check, err := h.svc.CheckCertification(ctx,
		req.Msg.GetFieldId(),
		standardFromProto(req.Msg.GetStandard()),
		asTime(req.Msg.GetConversionStartedOn()),
	)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.CheckCertificationResponse{Check: checkToProto(check)}), nil
}

func (h *SustainabilityHandler) ExportCertificationPack(ctx context.Context, req *connect.Request[pb.ExportCertificationPackRequest]) (*connect.Response[pb.ExportCertificationPackResponse], error) {
	pack, err := h.svc.ExportCertificationPack(ctx,
		req.Msg.GetFieldId(),
		standardFromProto(req.Msg.GetStandard()),
		asTime(req.Msg.GetConversionStartedOn()),
		req.Msg.GetAllowIncomplete(),
	)
	if err != nil {
		// A refused export still carries the check, so the caller can show the
		// person what is standing in the way rather than just "no".
		h.log.Infow("msg", "certification pack was not exported",
			"field", req.Msg.GetFieldId(), "status", pack.Check.Status)
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.ExportCertificationPackResponse{
		Filename:    pack.Filename,
		Content:     pack.Content,
		ContentType: pack.ContentType,
		Check:       checkToProto(pack.Check),
	}), nil
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

func asTime(ts *timestamppb.Timestamp) time.Time {
	if ts == nil {
		return time.Time{}
	}
	return ts.AsTime()
}

var categoryNames = map[pb.InputCategory]domain.InputCategory{
	pb.InputCategory_INPUT_CATEGORY_SYNTHETIC_N:  domain.CategorySyntheticN,
	pb.InputCategory_INPUT_CATEGORY_UREA:         domain.CategoryUrea,
	pb.InputCategory_INPUT_CATEGORY_PHOSPHATE:    domain.CategoryPhosphate,
	pb.InputCategory_INPUT_CATEGORY_POTASH:       domain.CategoryPotash,
	pb.InputCategory_INPUT_CATEGORY_ORGANIC_N:    domain.CategoryOrganicN,
	pb.InputCategory_INPUT_CATEGORY_LIME:         domain.CategoryLime,
	pb.InputCategory_INPUT_CATEGORY_PESTICIDE:    domain.CategoryPesticide,
	pb.InputCategory_INPUT_CATEGORY_SEED:         domain.CategorySeed,
	pb.InputCategory_INPUT_CATEGORY_DIESEL:       domain.CategoryDiesel,
	pb.InputCategory_INPUT_CATEGORY_ELECTRICITY:  domain.CategoryElectricity,
	pb.InputCategory_INPUT_CATEGORY_RESIDUE_BURN: domain.CategoryResidueBurn,
}

// categoryFromProto leaves an unspecified category empty rather than guessing.
//
// The category decides both the emission pathway and the organic verdict, so a
// default would put an unlabelled application into whichever bucket happened to
// be first — and the record would look deliberate afterwards.
func categoryFromProto(c pb.InputCategory) domain.InputCategory { return categoryNames[c] }

func categoryToProto(c domain.InputCategory) pb.InputCategory {
	for proto, name := range categoryNames {
		if name == c {
			return proto
		}
	}
	return pb.InputCategory_INPUT_CATEGORY_UNSPECIFIED
}

var regimeNames = map[pb.WaterRegime]domain.WaterRegime{
	pb.WaterRegime_WATER_REGIME_CONTINUOUS_FLOOD:  domain.RegimeContinuousFlood,
	pb.WaterRegime_WATER_REGIME_SINGLE_DRAINAGE:   domain.RegimeSingleDrainage,
	pb.WaterRegime_WATER_REGIME_MULTIPLE_DRAINAGE: domain.RegimeMultipleDrainage,
	pb.WaterRegime_WATER_REGIME_AWD:               domain.RegimeAWD,
	pb.WaterRegime_WATER_REGIME_RAINFED:           domain.RegimeRainfed,
	pb.WaterRegime_WATER_REGIME_UPLAND:            domain.RegimeUpland,
}

func regimeFromProto(r pb.WaterRegime) domain.WaterRegime { return regimeNames[r] }

func regimeToProto(r domain.WaterRegime) pb.WaterRegime {
	for proto, name := range regimeNames {
		if name == r {
			return proto
		}
	}
	return pb.WaterRegime_WATER_REGIME_UNSPECIFIED
}

var sourceNames = map[pb.EmissionSource]domain.EmissionSource{
	pb.EmissionSource_EMISSION_SOURCE_DIRECT_N2O:   domain.SourceDirectN2O,
	pb.EmissionSource_EMISSION_SOURCE_INDIRECT_N2O: domain.SourceIndirectN2O,
	pb.EmissionSource_EMISSION_SOURCE_UREA_CO2:     domain.SourceUreaCO2,
	pb.EmissionSource_EMISSION_SOURCE_LIME_CO2:     domain.SourceLimeCO2,
	pb.EmissionSource_EMISSION_SOURCE_RICE_CH4:     domain.SourceRiceCH4,
	pb.EmissionSource_EMISSION_SOURCE_ENERGY:       domain.SourceEnergy,
	pb.EmissionSource_EMISSION_SOURCE_RESIDUE_BURN: domain.SourceResidueBurn,
	pb.EmissionSource_EMISSION_SOURCE_UPSTREAM:     domain.SourceUpstream,
}

func sourceToProto(s domain.EmissionSource) pb.EmissionSource {
	for proto, name := range sourceNames {
		if name == s {
			return proto
		}
	}
	return pb.EmissionSource_EMISSION_SOURCE_UNSPECIFIED
}

var completenessNames = map[pb.Completeness]domain.Completeness{
	pb.Completeness_COMPLETENESS_RECORDED:       domain.CompletenessRecorded,
	pb.Completeness_COMPLETENESS_MISSING:        domain.CompletenessMissing,
	pb.Completeness_COMPLETENESS_NOT_APPLICABLE: domain.CompletenessNotApplicable,
}

func completenessToProto(c domain.Completeness) pb.Completeness {
	for proto, name := range completenessNames {
		if name == c {
			return proto
		}
	}
	return pb.Completeness_COMPLETENESS_UNSPECIFIED
}

var standardNames = map[pb.CertificationStandard]domain.CertificationStandard{
	pb.CertificationStandard_CERTIFICATION_STANDARD_NPOP:       domain.StandardNPOP,
	pb.CertificationStandard_CERTIFICATION_STANDARD_GLOBALGAP:  domain.StandardGlobalGAP,
	pb.CertificationStandard_CERTIFICATION_STANDARD_FAIRTRADE:  domain.StandardFairtrade,
	pb.CertificationStandard_CERTIFICATION_STANDARD_RAINFOREST: domain.StandardRainforest,
}

// standardFromProto leaves an unspecified standard empty so the service can
// refuse it. The rules differ enough between schemes that defaulting to one
// would assess a field against a standard nobody asked about.
func standardFromProto(s pb.CertificationStandard) domain.CertificationStandard {
	return standardNames[s]
}

func standardToProto(s domain.CertificationStandard) pb.CertificationStandard {
	for proto, name := range standardNames {
		if name == s {
			return proto
		}
	}
	return pb.CertificationStandard_CERTIFICATION_STANDARD_UNSPECIFIED
}

var certStatusNames = map[pb.CertificationStatus]domain.CertificationStatus{
	pb.CertificationStatus_CERTIFICATION_STATUS_IN_CONVERSION:        domain.StatusInConversion,
	pb.CertificationStatus_CERTIFICATION_STATUS_ELIGIBLE:             domain.StatusEligible,
	pb.CertificationStatus_CERTIFICATION_STATUS_BLOCKED:              domain.StatusBlocked,
	pb.CertificationStatus_CERTIFICATION_STATUS_INSUFFICIENT_RECORDS: domain.StatusInsufficientRecord,
}

func certStatusToProto(s domain.CertificationStatus) pb.CertificationStatus {
	for proto, name := range certStatusNames {
		if name == s {
			return proto
		}
	}
	return pb.CertificationStatus_CERTIFICATION_STATUS_UNSPECIFIED
}

var severityNames = map[pb.FindingSeverity]domain.FindingSeverity{
	pb.FindingSeverity_FINDING_SEVERITY_BLOCKER: domain.SeverityBlocker,
	pb.FindingSeverity_FINDING_SEVERITY_MAJOR:   domain.SeverityMajor,
	pb.FindingSeverity_FINDING_SEVERITY_MINOR:   domain.SeverityMinor,
}

func severityToProto(s domain.FindingSeverity) pb.FindingSeverity {
	for proto, name := range severityNames {
		if name == s {
			return proto
		}
	}
	return pb.FindingSeverity_FINDING_SEVERITY_UNSPECIFIED
}

func inputToProto(in *domain.InputUse) *pb.InputUse {
	if in == nil {
		return nil
	}
	out := &pb.InputUse{
		Id:               in.ID,
		FieldId:          in.FieldID,
		Crop:             in.Crop,
		Year:             int32(in.Year),
		Category:         categoryToProto(in.Category),
		Product:          in.Product,
		Quantity:         in.Quantity,
		Unit:             in.Unit,
		NitrogenKg:       in.NitrogenKg,
		AppliedBy:        in.AppliedBy,
		Notes:            in.Notes,
		OrganicPermitted: in.OrganicPermitted,
	}
	if !in.AppliedOn.IsZero() {
		out.AppliedOn = timestamppb.New(in.AppliedOn)
	}
	if !in.CreatedAt.IsZero() {
		out.CreatedAt = timestamppb.New(in.CreatedAt)
	}
	return out
}

func footprintToProto(f *domain.Footprint) *pb.Footprint {
	if f == nil {
		return nil
	}
	out := &pb.Footprint{
		Id:               f.ID,
		FieldId:          f.FieldID,
		FarmId:           f.FarmID,
		Crop:             f.Crop,
		Year:             int32(f.Year),
		AreaHectares:     f.AreaHectares,
		WaterRegime:      regimeToProto(f.WaterRegime),
		TotalKgCo2E:      f.TotalKgCO2e,
		KgCo2EPerHectare: f.KgCO2ePerHa,
		KgCo2EPerTonne:   f.KgCO2ePerTonne,
		YieldTonnes:      f.YieldTonnes,
		Complete:         f.Complete,
		Method:           f.Method,
	}
	if !f.ComputedAt.IsZero() {
		out.ComputedAt = timestamppb.New(f.ComputedAt)
	}

	out.Lines = make([]*pb.EmissionLine, 0, len(f.Lines))
	for _, line := range f.Lines {
		out.Lines = append(out.Lines, &pb.EmissionLine{
			Source: sourceToProto(line.Source),
			KgCo2E: line.KgCO2e,
			Basis:  line.Basis,
			// Sent with every line, not only the total's flag. A client that
			// renders a chart of the breakdown has to be able to mark the bar
			// that has nothing behind it.
			Completeness: completenessToProto(line.Completeness),
		})
	}

	out.MissingSources = make([]pb.EmissionSource, 0, len(f.MissingSources))
	for _, source := range f.MissingSources {
		out.MissingSources = append(out.MissingSources, sourceToProto(source))
	}
	return out
}

func checkToProto(c domain.CertificationCheck) *pb.CertificationCheck {
	out := &pb.CertificationCheck{
		FieldId:     c.FieldID,
		Standard:    standardToProto(c.Standard),
		Status:      certStatusToProto(c.Status),
		RecordYears: int32(c.RecordYears),
		Summary:     c.Summary,
	}
	if !c.ConversionStartedOn.IsZero() {
		out.ConversionStartedOn = timestamppb.New(c.ConversionStartedOn)
	}
	if !c.EligibleFrom.IsZero() {
		out.EligibleFrom = timestamppb.New(c.EligibleFrom)
	}

	out.Findings = make([]*pb.Finding, 0, len(c.Findings))
	for _, f := range c.Findings {
		finding := &pb.Finding{
			Severity:   severityToProto(f.Severity),
			Code:       f.Code,
			Message:    f.Message,
			EvidenceId: f.EvidenceID,
		}
		if !f.OccurredOn.IsZero() {
			finding.OccurredOn = timestamppb.New(f.OccurredOn)
		}
		out.Findings = append(out.Findings, finding)
	}
	return out
}
