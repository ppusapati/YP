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
	EventTypeZoneCreated         domain.EventType = "agriculture.irrigation.zone.created"
	EventTypeScheduleCreated     domain.EventType = "agriculture.irrigation.schedule.created"
	EventTypeScheduleCancelled   domain.EventType = "agriculture.irrigation.schedule.cancelled"
	EventTypeIrrigationTriggered domain.EventType = "agriculture.irrigation.triggered"
	EventTypeIrrigationCompleted domain.EventType = "agriculture.irrigation.completed"
	EventTypeIrrigationFailed    domain.EventType = "agriculture.irrigation.failed"
)

// ZoneEventData represents the data payload for zone-related events.
type ZoneEventData struct {
	ZoneID   string `json:"zone_id"`
	TenantID string `json:"tenant_id"`
	Name     string `json:"name,omitempty"`
	FieldID  string `json:"field_id,omitempty"`
	FarmID   string `json:"farm_id,omitempty"`
}

// ScheduleEventData represents the data payload for schedule-related events.
type ScheduleEventData struct {
	ScheduleID   string `json:"schedule_id"`
	TenantID     string `json:"tenant_id"`
	Name         string `json:"name,omitempty"`
	ZoneID       string `json:"zone_id,omitempty"`
	ScheduleType string `json:"schedule_type,omitempty"`
	Status       string `json:"status,omitempty"`
	CancelledBy  string `json:"cancelled_by,omitempty"`
}

// IrrigationTriggerEventData represents the data payload for irrigation trigger/complete/fail events.
type IrrigationTriggerEventData struct {
	EventID      string  `json:"event_id"`
	TenantID     string  `json:"tenant_id"`
	ScheduleID   string  `json:"schedule_id,omitempty"`
	ControllerID string  `json:"controller_id,omitempty"`
	ZoneID       string  `json:"zone_id,omitempty"`
	ScheduleName string  `json:"schedule_name,omitempty"`
	WaterLiters  float64 `json:"water_liters,omitempty"`
	DurationMin  int32   `json:"duration_min,omitempty"`
	Reason       string  `json:"reason,omitempty"`
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
	case EventTypeZoneCreated:
		return h.handleZoneCreated(ctx, event)
	case EventTypeScheduleCreated:
		return h.handleScheduleCreated(ctx, event)
	case EventTypeScheduleCancelled:
		return h.handleScheduleCancelled(ctx, event)
	case EventTypeIrrigationTriggered:
		return h.handleIrrigationTriggered(ctx, event)
	case EventTypeIrrigationCompleted:
		return h.handleIrrigationCompleted(ctx, event)
	case EventTypeIrrigationFailed:
		return h.handleIrrigationFailed(ctx, event)
	default:
		h.log.Warnf("unhandled irrigation event type: %s", event.Type)
		return nil
	}
}

// handleZoneCreated processes a zone created event.
func (h *IrrigationEventHandler) handleZoneCreated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractZoneEventData(event)
	if err != nil {
		h.log.Errorw("msg", "failed to extract zone created event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "zone created event received",
		"zone_id", data.ZoneID,
		"tenant_id", data.TenantID,
		"name", data.Name,
		"field_id", data.FieldID,
		"farm_id", data.FarmID,
	)

	// Downstream consumers can react here:
	// - Initialize default controller assignments
	// - Create default irrigation schedules for the zone
	// - Notify sensor-service to start soil moisture monitoring
	// - Update field-service with zone coverage data

	return nil
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
	// - Register schedule with the scheduler/cron service
	// - Notify weather-service to start forecast tracking for the zone
	// - Update analytics dashboards with new schedule data
	// - Send notification to farm operators

	return nil
}

// handleScheduleCancelled processes a schedule cancelled event.
func (h *IrrigationEventHandler) handleScheduleCancelled(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractScheduleEventData(event)
	if err != nil {
		h.log.Errorw("msg", "failed to extract schedule cancelled event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "schedule cancelled event received",
		"schedule_id", data.ScheduleID,
		"tenant_id", data.TenantID,
		"cancelled_by", data.CancelledBy,
	)

	// Downstream consumers can react here:
	// - Remove schedule from the scheduler/cron service
	// - Cancel pending controller commands
	// - Update analytics dashboards
	// - Send cancellation notification to farm operators

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
	// - Send start command to the physical controller via IoT gateway
	// - Start real-time monitoring of water flow sensors
	// - Update dashboard with active irrigation status
	// - Begin recording water usage telemetry

	return nil
}

// handleIrrigationCompleted processes an irrigation completed event.
func (h *IrrigationEventHandler) handleIrrigationCompleted(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractIrrigationTriggerEventData(event)
	if err != nil {
		h.log.Errorw("msg", "failed to extract irrigation completed event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "irrigation completed event received",
		"event_id", data.EventID,
		"tenant_id", data.TenantID,
		"zone_id", data.ZoneID,
		"water_liters", data.WaterLiters,
		"duration_min", data.DurationMin,
	)

	// Downstream consumers can react here:
	// - Send stop command to the physical controller
	// - Record final water usage summary
	// - Trigger post-irrigation soil moisture reading
	// - Update analytics with completion data
	// - Send completion notification to farm operators

	return nil
}

// handleIrrigationFailed processes an irrigation failed event.
func (h *IrrigationEventHandler) handleIrrigationFailed(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractIrrigationTriggerEventData(event)
	if err != nil {
		h.log.Errorw("msg", "failed to extract irrigation failed event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Errorw("msg", "irrigation failed event received",
		"event_id", data.EventID,
		"tenant_id", data.TenantID,
		"zone_id", data.ZoneID,
		"controller_id", data.ControllerID,
		"reason", data.Reason,
	)

	// Downstream consumers can react here:
	// - Send emergency stop command to the controller
	// - Update controller status to ERROR
	// - Send alert notification to farm operators
	// - Log failure in incident tracking system
	// - Attempt to reschedule irrigation if appropriate

	return nil
}

// extractZoneEventData extracts ZoneEventData from a domain event's Data map.
func extractZoneEventData(event *domain.DomainEvent) (*ZoneEventData, error) {
	data := &ZoneEventData{}
	raw, err := json.Marshal(event.Data)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal event data: %w", err)
	}
	if err := json.Unmarshal(raw, data); err != nil {
		return nil, fmt.Errorf("failed to unmarshal event data: %w", err)
	}
	return data, nil
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
	case EventTypeZoneCreated,
		EventTypeScheduleCreated,
		EventTypeScheduleCancelled,
		EventTypeIrrigationTriggered,
		EventTypeIrrigationCompleted,
		EventTypeIrrigationFailed:
		return true
	default:
		return false
	}
}
