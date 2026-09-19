package events

import (
	"context"
	"errors"
	"testing"
	"time"

	eventsdomain "p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/testutil"

	"p9e.in/samavaya/agriculture/farm-service/internal/ports/inbound"
)

// forgetfulService records what the consumer asked farm-service to forget.
type forgetfulService struct {
	inbound.FarmService // nil: the consumer only calls ForgetDeletedField

	fields  []string
	tenants []string
	err     error
	removed int64
}

func (s *forgetfulService) ForgetDeletedField(ctx context.Context, fieldID string) (int64, error) {
	s.fields = append(s.fields, fieldID)
	s.tenants = append(s.tenants, p9context.TenantID(ctx))
	if s.err != nil {
		return 0, s.err
	}
	return s.removed, nil
}

func event(t eventsdomain.EventType, data map[string]any) *eventsdomain.DomainEvent {
	return &eventsdomain.DomainEvent{
		ID: "evt-1", Type: t, AggregateID: "agg-1", Timestamp: time.Now(), Data: data,
	}
}

func fieldDeleted(fieldID, tenantID string) *eventsdomain.DomainEvent {
	return event(eventsdomain.EventTypeFieldDeleted, map[string]any{
		"field_id": fieldID, "tenant_id": tenantID, "farm_id": "fm-1",
	})
}

// ---------------------------------------------------------------------------

// The one thing farm-service genuinely holds about a field is its membership
// of a management unit, and nothing dropped it.
//
// The handler used to log "field deleted from farm" and return nil. The
// junction row keys on a field_id belonging to another service, so it has no
// foreign key to cascade from and nothing else can reach it — the deleted
// field stayed a member of its unit for ever.
func TestFieldDeletedDropsUnitMemberships(t *testing.T) {
	svc := &forgetfulService{removed: 2}
	c := NewFarmConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), fieldDeleted("fld-1", "tenant-a")); err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}
	if len(svc.fields) != 1 || svc.fields[0] != "fld-1" {
		t.Errorf("dropped memberships for %v, want [fld-1]", svc.fields)
	}
}

// The consumer has no request to inherit a tenant from, so it must attach one.
// Without it the delete runs unscoped, RLS matches nothing, and the handler
// reports success over zero rows.
func TestTheDropRunsInTheEventsTenant(t *testing.T) {
	svc := &forgetfulService{}
	c := NewFarmConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), fieldDeleted("fld-1", "tenant-a")); err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}
	if len(svc.tenants) != 1 || svc.tenants[0] != "tenant-a" {
		t.Errorf("ran with tenants %v, want [tenant-a]", svc.tenants)
	}
}

// A write failure is returned so the consumer retries, rather than leaving a
// unit listing a field that no longer exists.
func TestAWriteFailureIsRetryable(t *testing.T) {
	svc := &forgetfulService{err: errors.New("database unavailable")}
	c := NewFarmConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), fieldDeleted("fld-1", "tenant-a")); err == nil {
		t.Error("a write failure was reported as a successful handle")
	}
}

// An event with no tenant is dropped, not retried: it can never succeed, and
// retrying forever blocks the partition. Guessing a tenant would touch another
// tenant's units.
func TestAnEventWithoutATenantIsDroppedNotRetried(t *testing.T) {
	svc := &forgetfulService{}
	c := NewFarmConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), fieldDeleted("fld-1", "")); err != nil {
		t.Errorf("a tenantless event was retried: %v", err)
	}
	if len(svc.fields) != 0 {
		t.Errorf("a tenantless event still touched %v", svc.fields)
	}
}

// Replaying is safe: the second pass finds no memberships and says so.
func TestReplayingTheEventIsSafe(t *testing.T) {
	svc := &forgetfulService{removed: 0}
	c := NewFarmConsumer(svc, testutil.NopLogger{})

	for i := 0; i < 2; i++ {
		if err := c.HandleEvent(context.Background(), fieldDeleted("fld-1", "tenant-a")); err != nil {
			t.Fatalf("pass %d: %v", i+1, err)
		}
	}
}

// Field creation and update write nothing, on purpose.
//
// The markers that used to sit here asked these to "update the farm aggregate
// (e.g. field count, total area)". There is no field count anywhere in this
// service, and
// total_area_hectares is the farmer's own declared area for the parcel —
// summing the fields into it would overwrite what they typed with a strictly
// smaller number, because fields do not cover tracks, buildings or margins.
//
// Asserted rather than left implicit, so that a future attempt to "finish"
// these handlers has to argue with a test first.
func TestFieldCreatedAndUpdatedWriteNothing(t *testing.T) {
	for _, evt := range []*eventsdomain.DomainEvent{
		event(eventsdomain.EventTypeFieldCreated, map[string]any{
			"field_id": "fld-1", "farm_id": "fm-1", "tenant_id": "tenant-a",
		}),
		event(eventsdomain.EventTypeFieldUpdated, map[string]any{
			"field_id": "fld-1", "farm_id": "fm-1", "tenant_id": "tenant-a",
		}),
	} {
		svc := &forgetfulService{}
		if err := NewFarmConsumer(svc, testutil.NopLogger{}).HandleEvent(context.Background(), evt); err != nil {
			t.Fatalf("%s: %v", evt.Type, err)
		}
		if len(svc.fields) != 0 {
			t.Errorf("%s wrote to the farm aggregate", evt.Type)
		}
	}
}
