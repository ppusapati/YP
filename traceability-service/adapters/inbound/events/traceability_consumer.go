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

// onFarmCreated records a farm creation as a supply chain origin event.
func (c *TraceabilityConsumer) onFarmCreated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onFarmCreated: %w", err)
	}
	farmID, _ := data["farm_id"].(string)
	name, _ := data["name"].(string)
	c.log.Infow("msg", "farm created, recording supply chain origin",
		"farm_id", farmID,
		"name", name,
	)
	// TODO: call c.svc.AddSupplyChainEvent to record farm as origin in traceability
	return nil
}

// onFarmUpdated records farm updates for traceability audit trail.
func (c *TraceabilityConsumer) onFarmUpdated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onFarmUpdated: %w", err)
	}
	farmID, _ := data["farm_id"].(string)
	c.log.Infow("msg", "farm updated, recording in audit trail",
		"farm_id", farmID,
	)
	// TODO: call c.svc.AddSupplyChainEvent to record farm update
	return nil
}

// onFieldCreated records field creation as part of the supply chain.
func (c *TraceabilityConsumer) onFieldCreated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onFieldCreated: %w", err)
	}
	fieldID, _ := data["field_id"].(string)
	farmID, _ := data["farm_id"].(string)
	c.log.Infow("msg", "field created, recording in traceability chain",
		"field_id", fieldID,
		"farm_id", farmID,
	)
	// TODO: call c.svc.AddSupplyChainEvent for field creation
	return nil
}

// onFieldCropAssigned records a crop assignment for traceability.
func (c *TraceabilityConsumer) onFieldCropAssigned(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onFieldCropAssigned: %w", err)
	}
	fieldID, _ := data["field_id"].(string)
	cropID, _ := data["crop_id"].(string)
	c.log.Infow("msg", "crop assigned to field, recording in traceability",
		"field_id", fieldID,
		"crop_id", cropID,
	)
	// TODO: call c.svc.AddSupplyChainEvent for crop assignment
	return nil
}

// onCropCreated records crop type registration for traceability.
func (c *TraceabilityConsumer) onCropCreated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onCropCreated: %w", err)
	}
	cropID, _ := data["crop_id"].(string)
	c.log.Infow("msg", "crop type created, available for traceability records",
		"crop_id", cropID,
	)
	// Informational: crop type is now available for traceability records
	return nil
}

// onIrrigationEvent records irrigation activity for compliance traceability.
func (c *TraceabilityConsumer) onIrrigationEvent(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onIrrigationEvent: %w", err)
	}
	irrigationID, _ := data["irrigation_id"].(string)
	fieldID, _ := data["field_id"].(string)
	c.log.Infow("msg", "irrigation event, recording for compliance",
		"irrigation_id", irrigationID,
		"field_id", fieldID,
	)
	// TODO: call c.svc.AddSupplyChainEvent for irrigation record
	return nil
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
			"source":          "yield-service",
			"yield_record_id": recordID,
			"season":          str(data, "season"),
			"quality_grade":   str(data, "quality_grade"),
		},
	}
	if harvested := timestamp(data, "harvest_date"); harvested != nil {
		input.HarvestDate = harvested
	}

	record, err := c.svc.CreateRecord(ctx, input)
	if err != nil {
		// Returned, so the consumer retries: a database that is briefly
		// unavailable must not lose the harvest.
		return fmt.Errorf("onYieldRecorded: create record for yield %s: %w", recordID, err)
	}

	c.log.Infow("msg", "traceability record created for harvest",
		"record_id", record.ID, "yield_record_id", recordID, "field_id", fieldID)
	return nil
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
