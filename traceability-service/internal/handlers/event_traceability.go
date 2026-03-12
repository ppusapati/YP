package handlers

import (
	"context"
	"encoding/json"
	"fmt"

	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9log"
)

// Traceability event type constants matching those in services.
const (
	EventTypeRecordCreated        domain.EventType = "agriculture.traceability.record.created"
	EventTypeSupplyChainEventAdded domain.EventType = "agriculture.traceability.supply_chain.event_added"
	EventTypeCertificationCreated domain.EventType = "agriculture.traceability.certification.created"
	EventTypeCertificationVerified domain.EventType = "agriculture.traceability.certification.verified"
	EventTypeBatchCreated         domain.EventType = "agriculture.traceability.batch.created"
	EventTypeQRGenerated          domain.EventType = "agriculture.traceability.qr.generated"
)

// RecordEventData represents the data payload for record-related events.
type RecordEventData struct {
	RecordID    string `json:"record_id"`
	TenantID    string `json:"tenant_id"`
	FarmID      string `json:"farm_id"`
	ProductType string `json:"product_type,omitempty"`
	BatchNumber string `json:"batch_number,omitempty"`
}

// SupplyChainEventData represents the data payload for supply chain events.
type SupplyChainEventData struct {
	EventID   string `json:"event_id"`
	RecordID  string `json:"record_id"`
	EventType string `json:"event_type"`
	Actor     string `json:"actor,omitempty"`
	Location  string `json:"location,omitempty"`
}

// CertificationEventData represents the data payload for certification-related events.
type CertificationEventData struct {
	CertificationID string `json:"certification_id"`
	RecordID        string `json:"record_id"`
	CertType        string `json:"cert_type"`
	CertNumber      string `json:"cert_number,omitempty"`
	VerifiedBy      string `json:"verified_by,omitempty"`
}

// BatchEventData represents the data payload for batch-related events.
type BatchEventData struct {
	BatchID     string  `json:"batch_id"`
	RecordID    string  `json:"record_id"`
	BatchNumber string  `json:"batch_number"`
	Quantity    float64 `json:"quantity,omitempty"`
}

// QREventData represents the data payload for QR code-related events.
type QREventData struct {
	QRID     string `json:"qr_id"`
	RecordID string `json:"record_id"`
	BatchID  string `json:"batch_id,omitempty"`
}

// TraceabilityEventHandler handles incoming traceability-related domain events (consumer side).
type TraceabilityEventHandler struct {
	d   deps.ServiceDeps
	log *p9log.Helper
}

// NewTraceabilityEventHandler creates a new TraceabilityEventHandler for consuming traceability events.
func NewTraceabilityEventHandler(d deps.ServiceDeps) *TraceabilityEventHandler {
	return &TraceabilityEventHandler{
		d:   d,
		log: p9log.NewHelper(p9log.With(d.Log, "component", "TraceabilityEventHandler")),
	}
}

// HandleEvent is the entry point for consuming a traceability domain event.
// It dispatches to the appropriate handler based on event type.
func (h *TraceabilityEventHandler) HandleEvent(ctx context.Context, event *domain.DomainEvent) error {
	if event == nil {
		return fmt.Errorf("received nil event")
	}

	h.log.Infow("msg", "handling traceability event",
		"event_id", event.ID,
		"event_type", string(event.Type),
		"aggregate_id", event.AggregateID,
	)

	switch event.Type {
	case EventTypeRecordCreated:
		return h.handleRecordCreated(ctx, event)
	case EventTypeSupplyChainEventAdded:
		return h.handleSupplyChainEventAdded(ctx, event)
	case EventTypeCertificationCreated:
		return h.handleCertificationCreated(ctx, event)
	case EventTypeCertificationVerified:
		return h.handleCertificationVerified(ctx, event)
	case EventTypeBatchCreated:
		return h.handleBatchCreated(ctx, event)
	case EventTypeQRGenerated:
		return h.handleQRGenerated(ctx, event)
	default:
		h.log.Warnf("unhandled traceability event type: %s", event.Type)
		return nil
	}
}

// handleRecordCreated processes a traceability record created event.
func (h *TraceabilityEventHandler) handleRecordCreated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractRecordEventData(event)
	if err != nil {
		h.log.Errorw("msg", "failed to extract record created event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "traceability record created event received",
		"record_id", data.RecordID,
		"tenant_id", data.TenantID,
		"farm_id", data.FarmID,
		"product_type", data.ProductType,
	)

	// Downstream consumers can react here:
	// - Initialize supply chain tracking for the new record
	// - Notify farm-service of new traceability association
	// - Create initial compliance check entry
	// - Index record for search and analytics

	return nil
}

// handleSupplyChainEventAdded processes a supply chain event added event.
func (h *TraceabilityEventHandler) handleSupplyChainEventAdded(ctx context.Context, event *domain.DomainEvent) error {
	data := &SupplyChainEventData{}
	raw, _ := json.Marshal(event.Data)
	if err := json.Unmarshal(raw, data); err != nil {
		h.log.Errorw("msg", "failed to extract supply chain event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "supply chain event added event received",
		"event_id", data.EventID,
		"record_id", data.RecordID,
		"event_type", data.EventType,
		"actor", data.Actor,
	)

	// Downstream consumers can react here:
	// - Update blockchain ledger with new supply chain entry
	// - Trigger verification hash validation
	// - Update real-time tracking dashboards
	// - Notify downstream supply chain participants

	return nil
}

// handleCertificationCreated processes a certification created event.
func (h *TraceabilityEventHandler) handleCertificationCreated(ctx context.Context, event *domain.DomainEvent) error {
	data := &CertificationEventData{}
	raw, _ := json.Marshal(event.Data)
	if err := json.Unmarshal(raw, data); err != nil {
		h.log.Errorw("msg", "failed to extract certification created event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "certification created event received",
		"certification_id", data.CertificationID,
		"record_id", data.RecordID,
		"cert_type", data.CertType,
	)

	// Downstream consumers can react here:
	// - Schedule certification verification workflow
	// - Notify certification authority for review
	// - Update compliance status tracking
	// - Add certification to record's compliance profile

	return nil
}

// handleCertificationVerified processes a certification verified event.
func (h *TraceabilityEventHandler) handleCertificationVerified(ctx context.Context, event *domain.DomainEvent) error {
	data := &CertificationEventData{}
	raw, _ := json.Marshal(event.Data)
	if err := json.Unmarshal(raw, data); err != nil {
		h.log.Errorw("msg", "failed to extract certification verified event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "certification verified event received",
		"certification_id", data.CertificationID,
		"record_id", data.RecordID,
		"cert_type", data.CertType,
		"verified_by", data.VerifiedBy,
	)

	// Downstream consumers can react here:
	// - Update record compliance status to reflect verified certification
	// - Trigger compliance report re-generation
	// - Notify record owner of certification verification
	// - Update marketplace listing with verified certification badge

	return nil
}

// handleBatchCreated processes a batch created event.
func (h *TraceabilityEventHandler) handleBatchCreated(ctx context.Context, event *domain.DomainEvent) error {
	data := &BatchEventData{}
	raw, _ := json.Marshal(event.Data)
	if err := json.Unmarshal(raw, data); err != nil {
		h.log.Errorw("msg", "failed to extract batch created event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "batch created event received",
		"batch_id", data.BatchID,
		"record_id", data.RecordID,
		"batch_number", data.BatchNumber,
	)

	// Downstream consumers can react here:
	// - Generate QR codes for the new batch
	// - Initialize inventory tracking for the batch
	// - Notify warehouse management system
	// - Update yield-service with batch production data

	return nil
}

// handleQRGenerated processes a QR code generated event.
func (h *TraceabilityEventHandler) handleQRGenerated(ctx context.Context, event *domain.DomainEvent) error {
	data := &QREventData{}
	raw, _ := json.Marshal(event.Data)
	if err := json.Unmarshal(raw, data); err != nil {
		h.log.Errorw("msg", "failed to extract QR generated event data", "error", err, "event_id", event.ID)
		return err
	}

	h.log.Infow("msg", "QR code generated event received",
		"qr_id", data.QRID,
		"record_id", data.RecordID,
		"batch_id", data.BatchID,
	)

	// Downstream consumers can react here:
	// - Generate QR code image via image generation service
	// - Associate QR code with packaging labels
	// - Update consumer-facing traceability portal
	// - Log QR code generation for audit trail

	return nil
}

// extractRecordEventData extracts RecordEventData from a domain event's Data map.
func extractRecordEventData(event *domain.DomainEvent) (*RecordEventData, error) {
	data := &RecordEventData{}
	raw, err := json.Marshal(event.Data)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal event data: %w", err)
	}
	if err := json.Unmarshal(raw, data); err != nil {
		return nil, fmt.Errorf("failed to unmarshal event data: %w", err)
	}
	return data, nil
}

// RegisterTraceabilityEventConsumer registers the traceability event handler with the Kafka consumer.
// This should be called during service initialization.
func RegisterTraceabilityEventConsumer(d deps.ServiceDeps) (*TraceabilityEventHandler, error) {
	handler := NewTraceabilityEventHandler(d)

	if d.KafkaConsumer == nil {
		handler.log.Warnf("Kafka consumer not configured, skipping event registration")
		return handler, nil
	}

	topic := "samavaya.agriculture.traceability.events"
	handler.log.Infow("msg", "registering traceability event consumer", "topic", topic)

	// The actual Kafka subscription is wired during application bootstrap.
	// The handler.HandleEvent method is the callback for incoming messages.

	return handler, nil
}

// IsTraceabilityEvent checks if a domain event type belongs to the traceability domain.
func IsTraceabilityEvent(eventType domain.EventType) bool {
	switch eventType {
	case EventTypeRecordCreated,
		EventTypeSupplyChainEventAdded,
		EventTypeCertificationCreated,
		EventTypeCertificationVerified,
		EventTypeBatchCreated,
		EventTypeQRGenerated:
		return true
	default:
		return false
	}
}
