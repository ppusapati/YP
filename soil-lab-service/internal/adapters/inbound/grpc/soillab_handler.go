// Package grpc adapts the ConnectRPC surface onto soil-lab-service's use cases.
package grpc

import (
	"context"
	"strconv"

	"connectrpc.com/connect"
	"google.golang.org/protobuf/types/known/timestamppb"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"

	pb "p9e.in/samavaya/agriculture/soil-lab-service/api/v1"
	"p9e.in/samavaya/agriculture/soil-lab-service/internal/domain"
	"p9e.in/samavaya/agriculture/soil-lab-service/internal/ports/inbound"
)

// SoilLabHandler serves the SoilLabService RPCs.
type SoilLabHandler struct {
	svc inbound.SoilLabService
	log *p9log.Helper
}

// NewSoilLabHandler creates a SoilLabHandler.
func NewSoilLabHandler(svc inbound.SoilLabService, log p9log.Logger) *SoilLabHandler {
	return &SoilLabHandler{
		svc: svc,
		log: p9log.NewHelper(p9log.With(log, "component", "SoilLabHandler")),
	}
}

func (h *SoilLabHandler) RegisterLab(ctx context.Context, req *connect.Request[pb.RegisterLabRequest]) (*connect.Response[pb.RegisterLabResponse], error) {
	lab, err := h.svc.RegisterLab(ctx, &domain.Lab{
		Name:          req.Msg.GetName(),
		Accreditation: req.Msg.GetAccreditation(),
		ContactEmail:  req.Msg.GetContactEmail(),
		ColumnAliases: req.Msg.GetColumnAliases(),
	})
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.RegisterLabResponse{Lab: labToProto(lab)}), nil
}

func (h *SoilLabHandler) ListLabs(ctx context.Context, req *connect.Request[pb.ListLabsRequest]) (*connect.Response[pb.ListLabsResponse], error) {
	limit, offset := page(req.Msg.GetPageSize(), req.Msg.GetPageToken())

	labs, total, err := h.svc.ListLabs(ctx, domain.ListLabsParams{Limit: limit, Offset: offset})
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	out := make([]*pb.Lab, 0, len(labs))
	for i := range labs {
		out = append(out, labToProto(&labs[i]))
	}
	return connect.NewResponse(&pb.ListLabsResponse{
		Labs:          out,
		NextPageToken: nextToken(offset, limit, total),
		TotalCount:    int32(total),
	}), nil
}

func (h *SoilLabHandler) UploadReport(ctx context.Context, req *connect.Request[pb.UploadReportRequest]) (*connect.Response[pb.UploadReportResponse], error) {
	result, err := h.svc.UploadReport(ctx,
		req.Msg.GetLabId(),
		formatFromProto(req.Msg.GetFormat()),
		req.Msg.GetFilename(),
		req.Msg.GetContent(),
	)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.UploadReportResponse{
		Report:    reportToProto(result.Report),
		Duplicate: result.Duplicate,
	}), nil
}

func (h *SoilLabHandler) GetReport(ctx context.Context, req *connect.Request[pb.GetReportRequest]) (*connect.Response[pb.GetReportResponse], error) {
	report, err := h.svc.GetReport(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.GetReportResponse{Report: reportToProto(report)}), nil
}

func (h *SoilLabHandler) ListReports(ctx context.Context, req *connect.Request[pb.ListReportsRequest]) (*connect.Response[pb.ListReportsResponse], error) {
	limit, offset := page(req.Msg.GetPageSize(), req.Msg.GetPageToken())

	reports, total, err := h.svc.ListReports(ctx, domain.ListReportsParams{
		LabID:  req.Msg.GetLabId(),
		Status: statusFromProto(req.Msg.GetStatus()),
		Limit:  limit,
		Offset: offset,
	})
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	out := make([]*pb.LabReport, 0, len(reports))
	for i := range reports {
		out = append(out, reportToProto(&reports[i]))
	}
	return connect.NewResponse(&pb.ListReportsResponse{
		Reports:       out,
		NextPageToken: nextToken(offset, limit, total),
		TotalCount:    int32(total),
	}), nil
}

func (h *SoilLabHandler) ApplyReport(ctx context.Context, req *connect.Request[pb.ApplyReportRequest]) (*connect.Response[pb.ApplyReportResponse], error) {
	result, err := h.svc.ApplyReport(ctx, req.Msg.GetId(), req.Msg.GetSkipBlocked())
	if err != nil {
		// A partial apply returns both an error and what it managed. The ids
		// go back with it so the caller knows which samples exist — re-applying
		// blindly would duplicate them.
		if len(result.CreatedSampleIDs) > 0 {
			h.log.Warnw("msg", "partial apply",
				"report", req.Msg.GetId(), "created", len(result.CreatedSampleIDs), "error", err)
		}
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.ApplyReportResponse{
		Report:           reportToProto(result.Report),
		CreatedSampleIds: result.CreatedSampleIDs,
	}), nil
}

func (h *SoilLabHandler) RejectReport(ctx context.Context, req *connect.Request[pb.RejectReportRequest]) (*connect.Response[pb.RejectReportResponse], error) {
	report, err := h.svc.RejectReport(ctx, req.Msg.GetId(), req.Msg.GetReason())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.RejectReportResponse{Report: reportToProto(report)}), nil
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

func formatFromProto(f pb.ReportFormat) domain.ReportFormat {
	switch f {
	case pb.ReportFormat_REPORT_FORMAT_CSV:
		return domain.FormatCSV
	case pb.ReportFormat_REPORT_FORMAT_PDF:
		return domain.FormatPDF
	default:
		// Left empty so the service refuses it by name. Guessing CSV for an
		// unspecified format would try to parse a PDF as text and produce
		// nonsense readings that drive a fertiliser prescription.
		return ""
	}
}

func formatToProto(f domain.ReportFormat) pb.ReportFormat {
	switch f {
	case domain.FormatCSV:
		return pb.ReportFormat_REPORT_FORMAT_CSV
	case domain.FormatPDF:
		return pb.ReportFormat_REPORT_FORMAT_PDF
	default:
		return pb.ReportFormat_REPORT_FORMAT_UNSPECIFIED
	}
}

var statusNames = map[pb.ImportStatus]domain.ImportStatus{
	pb.ImportStatus_IMPORT_STATUS_RECEIVED:     domain.StatusReceived,
	pb.ImportStatus_IMPORT_STATUS_PARSED:       domain.StatusParsed,
	pb.ImportStatus_IMPORT_STATUS_NEEDS_REVIEW: domain.StatusNeedsReview,
	pb.ImportStatus_IMPORT_STATUS_APPLIED:      domain.StatusApplied,
	pb.ImportStatus_IMPORT_STATUS_REJECTED:     domain.StatusRejected,
}

func statusFromProto(s pb.ImportStatus) domain.ImportStatus { return statusNames[s] }

func statusToProto(s domain.ImportStatus) pb.ImportStatus {
	for proto, name := range statusNames {
		if name == s {
			return proto
		}
	}
	return pb.ImportStatus_IMPORT_STATUS_UNSPECIFIED
}

func labToProto(l *domain.Lab) *pb.Lab {
	return &pb.Lab{
		Id:            l.ID,
		Name:          l.Name,
		Accreditation: l.Accreditation,
		ContactEmail:  l.ContactEmail,
		ColumnAliases: l.ColumnAliases,
	}
}

func reportToProto(r *domain.LabReport) *pb.LabReport {
	if r == nil {
		return nil
	}
	out := &pb.LabReport{
		Id:              r.ID,
		LabId:           r.LabID,
		LabName:         r.LabName,
		Format:          formatToProto(r.Format),
		Filename:        r.Filename,
		StorageUrl:      r.StorageURL,
		ContentSha256:   r.ContentSHA256,
		Status:          statusToProto(r.Status),
		RowCount:        int32(r.RowCount),
		AppliedCount:    int32(r.AppliedCount),
		BlockedCount:    int32(r.BlockedCount),
		UploadedBy:      r.UploadedBy,
		RejectionReason: r.RejectionReason,
	}
	if !r.UploadedAt.IsZero() {
		out.UploadedAt = timestamppb.New(r.UploadedAt)
	}
	if r.AppliedAt != nil {
		out.AppliedAt = timestamppb.New(*r.AppliedAt)
	}

	out.Rows = make([]*pb.ReportRow, 0, len(r.Rows))
	for _, row := range r.Rows {
		out.Rows = append(out.Rows, rowToProto(row))
	}
	return out
}

func rowToProto(row domain.ReportRow) *pb.ReportRow {
	out := &pb.ReportRow{
		LineNumber: int32(row.LineNumber),
		SampleRef:  row.SampleRef,
		FieldId:    row.FieldID,
		DepthCm:    row.DepthCM,
		Blocker:    row.Blocker,
	}
	if !row.CollectedOn.IsZero() {
		out.CollectedOn = timestamppb.New(row.CollectedOn)
	}

	out.Results = make([]*pb.LabResult, 0, len(row.Results))
	for _, result := range row.Results {
		out.Results = append(out.Results, &pb.LabResult{
			Analyte: string(result.Analyte),
			Value:   result.Value,
			Unit:    result.Unit,
			// Carried through rather than filtered: a person reviewing an
			// import has to see what the lab actually sent and why it is
			// doubted, not a tidied version with the awkward rows removed.
			Suspect: result.Suspect,
			Note:    result.Note,
		})
	}
	return out
}
