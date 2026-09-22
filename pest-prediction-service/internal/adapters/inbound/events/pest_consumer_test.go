package events

import (
	"context"
	"errors"
	"testing"
	"time"

	eventsdomain "p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/testutil"

	"p9e.in/samavaya/agriculture/pest-prediction-service/internal/domain"
	"p9e.in/samavaya/agriculture/pest-prediction-service/internal/ports/inbound"
)

// assessingService records what the consumer asked to assess.
type assessingService struct {
	inbound.PestService // nil: the consumer only calls PredictPestRisk

	asked   []domain.PredictPestRiskParams
	tenants []string
	err     error
}

func (s *assessingService) PredictPestRisk(ctx context.Context, p *domain.PredictPestRiskParams) (*domain.PestPrediction, error) {
	s.asked = append(s.asked, *p)
	s.tenants = append(s.tenants, p9context.TenantID(ctx))
	if s.err != nil {
		return nil, s.err
	}
	out := &domain.PestPrediction{RiskLevel: domain.RiskLevelHigh, RiskScore: 65}
	out.ID = "pred-1"
	return out, nil
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
		"field_id": "fld-1", "crop_id": "01JABCDEF0123456789ABCDEFG",
		"tenant_id": "tenant-a", "farm_id": "fm-1",
		"crop_name": "Wheat", "growth_stage": "SEEDLING",
	}
}

// ---------------------------------------------------------------------------

// The point of the handler: planting a crop records a pest risk assessment.
//
// It used to log "generating pest risk assessment" and return nil, having
// generated nothing, so the field had no assessment until somebody asked for
// one by hand.
func TestCropAssignedRecordsAnAssessment(t *testing.T) {
	svc := &assessingService{}
	c := NewPestConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), cropAssigned(fullAssignment())); err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}
	if len(svc.asked) != 1 {
		t.Fatalf("made %d assessments, want 1", len(svc.asked))
	}
	p := svc.asked[0]
	if p.FieldID != "fld-1" || p.FarmID != "fm-1" {
		t.Errorf("assessment is for %+v", p)
	}
}

// The crop *name* goes in, not the crop id.
//
// PredictPestRisk stores whatever it is given as the prediction's crop type
// and forwards it to the AI gateway, so passing the opaque crop-service id
// would file a farmer-facing prediction against a crop nobody can read — and
// the rules scorer ignores crop type entirely, so the risk number would look
// perfectly normal while being about nothing.
func TestTheCropNameIsUsedNotTheCropID(t *testing.T) {
	svc := &assessingService{}
	c := NewPestConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), cropAssigned(fullAssignment())); err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}
	if got := svc.asked[0].CropType; got != "Wheat" {
		t.Errorf("CropType = %q, want the crop name; an opaque id here is "+
			"stored and shown to the farmer", got)
	}
}

// An event with a crop id but no name is skipped rather than falling back to
// the id, which is the defect the name exists to prevent.
func TestAnEventWithoutACropNameIsSkipped(t *testing.T) {
	data := fullAssignment()
	delete(data, "crop_name")

	svc := &assessingService{}
	c := NewPestConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), cropAssigned(data)); err != nil {
		t.Errorf("an event without a crop name was retried: %v", err)
	}
	if len(svc.asked) != 0 {
		t.Errorf("an event without a crop name still produced an assessment "+
			"with CropType %q", svc.asked[0].CropType)
	}
}

// Planting does not page the farmer.
//
// Risk at or above HIGH normally raises an alert, and weather alone clears
// that threshold on a warm wet day — so without suppression, planting three
// fields on one damp morning would page the farmer three times about pests on
// bare ground.
func TestPlantingDoesNotRaiseAnAlert(t *testing.T) {
	svc := &assessingService{}
	c := NewPestConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), cropAssigned(fullAssignment())); err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}
	if !svc.asked[0].SuppressAlert {
		t.Error("the opening assessment can raise a farmer-facing alert; " +
			"planting on a warm wet day would page them about bare ground")
	}
}

// The growth stage rides along, because it is worth up to a quarter of the
// rules score. Omitting it scores every assessment at planting as unstaged.
func TestTheGrowthStageIsCarried(t *testing.T) {
	svc := &assessingService{}
	c := NewPestConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), cropAssigned(fullAssignment())); err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}
	stage := svc.asked[0].GrowthStage
	if stage == nil || *stage != domain.GrowthStageSeedling {
		t.Errorf("GrowthStage = %v, want SEEDLING", stage)
	}
}

// field-service and this service do not share a growth-stage vocabulary:
// field has BUDDING, FRUIT_SET, RIPENING, MATURITY and SENESCENCE that this
// service does not. A stage from that half must score as unstaged rather than
// fall through to whichever stage happens to be first.
func TestAnUnknownGrowthStageScoresAsUnstaged(t *testing.T) {
	for _, stage := range []string{"RIPENING", "SENESCENCE", "BUDDING", "NONSENSE"} {
		data := fullAssignment()
		data["growth_stage"] = stage

		svc := &assessingService{}
		c := NewPestConsumer(svc, testutil.NopLogger{})

		if err := c.HandleEvent(context.Background(), cropAssigned(data)); err != nil {
			t.Fatalf("%s: %v", stage, err)
		}
		if got := svc.asked[0].GrowthStage; got != nil {
			t.Errorf("growth stage %q was read as %v; it is not in this "+
				"service's vocabulary", stage, *got)
		}
	}
}

// Weather is left for the service to look up. It fetches the field's own
// observation from weather-service and treats anything supplied by a caller as
// a fallback, so that a caller cannot move a risk score by sending numbers of
// its own — and a consumer has none to send anyway.
func TestWeatherIsLeftToTheService(t *testing.T) {
	svc := &assessingService{}
	c := NewPestConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), cropAssigned(fullAssignment())); err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}
	if svc.asked[0].Weather != (domain.WeatherFactors{}) {
		t.Errorf("the consumer supplied weather of its own: %+v", svc.asked[0].Weather)
	}
}

// No pest species is named: a crop assignment does not imply one. This is the
// field's environmental pest risk, not a species forecast.
func TestNoPestSpeciesIsInvented(t *testing.T) {
	svc := &assessingService{}
	c := NewPestConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), cropAssigned(fullAssignment())); err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}
	if got := svc.asked[0].PestSpeciesID; got != "" {
		t.Errorf("PestSpeciesID = %q; nothing in a crop assignment names a species", got)
	}
}

// The consumer has no request to inherit a tenant from, so it must attach one.
// Without it the write runs unscoped and row-level security rejects it.
func TestTheAssessmentRunsInTheEventsTenant(t *testing.T) {
	svc := &assessingService{}
	c := NewPestConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), cropAssigned(fullAssignment())); err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}
	if len(svc.tenants) != 1 || svc.tenants[0] != "tenant-a" {
		t.Errorf("assessed with tenants %v, want [tenant-a]", svc.tenants)
	}
}

// A failure is returned so the consumer retries: an assessment lost to a
// briefly unavailable gateway is the defect this handler exists to fix.
func TestAnAssessmentFailureIsRetryable(t *testing.T) {
	svc := &assessingService{err: errors.New("gateway unavailable")}
	c := NewPestConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), cropAssigned(fullAssignment())); err == nil {
		t.Error("an assessment failure was reported as a successful handle")
	}
}

// An event missing a field or a tenant is dropped, not retried: a replay will
// not supply what the producer never sent, and retrying forever blocks the
// partition for every event behind it.
func TestAnIncompleteEventIsDroppedNotRetried(t *testing.T) {
	for _, missing := range []string{"field_id", "tenant_id"} {
		data := fullAssignment()
		delete(data, missing)

		svc := &assessingService{}
		c := NewPestConsumer(svc, testutil.NopLogger{})

		if err := c.HandleEvent(context.Background(), cropAssigned(data)); err != nil {
			t.Errorf("an event without %s was retried: %v", missing, err)
		}
		if len(svc.asked) != 0 {
			t.Errorf("an event without %s still produced an assessment", missing)
		}
	}
}
