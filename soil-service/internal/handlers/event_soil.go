package handlers

import (
	"context"
	"encoding/json"
	"fmt"

	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9log"
)

// Soil event type constants matching those in services.
const (
	EventTypeSoilSampleCreated      domain.EventType = "agriculture.soil.sample.created"
	EventTypeSoilAnalysisCompleted  domain.EventType = "agriculture.soil.analysis.completed"
	EventTypeSoilHealthUpdated      domain.EventType = "agriculture.soil.health.updated"
	EventTypeSoilReportGenerated    domain.EventType = "agriculture.soil.report.generated"
)

// SoilEventData represents the data payload for soil-related events.
type SoilEventData struct {
	SampleID   string `json:"sample_id,omitempty"`
	FieldID    string `json:"field_id,omitempty"`
	FarmID     string `json:"farm_id,omitempty"`
	TenantID   string `json:"tenant_id,omitempty"`
	AnalysisID string `json:"analysis_id,omitempty"`
}

// SoilAnalysisEventData represents the data payload for soil analysis events.
type SoilAnalysisEventData struct {
	AnalysisID      string  `json:"analysis_id"`
	SampleID        string  `json:"sample_id"`
	FieldID         string  `json:"field_id,omitempty"`
	FarmID          string  `json:"farm_id,omitempty"`
	SoilHealthScore float64 `json:"soil_health_score"`
	HealthCategory  string  `json:"health_category,omitempty"`
	TenantID        string  `json:"tenant_id,omitempty"`
}

// SoilHealthEventData represents the data payload for soil health assessment events.
type SoilHealthEventData struct {
	FieldID         string  `json:"field_id"`
	FarmID          string  `json:"farm_id,omitempty"`
	TenantID        string  `json:"tenant_id,omitempty"`
	OverallScore    float64 `json:"overall_score"`
	Category        string  `json:"category,omitempty"`
	PhysicalScore   float64 `json:"physical_score,omitempty"`
	ChemicalScore   float64 `json:"chemical_score,omitempty"`
	BiologicalScore float64 `json:"biological_score,omitempty"`
}

// SoilReportEventData represents the data payload for soil report generation events.
type SoilReportEventData struct {
	ReportID string `json:"report_id"`
	FieldID  string `json:"field_id"`
	FarmID   string `json:"farm_id,omitempty"`
	TenantID string `json:"tenant_id,omitempty"`
}

// SoilEventHandler handles incoming soil-related domain events (consumer side).
type SoilEventHandler struct {
	d   deps.ServiceDeps
	log *p9log.Helper
}

// NewSoilEventHandler creates a new SoilEventHandler for consuming soil events.
func NewSoilEventHandler(d deps.ServiceDeps) *SoilEventHandler {
	return &SoilEventHandler{
		d:   d,
		log: p9log.NewHelper(p9log.With(d.Log, "component", "SoilEventHandler")),
	}
}

// HandleEvent is the entry point for consuming a soil domain event.
// It dispatches to the appropriate handler based on event type.
func (h *SoilEventHandler) HandleEvent(ctx context.Context, event *domain.DomainEvent) error {
	if event == nil {
		return fmt.Errorf("received nil event")
	}

	h.log.Infow("msg", "handling soil event",
		"event_id", event.ID,
		"event_type", string(event.Type),
		"aggregate_id", event.AggregateID,
	)

	switch event.Type {
	case EventTypeSoilSampleCreated:
		return h.handleSoilSampleCreated(ctx, event)
	case EventTypeSoilAnalysisCompleted:
		return h.handleSoilAnalysisCompleted(ctx, event)
	case EventTypeSoilHealthUpdated:
		return h.handleSoilHealthUpdated(ctx, event)
	case EventTypeSoilReportGenerated:
		return h.handleSoilReportGenerated(ctx, event)
	default:
		h.log.Warnf("unhandled soil event type: %s", event.Type)
		return nil
	}
}

// handleSoilSampleCreated processes a soil sample created event.
func (h *SoilEventHandler) handleSoilSampleCreated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractSoilEventData(event)
	if err != nil {
		h.log.Errorw("msg", "failed to extract soil sample created event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "soil sample created event received",
		"sample_id", data.SampleID,
		"field_id", data.FieldID,
		"farm_id", data.FarmID,
		"tenant_id", data.TenantID,
	)

	// Downstream consumers can react here:
	// - Trigger automatic soil analysis pipeline
	// - Update field-service with latest sample metadata
	// - Notify agronomists of new sample availability
	// - Update soil map generation queue

	return nil
}

// handleSoilAnalysisCompleted processes a soil analysis completed event.
func (h *SoilEventHandler) handleSoilAnalysisCompleted(ctx context.Context, event *domain.DomainEvent) error {
	analysisData := &SoilAnalysisEventData{}
	raw, _ := json.Marshal(event.Data)
	if err := json.Unmarshal(raw, analysisData); err != nil {
		h.log.Errorw("msg", "failed to extract soil analysis completed event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "soil analysis completed event received",
		"analysis_id", analysisData.AnalysisID,
		"sample_id", analysisData.SampleID,
		"field_id", analysisData.FieldID,
		"soil_health_score", analysisData.SoilHealthScore,
		"health_category", analysisData.HealthCategory,
	)

	// Downstream consumers can react here:
	// - Update crop-service with soil fertility data for yield predictions
	// - Trigger irrigation-service adjustments based on soil conditions
	// - Notify farm-service of nutrient deficiencies for fertilization planning
	// - Feed data to pest-prediction-service for disease risk assessment

	return nil
}

// handleSoilHealthUpdated processes a soil health updated event.
func (h *SoilEventHandler) handleSoilHealthUpdated(ctx context.Context, event *domain.DomainEvent) error {
	healthData := &SoilHealthEventData{}
	raw, _ := json.Marshal(event.Data)
	if err := json.Unmarshal(raw, healthData); err != nil {
		h.log.Errorw("msg", "failed to extract soil health updated event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "soil health updated event received",
		"field_id", healthData.FieldID,
		"farm_id", healthData.FarmID,
		"overall_score", healthData.OverallScore,
		"category", healthData.Category,
		"physical_score", healthData.PhysicalScore,
		"chemical_score", healthData.ChemicalScore,
		"biological_score", healthData.BiologicalScore,
	)

	// Downstream consumers can react here:
	// - Update farm-service dashboard with health trend data
	// - Generate alerts for declining soil health scores
	// - Trigger cover crop recommendations in crop-service
	// - Update sustainability reporting metrics

	return nil
}

// handleSoilReportGenerated processes a soil report generated event.
func (h *SoilEventHandler) handleSoilReportGenerated(ctx context.Context, event *domain.DomainEvent) error {
	reportData := &SoilReportEventData{}
	raw, _ := json.Marshal(event.Data)
	if err := json.Unmarshal(raw, reportData); err != nil {
		h.log.Errorw("msg", "failed to extract soil report generated event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "soil report generated event received",
		"report_id", reportData.ReportID,
		"field_id", reportData.FieldID,
		"farm_id", reportData.FarmID,
		"tenant_id", reportData.TenantID,
	)

	// Downstream consumers can react here:
	// - Send report notification to farm operators via notification-service
	// - Archive report in document management system
	// - Update compliance tracking for regulatory reporting
	// - Feed report data to analytics dashboards

	return nil
}

// extractSoilEventData extracts SoilEventData from a domain event's Data map.
func extractSoilEventData(event *domain.DomainEvent) (*SoilEventData, error) {
	data := &SoilEventData{}
	raw, err := json.Marshal(event.Data)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal event data: %w", err)
	}
	if err := json.Unmarshal(raw, data); err != nil {
		return nil, fmt.Errorf("failed to unmarshal event data: %w", err)
	}
	return data, nil
}

// RegisterSoilEventConsumer registers the soil event handler with the Kafka consumer.
// This should be called during service initialization.
func RegisterSoilEventConsumer(d deps.ServiceDeps) (*SoilEventHandler, error) {
	handler := NewSoilEventHandler(d)

	if d.KafkaConsumer == nil {
		handler.log.Warnf("Kafka consumer not configured, skipping event registration")
		return handler, nil
	}

	topic := "samavaya.agriculture.soil.events"
	handler.log.Infow("msg", "registering soil event consumer", "topic", topic)

	// The actual Kafka subscription is wired during application bootstrap.
	// The handler.HandleEvent method is the callback for incoming messages.

	return handler, nil
}

// IsSoilEvent checks if a domain event type belongs to the soil domain.
func IsSoilEvent(eventType domain.EventType) bool {
	switch eventType {
	case EventTypeSoilSampleCreated,
		EventTypeSoilAnalysisCompleted,
		EventTypeSoilHealthUpdated,
		EventTypeSoilReportGenerated:
		return true
	default:
		return false
	}
}
