// Package events contains the inbound Kafka consumer adapter for satellite-service.
// It subscribes to events from OTHER services that the satellite-service needs to react to:
// farm events (farm boundaries for satellite coverage) and field events (field boundaries
// for targeted satellite analysis).
package events

import (
	"context"
	"encoding/json"
	"fmt"

	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9log"

	"p9e.in/samavaya/agriculture/satellite-service/internal/ports/inbound"
)

// Topics from OTHER services that satellite-service consumes.
const (
	FarmEventTopic  = "samavaya.agriculture.farm.events"
	FieldEventTopic = "samavaya.agriculture.field.events"
)

// SatelliteConsumer is the inbound Kafka adapter that reacts to cross-service domain events.
type SatelliteConsumer struct {
	svc inbound.SatelliteService
	log *p9log.Helper
}

// NewSatelliteConsumer creates a new Kafka consumer for cross-service events.
func NewSatelliteConsumer(svc inbound.SatelliteService, log p9log.Logger) *SatelliteConsumer {
	return &SatelliteConsumer{
		svc: svc,
		log: p9log.NewHelper(p9log.With(log, "component", "SatelliteConsumer")),
	}
}

// Topics returns the Kafka topics this consumer listens on.
func (c *SatelliteConsumer) Topics() []string {
	return []string{FarmEventTopic, FieldEventTopic}
}

// HandleEvent dispatches an incoming domain event.
func (c *SatelliteConsumer) HandleEvent(ctx context.Context, event *domain.DomainEvent) error {
	if event == nil {
		return fmt.Errorf("received nil event")
	}
	c.log.Infow("msg", "cross-service event received",
		"event_id", event.ID,
		"event_type", string(event.Type),
		"aggregate_id", event.AggregateID,
	)

	switch event.Type {
	// Farm events: farm boundaries define satellite coverage areas
	case domain.EventTypeFarmCreated:
		return c.onFarmCreated(ctx, event)
	case domain.EventTypeFarmBoundarySet:
		return c.onFarmBoundarySet(ctx, event)
	case domain.EventTypeFarmDeleted:
		return c.onFarmDeleted(ctx, event)

	// Field events: field boundaries for targeted satellite analysis
	case domain.EventTypeFieldCreated:
		return c.onFieldCreated(ctx, event)
	case domain.EventTypeFieldDeleted:
		return c.onFieldDeleted(ctx, event)

	default:
		c.log.Infow("msg", "unhandled event type", "type", string(event.Type))
		return nil
	}
}

// onFarmCreated handles a new farm being created.
// Satellite-service can schedule initial imagery for the farm area.
func (c *SatelliteConsumer) onFarmCreated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onFarmCreated: %w", err)
	}
	farmID, _ := data["farm_id"].(string)
	c.log.Infow("msg", "farm created, scheduling initial satellite imagery",
		"farm_id", farmID,
	)
	// TODO: call c.svc.RequestImagery for the new farm's geographic area
	return nil
}

// onFarmBoundarySet handles a farm boundary being set or updated.
// The satellite coverage area should be recalculated.
func (c *SatelliteConsumer) onFarmBoundarySet(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onFarmBoundarySet: %w", err)
	}
	farmID, _ := data["farm_id"].(string)
	c.log.Infow("msg", "farm boundary updated, recalculating satellite coverage",
		"farm_id", farmID,
	)
	// TODO: update satellite coverage area based on new farm boundary
	return nil
}

// onFarmDeleted handles a farm being deleted.
func (c *SatelliteConsumer) onFarmDeleted(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onFarmDeleted: %w", err)
	}
	farmID, _ := data["farm_id"].(string)
	c.log.Infow("msg", "farm deleted, removing satellite monitoring tasks",
		"farm_id", farmID,
	)
	// TODO: cancel pending satellite tasks for this farm
	return nil
}

// onFieldCreated handles a new field being created.
// Satellite-service can schedule field-level analysis (NDVI, crop stress).
func (c *SatelliteConsumer) onFieldCreated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onFieldCreated: %w", err)
	}
	fieldID, _ := data["field_id"].(string)
	farmID, _ := data["farm_id"].(string)
	c.log.Infow("msg", "field created, scheduling satellite analysis",
		"field_id", fieldID,
		"farm_id", farmID,
	)
	// TODO: call c.svc.RequestImagery for field-level vegetation index analysis
	return nil
}

// onFieldDeleted handles a field being deleted.
func (c *SatelliteConsumer) onFieldDeleted(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onFieldDeleted: %w", err)
	}
	fieldID, _ := data["field_id"].(string)
	c.log.Infow("msg", "field deleted, cancelling satellite analysis tasks",
		"field_id", fieldID,
	)
	// TODO: cancel pending satellite tasks for this field
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
