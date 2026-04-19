// Package events contains the inbound Kafka consumer adapter for yield-service events.
package events

import (
	"context"
	"encoding/json"
	"fmt"

	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9log"

	"p9e.in/samavaya/agriculture/yield-service/internal/ports/inbound"
)

const YieldEventTopic = "samavaya.agriculture.yield.events"

// YieldConsumer is the inbound Kafka adapter for yield-service domain events.
type YieldConsumer struct {
	svc inbound.YieldService
	log *p9log.Helper
}

// NewYieldConsumer creates a new Kafka consumer for yield events.
func NewYieldConsumer(svc inbound.YieldService, log p9log.Logger) *YieldConsumer {
	return &YieldConsumer{
		svc: svc,
		log: p9log.NewHelper(p9log.With(log, "component", "YieldConsumer")),
	}
}

// Topic returns the Kafka topic this consumer listens on.
func (c *YieldConsumer) Topic() string { return YieldEventTopic }

// HandleEvent dispatches an incoming domain event.
func (c *YieldConsumer) HandleEvent(ctx context.Context, event *domain.DomainEvent) error {
	if event == nil {
		return fmt.Errorf("received nil event")
	}
	c.log.Infow("msg", "yield event received",
		"event_id", event.ID,
		"event_type", string(event.Type),
		"aggregate_id", event.AggregateID,
	)
	switch event.Type {
	case "agriculture.yield.created":
		return c.onYieldCreated(ctx, event)
	case "agriculture.yield.updated":
		return c.onYieldUpdated(ctx, event)
	case "agriculture.yield.deleted":
		return c.onYieldDeleted(ctx, event)
	default:
		c.log.Infow("msg", "unhandled event type", "type", event.Type)
		return nil
	}
}

func (c *YieldConsumer) onYieldCreated(_ context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return err
	}
	c.log.Infow("msg", "yield created event", "yield_id", data["yield_id"])
	return nil
}

func (c *YieldConsumer) onYieldUpdated(_ context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return err
	}
	c.log.Infow("msg", "yield updated event", "yield_id", data["yield_id"])
	return nil
}

func (c *YieldConsumer) onYieldDeleted(_ context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return err
	}
	c.log.Infow("msg", "yield deleted event", "yield_id", data["yield_id"])
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
