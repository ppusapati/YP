// Package events contains the inbound Kafka consumer adapter for pest-prediction-service.
// It subscribes to events from OTHER services that the pest-prediction-service needs to react to:
// sensor events (weather/humidity data), crop events (crop type affects pest models),
// and satellite events (satellite pest detection).
package events

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"

	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/saas"

	pestdomain "p9e.in/samavaya/agriculture/pest-prediction-service/internal/domain"
	"p9e.in/samavaya/agriculture/pest-prediction-service/internal/ports/inbound"
)

// Topics from OTHER services that pest-prediction-service consumes.
const (
	SensorEventTopic    = "samavaya.agriculture.sensor.events"
	CropEventTopic      = "samavaya.agriculture.crop.events"
	FieldEventTopic     = "samavaya.agriculture.field.events"
	SatelliteEventTopic = "samavaya.agriculture.satellite.events"
)

// PestConsumer is the inbound Kafka adapter that reacts to cross-service domain events.
type PestConsumer struct {
	svc inbound.PestService
	log *p9log.Helper
}

// NewPestConsumer creates a new Kafka consumer for cross-service events.
func NewPestConsumer(svc inbound.PestService, log p9log.Logger) *PestConsumer {
	return &PestConsumer{
		svc: svc,
		log: p9log.NewHelper(p9log.With(log, "component", "PestConsumer")),
	}
}

// Topics returns the Kafka topics this consumer listens on.
func (c *PestConsumer) Topics() []string {
	return []string{SensorEventTopic, CropEventTopic, FieldEventTopic, SatelliteEventTopic}
}

// HandleEvent dispatches an incoming domain event.
func (c *PestConsumer) HandleEvent(ctx context.Context, event *domain.DomainEvent) error {
	if event == nil {
		return fmt.Errorf("received nil event")
	}
	c.log.Infow("msg", "cross-service event received",
		"event_id", event.ID,
		"event_type", string(event.Type),
		"aggregate_id", event.AggregateID,
	)

	switch event.Type {
	// Sensor events: weather/humidity data feeds pest prediction models
	case domain.EventTypeSensorCreated:
		return c.onSensorDeployed(ctx, event)
	case domain.EventTypeSensorUpdated:
		return c.onSensorUpdated(ctx, event)

	// Crop events: crop type and lifecycle affect pest risk
	case domain.EventTypeCropCreated:
		return c.onCropCreated(ctx, event)
	case domain.EventTypeFieldCropAssigned:
		return c.onFieldCropAssigned(ctx, event)

	// Satellite events: satellite imagery can detect pest outbreaks
	case domain.EventTypeSatelliteImageCreated:
		return c.onSatelliteImageCreated(ctx, event)

	default:
		c.log.Infow("msg", "unhandled event type", "type", string(event.Type))
		return nil
	}
}

// onSensorDeployed handles a weather or environmental sensor being deployed.
func (c *PestConsumer) onSensorDeployed(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onSensorDeployed: %w", err)
	}
	sensorID, _ := data["sensor_id"].(string)
	fieldID, _ := data["field_id"].(string)
	c.log.Infow("msg", "sensor deployed, may provide weather data for pest models",
		"sensor_id", sensorID,
		"field_id", fieldID,
	)
	// TODO: register sensor as environmental data source for pest prediction
	return nil
}

// onSensorUpdated handles a sensor calibration or configuration change.
func (c *PestConsumer) onSensorUpdated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onSensorUpdated: %w", err)
	}
	sensorID, _ := data["sensor_id"].(string)
	c.log.Infow("msg", "sensor updated, adjusting pest prediction parameters",
		"sensor_id", sensorID,
	)
	// TODO: recalibrate pest prediction model inputs
	return nil
}

// onCropCreated handles a new crop type being registered.
// Different crops have different pest vulnerability profiles.
func (c *PestConsumer) onCropCreated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onCropCreated: %w", err)
	}
	cropID, _ := data["crop_id"].(string)
	c.log.Infow("msg", "new crop type, loading pest vulnerability profile",
		"crop_id", cropID,
	)
	// TODO: load pest species that commonly affect this crop type
	return nil
}

// onFieldCropAssigned records the opening pest risk assessment for a new
// crop-field assignment.
//
// This used to log "generating pest risk assessment" and return nil, having
// generated nothing. Kafka committed the offset and the field had no
// assessment until somebody asked for one by hand.
//
// Three things about it are deliberate, because the obvious implementation
// gets each of them wrong:
//
// It reads `crop_name`, not `crop_id`. `crop_id` is an opaque crop-service
// identifier; PredictPestRisk stores whatever it is given as the prediction's
// crop type and forwards it to the AI gateway, so passing the id would file a
// farmer-facing prediction against a crop nobody can read — and the rules
// scorer ignores crop type entirely, so the number would look perfectly
// normal while being about nothing.
//
// It carries the growth stage, which is worth up to a quarter of the rules
// score. Omitting it would make every assessment at planting systematically
// score as though growth stage contributed nothing.
//
// It suppresses the alert. Risk at or above HIGH normally raises one, and
// weather alone clears that threshold on a warm wet day — so without this,
// planting three fields on one damp morning pages the farmer three times
// about pests on bare ground. The assessment is recorded and visible; it just
// does not interrupt anyone. A list that cries wolf at planting is a list
// nobody reads in August.
//
// No pest species is named, because a crop assignment does not imply one.
// This is the field's environmental pest risk, not a species forecast.
//
// A replay writes a second assessment. There is no natural key to dedupe on —
// pest predictions are a time series with no season or year, and
// ListPredictionsParams filters only by farm, field, species and risk — and
// inventing a fuzzy "one within the last hour" rule would suppress genuine
// re-assessments as readily as duplicates. The cost is bounded: the alert is
// suppressed either way, so a duplicate is one extra row in a list meant to
// hold many, not a second interruption.
func (c *PestConsumer) onFieldCropAssigned(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onFieldCropAssigned: %w", err)
	}
	fieldID, _ := data["field_id"].(string)
	tenantID, _ := data["tenant_id"].(string)
	farmID, _ := data["farm_id"].(string)
	cropName, _ := data["crop_name"].(string)

	if fieldID == "" || tenantID == "" || cropName == "" {
		// Dropped rather than retried: a replay will not supply a field the
		// producer did not send, and retrying forever blocks the partition for
		// every event behind it. cropName specifically, rather than falling
		// back to crop_id, because the fallback is the defect described above.
		c.log.Warnw("msg", "crop assigned event is missing what an assessment needs; skipping",
			"event_id", event.ID, "field_id", fieldID,
			"has_tenant", tenantID != "", "has_crop_name", cropName != "")
		return nil
	}

	// A consumer has no request to inherit a tenant from, so one is attached
	// explicitly. Without it the write runs unscoped and row-level security
	// rejects it.
	ctx = c.systemContext(ctx, tenantID)

	stage, recognised := growthStage(data["growth_stage"])
	if !recognised {
		// field-service and this service do not share a growth-stage
		// vocabulary: field has BUDDING, FRUIT_SET, RIPENING, MATURITY and
		// SENESCENCE, this service has FRUITING, MATURATION and HARVEST, and
		// only GERMINATION, SEEDLING, VEGETATIVE and FLOWERING appear in both.
		// A stage from the half that does not overlap scores as unstaged,
		// which is the safe direction, but it is a real divergence and the log
		// is how it gets noticed rather than quietly costing a quarter of the
		// score.
		c.log.Warnw("msg", "unrecognised growth stage; scoring as unstaged",
			"event_id", event.ID, "field_id", fieldID,
			"growth_stage", data["growth_stage"])
	}

	prediction, err := c.svc.PredictPestRisk(ctx, &pestdomain.PredictPestRiskParams{
		FarmID:      farmID,
		FieldID:     fieldID,
		CropType:    cropName,
		GrowthStage: stage,
		// Weather is deliberately left zero: the service looks it up from
		// weather-service against the field, and treats anything supplied here
		// as a fallback only, so that a caller cannot move a risk score by
		// sending numbers of its own.
		SuppressAlert: true,
	})
	if err != nil {
		// Returned, so the consumer retries: an assessment lost to a briefly
		// unavailable gateway is the defect this handler exists to fix.
		return fmt.Errorf("onFieldCropAssigned: predict pest risk for field %s: %w", fieldID, err)
	}

	c.log.Infow("msg", "opening pest risk assessment recorded",
		"field_id", fieldID, "crop", cropName, "prediction_id", prediction.ID,
		"risk_level", string(prediction.RiskLevel), "risk_score", prediction.RiskScore)
	return nil
}

// growthStage reads a growth stage off the event. The second return is false
// only when a stage was sent and this service does not recognise it — an
// absent stage is not a mismatch, just an absence.
//
// nil rather than a zero value: the scorer adds points per stage and skips a
// nil stage entirely, so an unrecognised string must not be allowed to fall
// through to whichever stage happens to be first.
func growthStage(raw any) (*pestdomain.GrowthStage, bool) {
	s, ok := raw.(string)
	if !ok || s == "" {
		return nil, true
	}
	stage := pestdomain.GrowthStage(strings.ToUpper(s))
	if !stage.IsValid() || stage == pestdomain.GrowthStageUnspecified {
		return nil, false
	}
	return &stage, true
}

// systemContext scopes a consumer-initiated operation to a tenant.
//
// Both the RLS scope and the connection info are set: the repository layer
// reads one and the service layer the other, and setting only one leaves
// queries running unscoped in a way that returns empty rather than failing.
func (c *PestConsumer) systemContext(ctx context.Context, tenantID string) context.Context {
	ctx = p9context.NewConnectionInfo(ctx, &saas.ConnectionInfo{TenantID: tenantID})
	ctx = p9context.NewUserContext(ctx, p9context.UserContext{
		UserID:   "system",
		TenantID: tenantID,
	})
	return p9context.NewRLSScopeTenantOnly(ctx, tenantID)
}

// onSatelliteImageCreated handles new satellite imagery that may detect pest damage.
func (c *PestConsumer) onSatelliteImageCreated(ctx context.Context, event *domain.DomainEvent) error {
	data, err := extractEventData(event)
	if err != nil {
		return fmt.Errorf("onSatelliteImageCreated: %w", err)
	}
	fieldID, _ := data["field_id"].(string)
	imageID, _ := data["satellite_id"].(string)
	c.log.Infow("msg", "satellite imagery available for pest detection",
		"field_id", fieldID,
		"image_id", imageID,
	)
	// TODO: analyze satellite imagery for pest outbreak indicators
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
