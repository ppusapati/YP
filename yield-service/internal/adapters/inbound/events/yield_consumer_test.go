package events

import (
	"context"
	"errors"
	"testing"
	"time"

	eventsdomain "p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/testutil"

	"p9e.in/samavaya/agriculture/yield-service/internal/domain"
	"p9e.in/samavaya/agriculture/yield-service/internal/ports/inbound"
)

// predictingService records what the consumer asked to predict.
type predictingService struct {
	inbound.YieldService // nil: the consumer only lists and predicts

	predicted []domain.YieldPrediction
	tenants   []string
	listed    []domain.ListPredictionsParams

	predictErr error
	listErr    error
	// existing is returned by ListPredictions, modelling a prediction that is
	// already on record for this assignment.
	existing []domain.YieldPrediction
}

func (s *predictingService) ListPredictions(ctx context.Context, p domain.ListPredictionsParams) ([]domain.YieldPrediction, int32, error) {
	s.listed = append(s.listed, p)
	if s.listErr != nil {
		return nil, 0, s.listErr
	}
	return s.existing, int32(len(s.existing)), nil
}

func (s *predictingService) PredictYield(ctx context.Context, p *domain.YieldPrediction) (*domain.YieldPrediction, error) {
	s.tenants = append(s.tenants, p9context.TenantID(ctx))
	if s.predictErr != nil {
		return nil, s.predictErr
	}
	out := *p
	out.ID = "pred-1"
	// What the real service does against all-zero factors: the crop's base
	// yield at zero confidence.
	out.PredictedYieldKgPerHectare = 3200
	out.PredictionConfidencePct = 0
	s.predicted = append(s.predicted, out)
	return &out, nil
}

func cropAssigned(data map[string]any) *eventsdomain.DomainEvent {
	return &eventsdomain.DomainEvent{
		ID:          "evt-1",
		Type:        eventsdomain.EventTypeFieldCropAssigned,
		AggregateID: "fld-1",
		Timestamp:   time.Now(),
		Data:        data,
	}
}

func fullAssignment() map[string]any {
	return map[string]any{
		"field_id": "fld-1", "crop_id": "wheat", "tenant_id": "tenant-a",
		"farm_id": "fm-1", "season": "RABI",
		"planting_date": "2025-12-03T00:00:00Z",
	}
}

// ---------------------------------------------------------------------------

// The point of the handler: planting a crop produces a prediction.
//
// It used to log "generating initial yield prediction" and return nil, having
// generated nothing, so the field's yield page showed "no data" from planting
// until somebody asked for a prediction by hand — the one moment a farmer is
// least likely to, having just told the system what they planted.
func TestCropAssignedGeneratesAPrediction(t *testing.T) {
	svc := &predictingService{}
	c := NewYieldConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), cropAssigned(fullAssignment())); err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}
	if len(svc.predicted) != 1 {
		t.Fatalf("made %d predictions, want 1", len(svc.predicted))
	}
	p := svc.predicted[0]
	if p.FieldID != "fld-1" || p.CropID != "wheat" || p.FarmID != "fm-1" || p.Season != "RABI" {
		t.Errorf("prediction is for %+v", p)
	}
}

// The season year comes from the planting date, not from today. A crop sown in
// December for the following season belongs to that season's year, and filing
// it under the calendar year of the event would put it in the wrong one.
func TestTheYearComesFromThePlantingDate(t *testing.T) {
	svc := &predictingService{}
	c := NewYieldConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), cropAssigned(fullAssignment())); err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}
	if got := svc.predicted[0].Year; got != 2025 {
		t.Errorf("Year = %d, want 2025 from the planting date", got)
	}
}

// With no planting date the year falls back to now rather than to zero, which
// PredictYield rejects outright.
func TestAMissingPlantingDateFallsBackToNow(t *testing.T) {
	data := fullAssignment()
	delete(data, "planting_date")

	svc := &predictingService{}
	c := NewYieldConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), cropAssigned(data)); err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}
	if got := svc.predicted[0].Year; got != int32(time.Now().UTC().Year()) {
		t.Errorf("Year = %d, want the current year", got)
	}
}

// The consumer has no request to inherit a tenant from, so it must attach one.
// Without it the write runs unscoped and row-level security rejects it.
func TestThePredictionRunsInTheEventsTenant(t *testing.T) {
	svc := &predictingService{}
	c := NewYieldConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), cropAssigned(fullAssignment())); err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}
	if len(svc.tenants) != 1 || svc.tenants[0] != "tenant-a" {
		t.Errorf("predicted with tenants %v, want [tenant-a]", svc.tenants)
	}
}

// Kafka delivery is at-least-once, so a replay must not add a second identical
// baseline. Several predictions over a season are wanted; two copies of the
// opening one are not.
func TestAReplayDoesNotAddASecondBaseline(t *testing.T) {
	svc := &predictingService{}
	c := NewYieldConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), cropAssigned(fullAssignment())); err != nil {
		t.Fatalf("first pass: %v", err)
	}
	// The prediction just made is now on record.
	svc.existing = svc.predicted

	if err := c.HandleEvent(context.Background(), cropAssigned(fullAssignment())); err != nil {
		t.Fatalf("replay: %v", err)
	}
	if len(svc.predicted) != 1 {
		t.Errorf("a replay produced %d predictions, want 1", len(svc.predicted))
	}
}

// The existence check is scoped to this assignment, not to the field. A field
// carrying last season's prediction must still get one for this season.
func TestTheExistenceCheckIsScopedToTheSeason(t *testing.T) {
	svc := &predictingService{}
	c := NewYieldConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), cropAssigned(fullAssignment())); err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}
	if len(svc.listed) != 1 {
		t.Fatalf("checked %d times, want 1", len(svc.listed))
	}
	q := svc.listed[0]
	if q.FieldID != "fld-1" || q.CropID != "wheat" || q.Season != "RABI" || q.Year != 2025 {
		t.Errorf("checked with %+v; a check on the field alone would suppress "+
			"every season after the first", q)
	}
}

// A prediction failure is returned so the consumer retries. Accepting it
// silently is how the field ends up showing "no data" again — the defect this
// handler exists to fix.
func TestAPredictionFailureIsRetryable(t *testing.T) {
	svc := &predictingService{predictErr: errors.New("gateway unavailable")}
	c := NewYieldConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), cropAssigned(fullAssignment())); err == nil {
		t.Error("a prediction failure was reported as a successful handle")
	}
}

// So is a failure of the existence check: proceeding blind would duplicate,
// and giving up would lose the prediction.
func TestAFailedExistenceCheckIsRetryable(t *testing.T) {
	svc := &predictingService{listErr: errors.New("database unavailable")}
	c := NewYieldConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), cropAssigned(fullAssignment())); err == nil {
		t.Error("a failed existence check was reported as a successful handle")
	}
	if len(svc.predicted) != 0 {
		t.Error("a prediction was written despite the check failing")
	}
}

// An event missing anything a prediction needs is dropped, not retried: a
// replay will not supply a field the producer never sent, and retrying forever
// blocks the partition for every event behind it.
func TestAnIncompleteEventIsDroppedNotRetried(t *testing.T) {
	for _, missing := range []string{"field_id", "crop_id", "tenant_id", "farm_id", "season"} {
		data := fullAssignment()
		delete(data, missing)

		svc := &predictingService{}
		c := NewYieldConsumer(svc, testutil.NopLogger{})

		if err := c.HandleEvent(context.Background(), cropAssigned(data)); err != nil {
			t.Errorf("an event without %s was retried: %v", missing, err)
		}
		if len(svc.predicted) != 0 {
			t.Errorf("an event without %s still produced a prediction", missing)
		}
	}
}
