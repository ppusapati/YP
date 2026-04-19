// Package events contains the inbound Kafka event consumer adapter for farm events.
// It decodes incoming Kafka messages and dispatches to the inbound.FarmService port.
package events

import (
	"context"
	"encoding/json"
	"fmt"

	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9log"

	"p9e.in/samavaya/agriculture/farm-service/internal/ports/inbound"
)

// FarmEventTopic is the Kafka topic for farm domain events.
const FarmEventTopic = "samavaya.agriculture.farm.events"

// FarmConsumer is the inbound Kafka adapter for farm domain events.
// It converts raw Kafka messages into domain calls on the FarmService port.
type FarmConsumer struct {
	svc inbound.FarmService
	log *p9log.Helper
}

// NewFarmConsumer creates a new Kafka consumer for farm events.
func NewFarmConsumer(svc inbound.FarmService, log p9log.Logger) *FarmConsumer {
	return &FarmConsumer{
		svc: svc,
		log: p9log.NewHelper(p9log.With(log, "component", "FarmConsumer")),
	}
}

// Topic returns the Kafka topic this consumer listens on.
func (c *FarmConsumer) Topic() string { return FarmEventTopic }

// HandleEvent dispatches an incoming domain event to the appropriate handler.
func (c *FarmConsumer) HandleEvent(ctx context.Context, event *domain.DomainEvent) error {
	if event == nil {
		return fmt.Errorf("received nil event")
	}
	c.log.Infow("msg", "farm event received",
		"event_id", event.ID,
		"event_type", string(event.Type),
		"aggregate_id", event.AggregateID,
	)

	switch event.Type {
	case "agriculture.farm.created":
		return c.onFarmCreated(ctx, event)
	case "agriculture.farm.updated":
		return c.onFarmUpdated(ctx, event)
	case "agriculture.farm.deleted":
		return c.onFarmDeleted(ctx, event)
	case "agriculture.farm.boundary.set":
		return c.onBoundarySet(ctx, event)
	case "agriculture.farm.ownership.transferred":
		return c.onOwnershipTransferred(ctx, event)
	default:
		c.log.Infow("msg", "unhandled event type", "type", event.Type)
		return nil
	}
}

func (c *FarmConsumer) onFarmCreated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return err
	}
	c.log.Infow("msg", "farm created event",
		"farm_id", data["farm_id"],
		"tenant_id", data["tenant_id"],
		"name", data["name"],
	)
	// Downstream reactions (e.g. cache warm-up, analytics) go here.
	return nil
}

func (c *FarmConsumer) onFarmUpdated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return err
	}
	c.log.Infow("msg", "farm updated event", "farm_id", data["farm_id"])
	return nil
}

func (c *FarmConsumer) onFarmDeleted(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return err
	}
	c.log.Infow("msg", "farm deleted event", "farm_id", data["farm_id"])
	return nil
}

func (c *FarmConsumer) onBoundarySet(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return err
	}
	c.log.Infow("msg", "boundary set event", "farm_id", data["farm_id"], "boundary_id", data["boundary_id"])
	return nil
}

func (c *FarmConsumer) onOwnershipTransferred(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return err
	}
	c.log.Infow("msg", "ownership transferred event",
		"farm_id", data["farm_id"],
		"from_user_id", data["from_user_id"],
		"to_user_id", data["to_user_id"],
	)
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
