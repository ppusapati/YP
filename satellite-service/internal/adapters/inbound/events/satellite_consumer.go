// Package events contains the inbound Kafka consumer adapter for satellite-service.
// It subscribes to events from OTHER services that the satellite-service needs to react to:
// farm events (farm boundaries for satellite coverage) and field events (field boundaries
// for targeted satellite analysis).
package events

import (
	"context"
	"encoding/json"
	"fmt"

	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/saas"

	"p9e.in/samavaya/agriculture/satellite-service/internal/ports/inbound"
)

// Topics from OTHER services that satellite-service consumes.
const (
	FarmEventTopic  = "samavaya.agriculture.farm.events"
	FieldEventTopic = "samavaya.agriculture.field.events"
)

// SatelliteConsumer is the inbound Kafka adapter that reacts to cross-service domain events.
type SatelliteConsumer struct {
	svc inbound.SatelliteService
	log *p9log.Helper
}

// NewSatelliteConsumer creates a new Kafka consumer for cross-service events.
func NewSatelliteConsumer(svc inbound.SatelliteService, log p9log.Logger) *SatelliteConsumer {
	return &SatelliteConsumer{
		svc: svc,
		log: p9log.NewHelper(p9log.With(log, "component", "SatelliteConsumer")),
	}
}

// Topics returns the Kafka topics this consumer listens on.
func (c *SatelliteConsumer) Topics() []string {
	return []string{FarmEventTopic, FieldEventTopic}
}

// HandleEvent dispatches an incoming domain event.
func (c *SatelliteConsumer) HandleEvent(ctx context.Context, event *domain.DomainEvent) error {
	if event == nil {
		return fmt.Errorf("received nil event")
	}
	c.log.Infow("msg", "cross-service event received",
		"event_id", event.ID,
		"event_type", string(event.Type),
		"aggregate_id", event.AggregateID,
	)

	switch event.Type {
	// Farm events: farm boundaries define satellite coverage areas
	case domain.EventTypeFarmCreated:
		return c.onFarmCreated(ctx, event)
	case domain.EventTypeFarmBoundarySet:
		return c.onFarmBoundarySet(ctx, event)
	case domain.EventTypeFarmDeleted:
		return c.onFarmDeleted(ctx, event)

	// Field events: field boundaries for targeted satellite analysis
	case domain.EventTypeFieldCreated:
		return c.onFieldCreated(ctx, event)
	case domain.EventTypeFieldDeleted:
		return c.onFieldDeleted(ctx, event)

	default:
		c.log.Infow("msg", "unhandled event type", "type", string(event.Type))
		return nil
	}
}

// onFarmCreated handles a new farm being created.
// Satellite-service can schedule initial imagery for the farm area.
func (c *SatelliteConsumer) onFarmCreated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onFarmCreated: %w", err)
	}
	farmID, _ := data["farm_id"].(string)
	c.log.Infow("msg", "farm created, scheduling initial satellite imagery",
		"farm_id", farmID,
	)
	// TODO: call c.svc.RequestImagery for the new farm's geographic area
	return nil
}

// onFarmBoundarySet handles a farm boundary being set or updated.
// The satellite coverage area should be recalculated.
func (c *SatelliteConsumer) onFarmBoundarySet(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onFarmBoundarySet: %w", err)
	}
	farmID, _ := data["farm_id"].(string)
	c.log.Infow("msg", "farm boundary updated, recalculating satellite coverage",
		"farm_id", farmID,
	)
	// TODO: update satellite coverage area based on new farm boundary
	return nil
}

// onFarmDeleted handles a farm being deleted.
//
// Deliberately does nothing beyond logging, and the TODO asking for a
// farm-level cancellation was the wrong thing to ask for. A satellite task
// carries a field_id and no farm_id, so "cancel this farm's tasks" is not a
// query this service can express. It does not need to be: field-service
// cascades a farm deletion into a delete per field, each of which emits
// agriculture.field.deleted, and onFieldDeleted below retires that field's
// tasks. Adding a farm path would either duplicate that work or reach into
// field-service for a listing to fan out over, which is a round trip to
// rediscover events already on the way.
func (c *SatelliteConsumer) onFarmDeleted(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onFarmDeleted: %w", err)
	}
	farmID, _ := data["farm_id"].(string)
	c.log.Infow("msg", "farm deleted; tasks retire with each field's own delete event",
		"farm_id", farmID,
	)
	return nil
}

// onFieldCreated handles a new field being created.
// Satellite-service can schedule field-level analysis (NDVI, crop stress).
func (c *SatelliteConsumer) onFieldCreated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onFieldCreated: %w", err)
	}
	fieldID, _ := data["field_id"].(string)
	farmID, _ := data["farm_id"].(string)
	c.log.Infow("msg", "field created, scheduling satellite analysis",
		"field_id", fieldID,
		"farm_id", farmID,
	)
	// TODO: call c.svc.RequestImagery for field-level vegetation index analysis
	return nil
}

// onFieldDeleted retires the outstanding acquisition tasks for a deleted field.
//
// This used to log "field deleted, cancelling satellite analysis tasks" and
// return nil, having cancelled nothing. Kafka committed the offset and the
// rows stayed PENDING for ever against a field that no longer existed.
//
// The debt register recorded the consequence as "pending imagery tasks keep
// billing". That is not what happens today: nothing in this service reads
// satellite_tasks — the repository could only insert — so no acquisition was
// ever going to be ordered from one. The real defect is narrower and still
// worth closing: the table accumulates rows for fields nobody can open, and
// the first thing to process that queue would pick them up.
func (c *SatelliteConsumer) onFieldDeleted(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onFieldDeleted: %w", err)
	}
	fieldID, _ := data["field_id"].(string)
	tenantID, _ := data["tenant_id"].(string)

	if fieldID == "" || tenantID == "" {
		// Dropped rather than retried: a message that can never succeed would
		// block the partition, and guessing a tenant would touch another
		// tenant's rows.
		c.log.Warnw("msg", "field deleted event missing field or tenant; cannot retire tasks",
			"event_id", event.ID, "field_id", fieldID)
		return nil
	}

	// A consumer has no request to inherit a tenant from, so one is attached
	// explicitly. Without it the update runs unscoped, row-level security
	// matches nothing, and the handler reports success over zero rows.
	ctx = c.systemContext(ctx, tenantID)

	retired, err := c.svc.AbandonTasksForField(ctx, fieldID)
	if err != nil {
		// Returned, so the consumer retries: a database that is briefly
		// unavailable must not leave the tasks behind.
		return fmt.Errorf("onFieldDeleted: retire tasks for field %s: %w", fieldID, err)
	}

	c.log.Infow("msg", "field deleted, satellite tasks retired",
		"field_id", fieldID, "tasks_retired", retired)
	return nil
}

// systemContext scopes a consumer-initiated operation to a tenant.
//
// Both the RLS scope and the connection info are set: the repository layer
// reads one and the service layer the other, and setting only one leaves
// queries running unscoped in a way that returns empty rather than failing.
func (c *SatelliteConsumer) systemContext(ctx context.Context, tenantID string) context.Context {
	ctx = p9context.NewConnectionInfo(ctx, &saas.ConnectionInfo{TenantID: tenantID})
	ctx = p9context.NewUserContext(ctx, p9context.UserContext{
		UserID:   "system",
		TenantID: tenantID,
	})
	return p9context.NewRLSScopeTenantOnly(ctx, tenantID)
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
