package events

import (
	"context"
	"errors"
	"strings"
	"testing"
	"time"

	eventsdomain "p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/testutil"

	tracedomain "p9e.in/samavaya/agriculture/traceability-service/internal/domain"
	"p9e.in/samavaya/agriculture/traceability-service/internal/ports/inbound"
)

// recordingService captures what the consumer would create, plus the tenant
// the call was scoped to — which is the part that silently produces nothing
// when it is missing.
type recordingService struct {
	inbound.TraceabilityService // nil: the consumer only calls CreateRecord

	created []tracedomain.CreateRecordInput
	tenants []string
	err     error
}

func (s *recordingService) CreateRecord(ctx context.Context, in tracedomain.CreateRecordInput) (*tracedomain.TraceabilityRecord, error) {
	if s.err != nil {
		return nil, s.err
	}
	s.created = append(s.created, in)
	s.tenants = append(s.tenants, p9context.TenantID(ctx))
	rec := &tracedomain.TraceabilityRecord{}
	rec.ID = "trace-1"
	return rec, nil
}

func newConsumer() (*TraceabilityConsumer, *recordingService) {
	svc := &recordingService{}
	return NewTraceabilityConsumer(svc, testutil.NopLogger{}), svc
}

func harvestEvent(data map[string]interface{}) *eventsdomain.DomainEvent {
	return &eventsdomain.DomainEvent{
		ID:          "evt-1",
		Type:        yieldRecordCreated,
		AggregateID: "yr-1",
		Timestamp:   time.Date(2026, 3, 15, 6, 0, 0, 0, time.UTC),
		Data:        data,
	}
}

func fullHarvest() map[string]interface{} {
	return map[string]interface{}{
		"record_id":      "yr-1",
		"tenant_id":      "t-1",
		"farm_id":        "fm-1",
		"field_id":       "f-1",
		"crop_id":        "c-1",
		"season":         "kharif",
		"quality_grade":  "A",
		"total_yield_kg": 42000.0,
		"harvest_date":   "2026-03-14T00:00:00Z",
	}
}

func TestAHarvestOpensATraceabilityRecord(t *testing.T) {
	// This handler used to log "creating traceability record for harvest" and
	// return nil, having created nothing. Kafka committed the offset and the
	// harvest was gone — leaving a gap at the one link a chain of custody
	// exists to provide.
	c, svc := newConsumer()
	if err := c.HandleEvent(context.Background(), harvestEvent(fullHarvest())); err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}

	if len(svc.created) != 1 {
		t.Fatalf("created %d records, want 1", len(svc.created))
	}
	got := svc.created[0]
	if got.FieldID != "f-1" || got.FarmID != "fm-1" || got.CropID != "c-1" {
		t.Errorf("record does not identify the harvest: %+v", got)
	}
	if got.HarvestDate == nil {
		t.Error("the harvest date was dropped")
	}
	if got.Metadata["yield_record_id"] != "yr-1" {
		t.Errorf("metadata %v does not link back to the yield record", got.Metadata)
	}
	// Without a tenant on the context every query runs unscoped and row-level
	// security returns nothing, which looks like success with no data.
	if svc.tenants[0] != "t-1" {
		t.Errorf("scoped to tenant %q, want t-1", svc.tenants[0])
	}
}

func TestTheEventTypeYieldServiceActuallyPublishesIsHandled(t *testing.T) {
	// The consumer listened only for "agriculture.yield.created", which
	// yield-service has never emitted — it publishes
	// "agriculture.yield.record.created" — so the branch would not have fired
	// even once the handler did something.
	c, svc := newConsumer()
	e := harvestEvent(fullHarvest())
	e.Type = "agriculture.yield.record.created"

	if err := c.HandleEvent(context.Background(), e); err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}
	if len(svc.created) != 1 {
		t.Errorf("the event yield-service actually publishes was ignored")
	}
}

func TestTheBatchNumberIsStableAcrossReplays(t *testing.T) {
	// Kafka delivery is at-least-once. A generated batch number would open a
	// second chain of custody for one harvest on every redelivery.
	c, svc := newConsumer()
	e := harvestEvent(fullHarvest())
	for i := 0; i < 3; i++ {
		if err := c.HandleEvent(context.Background(), e); err != nil {
			t.Fatalf("HandleEvent: %v", err)
		}
	}
	if len(svc.created) != 3 {
		t.Fatalf("got %d calls, want 3", len(svc.created))
	}
	first := svc.created[0].BatchNumber
	if first == "" {
		t.Fatal("no batch number was derived")
	}
	for i, in := range svc.created {
		if in.BatchNumber != first {
			t.Errorf("call %d produced batch %q, want the stable %q", i, in.BatchNumber, first)
		}
	}
	if !strings.Contains(first, "yr-1") {
		t.Errorf("batch %q is not derived from the yield record id", first)
	}
}

func TestAHarvestWithoutATenantIsDroppedNotRetried(t *testing.T) {
	// There is nothing to attribute it to, and a message that can never
	// succeed would block the partition for every harvest behind it.
	c, svc := newConsumer()
	data := fullHarvest()
	delete(data, "tenant_id")

	if err := c.HandleEvent(context.Background(), harvestEvent(data)); err != nil {
		t.Fatalf("HandleEvent returned %v; this must not be retried forever", err)
	}
	if len(svc.created) != 0 {
		t.Error("a record was created with no tenant")
	}
}

func TestAHarvestWithoutAFieldIsDropped(t *testing.T) {
	c, svc := newConsumer()
	data := fullHarvest()
	delete(data, "field_id")

	if err := c.HandleEvent(context.Background(), harvestEvent(data)); err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}
	if len(svc.created) != 0 {
		t.Error("a record was created with no field")
	}
}

func TestAStorageFailureIsRetried(t *testing.T) {
	// The opposite case: a database briefly unavailable must not lose the
	// harvest, so this one does come back as an error.
	c, svc := newConsumer()
	svc.err = errors.New("connection refused")

	if err := c.HandleEvent(context.Background(), harvestEvent(fullHarvest())); err == nil {
		t.Error("a storage failure was swallowed; the harvest would be lost")
	}
}

func TestWronglyTypedFieldsDoNotPanic(t *testing.T) {
	// The payload is JSON from another service. A type assertion that panics
	// takes the consumer down and stops the partition, which is far worse
	// than one badly-formed record.
	c, _ := newConsumer()
	err := c.HandleEvent(context.Background(), harvestEvent(map[string]interface{}{
		"record_id": 12345, "tenant_id": "t-1", "field_id": "f-1",
		"harvest_date": 99, "season": []string{"kharif"},
	}))
	if err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}
}

func TestABadHarvestDateDoesNotBlockTheRecord(t *testing.T) {
	// The date is useful but not essential; losing the whole chain-of-custody
	// link over an unparseable timestamp would be the wrong trade.
	c, svc := newConsumer()
	data := fullHarvest()
	data["harvest_date"] = "the fourteenth"

	if err := c.HandleEvent(context.Background(), harvestEvent(data)); err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}
	if len(svc.created) != 1 {
		t.Fatal("an unparseable date prevented the record")
	}
	if svc.created[0].HarvestDate != nil {
		t.Error("an unparseable date was stored as a time")
	}
}
