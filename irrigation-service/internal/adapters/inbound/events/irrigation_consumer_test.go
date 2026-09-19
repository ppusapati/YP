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
