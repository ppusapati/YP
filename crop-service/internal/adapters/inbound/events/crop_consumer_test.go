package events

import (
	"context"
	"testing"
	"time"

	eventsdomain "p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/testutil"

	"p9e.in/samavaya/agriculture/crop-service/internal/ports/inbound"
)

// recordingService fails loudly if the consumer calls anything. Every method
// on CropService is embedded as nil, so any call panics rather than quietly
// doing nothing — which is what makes the assertion below meaningful.
type recordingService struct {
	inbound.CropService
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

// A field deletion does nothing here on purpose.
//
// The marker that used to sit here asked this handler to "deactivate crop
// assignments linked to the deleted field". crop-service has no assignment
// table: its schema is crops, varieties, growth stages, requirements and
// recommendations — the catalogue of what a crop *is*. An assignment is a fact
// about a field, lives in
// field-service's `crop_assignments`, and is now deleted there in the same
// statement as the field.
//
// Asserted rather than left implicit, so that a future attempt to "finish"
// this handler by reaching across the service boundary has to argue with a
// test first.
func TestFieldDeletedDoesNotReachIntoFieldService(t *testing.T) {
	c := NewCropConsumer(&recordingService{}, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), fieldDeleted("fld-1", "tenant-a")); err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}
}

// A nil event is reported rather than panicking the consumer goroutine.
func TestANilEventIsReported(t *testing.T) {
	c := NewCropConsumer(&recordingService{}, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), nil); err == nil {
		t.Error("a nil event was accepted")
	}
}
