// Package events contains the inbound Kafka consumer adapter for soil-service events.
package events

import (
	"context"
	"encoding/json"
	"fmt"

	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9log"

	"p9e.in/samavaya/agriculture/soil-service/internal/ports/inbound"
)

const SoilEventTopic = "samavaya.agriculture.soil.events"

// SoilConsumer is the inbound Kafka adapter for soil-service domain events.
type SoilConsumer struct {
	svc inbound.SoilService
	log *p9log.Helper
}

// NewSoilConsumer creates a new Kafka consumer for soil events.
func NewSoilConsumer(svc inbound.SoilService, log p9log.Logger) *SoilConsumer {
	return &SoilConsumer{
		svc: svc,
		log: p9log.NewHelper(p9log.With(log, "component", "SoilConsumer")),
	}
}

// Topic returns the Kafka topic this consumer listens on.
func (c *SoilConsumer) Topic() string { return SoilEventTopic }

// HandleEvent dispatches an incoming domain event.
func (c *SoilConsumer) HandleEvent(ctx context.Context, event *domain.DomainEvent) error {
	if event == nil {
		return fmt.Errorf("received nil event")
	}
	c.log.Infow("msg", "soil event received",
		"event_id", event.ID,
		"event_type", string(event.Type),
		"aggregate_id", event.AggregateID,
	)
	switch event.Type {
	case "agriculture.soil.created":
		return c.onSoilCreated(ctx, event)
	case "agriculture.soil.updated":
		return c.onSoilUpdated(ctx, event)
	case "agriculture.soil.deleted":
		return c.onSoilDeleted(ctx, event)
	default:
		c.log.Infow("msg", "unhandled event type", "type", event.Type)
		return nil
	}
}

func (c *SoilConsumer) onSoilCreated(_ context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return err
	}
	c.log.Infow("msg", "soil created event", "soil_id", data["soil_id"])
	return nil
}

func (c *SoilConsumer) onSoilUpdated(_ context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return err
	}
	c.log.Infow("msg", "soil updated event", "soil_id", data["soil_id"])
	return nil
}

func (c *SoilConsumer) onSoilDeleted(_ context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return err
	}
	c.log.Infow("msg", "soil deleted event", "soil_id", data["soil_id"])
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
