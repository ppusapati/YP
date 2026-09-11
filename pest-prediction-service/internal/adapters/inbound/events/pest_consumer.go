// Package events contains the inbound Kafka consumer adapter for pest-prediction-service.
// It subscribes to events from OTHER services that the pest-prediction-service needs to react to:
// sensor events (weather/humidity data), crop events (crop type affects pest models),
// and satellite events (satellite pest detection).
package events

import (
	"context"
	"encoding/json"
	"fmt"

	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9log"

	"p9e.in/samavaya/agriculture/pest-prediction-service/internal/ports/inbound"
)

// Topics from OTHER services that pest-prediction-service consumes.
const (
	SensorEventTopic    = "samavaya.agriculture.sensor.events"
	CropEventTopic      = "samavaya.agriculture.crop.events"
	FieldEventTopic     = "samavaya.agriculture.field.events"
	SatelliteEventTopic = "samavaya.agriculture.satellite.events"
)

// PestConsumer is the inbound Kafka adapter that reacts to cross-service domain events.
type PestConsumer struct {
	svc inbound.PestService
	log *p9log.Helper
}

// NewPestConsumer creates a new Kafka consumer for cross-service events.
func NewPestConsumer(svc inbound.PestService, log p9log.Logger) *PestConsumer {
	return &PestConsumer{
		svc: svc,
		log: p9log.NewHelper(p9log.With(log, "component", "PestConsumer")),
	}
}

// Topics returns the Kafka topics this consumer listens on.
func (c *PestConsumer) Topics() []string {
	return []string{SensorEventTopic, CropEventTopic, FieldEventTopic, SatelliteEventTopic}
}

// HandleEvent dispatches an incoming domain event.
func (c *PestConsumer) HandleEvent(ctx context.Context, event *domain.DomainEvent) error {
	if event == nil {
		return fmt.Errorf("received nil event")
	}
	c.log.Infow("msg", "cross-service event received",
		"event_id", event.ID,
		"event_type", string(event.Type),
		"aggregate_id", event.AggregateID,
	)

	switch event.Type {
	// Sensor events: weather/humidity data feeds pest prediction models
	case domain.EventTypeSensorCreated:
		return c.onSensorDeployed(ctx, event)
	case domain.EventTypeSensorUpdated:
		return c.onSensorUpdated(ctx, event)

	// Crop events: crop type and lifecycle affect pest risk
	case domain.EventTypeCropCreated:
		return c.onCropCreated(ctx, event)
	case domain.EventTypeFieldCropAssigned:
		return c.onFieldCropAssigned(ctx, event)

	// Satellite events: satellite imagery can detect pest outbreaks
	case domain.EventTypeSatelliteImageCreated:
		return c.onSatelliteImageCreated(ctx, event)

	default:
		c.log.Infow("msg", "unhandled event type", "type", string(event.Type))
		return nil
	}
}

// onSensorDeployed handles a weather or environmental sensor being deployed.
func (c *PestConsumer) onSensorDeployed(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onSensorDeployed: %w", err)
	}
	sensorID, _ := data["sensor_id"].(string)
	fieldID, _ := data["field_id"].(string)
	c.log.Infow("msg", "sensor deployed, may provide weather data for pest models",
		"sensor_id", sensorID,
		"field_id", fieldID,
	)
	// TODO: register sensor as environmental data source for pest prediction
	return nil
}

// onSensorUpdated handles a sensor calibration or configuration change.
func (c *PestConsumer) onSensorUpdated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onSensorUpdated: %w", err)
	}
	sensorID, _ := data["sensor_id"].(string)
	c.log.Infow("msg", "sensor updated, adjusting pest prediction parameters",
		"sensor_id", sensorID,
	)
	// TODO: recalibrate pest prediction model inputs
	return nil
}

// onCropCreated handles a new crop type being registered.
// Different crops have different pest vulnerability profiles.
func (c *PestConsumer) onCropCreated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onCropCreated: %w", err)
	}
	cropID, _ := data["crop_id"].(string)
	c.log.Infow("msg", "new crop type, loading pest vulnerability profile",
		"crop_id", cropID,
	)
	// TODO: load pest species that commonly affect this crop type
	return nil
}

// onFieldCropAssigned handles a crop being assigned to a field.
// Triggers pest risk assessment for the specific crop-field combination.
func (c *PestConsumer) onFieldCropAssigned(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onFieldCropAssigned: %w", err)
	}
	fieldID, _ := data["field_id"].(string)
	cropID, _ := data["crop_id"].(string)
	c.log.Infow("msg", "crop assigned to field, generating pest risk assessment",
		"field_id", fieldID,
		"crop_id", cropID,
	)
	// TODO: call c.svc.PredictPestRisk for the crop-field combination
	return nil
}

// onSatelliteImageCreated handles new satellite imagery that may detect pest damage.
func (c *PestConsumer) onSatelliteImageCreated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onSatelliteImageCreated: %w", err)
	}
	fieldID, _ := data["field_id"].(string)
	imageID, _ := data["satellite_id"].(string)
	c.log.Infow("msg", "satellite imagery available for pest detection",
		"field_id", fieldID,
		"image_id", imageID,
	)
	// TODO: analyze satellite imagery for pest outbreak indicators
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
