// Package grpc adapts the ConnectRPC surface onto device-service's use cases.
package grpc

import (
	"context"
	"strconv"

	"connectrpc.com/connect"
	"google.golang.org/protobuf/types/known/timestamppb"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"

	pb "p9e.in/samavaya/agriculture/device-service/api/v1"
	"p9e.in/samavaya/agriculture/device-service/internal/domain"
	"p9e.in/samavaya/agriculture/device-service/internal/ports/inbound"
)

// DeviceHandler serves the DeviceService RPCs.
type DeviceHandler struct {
	svc inbound.DeviceService
	log *p9log.Helper
}

// NewDeviceHandler creates a DeviceHandler.
func NewDeviceHandler(svc inbound.DeviceService, log p9log.Logger) *DeviceHandler {
	return &DeviceHandler{
		svc: svc,
		log: p9log.NewHelper(p9log.With(log, "component", "DeviceHandler")),
	}
}

func (h *DeviceHandler) ProvisionDevice(ctx context.Context, req *connect.Request[pb.ProvisionDeviceRequest]) (*connect.Response[pb.ProvisionDeviceResponse], error) {
	result, err := h.svc.ProvisionDevice(ctx, &domain.Device{
		Serial:           req.Msg.GetSerial(),
		Name:             req.Msg.GetName(),
		Kind:             kindFromProto(req.Msg.GetKind()),
		FarmID:           req.Msg.GetFarmId(),
		FieldID:          req.Msg.GetFieldId(),
		Fleet:            req.Msg.GetFleet(),
		HardwareRevision: req.Msg.GetHardwareRevision(),
		Latitude:         req.Msg.GetLatitude(),
		Longitude:        req.Msg.GetLongitude(),
	})
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return connect.NewResponse(&pb.ProvisionDeviceResponse{
		Device: deviceToProto(result.Device),
		// Returned once and never readable again; the service stores only a
		// hash of it.
		EnrolmentToken: result.EnrolmentToken,
	}), nil
}

func (h *DeviceHandler) GetDevice(ctx context.Context, req *connect.Request[pb.GetDeviceRequest]) (*connect.Response[pb.GetDeviceResponse], error) {
	device, err := h.svc.GetDevice(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.GetDeviceResponse{Device: deviceToProto(device)}), nil
}

func (h *DeviceHandler) ListDevices(ctx context.Context, req *connect.Request[pb.ListDevicesRequest]) (*connect.Response[pb.ListDevicesResponse], error) {
	limit, offset := page(req.Msg.GetPageSize(), req.Msg.GetPageToken())

	devices, total, err := h.svc.ListDevices(ctx, domain.ListDevicesParams{
		Fleet:   req.Msg.GetFleet(),
		FarmID:  req.Msg.GetFarmId(),
		FieldID: req.Msg.GetFieldId(),
		Kind:    kindFromProto(req.Msg.GetKind()),
		Status:  statusFromProto(req.Msg.GetStatus()),
		Limit:   limit,
		Offset:  offset,
	})
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	out := make([]*pb.Device, 0, len(devices))
	for i := range devices {
		out = append(out, deviceToProto(&devices[i]))
	}

	return connect.NewResponse(&pb.ListDevicesResponse{
		Devices:       out,
		NextPageToken: nextToken(offset, limit, total),
		TotalCount:    int32(total),
	}), nil
}

func (h *DeviceHandler) RecordHeartbeats(ctx context.Context, req *connect.Request[pb.RecordHeartbeatsRequest]) (*connect.Response[pb.RecordHeartbeatsResponse], error) {
	beats := make([]domain.Heartbeat, 0, len(req.Msg.GetHeartbeats()))
	for _, b := range req.Msg.GetHeartbeats() {
		h := domain.Heartbeat{
			DeviceID:        b.GetDeviceId(),
			FirmwareVersion: b.GetFirmwareVersion(),
			BatteryPercent:  b.GetBatteryPercent(),
			SignalDBM:       int(b.GetSignalDbm()),
			Fault:           b.GetFault(),
		}
		if ts := b.GetRecordedAt(); ts != nil {
			h.RecordedAt = ts.AsTime()
		}
		beats = append(beats, h)
	}

	result, err := h.svc.RecordHeartbeats(ctx, beats)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return connect.NewResponse(&pb.RecordHeartbeatsResponse{
		Recorded: int32(result.Recorded),
		Rejected: result.Rejected,
	}), nil
}

func (h *DeviceHandler) RetireDevice(ctx context.Context, req *connect.Request[pb.RetireDeviceRequest]) (*connect.Response[pb.RetireDeviceResponse], error) {
	device, err := h.svc.RetireDevice(ctx, req.Msg.GetId(), req.Msg.GetReason())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.RetireDeviceResponse{Device: deviceToProto(device)}), nil
}

func (h *DeviceHandler) GetFleetHealth(ctx context.Context, req *connect.Request[pb.GetFleetHealthRequest]) (*connect.Response[pb.GetFleetHealthResponse], error) {
	health, err := h.svc.GetFleetHealth(ctx, req.Msg.GetFleet())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.GetFleetHealthResponse{
		Health: &pb.FleetHealth{
			Fleet:       health.Fleet,
			Total:       int32(health.Total),
			Online:      int32(health.Online),
			Offline:     int32(health.Offline),
			Degraded:    int32(health.Degraded),
			Provisioned: int32(health.Provisioned),
			LowBattery:  int32(health.LowBattery),
			ComputedAt:  timestamppb.New(health.ComputedAt),
		},
	}), nil
}

func (h *DeviceHandler) CreateRollout(ctx context.Context, req *connect.Request[pb.CreateRolloutRequest]) (*connect.Response[pb.CreateRolloutResponse], error) {
	rollout, err := h.svc.CreateRollout(ctx, &domain.FirmwareRollout{
		Fleet:            req.Msg.GetFleet(),
		Kind:             kindFromProto(req.Msg.GetKind()),
		Version:          req.Msg.GetVersion(),
		ArtifactURL:      req.Msg.GetArtifactUrl(),
		ArtifactSHA256:   req.Msg.GetArtifactSha256(),
		StagePercent:     int(req.Msg.GetStagePercent()),
		FailureThreshold: req.Msg.GetFailureThreshold(),
	})
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.CreateRolloutResponse{Rollout: rolloutToProto(rollout)}), nil
}

func (h *DeviceHandler) AdvanceRollout(ctx context.Context, req *connect.Request[pb.AdvanceRolloutRequest]) (*connect.Response[pb.AdvanceRolloutResponse], error) {
	rollout, err := h.svc.AdvanceRollout(ctx, req.Msg.GetId(), int(req.Msg.GetStagePercent()))
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.AdvanceRolloutResponse{Rollout: rolloutToProto(rollout)}), nil
}

func (h *DeviceHandler) ReportUpdate(ctx context.Context, req *connect.Request[pb.ReportUpdateRequest]) (*connect.Response[pb.ReportUpdateResponse], error) {
	update, rollout, err := h.svc.ReportUpdate(ctx, &domain.DeviceUpdate{
		DeviceID:  req.Msg.GetDeviceId(),
		RolloutID: req.Msg.GetRolloutId(),
		State:     updateStateFromProto(req.Msg.GetState()),
		Detail:    req.Msg.GetDetail(),
	})
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	// The rollout goes back with the update, so a device that just halted one
	// learns that from its own response rather than from a later poll.
	return connect.NewResponse(&pb.ReportUpdateResponse{
		Update: &pb.DeviceUpdate{
			DeviceId:  update.DeviceID,
			RolloutId: update.RolloutID,
			State:     updateStateToProto(update.State),
			Detail:    update.Detail,
			UpdatedAt: timestamppb.New(update.UpdatedAt),
		},
		Rollout: rolloutToProto(rollout),
	}), nil
}

func (h *DeviceHandler) ListRollouts(ctx context.Context, req *connect.Request[pb.ListRolloutsRequest]) (*connect.Response[pb.ListRolloutsResponse], error) {
	limit, offset := page(req.Msg.GetPageSize(), req.Msg.GetPageToken())

	rollouts, total, err := h.svc.ListRollouts(ctx, domain.ListRolloutsParams{
		Fleet:  req.Msg.GetFleet(),
		Limit:  limit,
		Offset: offset,
	})
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	out := make([]*pb.FirmwareRollout, 0, len(rollouts))
	for i := range rollouts {
		out = append(out, rolloutToProto(&rollouts[i]))
	}

	return connect.NewResponse(&pb.ListRolloutsResponse{
		Rollouts:      out,
		NextPageToken: nextToken(offset, limit, total),
		TotalCount:    int32(total),
	}), nil
}

// ─────────────────────────────────────────────────────────────────────────────
// Mapping
// ─────────────────────────────────────────────────────────────────────────────

func page(pageSize int32, pageToken string) (limit, offset int) {
	limit = int(pageSize)
	if limit <= 0 {
		limit = 50
	}
	if limit > 500 {
		limit = 500
	}
	if pageToken != "" {
		if parsed, err := strconv.Atoi(pageToken); err == nil && parsed > 0 {
			offset = parsed
		}
	}
	return limit, offset
}

func nextToken(offset, limit int, total int64) string {
	next := offset + limit
	if int64(next) >= total {
		return ""
	}
	return strconv.Itoa(next)
}

var kindNames = map[pb.DeviceKind]domain.DeviceKind{
	pb.DeviceKind_DEVICE_KIND_SOIL_PROBE:         domain.KindSoilProbe,
	pb.DeviceKind_DEVICE_KIND_WEATHER_STATION:    domain.KindWeatherStation,
	pb.DeviceKind_DEVICE_KIND_IRRIGATION_VALVE:   domain.KindIrrigationValve,
	pb.DeviceKind_DEVICE_KIND_FLOW_METER:         domain.KindFlowMeter,
	pb.DeviceKind_DEVICE_KIND_GATEWAY:            domain.KindGateway,
	pb.DeviceKind_DEVICE_KIND_TRACTOR_TELEMATICS: domain.KindTractorTelematics,
}

func kindFromProto(k pb.DeviceKind) domain.DeviceKind { return kindNames[k] }

func kindToProto(k domain.DeviceKind) pb.DeviceKind {
	for proto, name := range kindNames {
		if name == k {
			return proto
		}
	}
	return pb.DeviceKind_DEVICE_KIND_UNSPECIFIED
}

var statusNames = map[pb.DeviceStatus]domain.DeviceStatus{
	pb.DeviceStatus_DEVICE_STATUS_PROVISIONED: domain.StatusProvisioned,
	pb.DeviceStatus_DEVICE_STATUS_ONLINE:      domain.StatusOnline,
	pb.DeviceStatus_DEVICE_STATUS_OFFLINE:     domain.StatusOffline,
	pb.DeviceStatus_DEVICE_STATUS_DEGRADED:    domain.StatusDegraded,
	pb.DeviceStatus_DEVICE_STATUS_RETIRED:     domain.StatusRetired,
}

func statusFromProto(s pb.DeviceStatus) domain.DeviceStatus { return statusNames[s] }

func statusToProto(s domain.DeviceStatus) pb.DeviceStatus {
	for proto, name := range statusNames {
		if name == s {
			return proto
		}
	}
	return pb.DeviceStatus_DEVICE_STATUS_UNSPECIFIED
}

var updateStateNames = map[pb.UpdateState]domain.UpdateState{
	pb.UpdateState_UPDATE_STATE_OFFERED:     domain.UpdateOffered,
	pb.UpdateState_UPDATE_STATE_DOWNLOADING: domain.UpdateDownloading,
	pb.UpdateState_UPDATE_STATE_INSTALLING:  domain.UpdateInstalling,
	pb.UpdateState_UPDATE_STATE_SUCCEEDED:   domain.UpdateSucceeded,
	pb.UpdateState_UPDATE_STATE_FAILED:      domain.UpdateFailed,
	pb.UpdateState_UPDATE_STATE_ROLLED_BACK: domain.UpdateRolledBack,
}

func updateStateFromProto(s pb.UpdateState) domain.UpdateState { return updateStateNames[s] }

func updateStateToProto(s domain.UpdateState) pb.UpdateState {
	for proto, name := range updateStateNames {
		if name == s {
			return proto
		}
	}
	return pb.UpdateState_UPDATE_STATE_UNSPECIFIED
}

var rolloutStateNames = map[pb.RolloutState]domain.RolloutState{
	pb.RolloutState_ROLLOUT_STATE_PENDING:     domain.RolloutPending,
	pb.RolloutState_ROLLOUT_STATE_IN_PROGRESS: domain.RolloutInProgress,
	pb.RolloutState_ROLLOUT_STATE_PAUSED:      domain.RolloutPaused,
	pb.RolloutState_ROLLOUT_STATE_COMPLETED:   domain.RolloutCompleted,
	pb.RolloutState_ROLLOUT_STATE_HALTED:      domain.RolloutHalted,
}

func rolloutStateToProto(s domain.RolloutState) pb.RolloutState {
	for proto, name := range rolloutStateNames {
		if name == s {
			return proto
		}
	}
	return pb.RolloutState_ROLLOUT_STATE_UNSPECIFIED
}

func deviceToProto(d *domain.Device) *pb.Device {
	out := &pb.Device{
		Id:               d.ID,
		Serial:           d.Serial,
		Name:             d.Name,
		Kind:             kindToProto(d.Kind),
		Status:           statusToProto(d.Status),
		FarmId:           d.FarmID,
		FieldId:          d.FieldID,
		Fleet:            d.Fleet,
		FirmwareVersion:  d.FirmwareVersion,
		HardwareRevision: d.HardwareRevision,
		Latitude:         d.Latitude,
		Longitude:        d.Longitude,
		BatteryPercent:   d.BatteryPercent,
		SignalDbm:        int32(d.SignalDBM),
		Fault:            d.Fault,
	}
	if !d.ProvisionedAt.IsZero() {
		out.ProvisionedAt = timestamppb.New(d.ProvisionedAt)
	}
	if d.LastSeenAt != nil {
		out.LastSeenAt = timestamppb.New(*d.LastSeenAt)
	}
	// The enrolment token hash is deliberately not mapped. It is a credential
	// digest, and nothing outside this service has any use for it.
	return out
}

func rolloutToProto(r *domain.FirmwareRollout) *pb.FirmwareRollout {
	out := &pb.FirmwareRollout{
		Id:               r.ID,
		Fleet:            r.Fleet,
		Kind:             kindToProto(r.Kind),
		Version:          r.Version,
		ArtifactUrl:      r.ArtifactURL,
		ArtifactSha256:   r.ArtifactSHA256,
		State:            rolloutStateToProto(r.State),
		StagePercent:     int32(r.StagePercent),
		FailureThreshold: r.FailureThreshold,
		Offered:          int32(r.Offered),
		Succeeded:        int32(r.Succeeded),
		Failed:           int32(r.Failed),
		HaltedReason:     r.HaltedReason,
	}
	if !r.CreatedAt.IsZero() {
		out.CreatedAt = timestamppb.New(r.CreatedAt)
	}
	return out
}
