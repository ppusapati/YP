package handlers

import (
	"context"
	"encoding/json"
	"fmt"

	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9log"
)

// Pest event type constants matching those in services.
const (
	EventTypePestRiskPredicted     domain.EventType = "agriculture.pest.risk.predicted"
	EventTypeObservationReported   domain.EventType = "agriculture.pest.observation.reported"
	EventTypePestAlertCreated      domain.EventType = "agriculture.pest.alert.created"
	EventTypePestAlertAcknowledged domain.EventType = "agriculture.pest.alert.acknowledged"
)

// PestRiskPredictedEventData represents the data payload for pest risk predicted events.
type PestRiskPredictedEventData struct {
	PredictionID  string `json:"prediction_id"`
	FarmID        string `json:"farm_id"`
	FieldID       string `json:"field_id"`
	PestSpeciesID string `json:"pest_species_id"`
	RiskLevel     string `json:"risk_level"`
	RiskScore     int    `json:"risk_score"`
	TenantID      string `json:"tenant_id"`
}

// ObservationReportedEventData represents the data payload for observation reported events.
type ObservationReportedEventData struct {
	ObservationID string `json:"observation_id"`
	FarmID        string `json:"farm_id"`
	FieldID       string `json:"field_id"`
	PestSpeciesID string `json:"pest_species_id"`
	PestCount     int    `json:"pest_count"`
	DamageLevel   string `json:"damage_level"`
	TenantID      string `json:"tenant_id"`
}

// AlertCreatedEventData represents the data payload for alert created events.
type AlertCreatedEventData struct {
	AlertID       string `json:"alert_id"`
	FarmID        string `json:"farm_id"`
	FieldID       string `json:"field_id"`
	PestSpeciesID string `json:"pest_species_id"`
	RiskLevel     string `json:"risk_level"`
	Title         string `json:"title"`
	TenantID      string `json:"tenant_id"`
}

// AlertAcknowledgedEventData represents the data payload for alert acknowledged events.
type AlertAcknowledgedEventData struct {
	AlertID        string `json:"alert_id"`
	FarmID         string `json:"farm_id"`
	FieldID        string `json:"field_id"`
	AcknowledgedBy string `json:"acknowledged_by"`
	TenantID       string `json:"tenant_id"`
}

// PestEventHandler handles incoming pest-related domain events (consumer side).
type PestEventHandler struct {
	d   deps.ServiceDeps
	log *p9log.Helper
}

// NewPestEventHandler creates a new PestEventHandler for consuming pest events.
func NewPestEventHandler(d deps.ServiceDeps) *PestEventHandler {
	return &PestEventHandler{
		d:   d,
		log: p9log.NewHelper(p9log.With(d.Log, "component", "PestEventHandler")),
	}
}

// HandleEvent is the entry point for consuming a pest domain event.
// It dispatches to the appropriate handler based on event type.
func (h *PestEventHandler) HandleEvent(ctx context.Context, event *domain.DomainEvent) error {
	if event == nil {
		return fmt.Errorf("received nil event")
	}

	h.log.Infow("msg", "handling pest event",
		"event_id", event.ID,
		"event_type", string(event.Type),
		"aggregate_id", event.AggregateID,
	)

	switch event.Type {
	case EventTypePestRiskPredicted:
		return h.handlePestRiskPredicted(ctx, event)
	case EventTypeObservationReported:
		return h.handleObservationReported(ctx, event)
	case EventTypePestAlertCreated:
		return h.handleAlertCreated(ctx, event)
	case EventTypePestAlertAcknowledged:
		return h.handleAlertAcknowledged(ctx, event)
	default:
		h.log.Warnf("unhandled pest event type: %s", event.Type)
		return nil
	}
}

// handlePestRiskPredicted processes a pest risk predicted event.
func (h *PestEventHandler) handlePestRiskPredicted(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractPestEventData[PestRiskPredictedEventData](event)
	if err != nil {
		h.log.Errorw("msg", "failed to extract pest risk predicted event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "pest risk predicted event received",
		"prediction_id", data.PredictionID,
		"farm_id", data.FarmID,
		"field_id", data.FieldID,
		"risk_level", data.RiskLevel,
		"risk_score", data.RiskScore,
	)

	// Downstream consumers can react here:
	// - Auto-create alerts for HIGH and CRITICAL risk predictions
	// - Notify farm owners and agronomists of new predictions
	// - Update risk maps with latest prediction data
	// - Trigger drone surveillance scheduling for affected fields
	// - Log prediction to analytics pipeline for model improvement

	return nil
}

// handleObservationReported processes a pest observation reported event.
func (h *PestEventHandler) handleObservationReported(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractPestEventData[ObservationReportedEventData](event)
	if err != nil {
		h.log.Errorw("msg", "failed to extract observation reported event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "pest observation reported event received",
		"observation_id", data.ObservationID,
		"farm_id", data.FarmID,
		"field_id", data.FieldID,
		"pest_count", data.PestCount,
		"damage_level", data.DamageLevel,
	)

	// Downstream consumers can react here:
	// - Trigger re-computation of risk predictions for the affected field
	// - Notify neighboring farms if infestation is spreading
	// - Update historical occurrence records for future predictions
	// - Send observation data to satellite/imagery analysis service
	// - Generate field scouting recommendations

	return nil
}

// handleAlertCreated processes a pest alert created event.
func (h *PestEventHandler) handleAlertCreated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractPestEventData[AlertCreatedEventData](event)
	if err != nil {
		h.log.Errorw("msg", "failed to extract alert created event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "pest alert created event received",
		"alert_id", data.AlertID,
		"farm_id", data.FarmID,
		"risk_level", data.RiskLevel,
		"title", data.Title,
	)

	// Downstream consumers can react here:
	// - Send push notifications to farm owners and field managers
	// - Trigger SMS/email alerts for critical risk levels
	// - Update dashboard real-time alert counters
	// - Initiate automated response workflows (e.g., irrigation adjustments)
	// - Notify regional agricultural authorities for critical outbreaks

	return nil
}

// handleAlertAcknowledged processes a pest alert acknowledged event.
func (h *PestEventHandler) handleAlertAcknowledged(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractPestEventData[AlertAcknowledgedEventData](event)
	if err != nil {
		h.log.Errorw("msg", "failed to extract alert acknowledged event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "pest alert acknowledged event received",
		"alert_id", data.AlertID,
		"farm_id", data.FarmID,
		"acknowledged_by", data.AcknowledgedBy,
	)

	// Downstream consumers can react here:
	// - Update notification status to reflect acknowledgment
	// - Log acknowledgment for audit and compliance tracking
	// - Trigger follow-up action reminders if treatment is not applied
	// - Update real-time dashboard alert status

	return nil
}

// extractPestEventData extracts typed event data from a domain event's Data map.
func extractPestEventData[T any](event *domain.DomainEvent) (*T, error) {
	data := new(T)
	raw, err := json.Marshal(event.Data)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal event data: %w", err)
	}
	if err := json.Unmarshal(raw, data); err != nil {
		return nil, fmt.Errorf("failed to unmarshal event data: %w", err)
	}
	return data, nil
}

// RegisterPestEventConsumer registers the pest event handler with the Kafka consumer.
// This should be called during service initialization.
func RegisterPestEventConsumer(d deps.ServiceDeps) (*PestEventHandler, error) {
	handler := NewPestEventHandler(d)

	if d.KafkaConsumer == nil {
		handler.log.Warnf("Kafka consumer not configured, skipping event registration")
		return handler, nil
	}

	topic := "samavaya.agriculture.pest.events"
	handler.log.Infow("msg", "registering pest event consumer", "topic", topic)

	// The actual Kafka subscription is wired during application bootstrap.
	// The handler.HandleEvent method is the callback for incoming messages.

	return handler, nil
}

// IsPestEvent checks if a domain event type belongs to the pest domain.
func IsPestEvent(eventType domain.EventType) bool {
	switch eventType {
	case EventTypePestRiskPredicted,
		EventTypeObservationReported,
		EventTypePestAlertCreated,
		EventTypePestAlertAcknowledged:
		return true
	default:
		return false
	}
}
