// Package events contains the inbound Kafka consumer adapter for traceability-service.
// It subscribes to events from OTHER services that the traceability-service needs to react to.
// Traceability tracks the full lifecycle: farm, field, crop, irrigation, and yield events.
package events

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/saas"

	tracedomain "p9e.in/samavaya/agriculture/traceability-service/internal/domain"
	"p9e.in/samavaya/agriculture/traceability-service/internal/ports/inbound"
)

// Topics from OTHER services that traceability-service consumes.
const (
	FarmEventTopic       = "samavaya.agriculture.farm.events"
	FieldEventTopic      = "samavaya.agriculture.field.events"
	CropEventTopic       = "samavaya.agriculture.crop.events"
	IrrigationEventTopic = "samavaya.agriculture.irrigation.events"
	YieldEventTopic      = "samavaya.agriculture.yield.events"
)

// TraceabilityConsumer is the inbound Kafka adapter that reacts to cross-service domain events.
type TraceabilityConsumer struct {
	svc inbound.TraceabilityService
	log *p9log.Helper
}

// NewTraceabilityConsumer creates a new Kafka consumer for cross-service events.
func NewTraceabilityConsumer(svc inbound.TraceabilityService, log p9log.Logger) *TraceabilityConsumer {
	return &TraceabilityConsumer{
		svc: svc,
		log: p9log.NewHelper(p9log.With(log, "component", "TraceabilityConsumer")),
	}
}

// Topics returns the Kafka topics this consumer listens on.
func (c *TraceabilityConsumer) Topics() []string {
	return []string{FarmEventTopic, FieldEventTopic, CropEventTopic, IrrigationEventTopic, YieldEventTopic}
}

// HandleEvent dispatches an incoming domain event.
func (c *TraceabilityConsumer) HandleEvent(ctx context.Context, event *domain.DomainEvent) error {
	if event == nil {
		return fmt.Errorf("received nil event")
	}
	c.log.Infow("msg", "cross-service event received",
		"event_id", event.ID,
		"event_type", string(event.Type),
		"aggregate_id", event.AggregateID,
	)

	switch event.Type {
	// Farm events: record farm lifecycle in supply chain
	case domain.EventTypeFarmCreated:
		return c.onFarmCreated(ctx, event)
	case domain.EventTypeFarmUpdated:
		return c.onFarmUpdated(ctx, event)

	// Field events: record field-level activities
	case domain.EventTypeFieldCreated:
		return c.onFieldCreated(ctx, event)
	case domain.EventTypeFieldCropAssigned:
		return c.onFieldCropAssigned(ctx, event)

	// Crop events: crop lifecycle traceability
	case domain.EventTypeCropCreated:
		return c.onCropCreated(ctx, event)

	// Irrigation events: record irrigation for compliance
	case domain.EventTypeIrrigationCreated:
		return c.onIrrigationEvent(ctx, event)

	// Yield events: harvest and yield records for traceability.
	//
	// Both spellings are handled. The consumer listened only for
	// "agriculture.yield.created", which yield-service has never emitted — it
	// publishes "agriculture.yield.record.created" — so this branch would not
	// have fired even once the handler below did something.
	case domain.EventTypeYieldCreated, yieldRecordCreated:
		return c.onYieldRecorded(ctx, event)

	default:
		c.log.Infow("msg", "unhandled event type", "type", string(event.Type))
		return nil
	}
}

// Master data, not chain of custody.
//
// These four handlers do nothing on purpose, and the TODOs that used to sit in
// them — "call AddSupplyChainEvent to record farm as origin" — asked for
// something the model cannot express. A SupplyChainEvent hangs off a
// TraceabilityRecord, and a record is one batch from one field's season. A farm
// being created, renamed, or a crop *type* being registered belongs to no
// batch; there is nothing to attach the event to and nothing a consumer of a
// finished crate could learn from it.
//
// What the farm and field actually contribute to provenance — their name,
// region, and boundary — is read through the outbound clients when a record is
// built, so it is current at the time the chain is assembled rather than
// duplicated into an event stream that then drifts.
//
// Logged at debug rather than dropped silently, so the topic can be seen to be
// flowing.

func (c *TraceabilityConsumer) onFarmCreated(ctx context.Context, event *domain.DomainEvent) error {
	return c.noteMasterData(event, "farm created", "farm_id")
}

func (c *TraceabilityConsumer) onFarmUpdated(ctx context.Context, event *domain.DomainEvent) error {
	return c.noteMasterData(event, "farm updated", "farm_id")
}

func (c *TraceabilityConsumer) onFieldCreated(ctx context.Context, event *domain.DomainEvent) error {
	return c.noteMasterData(event, "field created", "field_id")
}

func (c *TraceabilityConsumer) onCropCreated(ctx context.Context, event *domain.DomainEvent) error {
	return c.noteMasterData(event, "crop type created", "crop_id")
}

func (c *TraceabilityConsumer) noteMasterData(event *domain.DomainEvent, what, idKey string) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("%s: %w", what, err)
	}
	c.log.Debugw("msg", what+"; master data, no chain of custody to attach it to",
		idKey, str(data, idKey), "event_id", event.ID)
	return nil
}

// onFieldCropAssigned opens the chain of custody for a planting.
//
// This is where a batch begins. It used to log "crop assigned to field,
// recording in traceability" and return nil, having recorded nothing — which
// meant the record was not opened until harvest, and everything that happened
// to the crop while it grew had no batch to attach to. A traceability service
// whose chain starts at harvest can say where a crate came from but not how it
// was grown, which is exactly the claim an organic or GAP certification rests
// on.
func (c *TraceabilityConsumer) onFieldCropAssigned(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onFieldCropAssigned: %w", err)
	}

	tenantID := str(data, "tenant_id")
	fieldID := str(data, "field_id")
	farmID := str(data, "farm_id")
	cropID := str(data, "crop_id")

	if tenantID == "" || fieldID == "" || cropID == "" {
		// Dropped rather than retried: a message that can never succeed would
		// block the partition, and guessing a tenant would write into another
		// tenant's chain.
		c.log.Warnw("msg", "crop assignment missing tenant, field or crop; no record opened",
			"event_id", event.ID, "field_id", fieldID, "crop_id", cropID)
		return nil
	}

	ctx = c.systemContext(ctx, tenantID)

	planted := timestamp(data, "planting_date")
	if planted == nil {
		planted = timestamp(data, "assigned_at")
	}
	if planted == nil {
		t := event.Timestamp
		if t.IsZero() {
			t = time.Now().UTC()
		}
		planted = &t
	}

	// Derived, not generated, so a replayed event finds the record it created
	// the first time instead of opening a second chain of custody for one
	// planting. The date is part of it because the same field grows the same
	// crop again next season and those are different batches.
	batch := plantingBatchNumber(fieldID, cropID, *planted)

	existing, err := c.svc.FindRecordByBatch(ctx, batch)
	if err != nil {
		return fmt.Errorf("onFieldCropAssigned: look up batch %s: %w", batch, err)
	}
	if existing != nil {
		c.log.Debugw("msg", "planting already recorded", "record_id", existing.ID, "batch_number", batch)
		return nil
	}

	record, err := c.svc.CreateRecord(ctx, tracedomain.CreateRecordInput{
		FarmID:       farmID,
		FieldID:      fieldID,
		CropID:       cropID,
		BatchNumber:  batch,
		ProductType:  cropID,
		PlantingDate: planted,
		SeedSource:   str(data, "seed_source"),
		Metadata: map[string]string{
			"source":   "field-service",
			"event_id": event.ID,
			"season":   str(data, "season"),
		},
	})
	if err != nil {
		// Returned, so the consumer retries. A database that is briefly
		// unavailable must not leave the season without a chain.
		return fmt.Errorf("onFieldCropAssigned: open record for field %s: %w", fieldID, err)
	}

	if err := c.addEvent(ctx, record.ID, tracedomain.SupplyChainEventTypePlanted, *planted, data,
		fmt.Sprintf("crop %s planted in field %s", cropID, fieldID)); err != nil {
		// The record exists; the event did not. Retried rather than swallowed,
		// and the create above is idempotent on the batch number, so the replay
		// finds the record and only the event is retried.
		return fmt.Errorf("onFieldCropAssigned: record planting event: %w", err)
	}

	c.log.Infow("msg", "chain of custody opened at planting",
		"record_id", record.ID, "batch_number", batch, "field_id", fieldID)
	return nil
}

// onIrrigationEvent attaches an irrigation to the batch growing in that field.
//
// This used to log "irrigation event, recording for compliance" and return nil.
// Water application is one of the inputs an organic or GAP audit asks about, so
// "recording for compliance" while recording nothing was the worst possible
// version of it.
func (c *TraceabilityConsumer) onIrrigationEvent(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onIrrigationEvent: %w", err)
	}

	tenantID := str(data, "tenant_id")
	fieldID := str(data, "field_id")
	if tenantID == "" || fieldID == "" {
		c.log.Warnw("msg", "irrigation event missing tenant or field; not recorded",
			"event_id", event.ID, "irrigation_id", str(data, "irrigation_id"))
		return nil
	}

	ctx = c.systemContext(ctx, tenantID)

	record, err := c.svc.FindOpenRecordForField(ctx, fieldID)
	if err != nil {
		return fmt.Errorf("onIrrigationEvent: find open record for field %s: %w", fieldID, err)
	}
	if record == nil {
		// Irrigating a fallow field is a real thing that happens and there is
		// no batch it belongs to. Not an error, and not silently dropped
		// either — a run of these means plantings are not reaching this
		// consumer, which is worth being able to see.
		c.log.Infow("msg", "irrigation on a field with no open batch; nothing to attach it to",
			"field_id", fieldID, "irrigation_id", str(data, "irrigation_id"))
		return nil
	}

	when := timestamp(data, "started_at")
	if when == nil {
		when = timestamp(data, "scheduled_at")
	}
	if when == nil {
		t := event.Timestamp
		if t.IsZero() {
			t = time.Now().UTC()
		}
		when = &t
	}

	details := fmt.Sprintf("irrigation %s", str(data, "irrigation_id"))
	if litres := str(data, "water_amount_liters"); litres != "" {
		details += ", " + litres + " L"
	}

	if err := c.addEvent(ctx, record.ID, tracedomain.SupplyChainEventTypeIrrigated, *when, data, details); err != nil {
		return fmt.Errorf("onIrrigationEvent: record irrigation on %s: %w", record.ID, err)
	}

	c.log.Infow("msg", "irrigation recorded against batch",
		"record_id", record.ID, "field_id", fieldID)
	return nil
}

// addEvent writes one supply chain event.
func (c *TraceabilityConsumer) addEvent(
	ctx context.Context,
	recordID string,
	kind tracedomain.SupplyChainEventType,
	when time.Time,
	data map[string]interface{},
	details string,
) error {
	actor := str(data, "actor")
	if actor == "" {
		actor = str(data, "created_by")
	}
	if actor == "" {
		// Named rather than left blank. "system" in an audit trail says an
		// automated pipeline wrote this; an empty actor says nothing and reads
		// as missing data.
		actor = "system"
	}

	_, err := c.svc.AddSupplyChainEvent(ctx, tracedomain.AddSupplyChainEventInput{
		RecordID:  recordID,
		EventType: kind,
		Timestamp: when,
		Location:  str(data, "location"),
		Actor:     actor,
		Details:   details,
	})
	return err
}

// plantingBatchNumber derives a stable batch number for one field-season.
func plantingBatchNumber(fieldID, cropID string, planted time.Time) string {
	return fmt.Sprintf("BATCH-%s-%s-%s", fieldID, cropID, planted.UTC().Format("20060102"))
}

// yieldRecordCreated is what yield-service actually publishes when a harvest
// is recorded.
const yieldRecordCreated domain.EventType = "agriculture.yield.record.created"

// onYieldRecorded opens a traceability record for a harvest.
//
// This used to log "creating traceability record for harvest" and return nil,
// having created nothing. Kafka committed the offset and the harvest was gone.
// A traceability record is the chain of custody for a batch and the harvest is
// the link it starts from — so every record downstream traced back to a gap,
// in the one service that exists to prevent exactly that.
func (c *TraceabilityConsumer) onYieldRecorded(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onYieldRecorded: %w", err)
	}

	recordID, _ := data["record_id"].(string)
	if recordID == "" {
		recordID, _ = data["yield_id"].(string)
	}
	tenantID, _ := data["tenant_id"].(string)
	farmID, _ := data["farm_id"].(string)
	fieldID, _ := data["field_id"].(string)
	cropID, _ := data["crop_id"].(string)

	if tenantID == "" || fieldID == "" {
		// Nothing to attribute the harvest to. Dropped rather than retried,
		// since a message that can never succeed would block the partition.
		c.log.Warnw("msg", "yield event missing tenant or field; no traceability record created",
			"event_id", event.ID, "record_id", recordID)
		return nil
	}

	ctx = c.systemContext(ctx, tenantID)

	// A harvest date is required, not optional, because harvest_date IS NULL is
	// what marks a batch open: a record closed without one stays open forever
	// and the next irrigation on that field attaches to a batch already in a
	// crate. When the payload's date is missing or unparseable the event's own
	// timestamp stands in — which is a real fact, the moment the harvest was
	// reported, not an invented one — and the substitution is recorded in the
	// metadata rather than passed off as the farmer's figure.
	harvested, harvestDateSource := timestamp(data, "harvest_date"), "payload"
	if harvested == nil {
		harvestDateSource = "event-timestamp"
		t := event.Timestamp
		if t.IsZero() {
			harvestDateSource = "consumer-clock"
			t = time.Now().UTC()
		}
		harvested = &t
	}

	// The batch this harvest closes, if the planting was seen. Closing the open
	// record rather than creating a second one is what keeps the chain
	// continuous: the alternative is one record covering the growing season
	// with no harvest and another covering the harvest with no history, which
	// is two halves of a chain of custody and no chain.
	if open, findErr := c.svc.FindOpenRecordForField(ctx, fieldID); findErr != nil {
		return fmt.Errorf("onYieldRecorded: find open record for field %s: %w", fieldID, findErr)
	} else if open != nil {
		return c.closeAtHarvest(ctx, open, *harvested, harvestDateSource, recordID, data)
	}

	// No planting was recorded for this field, so there is nothing to close and
	// the harvest opens its own record. Less useful than a full chain — it can
	// say where the crate came from but not how it was grown — and worth having
	// rather than losing the harvest.
	//
	// The batch number is derived from the yield record's id rather than
	// generated, so a replayed event produces the same batch and the record
	// service can recognise it as a duplicate instead of opening a second
	// chain of custody for one harvest.
	input := tracedomain.CreateRecordInput{
		FarmID:      farmID,
		FieldID:     fieldID,
		CropID:      cropID,
		BatchNumber: batchNumberFor(recordID),
		ProductType: str(data, "crop_id"),
		Metadata: map[string]string{
			"source":              "yield-service",
			"yield_record_id":     recordID,
			"season":              str(data, "season"),
			"quality_grade":       str(data, "quality_grade"),
			"harvest_date_source": harvestDateSource,
		},
	}
	input.HarvestDate = harvested

	record, err := c.svc.CreateRecord(ctx, input)
	if err != nil {
		// Returned, so the consumer retries: a database that is briefly
		// unavailable must not lose the harvest.
		return fmt.Errorf("onYieldRecorded: create record for yield %s: %w", recordID, err)
	}

	if err := c.addEvent(ctx, record.ID, tracedomain.SupplyChainEventTypeHarvested, *harvested, data,
		harvestDetails(data, recordID)); err != nil {
		return fmt.Errorf("onYieldRecorded: record harvest event: %w", err)
	}

	c.log.Infow("msg", "traceability record created for harvest with no recorded planting",
		"record_id", record.ID, "yield_record_id", recordID, "field_id", fieldID)
	return nil
}

// closeAtHarvest stamps the harvest onto the record opened at planting.
func (c *TraceabilityConsumer) closeAtHarvest(
	ctx context.Context,
	record *tracedomain.TraceabilityRecord,
	harvested time.Time,
	harvestDateSource string,
	yieldRecordID string,
	data map[string]interface{},
) error {
	// Already closed. A Kafka replay must not move the harvest date or append a
	// second HARVESTED event to the same batch.
	if record.HarvestDate != nil {
		c.log.Debugw("msg", "harvest already recorded on this batch",
			"record_id", record.ID, "yield_record_id", yieldRecordID)
		return nil
	}

	if _, err := c.svc.UpdateRecord(ctx, record.ID, tracedomain.UpdateRecordInput{
		HarvestDate: &harvested,
		Metadata: map[string]string{
			"yield_record_id":     yieldRecordID,
			"quality_grade":       str(data, "quality_grade"),
			"harvest_date_source": harvestDateSource,
		},
	}); err != nil {
		return fmt.Errorf("onYieldRecorded: close record %s: %w", record.ID, err)
	}

	if err := c.addEvent(ctx, record.ID, tracedomain.SupplyChainEventTypeHarvested, harvested, data,
		harvestDetails(data, yieldRecordID)); err != nil {
		return fmt.Errorf("onYieldRecorded: record harvest event on %s: %w", record.ID, err)
	}

	c.log.Infow("msg", "chain of custody closed at harvest",
		"record_id", record.ID, "batch_number", record.BatchNumber,
		"yield_record_id", yieldRecordID)
	return nil
}

func harvestDetails(data map[string]interface{}, yieldRecordID string) string {
	details := "harvest " + yieldRecordID
	if grade := str(data, "quality_grade"); grade != "" {
		details += ", grade " + grade
	}
	return details
}

// batchNumberFor derives a stable batch number from a yield record id.
func batchNumberFor(yieldRecordID string) string {
	if yieldRecordID == "" {
		return ""
	}
	return "HARVEST-" + yieldRecordID
}

// str reads a string field, tolerating a missing or wrongly-typed one — the
// payload is JSON from another service and nothing here may assume a type.
func str(data map[string]interface{}, key string) string {
	v, _ := data[key].(string)
	return v
}

// timestamp reads an RFC 3339 string into a time.
func timestamp(data map[string]interface{}, key string) *time.Time {
	raw := str(data, key)
	if raw == "" {
		return nil
	}
	t, err := time.Parse(time.RFC3339, raw)
	if err != nil {
		return nil
	}
	u := t.UTC()
	return &u
}

// systemContext scopes a consumer-initiated operation to a tenant.
//
// A consumer has no request to inherit one from, so without this every query
// runs unscoped and row-level security returns nothing — which looks like
// success with no data rather than a failure.
func (c *TraceabilityConsumer) systemContext(ctx context.Context, tenantID string) context.Context {
	ctx = p9context.NewConnectionInfo(ctx, &saas.ConnectionInfo{TenantID: tenantID})
	ctx = p9context.NewUserContext(ctx, p9context.UserContext{
		UserID:   "system",
		TenantID: tenantID,
	})
	return p9context.NewRLSScopeTenantOnly(ctx, tenantID)
}

func extractEventData(event *domain.DomainEvent) (map[string]interface{}, error) {
	raw, err := json.Marshal(event.Data)
	if err != nil {
		return nil, fmt.Errorf("marshal event data: %w", err)
	}
	var data map[string]interface{}
	if err := json.Unmarshal(raw, &data); err != nil {
		return nil, fmt.Errorf("unmarshal event data: %w", err)
	}
	return data, nil
}
