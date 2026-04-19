// Package events contains the inbound Kafka consumer adapter for sensor-service events.
package events

import (
	"context"
	"encoding/json"
	"fmt"

	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9log"

	"p9e.in/samavaya/agriculture/sensor-service/internal/ports/inbound"
)

const SensorEventTopic = "samavaya.agriculture.sensor.events"

// SensorConsumer is the inbound Kafka adapter for sensor-service domain events.
type SensorConsumer struct {
	svc inbound.SensorService
	log *p9log.Helper
}

// NewSensorConsumer creates a new Kafka consumer for sensor events.
func NewSensorConsumer(svc inbound.SensorService, log p9log.Logger) *SensorConsumer {
	return &SensorConsumer{
		svc: svc,
		log: p9log.NewHelper(p9log.With(log, "component", "SensorConsumer")),
	}
}

// Topic returns the Kafka topic this consumer listens on.
func (c *SensorConsumer) Topic() string { return SensorEventTopic }

// HandleEvent dispatches an incoming domain event.
func (c *SensorConsumer) HandleEvent(ctx context.Context, event *domain.DomainEvent) error {
	if event == nil {
		return fmt.Errorf("received nil event")
	}
	c.log.Infow("msg", "sensor event received",
		"event_id", event.ID,
		"event_type", string(event.Type),
		"aggregate_id", event.AggregateID,
	)
	switch event.Type {
	case "agriculture.sensor.created":
		return c.onSensorCreated(ctx, event)
	case "agriculture.sensor.updated":
		return c.onSensorUpdated(ctx, event)
	case "agriculture.sensor.deleted":
		return c.onSensorDeleted(ctx, event)
	default:
		c.log.Infow("msg", "unhandled event type", "type", event.Type)
		return nil
	}
}

func (c *SensorConsumer) onSensorCreated(_ context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return err
	}
	c.log.Infow("msg", "sensor created event", "sensor_id", data["sensor_id"])
	return nil
}

func (c *SensorConsumer) onSensorUpdated(_ context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return err
	}
	c.log.Infow("msg", "sensor updated event", "sensor_id", data["sensor_id"])
	return nil
}

func (c *SensorConsumer) onSensorDeleted(_ context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return err
	}
	c.log.Infow("msg", "sensor deleted event", "sensor_id", data["sensor_id"])
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
