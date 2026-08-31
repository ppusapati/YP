// Package events contains the inbound Kafka consumer adapter for crop-service events.
package events

import (
	"context"
	"encoding/json"
	"fmt"

	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9log"

	"p9e.in/samavaya/agriculture/crop-service/internal/ports/inbound"
)

const CropEventTopic = "samavaya.agriculture.crop.events"

// CropConsumer is the inbound Kafka adapter for crop-service domain events.
type CropConsumer struct {
	svc inbound.CropService
	log *p9log.Helper
}

// NewCropConsumer creates a new Kafka consumer for crop events.
func NewCropConsumer(svc inbound.CropService, log p9log.Logger) *CropConsumer {
	return &CropConsumer{
		svc: svc,
		log: p9log.NewHelper(p9log.With(log, "component", "CropConsumer")),
	}
}

// Topic returns the Kafka topic this consumer listens on.
func (c *CropConsumer) Topic() string { return CropEventTopic }

// HandleEvent dispatches an incoming domain event.
func (c *CropConsumer) HandleEvent(ctx context.Context, event *domain.DomainEvent) error {
	if event == nil {
		return fmt.Errorf("received nil event")
	}
	c.log.Infow("msg", "crop event received",
		"event_id", event.ID,
		"event_type", string(event.Type),
		"aggregate_id", event.AggregateID,
	)
	switch event.Type {
	case "agriculture.crop.created":
		return c.onCropCreated(ctx, event)
	case "agriculture.crop.updated":
		return c.onCropUpdated(ctx, event)
	case "agriculture.crop.deleted":
		return c.onCropDeleted(ctx, event)
	default:
		c.log.Infow("msg", "unhandled event type", "type", event.Type)
		return nil
	}
}

func (c *CropConsumer) onCropCreated(_ context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return err
	}
	c.log.Infow("msg", "crop created event", "crop_id", data["crop_id"])
	return nil
}

func (c *CropConsumer) onCropUpdated(_ context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return err
	}
	c.log.Infow("msg", "crop updated event", "crop_id", data["crop_id"])
	return nil
}

func (c *CropConsumer) onCropDeleted(_ context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return err
	}
	c.log.Infow("msg", "crop deleted event", "crop_id", data["crop_id"])
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
