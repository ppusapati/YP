// Package events contains the inbound Kafka consumer adapter for pest-prediction-service events.
package events

import (
	"context"
	"encoding/json"
	"fmt"

	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9log"

	"p9e.in/samavaya/agriculture/pest-prediction-service/internal/ports/inbound"
)

const PestEventTopic = "samavaya.agriculture.pest-prediction.events"

// PestConsumer is the inbound Kafka adapter for pest-prediction-service domain events.
type PestConsumer struct {
	svc inbound.PestService
	log *p9log.Helper
}

// NewPestConsumer creates a new Kafka consumer for pest events.
func NewPestConsumer(svc inbound.PestService, log p9log.Logger) *PestConsumer {
	return &PestConsumer{
		svc: svc,
		log: p9log.NewHelper(p9log.With(log, "component", "PestConsumer")),
	}
}

// Topic returns the Kafka topic this consumer listens on.
func (c *PestConsumer) Topic() string { return PestEventTopic }

// HandleEvent dispatches an incoming domain event.
func (c *PestConsumer) HandleEvent(ctx context.Context, event *domain.DomainEvent) error {
	if event == nil {
		return fmt.Errorf("received nil event")
	}
	c.log.Infow("msg", "pest event received",
		"event_id", event.ID,
		"event_type", string(event.Type),
		"aggregate_id", event.AggregateID,
	)
	switch event.Type {
	case "agriculture.pest-prediction.created":
		return c.onPestCreated(ctx, event)
	case "agriculture.pest-prediction.updated":
		return c.onPestUpdated(ctx, event)
	case "agriculture.pest-prediction.deleted":
		return c.onPestDeleted(ctx, event)
	default:
		c.log.Infow("msg", "unhandled event type", "type", event.Type)
		return nil
	}
}

func (c *PestConsumer) onPestCreated(_ context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return err
	}
	c.log.Infow("msg", "pest created event", "pest_prediction_id", data["pest_prediction_id"])
	return nil
}

func (c *PestConsumer) onPestUpdated(_ context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return err
	}
	c.log.Infow("msg", "pest updated event", "pest_prediction_id", data["pest_prediction_id"])
	return nil
}

func (c *PestConsumer) onPestDeleted(_ context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return err
	}
	c.log.Infow("msg", "pest deleted event", "pest_prediction_id", data["pest_prediction_id"])
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
