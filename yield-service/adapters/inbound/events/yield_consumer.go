// Package events contains the inbound Kafka consumer adapter for yield-service.
// It subscribes to events from OTHER services that the yield-service needs to react to:
// crop events (crop data for yield predictions), field events (field-level yield tracking),
// and satellite events (NDVI data for yield estimation).
package events

import (
	"context"
	"encoding/json"
	"fmt"

	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9log"

	"p9e.in/samavaya/agriculture/yield-service/internal/ports/inbound"
)

// Topics from OTHER services that yield-service consumes.
const (
	CropEventTopic      = "samavaya.agriculture.crop.events"
	FieldEventTopic     = "samavaya.agriculture.field.events"
	SatelliteEventTopic = "samavaya.agriculture.satellite.events"
)

// YieldConsumer is the inbound Kafka adapter that reacts to cross-service domain events.
type YieldConsumer struct {
	svc inbound.YieldService
	log *p9log.Helper
}

// NewYieldConsumer creates a new Kafka consumer for cross-service events.
func NewYieldConsumer(svc inbound.YieldService, log p9log.Logger) *YieldConsumer {
	return &YieldConsumer{
		svc: svc,
		log: p9log.NewHelper(p9log.With(log, "component", "YieldConsumer")),
	}
}

// Topics returns the Kafka topics this consumer listens on.
func (c *YieldConsumer) Topics() []string {
	return []string{CropEventTopic, FieldEventTopic, SatelliteEventTopic}
}

// HandleEvent dispatches an incoming domain event.
func (c *YieldConsumer) HandleEvent(ctx context.Context, event *domain.DomainEvent) error {
	if event == nil {
		return fmt.Errorf("received nil event")
	}
	c.log.Infow("msg", "cross-service event received",
		"event_id", event.ID,
		"event_type", string(event.Type),
		"aggregate_id", event.AggregateID,
	)

	switch event.Type {
	// Crop events: crop lifecycle affects yield predictions
	case domain.EventTypeCropCreated:
		return c.onCropCreated(ctx, event)
	case domain.EventTypeCropUpdated:
		return c.onCropUpdated(ctx, event)

	// Field events: crop assignment to a field triggers yield prediction
	case domain.EventTypeFieldCropAssigned:
		return c.onFieldCropAssigned(ctx, event)
	case domain.EventTypeFieldDeleted:
		return c.onFieldDeleted(ctx, event)

	// Satellite events: NDVI and vegetation indices improve yield estimates
	case domain.EventTypeSatelliteImageCreated:
		return c.onSatelliteImageCreated(ctx, event)

	default:
		c.log.Infow("msg", "unhandled event type", "type", string(event.Type))
		return nil
	}
}

// onCropCreated handles a new crop type being registered.
func (c *YieldConsumer) onCropCreated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onCropCreated: %w", err)
	}
	cropID, _ := data["crop_id"].(string)
	c.log.Infow("msg", "new crop type available for yield predictions",
		"crop_id", cropID,
	)
	// TODO: load baseline yield model parameters for the new crop type
	return nil
}

// onCropUpdated handles a crop type being updated.
func (c *YieldConsumer) onCropUpdated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onCropUpdated: %w", err)
	}
	cropID, _ := data["crop_id"].(string)
	c.log.Infow("msg", "crop type updated, refreshing yield models",
		"crop_id", cropID,
	)
	// TODO: refresh yield prediction models for affected fields
	return nil
}

// onFieldCropAssigned handles a crop being assigned to a field.
// This triggers initial yield prediction for the crop-field combination.
func (c *YieldConsumer) onFieldCropAssigned(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onFieldCropAssigned: %w", err)
	}
	fieldID, _ := data["field_id"].(string)
	cropID, _ := data["crop_id"].(string)
	c.log.Infow("msg", "crop assigned to field, generating initial yield prediction",
		"field_id", fieldID,
		"crop_id", cropID,
	)
	// TODO: call c.svc.PredictYield for the new crop-field assignment
	return nil
}

// onFieldDeleted handles a field being deleted.
func (c *YieldConsumer) onFieldDeleted(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onFieldDeleted: %w", err)
	}
	fieldID, _ := data["field_id"].(string)
	c.log.Infow("msg", "field deleted, archiving yield predictions",
		"field_id", fieldID,
	)
	// TODO: archive yield predictions and harvest plans for the deleted field
	return nil
}

// onSatelliteImageCreated handles new satellite imagery.
// NDVI and vegetation index data improve yield estimation accuracy.
func (c *YieldConsumer) onSatelliteImageCreated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onSatelliteImageCreated: %w", err)
	}
	fieldID, _ := data["field_id"].(string)
	imageID, _ := data["satellite_id"].(string)
	c.log.Infow("msg", "satellite imagery available for yield estimation",
		"field_id", fieldID,
		"image_id", imageID,
	)
	// TODO: incorporate satellite vegetation index data into yield predictions
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
