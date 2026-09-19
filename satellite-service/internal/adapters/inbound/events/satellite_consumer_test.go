package events

import (
	"context"
	"errors"
	"testing"
	"time"

	eventsdomain "p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/testutil"

	"p9e.in/samavaya/agriculture/satellite-service/internal/ports/inbound"
)

// retiringService records what the consumer asked to retire.
type retiringService struct {
	inbound.SatelliteService // nil: the consumer only retires tasks

	fields  []string
	tenants []string
	err     error
	retired int64
}

func (s *retiringService) AbandonTasksForField(ctx context.Context, fieldID string) (int64, error) {
	s.fields = append(s.fields, fieldID)
	s.tenants = append(s.tenants, p9context.TenantID(ctx))
	if s.err != nil {
		return 0, s.err
	}
	return s.retired, nil
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

func farmDeleted(farmID, tenantID string) *eventsdomain.DomainEvent {
	return &eventsdomain.DomainEvent{
		ID:          "evt-2",
		Type:        eventsdomain.EventTypeFarmDeleted,
		AggregateID: farmID,
		Timestamp:   time.Now(),
		Data:        map[string]any{"farm_id": farmID, "tenant_id": tenantID},
	}
}

// ---------------------------------------------------------------------------

// The point of the handler: a deleted field's outstanding tasks are retired.
//
// It used to log "field deleted, cancelling satellite analysis tasks" and
// return nil, having cancelled nothing. Kafka committed the offset and the
// rows stayed PENDING for ever against a field nobody could open.
func TestFieldDeletedRetiresItsTasks(t *testing.T) {
	svc := &retiringService{retired: 3}
	c := NewSatelliteConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), fieldDeleted("fld-1", "tenant-a")); err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}
	if len(svc.fields) != 1 || svc.fields[0] != "fld-1" {
		t.Errorf("retired tasks for %v, want [fld-1]", svc.fields)
	}
}

// The consumer has no request to inherit a tenant from, so it must attach one.
// Without it the update runs unscoped, RLS matches nothing, and the handler
// reports success over zero rows.
func TestTheRetirementRunsInTheEventsTenant(t *testing.T) {
	svc := &retiringService{}
	c := NewSatelliteConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), fieldDeleted("fld-1", "tenant-a")); err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}
	if len(svc.tenants) != 1 || svc.tenants[0] != "tenant-a" {
		t.Errorf("retired with tenants %v, want [tenant-a]", svc.tenants)
	}
}

// A write failure is returned so the consumer retries, rather than leaving the
// tasks behind because the database was briefly unavailable.
func TestAWriteFailureIsRetryable(t *testing.T) {
	svc := &retiringService{err: errors.New("database unavailable")}
	c := NewSatelliteConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), fieldDeleted("fld-1", "tenant-a")); err == nil {
		t.Error("a write failure was reported as a successful handle")
	}
}

// An event with no tenant is dropped, not retried: it can never succeed, and
// retrying forever blocks the partition. Guessing a tenant would touch another
// tenant's rows.
func TestAnEventWithoutATenantIsDroppedNotRetried(t *testing.T) {
	svc := &retiringService{}
	c := NewSatelliteConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), fieldDeleted("fld-1", "")); err != nil {
		t.Errorf("a tenantless event was retried: %v", err)
	}
	if len(svc.fields) != 0 {
		t.Errorf("a tenantless event still retired tasks for %v", svc.fields)
	}
}

// Replaying is safe: the second pass finds nothing outstanding and says so
// rather than failing.
func TestReplayingTheEventIsSafe(t *testing.T) {
	svc := &retiringService{retired: 0}
	c := NewSatelliteConsumer(svc, testutil.NopLogger{})

	for i := 0; i < 2; i++ {
		if err := c.HandleEvent(context.Background(), fieldDeleted("fld-1", "tenant-a")); err != nil {
			t.Fatalf("pass %d: %v", i+1, err)
		}
	}
}

// A farm deletion does nothing here on purpose. A satellite task carries a
// field_id and no farm_id, so "this farm's tasks" is not a query this service
// can express — and it does not need to, because field-service cascades a farm
// deletion into a delete per field and each one arrives as its own event.
//
// Asserted rather than left implicit: a future farm handler that fans out over
// field-service would be a round trip to rediscover events already on the way.
func TestFarmDeletedDoesNotFanOut(t *testing.T) {
	svc := &retiringService{}
	c := NewSatelliteConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), farmDeleted("fm-1", "tenant-a")); err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}
	if len(svc.fields) != 0 {
		t.Errorf("a farm deletion retired tasks for %v directly", svc.fields)
	}
}
