package handlers

import (
	"context"
	"encoding/json"
	"fmt"

	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9log"
)

// Satellite event type constants matching those in services.
const (
	EventTypeSatelliteImageryRequested domain.EventType = "agriculture.satellite.imagery.requested"
	EventTypeSatelliteImageryReceived  domain.EventType = "agriculture.satellite.imagery.received"
	EventTypeSatelliteStressDetected   domain.EventType = "agriculture.satellite.stress.detected"
	EventTypeSatelliteAlertCreated     domain.EventType = "agriculture.satellite.alert.created"
)

// SatelliteEventData represents the data payload for satellite-related events.
type SatelliteEventData struct {
	TaskID            string  `json:"task_id,omitempty"`
	ImageID           string  `json:"image_id,omitempty"`
	AlertID           string  `json:"alert_id,omitempty"`
	TenantID          string  `json:"tenant_id"`
	FieldID           string  `json:"field_id"`
	FarmID            string  `json:"farm_id,omitempty"`
	SatelliteProvider string  `json:"satellite_provider,omitempty"`
	ResolutionMeters  float64 `json:"resolution_meters,omitempty"`
	IndexType         string  `json:"index_type,omitempty"`
	MeanValue         float64 `json:"mean_value,omitempty"`
	StressType        string  `json:"stress_type,omitempty"`
	StressSeverity    float64 `json:"stress_severity,omitempty"`
	AffectedAreaPct   float64 `json:"affected_area_pct,omitempty"`
	RequestedBy       string  `json:"requested_by,omitempty"`
}

// SatelliteEventHandler handles incoming satellite-related domain events (consumer side).
type SatelliteEventHandler struct {
	d   deps.ServiceDeps
	log *p9log.Helper
}

// NewSatelliteEventHandler creates a new SatelliteEventHandler for consuming satellite events.
func NewSatelliteEventHandler(d deps.ServiceDeps) *SatelliteEventHandler {
	return &SatelliteEventHandler{
		d:   d,
		log: p9log.NewHelper(p9log.With(d.Log, "component", "SatelliteEventHandler")),
	}
}

// HandleEvent is the entry point for consuming a satellite domain event.
// It dispatches to the appropriate handler based on event type.
func (h *SatelliteEventHandler) HandleEvent(ctx context.Context, event *domain.DomainEvent) error {
	if event == nil {
		return fmt.Errorf("received nil event")
	}

	h.log.Infow("msg", "handling satellite event",
		"event_id", event.ID,
		"event_type", string(event.Type),
		"aggregate_id", event.AggregateID,
	)

	switch event.Type {
	case EventTypeSatelliteImageryRequested:
		return h.handleImageryRequested(ctx, event)
	case EventTypeSatelliteImageryReceived:
		return h.handleImageryReceived(ctx, event)
	case EventTypeSatelliteStressDetected:
		return h.handleStressDetected(ctx, event)
	case EventTypeSatelliteAlertCreated:
		return h.handleAlertCreated(ctx, event)
	default:
		h.log.Warnf("unhandled satellite event type: %s", event.Type)
		return nil
	}
}

// handleImageryRequested processes a satellite imagery requested event.
func (h *SatelliteEventHandler) handleImageryRequested(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractSatelliteEventData(event)
	if err != nil {
		h.log.Errorw("msg", "failed to extract imagery requested event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "satellite imagery requested event received",
		"task_id", data.TaskID,
		"tenant_id", data.TenantID,
		"field_id", data.FieldID,
		"farm_id", data.FarmID,
		"provider", data.SatelliteProvider,
	)

	// Downstream consumers can react here:
	// - Queue the imagery acquisition with the satellite data provider
	// - Notify farm-service that satellite coverage is being acquired
	// - Update monitoring dashboard with pending acquisition status
	// - Schedule follow-up analysis tasks once imagery is available

	return nil
}

// handleImageryReceived processes a satellite imagery received event.
func (h *SatelliteEventHandler) handleImageryReceived(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractSatelliteEventData(event)
	if err != nil {
		h.log.Errorw("msg", "failed to extract imagery received event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "satellite imagery received event received",
		"image_id", data.ImageID,
		"tenant_id", data.TenantID,
		"field_id", data.FieldID,
		"farm_id", data.FarmID,
	)

	// Downstream consumers can react here:
	// - Trigger vegetation index computation (NDVI, NDWI, EVI)
	// - Notify plant-diagnosis-service to correlate with diagnosis data
	// - Update field health metrics in field-service
	// - Feed temporal analysis pipeline with new data point

	return nil
}

// handleStressDetected processes a crop stress detected event.
func (h *SatelliteEventHandler) handleStressDetected(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractSatelliteEventData(event)
	if err != nil {
		h.log.Errorw("msg", "failed to extract stress detected event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "satellite stress detected event received",
		"alert_id", data.AlertID,
		"tenant_id", data.TenantID,
		"field_id", data.FieldID,
		"image_id", data.ImageID,
		"stress_type", data.StressType,
		"severity", data.StressSeverity,
		"affected_area_pct", data.AffectedAreaPct,
	)

	// Downstream consumers can react here:
	// - Alert farm owner and field managers of detected stress
	// - Trigger irrigation-service if water stress is detected
	// - Notify plant-diagnosis-service to recommend targeted scouting
	// - Update pest-prediction-service models with stress location data
	// - Schedule follow-up satellite imagery acquisition for monitoring

	return nil
}

// handleAlertCreated processes a satellite alert created event.
func (h *SatelliteEventHandler) handleAlertCreated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractSatelliteEventData(event)
	if err != nil {
		h.log.Errorw("msg", "failed to extract alert created event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "satellite alert created event received",
		"alert_id", data.AlertID,
		"tenant_id", data.TenantID,
		"field_id", data.FieldID,
		"image_id", data.ImageID,
		"stress_type", data.StressType,
		"severity", data.StressSeverity,
	)

	// Downstream consumers can react here:
	// - Send push notification to farm manager's mobile device
	// - Update farm-service alert dashboard with new alert
	// - Trigger automated response workflows based on alert severity
	// - Log alert for compliance and audit reporting

	return nil
}

// extractSatelliteEventData extracts SatelliteEventData from a domain event's Data map.
func extractSatelliteEventData(event *domain.DomainEvent) (*SatelliteEventData, error) {
	data := &SatelliteEventData{}
	raw, err := json.Marshal(event.Data)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal event data: %w", err)
	}
	if err := json.Unmarshal(raw, data); err != nil {
		return nil, fmt.Errorf("failed to unmarshal event data: %w", err)
	}
	return data, nil
}

// RegisterSatelliteEventConsumer registers the satellite event handler with the Kafka consumer.
// This should be called during service initialization.
func RegisterSatelliteEventConsumer(d deps.ServiceDeps) (*SatelliteEventHandler, error) {
	handler := NewSatelliteEventHandler(d)

	if d.KafkaConsumer == nil {
		handler.log.Warnf("Kafka consumer not configured, skipping event registration")
		return handler, nil
	}

	topic := "samavaya.agriculture.satellite.events"
	handler.log.Infow("msg", "registering satellite event consumer", "topic", topic)

	// The actual Kafka subscription is wired during application bootstrap.
	// The handler.HandleEvent method is the callback for incoming messages.

	return handler, nil
}

// IsSatelliteEvent checks if a domain event type belongs to the satellite domain.
func IsSatelliteEvent(eventType domain.EventType) bool {
	switch eventType {
	case EventTypeSatelliteImageryRequested,
		EventTypeSatelliteImageryReceived,
		EventTypeSatelliteStressDetected,
		EventTypeSatelliteAlertCreated:
		return true
	default:
		return false
	}
}
