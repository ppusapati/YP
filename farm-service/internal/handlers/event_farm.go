package handlers

import (
	"context"
	"encoding/json"
	"fmt"

	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9log"
)

// Farm event type constants matching those in services.
const (
	EventTypeFarmCreated          domain.EventType = "agriculture.farm.created"
	EventTypeFarmUpdated          domain.EventType = "agriculture.farm.updated"
	EventTypeFarmDeleted          domain.EventType = "agriculture.farm.deleted"
	EventTypeFarmBoundarySet      domain.EventType = "agriculture.farm.boundary.set"
	EventTypeOwnershipTransferred domain.EventType = "agriculture.farm.ownership.transferred"
)

// FarmEventData represents the data payload for farm-related events.
type FarmEventData struct {
	FarmID    string `json:"farm_id"`
	TenantID  string `json:"tenant_id"`
	Name      string `json:"name,omitempty"`
	FarmType  string `json:"farm_type,omitempty"`
	Status    string `json:"status,omitempty"`
	DeletedBy string `json:"deleted_by,omitempty"`
}

// BoundaryEventData represents the data payload for boundary-related events.
type BoundaryEventData struct {
	FarmID     string `json:"farm_id"`
	BoundaryID string `json:"boundary_id"`
}

// OwnershipTransferEventData represents the data payload for ownership transfer events.
type OwnershipTransferEventData struct {
	FarmID     string `json:"farm_id"`
	FromUserID string `json:"from_user_id"`
	ToUserID   string `json:"to_user_id"`
	TenantID   string `json:"tenant_id,omitempty"`
}

// FarmEventHandler handles incoming farm-related domain events (consumer side).
type FarmEventHandler struct {
	d   deps.ServiceDeps
	log *p9log.Helper
}

// NewFarmEventHandler creates a new FarmEventHandler for consuming farm events.
func NewFarmEventHandler(d deps.ServiceDeps) *FarmEventHandler {
	return &FarmEventHandler{
		d:   d,
		log: p9log.NewHelper(p9log.With(d.Log, "component", "FarmEventHandler")),
	}
}

// HandleEvent is the entry point for consuming a farm domain event.
// It dispatches to the appropriate handler based on event type.
func (h *FarmEventHandler) HandleEvent(ctx context.Context, event *domain.DomainEvent) error {
	if event == nil {
		return fmt.Errorf("received nil event")
	}

	h.log.Infow("msg", "handling farm event",
		"event_id", event.ID,
		"event_type", string(event.Type),
		"aggregate_id", event.AggregateID,
	)

	switch event.Type {
	case EventTypeFarmCreated:
		return h.handleFarmCreated(ctx, event)
	case EventTypeFarmUpdated:
		return h.handleFarmUpdated(ctx, event)
	case EventTypeFarmDeleted:
		return h.handleFarmDeleted(ctx, event)
	case EventTypeFarmBoundarySet:
		return h.handleFarmBoundarySet(ctx, event)
	case EventTypeOwnershipTransferred:
		return h.handleOwnershipTransferred(ctx, event)
	default:
		h.log.Warnf("unhandled farm event type: %s", event.Type)
		return nil
	}
}

// handleFarmCreated processes a farm created event.
func (h *FarmEventHandler) handleFarmCreated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractFarmEventData(event)
	if err != nil {
		h.log.Errorw("msg", "failed to extract farm created event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "farm created event received",
		"farm_id", data.FarmID,
		"tenant_id", data.TenantID,
		"name", data.Name,
		"farm_type", data.FarmType,
	)

	// Downstream consumers can react here:
	// - Notify field-service to prepare default fields
	// - Update analytics/reporting indices
	// - Send welcome notification to farm owner
	// - Initialize sensor-service monitoring configuration

	return nil
}

// handleFarmUpdated processes a farm updated event.
func (h *FarmEventHandler) handleFarmUpdated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractFarmEventData(event)
	if err != nil {
		h.log.Errorw("msg", "failed to extract farm updated event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "farm updated event received",
		"farm_id", data.FarmID,
		"tenant_id", data.TenantID,
		"status", data.Status,
	)

	// Downstream consumers can react here:
	// - Update cached farm data in other services
	// - Trigger re-computation of satellite coverage for updated boundaries
	// - Notify dependent services (irrigation, soil) of farm parameter changes

	return nil
}

// handleFarmDeleted processes a farm deleted event.
func (h *FarmEventHandler) handleFarmDeleted(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractFarmEventData(event)
	if err != nil {
		h.log.Errorw("msg", "failed to extract farm deleted event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "farm deleted event received",
		"farm_id", data.FarmID,
		"tenant_id", data.TenantID,
		"deleted_by", data.DeletedBy,
	)

	// Downstream consumers can react here:
	// - Cascade soft-delete to fields in field-service
	// - Stop sensor monitoring in sensor-service
	// - Archive satellite imagery associations
	// - Cancel pending irrigation schedules

	return nil
}

// handleFarmBoundarySet processes a farm boundary set event.
func (h *FarmEventHandler) handleFarmBoundarySet(ctx context.Context, event *domain.DomainEvent) error {
	boundaryData := &BoundaryEventData{}
	raw, _ := json.Marshal(event.Data)
	if err := json.Unmarshal(raw, boundaryData); err != nil {
		h.log.Errorw("msg", "failed to extract boundary event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "farm boundary set event received",
		"farm_id", boundaryData.FarmID,
		"boundary_id", boundaryData.BoundaryID,
	)

	// Downstream consumers can react here:
	// - Trigger satellite imagery acquisition for the new boundary area
	// - Recalculate soil analysis zones
	// - Update field boundaries if they reference the farm polygon
	// - Notify pest-prediction-service of new coverage area

	return nil
}

// handleOwnershipTransferred processes an ownership transferred event.
func (h *FarmEventHandler) handleOwnershipTransferred(ctx context.Context, event *domain.DomainEvent) error {
	transferData := &OwnershipTransferEventData{}
	raw, _ := json.Marshal(event.Data)
	if err := json.Unmarshal(raw, transferData); err != nil {
		h.log.Errorw("msg", "failed to extract ownership transfer event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "ownership transfer event received",
		"farm_id", transferData.FarmID,
		"from_user_id", transferData.FromUserID,
		"to_user_id", transferData.ToUserID,
	)

	// Downstream consumers can react here:
	// - Update access controls/permissions for the new owner
	// - Transfer notification subscriptions
	// - Update billing/subscription associations
	// - Audit log the ownership change

	return nil
}

// extractFarmEventData extracts FarmEventData from a domain event's Data map.
func extractFarmEventData(event *domain.DomainEvent) (*FarmEventData, error) {
	data := &FarmEventData{}
	raw, err := json.Marshal(event.Data)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal event data: %w", err)
	}
	if err := json.Unmarshal(raw, data); err != nil {
		return nil, fmt.Errorf("failed to unmarshal event data: %w", err)
	}
	return data, nil
}

// RegisterFarmEventConsumer registers the farm event handler with the Kafka consumer.
// This should be called during service initialization.
func RegisterFarmEventConsumer(d deps.ServiceDeps) (*FarmEventHandler, error) {
	handler := NewFarmEventHandler(d)

	if d.KafkaConsumer == nil {
		handler.log.Warnf("Kafka consumer not configured, skipping event registration")
		return handler, nil
	}

	topic := "samavaya.agriculture.farm.events"
	handler.log.Infow("msg", "registering farm event consumer", "topic", topic)

	// The actual Kafka subscription is wired during application bootstrap.
	// The handler.HandleEvent method is the callback for incoming messages.

	return handler, nil
}

// IsFarmEvent checks if a domain event type belongs to the farm domain.
func IsFarmEvent(eventType domain.EventType) bool {
	switch eventType {
	case EventTypeFarmCreated,
		EventTypeFarmUpdated,
		EventTypeFarmDeleted,
		EventTypeFarmBoundarySet,
		EventTypeOwnershipTransferred:
		return true
	default:
		return false
	}
}
