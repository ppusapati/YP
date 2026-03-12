package handlers

import (
	"context"
	"encoding/json"
	"fmt"

	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9log"
)

// Vegetation compute event type constants matching those in services.
const (
	EventTypeComputeStarted   domain.EventType = "agriculture.satellite.vegetation.compute.started"
	EventTypeComputeCompleted domain.EventType = "agriculture.satellite.vegetation.compute.completed"
	EventTypeComputeFailed    domain.EventType = "agriculture.satellite.vegetation.compute.failed"
)

// ComputeEventData represents the data payload for compute-related events.
type ComputeEventData struct {
	ComputeTaskID    string   `json:"compute_task_id"`
	TenantID         string   `json:"tenant_id"`
	ProcessingJobID  string   `json:"processing_job_id"`
	FarmID           string   `json:"farm_id"`
	Status           string   `json:"status"`
	IndexTypes       []string `json:"index_types,omitempty"`
	ErrorMessage     string   `json:"error_message,omitempty"`
	ComputeTimeSecs  float64  `json:"compute_time_seconds,omitempty"`
}

// VegetationIndexEventHandler handles incoming vegetation-index-related domain events (consumer side).
type VegetationIndexEventHandler struct {
	d   deps.ServiceDeps
	log *p9log.Helper
}

// NewVegetationIndexEventHandler creates a new VegetationIndexEventHandler for consuming events.
func NewVegetationIndexEventHandler(d deps.ServiceDeps) *VegetationIndexEventHandler {
	return &VegetationIndexEventHandler{
		d:   d,
		log: p9log.NewHelper(p9log.With(d.Log, "component", "VegetationIndexEventHandler")),
	}
}

// HandleEvent is the entry point for consuming a vegetation index domain event.
// It dispatches to the appropriate handler based on event type.
func (h *VegetationIndexEventHandler) HandleEvent(ctx context.Context, event *domain.DomainEvent) error {
	if event == nil {
		return fmt.Errorf("received nil event")
	}

	h.log.Infow("msg", "handling vegetation index event",
		"event_id", event.ID,
		"event_type", string(event.Type),
		"aggregate_id", event.AggregateID,
	)

	switch event.Type {
	case EventTypeComputeStarted:
		return h.handleComputeStarted(ctx, event)
	case EventTypeComputeCompleted:
		return h.handleComputeCompleted(ctx, event)
	case EventTypeComputeFailed:
		return h.handleComputeFailed(ctx, event)
	default:
		h.log.Warnf("unhandled vegetation index event type: %s", event.Type)
		return nil
	}
}

// handleComputeStarted processes a compute started event.
func (h *VegetationIndexEventHandler) handleComputeStarted(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractComputeEventData(event)
	if err != nil {
		h.log.Errorw("msg", "failed to extract compute started event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "compute started event received",
		"compute_task_id", data.ComputeTaskID,
		"tenant_id", data.TenantID,
		"processing_job_id", data.ProcessingJobID,
		"farm_id", data.FarmID,
		"index_types", data.IndexTypes,
	)

	// Downstream consumers can react here:
	// - Start actual raster computation pipeline
	// - Fetch satellite imagery bands from S3
	// - Schedule GPU-based index computation
	// - Update monitoring dashboards with task progress

	return nil
}

// handleComputeCompleted processes a compute completed event.
func (h *VegetationIndexEventHandler) handleComputeCompleted(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractComputeEventData(event)
	if err != nil {
		h.log.Errorw("msg", "failed to extract compute completed event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "compute completed event received",
		"compute_task_id", data.ComputeTaskID,
		"tenant_id", data.TenantID,
		"farm_id", data.FarmID,
		"compute_time_seconds", data.ComputeTimeSecs,
	)

	// Downstream consumers can react here:
	// - Trigger alert/notification service for anomalous NDVI values
	// - Update field health dashboards
	// - Feed data into crop yield prediction models
	// - Archive computation results for historical analysis

	return nil
}

// handleComputeFailed processes a compute failed event.
func (h *VegetationIndexEventHandler) handleComputeFailed(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractComputeEventData(event)
	if err != nil {
		h.log.Errorw("msg", "failed to extract compute failed event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Errorw("msg", "compute failed event received",
		"compute_task_id", data.ComputeTaskID,
		"tenant_id", data.TenantID,
		"farm_id", data.FarmID,
		"error_message", data.ErrorMessage,
	)

	// Downstream consumers can react here:
	// - Schedule retry with exponential backoff
	// - Alert operations team of persistent failures
	// - Update task status in monitoring dashboards
	// - Log failure metrics for SLA tracking

	return nil
}

// extractComputeEventData extracts ComputeEventData from a domain event's Data map.
func extractComputeEventData(event *domain.DomainEvent) (*ComputeEventData, error) {
	data := &ComputeEventData{}
	raw, err := json.Marshal(event.Data)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal event data: %w", err)
	}
	if err := json.Unmarshal(raw, data); err != nil {
		return nil, fmt.Errorf("failed to unmarshal event data: %w", err)
	}
	return data, nil
}

// RegisterVegetationIndexEventConsumer registers the event handler with the Kafka consumer.
// This should be called during service initialization.
func RegisterVegetationIndexEventConsumer(d deps.ServiceDeps) (*VegetationIndexEventHandler, error) {
	handler := NewVegetationIndexEventHandler(d)

	if d.KafkaConsumer == nil {
		handler.log.Warnf("Kafka consumer not configured, skipping event registration")
		return handler, nil
	}

	topic := "samavaya.agriculture.satellite.vegetation.events"
	handler.log.Infow("msg", "registering vegetation index event consumer", "topic", topic)

	// The actual Kafka subscription is wired during application bootstrap.
	// The handler.HandleEvent method is the callback for incoming messages.

	return handler, nil
}

// IsVegetationIndexEvent checks if a domain event type belongs to the vegetation index domain.
func IsVegetationIndexEvent(eventType domain.EventType) bool {
	switch eventType {
	case EventTypeComputeStarted,
		EventTypeComputeCompleted,
		EventTypeComputeFailed:
		return true
	default:
		return false
	}
}
