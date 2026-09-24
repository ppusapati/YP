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

// recordingService captures what the consumer would write, plus the tenant the
// call was scoped to — which is the part that silently produces nothing when it
// is missing.
type recordingService struct {
	inbound.TraceabilityService // nil: only the methods below are reached

	created  []tracedomain.CreateRecordInput
	updated  []tracedomain.UpdateRecordInput
	events   []tracedomain.AddSupplyChainEventInput
	tenants  []string
	openFor  map[string]*tracedomain.TraceabilityRecord // field id → open record
	byBatch  map[string]*tracedomain.TraceabilityRecord
	err      error
	eventErr error
}

func (s *recordingService) CreateRecord(ctx context.Context, in tracedomain.CreateRecordInput) (*tracedomain.TraceabilityRecord, error) {
	if s.err != nil {
		return nil, s.err
	}
	s.created = append(s.created, in)
	s.tenants = append(s.tenants, p9context.TenantID(ctx))
	rec := &tracedomain.TraceabilityRecord{}
	rec.ID = "trace-1"
	rec.BatchNumber = in.BatchNumber
	return rec, nil
}

func (s *recordingService) UpdateRecord(ctx context.Context, _ string, in tracedomain.UpdateRecordInput) (*tracedomain.TraceabilityRecord, error) {
	if s.err != nil {
		return nil, s.err
	}
	s.updated = append(s.updated, in)
	s.tenants = append(s.tenants, p9context.TenantID(ctx))
	return &tracedomain.TraceabilityRecord{ID: "trace-1"}, nil
}

func (s *recordingService) AddSupplyChainEvent(ctx context.Context, in tracedomain.AddSupplyChainEventInput) (*tracedomain.SupplyChainEvent, error) {
	if s.eventErr != nil {
		return nil, s.eventErr
	}
	s.events = append(s.events, in)
	s.tenants = append(s.tenants, p9context.TenantID(ctx))
	return &tracedomain.SupplyChainEvent{ID: "sce-1", RecordID: in.RecordID}, nil
}

func (s *recordingService) FindOpenRecordForField(_ context.Context, fieldID string) (*tracedomain.TraceabilityRecord, error) {
	if s.err != nil {
		return nil, s.err
	}
	return s.openFor[fieldID], nil
}

func (s *recordingService) FindRecordByBatch(_ context.Context, batch string) (*tracedomain.TraceabilityRecord, error) {
	if s.err != nil {
		return nil, s.err
	}
	return s.byBatch[batch], nil
}

// kinds lists the supply chain event types recorded, in order.
func (s *recordingService) kinds() []tracedomain.SupplyChainEventType {
	out := make([]tracedomain.SupplyChainEventType, 0, len(s.events))
	for _, e := range s.events {
		out = append(out, e.EventType)
	}
	return out
}

func newConsumer() (*TraceabilityConsumer, *recordingService) {
	svc := &recordingService{
		openFor: map[string]*tracedomain.TraceabilityRecord{},
		byBatch: map[string]*tracedomain.TraceabilityRecord{},
	}
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
	//
	// It does not become nil either, which is what this used to do. harvest_date
	// IS NULL is what marks a batch open, so a record closed without one stays
	// open forever and the next irrigation on that field attaches to a batch
	// already in a crate. The event's own timestamp stands in — a real fact,
	// the moment the harvest was reported — and the metadata says so rather
	// than passing it off as the farmer's figure.
	c, svc := newConsumer()
	data := fullHarvest()
	data["harvest_date"] = "the fourteenth"

	if err := c.HandleEvent(context.Background(), harvestEvent(data)); err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}
	if len(svc.created) != 1 {
		t.Fatal("an unparseable date prevented the record")
	}
	got := svc.created[0]
	if got.HarvestDate == nil {
		t.Fatal("the batch was left open with no harvest date")
	}
	if !got.HarvestDate.Equal(time.Date(2026, 3, 15, 6, 0, 0, 0, time.UTC)) {
		t.Errorf("harvest date %v, want the event timestamp", got.HarvestDate)
	}
	if got.Metadata["harvest_date_source"] != "event-timestamp" {
		t.Errorf("metadata %v does not disclose that the date was substituted", got.Metadata)
	}
}

// ── The chain, from planting to harvest ─────────────────────────────────────

func plantingEvent(data map[string]interface{}) *eventsdomain.DomainEvent {
	return &eventsdomain.DomainEvent{
		ID:          "evt-plant",
		Type:        eventsdomain.EventTypeFieldCropAssigned,
		AggregateID: "f-1",
		Timestamp:   time.Date(2025, 11, 2, 7, 0, 0, 0, time.UTC),
		Data:        data,
	}
}

func fullPlanting() map[string]interface{} {
	return map[string]interface{}{
		"tenant_id":     "t-1",
		"farm_id":       "fm-1",
		"field_id":      "f-1",
		"crop_id":       "c-1",
		"planting_date": "2025-11-01T00:00:00Z",
		"season":        "rabi",
	}
}

func TestPlantingOpensTheChainOfCustody(t *testing.T) {
	// This handler used to log "crop assigned to field, recording in
	// traceability" and record nothing, so the chain did not start until
	// harvest. A traceability service whose chain starts at harvest can say
	// where a crate came from but not how it was grown — which is exactly the
	// claim an organic or GAP certification rests on.
	c, svc := newConsumer()
	if err := c.HandleEvent(context.Background(), plantingEvent(fullPlanting())); err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}

	if len(svc.created) != 1 {
		t.Fatalf("created %d records, want 1", len(svc.created))
	}
	rec := svc.created[0]
	if rec.FieldID != "f-1" || rec.CropID != "c-1" || rec.FarmID != "fm-1" {
		t.Errorf("record does not identify the planting: %+v", rec)
	}
	if rec.PlantingDate == nil || !rec.PlantingDate.Equal(time.Date(2025, 11, 1, 0, 0, 0, 0, time.UTC)) {
		t.Errorf("planting date %v", rec.PlantingDate)
	}
	if rec.HarvestDate != nil {
		t.Error("a freshly planted batch was opened already harvested")
	}

	// And the PLANTED link exists, not just the record.
	if kinds := svc.kinds(); len(kinds) != 1 || kinds[0] != tracedomain.SupplyChainEventTypePlanted {
		t.Errorf("supply chain events %v, want one PLANTED", kinds)
	}
	if svc.tenants[0] != "t-1" {
		t.Errorf("scoped to tenant %q, want t-1", svc.tenants[0])
	}
}

func TestAReplayedPlantingDoesNotOpenASecondBatch(t *testing.T) {
	// Kafka delivery is at-least-once. Two records for one planting is two
	// chains of custody for one crop, and no way to tell which is the real one.
	c, svc := newConsumer()
	e := plantingEvent(fullPlanting())

	if err := c.HandleEvent(context.Background(), e); err != nil {
		t.Fatalf("first delivery: %v", err)
	}
	// The record now exists under its derived batch number.
	batch := svc.created[0].BatchNumber
	if batch == "" {
		t.Fatal("no batch number was derived")
	}
	svc.byBatch[batch] = &tracedomain.TraceabilityRecord{ID: "trace-1", BatchNumber: batch}

	if err := c.HandleEvent(context.Background(), e); err != nil {
		t.Fatalf("redelivery: %v", err)
	}
	if len(svc.created) != 1 {
		t.Errorf("created %d records for one planting", len(svc.created))
	}
}

// triggeredRun is the payload irrigation-service publishes when a schedule
// fires, with the types it publishes: the quantity as a number, not a quoted
// string.
//
// This used to be written inline with a `field_id` and a `water_amount_liters`
// that the producer did not send, which is why the handler passed its test and
// recorded nothing in production. It is pinned from the other side too, in
// irrigation-service's irrigation_event_payload_test.go.
func triggeredRun() map[string]interface{} {
	return map[string]interface{}{
		"event_id":                 "run-9",
		"schedule_id":              "sched-1",
		"tenant_id":                "t-1",
		"zone_id":                  "zone-1",
		"field_id":                 "f-1",
		"farm_id":                  "farm-1",
		"started_at":               "2026-01-08T05:00:00Z",
		"planned_water_liters":     12000.0,
		"planned_duration_minutes": 30.0,
	}
}

func TestIrrigationAttachesToTheBatchGrowingInThatField(t *testing.T) {
	// "Recording for compliance" while recording nothing was the worst possible
	// version of this handler: water application is one of the inputs an
	// organic or GAP audit asks about.
	c, svc := newConsumer()
	svc.openFor["f-1"] = &tracedomain.TraceabilityRecord{ID: "trace-1", BatchNumber: "BATCH-f-1"}

	err := c.HandleEvent(context.Background(), &eventsdomain.DomainEvent{
		ID:        "evt-irr",
		Type:      eventsdomain.EventTypeIrrigationTriggered,
		Timestamp: time.Date(2026, 1, 8, 5, 30, 0, 0, time.UTC),
		Data:      triggeredRun(),
	})
	if err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}

	if len(svc.events) != 1 {
		t.Fatalf("recorded %d supply chain events, want 1", len(svc.events))
	}
	got := svc.events[0]
	if got.EventType != tracedomain.SupplyChainEventTypeIrrigated {
		t.Errorf("event type %q, want IRRIGATED", got.EventType)
	}
	if got.RecordID != "trace-1" {
		t.Errorf("attached to record %q, want the open batch", got.RecordID)
	}
	if !strings.Contains(got.Details, "run-9") || !strings.Contains(got.Details, "12000") {
		t.Errorf("details %q lose the irrigation", got.Details)
	}
	// The run started at 05:00; the event reached Kafka at 05:30. An audit
	// asks when water went on the field.
	if !got.Timestamp.Equal(time.Date(2026, 1, 8, 5, 0, 0, 0, time.UTC)) {
		t.Errorf("recorded at %v, want the run's start", got.Timestamp)
	}
}

// The quantity is a plan and is labelled as one.
//
// irrigation-service copies the schedule's figure into the run at start time
// and never revises it, so rendering it as applied would put a plan into an
// audit record as a measurement. An auditor reading "planned" knows to ask for
// the meter.
func TestAPlannedQuantityIsNotRecordedAsApplied(t *testing.T) {
	c, svc := newConsumer()
	svc.openFor["f-1"] = &tracedomain.TraceabilityRecord{ID: "trace-1"}

	if err := c.HandleEvent(context.Background(), &eventsdomain.DomainEvent{
		ID: "evt-irr", Type: eventsdomain.EventTypeIrrigationTriggered,
		Timestamp: time.Now(), Data: triggeredRun(),
	}); err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}

	details := svc.events[0].Details
	if !strings.Contains(details, "12000 L planned") {
		t.Errorf("details %q do not say the quantity is a plan", details)
	}
	if strings.Contains(details, "applied") {
		t.Errorf("details %q report a plan as a measurement", details)
	}
}

// A measured figure wins when a producer sends one, so that metering this path
// later needs no change here.
func TestAMeasuredQuantityIsPreferred(t *testing.T) {
	c, svc := newConsumer()
	svc.openFor["f-1"] = &tracedomain.TraceabilityRecord{ID: "trace-1"}

	data := triggeredRun()
	data["water_amount_liters"] = 11480.0

	if err := c.HandleEvent(context.Background(), &eventsdomain.DomainEvent{
		ID: "evt-irr", Type: eventsdomain.EventTypeIrrigationTriggered,
		Timestamp: time.Now(), Data: data,
	}); err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}

	details := svc.events[0].Details
	if !strings.Contains(details, "11480 L applied") {
		t.Errorf("details %q ignore the measured figure", details)
	}
	if strings.Contains(details, "planned") {
		t.Errorf("details %q report the plan alongside the measurement", details)
	}
}

// Creating an Irrigation record is master data, not a water application.
//
// The domain type behind `agriculture.irrigation.created` is a named plan with
// a status — no field, no zone, no water — so this consumer listening for it
// meant dropping every message at the field_id guard while appearing wired.
func TestCreatingAnIrrigationRecordIsNotAWaterApplication(t *testing.T) {
	c, svc := newConsumer()
	svc.openFor["f-1"] = &tracedomain.TraceabilityRecord{ID: "trace-1"}

	if err := c.HandleEvent(context.Background(), &eventsdomain.DomainEvent{
		ID: "evt-irr", Type: eventsdomain.EventTypeIrrigationCreated,
		Timestamp: time.Now(),
		Data:      map[string]interface{}{"tenant_id": "t-1", "irrigation_id": "irr-9"},
	}); err != nil {
		t.Fatalf("HandleEvent returned %v", err)
	}
	if len(svc.events) != 0 {
		t.Errorf("an irrigation plan was recorded as water on a field: %+v", svc.events)
	}
}

func TestIrrigatingAFallowFieldIsNotAnError(t *testing.T) {
	// It happens, and there is no batch it belongs to. Not a failure to retry
	// and not something to attach to whatever record is nearest.
	c, svc := newConsumer() // no open record for f-1

	err := c.HandleEvent(context.Background(), &eventsdomain.DomainEvent{
		ID: "evt-irr", Type: eventsdomain.EventTypeIrrigationTriggered,
		Timestamp: time.Now(),
		Data:      triggeredRun(),
	})
	if err != nil {
		t.Fatalf("HandleEvent returned %v; this must not block the partition", err)
	}
	if len(svc.events) != 0 {
		t.Errorf("an irrigation was attached to a batch that does not exist: %+v", svc.events)
	}
}

// A run with no field is declined rather than attached to a guess.
func TestARunWithNoFieldIsNotRecorded(t *testing.T) {
	c, svc := newConsumer()
	svc.openFor["f-1"] = &tracedomain.TraceabilityRecord{ID: "trace-1"}

	data := triggeredRun()
	data["field_id"] = ""

	if err := c.HandleEvent(context.Background(), &eventsdomain.DomainEvent{
		ID: "evt-irr", Type: eventsdomain.EventTypeIrrigationTriggered,
		Timestamp: time.Now(), Data: data,
	}); err != nil {
		t.Fatalf("HandleEvent returned %v; this must not block the partition", err)
	}
	if len(svc.events) != 0 {
		t.Errorf("a run with no field was recorded against a batch: %+v", svc.events)
	}
}

func TestAHarvestClosesTheBatchItBelongsTo(t *testing.T) {
	// The whole point of opening at planting. Creating a second record here
	// would leave one covering the growing season with no harvest and another
	// covering the harvest with no history — two halves of a chain of custody
	// and no chain.
	c, svc := newConsumer()
	svc.openFor["f-1"] = &tracedomain.TraceabilityRecord{ID: "trace-1", BatchNumber: "BATCH-f-1-c-1-20251101"}

	if err := c.HandleEvent(context.Background(), harvestEvent(fullHarvest())); err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}

	if len(svc.created) != 0 {
		t.Errorf("a second record was opened for a harvest that closes an existing batch: %+v", svc.created)
	}
	if len(svc.updated) != 1 {
		t.Fatalf("updated %d records, want 1", len(svc.updated))
	}
	if svc.updated[0].HarvestDate == nil {
		t.Error("the batch was not closed: no harvest date was written")
	}
	if kinds := svc.kinds(); len(kinds) != 1 || kinds[0] != tracedomain.SupplyChainEventTypeHarvested {
		t.Errorf("supply chain events %v, want one HARVESTED", kinds)
	}
}

func TestAReplayedHarvestDoesNotReopenOrDoubleStampTheBatch(t *testing.T) {
	// A redelivery must not move the harvest date or append a second HARVESTED
	// link to the same batch.
	closed := time.Date(2026, 3, 14, 0, 0, 0, 0, time.UTC)
	c, svc := newConsumer()
	svc.openFor["f-1"] = &tracedomain.TraceabilityRecord{
		ID: "trace-1", BatchNumber: "BATCH-f-1", HarvestDate: &closed,
	}

	if err := c.HandleEvent(context.Background(), harvestEvent(fullHarvest())); err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}
	if len(svc.updated) != 0 || len(svc.events) != 0 {
		t.Errorf("an already-harvested batch was written to again: %d updates, %d events",
			len(svc.updated), len(svc.events))
	}
}

func TestAHarvestWithNoRecordedPlantingStillGetsARecord(t *testing.T) {
	// Less useful than a full chain — where the crate came from, but not how it
	// was grown — and much better than losing the harvest.
	c, svc := newConsumer() // nothing open for f-1

	if err := c.HandleEvent(context.Background(), harvestEvent(fullHarvest())); err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}
	if len(svc.created) != 1 {
		t.Fatalf("created %d records, want 1", len(svc.created))
	}
	if kinds := svc.kinds(); len(kinds) != 1 || kinds[0] != tracedomain.SupplyChainEventTypeHarvested {
		t.Errorf("supply chain events %v, want one HARVESTED", kinds)
	}
}

func TestMasterDataEventsAreNotWrittenIntoAnyChain(t *testing.T) {
	// A farm being renamed or a crop *type* being registered belongs to no
	// batch. The TODOs that used to sit in these handlers asked for a supply
	// chain event with nothing to hang it from.
	c, svc := newConsumer()

	for _, e := range []*eventsdomain.DomainEvent{
		{ID: "e1", Type: eventsdomain.EventTypeFarmCreated, Data: map[string]interface{}{"farm_id": "fm-1"}},
		{ID: "e2", Type: eventsdomain.EventTypeFarmUpdated, Data: map[string]interface{}{"farm_id": "fm-1"}},
		{ID: "e3", Type: eventsdomain.EventTypeFieldCreated, Data: map[string]interface{}{"field_id": "f-1"}},
		{ID: "e4", Type: eventsdomain.EventTypeCropCreated, Data: map[string]interface{}{"crop_id": "c-1"}},
	} {
		if err := c.HandleEvent(context.Background(), e); err != nil {
			t.Fatalf("%s: %v", e.Type, err)
		}
	}

	if len(svc.created) != 0 || len(svc.events) != 0 {
		t.Errorf("master data was written into a chain: %d records, %d events",
			len(svc.created), len(svc.events))
	}
}
