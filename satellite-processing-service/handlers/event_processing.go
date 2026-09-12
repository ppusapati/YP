package handlers

import (
	"context"
	"encoding/json"
	"fmt"

	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9log"
)

// Processing event type constants matching those in services.
const (
	EventTypeProcessingSubmitted domain.EventType = "agriculture.satellite.processing.submitted"
	EventTypeProcessingCompleted domain.EventType = "agriculture.satellite.processing.completed"
	EventTypeProcessingFailed    domain.EventType = "agriculture.satellite.processing.failed"
)

// ProcessingEventData represents the data payload for processing-related events.
type ProcessingEventData struct {
	JobID            string `json:"job_id"`
	TenantID         string `json:"tenant_id"`
	FarmID           string `json:"farm_id,omitempty"`
	IngestionTaskID  string `json:"ingestion_task_id,omitempty"`
	Status           string `json:"status,omitempty"`
	Algorithm        string `json:"algorithm,omitempty"`
	InputLevel       string `json:"input_level,omitempty"`
	OutputLevel      string `json:"output_level,omitempty"`
	ErrorMessage     string `json:"error_message,omitempty"`
	Reason           string `json:"reason,omitempty"`
	CancelledBy      string `json:"cancelled_by,omitempty"`
}

// ProcessingEventHandler handles incoming processing-related domain events (consumer side).
type ProcessingEventHandler struct {
	d   deps.ServiceDeps
	log *p9log.Helper
}

// NewProcessingEventHandler creates a new ProcessingEventHandler for consuming processing events.
func NewProcessingEventHandler(d deps.ServiceDeps) *ProcessingEventHandler {
	return &ProcessingEventHandler{
		d:   d,
		log: p9log.NewHelper(p9log.With(d.Log, "component", "ProcessingEventHandler")),
	}
}

// HandleEvent is the entry point for consuming a processing domain event.
// It dispatches to the appropriate handler based on event type.
func (h *ProcessingEventHandler) HandleEvent(ctx context.Context, event *domain.DomainEvent) error {
	if event == nil {
		return fmt.Errorf("received nil event")
	}

	h.log.Infow("msg", "handling processing event",
		"event_id", event.ID,
		"event_type", string(event.Type),
		"aggregate_id", event.AggregateID,
	)

	switch event.Type {
	case EventTypeProcessingSubmitted:
		return h.handleProcessingSubmitted(ctx, event)
	case EventTypeProcessingCompleted:
		return h.handleProcessingCompleted(ctx, event)
	case EventTypeProcessingFailed:
		return h.handleProcessingFailed(ctx, event)
	default:
		h.log.Warnf("unhandled processing event type: %s", event.Type)
		return nil
	}
}

// handleProcessingSubmitted processes a processing job submitted event.
func (h *ProcessingEventHandler) handleProcessingSubmitted(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractProcessingEventData(event)
	if err != nil {
		h.log.Errorw("msg", "failed to extract processing submitted event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "processing submitted event received",
		"job_id", data.JobID,
		"tenant_id", data.TenantID,
		"farm_id", data.FarmID,
		"algorithm", data.Algorithm,
	)

	// Downstream consumers can react here:
	// - Enqueue the job to the raster processing worker pool
	// - Fetch raw imagery from S3 for atmospheric correction
	// - Notify the ingestion service that processing has started
	// - Update monitoring dashboards with new job metrics

	return nil
}

// handleProcessingCompleted processes a processing job completed event.
func (h *ProcessingEventHandler) handleProcessingCompleted(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractProcessingEventData(event)
	if err != nil {
		h.log.Errorw("msg", "failed to extract processing completed event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "processing completed event received",
		"job_id", data.JobID,
		"tenant_id", data.TenantID,
		"farm_id", data.FarmID,
		"output_level", data.OutputLevel,
	)

	// Downstream consumers can react here:
	// - Trigger index generation (NDVI, EVI, NDWI) from processed bands
	// - Notify the analytics service of new processed imagery
	// - Update the satellite catalog with processed product metadata
	// - Send notification to the farm owner that imagery is ready

	return nil
}

// handleProcessingFailed processes a processing job failed event.
func (h *ProcessingEventHandler) handleProcessingFailed(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractProcessingEventData(event)
	if err != nil {
		h.log.Errorw("msg", "failed to extract processing failed event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "processing failed event received",
		"job_id", data.JobID,
		"tenant_id", data.TenantID,
		"farm_id", data.FarmID,
		"reason", data.Reason,
		"error_message", data.ErrorMessage,
	)

	// Downstream consumers can react here:
	// - Retry the processing job with different parameters
	// - Alert operations team of recurring failures
	// - Update farm dashboard with processing failure notification
	// - Log the failure for SLA compliance reporting

	return nil
}

// extractProcessingEventData extracts ProcessingEventData from a domain event's Data map.
func extractProcessingEventData(event *domain.DomainEvent) (*ProcessingEventData, error) {
	data := &ProcessingEventData{}
	raw, err := json.Marshal(event.Data)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal event data: %w", err)
	}
	if err := json.Unmarshal(raw, data); err != nil {
		return nil, fmt.Errorf("failed to unmarshal event data: %w", err)
	}
	return data, nil
}

// RegisterProcessingEventConsumer registers the processing event handler with the Kafka consumer.
// This should be called during service initialization.
func RegisterProcessingEventConsumer(d deps.ServiceDeps) (*ProcessingEventHandler, error) {
	handler := NewProcessingEventHandler(d)

	if d.KafkaConsumer == nil {
		handler.log.Warnf("Kafka consumer not configured, skipping event registration")
		return handler, nil
	}

	topic := "samavaya.agriculture.satellite.processing.events"
	handler.log.Infow("msg", "registering processing event consumer", "topic", topic)

	// The actual Kafka subscription is wired during application bootstrap.
	// The handler.HandleEvent method is the callback for incoming messages.

	return handler, nil
}

// IsProcessingEvent checks if a domain event type belongs to the processing domain.
func IsProcessingEvent(eventType domain.EventType) bool {
	switch eventType {
	case EventTypeProcessingSubmitted,
		EventTypeProcessingCompleted,
		EventTypeProcessingFailed:
		return true
	default:
		return false
	}
}
