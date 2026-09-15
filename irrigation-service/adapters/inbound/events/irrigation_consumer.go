// Package events contains the inbound Kafka consumer adapter for irrigation-service.
// It subscribes to events from OTHER services that the irrigation-service needs to react to:
// sensor events (soil moisture data), field events (irrigation zones per field),
// and soil events (soil data affecting irrigation decisions).
package events

import (
	"context"
	"encoding/json"
	"fmt"

	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9log"

	"p9e.in/samavaya/agriculture/irrigation-service/internal/ports/inbound"
)

// Topics from OTHER services that irrigation-service consumes.
const (
	SensorEventTopic = "samavaya.agriculture.sensor.events"
	FieldEventTopic  = "samavaya.agriculture.field.events"
	SoilEventTopic   = "samavaya.agriculture.soil.events"
)

// IrrigationConsumer is the inbound Kafka adapter that reacts to cross-service domain events.
type IrrigationConsumer struct {
	svc inbound.IrrigationService
	log *p9log.Helper
}

// NewIrrigationConsumer creates a new Kafka consumer for cross-service events.
func NewIrrigationConsumer(svc inbound.IrrigationService, log p9log.Logger) *IrrigationConsumer {
	return &IrrigationConsumer{
		svc: svc,
		log: p9log.NewHelper(p9log.With(log, "component", "IrrigationConsumer")),
	}
}

// Topics returns the Kafka topics this consumer listens on.
func (c *IrrigationConsumer) Topics() []string {
	return []string{SensorEventTopic, FieldEventTopic, SoilEventTopic}
}

// HandleEvent dispatches an incoming domain event.
func (c *IrrigationConsumer) HandleEvent(ctx context.Context, event *domain.DomainEvent) error {
	if event == nil {
		return fmt.Errorf("received nil event")
	}
	c.log.Infow("msg", "cross-service event received",
		"event_id", event.ID,
		"event_type", string(event.Type),
		"aggregate_id", event.AggregateID,
	)

	switch event.Type {
	// Sensor events: soil moisture data drives irrigation decisions
	case domain.EventTypeSensorCreated:
		return c.onSensorDeployed(ctx, event)
	case domain.EventTypeSensorUpdated:
		return c.onSensorUpdated(ctx, event)

	// Field events: fields need irrigation zones
	case domain.EventTypeFieldCreated:
		return c.onFieldCreated(ctx, event)
	case domain.EventTypeFieldDeleted:
		return c.onFieldDeleted(ctx, event)

	// Soil events: soil characteristics affect irrigation scheduling
	case domain.EventTypeSoilSampleCreated:
		return c.onSoilSampleCreated(ctx, event)

	default:
		c.log.Infow("msg", "unhandled event type", "type", string(event.Type))
		return nil
	}
}

// onSensorDeployed handles a moisture sensor being deployed.
// Irrigation-service uses moisture data for smart scheduling.
func (c *IrrigationConsumer) onSensorDeployed(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onSensorDeployed: %w", err)
	}
	sensorID, _ := data["sensor_id"].(string)
	fieldID, _ := data["field_id"].(string)
	c.log.Infow("msg", "sensor deployed, may provide moisture data for irrigation",
		"sensor_id", sensorID,
		"field_id", fieldID,
	)
	// TODO: register sensor as moisture data source for irrigation decisions
	return nil
}

// onSensorUpdated handles a sensor calibration or configuration change.
func (c *IrrigationConsumer) onSensorUpdated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onSensorUpdated: %w", err)
	}
	sensorID, _ := data["sensor_id"].(string)
	c.log.Infow("msg", "sensor updated, adjusting irrigation thresholds",
		"sensor_id", sensorID,
	)
	// TODO: recalibrate irrigation decision thresholds
	return nil
}

// onFieldCreated handles a new field being created.
// Irrigation-service may create default irrigation zones for the field.
func (c *IrrigationConsumer) onFieldCreated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onFieldCreated: %w", err)
	}
	fieldID, _ := data["field_id"].(string)
	farmID, _ := data["farm_id"].(string)
	c.log.Infow("msg", "field created, may need irrigation zone setup",
		"field_id", fieldID,
		"farm_id", farmID,
	)
	// TODO: call c.svc.CreateZone to set up default irrigation zone for the field
	return nil
}

// onFieldDeleted handles a field being deleted.
// Irrigation zones and schedules for this field should be cancelled.
func (c *IrrigationConsumer) onFieldDeleted(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onFieldDeleted: %w", err)
	}
	fieldID, _ := data["field_id"].(string)
	c.log.Infow("msg", "field deleted, cancelling irrigation schedules",
		"field_id", fieldID,
	)
	// TODO: list zones and schedules by field, cancel active schedules
	return nil
}

// onSoilSampleCreated handles new soil data that affects irrigation decisions.
// Soil water-holding capacity affects how much water is needed.
func (c *IrrigationConsumer) onSoilSampleCreated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onSoilSampleCreated: %w", err)
	}
	fieldID, _ := data["field_id"].(string)
	c.log.Infow("msg", "soil data available, updating irrigation parameters",
		"field_id", fieldID,
	)
	// TODO: call c.svc.RequestDecision to recalculate irrigation based on new soil data
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
