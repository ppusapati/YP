package handlers

import (
	"context"
	"encoding/json"
	"fmt"

	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9log"
)

// Irrigation event type constants matching those in services.
const (
	EventTypeScheduleCreated     domain.EventType = "agriculture.irrigation.schedule.created"
	EventTypeScheduleUpdated     domain.EventType = "agriculture.irrigation.schedule.updated"
	EventTypeIrrigationTriggered domain.EventType = "agriculture.irrigation.triggered"
	EventTypeIrrigationStopped   domain.EventType = "agriculture.irrigation.stopped"
	EventTypeDecisionGenerated   domain.EventType = "agriculture.irrigation.decision.generated"
)

// ScheduleEventData represents the data payload for schedule-related events.
type ScheduleEventData struct {
	ScheduleID   string `json:"schedule_id"`
	TenantID     string `json:"tenant_id"`
	Name         string `json:"name,omitempty"`
	ZoneID       string `json:"zone_id,omitempty"`
	ScheduleType string `json:"schedule_type,omitempty"`
	Status       string `json:"status,omitempty"`
	Version      int64  `json:"version,omitempty"`
}

// IrrigationTriggerEventData represents the data payload for irrigation trigger/stop events.
type IrrigationTriggerEventData struct {
	EventID      string  `json:"event_id"`
	TenantID     string  `json:"tenant_id"`
	ScheduleID   string  `json:"schedule_id,omitempty"`
	ControllerID string  `json:"controller_id,omitempty"`
	ZoneID       string  `json:"zone_id,omitempty"`
	ScheduleName string  `json:"schedule_name,omitempty"`
	WaterLiters  float64 `json:"water_liters,omitempty"`
	DurationMin  int32   `json:"duration_min,omitempty"`
}

// DecisionEventData represents the data payload for decision-related events.
type DecisionEventData struct {
	DecisionID      string  `json:"decision_id"`
	TenantID        string  `json:"tenant_id"`
	ZoneID          string  `json:"zone_id,omitempty"`
	ShouldIrrigate  bool    `json:"should_irrigate"`
	ConfidenceScore float64 `json:"confidence_score,omitempty"`
}

// IrrigationEventHandler handles incoming irrigation-related domain events (consumer side).
type IrrigationEventHandler struct {
	d   deps.ServiceDeps
	log *p9log.Helper
}

// NewIrrigationEventHandler creates a new IrrigationEventHandler for consuming irrigation events.
func NewIrrigationEventHandler(d deps.ServiceDeps) *IrrigationEventHandler {
	return &IrrigationEventHandler{
		d:   d,
		log: p9log.NewHelper(p9log.With(d.Log, "component", "IrrigationEventHandler")),
	}
}

// HandleEvent is the entry point for consuming an irrigation domain event.
// It dispatches to the appropriate handler based on event type.
func (h *IrrigationEventHandler) HandleEvent(ctx context.Context, event *domain.DomainEvent) error {
	if event == nil {
		return fmt.Errorf("received nil event")
	}

	h.log.Infow("msg", "handling irrigation event",
		"event_id", event.ID,
		"event_type", string(event.Type),
		"aggregate_id", event.AggregateID,
	)

	switch event.Type {
	case EventTypeScheduleCreated:
		return h.handleScheduleCreated(ctx, event)
	case EventTypeScheduleUpdated:
		return h.handleScheduleUpdated(ctx, event)
	case EventTypeIrrigationTriggered:
		return h.handleIrrigationTriggered(ctx, event)
	case EventTypeIrrigationStopped:
		return h.handleIrrigationStopped(ctx, event)
	case EventTypeDecisionGenerated:
		return h.handleDecisionGenerated(ctx, event)
	default:
		h.log.Warnf("unhandled irrigation event type: %s", event.Type)
		return nil
	}
}

// handleScheduleCreated processes a schedule created event.
func (h *IrrigationEventHandler) handleScheduleCreated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractScheduleEventData(event)
	if err != nil {
		h.log.Errorw("msg", "failed to extract schedule created event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "schedule created event received",
		"schedule_id", data.ScheduleID,
		"tenant_id", data.TenantID,
		"name", data.Name,
		"zone_id", data.ZoneID,
		"schedule_type", data.ScheduleType,
	)

	// Downstream consumers can react here:
	// - Notify controller-service to prepare for upcoming irrigation
	// - Update analytics/reporting indices
	// - Send notification to farm manager about new schedule
	// - Initialize weather monitoring for adaptive schedules

	return nil
}

// handleScheduleUpdated processes a schedule updated event.
func (h *IrrigationEventHandler) handleScheduleUpdated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractScheduleEventData(event)
	if err != nil {
		h.log.Errorw("msg", "failed to extract schedule updated event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "schedule updated event received",
		"schedule_id", data.ScheduleID,
		"tenant_id", data.TenantID,
		"status", data.Status,
		"version", data.Version,
	)

	// Downstream consumers can react here:
	// - Update cached schedule data in other services
	// - Recalculate water consumption forecasts
	// - Adjust controller configurations for updated parameters
	// - Notify farm-service of schedule changes

	return nil
}

// handleIrrigationTriggered processes an irrigation triggered event.
func (h *IrrigationEventHandler) handleIrrigationTriggered(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractIrrigationTriggerEventData(event)
	if err != nil {
		h.log.Errorw("msg", "failed to extract irrigation triggered event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "irrigation triggered event received",
		"event_id", data.EventID,
		"tenant_id", data.TenantID,
		"schedule_id", data.ScheduleID,
		"controller_id", data.ControllerID,
		"zone_id", data.ZoneID,
	)

	// Downstream consumers can react here:
	// - Send real-time notification to farm manager
	// - Update dashboard with active irrigation status
	// - Start monitoring sensor readings during irrigation
	// - Log water consumption start for billing

	return nil
}

// handleIrrigationStopped processes an irrigation stopped event.
func (h *IrrigationEventHandler) handleIrrigationStopped(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractIrrigationTriggerEventData(event)
	if err != nil {
		h.log.Errorw("msg", "failed to extract irrigation stopped event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "irrigation stopped event received",
		"event_id", data.EventID,
		"tenant_id", data.TenantID,
		"controller_id", data.ControllerID,
		"water_liters", data.WaterLiters,
		"duration_min", data.DurationMin,
	)

	// Downstream consumers can react here:
	// - Update water usage reports and billing
	// - Record soil moisture changes for analytics
	// - Trigger post-irrigation sensor readings
	// - Update daily water consumption totals

	return nil
}

// handleDecisionGenerated processes a decision generated event.
func (h *IrrigationEventHandler) handleDecisionGenerated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractDecisionEventData(event)
	if err != nil {
		h.log.Errorw("msg", "failed to extract decision generated event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "decision generated event received",
		"decision_id", data.DecisionID,
		"tenant_id", data.TenantID,
		"zone_id", data.ZoneID,
		"should_irrigate", data.ShouldIrrigate,
		"confidence_score", data.ConfidenceScore,
	)

	// Downstream consumers can react here:
	// - Auto-trigger irrigation if confidence is high enough
	// - Feed decision data into ML model training pipeline
	// - Notify farm manager of AI recommendation
	// - Update decision history for analytics

	return nil
}

// extractScheduleEventData extracts ScheduleEventData from a domain event's Data map.
func extractScheduleEventData(event *domain.DomainEvent) (*ScheduleEventData, error) {
	data := &ScheduleEventData{}
	raw, err := json.Marshal(event.Data)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal event data: %w", err)
	}
	if err := json.Unmarshal(raw, data); err != nil {
		return nil, fmt.Errorf("failed to unmarshal event data: %w", err)
	}
	return data, nil
}

// extractIrrigationTriggerEventData extracts IrrigationTriggerEventData from a domain event's Data map.
func extractIrrigationTriggerEventData(event *domain.DomainEvent) (*IrrigationTriggerEventData, error) {
	data := &IrrigationTriggerEventData{}
	raw, err := json.Marshal(event.Data)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal event data: %w", err)
	}
	if err := json.Unmarshal(raw, data); err != nil {
		return nil, fmt.Errorf("failed to unmarshal event data: %w", err)
	}
	return data, nil
}

// extractDecisionEventData extracts DecisionEventData from a domain event's Data map.
func extractDecisionEventData(event *domain.DomainEvent) (*DecisionEventData, error) {
	data := &DecisionEventData{}
	raw, err := json.Marshal(event.Data)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal event data: %w", err)
	}
	if err := json.Unmarshal(raw, data); err != nil {
		return nil, fmt.Errorf("failed to unmarshal event data: %w", err)
	}
	return data, nil
}

// RegisterIrrigationEventConsumer registers the irrigation event handler with the Kafka consumer.
// This should be called during service initialization.
func RegisterIrrigationEventConsumer(d deps.ServiceDeps) (*IrrigationEventHandler, error) {
	handler := NewIrrigationEventHandler(d)

	if d.KafkaConsumer == nil {
		handler.log.Warnf("Kafka consumer not configured, skipping event registration")
		return handler, nil
	}

	topic := "samavaya.agriculture.irrigation.events"
	handler.log.Infow("msg", "registering irrigation event consumer", "topic", topic)

	// The actual Kafka subscription is wired during application bootstrap.
	// The handler.HandleEvent method is the callback for incoming messages.

	return handler, nil
}

// IsIrrigationEvent checks if a domain event type belongs to the irrigation domain.
func IsIrrigationEvent(eventType domain.EventType) bool {
	switch eventType {
	case EventTypeScheduleCreated,
		EventTypeScheduleUpdated,
		EventTypeIrrigationTriggered,
		EventTypeIrrigationStopped,
		EventTypeDecisionGenerated:
		return true
	default:
		return false
	}
}
