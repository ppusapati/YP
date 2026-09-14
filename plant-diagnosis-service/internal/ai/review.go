package ai

import (
	"context"
	"fmt"

	aipb "p9e.in/samavaya/agriculture/ai-gateway/api/v1"
)

// Human-in-the-loop label review. The gateway owns the sample store; these
// calls are proxied tenant-scoped by the application layer.

// ListSamplesQuery filters the gateway's training-sample store.
type ListSamplesQuery struct {
	Task          string
	ReviewStatus  string // "unreviewed" (default), "reviewed", "all"
	TenantID      string
	MinConfidence float64
	MaxConfidence float64
	Provenance    string
	PageSize      int32
	PageOffset    int32
	Order         string // "confidence_asc" (default), "newest", "suspect_first"
	// SuspectOnly restricts the queue to labels a trained model contradicted.
	SuspectOnly bool
	// SecondOpinionOnly restricts it to samples waiting on another reviewer.
	SecondOpinionOnly bool
}

// SampleReview is a reviewer's decision to record on a sample.
type SampleReview struct {
	Decision       string // confirmed, corrected, rejected
	CorrectedLabel string
	ReviewerID     string
	TenantID       string
	Notes          string
}

// SamplePage is one page of the review queue.
type SamplePage struct {
	Samples         []*aipb.TrainingSampleInfo
	TotalCount      int32
	UnreviewedCount int32
}

// ListTrainingSamples lists collected samples for review.
func (c *AIClient) ListTrainingSamples(ctx context.Context, q ListSamplesQuery) (*SamplePage, error) {
	var page *SamplePage
	err := c.cb.Execute(ctx, func(cbCtx context.Context) error {
		resp, err := gatewayClient(c.conn).ListTrainingSamples(cbCtx, &aipb.ListTrainingSamplesRequest{
			Task:              q.Task,
			ReviewStatus:      q.ReviewStatus,
			TenantId:          q.TenantID,
			MinConfidence:     q.MinConfidence,
			MaxConfidence:     q.MaxConfidence,
			Provenance:        q.Provenance,
			PageSize:          q.PageSize,
			PageOffset:        q.PageOffset,
			Order:             q.Order,
			SuspectOnly:       q.SuspectOnly,
			SecondOpinionOnly: q.SecondOpinionOnly,
		})
		if err != nil {
			return fmt.Errorf("ListTrainingSamples RPC failed: %w", err)
		}
		page = &SamplePage{
			Samples:         resp.GetSamples(),
			TotalCount:      resp.GetTotalCount(),
			UnreviewedCount: resp.GetUnreviewedCount(),
		}
		return nil
	})
	if err != nil {
		c.logger.Errorw("msg", "AI ListTrainingSamples failed", "task", q.Task, "error", err)
		return nil, err
	}
	return page, nil
}

// SubmitLabelReview records a review decision and returns the updated sample.
func (c *AIClient) SubmitLabelReview(ctx context.Context, task, sampleID string, review SampleReview) (*aipb.TrainingSampleInfo, error) {
	var sample *aipb.TrainingSampleInfo
	err := c.cb.Execute(ctx, func(cbCtx context.Context) error {
		resp, err := gatewayClient(c.conn).SubmitLabelReview(cbCtx, &aipb.SubmitLabelReviewRequest{
			Task:     task,
			SampleId: sampleID,
			Review: &aipb.LabelReview{
				Decision:       review.Decision,
				CorrectedLabel: review.CorrectedLabel,
				ReviewerId:     review.ReviewerID,
				TenantId:       review.TenantID,
				Notes:          review.Notes,
			},
		})
		if err != nil {
			return fmt.Errorf("SubmitLabelReview RPC failed: %w", err)
		}
		sample = resp.GetSample()
		return nil
	})
	if err != nil {
		c.logger.Errorw("msg", "AI SubmitLabelReview failed", "task", task, "sample_id", sampleID, "error", err)
		return nil, err
	}
	return sample, nil
}

// GetTrainingSampleImage fetches the image bytes behind a sample. tenantID
// (when non-empty) must match the tenant the sample was collected under.
func (c *AIClient) GetTrainingSampleImage(ctx context.Context, task, sampleID, tenantID string) ([]byte, string, error) {
	var (
		data []byte
		mime string
	)
	err := c.cb.Execute(ctx, func(cbCtx context.Context) error {
		resp, err := gatewayClient(c.conn).GetTrainingSampleImage(cbCtx, &aipb.GetTrainingSampleImageRequest{
			Task:     task,
			SampleId: sampleID,
			TenantId: tenantID,
		})
		if err != nil {
			return fmt.Errorf("GetTrainingSampleImage RPC failed: %w", err)
		}
		data, mime = resp.GetImageBytes(), resp.GetMimeType()
		return nil
	})
	if err != nil {
		c.logger.Errorw("msg", "AI GetTrainingSampleImage failed", "task", task, "sample_id", sampleID, "error", err)
		return nil, "", err
	}
	return data, mime, nil
}

// RequestSecondOpinion flags a sample as wanting another reviewer, or clears
// the flag once the question is settled.
func (c *AIClient) RequestSecondOpinion(ctx context.Context, task, sampleID, tenantID string, wanted bool) (*aipb.TrainingSampleInfo, error) {
	var sample *aipb.TrainingSampleInfo
	err := c.cb.Execute(ctx, func(cbCtx context.Context) error {
		resp, err := gatewayClient(c.conn).RequestSecondOpinion(cbCtx, &aipb.RequestSecondOpinionRequest{
			Task:     task,
			SampleId: sampleID,
			TenantId: tenantID,
			Wanted:   wanted,
		})
		if err != nil {
			return fmt.Errorf("RequestSecondOpinion RPC failed: %w", err)
		}
		sample = resp.GetSample()
		return nil
	})
	if err != nil {
		return nil, err
	}
	return sample, nil
}

// ReviewAgreement reports how much reviewers agree on a task's labels.
func (c *AIClient) ReviewAgreement(ctx context.Context, task, tenantID string) (*aipb.ReviewAgreement, error) {
	var out *aipb.ReviewAgreement
	err := c.cb.Execute(ctx, func(cbCtx context.Context) error {
		resp, err := gatewayClient(c.conn).GetReviewAgreement(cbCtx, &aipb.GetReviewAgreementRequest{
			Task:     task,
			TenantId: tenantID,
		})
		if err != nil {
			return fmt.Errorf("GetReviewAgreement RPC failed: %w", err)
		}
		out = resp.GetAgreement()
		return nil
	})
	if err != nil {
		return nil, err
	}
	return out, nil
}
