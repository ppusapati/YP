package handlers

import (
	"context"
	"encoding/json"
	"fmt"

	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9log"
)

// Sensor event type constants matching those in services.
const (
	EventTypeSensorRegistered      domain.EventType = "agriculture.sensor.registered"
	EventTypeSensorReadingIngested domain.EventType = "agriculture.sensor.reading.ingested"
	EventTypeSensorAlertTriggered  domain.EventType = "agriculture.sensor.alert.triggered"
	EventTypeSensorDecommissioned  domain.EventType = "agriculture.sensor.decommissioned"
	EventTypeSensorCalibrated      domain.EventType = "agriculture.sensor.calibrated"
)

// SensorEventData represents the data payload for sensor lifecycle events.
type SensorEventData struct {
	SensorID   string `json:"sensor_id"`
	FieldID    string `json:"field_id,omitempty"`
	FarmID     string `json:"farm_id,omitempty"`
	TenantID   string `json:"tenant_id,omitempty"`
	SensorType string `json:"sensor_type,omitempty"`
	Status     string `json:"status,omitempty"`
}

// ReadingEventData represents the data payload for reading ingestion events.
type ReadingEventData struct {
	SensorID string  `json:"sensor_id"`
	Value    float64 `json:"value"`
	Unit     string  `json:"unit,omitempty"`
	Quality  string  `json:"quality,omitempty"`
}

// AlertEventData represents the data payload for alert triggered events.
type AlertEventData struct {
	AlertID     string  `json:"alert_id"`
	SensorID    string  `json:"sensor_id"`
	SensorType  string  `json:"sensor_type,omitempty"`
	FieldID     string  `json:"field_id,omitempty"`
	Condition   string  `json:"condition,omitempty"`
	Threshold   float64 `json:"threshold"`
	ActualValue float64 `json:"actual_value"`
	Severity    string  `json:"severity,omitempty"`
}

// CalibrationEventData represents the data payload for sensor calibration events.
type CalibrationEventData struct {
	SensorID     string  `json:"sensor_id"`
	Offset       float64 `json:"offset"`
	ScaleFactor  float64 `json:"scale_factor"`
	CalibratedBy string  `json:"calibrated_by,omitempty"`
}

// SensorEventHandler handles incoming sensor-related domain events (consumer side).
type SensorEventHandler struct {
	d   deps.ServiceDeps
	log *p9log.Helper
}

// NewSensorEventHandler creates a new SensorEventHandler for consuming sensor events.
func NewSensorEventHandler(d deps.ServiceDeps) *SensorEventHandler {
	return &SensorEventHandler{
		d:   d,
		log: p9log.NewHelper(p9log.With(d.Log, "component", "SensorEventHandler")),
	}
}

// HandleEvent is the entry point for consuming a sensor domain event.
// It dispatches to the appropriate handler based on event type.
func (h *SensorEventHandler) HandleEvent(ctx context.Context, event *domain.DomainEvent) error {
	if event == nil {
		return fmt.Errorf("received nil event")
	}

	h.log.Infow("msg", "handling sensor event",
		"event_id", event.ID,
		"event_type", string(event.Type),
		"aggregate_id", event.AggregateID,
	)

	switch event.Type {
	case EventTypeSensorRegistered:
		return h.handleSensorRegistered(ctx, event)
	case EventTypeSensorReadingIngested:
		return h.handleReadingIngested(ctx, event)
	case EventTypeSensorAlertTriggered:
		return h.handleAlertTriggered(ctx, event)
	case EventTypeSensorDecommissioned:
		return h.handleSensorDecommissioned(ctx, event)
	case EventTypeSensorCalibrated:
		return h.handleSensorCalibrated(ctx, event)
	default:
		h.log.Warnf("unhandled sensor event type: %s", event.Type)
		return nil
	}
}

// handleSensorRegistered processes a sensor registered event.
func (h *SensorEventHandler) handleSensorRegistered(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractSensorEventData(event)
	if err != nil {
		h.log.Errorw("msg", "failed to extract sensor registered event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "sensor registered event received",
		"sensor_id", data.SensorID,
		"sensor_type", data.SensorType,
		"field_id", data.FieldID,
		"farm_id", data.FarmID,
		"tenant_id", data.TenantID,
	)

	// Downstream consumers can react here:
	// - Notify farm-service of new sensor deployment
	// - Initialize monitoring dashboards
	// - Configure default alert thresholds based on sensor type
	// - Update field-service with sensor coverage metadata

	return nil
}

// handleReadingIngested processes a sensor reading ingested event.
func (h *SensorEventHandler) handleReadingIngested(ctx context.Context, event *domain.DomainEvent) error {
	readingData := &ReadingEventData{}
	raw, _ := json.Marshal(event.Data)
	if err := json.Unmarshal(raw, readingData); err != nil {
		h.log.Errorw("msg", "failed to extract reading ingested event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "sensor reading ingested event received",
		"sensor_id", readingData.SensorID,
		"value", readingData.Value,
		"unit", readingData.Unit,
		"quality", readingData.Quality,
	)

	// Downstream consumers can react here:
	// - Feed data to soil-service for soil moisture analysis
	// - Update weather-service aggregation pipelines
	// - Trigger irrigation-service scheduling adjustments
	// - Update real-time analytics dashboards

	return nil
}

// handleAlertTriggered processes a sensor alert triggered event.
func (h *SensorEventHandler) handleAlertTriggered(ctx context.Context, event *domain.DomainEvent) error {
	alertData := &AlertEventData{}
	raw, _ := json.Marshal(event.Data)
	if err := json.Unmarshal(raw, alertData); err != nil {
		h.log.Errorw("msg", "failed to extract alert triggered event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "sensor alert triggered event received",
		"alert_id", alertData.AlertID,
		"sensor_id", alertData.SensorID,
		"sensor_type", alertData.SensorType,
		"condition", alertData.Condition,
		"threshold", alertData.Threshold,
		"actual_value", alertData.ActualValue,
		"severity", alertData.Severity,
	)

	// Downstream consumers can react here:
	// - Send push notifications to farm operators
	// - Trigger automated irrigation responses for moisture alerts
	// - Log to audit trail for compliance reporting
	// - Escalate critical alerts to farm management dashboard

	return nil
}

// handleSensorDecommissioned processes a sensor decommissioned event.
func (h *SensorEventHandler) handleSensorDecommissioned(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractSensorEventData(event)
	if err != nil {
		h.log.Errorw("msg", "failed to extract sensor decommissioned event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "sensor decommissioned event received",
		"sensor_id", data.SensorID,
		"field_id", data.FieldID,
		"farm_id", data.FarmID,
		"tenant_id", data.TenantID,
	)

	// Downstream consumers can react here:
	// - Update field-service to remove sensor coverage mapping
	// - Archive historical readings for the sensor
	// - Notify maintenance team for device retrieval
	// - Update sensor network topology in monitoring systems

	return nil
}

// handleSensorCalibrated processes a sensor calibrated event.
func (h *SensorEventHandler) handleSensorCalibrated(ctx context.Context, event *domain.DomainEvent) error {
	calData := &CalibrationEventData{}
	raw, _ := json.Marshal(event.Data)
	if err := json.Unmarshal(raw, calData); err != nil {
		h.log.Errorw("msg", "failed to extract sensor calibrated event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "sensor calibrated event received",
		"sensor_id", calData.SensorID,
		"offset", calData.Offset,
		"scale_factor", calData.ScaleFactor,
		"calibrated_by", calData.CalibratedBy,
	)

	// Downstream consumers can react here:
	// - Recalculate historical readings with new calibration parameters
	// - Update sensor accuracy metrics in monitoring dashboards
	// - Notify dependent services of calibration change
	// - Schedule next calibration reminder

	return nil
}

// extractSensorEventData extracts SensorEventData from a domain event's Data map.
func extractSensorEventData(event *domain.DomainEvent) (*SensorEventData, error) {
	data := &SensorEventData{}
	raw, err := json.Marshal(event.Data)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal event data: %w", err)
	}
	if err := json.Unmarshal(raw, data); err != nil {
		return nil, fmt.Errorf("failed to unmarshal event data: %w", err)
	}
	return data, nil
}

// RegisterSensorEventConsumer registers the sensor event handler with the Kafka consumer.
// This should be called during service initialization.
func RegisterSensorEventConsumer(d deps.ServiceDeps) (*SensorEventHandler, error) {
	handler := NewSensorEventHandler(d)

	if d.KafkaConsumer == nil {
		handler.log.Warnf("Kafka consumer not configured, skipping event registration")
		return handler, nil
	}

	topic := "samavaya.agriculture.sensor.events"
	handler.log.Infow("msg", "registering sensor event consumer", "topic", topic)

	// The actual Kafka subscription is wired during application bootstrap.
	// The handler.HandleEvent method is the callback for incoming messages.

	return handler, nil
}

// IsSensorEvent checks if a domain event type belongs to the sensor domain.
func IsSensorEvent(eventType domain.EventType) bool {
	switch eventType {
	case EventTypeSensorRegistered,
		EventTypeSensorReadingIngested,
		EventTypeSensorAlertTriggered,
		EventTypeSensorDecommissioned,
		EventTypeSensorCalibrated:
		return true
	default:
		return false
	}
}
