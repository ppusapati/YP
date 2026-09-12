// Package events contains the inbound Kafka consumer adapter for soil-service.
// It subscribes to events from OTHER services that the soil-service needs to react to:
// sensor events (soil sensor readings) and field events (soil profiles linked to fields).
package events

import (
	"context"
	"encoding/json"
	"fmt"

	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9log"

	"p9e.in/samavaya/agriculture/soil-service/internal/ports/inbound"
)

// Topics from OTHER services that soil-service consumes.
const (
	SensorEventTopic = "samavaya.agriculture.sensor.events"
	FieldEventTopic  = "samavaya.agriculture.field.events"
)

// SoilConsumer is the inbound Kafka adapter that reacts to cross-service domain events.
type SoilConsumer struct {
	svc inbound.SoilService
	log *p9log.Helper
}

// NewSoilConsumer creates a new Kafka consumer for cross-service events.
func NewSoilConsumer(svc inbound.SoilService, log p9log.Logger) *SoilConsumer {
	return &SoilConsumer{
		svc: svc,
		log: p9log.NewHelper(p9log.With(log, "component", "SoilConsumer")),
	}
}

// Topics returns the Kafka topics this consumer listens on.
func (c *SoilConsumer) Topics() []string {
	return []string{SensorEventTopic, FieldEventTopic}
}

// HandleEvent dispatches an incoming domain event.
func (c *SoilConsumer) HandleEvent(ctx context.Context, event *domain.DomainEvent) error {
	if event == nil {
		return fmt.Errorf("received nil event")
	}
	c.log.Infow("msg", "cross-service event received",
		"event_id", event.ID,
		"event_type", string(event.Type),
		"aggregate_id", event.AggregateID,
	)

	switch event.Type {
	// Sensor events: soil sensors provide data for analysis
	case domain.EventTypeSensorCreated:
		return c.onSensorDeployed(ctx, event)
	case domain.EventTypeSensorUpdated:
		return c.onSensorUpdated(ctx, event)

	// Field events: soil profiles are linked to fields
	case domain.EventTypeFieldCreated:
		return c.onFieldCreated(ctx, event)
	case domain.EventTypeFieldDeleted:
		return c.onFieldDeleted(ctx, event)

	default:
		c.log.Infow("msg", "unhandled event type", "type", string(event.Type))
		return nil
	}
}

// onSensorDeployed handles a new soil sensor being deployed.
func (c *SoilConsumer) onSensorDeployed(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onSensorDeployed: %w", err)
	}
	sensorID, _ := data["sensor_id"].(string)
	fieldID, _ := data["field_id"].(string)
	sensorType, _ := data["sensor_type"].(string)
	c.log.Infow("msg", "sensor deployed, may provide soil readings",
		"sensor_id", sensorID,
		"field_id", fieldID,
		"sensor_type", sensorType,
	)
	// TODO: if sensor_type is soil-related, register it as a soil data source
	return nil
}

// onSensorUpdated handles a sensor being recalibrated or updated.
func (c *SoilConsumer) onSensorUpdated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onSensorUpdated: %w", err)
	}
	sensorID, _ := data["sensor_id"].(string)
	c.log.Infow("msg", "sensor updated, adjusting soil data calibration",
		"sensor_id", sensorID,
	)
	// TODO: update soil measurement calibration offsets
	return nil
}

// onFieldCreated handles a new field being created.
// Soil-service can prepare soil profile and baseline analysis.
func (c *SoilConsumer) onFieldCreated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onFieldCreated: %w", err)
	}
	fieldID, _ := data["field_id"].(string)
	c.log.Infow("msg", "field created, preparing soil profile",
		"field_id", fieldID,
	)
	// TODO: initialize soil profile for the new field
	return nil
}

// onFieldDeleted handles a field being deleted.
func (c *SoilConsumer) onFieldDeleted(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onFieldDeleted: %w", err)
	}
	fieldID, _ := data["field_id"].(string)
	c.log.Infow("msg", "field deleted, archiving soil data",
		"field_id", fieldID,
	)
	// TODO: archive soil samples/analyses for the deleted field
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
