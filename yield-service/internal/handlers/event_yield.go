package handlers

import (
	"context"
	"encoding/json"
	"fmt"

	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9log"
)

// Yield event type constants matching those in services.
const (
	EventTypeYieldPredicted      domain.EventType = "agriculture.yield.predicted"
	EventTypeYieldRecorded       domain.EventType = "agriculture.yield.recorded"
	EventTypeHarvestPlanCreated  domain.EventType = "agriculture.yield.harvest_plan.created"
	EventTypePerformanceAnalyzed domain.EventType = "agriculture.yield.performance.analyzed"
)

// YieldPredictionEventData represents the data payload for yield prediction events.
type YieldPredictionEventData struct {
	PredictionID string  `json:"prediction_id"`
	TenantID     string  `json:"tenant_id"`
	FarmID       string  `json:"farm_id"`
	FieldID      string  `json:"field_id"`
	CropID       string  `json:"crop_id"`
	Season       string  `json:"season,omitempty"`
	Year         int32   `json:"year,omitempty"`
	PredictedKg  float64 `json:"predicted_kg_per_hectare,omitempty"`
	Confidence   float64 `json:"confidence_pct,omitempty"`
}

// YieldRecordEventData represents the data payload for yield recorded events.
type YieldRecordEventData struct {
	RecordID    string  `json:"record_id"`
	TenantID    string  `json:"tenant_id"`
	FarmID      string  `json:"farm_id"`
	FieldID     string  `json:"field_id"`
	CropID      string  `json:"crop_id"`
	Season      string  `json:"season,omitempty"`
	Year        int32   `json:"year,omitempty"`
	ActualKg    float64 `json:"actual_kg_per_hectare,omitempty"`
	QualityGrade string `json:"quality_grade,omitempty"`
}

// HarvestPlanEventData represents the data payload for harvest plan events.
type HarvestPlanEventData struct {
	PlanID   string `json:"plan_id"`
	TenantID string `json:"tenant_id"`
	FarmID   string `json:"farm_id"`
	FieldID  string `json:"field_id"`
	CropID   string `json:"crop_id"`
	Season   string `json:"season,omitempty"`
	Year     int32  `json:"year,omitempty"`
	Status   string `json:"status,omitempty"`
}

// PerformanceEventData represents the data payload for performance analysis events.
type PerformanceEventData struct {
	PerformanceID string  `json:"performance_id"`
	TenantID      string  `json:"tenant_id"`
	FarmID        string  `json:"farm_id"`
	FieldID       string  `json:"field_id"`
	CropID        string  `json:"crop_id"`
	Season        string  `json:"season,omitempty"`
	Year          int32   `json:"year,omitempty"`
	VariancePct   float64 `json:"variance_pct,omitempty"`
}

// YieldEventHandler handles incoming yield-related domain events (consumer side).
type YieldEventHandler struct {
	d   deps.ServiceDeps
	log *p9log.Helper
}

// NewYieldEventHandler creates a new YieldEventHandler for consuming yield events.
func NewYieldEventHandler(d deps.ServiceDeps) *YieldEventHandler {
	return &YieldEventHandler{
		d:   d,
		log: p9log.NewHelper(p9log.With(d.Log, "component", "YieldEventHandler")),
	}
}

// HandleEvent is the entry point for consuming a yield domain event.
// It dispatches to the appropriate handler based on event type.
func (h *YieldEventHandler) HandleEvent(ctx context.Context, event *domain.DomainEvent) error {
	if event == nil {
		return fmt.Errorf("received nil event")
	}

	h.log.Infow("msg", "handling yield event",
		"event_id", event.ID,
		"event_type", string(event.Type),
		"aggregate_id", event.AggregateID,
	)

	switch event.Type {
	case EventTypeYieldPredicted:
		return h.handleYieldPredicted(ctx, event)
	case EventTypeYieldRecorded:
		return h.handleYieldRecorded(ctx, event)
	case EventTypeHarvestPlanCreated:
		return h.handleHarvestPlanCreated(ctx, event)
	case EventTypePerformanceAnalyzed:
		return h.handlePerformanceAnalyzed(ctx, event)
	default:
		h.log.Warnf("unhandled yield event type: %s", event.Type)
		return nil
	}
}

// handleYieldPredicted processes a yield predicted event.
func (h *YieldEventHandler) handleYieldPredicted(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractYieldPredictionEventData(event)
	if err != nil {
		h.log.Errorw("msg", "failed to extract yield predicted event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "yield predicted event received",
		"prediction_id", data.PredictionID,
		"tenant_id", data.TenantID,
		"farm_id", data.FarmID,
		"crop_id", data.CropID,
		"predicted_kg", data.PredictedKg,
	)

	// Downstream consumers can react here:
	// - Notify farm-service of updated yield expectations
	// - Update harvest planning recommendations
	// - Trigger irrigation-service adjustments based on predicted yield
	// - Update market forecasting dashboards

	return nil
}

// handleYieldRecorded processes a yield recorded event.
func (h *YieldEventHandler) handleYieldRecorded(ctx context.Context, event *domain.DomainEvent) error {
	data := &YieldRecordEventData{}
	raw, _ := json.Marshal(event.Data)
	if err := json.Unmarshal(raw, data); err != nil {
		h.log.Errorw("msg", "failed to extract yield recorded event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "yield recorded event received",
		"record_id", data.RecordID,
		"tenant_id", data.TenantID,
		"farm_id", data.FarmID,
		"crop_id", data.CropID,
		"actual_kg", data.ActualKg,
	)

	// Downstream consumers can react here:
	// - Update traceability-service with actual harvest data
	// - Trigger crop performance recalculation
	// - Notify market-service of available inventory
	// - Update prediction model training data

	return nil
}

// handleHarvestPlanCreated processes a harvest plan created event.
func (h *YieldEventHandler) handleHarvestPlanCreated(ctx context.Context, event *domain.DomainEvent) error {
	data := &HarvestPlanEventData{}
	raw, _ := json.Marshal(event.Data)
	if err := json.Unmarshal(raw, data); err != nil {
		h.log.Errorw("msg", "failed to extract harvest plan created event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "harvest plan created event received",
		"plan_id", data.PlanID,
		"tenant_id", data.TenantID,
		"farm_id", data.FarmID,
		"field_id", data.FieldID,
	)

	// Downstream consumers can react here:
	// - Schedule labor and equipment resources
	// - Notify logistics-service for transport planning
	// - Update field-service with planned harvest dates
	// - Create calendar entries for farm workers

	return nil
}

// handlePerformanceAnalyzed processes a performance analyzed event.
func (h *YieldEventHandler) handlePerformanceAnalyzed(ctx context.Context, event *domain.DomainEvent) error {
	data := &PerformanceEventData{}
	raw, _ := json.Marshal(event.Data)
	if err := json.Unmarshal(raw, data); err != nil {
		h.log.Errorw("msg", "failed to extract performance analyzed event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "performance analyzed event received",
		"performance_id", data.PerformanceID,
		"tenant_id", data.TenantID,
		"farm_id", data.FarmID,
		"crop_id", data.CropID,
		"variance_pct", data.VariancePct,
	)

	// Downstream consumers can react here:
	// - Generate performance alerts if variance exceeds thresholds
	// - Update recommendation-service with new performance insights
	// - Trigger soil analysis if underperformance detected
	// - Update regional benchmarking data

	return nil
}

// extractYieldPredictionEventData extracts YieldPredictionEventData from a domain event's Data map.
func extractYieldPredictionEventData(event *domain.DomainEvent) (*YieldPredictionEventData, error) {
	data := &YieldPredictionEventData{}
	raw, err := json.Marshal(event.Data)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal event data: %w", err)
	}
	if err := json.Unmarshal(raw, data); err != nil {
		return nil, fmt.Errorf("failed to unmarshal event data: %w", err)
	}
	return data, nil
}

// RegisterYieldEventConsumer registers the yield event handler with the Kafka consumer.
// This should be called during service initialization.
func RegisterYieldEventConsumer(d deps.ServiceDeps) (*YieldEventHandler, error) {
	handler := NewYieldEventHandler(d)

	if d.KafkaConsumer == nil {
		handler.log.Warnf("Kafka consumer not configured, skipping event registration")
		return handler, nil
	}

	topic := "samavaya.agriculture.yield.events"
	handler.log.Infow("msg", "registering yield event consumer", "topic", topic)

	// The actual Kafka subscription is wired during application bootstrap.
	// The handler.HandleEvent method is the callback for incoming messages.

	return handler, nil
}

// IsYieldEvent checks if a domain event type belongs to the yield domain.
func IsYieldEvent(eventType domain.EventType) bool {
	switch eventType {
	case EventTypeYieldPredicted,
		EventTypeYieldRecorded,
		EventTypeHarvestPlanCreated,
		EventTypePerformanceAnalyzed:
		return true
	default:
		return false
	}
}
