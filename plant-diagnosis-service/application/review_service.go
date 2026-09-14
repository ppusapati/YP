package application

import (
	"context"
	"fmt"
	"strings"
	"time"

	aipb "p9e.in/samavaya/agriculture/ai-gateway/api/v1"
	"p9e.in/samavaya/agriculture/plant-diagnosis-service/internal/ai"
	"p9e.in/samavaya/agriculture/plant-diagnosis-service/internal/domain"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
)

// Human-in-the-loop label review. The AI gateway owns the collected training
// samples; this layer scopes every call to the caller's tenant, stamps the
// reviewer identity from the JWT, and maps gateway records to domain types.

const (
	defaultReviewPageSize = 50
	maxReviewPageSize     = 500
)

// sampleContext builds the training-sample metadata attached to vision calls
// so collected images can be sliced by tenant and reviewed by the same tenant.
func (s *diagnosisService) sampleContext(ctx context.Context, crop string) *ai.SampleContext {
	return &ai.SampleContext{
		TenantID:    p9context.TenantID(ctx),
		Crop:        crop,
		SubmittedBy: p9context.UserID(ctx),
	}
}

func (s *diagnosisService) reviewClient() (*ai.AIClient, error) {
	if s.aiClient == nil {
		return nil, errors.ServiceUnavailable("AI_GATEWAY_UNAVAILABLE", "label review requires the AI gateway (AI_GATEWAY_URL)")
	}
	return s.aiClient, nil
}

func (s *diagnosisService) ListLabelReviewQueue(ctx context.Context, params domain.ListLabelReviewQueueParams) ([]domain.LabelReviewSample, int32, int32, error) {
	client, err := s.reviewClient()
	if err != nil {
		return nil, 0, 0, err
	}
	if !domain.IsReviewTask(params.Task) {
		return nil, 0, 0, errors.BadRequest("INVALID_ARGUMENT", fmt.Sprintf("task must be one of %s", strings.Join(domain.ReviewTasks, ", ")))
	}
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, 0, errors.Unauthorized("TENANT_REQUIRED", "tenant context is required")
	}

	pageSize := params.PageSize
	if pageSize <= 0 {
		pageSize = defaultReviewPageSize
	}
	if pageSize > maxReviewPageSize {
		pageSize = maxReviewPageSize
	}
	status := "unreviewed"
	if params.IncludeReviewed {
		status = "all"
	}
	// Suspect ordering wins over "newest": a reviewer who asked for the labels
	// a model disputes wants the worst disagreements first, not the latest.
	order := "confidence_asc"
	switch {
	case params.SuspectOnly:
		order = "suspect_first"
	case params.NewestFirst:
		order = "newest"
	}

	page, err := client.ListTrainingSamples(ctx, ai.ListSamplesQuery{
		Task:          params.Task,
		ReviewStatus:  status,
		TenantID:      tenantID,
		MaxConfidence: params.MaxConfidence,
		Provenance:    params.Provenance,
		PageSize:      pageSize,
		PageOffset:    params.Offset,
		Order:         order,
		SuspectOnly:   params.SuspectOnly,
	})
	if err != nil {
		return nil, 0, 0, errors.ServiceUnavailable("AI_GATEWAY_ERROR", fmt.Sprintf("list review queue: %v", err))
	}

	samples := make([]domain.LabelReviewSample, 0, len(page.Samples))
	for _, info := range page.Samples {
		samples = append(samples, sampleInfoToDomain(info))
	}
	return samples, page.TotalCount, page.UnreviewedCount, nil
}

func (s *diagnosisService) SubmitLabelReview(ctx context.Context, input domain.SubmitLabelReviewInput) (*domain.LabelReviewSample, error) {
	client, err := s.reviewClient()
	if err != nil {
		return nil, err
	}
	if !domain.IsReviewTask(input.Task) {
		return nil, errors.BadRequest("INVALID_ARGUMENT", fmt.Sprintf("task must be one of %s", strings.Join(domain.ReviewTasks, ", ")))
	}
	if strings.TrimSpace(input.SampleID) == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "sample_id is required")
	}
	switch input.Decision {
	case domain.LabelReviewConfirmed, domain.LabelReviewRejected:
	case domain.LabelReviewCorrected:
		if strings.TrimSpace(input.CorrectedLabel) == "" {
			return nil, errors.BadRequest("INVALID_ARGUMENT", "corrected_label is required when decision is corrected")
		}
	default:
		return nil, errors.BadRequest("INVALID_ARGUMENT", "decision must be confirmed, corrected, or rejected")
	}
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.Unauthorized("TENANT_REQUIRED", "tenant context is required")
	}
	reviewerID := p9context.UserID(ctx)
	if reviewerID == "" {
		return nil, errors.Unauthorized("USER_REQUIRED", "reviewer identity is required")
	}

	info, err := client.SubmitLabelReview(ctx, input.Task, input.SampleID, ai.SampleReview{
		Decision:       string(input.Decision),
		CorrectedLabel: strings.TrimSpace(input.CorrectedLabel),
		ReviewerID:     reviewerID,
		TenantID:       tenantID,
		Notes:          input.Notes,
	})
	if err != nil {
		return nil, mapGatewayError(err, input.SampleID)
	}

	sample := sampleInfoToDomain(info)
	s.log.Infow("msg", "label review recorded",
		"task", input.Task, "sample_id", input.SampleID,
		"decision", input.Decision, "reviewer", reviewerID, "tenant_id", tenantID)
	s.emitEvent(ctx, "diagnosis.label_reviewed", input.SampleID, map[string]interface{}{
		"task":            input.Task,
		"sample_id":       input.SampleID,
		"decision":        string(input.Decision),
		"corrected_label": sample.EffectiveLabel,
		"reviewer_id":     reviewerID,
		"tenant_id":       tenantID,
	})
	return &sample, nil
}

func (s *diagnosisService) GetLabelReviewImage(ctx context.Context, task, sampleID string) (*domain.LabelReviewImage, error) {
	client, err := s.reviewClient()
	if err != nil {
		return nil, err
	}
	if !domain.IsReviewTask(task) {
		return nil, errors.BadRequest("INVALID_ARGUMENT", fmt.Sprintf("task must be one of %s", strings.Join(domain.ReviewTasks, ", ")))
	}
	if strings.TrimSpace(sampleID) == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "sample_id is required")
	}
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.Unauthorized("TENANT_REQUIRED", "tenant context is required")
	}
	data, mime, err := client.GetTrainingSampleImage(ctx, task, sampleID, tenantID)
	if err != nil {
		return nil, mapGatewayError(err, sampleID)
	}
	return &domain.LabelReviewImage{Bytes: data, MimeType: mime}, nil
}

// mapGatewayError turns gateway status text into domain errors so the handler
// returns the right Connect code (not found / permission denied / invalid).
func mapGatewayError(err error, sampleID string) error {
	msg := err.Error()
	switch {
	case strings.Contains(msg, "NotFound"):
		return errors.NotFound("SAMPLE_NOT_FOUND", fmt.Sprintf("training sample not found: %s", sampleID))
	case strings.Contains(msg, "PermissionDenied"):
		return errors.Forbidden("SAMPLE_FORBIDDEN", "training sample belongs to another tenant")
	case strings.Contains(msg, "InvalidArgument"):
		return errors.BadRequest("INVALID_ARGUMENT", msg)
	default:
		return errors.ServiceUnavailable("AI_GATEWAY_ERROR", msg)
	}
}

func sampleInfoToDomain(info *aipb.TrainingSampleInfo) domain.LabelReviewSample {
	if info == nil {
		return domain.LabelReviewSample{}
	}
	out := domain.LabelReviewSample{
		ID:             info.GetId(),
		Task:           info.GetTask(),
		CollectedAt:    parseRFC3339(info.GetTimestamp()),
		Provenance:     info.GetProvenance(),
		Provider:       info.GetProvider(),
		TopConfidence:  info.GetTopConfidence(),
		EffectiveLabel: info.GetEffectiveLabel(),
	}
	if sus := info.GetSuspect(); sus != nil {
		out.Suspect = &domain.LabelSuspicion{
			Predicted:     sus.GetPredicted(),
			PredictedProb: sus.GetPredictedProb(),
			LabelProb:     sus.GetLabelProb(),
			ModelVersion:  sus.GetModelVersion(),
			FlaggedAt:     sus.GetFlaggedAt(),
		}
	}
	for _, l := range info.GetLabels() {
		out.Labels = append(out.Labels, domain.TrainingLabel{
			Name:       l.GetName(),
			Confidence: l.GetConfidence(),
			Category:   l.GetCategory(),
			Severity:   l.GetSeverity(),
		})
	}
	if c := info.GetContext(); c != nil {
		out.FarmID = c.GetFarmId()
		out.FieldID = c.GetFieldId()
		out.Crop = c.GetCrop()
		out.SubmittedBy = c.GetSubmittedBy()
	}
	if r := info.GetReview(); r != nil {
		out.Review = &domain.LabelReview{
			Decision:       domain.LabelReviewDecision(r.GetDecision()),
			CorrectedLabel: r.GetCorrectedLabel(),
			ReviewerID:     r.GetReviewerId(),
			Notes:          r.GetNotes(),
			ReviewedAt:     parseRFC3339(r.GetReviewedAt()),
		}
	}
	return out
}

func parseRFC3339(s string) *time.Time {
	if s == "" {
		return nil
	}
	t, err := time.Parse(time.RFC3339Nano, s)
	if err != nil {
		if t, err = time.Parse(time.RFC3339, s); err != nil {
			return nil
		}
	}
	return &t
}
