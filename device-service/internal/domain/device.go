// Package domain holds device-service's entities and fleet logic.
package domain

import (
	"errors"
	"fmt"
	"math"
	"strings"
	"time"
)

// Errors the domain returns.
var (
	ErrMissingSerial     = errors.New("device: serial is required")
	ErrMissingDevice     = errors.New("device: device id is required")
	ErrUnknownKind       = errors.New("device: kind is required")
	ErrRetired           = errors.New("device: device is retired")
	ErrHeartbeatFuture   = errors.New("device: heartbeat is dated in the future")
	ErrHeartbeatTooOld   = errors.New("device: heartbeat is older than the fleet view keeps")
	ErrBatteryOutOfRange = errors.New("device: battery percentage is outside 0-100")
	ErrMissingVersion    = errors.New("device: firmware version is required")
	ErrMissingArtifact   = errors.New("device: firmware artifact URL and checksum are required")
	ErrStageOutOfRange   = errors.New("device: stage percent must be between 1 and 100")
	ErrStageWentBackward = errors.New("device: a rollout stage cannot be reduced")
	ErrRolloutNotRunning = errors.New("device: rollout is not accepting updates")
)

// DeviceStatus is what the fleet view shows for one device.
type DeviceStatus string

const (
	// StatusProvisioned means enrolled but never heard from. Distinct from
	// offline, which means it worked and stopped: one is an installation that
	// was never finished, the other is a device that needs a visit.
	StatusProvisioned DeviceStatus = "PROVISIONED"
	StatusOnline      DeviceStatus = "ONLINE"
	StatusOffline     DeviceStatus = "OFFLINE"
	StatusDegraded    DeviceStatus = "DEGRADED"
	StatusRetired     DeviceStatus = "RETIRED"
)

// DeviceKind is what the hardware does.
type DeviceKind string

const (
	KindSoilProbe         DeviceKind = "SOIL_PROBE"
	KindWeatherStation    DeviceKind = "WEATHER_STATION"
	KindIrrigationValve   DeviceKind = "IRRIGATION_VALVE"
	KindFlowMeter         DeviceKind = "FLOW_METER"
	KindGateway           DeviceKind = "GATEWAY"
	KindTractorTelematics DeviceKind = "TRACTOR_TELEMATICS"
)

// Device is one piece of field hardware.
type Device struct {
	ID       string `json:"id" db:"id"`
	TenantID string `json:"tenant_id" db:"tenant_id"`

	Serial string       `json:"serial" db:"serial"`
	Name   string       `json:"name" db:"name"`
	Kind   DeviceKind   `json:"kind" db:"kind"`
	Status DeviceStatus `json:"status" db:"status"`

	FarmID  string `json:"farm_id" db:"farm_id"`
	FieldID string `json:"field_id" db:"field_id"`
	Fleet   string `json:"fleet" db:"fleet"`

	FirmwareVersion  string `json:"firmware_version" db:"firmware_version"`
	HardwareRevision string `json:"hardware_revision" db:"hardware_revision"`

	Latitude  float64 `json:"latitude" db:"latitude"`
	Longitude float64 `json:"longitude" db:"longitude"`

	ProvisionedAt  time.Time  `json:"provisioned_at" db:"provisioned_at"`
	LastSeenAt     *time.Time `json:"last_seen_at" db:"last_seen_at"`
	BatteryPercent float64    `json:"battery_percent" db:"battery_percent"`
	SignalDBM      int        `json:"signal_dbm" db:"signal_dbm"`
	Fault          string     `json:"fault" db:"fault"`

	// EnrolmentTokenHash is what a device's credential is checked against.
	// The token itself is returned once at provisioning and never stored, the
	// same way a password is — a fleet database that leaks should not hand
	// somebody the keys to every valve in it.
	EnrolmentTokenHash string `json:"-" db:"enrolment_token_hash"`

	RetiredAt     *time.Time `json:"retired_at" db:"retired_at"`
	RetiredReason string     `json:"retired_reason" db:"retired_reason"`
}

// Validate checks a device can be provisioned.
func (d *Device) Validate() error {
	if strings.TrimSpace(d.Serial) == "" {
		return ErrMissingSerial
	}
	if d.Kind == "" {
		return ErrUnknownKind
	}
	if math.Abs(d.Latitude) > 90 || math.Abs(d.Longitude) > 180 {
		return fmt.Errorf("device: position %.4f,%.4f is not on Earth", d.Latitude, d.Longitude)
	}
	return nil
}

// OfflineAfter is how long without a heartbeat before a device counts offline.
//
// Six hours. Field hardware on a solar panel and a cellular uplink misses
// hours at a time in ordinary weather; a tighter window fills the fleet view
// with devices that are working, and an operator who sees fifty false alarms
// stops reading it.
const OfflineAfter = 6 * time.Hour

// LowBatteryPercent is the threshold for flagging a device for a visit.
//
// 20%. Low enough not to cry wolf, high enough that a technician has time to
// reach a remote field before the device stops reporting — which is the whole
// point of knowing.
const LowBatteryPercent = 20.0

// MaxHeartbeatAge is how old a heartbeat may be and still move a device's state.
//
// A gateway buffers while its uplink is down and floods when it returns, so
// the backlog is normal and must be accepted. Beyond a day, though, a
// heartbeat says where a device was yesterday, and letting it set "online"
// would mark a dead device healthy.
const MaxHeartbeatAge = 24 * time.Hour

// StatusAt derives a device's status from its last heartbeat.
//
// Derived rather than stored, because a stored status is only as fresh as the
// last thing that wrote it: a device that stops reporting never writes
// "offline" — that is precisely what it has stopped doing.
func (d *Device) StatusAt(now time.Time) DeviceStatus {
	if d.RetiredAt != nil {
		return StatusRetired
	}
	if d.LastSeenAt == nil {
		return StatusProvisioned
	}
	if now.Sub(*d.LastSeenAt) > OfflineAfter {
		return StatusOffline
	}
	if d.Fault != "" {
		return StatusDegraded
	}
	return StatusOnline
}

// NeedsVisit reports whether somebody has to go out to this device.
func (d *Device) NeedsVisit(now time.Time) bool {
	switch d.StatusAt(now) {
	case StatusOffline, StatusDegraded:
		return true
	case StatusOnline:
		return d.BatteryPercent > 0 && d.BatteryPercent < LowBatteryPercent
	default:
		return false
	}
}

// Heartbeat is one health report from a device.
type Heartbeat struct {
	DeviceID        string    `json:"device_id"`
	TenantID        string    `json:"tenant_id"`
	FirmwareVersion string    `json:"firmware_version"`
	BatteryPercent  float64   `json:"battery_percent"`
	SignalDBM       int       `json:"signal_dbm"`
	Fault           string    `json:"fault"`
	RecordedAt      time.Time `json:"recorded_at"`
}

// Validate checks a heartbeat can be applied.
func (h *Heartbeat) Validate(now time.Time) error {
	if strings.TrimSpace(h.DeviceID) == "" {
		return ErrMissingDevice
	}
	// Clock drift on field hardware is routine, so a little slack; a heartbeat
	// an hour ahead is a broken clock rather than a future reading, and
	// accepting it would keep a dead device "online" for that hour.
	if h.RecordedAt.After(now.Add(5 * time.Minute)) {
		return ErrHeartbeatFuture
	}
	if h.RecordedAt.IsZero() || now.Sub(h.RecordedAt) > MaxHeartbeatAge {
		return ErrHeartbeatTooOld
	}
	if h.BatteryPercent < 0 || h.BatteryPercent > 100 {
		return ErrBatteryOutOfRange
	}
	return nil
}

// Apply folds a heartbeat into a device.
//
// Out-of-order heartbeats are normal: a gateway's backlog arrives in whatever
// order it was queued. Only a newer one moves the device's state, so a replayed
// old reading cannot roll the battery level back up or clear a fault that was
// raised afterwards.
func (d *Device) Apply(h Heartbeat) bool {
	if d.LastSeenAt != nil && !h.RecordedAt.After(*d.LastSeenAt) {
		return false
	}
	at := h.RecordedAt
	d.LastSeenAt = &at
	d.BatteryPercent = h.BatteryPercent
	d.SignalDBM = h.SignalDBM
	d.Fault = h.Fault
	if h.FirmwareVersion != "" {
		d.FirmwareVersion = h.FirmwareVersion
	}
	return true
}

// FleetHealth summarises a fleet.
type FleetHealth struct {
	Fleet string `json:"fleet"`

	Total       int `json:"total"`
	Online      int `json:"online"`
	Offline     int `json:"offline"`
	Degraded    int `json:"degraded"`
	Provisioned int `json:"provisioned"`
	LowBattery  int `json:"low_battery"`

	ComputedAt time.Time `json:"computed_at"`
}

// SummariseFleet counts a fleet's devices by derived status.
//
// Retired devices are excluded from every count including the total. A fleet
// of 500 with 200 retired is a fleet of 300, and reporting 60% online when the
// live devices are all reporting would send somebody looking for a fault that
// is not there.
func SummariseFleet(fleet string, devices []Device, now time.Time) FleetHealth {
	health := FleetHealth{Fleet: fleet, ComputedAt: now}

	for i := range devices {
		d := &devices[i]
		status := d.StatusAt(now)
		if status == StatusRetired {
			continue
		}

		health.Total++
		switch status {
		case StatusOnline:
			health.Online++
		case StatusOffline:
			health.Offline++
		case StatusDegraded:
			health.Degraded++
		case StatusProvisioned:
			health.Provisioned++
		}

		// Counted for any device that has reported a level, including a
		// degraded one: a flat battery is often why it is degraded.
		if status != StatusProvisioned && d.BatteryPercent > 0 && d.BatteryPercent < LowBatteryPercent {
			health.LowBattery++
		}
	}
	return health
}

// RolloutState is where a firmware rollout has got to.
type RolloutState string

const (
	RolloutPending    RolloutState = "PENDING"
	RolloutInProgress RolloutState = "IN_PROGRESS"
	RolloutPaused     RolloutState = "PAUSED"
	RolloutCompleted  RolloutState = "COMPLETED"
	RolloutHalted     RolloutState = "HALTED"
)

// UpdateState is one device's progress through a rollout.
type UpdateState string

const (
	UpdateOffered     UpdateState = "OFFERED"
	UpdateDownloading UpdateState = "DOWNLOADING"
	UpdateInstalling  UpdateState = "INSTALLING"
	UpdateSucceeded   UpdateState = "SUCCEEDED"
	UpdateFailed      UpdateState = "FAILED"
	UpdateRolledBack  UpdateState = "ROLLED_BACK"
)

// DefaultFailureThreshold is the share of failed attempts that halts a rollout.
//
// 10%. Bad firmware on field hardware is not a bad deploy you roll back from a
// console — every affected device needs somebody to drive to it. Stopping
// early costs a slow rollout; not stopping costs a season.
const DefaultFailureThreshold = 0.10

// MinAttemptsBeforeHalt is how many devices must have reported before the
// failure rate is trusted.
//
// Five. One failure out of one is a 100% failure rate and means nothing; a
// rollout that halts on the first device to have a flat battery never reaches
// the fleet.
const MinAttemptsBeforeHalt = 5

// FirmwareRollout is a staged update across a fleet.
type FirmwareRollout struct {
	ID       string `json:"id" db:"id"`
	TenantID string `json:"tenant_id" db:"tenant_id"`

	Fleet string     `json:"fleet" db:"fleet"`
	Kind  DeviceKind `json:"kind" db:"kind"`

	Version        string `json:"version" db:"version"`
	ArtifactURL    string `json:"artifact_url" db:"artifact_url"`
	ArtifactSHA256 string `json:"artifact_sha256" db:"artifact_sha256"`

	State RolloutState `json:"state" db:"state"`

	// StagePercent is how much of the fleet the rollout may reach so far.
	StagePercent int `json:"stage_percent" db:"stage_percent"`

	FailureThreshold float64 `json:"failure_threshold" db:"failure_threshold"`

	Offered   int `json:"offered" db:"offered"`
	Succeeded int `json:"succeeded" db:"succeeded"`
	Failed    int `json:"failed" db:"failed"`

	CreatedBy    string    `json:"created_by" db:"created_by"`
	CreatedAt    time.Time `json:"created_at" db:"created_at"`
	HaltedReason string    `json:"halted_reason" db:"halted_reason"`
}

// Validate checks a rollout can be started.
func (r *FirmwareRollout) Validate() error {
	if strings.TrimSpace(r.Version) == "" {
		return ErrMissingVersion
	}
	// Both, not either. A URL with no checksum means a device installs
	// whatever is served at that address, which is the difference between an
	// update channel and a way to brick a fleet.
	if strings.TrimSpace(r.ArtifactURL) == "" || strings.TrimSpace(r.ArtifactSHA256) == "" {
		return ErrMissingArtifact
	}
	if r.StagePercent < 1 || r.StagePercent > 100 {
		return ErrStageOutOfRange
	}
	if r.FailureThreshold <= 0 || r.FailureThreshold > 1 {
		r.FailureThreshold = DefaultFailureThreshold
	}
	return nil
}

// Advance widens a rollout to a larger share of the fleet.
//
// Forward only. Reducing the stage would not recall an update already
// installed — the firmware is on those devices — so a lower number would be a
// record that disagrees with the hardware.
func (r *FirmwareRollout) Advance(stagePercent int) error {
	if r.State == RolloutHalted || r.State == RolloutCompleted {
		return ErrRolloutNotRunning
	}
	if stagePercent < 1 || stagePercent > 100 {
		return ErrStageOutOfRange
	}
	if stagePercent < r.StagePercent {
		return ErrStageWentBackward
	}

	r.StagePercent = stagePercent
	r.State = RolloutInProgress
	if stagePercent == 100 {
		// Reaching 100% opens the rollout to the whole fleet; it completes
		// when the devices have reported, not when it is offered to them.
		r.State = RolloutInProgress
	}
	return nil
}

// RecordUpdate folds one device's report into the rollout and halts it if too
// many are failing.
//
// Returns whether the rollout halted on this report, so the caller can say so
// rather than leaving an operator to notice the state changed.
func (r *FirmwareRollout) RecordUpdate(state UpdateState, now time.Time) (halted bool) {
	switch state {
	case UpdateOffered:
		r.Offered++
	case UpdateSucceeded:
		r.Succeeded++
	case UpdateFailed, UpdateRolledBack:
		r.Failed++
	default:
		// Downloading and installing are progress, not outcomes.
		return false
	}

	if r.State == RolloutHalted || r.State == RolloutCompleted {
		return false
	}

	attempts := r.Succeeded + r.Failed
	if attempts >= MinAttemptsBeforeHalt {
		rate := float64(r.Failed) / float64(attempts)
		if rate >= r.FailureThreshold {
			r.State = RolloutHalted
			r.HaltedReason = fmt.Sprintf(
				"%d of %d devices failed (%.0f%%), at or above the %.0f%% threshold",
				r.Failed, attempts, rate*100, r.FailureThreshold*100,
			)
			return true
		}
	}

	if r.State == RolloutPending {
		r.State = RolloutInProgress
	}
	return false
}

// AcceptsUpdates reports whether devices may still take this rollout.
func (r *FirmwareRollout) AcceptsUpdates() bool {
	return r.State == RolloutPending || r.State == RolloutInProgress
}

// DeviceUpdate is one device's progress through a rollout.
type DeviceUpdate struct {
	DeviceID  string      `json:"device_id" db:"device_id"`
	RolloutID string      `json:"rollout_id" db:"rollout_id"`
	TenantID  string      `json:"tenant_id" db:"tenant_id"`
	State     UpdateState `json:"state" db:"state"`
	Detail    string      `json:"detail" db:"detail"`
	UpdatedAt time.Time   `json:"updated_at" db:"updated_at"`
}

// ListDevicesParams filters a device query.
type ListDevicesParams struct {
	TenantID string
	Fleet    string
	FarmID   string
	FieldID  string
	Kind     DeviceKind
	Status   DeviceStatus
	Limit    int
	Offset   int
}

// ListRolloutsParams filters a rollout query.
type ListRolloutsParams struct {
	TenantID string
	Fleet    string
	Limit    int
	Offset   int
}
