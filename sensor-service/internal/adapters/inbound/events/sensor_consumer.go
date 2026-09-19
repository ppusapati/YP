// Package events contains the inbound Kafka consumer adapter for sensor-service.
// It subscribes to events from OTHER services that the sensor-service needs to react to:
// field events (field lifecycle affecting sensor placement) and farm events (farm deletion
// requiring sensor decommission).
package events

import (
	"context"
	"encoding/json"
	"fmt"

	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/saas"

	sensordomain "p9e.in/samavaya/agriculture/sensor-service/internal/domain"
	"p9e.in/samavaya/agriculture/sensor-service/internal/ports/inbound"
)

// Topics from OTHER services that sensor-service consumes.
const (
	FieldEventTopic = "samavaya.agriculture.field.events"
	FarmEventTopic  = "samavaya.agriculture.farm.events"
)

// SensorConsumer is the inbound Kafka adapter that reacts to cross-service domain events.
type SensorConsumer struct {
	svc inbound.SensorService
	log *p9log.Helper
}

// NewSensorConsumer creates a new Kafka consumer for cross-service events.
func NewSensorConsumer(svc inbound.SensorService, log p9log.Logger) *SensorConsumer {
	return &SensorConsumer{
		svc: svc,
		log: p9log.NewHelper(p9log.With(log, "component", "SensorConsumer")),
	}
}

// Topics returns the Kafka topics this consumer listens on.
func (c *SensorConsumer) Topics() []string {
	return []string{FieldEventTopic, FarmEventTopic}
}

// HandleEvent dispatches an incoming domain event.
func (c *SensorConsumer) HandleEvent(ctx context.Context, event *domain.DomainEvent) error {
	if event == nil {
		return fmt.Errorf("received nil event")
	}
	c.log.Infow("msg", "cross-service event received",
		"event_id", event.ID,
		"event_type", string(event.Type),
		"aggregate_id", event.AggregateID,
	)

	switch event.Type {
	// Field events: sensor placement depends on field lifecycle
	case domain.EventTypeFieldCreated:
		return c.onFieldCreated(ctx, event)
	case domain.EventTypeFieldDeleted:
		return c.onFieldDeleted(ctx, event)

	// Farm events: farm deletion triggers sensor decommission
	case domain.EventTypeFarmDeleted:
		return c.onFarmDeleted(ctx, event)

	default:
		c.log.Infow("msg", "unhandled event type", "type", string(event.Type))
		return nil
	}
}

// onFieldCreated handles a new field being created.
// Sensor-service may plan sensor deployment for the new field.
func (c *SensorConsumer) onFieldCreated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onFieldCreated: %w", err)
	}
	fieldID, _ := data["field_id"].(string)
	farmID, _ := data["farm_id"].(string)
	c.log.Infow("msg", "field created, sensor deployment may be needed",
		"field_id", fieldID,
		"farm_id", farmID,
	)
	// TODO: plan sensor deployment for the new field
	return nil
}

// cascadePageSize is how many sensors are read per round.
const cascadePageSize = 100

// cascadeMaxPages bounds the sweep.
//
// The offset advances rather than re-reading the first page, because
// decommissioning is a status change: the sensor stays in the listing
// afterwards, so re-reading page zero would return the same rows for ever.
// That is the opposite of the shape a cascading *delete* needs, and getting
// the two confused silently skips half the rows or never terminates.
const cascadeMaxPages = 1000

// onFieldDeleted decommissions the sensors that were on the deleted field.
//
// This used to log "field deleted, decommissioning associated sensors" and
// return nil, having decommissioned nothing. Kafka committed the offset, so
// the sensors stayed ACTIVE against a field that no longer existed: still
// listed in the network view, still ingesting readings, and still raising
// threshold alerts that named a field nobody could open.
func (c *SensorConsumer) onFieldDeleted(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onFieldDeleted: %w", err)
	}
	fieldID, _ := data["field_id"].(string)
	tenantID, _ := data["tenant_id"].(string)

	if fieldID == "" || tenantID == "" {
		c.log.Warnw("msg", "field deleted event missing field or tenant; cannot decommission",
			"event_id", event.ID, "field_id", fieldID)
		return nil
	}

	return c.decommission(ctx, tenantID, sensordomain.SensorListFilter{FieldID: fieldID},
		"field deleted", "field_id", fieldID)
}

// onFarmDeleted decommissions every sensor on the deleted farm.
//
// Done by farm rather than relying on the per-field deletes that field-service
// cascades, because a sensor can sit at the farm rather than on a field — a
// weather station by the gate — and no field-deleted event would ever reach it.
// Sensors that are on a field are decommissioned twice over, which is why the
// sweep skips ones already in that state rather than erroring on them.
func (c *SensorConsumer) onFarmDeleted(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onFarmDeleted: %w", err)
	}
	farmID, _ := data["farm_id"].(string)
	tenantID, _ := data["tenant_id"].(string)

	if farmID == "" || tenantID == "" {
		c.log.Warnw("msg", "farm deleted event missing farm or tenant; cannot decommission",
			"event_id", event.ID, "farm_id", farmID)
		return nil
	}

	return c.decommission(ctx, tenantID, sensordomain.SensorListFilter{FarmID: farmID},
		"farm deleted", "farm_id", farmID)
}

// decommission sweeps every sensor matching the filter and decommissions the
// ones still in service.
//
// The error contract is what decides whether an orphaned sensor keeps
// reporting. A listing failure is returned, so the consumer retries and the
// cascade is not lost to a database blip. A single sensor failing is logged
// and the sweep continues, because a replay will find whatever is left and
// abandoning the page would leave the rest of the farm reporting. A page where
// every sensor failed is returned, since the next page would fail the same way
// and reporting success on it would be a lie Kafka then commits.
func (c *SensorConsumer) decommission(
	ctx context.Context,
	tenantID string,
	filter sensordomain.SensorListFilter,
	reason string,
	logKey, logValue string,
) error {
	// A consumer has no request to inherit a tenant from, so one is attached
	// explicitly. Without it every query below runs unscoped, row-level
	// security returns nothing, and the cascade reports success over an empty
	// list — which looks exactly like a farm with no sensors.
	ctx = c.systemContext(ctx, tenantID)

	var decommissioned, skipped int
	for page := 0; page < cascadeMaxPages; page++ {
		filter.PageSize = cascadePageSize
		filter.PageOffset = int32(page) * cascadePageSize

		sensors, _, listErr := c.svc.ListSensors(ctx, filter)
		if listErr != nil {
			return fmt.Errorf("decommission on %s: list sensors: %w", reason, listErr)
		}
		if len(sensors) == 0 {
			break
		}

		var attempted, failed int
		for _, s := range sensors {
			if s.Status == sensordomain.SensorStatusDecommissioned {
				skipped++
				continue
			}
			attempted++
			if _, decErr := c.svc.DecommissionSensor(ctx, s.ID, reason); decErr != nil {
				c.log.Errorw("msg", "failed to decommission sensor during cascade",
					logKey, logValue, "sensor_id", s.ID, "error", decErr)
				failed++
				continue
			}
			decommissioned++
		}

		if attempted > 0 && failed == attempted {
			return fmt.Errorf("decommission on %s: all %d sensors on page %d failed",
				reason, failed, page)
		}
		if len(sensors) < cascadePageSize {
			break
		}
	}

	c.log.Infow("msg", "sensors decommissioned after "+reason,
		logKey, logValue, "decommissioned", decommissioned, "already_decommissioned", skipped)
	return nil
}

// systemContext scopes a consumer-initiated operation to a tenant.
//
// Both the RLS scope and the connection info are set: the repository layer
// reads one and the service layer the other, and setting only one leaves
// queries running unscoped in a way that returns empty rather than failing.
func (c *SensorConsumer) systemContext(ctx context.Context, tenantID string) context.Context {
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
