// Package events contains the inbound Kafka consumer adapter for sensor-service.
// It subscribes to events from OTHER services that the sensor-service needs to react to:
// field events (field lifecycle affecting sensor placement) and farm events (farm deletion
// requiring sensor decommission).
package events

import (
	"context"
	"encoding/json"
	"fmt"

	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9log"

	"p9e.in/samavaya/agriculture/sensor-service/internal/ports/inbound"
)

// Topics from OTHER services that sensor-service consumes.
const (
	FieldEventTopic = "samavaya.agriculture.field.events"
	FarmEventTopic  = "samavaya.agriculture.farm.events"
)

// SensorConsumer is the inbound Kafka adapter that reacts to cross-service domain events.
type SensorConsumer struct {
	svc inbound.SensorService
	log *p9log.Helper
}

// NewSensorConsumer creates a new Kafka consumer for cross-service events.
func NewSensorConsumer(svc inbound.SensorService, log p9log.Logger) *SensorConsumer {
	return &SensorConsumer{
		svc: svc,
		log: p9log.NewHelper(p9log.With(log, "component", "SensorConsumer")),
	}
}

// Topics returns the Kafka topics this consumer listens on.
func (c *SensorConsumer) Topics() []string {
	return []string{FieldEventTopic, FarmEventTopic}
}

// HandleEvent dispatches an incoming domain event.
func (c *SensorConsumer) HandleEvent(ctx context.Context, event *domain.DomainEvent) error {
	if event == nil {
		return fmt.Errorf("received nil event")
	}
	c.log.Infow("msg", "cross-service event received",
		"event_id", event.ID,
		"event_type", string(event.Type),
		"aggregate_id", event.AggregateID,
	)

	switch event.Type {
	// Field events: sensor placement depends on field lifecycle
	case domain.EventTypeFieldCreated:
		return c.onFieldCreated(ctx, event)
	case domain.EventTypeFieldDeleted:
		return c.onFieldDeleted(ctx, event)

	// Farm events: farm deletion triggers sensor decommission
	case domain.EventTypeFarmDeleted:
		return c.onFarmDeleted(ctx, event)

	default:
		c.log.Infow("msg", "unhandled event type", "type", string(event.Type))
		return nil
	}
}

// onFieldCreated handles a new field being created.
// Sensor-service may plan sensor deployment for the new field.
func (c *SensorConsumer) onFieldCreated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onFieldCreated: %w", err)
	}
	fieldID, _ := data["field_id"].(string)
	farmID, _ := data["farm_id"].(string)
	c.log.Infow("msg", "field created, sensor deployment may be needed",
		"field_id", fieldID,
		"farm_id", farmID,
	)
	// TODO: plan sensor deployment for the new field
	return nil
}

// onFieldDeleted handles a field being deleted.
// Sensors on this field should be flagged for decommission or redeployment.
func (c *SensorConsumer) onFieldDeleted(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onFieldDeleted: %w", err)
	}
	fieldID, _ := data["field_id"].(string)
	c.log.Infow("msg", "field deleted, decommissioning associated sensors",
		"field_id", fieldID,
	)
	// TODO: list sensors by field, call c.svc.DecommissionSensor for each
	return nil
}

// onFarmDeleted handles a farm being deleted.
// All sensors on this farm should be decommissioned.
func (c *SensorConsumer) onFarmDeleted(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onFarmDeleted: %w", err)
	}
	farmID, _ := data["farm_id"].(string)
	c.log.Infow("msg", "farm deleted, decommissioning all sensors",
		"farm_id", farmID,
	)
	// TODO: list sensors by farm, call c.svc.DecommissionSensor for each
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
