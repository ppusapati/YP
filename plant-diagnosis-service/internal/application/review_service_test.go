package application

import (
	"context"
	"errors"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.uber.org/zap"

	aipb "p9e.in/samavaya/agriculture/ai-gateway/api/v1"
	"p9e.in/samavaya/agriculture/plant-diagnosis-service/internal/domain"
	p9errors "p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"
)

func newReviewSvcWithoutGateway() *diagnosisService {
	return &diagnosisService{
		repo: newMockDiagnosisRepo(),
		pub:  &mockEventPublisher{},
		log:  p9log.NewHelper(p9log.NewLogger(zap.NewNop())),
	}
}

func TestLabelReview_RequiresGateway(t *testing.T) {
	svc := newReviewSvcWithoutGateway()
	ctx := context.Background()

	_, _, _, err := svc.ListLabelReviewQueue(ctx, domain.ListLabelReviewQueueParams{Task: "disease"})
	require.Error(t, err)
	assert.True(t, p9errors.IsServiceUnavailable(err), "expected service unavailable, got %v", err)

	_, err = svc.SubmitLabelReview(ctx, domain.SubmitLabelReviewInput{Task: "disease", SampleID: "abc", Decision: domain.LabelReviewConfirmed})
	assert.True(t, p9errors.IsServiceUnavailable(err))

	_, err = svc.GetLabelReviewImage(ctx, "disease", "abc")
	assert.True(t, p9errors.IsServiceUnavailable(err))
}

func TestMapGatewayError(t *testing.T) {
	assert.True(t, p9errors.IsNotFound(mapGatewayError(errors.New("rpc error: code = NotFound desc = sample x not found"), "x")))
	assert.True(t, p9errors.IsForbidden(mapGatewayError(errors.New("rpc error: code = PermissionDenied desc = sample x belongs to another tenant"), "x")))
	assert.True(t, p9errors.IsBadRequest(mapGatewayError(errors.New("rpc error: code = InvalidArgument desc = corrected decision requires corrected_label"), "x")))
	assert.True(t, p9errors.IsServiceUnavailable(mapGatewayError(errors.New("connection refused"), "x")))
}

func TestSampleInfoToDomain(t *testing.T) {
	info := &aipb.TrainingSampleInfo{
		Id:            "deadbeef",
		Task:          "disease",
		Timestamp:     "2026-09-01T10:00:00Z",
		Provenance:    "external_api",
		Provider:      "plantnet",
		TopConfidence: 0.42,
		Labels: []*aipb.TrainingLabel{
			{Name: "rust", Confidence: 0.42, Category: "disease", Severity: "moderate"},
			{Name: "healthy", Confidence: 0.3},
		},
		Context: &aipb.SampleContext{TenantId: "t1", FarmId: "farm-1", FieldId: "field-1", Crop: "wheat", SubmittedBy: "u1"},
		Review: &aipb.LabelReview{
			Decision:       "corrected",
			CorrectedLabel: "leaf_spot",
			ReviewerId:     "agro-1",
			ReviewedAt:     "2026-09-02T08:30:00Z",
		},
		EffectiveLabel: "leaf_spot",
	}

	s := sampleInfoToDomain(info)
	assert.Equal(t, "deadbeef", s.ID)
	assert.Equal(t, "disease", s.Task)
	require.NotNil(t, s.CollectedAt)
	assert.Equal(t, 2026, s.CollectedAt.Year())
	assert.Len(t, s.Labels, 2)
	assert.Equal(t, "moderate", s.Labels[0].Severity)
	assert.Equal(t, "farm-1", s.FarmID)
	assert.Equal(t, "field-1", s.FieldID)
	assert.Equal(t, "wheat", s.Crop)
	assert.Equal(t, "u1", s.SubmittedBy)
	require.NotNil(t, s.Review)
	assert.Equal(t, domain.LabelReviewCorrected, s.Review.Decision)
	assert.Equal(t, "leaf_spot", s.Review.CorrectedLabel)
	require.NotNil(t, s.Review.ReviewedAt)
	assert.Equal(t, "leaf_spot", s.EffectiveLabel)

	// Unreviewed sample has no review and nil timestamps parse safely.
	bare := sampleInfoToDomain(&aipb.TrainingSampleInfo{Id: "x", Timestamp: "not-a-time"})
	assert.Nil(t, bare.Review)
	assert.Nil(t, bare.CollectedAt)
	assert.Empty(t, sampleInfoToDomain(nil).ID)
}

func TestIsReviewTask(t *testing.T) {
	for _, task := range domain.ReviewTasks {
		assert.True(t, domain.IsReviewTask(task), task)
	}
	assert.False(t, domain.IsReviewTask("yield"))
	assert.False(t, domain.IsReviewTask(""))
}
