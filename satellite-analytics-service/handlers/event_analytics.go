package handlers

import (
	"context"
	"encoding/json"
	"fmt"

	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9log"
)

// Analytics event type constants matching those in services.
const (
	EventTypeStressDetected    domain.EventType = "agriculture.satellite.analytics.stress.detected"
	EventTypeAnalysisCompleted domain.EventType = "agriculture.satellite.analytics.analysis.completed"
)

// StressDetectedEventData represents the data payload for stress detection events.
type StressDetectedEventData struct {
	FarmID           string `json:"farm_id"`
	FieldID          string `json:"field_id"`
	ProcessingJobID  string `json:"processing_job_id"`
	AlertCount       int    `json:"alert_count"`
	StressType       string `json:"stress_type,omitempty"`
	Severity         string `json:"severity,omitempty"`
}

// AnalysisCompletedEventData represents the data payload for analysis completed events.
type AnalysisCompletedEventData struct {
	FarmID       string `json:"farm_id"`
	FieldID      string `json:"field_id"`
	AnalysisType string `json:"analysis_type"`
	AnalysisID   string `json:"analysis_id"`
	MetricName   string `json:"metric_name"`
}

// AnalyticsEventHandler handles incoming analytics-related domain events (consumer side).
type AnalyticsEventHandler struct {
	d   deps.ServiceDeps
	log *p9log.Helper
}

// NewAnalyticsEventHandler creates a new AnalyticsEventHandler for consuming analytics events.
func NewAnalyticsEventHandler(d deps.ServiceDeps) *AnalyticsEventHandler {
	return &AnalyticsEventHandler{
		d:   d,
		log: p9log.NewHelper(p9log.With(d.Log, "component", "AnalyticsEventHandler")),
	}
}

// HandleEvent is the entry point for consuming an analytics domain event.
// It dispatches to the appropriate handler based on event type.
func (h *AnalyticsEventHandler) HandleEvent(ctx context.Context, event *domain.DomainEvent) error {
	if event == nil {
		return fmt.Errorf("received nil event")
	}

	h.log.Infow("msg", "handling analytics event",
		"event_id", event.ID,
		"event_type", string(event.Type),
		"aggregate_id", event.AggregateID,
	)

	switch event.Type {
	case EventTypeStressDetected:
		return h.handleStressDetected(ctx, event)
	case EventTypeAnalysisCompleted:
		return h.handleAnalysisCompleted(ctx, event)
	default:
		h.log.Warnf("unhandled analytics event type: %s", event.Type)
		return nil
	}
}

// handleStressDetected processes a stress detected event.
func (h *AnalyticsEventHandler) handleStressDetected(ctx context.Context, event *domain.DomainEvent) error {
	data := &StressDetectedEventData{}
	raw, err := json.Marshal(event.Data)
	if err != nil {
		return fmt.Errorf("failed to marshal event data: %w", err)
	}
	if err := json.Unmarshal(raw, data); err != nil {
		h.log.Errorw("msg", "failed to extract stress detected event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "stress detected event received",
		"farm_id", data.FarmID,
		"field_id", data.FieldID,
		"processing_job_id", data.ProcessingJobID,
		"alert_count", data.AlertCount,
		"stress_type", data.StressType,
		"severity", data.Severity,
	)

	// Downstream consumers can react here:
	// - Send push notifications to farm owners about detected stress
	// - Trigger automated irrigation adjustments
	// - Update farm dashboard with new alerts
	// - Log stress event for historical tracking

	return nil
}

// handleAnalysisCompleted processes an analysis completed event.
func (h *AnalyticsEventHandler) handleAnalysisCompleted(ctx context.Context, event *domain.DomainEvent) error {
	data := &AnalysisCompletedEventData{}
	raw, err := json.Marshal(event.Data)
	if err != nil {
		return fmt.Errorf("failed to marshal event data: %w", err)
	}
	if err := json.Unmarshal(raw, data); err != nil {
		h.log.Errorw("msg", "failed to extract analysis completed event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "analysis completed event received",
		"farm_id", data.FarmID,
		"field_id", data.FieldID,
		"analysis_type", data.AnalysisType,
		"analysis_id", data.AnalysisID,
		"metric_name", data.MetricName,
	)

	// Downstream consumers can react here:
	// - Update field health dashboards with new analysis results
	// - Trigger downstream dependent analyses
	// - Generate reports or summaries
	// - Update tile service to regenerate visualization tiles

	return nil
}

// RegisterAnalyticsEventConsumer registers the analytics event handler with the Kafka consumer.
// This should be called during service initialization.
func RegisterAnalyticsEventConsumer(d deps.ServiceDeps) (*AnalyticsEventHandler, error) {
	handler := NewAnalyticsEventHandler(d)

	if d.KafkaConsumer == nil {
		handler.log.Warnf("Kafka consumer not configured, skipping event registration")
		return handler, nil
	}

	topic := "samavaya.agriculture.satellite.analytics.events"
	handler.log.Infow("msg", "registering analytics event consumer", "topic", topic)

	// The actual Kafka subscription is wired during application bootstrap.
	// The handler.HandleEvent method is the callback for incoming messages.

	return handler, nil
}

// IsAnalyticsEvent checks if a domain event type belongs to the analytics domain.
func IsAnalyticsEvent(eventType domain.EventType) bool {
	switch eventType {
	case EventTypeStressDetected,
		EventTypeAnalysisCompleted:
		return true
	default:
		return false
	}
}
