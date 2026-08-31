// Package events contains the inbound Kafka consumer adapter for satellite-service events.
package events

import (
	"context"
	"encoding/json"
	"fmt"

	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9log"

	"p9e.in/samavaya/agriculture/satellite-service/internal/ports/inbound"
)

const SatelliteEventTopic = "samavaya.agriculture.satellite.events"

// SatelliteConsumer is the inbound Kafka adapter for satellite-service domain events.
type SatelliteConsumer struct {
	svc inbound.SatelliteService
	log *p9log.Helper
}

// NewSatelliteConsumer creates a new Kafka consumer for satellite events.
func NewSatelliteConsumer(svc inbound.SatelliteService, log p9log.Logger) *SatelliteConsumer {
	return &SatelliteConsumer{
		svc: svc,
		log: p9log.NewHelper(p9log.With(log, "component", "SatelliteConsumer")),
	}
}

// Topic returns the Kafka topic this consumer listens on.
func (c *SatelliteConsumer) Topic() string { return SatelliteEventTopic }

// HandleEvent dispatches an incoming domain event.
func (c *SatelliteConsumer) HandleEvent(ctx context.Context, event *domain.DomainEvent) error {
	if event == nil {
		return fmt.Errorf("received nil event")
	}
	c.log.Infow("msg", "satellite event received",
		"event_id", event.ID,
		"event_type", string(event.Type),
		"aggregate_id", event.AggregateID,
	)
	switch event.Type {
	case "agriculture.satellite.created":
		return c.onSatelliteCreated(ctx, event)
	case "agriculture.satellite.updated":
		return c.onSatelliteUpdated(ctx, event)
	case "agriculture.satellite.deleted":
		return c.onSatelliteDeleted(ctx, event)
	default:
		c.log.Infow("msg", "unhandled event type", "type", event.Type)
		return nil
	}
}

func (c *SatelliteConsumer) onSatelliteCreated(_ context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return err
	}
	c.log.Infow("msg", "satellite created event", "satellite_id", data["satellite_id"])
	return nil
}

func (c *SatelliteConsumer) onSatelliteUpdated(_ context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return err
	}
	c.log.Infow("msg", "satellite updated event", "satellite_id", data["satellite_id"])
	return nil
}

func (c *SatelliteConsumer) onSatelliteDeleted(_ context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return err
	}
	c.log.Infow("msg", "satellite deleted event", "satellite_id", data["satellite_id"])
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
