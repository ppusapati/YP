// Package inbound defines the primary ports for device-service.
package inbound

import (
	"context"

	"p9e.in/samavaya/agriculture/device-service/internal/domain"
)

// ProvisionResult carries the device and the credential it enrols with.
//
// The token is returned once and never stored in the clear, so a caller that
// loses it has to re-provision — which is the right trade for a credential
// that opens an irrigation valve.
type ProvisionResult struct {
	Device         *domain.Device
	EnrolmentToken string
}

// HeartbeatResult reports what a batch of heartbeats did.
type HeartbeatResult struct {
	Recorded int
	Rejected []string
}

// DeviceService is the primary port for device operations.
type DeviceService interface {
	ProvisionDevice(ctx context.Context, d *domain.Device) (ProvisionResult, error)
	GetDevice(ctx context.Context, id string) (*domain.Device, error)
	ListDevices(ctx context.Context, params domain.ListDevicesParams) ([]domain.Device, int64, error)
	RecordHeartbeats(ctx context.Context, beats []domain.Heartbeat) (HeartbeatResult, error)
	RetireDevice(ctx context.Context, id, reason string) (*domain.Device, error)
	GetFleetHealth(ctx context.Context, fleet string) (domain.FleetHealth, error)

	CreateRollout(ctx context.Context, r *domain.FirmwareRollout) (*domain.FirmwareRollout, error)
	AdvanceRollout(ctx context.Context, id string, stagePercent int) (*domain.FirmwareRollout, error)
	ReportUpdate(ctx context.Context, u *domain.DeviceUpdate) (*domain.DeviceUpdate, *domain.FirmwareRollout, error)
	ListRollouts(ctx context.Context, params domain.ListRolloutsParams) ([]domain.FirmwareRollout, int64, error)
}
