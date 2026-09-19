// Package events contains the inbound Kafka consumer adapter for irrigation-service.
// It subscribes to events from OTHER services that the irrigation-service needs to react to:
// sensor events (soil moisture data), field events (irrigation zones per field),
// and soil events (soil data affecting irrigation decisions).
package events

import (
	"context"
	"encoding/json"
	"fmt"

	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/saas"

	irrigationdomain "p9e.in/samavaya/agriculture/irrigation-service/internal/domain"
	"p9e.in/samavaya/agriculture/irrigation-service/internal/ports/inbound"
)

// Topics from OTHER services that irrigation-service consumes.
const (
	SensorEventTopic = "samavaya.agriculture.sensor.events"
	FieldEventTopic  = "samavaya.agriculture.field.events"
	SoilEventTopic   = "samavaya.agriculture.soil.events"
)

// IrrigationConsumer is the inbound Kafka adapter that reacts to cross-service domain events.
type IrrigationConsumer struct {
	svc inbound.IrrigationService
	log *p9log.Helper
}

// NewIrrigationConsumer creates a new Kafka consumer for cross-service events.
func NewIrrigationConsumer(svc inbound.IrrigationService, log p9log.Logger) *IrrigationConsumer {
	return &IrrigationConsumer{
		svc: svc,
		log: p9log.NewHelper(p9log.With(log, "component", "IrrigationConsumer")),
	}
}

// Topics returns the Kafka topics this consumer listens on.
func (c *IrrigationConsumer) Topics() []string {
	return []string{SensorEventTopic, FieldEventTopic, SoilEventTopic}
}

// HandleEvent dispatches an incoming domain event.
func (c *IrrigationConsumer) HandleEvent(ctx context.Context, event *domain.DomainEvent) error {
	if event == nil {
		return fmt.Errorf("received nil event")
	}
	c.log.Infow("msg", "cross-service event received",
		"event_id", event.ID,
		"event_type", string(event.Type),
		"aggregate_id", event.AggregateID,
	)

	switch event.Type {
	// Sensor events: soil moisture data drives irrigation decisions
	case domain.EventTypeSensorCreated:
		return c.onSensorDeployed(ctx, event)
	case domain.EventTypeSensorUpdated:
		return c.onSensorUpdated(ctx, event)

	// Field events: fields need irrigation zones
	case domain.EventTypeFieldCreated:
		return c.onFieldCreated(ctx, event)
	case domain.EventTypeFieldDeleted:
		return c.onFieldDeleted(ctx, event)

	// Soil events: soil characteristics affect irrigation scheduling
	case domain.EventTypeSoilSampleCreated:
		return c.onSoilSampleCreated(ctx, event)

	default:
		c.log.Infow("msg", "unhandled event type", "type", string(event.Type))
		return nil
	}
}

// onSensorDeployed handles a moisture sensor being deployed.
// Irrigation-service uses moisture data for smart scheduling.
func (c *IrrigationConsumer) onSensorDeployed(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onSensorDeployed: %w", err)
	}
	sensorID, _ := data["sensor_id"].(string)
	fieldID, _ := data["field_id"].(string)
	c.log.Infow("msg", "sensor deployed, may provide moisture data for irrigation",
		"sensor_id", sensorID,
		"field_id", fieldID,
	)
	// TODO: register sensor as moisture data source for irrigation decisions
	return nil
}

// onSensorUpdated handles a sensor calibration or configuration change.
func (c *IrrigationConsumer) onSensorUpdated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onSensorUpdated: %w", err)
	}
	sensorID, _ := data["sensor_id"].(string)
	c.log.Infow("msg", "sensor updated, adjusting irrigation thresholds",
		"sensor_id", sensorID,
	)
	// TODO: recalibrate irrigation decision thresholds
	return nil
}

// onFieldCreated handles a new field being created.
// Irrigation-service may create default irrigation zones for the field.
func (c *IrrigationConsumer) onFieldCreated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onFieldCreated: %w", err)
	}
	fieldID, _ := data["field_id"].(string)
	farmID, _ := data["farm_id"].(string)
	c.log.Infow("msg", "field created, may need irrigation zone setup",
		"field_id", fieldID,
		"farm_id", farmID,
	)
	// TODO: call c.svc.CreateZone to set up default irrigation zone for the field
	return nil
}

// cascadePageSize is how many schedules are read per round.
const cascadePageSize = 100

// cascadeMaxPages bounds the sweep.
//
// The offset advances rather than re-reading the first page: cancelling is a
// status change, so the schedule stays in the listing and re-reading page zero
// would return the same rows for ever.
const cascadeMaxPages = 1000

// onFieldDeleted cancels the irrigation schedules for a deleted field.
//
// This used to log "field deleted, cancelling irrigation schedules" and return
// nil, having cancelled nothing. Kafka committed the offset, so the schedules
// stayed SCHEDULED against a field that no longer existed — and an irrigation
// schedule is not a stale row, it is a valve. The next window would have run
// water onto ground the system no longer believes anybody farms, and billed
// for it.
//
// Zones are left alone. A zone is a description of hardware in the ground,
// which outlives the field record and is what a replacement field would be
// attached to; the schedules are the part that acts.
func (c *IrrigationConsumer) onFieldDeleted(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onFieldDeleted: %w", err)
	}
	fieldID, _ := data["field_id"].(string)
	tenantID, _ := data["tenant_id"].(string)

	if fieldID == "" || tenantID == "" {
		c.log.Warnw("msg", "field deleted event missing field or tenant; cannot cancel schedules",
			"event_id", event.ID, "field_id", fieldID)
		return nil
	}

	// A consumer has no request to inherit a tenant from, so one is attached
	// explicitly. Without it every query below runs unscoped, row-level
	// security returns nothing, and the cascade reports success over an empty
	// list — which looks exactly like a field with no schedules.
	ctx = c.systemContext(ctx, tenantID)

	var cancelled, skipped int
	for page := 0; page < cascadeMaxPages; page++ {
		schedules, _, listErr := c.svc.ListSchedulesByField(
			ctx, fieldID, cascadePageSize, int32(page)*cascadePageSize)
		if listErr != nil {
			// Returned, so the consumer retries: a database that is briefly
			// unavailable must not leave a valve scheduled to open.
			return fmt.Errorf("onFieldDeleted: list schedules for field %s: %w", fieldID, listErr)
		}
		if len(schedules) == 0 {
			break
		}

		var attempted, failed int
		for _, s := range schedules {
			// Terminal schedules are skipped rather than cancelled: the
			// service rejects both with ALREADY_CANCELLED and ALREADY_COMPLETED,
			// and counting those rejections as failures would abandon the page
			// on a field whose schedules had simply all finished.
			if s.Status == irrigationdomain.IrrigationStatusCancelled ||
				s.Status == irrigationdomain.IrrigationStatusCompleted {
				skipped++
				continue
			}
			attempted++
			if cancelErr := c.svc.CancelSchedule(ctx, s.ID); cancelErr != nil {
				c.log.Errorw("msg", "failed to cancel schedule during field cascade",
					"field_id", fieldID, "schedule_id", s.ID, "error", cancelErr)
				failed++
				continue
			}
			cancelled++
		}

		// Every schedule on the page failed, so the next page would fail the
		// same way. Reported rather than swallowed: a valve left scheduled is
		// not something to report success on.
		if attempted > 0 && failed == attempted {
			return fmt.Errorf("onFieldDeleted: could not cancel any of %d schedules on page %d for field %s",
				failed, page, fieldID)
		}
		if len(schedules) < cascadePageSize {
			break
		}
	}

	c.log.Infow("msg", "field deleted, irrigation schedules cancelled",
		"field_id", fieldID, "cancelled", cancelled, "already_terminal", skipped)
	return nil
}

// systemContext scopes a consumer-initiated operation to a tenant.
//
// Both the RLS scope and the connection info are set: the repository layer
// reads one and the service layer the other, and setting only one leaves
// queries running unscoped in a way that returns empty rather than failing.
func (c *IrrigationConsumer) systemContext(ctx context.Context, tenantID string) context.Context {
	ctx = p9context.NewConnectionInfo(ctx, &saas.ConnectionInfo{TenantID: tenantID})
	ctx = p9context.NewUserContext(ctx, p9context.UserContext{
		UserID:   "system",
		TenantID: tenantID,
	})
	return p9context.NewRLSScopeTenantOnly(ctx, tenantID)
}

// onSoilSampleCreated handles new soil data that affects irrigation decisions.
// Soil water-holding capacity affects how much water is needed.
func (c *IrrigationConsumer) onSoilSampleCreated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onSoilSampleCreated: %w", err)
	}
	fieldID, _ := data["field_id"].(string)
	c.log.Infow("msg", "soil data available, updating irrigation parameters",
		"field_id", fieldID,
	)
	// TODO: call c.svc.RequestDecision to recalculate irrigation based on new soil data
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
