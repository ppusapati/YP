// Package events contains the inbound Kafka event consumer adapter for farm-service.
// It subscribes to events from OTHER services that the farm-service needs to react to:
// field events (fields created/deleted on the farm) and sensor events (sensors deployed).
package events

import (
	"context"
	"encoding/json"
	"fmt"

	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/saas"

	"p9e.in/samavaya/agriculture/farm-service/internal/ports/inbound"
)

// Topics from OTHER services that farm-service consumes.
const (
	FieldEventTopic  = "samavaya.agriculture.field.events"
	SensorEventTopic = "samavaya.agriculture.sensor.events"
)

// FarmConsumer is the inbound Kafka adapter that reacts to cross-service domain events.
// It listens for field and sensor events relevant to farm management.
type FarmConsumer struct {
	svc inbound.FarmService
	log *p9log.Helper
}

// NewFarmConsumer creates a new Kafka consumer for cross-service events.
func NewFarmConsumer(svc inbound.FarmService, log p9log.Logger) *FarmConsumer {
	return &FarmConsumer{
		svc: svc,
		log: p9log.NewHelper(p9log.With(log, "component", "FarmConsumer")),
	}
}

// Topics returns the Kafka topics this consumer listens on.
func (c *FarmConsumer) Topics() []string {
	return []string{FieldEventTopic, SensorEventTopic}
}

// HandleEvent dispatches an incoming domain event to the appropriate handler.
func (c *FarmConsumer) HandleEvent(ctx context.Context, event *domain.DomainEvent) error {
	if event == nil {
		return fmt.Errorf("received nil event")
	}
	c.log.Infow("msg", "cross-service event received",
		"event_id", event.ID,
		"event_type", string(event.Type),
		"aggregate_id", event.AggregateID,
	)

	switch event.Type {
	// Field events: react when fields are created/deleted on a farm
	case domain.EventTypeFieldCreated:
		return c.onFieldCreated(ctx, event)
	case domain.EventTypeFieldUpdated:
		return c.onFieldUpdated(ctx, event)
	case domain.EventTypeFieldDeleted:
		return c.onFieldDeleted(ctx, event)

	// Sensor events: react when sensors are deployed/removed on a farm
	case domain.EventTypeSensorCreated:
		return c.onSensorDeployed(ctx, event)
	case domain.EventTypeSensorDeleted:
		return c.onSensorRemoved(ctx, event)

	default:
		c.log.Infow("msg", "unhandled event type", "type", string(event.Type))
		return nil
	}
}

// Field creation and update carry nothing farm-service has to record, and the
// markers that used to sit here — asking them to "update the farm aggregate
// (e.g. field count, total area)" — were the wrong thing to ask for.
//
// There is no field count. Not on `Farm`, not in the `farms` table, not in the
// proto — nothing in this service counts fields, and nothing serves a count,
// so there is no figure here that could drift. Whoever needs one asks
// field-service, which is where fields live and where the answer is current
// rather than a copy that goes stale between events.
//
// `total_area_hectares` does exist, and is the farmer's own declared area for
// the parcel: they type it into CreateFarm and can edit it. Summing the fields
// into it would overwrite what they entered with a strictly smaller number,
// because fields do not cover tracks, buildings, margins or watercourses —
// silently, on every field created. Implementing that as written would
// have corrupted user data while looking like the debt was cleared.
//
// These stay as log lines because the events are genuinely useful to see in a
// trace, not because there is work left here.

// onFieldCreated records that a field appeared on a farm.
func (c *FarmConsumer) onFieldCreated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onFieldCreated: %w", err)
	}
	farmID, _ := data["farm_id"].(string)
	fieldID, _ := data["field_id"].(string)
	c.log.Infow("msg", "field created on farm",
		"farm_id", farmID,
		"field_id", fieldID,
	)
	return nil
}

// onFieldUpdated records that a field on a farm changed.
func (c *FarmConsumer) onFieldUpdated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onFieldUpdated: %w", err)
	}
	farmID, _ := data["farm_id"].(string)
	fieldID, _ := data["field_id"].(string)
	c.log.Infow("msg", "field updated on farm",
		"farm_id", farmID,
		"field_id", fieldID,
	)
	return nil
}

// onFieldDeleted drops the field's membership of every management unit.
//
// This is the one thing a farm genuinely holds about a field, and it is not a
// count: `management_unit_fields` is farm-service's own junction table, keyed
// on a `field_id` that belongs to another service and therefore has no foreign
// key to cascade from. Nothing else can reach the row — fields live in
// field-service — so without this the deleted field stays a member of its unit
// for ever and `GetManagementUnit` lists it. `AssignFieldsToUnit` is
// `ON CONFLICT DO NOTHING`, so even reusing the id would not clear it.
func (c *FarmConsumer) onFieldDeleted(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onFieldDeleted: %w", err)
	}
	fieldID, _ := data["field_id"].(string)
	tenantID, _ := data["tenant_id"].(string)

	if fieldID == "" || tenantID == "" {
		// Dropped rather than retried: a message that can never succeed would
		// block the partition, and guessing a tenant would touch another
		// tenant's units.
		c.log.Warnw("msg", "field deleted event missing field or tenant; cannot update units",
			"event_id", event.ID, "field_id", fieldID)
		return nil
	}

	// A consumer has no request to inherit a tenant from, so one is attached
	// explicitly. Without it the delete runs unscoped, row-level security
	// matches nothing, and the handler reports success over zero rows.
	ctx = c.systemContext(ctx, tenantID)

	removed, err := c.svc.ForgetDeletedField(ctx, fieldID)
	if err != nil {
		// Returned, so the consumer retries: a database blip must not leave a
		// unit listing a field that no longer exists.
		return fmt.Errorf("onFieldDeleted: remove field %s from units: %w", fieldID, err)
	}

	c.log.Infow("msg", "field deleted, unit memberships dropped",
		"field_id", fieldID, "memberships_removed", removed)
	return nil
}

// systemContext scopes a consumer-initiated operation to a tenant.
//
// Both the RLS scope and the connection info are set: the repository layer
// reads one and the service layer the other, and setting only one leaves
// queries running unscoped in a way that returns empty rather than failing.
func (c *FarmConsumer) systemContext(ctx context.Context, tenantID string) context.Context {
	ctx = p9context.NewConnectionInfo(ctx, &saas.ConnectionInfo{TenantID: tenantID})
	ctx = p9context.NewUserContext(ctx, p9context.UserContext{
		UserID:   "system",
		TenantID: tenantID,
	})
	return p9context.NewRLSScopeTenantOnly(ctx, tenantID)
}

// onSensorDeployed handles a sensor being deployed on the farm.
func (c *FarmConsumer) onSensorDeployed(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onSensorDeployed: %w", err)
	}
	farmID, _ := data["farm_id"].(string)
	sensorID, _ := data["sensor_id"].(string)
	c.log.Infow("msg", "sensor deployed on farm",
		"farm_id", farmID,
		"sensor_id", sensorID,
	)
	// TODO: call c.svc to track sensor presence on the farm
	return nil
}

// onSensorRemoved handles a sensor being removed from the farm.
func (c *FarmConsumer) onSensorRemoved(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onSensorRemoved: %w", err)
	}
	farmID, _ := data["farm_id"].(string)
	sensorID, _ := data["sensor_id"].(string)
	c.log.Infow("msg", "sensor removed from farm",
		"farm_id", farmID,
		"sensor_id", sensorID,
	)
	// TODO: call c.svc to remove sensor tracking from the farm
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
