package mappers

import (
	"time"

	pb "p9e.in/samavaya/agriculture/irrigation-service/api/v1"
	"p9e.in/samavaya/agriculture/irrigation-service/internal/models"

	"google.golang.org/protobuf/types/known/timestamppb"
)

// ---------------------------------------------------------------------------
// Proto enum <-> domain string conversions
// ---------------------------------------------------------------------------

func ScheduleTypeToProto(st models.ScheduleType) pb.ScheduleType {
	switch st {
	case models.ScheduleTypeFixed:
		return pb.ScheduleType_SCHEDULE_TYPE_FIXED
	case models.ScheduleTypeAdaptive:
		return pb.ScheduleType_SCHEDULE_TYPE_ADAPTIVE
	case models.ScheduleTypeAIDriven:
		return pb.ScheduleType_SCHEDULE_TYPE_AI_DRIVEN
	default:
		return pb.ScheduleType_SCHEDULE_TYPE_UNSPECIFIED
	}
}

func ScheduleTypeFromProto(st pb.ScheduleType) models.ScheduleType {
	switch st {
	case pb.ScheduleType_SCHEDULE_TYPE_FIXED:
		return models.ScheduleTypeFixed
	case pb.ScheduleType_SCHEDULE_TYPE_ADAPTIVE:
		return models.ScheduleTypeAdaptive
	case pb.ScheduleType_SCHEDULE_TYPE_AI_DRIVEN:
		return models.ScheduleTypeAIDriven
	default:
		return models.ScheduleTypeFixed
	}
}

func FrequencyToProto(f models.Frequency) pb.Frequency {
	switch f {
	case models.FrequencyDaily:
		return pb.Frequency_FREQUENCY_DAILY
	case models.FrequencyEveryOther:
		return pb.Frequency_FREQUENCY_EVERY_OTHER_DAY
	case models.FrequencyWeekly:
		return pb.Frequency_FREQUENCY_WEEKLY
	case models.FrequencyCustom:
		return pb.Frequency_FREQUENCY_CUSTOM
	default:
		return pb.Frequency_FREQUENCY_UNSPECIFIED
	}
}

func FrequencyFromProto(f pb.Frequency) models.Frequency {
	switch f {
	case pb.Frequency_FREQUENCY_DAILY:
		return models.FrequencyDaily
	case pb.Frequency_FREQUENCY_EVERY_OTHER_DAY:
		return models.FrequencyEveryOther
	case pb.Frequency_FREQUENCY_WEEKLY:
		return models.FrequencyWeekly
	case pb.Frequency_FREQUENCY_CUSTOM:
		return models.FrequencyCustom
	default:
		return models.FrequencyDaily
	}
}

func ControllerTypeToProto(ct models.ControllerType) pb.ControllerType {
	switch ct {
	case models.ControllerTypeDrip:
		return pb.ControllerType_CONTROLLER_TYPE_DRIP
	case models.ControllerTypeValve:
		return pb.ControllerType_CONTROLLER_TYPE_VALVE
	case models.ControllerTypePump:
		return pb.ControllerType_CONTROLLER_TYPE_PUMP
	case models.ControllerTypeSprinkler:
		return pb.ControllerType_CONTROLLER_TYPE_SPRINKLER
	default:
		return pb.ControllerType_CONTROLLER_TYPE_UNSPECIFIED
	}
}

func ControllerTypeFromProto(ct pb.ControllerType) models.ControllerType {
	switch ct {
	case pb.ControllerType_CONTROLLER_TYPE_DRIP:
		return models.ControllerTypeDrip
	case pb.ControllerType_CONTROLLER_TYPE_VALVE:
		return models.ControllerTypeValve
	case pb.ControllerType_CONTROLLER_TYPE_PUMP:
		return models.ControllerTypePump
	case pb.ControllerType_CONTROLLER_TYPE_SPRINKLER:
		return models.ControllerTypeSprinkler
	default:
		return models.ControllerTypeDrip
	}
}

func ProtocolToProto(p models.Protocol) pb.Protocol {
	switch p {
	case models.ProtocolMQTT:
		return pb.Protocol_PROTOCOL_MQTT
	case models.ProtocolLoRaWAN:
		return pb.Protocol_PROTOCOL_LORAWAN
	case models.ProtocolModbus:
		return pb.Protocol_PROTOCOL_MODBUS
	default:
		return pb.Protocol_PROTOCOL_UNSPECIFIED
	}
}

func ProtocolFromProto(p pb.Protocol) models.Protocol {
	switch p {
	case pb.Protocol_PROTOCOL_MQTT:
		return models.ProtocolMQTT
	case pb.Protocol_PROTOCOL_LORAWAN:
		return models.ProtocolLoRaWAN
	case pb.Protocol_PROTOCOL_MODBUS:
		return models.ProtocolModbus
	default:
		return models.ProtocolMQTT
	}
}

func ControllerStatusToProto(cs models.ControllerStatus) pb.ControllerStatus {
	switch cs {
	case models.ControllerStatusOnline:
		return pb.ControllerStatus_CONTROLLER_STATUS_ONLINE
	case models.ControllerStatusOffline:
		return pb.ControllerStatus_CONTROLLER_STATUS_OFFLINE
	case models.ControllerStatusError:
		return pb.ControllerStatus_CONTROLLER_STATUS_ERROR
	default:
		return pb.ControllerStatus_CONTROLLER_STATUS_UNSPECIFIED
	}
}

func ControllerStatusFromProto(cs pb.ControllerStatus) models.ControllerStatus {
	switch cs {
	case pb.ControllerStatus_CONTROLLER_STATUS_ONLINE:
		return models.ControllerStatusOnline
	case pb.ControllerStatus_CONTROLLER_STATUS_OFFLINE:
		return models.ControllerStatusOffline
	case pb.ControllerStatus_CONTROLLER_STATUS_ERROR:
		return models.ControllerStatusError
	default:
		return models.ControllerStatusOffline
	}
}

func IrrigationStatusToProto(s models.IrrigationStatus) pb.IrrigationStatus {
	switch s {
	case models.IrrigationStatusScheduled:
		return pb.IrrigationStatus_IRRIGATION_STATUS_SCHEDULED
	case models.IrrigationStatusActive:
		return pb.IrrigationStatus_IRRIGATION_STATUS_ACTIVE
	case models.IrrigationStatusCompleted:
		return pb.IrrigationStatus_IRRIGATION_STATUS_COMPLETED
	case models.IrrigationStatusCancelled:
		return pb.IrrigationStatus_IRRIGATION_STATUS_CANCELLED
	case models.IrrigationStatusFailed:
		return pb.IrrigationStatus_IRRIGATION_STATUS_FAILED
	default:
		return pb.IrrigationStatus_IRRIGATION_STATUS_UNSPECIFIED
	}
}

func IrrigationStatusFromProto(s pb.IrrigationStatus) models.IrrigationStatus {
	switch s {
	case pb.IrrigationStatus_IRRIGATION_STATUS_SCHEDULED:
		return models.IrrigationStatusScheduled
	case pb.IrrigationStatus_IRRIGATION_STATUS_ACTIVE:
		return models.IrrigationStatusActive
	case pb.IrrigationStatus_IRRIGATION_STATUS_COMPLETED:
		return models.IrrigationStatusCompleted
	case pb.IrrigationStatus_IRRIGATION_STATUS_CANCELLED:
		return models.IrrigationStatusCancelled
	case pb.IrrigationStatus_IRRIGATION_STATUS_FAILED:
		return models.IrrigationStatusFailed
	default:
		return models.IrrigationStatusScheduled
	}
}

// ---------------------------------------------------------------------------
// Timestamp helpers
// ---------------------------------------------------------------------------

func timeToProto(t time.Time) *timestamppb.Timestamp {
	if t.IsZero() {
		return nil
	}
	return timestamppb.New(t)
}

func timePtrToProto(t *time.Time) *timestamppb.Timestamp {
	if t == nil {
		return nil
	}
	return timestamppb.New(*t)
}

func protoToTime(ts *timestamppb.Timestamp) time.Time {
	if ts == nil {
		return time.Time{}
	}
	return ts.AsTime()
}

func protoToTimePtr(ts *timestamppb.Timestamp) *time.Time {
	if ts == nil {
		return nil
	}
	t := ts.AsTime()
	return &t
}

// ---------------------------------------------------------------------------
// Schedule mappers
// ---------------------------------------------------------------------------

// ScheduleToProto converts a domain IrrigationSchedule to its proto representation.
func ScheduleToProto(s *models.IrrigationSchedule) *pb.IrrigationSchedule {
	if s == nil {
		return nil
	}
	return &pb.IrrigationSchedule{
		Id:                       s.UUID,
		TenantId:                 s.TenantID,
		FieldId:                  s.FieldID,
		FarmId:                   s.FarmID,
		ZoneId:                   s.ZoneID,
		Name:                     s.Name,
		Description:              s.Description,
		ScheduleType:             ScheduleTypeToProto(s.ScheduleType),
		StartTime:                timeToProto(s.StartTime),
		EndTime:                  timePtrToProto(s.EndTime),
		DurationMinutes:          s.DurationMinutes,
		WaterQuantityLiters:      s.WaterQuantityLiters,
		FlowRateLitersPerHour:    s.FlowRateLitersPerHour,
		Frequency:                FrequencyToProto(s.Frequency),
		SoilMoistureThresholdPct: s.SoilMoistureThresholdPct,
		WeatherAdjusted:          s.WeatherAdjusted,
		CropGrowthStage:          s.CropGrowthStage,
		ControllerId:             s.ControllerID,
		Status:                   IrrigationStatusToProto(s.Status),
		Version:                  s.Version,
		CreatedBy:                s.CreatedBy,
		CreatedAt:                timeToProto(s.CreatedAt),
		UpdatedAt:                timePtrToProto(s.UpdatedAt),
	}
}

// ScheduleFromProto converts a proto IrrigationSchedule to the domain model.
func ScheduleFromProto(p *pb.IrrigationSchedule) *models.IrrigationSchedule {
	if p == nil {
		return nil
	}
	return &models.IrrigationSchedule{
		TenantID:                 p.TenantId,
		FieldID:                  p.FieldId,
		FarmID:                   p.FarmId,
		ZoneID:                   p.ZoneId,
		Name:                     p.Name,
		Description:              p.Description,
		ScheduleType:             ScheduleTypeFromProto(p.ScheduleType),
		StartTime:                protoToTime(p.StartTime),
		EndTime:                  protoToTimePtr(p.EndTime),
		DurationMinutes:          p.DurationMinutes,
		WaterQuantityLiters:      p.WaterQuantityLiters,
		FlowRateLitersPerHour:    p.FlowRateLitersPerHour,
		Frequency:                FrequencyFromProto(p.Frequency),
		SoilMoistureThresholdPct: p.SoilMoistureThresholdPct,
		WeatherAdjusted:          p.WeatherAdjusted,
		CropGrowthStage:          p.CropGrowthStage,
		ControllerID:             p.ControllerId,
		Status:                   IrrigationStatusFromProto(p.Status),
		Version:                  p.Version,
	}
}

// SchedulesToProto converts a slice of domain schedules to proto.
func SchedulesToProto(ss []models.IrrigationSchedule) []*pb.IrrigationSchedule {
	out := make([]*pb.IrrigationSchedule, len(ss))
	for i := range ss {
		out[i] = ScheduleToProto(&ss[i])
	}
	return out
}

// ---------------------------------------------------------------------------
// Zone mappers
// ---------------------------------------------------------------------------

// ZoneToProto converts a domain IrrigationZone to its proto representation.
func ZoneToProto(z *models.IrrigationZone) *pb.IrrigationZone {
	if z == nil {
		return nil
	}
	return &pb.IrrigationZone{
		Id:              z.UUID,
		TenantId:        z.TenantID,
		FieldId:         z.FieldID,
		FarmId:          z.FarmID,
		Name:            z.Name,
		Description:     z.Description,
		AreaHectares:    z.AreaHectares,
		SoilType:        z.SoilType,
		CropType:        z.CropType,
		CropGrowthStage: z.CropGrowthStage,
		Latitude:        z.Latitude,
		Longitude:       z.Longitude,
		IsActive:        z.IsActive,
		CreatedAt:       timeToProto(z.CreatedAt),
		UpdatedAt:       timePtrToProto(z.UpdatedAt),
	}
}

// ZoneFromProto converts a proto IrrigationZone to the domain model.
func ZoneFromProto(p *pb.IrrigationZone) *models.IrrigationZone {
	if p == nil {
		return nil
	}
	return &models.IrrigationZone{
		TenantID:        p.TenantId,
		FieldID:         p.FieldId,
		FarmID:          p.FarmId,
		Name:            p.Name,
		Description:     p.Description,
		AreaHectares:    p.AreaHectares,
		SoilType:        p.SoilType,
		CropType:        p.CropType,
		CropGrowthStage: p.CropGrowthStage,
		Latitude:        p.Latitude,
		Longitude:       p.Longitude,
	}
}

// ZonesToProto converts a slice of domain zones to proto.
func ZonesToProto(zz []models.IrrigationZone) []*pb.IrrigationZone {
	out := make([]*pb.IrrigationZone, len(zz))
	for i := range zz {
		out[i] = ZoneToProto(&zz[i])
	}
	return out
}

// ---------------------------------------------------------------------------
// Controller mappers
// ---------------------------------------------------------------------------

// ControllerToProto converts a domain WaterController to its proto representation.
func ControllerToProto(c *models.WaterController) *pb.WaterController {
	if c == nil {
		return nil
	}
	return &pb.WaterController{
		Id:                        c.UUID,
		TenantId:                  c.TenantID,
		ZoneId:                    c.ZoneID,
		FieldId:                   c.FieldID,
		FarmId:                    c.FarmID,
		Name:                      c.Name,
		Model:                     c.Model,
		FirmwareVersion:           c.FirmwareVersion,
		ControllerType:            ControllerTypeToProto(c.ControllerType),
		Protocol:                  ProtocolToProto(c.Protocol),
		Status:                    ControllerStatusToProto(c.Status),
		Endpoint:                  c.Endpoint,
		MaxFlowRateLitersPerHour:  c.MaxFlowRateLitersPerHour,
		LastHeartbeat:             timePtrToProto(c.LastHeartbeat),
		CreatedAt:                 timeToProto(c.CreatedAt),
		UpdatedAt:                 timePtrToProto(c.UpdatedAt),
	}
}

// ControllerFromProto converts a proto WaterController to the domain model.
func ControllerFromProto(p *pb.WaterController) *models.WaterController {
	if p == nil {
		return nil
	}
	return &models.WaterController{
		TenantID:                  p.TenantId,
		ZoneID:                    p.ZoneId,
		FieldID:                   p.FieldId,
		FarmID:                    p.FarmId,
		Name:                      p.Name,
		Model:                     p.Model,
		FirmwareVersion:           p.FirmwareVersion,
		ControllerType:            ControllerTypeFromProto(p.ControllerType),
		Protocol:                  ProtocolFromProto(p.Protocol),
		Status:                    ControllerStatusFromProto(p.Status),
		Endpoint:                  p.Endpoint,
		MaxFlowRateLitersPerHour:  p.MaxFlowRateLitersPerHour,
		LastHeartbeat:             protoToTimePtr(p.LastHeartbeat),
	}
}

// ControllersToProto converts a slice of domain controllers to proto.
func ControllersToProto(cc []models.WaterController) []*pb.WaterController {
	out := make([]*pb.WaterController, len(cc))
	for i := range cc {
		out[i] = ControllerToProto(&cc[i])
	}
	return out
}

// ---------------------------------------------------------------------------
// Event mappers
// ---------------------------------------------------------------------------

// EventToProto converts a domain IrrigationEvent to its proto representation.
func EventToProto(e *models.IrrigationEvent) *pb.IrrigationEvent {
	if e == nil {
		return nil
	}
	return &pb.IrrigationEvent{
		Id:                    e.UUID,
		TenantId:              e.TenantID,
		ScheduleId:            e.ScheduleID,
		ZoneId:                e.ZoneID,
		ControllerId:          e.ControllerID,
		Status:                IrrigationStatusToProto(e.Status),
		StartedAt:             timePtrToProto(e.StartedAt),
		EndedAt:               timePtrToProto(e.EndedAt),
		ActualDurationMinutes: e.ActualDurationMinutes,
		ActualWaterLiters:     e.ActualWaterLiters,
		SoilMoistureBeforePct: e.SoilMoistureBeforePct,
		SoilMoistureAfterPct:  e.SoilMoistureAfterPct,
		FailureReason:         e.FailureReason,
		CreatedAt:             timeToProto(e.CreatedAt),
	}
}

// EventsToProto converts a slice of domain events to proto.
func EventsToProto(ee []models.IrrigationEvent) []*pb.IrrigationEvent {
	out := make([]*pb.IrrigationEvent, len(ee))
	for i := range ee {
		out[i] = EventToProto(&ee[i])
	}
	return out
}

// ---------------------------------------------------------------------------
// Decision mappers
// ---------------------------------------------------------------------------

// DecisionToProto converts a domain IrrigationDecision to its proto representation.
func DecisionToProto(d *models.IrrigationDecision) *pb.IrrigationDecision {
	if d == nil {
		return nil
	}
	return &pb.IrrigationDecision{
		Id:         d.UUID,
		TenantId:   d.TenantID,
		ZoneId:     d.ZoneID,
		FieldId:    d.FieldID,
		ScheduleId: d.ScheduleID,
		Inputs: &pb.DecisionInputs{
			SoilMoisture:         d.Inputs.SoilMoisture,
			Temperature:          d.Inputs.Temperature,
			Humidity:             d.Inputs.Humidity,
			RainfallForecastMm:   d.Inputs.RainfallForecastMM,
			WindSpeed:            d.Inputs.WindSpeed,
			CropType:            d.Inputs.CropType,
			GrowthStage:         d.Inputs.GrowthStage,
			EvapotranspirationMm: d.Inputs.EvapotranspirationMM,
		},
		Output: &pb.DecisionOutput{
			ShouldIrrigate:      d.Output.ShouldIrrigate,
			WaterQuantityLiters: d.Output.WaterQuantityLiters,
			DurationMinutes:     d.Output.DurationMinutes,
			OptimalTime:         timePtrToProto(d.Output.OptimalTime),
			Reasoning:           d.Output.Reasoning,
			ConfidenceScore:     d.Output.ConfidenceScore,
		},
		DecidedAt: timeToProto(d.DecidedAt),
		Applied:   d.Applied,
		CreatedAt: timeToProto(d.CreatedAt),
	}
}

// DecisionInputsFromProto converts proto DecisionInputs to the domain model.
func DecisionInputsFromProto(p *pb.DecisionInputs) models.DecisionInputs {
	if p == nil {
		return models.DecisionInputs{}
	}
	return models.DecisionInputs{
		SoilMoisture:         p.SoilMoisture,
		Temperature:          p.Temperature,
		Humidity:             p.Humidity,
		RainfallForecastMM:   p.RainfallForecastMm,
		WindSpeed:            p.WindSpeed,
		CropType:            p.CropType,
		GrowthStage:         p.GrowthStage,
		EvapotranspirationMM: p.EvapotranspirationMm,
	}
}

// ---------------------------------------------------------------------------
// Water Usage mappers
// ---------------------------------------------------------------------------

// WaterUsageLogToProto converts a domain WaterUsageLog to its proto representation.
func WaterUsageLogToProto(w *models.WaterUsageLog) *pb.WaterUsageLog {
	if w == nil {
		return nil
	}
	return &pb.WaterUsageLog{
		Id:           w.UUID,
		TenantId:     w.TenantID,
		ZoneId:       w.ZoneID,
		ControllerId: w.ControllerID,
		WaterLiters:  w.WaterLiters,
		RecordedAt:   timeToProto(w.RecordedAt),
		PeriodStart:  timeToProto(w.PeriodStart),
		PeriodEnd:    timeToProto(w.PeriodEnd),
	}
}

// WaterUsageLogsToProto converts a slice of domain water usage logs to proto.
func WaterUsageLogsToProto(ww []models.WaterUsageLog) []*pb.WaterUsageLog {
	out := make([]*pb.WaterUsageLog, len(ww))
	for i := range ww {
		out[i] = WaterUsageLogToProto(&ww[i])
	}
	return out
}
