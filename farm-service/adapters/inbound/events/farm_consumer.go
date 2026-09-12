// Package events contains the inbound Kafka event consumer adapter for farm-service.
// It subscribes to events from OTHER services that the farm-service needs to react to:
// field events (fields created/deleted on the farm) and sensor events (sensors deployed).
package events

import (
	"context"
	"encoding/json"
	"fmt"

	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9log"

	"p9e.in/samavaya/agriculture/farm-service/internal/ports/inbound"
)

// Topics from OTHER services that farm-service consumes.
const (
	FieldEventTopic  = "samavaya.agriculture.field.events"
	SensorEventTopic = "samavaya.agriculture.sensor.events"
)

// FarmConsumer is the inbound Kafka adapter that reacts to cross-service domain events.
// It listens for field and sensor events relevant to farm management.
type FarmConsumer struct {
	svc inbound.FarmService
	log *p9log.Helper
}

// NewFarmConsumer creates a new Kafka consumer for cross-service events.
func NewFarmConsumer(svc inbound.FarmService, log p9log.Logger) *FarmConsumer {
	return &FarmConsumer{
		svc: svc,
		log: p9log.NewHelper(p9log.With(log, "component", "FarmConsumer")),
	}
}

// Topics returns the Kafka topics this consumer listens on.
func (c *FarmConsumer) Topics() []string {
	return []string{FieldEventTopic, SensorEventTopic}
}

// HandleEvent dispatches an incoming domain event to the appropriate handler.
func (c *FarmConsumer) HandleEvent(ctx context.Context, event *domain.DomainEvent) error {
	if event == nil {
		return fmt.Errorf("received nil event")
	}
	c.log.Infow("msg", "cross-service event received",
		"event_id", event.ID,
		"event_type", string(event.Type),
		"aggregate_id", event.AggregateID,
	)

	switch event.Type {
	// Field events: react when fields are created/deleted on a farm
	case domain.EventTypeFieldCreated:
		return c.onFieldCreated(ctx, event)
	case domain.EventTypeFieldUpdated:
		return c.onFieldUpdated(ctx, event)
	case domain.EventTypeFieldDeleted:
		return c.onFieldDeleted(ctx, event)

	// Sensor events: react when sensors are deployed/removed on a farm
	case domain.EventTypeSensorCreated:
		return c.onSensorDeployed(ctx, event)
	case domain.EventTypeSensorDeleted:
		return c.onSensorRemoved(ctx, event)

	default:
		c.log.Infow("msg", "unhandled event type", "type", string(event.Type))
		return nil
	}
}

// onFieldCreated handles a new field being added to a farm.
// The farm-service can use this to update field counts or warm caches.
func (c *FarmConsumer) onFieldCreated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onFieldCreated: %w", err)
	}
	farmID, _ := data["farm_id"].(string)
	fieldID, _ := data["field_id"].(string)
	c.log.Infow("msg", "field created on farm",
		"farm_id", farmID,
		"field_id", fieldID,
	)
	// TODO: call c.svc to update farm aggregate (e.g. field count, total area)
	return nil
}

// onFieldUpdated handles a field being updated (e.g. boundary change).
func (c *FarmConsumer) onFieldUpdated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onFieldUpdated: %w", err)
	}
	farmID, _ := data["farm_id"].(string)
	fieldID, _ := data["field_id"].(string)
	c.log.Infow("msg", "field updated on farm",
		"farm_id", farmID,
		"field_id", fieldID,
	)
	// TODO: call c.svc to refresh farm summary (e.g. recalc total area)
	return nil
}

// onFieldDeleted handles a field being removed from a farm.
func (c *FarmConsumer) onFieldDeleted(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onFieldDeleted: %w", err)
	}
	farmID, _ := data["farm_id"].(string)
	fieldID, _ := data["field_id"].(string)
	c.log.Infow("msg", "field deleted from farm",
		"farm_id", farmID,
		"field_id", fieldID,
	)
	// TODO: call c.svc to update farm aggregate (decrement field count)
	return nil
}

// onSensorDeployed handles a sensor being deployed on the farm.
func (c *FarmConsumer) onSensorDeployed(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onSensorDeployed: %w", err)
	}
	farmID, _ := data["farm_id"].(string)
	sensorID, _ := data["sensor_id"].(string)
	c.log.Infow("msg", "sensor deployed on farm",
		"farm_id", farmID,
		"sensor_id", sensorID,
	)
	// TODO: call c.svc to track sensor presence on the farm
	return nil
}

// onSensorRemoved handles a sensor being removed from the farm.
func (c *FarmConsumer) onSensorRemoved(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onSensorRemoved: %w", err)
	}
	farmID, _ := data["farm_id"].(string)
	sensorID, _ := data["sensor_id"].(string)
	c.log.Infow("msg", "sensor removed from farm",
		"farm_id", farmID,
		"sensor_id", sensorID,
	)
	// TODO: call c.svc to remove sensor tracking from the farm
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
