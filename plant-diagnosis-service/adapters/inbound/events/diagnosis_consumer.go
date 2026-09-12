// Package events contains the inbound Kafka consumer adapter for plant-diagnosis-service.
// It subscribes to events from OTHER services that the plant-diagnosis-service needs to react to:
// sensor events (plant health indicators), crop events (diagnosis linked to crops),
// and pest-prediction events (pest alerts triggering diagnosis workflow).
package events

import (
	"context"
	"encoding/json"
	"fmt"

	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9log"

	"p9e.in/samavaya/agriculture/plant-diagnosis-service/internal/ports/inbound"
)

// Topics from OTHER services that plant-diagnosis-service consumes.
const (
	SensorEventTopic         = "samavaya.agriculture.sensor.events"
	CropEventTopic           = "samavaya.agriculture.crop.events"
	PestPredictionEventTopic = "samavaya.agriculture.pest-prediction.events"
)

// DiagnosisConsumer is the inbound Kafka adapter that reacts to cross-service domain events.
type DiagnosisConsumer struct {
	svc inbound.DiagnosisService
	log *p9log.Helper
}

// NewDiagnosisConsumer creates a new Kafka consumer for cross-service events.
func NewDiagnosisConsumer(svc inbound.DiagnosisService, log p9log.Logger) *DiagnosisConsumer {
	return &DiagnosisConsumer{
		svc: svc,
		log: p9log.NewHelper(p9log.With(log, "component", "DiagnosisConsumer")),
	}
}

// Topics returns the Kafka topics this consumer listens on.
func (c *DiagnosisConsumer) Topics() []string {
	return []string{SensorEventTopic, CropEventTopic, PestPredictionEventTopic}
}

// HandleEvent dispatches an incoming domain event.
func (c *DiagnosisConsumer) HandleEvent(ctx context.Context, event *domain.DomainEvent) error {
	if event == nil {
		return fmt.Errorf("received nil event")
	}
	c.log.Infow("msg", "cross-service event received",
		"event_id", event.ID,
		"event_type", string(event.Type),
		"aggregate_id", event.AggregateID,
	)

	switch event.Type {
	// Sensor events: sensor readings may indicate plant health issues
	case domain.EventTypeSensorCreated:
		return c.onSensorDeployed(ctx, event)
	case domain.EventTypeSensorUpdated:
		return c.onSensorUpdated(ctx, event)

	// Crop events: diagnosis is linked to specific crop types
	case domain.EventTypeCropCreated:
		return c.onCropCreated(ctx, event)

	// Pest prediction events: pest alerts may trigger diagnosis workflow
	case domain.EventTypePestPredictionCreated:
		return c.onPestPredictionCreated(ctx, event)

	default:
		c.log.Infow("msg", "unhandled event type", "type", string(event.Type))
		return nil
	}
}

// onSensorDeployed handles a sensor being deployed that may provide plant health data.
func (c *DiagnosisConsumer) onSensorDeployed(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onSensorDeployed: %w", err)
	}
	sensorID, _ := data["sensor_id"].(string)
	fieldID, _ := data["field_id"].(string)
	c.log.Infow("msg", "sensor deployed, may provide plant health indicators",
		"sensor_id", sensorID,
		"field_id", fieldID,
	)
	// TODO: register sensor as plant health data source
	return nil
}

// onSensorUpdated handles a sensor being recalibrated.
func (c *DiagnosisConsumer) onSensorUpdated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onSensorUpdated: %w", err)
	}
	sensorID, _ := data["sensor_id"].(string)
	c.log.Infow("msg", "sensor updated, adjusting health thresholds",
		"sensor_id", sensorID,
	)
	// TODO: update diagnostic thresholds based on sensor calibration
	return nil
}

// onCropCreated handles a new crop type being registered.
// Plant-diagnosis-service needs to load disease profiles for the crop.
func (c *DiagnosisConsumer) onCropCreated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onCropCreated: %w", err)
	}
	cropID, _ := data["crop_id"].(string)
	c.log.Infow("msg", "new crop type, loading disease profiles",
		"crop_id", cropID,
	)
	// TODO: load known diseases and nutrient deficiency patterns for this crop
	return nil
}

// onPestPredictionCreated handles a pest prediction alert.
// A pest alert may trigger proactive plant diagnosis in affected fields.
func (c *DiagnosisConsumer) onPestPredictionCreated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onPestPredictionCreated: %w", err)
	}
	predictionID, _ := data["pest_prediction_id"].(string)
	fieldID, _ := data["field_id"].(string)
	riskLevel, _ := data["risk_level"].(string)
	c.log.Infow("msg", "pest prediction alert, may trigger proactive diagnosis",
		"prediction_id", predictionID,
		"field_id", fieldID,
		"risk_level", riskLevel,
	)
	// TODO: if risk is high, trigger proactive plant diagnosis via c.svc.DetectPestDamage
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
