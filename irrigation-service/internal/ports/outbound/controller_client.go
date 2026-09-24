package outbound

import (
	"context"

	"p9e.in/samavaya/agriculture/irrigation-service/internal/domain"
)

// ControllerClient delivers commands to a physical water controller.
//
// The controllers have carried an `Endpoint` and a `Protocol` since the schema
// was written and nothing has ever dialled either, so "turn on zone 3" has
// been a database row rather than a valve movement.
//
// A port rather than a concrete client because the three protocols in the
// domain — MQTT, LoRaWAN, Modbus — have nothing in common at the wire level,
// and because a deployment with no controllers should be a visible nil rather
// than a client that silently accepts commands.
type ControllerClient interface {
	// Send delivers one command and reports what the controller said.
	//
	// Must be idempotent on the command's ID: these links are lossy, a send
	// that times out may or may not have arrived, and a retry must not open
	// the valve a second time.
	Send(ctx context.Context, controller *domain.WaterController, cmd *domain.IrrigationCommand) (*ControllerAck, error)

	// Status asks a controller what it is doing.
	//
	// Needed because the service's belief about a valve and the valve's actual
	// position diverge — a command lost in transit, a controller rebooted
	// mid-run, a manual override at the panel. Reconciling against the device
	// is the only way to find out.
	Status(ctx context.Context, controller *domain.WaterController) (*ControllerStatus, error)
}

// ControllerAck is a controller's response to a command.
type ControllerAck struct {
	// Accepted is whether the controller took the command. A controller may
	// refuse for its own reasons — a local lockout, a low reservoir, a fault —
	// and that refusal is information, not an error.
	Accepted bool
	// Reason is the controller's explanation when it refuses.
	Reason string
	// Duplicate is set when the controller recognised the command id and did
	// nothing. Distinguished from Accepted so a retry does not look like a
	// second run in the logs or the daily total.
	Duplicate bool

	// Queued means the command was handed to a network that will deliver it
	// later, and the device itself has not answered.
	//
	// LoRaWAN forces this distinction into the open. A class A device only
	// listens in the short receive window after its own next uplink, so a
	// downlink is enqueued at the network server and may sit there for
	// minutes. The network server's 200 means "accepted for delivery", which
	// is not the valve moving — and recording it as an acceptance would put
	// "irrigation started" against a command still waiting in a queue.
	//
	// The same care applies to MQTT: a broker's PUBACK is the broker's, not
	// the device's, which is why the MQTT client waits for the controller to
	// answer on its own topic rather than treating the publish as the ack.
	Queued bool
}

// ControllerStatus is a controller's reported state.
type ControllerStatus struct {
	Online bool
	// Running is whether water is flowing now, as the controller sees it.
	Running bool
	// FlowRateLitersPerHour is the measured rate, where the hardware reports
	// one. Zero while a run is supposedly in progress is the signature of a
	// blocked line or a closed manual valve upstream.
	FlowRateLitersPerHour float64
	// HasFlowRate separates a measured zero from a panel with no flow sensor.
	// A zero rate mid-run is a blocked line and worth an alarm; no sensor is
	// not.
	HasFlowRate bool

	// VolumeTotalLiters is the controller's cumulative water meter, and it is
	// the only honest source of how much water a run applied.
	//
	// Read at the start of a run and again at the end, the difference is a
	// measurement. Everything else available here is arithmetic on a plan: a
	// nameplate flow rate times a duration produces a number that looks like
	// a meter reading and is not one, and a blocked line delivers nothing at
	// exactly that nameplate rate.
	//
	// Cumulative and monotonic, so it wraps. See domain.MeteredVolume.
	VolumeTotalLiters float64
	// HasVolumeTotal is false for a controller with no meter, and for
	// LoRaWAN, where there is no synchronous way to ask.
	HasVolumeTotal bool

	// FirmwareVersion and Fault are reported as the controller gives them.
	FirmwareVersion string
	Fault           string
}
