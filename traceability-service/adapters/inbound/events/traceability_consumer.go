// Package events contains the inbound Kafka consumer adapter for traceability-service.
// It subscribes to events from OTHER services that the traceability-service needs to react to.
// Traceability tracks the full lifecycle: farm, field, crop, irrigation, and yield events.
package events

import (
	"context"
	"encoding/json"
	"fmt"

	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9log"

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

	// Yield events: harvest and yield records for traceability
	case domain.EventTypeYieldCreated:
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

// onYieldRecorded records harvest/yield data for product traceability.
func (c *TraceabilityConsumer) onYieldRecorded(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onYieldRecorded: %w", err)
	}
	yieldID, _ := data["yield_id"].(string)
	fieldID, _ := data["field_id"].(string)
	c.log.Infow("msg", "yield recorded, creating traceability record for harvest",
		"yield_id", yieldID,
		"field_id", fieldID,
	)
	// TODO: call c.svc.CreateRecord to create a traceability record for the harvest
	return nil
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
