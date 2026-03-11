package handlers

import (
	"context"
	"encoding/json"
	"fmt"

	"p9e.in/samavaya/agriculture/field-service/internal/services"
	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9log"
)

// FieldEventType aliases the domain EventType for field-service events.
type FieldEventType = domain.EventType

// Event types published by the field service.
const (
	FieldCreated   FieldEventType = "agriculture.field.created"
	FieldUpdated   FieldEventType = "agriculture.field.updated"
	FieldDeleted   FieldEventType = "agriculture.field.deleted"
	FieldMapped    FieldEventType = "agriculture.field.mapped"
	CropAssigned   FieldEventType = "agriculture.field.crop.assigned"
	FieldSegmented FieldEventType = "agriculture.field.segmented"
)

// FieldCreatedEventData carries the payload for a FieldCreated event.
type FieldCreatedEventData struct {
	FieldID  string `json:"field_id"`
	FarmID   string `json:"farm_id"`
	Name     string `json:"name"`
	TenantID string `json:"tenant_id"`
}

// FieldUpdatedEventData carries the payload for a FieldUpdated event.
type FieldUpdatedEventData struct {
	FieldID  string `json:"field_id"`
	TenantID string `json:"tenant_id"`
}

// FieldDeletedEventData carries the payload for a FieldDeleted event.
type FieldDeletedEventData struct {
	FieldID  string `json:"field_id"`
	TenantID string `json:"tenant_id"`
}

// FieldMappedEventData carries the payload for a FieldMapped (boundary set) event.
type FieldMappedEventData struct {
	FieldID    string `json:"field_id"`
	BoundaryID string `json:"boundary_id"`
	Source     string `json:"source"`
	TenantID   string `json:"tenant_id"`
}

// CropAssignedEventData carries the payload for a CropAssigned event.
type CropAssignedEventData struct {
	FieldID      string `json:"field_id"`
	CropID       string `json:"crop_id"`
	AssignmentID string `json:"assignment_id"`
	Season       string `json:"season"`
	TenantID     string `json:"tenant_id"`
}

// FieldSegmentedEventData carries the payload for a FieldSegmented event.
type FieldSegmentedEventData struct {
	FieldID      string `json:"field_id"`
	SegmentCount int    `json:"segment_count"`
	TenantID     string `json:"tenant_id"`
}

// FieldEventHandler consumes domain events that are relevant to the field service.
type FieldEventHandler struct {
	service services.FieldService
	deps    deps.ServiceDeps
	logger  *p9log.Helper
}

// NewFieldEventHandler creates a new event handler for field-related events.
func NewFieldEventHandler(d deps.ServiceDeps, svc services.FieldService) *FieldEventHandler {
	return &FieldEventHandler{
		service: svc,
		deps:    d,
		logger:  p9log.NewHelper(p9log.With(d.Log, "component", "field_event_handler")),
	}
}

// RegisterConsumers subscribes to Kafka topics that the field service cares about.
// Call this during service startup to begin consuming events.
func (h *FieldEventHandler) RegisterConsumers(ctx context.Context) error {
	if h.deps.KafkaConsumer == nil {
		h.logger.Infow("msg", "kafka consumer not configured, skipping event registration")
		return nil
	}

	topics := []struct {
		topic   string
		handler func(ctx context.Context, data []byte) error
	}{
		{"samavaya.agriculture.field.events", h.handleFieldEvent},
		{"samavaya.farm.events", h.handleFarmEvent},
	}

	for _, t := range topics {
		if err := h.deps.KafkaConsumer.Subscribe(ctx, t.topic, t.handler); err != nil {
			return fmt.Errorf("failed to subscribe to topic %s: %w", t.topic, err)
		}
		h.logger.Infow("msg", "subscribed to topic", "topic", t.topic)
	}

	return nil
}

// handleFieldEvent processes events on the agriculture.field topic.
func (h *FieldEventHandler) handleFieldEvent(ctx context.Context, data []byte) error {
	var evt domain.DomainEvent
	if err := json.Unmarshal(data, &evt); err != nil {
		h.logger.Errorw("msg", "failed to unmarshal field event", "error", err.Error())
		return fmt.Errorf("unmarshal field event: %w", err)
	}

	h.logger.Infow("msg", "received field event",
		"event_type", string(evt.Type),
		"aggregate_id", evt.AggregateID,
		"event_id", evt.ID,
	)

	switch evt.Type {
	case FieldCreated:
		return h.onFieldCreated(ctx, &evt)
	case FieldUpdated:
		return h.onFieldUpdated(ctx, &evt)
	case FieldDeleted:
		return h.onFieldDeleted(ctx, &evt)
	case FieldMapped:
		return h.onFieldMapped(ctx, &evt)
	case CropAssigned:
		return h.onCropAssigned(ctx, &evt)
	case FieldSegmented:
		return h.onFieldSegmented(ctx, &evt)
	default:
		h.logger.Debugw("msg", "unhandled field event type", "event_type", string(evt.Type))
		return nil
	}
}

// handleFarmEvent processes events from the farm service (e.g., farm deleted).
func (h *FieldEventHandler) handleFarmEvent(ctx context.Context, data []byte) error {
	var evt domain.DomainEvent
	if err := json.Unmarshal(data, &evt); err != nil {
		h.logger.Errorw("msg", "failed to unmarshal farm event", "error", err.Error())
		return fmt.Errorf("unmarshal farm event: %w", err)
	}

	h.logger.Infow("msg", "received farm event",
		"event_type", string(evt.Type),
		"aggregate_id", evt.AggregateID,
	)

	// Handle farm deletion: cascade-delete or deactivate fields.
	if evt.Type == "agriculture.farm.deleted" {
		return h.onFarmDeleted(ctx, &evt)
	}

	return nil
}

// ---------------------------------------------------------------------------
// Event handlers
// ---------------------------------------------------------------------------

func (h *FieldEventHandler) onFieldCreated(_ context.Context, evt *domain.DomainEvent) error {
	h.logger.Infow("msg", "processing field.created event",
		"field_id", evt.AggregateID,
		"data", evt.Data,
	)
	// Additional side effects can be added here: notifications, cache warming, etc.
	if h.deps.Metrics != nil {
		h.deps.Metrics.RecordHTTPRequest("field_event", "field.created", 200, 0)
	}
	return nil
}

func (h *FieldEventHandler) onFieldUpdated(_ context.Context, evt *domain.DomainEvent) error {
	h.logger.Infow("msg", "processing field.updated event",
		"field_id", evt.AggregateID,
	)
	if h.deps.Cache != nil {
		cacheKey := fmt.Sprintf("field:%s", evt.AggregateID)
		_ = h.deps.Cache.Delete(context.Background(), cacheKey)
	}
	return nil
}

func (h *FieldEventHandler) onFieldDeleted(_ context.Context, evt *domain.DomainEvent) error {
	h.logger.Infow("msg", "processing field.deleted event",
		"field_id", evt.AggregateID,
	)
	if h.deps.Cache != nil {
		cacheKey := fmt.Sprintf("field:%s", evt.AggregateID)
		_ = h.deps.Cache.Delete(context.Background(), cacheKey)
	}
	return nil
}

func (h *FieldEventHandler) onFieldMapped(_ context.Context, evt *domain.DomainEvent) error {
	h.logger.Infow("msg", "processing field.mapped event",
		"field_id", evt.AggregateID,
		"source", evt.Data["source"],
	)
	// Could trigger satellite imagery analysis, NDVI recalculation, etc.
	return nil
}

func (h *FieldEventHandler) onCropAssigned(_ context.Context, evt *domain.DomainEvent) error {
	h.logger.Infow("msg", "processing crop.assigned event",
		"field_id", evt.AggregateID,
		"crop_id", evt.Data["crop_id"],
	)
	// Could trigger irrigation schedule recalculation, pest prediction update, etc.
	return nil
}

func (h *FieldEventHandler) onFieldSegmented(_ context.Context, evt *domain.DomainEvent) error {
	h.logger.Infow("msg", "processing field.segmented event",
		"field_id", evt.AggregateID,
		"segment_count", evt.Data["segment_count"],
	)
	// Could trigger per-segment sensor assignment, zone-based irrigation, etc.
	return nil
}

func (h *FieldEventHandler) onFarmDeleted(ctx context.Context, evt *domain.DomainEvent) error {
	farmID := evt.AggregateID
	h.logger.Infow("msg", "processing farm.deleted event, will cascade to fields",
		"farm_id", farmID,
	)

	// Retrieve tenant from event metadata.
	tenantID, ok := evt.Metadata["tenant_id"]
	if !ok {
		h.logger.Warnw("msg", "farm.deleted event missing tenant_id metadata", "farm_id", farmID)
		return nil
	}

	// List all fields belonging to the deleted farm and soft-delete them.
	fields, _, err := h.service.ListFieldsByFarm(ctx, farmID, 1000, 0)
	if err != nil {
		h.logger.Errorw("msg", "failed to list fields for deleted farm",
			"farm_id", farmID, "error", err.Error())
		return fmt.Errorf("list fields for farm %s: %w", farmID, err)
	}

	for _, f := range fields {
		if err := h.service.DeleteField(ctx, f.ID); err != nil {
			h.logger.Errorw("msg", "failed to cascade-delete field",
				"field_id", f.ID, "farm_id", farmID, "error", err.Error())
			// Continue deleting remaining fields; do not abort.
		}
	}

	h.logger.Infow("msg", "cascade deletion complete",
		"farm_id", farmID, "tenant_id", tenantID, "fields_deleted", len(fields))
	return nil
}
