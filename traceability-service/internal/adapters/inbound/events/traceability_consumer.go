// Package events contains the inbound Kafka consumer adapter for traceability-service events.
package events

import (
	"context"
	"encoding/json"
	"fmt"

	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9log"

	"p9e.in/samavaya/agriculture/traceability-service/internal/ports/inbound"
)

const TraceabilityEventTopic = "samavaya.agriculture.traceability.events"

// TraceabilityConsumer is the inbound Kafka adapter for traceability-service domain events.
type TraceabilityConsumer struct {
	svc inbound.TraceabilityService
	log *p9log.Helper
}

// NewTraceabilityConsumer creates a new Kafka consumer for traceability events.
func NewTraceabilityConsumer(svc inbound.TraceabilityService, log p9log.Logger) *TraceabilityConsumer {
	return &TraceabilityConsumer{
		svc: svc,
		log: p9log.NewHelper(p9log.With(log, "component", "TraceabilityConsumer")),
	}
}

// Topic returns the Kafka topic this consumer listens on.
func (c *TraceabilityConsumer) Topic() string { return TraceabilityEventTopic }

// HandleEvent dispatches an incoming domain event.
func (c *TraceabilityConsumer) HandleEvent(ctx context.Context, event *domain.DomainEvent) error {
	if event == nil {
		return fmt.Errorf("received nil event")
	}
	c.log.Infow("msg", "traceability event received",
		"event_id", event.ID,
		"event_type", string(event.Type),
		"aggregate_id", event.AggregateID,
	)
	switch event.Type {
	case "agriculture.traceability.created":
		return c.onTraceabilityCreated(ctx, event)
	case "agriculture.traceability.updated":
		return c.onTraceabilityUpdated(ctx, event)
	case "agriculture.traceability.deleted":
		return c.onTraceabilityDeleted(ctx, event)
	default:
		c.log.Infow("msg", "unhandled event type", "type", event.Type)
		return nil
	}
}

func (c *TraceabilityConsumer) onTraceabilityCreated(_ context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return err
	}
	c.log.Infow("msg", "traceability created event", "traceability_id", data["traceability_id"])
	return nil
}

func (c *TraceabilityConsumer) onTraceabilityUpdated(_ context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return err
	}
	c.log.Infow("msg", "traceability updated event", "traceability_id", data["traceability_id"])
	return nil
}

func (c *TraceabilityConsumer) onTraceabilityDeleted(_ context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return err
	}
	c.log.Infow("msg", "traceability deleted event", "traceability_id", data["traceability_id"])
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
