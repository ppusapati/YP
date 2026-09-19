package events

import (
	"context"
	"errors"
	"testing"
	"time"

	eventsdomain "p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/testutil"

	"p9e.in/samavaya/agriculture/soil-service/internal/ports/inbound"
)

// archivingService records what the consumer asked to archive.
type archivingService struct {
	inbound.SoilService // nil: the consumer only calls ArchiveFieldSoilData

	fields   []string
	tenants  []string
	err      error
	archived int64
}

func (s *archivingService) ArchiveFieldSoilData(ctx context.Context, fieldID string) (int64, error) {
	s.fields = append(s.fields, fieldID)
	s.tenants = append(s.tenants, p9context.TenantID(ctx))
	if s.err != nil {
		return 0, s.err
	}
	return s.archived, nil
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

// The point of the handler: a deleted field's soil records stop appearing.
//
// It used to log "field deleted, archiving soil data" and return nil, having
// archived nothing, so a farm-level soil listing kept returning samples and
// health scores attributed to a field nobody could open.
func TestFieldDeletedArchivesItsSoilData(t *testing.T) {
	svc := &archivingService{archived: 7}
	c := NewSoilConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), fieldDeleted("fld-1", "tenant-a")); err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}
	if len(svc.fields) != 1 || svc.fields[0] != "fld-1" {
		t.Errorf("archived soil data for %v, want [fld-1]", svc.fields)
	}
}

// The consumer has no request to inherit a tenant from, so it must attach one.
func TestTheArchiveRunsInTheEventsTenant(t *testing.T) {
	svc := &archivingService{}
	c := NewSoilConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), fieldDeleted("fld-1", "tenant-a")); err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}
	if len(svc.tenants) != 1 || svc.tenants[0] != "tenant-a" {
		t.Errorf("archived with tenants %v, want [tenant-a]", svc.tenants)
	}
}

// A write failure is returned so the consumer retries, rather than leaving a
// deleted field's soil data live in a farm listing.
func TestAWriteFailureIsRetryable(t *testing.T) {
	svc := &archivingService{err: errors.New("database unavailable")}
	c := NewSoilConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), fieldDeleted("fld-1", "tenant-a")); err == nil {
		t.Error("a write failure was reported as a successful handle")
	}
}

// An event with no tenant is dropped, not retried: it can never succeed, and
// guessing a tenant would archive another tenant's soil records.
func TestAnEventWithoutATenantIsDroppedNotRetried(t *testing.T) {
	svc := &archivingService{}
	c := NewSoilConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), fieldDeleted("fld-1", "")); err != nil {
		t.Errorf("a tenantless event was retried: %v", err)
	}
	if len(svc.fields) != 0 {
		t.Errorf("a tenantless event still archived %v", svc.fields)
	}
}

// Replaying is safe: the second pass finds nothing active and says so.
func TestReplayingTheEventIsSafe(t *testing.T) {
	svc := &archivingService{archived: 0}
	c := NewSoilConsumer(svc, testutil.NopLogger{})

	for i := 0; i < 2; i++ {
		if err := c.HandleEvent(context.Background(), fieldDeleted("fld-1", "tenant-a")); err != nil {
			t.Fatalf("pass %d: %v", i+1, err)
		}
	}
}
