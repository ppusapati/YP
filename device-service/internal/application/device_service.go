// Package application holds device-service's use cases.
package application

import (
	"context"
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"strings"
	"time"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	"p9e.in/samavaya/agriculture/device-service/internal/domain"
	"p9e.in/samavaya/agriculture/device-service/internal/ports/inbound"
	"p9e.in/samavaya/agriculture/device-service/internal/ports/outbound"
)

// Topics this service publishes on.
const (
	topicRolloutHalted = "yp.device.rollout.halted"
	topicDeviceRetired = "yp.device.retired"
)

type deviceService struct {
	repo outbound.DeviceRepository
	pub  outbound.EventPublisher
	log  *p9log.Helper
	now  func() time.Time
}

// NewDeviceService creates the device service.
func NewDeviceService(
	repo outbound.DeviceRepository,
	pub outbound.EventPublisher,
	log p9log.Logger,
) inbound.DeviceService {
	return &deviceService{
		repo: repo,
		pub:  pub,
		log:  p9log.NewHelper(p9log.With(log, "component", "DeviceService")),
		now:  time.Now,
	}
}

// ProvisionDevice enrols a new device and issues its credential.
//
// The token is generated here, returned once, and stored only as a SHA-256
// hash. A fleet database that leaks should not hand somebody the credentials
// to every irrigation valve in it — and unlike a user password, nobody can
// rotate a device's token by logging in, so the blast radius of storing it in
// the clear is the life of the hardware.
func (s *deviceService) ProvisionDevice(ctx context.Context, d *domain.Device) (inbound.ProvisionResult, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return inbound.ProvisionResult{}, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}

	if err := d.Validate(); err != nil {
		return inbound.ProvisionResult{}, errors.BadRequest("INVALID_DEVICE", err.Error())
	}

	// A serial that is already enrolled is almost always a technician
	// re-scanning a device rather than a new one; saying so is more useful
	// than a unique-constraint error from the database.
	if existing, err := s.repo.GetDeviceBySerial(ctx, d.Serial, tenantID); err == nil && existing != nil {
		return inbound.ProvisionResult{}, errors.Conflict(
			"DEVICE_ALREADY_ENROLLED",
			fmt.Sprintf("serial %s is already enrolled as %s", d.Serial, existing.ID),
		)
	}

	token, hash, err := newEnrolmentToken()
	if err != nil {
		s.log.Errorw("msg", "could not generate an enrolment token", "error", err)
		return inbound.ProvisionResult{}, errors.InternalServer("TOKEN_FAILED", "an internal error occurred")
	}

	d.ID = ulid.NewString()
	d.TenantID = tenantID
	d.ProvisionedAt = s.now()
	d.EnrolmentTokenHash = hash
	if d.Fleet == "" {
		d.Fleet = "default"
	}

	created, err := s.repo.CreateDevice(ctx, d)
	if err != nil {
		return inbound.ProvisionResult{}, err
	}

	return inbound.ProvisionResult{Device: created, EnrolmentToken: token}, nil
}

// newEnrolmentToken returns a credential and the hash to store for it.
func newEnrolmentToken() (token, hash string, err error) {
	raw := make([]byte, 32)
	if _, err := rand.Read(raw); err != nil {
		return "", "", err
	}
	token = base64.RawURLEncoding.EncodeToString(raw)
	sum := sha256.Sum256([]byte(token))
	return token, hex.EncodeToString(sum[:]), nil
}

func (s *deviceService) GetDevice(ctx context.Context, id string) (*domain.Device, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	if strings.TrimSpace(id) == "" {
		return nil, errors.BadRequest("MISSING_ID", "id is required")
	}

	device, err := s.repo.GetDevice(ctx, id, tenantID)
	if err != nil {
		return nil, err
	}
	// Status is derived on read, so a device that stopped reporting shows as
	// offline without anything having had to write that.
	device.Status = device.StatusAt(s.now())
	return device, nil
}

func (s *deviceService) ListDevices(ctx context.Context, params domain.ListDevicesParams) ([]domain.Device, int64, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	params.TenantID = tenantID
	params.Limit = clampLimit(params.Limit)

	devices, total, err := s.repo.ListDevices(ctx, params)
	if err != nil {
		return nil, 0, err
	}

	now := s.now()
	for i := range devices {
		devices[i].Status = devices[i].StatusAt(now)
	}

	// Status is derived, so it cannot be a SQL filter without duplicating the
	// rule in two places that will drift. Filtering here keeps one definition;
	// the total is corrected to match so the count and the page agree.
	if params.Status != "" {
		filtered := devices[:0]
		for _, d := range devices {
			if d.Status == params.Status {
				filtered = append(filtered, d)
			}
		}
		devices = filtered
		total = int64(len(devices))
	}

	return devices, total, nil
}

// RecordHeartbeats folds a batch of health reports into their devices.
//
// One bad heartbeat does not sink the batch: a gateway uploads hundreds at
// once after an outage, and refusing the lot because one has a broken clock
// would leave the whole fleet looking offline.
func (s *deviceService) RecordHeartbeats(ctx context.Context, beats []domain.Heartbeat) (inbound.HeartbeatResult, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return inbound.HeartbeatResult{}, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	if len(beats) == 0 {
		return inbound.HeartbeatResult{}, errors.BadRequest("NO_HEARTBEATS", "at least one heartbeat is required")
	}

	now := s.now()
	var result inbound.HeartbeatResult

	// Grouped by device so a backlog of fifty readings for one device is one
	// load and one save rather than fifty of each.
	byDevice := make(map[string][]domain.Heartbeat)
	for i, h := range beats {
		h.TenantID = tenantID
		if err := h.Validate(now); err != nil {
			result.Rejected = append(result.Rejected,
				fmt.Sprintf("heartbeats[%d] device %s: %v", i, h.DeviceID, err))
			continue
		}
		byDevice[h.DeviceID] = append(byDevice[h.DeviceID], h)
	}

	for deviceID, deviceBeats := range byDevice {
		device, err := s.repo.GetDevice(ctx, deviceID, tenantID)
		if err != nil {
			result.Rejected = append(result.Rejected,
				fmt.Sprintf("device %s: not enrolled", deviceID))
			continue
		}
		if device.RetiredAt != nil {
			// A retired device still transmitting is worth knowing about, but
			// it must not come back into the fleet view by itself.
			result.Rejected = append(result.Rejected,
				fmt.Sprintf("device %s: retired on %s",
					deviceID, device.RetiredAt.Format("2006-01-02")))
			continue
		}

		applied := false
		for _, h := range deviceBeats {
			if device.Apply(h) {
				applied = true
			}
		}
		if !applied {
			// Every reading was older than what we already had. Not an error —
			// a replayed backlog — and not a write either.
			continue
		}

		if err := s.repo.UpdateDeviceHealth(ctx, device); err != nil {
			result.Rejected = append(result.Rejected,
				fmt.Sprintf("device %s: %v", deviceID, err))
			continue
		}
		result.Recorded += len(deviceBeats)
	}

	return result, nil
}

func (s *deviceService) RetireDevice(ctx context.Context, id, reason string) (*domain.Device, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	if strings.TrimSpace(id) == "" {
		return nil, errors.BadRequest("MISSING_ID", "id is required")
	}

	device, err := s.repo.RetireDevice(ctx, id, tenantID, reason)
	if err != nil {
		return nil, err
	}

	s.publish(ctx, topicDeviceRetired, device.ID, map[string]any{
		"tenant_id": tenantID,
		"device_id": device.ID,
		"serial":    device.Serial,
		"fleet":     device.Fleet,
		"reason":    reason,
	})
	return device, nil
}

func (s *deviceService) GetFleetHealth(ctx context.Context, fleet string) (domain.FleetHealth, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return domain.FleetHealth{}, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	if strings.TrimSpace(fleet) == "" {
		return domain.FleetHealth{}, errors.BadRequest("MISSING_FLEET", "fleet is required")
	}

	devices, err := s.repo.FleetDevices(ctx, tenantID, fleet)
	if err != nil {
		return domain.FleetHealth{}, err
	}
	return domain.SummariseFleet(fleet, devices, s.now()), nil
}

func (s *deviceService) CreateRollout(ctx context.Context, r *domain.FirmwareRollout) (*domain.FirmwareRollout, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}

	if r.StagePercent == 0 {
		// A rollout that starts at the whole fleet is not staged, and staging
		// is the point: bad firmware on every device in a region at once is a
		// season lost and a visit to each one.
		r.StagePercent = 10
	}
	if err := r.Validate(); err != nil {
		return nil, errors.BadRequest("INVALID_ROLLOUT", err.Error())
	}

	r.ID = ulid.NewString()
	r.TenantID = tenantID
	r.State = domain.RolloutPending
	r.CreatedAt = s.now()
	if user := p9context.UserID(ctx); user != "" {
		r.CreatedBy = user
	} else {
		r.CreatedBy = "system"
	}

	return s.repo.CreateRollout(ctx, r)
}

func (s *deviceService) AdvanceRollout(ctx context.Context, id string, stagePercent int) (*domain.FirmwareRollout, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}

	rollout, err := s.repo.GetRollout(ctx, id, tenantID)
	if err != nil {
		return nil, err
	}
	if err := rollout.Advance(stagePercent); err != nil {
		return nil, errors.BadRequest("ROLLOUT_NOT_ADVANCED", err.Error())
	}
	if err := s.repo.SaveRollout(ctx, rollout); err != nil {
		return nil, err
	}
	return rollout, nil
}

// ReportUpdate records one device's progress and halts the rollout if too many
// devices are failing.
func (s *deviceService) ReportUpdate(ctx context.Context, u *domain.DeviceUpdate) (*domain.DeviceUpdate, *domain.FirmwareRollout, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, nil, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	if strings.TrimSpace(u.DeviceID) == "" || strings.TrimSpace(u.RolloutID) == "" {
		return nil, nil, errors.BadRequest("MISSING_IDS", "device_id and rollout_id are required")
	}

	rollout, err := s.repo.GetRollout(ctx, u.RolloutID, tenantID)
	if err != nil {
		return nil, nil, err
	}

	u.TenantID = tenantID
	u.UpdatedAt = s.now()
	if err := s.repo.UpsertDeviceUpdate(ctx, u); err != nil {
		return nil, nil, err
	}

	halted := rollout.RecordUpdate(u.State, s.now())
	if err := s.repo.SaveRollout(ctx, rollout); err != nil {
		return nil, nil, err
	}

	if halted {
		// Published as well as stored: a halted rollout needs somebody to look
		// at it, and a state change nobody is told about is one that gets
		// noticed when the next stage does not happen.
		s.log.Warnw("msg", "firmware rollout halted",
			"rollout", rollout.ID, "reason", rollout.HaltedReason)
		s.publish(ctx, topicRolloutHalted, rollout.ID, map[string]any{
			"tenant_id":  tenantID,
			"rollout_id": rollout.ID,
			"fleet":      rollout.Fleet,
			"version":    rollout.Version,
			"reason":     rollout.HaltedReason,
			"succeeded":  rollout.Succeeded,
			"failed":     rollout.Failed,
		})
	}

	return u, rollout, nil
}

func (s *deviceService) ListRollouts(ctx context.Context, params domain.ListRolloutsParams) ([]domain.FirmwareRollout, int64, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	params.TenantID = tenantID
	params.Limit = clampLimit(params.Limit)
	return s.repo.ListRollouts(ctx, params)
}

func (s *deviceService) publish(ctx context.Context, topic, key string, payload map[string]any) {
	if s.pub == nil {
		return
	}
	body, err := json.Marshal(payload)
	if err != nil {
		s.log.Errorw("msg", "could not encode event", "topic", topic, "error", err)
		return
	}
	if err := s.pub.Publish(ctx, topic, key, body); err != nil {
		s.log.Warnw("msg", "could not publish event", "topic", topic, "error", err)
	}
}

func clampLimit(limit int) int {
	switch {
	case limit <= 0:
		return 50
	case limit > 500:
		return 500
	default:
		return limit
	}
}
