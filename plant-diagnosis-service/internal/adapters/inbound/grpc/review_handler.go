package grpc

import (
	"context"

	"connectrpc.com/connect"
	"google.golang.org/protobuf/types/known/timestamppb"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"

	pb "p9e.in/samavaya/agriculture/plant-diagnosis-service/api/v1"
	"p9e.in/samavaya/agriculture/plant-diagnosis-service/internal/domain"
)

// ─────────────────────────────────────────────────────────────────────────────
// Label review queue (human-in-the-loop labeling)
// ─────────────────────────────────────────────────────────────────────────────

func (h *DiagnosisHandler) ListLabelReviewQueue(ctx context.Context, req *connect.Request[pb.ListLabelReviewQueueRequest]) (*connect.Response[pb.ListLabelReviewQueueResponse], error) {
	if req.Msg.GetTask() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "task is required")
	}
	h.log.Infow("msg", "ListLabelReviewQueue request", "tenant_id", p9context.TenantID(ctx), "task", req.Msg.GetTask())

	samples, total, unreviewed, err := h.svc.ListLabelReviewQueue(ctx, domain.ListLabelReviewQueueParams{
		Task:            req.Msg.GetTask(),
		IncludeReviewed: req.Msg.GetIncludeReviewed(),
		MaxConfidence:   req.Msg.GetMaxConfidence(),
		Provenance:      req.Msg.GetProvenance(),
		PageSize:        req.Msg.GetPageSize(),
		Offset:          req.Msg.GetPageOffset(),
		NewestFirst:     req.Msg.GetNewestFirst(),
		SuspectOnly:     req.Msg.GetSuspectOnly(),
	})
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	out := make([]*pb.LabelReviewSample, 0, len(samples))
	for i := range samples {
		out = append(out, labelReviewSampleToProto(&samples[i]))
	}
	return connect.NewResponse(&pb.ListLabelReviewQueueResponse{
		Samples:         out,
		TotalCount:      total,
		UnreviewedCount: unreviewed,
	}), nil
}

func (h *DiagnosisHandler) SubmitLabelReview(ctx context.Context, req *connect.Request[pb.SubmitLabelReviewRequest]) (*connect.Response[pb.SubmitLabelReviewResponse], error) {
	if req.Msg.GetTask() == "" || req.Msg.GetSampleId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "task and sample_id are required")
	}
	decision, ok := protoDecisionToDomain(req.Msg.GetDecision())
	if !ok {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "decision must be confirmed, corrected, or rejected")
	}

	sample, err := h.svc.SubmitLabelReview(ctx, domain.SubmitLabelReviewInput{
		Task:           req.Msg.GetTask(),
		SampleID:       req.Msg.GetSampleId(),
		Decision:       decision,
		CorrectedLabel: req.Msg.GetCorrectedLabel(),
		Notes:          req.Msg.GetNotes(),
	})
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.SubmitLabelReviewResponse{
		Sample: labelReviewSampleToProto(sample),
	}), nil
}

func (h *DiagnosisHandler) GetLabelReviewImage(ctx context.Context, req *connect.Request[pb.GetLabelReviewImageRequest]) (*connect.Response[pb.GetLabelReviewImageResponse], error) {
	if req.Msg.GetTask() == "" || req.Msg.GetSampleId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "task and sample_id are required")
	}
	img, err := h.svc.GetLabelReviewImage(ctx, req.Msg.GetTask(), req.Msg.GetSampleId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.GetLabelReviewImageResponse{
		ImageBytes: img.Bytes,
		MimeType:   img.MimeType,
	}), nil
}

// ─────────────────────────────────────────────────────────────────────────────
// Mappers
// ─────────────────────────────────────────────────────────────────────────────

func protoDecisionToDomain(d pb.LabelReviewDecision) (domain.LabelReviewDecision, bool) {
	switch d {
	case pb.LabelReviewDecision_LABEL_REVIEW_DECISION_CONFIRMED:
		return domain.LabelReviewConfirmed, true
	case pb.LabelReviewDecision_LABEL_REVIEW_DECISION_CORRECTED:
		return domain.LabelReviewCorrected, true
	case pb.LabelReviewDecision_LABEL_REVIEW_DECISION_REJECTED:
		return domain.LabelReviewRejected, true
	default:
		return "", false
	}
}

func domainDecisionToProto(d domain.LabelReviewDecision) pb.LabelReviewDecision {
	switch d {
	case domain.LabelReviewConfirmed:
		return pb.LabelReviewDecision_LABEL_REVIEW_DECISION_CONFIRMED
	case domain.LabelReviewCorrected:
		return pb.LabelReviewDecision_LABEL_REVIEW_DECISION_CORRECTED
	case domain.LabelReviewRejected:
		return pb.LabelReviewDecision_LABEL_REVIEW_DECISION_REJECTED
	default:
		return pb.LabelReviewDecision_LABEL_REVIEW_DECISION_UNSPECIFIED
	}
}

func labelReviewSampleToProto(s *domain.LabelReviewSample) *pb.LabelReviewSample {
	if s == nil {
		return nil
	}
	out := &pb.LabelReviewSample{
		Id:             s.ID,
		Task:           s.Task,
		Provenance:     s.Provenance,
		Provider:       s.Provider,
		TopConfidence:  s.TopConfidence,
		FarmId:         s.FarmID,
		FieldId:        s.FieldID,
		Crop:           s.Crop,
		SubmittedBy:    s.SubmittedBy,
		EffectiveLabel: s.EffectiveLabel,
	}
	if s.Suspect != nil {
		out.Suspect = &pb.LabelSuspicion{
			Predicted:     s.Suspect.Predicted,
			PredictedProb: s.Suspect.PredictedProb,
			LabelProb:     s.Suspect.LabelProb,
			ModelVersion:  s.Suspect.ModelVersion,
			FlaggedAt:     s.Suspect.FlaggedAt,
		}
	}
	if s.CollectedAt != nil {
		out.CollectedAt = timestamppb.New(*s.CollectedAt)
	}
	for _, l := range s.Labels {
		out.Labels = append(out.Labels, &pb.TrainingLabel{
			Name:       l.Name,
			Confidence: l.Confidence,
			Category:   l.Category,
			Severity:   l.Severity,
		})
	}
	if s.Review != nil {
		r := &pb.LabelReview{
			Decision:       domainDecisionToProto(s.Review.Decision),
			CorrectedLabel: s.Review.CorrectedLabel,
			ReviewerId:     s.Review.ReviewerID,
			Notes:          s.Review.Notes,
		}
		if s.Review.ReviewedAt != nil {
			r.ReviewedAt = timestamppb.New(*s.Review.ReviewedAt)
		}
		out.Review = r
	}
	return out
}
