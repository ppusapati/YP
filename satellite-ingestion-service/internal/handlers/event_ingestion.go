package handlers

import (
	"context"
	"encoding/json"
	"fmt"

	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9log"
)

// Ingestion event type constants matching those in services.
const (
	EventTypeIngestionRequested domain.EventType = "agriculture.satellite.ingestion.requested"
	EventTypeIngestionCompleted domain.EventType = "agriculture.satellite.ingestion.completed"
	EventTypeIngestionFailed    domain.EventType = "agriculture.satellite.ingestion.failed"
)

// IngestionEventData represents the data payload for ingestion-related events.
type IngestionEventData struct {
	TaskID   string `json:"task_id"`
	TenantID string `json:"tenant_id"`
	FarmID   string `json:"farm_id,omitempty"`
	Provider string `json:"provider,omitempty"`
	Status   string `json:"status,omitempty"`
	SceneID  string `json:"scene_id,omitempty"`
	Reason   string `json:"reason,omitempty"`
}

// IngestionEventHandler handles incoming ingestion-related domain events (consumer side).
type IngestionEventHandler struct {
	d   deps.ServiceDeps
	log *p9log.Helper
}

// NewIngestionEventHandler creates a new IngestionEventHandler for consuming ingestion events.
func NewIngestionEventHandler(d deps.ServiceDeps) *IngestionEventHandler {
	return &IngestionEventHandler{
		d:   d,
		log: p9log.NewHelper(p9log.With(d.Log, "component", "IngestionEventHandler")),
	}
}

// HandleEvent is the entry point for consuming an ingestion domain event.
// It dispatches to the appropriate handler based on event type.
func (h *IngestionEventHandler) HandleEvent(ctx context.Context, event *domain.DomainEvent) error {
	if event == nil {
		return fmt.Errorf("received nil event")
	}

	h.log.Infow("msg", "handling ingestion event",
		"event_id", event.ID,
		"event_type", string(event.Type),
		"aggregate_id", event.AggregateID,
	)

	switch event.Type {
	case EventTypeIngestionRequested:
		return h.handleIngestionRequested(ctx, event)
	case EventTypeIngestionCompleted:
		return h.handleIngestionCompleted(ctx, event)
	case EventTypeIngestionFailed:
		return h.handleIngestionFailed(ctx, event)
	default:
		h.log.Warnf("unhandled ingestion event type: %s", event.Type)
		return nil
	}
}

// handleIngestionRequested processes an ingestion requested event.
func (h *IngestionEventHandler) handleIngestionRequested(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractIngestionEventData(event)
	if err != nil {
		h.log.Errorw("msg", "failed to extract ingestion requested event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "ingestion requested event received",
		"task_id", data.TaskID,
		"tenant_id", data.TenantID,
		"farm_id", data.FarmID,
		"provider", data.Provider,
	)

	// Downstream consumers can react here:
	// - Start the satellite imagery download worker
	// - Notify the provider-specific adapter to begin scene retrieval
	// - Update monitoring dashboards with new task queued
	// - Validate farm boundary exists for the requested area

	return nil
}

// handleIngestionCompleted processes an ingestion completed event.
func (h *IngestionEventHandler) handleIngestionCompleted(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractIngestionEventData(event)
	if err != nil {
		h.log.Errorw("msg", "failed to extract ingestion completed event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "ingestion completed event received",
		"task_id", data.TaskID,
		"tenant_id", data.TenantID,
		"provider", data.Provider,
		"scene_id", data.SceneID,
	)

	// Downstream consumers can react here:
	// - Trigger NDVI/vegetation index computation pipeline
	// - Notify the analytics service of new imagery available
	// - Update the satellite imagery catalog
	// - Send notification to farm owner about new imagery

	return nil
}

// handleIngestionFailed processes an ingestion failed event.
func (h *IngestionEventHandler) handleIngestionFailed(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractIngestionEventData(event)
	if err != nil {
		h.log.Errorw("msg", "failed to extract ingestion failed event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "ingestion failed event received",
		"task_id", data.TaskID,
		"tenant_id", data.TenantID,
		"provider", data.Provider,
		"reason", data.Reason,
	)

	// Downstream consumers can react here:
	// - Schedule automatic retry if within retry limits
	// - Alert operations team for persistent failures
	// - Update failure metrics and dashboards
	// - Notify the user if max retries exceeded

	return nil
}

// extractIngestionEventData extracts IngestionEventData from a domain event's Data map.
func extractIngestionEventData(event *domain.DomainEvent) (*IngestionEventData, error) {
	data := &IngestionEventData{}
	raw, err := json.Marshal(event.Data)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal event data: %w", err)
	}
	if err := json.Unmarshal(raw, data); err != nil {
		return nil, fmt.Errorf("failed to unmarshal event data: %w", err)
	}
	return data, nil
}

// RegisterIngestionEventConsumer registers the ingestion event handler with the Kafka consumer.
// This should be called during service initialization.
func RegisterIngestionEventConsumer(d deps.ServiceDeps) (*IngestionEventHandler, error) {
	handler := NewIngestionEventHandler(d)

	if d.KafkaConsumer == nil {
		handler.log.Warnf("Kafka consumer not configured, skipping event registration")
		return handler, nil
	}

	topic := "samavaya.agriculture.satellite.ingestion.events"
	handler.log.Infow("msg", "registering ingestion event consumer", "topic", topic)

	// The actual Kafka subscription is wired during application bootstrap.
	// The handler.HandleEvent method is the callback for incoming messages.

	return handler, nil
}

// IsIngestionEvent checks if a domain event type belongs to the ingestion domain.
func IsIngestionEvent(eventType domain.EventType) bool {
	switch eventType {
	case EventTypeIngestionRequested,
		EventTypeIngestionCompleted,
		EventTypeIngestionFailed:
		return true
	default:
		return false
	}
}
