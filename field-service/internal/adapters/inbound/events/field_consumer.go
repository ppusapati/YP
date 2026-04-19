// Package events contains the inbound Kafka event consumer adapter for field events.
package events

import (
"context"
"encoding/json"
"fmt"

"p9e.in/samavaya/packages/events/domain"
"p9e.in/samavaya/packages/p9log"

"p9e.in/samavaya/agriculture/field-service/internal/ports/inbound"
)

const FieldEventTopic = "samavaya.agriculture.field.events"

// FieldConsumer is the inbound Kafka adapter for field domain events.
type FieldConsumer struct {
svc inbound.FieldService
log *p9log.Helper
}

// NewFieldConsumer creates a new Kafka consumer for field events.
func NewFieldConsumer(svc inbound.FieldService, log p9log.Logger) *FieldConsumer {
return &FieldConsumer{
svc: svc,
log: p9log.NewHelper(p9log.With(log, "component", "FieldConsumer")),
}
}

// Topic returns the Kafka topic this consumer listens on.
func (c *FieldConsumer) Topic() string { return FieldEventTopic }

// HandleEvent dispatches an incoming domain event to the appropriate handler.
func (c *FieldConsumer) HandleEvent(ctx context.Context, event *domain.DomainEvent) error {
if event == nil {
return fmt.Errorf("received nil event")
}
c.log.Infow("msg", "field event received",
"event_id", event.ID,
"event_type", string(event.Type),
"aggregate_id", event.AggregateID,
)

switch event.Type {
case "agriculture.field.created":
return c.onFieldCreated(ctx, event)
case "agriculture.field.updated":
return c.onFieldUpdated(ctx, event)
case "agriculture.field.deleted":
return c.onFieldDeleted(ctx, event)
case "agriculture.field.crop.assigned":
return c.onCropAssigned(ctx, event)
default:
c.log.Infow("msg", "unhandled event type", "type", event.Type)
return nil
}
}

func (c *FieldConsumer) onFieldCreated(_ context.Context, event *domain.DomainEvent) error {
data, err := extractEventData(event)
if err != nil {
return err
}
c.log.Infow("msg", "field created event", "field_id", data["field_id"])
return nil
}

func (c *FieldConsumer) onFieldUpdated(_ context.Context, event *domain.DomainEvent) error {
data, err := extractEventData(event)
if err != nil {
return err
}
c.log.Infow("msg", "field updated event", "field_id", data["field_id"])
return nil
}

func (c *FieldConsumer) onFieldDeleted(_ context.Context, event *domain.DomainEvent) error {
data, err := extractEventData(event)
if err != nil {
return err
}
c.log.Infow("msg", "field deleted event", "field_id", data["field_id"])
return nil
}

func (c *FieldConsumer) onCropAssigned(_ context.Context, event *domain.DomainEvent) error {
data, err := extractEventData(event)
if err != nil {
return err
}
c.log.Infow("msg", "crop assigned to field", "field_id", data["field_id"], "crop_id", data["crop_id"])
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
