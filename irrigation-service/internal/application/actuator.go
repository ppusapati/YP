package application

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"time"

	p9errors "p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	"p9e.in/samavaya/agriculture/irrigation-service/internal/domain"
	"p9e.in/samavaya/agriculture/irrigation-service/internal/ports/outbound"
)

// The actuator turns a decision into a valve movement.
//
// Everything upstream of here produces advice. This is the part that acts on a
// real farm, so its job is mostly to decline: of the paths through Actuate
// below, most end in a refusal, and that is the intended shape.

// ZoneStateReader supplies what the interlocks need about a zone.
//
// Narrower than the full repository on purpose — an actuator that could write
// to the schedule store would eventually be given a reason to.
type ZoneStateReader interface {
	ZoneState(ctx context.Context, tenantID, zoneID string) (domain.ZoneState, error)
	ControllerForZone(ctx context.Context, tenantID, zoneID string) (*domain.WaterController, error)
}

// CommandRecorder persists commands and their outcomes.
//
// Every command is written before it is sent, not after. A send that times out
// leaves no record otherwise, and a valve that opened without a corresponding
// row is exactly the state nobody can reason about afterwards.
type CommandRecorder interface {
	RecordCommand(ctx context.Context, cmd *domain.IrrigationCommand) error
	RecordOutcome(ctx context.Context, commandID string, accepted bool, detail string) error
}

// Actuator issues commands to controllers.
type Actuator struct {
	zones      ZoneStateReader
	controller outbound.ControllerClient
	commands   CommandRecorder
	pub        outbound.EventPublisher
	log        *p9log.Helper
	now        func() time.Time
}

// NewActuator creates an actuator.
//
// controller may be nil, in which case every command is refused with a clear
// error. That is the honest behaviour for a deployment with no hardware: the
// alternative — accepting commands and recording them as sent — is the pattern
// that makes a system look like it is irrigating when it is not.
func NewActuator(
	zones ZoneStateReader,
	controller outbound.ControllerClient,
	commands CommandRecorder,
	pub outbound.EventPublisher,
	log p9log.Logger,
) *Actuator {
	return &Actuator{
		zones:      zones,
		controller: controller,
		commands:   commands,
		pub:        pub,
		log:        p9log.NewHelper(p9log.With(log, "component", "Actuator")),
		now:        time.Now,
	}
}

// Actuate issues one command after checking every interlock.
//
// Returns the command as recorded. A refusal is an error carrying the
// interlock's name, so a caller can tell a safety limit from a fault, and the
// log says which limit rather than "rejected".
func (a *Actuator) Actuate(ctx context.Context, cmd *domain.IrrigationCommand) (*domain.IrrigationCommand, error) {
	if cmd == nil {
		return nil, p9errors.BadRequest("INVALID_COMMAND", "command is required")
	}
	if cmd.ID == "" {
		cmd.ID = ulid.NewString()
	}
	if cmd.IssuedAt.IsZero() {
		cmd.IssuedAt = a.now()
	}

	if a.controller == nil {
		return nil, p9errors.ServiceUnavailable("CONTROLLER_UNAVAILABLE",
			"no controller client is configured; irrigation cannot be actuated")
	}

	controller, err := a.zones.ControllerForZone(ctx, cmd.TenantID, cmd.ZoneID)
	if err != nil {
		return nil, err
	}
	if controller == nil {
		return nil, p9errors.NotFound("CONTROLLER_NOT_FOUND",
			"this zone has no controller")
	}

	state, err := a.zones.ZoneState(ctx, cmd.TenantID, cmd.ZoneID)
	if err != nil {
		return nil, err
	}

	if err := domain.CheckInterlocks(cmd, state, a.now()); err != nil {
		var interlock *domain.InterlockError
		if errors.As(err, &interlock) {
			// Logged at warn rather than error: a refused command is the
			// safety system working, not a fault. A flood of them is a
			// problem, which is why the interlock name is a field.
			a.log.Warnw("msg", "command refused by interlock",
				"interlock", interlock.Interlock, "zone_id", cmd.ZoneID,
				"kind", cmd.Kind, "detail", interlock.Detail)
			return nil, p9errors.Conflict("INTERLOCK_"+interlock.Interlock, interlock.Detail)
		}
		return nil, p9errors.BadRequest("INVALID_COMMAND", err.Error())
	}

	// Recorded before sending, and against the box it is going to: a zone's
	// controller can be replaced, so a command that only names the zone cannot
	// say afterwards which device received it.
	cmd.ControllerID = controller.ID
	if err := a.commands.RecordCommand(ctx, cmd); err != nil {
		return nil, err
	}

	ack, sendErr := a.controller.Send(ctx, controller, cmd)
	switch {
	case sendErr != nil:
		// The command may or may not have arrived. The record already exists,
		// so a reconciliation against the controller can settle it; what must
		// not happen is reporting success.
		_ = a.commands.RecordOutcome(ctx, cmd.ID, false, sendErr.Error())
		a.log.Errorw("msg", "controller send failed", "zone_id", cmd.ZoneID,
			"command_id", cmd.ID, "error", sendErr)
		return nil, p9errors.ServiceUnavailable("CONTROLLER_SEND_FAILED",
			"the controller did not acknowledge the command")

	case ack != nil && ack.Duplicate:
		// A retry the controller recognised. Not a second run, and must not be
		// counted as one in the daily total.
		a.log.Infow("msg", "controller reported a duplicate command",
			"zone_id", cmd.ZoneID, "command_id", cmd.ID)
		_ = a.commands.RecordOutcome(ctx, cmd.ID, true, "duplicate")
		return cmd, nil

	case ack != nil && ack.Queued:
		// Handed to a network that will deliver it later; the device has not
		// answered. Recorded as its own outcome rather than as an acceptance,
		// because "irrigation started" against a command still sitting in a
		// LoRaWAN downlink queue is the kind of entry an operator later reads
		// as proof that water went on.
		//
		// Not an error either: enqueuing is the normal, correct outcome on
		// those networks, and failing the call would mean no unattended
		// irrigation on any class A device.
		_ = a.commands.RecordOutcome(ctx, cmd.ID, true,
			"queued for delivery; the controller has not confirmed it")
		a.log.Infow("msg", "irrigation command queued for delivery",
			"zone_id", cmd.ZoneID, "command_id", cmd.ID, "kind", cmd.Kind)
		a.emit(ctx, cmd)
		return cmd, nil

	case ack == nil || !ack.Accepted:
		detail := "controller refused the command"
		if ack != nil && ack.Reason != "" {
			detail = ack.Reason
		}
		// The controller refusing is information, not a fault: it may know
		// about a low reservoir or a local lockout that this service does not.
		_ = a.commands.RecordOutcome(ctx, cmd.ID, false, detail)
		return nil, p9errors.Conflict("CONTROLLER_REFUSED", detail)
	}

	_ = a.commands.RecordOutcome(ctx, cmd.ID, true, "")
	a.emit(ctx, cmd)
	a.log.Infow("msg", "irrigation command sent",
		"zone_id", cmd.ZoneID, "kind", cmd.Kind,
		"duration_minutes", cmd.DurationMinutes, "issued_by", cmd.IssuedBy)
	return cmd, nil
}

// ActuateFromReading turns a sensor reading into a command, if one is
// warranted.
//
// Returns (nil, nil) when no action is called for — a dry reading on a zone
// that irrigated an hour ago, a zone with automation off, a reading too old to
// act on. Those are the common cases and none of them is an error.
func (a *Actuator) ActuateFromReading(
	ctx context.Context,
	tenantID, zoneID string,
	moisture float64,
	threshold float64,
	readingAt time.Time,
	durationMinutes int32,
) (*domain.IrrigationCommand, error) {
	if moisture >= threshold {
		return nil, nil
	}

	// The failure this guards against is a sensor that has stopped reporting
	// while reading dry: without it, the last value justifies irrigation
	// forever and the field is watered on a measurement from last week.
	if domain.ReadingTooOld(readingAt, a.now(), domain.MaxReadingAge) {
		a.log.Warnw("msg", "reading too old to act on",
			"zone_id", zoneID, "reading_at", readingAt)
		return nil, nil
	}

	cmd := &domain.IrrigationCommand{
		ID:              ulid.NewString(),
		TenantID:        tenantID,
		ZoneID:          zoneID,
		Kind:            domain.CommandStart,
		DurationMinutes: durationMinutes,
		IssuedBy:        "system",
		IssuedAt:        a.now(),
		Reason: fmt.Sprintf("soil moisture %.3f below the threshold of %.3f at %s",
			moisture, threshold, readingAt.UTC().Format(time.RFC3339)),
	}

	out, err := a.Actuate(ctx, cmd)
	if err != nil {
		// An interlock refusing an automatic command is the normal case, not a
		// failure to report upward: a zone that irrigated an hour ago should
		// still be reading dry, and the rest interlock is what stops the
		// second run.
		var conflict *p9errors.Error
		if errors.As(err, &conflict) && conflict.Code == 409 {
			return nil, nil
		}
		return nil, err
	}
	return out, nil
}

// Stop closes a zone.
//
// Separate from Actuate's general path because stopping is never refused, and
// giving it its own entry point means no caller has to construct the command
// that turns water off correctly under pressure.
func (a *Actuator) Stop(ctx context.Context, tenantID, zoneID, issuedBy, reason string) (*domain.IrrigationCommand, error) {
	if reason == "" {
		reason = "stop requested"
	}
	return a.Actuate(ctx, &domain.IrrigationCommand{
		ID:       ulid.NewString(),
		TenantID: tenantID,
		ZoneID:   zoneID,
		Kind:     domain.CommandStop,
		IssuedBy: issuedBy,
		Reason:   reason,
	})
}

func (a *Actuator) emit(ctx context.Context, cmd *domain.IrrigationCommand) {
	if a.pub == nil {
		return
	}
	payload, err := json.Marshal(map[string]interface{}{
		"command_id":       cmd.ID,
		"tenant_id":        cmd.TenantID,
		"zone_id":          cmd.ZoneID,
		"kind":             string(cmd.Kind),
		"duration_minutes": cmd.DurationMinutes,
		"issued_by":        cmd.IssuedBy,
		"reason":           cmd.Reason,
	})
	if err != nil {
		a.log.Warnw("msg", "failed to encode command event", "command_id", cmd.ID, "error", err)
		return
	}

	// Best effort. A failure to publish must not make a valve that did open
	// look like one that did not.
	if err := a.pub.Publish(ctx, "agriculture.irrigation.command.sent", cmd.ID, payload); err != nil {
		a.log.Warnw("msg", "failed to publish command event", "command_id", cmd.ID, "error", err)
	}
}

// MeterReading asks a zone's controller what its water meter and flow sensor
// currently read.
//
// On the actuator because it is the only thing here that talks to controllers,
// and separate from Actuate because a reading is taken twice per run — once
// when the valve opens and once when it closes — and the difference between
// those two is the only measurement of volume this platform can take.
//
// Returns nil, nil when there is nothing to ask: no controller client, no
// controller on the zone. The caller records the run as unmetered, which is
// the honest outcome and is distinct from a meter that read zero.
func (a *Actuator) MeterReading(ctx context.Context, tenantID, zoneID string) (*outbound.ControllerStatus, error) {
	if a.controller == nil {
		return nil, nil
	}
	controller, err := a.zones.ControllerForZone(ctx, tenantID, zoneID)
	if err != nil {
		return nil, err
	}
	if controller == nil {
		return nil, nil
	}
	return a.controller.Status(ctx, controller)
}
