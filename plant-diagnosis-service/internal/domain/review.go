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
	// Suspect is set when a trained model confidently contradicted this
	// sample's label, which usually means the label is wrong rather than the
	// image hard.
	Suspect *LabelSuspicion
	// NeedsSecondOpinion is true when a reviewer asked for another pair of
	// eyes, or when two reviewers already disagreed.
	NeedsSecondOpinion bool
	// Reviews is every verdict this sample has received, oldest first.
	Reviews []LabelReview
}

// ReviewAgreement is how much two reviewers agree, and whether that is more
// than chance would produce on its own.
type ReviewAgreement struct {
	Compared      int32
	RawAgreement  float64
	Kappa         float64
	Strength      string
	Disagreements []LabelDisagreement
}

// LabelDisagreement is one pair of labels reviewers chose differently.
type LabelDisagreement struct {
	First  string
	Second string
	Count  int32
}

// LabelSuspicion records a trained model's disagreement with a stored label.
type LabelSuspicion struct {
	Predicted     string
	PredictedProb float64
	LabelProb     float64
	ModelVersion  string
	FlaggedAt     string
}

// ListLabelReviewQueueParams filters the review queue. TenantID is always set
// from the caller's context by the application layer.
type ListLabelReviewQueueParams struct {
	TenantID          string
	Task              string
	SuspectOnly       bool
	SecondOpinionOnly bool
	IncludeReviewed   bool
	MaxConfidence     float64
	Provenance        string
	PageSize          int32
	Offset            int32
	NewestFirst       bool
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
