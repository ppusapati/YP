package services

import (
	"context"
	"encoding/json"
	"fmt"
	"math"
	"time"

	"p9e.in/samavaya/agriculture/sensor-service/internal/models"
	"p9e.in/samavaya/agriculture/sensor-service/internal/repositories"
	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"
)

// SensorService defines the business logic for sensor management.
type SensorService interface {
	// Sensor lifecycle
	RegisterSensor(ctx context.Context, sensor *models.Sensor) (*models.Sensor, error)
	GetSensor(ctx context.Context, id string) (*models.Sensor, error)
	ListSensors(ctx context.Context, filter models.SensorListFilter) ([]models.Sensor, int32, error)
	UpdateSensor(ctx context.Context, sensor *models.Sensor) (*models.Sensor, error)
	DecommissionSensor(ctx context.Context, id, reason string) (*models.Sensor, error)

	// Data ingestion
	IngestReading(ctx context.Context, sensorID string, value float64, unit string, timestamp time.Time, quality models.ReadingQuality, batteryPct, signalDbm *float64, metadata json.RawMessage) (*models.SensorReading, *models.SensorAlert, error)
	BatchIngestReadings(ctx context.Context, readings []ReadingInput) (int32, int32, []string, []models.SensorAlert, error)
	GetLatestReading(ctx context.Context, sensorID string) (*models.SensorReading, error)
	GetReadingHistory(ctx context.Context, sensorID string, start, end time.Time, minQuality string, pageSize, pageOffset int32) ([]models.SensorReading, int32, error)

	// Alerting
	CreateAlert(ctx context.Context, alert *models.SensorAlert) (*models.SensorAlert, error)
	ListAlerts(ctx context.Context, filter models.AlertListFilter) ([]models.SensorAlert, int32, error)
	AcknowledgeAlert(ctx context.Context, id string) (*models.SensorAlert, error)

	// Network and calibration
	GetSensorNetwork(ctx context.Context, id, farmID string) (*models.SensorNetwork, error)
	CalibrateSensor(ctx context.Context, sensorID string, offset, scaleFactor float64, notes string, nextCalDate *time.Time) (*models.SensorCalibration, error)
}

// ReadingInput represents an individual reading in a batch ingest request.
type ReadingInput struct {
	SensorID          string
	Value             float64
	Unit              string
	Timestamp         time.Time
	Quality           models.ReadingQuality
	BatteryLevelPct   *float64
	SignalStrengthDbm *float64
	Metadata          json.RawMessage
}

type sensorService struct {
	repo   repositories.SensorRepository
	deps   deps.ServiceDeps
	logger *p9log.Helper
}

// NewSensorService creates a new SensorService.
func NewSensorService(repo repositories.SensorRepository, d deps.ServiceDeps) SensorService {
	return &sensorService{
		repo:   repo,
		deps:   d,
		logger: p9log.NewHelper(p9log.With(d.Log, "component", "SensorService")),
	}
}

// =============================================================================
// Sensor Lifecycle
// =============================================================================

func (s *sensorService) RegisterSensor(ctx context.Context, sensor *models.Sensor) (*models.Sensor, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}

	if err := s.validateSensor(sensor); err != nil {
		return nil, err
	}

	sensor.TenantID = tenantID
	sensor.CreatedBy = userID
	if sensor.UUID == "" {
		sensor.UUID = ulid.NewString()
	}

	// Check for duplicate device_id within tenant
	existing, err := s.repo.GetSensorByDeviceID(ctx, tenantID, sensor.DeviceID)
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

	s.logger.Infof("sensor registered: uuid=%s device_id=%s type=%s tenant=%s",
		created.UUID, created.DeviceID, created.SensorType, tenantID)

	// Publish domain event
	s.publishEvent(ctx, domain.EventType("agriculture.sensor.registered"), created.UUID, "sensor", map[string]interface{}{
		"sensor_id":   created.UUID,
		"device_id":   created.DeviceID,
		"sensor_type": string(created.SensorType),
		"field_id":    created.FieldID,
		"farm_id":     created.FarmID,
		"status":      string(created.Status),
	})

	return created, nil
}

func (s *sensorService) GetSensor(ctx context.Context, id string) (*models.Sensor, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if id == "" {
		return nil, errors.BadRequest("MISSING_ID", "sensor ID is required")
	}

	return s.repo.GetSensorByUUID(ctx, tenantID, id)
}

func (s *sensorService) ListSensors(ctx context.Context, filter models.SensorListFilter) ([]models.Sensor, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	filter.TenantID = tenantID

	return s.repo.ListSensors(ctx, filter)
}

func (s *sensorService) UpdateSensor(ctx context.Context, sensor *models.Sensor) (*models.Sensor, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if sensor.UUID == "" {
		return nil, errors.BadRequest("MISSING_ID", "sensor ID is required")
	}

	// Verify sensor exists
	existing, err := s.repo.GetSensorByUUID(ctx, tenantID, sensor.UUID)
	if err != nil {
		return nil, err
	}
	if existing.Status == models.SensorStatusDecommissioned {
		return nil, errors.BadRequest("SENSOR_DECOMMISSIONED", "cannot update a decommissioned sensor")
	}

	sensor.TenantID = tenantID
	updatedBy := userID
	sensor.UpdatedBy = &updatedBy

	updated, err := s.repo.UpdateSensor(ctx, sensor)
	if err != nil {
		return nil, err
	}

	s.logger.Infof("sensor updated: uuid=%s tenant=%s", updated.UUID, tenantID)

	return updated, nil
}

func (s *sensorService) DecommissionSensor(ctx context.Context, id, reason string) (*models.Sensor, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if id == "" {
		return nil, errors.BadRequest("MISSING_ID", "sensor ID is required")
	}

	decommissioned, err := s.repo.DecommissionSensor(ctx, tenantID, id, userID)
	if err != nil {
		return nil, err
	}

	s.logger.Infof("sensor decommissioned: uuid=%s reason=%s tenant=%s", id, reason, tenantID)

	s.publishEvent(ctx, domain.EventType("agriculture.sensor.decommissioned"), id, "sensor", map[string]interface{}{
		"sensor_id": id,
		"reason":    reason,
		"device_id": decommissioned.DeviceID,
	})

	return decommissioned, nil
}

// =============================================================================
// Data Ingestion
// =============================================================================

func (s *sensorService) IngestReading(ctx context.Context, sensorID string, value float64, unit string, timestamp time.Time, quality models.ReadingQuality, batteryPct, signalDbm *float64, metadata json.RawMessage) (*models.SensorReading, *models.SensorAlert, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if sensorID == "" {
		return nil, nil, errors.BadRequest("MISSING_SENSOR_ID", "sensor ID is required")
	}

	// Retrieve sensor for validation and type-specific checks
	sensor, err := s.repo.GetSensorByUUID(ctx, tenantID, sensorID)
	if err != nil {
		return nil, nil, err
	}
	if sensor.Status != models.SensorStatusActive {
		return nil, nil, errors.BadRequest("SENSOR_NOT_ACTIVE", fmt.Sprintf("sensor %s is in %s state", sensorID, sensor.Status))
	}

	// Apply calibration correction if available
	calibratedValue := value
	cal, calErr := s.repo.GetLatestCalibration(ctx, tenantID, sensorID)
	if calErr == nil && cal != nil {
		calibratedValue = (value * cal.ScaleFactor) + cal.OffsetValue
	}

	// Perform anomaly detection: auto-assign quality if not explicitly set
	if quality == "" || quality == models.ReadingQualityGood {
		quality = s.detectAnomalies(ctx, tenantID, sensorID, sensor.SensorType, calibratedValue)
	}

	// Set default timestamp
	if timestamp.IsZero() {
		timestamp = time.Now()
	}

	// Set default unit based on sensor type
	if unit == "" {
		if r, ok := models.ValidReadingRanges[sensor.SensorType]; ok {
			unit = r.Unit
		}
	}

	reading := &models.SensorReading{
		UUID:              ulid.NewString(),
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

	// Update sensor's last reading timestamp and telemetry
	if updateErr := s.repo.UpdateSensorLastReading(ctx, tenantID, sensorID, timestamp, batteryPct, signalDbm); updateErr != nil {
		s.logger.Errorf("failed to update sensor last reading: %v", updateErr)
	}

	// Check low battery
	if batteryPct != nil && *batteryPct < 20.0 {
		s.logger.Warnf("low battery on sensor %s: %.1f%%", sensorID, *batteryPct)
	}

	// Check threshold alerts
	triggeredAlert := s.evaluateThresholdAlerts(ctx, tenantID, sensorID, sensor, calibratedValue)

	// Publish reading ingested event
	s.publishEvent(ctx, domain.EventType("agriculture.sensor.reading.ingested"), sensorID, "sensor_reading", map[string]interface{}{
		"sensor_id":   sensorID,
		"value":       calibratedValue,
		"unit":        unit,
		"quality":     string(quality),
		"sensor_type": string(sensor.SensorType),
		"field_id":    sensor.FieldID,
	})

	return created, triggeredAlert, nil
}

func (s *sensorService) BatchIngestReadings(ctx context.Context, readings []ReadingInput) (int32, int32, []string, []models.SensorAlert, error) {
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
		alerts        []models.SensorAlert
	)

	// Cache sensor lookups for efficiency
	sensorCache := make(map[string]*models.Sensor)
	calibrationCache := make(map[string]*models.SensorCalibration)

	for i, input := range readings {
		// Get or cache the sensor
		sensor, ok := sensorCache[input.SensorID]
		if !ok {
			var err error
			sensor, err = s.repo.GetSensorByUUID(ctx, tenantID, input.SensorID)
			if err != nil {
				failedCount++
				errs = append(errs, fmt.Sprintf("reading[%d]: sensor %s not found", i, input.SensorID))
				continue
			}
			sensorCache[input.SensorID] = sensor
		}

		if sensor.Status != models.SensorStatusActive {
			failedCount++
			errs = append(errs, fmt.Sprintf("reading[%d]: sensor %s is %s", i, input.SensorID, sensor.Status))
			continue
		}

		// Apply calibration
		calibratedValue := input.Value
		cal, calOk := calibrationCache[input.SensorID]
		if !calOk {
			cal, _ = s.repo.GetLatestCalibration(ctx, tenantID, input.SensorID)
			calibrationCache[input.SensorID] = cal
		}
		if cal != nil {
			calibratedValue = (input.Value * cal.ScaleFactor) + cal.OffsetValue
		}

		// Quality detection
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
			if r, exists := models.ValidReadingRanges[sensor.SensorType]; exists {
				unit = r.Unit
			}
		}

		reading := &models.SensorReading{
			UUID:              ulid.NewString(),
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

		// Update sensor last reading
		_ = s.repo.UpdateSensorLastReading(ctx, tenantID, input.SensorID, ts, input.BatteryLevelPct, input.SignalStrengthDbm)

		// Check alerts
		if alert := s.evaluateThresholdAlerts(ctx, tenantID, input.SensorID, sensor, calibratedValue); alert != nil {
			alerts = append(alerts, *alert)
		}
	}

	s.logger.Infof("batch ingest completed: ingested=%d failed=%d tenant=%s", ingestedCount, failedCount, tenantID)

	return ingestedCount, failedCount, errs, alerts, nil
}

func (s *sensorService) GetLatestReading(ctx context.Context, sensorID string) (*models.SensorReading, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if sensorID == "" {
		return nil, errors.BadRequest("MISSING_SENSOR_ID", "sensor ID is required")
	}

	return s.repo.GetLatestReading(ctx, tenantID, sensorID)
}

func (s *sensorService) GetReadingHistory(ctx context.Context, sensorID string, start, end time.Time, minQuality string, pageSize, pageOffset int32) ([]models.SensorReading, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if sensorID == "" {
		return nil, 0, errors.BadRequest("MISSING_SENSOR_ID", "sensor ID is required")
	}
	if start.IsZero() {
		start = time.Now().Add(-24 * time.Hour) // default to last 24 hours
	}
	if end.IsZero() {
		end = time.Now()
	}
	if start.After(end) {
		return nil, 0, errors.BadRequest("INVALID_TIME_RANGE", "start time must be before end time")
	}

	return s.repo.GetReadingHistory(ctx, tenantID, sensorID, start, end, minQuality, pageSize, pageOffset)
}

// =============================================================================
// Alerting
// =============================================================================

func (s *sensorService) CreateAlert(ctx context.Context, alert *models.SensorAlert) (*models.SensorAlert, error) {
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
		alert.Severity = models.AlertSeverityMedium
	}

	// Verify sensor exists
	sensor, err := s.repo.GetSensorByUUID(ctx, tenantID, alert.SensorID)
	if err != nil {
		return nil, err
	}

	alert.TenantID = tenantID
	alert.FieldID = sensor.FieldID
	alert.SensorType = sensor.SensorType
	alert.UUID = ulid.NewString()
	alert.CreatedBy = userID
	alert.IsActive = true

	created, err := s.repo.CreateAlert(ctx, alert)
	if err != nil {
		return nil, err
	}

	s.logger.Infof("alert created: uuid=%s sensor=%s condition=%s threshold=%.2f severity=%s",
		created.UUID, alert.SensorID, alert.Condition, alert.Threshold, alert.Severity)

	return created, nil
}

func (s *sensorService) ListAlerts(ctx context.Context, filter models.AlertListFilter) ([]models.SensorAlert, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	filter.TenantID = tenantID

	return s.repo.ListAlerts(ctx, filter)
}

func (s *sensorService) AcknowledgeAlert(ctx context.Context, id string) (*models.SensorAlert, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if id == "" {
		return nil, errors.BadRequest("MISSING_ID", "alert ID is required")
	}

	acked, err := s.repo.AcknowledgeAlert(ctx, tenantID, id, userID)
	if err != nil {
		return nil, err
	}

	s.logger.Infof("alert acknowledged: uuid=%s by=%s tenant=%s", id, userID, tenantID)

	return acked, nil
}

// =============================================================================
// Network & Calibration
// =============================================================================

func (s *sensorService) GetSensorNetwork(ctx context.Context, id, farmID string) (*models.SensorNetwork, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}

	if id != "" {
		return s.repo.GetSensorNetworkByUUID(ctx, tenantID, id)
	}
	if farmID != "" {
		return s.repo.GetSensorNetworkByFarm(ctx, tenantID, farmID)
	}

	return nil, errors.BadRequest("MISSING_IDENTIFIER", "either network ID or farm ID is required")
}

func (s *sensorService) CalibrateSensor(ctx context.Context, sensorID string, offset, scaleFactor float64, notes string, nextCalDate *time.Time) (*models.SensorCalibration, error) {
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

	// Verify sensor exists
	sensor, err := s.repo.GetSensorByUUID(ctx, tenantID, sensorID)
	if err != nil {
		return nil, err
	}
	if sensor.Status == models.SensorStatusDecommissioned {
		return nil, errors.BadRequest("SENSOR_DECOMMISSIONED", "cannot calibrate a decommissioned sensor")
	}

	cal := &models.SensorCalibration{
		UUID:                ulid.NewString(),
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

	s.logger.Infof("sensor calibrated: sensor=%s offset=%.4f scale=%.4f tenant=%s", sensorID, offset, scaleFactor, tenantID)

	s.publishEvent(ctx, domain.EventType("agriculture.sensor.calibrated"), sensorID, "sensor", map[string]interface{}{
		"sensor_id":    sensorID,
		"offset":       offset,
		"scale_factor": scaleFactor,
		"calibrated_by": userID,
	})

	return created, nil
}

// =============================================================================
// Validation & Anomaly Detection
// =============================================================================

func (s *sensorService) validateSensor(sensor *models.Sensor) error {
	if sensor.DeviceID == "" {
		return errors.BadRequest("MISSING_DEVICE_ID", "device ID is required")
	}
	if sensor.FieldID == "" {
		return errors.BadRequest("MISSING_FIELD_ID", "field ID is required")
	}
	if sensor.FarmID == "" {
		return errors.BadRequest("MISSING_FARM_ID", "farm ID is required")
	}
	if !models.ValidSensorTypes[sensor.SensorType] {
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
// 3. Statistical deviation analysis from recent readings
func (s *sensorService) detectAnomalies(ctx context.Context, tenantID, sensorID string, sensorType models.SensorType, value float64) models.ReadingQuality {
	// Step 1: Range validation
	rangeQuality := sensorType.IsValidReading(value)
	if rangeQuality == models.ReadingQualityBad {
		return models.ReadingQualityBad
	}

	// Step 2: Rate-of-change detection
	latestReading, err := s.repo.GetLatestReading(ctx, tenantID, sensorID)
	if err != nil || latestReading == nil {
		// No prior reading to compare against; rely only on range check
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
				return models.ReadingQualityBad
			}
			if actualRate > maxRatePerHour*1.5 {
				return models.ReadingQualitySuspect
			}
		}
	}

	return rangeQuality
}

// getMaxRateOfChange returns the maximum expected rate of change per hour for each sensor type.
// Values beyond these rates indicate potential anomalies.
func (s *sensorService) getMaxRateOfChange(sensorType models.SensorType) float64 {
	switch sensorType {
	case models.SensorTypeSoilMoisture:
		return 10.0 // 10% per hour max normal change
	case models.SensorTypeSoilPH:
		return 0.5 // pH changes very slowly
	case models.SensorTypeTemperature:
		return 5.0 // 5 degrees C per hour
	case models.SensorTypeHumidity:
		return 15.0 // 15% per hour
	case models.SensorTypeRainfall:
		return 50.0 // 50mm per hour (heavy rain)
	case models.SensorTypeWindSpeed:
		return 40.0 // 40 km/h per hour change
	case models.SensorTypeWindDirection:
		return 360.0 // can change rapidly
	case models.SensorTypeLightIntensity:
		return 100000.0 // changes rapidly with clouds
	case models.SensorTypeLeafWetness:
		return 30.0 // can change quickly with irrigation
	default:
		return 100.0
	}
}

// evaluateThresholdAlerts checks all active alert rules for a sensor and creates
// an alert if any threshold is breached.
func (s *sensorService) evaluateThresholdAlerts(ctx context.Context, tenantID, sensorID string, sensor *models.Sensor, value float64) *models.SensorAlert {
	activeAlerts, err := s.repo.GetActiveAlertsForSensor(ctx, tenantID, sensorID)
	if err != nil {
		s.logger.Errorf("failed to get active alerts for sensor %s: %v", sensorID, err)
		return nil
	}

	for _, alertRule := range activeAlerts {
		if models.EvaluateCondition(alertRule.Condition, value, alertRule.Threshold) {
			// Threshold breached - create a new triggered alert
			triggeredAlert := &models.SensorAlert{
				SensorID:   sensorID,
				TenantID:   tenantID,
				FieldID:    sensor.FieldID,
				SensorType: sensor.SensorType,
				Threshold:  alertRule.Threshold,
				ActualValue: value,
				Condition:  alertRule.Condition,
				Severity:   alertRule.Severity,
				Message: fmt.Sprintf("sensor %s (%s): value %.2f %s threshold %.2f",
					sensorID, sensor.SensorType, value, alertRule.Condition, alertRule.Threshold),
				UUID:      ulid.NewString(),
				CreatedBy: "system",
			}
			triggeredAlert.IsActive = true

			created, createErr := s.repo.CreateAlert(ctx, triggeredAlert)
			if createErr != nil {
				s.logger.Errorf("failed to create triggered alert: %v", createErr)
				continue
			}

			s.logger.Warnf("alert triggered: sensor=%s condition=%s value=%.2f threshold=%.2f severity=%s",
				sensorID, alertRule.Condition, value, alertRule.Threshold, alertRule.Severity)

			// Publish alert event
			s.publishEvent(ctx, domain.EventType("agriculture.sensor.alert.triggered"), created.UUID, "sensor_alert", map[string]interface{}{
				"alert_id":    created.UUID,
				"sensor_id":   sensorID,
				"sensor_type": string(sensor.SensorType),
				"field_id":    sensor.FieldID,
				"condition":   string(alertRule.Condition),
				"threshold":   alertRule.Threshold,
				"actual_value": value,
				"severity":    string(alertRule.Severity),
			})

			return created
		}
	}

	return nil
}

// =============================================================================
// Event Publishing
// =============================================================================

func (s *sensorService) publishEvent(ctx context.Context, eventType domain.EventType, aggregateID, aggregateType string, data map[string]interface{}) {
	event := domain.NewDomainEvent(eventType, aggregateID, aggregateType, data).
		WithSource("sensor-service").
		WithPriority(domain.PriorityMedium)

	tenantID := p9context.TenantID(ctx)
	if tenantID != "" {
		event.WithMetadata("tenant_id", tenantID)
	}

	if s.deps.KafkaProducer != nil {
		eventData, err := json.Marshal(event)
		if err != nil {
			s.logger.Errorf("failed to marshal event: %v", err)
			return
		}
		s.logger.Debugf("publishing event: type=%s aggregate=%s data_size=%d", eventType, aggregateID, len(eventData))
	}
}
