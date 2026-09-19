// Package events contains the inbound Kafka consumer adapter for crop-service.
// It subscribes to events from OTHER services that the crop-service needs to react to:
// field events (crop assignments), soil events (soil data for recommendations),
// and satellite events (crop monitoring imagery).
package events

import (
	"context"
	"encoding/json"
	"fmt"

	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9log"

	"p9e.in/samavaya/agriculture/crop-service/internal/ports/inbound"
)

// Topics from OTHER services that crop-service consumes.
const (
	FieldEventTopic     = "samavaya.agriculture.field.events"
	SoilEventTopic      = "samavaya.agriculture.soil.events"
	SatelliteEventTopic = "samavaya.agriculture.satellite.events"
)

// CropConsumer is the inbound Kafka adapter that reacts to cross-service domain events.
type CropConsumer struct {
	svc inbound.CropService
	log *p9log.Helper
}

// NewCropConsumer creates a new Kafka consumer for cross-service events.
func NewCropConsumer(svc inbound.CropService, log p9log.Logger) *CropConsumer {
	return &CropConsumer{
		svc: svc,
		log: p9log.NewHelper(p9log.With(log, "component", "CropConsumer")),
	}
}

// Topics returns the Kafka topics this consumer listens on.
func (c *CropConsumer) Topics() []string {
	return []string{FieldEventTopic, SoilEventTopic, SatelliteEventTopic}
}

// HandleEvent dispatches an incoming domain event.
func (c *CropConsumer) HandleEvent(ctx context.Context, event *domain.DomainEvent) error {
	if event == nil {
		return fmt.Errorf("received nil event")
	}
	c.log.Infow("msg", "cross-service event received",
		"event_id", event.ID,
		"event_type", string(event.Type),
		"aggregate_id", event.AggregateID,
	)

	switch event.Type {
	// Field events: react when fields are assigned crops or deleted
	case domain.EventTypeFieldCropAssigned:
		return c.onFieldCropAssigned(ctx, event)
	case domain.EventTypeFieldDeleted:
		return c.onFieldDeleted(ctx, event)

	// Soil events: soil data affects crop recommendations
	case domain.EventTypeSoilSampleCreated:
		return c.onSoilSampleCreated(ctx, event)

	// Satellite events: satellite imagery for crop monitoring
	case domain.EventTypeSatelliteImageCreated:
		return c.onSatelliteImageCreated(ctx, event)

	default:
		c.log.Infow("msg", "unhandled event type", "type", string(event.Type))
		return nil
	}
}

// onFieldCropAssigned handles a crop being assigned to a field.
// Crop-service can use this to track active crop deployments.
func (c *CropConsumer) onFieldCropAssigned(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onFieldCropAssigned: %w", err)
	}
	cropID, _ := data["crop_id"].(string)
	fieldID, _ := data["field_id"].(string)
	c.log.Infow("msg", "crop assigned to field",
		"crop_id", cropID,
		"field_id", fieldID,
	)
	// TODO: track active deployment, possibly trigger growth stage initialization
	return nil
}

// onFieldDeleted handles a field being deleted.
//
// Deliberately does nothing. The marker that used to sit here asked this
// handler to "deactivate crop assignments linked to the deleted field", which
// was the wrong thing to ask for: crop-service has no assignment table. Its
// schema is crops,
// crop_varieties, crop_growth_stages, crop_requirements and
// crop_recommendations — the catalogue of what a crop *is*. A crop assignment
// is a fact about a field, lives in field-service's `crop_assignments`, and
// is written there by AssignCrop.
//
// Implementing this as written would have meant reaching across a service
// boundary to deactivate rows another service owns. field-service now deletes
// them itself, in the same statement as the field, which is where the
// invariant belongs and is the only place it can be made atomic.
func (c *CropConsumer) onFieldDeleted(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onFieldDeleted: %w", err)
	}
	fieldID, _ := data["field_id"].(string)
	c.log.Infow("msg", "field deleted; its crop assignments belong to field-service",
		"field_id", fieldID,
	)
	return nil
}

// onSoilSampleCreated handles new soil data that may affect crop recommendations.
func (c *CropConsumer) onSoilSampleCreated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onSoilSampleCreated: %w", err)
	}
	fieldID, _ := data["field_id"].(string)
	sampleID, _ := data["soil_id"].(string)
	c.log.Infow("msg", "soil sample available for crop recommendations",
		"field_id", fieldID,
		"soil_sample_id", sampleID,
	)
	// TODO: trigger recommendation refresh using new soil data via c.svc.GenerateRecommendation
	return nil
}

// onSatelliteImageCreated handles satellite imagery that may reveal crop health issues.
func (c *CropConsumer) onSatelliteImageCreated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onSatelliteImageCreated: %w", err)
	}
	fieldID, _ := data["field_id"].(string)
	imageID, _ := data["satellite_id"].(string)
	c.log.Infow("msg", "satellite imagery available for crop monitoring",
		"field_id", fieldID,
		"image_id", imageID,
	)
	// TODO: trigger crop health assessment using satellite data
	return nil
}

func extractEventData(event *domain.DomainEvent) (map[string]interface{}, error) {
	raw, err := json.Marshal(event.Data)
	if err != nil {
		return nil, fmt.Errorf("marshal event data: %w", err)
	}
	var data map[string]interface{}
	if err := json.Unmarshal(raw, &data); err != nil {
		return nil, fmt.Errorf("unmarshal event data: %w", err)
	}
	return data, nil
}
