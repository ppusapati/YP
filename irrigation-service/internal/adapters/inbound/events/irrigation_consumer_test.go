package events

import (
	"context"
	"errors"
	"sort"
	"strconv"
	"testing"
	"time"

	eventsdomain "p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/testutil"

	"p9e.in/samavaya/agriculture/irrigation-service/internal/domain"
	"p9e.in/samavaya/agriculture/irrigation-service/internal/ports/inbound"
)

// cascadeService holds schedules whose status cancelling actually changes. A
// cancelled schedule stays in the listing, which is the property that makes
// the offset have to advance rather than re-read the first page.
type cascadeService struct {
	inbound.IrrigationService // nil: the consumer only lists and cancels

	schedules map[string]*domain.IrrigationSchedule
	tenants   []string
	listCalls int

	listErr   error
	cancelErr error
}

func newCascadeService(n int, status domain.IrrigationStatus) *cascadeService {
	s := &cascadeService{schedules: map[string]*domain.IrrigationSchedule{}}
	for i := 0; i < n; i++ {
		id := "sch-" + strconv.Itoa(1000+i)
		sched := &domain.IrrigationSchedule{FieldID: "fld-1", Status: status}
		sched.ID = id
		s.schedules[id] = sched
	}
	return s
}

func (s *cascadeService) ListSchedulesByField(ctx context.Context, fieldID string, pageSize, offset int32) ([]domain.IrrigationSchedule, int32, error) {
	s.listCalls++
	s.tenants = append(s.tenants, p9context.TenantID(ctx))
	if s.listErr != nil {
		return nil, 0, s.listErr
	}

	ids := make([]string, 0, len(s.schedules))
	for id, sched := range s.schedules {
		if sched.FieldID == fieldID {
			ids = append(ids, id)
		}
	}
	sort.Strings(ids)

	total := int32(len(ids))
	if offset >= total {
		return nil, total, nil
	}
	ids = ids[offset:]
	if pageSize > 0 && int32(len(ids)) > pageSize {
		ids = ids[:pageSize]
	}

	out := make([]domain.IrrigationSchedule, 0, len(ids))
	for _, id := range ids {
		out = append(out, *s.schedules[id])
	}
	return out, total, nil
}

func (s *cascadeService) CancelSchedule(_ context.Context, id string) error {
	if s.cancelErr != nil {
		return s.cancelErr
	}
	sched, ok := s.schedules[id]
	if !ok {
		return errors.New("not found")
	}
	// Mirrors the service, which rejects both rather than being idempotent.
	if sched.Status == domain.IrrigationStatusCancelled {
		return errors.New("ALREADY_CANCELLED")
	}
	if sched.Status == domain.IrrigationStatusCompleted {
		return errors.New("ALREADY_COMPLETED")
	}
	sched.Status = domain.IrrigationStatusCancelled
	return nil
}

func (s *cascadeService) liveCount() int {
	n := 0
	for _, sched := range s.schedules {
		if sched.Status != domain.IrrigationStatusCancelled &&
			sched.Status != domain.IrrigationStatusCompleted {
			n++
		}
	}
	return n
}

func fieldDeleted(fieldID, tenantID string) *eventsdomain.DomainEvent {
	return &eventsdomain.DomainEvent{
		ID:          "evt-1",
		Type:        eventsdomain.EventTypeFieldDeleted,
		AggregateID: fieldID,
		Timestamp:   time.Now(),
		Data:        map[string]any{"field_id": fieldID, "tenant_id": tenantID},
	}
}

// ---------------------------------------------------------------------------

// The point of the handler: a deleted field stops having water scheduled onto
// it.
//
// It used to log "field deleted, cancelling irrigation schedules" and return
// nil, having cancelled nothing. An irrigation schedule is not a stale row,
// it is a valve: the next window would have run water onto ground the system
// no longer believes anybody farms, and billed for it.
func TestFieldDeletedCancelsItsSchedules(t *testing.T) {
	svc := newCascadeService(4, domain.IrrigationStatusScheduled)
	c := NewIrrigationConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), fieldDeleted("fld-1", "tenant-a")); err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}
	if got := svc.liveCount(); got != 0 {
		t.Errorf("%d schedules are still live against a deleted field", got)
	}
}

// An ACTIVE schedule — a valve open right now — is cancelled too, not only the
// ones merely booked.
func TestAnActiveScheduleIsCancelled(t *testing.T) {
	svc := newCascadeService(2, domain.IrrigationStatusActive)
	c := NewIrrigationConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), fieldDeleted("fld-1", "tenant-a")); err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}
	if got := svc.liveCount(); got != 0 {
		t.Errorf("%d schedules were left running", got)
	}
}

// Schedules that have already finished are skipped rather than cancelled. The
// service rejects them with ALREADY_COMPLETED, and counting those rejections
// as failures would abandon the page on a field whose schedules had simply
// all run.
func TestTerminalSchedulesAreSkippedNotFailed(t *testing.T) {
	svc := newCascadeService(3, domain.IrrigationStatusCompleted)
	c := NewIrrigationConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), fieldDeleted("fld-1", "tenant-a")); err != nil {
		t.Errorf("a field whose schedules had all completed was reported as a failure: %v", err)
	}
	for id, sched := range svc.schedules {
		if sched.Status != domain.IrrigationStatusCompleted {
			t.Errorf("completed schedule %s was rewritten to %s", id, sched.Status)
		}
	}
}

// Replaying the event must not fail. Kafka delivery is at-least-once, and a
// second pass finds everything already cancelled.
func TestReplayingTheEventIsSafe(t *testing.T) {
	svc := newCascadeService(3, domain.IrrigationStatusScheduled)
	c := NewIrrigationConsumer(svc, testutil.NopLogger{})

	for i := 0; i < 2; i++ {
		if err := c.HandleEvent(context.Background(), fieldDeleted("fld-1", "tenant-a")); err != nil {
			t.Fatalf("pass %d: %v", i+1, err)
		}
	}
	if got := svc.liveCount(); got != 0 {
		t.Errorf("%d schedules still live after two passes", got)
	}
}

// The sweep must cross page boundaries: cancelling leaves the schedule in the
// listing, so a loop re-reading page zero would spin or stop after one page.
func TestSweepCrossesPageBoundaries(t *testing.T) {
	svc := newCascadeService(250, domain.IrrigationStatusScheduled)
	c := NewIrrigationConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), fieldDeleted("fld-1", "tenant-a")); err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}
	if got := svc.liveCount(); got != 0 {
		t.Errorf("%d of 250 schedules were left live; the sweep stopped early", got)
	}
	if svc.listCalls < 3 {
		t.Errorf("listed %d times for 250 schedules at a page size of %d",
			svc.listCalls, cascadePageSize)
	}
}

// A listing failure is returned so the consumer retries, rather than leaving a
// valve scheduled to open because the database was briefly unavailable.
func TestAListingFailureIsRetryable(t *testing.T) {
	svc := newCascadeService(2, domain.IrrigationStatusScheduled)
	svc.listErr = errors.New("database unavailable")
	c := NewIrrigationConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), fieldDeleted("fld-1", "tenant-a")); err == nil {
		t.Error("a listing failure was reported as a successful handle")
	}
}

// A page where every cancellation failed is returned rather than committed.
func TestAWhollyFailedPageIsReported(t *testing.T) {
	svc := newCascadeService(3, domain.IrrigationStatusScheduled)
	svc.cancelErr = errors.New("write failed")
	c := NewIrrigationConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), fieldDeleted("fld-1", "tenant-a")); err == nil {
		t.Error("a page where every cancellation failed was reported as success")
	}
}

// An event with no tenant is dropped, not retried: it can never succeed, and
// retrying forever blocks the partition. Guessing a tenant would cancel
// somebody else's irrigation.
func TestAnEventWithoutATenantIsDroppedNotRetried(t *testing.T) {
	svc := newCascadeService(2, domain.IrrigationStatusScheduled)
	c := NewIrrigationConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), fieldDeleted("fld-1", "")); err != nil {
		t.Errorf("a tenantless event was retried: %v", err)
	}
	if svc.listCalls != 0 {
		t.Errorf("a tenantless event still queried: %d calls", svc.listCalls)
	}
	if svc.liveCount() != 2 {
		t.Error("schedules were cancelled from a tenantless event")
	}
}

// The consumer has no request to inherit a tenant from, so it must attach one.
// Without it the queries run unscoped, RLS returns nothing, and the handler
// reports success over an empty list.
func TestTheSweepRunsInTheEventsTenant(t *testing.T) {
	svc := newCascadeService(2, domain.IrrigationStatusScheduled)
	c := NewIrrigationConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), fieldDeleted("fld-1", "tenant-a")); err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}
	if len(svc.tenants) == 0 {
		t.Fatal("no listing happened")
	}
	for _, got := range svc.tenants {
		if got != "tenant-a" {
			t.Errorf("listed with tenant %q, want tenant-a", got)
		}
	}
}

// ---------------------------------------------------------------------------
// The sensor leg

// readingService captures what the consumer hands the application layer.
type readingService struct {
	inbound.IrrigationService // nil: the consumer only calls ApplyMoistureReading

	got []domain.MoistureReading
	err error
}

func (s *readingService) ApplyMoistureReading(_ context.Context, r domain.MoistureReading) error {
	s.got = append(s.got, r)
	return s.err
}

// ingestedReading is the payload sensor-service publishes, with the types it
// publishes: value as a JSON number, recorded_at as an RFC 3339 string.
//
// Pinned against the producer rather than written to suit this test. The last
// consumer in this platform that hand-built its own payload passed for months
// while recording nothing, because the producer never sent the field it keyed
// on — see traceability's irrigation handler.
func ingestedReading() map[string]interface{} {
	return map[string]interface{}{
		"sensor_id":   "sen-1",
		"tenant_id":   "t-1",
		"value":       18.5,
		"unit":        "%",
		"quality":     "GOOD",
		"sensor_type": "SOIL_MOISTURE",
		"field_id":    "fld-1",
		"recorded_at": "2026-09-24T09:15:00Z",
	}
}

func TestAMoistureReadingReachesTheApplicationLayer(t *testing.T) {
	svc := &readingService{}
	c := NewIrrigationConsumer(svc, testutil.NopLogger{})

	err := c.HandleEvent(context.Background(), &eventsdomain.DomainEvent{
		ID:        "evt-1",
		Type:      eventsdomain.EventTypeSensorReadingIngested,
		Timestamp: time.Now(),
		Data:      ingestedReading(),
	})
	if err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}

	if len(svc.got) != 1 {
		t.Fatalf("the application layer saw %d readings, want 1", len(svc.got))
	}
	got := svc.got[0]

	// The value is a number on the wire. Read with a string assertion it
	// would come back as zero — and zero percent is the driest possible soil,
	// so a value dropped that way does not go missing, it waters the field.
	if got.Percent != 18.5 {
		t.Errorf("Percent = %v, want 18.5", got.Percent)
	}
	if got.TenantID != "t-1" || got.FieldID != "fld-1" {
		t.Errorf("tenant/field = %q/%q", got.TenantID, got.FieldID)
	}
	if got.Quality != "GOOD" || got.SensorType != "SOIL_MOISTURE" || got.Unit != "%" {
		t.Errorf("quality/type/unit = %q/%q/%q", got.Quality, got.SensorType, got.Unit)
	}
	want := time.Date(2026, 9, 24, 9, 15, 0, 0, time.UTC)
	if !got.RecordedAt.Equal(want) {
		t.Errorf("RecordedAt = %v, want %v", got.RecordedAt, want)
	}
}

// A missing timestamp arrives as the zero time, which the staleness guard
// reads as "do not act". Substituting time.Now() here would turn that guard
// into a no-op that still looked like a guard.
func TestAMissingTimestampDoesNotBecomeNow(t *testing.T) {
	svc := &readingService{}
	c := NewIrrigationConsumer(svc, testutil.NopLogger{})

	data := ingestedReading()
	delete(data, "recorded_at")

	if err := c.HandleEvent(context.Background(), &eventsdomain.DomainEvent{
		ID: "evt-1", Type: eventsdomain.EventTypeSensorReadingIngested,
		Timestamp: time.Now(), Data: data,
	}); err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}

	if !svc.got[0].RecordedAt.IsZero() {
		t.Errorf("RecordedAt = %v; an absent timestamp was invented", svc.got[0].RecordedAt)
	}
}

// An unreadable payload is dropped rather than retried: Kafka would redeliver
// it for ever, and a blocked partition stops every other reading on the farm,
// including the ones that should be opening valves.
func TestAnUnreadablePayloadDoesNotBlockThePartition(t *testing.T) {
	svc := &readingService{}
	c := NewIrrigationConsumer(svc, testutil.NopLogger{})

	err := c.HandleEvent(context.Background(), &eventsdomain.DomainEvent{
		ID: "evt-1", Type: eventsdomain.EventTypeSensorReadingIngested,
		Timestamp: time.Now(),
		// A value that cannot be marshalled, standing in for a payload
		// whose shape this consumer cannot read.
		Data: map[string]interface{}{"value": make(chan int)},
	})
	if err != nil {
		t.Fatalf("HandleEvent returned %v; this must not block the partition", err)
	}
	if len(svc.got) != 0 {
		t.Error("an unreadable payload reached the application layer")
	}
}

// A failure the application layer reports as retryable is passed up, so the
// reading is redelivered rather than lost.
func TestARetryableFailureIsReturned(t *testing.T) {
	svc := &readingService{err: errors.New("database unreachable")}
	c := NewIrrigationConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), &eventsdomain.DomainEvent{
		ID: "evt-1", Type: eventsdomain.EventTypeSensorReadingIngested,
		Timestamp: time.Now(), Data: ingestedReading(),
	}); err == nil {
		t.Fatal("a retryable failure was swallowed; the reading would be lost")
	}
}

// sensor-service emits `registered` and `decommissioned`. The consumer used to
// listen only for `created` and `updated`, which nothing publishes — so these
// handlers had never run.
func TestTheSpellingsSensorServiceActuallyEmitsAreHandled(t *testing.T) {
	for _, evType := range []eventsdomain.EventType{
		eventsdomain.EventTypeSensorRegistered,
		eventsdomain.EventTypeSensorDecommissioned,
	} {
		c := NewIrrigationConsumer(&readingService{}, testutil.NopLogger{})
		if err := c.HandleEvent(context.Background(), &eventsdomain.DomainEvent{
			ID: "evt-1", Type: evType, Timestamp: time.Now(),
			Data: map[string]interface{}{"sensor_id": "sen-1", "field_id": "fld-1"},
		}); err != nil {
			t.Errorf("%s: %v", evType, err)
		}
	}
}
