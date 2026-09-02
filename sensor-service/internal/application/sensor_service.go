// Package application contains the sensor-service application service.
package application

import (
	"context"
	"encoding/json"
	"fmt"
	"math"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	"p9e.in/samavaya/agriculture/sensor-service/internal/domain"
	"p9e.in/samavaya/agriculture/sensor-service/internal/ports/outbound"
)

const (
	serviceName           = "sensor-service"
	eventTopic            = "samavaya.agriculture.sensor.events"
	maxPageSize     int32 = 100
	defaultPageSize       = int32(20)
)

type sensorService struct {
	repo outbound.SensorRepository
	pub  outbound.EventPublisher
	pool *pgxpool.Pool
	log  *p9log.Helper
}

// NewSensorService creates a new application-layer SensorService.
func NewSensorService(
	repo outbound.SensorRepository,
	pub outbound.EventPublisher,
	pool *pgxpool.Pool,
	log p9log.Logger,
) *sensorService {
	return &sensorService{
		repo: repo,
		pub:  pub,
		pool: pool,
		log:  p9log.NewHelper(p9log.With(log, "component", "SensorService")),
	}
}

// =============================================================================
// Sensor Lifecycle
// =============================================================================

func (s *sensorService) RegisterSensor(ctx context.Context, sensor *domain.Sensor) (*domain.Sensor, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	if err := s.validateSensor(sensor); err != nil {
		return nil, err
	}

	sensor.TenantID = tenantID
	sensor.CreatedBy = userID
	sensor.Status = domain.SensorStatusActive

	// Check for duplicate device_id within tenant.
	existing, err := s.repo.GetSensorByDeviceID(ctx, sensor.DeviceID, tenantID)
	if err != nil && !errors.IsNotFound(err) {
		return nil, errors.Internal("failed to check for duplicate device: %v", err)
	}
	if existing != nil {
		return nil, errors.AlreadyExists("sensor with device_id %s already registered", sensor.DeviceID)
	}

	created, err := s.repo.CreateSensor(ctx, sensor)
	if err != nil {
		return nil, err
	}

	s.log.Infow("msg", "sensor registered", "uuid", created.UUID, "device_id", created.DeviceID, "sensor_type", created.SensorType, "tenant_id", tenantID)

	s.emitEvent(ctx, "agriculture.sensor.registered", created.UUID, map[string]interface{}{
		"sensor_id":   created.UUID,
		"device_id":   created.DeviceID,
		"sensor_type": string(created.SensorType),
		"field_id":    created.FieldID,
		"farm_id":     created.FarmID,
		"status":      string(created.Status),
	})

	return created, nil
}

func (s *sensorService) GetSensor(ctx context.Context, id string) (*domain.Sensor, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if id == "" {
		return nil, errors.BadRequest("MISSING_ID", "sensor ID is required")
	}
	return s.repo.GetSensorByUUID(ctx, id, tenantID)
}

func (s *sensorService) ListSensors(ctx context.Context, filter domain.SensorListFilter) ([]domain.Sensor, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	filter.TenantID = tenantID
	if filter.PageSize <= 0 {
		filter.PageSize = defaultPageSize
	}
	if filter.PageSize > maxPageSize {
		filter.PageSize = maxPageSize
	}
	return s.repo.ListSensors(ctx, filter)
}

func (s *sensorService) UpdateSensor(ctx context.Context, sensor *domain.Sensor) (*domain.Sensor, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if sensor.UUID == "" {
		return nil, errors.BadRequest("MISSING_ID", "sensor ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	existing, err := s.repo.GetSensorByUUID(ctx, sensor.UUID, tenantID)
	if err != nil {
		return nil, err
	}
	if existing.Status == domain.SensorStatusDecommissioned {
		return nil, errors.BadRequest("SENSOR_DECOMMISSIONED", "cannot update a decommissioned sensor")
	}

	sensor.TenantID = tenantID
	updatedBy := userID
	sensor.UpdatedBy = &updatedBy

	updated, err := s.repo.UpdateSensor(ctx, sensor)
	if err != nil {
		return nil, err
	}

	s.log.Infow("msg", "sensor updated", "uuid", updated.UUID, "tenant_id", tenantID)

	s.emitEvent(ctx, "agriculture.sensor.updated", updated.UUID, map[string]interface{}{
		"sensor_id": updated.UUID, "tenant_id": tenantID,
	})
	return updated, nil
}

func (s *sensorService) DecommissionSensor(ctx context.Context, id, reason string) (*domain.Sensor, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if id == "" {
		return nil, errors.BadRequest("MISSING_ID", "sensor ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	decommissioned, err := s.repo.DecommissionSensor(ctx, id, tenantID, userID)
	if err != nil {
		return nil, err
	}

	s.log.Infow("msg", "sensor decommissioned", "uuid", id, "reason", reason, "tenant_id", tenantID)

	s.emitEvent(ctx, "agriculture.sensor.decommissioned", id, map[string]interface{}{
		"sensor_id": id,
		"reason":    reason,
		"device_id": decommissioned.DeviceID,
	})

	return decommissioned, nil
}

// =============================================================================
// Data Ingestion
// =============================================================================

func (s *sensorService) IngestReading(ctx context.Context, sensorID string, value float64, unit string, timestamp time.Time, quality domain.ReadingQuality, batteryPct, signalDbm *float64, metadata json.RawMessage) (*domain.SensorReading, *domain.SensorAlert, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if sensorID == "" {
		return nil, nil, errors.BadRequest("MISSING_SENSOR_ID", "sensor ID is required")
	}

	sensor, err := s.repo.GetSensorByUUID(ctx, sensorID, tenantID)
	if err != nil {
		return nil, nil, err
	}
	if sensor.Status != domain.SensorStatusActive {
		return nil, nil, errors.BadRequest("SENSOR_NOT_ACTIVE", fmt.Sprintf("sensor %s is in %s state", sensorID, sensor.Status))
	}

	// Apply calibration correction if available.
	calibratedValue := value
	cal, calErr := s.repo.GetLatestCalibration(ctx, sensorID, tenantID)
	if calErr == nil && cal != nil {
		calibratedValue = (value * cal.ScaleFactor) + cal.OffsetValue
	}

	// Perform anomaly detection: auto-assign quality if not explicitly set.
	if quality == "" || quality == domain.ReadingQualityGood {
		quality = s.detectAnomalies(ctx, tenantID, sensorID, sensor.SensorType, calibratedValue)
	}

	if timestamp.IsZero() {
		timestamp = time.Now()
	}

	if unit == "" {
		if r, ok := domain.ValidReadingRanges[sensor.SensorType]; ok {
			unit = r.Unit
		}
	}

	reading := &domain.SensorReading{
		SensorID:          sensorID,
		TenantID:          tenantID,
		Value:             calibratedValue,
		Unit:              unit,
		RecordedAt:        timestamp,
		Quality:           quality,
		BatteryLevelPct:   batteryPct,
		SignalStrengthDbm: signalDbm,
		Metadata:          metadata,
	}

	created, err := s.repo.CreateReading(ctx, reading)
	if err != nil {
		return nil, nil, err
	}

	if updateErr := s.repo.UpdateSensorLastReading(ctx, sensorID, tenantID, timestamp, batteryPct, signalDbm); updateErr != nil {
		s.log.Errorw("msg", "failed to update sensor last reading", "error", updateErr)
	}

	if batteryPct != nil && *batteryPct < 20.0 {
		s.log.Warnw("msg", "low battery on sensor", "sensor_id", sensorID, "battery_pct", *batteryPct)
	}

	triggeredAlert := s.evaluateThresholdAlerts(ctx, tenantID, sensorID, sensor, calibratedValue)

	s.emitEvent(ctx, "agriculture.sensor.reading.ingested", sensorID, map[string]interface{}{
		"sensor_id":   sensorID,
		"value":       calibratedValue,
		"unit":        unit,
		"quality":     string(quality),
		"sensor_type": string(sensor.SensorType),
		"field_id":    sensor.FieldID,
	})

	return created, triggeredAlert, nil
}

func (s *sensorService) BatchIngestReadings(ctx context.Context, readings []domain.ReadingInput) (int32, int32, []string, []domain.SensorAlert, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return 0, 0, nil, nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if len(readings) == 0 {
		return 0, 0, nil, nil, errors.BadRequest("EMPTY_BATCH", "no readings provided")
	}
	if len(readings) > 10000 {
		return 0, 0, nil, nil, errors.BadRequest("BATCH_TOO_LARGE", "maximum 10000 readings per batch")
	}

	var (
		ingestedCount int32
		failedCount   int32
		errs          []string
		alerts        []domain.SensorAlert
	)

	sensorCache := make(map[string]*domain.Sensor)
	calibrationCache := make(map[string]*domain.SensorCalibration)

	for i, input := range readings {
		sensor, ok := sensorCache[input.SensorID]
		if !ok {
			var err error
			sensor, err = s.repo.GetSensorByUUID(ctx, input.SensorID, tenantID)
			if err != nil {
				failedCount++
				errs = append(errs, fmt.Sprintf("reading[%d]: sensor %s not found", i, input.SensorID))
				continue
			}
			sensorCache[input.SensorID] = sensor
		}

		if sensor.Status != domain.SensorStatusActive {
			failedCount++
			errs = append(errs, fmt.Sprintf("reading[%d]: sensor %s is %s", i, input.SensorID, sensor.Status))
			continue
		}

		calibratedValue := input.Value
		cal, calOk := calibrationCache[input.SensorID]
		if !calOk {
			cal, _ = s.repo.GetLatestCalibration(ctx, input.SensorID, tenantID)
			calibrationCache[input.SensorID] = cal
		}
		if cal != nil {
			calibratedValue = (input.Value * cal.ScaleFactor) + cal.OffsetValue
		}

		quality := input.Quality
		if quality == "" {
			quality = s.detectAnomalies(ctx, tenantID, input.SensorID, sensor.SensorType, calibratedValue)
		}

		ts := input.Timestamp
		if ts.IsZero() {
			ts = time.Now()
		}

		unit := input.Unit
		if unit == "" {
			if r, exists := domain.ValidReadingRanges[sensor.SensorType]; exists {
				unit = r.Unit
			}
		}

		reading := &domain.SensorReading{
			SensorID:          input.SensorID,
			TenantID:          tenantID,
			Value:             calibratedValue,
			Unit:              unit,
			RecordedAt:        ts,
			Quality:           quality,
			BatteryLevelPct:   input.BatteryLevelPct,
			SignalStrengthDbm: input.SignalStrengthDbm,
			Metadata:          input.Metadata,
		}

		_, createErr := s.repo.CreateReading(ctx, reading)
		if createErr != nil {
			failedCount++
			errs = append(errs, fmt.Sprintf("reading[%d]: %v", i, createErr))
			continue
		}
		ingestedCount++

		_ = s.repo.UpdateSensorLastReading(ctx, input.SensorID, tenantID, ts, input.BatteryLevelPct, input.SignalStrengthDbm)

		if alert := s.evaluateThresholdAlerts(ctx, tenantID, input.SensorID, sensor, calibratedValue); alert != nil {
			alerts = append(alerts, *alert)
		}
	}

	s.log.Infow("msg", "batch ingest completed", "ingested", ingestedCount, "failed", failedCount, "tenant_id", tenantID)

	return ingestedCount, failedCount, errs, alerts, nil
}

func (s *sensorService) GetLatestReading(ctx context.Context, sensorID string) (*domain.SensorReading, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if sensorID == "" {
		return nil, errors.BadRequest("MISSING_SENSOR_ID", "sensor ID is required")
	}
	return s.repo.GetLatestReading(ctx, sensorID, tenantID)
}

func (s *sensorService) GetReadingHistory(ctx context.Context, sensorID string, start, end time.Time, minQuality string, pageSize, pageOffset int32) ([]domain.SensorReading, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if sensorID == "" {
		return nil, 0, errors.BadRequest("MISSING_SENSOR_ID", "sensor ID is required")
	}
	if start.IsZero() {
		start = time.Now().Add(-24 * time.Hour)
	}
	if end.IsZero() {
		end = time.Now()
	}
	if start.After(end) {
		return nil, 0, errors.BadRequest("INVALID_TIME_RANGE", "start time must be before end time")
	}
	return s.repo.GetReadingHistory(ctx, sensorID, tenantID, start, end, minQuality, pageSize, pageOffset)
}

// =============================================================================
// Alerting
// =============================================================================

func (s *sensorService) CreateAlert(ctx context.Context, alert *domain.SensorAlert) (*domain.SensorAlert, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if alert.SensorID == "" {
		return nil, errors.BadRequest("MISSING_SENSOR_ID", "sensor ID is required")
	}
	if alert.Condition == "" {
		return nil, errors.BadRequest("MISSING_CONDITION", "alert condition is required")
	}
	if alert.Severity == "" {
		alert.Severity = domain.AlertSeverityMedium
	}
	if userID == "" {
		userID = "system"
	}

	sensor, err := s.repo.GetSensorByUUID(ctx, alert.SensorID, tenantID)
	if err != nil {
		return nil, err
	}

	alert.TenantID = tenantID
	alert.FieldID = sensor.FieldID
	alert.SensorType = sensor.SensorType
	alert.CreatedBy = userID
	alert.IsActive = true

	created, err := s.repo.CreateAlert(ctx, alert)
	if err != nil {
		return nil, err
	}

	s.log.Infow("msg", "alert created", "uuid", created.UUID, "sensor_id", alert.SensorID, "condition", alert.Condition, "threshold", alert.Threshold, "severity", alert.Severity)

	return created, nil
}

func (s *sensorService) ListAlerts(ctx context.Context, filter domain.AlertListFilter) ([]domain.SensorAlert, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	filter.TenantID = tenantID
	if filter.PageSize <= 0 {
		filter.PageSize = defaultPageSize
	}
	if filter.PageSize > maxPageSize {
		filter.PageSize = maxPageSize
	}
	return s.repo.ListAlerts(ctx, filter)
}

func (s *sensorService) AcknowledgeAlert(ctx context.Context, id string) (*domain.SensorAlert, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if id == "" {
		return nil, errors.BadRequest("MISSING_ID", "alert ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	acked, err := s.repo.AcknowledgeAlert(ctx, id, tenantID, userID)
	if err != nil {
		return nil, err
	}

	s.log.Infow("msg", "alert acknowledged", "uuid", id, "by", userID, "tenant_id", tenantID)

	return acked, nil
}

// =============================================================================
// Network & Calibration
// =============================================================================

func (s *sensorService) GetSensorNetwork(ctx context.Context, id, farmID string) (*domain.SensorNetwork, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}

	if id != "" {
		return s.repo.GetSensorNetworkByUUID(ctx, id, tenantID)
	}
	if farmID != "" {
		return s.repo.GetSensorNetworkByFarm(ctx, farmID, tenantID)
	}

	return nil, errors.BadRequest("MISSING_IDENTIFIER", "either network ID or farm ID is required")
}

func (s *sensorService) CalibrateSensor(ctx context.Context, sensorID string, offset, scaleFactor float64, notes string, nextCalDate *time.Time) (*domain.SensorCalibration, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if sensorID == "" {
		return nil, errors.BadRequest("MISSING_SENSOR_ID", "sensor ID is required")
	}
	if scaleFactor == 0 {
		return nil, errors.BadRequest("INVALID_SCALE_FACTOR", "scale factor cannot be zero")
	}
	if userID == "" {
		userID = "system"
	}

	sensor, err := s.repo.GetSensorByUUID(ctx, sensorID, tenantID)
	if err != nil {
		return nil, err
	}
	if sensor.Status == domain.SensorStatusDecommissioned {
		return nil, errors.BadRequest("SENSOR_DECOMMISSIONED", "cannot calibrate a decommissioned sensor")
	}

	cal := &domain.SensorCalibration{
		SensorID:            sensorID,
		TenantID:            tenantID,
		OffsetValue:         offset,
		ScaleFactor:         scaleFactor,
		CalibratedBy:        userID,
		Notes:               notes,
		NextCalibrationDate: nextCalDate,
	}

	created, err := s.repo.CreateCalibration(ctx, cal)
	if err != nil {
		return nil, err
	}

	s.log.Infow("msg", "sensor calibrated", "sensor_id", sensorID, "offset", offset, "scale_factor", scaleFactor, "tenant_id", tenantID)

	s.emitEvent(ctx, "agriculture.sensor.calibrated", sensorID, map[string]interface{}{
		"sensor_id":     sensorID,
		"offset":        offset,
		"scale_factor":  scaleFactor,
		"calibrated_by": userID,
	})

	return created, nil
}

// =============================================================================
// Validation & Anomaly Detection
// =============================================================================

func (s *sensorService) validateSensor(sensor *domain.Sensor) error {
	if sensor.DeviceID == "" {
		return errors.BadRequest("MISSING_DEVICE_ID", "device ID is required")
	}
	if sensor.FieldID == "" {
		return errors.BadRequest("MISSING_FIELD_ID", "field ID is required")
	}
	if sensor.FarmID == "" {
		return errors.BadRequest("MISSING_FARM_ID", "farm ID is required")
	}
	if !domain.ValidSensorTypes[sensor.SensorType] {
		return errors.BadRequest("INVALID_SENSOR_TYPE", fmt.Sprintf("invalid sensor type: %s", sensor.SensorType))
	}
	if sensor.ReadingIntervalSeconds < 0 {
		return errors.BadRequest("INVALID_INTERVAL", "reading interval must be non-negative")
	}
	if sensor.Latitude != nil && (*sensor.Latitude < -90 || *sensor.Latitude > 90) {
		return errors.BadRequest("INVALID_LATITUDE", "latitude must be between -90 and 90")
	}
	if sensor.Longitude != nil && (*sensor.Longitude < -180 || *sensor.Longitude > 180) {
		return errors.BadRequest("INVALID_LONGITUDE", "longitude must be between -180 and 180")
	}
	return nil
}

// detectAnomalies performs anomaly detection on a sensor reading using:
// 1. Range validation based on sensor type
// 2. Rate-of-change detection against previous readings
func (s *sensorService) detectAnomalies(ctx context.Context, _, sensorID string, sensorType domain.SensorType, value float64) domain.ReadingQuality {
	rangeQuality := sensorType.IsValidReading(value)
	if rangeQuality == domain.ReadingQualityBad {
		return domain.ReadingQualityBad
	}

	latestReading, err := s.repo.GetLatestReading(ctx, sensorID, p9context.TenantID(ctx))
	if err != nil || latestReading == nil {
		return rangeQuality
	}

	timeDelta := time.Since(latestReading.RecordedAt)
	if timeDelta > 0 && timeDelta < 24*time.Hour {
		valueDelta := math.Abs(value - latestReading.Value)
		maxRatePerHour := s.getMaxRateOfChange(sensorType)
		hours := timeDelta.Hours()
		if hours > 0 {
			actualRate := valueDelta / hours
			if actualRate > maxRatePerHour*3 {
				return domain.ReadingQualityBad
			}
			if actualRate > maxRatePerHour*1.5 {
				return domain.ReadingQualitySuspect
			}
		}
	}

	return rangeQuality
}

// getMaxRateOfChange returns the maximum expected rate of change per hour for each sensor type.
func (s *sensorService) getMaxRateOfChange(sensorType domain.SensorType) float64 {
	switch sensorType {
	case domain.SensorTypeSoilMoisture:
		return 10.0
	case domain.SensorTypeSoilPH:
		return 0.5
	case domain.SensorTypeTemperature:
		return 5.0
	case domain.SensorTypeHumidity:
		return 15.0
	case domain.SensorTypeRainfall:
		return 50.0
	case domain.SensorTypeWindSpeed:
		return 40.0
	case domain.SensorTypeWindDirection:
		return 360.0
	case domain.SensorTypeLightIntensity:
		return 100000.0
	case domain.SensorTypeLeafWetness:
		return 30.0
	default:
		return 100.0
	}
}

// evaluateThresholdAlerts checks all active alert rules for a sensor and creates
// an alert if any threshold is breached.
func (s *sensorService) evaluateThresholdAlerts(ctx context.Context, tenantID, sensorID string, sensor *domain.Sensor, value float64) *domain.SensorAlert {
	activeAlerts, err := s.repo.GetActiveAlertsForSensor(ctx, sensorID, tenantID)
	if err != nil {
		s.log.Errorw("msg", "failed to get active alerts for sensor", "sensor_id", sensorID, "error", err)
		return nil
	}

	for _, alertRule := range activeAlerts {
		if domain.EvaluateCondition(alertRule.Condition, value, alertRule.Threshold) {
			triggeredAlert := &domain.SensorAlert{
				SensorID:    sensorID,
				TenantID:    tenantID,
				FieldID:     sensor.FieldID,
				SensorType:  sensor.SensorType,
				Threshold:   alertRule.Threshold,
				ActualValue: value,
				Condition:   alertRule.Condition,
				Severity:    alertRule.Severity,
				Message: fmt.Sprintf("sensor %s (%s): value %.2f %s threshold %.2f",
					sensorID, sensor.SensorType, value, alertRule.Condition, alertRule.Threshold),
			}
			triggeredAlert.CreatedBy = "system"
			triggeredAlert.IsActive = true

			created, createErr := s.repo.CreateAlert(ctx, triggeredAlert)
			if createErr != nil {
				s.log.Errorw("msg", "failed to create triggered alert", "error", createErr)
				continue
			}

			s.log.Warnw("msg", "alert triggered", "sensor_id", sensorID, "condition", alertRule.Condition, "value", value, "threshold", alertRule.Threshold, "severity", alertRule.Severity)

			s.emitEvent(ctx, "agriculture.sensor.alert.triggered", created.UUID, map[string]interface{}{
				"alert_id":     created.UUID,
				"sensor_id":    sensorID,
				"sensor_type":  string(sensor.SensorType),
				"field_id":     sensor.FieldID,
				"condition":    string(alertRule.Condition),
				"threshold":    alertRule.Threshold,
				"actual_value": value,
				"severity":     string(alertRule.Severity),
			})

			return created
		}
	}

	return nil
}

// =============================================================================
// Event Publishing
// =============================================================================

func (s *sensorService) emitEvent(ctx context.Context, eventType, aggregateID string, data map[string]interface{}) {
	if s.pub == nil {
		return
	}
	payload := map[string]interface{}{
		"id":             ulid.NewString(),
		"type":           eventType,
		"aggregate_id":   aggregateID,
		"source":         serviceName,
		"correlation_id": p9context.RequestID(ctx),
		"data":           data,
	}
	raw, err := json.Marshal(payload)
	if err != nil {
		s.log.Errorw("msg", "failed to marshal event", "error", err)
		return
	}
	if err := s.pub.Publish(ctx, eventTopic, aggregateID, raw); err != nil {
		s.log.Errorw("msg", "failed to publish event", "event_type", eventType, "error", err)
	}
}
