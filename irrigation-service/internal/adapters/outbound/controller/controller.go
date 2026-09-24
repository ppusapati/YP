// Package controller delivers irrigation commands to physical water
// controllers.
//
// The controllers have carried an Endpoint and a Protocol since the schema was
// written and nothing ever dialled either, so "turn on zone 3" has been a
// database row rather than a valve movement. These are the clients that make
// it one.
//
// Three protocols, because that is what the domain declares and they have
// nothing in common at the wire level: MQTT publishes to a broker and waits
// for the device to answer on its own topic, LoRaWAN enqueues a downlink at a
// network server and cannot know when the device will hear it, and Modbus
// opens a TCP socket and writes a coil.
//
// The shared discipline is about what an acknowledgement means. Every one of
// these transports offers something that looks like an ack and is not the
// valve moving: the broker's PUBACK, the network server's 200, the TCP write
// returning. Each client here is written so that ControllerAck.Accepted means
// the controller answered, and everything weaker is reported as what it is.
package controller

import (
	"context"
	"encoding/json"
	"fmt"
	"net/url"
	"strconv"
	"strings"
	"time"

	"p9e.in/samavaya/agriculture/irrigation-service/internal/domain"
	"p9e.in/samavaya/agriculture/irrigation-service/internal/ports/outbound"
)

// DefaultTimeout bounds a single send.
//
// Short, because it is held while an operator waits and because a controller
// that has not answered in ten seconds is not about to. The actuator treats a
// timeout as "may or may not have arrived", which is the truth and is why the
// command row is written before the send.
const DefaultTimeout = 10 * time.Second

// commandPayload is what a controller receives over the packet-based
// transports.
//
// CommandID first among the fields and first in importance: it is the
// idempotency key. These links are lossy, so a send that times out may or may
// not have arrived, and a retry carries the same id for the controller to
// recognise rather than opening the valve a second time.
type commandPayload struct {
	CommandID       string `json:"command_id"`
	Kind            string `json:"kind"`
	ZoneID          string `json:"zone_id"`
	DurationMinutes int32  `json:"duration_minutes"`
	IssuedAt        string `json:"issued_at"`
	// IssuedBy travels so that a controller with a local display can say who
	// asked, and so a packet capture is readable during a callout.
	IssuedBy string `json:"issued_by"`
}

func encodeCommand(cmd *domain.IrrigationCommand) ([]byte, error) {
	if cmd == nil {
		return nil, fmt.Errorf("command is required")
	}
	return json.Marshal(commandPayload{
		CommandID:       cmd.ID,
		Kind:            string(cmd.Kind),
		ZoneID:          cmd.ZoneID,
		DurationMinutes: cmd.DurationMinutes,
		IssuedAt:        cmd.IssuedAt.UTC().Format(time.RFC3339),
		IssuedBy:        cmd.IssuedBy,
	})
}

// ackPayload is what a controller sends back on its ack topic.
type ackPayload struct {
	CommandID string `json:"command_id"`
	Accepted  bool   `json:"accepted"`
	Reason    string `json:"reason"`
	Duplicate bool   `json:"duplicate"`
}

// decodeAck reads a controller's reply and checks it is about this command.
//
// The id check is not a formality. Several controllers share a broker and an
// operator can send two commands to one zone within a second of each other;
// without it, the first reply to arrive would be read as the answer to
// whichever command happened to be waiting, and a refusal could be recorded as
// an acceptance.
func decodeAck(raw []byte, commandID string) (*outbound.ControllerAck, error) {
	var payload ackPayload
	if err := json.Unmarshal(raw, &payload); err != nil {
		return nil, fmt.Errorf("controller sent an unreadable ack: %w", err)
	}
	if payload.CommandID != commandID {
		return nil, fmt.Errorf("controller acked %q while waiting for %q",
			payload.CommandID, commandID)
	}
	return &outbound.ControllerAck{
		Accepted:  payload.Accepted,
		Reason:    payload.Reason,
		Duplicate: payload.Duplicate,
	}, nil
}

// endpoint is a controller's Endpoint parsed into a target and its options.
//
// The column is one free-text field shared by three protocols, so each client
// reads it differently — a topic, a DevEUI, a host and port — and the query
// string carries whatever else that protocol needs. Parsing it in one place
// keeps a malformed endpoint a clear refusal rather than three different
// surprises.
type endpoint struct {
	target string
	opts   url.Values
}

func parseEndpoint(raw string) (endpoint, error) {
	raw = strings.TrimSpace(raw)
	if raw == "" {
		return endpoint{}, fmt.Errorf("controller has no endpoint; there is nowhere to send the command")
	}
	target, query, found := strings.Cut(raw, "?")
	if target == "" {
		return endpoint{}, fmt.Errorf("controller endpoint %q has no target", raw)
	}
	if !found {
		return endpoint{target: target, opts: url.Values{}}, nil
	}
	opts, err := url.ParseQuery(query)
	if err != nil {
		return endpoint{}, fmt.Errorf("controller endpoint %q has an unreadable option string: %w", raw, err)
	}
	return endpoint{target: target, opts: opts}, nil
}

// intOpt reads a numeric endpoint option, falling back to a default.
func (e endpoint) intOpt(key string, fallback int) (int, error) {
	raw := e.opts.Get(key)
	if raw == "" {
		return fallback, nil
	}
	v, err := strconv.Atoi(raw)
	if err != nil {
		return 0, fmt.Errorf("endpoint option %s=%q is not a number", key, raw)
	}
	return v, nil
}

// Registry routes a command to the client for its controller's protocol.
//
// A protocol with no client configured is refused by name — "no client is
// configured for protocol LORAWAN" — rather than falling back to whichever
// client happens to exist. A farm reached over LoRaWAN whose command quietly
// went out over MQTT would be a valve nobody could account for.
type Registry struct {
	clients map[domain.Protocol]outbound.ControllerClient
}

// NewRegistry builds a registry from the clients that are configured.
//
// An empty registry is legitimate and means a deployment with no hardware. It
// refuses every command, which is the honest behaviour: the alternative —
// accepting them and recording them as sent — is the pattern that makes a
// system look like it is irrigating when it is not.
func NewRegistry(clients map[domain.Protocol]outbound.ControllerClient) *Registry {
	if clients == nil {
		clients = map[domain.Protocol]outbound.ControllerClient{}
	}
	return &Registry{clients: clients}
}

// Protocols lists what this registry can reach, for logging at startup.
func (r *Registry) Protocols() []string {
	out := make([]string, 0, len(r.clients))
	for p := range r.clients {
		out = append(out, string(p))
	}
	return out
}

func (r *Registry) clientFor(c *domain.WaterController) (outbound.ControllerClient, error) {
	if c == nil {
		return nil, fmt.Errorf("no controller given")
	}
	client, ok := r.clients[c.Protocol]
	if !ok {
		return nil, fmt.Errorf("no client is configured for protocol %s (controller %s)",
			c.Protocol, c.ID)
	}
	return client, nil
}

// Send delivers a command through the client for its controller's protocol.
func (r *Registry) Send(
	ctx context.Context,
	c *domain.WaterController,
	cmd *domain.IrrigationCommand,
) (*outbound.ControllerAck, error) {
	client, err := r.clientFor(c)
	if err != nil {
		return nil, err
	}
	return client.Send(ctx, c, cmd)
}

// Status asks a controller what it is doing.
func (r *Registry) Status(ctx context.Context, c *domain.WaterController) (*outbound.ControllerStatus, error) {
	client, err := r.clientFor(c)
	if err != nil {
		return nil, err
	}
	return client.Status(ctx, c)
}

// registerOpt reads an optional register address from the endpoint.
//
// The bool separates "not configured" from register zero, which is a real and
// commonly used address — and getting that wrong would have every panel
// reporting whatever sits at register 0 as its water meter.
func (e endpoint) registerOpt(key string) (int, bool) {
	if e.opts.Get(key) == "" {
		return 0, false
	}
	v, err := e.intOpt(key, 0)
	if err != nil || v < 0 || v > 0xFFFF {
		return 0, false
	}
	return v, true
}

// floatOpt reads a scaling factor, which is rarely 1: water meters commonly
// count in tenths of a litre, in gallons, or in cubic metres, and the register
// alone does not say which.
func (e endpoint) floatOpt(key string, fallback float64) (float64, error) {
	raw := e.opts.Get(key)
	if raw == "" {
		return fallback, nil
	}
	v, err := strconv.ParseFloat(raw, 64)
	if err != nil {
		return 0, fmt.Errorf("endpoint option %s=%q is not a number", key, raw)
	}
	if v <= 0 {
		return 0, fmt.Errorf("endpoint option %s=%q must be positive", key, raw)
	}
	return v, nil
}
