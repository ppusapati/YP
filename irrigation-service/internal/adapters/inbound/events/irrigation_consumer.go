// Package events contains the inbound Kafka consumer adapter for irrigation-service events.
package events

import (
	"context"
	"encoding/json"
	"fmt"

	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9log"

	"p9e.in/samavaya/agriculture/irrigation-service/internal/ports/inbound"
)

const IrrigationEventTopic = "samavaya.agriculture.irrigation.events"

// IrrigationConsumer is the inbound Kafka adapter for irrigation-service domain events.
type IrrigationConsumer struct {
	svc inbound.IrrigationService
	log *p9log.Helper
}

// NewIrrigationConsumer creates a new Kafka consumer for irrigation events.
func NewIrrigationConsumer(svc inbound.IrrigationService, log p9log.Logger) *IrrigationConsumer {
	return &IrrigationConsumer{
		svc: svc,
		log: p9log.NewHelper(p9log.With(log, "component", "IrrigationConsumer")),
	}
}

// Topic returns the Kafka topic this consumer listens on.
func (c *IrrigationConsumer) Topic() string { return IrrigationEventTopic }

// HandleEvent dispatches an incoming domain event.
func (c *IrrigationConsumer) HandleEvent(ctx context.Context, event *domain.DomainEvent) error {
	if event == nil {
		return fmt.Errorf("received nil event")
	}
	c.log.Infow("msg", "irrigation event received",
		"event_id", event.ID,
		"event_type", string(event.Type),
		"aggregate_id", event.AggregateID,
	)
	switch event.Type {
	case "agriculture.irrigation.created":
		return c.onIrrigationCreated(ctx, event)
	case "agriculture.irrigation.updated":
		return c.onIrrigationUpdated(ctx, event)
	case "agriculture.irrigation.deleted":
		return c.onIrrigationDeleted(ctx, event)
	default:
		c.log.Infow("msg", "unhandled event type", "type", event.Type)
		return nil
	}
}

func (c *IrrigationConsumer) onIrrigationCreated(_ context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return err
	}
	c.log.Infow("msg", "irrigation created event", "irrigation_id", data["irrigation_id"])
	return nil
}

func (c *IrrigationConsumer) onIrrigationUpdated(_ context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return err
	}
	c.log.Infow("msg", "irrigation updated event", "irrigation_id", data["irrigation_id"])
	return nil
}

func (c *IrrigationConsumer) onIrrigationDeleted(_ context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return err
	}
	c.log.Infow("msg", "irrigation deleted event", "irrigation_id", data["irrigation_id"])
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
