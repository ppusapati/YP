// Package events contains the inbound Kafka consumer adapter for yield-service.
// It subscribes to events from OTHER services that the yield-service needs to react to:
// crop events (crop data for yield predictions), field events (field-level yield tracking),
// and satellite events (NDVI data for yield estimation).
package events

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/saas"

	yielddomain "p9e.in/samavaya/agriculture/yield-service/internal/domain"
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

// onFieldCropAssigned generates the opening yield prediction for a new
// crop-field assignment.
//
// This used to log "generating initial yield prediction" and return nil,
// having generated nothing. Kafka committed the offset, and the field's yield
// page showed "no data" from planting until somebody went and asked for a
// prediction by hand — which is the one moment a farmer is least likely to,
// because they have just told the system what they planted and reasonably
// expect it to know.
//
// The prediction is a baseline: no soil, weather or pest scores exist for a
// field on the day it is planted, so the factors are all zero and the service
// falls back to the crop's base yield. computeConfidence returns 0 against no
// factors, so it is stored at zero confidence rather than dressed up — a
// figure the UI can show as provisional, and one later predictions replace as
// real measurements arrive.
func (c *YieldConsumer) onFieldCropAssigned(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onFieldCropAssigned: %w", err)
	}
	fieldID, _ := data["field_id"].(string)
	cropID, _ := data["crop_id"].(string)
	tenantID, _ := data["tenant_id"].(string)
	farmID, _ := data["farm_id"].(string)
	season, _ := data["season"].(string)

	if fieldID == "" || cropID == "" || tenantID == "" || farmID == "" || season == "" {
		// Dropped rather than retried: nothing about a replay supplies a field
		// the producer did not send, and retrying forever blocks the partition
		// for every event behind it.
		c.log.Warnw("msg", "crop assigned event is missing what a prediction needs; skipping",
			"event_id", event.ID, "field_id", fieldID, "crop_id", cropID,
			"farm_id", farmID, "season", season, "has_tenant", tenantID != "")
		return nil
	}

	// A consumer has no request to inherit a tenant from, so one is attached
	// explicitly. Without it the write runs unscoped and row-level security
	// rejects it.
	ctx = c.systemContext(ctx, tenantID)

	year := plantingYear(data["planting_date"])

	// Kafka delivery is at-least-once and a rebalance replays whatever was in
	// flight, so the handler checks before writing. Several predictions per
	// season are normal and wanted — that is what makes them useful as the
	// season progresses — but a replay of the *same* assignment should not add
	// a second identical baseline.
	//
	// A read-then-write, so two replicas racing can still produce a duplicate.
	// Left as a read rather than an upsert because the cost of losing that race
	// is one redundant row in a list that is meant to hold many, and because
	// the alternative is a uniqueness constraint that would also forbid the
	// later predictions this table exists to accumulate.
	existing, _, err := c.svc.ListPredictions(ctx, yielddomain.ListPredictionsParams{
		FieldID: fieldID, CropID: cropID, Season: season, Year: year, PageSize: 1,
	})
	if err != nil {
		return fmt.Errorf("onFieldCropAssigned: check existing predictions for field %s: %w", fieldID, err)
	}
	if len(existing) > 0 {
		c.log.Infow("msg", "crop assignment already has a prediction; skipping",
			"field_id", fieldID, "crop_id", cropID, "season", season, "year", year)
		return nil
	}

	prediction := &yielddomain.YieldPrediction{
		FarmID:  farmID,
		FieldID: fieldID,
		CropID:  cropID,
		Season:  season,
		Year:    year,
	}

	created, err := c.svc.PredictYield(ctx, prediction)
	if err != nil {
		// Returned, so the consumer retries. A prediction that fails because
		// the AI gateway is briefly down is worth another attempt; silently
		// accepting the failure is how the field ends up showing "no data"
		// again, which is the defect this handler exists to fix.
		return fmt.Errorf("onFieldCropAssigned: predict yield for field %s: %w", fieldID, err)
	}

	c.log.Infow("msg", "opening yield prediction generated",
		"field_id", fieldID, "crop_id", cropID, "prediction_id", created.ID,
		"predicted_kg_per_ha", created.PredictedYieldKgPerHectare,
		"confidence_pct", created.PredictionConfidencePct)
	return nil
}

// plantingYear reads the season year from the planting date.
//
// The planting date rather than today, because a crop sown in December for the
// following season belongs to that season's year, and filing it under the
// calendar year of the event would put it in the wrong one. Falls back to now
// when the producer sent no date, which is the common case and off by at most
// the width of a sowing window.
func plantingYear(raw any) int32 {
	if s, ok := raw.(string); ok && s != "" {
		if t, err := time.Parse(time.RFC3339, s); err == nil {
			return int32(t.UTC().Year())
		}
	}
	return int32(time.Now().UTC().Year())
}

// systemContext scopes a consumer-initiated operation to a tenant.
//
// Both the RLS scope and the connection info are set: the repository layer
// reads one and the service layer the other, and setting only one leaves
// queries running unscoped in a way that returns empty rather than failing.
func (c *YieldConsumer) systemContext(ctx context.Context, tenantID string) context.Context {
	ctx = p9context.NewConnectionInfo(ctx, &saas.ConnectionInfo{TenantID: tenantID})
	ctx = p9context.NewUserContext(ctx, p9context.UserContext{
		UserID:   "system",
		TenantID: tenantID,
	})
	return p9context.NewRLSScopeTenantOnly(ctx, tenantID)
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
