package handlers

import (
	"context"

	"connectrpc.com/connect"

	pb "p9e.in/samavaya/agriculture/prescription-service/api/v1"
	"p9e.in/samavaya/agriculture/prescription-service/api/v1/v1connect"
	"p9e.in/samavaya/agriculture/prescription-service/internal/models"
	"p9e.in/samavaya/agriculture/prescription-service/internal/services"
	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"
)

// PrescriptionHandler implements the ConnectRPC PrescriptionServiceHandler interface.
type PrescriptionHandler struct {
	v1connect.UnimplementedPrescriptionServiceHandler

	service services.PrescriptionService
	deps    deps.ServiceDeps
	logger  *p9log.Helper
}

// NewPrescriptionHandler creates a new PrescriptionHandler.
func NewPrescriptionHandler(d deps.ServiceDeps, svc services.PrescriptionService) *PrescriptionHandler {
	return &PrescriptionHandler{
		service: svc,
		deps:    d,
		logger:  p9log.NewHelper(p9log.With(d.Log, "component", "prescription_handler")),
	}
}

// ListPrescriptions handles the ListPrescriptions RPC.
func (h *PrescriptionHandler) ListPrescriptions(ctx context.Context, req *connect.Request[pb.ListPrescriptionsRequest]) (*connect.Response[pb.ListPrescriptionsResponse], error) {
	typeFilter := ""
	if req.Msg.GetPrescriptionType() != pb.PrescriptionType_PRESCRIPTION_TYPE_UNSPECIFIED {
		typeFilter = req.Msg.GetPrescriptionType().String()
	}

	bundles, nextToken, err := h.service.ListPrescriptions(ctx, typeFilter, req.Msg.GetPageSize(), req.Msg.GetPageToken())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	out := make([]*pb.PrescriptionBundle, len(bundles))
	for i, b := range bundles {
		out[i] = bundleToProto(&b)
	}

	return connect.NewResponse(&pb.ListPrescriptionsResponse{
		Prescriptions: out,
		NextPageToken: nextToken,
	}), nil
}

// GetPrescription handles the GetPrescription RPC.
func (h *PrescriptionHandler) GetPrescription(ctx context.Context, req *connect.Request[pb.GetPrescriptionRequest]) (*connect.Response[pb.GetPrescriptionResponse], error) {
	if req.Msg.GetId() == "" {
		return nil, errors.BadRequest("MISSING_ID", "id is required")
	}

	bundle, err := h.service.GetPrescription(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return connect.NewResponse(&pb.GetPrescriptionResponse{
		Prescription: bundleToProto(bundle),
	}), nil
}

// GeneratePrescription handles the GeneratePrescription RPC.
func (h *PrescriptionHandler) GeneratePrescription(ctx context.Context, req *connect.Request[pb.GeneratePrescriptionRequest]) (*connect.Response[pb.GeneratePrescriptionResponse], error) {
	if req.Msg.GetFieldId() == "" {
		return nil, errors.BadRequest("MISSING_FIELD_ID", "field_id is required")
	}
	if req.Msg.GetCropType() == "" {
		return nil, errors.BadRequest("MISSING_CROP_TYPE", "crop_type is required")
	}

	soilData := make([]models.SoilDataRow, len(req.Msg.GetSoilData()))
	for i, row := range req.Msg.GetSoilData() {
		soilData[i] = models.SoilDataRow{Values: row.GetValues()}
	}

	input := models.GeneratePrescriptionInput{
		FieldID:     req.Msg.GetFieldId(),
		CropType:    req.Msg.GetCropType(),
		TargetYield: req.Msg.GetTargetYield(),
		SoilData:    soilData,
	}

	bundle, err := h.service.GeneratePrescription(ctx, input)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return connect.NewResponse(&pb.GeneratePrescriptionResponse{
		Prescription: bundleToProto(bundle),
	}), nil
}

// ExportPrescription handles the ExportPrescription RPC.
func (h *PrescriptionHandler) ExportPrescription(ctx context.Context, req *connect.Request[pb.ExportPrescriptionRequest]) (*connect.Response[pb.ExportPrescriptionResponse], error) {
	if req.Msg.GetId() == "" {
		return nil, errors.BadRequest("MISSING_ID", "id is required")
	}
	if req.Msg.GetFormat() == "" {
		return nil, errors.BadRequest("MISSING_FORMAT", "format is required")
	}

	downloadURL, fileName, err := h.service.ExportPrescription(ctx, req.Msg.GetId(), req.Msg.GetFormat())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return connect.NewResponse(&pb.ExportPrescriptionResponse{
		DownloadUrl: downloadURL,
		FileName:    fileName,
	}), nil
}

// ---------------------------------------------------------------------------
// Proto mapping helpers
// ---------------------------------------------------------------------------

func bundleToProto(b *models.PrescriptionBundle) *pb.PrescriptionBundle {
	if b == nil {
		return nil
	}

	prescriptions := make([]*pb.PrescriptionMap, len(b.Prescriptions))
	for i, p := range b.Prescriptions {
		rates := make([]*pb.RateRow, len(p.Rates))
		for j, r := range p.Rates {
			rates[j] = &pb.RateRow{Values: r.Values}
		}
		prescriptions[i] = &pb.PrescriptionMap{
			Id:               p.ID,
			PrescriptionType: prescriptionTypeToProto(p.PrescriptionType),
			Unit:             p.Unit,
			Rates:            rates,
			AvgRate:          p.AvgRate,
		}
	}

	zones := make([]*pb.ZoneSummary, len(b.ZoneSummaries))
	for i, z := range b.ZoneSummaries {
		zones[i] = &pb.ZoneSummary{
			Zone:             z.Zone,
			PrescriptionType: prescriptionTypeToProto(z.PrescriptionType),
			AreaHectares:     z.AreaHectares,
			MinRate:          z.MinRate,
			MeanRate:         z.MeanRate,
			MaxRate:          z.MaxRate,
			TotalAmount:      z.TotalAmount,
		}
	}

	return &pb.PrescriptionBundle{
		Id:                   b.ID,
		FieldId:              b.FieldID,
		FieldName:            b.FieldName,
		CropType:             b.CropType,
		TargetYield:          b.TargetYield,
		CreatedAt:            b.CreatedAt,
		EstimatedCostSavings: b.EstimatedCostSavings,
		EstimatedYieldGain:   b.EstimatedYieldGain,
		Prescriptions:        prescriptions,
		ZoneSummaries:        zones,
	}
}

func prescriptionTypeToProto(t models.PrescriptionType) pb.PrescriptionType {
	switch t {
	case models.PrescriptionTypeFertilizer:
		return pb.PrescriptionType_PRESCRIPTION_TYPE_FERTILIZER
	case models.PrescriptionTypeIrrigation:
		return pb.PrescriptionType_PRESCRIPTION_TYPE_IRRIGATION
	case models.PrescriptionTypeSeeding:
		return pb.PrescriptionType_PRESCRIPTION_TYPE_SEEDING
	case models.PrescriptionTypeLiming:
		return pb.PrescriptionType_PRESCRIPTION_TYPE_LIMING
	default:
		return pb.PrescriptionType_PRESCRIPTION_TYPE_UNSPECIFIED
	}
}
