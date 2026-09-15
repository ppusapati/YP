// Package events contains the inbound Kafka event consumer adapter for field-service.
// It subscribes to events from OTHER services that the field-service needs to react to:
// farm events (parent farm lifecycle) and crop events (crop changes affecting fields).
package events

import (
	"context"
	"encoding/json"
	"fmt"

	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/saas"

	"p9e.in/samavaya/agriculture/field-service/internal/ports/inbound"
)

// Topics from OTHER services that field-service consumes.
const (
	FarmEventTopic   = "samavaya.agriculture.farm.events"
	CropEventTopic   = "samavaya.agriculture.crop.events"
	SensorEventTopic = "samavaya.agriculture.sensor.events"
)

// FieldConsumer is the inbound Kafka adapter that reacts to cross-service domain events.
type FieldConsumer struct {
	svc inbound.FieldService
	log *p9log.Helper
}

// NewFieldConsumer creates a new Kafka consumer for cross-service events.
func NewFieldConsumer(svc inbound.FieldService, log p9log.Logger) *FieldConsumer {
	return &FieldConsumer{
		svc: svc,
		log: p9log.NewHelper(p9log.With(log, "component", "FieldConsumer")),
	}
}

// Topics returns the Kafka topics this consumer listens on.
func (c *FieldConsumer) Topics() []string {
	return []string{FarmEventTopic, CropEventTopic, SensorEventTopic}
}

// HandleEvent dispatches an incoming domain event to the appropriate handler.
func (c *FieldConsumer) HandleEvent(ctx context.Context, event *domain.DomainEvent) error {
	if event == nil {
		return fmt.Errorf("received nil event")
	}
	c.log.Infow("msg", "cross-service event received",
		"event_id", event.ID,
		"event_type", string(event.Type),
		"aggregate_id", event.AggregateID,
	)

	switch event.Type {
	// Farm events: react to parent farm lifecycle changes
	case domain.EventTypeFarmCreated:
		return c.onFarmCreated(ctx, event)
	case domain.EventTypeFarmDeleted:
		return c.onFarmDeleted(ctx, event)
	case domain.EventTypeFarmBoundarySet:
		return c.onFarmBoundarySet(ctx, event)

	// Crop events: react when crop definitions change
	case domain.EventTypeCropCreated:
		return c.onCropCreated(ctx, event)
	case domain.EventTypeCropUpdated:
		return c.onCropUpdated(ctx, event)
	case domain.EventTypeCropDeleted:
		return c.onCropDeleted(ctx, event)

	// Sensor events: react when sensors are deployed on fields
	case domain.EventTypeSensorCreated:
		return c.onSensorDeployed(ctx, event)

	default:
		c.log.Infow("msg", "unhandled event type", "type", string(event.Type))
		return nil
	}
}

// onFarmCreated handles a new farm being created.
// Field-service may prepare for field creation on the new farm.
func (c *FieldConsumer) onFarmCreated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onFarmCreated: %w", err)
	}
	farmID, _ := data["farm_id"].(string)
	c.log.Infow("msg", "farm created, ready for field creation",
		"farm_id", farmID,
	)
	// TODO: initialize field management for the new farm (e.g. warm caches)
	return nil
}

// cascadePageSize is how many fields are deleted per round.
const cascadePageSize = 100

// cascadeMaxRounds bounds the delete loop.
//
// The loop re-reads the first page each time rather than advancing an offset,
// because deleting rows shifts the window and an advancing offset would skip
// as many fields as it deleted. That makes the loop depend on the deletes
// actually taking effect, so a delete that silently no-ops would spin forever
// without this.
const cascadeMaxRounds = 1000

// onFarmDeleted cascades the deletion to the farm's fields.
//
// This used to log "farm deleted, deactivating associated fields" and return
// nil, having deactivated nothing. Kafka saw a successful handle and committed
// the offset, so the fields stayed active under a farm that no longer existed —
// visible in listings, still accruing irrigation schedules and sensor
// readings, and unreachable through their parent.
func (c *FieldConsumer) onFarmDeleted(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onFarmDeleted: %w", err)
	}
	farmID, _ := data["farm_id"].(string)
	tenantID, _ := data["tenant_id"].(string)

	if farmID == "" || tenantID == "" {
		// Nothing to scope the deletion to. Dropped rather than retried: a
		// message that can never succeed would block the partition, and
		// guessing a tenant here would delete another tenant's fields.
		c.log.Warnw("msg", "farm deleted event missing farm or tenant; cannot cascade",
			"event_id", event.ID, "farm_id", farmID)
		return nil
	}

	// A consumer has no request to inherit a tenant from, so one is attached
	// explicitly. Without it every query below runs unscoped and row-level
	// security returns nothing — which would look exactly like a farm with no
	// fields.
	ctx = c.systemContext(ctx, tenantID)

	var deleted int
	for round := 0; round < cascadeMaxRounds; round++ {
		fields, _, listErr := c.svc.ListFieldsByFarm(ctx, farmID, cascadePageSize, 0)
		if listErr != nil {
			// Returned, so the consumer retries: a database that is briefly
			// unavailable must not leave the fields orphaned.
			return fmt.Errorf("onFarmDeleted: list fields for farm %s: %w", farmID, listErr)
		}
		if len(fields) == 0 {
			break
		}

		var failed int
		for _, f := range fields {
			if delErr := c.svc.DeleteField(ctx, f.ID); delErr != nil {
				// One field failing must not abandon the rest, and a replay
				// will find whatever is left. Counted so the round can tell
				// progress from a loop.
				c.log.Errorw("msg", "failed to delete field during farm cascade",
					"farm_id", farmID, "field_id", f.ID, "error", delErr)
				failed++
				continue
			}
			deleted++
		}

		// Every field in the page failed, so the next round would read the
		// same page and fail identically. Reported rather than spun on.
		if failed == len(fields) {
			return fmt.Errorf("onFarmDeleted: could not delete any of %d fields for farm %s",
				failed, farmID)
		}
	}

	c.log.Infow("msg", "farm deleted, fields cascaded",
		"farm_id", farmID, "fields_deleted", deleted)
	return nil
}

// systemContext scopes a consumer-initiated operation to a tenant.
//
// Both the RLS scope and the connection info are set: the repository layer
// reads one and the service layer the other, and setting only one leaves
// queries running unscoped in a way that returns empty rather than failing.
func (c *FieldConsumer) systemContext(ctx context.Context, tenantID string) context.Context {
	ctx = p9context.NewConnectionInfo(ctx, &saas.ConnectionInfo{TenantID: tenantID})
	ctx = p9context.NewUserContext(ctx, p9context.UserContext{
		UserID:   "system",
		TenantID: tenantID,
	})
	return p9context.NewRLSScopeTenantOnly(ctx, tenantID)
}

// onFarmBoundarySet handles a farm boundary being set or updated.
// Fields may need validation that they lie within the new boundary.
func (c *FieldConsumer) onFarmBoundarySet(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onFarmBoundarySet: %w", err)
	}
	farmID, _ := data["farm_id"].(string)
	c.log.Infow("msg", "farm boundary updated, validating field boundaries",
		"farm_id", farmID,
	)
	// TODO: validate existing field boundaries fall within new farm boundary
	return nil
}

// onCropCreated handles a new crop type being registered.
func (c *FieldConsumer) onCropCreated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onCropCreated: %w", err)
	}
	cropID, _ := data["crop_id"].(string)
	c.log.Infow("msg", "new crop type available for field assignment",
		"crop_id", cropID,
	)
	// Informational: new crop available for AssignCrop operations
	return nil
}

// onCropUpdated handles a crop type being updated.
func (c *FieldConsumer) onCropUpdated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onCropUpdated: %w", err)
	}
	cropID, _ := data["crop_id"].(string)
	c.log.Infow("msg", "crop type updated",
		"crop_id", cropID,
	)
	// TODO: update cached crop info used in field summaries
	return nil
}

// onCropDeleted handles a crop type being removed.
// Fields currently assigned this crop may need attention.
func (c *FieldConsumer) onCropDeleted(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onCropDeleted: %w", err)
	}
	cropID, _ := data["crop_id"].(string)
	c.log.Infow("msg", "crop type deleted, checking active assignments",
		"crop_id", cropID,
	)
	// TODO: identify fields still assigned this crop and flag for review
	return nil
}

// onSensorDeployed handles a sensor being deployed on a field.
func (c *FieldConsumer) onSensorDeployed(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onSensorDeployed: %w", err)
	}
	fieldID, _ := data["field_id"].(string)
	sensorID, _ := data["sensor_id"].(string)
	c.log.Infow("msg", "sensor deployed on field",
		"field_id", fieldID,
		"sensor_id", sensorID,
	)
	// TODO: update field metadata with sensor information
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
