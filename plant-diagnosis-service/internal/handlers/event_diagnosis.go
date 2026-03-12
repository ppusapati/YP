package handlers

import (
	"context"
	"encoding/json"
	"fmt"

	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9log"
)

// Diagnosis event type constants matching those in services.
const (
	EventTypeDiagnosisSubmitted          domain.EventType = "agriculture.diagnosis.submitted"
	EventTypeDiagnosisCompleted          domain.EventType = "agriculture.diagnosis.completed"
	EventTypeDiagnosisFailed             domain.EventType = "agriculture.diagnosis.failed"
	EventTypeDiagnosisTreatmentGenerated domain.EventType = "agriculture.diagnosis.treatment.generated"
)

// DiagnosisEventData represents the data payload for diagnosis-related events.
type DiagnosisEventData struct {
	DiagnosisID string  `json:"diagnosis_id"`
	FarmID      string  `json:"farm_id"`
	FieldID     string  `json:"field_id,omitempty"`
	TenantID    string  `json:"tenant_id"`
	Status      string  `json:"status,omitempty"`
	DiseaseID   string  `json:"disease_id,omitempty"`
	Confidence  float64 `json:"confidence,omitempty"`
}

// DiagnosisEventHandler handles incoming diagnosis-related domain events (consumer side).
type DiagnosisEventHandler struct {
	d   deps.ServiceDeps
	log *p9log.Helper
}

// NewDiagnosisEventHandler creates a new DiagnosisEventHandler for consuming diagnosis events.
func NewDiagnosisEventHandler(d deps.ServiceDeps) *DiagnosisEventHandler {
	return &DiagnosisEventHandler{
		d:   d,
		log: p9log.NewHelper(p9log.With(d.Log, "component", "DiagnosisEventHandler")),
	}
}

// HandleEvent is the entry point for consuming a diagnosis domain event.
// It dispatches to the appropriate handler based on event type.
func (h *DiagnosisEventHandler) HandleEvent(ctx context.Context, event *domain.DomainEvent) error {
	if event == nil {
		return fmt.Errorf("received nil event")
	}

	h.log.Infow("msg", "handling diagnosis event",
		"event_id", event.ID,
		"event_type", string(event.Type),
		"aggregate_id", event.AggregateID,
	)

	switch event.Type {
	case EventTypeDiagnosisSubmitted:
		return h.handleDiagnosisSubmitted(ctx, event)
	case EventTypeDiagnosisCompleted:
		return h.handleDiagnosisCompleted(ctx, event)
	case EventTypeDiagnosisFailed:
		return h.handleDiagnosisFailed(ctx, event)
	case EventTypeDiagnosisTreatmentGenerated:
		return h.handleDiagnosisTreatmentGenerated(ctx, event)
	default:
		h.log.Warnf("unhandled diagnosis event type: %s", event.Type)
		return nil
	}
}

// handleDiagnosisSubmitted processes a diagnosis submitted event.
func (h *DiagnosisEventHandler) handleDiagnosisSubmitted(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractDiagnosisEventData(event)
	if err != nil {
		h.log.Errorw("msg", "failed to extract diagnosis submitted event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "diagnosis submitted event received",
		"diagnosis_id", data.DiagnosisID,
		"tenant_id", data.TenantID,
		"farm_id", data.FarmID,
		"field_id", data.FieldID,
		"status", data.Status,
	)

	// Downstream consumers can react here:
	// - Notify farm-service of pending diagnosis
	// - Queue AI pipeline preprocessing tasks
	// - Update farm health monitoring dashboard
	// - Send notification to farm manager

	return nil
}

// handleDiagnosisCompleted processes a diagnosis completed event.
func (h *DiagnosisEventHandler) handleDiagnosisCompleted(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractDiagnosisEventData(event)
	if err != nil {
		h.log.Errorw("msg", "failed to extract diagnosis completed event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "diagnosis completed event received",
		"diagnosis_id", data.DiagnosisID,
		"tenant_id", data.TenantID,
		"farm_id", data.FarmID,
		"disease_id", data.DiseaseID,
		"confidence", data.Confidence,
		"status", data.Status,
	)

	// Downstream consumers can react here:
	// - Update farm health indices in analytics-service
	// - Trigger treatment plan notifications
	// - Update satellite-service to correlate with imagery data
	// - Record processing metrics for AI pipeline monitoring

	return nil
}

// handleDiagnosisFailed processes a diagnosis failed event.
func (h *DiagnosisEventHandler) handleDiagnosisFailed(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractDiagnosisEventData(event)
	if err != nil {
		h.log.Errorw("msg", "failed to extract diagnosis failed event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "diagnosis failed event received",
		"diagnosis_id", data.DiagnosisID,
		"tenant_id", data.TenantID,
		"farm_id", data.FarmID,
		"field_id", data.FieldID,
		"status", data.Status,
	)

	// Downstream consumers can react here:
	// - Notify farm owner of diagnosis failure
	// - Trigger retry logic or escalation workflow
	// - Update monitoring dashboards with failure metrics
	// - Log diagnostic information for AI pipeline debugging

	return nil
}

// handleDiagnosisTreatmentGenerated processes a diagnosis treatment generated event.
func (h *DiagnosisEventHandler) handleDiagnosisTreatmentGenerated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractDiagnosisEventData(event)
	if err != nil {
		h.log.Errorw("msg", "failed to extract diagnosis treatment generated event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "diagnosis treatment generated event received",
		"diagnosis_id", data.DiagnosisID,
		"tenant_id", data.TenantID,
		"farm_id", data.FarmID,
		"field_id", data.FieldID,
		"disease_id", data.DiseaseID,
	)

	// Downstream consumers can react here:
	// - Notify farm owner that a treatment plan is available
	// - Trigger irrigation-service to schedule treatment applications
	// - Update field-service with recommended treatment actions
	// - Send push notification to farm manager's mobile device

	return nil
}

// extractDiagnosisEventData extracts DiagnosisEventData from a domain event's Data map.
func extractDiagnosisEventData(event *domain.DomainEvent) (*DiagnosisEventData, error) {
	data := &DiagnosisEventData{}
	raw, err := json.Marshal(event.Data)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal event data: %w", err)
	}
	if err := json.Unmarshal(raw, data); err != nil {
		return nil, fmt.Errorf("failed to unmarshal event data: %w", err)
	}
	return data, nil
}

// RegisterDiagnosisEventConsumer registers the diagnosis event handler with the Kafka consumer.
// This should be called during service initialization.
func RegisterDiagnosisEventConsumer(d deps.ServiceDeps) (*DiagnosisEventHandler, error) {
	handler := NewDiagnosisEventHandler(d)

	if d.KafkaConsumer == nil {
		handler.log.Warnf("Kafka consumer not configured, skipping event registration")
		return handler, nil
	}

	topic := "samavaya.agriculture.diagnosis.events"
	handler.log.Infow("msg", "registering diagnosis event consumer", "topic", topic)

	// The actual Kafka subscription is wired during application bootstrap.
	// The handler.HandleEvent method is the callback for incoming messages.

	return handler, nil
}

// IsDiagnosisEvent checks if a domain event type belongs to the diagnosis domain.
func IsDiagnosisEvent(eventType domain.EventType) bool {
	switch eventType {
	case EventTypeDiagnosisSubmitted,
		EventTypeDiagnosisCompleted,
		EventTypeDiagnosisFailed,
		EventTypeDiagnosisTreatmentGenerated:
		return true
	default:
		return false
	}
}
