// Package events contains the inbound Kafka consumer adapter for plant-diagnosis-service events.
package events

import (
	"context"
	"encoding/json"
	"fmt"

	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9log"

	"p9e.in/samavaya/agriculture/plant-diagnosis-service/internal/ports/inbound"
)

const DiagnosisEventTopic = "samavaya.agriculture.plant-diagnosis.events"

// DiagnosisConsumer is the inbound Kafka adapter for plant-diagnosis-service domain events.
type DiagnosisConsumer struct {
	svc inbound.DiagnosisService
	log *p9log.Helper
}

// NewDiagnosisConsumer creates a new Kafka consumer for diagnosis events.
func NewDiagnosisConsumer(svc inbound.DiagnosisService, log p9log.Logger) *DiagnosisConsumer {
	return &DiagnosisConsumer{
		svc: svc,
		log: p9log.NewHelper(p9log.With(log, "component", "DiagnosisConsumer")),
	}
}

// Topic returns the Kafka topic this consumer listens on.
func (c *DiagnosisConsumer) Topic() string { return DiagnosisEventTopic }

// HandleEvent dispatches an incoming domain event.
func (c *DiagnosisConsumer) HandleEvent(ctx context.Context, event *domain.DomainEvent) error {
	if event == nil {
		return fmt.Errorf("received nil event")
	}
	c.log.Infow("msg", "diagnosis event received",
		"event_id", event.ID,
		"event_type", string(event.Type),
		"aggregate_id", event.AggregateID,
	)
	switch event.Type {
	case "agriculture.plant-diagnosis.created":
		return c.onDiagnosisCreated(ctx, event)
	case "agriculture.plant-diagnosis.updated":
		return c.onDiagnosisUpdated(ctx, event)
	case "agriculture.plant-diagnosis.deleted":
		return c.onDiagnosisDeleted(ctx, event)
	default:
		c.log.Infow("msg", "unhandled event type", "type", event.Type)
		return nil
	}
}

func (c *DiagnosisConsumer) onDiagnosisCreated(_ context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return err
	}
	c.log.Infow("msg", "diagnosis created event", "plant_diagnosis_id", data["plant_diagnosis_id"])
	return nil
}

func (c *DiagnosisConsumer) onDiagnosisUpdated(_ context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return err
	}
	c.log.Infow("msg", "diagnosis updated event", "plant_diagnosis_id", data["plant_diagnosis_id"])
	return nil
}

func (c *DiagnosisConsumer) onDiagnosisDeleted(_ context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return err
	}
	c.log.Infow("msg", "diagnosis deleted event", "plant_diagnosis_id", data["plant_diagnosis_id"])
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
