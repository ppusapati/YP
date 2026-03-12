package handlers

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"

	pb "p9e.in/samavaya/agriculture/sensor-service/api/v1"
	"p9e.in/samavaya/agriculture/sensor-service/internal/mappers"
	"p9e.in/samavaya/agriculture/sensor-service/internal/models"
	"p9e.in/samavaya/agriculture/sensor-service/internal/services"
)

// SensorHandler implements the ConnectRPC SensorService handler.
type SensorHandler struct {
	d       deps.ServiceDeps
	service services.SensorService
	log     *p9log.Helper
}

// NewSensorHandler creates a new SensorHandler.
func NewSensorHandler(d deps.ServiceDeps, service services.SensorService) *SensorHandler {
	return &SensorHandler{
		d:       d,
		service: service,
		log:     p9log.NewHelper(p9log.With(d.Log, "component", "SensorHandler")),
	}
}

// RegisterSensor handles sensor registration requests.
func (h *SensorHandler) RegisterSensor(ctx context.Context, req *pb.RegisterSensorRequest) (*pb.RegisterSensorResponse, error) {
	requestID := p9context.RequestID(ctx)
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	h.log.Infow("msg", "RegisterSensor request", "tenant_id", tenantID, "request_id", requestID)

	if req.GetDeviceId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "device_id is required")
	}
	if req.GetFieldId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "field_id is required")
	}
	if req.GetFarmId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "farm_id is required")
	}
	if req.GetSensorType() == pb.SensorType_SENSOR_TYPE_UNSPECIFIED {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "sensor_type is required")
	}

	sensor := mappers.RegisterSensorRequestToModel(req, tenantID, userID, "")

	created, err := h.service.RegisterSensor(ctx, sensor)
	if err != nil {
		h.log.Errorw("msg", "RegisterSensor failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	return &pb.RegisterSensorResponse{
		Sensor: mappers.SensorToProto(created),
	}, nil
}

// GetSensor handles get sensor requests.
func (h *SensorHandler) GetSensor(ctx context.Context, req *pb.GetSensorRequest) (*pb.GetSensorResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GetSensor request", "id", req.GetId(), "request_id", requestID)

	if req.GetId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "sensor ID is required")
	}

	sensor, err := h.service.GetSensor(ctx, req.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetSensorResponse{
		Sensor: mappers.SensorToProto(sensor),
	}, nil
}

// ListSensors handles list sensors requests with filtering and pagination.
func (h *SensorHandler) ListSensors(ctx context.Context, req *pb.ListSensorsRequest) (*pb.ListSensorsResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "ListSensors request", "request_id", requestID)

	filter := models.SensorListFilter{
		FieldID:    req.GetFieldId(),
		FarmID:     req.GetFarmId(),
		PageSize:   req.GetPageSize(),
		PageOffset: req.GetPageOffset(),
	}

	if req.GetSensorType() != pb.SensorType_SENSOR_TYPE_UNSPECIFIED {
		filter.SensorType = string(mappers.SensorTypeFromProto(req.GetSensorType()))
	}
	if req.GetStatus() != pb.SensorStatus_SENSOR_STATUS_UNSPECIFIED {
		filter.Status = string(mappers.SensorStatusFromProto(req.GetStatus()))
	}
	if req.GetProtocol() != pb.SensorProtocol_SENSOR_PROTOCOL_UNSPECIFIED {
		filter.Protocol = string(mappers.SensorProtocolFromProto(req.GetProtocol()))
	}

	sensors, totalCount, err := h.service.ListSensors(ctx, filter)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.ListSensorsResponse{
		Sensors:    mappers.SensorsToProto(sensors),
		TotalCount: totalCount,
	}, nil
}

// UpdateSensor handles sensor update requests.
func (h *SensorHandler) UpdateSensor(ctx context.Context, req *pb.UpdateSensorRequest) (*pb.UpdateSensorResponse, error) {
	requestID := p9context.RequestID(ctx)
	tenantID := p9context.TenantID(ctx)

	h.log.Infow("msg", "UpdateSensor request", "id", req.GetId(), "request_id", requestID)

	if req.GetId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "sensor ID is required")
	}

	sensor := &models.Sensor{
		TenantID: tenantID,
	}
	sensor.UUID = req.GetId()

	if req.GetFirmwareVersion() != "" {
		sensor.FirmwareVersion = req.GetFirmwareVersion()
	}
	if req.GetLocation() != nil {
		lat := req.GetLocation().GetLatitude()
		lng := req.GetLocation().GetLongitude()
		sensor.Latitude = &lat
		sensor.Longitude = &lng
		sensor.ElevationM = req.GetLocation().GetElevationM()
	}
	if req.GetStatus() != pb.SensorStatus_SENSOR_STATUS_UNSPECIFIED {
		sensor.Status = mappers.SensorStatusFromProto(req.GetStatus())
	}
	if req.GetProtocol() != pb.SensorProtocol_SENSOR_PROTOCOL_UNSPECIFIED {
		sensor.Protocol = mappers.SensorProtocolFromProto(req.GetProtocol())
	}
	if req.GetReadingIntervalSeconds() > 0 {
		sensor.ReadingIntervalSeconds = req.GetReadingIntervalSeconds()
	}
	if req.GetMetadata() != nil {
		md, err := json.Marshal(req.GetMetadata())
		if err == nil {
			sensor.Metadata = md
		}
	}

	updated, err := h.service.UpdateSensor(ctx, sensor)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.UpdateSensorResponse{
		Sensor: mappers.SensorToProto(updated),
	}, nil
}

// DecommissionSensor handles sensor decommission requests.
func (h *SensorHandler) DecommissionSensor(ctx context.Context, req *pb.DecommissionSensorRequest) (*pb.DecommissionSensorResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "DecommissionSensor request", "id", req.GetId(), "request_id", requestID)

	if req.GetId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "sensor ID is required")
	}

	sensor, err := h.service.DecommissionSensor(ctx, req.GetId(), req.GetReason())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.DecommissionSensorResponse{
		Sensor: mappers.SensorToProto(sensor),
	}, nil
}

// IngestReading handles a single sensor reading ingestion request.
func (h *SensorHandler) IngestReading(ctx context.Context, req *pb.IngestReadingRequest) (*pb.IngestReadingResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "IngestReading request", "sensor_id", req.GetSensorId(), "request_id", requestID)

	if req.GetSensorId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "sensor_id is required")
	}

	var timestamp time.Time
	if req.GetTimestamp() != nil {
		timestamp = req.GetTimestamp().AsTime()
	}

	quality := mappers.ReadingQualityFromProto(req.GetQuality())

	var batteryPct *float64
	if req.GetBatteryLevelPct() > 0 {
		v := req.GetBatteryLevelPct()
		batteryPct = &v
	}

	var signalDbm *float64
	if req.GetSignalStrengthDbm() != 0 {
		v := req.GetSignalStrengthDbm()
		signalDbm = &v
	}

	var metadata json.RawMessage
	if req.GetMetadata() != nil {
		metadata = mappers.MetadataToJSON(req.GetMetadata())
	}

	reading, alert, err := h.service.IngestReading(ctx, req.GetSensorId(), req.GetValue(), req.GetUnit(), timestamp, quality, batteryPct, signalDbm, metadata)
	if err != nil {
		h.log.Errorw("msg", "IngestReading failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	resp := &pb.IngestReadingResponse{
		Reading: mappers.SensorReadingToProto(reading),
	}

	if alert != nil {
		resp.AlertTriggered = true
		resp.Alert = mappers.SensorAlertToProto(alert)
	}

	return resp, nil
}

// BatchIngestReadings handles batch sensor reading ingestion requests.
func (h *SensorHandler) BatchIngestReadings(ctx context.Context, req *pb.BatchIngestReadingsRequest) (*pb.BatchIngestReadingsResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "BatchIngestReadings request", "count", len(req.GetReadings()), "request_id", requestID)

	if len(req.GetReadings()) == 0 {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "at least one reading is required")
	}

	readings := make([]services.ReadingInput, 0, len(req.GetReadings()))
	for _, r := range req.GetReadings() {
		var ts time.Time
		if r.GetTimestamp() != nil {
			ts = r.GetTimestamp().AsTime()
		}

		quality := mappers.ReadingQualityFromProto(r.GetQuality())

		var batteryPct *float64
		if r.GetBatteryLevelPct() > 0 {
			v := r.GetBatteryLevelPct()
			batteryPct = &v
		}

		var signalDbm *float64
		if r.GetSignalStrengthDbm() != 0 {
			v := r.GetSignalStrengthDbm()
			signalDbm = &v
		}

		var metadata json.RawMessage
		if r.GetMetadata() != nil {
			metadata = mappers.MetadataToJSON(r.GetMetadata())
		}

		readings = append(readings, services.ReadingInput{
			SensorID:          r.GetSensorId(),
			Value:             r.GetValue(),
			Unit:              r.GetUnit(),
			Timestamp:         ts,
			Quality:           quality,
			BatteryLevelPct:   batteryPct,
			SignalStrengthDbm: signalDbm,
			Metadata:          metadata,
		})
	}

	ingestedCount, failedCount, errs, alerts, err := h.service.BatchIngestReadings(ctx, readings)
	if err != nil {
		h.log.Errorw("msg", "BatchIngestReadings failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	return &pb.BatchIngestReadingsResponse{
		IngestedCount: ingestedCount,
		FailedCount:   failedCount,
		Errors:        errs,
		Alerts:        mappers.SensorAlertsToProto(alerts),
	}, nil
}

// GetLatestReading handles get latest reading requests.
func (h *SensorHandler) GetLatestReading(ctx context.Context, req *pb.GetLatestReadingRequest) (*pb.GetLatestReadingResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GetLatestReading request", "sensor_id", req.GetSensorId(), "request_id", requestID)

	if req.GetSensorId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "sensor_id is required")
	}

	reading, err := h.service.GetLatestReading(ctx, req.GetSensorId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetLatestReadingResponse{
		Reading: mappers.SensorReadingToProto(reading),
	}, nil
}

// GetReadingHistory handles reading history requests with time range and pagination.
func (h *SensorHandler) GetReadingHistory(ctx context.Context, req *pb.GetReadingHistoryRequest) (*pb.GetReadingHistoryResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GetReadingHistory request", "sensor_id", req.GetSensorId(), "request_id", requestID)

	if req.GetSensorId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "sensor_id is required")
	}

	var startTime, endTime time.Time
	if req.GetStartTime() != nil {
		startTime = req.GetStartTime().AsTime()
	}
	if req.GetEndTime() != nil {
		endTime = req.GetEndTime().AsTime()
	}

	var minQuality string
	if req.GetMinQuality() != pb.ReadingQuality_READING_QUALITY_UNSPECIFIED {
		minQuality = string(mappers.ReadingQualityFromProto(req.GetMinQuality()))
	}

	readings, totalCount, err := h.service.GetReadingHistory(ctx, req.GetSensorId(), startTime, endTime, minQuality, req.GetPageSize(), req.GetPageOffset())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetReadingHistoryResponse{
		Readings:   mappers.SensorReadingsToProto(readings),
		TotalCount: totalCount,
	}, nil
}

// CreateAlert handles alert creation requests.
func (h *SensorHandler) CreateAlert(ctx context.Context, req *pb.CreateAlertRequest) (*pb.CreateAlertResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "CreateAlert request", "sensor_id", req.GetSensorId(), "request_id", requestID)

	if req.GetSensorId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "sensor_id is required")
	}
	if req.GetCondition() == pb.AlertCondition_ALERT_CONDITION_UNSPECIFIED {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "condition is required")
	}

	alert := &models.SensorAlert{
		SensorID:  req.GetSensorId(),
		Threshold: req.GetThreshold(),
		Condition: mappers.AlertConditionFromProto(req.GetCondition()),
		Severity:  mappers.AlertSeverityFromProto(req.GetSeverity()),
		Message:   req.GetMessage(),
	}

	if req.GetSensorType() != pb.SensorType_SENSOR_TYPE_UNSPECIFIED {
		alert.SensorType = mappers.SensorTypeFromProto(req.GetSensorType())
	}

	created, err := h.service.CreateAlert(ctx, alert)
	if err != nil {
		h.log.Errorw("msg", "CreateAlert failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	return &pb.CreateAlertResponse{
		Alert: mappers.SensorAlertToProto(created),
	}, nil
}

// ListAlerts handles list alerts requests with filtering and pagination.
func (h *SensorHandler) ListAlerts(ctx context.Context, req *pb.ListAlertsRequest) (*pb.ListAlertsResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "ListAlerts request", "request_id", requestID)

	filter := models.AlertListFilter{
		SensorID:           req.GetSensorId(),
		FieldID:            req.GetFieldId(),
		UnacknowledgedOnly: req.GetUnacknowledgedOnly(),
		PageSize:           req.GetPageSize(),
		PageOffset:         req.GetPageOffset(),
	}

	if req.GetSeverity() != pb.AlertSeverity_ALERT_SEVERITY_UNSPECIFIED {
		filter.Severity = string(mappers.AlertSeverityFromProto(req.GetSeverity()))
	}

	alerts, totalCount, err := h.service.ListAlerts(ctx, filter)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.ListAlertsResponse{
		Alerts:     mappers.SensorAlertsToProto(alerts),
		TotalCount: totalCount,
	}, nil
}

// AcknowledgeAlert handles alert acknowledgement requests.
func (h *SensorHandler) AcknowledgeAlert(ctx context.Context, req *pb.AcknowledgeAlertRequest) (*pb.AcknowledgeAlertResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "AcknowledgeAlert request", "id", req.GetId(), "request_id", requestID)

	if req.GetId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "alert ID is required")
	}

	alert, err := h.service.AcknowledgeAlert(ctx, req.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.AcknowledgeAlertResponse{
		Alert: mappers.SensorAlertToProto(alert),
	}, nil
}

// GetSensorNetwork handles get sensor network requests.
func (h *SensorHandler) GetSensorNetwork(ctx context.Context, req *pb.GetSensorNetworkRequest) (*pb.GetSensorNetworkResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GetSensorNetwork request", "id", req.GetId(), "farm_id", req.GetFarmId(), "request_id", requestID)

	if req.GetId() == "" && req.GetFarmId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "either network ID or farm_id is required")
	}

	network, err := h.service.GetSensorNetwork(ctx, req.GetId(), req.GetFarmId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetSensorNetworkResponse{
		Network: mappers.SensorNetworkToProto(network),
	}, nil
}

// CalibrateSensor handles sensor calibration requests.
func (h *SensorHandler) CalibrateSensor(ctx context.Context, req *pb.CalibrateSensorRequest) (*pb.CalibrateSensorResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "CalibrateSensor request", "sensor_id", req.GetSensorId(), "request_id", requestID)

	if req.GetSensorId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "sensor_id is required")
	}
	if req.GetScaleFactor() == 0 {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "scale_factor cannot be zero")
	}

	var nextCalDate *time.Time
	if req.GetNextCalibrationDate() != nil {
		t := req.GetNextCalibrationDate().AsTime()
		nextCalDate = &t
	}

	calibration, err := h.service.CalibrateSensor(ctx, req.GetSensorId(), req.GetOffset(), req.GetScaleFactor(), req.GetNotes(), nextCalDate)
	if err != nil {
		h.log.Errorw("msg", "CalibrateSensor failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	return &pb.CalibrateSensorResponse{
		Calibration: mappers.SensorCalibrationToProto(calibration),
	}, nil
}

// Ensure fmt import is referenced.
var _ = fmt.Sprintf
