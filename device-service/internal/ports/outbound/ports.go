// Package outbound defines the secondary ports for device-service.
package outbound

import (
	"context"

	"p9e.in/samavaya/agriculture/device-service/internal/domain"
)

// DeviceRepository is the secondary port for device persistence.
type DeviceRepository interface {
	CreateDevice(ctx context.Context, d *domain.Device) (*domain.Device, error)
	GetDevice(ctx context.Context, id, tenantID string) (*domain.Device, error)
	GetDeviceBySerial(ctx context.Context, serial, tenantID string) (*domain.Device, error)
	ListDevices(ctx context.Context, params domain.ListDevicesParams) ([]domain.Device, int64, error)
	UpdateDeviceHealth(ctx context.Context, d *domain.Device) error
	RetireDevice(ctx context.Context, id, tenantID, reason string) (*domain.Device, error)

	// FleetDevices returns every live device in a fleet, for the health
	// summary. Unpaginated on purpose: a summary of the first fifty devices
	// is not a summary of the fleet, and a fleet is thousands, not millions.
	FleetDevices(ctx context.Context, tenantID, fleet string) ([]domain.Device, error)

	CreateRollout(ctx context.Context, r *domain.FirmwareRollout) (*domain.FirmwareRollout, error)
	GetRollout(ctx context.Context, id, tenantID string) (*domain.FirmwareRollout, error)
	SaveRollout(ctx context.Context, r *domain.FirmwareRollout) error
	ListRollouts(ctx context.Context, params domain.ListRolloutsParams) ([]domain.FirmwareRollout, int64, error)

	UpsertDeviceUpdate(ctx context.Context, u *domain.DeviceUpdate) error
}

// EventPublisher is the secondary port for emitting domain events.
type EventPublisher interface {
	Publish(ctx context.Context, topic, key string, payload []byte) error
}
