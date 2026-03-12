package handlers

import (
	"context"
	"fmt"

	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9log"
)

// Agriculture-specific event types for the crop domain.
const (
	EventTypeCropCreated              domain.EventType = "agriculture.crop.created"
	EventTypeCropUpdated              domain.EventType = "agriculture.crop.updated"
	EventTypeCropDeleted              domain.EventType = "agriculture.crop.deleted"
	EventTypeVarietyAdded             domain.EventType = "agriculture.crop.variety_added"
	EventTypeRecommendationGenerated  domain.EventType = "agriculture.crop.recommendation_generated"
)

// CropEventTopic is the Kafka topic for all crop-related events.
const CropEventTopic = "samavaya.agriculture.crop.events"

// CropCreatedEvent is the payload for a crop.created event.
type CropCreatedEvent struct {
	CropID   string `json:"crop_id"`
	TenantID string `json:"tenant_id"`
	Name     string `json:"name"`
	Category string `json:"category"`
}

// CropUpdatedEvent is the payload for a crop.updated event.
type CropUpdatedEvent struct {
	CropID   string `json:"crop_id"`
	TenantID string `json:"tenant_id"`
	Name     string `json:"name"`
	Version  int32  `json:"version"`
}

// CropDeletedEvent is the payload for a crop.deleted event.
type CropDeletedEvent struct {
	CropID    string `json:"crop_id"`
	TenantID  string `json:"tenant_id"`
	DeletedBy string `json:"deleted_by"`
}

// VarietyAddedEvent is the payload for a variety.added event.
type VarietyAddedEvent struct {
	VarietyID string `json:"variety_id"`
	CropID    int64  `json:"crop_id"`
	TenantID  string `json:"tenant_id"`
	Name      string `json:"name"`
}

// RecommendationGeneratedEvent is the payload for a recommendation.generated event.
type RecommendationGeneratedEvent struct {
	RecommendationID string  `json:"recommendation_id"`
	CropID           string  `json:"crop_id"`
	TenantID         string  `json:"tenant_id"`
	Type             string  `json:"type"`
	Confidence       float64 `json:"confidence"`
}

// CropEventHandler handles inbound domain events relevant to the crop service.
type CropEventHandler struct {
	logger *p9log.Helper
}

// NewCropEventHandler creates a new event handler for crop-related events.
func NewCropEventHandler(log p9log.Logger) *CropEventHandler {
	return &CropEventHandler{
		logger: p9log.NewHelper(p9log.With(log, "component", "CropEventHandler")),
	}
}

// HandleEvent dispatches a domain event to the appropriate handler based on event type.
func (h *CropEventHandler) HandleEvent(ctx context.Context, event *domain.DomainEvent) error {
	if event == nil {
		return fmt.Errorf("nil event received")
	}

	switch event.Type {
	case EventTypeCropCreated:
		return h.handleCropCreated(ctx, event)
	case EventTypeCropUpdated:
		return h.handleCropUpdated(ctx, event)
	case EventTypeCropDeleted:
		return h.handleCropDeleted(ctx, event)
	case EventTypeVarietyAdded:
		return h.handleVarietyAdded(ctx, event)
	case EventTypeRecommendationGenerated:
		return h.handleRecommendationGenerated(ctx, event)
	default:
		h.logger.Debugf("Unhandled event type: %s", event.Type)
		return nil
	}
}

// handleCropCreated processes crop-created events.
// This can trigger downstream workflows such as cache warming, notification dispatch,
// or creation of default growth stages/requirements templates.
func (h *CropEventHandler) handleCropCreated(ctx context.Context, event *domain.DomainEvent) error {
	cropID, _ := event.Data["crop_id"].(string)
	tenantID, _ := event.Data["tenant_id"].(string)
	name, _ := event.Data["name"].(string)
	category, _ := event.Data["category"].(string)

	h.logger.Infof("Crop created event received: crop_id=%s tenant=%s name=%s category=%s",
		cropID, tenantID, name, category)

	// Future: trigger template growth-stage creation, cache population, etc.
	return nil
}

// handleCropUpdated processes crop-updated events.
func (h *CropEventHandler) handleCropUpdated(ctx context.Context, event *domain.DomainEvent) error {
	cropID, _ := event.Data["crop_id"].(string)
	tenantID, _ := event.Data["tenant_id"].(string)
	name, _ := event.Data["name"].(string)

	var version int32
	if v, ok := event.Data["version"].(float64); ok {
		version = int32(v)
	}

	h.logger.Infof("Crop updated event received: crop_id=%s tenant=%s name=%s version=%d",
		cropID, tenantID, name, version)

	// Future: invalidate cache, propagate to dependent services (field-service, irrigation-service).
	return nil
}

// handleCropDeleted processes crop-deleted events.
func (h *CropEventHandler) handleCropDeleted(ctx context.Context, event *domain.DomainEvent) error {
	cropID, _ := event.Data["crop_id"].(string)
	tenantID, _ := event.Data["tenant_id"].(string)
	deletedBy, _ := event.Data["deleted_by"].(string)

	h.logger.Infof("Crop deleted event received: crop_id=%s tenant=%s deleted_by=%s",
		cropID, tenantID, deletedBy)

	// Future: cascade delete references, invalidate cache, notify field-service.
	return nil
}

// handleVarietyAdded processes variety-added events.
func (h *CropEventHandler) handleVarietyAdded(ctx context.Context, event *domain.DomainEvent) error {
	varietyID, _ := event.Data["variety_id"].(string)
	tenantID, _ := event.Data["tenant_id"].(string)
	name, _ := event.Data["name"].(string)

	h.logger.Infof("Variety added event received: variety_id=%s tenant=%s name=%s",
		varietyID, tenantID, name)

	// Future: update seed catalog, trigger yield projection recalculation.
	return nil
}

// handleRecommendationGenerated processes recommendation-generated events.
func (h *CropEventHandler) handleRecommendationGenerated(ctx context.Context, event *domain.DomainEvent) error {
	recID, _ := event.Data["recommendation_id"].(string)
	cropID, _ := event.Data["crop_id"].(string)
	tenantID, _ := event.Data["tenant_id"].(string)
	recType, _ := event.Data["type"].(string)

	var confidence float64
	if c, ok := event.Data["confidence"].(float64); ok {
		confidence = c
	}

	h.logger.Infof("Recommendation generated event received: id=%s crop=%s tenant=%s type=%s confidence=%.2f",
		recID, cropID, tenantID, recType, confidence)

	// Future: push notification to farmer dashboard, trigger irrigation schedule adjustment.
	return nil
}

// IsCropEvent returns true if the event type belongs to the crop domain.
func IsCropEvent(eventType domain.EventType) bool {
	switch eventType {
	case EventTypeCropCreated, EventTypeCropUpdated, EventTypeCropDeleted,
		EventTypeVarietyAdded, EventTypeRecommendationGenerated:
		return true
	default:
		return false
	}
}
