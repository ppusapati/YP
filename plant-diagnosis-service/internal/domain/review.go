package domain

import "time"

// Training-label review types. The AI gateway owns the collected samples;
// these are the tenant-scoped view the service exposes to agronomists.

// LabelReviewDecision is the outcome of a human review of an auto-label.
type LabelReviewDecision string

const (
	LabelReviewConfirmed LabelReviewDecision = "confirmed"
	LabelReviewCorrected LabelReviewDecision = "corrected"
	LabelReviewRejected  LabelReviewDecision = "rejected"
)

// ReviewTasks are the vision tasks with collected samples.
var ReviewTasks = []string{"disease", "pest", "nutrient_deficiency", "plant_classification"}

// IsReviewTask reports whether task names a reviewable sample store.
func IsReviewTask(task string) bool {
	for _, t := range ReviewTasks {
		if t == task {
			return true
		}
	}
	return false
}

// TrainingLabel is one auto-assigned label with its confidence.
type TrainingLabel struct {
	Name       string
	Confidence float64
	Category   string
	Severity   string
}

// LabelReview records a human decision on a sample.
type LabelReview struct {
	Decision       LabelReviewDecision
	CorrectedLabel string
	ReviewerID     string
	Notes          string
	ReviewedAt     *time.Time
}

// LabelReviewSample is a collected training image with its auto-labels,
// context, and (optionally) the review applied to it.
type LabelReviewSample struct {
	ID             string
	Task           string
	CollectedAt    *time.Time
	Provenance     string
	Provider       string
	Labels         []TrainingLabel
	TopConfidence  float64
	FarmID         string
	FieldID        string
	Crop           string
	SubmittedBy    string
	Review         *LabelReview
	EffectiveLabel string
}

// ListLabelReviewQueueParams filters the review queue. TenantID is always set
// from the caller's context by the application layer.
type ListLabelReviewQueueParams struct {
	TenantID        string
	Task            string
	IncludeReviewed bool
	MaxConfidence   float64
	Provenance      string
	PageSize        int32
	Offset          int32
	NewestFirst     bool
}

// SubmitLabelReviewInput is a reviewer's decision on one sample.
type SubmitLabelReviewInput struct {
	Task           string
	SampleID       string
	Decision       LabelReviewDecision
	CorrectedLabel string
	Notes          string
}

// LabelReviewImage is the raw image bytes behind a sample.
type LabelReviewImage struct {
	Bytes    []byte
	MimeType string
}
