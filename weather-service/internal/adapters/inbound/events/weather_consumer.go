// Package events contains the inbound Kafka consumer adapter for weather-service.
// It reacts to field lifecycle events so every field with a boundary gets a
// weather location registered without a manual RPC call.
package events

import (
	"context"
	"fmt"

	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9log"

	"p9e.in/samavaya/agriculture/weather-service/internal/ports/inbound"
)

// FieldEventTopic is the field-service event stream.
const FieldEventTopic = "samavaya.agriculture.field.events"

// WeatherConsumer is the inbound Kafka adapter for cross-service events.
type WeatherConsumer struct {
	svc inbound.WeatherService
	log *p9log.Helper
}

// NewWeatherConsumer creates a new consumer.
func NewWeatherConsumer(svc inbound.WeatherService, log p9log.Logger) *WeatherConsumer {
	return &WeatherConsumer{
		svc: svc,
		log: p9log.NewHelper(p9log.With(log, "component", "WeatherConsumer")),
	}
}

// Topics returns the Kafka topics this consumer listens on.
func (c *WeatherConsumer) Topics() []string {
	return []string{FieldEventTopic}
}

// HandleEvent dispatches an incoming domain event.
func (c *WeatherConsumer) HandleEvent(ctx context.Context, event *domain.DomainEvent) error {
	if event == nil {
		return fmt.Errorf("received nil event")
	}
	switch event.Type {
	case domain.EventTypeFieldCreated, domain.EventTypeFieldUpdated:
		return c.onFieldChanged(ctx, event)
	default:
		return nil
	}
}

func (c *WeatherConsumer) onFieldChanged(ctx context.Context, event *domain.DomainEvent) error {
	tenantID, _ := event.Data["tenant_id"].(string)
	fieldID, _ := event.Data["field_id"].(string)
	if fieldID == "" {
		fieldID = event.AggregateID
	}
	if tenantID == "" || fieldID == "" {
		c.log.Warnw("msg", "field event missing tenant or field id", "event_id", event.ID)
		return nil
	}
	if _, err := c.svc.RegisterFieldFromFieldService(ctx, tenantID, fieldID); err != nil {
		// Fields without a boundary yet are expected; log and move on rather than retry forever.
		c.log.Warnw("msg", "could not register weather location for field", "field_id", fieldID, "tenant_id", tenantID, "error", err)
		return nil
	}
	c.log.Infow("msg", "weather location registered from field event", "field_id", fieldID, "tenant_id", tenantID)
	return nil
}
